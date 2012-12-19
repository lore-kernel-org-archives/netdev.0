From: Paolo valente <paolo.valente@unimore.it>
Subject: [PATCH BUGFIX] pkt_sched: fix little service anomalies and possible crashes of qfq+
Date: Wed, 19 Dec 2012 18:31:06 +0100
Message-ID: <1355938266-18459-1-git-send-email-paolo.valente@unimore.it>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com,
	Paolo Valente <paolo.valente@unimore.it>
To: davem@davemloft.net, jhs@mojatatu.com, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.sms.unimo.it ([155.185.44.25]:37644 "EHLO
	smtp25.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756Ab2LSRbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 12:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains five fixes that remove some little service
anomalies, plus an improvement that slightly reduces the execution
time of qfq+.

As for possible crashes, in a stress test in which a few hundreds of
classes randomly switched from backlogged to non-backlogged, and the
parameters of a few tens of randomly chosen classes were changed
repeatedly and in parallel, the problems solved by these fixes
happened to combine and cause corruption of the data structures
supporting the group bucket lists.

The portions of the code interested by each fix are small and do not
overlap with each other, so I decided to provide just one patch
(I hope that this was the right choice).

1. Fix the update of eligible-group sets

Between two invocations of make_eligible, the system virtual time may
happen to grow enough that, in its binary representation, a bit with
higher order than 31 flips. This happens especially with
TSO/GSO. Before this fix, the mask used in make_eligible was computed
as (1UL<<index_of_last_flipped_bit)-1, whose value is well defined on
a 64-bit architecture, because index_of_flipped_bit <= 63, but is in
general undefined on a 32-bit architecture if index_of_flipped_bit > 31.
The fix just replaces 1UL with 1ULL.

2. Properly cap timestamps in charge_actual_service

After decreasing the number of classes, and hence the maximum budget
budgetmax for an aggregate in service, it may happen that the service
it receives before a new aggregate is chosen for service becomes
larger than budgetmax. This may cause the aggregate to be assigned an
incorrect, too high virtual finish time. The cap introduced by this
fix solves this problem.

3. Do not allow virtual time to jump if an aggregate is in service

By definition of (the algorithm of) qfq+, the system virtual time must
be pushed up only if there is no eligible aggregate. But to decide
whether this condition holds correctly, qfq+ must also check whether
no aggregate is in service (and hence eligible).

4. Prevent the budget of an aggregate from becoming negative in
qfq_dequeue

If lmax is lowered, through qfq_change_class, for a class owning
pending packets with larger size than the new value of lmax, then even
the budget of a just selected-aggregate may happen to be lower than
the length of the next packet to serve. This fix prevents the budget
from becoming negative after the packet is dequeued.

5. Start serving a just-activated aggregate immediately if the
scheduler is empty

This avoids qfq+ to be occasionally non-work-conserving.

6. Remove useless invocation of qfq_update_eligible from qfq_deactivate_agg

There is no need to invoke qfq_update_eligible in qfq_deactivate_agg
to keep qfq+ work-conserving.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
---
 net/sched/sch_qfq.c |   72 +++++++++++++++++++++++++++++++++++----------------
 1 file changed, 49 insertions(+), 23 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 6ed3765..01f36a5 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -299,6 +299,11 @@ static void qfq_update_agg(struct qfq_sched *q, struct qfq_aggregate *agg,
 	    new_num_classes == q->max_agg_classes - 1) /* agg no more full */
 		hlist_add_head(&agg->nonfull_next, &q->nonfull_aggs);
 
+	/*
+	 * The next assignment may let
+	 * agg->initial_budget > agg->budgetmax
+	 * hold, but this does not cause any harm
+	 */
 	agg->budgetmax = new_num_classes * agg->lmax;
 	new_agg_weight = agg->class_weight * new_num_classes;
 	agg->inv_w = ONE_FP/new_agg_weight;
@@ -325,9 +330,10 @@ static void qfq_add_to_agg(struct qfq_sched *q,
 	qfq_update_agg(q, agg, agg->num_classes+1);
 	if (cl->qdisc->q.qlen > 0) { /* adding an active class */
 		list_add_tail(&cl->alist, &agg->active);
-		if (list_first_entry(&agg->active, struct qfq_class, alist) ==
-		    cl && q->in_serv_agg != agg) /* agg was inactive */
-			qfq_activate_agg(q, agg, enqueue); /* schedule agg */
+		if (list_first_entry(&agg->active, struct qfq_class, alist) !=
+		    cl || q->in_serv_agg == agg)
+			return;
+		qfq_activate_agg(q, agg, enqueue);
 	}
 }
 
@@ -819,7 +825,7 @@ static void qfq_make_eligible(struct qfq_sched *q)
 	unsigned long old_vslot = q->oldV >> q->min_slot_shift;
 
 	if (vslot != old_vslot) {
-		unsigned long mask = (1UL << fls(vslot ^ old_vslot)) - 1;
+		unsigned long mask = (1ULL << fls(vslot ^ old_vslot)) - 1;
 		qfq_move_groups(q, mask, IR, ER);
 		qfq_move_groups(q, mask, IB, EB);
 	}
@@ -993,9 +999,19 @@ static inline void charge_actual_service(struct qfq_aggregate *agg)
 	/* compute the service received by the aggregate */
 	u32 service_received = agg->initial_budget - agg->budget;
 
+	/* may happen after decreasing the number of classes in agg */
+	if (service_received > agg->budgetmax)
+		service_received = agg->budgetmax;
+
 	agg->F = agg->S + (u64)service_received * agg->inv_w;
 }
 
