From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [5/5]
Date: Fri, 18 Dec 2009 12:30:55 +0100
Message-ID: <4B2B67EF.6030507@yahoo.it>
References: <4B2B5A26.8050400@uniroma2.it> <4B2B5A65.1060300@uniroma2.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010206010607030609050702"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:19527 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbZLRLa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 06:30:58 -0500
Received: by fg-out-1718.google.com with SMTP id 19so1329015fgg.1
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 03:30:56 -0800 (PST)
In-Reply-To: <4B2B5A65.1060300@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010206010607030609050702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

patch 5/5 : iproute2-2.6.29-1/tc/q_netem.c


--------------010206010607030609050702
Content-Type: text/plain;
 name="tc_patch_5_of_5"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="tc_patch_5_of_5"

diff -uNr iproute2-2.6.29-1/tc/q_netem.c iproute2-2.6.29-1-netem/tc/q_netem.c
--- iproute2-2.6.29-1/tc/q_netem.c	2009-03-24 23:40:54.000000000 +0100
+++ iproute2-2.6.29-1-netem/tc/q_netem.c	2009-12-11 16:41:14.766468716 +0100
@@ -7,7 +7,6 @@
  *		2 of the License, or (at your option) any later version.
  *
  * Authors:	Stephen Hemminger <shemminger@osdl.org>
- *
  */
 
 #include <stdio.h>
@@ -29,9 +28,19 @@
 {
 	fprintf(stderr,
 "Usage: ... netem [ limit PACKETS ] \n" \
+"                 [ logging LEVEL ] \n" \
+"		  [ query ] \n" \
 "                 [ delay TIME [ JITTER [CORRELATION]]]\n" \
 "                 [ distribution {uniform|normal|pareto|paretonormal} ]\n" \
 "                 [ drop PERCENT [CORRELATION]] \n" \
+"		  [ loss_GI ploss [burst_length [density [pisol [good_burst_length]]]]] \n" \
+"		  [ loss_GI_tran p13 p31 [p32 p23 [p14]]]  \n" \
+"		  [ loss_bern p ] \n" \
+"		  [ loss_gilb_4s p r [1-h]] \n" \
+"		  [ loss_gilbell_4s p r [1-h [1-k]]] \n" \
+"		  [ loss_gilb p r [1-h]] \n" \
+"		  [ loss_gilbell p r [1-h [1-k]]] \n" \
+"                 [ loss_pattern [filename [repetitions]]] \n" \
 "                 [ corrupt PERCENT [CORRELATION]] \n" \
 "                 [ duplicate PERCENT [CORRELATION]]\n" \
 "                 [ reorder PRECENT [CORRELATION] [ gap DISTANCE ]]\n");
@@ -138,6 +147,10 @@
 
 	memset(&opt, 0, sizeof(opt));
 	opt.limit = 1000;
+	opt.query = 0; 
+	opt.logging = 0; 
+	opt.pattern_length = 0;
+	opt.pattern_repetitions = 0; 
 	memset(&cor, 0, sizeof(cor));
 	memset(&reorder, 0, sizeof(reorder));
 	memset(&corrupt, 0, sizeof(corrupt));
@@ -150,6 +163,14 @@
 				explain1("limit");
 				return -1;
 			}
+		} else if (matches(*argv, "logging") == 0) {		
+			NEXT_ARG();
+			if (get_size(&opt.logging, *argv)) {
+				explain1("logging");
+				return -1;
+			}
+		} else if (matches(*argv, "query") == 0) {		
+			opt.query=1;			
 		} else if (matches(*argv, "latency") == 0 ||
 			   matches(*argv, "delay") == 0) {
 			NEXT_ARG();
@@ -189,6 +210,506 @@
 					return -1;
 				}
 			}
