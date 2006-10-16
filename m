From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: [PATCH REPOST 1/2] NET: Accurate packet scheduling for ATM/ADSL
	(kernel)
Date: Tue, 17 Oct 2006 09:34:37 +1000
Message-ID: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:14992 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1750805AbWJPXg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 19:36:26 -0400
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux traffic's control engine inaccurately calculates
transmission times for packets sent over ADSL links.  For
some packet sizes the error rises to over 50%.  This occurs
because ADSL uses ATM as its link layer transport, and ATM
transmits packets in fixed sized 53 byte cells.

This changes the kernel rate table lookup, to be able to lookup
packet transmission times over all ATM links, including ADSL,
with perfect accuracy. The accuracy is dependent on the rate
table that is calculated in userspace by iproute2 command tc.

A longer presentation of the patch, its rational, what it
does and how to use it can be found here:
   http://www.stuart.id.au/russell/files/tc/tc-atm/

A earlier version of the patch, and a _detailed_ empirical
investigation of its effects can be found here:
   http://www.adsl-optimizer.dk/

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
Signed-off-by: Russell Stuart <russell-tcatm@stuart.id.au>
---

diff -Nurp kernel-source-2.6.16.orig/include/linux/pkt_sched.h kernel-source-2.6.16/include/linux/pkt_sched.h
--- kernel-source-2.6.16.orig/include/linux/pkt_sched.h	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/include/linux/pkt_sched.h	2006-06-13 11:42:12.000000000 +1000
@@ -77,8 +77,9 @@ struct tc_ratespec
 {
 	unsigned char	cell_log;
 	unsigned char	__reserved;
-	unsigned short	feature;
-	short		addend;
+	unsigned short	feature;	/* Always 0 in pre-atm patch kernels */
+	char		cell_align;	/* Always 0 in pre-atm patch kernels */
+	unsigned char	__unused;
 	unsigned short	mpu;
 	__u32		rate;
 };
diff -Nurp kernel-source-2.6.16.orig/include/net/sch_generic.h kernel-source-2.6.16/include/net/sch_generic.h
--- kernel-source-2.6.16.orig/include/net/sch_generic.h	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/include/net/sch_generic.h	2006-06-13 11:42:12.000000000 +1000
@@ -307,4 +307,18 @@ drop:
 	return NET_XMIT_DROP;
 }
 
+/* Lookup a qdisc_rate_table to determine how long it will take to send a
+   packet given its size.
+ */
+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
+{
+	int slot = pktlen + rtab->rate.cell_align;
+	if (slot < 0)
+	  	slot = 0;
+	slot >>= rtab->rate.cell_log;
+	if (slot > 255)
+		return rtab->data[255] + 1;
+	return rtab->data[slot];
+}
+
 #endif
diff -Nurp kernel-source-2.6.16.orig/net/sched/act_police.c kernel-source-2.6.16/net/sched/act_police.c
--- kernel-source-2.6.16.orig/net/sched/act_police.c	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/net/sched/act_police.c	2006-06-13 11:42:12.000000000 +1000
@@ -33,8 +33,8 @@
 #include <net/sock.h>
 #include <net/act_api.h>
 
-#define L2T(p,L)   ((p)->R_tab->data[(L)>>(p)->R_tab->rate.cell_log])
-#define L2T_P(p,L) ((p)->P_tab->data[(L)>>(p)->P_tab->rate.cell_log])
+#define L2T(p,L)   qdisc_l2t((p)->R_tab,L)
+#define L2T_P(p,L) qdisc_l2t((p)->P_tab,L)
 #define PRIV(a) ((struct tcf_police *) (a)->priv)
 
 /* use generic hash table */
diff -Nurp kernel-source-2.6.16.orig/net/sched/sch_cbq.c kernel-source-2.6.16/net/sched/sch_cbq.c
--- kernel-source-2.6.16.orig/net/sched/sch_cbq.c	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/net/sched/sch_cbq.c	2006-06-13 11:42:12.000000000 +1000
@@ -193,7 +193,7 @@ struct cbq_sched_data
 };
 

-#define L2T(cl,len)	((cl)->R_tab->data[(len)>>(cl)->R_tab->rate.cell_log])
+#define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
 

 static __inline__ unsigned cbq_hash(u32 h)
diff -Nurp kernel-source-2.6.16.orig/net/sched/sch_htb.c kernel-source-2.6.16/net/sched/sch_htb.c
--- kernel-source-2.6.16.orig/net/sched/sch_htb.c	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/net/sched/sch_htb.c	2006-06-13 11:42:12.000000000 +1000
@@ -206,12 +206,10 @@ struct htb_class
 static __inline__ long L2T(struct htb_class *cl,struct qdisc_rate_table *rate,
 	int size)
 { 
-    int slot = size >> rate->rate.cell_log;
-    if (slot > 255) {
+    long result = qdisc_l2t(rate, size);
+    if (result > rate->data[255])
 	cl->xstats.giants++;
-	slot = 255;
-    }
-    return rate->data[slot];
+    return result;
 }
 
 struct htb_sched
diff -Nurp kernel-source-2.6.16.orig/net/sched/sch_tbf.c kernel-source-2.6.16/net/sched/sch_tbf.c
--- kernel-source-2.6.16.orig/net/sched/sch_tbf.c	2006-03-20 15:53:29.000000000 +1000
+++ kernel-source-2.6.16/net/sched/sch_tbf.c	2006-06-13 11:42:12.000000000 +1000
@@ -132,8 +132,8 @@ struct tbf_sched_data
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 };
 
-#define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
-#define L2T_P(q,L) ((q)->P_tab->data[(L)>>(q)->P_tab->rate.cell_log])
+#define L2T(q,L)   qdisc_l2t((q)->R_tab,L)
+#define L2T_P(q,L) qdisc_l2t((q)->P_tab,L)
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {



