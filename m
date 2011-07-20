From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 11/47] atl1e: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:13 +0200
Message-ID: <1311173689-17419-12-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747Ab1GTOzO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:14 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atl1e_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atl1e/atl1e.h      |    1 -
 drivers/net/atl1e/atl1e_main.c |   79 +++++++++++++++++++++++++---------------
 2 files changed, 50 insertions(+), 30 deletions(-)

diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index 8c8181b..829b5ad 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -433,7 +433,6 @@ struct atl1e_rx_ring {
 struct atl1e_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
-	struct vlan_group   *vlgrp;
 	struct napi_struct  napi;
 	struct mii_if_info  mii;    /* MII interface info */
 	struct atl1e_hw        hw;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index c3c5db1..d8d4119 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -313,8 +313,18 @@ static void atl1e_set_multi(struct net_device *netdev)
 	}
 }
 
-static void atl1e_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+static void __atl1e_vlan_mode(u32 features, u32 *mac_ctrl_data)
+{
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		*mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+	} else {
+		/* disable VLAN tag insert/strip */
+		*mac_ctrl_data &= ~MAC_CTRL_RMV_VLAN;
+	}
+}
+
+static void atl1e_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	u32 mac_ctrl_data = 0;
@@ -322,18 +332,8 @@ static void atl1e_vlan_rx_register(struct net_device *netdev,
 	netdev_dbg(adapter->netdev, "%s\n", __func__);
 
 	atl1e_irq_disable(adapter);
-
-	adapter->vlgrp = grp;
 	mac_ctrl_data = AT_READ_REG(&adapter->hw, REG_MAC_CTRL);
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
-	} else {
-		/* disable VLAN tag insert/strip */
-		mac_ctrl_data &= ~MAC_CTRL_RMV_VLAN;
-	}
-
+	__atl1e_vlan_mode(features, &mac_ctrl_data);
 	AT_WRITE_REG(&adapter->hw, REG_MAC_CTRL, mac_ctrl_data);
 	atl1e_irq_enable(adapter);
 }
@@ -341,8 +341,9 @@ static void atl1e_vlan_rx_register(struct net_device *netdev,
 static void atl1e_restore_vlan(struct atl1e_adapter *adapter)
 {
 	netdev_dbg(adapter->netdev, "%s\n", __func__);
-	atl1e_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	atl1e_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
+
 /*
  * atl1e_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -369,6 +370,30 @@ static int atl1e_set_mac_addr(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static u32 atl1e_fix_features(struct net_device *netdev, u32 features)
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
+static int atl1e_set_features(struct net_device *netdev, u32 features)
+{
+	u32 changed = netdev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		atl1e_vlan_mode(netdev, features);
+
+	return 0;
+}
+
 /*
  * atl1e_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -1039,8 +1064,7 @@ static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 	value |= (((u32)adapter->hw.preamble_len &
 		  MAC_CTRL_PRMLEN_MASK) << MAC_CTRL_PRMLEN_SHIFT);
 
-	if (adapter->vlgrp)
-		value |= MAC_CTRL_RMV_VLAN;
+	__atl1e_vlan_mode(netdev->features, &value);
 
 	value |= MAC_CTRL_BC_EN;
 	if (netdev->flags & IFF_PROMISC)
@@ -1423,19 +1447,16 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 			skb->protocol = eth_type_trans(skb, netdev);
 			atl1e_rx_checksum(adapter, skb, prrs);
 
-			if (unlikely(adapter->vlgrp &&
-				(prrs->pkt_flag & RRS_IS_VLAN_TAG))) {
+			if (prrs->pkt_flag & RRS_IS_VLAN_TAG) {
 				u16 vlan_tag = (prrs->vtag >> 4) |
 					       ((prrs->vtag & 7) << 13) |
 					       ((prrs->vtag & 8) << 9);
 				netdev_dbg(netdev,
 					   "RXD VLAN TAG<RRD>=0x%04x\n",
 					   prrs->vtag);
-				vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-							 vlan_tag);
-			} else {
-				netif_receive_skb(skb);
+				__vlan_hwaccel_put_tag(skb, vlan_tag);
 			}
+			netif_receive_skb(skb);
 
 skip_pkt:
 	/* skip current packet whether it's ok or not. */
@@ -1811,7 +1832,7 @@ static netdev_tx_t atl1e_xmit_frame(struct sk_buff *skb,
 
 	tpd = atl1e_get_tpd(adapter);
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
+	if (vlan_tx_tag_present(skb)) {
 		u16 vlan_tag = vlan_tx_tag_get(skb);
 		u16 atl1e_vlan_tag;
 
@@ -2093,8 +2114,7 @@ static int atl1e_suspend(struct pci_dev *pdev, pm_message_t state)
 				 MAC_CTRL_PRMLEN_MASK) <<
 				 MAC_CTRL_PRMLEN_SHIFT);
 
-		if (adapter->vlgrp)
-			mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+		__atl1e_vlan_mode(netdev->features, &mac_ctrl_data);
 
 		/* magic packet maybe Broadcast&multicast&Unicast frame */
 		if (wufc & AT_WUFC_MAG)
@@ -2195,10 +2215,11 @@ static const struct net_device_ops atl1e_netdev_ops = {
 	.ndo_set_multicast_list	= atl1e_set_multi,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl1e_set_mac_addr,
+	.ndo_fix_features	= atl1e_fix_features,
+	.ndo_set_features	= atl1e_set_features,
 	.ndo_change_mtu		= atl1e_change_mtu,
 	.ndo_do_ioctl		= atl1e_ioctl,
 	.ndo_tx_timeout		= atl1e_tx_timeout,
-	.ndo_vlan_rx_register	= atl1e_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1e_netpoll,
 #endif
@@ -2217,9 +2238,9 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	atl1e_set_ethtool_ops(netdev);
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX;
-	netdev->features = netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_LLTX;
+			      NETIF_F_HW_VLAN_RX;
+	netdev->features = netdev->hw_features | NETIF_F_LLTX |
+			   NETIF_F_HW_VLAN_TX;
 
 	return 0;
 }
-- 
1.7.6

