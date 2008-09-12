From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Thu, 11 Sep 2008 21:49:29 -0700 (PDT)
Message-ID: <20080911.214929.152271268.davem@davemloft.net>
References: <20080911.044255.245121628.davem@davemloft.net>
	<20080911114502.GA22698@gondor.apana.org.au>
	<20080911.044717.265303740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbYILEtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 00:49:36 -0400
In-Reply-To: <20080911.044717.265303740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Sep 2008 04:47:17 -0700 (PDT)

> Ok, so implementing ->peek() is the first step in dealing
> with this.

Ok, here's a first cut at this.

Most of it is simple and straightforward.

As usual, though, CBQ, HFSC, and HTB are complicated.

Most of the peek implementations just skb_peek() in their
downstream queue or iterate over their prio array doing
the same looking for a non-empty list.

But CBQ, HFSC, and HTB have complicated class iterators and
internal time state machine things.  I tried to do my best
in these cases.

I didn't want these things firing off class watchdog timers and
stuff like this.  Just see if there is any packet ready now
and return it.

The one exception is that I allow CBQ to advance it's time
state machine.

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e556962..c4eb6e5 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -41,6 +41,7 @@ struct Qdisc
 {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
+	struct sk_buff *	(*peek)(struct Qdisc *dev);
 	unsigned		flags;
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
@@ -110,6 +111,7 @@ struct Qdisc_ops
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
+	struct sk_buff *	(*peek)(struct Qdisc *);
 	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
 
@@ -431,6 +433,28 @@ static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
 	return __qdisc_dequeue_tail(sch, &sch->q);
 }
 
+static inline struct sk_buff *__qdisc_peek_head(struct Qdisc *sch,
+						struct sk_buff_head *list)
+{
+	return skb_peek(list);
+}
+
+static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
+{
+	return __qdisc_peek_head(sch, &sch->q);
+}
+
+static inline struct sk_buff *__qdisc_peek_tail(struct Qdisc *sch,
+						struct sk_buff_head *list)
+{
+	return skb_peek_tail(list);
+}
+
+static inline struct sk_buff *qdisc_peek_tail(struct Qdisc *sch)
+{
+	return __qdisc_peek_tail(sch, &sch->q);
+}
+
 static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 43d3725..cfe44c0 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -522,6 +522,13 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
+{
+	struct atm_qdisc_data *p = qdisc_priv(sch);
+
+	return p->link.q->peek(p->link.q);
+}
+
 static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -694,6 +701,7 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.priv_size	= sizeof(struct atm_qdisc_data),
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
+	.peek		= atm_tc_peek,
 	.requeue	= atm_tc_requeue,
 	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..094a874 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -33,6 +33,7 @@ static struct Qdisc_ops blackhole_qdisc_ops __read_mostly = {
 	.priv_size	= 0,
 	.enqueue	= blackhole_enqueue,
 	.dequeue	= blackhole_dequeue,
+	.peek		= blackhole_dequeue,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8b06fa9..bf1a5d9 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -851,7 +851,7 @@ cbq_under_limit(struct cbq_class *cl)
 }
 
 static __inline__ struct sk_buff *
-cbq_dequeue_prio(struct Qdisc *sch, int prio)
+cbq_dequeue_prio(struct Qdisc *sch, int prio, int peek)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *cl_tail, *cl_prev, *cl;
@@ -881,7 +881,13 @@ cbq_dequeue_prio(struct Qdisc *sch, int prio)
 				goto next_class;
 			}
 