+		} else if (matches(*argv, "loss_GI") == 0)  {		
+			NEXT_ARG();
+
+			double p13=0;
+			double p31=1;
+			double p32=0;
+			double p23=1;
+			double p14=0;
+			double ploss=0;
+			double burst_length=1;
+			double rho=1;
+			double pisol=0;
+			double good_burst_length=0;
+
+			opt.algorithm=0;	//algorithm 0 is GI, 1 is gilbell
+			
+			ploss=strtod(*argv,(char **)NULL)/100;
+
+			if (NEXT_IS_NUMBER()) {			
+			NEXT_ARG();
+			burst_length=strtod(*argv,(char **)NULL);
+			
+			if (NEXT_IS_NUMBER()) {
+			NEXT_ARG();			
+			rho=strtod(*argv,(char **)NULL)/100;
+			
+			if (ploss>rho) {
+			printf("\nError: ploss>density \n");
+			break;
+			}
+			
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			pisol=strtod(*argv,(char **)NULL)/100;
+			
+			if (pisol>ploss) {
+			printf("\nError: pisol>ploss \n");
+			break;
+			}
+
+			if (ploss>(rho-pisol*(rho-1))) {
+			printf("\nError: ploss>density-pisol(density-1) \n");
+			break;
+			}
+			
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			good_burst_length=strtod(*argv,(char **)NULL);
+			if (good_burst_length>burst_length) {printf("\nError: good burst length>burst length \n ");
+			break;
+							}
+						}		
+					}
+				}
+			}
+					
+			if(burst_length==0) {
+			p13=ploss;
+			p31=1-ploss;
+			}
+			
+			else if((burst_length!=0) & (rho==1) & (pisol==0)) {
+			p13=ploss/(burst_length*(1-ploss));
+			p31=1/burst_length;
+			} 
+			
+			else if ((burst_length!=0) & (rho!=1) & (pisol==0)) {
+			p13=(-ploss)/(burst_length*ploss-burst_length*rho);
+			p31=1/(burst_length*rho);
+			}
+			
+			else if ((burst_length!=0) & (rho!=1) & (pisol!=0)) {
+			p13=(pisol-ploss)/(burst_length*(pisol-1)*(rho-ploss));
+			p31=1/(burst_length*rho);
+			p14=pisol/(1-pisol);
+			}
+				
+			if((burst_length!=0) & (rho!=1))	{
+			
+				if(good_burst_length==0)	{
+				p23=(burst_length*rho-1) / (burst_length-1);
+				p32=(1+rho*rho*burst_length-rho-burst_length*rho) / (rho-rho*burst_length);
+							        					}				
+				else	{
+				p23=1/good_burst_length;
+				p32=(1-rho) / (rho*good_burst_length);				
+					}	
+					
+								}
+					
+			if (burst_length==0) burst_length=1/p31;						
+						
+			printf("\nTransition probabilities are:\n ");
+			printf("--------------------------------");
+			printf("\np13 is %.3f%% ", 100*p13);
+			printf("\np31 is %.3f%% ", 100*p31);
+			printf("\np32 is %.3f%% ", 100*p32);
+			printf("\np23 is %.3f%% ", 100*p23);
+			printf("\np14 is %.3f%%\n ", 100*p14);
+			
+			printf("\nGI (General and Intuitive) parameters will be: \n");
+			printf("--------------------------------");
+			printf("\nploss is %.3f%% ", 100*ploss);
+			printf("\nburst length is %.3f", burst_length);
+			printf("\nburst density is %.3f%% ", 100*rho);
+			printf("\nisolated ploss is %.3f%% ", 100*pisol);
+			printf("\ngood burst length is %.3f\n ", good_burst_length);
+
+			if(opt.query==0)	{
+			opt.p13=4294967295u*p13;
+			opt.p31=4294967295u*p31;
+			opt.p32=4294967295u*p32;
+			opt.p23=4294967295u*p23;
+			opt.p14=4294967295u*p14;			
+			}
+			
+			if(opt.query==1) return -1;	
+
+		} else if (matches(*argv, "loss_GI_tran") == 0)  {
+
+			double p13=0;
+			double p31=1;
+			double p32=0;
+			double p23=1;
+			double p14=0;
+			double ploss;
+			double burst_length;
+			double rho;
+			double pisol;
+			double good_burst_length;
+
+			opt.algorithm=0; 	//algorithm 0 is 4-state, 1 is gilbell
+
+			NEXT_ARG();
+			p13=strtod(*argv,(char **)NULL)/100;
+
+			if (NEXT_IS_NUMBER()) {			
+			NEXT_ARG();
+			p31=strtod(*argv,(char **)NULL)/100;
+			if (NEXT_IS_NUMBER()) {
+			NEXT_ARG();
+			p32=strtod(*argv,(char **)NULL)/100;
+			if (NEXT_IS_NUMBER()) {
+			NEXT_ARG();
+			p23=strtod(*argv,(char **)NULL)/100;
+			if (NEXT_IS_NUMBER()) {
+			NEXT_ARG();
+			p14=strtod(*argv,(char **)NULL)/100;
+			}
+			}
+			}
+			}
+
+			else p31=1-p13;
+			
+			printf("\nTransition probabilities are:\n ");
+			printf("--------------------------------");
+			printf("\np13 is %.3f%% ", 100*p13);
+			printf("\np31 is %.3f%% ", 100*p31);
+			printf("\np32 is %.3f%% ", 100*p32);
+			printf("\np23 is %.3f%% ", 100*p23);
+			printf("\np14 is %.3f%%\n ", 100*p14);
+
+			ploss=(p13*p23+p14*p23*p31) / (p13*p23+p23*p31+p14*p23*p31+p13*p32);
+			burst_length=(p32+p23) / (p23*p31);
+			rho=(p13*p23) / (p13*p23+p13*p32);
+			pisol=(p14*p23*p31) / (p14*p23*p31+p23*p31);
+			good_burst_length=1/p23;
+
+			printf("\nGI (General and Intuitive) parameters will be: \n");
+			printf("--------------------------------");
+			printf("\nploss is %.3f%%", 100*ploss);
+			printf("\nburst length is %.3f", burst_length);
+			printf("\nburst density is %.3f%% ", 100*rho);
+			printf("\nisolated ploss is %.3f%% ", 100*pisol);
+			printf("\ngood burst length is %.3f\n ", good_burst_length);
+
+			if(opt.query==0)	{
+			opt.p13=4294967295u*p13;
+			opt.p31=4294967295u*p31;
+			opt.p32=4294967295u*p32;
+			opt.p23=4294967295u*p23;
+			opt.p14=4294967295u*p14;			
+			}
+			
+			if(opt.query==1) return -1;
+			
+		} else if (matches(*argv, "loss_gilb") == 0)  {
+			
+			double p=0;
+			double r=0;
+			double h=0;
+									
+			opt.algorithm=1;	//algorithm 1 is gilbell
+					
+			NEXT_ARG();
+			p=strtod(*argv,(char **)NULL)/100;
+			
+			NEXT_ARG();
+			r=strtod(*argv,(char **)NULL)/100;
+						
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			h=(100-strtod(*argv,(char **)NULL))/100;						
+			}
+
+			printf("\nGilbert parameters will be: \n");
+			printf("--------------------------------");
+			printf("\np is %.3f%% ", 100*p);
+			printf("\nr is %.3f%%", 100*r);
+			printf("\n1-h is %.3f%%\n", 100*(1-h));	
+			
+			opt.gilb_p=4294967295u*p;
+			opt.gilb_r=4294967295u*r;
+			opt.gilb_h=4294967295u*h;
+														
+		} else if (matches(*argv, "loss_gilbell") == 0)  {
+			
+			double p=0;
+			double r=0;
+			double h=0;
+			double k=1;
+			
+			opt.algorithm=1;	//algorithm 1 is gilbell
+					
+			NEXT_ARG();
+			p=strtod(*argv,(char **)NULL)/100;
+			
+			NEXT_ARG();
+			r=strtod(*argv,(char **)NULL)/100;
+						
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			h=(100-strtod(*argv,(char **)NULL))/100;
+						
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			k=(100-strtod(*argv,(char **)NULL))/100;			
+						}
+						}
+
+			printf("\nGilbert-Elliot parameters will be: \n");
+			printf("--------------------------------");
+			printf("\np is %.3f%% ", 100*p);
+			printf("\nr is %.3f%%", 100*r);
+			printf("\n1-h is %.3f%% ", 100*(1-h));
+			printf("\n1-k is %.3f%%\n", 100*(1-k));		
+			
+			opt.gilb_p=4294967295u*p;
+			opt.gilb_r=4294967295u*r;
+			opt.gilb_h=4294967295u*h;
+			opt.gilb_k=4294967295u*k;		
+
+		} else if (matches(*argv, "loss_bern") == 0)  {		
+			
+			double p=0;
+			double r=0;
+			double ploss=0;
+			double burst_length=1;
+			double p13=0;
+			double p31=0;
+			
+			opt.algorithm=0;	//algorithm 0 is 4-state, 1 is gilbell
+					
+			NEXT_ARG();
+			p=strtod(*argv,(char **)NULL)/100;
+			r=1-p;
+			
+			ploss=p/(p+r);
+			burst_length=1/r;
+			
+			p13=p;
+			p31=r;
+
+			printf("\nTransition probabilities are:\n ");
+			printf("--------------------------------");
+			printf("\np13 is %.3f%% ", 100*p13);
+			printf("\np31 is %.3f%% ", 100*p31);
+			printf("\np32 is 0.000%% ");
+			printf("\np23 is 100.000%% ");
+			printf("\np14 is 0.000%%\n ");
+			
+			printf("\nGI (General and Intuitive) parameters will be: \n");
+			printf("--------------------------------");
+			printf("\nploss is %.3f%% ", 100*ploss);
+			printf("\nburst length is %.3f", burst_length);
+			printf("\nburst density is 100.000%% ");
+			printf("\nisolated ploss is 0.000%% ");
+			printf("\ngood burst length is 1.000%%\n "); 
+
+			if(opt.query==0)	{
+			opt.p13=4294967295u*p13;
+			opt.p31=4294967295u*p31;
+			opt.p32=0;
+			opt.p23=4294967295u;
+			opt.p14=0;			
+			}
+			
+			if(opt.query==1) return -1;			
+
+		} else if (matches(*argv, "loss_gilb_4s") == 0)  {
+			double p=0;
+			double r=0;
+			double h=0;
+			double ploss=0;
+			double burst_length=1;
+			double rho=1;
+			double p13=0;
+			double p31=1;
+			double p23=1;
+			double p32=0;
+			
+			opt.algorithm=0;	//algorithm 0 is 4-state, 1 is gilbell
+					
+			NEXT_ARG();
+			p=strtod(*argv,(char **)NULL)/100;
+			
+			NEXT_ARG();
+			r=strtod(*argv,(char **)NULL)/100;						
+			
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			h=(100-strtod(*argv,(char **)NULL))/100;
+						
+						}
+
+			ploss=(r-+p-h*p)/(p+r);
+			burst_length=(1/(r-r*h))*((h*h*(1-h+2*r*h*h-6*r*h+2*r))+(2*h*(1-h)*(1-h+r*h*h-3*h*r+r))+((1-h)*(1-h)*(1-h)));
+			
+			if(h!=0) rho=(1-h)/(r*burst_length);
+			else rho=1;
+	
+			p13=(-ploss)/(burst_length*(-rho+ploss));
+			p31=1/(burst_length*rho);
+
+			if (rho<1)	{	
+        		p32=(1+rho*rho*burst_length-rho-burst_length*rho) / (rho-rho*burst_length);
+			p23=(burst_length*rho-1) / (burst_length-1);			
+			}
+
+			else 	{
+			p32=0;
+			p23=1;
+			}
+
+			printf("\nTransition probabilities are:\n ");
+			printf("--------------------------------");
+			printf("\np13 is %.3f%% ", 100*p13);
+			printf("\np31 is %.3f%% ", 100*p31);
+			printf("\np32 is %.3f%% ", 100*p32);
+			printf("\np23 is %.3f%% ", 100*p23);
+			printf("\np14 is 0.000%%\n");
+			
+			printf("\nGI (General and Intuitive) parameters will be: \n");
+			printf("--------------------------------");
+			printf("\nploss is %.3f%% ", 100*ploss);
+			printf("\nburst length is %.3f", burst_length);
+			printf("\nburst density is %.3f%% ", 100*rho);
+			printf("\nisolated ploss is 0.000%% ");
+			printf("\ngood burst length is %.3f\n ", 1/p23); 
+
+			if(opt.query==0)	{
+			opt.p13=4294967295u*p13;
+			opt.p31=4294967295u*p31;
+			if(rho!=1) {
+			opt.p32=4294967295u*p32;
+			opt.p23=4294967295u*p23;
+			}
+			else {
+			opt.p32=0;
+			opt.p23=4294967295u;
+			}
+						}	
+			
+			if(opt.query==1) return -1;	
+
+		} else if (matches(*argv, "loss_gilbell_4s") == 0)  {
+			
+			double p=0;
+			double r=0;
+			double h=0;
+			double k=1;
+			double ploss=0;
+			double burst_length=1;
+			double rho=1;
+			double pisol=0;	
+			double p13=0;
+			double p31=1;
+			double p23=1;
+			double p32=0;
+			double p14=0;
+
+			opt.algorithm=0;	//algoritnm 1 is gilbell
+					
+			NEXT_ARG();
+			p=strtod(*argv,(char **)NULL)/100;
+			
+			NEXT_ARG();
+			r=strtod(*argv,(char **)NULL)/100;
+						
+			
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			h=(100-strtod(*argv,(char **)NULL))/100;
+						
+			if (NEXT_IS_NUMBER())	{
+			NEXT_ARG();
+			k=(100-strtod(*argv,(char **)NULL))/100;
+			
+						}
+						}
+
+			ploss=(r-k*r+p-h*p)/(p+r);
+			burst_length=(1/(r-r*h))*((h*h*(1-h+2*r*h*h-6*r*h+2*r))+(2*h*(1-h)*(1-h+r*h*h-3*h*r+r))+((1-h)*(1-h)*(1-h)));
+			
+			if(h!=0) rho=(1-h)/(r*burst_length);
+			else rho=1;
+	
+			if(k!=1) pisol=1-k;
+			else pisol=0;
+	
+			p13=(pisol-ploss)/(burst_length*(pisol*(rho-1)-rho+ploss));
+			p31=1/(burst_length*rho);
+
+			if (rho<1)	{	
+        		p32=(1+rho*rho*burst_length-rho-burst_length*rho) / (rho-rho*burst_length);
+			p23=(burst_length*rho-1) / (burst_length-1);			
+			}
+
+			else 	{
+			p32=0;
+			p23=1;
+			}
+
+			if (pisol!=0) p14=(pisol) / (1-pisol);
+			else p14=0;			
+			
+			printf("\nTransition probabilities are:\n ");
+			printf("--------------------------------");
+			printf("\np13 is %.3f%% ", 100*p13);
+			printf("\np31 is %.3f%% ", 100*p31);
+			printf("\np32 is %.3f%% ", 100*p32);
+			printf("\np23 is %.3f%% ", 100*p23);
+			printf("\np14 is %.3f%%\n ", 100*p14);
+			
+			printf("\nGI (General and Intuitive) parameters will be: \n");
+			printf("--------------------------------");
+			printf("\nploss is %.3f%% ", 100*ploss);
+			printf("\nburst length is %.3f", burst_length);
+			printf("\nburst density is %.3f%% ", 100*rho);
+			printf("\nisolated ploss is %.3f%% ", 100*pisol);
+			printf("\ngood burst length is %.3f\n ", 1/p23); 
+
+			if(opt.query==0)	{
+			opt.p13=4294967295u*p13;
+			opt.p31=4294967295u*p31;
+			if(rho!=1) {
+			opt.p32=4294967295u*p32;
+			opt.p23=4294967295u*p23;
+			}
+			else {
+			opt.p32=0;
+			opt.p23=4294967295u;
+			}
+			if(pisol>0) opt.p14=4294967295u*p14;
+			else opt.p14=0;		
+						}
+						
+			if(opt.query==1) return -1;				
+					
+		} else if (matches(*argv, "loss_pattern") == 0)  {	//LOSS PATTERN		
+			NEXT_ARG();
+						
+			int i; 
+					
+			FILE *sequence;
+			
+			sequence=fopen(*argv, "r");
+			
+			if (sequence == NULL) {
+				printf("Could not open the file %s \n", *argv);
+				exit(1);  } 				
+
+			fseek(sequence, 0, SEEK_END);
+			fgetpos(sequence, &opt.pattern_length);
+			rewind(sequence);
+
+			opt.user_pattern=malloc(opt.pattern_length*sizeof(int));
+			opt.pattern_repetitions=0;  			
+
+			for(i=1; i<opt.pattern_length; i++) {
+			if(fgetc(sequence)=='1') opt.user_pattern[i-1]=1;			
+			else opt.user_pattern[i-1]=0; }
+
+  			fclose(sequence);
+   			
+   			if (NEXT_IS_NUMBER()) {			
+			NEXT_ARG();
+			opt.pattern_repetitions=strtod(*argv,(char **)NULL);
+						}
 		} else if (matches(*argv, "reorder") == 0) {
 			NEXT_ARG();
 			present[TCA_NETEM_REORDER] = 1;
@@ -344,6 +865,46 @@
 	}
 
 	fprintf(f, "limit %d", qopt.limit);
