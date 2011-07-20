From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 31/47] atl1: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:33 +0200
Message-ID: <1311173689-17419-32-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61038 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab1GTOzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:55 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atlx_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atlx/atl1.c |   21 +++++++++--------
 drivers/net/atlx/atl1.h |    1 -
 drivers/net/atlx/atlx.c |   57 +++++++++++++++++++++++++++++++++--------------
 3 files changed, 51 insertions(+), 28 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index cd5789f..6f0e940 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1285,8 +1285,7 @@ static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
 	value |= (((u32) adapter->hw.preamble_len
 		   & MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);
 	/* vlan */
-	if (adapter->vlgrp)
-		value |= MAC_CTRL_RMV_VLAN;
+	__atlx_vlan_mode(netdev->features, &value);
 	/* rx checksum
 	   if (adapter->rx_csum)
 	   value |= MAC_CTRL_RX_CHKSUM_EN;
@@ -2023,13 +2022,14 @@ rrd_ok:
 		atl1_rx_checksum(adapter, rrd, skb);
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 
-		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
+		if (rrd->pkt_flg & PACKET_FLAG_VLAN_INS) {
 			u16 vlan_tag = (rrd->vlan_tag >> 4) |
 					((rrd->vlan_tag & 7) << 13) |
 					((rrd->vlan_tag & 8) << 9);
-			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
-		} else
-			netif_rx(skb);
+
+			__vlan_hwaccel_put_tag(skb, vlan_tag);
+		}
+		netif_rx(skb);
 
 		/* let protocol layer free skb */
 		buffer_info->skb = NULL;
@@ -2783,8 +2783,7 @@ static int atl1_suspend(struct device *dev)
 			ctrl |= MAC_CTRL_DUPLX;
 		ctrl |= (((u32)adapter->hw.preamble_len &
 			MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);
-		if (adapter->vlgrp)
-			ctrl |= MAC_CTRL_RMV_VLAN;
+		__atlx_vlan_mode(netdev->features, &ctrl);
 		if (wufc & ATLX_WUFC_MAG)
 			ctrl |= MAC_CTRL_BC_EN;
 		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
@@ -2874,9 +2873,10 @@ static const struct net_device_ops atl1_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl1_set_mac,
 	.ndo_change_mtu		= atl1_change_mtu,
+	.ndo_fix_features	= atlx_fix_features,
+	.ndo_set_features	= atlx_set_features,
 	.ndo_do_ioctl		= atlx_ioctl,
 	.ndo_tx_timeout		= atlx_tx_timeout,
-	.ndo_vlan_rx_register	= atlx_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1_poll_controller,
 #endif
@@ -2984,7 +2984,8 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_SG;
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 
-	netdev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_TSO;
+	netdev->hw_features = NETIF_F_HW_CSUM | NETIF_F_SG | NETIF_F_TSO |
+			      NETIF_F_HW_VLAN_RX;
 
 	/* is this valid? see atl1_setup_mac_ctrl() */
 	netdev->features |= NETIF_F_RXCSUM;
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 68de8cb..109d6da 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -753,7 +753,6 @@ struct atl1_adapter {
 	struct pci_dev *pdev;
 
 	struct atl1_sft_stats soft_stats;
-	struct vlan_group *vlgrp;
 	u32 rx_buffer_len;
 	u32 wol;
 	u16 link_speed;
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
index afb7f7d..aabcf4b 100644
--- a/drivers/net/atlx/atlx.c
+++ b/drivers/net/atlx/atlx.c
@@ -211,8 +211,18 @@ static void atlx_link_chg_task(struct work_struct *work)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-static void atlx_vlan_rx_register(struct net_device *netdev,
-	struct vlan_group *grp)
+static void __atlx_vlan_mode(u32 features, u32 *ctrl)
+{
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		*ctrl |= MAC_CTRL_RMV_VLAN;
+	} else {
+		/* disable VLAN tag insert/strip */
+		*ctrl &= ~MAC_CTRL_RMV_VLAN;
+	}
+}
+
+static void atlx_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct atlx_adapter *adapter = netdev_priv(netdev);
 	unsigned long flags;
@@ -220,27 +230,40 @@ static void atlx_vlan_rx_register(struct net_device *netdev,
 
 	spin_lock_irqsave(&adapter->lock, flags);
 	/* atlx_irq_disable(adapter); FIXME: confirm/remove */
-	adapter->vlgrp = grp;
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl |= MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	}
-
+	ctrl = ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+	__atlx_vlan_mode(features, &ctrl);
+	iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
 	/* atlx_irq_enable(adapter); FIXME */
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
 static void atlx_restore_vlan(struct atlx_adapter *adapter)
 {
-	atlx_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	atlx_vlan_mode(adapter->netdev, adapter->netdev->features);
+}
+
+static u32 atlx_fix_features(struct net_device *netdev, u32 features)
+{
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure tx flag is always in same state as rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_RX)
+		features |= NETIF_F_HW_VLAN_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_TX;
+
+	return features;
+}
+
+static int atlx_set_features(struct net_device *netdev, u32 features)
+{
+	u32 changed = netdev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		atlx_vlan_mode(netdev, features);
+
+	return 0;
 }
 
 #endif /* ATLX_C */
-- 
1.7.6

