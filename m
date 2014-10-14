From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] net: Add ndo_gso_check
Date: Tue, 14 Oct 2014 15:19:06 -0700
Message-ID: <1413325146-2404-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:37941 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615AbaJNWTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:19:21 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so16999pad.39
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 15:19:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ndo_gso_check which a device can define to indicate whether is
is capable of doing GSO on a packet. This funciton would be called from
the stack to determine whether software GSO is needed to be done. A
driver should populate this function if it advertises GSO types for
which there are combinations that it wouldn't be able to handle. For
instance a device that performs UDP tunneling might only implement
support for transparent Ethernet bridging type of inner packets
or might have limitations on lengths of inner headers.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/macvtap.c      |  2 +-
 drivers/net/xen-netfront.c |  2 +-
 include/linux/netdevice.h  | 12 +++++++++++-
 net/core/dev.c             |  2 +-
 4 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0c6adaa..65e2892 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -298,7 +298,7 @@ static rx_handler_result_t macvtap_handle_frame(struct sk_buff **pskb)
 	 */
 	if (q->flags & IFF_VNET_HDR)
 		features |= vlan->tap_features;
-	if (netif_needs_gso(skb, features)) {
+	if (netif_needs_gso(dev, skb, features)) {
 		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
 
 		if (IS_ERR(segs))
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index ca82f54..3c0b375 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -638,7 +638,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (slots > 1 && !xennet_can_sg(dev)) ||
-		     netif_needs_gso(skb, netif_skb_features(skb)))) {
+		     netif_needs_gso(dev, skb, netif_skb_features(skb)))) {
 		spin_unlock_irqrestore(&queue->tx_lock, flags);
 		goto drop;
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 838407a..74fd5d3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -998,6 +998,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
+ * bool	(*ndo_gso_check) (struct sk_buff *skb,
+ *			  struct net_device *dev);
+ *	Called by core transmit path to determine if device is capable of
+ *	performing GSO on a packet. The device returns true if it is
+ *	able to GSO the packet, false otherwise. If the return value is
+ *	false the stack will do software GSO.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1147,6 +1153,8 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+	bool			(*ndo_gso_check) (struct sk_buff *skb,
+						  struct net_device *dev);
 };
 
 /**
@@ -3572,10 +3580,12 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
-static inline bool netif_needs_gso(struct sk_buff *skb,
+static inline bool netif_needs_gso(struct net_device *dev, struct sk_buff *skb,
 				   netdev_features_t features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
+		(dev->netdev_ops->ndo_gso_check &&
+		 !dev->netdev_ops->ndo_gso_check(skb, dev)) ||
 		unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
 			 (skb->ip_summed != CHECKSUM_UNNECESSARY)));
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 3c5bdaa..0ae59ec 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2677,7 +2677,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (netif_needs_gso(skb, features)) {
+	if (netif_needs_gso(dev, skb, features)) {
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
-- 
2.1.0.rc2.206.gedb03e5
