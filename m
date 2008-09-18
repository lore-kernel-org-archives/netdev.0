From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH] sched: only dequeue if packet can be queued to hardware
	queue.
Date: Wed, 17 Sep 2008 23:43:02 -0700
Message-ID: <20080918063036.27934.91273.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, davem@daveloft.net,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63296 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333AbYIRGnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 02:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This this patch is mangled I appologize, this is my first try sending
a patch directly to netdev.

The patch below is my attempt to resolve the issue found with qdisc_run 
only checking the state of queue zero before running.  This approach 
essentially makes the qdisc layer smart enough to do it's own check to 
see if a hw queue is stopped instead of relying on other calls to check 
beforehand.

I have been able to verify functionality for most qdiscs with the
exceptions of netem, red, sfq, and tbf.  I am not familiar with the
operation of these qdiscs and so I am not certain how to avoid the high  
drop rate I am currently seeing when using these qdiscs.

The main advantages of this patch can be seen using a netperf UDP_STREAM
test to a slow interface with multiple queues and a qdisc such as pfifo,
bfifo, or prio.  For my testing I used an 82575 with 4 queues on a
system with 8 cpus.  When any queue other than 0 was used in the old 
method the cpu utilization for one core would go to 100%, using this new 
approach the cpu utilization for all queues was at the same level queue 
0 was with the old approach.

---
This patch changes the behavior of the sch->dequeue to only
dequeue a packet if the queue it is bound for is not currently
stopped.  This functionality is provided via a new op called
smart_dequeue.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/net/pkt_sched.h   |    5 --
 include/net/sch_generic.h |   27 ++++++++++
 net/sched/sch_atm.c       |   22 ++++++++
 net/sched/sch_blackhole.c |    1 
 net/sched/sch_cbq.c       |  118 ++++++++++++++++++++++++++++++++++++++++++++-
 net/sched/sch_dsmark.c    |   47 ++++++++++++++++++
 net/sched/sch_fifo.c      |    2 +
 net/sched/sch_generic.c   |   30 +++++++++--
 net/sched/sch_gred.c      |   34 +++++++++++++
 net/sched/sch_hfsc.c      |   86 ++++++++++++++++++++++++++++++++-
 net/sched/sch_htb.c       |   82 ++++++++++++++++++++++++++++++-
 net/sched/sch_multiq.c    |   45 ++++++++++++++---
 net/sched/sch_netem.c     |   40 +++++++++++++++
 net/sched/sch_prio.c      |   23 +++++++++
 net/sched/sch_red.c       |   22 ++++++++
 net/sched/sch_sfq.c       |   46 ++++++++++++++++--
 net/sched/sch_tbf.c       |   66 +++++++++++++++++++++++++
 net/sched/sch_teql.c      |   49 ++++++++++++++++---
 18 files changed, 706 insertions(+), 39 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b786a5b..4082f39 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,10 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	struct netdev_queue *txq = q->dev_queue;
-
-	if (!netif_tx_queue_stopped(txq) &&
-	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(q);
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e556962..4400a18 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -45,6 +45,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRESS	4
+#define TCQ_F_STOPPED	8
 	int			padded;
 	struct Qdisc_ops	*ops;
 	struct qdisc_size_table	*stab;
@@ -110,6 +111,7 @@ struct Qdisc_ops
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
+	struct sk_buff *	(*smart_dequeue)(struct Qdisc *);
 	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
@@ -399,6 +401,31 @@ static inline int qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
 	return __qdisc_enqueue_tail(skb, sch, &sch->q);
 }
 
+static inline struct sk_buff *__qdisc_smart_dequeue(struct Qdisc *sch,
+						    struct sk_buff_head *list)
+{
+	struct sk_buff *skb = skb_peek(list);
+	struct netdev_queue *txq;
+
+	if (!skb)
+		return NULL;
+
+	txq = netdev_get_tx_queue(qdisc_dev(sch), skb_get_queue_mapping(skb));
+	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
+		sch->flags |= TCQ_F_STOPPED;
+		return NULL;
+	}
+	__skb_unlink(skb, list);
+	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->flags &= ~TCQ_F_STOPPED;
+	return skb;
+}
+
+static inline struct sk_buff *qdisc_smart_dequeue(struct Qdisc *sch)
+{
+	return __qdisc_smart_dequeue(sch, &sch->q);
+}
+
 static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 						   struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 43d3725..91a40b2 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -516,12 +516,31 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 
 	pr_debug("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
-	skb = p->link.q->dequeue(p->link.q);
+	skb = p->link.q->ops->dequeue(p->link.q);
 	if (skb)
 		sch->q.qlen--;
 	return skb;
 }
 
