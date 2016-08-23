From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 09/15] net: sched: support skb_bad_tx with lockless
 qdisc
Date: Tue, 23 Aug 2016 13:26:34 -0700
Message-ID: <20160823202634.14368.16784.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36135 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbcHWU0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:26:53 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so10425751pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:26:52 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to how gso is handled skb_bad_tx needs to be per cpu to handle
lockless qdisc with multiple writer/producers.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    7 +++
 net/sched/sch_api.c       |    6 +++
 net/sched/sch_generic.c   |   95 +++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 99 insertions(+), 9 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 926da18..3597c63 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -40,6 +40,10 @@ struct gso_cell {
 	struct sk_buff *skb;
 };
 
+struct bad_txq_cell {
+	struct sk_buff *skb;
+};
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb,
 					   struct Qdisc *sch,
@@ -77,7 +81,8 @@ struct Qdisc {
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue	__percpu *cpu_qstats;
 
-	struct gso_cell __percpu *gso_cpu_skb;
+	struct gso_cell     __percpu *gso_cpu_skb;
+	struct bad_txq_cell __percpu *skb_bad_txq_cpu;
 
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d713052..b90a23a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -970,6 +970,11 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 			sch->gso_cpu_skb = alloc_percpu(struct gso_cell);
 			if (!sch->gso_cpu_skb)
 				goto err_out4;
+
+			sch->skb_bad_txq_cpu =
+				alloc_percpu(struct bad_txq_cell);
+			if (!sch->skb_bad_txq_cpu)
+				goto err_out4;
 		}
 
 		if (tca[TCA_STAB]) {
@@ -1021,6 +1026,7 @@ err_out4:
 	free_percpu(sch->cpu_bstats);
 	free_percpu(sch->cpu_qstats);
 	free_percpu(sch->gso_cpu_skb);
+	free_percpu(sch->skb_bad_txq_cpu);
 	/*
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index fd4a2b9..0b61b14 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,6 +44,43 @@ EXPORT_SYMBOL(default_qdisc_ops);
  * - ingress filtering is also serialized via qdisc root lock
  * - updates to tree and tree walking are only done under the rtnl mutex.
  */
+static inline struct sk_buff *qdisc_dequeue_skb_bad_txq(struct Qdisc *sch)
+{
+	if (sch->skb_bad_txq_cpu) {
+		struct bad_txq_cell *cell = this_cpu_ptr(sch->skb_bad_txq_cpu);
+
+		return cell->skb;
+	}
+
+	return sch->skb_bad_txq;
+}
+
+static inline void qdisc_enqueue_skb_bad_txq(struct Qdisc *sch,
+					     struct sk_buff *skb)
+{
+	if (sch->skb_bad_txq_cpu) {
+		struct bad_txq_cell *cell = this_cpu_ptr(sch->skb_bad_txq_cpu);
+
+		cell->skb = skb;
+		__netif_schedule(sch);
+		return;
+	}
+
+	sch->skb_bad_txq = skb;
+}
+
+static inline void qdisc_null_skb_bad_txq(struct Qdisc *sch)
+{
+	if (sch->skb_bad_txq_cpu) {
+		struct bad_txq_cell *cell = this_cpu_ptr(sch->skb_bad_txq_cpu);
+
+		cell->skb = NULL;
+		return;
+	}
+
+	sch->skb_bad_txq = NULL;
+}
+
 static inline struct sk_buff *qdisc_dequeue_gso_skb(struct Qdisc *sch)
 {
 	if (sch->gso_cpu_skb)
@@ -129,9 +166,15 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
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
@@ -160,7 +203,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 			qdisc_null_gso_skb(q);
 
 			if (qdisc_is_percpu_stats(q)) {
-				qdisc_qstats_cpu_backlog_inc(q, skb);
+				qdisc_qstats_cpu_backlog_dec(q, skb);
 				qdisc_qstats_cpu_qlen_dec(q);
 			} else {
 				qdisc_qstats_backlog_dec(q, skb);
@@ -171,14 +214,19 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		return skb;
 	}
 	*validate = true;
-	skb = q->skb_bad_txq;
+	skb = qdisc_dequeue_skb_bad_txq(q);
 	if (unlikely(skb)) {
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
-			q->skb_bad_txq = NULL;
-			qdisc_qstats_backlog_dec(q, skb);
-			q->q.qlen--;
+			qdisc_null_skb_bad_txq(q);
+			if (qdisc_is_percpu_stats(q)) {
+				qdisc_qstats_cpu_backlog_dec(q, skb);
+				qdisc_qstats_cpu_qlen_dec(q);
+			} else {
+				qdisc_qstats_backlog_dec(q, skb);
+				q->q.qlen--;
+			}
 			goto bulk;
 		}
 		return NULL;
@@ -717,6 +765,10 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 		sch->gso_cpu_skb = alloc_percpu(struct gso_cell);
 		if (!sch->gso_cpu_skb)
 			goto errout;
+
+		sch->skb_bad_txq_cpu = alloc_percpu(struct bad_txq_cell);
+		if (!sch->skb_bad_txq_cpu)
+			goto errout;
 	}
 
 	return sch;
@@ -752,6 +804,20 @@ void qdisc_reset(struct Qdisc *qdisc)
 		}
 	}
 
+	if (qdisc->skb_bad_txq_cpu) {
+		int i;
+
+		for_each_possible_cpu(i) {
+			struct bad_txq_cell *cell;
+
+			cell = per_cpu_ptr(qdisc->skb_bad_txq_cpu, i);
+			if (cell) {
+				kfree_skb(cell->skb);
+				cell->skb = NULL;
+			}
+		}
+	}
+
 	if (qdisc->gso_skb) {
 		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
@@ -782,6 +848,19 @@ static void qdisc_rcu_free(struct rcu_head *head)
 		free_percpu(qdisc->gso_cpu_skb);
 	}
 
+	if (qdisc->skb_bad_txq_cpu) {
+		int i;
+
+		for_each_possible_cpu(i) {
+			struct bad_txq_cell *cell;
+
+			cell = per_cpu_ptr(qdisc->skb_bad_txq_cpu, i);
+			kfree_skb(cell->skb);
+		}
+
+		free_percpu(qdisc->skb_bad_txq_cpu);
+	}
+
 	kfree((char *) qdisc - qdisc->padded);
 }
 
