From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is
 empty
Date: Fri, 26 Oct 2012 18:51:15 +0200
Message-ID: <20121026165115.GA16947@paolo-ThinkPad-W520>
References: <1350982432.26308.8.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Fabio Checconi <fchecconi@gmail.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spostino.sms.unimo.it ([155.185.44.3]:52601 "EHLO
	spostino.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133Ab2JZQvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 12:51:33 -0400
Content-Disposition: inline
In-Reply-To: <1350982432.26308.8.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 23/10/2012 10:53, Cong Wang ha scritto:
> On Tue, 2012-10-23 at 09:09 +0200, Paolo Valente wrote:
>> The crash you reported is one of the problems I tried to solve with my last fixes.
>> After those fixes I could not reproduce this crash (and other crashes) any more, but of course I am still missing something.
> 
> I am using the latest net-next, so if your patches are in net-next,
> then the problem of course still exists.
> 
>>
>> Il giorno 23/ott/2012, alle ore 06:15, Cong Wang ha scritto:
>>
>>> I am not sure if this patch fixes the real problem or just workarounds
>>> it. At least, after this patch I don't see the crash I reported any more.
>>
>> It is actually a workaround: if the condition that triggers your workaround holds true, then the group data structure is already inconstent, and qfq is likely not to schedule classes correctly.
>> I will try to reproduce the crash with the steps you suggest, and try to understand what is still wrong as soon as I can.
>>
> 
> OK, I don't pretend I understand qfq. And I can help you to test
> patches.
Here is a possible patch. Could you please give me a feedback?

If this patch actually works, there are some issues related to it that I would
like to point out after your (and/or anyone else's) tests.
> 
> Thanks!
> 
> 
---
 net/sched/sch_qfq.c |   84 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 55 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index f0dd83c..1fef61a 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -84,18 +84,19 @@
  * grp->index is the index of the group; and grp->slot_shift
  * is the shift for the corresponding (scaled) sigma_i.
  */
-#define QFQ_MAX_INDEX		19
-#define QFQ_MAX_WSHIFT		16
+#define QFQ_MAX_INDEX		24
+#define QFQ_MAX_WSHIFT		12
 
 #define	QFQ_MAX_WEIGHT		(1<<QFQ_MAX_WSHIFT)
-#define QFQ_MAX_WSUM		(2*QFQ_MAX_WEIGHT)
+#define QFQ_MAX_WSUM		(16*QFQ_MAX_WEIGHT)
 
 #define FRAC_BITS		30	/* fixed point arithmetic */
 #define ONE_FP			(1UL << FRAC_BITS)
 #define IWSUM			(ONE_FP/QFQ_MAX_WSUM)
 
-#define QFQ_MTU_SHIFT		11
+#define QFQ_MTU_SHIFT		16	/* because of TSO/GSP */
 #define QFQ_MIN_SLOT_SHIFT	(FRAC_BITS + QFQ_MTU_SHIFT - QFQ_MAX_INDEX)
+#define QFQ_MIN_LMAX		256	/* min possible lmax for a class */
 
 /*
  * Possible group states.  These values are used as indexes for the bitmaps
@@ -231,6 +232,32 @@ static void qfq_update_class_params(struct qfq_sched *q, struct qfq_class *cl,
 	q->wsum += delta_w;
 }
 
+static void qfq_update_reactivate_class(struct qfq_sched *q,
+					struct qfq_class *cl,
+					u32 inv_w, u32 lmax, int delta_w)
+{
+	bool need_reactivation = false;
+	int i = qfq_calc_index(inv_w, lmax);
+
+	if (&q->groups[i] != cl->grp && cl->qdisc->q.qlen > 0) {
+		/*
+		 * shift cl->F back, to not charge the
+		 * class for the not-yet-served head
+		 * packet
+		 */
+		cl->F = cl->S;
+		/* remove class from its slot in the old group */
+		qfq_deactivate_class(q, cl);
+		need_reactivation = true;
+	}
+
+	qfq_update_class_params(q, cl, lmax, inv_w, delta_w);
+
+	if (need_reactivation) /* activate in new group */
+		qfq_activate_class(q, cl, qdisc_peek_len(cl->qdisc));
+}
+
+
 static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			    struct nlattr **tca, unsigned long *arg)
 {
@@ -238,7 +265,7 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	struct qfq_class *cl = (struct qfq_class *)*arg;
 	struct nlattr *tb[TCA_QFQ_MAX + 1];
 	u32 weight, lmax, inv_w;
-	int i, err;
+	int err;
 	int delta_w;
 
 	if (tca[TCA_OPTIONS] == NULL) {
@@ -270,16 +297,14 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tb[TCA_QFQ_LMAX]) {
 		lmax = nla_get_u32(tb[TCA_QFQ_LMAX]);
-		if (!lmax || lmax > (1UL << QFQ_MTU_SHIFT)) {
+		if (lmax < QFQ_MIN_LMAX || lmax > (1UL << QFQ_MTU_SHIFT)) {
 			pr_notice("qfq: invalid max length %u\n", lmax);
 			return -EINVAL;
 		}
 	} else
-		lmax = 1UL << QFQ_MTU_SHIFT;
+		lmax = psched_mtu(qdisc_dev(sch));
 
 	if (cl != NULL) {
-		bool need_reactivation = false;
-
 		if (tca[TCA_RATE]) {
 			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
 						    qdisc_root_sleeping_lock(sch),
@@ -291,24 +316,8 @@ static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 		if (lmax == cl->lmax && inv_w == cl->inv_w)
 			return 0; /* nothing to update */
 
-		i = qfq_calc_index(inv_w, lmax);
 		sch_tree_lock(sch);
-		if (&q->groups[i] != cl->grp && cl->qdisc->q.qlen > 0) {
-			/*
-			 * shift cl->F back, to not charge the
-			 * class for the not-yet-served head
-			 * packet
-			 */
-			cl->F = cl->S;
-			/* remove class from its slot in the old group */
-			qfq_deactivate_class(q, cl);
-			need_reactivation = true;
-		}
-
-		qfq_update_class_params(q, cl, lmax, inv_w, delta_w);
-
-		if (need_reactivation) /* activate in new group */
-			qfq_activate_class(q, cl, qdisc_peek_len(cl->qdisc));
+		qfq_update_reactivate_class(q, cl, inv_w, lmax, delta_w);
 		sch_tree_unlock(sch);
 
 		return 0;
@@ -663,9 +672,17 @@ static void qfq_make_eligible(struct qfq_sched *q, u64 old_V)
 
 
 /*
- * XXX we should make sure that slot becomes less than 32.
- * This is guaranteed by the input values.
- * roundedS is always cl->S rounded on grp->slot_shift bits.
+ * If the weight and lmax (max_pkt_size) of the classes do not change,
+ * then QFQ guarantees that the slot index is never higher than 2 +
+ * ((1<<QFQ_MTU_SHIFT)/QFQ_MIN_LMAX) * (QFQ_MAX_WEIGHT/QFQ_MAX_WSUM).
+ *
+ * With the current values of the above constants, the index is
+ * then guaranteed to never be higher than 2 + 256 * (1 / 16) = 18.
+ *
+ * Even if the weight and/or lmax of some class change, the index
+ * should not, however, happen to be higher than 30, which is the
+ * critical threshold above which the full_slots bitmap my get
+ * corrupted.
  */
 static void qfq_slot_insert(struct qfq_group *grp, struct qfq_class *cl,
 			    u64 roundedS)
@@ -673,6 +690,8 @@ static void qfq_slot_insert(struct qfq_group *grp, struct qfq_class *cl,
 	u64 slot = (roundedS - grp->S) >> grp->slot_shift;
 	unsigned int i = (grp->front + slot) % QFQ_MAX_SLOTS;
 
+	BUG_ON(slot > 30);
+
 	hlist_add_head(&cl->next, &grp->slots[i]);
 	__set_bit(slot, &grp->full_slots);
 }
@@ -892,6 +911,13 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 	pr_debug("qfq_enqueue: cl = %x\n", cl->common.classid);
 
+	if (unlikely(cl->lmax < qdisc_pkt_len(skb))) {
+		pr_notice("qfq: increasing class max_pkt_size from %u to %u\n",
+			  cl->lmax, qdisc_pkt_len(skb));
+		qfq_update_reactivate_class(q, cl, cl->inv_w,
+					    qdisc_pkt_len(skb), 0);
+	}
+
 	err = qdisc_enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		pr_debug("qfq_enqueue: enqueue failed %d\n", err);
-- 
1.7.9.5