+static struct sk_buff *atm_tc_smart_dequeue(struct Qdisc *sch)
+{
+	struct atm_qdisc_data *p = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	pr_debug("atm_tc_smart_dequeue(sch %p,[qdisc %p])\n", sch, p);
+	tasklet_schedule(&p->task);
+	skb = p->link.q->dequeue(p->link.q);
+	if (skb) {
+		sch->q.qlen--;
+		sch->flags &= ~TCQ_F_STOPPED;
+	} else {
+		if (p->link.q->flags & TCQ_F_STOPPED)
+			sch->flags |= TCQ_F_STOPPED;
+	}
+
+	return skb;
+}
+
 static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -694,6 +713,7 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.priv_size	= sizeof(struct atm_qdisc_data),
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
+	.smart_dequeue	= atm_tc_smart_dequeue,
 	.requeue	= atm_tc_requeue,
 	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..48e6909 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -33,6 +33,7 @@ static struct Qdisc_ops blackhole_qdisc_ops __read_mostly = {
 	.priv_size	= 0,
 	.enqueue	= blackhole_enqueue,
 	.dequeue	= blackhole_dequeue,
+	.smart_dequeue	= blackhole_dequeue,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8b06fa9..5ec6040 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -851,7 +851,7 @@ cbq_under_limit(struct cbq_class *cl)
 }
 
 static __inline__ struct sk_buff *
-cbq_dequeue_prio(struct Qdisc *sch, int prio)
+cbq_dequeue_prio(struct Qdisc *sch, int prio, int *stopped)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl_tail, *cl_prev, *cl;
@@ -881,7 +881,10 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				goto next_class;
 			}
 
-			skb = cl->q->dequeue(cl->q);
+			if (stopped)
+				skb = cl->q->dequeue(cl->q);
+			else
+				skb = cl->q->ops->dequeue(cl->q);
 
 			/* Class did not give us any skb :-(
 			   It could occur even if cl->q->q.qlen != 0
@@ -912,6 +915,11 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 			return skb;
 
 skip_class:
+			if (stopped && (cl->q->flags & TCQ_F_STOPPED)) {
+				*stopped = true;
+				return NULL;
+			}
+
 			if (cl->q->q.qlen == 0 || prio != cl->cpriority) {
 				/* Class is empty or penalized.
 				   Unlink it from active chain.
@@ -964,7 +972,7 @@ cbq_dequeue_1(struct Qdisc *sch)
 	while (activemask) {
 		int prio = ffz(~activemask);
 		activemask &= ~(1<<prio);
-		skb = cbq_dequeue_prio(sch, prio);
+		skb = cbq_dequeue_prio(sch, prio, NULL);
 		if (skb)
 			return skb;
 	}
@@ -1048,6 +1056,109 @@ cbq_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
+static __inline__ struct sk_buff *
+cbq_smart_dequeue_1(struct Qdisc *sch)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	unsigned activemask;
+	int stopped = false;
+
+	activemask = q->activemask&0xFF;
+	while (activemask) {
+		int prio = ffz(~activemask);
+		activemask &= ~(1<<prio);
+		skb = cbq_dequeue_prio(sch, prio, &stopped);
+		if (skb)
+			return skb;
+		if (stopped) {
+			sch->flags |= TCQ_F_STOPPED;
+			break;
+		}
+	}
+	return NULL;
+}
+
+static struct sk_buff *
+cbq_smart_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb;
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	psched_time_t now;
+	psched_tdiff_t incr;
+
+	now = psched_get_time();
+	incr = now - q->now_rt;
+
+	if (q->tx_class) {
+		psched_tdiff_t incr2;
+		/* Time integrator. We calculate EOS time
+		   by adding expected packet transmission time.
+		   If real time is greater, we warp artificial clock,
+		   so that:
+
+		   cbq_time = max(real_time, work);
+		 */
+		incr2 = L2T(&q->link, q->tx_len);
+		q->now += incr2;
+		cbq_update(q);
+		incr -= incr2;
+		if (incr < 0)
+			incr = 0;
+	}
+	q->now += incr;
+	q->now_rt = now;
+
+	for (;;) {
+		q->wd_expires = 0;
+
+		skb = cbq_smart_dequeue_1(sch);
+		if (skb) {
+			sch->q.qlen--;
+			sch->flags &= ~(TCQ_F_THROTTLED | TCQ_F_STOPPED);
+			return skb;
+		}
+
+		if (sch->flags & TCQ_F_STOPPED)
+			return NULL;
+
+		/* All the classes are overlimit.
+
+		   It is possible, if:
+
+		   1. Scheduler is empty.
+		   2. Toplevel cutoff inhibited borrowing.
+		   3. Root class is overlimit.
+
+		   Reset 2d and 3d conditions and retry.
+
+		   Note, that NS and cbq-2.0 are buggy, peeking
+		   an arbitrary class is appropriate for ancestor-only
+		   sharing, but not for toplevel algorithm.
+
+		   Our version is better, but slower, because it requires
+		   two passes, but it is unavoidable with top-level sharing.
+		*/
+
+		if (q->toplevel == TC_CBQ_MAXLEVEL &&
+		    q->link.undertime == PSCHED_PASTPERFECT)
+			break;
+
+		q->toplevel = TC_CBQ_MAXLEVEL;
+		q->link.undertime = PSCHED_PASTPERFECT;
+	}
+
+	/* No packets in scheduler or nobody wants to give them to us :-(
+	   Sigh... start watchdog timer in the last case. */
+
+	if (sch->q.qlen) {
+		sch->qstats.overlimits++;
+		if (q->wd_expires)
+			qdisc_watchdog_schedule(&q->watchdog,
+						now + q->wd_expires);
+	}
+	return NULL;
+}
 /* CBQ class maintanance routines */
 
 static void cbq_adjust_levels(struct cbq_class *this)
