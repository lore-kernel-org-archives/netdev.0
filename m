From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 05/12] net: sched: per cpu gso handlers
Date: Wed, 30 Dec 2015 09:52:49 -0800
Message-ID: <20151230175249.26257.99.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36831 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753659AbbL3RxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:53:07 -0500
Received: by mail-pa0-f47.google.com with SMTP id yy13so48720381pab.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:53:07 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
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
 include/net/sch_generic.h |   36 ++++++++++++++++++++++++++++++++++++
 net/sched/sch_generic.c   |   34 ++++++++++++++++++++++++++++++++--
 2 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9966c17..aa39dd4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -44,6 +44,10 @@ struct qdisc_size_table {
 	u16			data[];
 };
 
+struct gso_cell {
+	struct sk_buff *skb;
+};
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
@@ -88,6 +92,7 @@ struct Qdisc {
 
 	struct Qdisc		*next_sched;
 	struct sk_buff		*gso_skb;
+	struct gso_cell __percpu *gso_cpu_skb;
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
@@ -699,6 +704,22 @@ static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
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
@@ -714,6 +735,21 @@ static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
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
 static inline void __qdisc_reset_queue(struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 37dfa4a..9aeb51f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,8 +44,7 @@ EXPORT_SYMBOL(default_qdisc_ops);
  * - ingress filtering is also serialized via qdisc root lock
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
-
-static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+static inline int __dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	q->gso_skb = skb;
 	q->qstats.requeues++;
@@ -55,6 +54,24 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
+static inline int dev_requeue_cpu_skb(struct sk_buff *skb, struct Qdisc *q)
+{
+	this_cpu_ptr(q->gso_cpu_skb)->skb = skb;
+	qdisc_qstats_cpu_requeues_inc(q);
+	qdisc_qstats_cpu_qlen_inc(q);
+	__netif_schedule(q);
+
+	return 0;
+}
+
+static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
+{
+	if (q->flags & TCQ_F_NOLOCK)
+		return __dev_requeue_skb(skb, q);
+	else
+		return dev_requeue_cpu_skb(skb, q);
+}
+
 static void try_bulk_dequeue_skb(struct Qdisc *q,
 				 struct sk_buff *skb,
 				 const struct netdev_queue *txq,
@@ -666,6 +683,19 @@ static void qdisc_rcu_free(struct rcu_head *head)
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
 
