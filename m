From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Thu, 7 Apr 2005 12:04:17 -0700
Message-ID: <20050407120417.4297cd14@dxpl.pdx.osdl.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
	<4252EB9D.9070305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4252EB9D.9070305@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Apr 2005 21:48:45 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Netem has a private queue for delayed packets, and currently, packets
> > in this queue are not accounted for in the qdisc qlen statistics.
> > This is a problem if netem is used inside another qdisc doing rate
> > control that peeks at the qlen.
> > 
> > This patch changes the statistics to include the packets held but
> > not ready to send.
> 
> There is one troublesome spot left, netem_watchdog() decreases q.qlen
> when the packet couldn't be enqueued. I don't think it is possible
> to make netem useable as leaf-qdisc, it will always have to touch
> q.qlen from timer context and classful qdiscs can't deal with this
> since they all maintain their own q.qlen counters and expect changes
> only in the +-1 range in enqueue/dequeue/requeue/drop. Best thing IMO
> would be to refuse to work as anything but root qdisc.
> 

Would this work better.? It just increases qlen by +/- 1 on enqueue, dequeue.
It also allows < 1ms delays if there is enough traffic going through.

--- linux-2.6.12-rc2/net/sched/sch_netem.c	2005-04-04 09:39:41.000000000 -0700
+++ netem-2.6.12-rc2/net/sched/sch_netem.c	2005-04-06 15:39:16.000000000 -0700
@@ -138,38 +138,78 @@ static long tabledist(unsigned long mu, 
 }
 
 /* Put skb in the private delayed queue. */
-static int delay_skb(struct Qdisc *sch, struct sk_buff *skb)
+static int netem_delay(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
 	psched_tdiff_t td;
 	psched_time_t now;
 	
 	PSCHED_GET_TIME(now);
 	td = tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist);
-	PSCHED_TADD2(now, td, cb->time_to_send);
 	
 	/* Always queue at tail to keep packets in order */
 	if (likely(q->delayed.qlen < q->limit)) {
+		struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+	
+		PSCHED_TADD2(now, td, cb->time_to_send);
+
+		pr_debug("netem_delay: skb=%p now=%llu tosend=%llu\n", skb, 
+			 now, cb->time_to_send);
+	
 		__skb_queue_tail(&q->delayed, skb);
-		if (!timer_pending(&q->timer)) {
-			q->timer.expires = jiffies + PSCHED_US2JIFFIE(td);
-			add_timer(&q->timer);
-		}
 		return NET_XMIT_SUCCESS;
 	}
 
+	pr_debug("netem_delay: queue over limit %d\n", q->limit);
+	sch->qstats.overlimits++;
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
 
+/*
+ *  Move a packet that is ready to send from the delay holding
+ *  list to the underlying qdisc.
+ */
+static int netem_run(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	psched_time_t now;
+
+	PSCHED_GET_TIME(now);
+
+	skb = skb_peek(&q->delayed);
+	if (skb) {
+		const struct netem_skb_cb *cb
+			= (const struct netem_skb_cb *)skb->cb;
+		long delay 
+			= PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
+		pr_debug("netem_run: skb=%p delay=%ld\n", skb, delay);
+
+		/* if more time remaining? */
+		if (delay > 0) {
+			mod_timer(&q->timer, jiffies + delay);
+			return 1;
+		}
+
+		__skb_unlink(skb, &q->delayed);
+		
+		if (q->qdisc->enqueue(skb, q->qdisc)) {
+			sch->q.qlen--;
+			sch->qstats.drops++;
+		} 
+	}
+
+	return 0;
+}
+
 static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb2;
 	int ret;
 
-	pr_debug("netem_enqueue skb=%p @%lu\n", skb, jiffies);
+	pr_debug("netem_enqueue skb=%p\n", skb);
 
 	/* Random packet drop 0 => none, ~0 => all */
 	if (q->loss && q->loss >= get_crandom(&q->loss_cor)) {
@@ -184,7 +224,7 @@ static int netem_enqueue(struct sk_buff 
 	    && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
 		pr_debug("netem_enqueue: dup %p\n", skb2);
 
-		if (delay_skb(sch, skb2)) {
+		if (netem_delay(sch, skb2)) {
 			sch->q.qlen++;
 			sch->bstats.bytes += skb2->len;
 			sch->bstats.packets++;
@@ -202,7 +242,8 @@ static int netem_enqueue(struct sk_buff 
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 	} else {
 		q->counter = 0;
-		ret = delay_skb(sch, skb);
+		ret = netem_delay(sch, skb);
+		netem_run(sch);
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -241,56 +282,35 @@ static unsigned int netem_drop(struct Qd
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
+	int pending;
+
+	pending = netem_run(sch);
 
 	skb = q->qdisc->dequeue(q->qdisc);
-	if (skb) 
+	if (skb) {
+		pr_debug("netem_dequeue: return skb=%p\n", skb);
 		sch->q.qlen--;
+		sch->flags &= ~TCQ_F_THROTTLED;
+	}
+	else if (pending) {
+		pr_debug("netem_dequeue: throttling\n");
+		sch->flags |= TCQ_F_THROTTLED;
+	} 
+
 	return skb;
 }
 
 static void netem_watchdog(unsigned long arg)
 {
 	struct Qdisc *sch = (struct Qdisc *)arg;
-	struct netem_sched_data *q = qdisc_priv(sch);
-	struct net_device *dev = sch->dev;
-	struct sk_buff *skb;
-	psched_time_t now;
 
-	pr_debug("netem_watchdog: fired @%lu\n", jiffies);
-
-	spin_lock_bh(&dev->queue_lock);
-	PSCHED_GET_TIME(now);
-
-	while ((skb = skb_peek(&q->delayed)) != NULL) {
-		const struct netem_skb_cb *cb
-			= (const struct netem_skb_cb *)skb->cb;
-		long delay 
-			= PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
-		pr_debug("netem_watchdog: skb %p@%lu %ld\n",
-			 skb, jiffies, delay);
-
-		/* if more time remaining? */
-		if (delay > 0) {
-			mod_timer(&q->timer, jiffies + delay);
-			break;
-		}
-		__skb_unlink(skb, &q->delayed);
-
-		if (q->qdisc->enqueue(skb, q->qdisc)) {
-			sch->q.qlen--;
-			sch->qstats.drops++;
-		}
-	}
-	qdisc_run(dev);
-	spin_unlock_bh(&dev->queue_lock);
+	pr_debug("netem_watchdog qlen=%d\n", sch->q.qlen);
+	sch->flags &= ~TCQ_F_THROTTLED;
+	netif_schedule(sch->dev);
 }
 
 static void netem_reset(struct Qdisc *sch)
@@ -301,6 +321,7 @@ static void netem_reset(struct Qdisc *sc
 	skb_queue_purge(&q->delayed);
 
 	sch->q.qlen = 0;
+	sch->flags &= ~TCQ_F_THROTTLED;
 	del_timer_sync(&q->timer);
 }
 
