From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] tbf: handle gso skbs properly
Date: Fri, 15 Feb 2013 16:24:42 +0100
Message-ID: <1360941882-6727-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:37104 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932792Ab3BOPYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 10:24:54 -0500
Received: by mail-ee0-f42.google.com with SMTP id b47so1825546eek.29
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 07:24:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So far, gso skbs has been handled by tbf in the same way as any other
ones. Given their pkt_len they got dropped which leads to very
inaccurate rates. This patch makes tbf gso-aware.

According to Eric's suggestion, when gso skb can't be sent in one mtu
time, resegment it.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/sch_generic.h |  1 +
 net/sched/sch_api.c       | 28 ++++++++++++++++++++++++++++
 net/sched/sch_tbf.c       | 15 +++++++++++++--
 3 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2761c90..9f57762 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -366,6 +366,7 @@ extern struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
+extern bool qdisc_gso_segment(struct Qdisc *qdisc, struct sk_buff *skb);
 extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 				 struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fe1ba54..cd8df6b 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -666,6 +666,34 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 }
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
 
+bool qdisc_gso_segment(struct Qdisc *qdisc, struct sk_buff *skb)
+{
+	struct sk_buff *segs;
+	struct sk_buff *next_skb;
+	struct sk_buff *prev_skb;
+	int num_skbs = 0;
+
+	segs = skb_gso_segment(skb, 0);
+	if (IS_ERR(segs) || !segs)
+		return false;
+	__skb_unlink(skb, &qdisc->q);
+	kfree_skb(skb);
+	skb = segs;
+	prev_skb = (struct sk_buff *) &qdisc->q;
+	do {
+		next_skb = skb->next;
+		qdisc_skb_cb(skb)->pkt_len = skb->len;
+		qdisc_calculate_pkt_len(skb, qdisc);
+		__skb_queue_after(&qdisc->q, prev_skb, skb);
+		prev_skb = skb;
+		skb = next_skb;
+		num_skbs++;
+	} while (skb);
+	qdisc_tree_decrease_qlen(qdisc, 1 - num_skbs);
+	return true;
+}
+EXPORT_SYMBOL(qdisc_gso_segment);
+
 static void notify_and_destroy(struct net *net, struct sk_buff *skb,
 			       struct nlmsghdr *n, u32 clid,
 			       struct Qdisc *old, struct Qdisc *new)
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c8388f3..5680562 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (qdisc_pkt_len(skb) > q->max_size)
+	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
 		return qdisc_reshape_fail(skb, sch);
 
 	ret = qdisc_enqueue(skb, q->qdisc);
@@ -164,10 +164,21 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		toks = min_t(s64, now - q->t_c, q->buffer);
 
 		if (q->peak_present) {
+			s64 skb_ptoks = (s64) psched_l2t_ns(&q->peak, len);
+
 			ptoks = toks + q->ptokens;
 			if (ptoks > q->mtu)
 				ptoks = q->mtu;
-			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
+			if (skb_is_gso(skb) && skb_ptoks > q->mtu &&
+			    qdisc_gso_segment(q->qdisc, skb)) {
+				q->qdisc->gso_skb = NULL;
+				skb = q->qdisc->ops->peek(q->qdisc);
+				if (unlikely(!skb))
+					return NULL;
+				len = qdisc_pkt_len(skb);
+				skb_ptoks = (s64) psched_l2t_ns(&q->peak, len);
+			}
+			ptoks -= skb_ptoks;
 		}
 		toks += q->tokens;
 		if (toks > q->buffer)
-- 
1.8.1.2
