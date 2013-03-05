From: Paolo valente <paolo.valente@unimore.it>
Subject: [PATCH BUGFIX 3/6] pkt_sched: serve activated aggregates immediately if the scheduler is empty
Date: Tue,  5 Mar 2013 19:04:59 +0100
Message-ID: <1362506702-4985-4-git-send-email-paolo.valente@unimore.it>
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

If no aggregate is in service, then the function qfq_dequeue() does
not dequeue any packet. For this reason, to guarantee QFQ+ to be work
conserving, a just-activated aggregate must be set as in service
immediately if it happens to be the only active aggregate.
This is done by the function qfq_enqueue().

Unfortunately, the function qfq_add_to_agg(), used to add a class to
an aggregate, does not perform this important additional operation.
In particular, if: 1) qfq_add_to_agg() is invoked to complete the move
of a class from a source aggregate, becoming, for this move, inactive,
to a destination aggregate, becoming instead active, and 2) the
destination aggregate becomes the only active aggregate, then this
aggregate is not however set as in service. QFQ+ remains then in a
non-work-conserving state until a new invocation of qfq_enqueue()
recovers the situation.

This fix solves the problem by moving the logic for setting an
aggregate as in service directly into the function qfq_activate_agg().
Hence, from whatever point qfq_activate_aggregate() is invoked, QFQ+
remains work conserving.  Since the more-complex logic of this new
version of activate_aggregate() is not necessary, in qfq_dequeue(), to
reschedule an aggregate that finishes its budget, then the aggregate
is now rescheduled by invoking directly the functions needed.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
Reviewed-by: Fabio Checconi <fchecconi@gmail.com>
---
 net/sched/sch_qfq.c |   36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 4cbbf79..0dbec31 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1005,6 +1005,12 @@ static inline void charge_actual_service(struct qfq_aggregate *agg)
 	agg->F = agg->S + (u64)service_received * agg->inv_w;
 }
 
+static inline void qfq_update_agg_ts(struct qfq_sched *q,
+				     struct qfq_aggregate *agg,
+				     enum update_reason reason);
+
+static void qfq_schedule_agg(struct qfq_sched *q, struct qfq_aggregate *agg);
+
 static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
@@ -1032,7 +1038,7 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
 		in_serv_agg->initial_budget = in_serv_agg->budget =
 			in_serv_agg->budgetmax;
 
-		if (!list_empty(&in_serv_agg->active))
+		if (!list_empty(&in_serv_agg->active)) {
 			/*
 			 * Still active: reschedule for
 			 * service. Possible optimization: if no other
@@ -1043,8 +1049,9 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
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
@@ -1228,17 +1235,11 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	cl->deficit = agg->lmax;
 	list_add_tail(&cl->alist, &agg->active);
 
-	if (list_first_entry(&agg->active, struct qfq_class, alist) != cl)
-		return err; /* aggregate was not empty, nothing else to do */
-
-	/* recharge budget */
-	agg->initial_budget = agg->budget = agg->budgetmax;
+	if (list_first_entry(&agg->active, struct qfq_class, alist) != cl ||
+	    q->in_serv_agg == agg)
+		return err; /* non-empty or in service, nothing else to do */
 
-	qfq_update_agg_ts(q, agg, enqueue);
-	if (q->in_serv_agg == NULL)
-		q->in_serv_agg = agg;
-	else if (agg != q->in_serv_agg)
-		qfq_schedule_agg(q, agg);
+	qfq_activate_agg(q, agg, enqueue);
 
 	return err;
 }
@@ -1295,8 +1296,15 @@ skip_update:
 static void qfq_activate_agg(struct qfq_sched *q, struct qfq_aggregate *agg,
 			     enum update_reason reason)
 {
+	agg->initial_budget = agg->budget = agg->budgetmax; /* recharge budg. */
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
-- 
1.7.9.5
