From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/9]: pkt_sched: Add qdisc_dequeue() helper.
Date: Mon, 18 Aug 2008 01:36:55 -0700 (PDT)
Message-ID: <20080818.013655.96795435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbYHRIgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Add qdisc_dequeue() helper.

It prioritizes packets on the ->requeue list.

Use in qdisc_restart() as it's basically a complete
copy of dequeue_skb().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    8 ++++++++
 net/sched/sch_generic.c   |   13 +------------
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 140c48b..6da6e0a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -355,6 +355,14 @@ enum net_xmit_qdisc_t {
 #define net_xmit_drop_count(e)	(1)
 #endif
 
+static inline struct sk_buff *qdisc_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = __skb_dequeue(&sch->requeue);
+	if (!skb)
+		skb = sch->dequeue(sch);
+	return skb;
+}
+
 static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 #ifdef CONFIG_NET_SCHED
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 96d7d08..81e3dc4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -50,17 +50,6 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
-static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
-{
-	struct sk_buff *skb;
-
-	skb = __skb_dequeue(&q->requeue);
-	if (!skb)
-		skb = q->dequeue(q);
-
-	return skb;
-}
-
 static inline int handle_dev_cpu_collision(struct sk_buff *skb,
 					   struct netdev_queue *dev_queue,
 					   struct Qdisc *q)
@@ -119,7 +108,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	struct sk_buff *skb;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dequeue_skb(q)) == NULL))
+	if (unlikely((skb = qdisc_dequeue(q)) == NULL))
 		return 0;
 
 	root_lock = qdisc_lock(q);
-- 
1.5.6.5.GIT

