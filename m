From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] Revert "net: core: introduce netif_skb_dev_features"
Date: Mon,  5 May 2014 15:00:44 +0200
Message-ID: <1399294844-7231-3-git-send-email-fw@strlen.de>
References: <1399294844-7231-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36400 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932187AbaEENGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 09:06:18 -0400
In-Reply-To: <1399294844-7231-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d206940319c41df4299db75ed56142177bb2e5f6,
there are no more callers.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h |  7 +------
 net/core/dev.c            | 22 ++++++++++------------
 2 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7ed3a3a..20e99ef 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3180,12 +3180,7 @@ void netdev_change_features(struct net_device *dev);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 					struct net_device *dev);
 
-netdev_features_t netif_skb_dev_features(struct sk_buff *skb,
-					 const struct net_device *dev);
-static inline netdev_features_t netif_skb_features(struct sk_buff *skb)
-{
-	return netif_skb_dev_features(skb, skb->dev);
-}
+netdev_features_t netif_skb_features(struct sk_buff *skb);
 
 static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index d2c8a06..c619b86 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2418,7 +2418,7 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
  * 2. No high memory really exists on this machine.
  */
 
-static int illegal_highdma(const struct net_device *dev, struct sk_buff *skb)
+static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
 #ifdef CONFIG_HIGHMEM
 	int i;
@@ -2493,38 +2493,36 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 }
 
 static netdev_features_t harmonize_features(struct sk_buff *skb,
-					    const struct net_device *dev,
-					    netdev_features_t features)
+	netdev_features_t features)
 {
 	int tmp;
 
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, skb_network_protocol(skb, &tmp))) {
 		features &= ~NETIF_F_ALL_CSUM;
-	} else if (illegal_highdma(dev, skb)) {
+	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
 	}
 
 	return features;
 }
 
-netdev_features_t netif_skb_dev_features(struct sk_buff *skb,
-					 const struct net_device *dev)
+netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol = skb->protocol;
-	netdev_features_t features = dev->features;
+	netdev_features_t features = skb->dev->features;
 
-	if (skb_shinfo(skb)->gso_segs > dev->gso_max_segs)
+	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
 		features &= ~NETIF_F_GSO_MASK;
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD)) {
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
 	} else if (!vlan_tx_tag_present(skb)) {
-		return harmonize_features(skb, dev, features);
+		return harmonize_features(skb, features);
 	}
 
-	features &= (dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
+	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
 					       NETIF_F_HW_VLAN_STAG_TX);
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
@@ -2532,9 +2530,9 @@ netdev_features_t netif_skb_dev_features(struct sk_buff *skb,
 				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_STAG_TX;
 
-	return harmonize_features(skb, dev, features);
+	return harmonize_features(skb, features);
 }
-EXPORT_SYMBOL(netif_skb_dev_features);
+EXPORT_SYMBOL(netif_skb_features);
 
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq)
-- 
1.8.1.5