@@ -2065,6 +2176,7 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct cbq_sched_data),
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
+	.smart_dequeue	=	cbq_smart_dequeue,
 	.requeue	=	cbq_requeue,
 	.drop		=	cbq_drop,
 	.init		=	cbq_init,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index edd1298..21da7af 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -313,6 +313,52 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *dsmark_smart_dequeue(struct Qdisc *sch)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+	struct sk_buff *skb;
+	u32 index;
+
+	pr_debug("dsmark_smart_dequeue(sch %p,[qdisc %p])\n", sch, p);
+
+	skb = p->q->dequeue(p->q);
+	if (skb == NULL) {
+		if (p->q->flags & TCQ_F_STOPPED)
+			sch->flags |= TCQ_F_STOPPED;
+		return NULL;
+	}
+
+	sch->q.qlen--;
+	sch->flags &= ~TCQ_F_STOPPED;
+
+	index = skb->tc_index & (p->indices - 1);
+	pr_debug("index %d->%d\n", skb->tc_index, index);
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
+				    p->value[index]);
+			break;
+	case __constant_htons(ETH_P_IPV6):
+		ipv6_change_dsfield(ipv6_hdr(skb), p->mask[index],
+				    p->value[index]);
+			break;
+	default:
+		/*
+		 * Only complain if a change was actually attempted.
+		 * This way, we can send non-IP traffic through dsmark
+		 * and don't need yet another qdisc as a bypass.
+		 */
+		if (p->mask[index] != 0xff || p->value[index])
+			printk(KERN_WARNING
+			       "dsmark_smart_dequeue: unsupported protocol %d"
+			       "\n", ntohs(skb->protocol));
+		break;
+	}
+
+	return skb;
+}
+
 static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -496,6 +542,7 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct dsmark_qdisc_data),
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
+	.smart_dequeue	=	dsmark_smart_dequeue,
 	.requeue	=	dsmark_requeue,
 	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 23d258b..15f28f6 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -83,6 +83,7 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.smart_dequeue	=	qdisc_smart_dequeue,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
@@ -98,6 +99,7 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.smart_dequeue	=	qdisc_smart_dequeue,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ec0a083..f32cb83 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -135,8 +135,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_tx_queue_stopped(txq) &&
-	    !netif_tx_queue_frozen(txq))
+	if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
 		ret = dev_hard_start_xmit(skb, dev, txq);
 	HARD_TX_UNLOCK(dev, txq);
 
@@ -163,10 +162,6 @@ static inline int qdisc_restart(struct Qdisc *q)
 		break;
 	}
 
-	if (ret && (netif_tx_queue_stopped(txq) ||
-		    netif_tx_queue_frozen(txq)))
-		ret = 0;
-
 	return ret;
 }
 
@@ -313,6 +308,7 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.smart_dequeue	=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -337,6 +333,7 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.smart_dequeue	=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -400,6 +397,24 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	return NULL;
 }
 
