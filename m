From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/5] PKT_SCHED: Replace tc_stats with new gnet_stats in struct Qdisc
Date: Thu, 7 Oct 2004 03:03:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010314.GB18621@postel.suug.ch>
References: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007010146.GA18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replaces tc_stats with gnet_stats replacements in struct
Qdisc and adapts all qdiscs to use them.

Signed-off-by: Thomas Graf <tgraf@suug.ch>


diff -Nru linux-2.6.9-rc3-bk6.orig/include/net/pkt_sched.h linux-2.6.9-rc3-bk6/include/net/pkt_sched.h
--- linux-2.6.9-rc3-bk6.orig/include/net/pkt_sched.h	2004-10-06 14:19:13.000000000 +0200
+++ linux-2.6.9-rc3-bk6/include/net/pkt_sched.h	2004-10-06 20:13:56.000000000 +0200
@@ -9,6 +9,7 @@
 #include <net/pkt_cls.h>
 #include <linux/module.h>
 #include <linux/rtnetlink.h>
+#include <net/gen_stats.h>
 
 struct rtattr;
 struct Qdisc;
@@ -86,7 +87,9 @@
 	struct net_device	*dev;
 	struct list_head	list;
 
-	struct tc_stats		stats;
+	struct gnet_stats_basic	bstats;
+	struct gnet_stats_queue	qstats;
+	struct gnet_stats_rate_est	rate_est;
 	spinlock_t		*stats_lock;
 	struct rcu_head 	q_rcu;
 	int			(*reshape_fail)(struct sk_buff *skb, struct Qdisc *q);
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_cbq.c linux-2.6.9-rc3-bk6/net/sched/sch_cbq.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_cbq.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_cbq.c	2004-10-06 20:35:09.000000000 +0200
@@ -433,8 +433,8 @@
 #endif
 		if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
 			sch->q.qlen++;
-			sch->stats.packets++;
-			sch->stats.bytes+=len;
+			sch->bstats.packets++;
+			sch->bstats.bytes+=len;
 			cbq_mark_toplevel(q, cl);
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
@@ -443,7 +443,7 @@
 	}
 
 #ifndef CONFIG_NET_CLS_ACT
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	if (cl == NULL)
 		kfree_skb(skb);
 	else {
@@ -452,7 +452,7 @@
 	}
 #else
 	if ( NET_XMIT_DROP == ret) {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 	}
 
 	if (cl != NULL) {
@@ -472,7 +472,7 @@
 
 	if ((cl = q->tx_class) == NULL) {
 		kfree_skb(skb);
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return NET_XMIT_CN;
 	}
 	q->tx_class = NULL;
@@ -489,7 +489,7 @@
 			cbq_activate_class(cl);
 		return 0;
 	}
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	cl->stats.drops++;
 	return ret;
 }
@@ -729,17 +729,17 @@
 
 		if (cl->q->enqueue(skb, cl->q) == 0) {
 			sch->q.qlen++;
-			sch->stats.packets++;
-			sch->stats.bytes+=len;
+			sch->bstats.packets++;
+			sch->bstats.bytes+=len;
 			if (!cl->next_alive)
 				cbq_activate_class(cl);
 			return 0;
 		}
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return 0;
 	}
 
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	return -1;
 }
 #endif
@@ -1090,7 +1090,7 @@
 	   Sigh... start watchdog timer in the last case. */
 
 	if (sch->q.qlen) {
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 		if (q->wd_expires) {
 			long delay = PSCHED_US2JIFFIE(q->wd_expires);
 			if (delay <= 0)
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_dsmark.c linux-2.6.9-rc3-bk6/net/sched/sch_dsmark.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_dsmark.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_dsmark.c	2004-10-06 20:45:26.000000000 +0200
@@ -241,11 +241,11 @@
 #endif
 
 	    ((ret = p->q->enqueue(skb,p->q)) != 0)) {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return ret;
 	}
-	sch->stats.bytes += skb->len;
-	sch->stats.packets++;
+	sch->bstats.bytes += skb->len;
+	sch->bstats.packets++;
 	sch->q.qlen++;
 	return ret;
 }
