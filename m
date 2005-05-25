From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem update for 2.4
Date: Wed, 25 May 2005 13:59:20 -0700
Message-ID: <20050525135920.659f3a00@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This includes the netem changes for 2.6 retargeted for 2.4
It covers:
	* make duplication reinsert from root to fix qlen issues
	* just use embedded qdisc for queueing to avoid qlen issues
	* probabilistic reordering support

Index: netem-2.4/net/sched/sch_netem.c
===================================================================
--- netem-2.4.orig/net/sched/sch_netem.c
+++ netem-2.4/net/sched/sch_netem.c
@@ -56,7 +56,6 @@
 
 struct netem_sched_data {
 	struct Qdisc	*qdisc;
-	struct sk_buff_head delayed;
 	struct timer_list timer;
 
 	u32 latency;
@@ -66,11 +65,12 @@ struct netem_sched_data {
 	u32 gap;
 	u32 jitter;
 	u32 duplicate;
+	u32 reorder;
 
 	struct crndstate {
 		unsigned long last;
 		unsigned long rho;
-	} delay_cor, loss_cor, dup_cor;
+	} delay_cor, loss_cor, dup_cor, reorder_cor;
 
 	struct disttable {
 		u32  size;
@@ -140,81 +140,79 @@ static long tabledist(unsigned long mu, 
 	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
-/* Put skb in the private delayed queue. */
-static int delay_skb(struct Qdisc *sch, struct sk_buff *skb)
+/*
+ * Insert one skb into qdisc.
+ * Note: parent depends on return value to account for queue length.
+ * 	NET_XMIT_DROP: queue length didn't change.
+ *      NET_XMIT_SUCCESS: one skb was queued.
+ */
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
- 	psched_tdiff_t td;
-  	psched_time_t now;
-  	
-  	PSCHED_GET_TIME(now);
-	td = tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist);
-	PSCHED_TADD2(now, td, cb->time_to_send);
-	
-	/* Always queue at tail to keep packets in order */
-	if (likely(q->delayed.qlen < q->limit)) {
-		__skb_queue_tail(&q->delayed, skb);
-		sch->stats.bytes += skb->len;
-		sch->stats.packets++;
- 
-		if (!timer_pending(&q->timer)) {
-			q->timer.expires = jiffies + PSCHED_US2JIFFIE(td);
-			add_timer(&q->timer);
-		}
-		return NET_XMIT_SUCCESS;
-	}
-
-	sch->stats.drops++;
-	kfree_skb(skb);
-	return NET_XMIT_DROP;
-}
+	struct sk_buff *skb2;
+	int ret;
+	int count = 1;
 
-static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
+	pr_debug("netem_enqueue skb=%p\n", skb);
 
-	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
+	/* Random duplication */
+	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
+		++count;
 
 	/* Random packet drop 0 => none, ~0 => all */
-	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
-		pr_debug("netem_enqueue: random loss\n");
+	if (q->loss && q->loss >= get_crandom(&q->loss_cor))
+		--count;
+
+	if (count == 0) {
 		sch->stats.drops++;
 		kfree_skb(skb);
-		return 0;	/* lie about loss so TCP doesn't know */
+		return NET_XMIT_DROP;
 	}
 
-	/* Random duplication */
-	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor)) {
-		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
-
-		pr_debug("netem_enqueue: dup %p\n", skb2);
-		if (skb2)
-			delay_skb(sch, skb2);
-	}
-
-	/* If doing simple delay then gap == 0 so all packets
-	 * go into the delayed holding queue
-	 * otherwise if doing out of order only "1 out of gap"
-	 * packets will be delayed.
+	/*
+	 * If we need to duplicate packet, then re-insert at top of the
+	 * qdisc tree, since parent queuer expects that only one
+	 * skb will be queued.
 	 */