+static struct sk_buff *pfifo_fast_smart_dequeue(struct Qdisc* qdisc)
+{
+	int prio;
+	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct sk_buff *skb;
+
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		if (!skb_queue_empty(list + prio)) {
+			skb = __qdisc_smart_dequeue(qdisc, list + prio);
+			if (skb != NULL)
+				qdisc->q.qlen--;
+			return skb;
+		}
+	}
+
+	return NULL;
+}
+
 static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	qdisc->q.qlen++;
@@ -446,6 +461,7 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
+	.smart_dequeue	=	pfifo_fast_smart_dequeue,
 	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
@@ -475,7 +491,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
-	sch->dequeue = ops->dequeue;
+	sch->dequeue = ops->smart_dequeue;
 	sch->dev_queue = dev_queue;
 	dev_hold(qdisc_dev(sch));
 	atomic_set(&sch->refcnt, 1);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c1ad6b8..5d1654f 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -292,6 +292,39 @@ static struct sk_buff *gred_dequeue(struct Qdisc* sch)
 	return NULL;
 }
 
+static struct sk_buff *gred_smart_dequeue(struct Qdisc* sch)
+{
+	struct sk_buff *skb;
+	struct gred_sched *t = qdisc_priv(sch);
+
+	skb = qdisc_smart_dequeue(sch);
+
+	if (skb) {
+		struct gred_sched_data *q;
+		u16 dp = tc_index_to_dp(skb);
+
+		if (dp >= t->DPs || (q = t->tab[dp]) == NULL) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "GRED: Unable to relocate "
+				       "VQ 0x%x after dequeue, screwing up "
+				       "backlog.\n", tc_index_to_dp(skb));
+		} else {
+			q->backlog -= qdisc_pkt_len(skb);
+
+			if (!q->backlog && !gred_wred_mode(t))
+				red_start_of_idle_period(&q->parms);
+		}
+
+		return skb;
+	}
+
+	if (!(sch->flags & TCQ_F_STOPPED) && gred_wred_mode(t) &&
+	    !red_is_idling(&t->wred_set))
+		red_start_of_idle_period(&t->wred_set);
+
+	return NULL;
+}
+
 static unsigned int gred_drop(struct Qdisc* sch)
 {
 	struct sk_buff *skb;
@@ -602,6 +635,7 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct gred_sched),
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
+	.smart_dequeue	=	gred_smart_dequeue,
 	.requeue	=	gred_requeue,
 	.drop		=	gred_drop,
 	.init		=	gred_init,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c1e77da..2060250 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -889,7 +889,7 @@ qdisc_peek_len(struct Qdisc *sch)
 	struct sk_buff *skb;
 	unsigned int len;
 
-	skb = sch->dequeue(sch);
+	skb = sch->ops->dequeue(sch);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("qdisc_peek_len: non work-conserving qdisc ?\n");
@@ -1642,7 +1642,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		}
 	}
 
-	skb = cl->qdisc->dequeue(cl->qdisc);
+	skb = cl->qdisc->ops->dequeue(cl->qdisc);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("HFSC: Non-work-conserving qdisc ?\n");
@@ -1674,6 +1674,87 @@ hfsc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *
+hfsc_smart_dequeue(struct Qdisc *sch)
+{
+	struct hfsc_sched *q = qdisc_priv(sch);
+	struct hfsc_class *cl;
+	struct sk_buff *skb;
+	u64 cur_time;
+	unsigned int next_len;
+	int realtime = 0;
+
+	if (sch->q.qlen == 0)
+		return NULL;
+	skb = skb_peek(&q->requeue);
+	if (skb) {
+		struct netdev_queue *txq;
+		txq = netdev_get_tx_queue(qdisc_dev(sch),
+		                          skb_get_queue_mapping(skb));
+		if (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq)) {
+			sch->flags |= TCQ_F_STOPPED;
+			return NULL;
+		}
+		__skb_unlink(skb, &q->requeue);
+		goto out;
+	}
+
+	cur_time = psched_get_time();
+
+	/*
+	 * if there are eligible classes, use real-time criteria.
+	 * find the class with the minimum deadline among
+	 * the eligible classes.
+	 */
+	cl = eltree_get_mindl(q, cur_time);
+	if (cl != NULL) {
+		realtime = 1;
+	} else {
+		/*
+		 * use link-sharing criteria
+		 * get the class with the minimum vt in the hierarchy
+		 */
+		cl = vttree_get_minvt(&q->root, cur_time);
+		if (cl == NULL) {
+			sch->qstats.overlimits++;
+			hfsc_schedule_watchdog(sch);
+			return NULL;
+		}
+	}
+
+	skb = cl->qdisc->dequeue(cl->qdisc);
+	if (skb == NULL) {
+		if (net_ratelimit())
+			printk("HFSC: Non-work-conserving qdisc ?\n");
+		return NULL;
+	}
+
+	update_vf(cl, qdisc_pkt_len(skb), cur_time);
+	if (realtime)
+		cl->cl_cumul += qdisc_pkt_len(skb);
+
+	if (cl->qdisc->q.qlen != 0) {
+		if (cl->cl_flags & HFSC_RSC) {
+			/* update ed */
+			next_len = qdisc_peek_len(cl->qdisc);
+			if (realtime)
+				update_ed(cl, next_len);
+			else
+				update_d(cl, next_len);
+		}
+	} else {
+		/* the class becomes passive */
+		set_passive(cl);
+	}
+
+ out:
+	sch->flags &= ~(TCQ_F_THROTTLED | TCQ_F_STOPPED);
+	sch->q.qlen--;
+
+	return skb;
+}
+
 static int
 hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
