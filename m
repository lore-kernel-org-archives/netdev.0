From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 4/4] [RFC] sched: Changes to dequeue_skb
Date: Wed, 04 May 2011 19:33:45 +0530
Message-ID: <20110504140345.14817.85236.sendpatchset@krkumar2.in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dequeue_skb has an additional check, for the first packet that
is requeued, to see if the device has requested xmits after a
interval. This is intended to not affect the fast xmit path, and
have minimal overhead to the slow path. Drivers setting the
restart time should not stop/start their tx queues, and hence
the frozen/stopped check can be avoided.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/sched/sch_generic.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2011-05-04 18:57:06.000000000 +0530
+++ new/net/sched/sch_generic.c	2011-05-04 18:57:09.000000000 +0530
@@ -50,17 +50,30 @@ static inline int dev_requeue_skb(struct
 	return 0;
 }
 
+/*
+ * This function can return a rare false positive for drivers setting
+ * xmit_restart_jiffies (e.g. virtio-net) when xmit_restart_jiffies is
+ * zero but the device may not be ready. That only leads to the skb
+ * being requeued again.
+ */
+static inline int can_restart_xmit(struct Qdisc *q, struct sk_buff *skb)
+{
+	struct net_device *dev = qdisc_dev(q);
+	struct netdev_queue *txq;
+
+	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+	if (unlikely(txq->xmit_restart_jiffies))
+		return time_after_eq(jiffies, txq->xmit_restart_jiffies);
+	return !netif_tx_queue_frozen_or_stopped(txq);
+}
+
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb = q->gso_skb;
 
 	if (unlikely(skb)) {
-		struct net_device *dev = qdisc_dev(q);
-		struct netdev_queue *txq;
-
 		/* check the reason of requeuing without tx lock first */
-		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_frozen_or_stopped(txq)) {
+		if (can_restart_xmit(q, skb)) {
 			q->gso_skb = NULL;
 			q->q.qlen--;
 		} else
