From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH 3/6] offloading: Pass features into netif_needs_gso().
Date: Sun,  9 Jan 2011 08:23:32 -0800
Message-ID: <1294590215-15541-3-git-send-email-jesse@nicira.com>
References: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:41095 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1AIQXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:23:45 -0500
Received: by yib18 with SMTP id 18so5042835yib.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:23:45 -0800 (PST)
In-Reply-To: <1294590215-15541-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that there is a single function that can compute the device
features relevant to a packet, we don't want to run it for each
offload.  This converts netif_needs_gso() to take the features
of the device, rather than computing them itself.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/xen-netfront.c |    2 +-
 include/linux/netdevice.h  |   12 +++---------
 net/core/dev.c             |    8 ++++++--
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index cdbeec9..546de57 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -488,7 +488,7 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(!netif_carrier_ok(dev) ||
 		     (frags > 1 && !xennet_can_sg(dev)) ||
-		     netif_needs_gso(dev, skb))) {
+		     netif_needs_gso(skb, netif_skb_features(skb)))) {
 		spin_unlock_irq(&np->tx_lock);
 		goto drop;
 	}
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d4dac09..de2bfe6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2317,16 +2317,10 @@ static inline int skb_gso_ok(struct sk_buff *skb, int features)
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
 
-static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
+static inline int netif_needs_gso(struct sk_buff *skb, int features)
 {
-	if (skb_is_gso(skb)) {
-		int features = netif_skb_features(skb);
-
-		return (!skb_gso_ok(skb, features) ||
-			unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
-	}
-
-	return 0;
+	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
+		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
 }
 
 static inline void netif_set_gso_max_size(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index a51dfd7..1444ed3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2086,6 +2086,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	int rc = NETDEV_TX_OK;
 
 	if (likely(!skb->next)) {
+		int features;
+
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -2098,8 +2100,10 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 		skb_orphan_try(skb);
 
+		features = netif_skb_features(skb);
+
 		if (vlan_tx_tag_present(skb) &&
-		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
+		    !(features & NETIF_F_HW_VLAN_TX)) {
 			skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
 			if (unlikely(!skb))
 				goto out;
@@ -2107,7 +2111,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			skb->vlan_tci = 0;
 		}
 
-		if (netif_needs_gso(dev, skb)) {
+		if (netif_needs_gso(skb, features)) {
 			if (unlikely(dev_gso_segment(skb)))
 				goto out_kfree_skb;
 			if (skb->next)
-- 
1.7.1

