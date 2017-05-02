From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 08/17] net: sched: support skb_bad_tx with lockless
 qdisc
Date: Tue, 02 May 2017 08:38:37 -0700
Message-ID: <20170502153837.9304.76478.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36365 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdEBPiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:38:55 -0400
Received: by mail-pg0-f66.google.com with SMTP id v1so23019419pgv.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:38:55 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to how gso is handled skb_bad_tx needs to be per cpu to handle
lockless qdisc with multiple writer/producers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    2 -
 net/sched/sch_generic.c   |  100 ++++++++++++++++++++++++++++++++++++---------
 2 files changed, 82 insertions(+), 20 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3021bbb..4288222 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -92,7 +92,7 @@ struct Qdisc {
 	struct gnet_stats_queue	qstats;
 	unsigned long		state;
 	struct Qdisc            *next_sched;
-	struct sk_buff		*skb_bad_txq;
+	struct sk_buff_head	skb_bad_txq;
 	struct rcu_head		rcu_head;
 	int			padded;
 	atomic_t		refcnt;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 37cd54e..d4194c2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,6 +44,68 @@
  * - ingress filtering is also serialized via qdisc root lock
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
+
+static inline struct sk_buff *__skb_dequeue_bad_txq(struct Qdisc *q)
+{
+	const struct netdev_queue *txq = q->dev_queue;
+	spinlock_t *lock = NULL;
+	struct sk_buff *skb;
+
+	if (q->flags & TCQ_F_NOLOCK) {
+		lock = qdisc_lock(q);
+		spin_lock(lock);
+	}
+
+	skb = skb_peek(&q->skb_bad_txq);
+	if (skb) {
+		/* check the reason of requeuing without tx lock first */
+		txq = skb_get_tx_queue(txq->dev, skb);
+		if (!netif_xmit_frozen_or_stopped(txq)) {
+			skb = __skb_dequeue(&q->skb_bad_txq);
+			if (qdisc_is_percpu_stats(q)) {
+				qdisc_qstats_cpu_backlog_dec(q, skb);
+				qdisc_qstats_cpu_qlen_dec(q);
+			} else {
+				qdisc_qstats_backlog_dec(q, skb);
+				q->q.qlen--;
+			}
+		} else {
+			skb = NULL;
+		}
+	}
+
+	if (lock)
+		spin_unlock(lock);
+
+	return skb;
+}
+
+static inline struct sk_buff *qdisc_dequeue_skb_bad_txq(struct Qdisc *q)
+{
+	struct sk_buff *skb = skb_peek(&q->skb_bad_txq);
+
+	if (unlikely(skb))
+		skb = __skb_dequeue_bad_txq(q);
+
+	return skb;
+}
+
+static inline void qdisc_enqueue_skb_bad_txq(struct Qdisc *q,
+					     struct sk_buff *skb)
+{
+	spinlock_t *lock = NULL;
+
+	if (q->flags & TCQ_F_NOLOCK) {
+		lock = qdisc_lock(q);
+		spin_lock(lock);
+	}
+
+	__skb_queue_tail(&q->skb_bad_txq, skb);
+
+	if (lock)
+		spin_unlock(lock);
+}
+
 static inline int __dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	__skb_queue_head(&q->gso_skb, skb);
@@ -116,9 +178,15 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
 		if (!nskb)
 			break;
 		if (unlikely(skb_get_queue_mapping(nskb) != mapping)) {
-			q->skb_bad_txq = nskb;
-			qdisc_qstats_backlog_inc(q, nskb);
-			q->q.qlen++;
+			qdisc_enqueue_skb_bad_txq(q, nskb);
+
+			if (qdisc_is_percpu_stats(q)) {
+				qdisc_qstats_cpu_backlog_inc(q, nskb);
+				qdisc_qstats_cpu_qlen_inc(q);
+			} else {
+				qdisc_qstats_backlog_inc(q, nskb);
+				q->q.qlen++;
+			}
 			break;
 		}
 		skb->next = nskb;
@@ -179,18 +247,9 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 	}
 validate:
 	*validate = true;
-	skb = q->skb_bad_txq;
-	if (unlikely(skb)) {
-		/* check the reason of requeuing without tx lock first */
-		txq = skb_get_tx_queue(txq->dev, skb);
-		if (!netif_xmit_frozen_or_stopped(txq)) {
-			q->skb_bad_txq = NULL;
-			qdisc_qstats_backlog_dec(q, skb);
-			q->q.qlen--;
-			goto bulk;
-		}
-		return NULL;
-	}
+	skb = qdisc_dequeue_skb_bad_txq(q);
+	if (unlikely(skb))
+		goto bulk;
 	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
 	    !netif_xmit_frozen_or_stopped(txq))
 		skb = q->dequeue(q);
@@ -673,6 +732,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 		sch->padded = (char *) sch - (char *) p;
 	}
 	__skb_queue_head_init(&sch->gso_skb);
+	__skb_queue_head_init(&sch->skb_bad_txq);
 	qdisc_skb_head_init(&sch->q);
 	spin_lock_init(&sch->q.lock);
 
@@ -746,12 +806,12 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 
-	kfree_skb(qdisc->skb_bad_txq);
-	qdisc->skb_bad_txq = NULL;
-
 	skb_queue_walk_safe(&qdisc->gso_skb, skb, tmp)
 		kfree_skb_list(skb);
 
+	skb_queue_walk_safe(&qdisc->skb_bad_txq, skb, tmp)
+		kfree_skb_list(skb);
+
 	qdisc->q.qlen = 0;
 }
 EXPORT_SYMBOL(qdisc_reset);
@@ -793,8 +853,9 @@ void qdisc_destroy(struct Qdisc *qdisc)
 
 	skb_queue_walk_safe(&qdisc->gso_skb, skb, tmp)
 		kfree_skb_list(skb);
+	skb_queue_walk_safe(&qdisc->skb_bad_txq, skb, tmp)
+		kfree_skb_list(skb);
 
-	kfree_skb(qdisc->skb_bad_txq);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
@@ -1036,6 +1097,7 @@ static void dev_init_scheduler_queue(struct net_device *dev,
 	rcu_assign_pointer(dev_queue->qdisc, qdisc);
 	dev_queue->qdisc_sleeping = qdisc;
 	__skb_queue_head_init(&qdisc->gso_skb);
+	__skb_queue_head_init(&qdisc->skb_bad_txq);
 }
 
 void dev_init_scheduler(struct net_device *dev)
