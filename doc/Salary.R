
library(choroplethr)
library(dplyr)
library(ggplot2)
library(data.table)

#read data from population dataset
colsToKeep <- c("ESR", "SCHOL", "WAGP","ST","SEX","MSP","PWGTP")
data1 <- fread("/Users/yiliu/Desktop/untitled folder/ss13pusa.csv", select=colsToKeep )
data2 <- fread("/Users/yiliu/Desktop/untitled folder/ss13pusb.csv", select=colsToKeep )
popudata <- rbind(data1, data2)

#filter the data
popudata <- popudata %>%
  na.omit()%>%
  filter(MSP %in% c(3,4,5,6))

Male <- popudata %>%
  filter(SEX %in% c(1)) %>%
  group_by(ST)

Female <- popudata %>%
  filter(SEX %in% c(2)) %>%
  group_by(ST)

#break the WAGP (lower=0, upper=100000, by=20000)
popudata$WAGP[popudata$WAGP %in% c(0:20000)] <- "0-2"
popudata$WAGP[popudata$WAGP %in% c(20000:40000)] <- "2-4"
popudata$WAGP[popudata$WAGP %in% c(40000:60000)] <- "4-6"
popudata$WAGP[popudata$WAGP %in% c(60000:80000)] <- "6-8"
popudata$WAGP[popudata$WAGP %in% c(80000:100000)] <- "8-10"
popudata$WAGP[popudata$WAGP %in% c(100000:1000000)] <- "over 10"

#sum the weights
popudata<- summarise(popudata,WAGP=WAGP,SEX=SEX,PWGTP=PWGTP)
popudata <- popudata[, lapply(.SD,sum), by=list(SEX,WAGP)]

#rename the SEX
popudata$SEX[popudata$SEX==1] <- "male"
popudata$SEX[popudata$SEX==2] <- "female"

#plot chart for Count VS Salary
salaryplot <- ggplot(popudata,aes(x=WAGP, y=PWGTP,fill=factor(SEX))) +geom_bar(stat="identity",position="dodge")
salaryplot <- salaryplot +ylab("count")+xlab("Annual Salary (in 10K)")+ggtitle("Salary for Single")
salaryplot


#state the ST codes
stateCode = "ST,State
 1,Alabama/AL
2,Alaska/AK
4,Arizona/AZ
5,Arkansas/AR
6,California/CA
8,Colorado/CO
9,Connecticut/CT
10,Delaware/DE
11,DistrictofColumbia/DC
12,Florida/FL
13,Georgia/GA
15,Hawaii/HI
16,Idaho/ID
17,Illinois/IL
18,Indiana/IN
19,Iowa/IA
20,Kansas/KS
21,Kentucky/KY
22,Louisiana/LA
23,Maine/ME
24,Maryland/MD
25,Massachusetts/MA
26,Michigan/MI
27,Minnesota/MN
28,Mississippi/MS
29,Missouri/MO
30,Montana/MT
31,Nebraska/NE
32,Nevada/NV
33,NewHampshire/NH
34,NewJersey/NJ
35,NewMexico/NM
36,NewYork/NY
37,NorthCarolina/NC
38,NorthDakota/ND
39,Ohio/OH
40,Oklahoma/OK
41,Oregon/OR
42,Pennsylvania/PA
44,RhodeIsland/RI
45,SouthCarolina/SC
46,SouthDakota/SD
47,Tennessee/TN
48,Texas/TX
49,Utah/UT
50,Vermont/VT
51,Virginia/VA
53,Washington/WA
54,WestVirginia/WV
55,Wisconsin/WI
56,Wyoming/WY
72,PuertoRico/PR"
statecode <- fread(stateCode)

#use the weight calculating average annual salary for single male and female
FemaleWAGP <- summarise(Female, average=sum(as.numeric(WAGP*PWGTP))/sum(PWGTP))
MaleWAGP <- summarise(Male, average=sum(as.numeric(WAGP*PWGTP))/sum(PWGTP))

MaleWAGP <- left_join(MaleWAGP , statecode, by.x=c("ST"))
FemaleWAGP <- left_join(FemaleWAGP , statecode, by.x=c("ST"))
MaleWAGP$gender <- c("Male")
FemaleWAGP$gender <- c("Female")

Salary <- rbind(MaleWAGP,FemaleWAGP)

#plot Average Annual Salary for Male/Female by States
AverageSal <- ggplot(Salary,aes(x=State, y=average,fill=factor(gender)))+geom_bar(stat="identity",position="dodge")
AverageSal <- AverageSal +ylab("Average Salary") +xlab("State") +ggtitle(paste("Average Salary by State")) 
AverageSal <- AverageSal +theme(axis.text.x = element_text(angle = 30, hjust = 1),panel.background = element_rect(fill = 'white' ))
AverageSal




