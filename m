From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: Add ndo_gso_check
Date: Sun, 28 Sep 2014 20:50:07 -0700
Message-ID: <1411962607-27878-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org, gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49676 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaI2DuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 23:50:13 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1863580pab.24
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 20:50:12 -0700 (PDT)
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
 include/linux/netdevice.h | 12 +++++++++++-
 net/core/dev.c            |  2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9f5d293..f8c2027 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -997,6 +997,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
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
@@ -1146,6 +1152,8 @@ struct net_device_ops {
 							struct net_device *dev,
 							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
+	bool			(*ndo_gso_check) (struct sk_buff *skb,
+						  struct net_device *dev);
 };
 
 /**
@@ -3536,10 +3544,12 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
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
index e2ced01..8c2b9bb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2680,7 +2680,7 @@ struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (netif_needs_gso(skb, features)) {
+	if (netif_needs_gso(dev, skb, features)) {
 		struct sk_buff *segs;
 
 		segs = skb_gso_segment(skb, features);
-- 
2.1.0.rc2.206.gedb03e5
