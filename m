From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 15/16] HFSC: Use dump_stats for class statistics dumping
Date: Thu, 21 Oct 2004 14:51:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021125111.GT21977@postel.suug.ch>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Makes HFSC use dump_stats to dump class statistics, i.e.
moves the statistics dump code from hfsc_dump_class to
hfsc_dump_class_stats.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_hfsc.c	2004-10-21 13:13:16.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_hfsc.c	2004-10-21 13:13:46.000000000 +0200
@@ -1404,36 +1404,6 @@
 	return -1;
 }
 
-static inline int
-hfsc_dump_stats(struct sk_buff *skb, struct hfsc_class *cl)
-{
-	cl->stats.qlen = cl->qdisc->q.qlen;
-	if (qdisc_copy_stats(skb, &cl->stats, cl->stats_lock) < 0)
-		goto rtattr_failure;
-
-	return skb->len;
-
- rtattr_failure:
-	return -1;
-}
-
-static inline int
-hfsc_dump_xstats(struct sk_buff *skb, struct hfsc_class *cl)
-{
-	struct tc_hfsc_stats xstats;
-
-	xstats.level  = cl->level;
-	xstats.period = cl->cl_vtperiod;
-	xstats.work   = cl->cl_total;
-	xstats.rtwork = cl->cl_cumul;
-	RTA_PUT(skb, TCA_XSTATS, sizeof(xstats), &xstats);
-
-	return skb->len;
-
- rtattr_failure:
-	return -1;
-}
-
 static int
 hfsc_dump_class(struct Qdisc *sch, unsigned long arg, struct sk_buff *skb,
                 struct tcmsg *tcm)
@@ -1451,11 +1421,6 @@
 	if (hfsc_dump_curves(skb, cl) < 0)
 		goto rtattr_failure;
 	rta->rta_len = skb->tail - b;
-
-	if ((hfsc_dump_stats(skb, cl) < 0) ||
-	    (hfsc_dump_xstats(skb, cl) < 0))
-		goto rtattr_failure;
-
 	return skb->len;
 
  rtattr_failure:
@@ -1463,6 +1428,31 @@
 	return -1;
 }
 
+static int
+hfsc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+	struct gnet_dump *d)
+{
+	struct hfsc_class *cl = (struct hfsc_class *)arg;
+	struct tc_hfsc_stats xstats;
+
+	cl->qstats.qlen = cl->qdisc->q.qlen;
+	xstats.level   = cl->level;
+	xstats.period  = cl->cl_vtperiod;
+	xstats.work    = cl->cl_total;
+	xstats.rtwork  = cl->cl_cumul;
+
+	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+#endif
+	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+		return -1;
+
+	return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
+}
+
+
+
 static void
 hfsc_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 {
@@ -1819,6 +1809,7 @@
 	.unbind_tcf	= hfsc_unbind_tcf,
 	.tcf_chain	= hfsc_tcf_chain,
 	.dump		= hfsc_dump_class,
+	.dump_stats	= hfsc_dump_class_stats,
 	.walk		= hfsc_walk
 };
 
