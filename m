From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem: use timer to handle packets not rescheduling
Date: Fri, 22 Oct 2004 12:53:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022125303.6c4c979a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the behaviour of netem's delayed packets queue to make it work better
with TBF and other rate control disciplines.

Now, packets are put in the delayed queue and held there until the next timer interval,
then moved to the underlying qdisc. qlen is set to match the available packets in 
the underlying discipline (and not count those waiting). Previously, netem would perturb
the rate control disciplines because of rescheduling and moving packets in
the dequeue handler.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6/net/sched/sch_netem.c	2004-10-22 11:59:01.888348800 -0700
+++ netem-2.6/net/sched/sch_netem.c	2004-10-22 12:10:09.520853232 -0700
@@ -142,19 +142,23 @@ static int delay_skb(struct Qdisc *sch, 
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
+	psched_tdiff_t td;
 	psched_time_t now;
 	
 	PSCHED_GET_TIME(now);
-	PSCHED_TADD2(now, tabledist(q->latency, q->jitter, 
-				    &q->delay_cor, q->delay_dist),
-		     cb->time_to_send);
+	td = tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist);
+	PSCHED_TADD2(now, td, cb->time_to_send);
 	
 	/* Always queue at tail to keep packets in order */
 	if (likely(q->delayed.qlen < q->limit)) {
 		__skb_queue_tail(&q->delayed, skb);
-		sch->q.qlen++;
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
+
+		if (!timer_pending(&q->timer)) {
+			q->timer.expires = jiffies + PSCHED_US2JIFFIE(td);
+			add_timer(&q->timer);
+		}
 		return NET_XMIT_SUCCESS;
 	}
 
@@ -243,15 +247,31 @@ static struct sk_buff *netem_dequeue(str
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
+
+	skb = q->qdisc->dequeue(q->qdisc);
+	if (skb) 
+		sch->q.qlen--;
+	return skb;
+}
+
+static void netem_watchdog(unsigned long arg)
+{
+	struct Qdisc *sch = (struct Qdisc *)arg;
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
 	psched_time_t now;
 
+	pr_debug("netem_watchdog: fired @%lu\n", jiffies);
+
+	spin_lock_bh(&sch->dev->queue_lock);
 	PSCHED_GET_TIME(now);
+
 	while ((skb = skb_peek(&q->delayed)) != NULL) {
 		const struct netem_skb_cb *cb
 			= (const struct netem_skb_cb *)skb->cb;
 		long delay 
 			= PSCHED_US2JIFFIE(PSCHED_TDIFF(cb->time_to_send, now));
-		pr_debug("netem_dequeue: delay queue %p@%lu %ld\n",
+		pr_debug("netem_watchdog: skb %p@%lu %ld\n",
 			 skb, jiffies, delay);
 
 		/* if more time remaining? */
@@ -263,20 +283,10 @@ static struct sk_buff *netem_dequeue(str
 
 		if (q->qdisc->enqueue(skb, q->qdisc))
 			sch->qstats.drops++;
+		else
+			sch->q.qlen++;
 	}
-
-	skb = q->qdisc->dequeue(q->qdisc);
-	if (skb) 
-		sch->q.qlen--;
-	return skb;
-}
-
-static void netem_watchdog(unsigned long arg)
-{
-	struct Qdisc *sch = (struct Qdisc *)arg;
-
-	pr_debug("netem_watchdog: fired @%lu\n", jiffies);
-	netif_schedule(sch->dev);
+	spin_unlock_bh(&sch->dev->queue_lock);
 }
 
 static void netem_reset(struct Qdisc *sch)
@@ -493,7 +503,7 @@ static int netem_graft(struct Qdisc *sch
 	sch_tree_lock(sch);
 	*old = xchg(&q->qdisc, new);
 	qdisc_reset(*old);
-	sch->q.qlen = q->delayed.qlen;
+	sch->q.qlen = 0;
 	sch_tree_unlock(sch);
 
 	return 0;