@@ -1735,6 +1816,7 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.dump		= hfsc_dump_qdisc,
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
+	.smart_dequeue	= hfsc_smart_dequeue,
 	.requeue	= hfsc_requeue,
 	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d14f020..4da1a85 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -803,7 +803,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 /* dequeues packet at given priority and level; call only if
    you are sure that there is active class at prio/level */
 static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
-					int level)
+					int level, int *stopped)
 {
 	struct sk_buff *skb = NULL;
 	struct htb_class *cl, *start;
@@ -840,9 +840,17 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		if (stopped)
+			skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		else
+			skb = cl->un.leaf.q->ops->dequeue(cl->un.leaf.q);
+
 		if (likely(skb != NULL))
 			break;
+		if (stopped && (cl->un.leaf.q->flags & TCQ_F_STOPPED)) {
+			*stopped = true;
+			break;
+		}
 		if (!cl->warned) {
 			printk(KERN_WARNING
 			       "htb: class %X isn't work conserving ?!\n",
@@ -915,7 +923,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		while (m != (int)(-1)) {
 			int prio = ffz(m);
 			m |= 1 << prio;
-			skb = htb_dequeue_tree(q, prio, level);
+			skb = htb_dequeue_tree(q, prio, level, NULL);
 			if (likely(skb != NULL)) {
 				sch->q.qlen--;
 				sch->flags &= ~TCQ_F_THROTTLED;
@@ -929,6 +937,73 @@ fin:
 	return skb;
 }
 
+static struct sk_buff *htb_smart_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = NULL;
+	struct htb_sched *q = qdisc_priv(sch);
+	int level, stopped = false;
+	psched_time_t next_event;
+
+	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
+	skb = skb_peek(&q->direct_queue);
+	if (skb) {
+		struct netdev_queue *txq;
+		txq = netdev_get_tx_queue(qdisc_dev(sch),
+		                          skb_get_queue_mapping(skb));
+		if (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq)) {
+			sch->flags |= TCQ_F_STOPPED;
+			return NULL;
+		}
+		__skb_unlink(skb, &q->direct_queue);
+		sch->flags &= ~(TCQ_F_THROTTLED | TCQ_F_STOPPED);
+		sch->q.qlen--;
+		return skb;
+	}
+
+	if (!sch->q.qlen)
+		goto fin;
+	q->now = psched_get_time();
+
+	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
+	q->nwc_hit = 0;
+	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
+		/* common case optimization - skip event handler quickly */
+		int m;
+		psched_time_t event;
+
+		if (q->now >= q->near_ev_cache[level]) {
+			event = htb_do_events(q, level);
+			if (!event)
+				event = q->now + PSCHED_TICKS_PER_SEC;
+			q->near_ev_cache[level] = event;
+		} else
+			event = q->near_ev_cache[level];
+
+		if (event && next_event > event)
+			next_event = event;
+
+		m = ~q->row_mask[level];
+		while (m != (int)(-1)) {
+			int prio = ffz(m);
+			m |= 1 << prio;
+			skb = htb_dequeue_tree(q, prio, level, &stopped);
+			if (likely(skb != NULL)) {
+				sch->q.qlen--;
+				sch->flags &= ~(TCQ_F_THROTTLED |
+				                TCQ_F_STOPPED);
+				goto fin;
+			}
+			if (stopped)
+				goto fin;
+		}
+	}
+	sch->qstats.overlimits++;
+	qdisc_watchdog_schedule(&q->watchdog, next_event);
+fin:
+	return skb;
+}
+
 /* try to drop from each class (by prio) until one succeed */
 static unsigned int htb_drop(struct Qdisc *sch)
 {
@@ -1565,6 +1640,7 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct htb_sched),
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
+	.smart_dequeue	=	htb_smart_dequeue,
 	.requeue	=	htb_requeue,
 	.drop		=	htb_drop,
 	.init		=	htb_init,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 7f4dbf0..e201171 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -142,15 +142,45 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 		/* Check that target subqueue is available before
 		 * pulling an skb to avoid excessive requeues
 		 */
-		if (!__netif_subqueue_stopped(qdisc_dev(sch), q->curband)) {
-			qdisc = q->queues[q->curband];
-			skb = qdisc->dequeue(qdisc);
-			if (skb) {
-				sch->q.qlen--;
-				return skb;
-			}
+		qdisc = q->queues[q->curband];
+		skb = qdisc->ops->dequeue(qdisc);
+		if (skb) {
+			sch->q.qlen--;
+			return skb;
+		}
+	}
+	return NULL;
+
+}
+
+static struct sk_buff *multiq_smart_dequeue(struct Qdisc *sch)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *qdisc;
+	struct sk_buff *skb;
+	int band, stopped = 0;
+
+	for (band = 0; band < q->bands; band++) {
+		/* cycle through bands to ensure fairness */
+		q->curband++;
+		if (q->curband >= q->bands)
+			q->curband = 0;
+
+		/* Check that target subqueue is available before
+		 * pulling an skb to avoid excessive requeues
+		 */
+		qdisc = q->queues[q->curband];
+		skb = qdisc->dequeue(qdisc);
+		if (skb) {
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_STOPPED;
+			return skb;
 		}
+		if (qdisc->flags & TCQ_F_STOPPED)
+			stopped++;
 	}
