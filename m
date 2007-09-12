From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 1/6] [NET_SCHED]: Cleanup L2T macros and handle oversized
	packets
Date: Wed, 12 Sep 2007 12:13:51 +0200
Message-ID: <1189592031.26927.22.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:39712 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933008AbXILKOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:14:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a28343c933f6cfc3df1be86e0ebe8d99fa8d5f77
Author: Jesper Dangaard Brouer <hawk@comx.dk>
Date:   Wed Sep 12 10:01:00 2007 +0200

    [NET_SCHED]: Cleanup L2T macros and handle oversized packets
    
    Change L2T (length to time) macros, in all rate based schedulers, to
    call a common function qdisc_l2t() that does the rate table lookup.
    This function handles if the packet size lookup is larger than the
    rate table, which often occurs with TSO enabled.
    
    Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 8a67f24..4ebd615 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -302,4 +302,16 @@ drop:
 	return NET_XMIT_DROP;
 }
 
+/* Length to Time (L2T) lookup in a qdisc_rate_table, to determine how
+   long it will take to send a packet given its size.
+ */
+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned int pktlen)
+{
+	int slot = pktlen;
+	slot >>= rtab->rate.cell_log;
+	if (slot > 255)
+		return (rtab->data[255]*(slot >> 8) + rtab->data[slot & 0xFF]);
+	return rtab->data[slot];
+}
+
 #endif
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 6085be5..46deb5f 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -21,8 +21,8 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 
-#define L2T(p,L)   ((p)->tcfp_R_tab->data[(L)>>(p)->tcfp_R_tab->rate.cell_log])
-#define L2T_P(p,L) ((p)->tcfp_P_tab->data[(L)>>(p)->tcfp_P_tab->rate.cell_log])
+#define L2T(p,L)   qdisc_l2t((p)->tcfp_R_tab, L)
+#define L2T_P(p,L) qdisc_l2t((p)->tcfp_P_tab, L)
 
 #define POL_TAB_MASK     15
 static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index e38c283..aed2af2 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -175,7 +175,7 @@ struct cbq_sched_data
 };
 
 
-#define L2T(cl,len)	((cl)->R_tab->data[(len)>>(cl)->R_tab->rate.cell_log])
+#define L2T(cl,len)	qdisc_l2t((cl)->R_tab,len)
 
 
 static __inline__ unsigned cbq_hash(u32 h)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 246a2f9..5e608a6 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -132,10 +132,8 @@ struct htb_class {
 static inline long L2T(struct htb_class *cl, struct qdisc_rate_table *rate,
 			   int size)
 {
-	int slot = size >> rate->rate.cell_log;
-	if (slot > 255)
-		return (rate->data[255]*(slot >> 8) + rate->data[slot & 0xFF]);
-	return rate->data[slot];
+	long result = qdisc_l2t(rate, size);
+	return result;
 }
 
 struct htb_sched {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 8c2639a..b0d8109 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -115,8 +115,8 @@ struct tbf_sched_data
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
 };
 
-#define L2T(q,L)   ((q)->R_tab->data[(L)>>(q)->R_tab->rate.cell_log])
-#define L2T_P(q,L) ((q)->P_tab->data[(L)>>(q)->P_tab->rate.cell_log])
+#define L2T(q,L)   qdisc_l2t((q)->R_tab,L)
+#define L2T_P(q,L) qdisc_l2t((q)->P_tab,L)
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {

