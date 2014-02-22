From: Florian Westphal <fw@strlen.de>
Subject: [PATCH stable 3.10.y 2/3] net: core: introduce netif_skb_dev_features
Date: Sat, 22 Feb 2014 10:30:18 +0100
Message-ID: <1393061419-4892-3-git-send-email-fw@strlen.de>
References: <1393061419-4892-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44033 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752322AbaBVJe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 04:34:29 -0500
In-Reply-To: <1393061419-4892-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d206940319c41df4299db75ed56142177bb2e5f6 upstream.

Will be used by upcoming ipv4 forward path change that needs to
determine feature mask using skb->dst->dev instead of skb->dev.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |  7 ++++++-
 net/core/dev.c            | 27 ++++++++++++++++-----------
 2 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index abf7756..4d2e041 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2761,7 +2761,12 @@ void netdev_change_features(struct net_device *dev);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 					struct net_device *dev);
 
-netdev_features_t netif_skb_features(struct sk_buff *skb);
+netdev_features_t netif_skb_dev_features(struct sk_buff *skb,
+					 const struct net_device *dev);
+static inline netdev_features_t netif_skb_features(struct sk_buff *skb)
+{
+	return netif_skb_dev_features(skb, skb->dev);
+}
 
 static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 1283c84..a0e55ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2374,7 +2374,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
  * 2. No high memory really exists on this machine.
  */
 
-static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
+static int illegal_highdma(const struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
@@ -2454,46 +2454,51 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 }
 
 static netdev_features_t harmonize_features(struct sk_buff *skb,
-	__be16 protocol, netdev_features_t features)
+					    __be16 protocol,
+					    const struct net_device *dev,
+					    netdev_features_t features)
 {
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, protocol)) {
 		features &= ~NETIF_F_ALL_CSUM;
-	} else if (illegal_highdma(skb->dev, skb)) {
+	} else if (illegal_highdma(dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
 
 	return features;
 }
 
-netdev_features_t netif_skb_features(struct sk_buff *skb)
+netdev_features_t netif_skb_dev_features(struct sk_buff *skb,
+					 const struct net_device *dev)
 {
 	__be16 protocol = skb->protocol;
-	netdev_features_t features = skb->dev->features;
+	netdev_features_t features = dev->features;
 
-	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
+	if (skb_shinfo(skb)->gso_segs > dev->gso_max_segs)
 		features &= ~NETIF_F_GSO_MASK;
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
 	} else if (!vlan_tx_tag_present(skb)) {
-		return harmonize_features(skb, protocol, features);
+		return harmonize_features(skb, protocol, dev, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
+	features &= (dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
 					       NETIF_F_HW_VLAN_STAG_TX);
 
 	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD)) {
-		return harmonize_features(skb, protocol, features);
+		return harmonize_features(skb, protocol, dev, features);
 	} else {
 		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
 				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_STAG_TX;
-		return harmonize_features(skb, protocol, features);
+		return harmonize_features(skb, protocol, dev, features);
 	}
+
+	return harmonize_features(skb, protocol, dev, features);
 }
-EXPORT_SYMBOL(netif_skb_features);
+EXPORT_SYMBOL(netif_skb_dev_features);
 
 /*
  * Returns true if either:
-- 
1.8.1.5
