From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH net-next] pkt_sched: avoid requeues if possible
Date: Tue, 11 Dec 2012 17:54:33 -0800
Message-ID: <1355277273.27891.166.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:38562 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586Ab2LLCZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 21:25:37 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so124989pac.15
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 18:25:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With BQL being deployed, we can more likely have following behavior :

We dequeue a packet from qdisc in dequeue_skb(), then we realize target
tx queue is in XOFF state in sch_direct_xmit(), and we have to hold the
skb into gso_skb for later.

This shows in stats (tc -s qdisc dev eth0) as requeues.

Problem of these requeues is that high priority packets can not be
dequeued as long as this (possibly low prio and big TSO packet) is not
removed from gso_skb.

At 1Gbps speed, a full size TSO packet is 500 us of extra latency.

In some cases, we know that all packets dequeued from a qdisc are
for a particular and known txq :

- If device is non multi queue
- For all MQ/MQPRIO slave qdiscs

This patch introduces a new qdisc flag, TCQ_F_ONETXQUEUE to mark
this capability, so that dequeue_skb() is allowed to dequeue a packet
only if the associated txq is not stopped.

This indeed reduce latencies for high prio packets (or improve fairness
with sfq/fq_codel), and almost remove qdisc 'requeues'.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    7 +++++++
 net/sched/sch_api.c       |    2 ++
 net/sched/sch_generic.c   |   11 ++++++-----
 net/sched/sch_mq.c        |    4 +++-
 net/sched/sch_mqprio.c    |    4 ++++
 5 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4616f46..1540f9c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -50,6 +50,13 @@ struct Qdisc {
 #define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
 #define TCQ_F_MQROOT		8
+#define TCQ_F_ONETXQUEUE	0x10 /* dequeue_skb() can assume all skbs are for
+				      * q->dev_queue : It can test
+				      * netif_xmit_frozen_or_stopped() before
+				      * dequeueing next packet.
+				      * Its true for MQ/MQPRIO slaves, or non
+				      * multiqueue device.
+				      */
 #define TCQ_F_WARN_NONWC	(1 << 16)
 	int			padded;
 	const struct Qdisc_ops	*ops;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4799c48..d84f7e7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -833,6 +833,8 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out3;
 		}
 		lockdep_set_class(qdisc_lock(sch), &qdisc_tx_lock);
+		if (!netif_is_multiqueue(dev))
+			sch->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	sch->handle = handle;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index aefc150..5d81a44 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -53,20 +53,19 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb = q->gso_skb;
+	const struct netdev_queue *txq = q->dev_queue;
 
 	if (unlikely(skb)) {
-		struct net_device *dev = qdisc_dev(q);
-		struct netdev_queue *txq;
-
 		/* check the reason of requeuing without tx lock first */
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		txq = netdev_get_tx_queue(txq->dev, skb_get_queue_mapping(skb));
 		if (!netif_xmit_frozen_or_stopped(txq)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
 		} else
 			skb = NULL;
 	} else {
-		skb = q->dequeue(q);
+		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq))
+			skb = q->dequeue(q);
 	}
 
 	return skb;
@@ -686,6 +685,8 @@ static void attach_one_default_qdisc(struct net_device *dev,
 			netdev_info(dev, "activation failed\n");
 			return;
 		}
+		if (!netif_is_multiqueue(dev))
+			qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 	dev_queue->qdisc_sleeping = qdisc;
 }
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 0a4b2f9..5da78a1 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -63,6 +63,7 @@ static int mq_init(struct Qdisc *sch, struct nlattr *opt)
 		if (qdisc == NULL)
 			goto err;
 		priv->qdiscs[ntx] = qdisc;
+		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	sch->flags |= TCQ_F_MQROOT;
@@ -150,7 +151,8 @@ static int mq_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 		dev_deactivate(dev);
 
 	*old = dev_graft_qdisc(dev_queue, new);
-
+	if (new)
+		new->flags |= TCQ_F_ONETXQUEUE;
 	if (dev->flags & IFF_UP)
 		dev_activate(dev);
 	return 0;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index d1831ca..accec33 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -132,6 +132,7 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 			goto err;
 		}
 		priv->qdiscs[i] = qdisc;
+		qdisc->flags |= TCQ_F_ONETXQUEUE;
 	}
 
 	/* If the mqprio options indicate that hardware should own
@@ -205,6 +206,9 @@ static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 
 	*old = dev_graft_qdisc(dev_queue, new);
 
+	if (new)
+		new->flags |= TCQ_F_ONETXQUEUE;
+
 	if (dev->flags & IFF_UP)
 		dev_activate(dev);
 
