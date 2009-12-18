From: Christian Samsel <christian.samsel@rwth-aachen.de>
Subject: [PATCH 1/2] improve netem reorder flexibility
Date: Fri, 18 Dec 2009 14:18:37 +0100
Message-ID: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:35844 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751466AbZLRNSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 08:18:50 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUU00MDUNNBBC50@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 18 Dec 2009 14:18:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new feature to netem: The newly introduced parameter 
reorderdelay TIME is the time a reordered packet is delayed. It can be used in
a combination with delay TIME to enable netem to produce late packets, which is
not possible in the standard netem / iproute2. In the standard version 
reordered packets are always sent immediately and therefore are always early packets.

Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>
---
 include/linux/pkt_sched.h |   21 ++++++++++++---------
 net/sched/sch_netem.c     |   40 ++++++++++++++++++++++++----------------
 2 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2cfa4bc..eca6401 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -441,18 +441,21 @@ enum {
 #define TCA_NETEM_MAX (__TCA_NETEM_MAX - 1)
 
 struct tc_netem_qopt {
-	__u32	latency;	/* added delay (us) */
-	__u32   limit;		/* fifo limit (packets) */
-	__u32	loss;		/* random packet loss (0=none ~0=100%) */
-	__u32	gap;		/* re-ordering gap (0 for none) */
-	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
-	__u32	jitter;		/* random jitter in latency (us) */
+	__u32	latency;		/* added delay (us) */
+	__u32	limit;			/* fifo limit (packets) */
+	__u32	loss;			/* random packet loss (0=none ~0=100%) */
+	__u32	gap;			/* minimum re-ordering gap (0 for none) */
+	__u32	duplicate;		/* random packet dup  (0=none ~0=100%) */
+	__u32	jitter;			/* random jitter in latency (us) */
+	__u32	reorderdelay;		/* delay for reordered packets (us) */
+	__u32	reorderdelayjitter;	/* random jitter for reordered packets (us) */
 };
 
 struct tc_netem_corr {
-	__u32	delay_corr;	/* delay correlation */
-	__u32	loss_corr;	/* packet loss correlation */
-	__u32	dup_corr;	/* duplicate correlation  */
+	__u32	delay_corr;		/* delay correlation */
+	__u32	reorderdelay_corr;	/* reorderdelay correlation */
+	__u32	loss_corr;		/* packet loss correlation */
+	__u32	dup_corr;		/* duplicate correlation  */
 };
 
 struct tc_netem_reorder {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index d8b10e0..84f7438 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -54,6 +54,7 @@ struct netem_sched_data {
 
 	psched_tdiff_t latency;
 	psched_tdiff_t jitter;
+	psched_tdiff_t reorderdelayjitter;
 
 	u32 loss;
 	u32 limit;
@@ -62,11 +63,12 @@ struct netem_sched_data {
 	u32 duplicate;
 	u32 reorder;
 	u32 corrupt;
+	u32 reorderdelay;
 
 	struct crndstate {
 		u32 last;
 		u32 rho;
-	} delay_cor, loss_cor, dup_cor, reorder_cor, corrupt_cor;
+	} delay_cor, reorderdelay_cor, loss_cor, dup_cor, reorder_cor, corrupt_cor;
 
 	struct disttable {
 		u32  size;
@@ -157,8 +159,10 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* We don't fill cb now as skb_unshare() may invalidate it */
 	struct netem_skb_cb *cb;
 	struct sk_buff *skb2;
+	struct sk_buff *skb3;
 	int ret;
 	int count = 1;
+	psched_tdiff_t delay;
 
 	pr_debug("netem_enqueue skb=%p\n", skb);
 
@@ -213,30 +217,30 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->gap == 0 || 		/* not doing reordering */
 	    q->counter < q->gap || 	/* inside last reordering gap */
 	    q->reorder < get_crandom(&q->reorder_cor)) {
-		psched_time_t now;
-		psched_tdiff_t delay;
 
+		/* no reordering (use standard delay) */
 		delay = tabledist(q->latency, q->jitter,
 				  &q->delay_cor, q->delay_dist);
-
-		now = psched_get_time();
-		cb->time_to_send = now + delay;
 		++q->counter;
-		ret = qdisc_enqueue(skb, q->qdisc);
 	} else {
-		/*
-		 * Do re-ordering by putting one out of N packets at the front
-		 * of the queue.
-		 */
-		cb->time_to_send = psched_get_time();
+		/* Do reordering (use reorderdelay) */
+		delay = tabledist(q->reorderdelay, q->reorderdelayjitter,
+				  &q->reorderdelay_cor, q->delay_dist);
 		q->counter = 0;
+	}
+	cb->time_to_send = psched_get_time()+delay;
 
-		__skb_queue_head(&q->qdisc->q, skb);
-		q->qdisc->qstats.backlog += qdisc_pkt_len(skb);
-		q->qdisc->qstats.requeues++;
-		ret = NET_XMIT_SUCCESS;
+	skb3 = q->qdisc->ops->peek(q->qdisc);
+	if (skb3) {
+		const struct netem_skb_cb *cb2 = netem_skb_cb(skb3);
+
+		/* if new packet is more recent, update watchdog */
+		if (cb->time_to_send < cb2->time_to_send)
+			qdisc_watchdog_schedule(&q->watchdog,cb->time_to_send);
 	}
 
+	ret = qdisc_enqueue(skb, q->qdisc);
+
 	if (likely(ret == NET_XMIT_SUCCESS)) {
 		sch->q.qlen++;
 		sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -347,6 +351,7 @@ static void get_correlation(struct Qdisc *sch, const struct nlattr *attr)
 	const struct tc_netem_corr *c = nla_data(attr);
 
 	init_crandom(&q->delay_cor, c->delay_corr);
+	init_crandom(&q->reorderdelay_cor, c->reorderdelay_corr);
 	init_crandom(&q->loss_cor, c->loss_corr);
 	init_crandom(&q->dup_cor, c->dup_corr);
 }
@@ -418,6 +423,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 	q->counter = 0;
 	q->loss = qopt->loss;
 	q->duplicate = qopt->duplicate;
+	q->reorderdelay = qopt->reorderdelay;
+	q->reorderdelayjitter = qopt->reorderdelayjitter;
 
 	/* for compatibility with earlier versions.
 	 * if gap is set, need to assume 100% probability
@@ -578,6 +585,7 @@ static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
 	qopt.loss = q->loss;
 	qopt.gap = q->gap;
 	qopt.duplicate = q->duplicate;
+	qopt.reorderdelay = q->reorderdelay;
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
 	cor.delay_corr = q->delay_cor.rho;
-- 
1.6.4.1

