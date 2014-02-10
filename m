From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/2] net: core: introduce netif_skb_dev_features
Date: Mon, 10 Feb 2014 21:35:36 +0100
Message-ID: <1392064537-30646-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:58126 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752253AbaBJUjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 15:39:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be used by upcoming ipv4 forward path change that needs to
determine feature mask using skb->dst->dev instead of skb->dev.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h |  7 ++++++-
 net/core/dev.c            | 20 +++++++++++---------
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 440a02e..21d4e6b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3068,7 +3068,12 @@ void netdev_change_features(struct net_device *dev);
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
index 3721db7..94f7401 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2495,34 +2495,36 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 }
 
 static netdev_features_t harmonize_features(struct sk_buff *skb,
-	netdev_features_t features)
+					    const struct net_device *dev,
+					    netdev_features_t features)
 {
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, skb_network_protocol(skb))) {
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
-		return harmonize_features(skb, features);
+		return harmonize_features(skb, dev, features);
 	}
 
-	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
+	features &= (dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
 					       NETIF_F_HW_VLAN_STAG_TX);
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
@@ -2530,9 +2532,9 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_STAG_TX;
 
-	return harmonize_features(skb, features);
+	return harmonize_features(skb, dev, features);
 }
-EXPORT_SYMBOL(netif_skb_features);
+EXPORT_SYMBOL(netif_skb_dev_features);
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
-- 
1.8.1.5
