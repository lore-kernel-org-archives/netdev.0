From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/5] sched: remove qdisc arg from __qdisc_dequeue_head
Date: Sun, 18 Sep 2016 00:57:32 +0200
Message-ID: <1474153054-9059-4-git-send-email-fw@strlen.de>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51388 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755055AbcIQW5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 18:57:34 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves qdisc stat accouting to qdisc_dequeue_head.

The only direct caller of the __qdisc_dequeue_head version open-codes
this now.

This allows us to later use __qdisc_dequeue_head as a replacement
of __skb_dequeue() (which operates on sk_buff_head list).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h | 15 ++++++++-------
 net/sched/sch_generic.c   |  7 ++++++-
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 52a2015..0741ed4 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -614,11 +614,17 @@ static inline int qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch)
 	return __qdisc_enqueue_tail(skb, sch, &sch->q);
 }
 
-static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
-						   struct sk_buff_head *list)
+static inline struct sk_buff *__qdisc_dequeue_head(struct sk_buff_head *list)
 {
 	struct sk_buff *skb = __skb_dequeue(list);
 
+	return skb;
+}
+
+static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
+{
+	struct sk_buff *skb = __qdisc_dequeue_head(&sch->q);
+
 	if (likely(skb != NULL)) {
 		qdisc_qstats_backlog_dec(sch, skb);
 		qdisc_bstats_update(sch, skb);
@@ -627,11 +633,6 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
 	return skb;
 }
 
-static inline struct sk_buff *qdisc_dequeue_head(struct Qdisc *sch)
-{
-	return __qdisc_dequeue_head(sch, &sch->q);
-}
-
 /* Instead of calling kfree_skb() while root qdisc lock is held,
  * queue the skb for future freeing at end of __dev_xmit_skb()
  */
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5e63bf6..73877d9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -506,7 +506,12 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 
 	if (likely(band >= 0)) {
 		struct sk_buff_head *list = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
+		struct sk_buff *skb = __qdisc_dequeue_head(list);
+
+		if (likely(skb != NULL)) {
+			qdisc_qstats_backlog_dec(qdisc, skb);
+			qdisc_bstats_update(qdisc, skb);
+		}
 
 		qdisc->q.qlen--;
 		if (skb_queue_empty(list))
-- 
2.7.3
