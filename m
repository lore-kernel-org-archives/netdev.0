From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] alternate way of handling netem duplication
Date: Wed, 4 May 2005 10:09:53 -0700
Message-ID: <20050504100953.615e28b8@dxpl.pdx.osdl.net>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>
	<42780AC1.8040409@trash.net>
	<20050503163025.38bb9682.davem@davemloft.net>
	<42780DB2.2090201@trash.net>
	<20050503165937.0c6cac6d.davem@davemloft.net>
	<42782B59.3000500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42782B59.3000500@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is an alternate way of handling duplication. 
What it does is mark the packets on enqueue with a repcount.
Then on dequeue it cheats and bypasses direct to the device avoiding
the other qdisc.

When duplication takes place in the dequeue there is a harmless race.
Since qdisc_xmit (formerly part of qdisc_restart) drops queue_lock, and reacquires.
Therefore netem dequeue will return NULL causing qdisc_restart to return qlen > 0
and qdisc_run will recall qdisc_restart, which will pick up the same packet again.

It is untested, and reordering needs fixing.

Index: netem-2.6.12-rc3/net/sched/sch_netem.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_netem.c
+++ netem-2.6.12-rc3/net/sched/sch_netem.c
@@ -59,7 +59,6 @@ struct netem_sched_data {
 	u32 latency;
 	u32 loss;
 	u32 limit;
-	u32 counter;
 	u32 gap;
 	u32 jitter;
 	u32 duplicate;
@@ -78,6 +77,7 @@ struct netem_sched_data {
 /* Time stamp put into socket buffer control block */
 struct netem_skb_cb {
 	psched_time_t	time_to_send;
+	int		repcount;
 };
 
 /* init_crandom - initialize correlated random number generator
@@ -137,35 +137,6 @@ static long tabledist(unsigned long mu, 
 	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
-/* Put skb in the private delayed queue. */
-static int netem_delay(struct Qdisc *sch, struct sk_buff *skb)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	psched_tdiff_t td;
-	psched_time_t now;
-	
-	PSCHED_GET_TIME(now);
-	td = tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist);
-	
-	/* Always queue at tail to keep packets in order */
-	if (likely(q->delayed.qlen < q->limit)) {
-		struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
-	
-		PSCHED_TADD2(now, td, cb->time_to_send);
-
-		pr_debug("netem_delay: skb=%p now=%llu tosend=%llu\n", skb, 
-			 now, cb->time_to_send);
-	
-		__skb_queue_tail(&q->delayed, skb);
-		return NET_XMIT_SUCCESS;
-	}
-
-	pr_debug("netem_delay: queue over limit %d\n", q->limit);
-	sch->qstats.overlimits++;
-	kfree_skb(skb);
-	return NET_XMIT_DROP;
-}
-
 /*
  *  Move a packet that is ready to send from the delay holding
  *  list to the underlying qdisc.
@@ -206,64 +177,45 @@ static int netem_run(struct Qdisc *sch)
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	int ret;
+	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+	psched_tdiff_t td;
+	psched_time_t now;
 
 	pr_debug("netem_enqueue skb=%p\n", skb);
 
+	cb->repcount = 1;
+	PSCHED_GET_TIME(now);
+	td = tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist);
+	PSCHED_TADD2(now, td, cb->time_to_send);
+
+	pr_debug("netem_enqueue: skb=%p now=%llu tosend=%llu\n", skb, 
+		 now, cb->time_to_send);
+	
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
-		pr_debug("netem_enqueue: random loss\n");
-		sch->qstats.drops++;
-		kfree_skb(skb);
-		return 0;	/* lie about loss so TCP doesn't know */
-	}
+	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) 
+		--cb->repcount;
 
 	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
-		struct sk_buff *skb2;
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) 
+		++cb->repcount;
 
-		skb2 = skb_clone(skb, GFP_ATOMIC);
-		if (skb2 && netem_delay(sch, skb2) == NET_XMIT_SUCCESS) {
-			struct Qdisc *qp;
-
-			/* Since one packet can generate two packets in the
-			 * queue, the parent's qlen accounting gets confused,
-			 * so fix it.
-			 */
-			qp = qdisc_lookup(sch->dev, TC_H_MAJ(sch->parent));
-			if (qp)
-				qp->q.qlen++;
-
-			sch->q.qlen++;
-			sch->bstats.bytes += skb2->len;
-			sch->bstats.packets++;
-		} else
-			sch->qstats.drops++;
-	}
-
-	/* If doing simple delay then gap == 0 so all packets
-	 * go into the delayed holding queue
-	 * otherwise if doing out of order only "1 out of gap"
-	 * packets will be delayed.
-	 */
-	if (q->counter < q->gap) {
-		++q->counter;
-		ret = q->qdisc->enqueue(skb, q->qdisc);
-	} else {
-		q->counter = 0;
-		ret = netem_delay(sch, skb);
-		netem_run(sch);
+	if (cb->repcount == 0) {
+		kfree_skb(skb);
+		return 0;
 	}
 
-	if (likely(ret == NET_XMIT_SUCCESS)) {
-		sch->q.qlen++;
-		sch->bstats.bytes += skb->len;
-		sch->bstats.packets++;
-	} else
+	if (q->delayed.qlen < q->limit) {
 		sch->qstats.drops++;
-
-	pr_debug("netem: enqueue ret %d\n", ret);
-	return ret;
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
+	}
+		
+	__skb_queue_tail(&q->delayed, skb);
+	sch->q.qlen++;
+	sch->bstats.bytes += skb->len;
+	sch->bstats.packets++;
+	
+	return NET_XMIT_SUCCESS;
 }
 
 /* Requeue packets but don't change time stamp */