+	if (stopped)
+		sch->flags |= TCQ_F_STOPPED;
 	return NULL;
 
 }
@@ -448,6 +478,7 @@ static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct multiq_sched_data),
 	.enqueue	=	multiq_enqueue,
 	.dequeue	=	multiq_dequeue,
+	.smart_dequeue	=	multiq_smart_dequeue,
 	.requeue	=	multiq_requeue,
 	.drop		=	multiq_drop,
 	.init		=	multiq_init,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a119599..47dfe8e 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -283,7 +283,7 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	if (sch->flags & TCQ_F_THROTTLED)
 		return NULL;
 
-	skb = q->qdisc->dequeue(q->qdisc);
+	skb = q->qdisc->ops->dequeue(q->qdisc);
 	if (skb) {
 		const struct netem_skb_cb *cb = netem_skb_cb(skb);
 		psched_time_t now = psched_get_time();
@@ -308,6 +308,42 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
+static struct sk_buff *netem_smart_dequeue(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	smp_mb();
+	if (sch->flags & TCQ_F_THROTTLED)
+		return NULL;
+
+	skb = q->qdisc->dequeue(q->qdisc);
+	if (skb) {
+		const struct netem_skb_cb *cb = netem_skb_cb(skb);
+		psched_time_t now = psched_get_time();
+
+		/* if more time remaining? */
+		if (cb->time_to_send <= now) {
+			pr_debug("netem_dequeue: return skb=%p\n", skb);
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_STOPPED;
+			return skb;
+		}
+
+		if (unlikely(q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS)) {
+			qdisc_tree_decrease_qlen(q->qdisc, 1);
+			sch->qstats.drops++;
+			printk(KERN_ERR "netem: %s could not requeue\n",
+			       q->qdisc->ops->id);
+		}
+
+		qdisc_watchdog_schedule(&q->watchdog, cb->time_to_send);
+	} else if (q->qdisc->flags & TCQ_F_STOPPED) {
+		sch->flags |= TCQ_F_STOPPED;
+	}
+
+	return NULL;
+}
 static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -541,6 +577,7 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	tfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.smart_dequeue	=	qdisc_smart_dequeue,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
@@ -716,6 +753,7 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
+	.smart_dequeue	=	netem_smart_dequeue,
 	.requeue	=	netem_requeue,
 	.drop		=	netem_drop,
 	.init		=	netem_init,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 504a78c..f085dbe 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -128,11 +128,33 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 
 	for (prio = 0; prio < q->bands; prio++) {
 		struct Qdisc *qdisc = q->queues[prio];
+		struct sk_buff *skb = qdisc->ops->dequeue(qdisc);
+		if (skb) {
+			sch->q.qlen--;
+			return skb;
+		}
+	}
+	return NULL;
+
+}
+
+static struct sk_buff *prio_smart_dequeue(struct Qdisc* sch)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int prio;
+
+	for (prio = 0; prio < q->bands; prio++) {
+		struct Qdisc *qdisc = q->queues[prio];
 		struct sk_buff *skb = qdisc->dequeue(qdisc);
 		if (skb) {
 			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_STOPPED;
 			return skb;
 		}
+		if (qdisc->flags & TCQ_F_STOPPED) {
+			sch->flags |= TCQ_F_STOPPED;
+			return NULL;
+		}
 	}
 	return NULL;
 
