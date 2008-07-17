From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/31]: pkt_sched: Move gso_skb into Qdisc.
Date: Thu, 17 Jul 2008 05:16:58 -0700 (PDT)
Message-ID: <20080717.051658.129292213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51654
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758077AbYGQMQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 08:16:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We liberate any dangling gso_skb during qdisc destruction.

It really only matters for the root qdisc.  But when qdiscs
can be shared by multiple netdev_queue objects, we can't
have the gso_skb in the netdev_queue any more.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |   19 +++++++++----------
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 787fbfc..0883fcf 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -449,7 +449,6 @@ struct netdev_queue {
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
-	struct sk_buff		*gso_skb;
 	spinlock_t		_xmit_lock;
 	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b47f556..b96c3d9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -36,6 +36,7 @@ struct Qdisc
 	u32			handle;
 	u32			parent;
 	atomic_t		refcnt;
+	struct sk_buff		*gso_skb;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
 	struct list_head	list;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2f575b9..2bd75be 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -77,7 +77,7 @@ static inline int dev_requeue_skb(struct sk_buff *skb,
 				  struct Qdisc *q)
 {
 	if (unlikely(skb->next))
-		dev_queue->gso_skb = skb;
+		q->gso_skb = skb;
 	else
 		q->ops->requeue(skb, q);
 
@@ -85,13 +85,12 @@ static inline int dev_requeue_skb(struct sk_buff *skb,
 	return 0;
 }
 
-static inline struct sk_buff *dequeue_skb(struct netdev_queue *dev_queue,
-					  struct Qdisc *q)
+static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb;
 
-	if ((skb = dev_queue->gso_skb))
-		dev_queue->gso_skb = NULL;
+	if ((skb = q->gso_skb))
+		q->gso_skb = NULL;
 	else
 		skb = q->dequeue(q);
 
@@ -155,10 +154,9 @@ static inline int qdisc_restart(struct netdev_queue *txq)
 	struct sk_buff *skb;
 
 	/* Dequeue packet */
-	if (unlikely((skb = dequeue_skb(txq, q)) == NULL))
+	if (unlikely((skb = dequeue_skb(q)) == NULL))
 		return 0;
 
-
 	/* And release queue */
 	spin_unlock(&txq->lock);
 
@@ -643,8 +641,8 @@ static void dev_deactivate_queue(struct net_device *dev,
 				 void *_qdisc_default)
 {
 	struct Qdisc *qdisc_default = _qdisc_default;
+	struct sk_buff *skb = NULL;
 	struct Qdisc *qdisc;
-	struct sk_buff *skb;
 
 	spin_lock_bh(&dev_queue->lock);
 
@@ -652,9 +650,10 @@ static void dev_deactivate_queue(struct net_device *dev,
 	if (qdisc) {
 		dev_queue->qdisc = qdisc_default;
 		qdisc_reset(qdisc);
+
+		skb = qdisc->gso_skb;
+		qdisc->gso_skb = NULL;
 	}
-	skb = dev_queue->gso_skb;
-	dev_queue->gso_skb = NULL;
 
 	spin_unlock_bh(&dev_queue->lock);
 
-- 
1.5.6.2.255.gbed62

