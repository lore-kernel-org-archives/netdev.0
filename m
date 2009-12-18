From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [2/5]
Date: Fri, 18 Dec 2009 12:24:38 +0100
Message-ID: <4B2B6676.301@yahoo.it>
References: <4B2B5A26.8050400@uniroma2.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040200060308000902030600"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:42767 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZLRLYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 06:24:42 -0500
Received: by fxm21 with SMTP id 21so2698745fxm.21
        for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 03:24:40 -0800 (PST)
In-Reply-To: <4B2B5A26.8050400@uniroma2.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040200060308000902030600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

patch 2/5 : linux-2.6.32/net/sched/sch_netem.c

--------------040200060308000902030600
Content-Type: text/plain;
 name="netem_patch_2_of_5"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="netem_patch_2_of_5"

diff -uNr linux-2.6.32/net/sched/sch_netem.c linux-2.6.32-netem/net/sched/sch_netem.c
--- linux-2.6.32/net/sched/sch_netem.c	2009-12-03 04:51:21.000000000 +0100
+++ linux-2.6.32-netem/net/sched/sch_netem.c	2009-12-11 13:06:11.477439585 +0100
@@ -24,6 +24,11 @@
 #include <net/pkt_sched.h>
 
 #define VERSION "1.2"
+static int num_of_drops = 0;	     //GI model-number of dropped packets
+static int num_of_transmissions = 0; //GI model-numberof transmitted packets
+static int chain_state;	     	     //GI Model-Markov chain state
+static int pattern_counter=0;	     //deterministic pattern counter
+static int repetitions_done=0;	     //deterministc pattern repetitions counter
 
 /*	Network Emulation Queuing algorithm.
 	====================================
@@ -62,6 +67,21 @@
 	u32 duplicate;
 	u32 reorder;
 	u32 corrupt;
+	u32 p13;	
+	u32 p31;	
+	u32 p23;	
+	u32 p32;	
+	u32 p14;
+	u32 gilb_p;
+	u32 gilb_r;		
+	u32 gilb_h;		
+	u32 gilb_k;	
+	u32 algorithm;
+	u32 logging; 
+	u32 query; 
+	u16 pattern_length;
+	u32 pattern_repetitions;
+	u32 *kernel_pattern;
 
 	struct crndstate {
 		u32 last;
@@ -151,6 +171,7 @@
  * 	NET_XMIT_DROP: queue length didn't change.
  *      NET_XMIT_SUCCESS: one skb was queued.
  */
+
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -160,6 +181,9 @@
 	int ret;
 	int count = 1;
 
+	u32 GI_random; 		     //GI loss model random number
+	u32 gilbell_random; 	     //Gilbert-Elliot loss model random number
+	
 	pr_debug("netem_enqueue skb=%p\n", skb);
 
 	/* Random duplication */
@@ -170,6 +194,157 @@
 	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
 		--count;
 