-	if (q->counter < q->gap) {
-		int ret;
-
+	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
+		struct Qdisc *rootq = sch->dev->qdisc;
+		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
+		q->duplicate = 0;
+
+		rootq->enqueue(skb2, rootq);
+		q->duplicate = dupsave;
+	}
+
+	if (q->gap == 0 		/* not doing reordering */
+	    || q->counter < q->gap 	/* inside last reordering gap */
+	    || q->reorder < get_crandom(&q->reorder_cor)) {
+		psched_time_t now;
+		PSCHED_GET_TIME(now);
+		PSCHED_TADD2(now, tabledist(q->latency, q->jitter, 
+					    &q->delay_cor, q->delay_dist),
+			     cb->time_to_send);
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
-		if (likely(ret == NET_XMIT_SUCCESS)) {
-			sch->q.qlen++;
-			sch->stats.bytes += skb->len;
-			sch->stats.packets++;
-		} else
-			sch->stats.drops++;
-		return ret;
+	} else {
+		/* 
+		 * Do re-ordering by putting one out of N packets at the front
+		 * of the queue.
+		 */
+		PSCHED_GET_TIME(cb->time_to_send);
+		q->counter = 0;
+		ret = q->qdisc->ops->requeue(skb, q->qdisc);
 	}
-	
-	q->counter = 0;
 
-	return delay_skb(sch, skb);
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		sch->q.qlen++;
+		sch->stats.bytes += skb->len;
+		sch->stats.packets++;
+	} else
+		sch->stats.drops++;
+
+	pr_debug("netem: enqueue ret %d\n", ret);
+	return ret;
 }
 
 /* Requeue packets but don't change time stamp */
@@ -241,56 +239,46 @@ static unsigned int netem_drop(struct Qd
 	return len;
 }
 
-/* Dequeue packet.
- *  Move all packets that are ready to send from the delay holding
- *  list to the underlying qdisc, then just call dequeue
- */
 static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
 	skb = q->qdisc->dequeue(q->qdisc);
-	if (skb) 
-		sch->q.qlen--;
-	return skb;
-}
-
-static void netem_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct netem_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = sch->dev;
-	struct sk_buff *skb;
-	psched_time_t now;
-
-	pr_debug("netem_watchdog: fired @%lu\n", jiffies);
-
-	spin_lock_bh(&dev->queue_lock);
-	PSCHED_GET_TIME(now);
-
-	while ((skb = skb_peek(&q->delayed)) != NULL) {
+	if (skb) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
-		long delay 
-			= PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
-		pr_debug("netem_watchdog: skb %p@%lu %ld\n",
-			 skb, jiffies, delay);
+		psched_time_t now;
+		long delay;
 
 		/* if more time remaining? */
-		if (delay > 0) {
-			mod_timer(&q->timer, jiffies + delay);
-			break;
+		PSCHED_GET_TIME(now);
+		delay = PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
+		pr_debug("netem_run: skb=%p delay=%ld\n", skb, delay);
+		if (delay <= 0) {
+			pr_debug("netem_dequeue: return skb=%p\n", skb);
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_THROTTLED;
+			return skb;
 		}
-		__skb_unlink(skb, &q->delayed);
 
-		if (q->qdisc->enqueue(skb, q->qdisc))
+		mod_timer(&q->timer, jiffies + delay);
+		sch->flags |= TCQ_F_THROTTLED;
+
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != 0)
 			sch->stats.drops++;
-		else
-			sch->q.qlen++;
 	}
-	qdisc_run(dev);
-	spin_unlock_bh(&dev->queue_lock);
+
+	return NULL;
+}
+
+static void netem_watchdog(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc *)arg;
+
+	pr_debug("netem_watchdog qlen=%d\n", sch->q.qlen);
+	sch->flags &= ~TCQ_F_THROTTLED;
+	netif_schedule(sch->dev);
 }
 
 static void netem_reset(struct Qdisc *sch)
@@ -298,9 +286,8 @@ static void netem_reset(struct Qdisc *sc
 	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
-	skb_queue_purge(&q->delayed);
-
 	sch->q.qlen = 0;
+	sch->flags &= ~TCQ_F_THROTTLED;
 	del_timer_sync(&q->timer);
 }
 