@@ -302,7 +254,23 @@ static struct sk_buff *netem_dequeue(str
 
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
-		pr_debug("netem_dequeue: return skb=%p\n", skb);
+		struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+
+		printk("netem_dequeue: skb=%p count=%d\n", skb, cb->repcount);
+		if (cb->repcount > 1) {
+			struct sk_buff *skb2;
+		
+			/* Go direct to device to avoid problems 
+			   with parent qlen */
+			skb2 = skb_clone(skb, GFP_ATOMIC);
+			if (skb2 && qdisc_xmit(sch->dev, skb2) != NETDEV_TX_OK) {
+				kfree_skb(skb2);
+				q->qdisc->ops->requeue(skb, q->qdisc);
+			}
+			--cb->repcount;
+			return NULL;
+		}
+
 		sch->q.qlen--;
 		sch->flags &= ~TCQ_F_THROTTLED;
 	}
@@ -459,7 +427,6 @@ static int netem_init(struct Qdisc *sch,
 	init_timer(&q->timer);
 	q->timer.function = netem_watchdog;
 	q->timer.data = (unsigned long) sch;
-	q->counter = 0;
 
 	q->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
 	if (!q->qdisc) {
Index: netem-2.6.12-rc3/include/net/pkt_sched.h
===================================================================
--- netem-2.6.12-rc3.orig/include/net/pkt_sched.h
+++ netem-2.6.12-rc3/include/net/pkt_sched.h
@@ -234,6 +234,8 @@ static inline void qdisc_run(struct net_
 		/* NOTHING */;
 }
 
+extern int qdisc_xmit(struct net_device *dev, struct sk_buff *skb);
+
 extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	struct tcf_result *res);
 
Index: netem-2.6.12-rc3/net/sched/sch_api.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_api.c
+++ netem-2.6.12-rc3/net/sched/sch_api.c
@@ -1289,7 +1289,6 @@ static int __init pktsched_init(void)
 
 subsys_initcall(pktsched_init);
 
-EXPORT_SYMBOL(qdisc_lookup);
 EXPORT_SYMBOL(qdisc_get_rtab);
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
Index: netem-2.6.12-rc3/net/sched/sch_generic.c
===================================================================
--- netem-2.6.12-rc3.orig/net/sched/sch_generic.c
+++ netem-2.6.12-rc3/net/sched/sch_generic.c
@@ -77,7 +77,78 @@ void qdisc_unlock_tree(struct net_device
    dev->queue_lock and dev->xmit_lock are mutually exclusive,
    if one is grabbed, another must be free.
  */
+int qdisc_xmit(struct net_device *dev, struct sk_buff *skb)
+{
+	unsigned need_lock = !(dev->features & NETIF_F_LLTX);
+
+	/*
+	 * When the driver has LLTX set it does its own locking
+	 * in start_xmit. No need to add additional overhead by
+	 * locking again. These checks are worth it because
+	 * even uncongested locks can be quite expensive.
+	 * The driver can do trylock like here too, in case
+	 * of lock congestion it should return -1 and the packet
+	 * will be requeued.
+	 */
+	if (need_lock) {
+		if (!spin_trylock(&dev->xmit_lock))
+			goto collision;
+		/* Remember that the driver is grabbed by us. */
+		dev->xmit_lock_owner = smp_processor_id();
+	}
+		
+	/* And release queue */
+	spin_unlock(&dev->queue_lock);
+	
+	if (likely(!netif_queue_stopped(dev))) {
+		int ret;
+		if (netdev_nit)
+			dev_queue_xmit_nit(skb, dev);
+
+		ret = dev->hard_start_xmit(skb, dev);
+		if (likely(ret == NETDEV_TX_OK)) { 
+			if (need_lock) {
+				dev->xmit_lock_owner = -1;
+				spin_unlock(&dev->xmit_lock);
+			}
+			spin_lock(&dev->queue_lock);
+			return NETDEV_TX_OK;
+		} 
 
+		if (ret == NETDEV_TX_LOCKED && !need_lock) {
+			spin_lock(&dev->queue_lock);
+			goto collision;
+		}
+
+	}
+
+	/* NETDEV_TX_BUSY - we need to requeue */
+	/* Release the driver */
+	if (need_lock) {
+		dev->xmit_lock_owner = -1;
+		spin_unlock(&dev->xmit_lock);
+	} 
+	spin_lock(&dev->queue_lock);
+	return NETDEV_TX_BUSY;
+
+ collision:
+	/* So, someone grabbed the driver. */
+	
+	/* It may be transient configuration error,
+	   when hard_start_xmit() recurses. We detect
+	   it by checking xmit owner and drop the
+	   packet when deadloop is detected.
+	*/
+	if (dev->xmit_lock_owner == smp_processor_id()) {
+		kfree_skb(skb);
+		if (net_ratelimit())
+			printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
+		return NETDEV_TX_OK;
+	}
+	
+	__get_cpu_var(netdev_rx_stat).cpu_collision++;
+	return NETDEV_TX_BUSY;
+}
 
 /* Kick device.
    Note, that this procedure can be called by a watchdog timer, so that
@@ -96,91 +167,19 @@ int qdisc_restart(struct net_device *dev
 	struct sk_buff *skb;
 
 	/* Dequeue packet */
-	if ((skb = q->dequeue(q)) != NULL) {
-		unsigned nolock = (dev->features & NETIF_F_LLTX);
-		/*
-		 * When the driver has LLTX set it does its own locking
-		 * in start_xmit. No need to add additional overhead by
-		 * locking again. These checks are worth it because
-		 * even uncongested locks can be quite expensive.
-		 * The driver can do trylock like here too, in case
-		 * of lock congestion it should return -1 and the packet
-		 * will be requeued.
-		 */
-		if (!nolock) {
-			if (!spin_trylock(&dev->xmit_lock)) {
-			collision:
-				/* So, someone grabbed the driver. */
-				
-				/* It may be transient configuration error,
-				   when hard_start_xmit() recurses. We detect
-				   it by checking xmit owner and drop the
-				   packet when deadloop is detected.
-				*/
-				if (dev->xmit_lock_owner == smp_processor_id()) {
-					kfree_skb(skb);
-					if (net_ratelimit())
-						printk(KERN_DEBUG "Dead loop on netdevice %s, fix it urgently!\n", dev->name);
-					return -1;
-				}
-				__get_cpu_var(netdev_rx_stat).cpu_collision++;
-				goto requeue;
-			}
-			/* Remember that the driver is grabbed by us. */
-			dev->xmit_lock_owner = smp_processor_id();
-		}
-		
-		{
-			/* And release queue */
-			spin_unlock(&dev->queue_lock);
-
-			if (!netif_queue_stopped(dev)) {
-				int ret;
-				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
-
-				ret = dev->hard_start_xmit(skb, dev);
-				if (ret == NETDEV_TX_OK) { 
-					if (!nolock) {
-						dev->xmit_lock_owner = -1;
-						spin_unlock(&dev->xmit_lock);
-					}
-					spin_lock(&dev->queue_lock);
-					return -1;
-				}
-				if (ret == NETDEV_TX_LOCKED && nolock) {
-					spin_lock(&dev->queue_lock);
-					goto collision; 
-				}
-			}
-
-			/* NETDEV_TX_BUSY - we need to requeue */
-			/* Release the driver */
-			if (!nolock) { 
-				dev->xmit_lock_owner = -1;
-				spin_unlock(&dev->xmit_lock);
-			} 
-			spin_lock(&dev->queue_lock);
-			q = dev->qdisc;
-		}
-
-		/* Device kicked us out :(
-		   This is possible in three cases:
-
-		   0. driver is locked
-		   1. fastroute is enabled
-		   2. device cannot determine busy state
-		      before start of transmission (f.e. dialout)
-		   3. device is buggy (ppp)
-		 */
+	skb = q->dequeue(q);
+	if (likely(skb)) {
+		if (likely(qdisc_xmit(dev, skb) == NETDEV_TX_OK))
+			return -1;
 
-requeue:
+		q = dev->qdisc;
 		q->ops->requeue(skb, q);
 		netif_schedule(dev);
 		return 1;
+	} else {
+		BUG_ON((int) q->q.qlen < 0);
+		return q->q.qlen;
 	}
-	BUG_ON((int) q->q.qlen < 0);
-	return q->q.qlen;
 }
 
 static void dev_watchdog(unsigned long arg)
@@ -604,6 +603,7 @@ EXPORT_SYMBOL(noop_qdisc);
 EXPORT_SYMBOL(noop_qdisc_ops);
 EXPORT_SYMBOL(qdisc_create_dflt);
 EXPORT_SYMBOL(qdisc_destroy);
+EXPORT_SYMBOL(qdisc_xmit);
 EXPORT_SYMBOL(qdisc_reset);
 EXPORT_SYMBOL(qdisc_restart);
 EXPORT_SYMBOL(qdisc_lock_tree);