+	/* General and Intuitive loss generator, Gilbert-Elliot generator, deterministic pattern
+	====================================
+        
+	Sources: [1] S. Salsano, F. Ludovici, A. Ordine: "Definition of a general and
+	intuitive loss model for packet networks and its implementation in the Netem
+	module in the Linux kernel", July 2009 available at 
+	http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetEm2#TechnicalReports
+
+	 ----------------------------------------------------------------
+
+	 This is an algorithm for loss generation based on the 4-state Markov chain adopted
+         in the GI (General and Intuitive) loss model. A random number (GI_random) is extracted
+         and compared to the transition probabilities to decide if a packet will be lost or not.
+         State 1 is related to successfully transmitted packets within a gap period,  State 4 to 
+         isolated losses within a gap period, State 3 to lost packets withing a burst, State 2 to 
+	 successfully transmitted packets within a burst. 
+        */
+
+    	if (q->algorithm==0) {
+
+	GI_random=net_random(); 
+    	
+    	switch (chain_state) {	
+   	    case 1:
+		num_of_transmissions++;
+		if((0<GI_random)&&(GI_random<q->p13))	{
+			chain_state=3;
+			break;
+		}
+		else if((q->p13<GI_random)&&(GI_random<(4294967295u-q->p14)))	{
+			chain_state=1;					
+			break;
+		}
+		else if(((4294967295u-q->p14)<GI_random) && (GI_random<4294967295u))	{
+			chain_state=4;
+			break;
+		}				
+ 	    case 2:  			
+   	    	num_of_transmissions++;
+   	    	if(GI_random<q->p23)	{
+			chain_state=3;
+			break;
+		}	
+		else  	{			
+			chain_state=2;
+			break;
+		}							
+   	    case 3:
+   	    	--count;
+		num_of_drops++; 
+		if (q->logging==1) 
+			printk("netem loss event GI burst %d RFPLE %d\n", 
+				num_of_drops, num_of_transmissions);
+		num_of_transmissions=0; 
+    		if((0<GI_random)&&(GI_random<q->p32)){
+			chain_state=2;
+			break;
+		}	
+		else if((q->p32<GI_random) && (GI_random<(q->p31+q->p32))){
+		chain_state=1;
+		break;
+		}
+		else if(((q->p31+q->p32)<GI_random) && (GI_random<4294967295u)){ 
+		chain_state=3;
+		break;
+		}
+	    case 4:
+	    	--count;
+	     	num_of_drops++;
+	     	chain_state=1;
+	     	if (q->logging==1) 
+			printk("netem loss event GI isolated %d RFPLE %d\n", 
+			num_of_drops, num_of_transmissions);
+		break;
+	}		
+	}
+	
+	/* Gilbert-Elliot loss generator algorithm 
+	This is an algorithm for loss generation based on the Gilbert-Elliot loss model and its 
+	special cases. 
+	*/
+        
+	if (q->algorithm==1) {
+
+	switch(chain_state) {
+	    case 1:		
+		gilbell_random=net_random();
+		if(gilbell_random<4294967295u-q->gilb_k){
+		--count;
+		num_of_drops++;
+		if (q->logging==1) 
+			printk("netem loss event gilbell %d RFPLE %d\n", 
+			num_of_drops, num_of_transmissions);
+		num_of_transmissions=0;
+		} 
+		else	{
+		num_of_transmissions++;
+		}
+	  	gilbell_random=net_random();
+		if(gilbell_random<q->gilb_p){
+		chain_state=2;			  			  	    
+		}
+		break;
+						
+	case 2:			
+		gilbell_random=net_random();								
+		if(gilbell_random<4294967295u-q->gilb_h){
+		--count;
+		num_of_drops++;
+		if (q->logging==1)
+			printk("netem loss event gilbell %d RFPLE %d\n", 
+				num_of_drops, num_of_transmissions);
+			num_of_transmissions=0;											
+		}
+		else	{
+		num_of_transmissions++;
+		}
+		gilbell_random=net_random();	
+		if(gilbell_random<q->gilb_r)	{
+			chain_state=1;
+		}
+		break;		
+	}
+	}
+
+	/* Deterministic loss pattern algorithm 
+	This options reads a loss sequence of 0 and 1 from a file where 0 represents a
+	transmitted packet and 1 represents a loss event. The pattern can be repeated 
+	for a fixed number of times or indefinitely (if pattern_repetitions=0).
+	*/     
+	
+	if ((0<q->pattern_length) & ((q->pattern_repetitions==0)||
+		(repetitions_done<q->pattern_repetitions)) & 
+		(pattern_counter<q->pattern_length)){  
+	
+		if (0<q->kernel_pattern[pattern_counter-1]){
+		--count;
+		num_of_drops++; 
+    		if (q->logging==1) 
+			printk("netem loss event deterministic %d RFPLE %d\n", 
+				num_of_drops, num_of_transmissions);
+		num_of_transmissions=0;
+				}
+		else num_of_transmissions++;
+		pattern_counter++;
+		if (pattern_counter==q->pattern_length-1){
+		repetitions_done++;
+		pattern_counter=1;
+		}	
+		}	
+				
 	if (count == 0) {
 		sch->qstats.drops++;
 		kfree_skb(skb);
@@ -396,6 +571,7 @@
 	struct nlattr *tb[TCA_NETEM_MAX + 1];
 	struct tc_netem_qopt *qopt;
 	int ret;
+	int pattern_element;
 
 	if (opt == NULL)
 		return -EINVAL;
@@ -418,6 +594,31 @@
 	q->counter = 0;
 	q->loss = qopt->loss;
 	q->duplicate = qopt->duplicate;
+	q->p13 = qopt->p13;		
+	q->p31 = qopt->p31;		
+	q->p32 = qopt->p32;		
+	q->p23 = qopt->p23;		
+	q->p14 = qopt->p14;
+	q->gilb_p = qopt->gilb_p;		
+	q->gilb_r = qopt->gilb_r;		
+	q->gilb_h = qopt->gilb_h;		
+	q->gilb_k = qopt->gilb_k;		
+	q->logging = qopt->logging; 
+	q->query = qopt->query; 
+	q->algorithm = qopt->algorithm; 
+ 	q->pattern_length = qopt->pattern_length; 
+ 	q->pattern_repetitions = qopt->pattern_repetitions; 	
+ 	q->kernel_pattern=kmalloc(q->pattern_length*sizeof(size_t), 
+		GFP_KERNEL);
+	
+		for (pattern_element=1; pattern_element<q->pattern_length; 
+			pattern_element++)	{
+			q->kernel_pattern[pattern_element-1] = 
+			qopt->user_pattern[pattern_element-1]; 
+							}								
+	pattern_counter=1;
+	repetitions_done=0;	 	
+	chain_state=1;
 
 	/* for compatibility with earlier versions.
 	 * if gap is set, need to assume 100% probability
@@ -571,7 +772,32 @@
 	struct tc_netem_corr cor;
 	struct tc_netem_reorder reorder;
 	struct tc_netem_corrupt corrupt;
-
+	int pattern_element;
+	qopt.p13=q->p13;
+	qopt.p31=q->p31;
+	qopt.p23=q->p23;
+	qopt.p32=q->p32;
+	qopt.p14=q->p14;
+	
+	qopt.gilb_p=q->gilb_p;
+	qopt.gilb_r=q->gilb_r;
+	qopt.gilb_h=q->gilb_h;
+	qopt.gilb_k=q->gilb_k;
+			 		
+	qopt.logging = q->logging;  
+	qopt.query = q->query;
+	qopt.algorithm = q->algorithm;
+	qopt.pattern_length = q->pattern_length; 
+	qopt.pattern_repetitions = q->pattern_repetitions;  
+	qopt.user_pattern=kmalloc(qopt.pattern_length*sizeof(size_t), 
+		GFP_KERNEL);
+	if(q->pattern_length)	{
+		for (pattern_element=1; pattern_element<q->pattern_length; 
+			pattern_element++) 	{
+		qopt.user_pattern[pattern_element-1] = 
+		q->kernel_pattern[pattern_element-1]; 	
+					} 
+					}
 	qopt.latency = q->latency;
 	qopt.jitter = q->jitter;
 	qopt.limit = q->limit;

--------------040200060308000902030600--
