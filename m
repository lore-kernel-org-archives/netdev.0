From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 16/16] ATM: Use gnet_stats for class statistics and dump them
Date: Thu, 21 Oct 2004 14:52:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021125201.GU21977@postel.suug.ch>
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

Makes ATM qdisc use gnet_stats for class statistic counters and
adds dumping bits to actually dump those. Althought the counters
were updated they never got dumped to userspace.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc5.orig/net/sched/sch_atm.c	2004-10-21 11:07:46.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_atm.c	2004-10-21 13:26:05.000000000 +0200
@@ -69,7 +69,8 @@
 	struct socket		*sock;		/* for closing */
 	u32			classid;	/* x:y type ID */
 	int			ref;		/* reference count */
-	struct tc_stats		stats;
+	struct gnet_stats_basic	bstats;
+	struct gnet_stats_queue	qstats;
 	spinlock_t		*stats_lock;
 	struct atm_flow_data	*next;
 	struct atm_flow_data	*excess;	/* flow for excess traffic;
@@ -450,13 +451,13 @@
 #endif
 	    (ret = flow->q->enqueue(skb,flow->q)) != 0) {
 		sch->qstats.drops++;
-		if (flow) flow->stats.drops++;
+		if (flow) flow->qstats.drops++;
 		return ret;
 	}
 	sch->bstats.bytes += skb->len;
 	sch->bstats.packets++;
-	flow->stats.bytes += skb->len;
-	flow->stats.packets++;
+	flow->bstats.bytes += skb->len;
+	flow->bstats.packets++;
 	/*
 	 * Okay, this may seem weird. We pretend we've dropped the packet if
 	 * it goes via ATM. The reason for this is that the outer qdisc
@@ -550,7 +551,7 @@
         sch->qstats.requeues++;
     } else {
 		sch->qstats.drops++;
-		p->link.stats.drops++;
+		p->link.qstats.drops++;
 	}
 	return ret;
 }
@@ -666,6 +667,21 @@
 	skb_trim(skb,b-skb->data);
 	return -1;
 }
+static int
+atm_tc_dump_class_stats(struct Qdisc *sch, unsigned long arg,
+	struct gnet_dump *d)
+{
+	struct atm_qdisc_data *p = PRIV(sch);
+	struct atm_flow_data *flow = (struct atm_flow_data *) arg;
+
+	flow->qstats.qlen = flow->q->q.qlen;
+
+	if (gnet_stats_copy_basic(d, &flow->bstats) < 0 ||
+	    gnet_stats_copy_queue(d, &flow->qstats) < 0)
+		return -1;
+
+	return 0;
+}
 
 static int atm_tc_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
@@ -684,6 +700,7 @@
 	.bind_tcf	=	atm_tc_bind_filter,
 	.unbind_tcf	=	atm_tc_put,
 	.dump		=	atm_tc_dump_class,
+	.dump_stats	=	atm_tc_dump_class_stats,
 };
 
 static struct Qdisc_ops atm_qdisc_ops = {
