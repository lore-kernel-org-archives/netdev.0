From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/16] CBQ: use dump_stats
Date: Thu, 21 Oct 2004 14:37:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123724.GI21977@postel.suug.ch>
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

Makes CBQ use dump_stats qdisc op to provide xstats.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_cbq.c	2004-10-21 11:07:46.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_cbq.c	2004-10-21 11:20:06.000000000 +0200
@@ -1633,13 +1633,6 @@
 	if (cbq_dump_attr(skb, &q->link) < 0)
 		goto rtattr_failure;
 	rta->rta_len = skb->tail - b;
-	spin_lock_bh(&sch->dev->queue_lock);
-	q->link.xstats.avgidle = q->link.avgidle;
-	if (cbq_copy_xstats(skb, &q->link.xstats)) {
-		spin_unlock_bh(&sch->dev->queue_lock);
-		goto rtattr_failure;
-	}
-	spin_unlock_bh(&sch->dev->queue_lock);
 	return skb->len;
 
 rtattr_failure:
@@ -1648,6 +1641,15 @@
 }
 
 static int
+cbq_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+
+	q->link.xstats.avgidle = q->link.avgidle;
+	return gnet_stats_copy_app(d, &q->link.xstats, sizeof(q->link.xstats));
+}
+
+static int
 cbq_dump_class(struct Qdisc *sch, unsigned long arg,
 	       struct sk_buff *skb, struct tcmsg *tcm)
 {
@@ -2133,6 +2135,7 @@
 	.destroy	=	cbq_destroy,
 	.change		=	NULL,
 	.dump		=	cbq_dump,
+	.dump_stats	=	cbq_dump_stats,
 	.owner		=	THIS_MODULE,
 };
 