-			skb = cl->q->dequeue(cl->q);
+			if (peek) {
+				skb = cl->q->peek(cl->q);
+				if (skb)
+					return skb;
+			} else {
+				skb = cl->q->dequeue(cl->q);
+			}
 
 			/* Class did not give us any skb :-(
 			   It could occur even if cl->q->q.qlen != 0
@@ -964,23 +970,34 @@ cbq_dequeue_1(struct Qdisc *sch)
 	while (activemask) {
 		int prio = ffz(~activemask);
 		activemask &= ~(1<<prio);
-		skb = cbq_dequeue_prio(sch, prio);
+		skb = cbq_dequeue_prio(sch, prio, 0);
 		if (skb)
 			return skb;
 	}
 	return NULL;
 }
 
-static struct sk_buff *
-cbq_dequeue(struct Qdisc *sch)
+static __inline__ struct sk_buff *
+cbq_peek_1(struct Qdisc *sch)
 {
-	struct sk_buff *skb;
 	struct cbq_sched_data *q = qdisc_priv(sch);
-	psched_time_t now;
-	psched_tdiff_t incr;
+	struct sk_buff *skb;
+	unsigned activemask;
 
-	now = psched_get_time();
-	incr = now - q->now_rt;
+	activemask = q->activemask&0xFF;
+	while (activemask) {
+		int prio = ffz(~activemask);
+		activemask &= ~(1<<prio);
+		skb = cbq_dequeue_prio(sch, prio, 1);
+		if (skb)
+			return skb;
+	}
+	return NULL;
+}
+
+static void cbq_update_clock(struct cbq_sched_data *q, psched_time_t now)
+{
+	psched_tdiff_t incr = now - q->now_rt;
 
 	if (q->tx_class) {
 		psched_tdiff_t incr2;
@@ -999,7 +1016,18 @@ cbq_dequeue(struct Qdisc *sch)
 	}
 	q->now += incr;
 	q->now_rt = now;
+}
 
+static struct sk_buff *
+cbq_dequeue(struct Qdisc *sch)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	psched_time_t now;
+
+	now = psched_get_time();
+
+	cbq_update_clock(q, now);
 	for (;;) {
 		q->wd_expires = 0;
 
@@ -1048,6 +1076,30 @@ cbq_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
+static struct sk_buff *
+cbq_peek(struct Qdisc *sch)
+{
+	struct cbq_sched_data *q = qdisc_priv(sch);
+	psched_time_t now;
+
+	now = psched_get_time();
+
+	cbq_update_clock(q, now);
+	for (;;) {
+		struct sk_buff *skb = cbq_peek_1(sch);
+		if (skb)
+			return skb;
+
+		if (q->toplevel == TC_CBQ_MAXLEVEL &&
+		    q->link.undertime == PSCHED_PASTPERFECT)
+			break;
+
+		q->toplevel = TC_CBQ_MAXLEVEL;
+		q->link.undertime = PSCHED_PASTPERFECT;
+	}
+	return NULL;
+}
+
 /* CBQ class maintanance routines */
 
 static void cbq_adjust_levels(struct cbq_class *this)
@@ -2065,6 +2117,7 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct cbq_sched_data),
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
+	.peek		=	cbq_peek,
 	.requeue	=	cbq_requeue,
 	.drop		=	cbq_drop,
 	.init		=	cbq_init,
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index edd1298..7213faa 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -313,6 +313,13 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *dsmark_peek(struct Qdisc *sch)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+
+	return p->q->ops->peek(p->q);
+}
+
 static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -496,6 +503,7 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct dsmark_qdisc_data),
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
+	.peek		=	dsmark_peek,
 	.requeue	=	dsmark_requeue,
 	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 23d258b..8825e88 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -83,6 +83,7 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
@@ -98,6 +99,7 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ec0a083..148c117 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -313,6 +313,7 @@ struct Qdisc_ops noop_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -324,6 +325,7 @@ static struct netdev_queue noop_netdev_queue = {
 struct Qdisc noop_qdisc = {
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
@@ -337,6 +339,7 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.priv_size	=	0,
 	.enqueue	=	noop_enqueue,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.requeue	=	noop_requeue,
 	.owner		=	THIS_MODULE,
 };
@@ -349,6 +352,7 @@ static struct netdev_queue noqueue_netdev_queue = {
 static struct Qdisc noqueue_qdisc = {
 	.enqueue	=	NULL,
 	.dequeue	=	noop_dequeue,
+	.peek		=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
@@ -400,6 +404,19 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 	return NULL;
 }
 
+static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
+{
+	int prio;
+	struct sk_buff_head *list = qdisc_priv(qdisc);
+
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		if (!skb_queue_empty(list + prio))
+			return __qdisc_peek_head(qdisc, list + prio);
+	}
+
+	return NULL;
+}
+
 static int pfifo_fast_requeue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	qdisc->q.qlen++;
@@ -446,6 +463,7 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
+	.peek		=	pfifo_fast_peek,
 	.requeue	=	pfifo_fast_requeue,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
@@ -476,6 +494,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
+	sch->peek = ops->peek;
 	sch->dev_queue = dev_queue;
 	dev_hold(qdisc_dev(sch));
 	atomic_set(&sch->refcnt, 1);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c1ad6b8..cb20ee3 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -602,6 +602,7 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct gred_sched),
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	gred_requeue,
 	.drop		=	gred_drop,
 	.init		=	gred_init,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index c1e77da..c9e80de 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1674,6 +1674,39 @@ hfsc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *
