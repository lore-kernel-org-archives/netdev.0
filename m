From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/16] CBQ: Use dump_stats for class statistics dumping
Date: Thu, 21 Oct 2004 14:43:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021124329.GM21977@postel.suug.ch>
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

Makes CBQ use dump_stats to dump class statistics, i.e.
moves the statistic dump code from cbq_dump_class to
cbq_dump_class_stats.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_cbq.c	2004-10-21 12:59:00.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_cbq.c	2004-10-21 12:59:32.000000000 +0200
@@ -1614,16 +1614,6 @@
 	return 0;
 }
 
-int cbq_copy_xstats(struct sk_buff *skb, struct tc_cbq_xstats *st)
-{
-	RTA_PUT(skb, TCA_XSTATS, sizeof(*st), st);
-	return 0;
-
-rtattr_failure:
-	return -1;
-}
-
-
 static int cbq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
@@ -1655,7 +1645,6 @@
 cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
 {
-	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl = (struct cbq_class*)arg;
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
@@ -1672,25 +1661,35 @@
 	if (cbq_dump_attr(skb, cl) < 0)
 		goto rtattr_failure;
 	rta->rta_len = skb->tail - b;
-	cl->stats.qlen = cl->q->q.qlen;
-	if (qdisc_copy_stats(skb, &cl->stats, cl->stats_lock))
-		goto rtattr_failure;
-	spin_lock_bh(&sch->dev->queue_lock);
+	return skb->len;
+
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int
+cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+	struct gnet_dump *d)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct cbq_class *cl = (struct cbq_class*)arg;
+
+	cl->qstats.qlen = cl->q->q.qlen;
 	cl->xstats.avgidle = cl->avgidle;
 	cl->xstats.undertime = 0;
+
 	if (!PSCHED_IS_PASTPERFECT(cl->undertime))
 		cl->xstats.undertime = PSCHED_TDIFF(cl->undertime, q->now);
-	if (cbq_copy_xstats(skb, &cl->xstats)) {
-		spin_unlock_bh(&sch->dev->queue_lock);
-		goto rtattr_failure;
-	}
-	spin_unlock_bh(&sch->dev->queue_lock);
 
-	return skb->len;
+	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
+#ifdef CONFIG_NET_ESTIMATOR
+	    gnet_stats_copy_rate_est(d, &cl->rate_est) < 0 ||
+#endif
+	    gnet_stats_copy_queue(d, &cl->qstats) < 0)
+		return -1;
 
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	return gnet_stats_copy_app(d, &cl->xstats, sizeof(cl->xstats));
 }
 
 static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
@@ -2121,6 +2120,7 @@
 	.bind_tcf	=	cbq_bind_filter,
 	.unbind_tcf	=	cbq_unbind_filter,
 	.dump		=	cbq_dump_class,
+	.dump_stats	=	cbq_dump_class_stats,
 };
 
 static struct Qdisc_ops cbq_qdisc_ops = {
