From: Paolo Valente <paolo.valente@unimore.it>
Subject: Subject: [PATCH] sched: add missing group change to qfq_change_class
Date: Sun, 05 Aug 2012 21:45:37 +0200
Message-ID: <501ECD61.5090209@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paolo.valente@unimore.it, Fabio Checconi <fchecconi@gmail.com>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com, jhs@mojatatu.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To speed up operations, QFQ internally divides classes into
groups. Which group a class belongs to depends on the ratio between
the maximum packet length and the weight of the class. Unfortunately
the function qfq_change_class lacks the steps for changing the group
of a class when the ratio max_pkt_len/weight of the class changes.

For example, when the last of the following three commands is
executed, the group of class 1:1 is not correctly changed:

tc disc add dev XXX root handle 1: qfq
tc class add dev XXX parent 1: qfq classid 1:1 weight 1
tc class change dev XXX parent 1: classid 1:1 qfq weight 4

Not changing the group of a class does not affect the long-term
bandwidth guaranteed to the class, as the latter is independent of the
maximum packet length, and correctly changes (only) if the weight of
the class changes. In contrast, if the group of the class is not
updated, the class is still guaranteed the short-term bandwidth and
packet delay related to its old group, and not the guarantees that it
should receive according to its new weight and/or maximum packet
length. This may also break service guarantees for other classes.
This patch adds the missing operations.

Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
---
  net/sched/sch_qfq.c |   95 +++++++++++++++++++++++++++++++++++++--------------
  1 file changed, 69 insertions(+), 26 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 9af01f3..e4723d3 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -203,6 +203,34 @@ out:
  	return index;
  }
  
+/* Length of the next packet (0 if the queue is empty). */
+static unsigned int qdisc_peek_len(struct Qdisc *sch)
+{
+	struct sk_buff *skb;
+
+	skb = sch->ops->peek(sch);
+	return skb ? qdisc_pkt_len(skb) : 0;
+}
+
+static void qfq_deactivate_class(struct qfq_sched *, struct qfq_class *);
+static void qfq_activate_class(struct qfq_sched *q, struct qfq_class *cl,
+			       unsigned int len);
+
+static void qfq_update_class_params(struct qfq_sched *q, struct qfq_class *cl,
+				    u32 lmax, u32 inv_w, int delta_w)
+{
+	int i;
+
+	/* update qfq-specific data */
+	cl->lmax = lmax;
+	cl->inv_w = inv_w;
+	i = qfq_calc_index(cl->inv_w, cl->lmax);
+
+	cl->grp = &q->groups[i];
+
+	q->wsum += delta_w;
+}
+
  static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
  			    struct nlattr **tca, unsigned long *arg)
  {
@@ -250,6 +278,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
  		lmax = 1UL << QFQ_MTU_SHIFT;
  
  	if (cl != NULL) {
+		bool need_reactivation = false;
+
  		if (tca[TCA_RATE]) {
  			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
  						    qdisc_root_sleeping_lock(sch),
@@ -258,12 +288,29 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
  				return err;
  		}
  
-		if (inv_w != cl->inv_w) {
-			sch_tree_lock(sch);
-			q->wsum += delta_w;
-			cl->inv_w = inv_w;
-			sch_tree_unlock(sch);
+		if (lmax == cl->lmax && inv_w == cl->inv_w)
+			return 0; /* nothing to update */
+
+		i = qfq_calc_index(inv_w, lmax);
+		sch_tree_lock(sch);
+		if (&q->groups[i] != cl->grp && cl->qdisc->q.qlen > 0) {
+			/*
+			 * shift cl->F back, to not charge the
+			 * class for the not-yet-served head
+			 * packet
+			 */
+			cl->F = cl->S;
+			/* remove class from its slot in the old group */
+			qfq_deactivate_class(q, cl);
+			need_reactivation = true;
  		}
+
+		qfq_update_class_params(q, cl, lmax, inv_w, delta_w);
+
+		if (need_reactivation) /* activate in new group */
+			qfq_activate_class(q, cl, qdisc_peek_len(cl->qdisc));
+		sch_tree_unlock(sch);
+
  		return 0;
  	}
  
@@ -273,11 +320,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
  
  	cl->refcnt = 1;
  	cl->common.classid = classid;
-	cl->lmax = lmax;
-	cl->inv_w = inv_w;
-	i = qfq_calc_index(cl->inv_w, cl->lmax);
  
-	cl->grp = &q->groups[i];
+	qfq_update_class_params(q, cl, lmax, inv_w, delta_w);
  
  	cl->qdisc = qdisc_create_dflt(sch->dev_queue,
  				      &pfifo_qdisc_ops, classid);
@@ -294,7 +338,6 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
  			return err;
  		}
  	}
-	q->wsum += weight;
  
  	sch_tree_lock(sch);
  	qdisc_class_hash_insert(&q->clhash, &cl->common);
@@ -711,15 +754,6 @@ static void qfq_update_eligible(struct qfq_sched *q, u64 old_V)
  	}
  }
  
-/* What is length of next packet in queue (0 if queue is empty) */
-static unsigned int qdisc_peek_len(struct Qdisc *sch)
-{
-	struct sk_buff *skb;
-
-	skb = sch->ops->peek(sch);
-	return skb ? qdisc_pkt_len(skb) : 0;
-}
-
  /*
   * Updates the class, returns true if also the group needs to be updated.
   */
@@ -843,11 +877,8 @@ static void qfq_update_start(struct qfq_sched *q, struct qfq_class *cl)
  static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
  {
  	struct qfq_sched *q = qdisc_priv(sch);
-	struct qfq_group *grp;
  	struct qfq_class *cl;
  	int err;
-	u64 roundedS;
-	int s;
  
  	cl = qfq_classify(skb, sch, &err);
  	if (cl == NULL) {
@@ -876,11 +907,25 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
  		return err;
  
  	/* If reach this point, queue q was idle */
-	grp = cl->grp;
+	qfq_activate_class(q, cl, qdisc_pkt_len(skb));
+
+	return err;
+}
+
+/*
+ * Handle class switch from idle to backlogged.
+ */
+static void qfq_activate_class(struct qfq_sched *q, struct qfq_class *cl,
+			       unsigned int pkt_len)
+{
+	struct qfq_group *grp = cl->grp;
+	u64 roundedS;
+	int s;
+
  	qfq_update_start(q, cl);
  
  	/* compute new finish time and rounded start. */
-	cl->F = cl->S + (u64)qdisc_pkt_len(skb) * cl->inv_w;
+	cl->F = cl->S + (u64)pkt_len * cl->inv_w;
  	roundedS = qfq_round_down(cl->S, grp->slot_shift);
  
  	/*
@@ -917,8 +962,6 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
  
  skip_update:
  	qfq_slot_insert(grp, cl, roundedS);
-
-	return err;
  }
  
  
-- 
1.7.9.5
