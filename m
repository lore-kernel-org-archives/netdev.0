From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/16] RED: use dump_stats
Date: Thu, 21 Oct 2004 14:38:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123827.GJ21977@postel.suug.ch>
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

Makes RED use dump_stats qdisc op.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_red.c	2004-10-21 11:07:46.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_red.c	2004-10-21 12:49:10.000000000 +0200
@@ -396,16 +396,6 @@
 	return red_change(sch, opt);
 }
 
-
-int red_copy_xstats(struct sk_buff *skb, struct tc_red_xstats *st)
-{
-        RTA_PUT(skb, TCA_XSTATS, sizeof(*st), st);
-        return 0;
-
-rtattr_failure:
-        return 1;
-}
-
 static int red_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -425,9 +415,6 @@
 	RTA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
 	rta->rta_len = skb->tail - b;
 
-	if (red_copy_xstats(skb, &q->st))
-		goto rtattr_failure;
-
 	return skb->len;
 
 rtattr_failure:
@@ -435,6 +422,13 @@
 	return -1;
 }
 
+static int red_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+
+	return gnet_stats_copy_app(d, &q->st, sizeof(q->st));
+}
+
 static struct Qdisc_ops red_qdisc_ops = {
 	.next		=	NULL,
 	.cl_ops		=	NULL,
@@ -448,6 +442,7 @@
 	.reset		=	red_reset,
 	.change		=	red_change,
 	.dump		=	red_dump,
+	.dump_stats	=	red_dump_stats,
 	.owner		=	THIS_MODULE,
 };
 
