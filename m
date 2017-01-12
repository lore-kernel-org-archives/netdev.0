From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: core: Make netif_wake_subqueue a wrapper
Date: Wed, 11 Jan 2017 21:13:02 -0800
Message-ID: <20170112051302.1064-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35518 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdALFNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 00:13:06 -0500
Received: by mail-oi0-f65.google.com with SMTP id x84so1350105oix.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 21:13:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_wake_subqueue() is duplicating the same thing that netif_tx_wake_queue()
does, so make it call it directly after looking up the queue from the index.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h | 14 +++++++++++++-
 net/core/dev.c            | 22 ----------------------
 2 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d532c070163f..6d021c37b774 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3106,7 +3106,19 @@ static inline bool netif_subqueue_stopped(const struct net_device *dev,
 	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
 }
 
-void netif_wake_subqueue(struct net_device *dev, u16 queue_index);
+/**
+ *	netif_wake_subqueue - allow sending packets on subqueue
+ *	@dev: network device
+ *	@queue_index: sub queue index
+ *
+ * Resume individual transmit queue of a device with multiple transmit queues.
+ */
+static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
+{
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
+
+	netif_tx_wake_queue(txq);
+}
 
 #ifdef CONFIG_XPS
 int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
diff --git a/net/core/dev.c b/net/core/dev.c
index 643e4a4491c6..7547e2ccc06b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2408,28 +2408,6 @@ void netif_schedule_queue(struct netdev_queue *txq)
 }
 EXPORT_SYMBOL(netif_schedule_queue);
 
-/**
- *	netif_wake_subqueue - allow sending packets on subqueue
- *	@dev: network device
- *	@queue_index: sub queue index
- *
- * Resume individual transmit queue of a device with multiple transmit queues.
- */
-void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
-{
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
-
-	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state)) {
-		struct Qdisc *q;
-
-		rcu_read_lock();
-		q = rcu_dereference(txq->qdisc);
-		__netif_schedule(q);
-		rcu_read_unlock();
-	}
-}
-EXPORT_SYMBOL(netif_wake_subqueue);
-
 void netif_tx_wake_queue(struct netdev_queue *dev_queue)
 {
 	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state)) {
-- 
2.9.3
