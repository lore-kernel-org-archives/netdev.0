From: Paolo valente <paolo.valente@unimore.it>
Subject: [PATCH BUGFIX 1/6] pkt_sched: properly cap timestamps in charge_actual_service
Date: Tue,  5 Mar 2013 19:04:57 +0100
Message-ID: <1362506702-4985-2-git-send-email-paolo.valente@unimore.it>
References: <20130226.173700.882998504986475149.davem@davemloft.net>
 <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it,
	Paolo Valente <paolo.valente@unimore.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362506702-4985-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QFQ+ schedules the active aggregates in a group using a bucket list
(one list per group). The bucket in which each aggregate is inserted
depends on the aggregate's timestamps, and the number
of buckets in a group is enough to accomodate the possible (range of)
values of the timestamps of all the aggregates in the group. For this
property to hold, timestamps must however be computed correctly.  One
necessary condition for computing timestamps correctly is that the
number of bits dequeued for each aggregate, while the aggregate is in
service, does not exceed the maximum budget budgetmax assigned to the
aggregate.

For each aggregate, budgetmax is proportional to the number of classes
in the aggregate. If the number of classes of the aggregate is
decreased through qfq_change_class(), then budgetmax is decreased
automatically as well.  Problems may occur if the aggregate is in
service when budgetmax is decreased, because the current remaining
budget of the aggregate and/or the service already received by the
aggregate may happen to be larger than the new value of budgetmax.  In
this case, when the aggregate is eventually deselected and its
timestamps are updated, the aggregate may happen to have received an
amount of service larger than budgetmax.  This may cause the aggregate
to be assigned a higher virtual finish time than the maximum
acceptable value for the last bucket in the bucket list of the group.

This fix introduces a cap that addresses this issue.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
Reviewed-by: Fabio Checconi <fchecconi@gmail.com>
---
 net/sched/sch_qfq.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 6ed3765..0f6e2db 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -299,6 +299,10 @@ static void qfq_update_agg(struct qfq_sched *q, struct qfq_aggregate *agg,
 	    new_num_classes == q->max_agg_classes - 1) /* agg no more full */
 		hlist_add_head(&agg->nonfull_next, &q->nonfull_aggs);
 
+	/* The next assignment may let
+	 * agg->initial_budget > agg->budgetmax
+	 * hold, we will take it into account in charge_actual_service().
+	 */
 	agg->budgetmax = new_num_classes * agg->lmax;
 	new_agg_weight = agg->class_weight * new_num_classes;
 	agg->inv_w = ONE_FP/new_agg_weight;
@@ -990,8 +994,13 @@ static inline struct sk_buff *qfq_peek_skb(struct qfq_aggregate *agg,
 /* Update F according to the actual service received by the aggregate. */
 static inline void charge_actual_service(struct qfq_aggregate *agg)
 {
-	/* compute the service received by the aggregate */
-	u32 service_received = agg->initial_budget - agg->budget;
+	/* Compute the service received by the aggregate, taking into
+	 * account that, after decreasing the number of classes in
+	 * agg, it may happen that
+	 * agg->initial_budget - agg->budget > agg->bugdetmax
+	 */
+	u32 service_received = min(agg->budgetmax,
+				   agg->initial_budget - agg->budget);
 
 	agg->F = agg->S + (u64)service_received * agg->inv_w;
 }
-- 
1.7.9.5