@@ -299,7 +299,7 @@
 		sch->q.qlen++;
 		return 0;
 	}
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	return ret;
 }
 
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_fifo.c linux-2.6.9-rc3-bk6/net/sched/sch_fifo.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_fifo.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_fifo.c	2004-10-06 20:29:31.000000000 +0200
@@ -47,14 +47,14 @@
 {
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
-	if (sch->stats.backlog + skb->len <= q->limit) {
+	if (sch->qstats.backlog + skb->len <= q->limit) {
 		__skb_queue_tail(&sch->q, skb);
-		sch->stats.backlog += skb->len;
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->qstats.backlog += skb->len;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		return 0;
 	}
-	sch->stats.drops++;
+	sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 	if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch))
 #endif
@@ -66,7 +66,7 @@
 bfifo_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	__skb_queue_head(&sch->q, skb);
-	sch->stats.backlog += skb->len;
+	sch->qstats.backlog += skb->len;
 	return 0;
 }
 
@@ -77,7 +77,7 @@
 
 	skb = __skb_dequeue(&sch->q);
 	if (skb)
-		sch->stats.backlog -= skb->len;
+		sch->qstats.backlog -= skb->len;
 	return skb;
 }
 
@@ -89,7 +89,7 @@
 	skb = __skb_dequeue_tail(&sch->q);
 	if (skb) {
 		unsigned int len = skb->len;
-		sch->stats.backlog -= len;
+		sch->qstats.backlog -= len;
 		kfree_skb(skb);
 		return len;
 	}
@@ -100,7 +100,7 @@
 fifo_reset(struct Qdisc* sch)
 {
 	skb_queue_purge(&sch->q);
-	sch->stats.backlog = 0;
+	sch->qstats.backlog = 0;
 }
 
 static int
@@ -110,11 +110,11 @@
 
 	if (sch->q.qlen < q->limit) {
 		__skb_queue_tail(&sch->q, skb);
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		return 0;
 	}
-	sch->stats.drops++;
+	sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 	if (sch->reshape_fail==NULL || sch->reshape_fail(skb, sch))
 #endif
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_generic.c linux-2.6.9-rc3-bk6/net/sched/sch_generic.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_generic.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_generic.c	2004-10-07 00:17:21.000000000 +0200
@@ -318,11 +318,11 @@
 	if (list->qlen < qdisc->dev->tx_queue_len) {
 		__skb_queue_tail(list, skb);
 		qdisc->q.qlen++;
-		qdisc->stats.bytes += skb->len;
-		qdisc->stats.packets++;
+		qdisc->bstats.bytes += skb->len;
+		qdisc->bstats.packets++;
 		return 0;
 	}
