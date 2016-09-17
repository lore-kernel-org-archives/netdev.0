From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 5/5] sched: add and use qdisc_skb_head helpers
Date: Sun, 18 Sep 2016 00:57:34 +0200
Message-ID: <1474153054-9059-6-git-send-email-fw@strlen.de>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51398 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755302AbcIQW5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:47 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces sk_buff_head struct in Qdiscs with new qdisc_skb_head.

Its similar to the skb_buff_head api, but does not use skb->prev pointers.

Qdiscs will commonly enqueue at the tail of a list and dequeue at head.
While skb_buff_head works fine for this, enqueue/dequeue needs to also
adjust the prev pointer of next element.

The ->prev pointer is not required for qdiscs so we can just leave
it undefined and avoid one cacheline write access for en/dequeue.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h | 63 ++++++++++++++++++++++++++++++++++++++---------
 net/sched/sch_generic.c   | 21 ++++++++--------
 net/sched/sch_htb.c       | 24 +++++++++++++++---
 net/sched/sch_netem.c     | 14 +++++++++--
 4 files changed, 94 insertions(+), 28 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0741ed4..e6aa0a2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -36,6 +36,14 @@ struct qdisc_size_table {
 	u16			data[];
 };
 
+/* similar to sk_buff_head, but skb->prev pointer is undefined. */
+struct qdisc_skb_head {
+	struct sk_buff	*head;
+	struct sk_buff	*tail;
+	__u32		qlen;
+	spinlock_t	lock;
+};
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb,
 					   struct Qdisc *sch,
@@ -76,7 +84,7 @@ struct Qdisc {
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
 	struct sk_buff		*gso_skb ____cacheline_aligned_in_smp;
-	struct sk_buff_head	q;
+	struct qdisc_skb_head	q;
 	struct gnet_stats_basic_packed bstats;
 	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
@@ -600,10 +608,27 @@ static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
 	sch->qstats.overlimits++;
 }
 
+static inline void qdisc_skb_head_init(struct qdisc_skb_head *qh)
+{
+	qh->head = NULL;
+	qh->tail = NULL;
+	qh->qlen = 0;
+}
+
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
-				       struct sk_buff_head *list)
+				       struct qdisc_skb_head *qh)
 {
-	__skb_queue_tail(list, skb);
+	struct sk_buff *last = qh->tail;
+
+	if (last) {
+		skb->next = NULL;
+		last->next = skb;
+		qh->tail = skb;
+	} else {
+		qh->tail = skb;
+		qh->head = skb;
+	}
+	qh->qlen++;
 	qdisc_qstats_backlog_inc(sch, skb);
 
 	return NET_XMIT_SUCCESS;
@@ -614,9 +639,17 @@ static inline int qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
 	return __qdisc_enqueue_tail(skb, sch, &sch->q);
 }
 
-static inline struct sk_buff *__qdisc_dequeue_head(struct sk_buff_head *list)
+static inline struct sk_buff *__qdisc_dequeue_head(struct qdisc_skb_head *qh)
 {
-	struct sk_buff *skb = __skb_dequeue(list);
+	struct sk_buff *skb = qh->head;
+
+	if (likely(skb != NULL)) {
+		qh->head = skb->next;
+		qh->qlen--;
+		if (qh->head == NULL)
+			qh->tail = NULL;
+		skb->next = NULL;
+	}
 
 	return skb;
 }
@@ -643,10 +676,10 @@ static inline void __qdisc_drop(struct sk_buff *skb, struct sk_buff **to_free)
 }
 
 static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