@@ -366,6 +353,19 @@ static int get_correlation(struct Qdisc 
 	return 0;
 }
 
+static int get_reorder(struct Qdisc *sch, const struct rtattr *attr)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	const struct tc_netem_reorder *r = RTA_DATA(attr);
+
+	if (RTA_PAYLOAD(attr) != sizeof(*r))
+		return -EINVAL;
+
+	q->reorder = r->probability;
+	init_crandom(&q->reorder_cor, r->correlation);
+	return 0;
+}
+
 static int netem_change(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -386,9 +386,15 @@ static int netem_change(struct Qdisc *sc
 	q->jitter = qopt->jitter;
 	q->limit = qopt->limit;
 	q->gap = qopt->gap;
+	q->counter = 0;
 	q->loss = qopt->loss;
 	q->duplicate = qopt->duplicate;
 
+	/* for compatiablity with earlier versions.
+	 * if gap is set, need to assume 100% probablity
+	 */
+	q->reorder = ~0;
+
 	/* Handle nested options after initial queue options.
 	 * Should have put all options in nested format but too late now.
 	 */ 
@@ -410,6 +416,11 @@ static int netem_change(struct Qdisc *sc
 			if (ret)
 				return ret;
 		}
+		if (tb[TCA_NETEM_REORDER-1]) {
+			ret = get_reorder(sch, tb[TCA_NETEM_REORDER-1]);
+			if (ret)
+				return ret;
+		}
 	}
 
 
@@ -425,11 +436,9 @@ static int netem_init(struct Qdisc *sch,
 		return -EINVAL;
 
 	MOD_INC_USE_COUNT;
-	skb_queue_head_init(&q->delayed);
 	init_timer(&q->timer);
 	q->timer.function = netem_watchdog;
 	q->timer.data = (unsigned long) sch;
-	q->counter = 0;
 
 	q->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
 	if (!q->qdisc) {
@@ -463,6 +472,7 @@ static int netem_dump(struct Qdisc *sch,
 	struct rtattr *rta = (struct rtattr *) b;
 	struct tc_netem_qopt qopt;
 	struct tc_netem_corr cor;
+	struct tc_netem_reorder reorder;
 
 	qopt.latency = q->latency;
 	qopt.jitter = q->jitter;
@@ -476,6 +486,11 @@ static int netem_dump(struct Qdisc *sch,
 	cor.loss_corr = q->loss_cor.rho;
 	cor.dup_corr = q->dup_cor.rho;
 	RTA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
+
+	reorder.probability = q->reorder;
+	reorder.correlation = q->reorder_cor.rho;
+	RTA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
+
 	rta->rta_len = skb->tail - b;
 
 	return skb->len;
Index: netem-2.4/include/linux/pkt_sched.h
===================================================================
--- netem-2.4.orig/include/linux/pkt_sched.h
+++ netem-2.4/include/linux/pkt_sched.h
@@ -439,16 +439,17 @@ enum
 	TCA_NETEM_UNSPEC,
 	TCA_NETEM_CORR,
 	TCA_NETEM_DELAY_DIST,
+	TCA_NETEM_REORDER,
 };
 
-#define TCA_NETEM_MAX	TCA_NETEM_DELAY_DIST
+#define TCA_NETEM_MAX	TCA_NETEM_REORDER
 
 struct tc_netem_qopt
 {
 	__u32	latency;	/* added delay (us) */
 	__u32   limit;		/* fifo limit (packets) */
 	__u32	loss;		/* random packet loss (0=none ~0=100%) */
-	__u32	gap;		/* re-ordering gap (0 for delay all) */
+	__u32	gap;		/* re-ordering gap (0 for none) */
 	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
 	__u32	jitter;		/* random jitter in latency (us) */
 };
@@ -460,6 +461,12 @@ struct tc_netem_corr
 	__u32	dup_corr;	/* duplicate correlation  */
 };
 
+struct tc_netem_reorder
+{
+	__u32	probability;
+	__u32	correlation;
+};
+
 #define NETEM_DIST_SCALE	8192
 
 #endif