-	qdisc->stats.drops++;
+	qdisc->qstats.drops++;
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_gred.c linux-2.6.9-rc3-bk6/net/sched/sch_gred.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_gred.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_gred.c	2004-10-06 20:44:10.000000000 +0200
@@ -130,7 +130,7 @@
 
 	D2PRINTK("gred_enqueue virtualQ 0x%x classid %x backlog %d "
 	    "general backlog %d\n",skb->tc_index&0xf,sch->handle,q->backlog,
-	    sch->stats.backlog);
+	    sch->qstats.backlog);
 	/* sum up all the qaves of prios <= to ours to get the new qave*/
 	if (!t->eqp && t->grio) {
 		for (i=0;i<t->DPs;i++) {
@@ -161,7 +161,7 @@
 		q->qave >>= q->Stab[(us_idle>>q->Scell_log)&0xFF];
 	} else {
 		if (t->eqp) {
-			q->qave += sch->stats.backlog - (q->qave >> q->Wlog);
+			q->qave += sch->qstats.backlog - (q->qave >> q->Wlog);
 		} else {
 			q->qave += q->backlog - (q->qave >> q->Wlog);
 		}
@@ -179,9 +179,9 @@
 			q->backlog += skb->len;
 do_enqueue:
 			__skb_queue_tail(&sch->q, skb);
-			sch->stats.backlog += skb->len;
-			sch->stats.bytes += skb->len;
-			sch->stats.packets++;
+			sch->qstats.backlog += skb->len;
+			sch->bstats.bytes += skb->len;
+			sch->bstats.packets++;
 			return 0;
 		} else {
 			q->pdrop++;
@@ -189,12 +189,12 @@
 
 drop:
 		kfree_skb(skb);
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return NET_XMIT_DROP;
 	}
 	if ((q->qave+qave) >= q->qth_max) {
 		q->qcount = -1;
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 		q->forced++;
 		goto drop;
 	}
@@ -203,7 +203,7 @@
 			goto enqueue;
 		q->qcount = 0;
 		q->qR = net_random()&q->Rmask;
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 		q->early++;
 		goto drop;
 	}
@@ -221,7 +221,7 @@
 	PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 	__skb_queue_head(&sch->q, skb);
-	sch->stats.backlog += skb->len;
+	sch->qstats.backlog += skb->len;
 	q->backlog += skb->len;
 	return 0;
 }
@@ -235,7 +235,7 @@
 
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
-		sch->stats.backlog -= skb->len;
+		sch->qstats.backlog -= skb->len;
 		q= t->tab[(skb->tc_index&0xf)];
 		if (q) {
 			q->backlog -= skb->len;
@@ -269,8 +269,8 @@
 	skb = __skb_dequeue_tail(&sch->q);
 	if (skb) {
 		unsigned int len = skb->len;
-		sch->stats.backlog -= len;
-		sch->stats.drops++;
+		sch->qstats.backlog -= len;
+		sch->qstats.drops++;
 		q= t->tab[(skb->tc_index&0xf)];
 		if (q) {
 			q->backlog -= len;
@@ -304,7 +304,7 @@
 
 	__skb_queue_purge(&sch->q);
 
-	sch->stats.backlog = 0;
+	sch->qstats.backlog = 0;
 
         for (i=0;i<t->DPs;i++) {
 	        q= t->tab[i];
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c	2004-10-07 00:18:23.000000000 +0200
@@ -1677,14 +1677,14 @@
 #ifdef CONFIG_NET_CLS_ACT
 	if (cl == NULL) {
 		if (NET_XMIT_DROP == ret) {
-			sch->stats.drops++;
+			sch->qstats.drops++;
 		}
 		return ret;
 	}
 #else
 	if (cl == NULL) {
 		kfree_skb(skb);
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return NET_XMIT_DROP;
 	}
 #endif
@@ -1692,7 +1692,7 @@
 	err = cl->qdisc->enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->stats.drops++;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return err;
 	}
 
@@ -1701,8 +1701,8 @@
 
 	cl->stats.packets++;
 	cl->stats.bytes += len;
-	sch->stats.packets++;
-	sch->stats.bytes += len;
+	sch->bstats.packets++;
+	sch->bstats.bytes += len;
 	sch->q.qlen++;
 
 	return NET_XMIT_SUCCESS;
@@ -1739,7 +1739,7 @@
 		 */
 		cl = vttree_get_minvt(&q->root, cur_time);
 		if (cl == NULL) {
-			sch->stats.overlimits++;
+			sch->qstats.overlimits++;
 			hfsc_schedule_watchdog(sch, cur_time);
 			return NULL;
 		}
@@ -1804,7 +1804,7 @@
 				list_move_tail(&cl->dlist, &q->droplist);
 			}
 			cl->stats.drops++;
-			sch->stats.drops++;
+			sch->qstats.drops++;
 			sch->q.qlen--;
 			return len;
 		}
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c linux-2.6.9-rc3-bk6/net/sched/sch_htb.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_htb.c	2004-10-07 00:19:38.000000000 +0200
@@ -735,7 +735,7 @@
 	}
     } else if (!cl) {
 	    if (NET_XMIT_DROP == ret) {
-		    sch->stats.drops++;
+		    sch->qstats.drops++;
 	    }
 	    return ret;
     }