-						   struct sk_buff_head *list,
+						   struct qdisc_skb_head *qh,
 						   struct sk_buff **to_free)
 {
-	struct sk_buff *skb = __skb_dequeue(list);
+	struct sk_buff *skb = __qdisc_dequeue_head(qh);
 
 	if (likely(skb != NULL)) {
 		unsigned int len = qdisc_pkt_len(skb);
@@ -667,7 +700,9 @@ static inline unsigned int qdisc_queue_drop_head(struct Qdisc *sch,
 
 static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 {
-	return skb_peek(&sch->q);
+	const struct qdisc_skb_head *qh = &sch->q;
+
+	return qh->head;
 }
 
 /* generic pseudo peek method for non-work-conserving qdisc */
@@ -702,15 +737,19 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 	return skb;
 }
 
-static inline void __qdisc_reset_queue(struct sk_buff_head *list)
+static inline void __qdisc_reset_queue(struct qdisc_skb_head *qh)
 {
 	/*
 	 * We do not know the backlog in bytes of this list, it
 	 * is up to the caller to correct it
 	 */
-	if (!skb_queue_empty(list)) {
-		rtnl_kfree_skbs(list->next, list->prev);
-		__skb_queue_head_init(list);
+	ASSERT_RTNL();
+	if (qh->qlen) {
+		rtnl_kfree_skbs(qh->head, qh->tail);
+
+		qh->head = NULL;
+		qh->tail = NULL;
+		qh->qlen = 0;
 	}
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 73877d9..6cfb6e9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -466,7 +466,7 @@ static const u8 prio2band[TC_PRIO_MAX + 1] = {
  */
 struct pfifo_fast_priv {
 	u32 bitmap;
-	struct sk_buff_head q[PFIFO_FAST_BANDS];
+	struct qdisc_skb_head q[PFIFO_FAST_BANDS];
 };
 
 /*
@@ -477,7 +477,7 @@ struct pfifo_fast_priv {
  */
 static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
 
-static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
+static inline struct qdisc_skb_head *band2list(struct pfifo_fast_priv *priv,
 					     int band)
 {
 	return priv->q + band;
@@ -489,7 +489,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
 	if (qdisc->q.qlen < qdisc_dev(qdisc)->tx_queue_len) {
 		int band = prio2band[skb->priority & TC_PRIO_MAX];
 		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-		struct sk_buff_head *list = band2list(priv, band);
+		struct qdisc_skb_head *list = band2list(priv, band);
 
 		priv->bitmap |= (1 << band);
 		qdisc->q.qlen++;
@@ -505,8 +505,8 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 	int band = bitmap2band[priv->bitmap];
 
 	if (likely(band >= 0)) {
-		struct sk_buff_head *list = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(list);
+		struct qdisc_skb_head *qh = band2list(priv, band);
+		struct sk_buff *skb = __qdisc_dequeue_head(qh);
 
 		if (likely(skb != NULL)) {
 			qdisc_qstats_backlog_dec(qdisc, skb);
@@ -514,7 +514,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 		}
 
 		qdisc->q.qlen--;
-		if (skb_queue_empty(list))
+		if (qh->qlen == 0)
 			priv->bitmap &= ~(1 << band);
 
 		return skb;
@@ -529,9 +529,9 @@ static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
 	int band = bitmap2band[priv->bitmap];
 
 	if (band >= 0) {
-		struct sk_buff_head *list = band2list(priv, band);
+		struct qdisc_skb_head *qh = band2list(priv, band);
 
-		return skb_peek(list);
+		return qh->head;
 	}
 
 	return NULL;
@@ -569,7 +569,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__skb_queue_head_init(band2list(priv, prio));
+		qdisc_skb_head_init(band2list(priv, prio));
 
 	/* Can by-pass the queue discipline */
 	qdisc->flags |= TCQ_F_CAN_BYPASS;
@@ -617,7 +617,8 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 		sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
 		sch->padded = (char *) sch - (char *) p;
 	}
-	skb_queue_head_init(&sch->q);
+	qdisc_skb_head_init(&sch->q);
+	spin_lock_init(&sch->q.lock);
 
 	spin_lock_init(&sch->busylock);
 	lockdep_set_class(&sch->busylock,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 53dbfa1..c798d0d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -162,7 +162,7 @@ struct htb_sched {
 	struct work_struct	work;
 
 	/* non shaped skbs; let them go directly thru */
-	struct sk_buff_head	direct_queue;
+	struct qdisc_skb_head	direct_queue;
 	long			direct_pkts;
 
 	struct qdisc_watchdog	watchdog;
@@ -570,6 +570,22 @@ static inline void htb_deactivate(struct htb_sched *q, struct htb_class *cl)
 	list_del_init(&cl->un.leaf.drop_list);
 }
 
+static void htb_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
+			     struct qdisc_skb_head *qh)
+{
+	struct sk_buff *last = qh->tail;
+
+	if (last) {
+		skb->next = NULL;
+		last->next = skb;
+		qh->tail = skb;
+	} else {
+		qh->tail = skb;
+		qh->head = skb;
+	}
+	qh->qlen++;
+}
+
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		       struct sk_buff **to_free)
 {
@@ -580,7 +596,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	if (cl == HTB_DIRECT) {
 		/* enqueue to helper queue */
 		if (q->direct_queue.qlen < q->direct_qlen) {
-			__skb_queue_tail(&q->direct_queue, skb);
+			htb_enqueue_tail(skb, sch, &q->direct_queue);
 			q->direct_pkts++;
 		} else {
 			return qdisc_drop(skb, sch, to_free);
@@ -888,7 +904,7 @@ static struct sk_buff *htb_dequeue(struct Qdisc *sch)
 	unsigned long start_at;
 
 	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
-	skb = __skb_dequeue(&q->direct_queue);
+	skb = __qdisc_dequeue_head(&q->direct_queue);
 	if (skb != NULL) {
 ok:
 		qdisc_bstats_update(sch, skb);
@@ -1019,7 +1035,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 	INIT_WORK(&q->work, htb_work_func);
-	__skb_queue_head_init(&q->direct_queue);
+	qdisc_skb_head_init(&q->direct_queue);
 
 	if (tb[TCA_HTB_DIRECT_QLEN])
 		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 0a964b3..9f7b380 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -413,6 +413,16 @@ static struct sk_buff *netem_segment(struct sk_buff *skb, struct Qdisc *sch,
 	return segs;
 }
 
+static void netem_enqueue_skb_head(struct qdisc_skb_head *qh, struct sk_buff *skb)
+{
+	skb->next = qh->head;
+
+	if (!qh->head)
+		qh->tail = skb;
+	qh->head = skb;
+	qh->qlen++;
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -523,7 +533,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 			struct sk_buff *last;
 
 			if (sch->q.qlen)
-				last = skb_peek_tail(&sch->q);
+				last = sch->q.tail;
 			else
 				last = netem_rb_to_skb(rb_last(&q->t_root));
 			if (last) {
@@ -552,7 +562,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
 
-		__skb_queue_head(&sch->q, skb);
+		netem_enqueue_skb_head(&sch->q, skb);
 		sch->qstats.requeues++;
 	}
 
-- 
2.7.3