@@ -421,6 +443,7 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct prio_sched_data),
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
+	.smart_dequeue	=	prio_smart_dequeue,
 	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5da0583..b8247cb 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -131,7 +131,7 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
 
-	skb = child->dequeue(child);
+	skb = child->ops->dequeue(child);
 	if (skb)
 		sch->q.qlen--;
 	else if (!red_is_idling(&q->parms))
@@ -140,6 +140,25 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff * red_smart_dequeue(struct Qdisc* sch)
+{
+	struct sk_buff *skb;
+	struct red_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+
+	skb = child->dequeue(child);
+	if (skb) {
+		sch->q.qlen--;
+		sch->flags &= ~TCQ_F_STOPPED;
+	} else {
+		if (child->flags & TCQ_F_STOPPED)
+			sch->flags |= TCQ_F_STOPPED;
+		else if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+	}
+
+	return skb;
+}
 static unsigned int red_drop(struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -361,6 +380,7 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.cl_ops		=	&red_class_ops,
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
+	.smart_dequeue	=	red_smart_dequeue,
 	.requeue	=	red_requeue,
 	.drop		=	red_drop,
 	.init		=	red_init,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..2a7ba8e 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -391,9 +391,6 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_CN;
 }
 
-
-
-
 static struct sk_buff *
 sfq_dequeue(struct Qdisc *sch)
 {
@@ -431,6 +428,48 @@ sfq_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *
+sfq_smart_dequeue(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	sfq_index a, old_a;
+	struct netdev_queue *txq;
+
+	/* No active slots */
+	if (q->tail == SFQ_DEPTH)
+		return NULL;
+
+	a = old_a = q->next[q->tail];
+
+	/* Grab packet */
+	skb = __qdisc_smart_dequeue(sch, &q->qs[a]);
+
+	if (!skb && (sch->flags & TCQ_F_STOPPED))
+		return NULL;
+
+	sfq_dec(q, a);
+	sch->q.qlen--;
+
+	/* Is the slot empty? */
+	if (q->qs[a].qlen == 0) {
+		q->ht[q->hash[a]] = SFQ_DEPTH;
+		a = q->next[a];
+		if (a == old_a) {
+			q->tail = SFQ_DEPTH;
+			return skb;
+		}
+		q->next[q->tail] = a;
+		q->allot[a] += q->quantum;
+	} else if ((q->allot[a] -= qdisc_pkt_len(skb)) <= 0) {
+		q->tail = a;
+		a = q->next[a];
+		q->allot[a] += q->quantum;
+	}
+	sch->flags &= ~TCQ_F_STOPPED;
+	return skb;
+}
+
 static void
 sfq_reset(struct Qdisc *sch)
 {
@@ -624,6 +663,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
+	.smart_dequeue	=	sfq_smart_dequeue,
 	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 94c6159..f65204c 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -169,6 +169,67 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
+	skb = q->qdisc->ops->dequeue(q->qdisc);
+
+	if (skb) {
+		psched_time_t now;
+		long toks;
+		long ptoks = 0;
+		unsigned int len = qdisc_pkt_len(skb);
+
+		now = psched_get_time();
+		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
+
+		if (q->P_tab) {
+			ptoks = toks + q->ptokens;
+			if (ptoks > (long)q->mtu)
+				ptoks = q->mtu;
+			ptoks -= L2T_P(q, len);
+		}
+		toks += q->tokens;
+		if (toks > (long)q->buffer)
+			toks = q->buffer;
+		toks -= L2T(q, len);
+
+		if ((toks|ptoks) >= 0) {
+			q->t_c = now;
+			q->tokens = toks;
+			q->ptokens = ptoks;
+			sch->q.qlen--;
+			sch->flags &= ~TCQ_F_THROTTLED;
+			return skb;
+		}
+
+		qdisc_watchdog_schedule(&q->watchdog,
+					now + max_t(long, -toks, -ptoks));
+
+		/* Maybe we have a shorter packet in the queue,
+		   which can be sent now. It sounds cool,
+		   but, however, this is wrong in principle.
+		   We MUST NOT reorder packets under these circumstances.
+
+		   Really, if we split the flow into independent
+		   subflows, it would be a very good solution.
+		   This is the main idea of all FQ algorithms
+		   (cf. CSZ, HPFQ, HFSC)
+		 */
+
+		if (q->qdisc->ops->requeue(skb, q->qdisc) != NET_XMIT_SUCCESS) {
+			/* When requeue fails skb is dropped */
+			qdisc_tree_decrease_qlen(q->qdisc, 1);
+			sch->qstats.drops++;
+		}
+
+		sch->qstats.overlimits++;
+	}
+	return NULL;
+}
+
+static struct sk_buff *tbf_smart_dequeue(struct Qdisc* sch)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
 	skb = q->qdisc->dequeue(q->qdisc);
 
 	if (skb) {
@@ -179,6 +240,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 
 		now = psched_get_time();
 		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
+		sch->flags &= ~TCQ_F_STOPPED;
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
@@ -221,7 +283,10 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		}
 
 		sch->qstats.overlimits++;
+	} else if (q->qdisc->flags & TCQ_F_STOPPED) {
+		sch->flags |= TCQ_F_STOPPED;
 	}
