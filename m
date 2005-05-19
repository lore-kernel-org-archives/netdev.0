From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) netem: use only inner qdisc -- no private skbuff
 queue
Date: Thu, 19 May 2005 15:12:52 -0700
Message-ID: <20050519151252.6cbbf0b7@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netem works better if there if packets are just queued in the inner discipline
rather than having a separate delayed queue. Change to use the dequeue/requeue
to peek like TBF does.

By doing this potential qlen problems with the old method are avoided. The problems
happened when the netem_run that moved packets from the inner discipline to the nested
discipline failed (because inner queue was full). This happened in dequeue, so the
effective qlen of the netem would be decreased (because of the drop), but there was
no way to keep the outer qdisc (caller of netem dequeue) in sync.

The problem window is still there since this patch doesn't address the issue of
requeue failing in netem_dequeue, but that shouldn't happen since the sequence dequeue/requeue
should always work.  Long term correct fix is to implement qdisc->peek in all the qdisc's
to allow for this (needed by several other qdisc's as well).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: netem-2.6.12-rc4/net/sched/sch_netem.c
===================================================================
--- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
+++ netem-2.6.12-rc4/net/sched/sch_netem.c
@@ -53,7 +53,6 @@
 
 struct netem_sched_data {
 	struct Qdisc	*qdisc;
-	struct sk_buff_head delayed;
 	struct timer_list timer;
 
 	u32 latency;
@@ -137,72 +136,6 @@ static long tabledist(unsigned long mu, 
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
-/*
- *  Move a packet that is ready to send from the delay holding
- *  list to the underlying qdisc.
- */
-static int netem_run(struct Qdisc *sch)
-{
-	struct netem_sched_data *q = qdisc_priv(sch);
-	struct sk_buff *skb;
-	psched_time_t now;
-
-	PSCHED_GET_TIME(now);
-
-	skb = skb_peek(&q->delayed);
-	if (skb) {
-		const struct netem_skb_cb *cb
-			= (const struct netem_skb_cb *)skb->cb;
-		long delay 
-			= PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
-		pr_debug("netem_run: skb=%p delay=%ld\n", skb, delay);
-
-		/* if more time remaining? */
-		if (delay > 0) {
-			mod_timer(&q->timer, jiffies + delay);
-			return 1;
-		}
-
-		__skb_unlink(skb, &q->delayed);
-		
-		if (q->qdisc->enqueue(skb, q->qdisc)) {
-			sch->q.qlen--;
-			sch->qstats.drops++;
-		} 
-	}
-
-	return 0;
-}
-
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -212,6 +145,7 @@ static int netem_run(struct Qdisc *sch)
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
+	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
 	struct sk_buff *skb2;
 	int ret;
 	int count = 1;
@@ -246,18 +180,24 @@ static int netem_enqueue(struct sk_buff 
 		q->duplicate = dupsave;
 	}
 
-	/* If doing simple delay then gap == 0 so all packets
-	 * go into the delayed holding queue
-	 * otherwise if doing out of order only "1 out of gap"
-	 * packets will be delayed.
+	/* 
+	 * Do re-ordering by putting one out of N packets at the front
+	 * of the queue.
+	 * gap == 0 is special case for no-reordering.
 	 */
-	if (q->counter < q->gap) {
+	if (q->gap == 0 || q->counter != q->gap) {
+		psched_time_t now;
+		PSCHED_GET_TIME(now);
+		PSCHED_TADD2(now, 
+			     tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist),
+			     cb->time_to_send);
+		
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 	} else {
 		q->counter = 0;
-		ret = netem_delay(sch, skb);
-		netem_run(sch);
+		PSCHED_GET_TIME(cb->time_to_send);
+		ret = q->qdisc->ops->requeue(skb, q->qdisc);
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -301,22 +241,33 @@ static struct sk_buff *netem_dequeue(str
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
-	int pending;
-
-	pending = netem_run(sch);
 
 	skb = q->qdisc->dequeue(q->qdisc);
 	if (skb) {
-		pr_debug("netem_dequeue: return skb=%p\n", skb);
-		sch->q.qlen--;
-		sch->flags &= ~TCQ_F_THROTTLED;
-	}
-	else if (pending) {
-		pr_debug("netem_dequeue: throttling\n");
+		const struct netem_skb_cb *cb
+			= (const struct netem_skb_cb *)skb->cb;
+		psched_time_t now;
+		long delay;
+
+		/* if more time remaining? */
+		PSCHED_GET_TIME(now);
+		delay = PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
+		pr_debug("netem_run: skb=%p delay=%ld\n", skb, delay);
+		if (delay <= 0) {
+			pr_debug("netem_dequeue: return skb=%p\n", skb);
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_THROTTLED;
+			return skb;
+		}
+
+		mod_timer(&q->timer, jiffies + delay);
 		sch->flags |= TCQ_F_THROTTLED;
-	} 
 
-	return skb;
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != 0)
+			sch->qstats.drops++;
+	}
+
+	return NULL;
 }
 
 static void netem_watchdog(unsigned long arg)
@@ -333,8 +284,6 @@ static void netem_reset(struct Qdisc *sc
 	struct netem_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
-	skb_queue_purge(&q->delayed);
-
 	sch->q.qlen = 0;
 	sch->flags &= ~TCQ_F_THROTTLED;
 	del_timer_sync(&q->timer);
@@ -460,7 +409,6 @@ static int netem_init(struct Qdisc *sch,
 	if (!opt)
 		return -EINVAL;
 
-	skb_queue_head_init(&q->delayed);
 	init_timer(&q->timer);
 	q->timer.function = netem_watchdog;
 	q->timer.data = (unsigned long) sch;
