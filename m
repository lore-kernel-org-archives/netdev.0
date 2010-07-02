From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 1/8] net: implement generic rx recycling
Date: Fri,  2 Jul 2010 21:20:14 +0200
Message-ID: <1278098421-21296-2-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41197 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

the code is basically what other drivers like gianfar are using right
now.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/netdevice.h |   67 +++++++++++++++++++++++++++++++++++++--------
 net/core/dev.c            |    1 +
 2 files changed, 56 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8fa5e5a..4fa400b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -595,6 +595,18 @@ struct netdev_rx_queue {
 } ____cacheline_aligned_in_smp;
 #endif /* CONFIG_RPS */
 
+/* Use this variant when it is known for sure that it
+ * is executing from hardware interrupt context or with hardware interrupts
+ * disabled.
+ */
+extern void dev_kfree_skb_irq(struct sk_buff *skb);
+
+/* Use this variant in places where it could be invoked
+ * from either hardware interrupt or other context, with hardware interrupts
+ * either disabled or enabled.
+ */
+extern void dev_kfree_skb_any(struct sk_buff *skb);
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1077,9 +1089,52 @@ struct net_device {
 #endif
 	/* n-tuple filter list attached to this device */
 	struct ethtool_rx_ntuple_list ethtool_ntuple_list;
+	struct sk_buff_head rx_recycle;
+	u32 rx_rec_skbs_max;
+	u32 rx_rec_skb_size;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
+static inline void net_recycle_init(struct net_device *dev, u32 qlen, u32 size)
+{
+	dev->rx_rec_skbs_max = qlen;
+	dev->rx_rec_skb_size = size;
+}
+
+static inline void net_recycle_size(struct net_device *dev, u32 size)
+{
+	dev->rx_rec_skb_size = size;
+}
+
+static inline void net_recycle_qlen(struct net_device *dev, u32 qlen)
+{
+	dev->rx_rec_skbs_max = qlen;
+}
+
+static inline void net_recycle_cleanup(struct net_device *dev)
+{
+	skb_queue_purge(&dev->rx_recycle);
+}
+
+static inline void net_recycle_add(struct net_device *dev, struct sk_buff *skb)
+{
+	if (skb_queue_len(&dev->rx_recycle) < dev->rx_rec_skbs_max &&
+			skb_recycle_check(skb, dev->rx_rec_skb_size))
+		__skb_queue_head(&dev->rx_recycle, skb);
+	else
+		dev_kfree_skb_any(skb);
+}
+
+static inline struct sk_buff *net_recycle_get(struct net_device *dev)
+{
+	struct sk_buff *skb;
+
+	skb = __skb_dequeue(&dev->rx_recycle);
+	if (skb)
+		return skb;
+	return netdev_alloc_skb(dev, dev->rx_rec_skb_size);
+}
+
 #define	NETDEV_ALIGN		32
 
 static inline
@@ -1672,18 +1727,6 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
 	return (dev->num_tx_queues > 1);
 }
 
-/* Use this variant when it is known for sure that it
- * is executing from hardware interrupt context or with hardware interrupts
- * disabled.
- */
-extern void dev_kfree_skb_irq(struct sk_buff *skb);
-
-/* Use this variant in places where it could be invoked
- * from either hardware interrupt or other context, with hardware interrupts
- * either disabled or enabled.
- */
-extern void dev_kfree_skb_any(struct sk_buff *skb);
-
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index e85cc5f..db9acd5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5404,6 +5404,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	netdev_init_queues(dev);
 
+	skb_queue_head_init(&dev->rx_recycle);
 	INIT_LIST_HEAD(&dev->ethtool_ntuple_list.list);
 	dev->ethtool_ntuple_list.count = 0;
 	INIT_LIST_HEAD(&dev->napi_list);
-- 
1.6.6.1

