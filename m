From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/16] PKT_SCHED: Requeues statistics
Date: Thu, 21 Oct 2004 14:33:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123340.GF21977@postel.suug.ch>
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

Introduces requeue statistics for qdiscs. Patch is based on a
patch of Jamal Hadi Salim and adapted to new statistic API.

Signed-off-by: Thomas Graf <tgraf@suug.ch>


--- linux-2.6.9-rc5.orig/net/sched/sch_atm.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_atm.c	2004-10-21 11:01:21.000000000 +0200
@@ -545,8 +545,10 @@
 
 	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
 	ret = p->link.q->ops->requeue(skb,p->link.q);
-	if (!ret) sch->q.qlen++;
-	else {
+	if (!ret) {
+        sch->q.qlen++;
+        sch->qstats.requeues++;
+    } else {
 		sch->qstats.drops++;
 		p->link.stats.drops++;
 	}
--- linux-2.6.9-rc5.orig/net/sched/sch_cbq.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_cbq.c	2004-10-21 10:52:50.000000000 +0200
@@ -485,6 +485,7 @@
 #endif
 	if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
 		sch->q.qlen++;
+		sch->qstats.requeues++;
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
 		return 0;
--- linux-2.6.9-rc5.orig/net/sched/sch_dsmark.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_dsmark.c	2004-10-21 10:52:50.000000000 +0200
@@ -297,6 +297,7 @@
 	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
         if ((ret = p->q->ops->requeue(skb, p->q)) == 0) {
 		sch->q.qlen++;
+		sch->qstats.requeues++;
 		return 0;
 	}
 	sch->qstats.drops++;
--- linux-2.6.9-rc5.orig/net/sched/sch_fifo.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_fifo.c	2004-10-21 10:52:50.000000000 +0200
@@ -67,6 +67,7 @@
 {
 	__skb_queue_head(&sch->q, skb);
 	sch->qstats.backlog += skb->len;
+	sch->qstats.requeues++;
 	return 0;
 }
 
@@ -126,6 +127,7 @@
 pfifo_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	__skb_queue_head(&sch->q, skb);
+	sch->qstats.requeues++;
 	return 0;
 }
 
--- linux-2.6.9-rc5.orig/net/sched/sch_generic.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_generic.c	2004-10-21 10:52:50.000000000 +0200
@@ -353,6 +353,7 @@
 
 	__skb_queue_head(list, skb);
 	qdisc->q.qlen++;
+	qdisc->qstats.requeues++;
 	return 0;
 }
 
--- linux-2.6.9-rc5.orig/net/sched/sch_gred.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_gred.c	2004-10-21 10:52:50.000000000 +0200
@@ -222,6 +222,7 @@
 
 	__skb_queue_head(&sch->q, skb);
 	sch->qstats.backlog += skb->len;
+	sch->qstats.requeues++;
 	q->backlog += skb->len;
 	return 0;
 }
--- linux-2.6.9-rc5.orig/net/sched/sch_hfsc.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_hfsc.c	2004-10-21 10:52:50.000000000 +0200
@@ -1779,6 +1779,7 @@
 
 	__skb_queue_head(&q->requeue, skb);
 	sch->q.qlen++;
+	sch->qstats.requeues++;
 	return NET_XMIT_SUCCESS;
 }
 
--- linux-2.6.9-rc5.orig/net/sched/sch_htb.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_htb.c	2004-10-21 10:52:50.000000000 +0200
@@ -794,6 +794,7 @@
 	    htb_activate (q,cl);
 
     sch->q.qlen++;
+    sch->qstats.requeues++;
     HTB_DBG(1,1,"htb_req_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
--- linux-2.6.9-rc5.orig/net/sched/sch_netem.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_netem.c	2004-10-21 10:52:50.000000000 +0200
@@ -211,8 +211,10 @@
 	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
+	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->qstats.requeues++;
+	}
 
 	return ret;
 }
--- linux-2.6.9-rc5.orig/net/sched/sch_prio.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_prio.c	2004-10-21 10:52:50.000000000 +0200
@@ -139,6 +139,7 @@
 
 	if ((ret = qdisc->ops->requeue(skb, qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->qstats.requeues++;
 		return 0;
 	}
 dropped:
--- linux-2.6.9-rc5.orig/net/sched/sch_red.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_red.c	2004-10-21 10:52:50.000000000 +0200
@@ -309,6 +309,7 @@
 
 	__skb_queue_head(&sch->q, skb);
 	sch->qstats.backlog += skb->len;
+	sch->qstats.requeues++;
 	return 0;
 }
 
--- linux-2.6.9-rc5.orig/net/sched/sch_sfq.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_sfq.c	2004-10-21 10:52:50.000000000 +0200
@@ -310,8 +310,10 @@
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen < q->limit - 1)
+	if (++sch->q.qlen < q->limit - 1) {
+		sch->qstats.requeues++;
 		return 0;
+	}
 
 	sch->qstats.drops++;
 	sfq_drop(sch);
--- linux-2.6.9-rc5.orig/net/sched/sch_tbf.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_tbf.c	2004-10-21 10:52:50.000000000 +0200
@@ -166,8 +166,10 @@
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
+	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->qstats.requeues++;
+	}
 
 	return ret;
 }
--- linux-2.6.9-rc5.orig/net/sched/sch_teql.c	2004-10-21 10:45:08.000000000 +0200
+++ linux-2.6.9-rc5/net/sched/sch_teql.c	2004-10-21 10:52:50.000000000 +0200
@@ -113,6 +113,7 @@
 	struct teql_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_head(&q->q, skb);
+	sch->qstats.requeues++;
 	return 0;
 }
 
