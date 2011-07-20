From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 36/47] forcedeth: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:38 +0200
Message-ID: <1311173689-17419-37-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270Ab1GTO4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:03 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill np->vlangrp and nv_vlan_rx_register
- allow to turn on/off rx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/forcedeth.c |   68 ++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 38 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 537b695..e64cd9c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -820,9 +820,6 @@ struct fe_priv {
 	struct nv_skb_map *tx_end_flip;
 	int tx_stop;
 
-	/* vlan fields */
-	struct vlan_group *vlangrp;
-
 	/* msi/msi-x fields */
 	u32 msi_flags;
 	struct msix_entry msi_x_entry[NV_MSI_X_MAX_VECTORS];
@@ -2766,17 +2763,13 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 			skb->protocol = eth_type_trans(skb, dev);
 			prefetch(skb->data);
 
-			if (likely(!np->vlangrp)) {
-				napi_gro_receive(&np->napi, skb);
-			} else {
-				vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-				if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
-					vlan_gro_receive(&np->napi, np->vlangrp,
-							 vlanflags & NV_RX3_VLAN_TAG_MASK, skb);
-				} else {
-					napi_gro_receive(&np->napi, skb);
-				}
+			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
+			if (vlanflags & NV_RX3_VLAN_TAG_PRESENT) {
+				u16 vid = vlanflags & NV_RX3_VLAN_TAG_MASK;
+
+				__vlan_hwaccel_put_tag(skb, vid);
 			}
+			napi_gro_receive(&np->napi, skb);
 
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
@@ -4484,6 +4477,27 @@ static u32 nv_fix_features(struct net_device *dev, u32 features)
 	return features;
 }
 
+static void nv_vlan_mode(struct net_device *dev, u32 features)
+{
+	struct fe_priv *np = get_nvpriv(dev);
+
+	spin_lock_irq(&np->lock);
+
+	if (features & NETIF_F_HW_VLAN_RX)
+		np->txrxctl_bits |= NVREG_TXRXCTL_VLANSTRIP;
+	else
+		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANSTRIP;
+
+	if (features & NETIF_F_HW_VLAN_TX)
+		np->txrxctl_bits |= NVREG_TXRXCTL_VLANINS;
+	else
+		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANINS;
+
+	writel(np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+
+	spin_unlock_irq(&np->lock);
+}
+
 static int nv_set_features(struct net_device *dev, u32 features)
 {
 	struct fe_priv *np = netdev_priv(dev);
@@ -4504,6 +4518,9 @@ static int nv_set_features(struct net_device *dev, u32 features)
 		spin_unlock_irq(&np->lock);
 	}
 
+	if (changed & (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX))
+		nv_vlan_mode(dev, features);
+
 	return 0;
 }
 
@@ -4879,29 +4896,6 @@ static const struct ethtool_ops ops = {
 	.self_test = nv_self_test,
 };
 
-static void nv_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct fe_priv *np = get_nvpriv(dev);
-
-	spin_lock_irq(&np->lock);
-
-	/* save vlan group */
-	np->vlangrp = grp;
-
-	if (grp) {
-		/* enable vlan on MAC */
-		np->txrxctl_bits |= NVREG_TXRXCTL_VLANSTRIP | NVREG_TXRXCTL_VLANINS;
-	} else {
-		/* disable vlan on MAC */
-		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANSTRIP;
-		np->txrxctl_bits &= ~NVREG_TXRXCTL_VLANINS;
-	}
-
-	writel(np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-
-	spin_unlock_irq(&np->lock);
-}
-
 /* The mgmt unit and driver use a semaphore to access the phy during init */
 static int nv_mgmt_acquire_sema(struct net_device *dev)
 {
@@ -5208,7 +5202,6 @@ static const struct net_device_ops nv_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_multicast_list	= nv_set_multicast,
-	.ndo_vlan_rx_register	= nv_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
@@ -5226,7 +5219,6 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= nv_set_mac_address,
 	.ndo_set_multicast_list	= nv_set_multicast,
-	.ndo_vlan_rx_register	= nv_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= nv_poll_controller,
 #endif
-- 
1.7.6