+
 	return NULL;
 }
 
@@ -469,6 +534,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct tbf_sched_data),
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
+	.smart_dequeue	=	tbf_smart_dequeue,
 	.requeue	=	tbf_requeue,
 	.drop		=	tbf_drop,
 	.init		=	tbf_init,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index d35ef05..fecb3f8 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -123,6 +123,40 @@ teql_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff *
+teql_smart_dequeue(struct Qdisc* sch)
+{
+	struct teql_sched_data *dat = qdisc_priv(sch);
+	struct netdev_queue *dat_queue;
+	struct sk_buff *skb;
+	struct netdev_queue *txq;
+
+	skb = skb_peek(&dat->q);
+	if (skb) {
+		txq = netdev_get_tx_queue(qdisc_dev(sch),
+		                          skb_get_queue_mapping(skb));
+		if (netif_tx_queue_stopped(txq) ||
+		    netif_tx_queue_frozen(txq)) {
+			sch->flags |= TCQ_F_STOPPED;
+			return NULL;
+		}
+		__skb_unlink(skb, &dat->q);
+	}
+	dat_queue = netdev_get_tx_queue(dat->m->dev, 0);
+	if (skb == NULL) {
+		struct net_device *m = qdisc_dev(dat_queue->qdisc);
+		if (m) {
+			dat->m->slaves = sch;
+			netif_wake_queue(m);
+		}
+	} else {
+		sch->flags &= ~TCQ_F_STOPPED;
+	}
+	sch->q.qlen = dat->q.qlen + dat_queue->qdisc->q.qlen;
+
+	return skb;
+}
+
 static __inline__ void
 teql_neigh_release(struct neighbour *n)
 {
@@ -431,13 +465,14 @@ static __init void teql_master_setup(struct net_device *dev)
 	master->dev	= dev;
 	ops->priv_size  = sizeof(struct teql_sched_data);
 
-	ops->enqueue	=	teql_enqueue;
-	ops->dequeue	=	teql_dequeue;
-	ops->requeue	=	teql_requeue;
-	ops->init	=	teql_qdisc_init;
-	ops->reset	=	teql_reset;
-	ops->destroy	=	teql_destroy;
-	ops->owner	=	THIS_MODULE;
+	ops->enqueue		= teql_enqueue;
+	ops->dequeue		= teql_dequeue;
+	ops->smart_dequeue	= teql_smart_dequeue;
+	ops->requeue		= teql_requeue;
+	ops->init		= teql_qdisc_init;
+	ops->reset		= teql_reset;
+	ops->destroy		= teql_destroy;
+	ops->owner		= THIS_MODULE;
 
 	dev->open		= teql_master_open;
 	dev->hard_start_xmit	= teql_master_xmit;