@@ -747,13 +747,13 @@
 	    q->direct_pkts++;
 	} else {
 	    kfree_skb (skb);
-	    sch->stats.drops++;
+	    sch->qstats.drops++;
 	    return NET_XMIT_DROP;
 	}
     }
 #endif
     else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	cl->stats.drops++;
 	return NET_XMIT_DROP;
     } else {
@@ -762,7 +762,7 @@
     }
 
     sch->q.qlen++;
-    sch->stats.packets++; sch->stats.bytes += skb->len;
+    sch->bstats.packets++; sch->bstats.bytes += skb->len;
     HTB_DBG(1,1,"htb_enq_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
@@ -783,11 +783,11 @@
             __skb_queue_head(&q->direct_queue, skb);
             tskb = __skb_dequeue_tail(&q->direct_queue);
             kfree_skb (tskb);
-            sch->stats.drops++;
+            sch->qstats.drops++;
             return NET_XMIT_CN;	
 	}
     } else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	cl->stats.drops++;
 	return NET_XMIT_DROP;
     } else 
@@ -1117,7 +1117,7 @@
 	/* why don't use jiffies here ? because expires can be in past */
 	mod_timer(&q->timer, q->jiffies + delay);
 	sch->flags |= TCQ_F_THROTTLED;
-	sch->stats.overlimits++;
+	sch->qstats.overlimits++;
 	HTB_DBG(3,1,"htb_deq t_delay=%ld\n",delay);
 }
 
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_ingress.c linux-2.6.9-rc3-bk6/net/sched/sch_ingress.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_ingress.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_ingress.c	2004-10-06 20:45:04.000000000 +0200
@@ -151,12 +151,12 @@
 	 * firewall FW_* code.
 	 */
 #ifdef CONFIG_NET_CLS_ACT
-	sch->stats.packets++;
-	sch->stats.bytes += skb->len;
+	sch->bstats.packets++;
+	sch->bstats.bytes += skb->len;
 	switch (result) {
 		case TC_ACT_SHOT:
 			result = TC_ACT_SHOT;
-			sch->stats.drops++;
+			sch->qstats.drops++;
 			break;
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
@@ -176,14 +176,14 @@
 	switch (result) {
 		case TC_POLICE_SHOT:
 		result = NF_DROP;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		break;
 		case TC_POLICE_RECLASSIFY: /* DSCP remarking here ? */
 		case TC_POLICE_OK:
 		case TC_POLICE_UNSPEC:
 		default:
-		sch->stats.packets++;
-		sch->stats.bytes += skb->len;
+		sch->bstats.packets++;
+		sch->bstats.bytes += skb->len;
 		result = NF_ACCEPT;
 		break;
 	};
@@ -191,8 +191,8 @@
 #else
 	D2PRINTK("Overriding result to ACCEPT\n");
 	result = NF_ACCEPT;
-	sch->stats.packets++;
-	sch->stats.bytes += skb->len;
+	sch->bstats.packets++;
+	sch->bstats.bytes += skb->len;
 #endif
 #endif
 
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_netem.c linux-2.6.9-rc3-bk6/net/sched/sch_netem.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_netem.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_netem.c	2004-10-06 21:02:46.000000000 +0200
@@ -153,12 +153,12 @@
 	if (likely(q->delayed.qlen < q->limit)) {
 		__skb_queue_tail(&q->delayed, skb);
 		sch->q.qlen++;
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		return NET_XMIT_SUCCESS;
 	}
 
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
@@ -172,7 +172,7 @@
 	/* Random packet drop 0 => none, ~0 => all */
 	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
 		pr_debug("netem_enqueue: random loss\n");
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return 0;	/* lie about loss so TCP doesn't know */
 	}
 
