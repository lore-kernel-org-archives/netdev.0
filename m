From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [RFC 1/5] net: implement generic rx recycling
Date: Wed,  5 May 2010 16:47:46 +0200
Message-ID: <1273070870-7821-2-git-send-email-sebastian@breakpoint.cc>
References: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51292 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933505Ab0EEOr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 10:47:59 -0400
In-Reply-To: <1273070870-7821-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 include/linux/netdevice.h |   70 +++++++++++++++++++++++++++++++++++++--------
 1 files changed, 58 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 98112fb..70d385d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -588,6 +588,18 @@ struct netdev_rx_queue {
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
@@ -1044,9 +1056,55 @@ struct net_device {
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
+	skb_queue_head_init(&dev->rx_recycle);
+	dev->rx_rec_skbs_max = qlen;
+	dev->rx_rec_skb_size = size;
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
+		skb_queue_head(&dev->rx_recycle, skb);
+	else
+		dev_kfree_skb_any(skb);
+}
+
+static inline struct sk_buff *net_recycle_get(struct net_device *dev)
+{
+	struct sk_buff *skb;
+
+	skb = skb_dequeue(&dev->rx_recycle);
+	if (skb)
+		return skb;
+	return netdev_alloc_skb(dev, dev->rx_rec_skb_size);
+}
+
+static inline void net_recycle_size(struct net_device *dev, u32 size)
+{
+	if (dev->rx_rec_skb_size < size)
+		net_recycle_cleanup(dev);
+	dev->rx_rec_skb_size = size;
+}
+
+static inline void net_recycle_qlen(struct net_device *dev, u32 qlen)
+{
+	dev->rx_rec_skbs_max = qlen;
+}
+
 #define	NETDEV_ALIGN		32
 
 static inline
@@ -1635,18 +1693,6 @@ static inline int netif_is_multiqueue(const struct net_device *dev)
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
-- 
1.6.6.1

