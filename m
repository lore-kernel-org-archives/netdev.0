From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 10/14] pkt_sched: Redo qdisc_dequeue() and bring back
	qdisc_requeue().
Date: Tue, 14 Oct 2008 09:55:03 +0000
Message-ID: <20081014095502.GK10804@ff.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:52657 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160AbYJNJzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 05:55:08 -0400
Received: by ug-out-1314.google.com with SMTP id k3so850192ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 02:55:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use __qdisc_dequeue_head() and update sch->q.qlen in qdisc_dequeue().
Bring back qdisc_requeue() wrapper to raplace open-coded uses of
sch->requeue.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f3f0b0b..78c38a4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -368,14 +368,6 @@ enum net_xmit_qdisc_t {
 #define net_xmit_drop_count(e)	(1)
 #endif
 
-static inline struct sk_buff *qdisc_dequeue(struct Qdisc *sch)
-{
-	struct sk_buff *skb = __skb_dequeue(&sch->requeue);
-	if (!skb)
-		skb = sch->dequeue(sch);
-	return skb;
-}
-
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
@@ -439,6 +431,26 @@ static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
 	return __qdisc_dequeue_tail(sch, &sch->q);
 }
 
+static inline struct sk_buff *qdisc_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = __qdisc_dequeue_head(sch, &sch->requeue);
+
+	if (unlikely(skb))
+		sch->q.qlen--;
+	else
+		skb = sch->dequeue(sch);
+
+	return skb;
+}
+
+static inline void qdisc_requeue(struct Qdisc *sch, struct sk_buff *skb)
+{
+	__skb_queue_head(&sch->requeue, skb);
+	sch->qstats.backlog += qdisc_pkt_len(skb);
+	sch->qstats.requeues++;
+	sch->q.qlen++;
+}
+
 static inline void __qdisc_reset_queue(struct Qdisc *sch,
 				       struct sk_buff_head *list)
 {
@@ -452,6 +464,7 @@ static inline void __qdisc_reset_queue(struct Qdisc *sch,
 static inline void qdisc_reset_queue(struct Qdisc *sch)
 {
 	__qdisc_reset_queue(sch, &sch->q);
+	__qdisc_reset_queue(sch, &sch->requeue);
 	sch->qstats.backlog = 0;
 }
 
-- 
1.5.6.5