+	if(qopt.logging!=0) fprintf(f, " logging %d", qopt.logging); 
+	if(qopt.pattern_length!=0) fprintf(f, " pattern_length %d", qopt.pattern_length);
+	if(qopt.pattern_repetitions!=0) fprintf(f, " pattern_repetitions %d", qopt.pattern_repetitions);
+	int j;
+	for (j=1; j<qopt.pattern_length; j++) {
+	fprintf(f, " pattern element %d is %d\n", j-1, qopt.user_pattern[j-1]);
+						}
+	
+	if (qopt.latency) {
+		fprintf(f, " delay %s", sprint_ticks(qopt.latency, b1));
+
+		if (qopt.jitter) {
+			fprintf(f, "  %s", sprint_ticks(qopt.jitter, b1));
+			if (cor && cor->delay_corr)
+				fprintf(f, " %s", sprint_percent(cor->delay_corr, b1));
+		}
+	}
+
+	if (qopt.loss) {
+		fprintf(f, " loss %s", sprint_percent(qopt.loss, b1));
+		if (cor && cor->loss_corr)
+			fprintf(f, " %s", sprint_percent(cor->loss_corr, b1));
+	}
+	
+	if (qopt.p13) {								
+		fprintf(f, " p13 %s", sprint_percent(qopt.p13, b1));
+		fprintf(f, " p31 %s", sprint_percent(qopt.p31, b1));
+		fprintf(f, " p32 %s", sprint_percent(qopt.p32, b1));
+		fprintf(f, " p23 %s", sprint_percent(qopt.p23, b1));
+		fprintf(f, " p14 %s", sprint_percent(qopt.p14, b1));
+			}	
+			
+	if (qopt.gilb_p) {								
+		fprintf(f, " p %s", sprint_percent(qopt.gilb_p, b1));
+		fprintf(f, " r %s", sprint_percent(qopt.gilb_r, b1));
+		fprintf(f, " h %s", sprint_percent(qopt.gilb_h, b1));
+		if (qopt.gilb_k) fprintf(f, " k %s", sprint_percent(qopt.gilb_k, b1));
+			}		
+
+	fprintf(f, "limit %d", qopt.limit);
 
 	if (qopt.latency) {
 		fprintf(f, " delay %s", sprint_ticks(qopt.latency, b1));

--------------010206010607030609050702--
