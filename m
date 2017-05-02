From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 06/17] net: sched: explicit locking in gso_cpu
 fallback
Date: Tue, 02 May 2017 08:38:00 -0700
Message-ID: <20170502153800.9304.30242.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32865 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdEBPiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:38:14 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so11384156pgc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:38:14 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work is preparing the qdisc layer to support egress lockless
qdiscs. If we are running the egress qdisc lockless in the case we
overrun the netdev, for whatever reason, the netdev returns a busy
error code and the skb is parked on the gso_skb pointer. With many
cores all hitting this case at once its possible to have multiple
sk_buffs here so we turn gso_skb into a queue.

This should be the edge case and if we see this frequently then
the netdev/qdisc layer needs to back off.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   20 +++++++----
 net/sched/sch_generic.c   |   81 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 80 insertions(+), 21 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 83952af..3021bbb 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -85,7 +85,7 @@ struct Qdisc {
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
-	struct sk_buff		*gso_skb ____cacheline_aligned_in_smp;
+	struct sk_buff_head	gso_skb ____cacheline_aligned_in_smp;
 	struct qdisc_skb_head	q;
 	struct gnet_stats_basic_packed bstats;
 	seqcount_t		running;
@@ -754,26 +754,30 @@ static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 /* generic pseudo peek method for non-work-conserving qdisc */
 static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
 {
+	struct sk_buff *skb = skb_peek(&sch->gso_skb);
+
 	/* we can reuse ->gso_skb because peek isn't called for root qdiscs */
-	if (!sch->gso_skb) {
-		sch->gso_skb = sch->dequeue(sch);
-		if (sch->gso_skb) {
+	if (!skb) {
+		skb = sch->dequeue(sch);
+
+		if (skb) {
+			__skb_queue_head(&sch->gso_skb, skb);
 			/* it's still part of the queue */
-			qdisc_qstats_backlog_inc(sch, sch->gso_skb);
+			qdisc_qstats_backlog_inc(sch, skb);
 			sch->q.qlen++;
 		}
 	}
 
-	return sch->gso_skb;
+	return skb;
 }
 
 /* use instead of qdisc->dequeue() for all qdiscs queried with ->peek() */
 static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 {
-	struct sk_buff *skb = sch->gso_skb;
+	struct sk_buff *skb = skb_peek(&sch->gso_skb);
 
 	if (skb) {
-		sch->gso_skb = NULL;
+		skb = __skb_dequeue(&sch->gso_skb);
 		qdisc_qstats_backlog_dec(sch, skb);
 		sch->q.qlen--;
 	} else {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 8a03738..f179fc9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,10 +44,9 @@
  * - ingress filtering is also serialized via qdisc root lock
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
-
-static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+static inline int __dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	q->gso_skb = skb;
+	__skb_queue_head(&q->gso_skb, skb);
 	q->qstats.requeues++;
 	qdisc_qstats_backlog_inc(q, skb);
 	q->q.qlen++;	/* it's still part of the queue */
@@ -56,6 +55,30 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
+static inline int dev_requeue_skb_locked(struct sk_buff *skb, struct Qdisc *q)
+{
+	spinlock_t *lock = qdisc_lock(q);
+
+	spin_lock(lock);
+	__skb_queue_tail(&q->gso_skb, skb);
+	spin_unlock(lock);
+
+	qdisc_qstats_cpu_requeues_inc(q);
+	qdisc_qstats_cpu_backlog_inc(q, skb);
+	qdisc_qstats_cpu_qlen_inc(q);
+	__netif_schedule(q);
+
+	return 0;
+}
+
+static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+{
+	if (q->flags & TCQ_F_NOLOCK)
+		return dev_requeue_skb_locked(skb, q);
+	else
+		return __dev_requeue_skb(skb, q);
+}
+
 static void try_bulk_dequeue_skb(struct Qdisc *q,
 				 struct sk_buff *skb,
 				 const struct netdev_queue *txq,
@@ -111,23 +134,50 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
 static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 				   int *packets)
 {
-	struct sk_buff *skb = q->gso_skb;
 	const struct netdev_queue *txq = q->dev_queue;
+	struct sk_buff *skb;
 
 	*packets = 1;
-	if (unlikely(skb)) {
+	if (unlikely(!skb_queue_empty(&q->gso_skb))) {
+		spinlock_t *lock = NULL;
+
+		if (q->flags & TCQ_F_NOLOCK) {
+			lock = qdisc_lock(q);
+			spin_lock(lock);
+		}
+
+		skb = skb_peek(&q->gso_skb);
+
+		/* skb may be null if another cpu pulls gso_skb off in between
+		 * empty check and lock.
+		 */
+		if (!skb) {
+			if (lock)
+				spin_unlock(lock);
+			goto validate;
+		}
+
 		/* skb in gso_skb were already validated */
 		*validate = false;
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
-			q->gso_skb = NULL;
-			qdisc_qstats_backlog_dec(q, skb);
-			q->q.qlen--;
+			skb = __skb_dequeue(&q->gso_skb);
+			if (qdisc_is_percpu_stats(q)) {
+				qdisc_qstats_cpu_backlog_dec(q, skb);
+				qdisc_qstats_cpu_qlen_dec(q);
+			} else {
+				qdisc_qstats_backlog_dec(q, skb);
+				q->q.qlen--;
+			}
 		} else
 			skb = NULL;
+
+		if (lock)
+			spin_unlock(lock);
 		return skb;
 	}
+validate:
 	*validate = true;
 	skb = q->skb_bad_txq;
 	if (unlikely(skb)) {
@@ -622,6 +672,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 		sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
 		sch->padded = (char *) sch - (char *) p;
 	}
+	__skb_queue_head_init(&sch->gso_skb);
 	qdisc_skb_head_init(&sch->q);
 	spin_lock_init(&sch->q.lock);
 
@@ -690,6 +741,7 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 void qdisc_reset(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops *ops = qdisc->ops;
+	struct sk_buff *skb, *tmp;
 
 	if (ops->reset)
 		ops->reset(qdisc);
@@ -697,10 +749,9 @@ void qdisc_reset(struct Qdisc *qdisc)
 	kfree_skb(qdisc->skb_bad_txq);
 	qdisc->skb_bad_txq = NULL;
 
-	if (qdisc->gso_skb) {
-		kfree_skb_list(qdisc->gso_skb);
-		qdisc->gso_skb = NULL;
-	}
+	skb_queue_walk_safe(&qdisc->gso_skb, skb, tmp)
+		kfree_skb_list(skb);
+
 	qdisc->q.qlen = 0;
 }
 EXPORT_SYMBOL(qdisc_reset);
@@ -720,6 +771,7 @@ static void qdisc_rcu_free(struct rcu_head *head)
 void qdisc_destroy(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops  *ops = qdisc->ops;
+	struct sk_buff *skb, *tmp;
 
 	if (qdisc->flags & TCQ_F_BUILTIN ||
 	    !atomic_dec_and_test(&qdisc->refcnt))
@@ -739,7 +791,9 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb_list(qdisc->gso_skb);
+	skb_queue_walk_safe(&qdisc->gso_skb, skb, tmp)
+		kfree_skb_list(skb);
+
 	kfree_skb(qdisc->skb_bad_txq);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
@@ -971,6 +1025,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 
 	rcu_assign_pointer(dev_queue->qdisc, qdisc);
 	dev_queue->qdisc_sleeping = qdisc;
+	__skb_queue_head_init(&qdisc->gso_skb);
 }
 
 void dev_init_scheduler(struct net_device *dev)