@@ -196,7 +196,7 @@
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 		if (ret)
-			sch->stats.drops++;
+			sch->qstats.drops++;
 		return ret;
 	}
 	
@@ -224,7 +224,7 @@
 
 	if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 	}
 	return len;
 }
@@ -256,7 +256,7 @@
 		__skb_unlink(skb, &q->delayed);
 
 		if (q->qdisc->enqueue(skb, q->qdisc))
-			sch->stats.drops++;
+			sch->qstats.drops++;
 	}
 
 	skb = q->qdisc->dequeue(q->qdisc);
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_prio.c linux-2.6.9-rc3-bk6/net/sched/sch_prio.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_prio.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_prio.c	2004-10-06 21:02:03.000000000 +0200
@@ -107,8 +107,8 @@
 		goto dropped;
 
 	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
@@ -117,10 +117,10 @@
 #ifdef CONFIG_NET_CLS_ACT
 	if (NET_XMIT_DROP == ret) {
 #endif
-		sch->stats.drops++;
+		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_ACT
 	} else {
-		sch->stats.overlimits++; /* abuse, but noone uses it */
+		sch->qstats.overlimits++; /* abuse, but noone uses it */
 	}
 #endif
 	return ret; 
@@ -142,7 +142,7 @@
 		return 0;
 	}
 dropped:
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	return NET_XMIT_DROP;
 }
 
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_red.c linux-2.6.9-rc3-bk6/net/sched/sch_red.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_red.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_red.c	2004-10-06 20:41:48.000000000 +0200
@@ -228,13 +228,13 @@
 				q->qave >>= 1;
 		}
 	} else {
-		q->qave += sch->stats.backlog - (q->qave >> q->Wlog);
+		q->qave += sch->qstats.backlog - (q->qave >> q->Wlog);
 		/* NOTE:
 		   q->qave is fixed point number with point at Wlog.
 		   The formulae above is equvalent to floating point
 		   version:
 
-		   qave = qave*(1-W) + sch->stats.backlog*W;
+		   qave = qave*(1-W) + sch->qstats.backlog*W;
 		                                           --ANK (980924)
 		 */
 	}
@@ -242,22 +242,22 @@
 	if (q->qave < q->qth_min) {
 		q->qcount = -1;
 enqueue:
-		if (sch->stats.backlog + skb->len <= q->limit) {
+		if (sch->qstats.backlog + skb->len <= q->limit) {
 			__skb_queue_tail(&sch->q, skb);
-			sch->stats.backlog += skb->len;
-			sch->stats.bytes += skb->len;
-			sch->stats.packets++;
+			sch->qstats.backlog += skb->len;
+			sch->bstats.bytes += skb->len;
+			sch->bstats.packets++;
 			return NET_XMIT_SUCCESS;
 		} else {
 			q->st.pdrop++;
 		}
 		kfree_skb(skb);
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return NET_XMIT_DROP;
 	}
 	if (q->qave >= q->qth_max) {
 		q->qcount = -1;
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 mark:
 		if  (!(q->flags&TC_RED_ECN) || !red_ecn_mark(skb)) {
 			q->st.early++;
@@ -288,7 +288,7 @@
 			goto enqueue;
 		q->qcount = 0;
 		q->qR = net_random()&q->Rmask;
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 		goto mark;
 	}
 	q->qR = net_random()&q->Rmask;
@@ -296,7 +296,7 @@
 
 drop:
 	kfree_skb(skb);
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	return NET_XMIT_CN;
 }
 
@@ -308,7 +308,7 @@
 	PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 	__skb_queue_head(&sch->q, skb);
-	sch->stats.backlog += skb->len;
+	sch->qstats.backlog += skb->len;
 	return 0;
 }
 
