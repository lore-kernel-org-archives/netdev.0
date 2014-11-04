From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 02/13] net_sched: introduce qdisc_peek() helper function
Date: Tue,  4 Nov 2014 09:56:25 -0800
Message-ID: <1415123796-8093-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49276 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaKDR4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:48 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so14817252pab.19
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:48 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_sched.h   |  1 -
 include/net/sch_generic.h | 19 +++++++++++++++++++
 net/sched/sch_api.c       | 10 ----------
 net/sched/sch_atm.c       |  4 ++--
 net/sched/sch_drr.c       |  6 ++----
 net/sched/sch_dsmark.c    |  2 +-
 net/sched/sch_hfsc.c      |  8 +++-----
 net/sched/sch_htb.c       |  2 +-
 net/sched/sch_multiq.c    |  2 +-
 net/sched/sch_prio.c      |  2 +-
 net/sched/sch_qfq.c       | 10 ++++------
 net/sched/sch_red.c       |  2 +-
 net/sched/sch_sfb.c       |  2 +-
 net/sched/sch_tbf.c       |  2 +-
 14 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 27a3383..f224b7c 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -96,7 +96,6 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 					struct nlattr *tab);
 void qdisc_put_rtab(struct qdisc_rate_table *tab);
 void qdisc_put_stab(struct qdisc_size_table *tab);
-void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc);
 int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		    struct net_device *dev, struct netdev_queue *txq,
 		    spinlock_t *root_lock, bool validate);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3d9fac9..a690e6f 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -518,6 +518,25 @@ static inline bool qdisc_is_percpu_stats(const struct Qdisc *q)
 	return q->flags & TCQ_F_CPUSTATS;
 }
 
+static inline void qdisc_warn_nonwc(void *func, struct Qdisc *qdisc)
+{
+	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
+		pr_warn("%pf: %s qdisc %X: is non-work-conserving?\n",
+			func, qdisc->ops->id, qdisc->handle >> 16);
+		qdisc->flags |= TCQ_F_WARN_NONWC;
+	}
+}
+
+static inline struct sk_buff *qdisc_peek(struct Qdisc *sch, bool warn)
+{
+	struct sk_buff *skb;
+
+	skb = sch->ops->peek(sch);
+	if (!skb && warn)
+		qdisc_warn_nonwc(__builtin_return_address(0), sch);
+	return skb;
+}
+
 static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
 				 const struct sk_buff *skb)
 {
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 76f402e..2276b15 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -563,16 +563,6 @@ void __qdisc_calculate_pkt_len(struct sk_buff *skb, const struct qdisc_size_tabl
 }
 EXPORT_SYMBOL(__qdisc_calculate_pkt_len);
 
-void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc)
-{
-	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
-		pr_warn("%s: %s qdisc %X: is non-work-conserving?\n",
-			txt, qdisc->ops->id, qdisc->handle >> 16);
-		qdisc->flags |= TCQ_F_WARN_NONWC;
-	}
-}
-EXPORT_SYMBOL(qdisc_warn_nonwc);
-
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e3e2cc5..1d3fb22 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -462,7 +462,7 @@ static void sch_atm_dequeue(unsigned long data)
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
 		 */