+static inline void qfq_update_agg_ts(struct qfq_sched *,
+				     struct qfq_aggregate *,
+				     enum update_reason);
+
+static void qfq_schedule_agg(struct qfq_sched *, struct qfq_aggregate *);
+
 static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
@@ -1023,7 +1039,7 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 		in_serv_agg->initial_budget = in_serv_agg->budget =
 			in_serv_agg->budgetmax;
 
-		if (!list_empty(&in_serv_agg->active))
+		if (!list_empty(&in_serv_agg->active)) {
 			/*
 			 * Still active: reschedule for
 			 * service. Possible optimization: if no other
@@ -1034,8 +1050,9 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 			 * handle it, we would need to maintain an
 			 * extra num_active_aggs field.
 			*/
-			qfq_activate_agg(q, in_serv_agg, requeue);
-		else if (sch->q.qlen == 0) { /* no aggregate to serve */
+			qfq_update_agg_ts(q, in_serv_agg, requeue);
+			qfq_schedule_agg(q, in_serv_agg);
+		} else if (sch->q.qlen == 0) { /* no aggregate to serve */
 			q->in_serv_agg = NULL;
 			return NULL;
 		}
@@ -1054,7 +1071,16 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 	qdisc_bstats_update(sch, skb);
 
 	agg_dequeue(in_serv_agg, cl, len);
-	in_serv_agg->budget -= len;
+	/*
+	 * If lmax is lowered, through qfq_change_class, for a class
+	 * owning pending packets with larger size than the new value of lmax,
+	 * then the following condition may hold.
+	 */
+	if (unlikely(in_serv_agg->budget < len))
+		in_serv_agg->budget = 0;
+	else
+		in_serv_agg->budget -= len;
+
 	q->V += (u64)len * IWSUM;
 	pr_debug("qfq dequeue: len %u F %lld now %lld\n",
 		 len, (unsigned long long) in_serv_agg->F,
@@ -1154,7 +1180,7 @@ static void qfq_update_start(struct qfq_sched *q, struct qfq_aggregate *agg)
  */
 static inline void
 qfq_update_agg_ts(struct qfq_sched *q,
-		    struct qfq_aggregate *agg, enum update_reason reason)
+		  struct qfq_aggregate *agg, enum update_reason reason)
 {
 	if (reason != requeue)
 		qfq_update_start(q, agg);
@@ -1219,17 +1245,11 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl->deficit = agg->lmax;
 	list_add_tail(&cl->alist, &agg->active);
 
-	if (list_first_entry(&agg->active, struct qfq_class, alist) != cl)
-		return err; /* aggregate was not empty, nothing else to do */
+	if (list_first_entry(&agg->active, struct qfq_class, alist) != cl ||
+	    q->in_serv_agg == agg)
+		return err; /* non-empty or in service, nothing else to do */
 
-	/* recharge budget */
-	agg->initial_budget = agg->budget = agg->budgetmax;
-
-	qfq_update_agg_ts(q, agg, enqueue);
-	if (q->in_serv_agg == NULL)
-		q->in_serv_agg = agg;
-	else if (agg != q->in_serv_agg)
-		qfq_schedule_agg(q, agg);
+	qfq_activate_agg(q, agg, enqueue);
 
 	return err;
 }
@@ -1263,7 +1283,8 @@ static void qfq_schedule_agg(struct qfq_sched *q, struct qfq_aggregate *agg)
 		/* group was surely ineligible, remove */
 		__clear_bit(grp->index, &q->bitmaps[IR]);
 		__clear_bit(grp->index, &q->bitmaps[IB]);
-	} else if (!q->bitmaps[ER] && qfq_gt(roundedS, q->V))
+	} else if (!q->bitmaps[ER] && qfq_gt(roundedS, q->V) &&
+		   q->in_serv_agg == NULL)
 		q->V = roundedS;
 
 	grp->S = roundedS;
@@ -1286,8 +1307,15 @@ skip_update:
 static void qfq_activate_agg(struct qfq_sched *q, struct qfq_aggregate *agg,
 			     enum update_reason reason)
 {
+	agg->initial_budget = agg->budget = agg->budgetmax; /* recharge budg */
+
 	qfq_update_agg_ts(q, agg, reason);
-	qfq_schedule_agg(q, agg);
+	if (q->in_serv_agg == NULL) { /* no aggr. in service or scheduled */
+		q->in_serv_agg = agg; /* start serving this aggregate */
+		 /* update V: to be in service, agg must be eligible */
+		q->oldV = q->V = agg->S;
+	} else if (agg != q->in_serv_agg)
+		qfq_schedule_agg(q, agg);
 }
 
 static void qfq_slot_remove(struct qfq_sched *q, struct qfq_group *grp,
@@ -1359,8 +1387,6 @@ static void qfq_deactivate_agg(struct qfq_sched *q, struct qfq_aggregate *agg)
 			__set_bit(grp->index, &q->bitmaps[s]);
 		}
 	}
-
-	qfq_update_eligible(q);
 }
 
 static void qfq_qlen_notify(struct Qdisc *sch, unsigned long arg)
-- 
1.7.9.5