@@ -320,7 +320,7 @@
 
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
-		sch->stats.backlog -= skb->len;
+		sch->qstats.backlog -= skb->len;
 		return skb;
 	}
 	PSCHED_GET_TIME(q->qidlestart);
@@ -335,8 +335,8 @@
 	skb = __skb_dequeue_tail(&sch->q);
 	if (skb) {
 		unsigned int len = skb->len;
-		sch->stats.backlog -= len;
-		sch->stats.drops++;
+		sch->qstats.backlog -= len;
+		sch->qstats.drops++;
 		q->st.other++;
 		kfree_skb(skb);
 		return len;
@@ -350,7 +350,7 @@
 	struct red_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_purge(&sch->q);
-	sch->stats.backlog = 0;
+	sch->qstats.backlog = 0;
 	PSCHED_SET_PASTPERFECT(q->qidlestart);
 	q->qave = 0;
 	q->qcount = -1;
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_sfq.c linux-2.6.9-rc3-bk6/net/sched/sch_sfq.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_sfq.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_sfq.c	2004-10-06 20:46:11.000000000 +0200
@@ -227,7 +227,7 @@
 		kfree_skb(skb);
 		sfq_dec(q, x);
 		sch->q.qlen--;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return len;
 	}
 
@@ -243,7 +243,7 @@
 		sfq_dec(q, d);
 		sch->q.qlen--;
 		q->ht[q->hash[d]] = SFQ_DEPTH;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return len;
 	}
 
@@ -276,8 +276,8 @@
 		}
 	}
 	if (++sch->q.qlen < q->limit-1) {
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		return 0;
 	}
 
@@ -313,7 +313,7 @@
 	if (++sch->q.qlen < q->limit - 1)
 		return 0;
 
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	sfq_drop(sch);
 	return NET_XMIT_CN;
 }
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_tbf.c linux-2.6.9-rc3-bk6/net/sched/sch_tbf.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_tbf.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_tbf.c	2004-10-06 21:00:24.000000000 +0200
@@ -141,7 +141,7 @@
 	int ret;
 
 	if (skb->len > q->max_size) {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 #ifdef CONFIG_NET_CLS_POLICE
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 #endif
@@ -151,13 +151,13 @@
 	}
 
 	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
-		sch->stats.drops++;
+		sch->qstats.drops++;
 		return ret;
 	}
 
 	sch->q.qlen++;
-	sch->stats.bytes += skb->len;
-	sch->stats.packets++;
+	sch->bstats.bytes += skb->len;
+	sch->bstats.packets++;
 	return 0;
 }
 
@@ -179,7 +179,7 @@
 
 	if ((len = q->qdisc->ops->drop(q->qdisc)) != 0) {
 		sch->q.qlen--;
-		sch->stats.drops++;
+		sch->qstats.drops++;
 	}
 	return len;
 }
@@ -250,11 +250,11 @@
 		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
 			/* When requeue fails skb is dropped */
 			sch->q.qlen--;
-			sch->stats.drops++;
+			sch->qstats.drops++;
 		}
 
 		sch->flags |= TCQ_F_THROTTLED;
-		sch->stats.overlimits++;
+		sch->qstats.overlimits++;
 	}
 	return NULL;
 }
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_teql.c linux-2.6.9-rc3-bk6/net/sched/sch_teql.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_teql.c	2004-10-06 14:19:49.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_teql.c	2004-10-06 21:01:33.000000000 +0200
@@ -96,14 +96,14 @@
 
 	__skb_queue_tail(&q->q, skb);
 	if (q->q.qlen <= dev->tx_queue_len) {
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
+		sch->bstats.bytes += skb->len;
+		sch->bstats.packets++;
 		return 0;
 	}
 
 	__skb_unlink(skb, &q->q);
 	kfree_skb(skb);
-	sch->stats.drops++;
+	sch->qstats.drops++;
 	return NET_XMIT_DROP;
 }
 