-		while ((skb = flow->q->ops->peek(flow->q))) {
+		while ((skb = qdisc_peek(flow->q, false))) {
 			if (!atm_may_send(flow->vcc, skb->truesize))
 				break;
 
@@ -516,7 +516,7 @@ static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
 
 	pr_debug("atm_tc_peek(sch %p,[qdisc %p])\n", sch, p);
 
-	return p->link.q->ops->peek(p->link.q);
+	return qdisc_peek(p->link.q ,false);
 }
 
 static unsigned int atm_tc_drop(struct Qdisc *sch)
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 3387060..a367fea 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -393,11 +393,9 @@ static struct sk_buff *drr_dequeue(struct Qdisc *sch)
 		goto out;
 	while (1) {
 		cl = list_first_entry(&q->active, struct drr_class, alist);
-		skb = cl->qdisc->ops->peek(cl->qdisc);
-		if (skb == NULL) {
-			qdisc_warn_nonwc(__func__, cl->qdisc);
+		skb = qdisc_peek(cl->qdisc, true);
+		if (skb == NULL)
 			goto out;
-		}
 
 		len = qdisc_pkt_len(skb);
 		if (len <= cl->deficit) {
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 227114f..7bdf7e0 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -319,7 +319,7 @@ static struct sk_buff *dsmark_peek(struct Qdisc *sch)
 
 	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
-	return p->q->ops->peek(p->q);
+	return qdisc_peek(p->q, false);
 }
 
 static unsigned int dsmark_drop(struct Qdisc *sch)
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e6c7416..7086ead 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -881,11 +881,9 @@ qdisc_peek_len(struct Qdisc *sch)
 	struct sk_buff *skb;
 	unsigned int len;
 
-	skb = sch->ops->peek(sch);
-	if (skb == NULL) {
-		qdisc_warn_nonwc("qdisc_peek_len", sch);
+	skb = qdisc_peek(sch, true);
+	if (skb == NULL)
 		return 0;
-	}
 	len = qdisc_pkt_len(skb);
 
 	return len;
@@ -1650,7 +1648,7 @@ hfsc_dequeue(struct Qdisc *sch)
 
 	skb = qdisc_dequeue_peeked(cl->qdisc);
 	if (skb == NULL) {
-		qdisc_warn_nonwc("HFSC", cl->qdisc);
+		qdisc_warn_nonwc(__builtin_return_address(0), cl->qdisc);
 		return NULL;
 	}
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f1acb0f..28b6929 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -850,7 +850,7 @@ static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, const int prio,
 		if (likely(skb != NULL))
 			break;
 
-		qdisc_warn_nonwc("htb", cl->un.leaf.q);
+		qdisc_warn_nonwc(__builtin_return_address(0), cl->un.leaf.q);
 		htb_next_rb_node(level ? &cl->parent->un.inner.clprio[prio].ptr:
 					 &q->hlevel[0].hprio[prio].ptr);
 		cl = htb_lookup_leaf(hprio, prio);
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 42dd218..1458aa3 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -142,7 +142,7 @@ static struct sk_buff *multiq_peek(struct Qdisc *sch)
 		if (!netif_xmit_stopped(
 		    netdev_get_tx_queue(qdisc_dev(sch), curband))) {
 			qdisc = q->queues[curband];
-			skb = qdisc->ops->peek(qdisc);
+			skb = qdisc_peek(qdisc, false);
 			if (skb)
 				return skb;
 		}
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8e5cd34..0e06d14 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -100,7 +100,7 @@ static struct sk_buff *prio_peek(struct Qdisc *sch)
 
 	for (prio = 0; prio < q->bands; prio++) {
 		struct Qdisc *qdisc = q->queues[prio];
-		struct sk_buff *skb = qdisc->ops->peek(qdisc);
+		struct sk_buff *skb = qdisc_peek(qdisc, false);
 		if (skb)
 			return skb;
 	}
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index 3ec7e88..9c9a5f3 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -1006,7 +1006,7 @@ static void agg_dequeue(struct qfq_aggregate *agg,
 
 	if (cl->qdisc->q.qlen == 0) /* no more packets, remove from list */
 		list_del(&cl->alist);
-	else if (cl->deficit < qdisc_pkt_len(cl->qdisc->ops->peek(cl->qdisc))) {
+	else if (cl->deficit < qdisc_pkt_len(qdisc_peek(cl->qdisc, false))) {
 		cl->deficit += agg->lmax;
 		list_move_tail(&cl->alist, &agg->active);
 	}
@@ -1019,10 +1019,8 @@ static inline struct sk_buff *qfq_peek_skb(struct qfq_aggregate *agg,
 	struct sk_buff *skb;
 
 	*cl = list_first_entry(&agg->active, struct qfq_class, alist);
-	skb = (*cl)->qdisc->ops->peek((*cl)->qdisc);
-	if (skb == NULL)
-		WARN_ONCE(1, "qfq_dequeue: non-workconserving leaf\n");
-	else
+	skb = qdisc_peek((*cl)->qdisc, true);
+	if (skb != NULL)
 		*len = qdisc_pkt_len(skb);
 
 	return skb;
@@ -1260,7 +1258,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	agg = cl->agg;
 	/* if the queue was not empty, then done here */
 	if (cl->qdisc->q.qlen != 1) {
-		if (unlikely(skb == cl->qdisc->ops->peek(cl->qdisc)) &&
+		if (unlikely(skb == qdisc_peek(cl->qdisc, false)) &&
 		    list_first_entry(&agg->active, struct qfq_class, alist)
 		    == cl && cl->deficit < qdisc_pkt_len(skb))
 			list_move_tail(&cl->alist, &agg->active);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 6c0534c..8fd96ae 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -131,7 +131,7 @@ static struct sk_buff *red_peek(struct Qdisc *sch)
 	struct red_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
 
-	return child->ops->peek(child);
+	return qdisc_peek(child, false);
 }
 
 static unsigned int red_drop(struct Qdisc *sch)
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 5819dd8..08c318e 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -447,7 +447,7 @@ static struct sk_buff *sfb_peek(struct Qdisc *sch)
 	struct sfb_sched_data *q = qdisc_priv(sch);
 	struct Qdisc *child = q->qdisc;
 
-	return child->ops->peek(child);
+	return qdisc_peek(child, false);
 }
 
 /* No sfb_drop -- impossible since the child doesn't return the dropped skb. */
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a4afde1..1f63a71 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -231,7 +231,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 
-	skb = q->qdisc->ops->peek(q->qdisc);
+	skb = qdisc_peek(q->qdisc, false);
 
 	if (skb) {
 		s64 now;
-- 
1.8.3.1
