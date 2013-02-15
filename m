From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC] tbf: handle gso skbs properly
Date: Fri, 15 Feb 2013 13:44:57 +0100
Message-ID: <1360932297-6698-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:35584 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935906Ab3BOMpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 07:45:05 -0500
Received: by mail-ea0-f176.google.com with SMTP id a13so1406776eaa.7
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 04:45:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to Eric's suggestion, when gso skb can't be sent in one mtu
time, resegment it.

Note that helper will be moved to sch_api.c probably so it can be used
by other code.

Also, I'm not sure similar patch to this can be done for act_police. I
have to look at that more closely.

Thanks for review.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/sch_generic.h |  1 +
 net/core/dev.c            | 24 ------------------------
 net/sched/sch_api.c       | 27 +++++++++++++++++++++++++++
 net/sched/sch_tbf.c       | 38 +++++++++++++++++++++++++++++++++++++-
 4 files changed, 65 insertions(+), 25 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2761c90..de6db57 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -372,6 +372,7 @@ extern struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
 extern void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 				      const struct qdisc_size_table *stab);
+extern void qdisc_pkt_len_init(struct sk_buff *skb);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto **fl);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index f444736..8f86b1c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2680,30 +2680,6 @@ out:
 	return rc;
 }
 
-static void qdisc_pkt_len_init(struct sk_buff *skb)
-{
-	const struct skb_shared_info *shinfo = skb_shinfo(skb);
-
-	qdisc_skb_cb(skb)->pkt_len = skb->len;
-
-	/* To get more precise estimation of bytes sent on wire,
-	 * we add to pkt_len the headers size of all segments
-	 */
-	if (shinfo->gso_size)  {
-		unsigned int hdr_len;
-
-		/* mac layer + network layer */
-		hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
-
-		/* + transport layer */
-		if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
-			hdr_len += tcp_hdrlen(skb);
-		else
-			hdr_len += sizeof(struct udphdr);
-		qdisc_skb_cb(skb)->pkt_len += (shinfo->gso_segs - 1) * hdr_len;
-	}
-}
-
 static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct net_device *dev,
 				 struct netdev_queue *txq)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fe1ba54..7672259 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -29,6 +29,8 @@
 #include <linux/hrtimer.h>
 #include <linux/lockdep.h>
 #include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -464,6 +466,31 @@ out:
 }
 EXPORT_SYMBOL(__qdisc_calculate_pkt_len);
 
+void qdisc_pkt_len_init(struct sk_buff *skb)
+{
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
+
+	/* To get more precise estimation of bytes sent on wire,
+	 * we add to pkt_len the headers size of all segments
+	 */
+	if (shinfo->gso_size)  {
+		unsigned int hdr_len;
+
+		/* mac layer + network layer */
+		hdr_len = skb_transport_header(skb) - skb_mac_header(skb);
+
+		/* + transport layer */
+		if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)))
+			hdr_len += tcp_hdrlen(skb);
+		else
+			hdr_len += sizeof(struct udphdr);
+		qdisc_skb_cb(skb)->pkt_len += (shinfo->gso_segs - 1) * hdr_len;
+	}
+}
+EXPORT_SYMBOL(qdisc_pkt_len_init);
+
 void qdisc_warn_nonwc(char *txt, struct Qdisc *qdisc)
 {
 	if (!(qdisc->flags & TCQ_F_WARN_NONWC)) {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c8388f3..bfc89be 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -121,7 +121,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (qdisc_pkt_len(skb) > q->max_size)
+	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
 		return qdisc_reshape_fail(skb, sch);
 
 	ret = qdisc_enqueue(skb, q->qdisc);
@@ -147,6 +147,33 @@ static unsigned int tbf_drop(struct Qdisc *sch)
 	return len;
 }
 
+static bool qdisc_gso_segment(struct Qdisc *qdisc, struct sk_buff *skb)
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
+		qdisc_pkt_len_init(skb);
+		qdisc_calculate_pkt_len(skb, qdisc);
+		__skb_queue_after(&qdisc->q, prev_skb, skb);
+		prev_skb = skb;
+		skb = next_skb;
+		num_skbs++;
+	} while (skb);
+	qdisc_tree_decrease_qlen(qdisc, 1 - num_skbs);
+	return true;
+}
+
 static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 {
 	struct tbf_sched_data *q = qdisc_priv(sch);
@@ -167,6 +194,15 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 			ptoks = toks + q->ptokens;
 			if (ptoks > q->mtu)
 				ptoks = q->mtu;
+			if (skb_is_gso(skb) &&
+			    (s64) psched_l2t_ns(&q->peak, len) > q->mtu &&
+			    qdisc_gso_segment(q->qdisc, skb)) {
+				q->qdisc->gso_skb = NULL;
+				skb = q->qdisc->ops->peek(q->qdisc);
+				if (unlikely(!skb))
+					return NULL;
+				len = qdisc_pkt_len(skb);
+			}
 			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
 		}
 		toks += q->tokens;
-- 
1.8.1.2