+hfsc_peek(struct Qdisc *sch)
+{
+	struct hfsc_sched *q = qdisc_priv(sch);
+	struct hfsc_class *cl;
+	struct sk_buff *skb;
+	u64 cur_time;
+
+	if (sch->q.qlen == 0)
+		return NULL;
+	if ((skb = skb_peek(&q->requeue)))
+		return skb;
+
+	cur_time = psched_get_time();
+
+	/*
+	 * if there are eligible classes, use real-time criteria.
+	 * find the class with the minimum deadline among
+	 * the eligible classes.
+	 */
+	if ((cl = eltree_get_mindl(q, cur_time)) == NULL) {
+		/*
+		 * use link-sharing criteria
+		 * get the class with the minimum vt in the hierarchy
+		 */
+		cl = vttree_get_minvt(&q->root, cur_time);
+		if (cl == NULL)
+			return NULL;
+	}
+
+	return cl->qdisc->peek(cl->qdisc);
+}
+
 static int
 hfsc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
@@ -1735,6 +1768,7 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.dump		= hfsc_dump_qdisc,
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
+	.peek		= hfsc_peek,
 	.requeue	= hfsc_requeue,
 	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d14f020..adc0264 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -803,7 +803,7 @@ static struct htb_class *htb_lookup_leaf(struct rb_root *tree, int prio,
 /* dequeues packet at given priority and level; call only if
    you are sure that there is active class at prio/level */
 static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
-					int level)
+					int level, int peek)
 {
 	struct sk_buff *skb = NULL;
 	struct htb_class *cl, *start;
@@ -840,7 +840,10 @@ next:
 			goto next;
 		}
 
-		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
+		if (peek)
+			skb = cl->un.leaf.q->peek(cl->un.leaf.q);
+		else
+			skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
 		if (likely(skb != NULL))
 			break;
 		if (!cl->warned) {
@@ -858,7 +861,7 @@ next:
 
 	} while (cl != start);
 
