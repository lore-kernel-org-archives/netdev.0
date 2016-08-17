From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 10/13] net: sched: lockless support for netif_schedule
Date: Wed, 17 Aug 2016 12:37:38 -0700
Message-ID: <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33333 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbcHQTiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:38:05 -0400
Received: by mail-oi0-f66.google.com with SMTP id s207so13017155oie.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:38:04 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_schedule uses a bit QDISC_STATE_SCHED to tell the qdisc layer
if a run of the qdisc has been scheduler. This is important when
tearing down qdisc instances. We can rcu_free an instance for example
if its possible that we might have outstanding references to it.

Perhaps more importantly in the per cpu lockless case we need to
schedule a run of the qdisc on all qdiscs that are enqueu'ing packets
and hitting the gso_skb requeue logic or else the skb may get stuck
on the gso_skb queue without anything to finish the xmit.

This patch uses a reference counter instead of a bit to account for
the multiple CPUs.
---
 include/net/sch_generic.h |    1 +
 net/core/dev.c            |   32 +++++++++++++++++++++++---------
 net/sched/sch_api.c       |    5 +++++
 net/sched/sch_generic.c   |   16 +++++++++++++++-
 4 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index cc28af0..2e0e5b0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -94,6 +94,7 @@ struct Qdisc {
 	seqcount_t		running;
 	struct gnet_stats_queue	qstats;
 	unsigned long		state;
+	unsigned long __percpu	*cpu_state;
 	struct Qdisc            *next_sched;
 	struct sk_buff		*skb_bad_txq;
 	struct rcu_head		rcu_head;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5db395d..f491845 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2272,8 +2272,14 @@ static void __netif_reschedule(struct Qdisc *q)
 
 void __netif_schedule(struct Qdisc *q)
 {
-	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
+	if (q->flags & TCQ_F_NOLOCK) {
+		unsigned long *s = this_cpu_ptr(q->cpu_state);
+
+		if (!test_and_set_bit(__QDISC_STATE_SCHED, s))
+			__netif_reschedule(q);
+	} else if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
 		__netif_reschedule(q);
+	}
 }
 EXPORT_SYMBOL(__netif_schedule);
 
@@ -3925,15 +3931,23 @@ static void net_tx_action(struct softirq_action *h)
 			if (!(q->flags & TCQ_F_NOLOCK)) {
 				root_lock = qdisc_lock(q);
 				spin_lock(root_lock);
-			}
-			/* We need to make sure head->next_sched is read
-			 * before clearing __QDISC_STATE_SCHED
-			 */
-			smp_mb__before_atomic();
-			clear_bit(__QDISC_STATE_SCHED, &q->state);
-			qdisc_run(q);
-			if (!(q->flags & TCQ_F_NOLOCK))
+
+				/* We need to make sure head->next_sched is read
+				 * before clearing __QDISC_STATE_SCHED
+				 */
+				smp_mb__before_atomic();
+				clear_bit(__QDISC_STATE_SCHED, &q->state);
+
+				qdisc_run(q);
+
 				spin_unlock(root_lock);
+			} else {
+				unsigned long *s = this_cpu_ptr(q->cpu_state);
+
+				smp_mb__before_atomic();
+				clear_bit(__QDISC_STATE_SCHED, s);
+				__qdisc_run(q);
+			}
 		}
 	}
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 6c5bf13..89989a6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -975,6 +975,10 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				alloc_percpu(struct bad_txq_cell);
 			if (!sch->skb_bad_txq_cpu)
 				goto err_out4;
+
+			sch->cpu_state = alloc_percpu(unsigned long);
+			if (!sch->cpu_state)
+				goto err_out4;
 		}
 
 		if (tca[TCA_STAB]) {
@@ -1027,6 +1031,7 @@ err_out4:
 	free_percpu(sch->cpu_qstats);
 	free_percpu(sch->gso_cpu_skb);
 	free_percpu(sch->skb_bad_txq_cpu);
+	free_percpu(sch->cpu_state);
 	/*
 	 * Any broken qdiscs that would require a ops->reset() here?
 	 * The qdisc was never in action so it shouldn't be necessary.
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d10b762..f5b7254 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -171,6 +171,7 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
 			if (qdisc_is_percpu_stats(q)) {
 				qdisc_qstats_cpu_backlog_inc(q, nskb);
 				qdisc_qstats_cpu_qlen_inc(q);
+				set_thread_flag(TIF_NEED_RESCHED);
 			} else {
 				qdisc_qstats_backlog_inc(q, nskb);
 				q->q.qlen++;
@@ -768,6 +769,10 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 		sch->skb_bad_txq_cpu = alloc_percpu(struct bad_txq_cell);
 		if (!sch->skb_bad_txq_cpu)
 			goto errout;
+
+		sch->cpu_state = alloc_percpu(unsigned long);
+		if (!sch->cpu_state)
+			goto errout;
 	}
 
 	return sch;
@@ -1037,7 +1042,16 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 		q = dev_queue->qdisc_sleeping;
 
 		if (q->flags & TCQ_F_NOLOCK) {
-			val = test_bit(__QDISC_STATE_SCHED, &q->state);
+			int i;
+
+			for_each_possible_cpu(i) {
+				unsigned long *s;
+
+				s = per_cpu_ptr(q->cpu_state, i);
+				val = test_bit(__QDISC_STATE_SCHED, s);
+				if (val)
+					break;
+			}
 		} else {
 			root_lock = qdisc_lock(q);
 			spin_lock_bh(root_lock);
