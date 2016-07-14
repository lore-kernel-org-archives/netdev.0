From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 05/10] net: sched: per cpu gso handlers
Date: Wed, 13 Jul 2016 23:21:47 -0700
Message-ID: <20160714062146.8270.66708.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35289 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbcGNGWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:22:10 -0400
Received: by mail-pa0-f66.google.com with SMTP id dx3so4150397pab.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:22:10 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net sched infrastructure has a gso ptr that points to skb structs
that have failed to be enqueued by the device driver.

This can happen when multiple cores try to push a skb onto the same
underlying hardware queue resulting in lock contention. This case is
handled by a cpu collision handler handle_dev_cpu_collision(). Another
case occurs when the stack overruns the drivers low level tx queues
capacity. Ideally these should be a rare occurrence in a well-tuned
system but they do happen.

To handle this in the lockless case use a per cpu gso field to park
the skb until the conflict can be resolved. Note at this point the
skb has already been popped off the qdisc so it has to be handled
by the infrastructure.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |   37 +++++++++++++++++++++++
 net/sched/sch_api.c       |    7 ++++
 net/sched/sch_generic.c   |   71 ++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 110 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f69da4b..7b140e2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -36,6 +36,10 @@ struct qdisc_size_table {
 	u16			data[];
 };
 
+struct gso_cell {
+	struct sk_buff *skb;
+};
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb,
 					   struct Qdisc *sch,
@@ -73,6 +77,8 @@ struct Qdisc {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue	__percpu *cpu_qstats;
 
+	struct gso_cell __percpu *gso_cpu_skb;
+
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
@@ -725,6 +731,22 @@ static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
 	return sch->gso_skb;
 }
 
+static inline struct sk_buff *qdisc_peek_dequeued_cpu(struct Qdisc *sch)
+{
+	struct gso_cell *gso = this_cpu_ptr(sch->gso_cpu_skb);
+
+	if (!gso->skb) {
+		struct sk_buff *skb = sch->dequeue(sch);
+
+		if (skb) {
+			gso->skb = skb;
+			qdisc_qstats_cpu_qlen_inc(sch);
+		}
+	}
+
+	return gso->skb;
+}
+
 /* use instead of qdisc->dequeue() for all qdiscs queried with ->peek() */
 static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 {
@@ -741,6 +763,21 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 	return skb;
 }
 
+static inline struct sk_buff *qdisc_dequeue_peeked_skb(struct Qdisc *sch)
+{
+	struct gso_cell *gso = this_cpu_ptr(sch->gso_cpu_skb);
+	struct sk_buff *skb = gso->skb;
+
+	if (skb) {
+		gso->skb = NULL;
+		qdisc_qstats_cpu_qlen_dec(sch);
+	} else {
+		skb = sch->dequeue(sch);
+	}
+
+	return skb;
+}
+
 static inline void __qdisc_reset_queue(struct sk_buff_head *list)
 {
 	/*
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 12ebde8..d713052 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -966,6 +966,12 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out4;
 		}
 
+		if (sch->flags & TCQ_F_NOLOCK) {
+			sch->gso_cpu_skb = alloc_percpu(struct gso_cell);
+			if (!sch->gso_cpu_skb)
+				goto err_out4;
+		}
+
 		if (tca[TCA_STAB]) {
 			stab = qdisc_get_stab(tca[TCA_STAB]);
 			if (IS_ERR(stab)) {
@@ -1014,6 +1020,7 @@ err_out:
 err_out4:
 	free_percpu(sch->cpu_bstats);
 	free_percpu(sch->cpu_qstats);
+	free_percpu(sch->gso_cpu_skb);
 	/*
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fc70204..f903093 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,8 +44,25 @@ EXPORT_SYMBOL(default_qdisc_ops);
  * - ingress filtering is also serialized via qdisc root lock
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
+static inline struct sk_buff *qdisc_dequeue_gso_skb(struct Qdisc *sch)
+{
+	if (sch->gso_cpu_skb)
+		return (this_cpu_ptr(sch->gso_cpu_skb))->skb;
 
-static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+	return sch->gso_skb;
+}
+
+static inline void qdisc_null_gso_skb(struct Qdisc *sch)
+{
+	if (sch->gso_cpu_skb) {
+		(this_cpu_ptr(sch->gso_cpu_skb))->skb = NULL;
+		return;
+	}
+
+	sch->gso_skb = NULL;
+}
+
+static inline int __dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	q->gso_skb = skb;
 	q->qstats.requeues++;
@@ -56,6 +73,25 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
+static inline int dev_requeue_cpu_skb(struct sk_buff *skb, struct Qdisc *q)
+{
+	this_cpu_ptr(q->gso_cpu_skb)->skb = skb;
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
+		return dev_requeue_cpu_skb(skb, q);
+	else
+		return __dev_requeue_skb(skb, q);
+}
+
 static void try_bulk_dequeue_skb(struct Qdisc *q,
 				 struct sk_buff *skb,
 				 const struct netdev_queue *txq,
@@ -111,7 +147,7 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
 static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 				   int *packets)
 {
-	struct sk_buff *skb = q->gso_skb;
+	struct sk_buff *skb = qdisc_dequeue_gso_skb(q);
 	const struct netdev_queue *txq = q->dev_queue;
 
 	*packets = 1;
@@ -121,9 +157,15 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
-			q->gso_skb = NULL;
-			qdisc_qstats_backlog_dec(q, skb);
-			q->q.qlen--;
+			qdisc_null_gso_skb(q);
+
+			if (qdisc_is_percpu_stats(q)) {
+				qdisc_qstats_cpu_backlog_inc(q, skb);
+				qdisc_qstats_cpu_qlen_dec(q);
+			} else {
+				qdisc_qstats_backlog_dec(q, skb);
+				q->q.qlen--;
+			}
 		} else
 			skb = NULL;
 		return skb;
@@ -672,6 +714,12 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 			goto errout;
 	}
 
+	if (sch->flags & TCQ_F_NOLOCK) {
+		sch->gso_cpu_skb = alloc_percpu(struct gso_cell);
+		if (!sch->gso_cpu_skb)
+			goto errout;
+	}
+
 	return sch;
 errout:
 	qdisc_destroy(sch);
@@ -708,6 +756,19 @@ static void qdisc_rcu_free(struct rcu_head *head)
 		free_percpu(qdisc->cpu_qstats);
 	}
 
+	if (qdisc->gso_cpu_skb) {
+		int i;
+
+		for_each_possible_cpu(i) {
+			struct gso_cell *cell;
+
+			cell = per_cpu_ptr(qdisc->gso_cpu_skb, i);
+			kfree_skb_list(cell->skb);
+		}
+
+		free_percpu(qdisc->gso_cpu_skb);
+	}
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
