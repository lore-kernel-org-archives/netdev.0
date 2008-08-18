From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/9]: pkt_sched: Make qdisc->gso_skb a list.
Date: Mon, 18 Aug 2008 01:36:47 -0700 (PDT)
Message-ID: <20080818.013647.50493345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751260AbYHRIgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 04:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pkt_sched: Make qdisc->gso_skb a list.

The idea is that we can use this to get rid of
->requeue().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    2 +-
 net/sched/sch_generic.c   |   12 +++++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 84d25f2..140c48b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -52,7 +52,7 @@ struct Qdisc
 	u32			parent;
 	atomic_t		refcnt;
 	unsigned long		state;
-	struct sk_buff		*gso_skb;
+	struct sk_buff_head	requeue;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
 	struct Qdisc		*next_sched;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6f96b7b..39d969e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -45,7 +45,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	if (unlikely(skb->next))
-		q->gso_skb = skb;
+		__skb_queue_head(&q->requeue, skb);
 	else
 		q->ops->requeue(skb, q);
 
@@ -57,9 +57,8 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb;
 
-	if ((skb = q->gso_skb))
-		q->gso_skb = NULL;
-	else
+	skb = __skb_dequeue(&q->requeue);
+	if (!skb)
 		skb = q->dequeue(q);
 
 	return skb;
@@ -328,6 +327,7 @@ struct Qdisc noop_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
+	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
 };
@@ -353,6 +353,7 @@ static struct Qdisc noqueue_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
+	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.dev_queue	=	&noqueue_netdev_queue,
 };
@@ -473,6 +474,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch->padded = (char *) sch - (char *) p;
 
 	INIT_LIST_HEAD(&sch->list);
+	skb_queue_head_init(&sch->requeue);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
@@ -543,7 +545,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb(qdisc->gso_skb);
+	__skb_queue_purge(&qdisc->requeue);
 
 	kfree((char *) qdisc - qdisc->padded);
 }
-- 
1.5.6.5.GIT

