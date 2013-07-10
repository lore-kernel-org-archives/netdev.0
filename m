From: Paolo Valente <paolo.valente@unimore.it>
Subject: [PATCH 2/2] pkt_sched: sch_qfq: remove forward declaration of qfq_update_agg_ts
Date: Wed, 10 Jul 2013 15:46:09 +0200
Message-ID: <1373463969-11285-3-git-send-email-paolo.valente@unimore.it>
References: <20130305.235006.1904081547083683406.davem@davemloft.net>
 <1373463969-11285-1-git-send-email-paolo.valente@unimore.it>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it,
	David Laight <David.Laight@ACULAB.COM>,
	Paolo Valente <paolo.valente@unimore.it>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp26.sms.unimo.it ([155.185.44.26]:36159 "EHLO
	smtp26.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671Ab3GJOVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 10:21:36 -0400
In-Reply-To: <1373463969-11285-1-git-send-email-paolo.valente@unimore.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the forward declaration of qfq_update_agg_ts, by moving
the definition of the function above its first call. This patch also
removes a useless forward declaration of qfq_schedule_agg.

Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
---
 net/sched/sch_qfq.c | 118 ++++++++++++++++++++++++----------------------------
 1 file changed, 55 insertions(+), 63 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 2a0ed50..0025ebe 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1010,9 +1010,61 @@ static inline void charge_actual_service(struct qfq_aggregate *agg)
 	agg->F = agg->S + (u64)service_received * agg->inv_w;
 }
 
-static inline void qfq_update_agg_ts(struct qfq_sched *q,
-				     struct qfq_aggregate *agg,
-				     enum update_reason reason);
+/* Assign a reasonable start time for a new aggregate in group i.
+ * Admissible values for \hat(F) are multiples of \sigma_i
+ * no greater than V+\sigma_i . Larger values mean that
+ * we had a wraparound so we consider the timestamp to be stale.
+ *
+ * If F is not stale and F >= V then we set S = F.
+ * Otherwise we should assign S = V, but this may violate
+ * the ordering in EB (see [2]). So, if we have groups in ER,
+ * set S to the F_j of the first group j which would be blocking us.
+ * We are guaranteed not to move S backward because
+ * otherwise our group i would still be blocked.
+ */
+static void qfq_update_start(struct qfq_sched *q, struct qfq_aggregate *agg)
+{
+	unsigned long mask;
+	u64 limit, roundedF;
+	int slot_shift = agg->grp->slot_shift;
+
+	roundedF = qfq_round_down(agg->F, slot_shift);
+	limit = qfq_round_down(q->V, slot_shift) + (1ULL << slot_shift);
+
+	if (!qfq_gt(agg->F, q->V) || qfq_gt(roundedF, limit)) {
+		/* timestamp was stale */
+		mask = mask_from(q->bitmaps[ER], agg->grp->index);
+		if (mask) {
+			struct qfq_group *next = qfq_ffs(q, mask);
+			if (qfq_gt(roundedF, next->F)) {
+				if (qfq_gt(limit, next->F))
+					agg->S = next->F;
+				else /* preserve timestamp correctness */
+					agg->S = limit;
+				return;
+			}
+		}
+		agg->S = q->V;
+	} else  /* timestamp is not stale */
+		agg->S = agg->F;
+}
+
+/* Update the timestamps of agg before scheduling/rescheduling it for
+ * service.  In particular, assign to agg->F its maximum possible
+ * value, i.e., the virtual finish time with which the aggregate
+ * should be labeled if it used all its budget once in service.
+ */
+static inline void
+qfq_update_agg_ts(struct qfq_sched *q,
+		    struct qfq_aggregate *agg, enum update_reason reason)
+{
+	if (reason != requeue)
+		qfq_update_start(q, agg);
+	else /* just charge agg for the service received */
+		agg->S = agg->F;
+
+	agg->F = agg->S + (u64)agg->budgetmax * agg->inv_w;
+}
 
 static void qfq_schedule_agg(struct qfq_sched *q, struct qfq_aggregate *agg);
 
@@ -1135,66 +1187,6 @@ static struct qfq_aggregate *qfq_choose_next_agg(struct qfq_sched *q)
 	return agg;
 }
 
-/*
- * Assign a reasonable start time for a new aggregate in group i.
- * Admissible values for \hat(F) are multiples of \sigma_i
- * no greater than V+\sigma_i . Larger values mean that
- * we had a wraparound so we consider the timestamp to be stale.
- *
- * If F is not stale and F >= V then we set S = F.
- * Otherwise we should assign S = V, but this may violate
- * the ordering in EB (see [2]). So, if we have groups in ER,
- * set S to the F_j of the first group j which would be blocking us.
- * We are guaranteed not to move S backward because
- * otherwise our group i would still be blocked.
- */
-static void qfq_update_start(struct qfq_sched *q, struct qfq_aggregate *agg)
-{
-	unsigned long mask;
-	u64 limit, roundedF;
-	int slot_shift = agg->grp->slot_shift;
-
-	roundedF = qfq_round_down(agg->F, slot_shift);
-	limit = qfq_round_down(q->V, slot_shift) + (1ULL << slot_shift);
-
-	if (!qfq_gt(agg->F, q->V) || qfq_gt(roundedF, limit)) {
-		/* timestamp was stale */
-		mask = mask_from(q->bitmaps[ER], agg->grp->index);
-		if (mask) {
-			struct qfq_group *next = qfq_ffs(q, mask);
-			if (qfq_gt(roundedF, next->F)) {
-				if (qfq_gt(limit, next->F))
-					agg->S = next->F;
-				else /* preserve timestamp correctness */
-					agg->S = limit;
-				return;
-			}
-		}
-		agg->S = q->V;
-	} else  /* timestamp is not stale */
-		agg->S = agg->F;
-}
-
-/*
- * Update the timestamps of agg before scheduling/rescheduling it for
- * service.  In particular, assign to agg->F its maximum possible
- * value, i.e., the virtual finish time with which the aggregate
- * should be labeled if it used all its budget once in service.
- */
-static inline void
-qfq_update_agg_ts(struct qfq_sched *q,
-		    struct qfq_aggregate *agg, enum update_reason reason)
-{
-	if (reason != requeue)
-		qfq_update_start(q, agg);
-	else /* just charge agg for the service received */
-		agg->S = agg->F;
-
-	agg->F = agg->S + (u64)agg->budgetmax * agg->inv_w;
-}
-
-static void qfq_schedule_agg(struct qfq_sched *, struct qfq_aggregate *);
-
 static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct qfq_sched *q = qdisc_priv(sch);
-- 
1.8.1.2