-	if (likely(skb != NULL)) {
+	if (likely(skb != NULL && !peek)) {
 		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
 		if (cl->un.leaf.deficit[level] < 0) {
 			cl->un.leaf.deficit[level] += cl->un.leaf.quantum;
@@ -915,7 +918,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 		while (m != (int)(-1)) {
 			int prio = ffz(m);
 			m |= 1 << prio;
-			skb = htb_dequeue_tree(q, prio, level);
+			skb = htb_dequeue_tree(q, prio, level, 0);
 			if (likely(skb != NULL)) {
 				sch->q.qlen--;
 				sch->flags &= ~TCQ_F_THROTTLED;
@@ -929,6 +932,52 @@ fin:
 	return skb;
 }
 
+static struct sk_buff *htb_peek(struct Qdisc *sch)
+{
+	struct htb_sched *q = qdisc_priv(sch);
+	psched_time_t next_event;
+	struct sk_buff *skb;
+	int level;
+
+	/* try to peek direct packets as high prio (!) to minimize cpu work */
+	if ((skb = skb_peek(&q->direct_queue)))
+		return skb;
+
+	if (!sch->q.qlen)
+		return NULL;
+
+	q->now = psched_get_time();
+
+	next_event = q->now + 5 * PSCHED_TICKS_PER_SEC;
+	q->nwc_hit = 0;
+	for (level = 0; level < TC_HTB_MAXDEPTH; level++) {
+		/* common case optimization - skip event handler quickly */
+		psched_time_t event;
+		int m;
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
+			skb = htb_dequeue_tree(q, prio, level, 1);
+			if (likely(skb != NULL))
+				return skb;
+		}
+	}
+	return NULL;
+}
+
 /* try to drop from each class (by prio) until one succeed */
 static unsigned int htb_drop(struct Qdisc *sch)
 {
@@ -1565,6 +1614,7 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct htb_sched),
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
+	.peek		=	htb_peek,
 	.requeue	=	htb_requeue,
 	.drop		=	htb_drop,
 	.init		=	htb_init,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a119599..528cd55 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -308,6 +308,28 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	return NULL;
 }
 
+static struct sk_buff *netem_peek(struct Qdisc *sch)
+{
+	struct netem_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	smp_mb();
+	if (sch->flags & TCQ_F_THROTTLED)
+		return NULL;
+
+	skb = q->qdisc->peek(q->qdisc);
+	if (skb) {
+		const struct netem_skb_cb *cb = netem_skb_cb(skb);
+		psched_time_t now = psched_get_time();
+
+		/* if more time remaining? */
+		if (cb->time_to_send <= now)
+			return skb;
+	}
+
+	return NULL;
+}
+
 static void netem_reset(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
@@ -541,6 +563,7 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	tfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
@@ -716,6 +739,7 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
+	.peek		=	netem_peek,
 	.requeue	=	netem_requeue,
 	.drop		=	netem_drop,
 	.init		=	netem_init,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 504a78c..7ae2226 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -138,6 +138,21 @@ static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 
 }
 
+static struct sk_buff *prio_peek(struct Qdisc* sch)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int prio;
+
+	for (prio = 0; prio < q->bands; prio++) {
+		struct Qdisc *qdisc = q->queues[prio];
+		struct sk_buff *skb = qdisc->peek(qdisc);
+		if (skb)
+			return skb;
+	}
+	return NULL;
+
+}
+
 static unsigned int prio_drop(struct Qdisc* sch)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
@@ -421,6 +436,7 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct prio_sched_data),
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
+	.peek		=	prio_peek,
 	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5da0583..f1b6465 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -140,6 +140,14 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff * red_peek(struct Qdisc* sch)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+
+	return child->peek(child);
+}
+
 static unsigned int red_drop(struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -361,6 +369,7 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.cl_ops		=	&red_class_ops,
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
+	.peek		=	red_peek,
 	.requeue	=	red_requeue,
 	.drop		=	red_drop,
 	.init		=	red_init,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..16102da 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -431,6 +431,21 @@ sfq_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *
+sfq_peek(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_index a;
+
+	/* No active slots */
+	if (q->tail == SFQ_DEPTH)
+		return NULL;
+
+	a = q->next[q->tail];
+
+	return skb_peek(&q->qs[a]);
+}
+
 static void
 sfq_reset(struct Qdisc *sch)
 {
@@ -624,6 +639,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
+	.peek		=	sfq_peek,
 	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 94c6159..876a0a7 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -225,6 +225,13 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 	return NULL;
 }
 
+static struct sk_buff *tbf_peek(struct Qdisc* sch)
+{
+	struct tbf_sched_data *q = qdisc_priv(sch);
+
+	return q->qdisc->peek(q->qdisc);
+}
+
 static void tbf_reset(struct Qdisc* sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -469,6 +476,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct tbf_sched_data),
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
+	.peek		=	tbf_peek,
 	.requeue	=	tbf_requeue,
 	.drop		=	tbf_drop,
 	.init		=	tbf_init,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index d35ef05..8d7acd8 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -123,6 +123,14 @@ teql_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff *
+teql_peek(struct Qdisc* sch)
+{
+	struct teql_sched_data *dat = qdisc_priv(sch);
+
+	return skb_peek(&dat->q);
+}
+
 static __inline__ void
 teql_neigh_release(struct neighbour *n)
 {
@@ -433,6 +441,7 @@ static __init void teql_master_setup(struct net_device *dev)
 
 	ops->enqueue	=	teql_enqueue;
 	ops->dequeue	=	teql_dequeue;
+	ops->peek	=	teql_peek;
 	ops->requeue	=	teql_requeue;
 	ops->init	=	teql_qdisc_init;
 	ops->reset	=	teql_reset;
