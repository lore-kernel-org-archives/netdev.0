From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 10/47] atl1c: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:12 +0200
Message-ID: <1311173689-17419-11-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab1GTOzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:12 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atl1c_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atl1c/atl1c.h      |    1 -
 drivers/net/atl1c/atl1c_main.c |   74 +++++++++++++++++++++++++---------------
 2 files changed, 46 insertions(+), 29 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 0f481b9..ca70e16 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -555,7 +555,6 @@ struct atl1c_smb {
 struct atl1c_adapter {
 	struct net_device   *netdev;
 	struct pci_dev      *pdev;
-	struct vlan_group   *vlgrp;
 	struct napi_struct  napi;
 	struct atl1c_hw        hw;
 	struct atl1c_hw_stats  hw_stats;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 1269ba5..9722442 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -411,29 +411,29 @@ static void atl1c_set_multi(struct net_device *netdev)
 	}
 }
 
-static void atl1c_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+static void __atl1c_vlan_mode(u32 features, u32 *mac_ctrl_data)
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
+static void atl1c_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
 	u32 mac_ctrl_data = 0;
 
 	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_vlan_rx_register\n");
+		dev_dbg(&pdev->dev, "atl1c_vlan_mode\n");
 
 	atl1c_irq_disable(adapter);
-
-	adapter->vlgrp = grp;
 	AT_READ_REG(&adapter->hw, REG_MAC_CTRL, &mac_ctrl_data);
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
-	} else {
-		/* disable VLAN tag insert/strip */
-		mac_ctrl_data &= ~MAC_CTRL_RMV_VLAN;
-	}
-
+	__atl1c_vlan_mode(features, &mac_ctrl_data);
 	AT_WRITE_REG(&adapter->hw, REG_MAC_CTRL, mac_ctrl_data);
 	atl1c_irq_enable(adapter);
 }
@@ -443,9 +443,10 @@ static void atl1c_restore_vlan(struct atl1c_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 
 	if (netif_msg_pktdata(adapter))
-		dev_dbg(&pdev->dev, "atl1c_restore_vlan !");
-	atl1c_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+		dev_dbg(&pdev->dev, "atl1c_restore_vlan\n");
+	atl1c_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
+
 /*
  * atl1c_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -483,12 +484,31 @@ static void atl1c_set_rxbufsize(struct atl1c_adapter *adapter,
 
 static u32 atl1c_fix_features(struct net_device *netdev, u32 features)
 {
+	/*
+	 * Since there is no support for separate rx/tx vlan accel
+	 * enable/disable make sure tx flag is always in same state as rx.
+	 */
+	if (features & NETIF_F_HW_VLAN_RX)
+		features |= NETIF_F_HW_VLAN_TX;
+	else
+		features &= ~NETIF_F_HW_VLAN_TX;
+
 	if (netdev->mtu > MAX_TSO_FRAME_SIZE)
 		features &= ~(NETIF_F_TSO | NETIF_F_TSO6);
 
 	return features;
 }
 
+static int atl1c_set_features(struct net_device *netdev, u32 features)
+{
+	u32 changed = netdev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		atl1c_vlan_mode(netdev, features);
+
+	return 0;
+}
+
 /*
  * atl1c_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -1433,8 +1453,7 @@ static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter)
 	mac_ctrl_data |= ((hw->preamble_len & MAC_CTRL_PRMLEN_MASK) <<
 			MAC_CTRL_PRMLEN_SHIFT);
 
-	if (adapter->vlgrp)
-		mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+	__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
 
 	mac_ctrl_data |= MAC_CTRL_BC_EN;
 	if (netdev->flags & IFF_PROMISC)
@@ -1878,14 +1897,14 @@ rrs_checked:
 		skb_put(skb, length - ETH_FCS_LEN);
 		skb->protocol = eth_type_trans(skb, netdev);
 		atl1c_rx_checksum(adapter, skb, rrs);
-		if (unlikely(adapter->vlgrp) && rrs->word3 & RRS_VLAN_INS) {
+		if (rrs->word3 & RRS_VLAN_INS) {
 			u16 vlan;
 
 			AT_TAG_TO_VLAN(rrs->vlan_tag, vlan);
 			vlan = le16_to_cpu(vlan);
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vlan);
-		} else
-			netif_receive_skb(skb);
+			__vlan_hwaccel_put_tag(skb, vlan);
+		}
+		netif_receive_skb(skb);
 
 		(*work_done)++;
 		count++;
@@ -2507,8 +2526,7 @@ static int atl1c_suspend(struct device *dev)
 		/* clear phy interrupt */
 		atl1c_read_phy_reg(hw, MII_ISR, &mii_intr_status_data);
 		/* Config MAC Ctrl register */
-		if (adapter->vlgrp)
-			mac_ctrl_data |= MAC_CTRL_RMV_VLAN;
+		__atl1c_vlan_mode(netdev->features, &mac_ctrl_data);
 
 		/* magic packet maybe Broadcast&multicast&Unicast frame */
 		if (wufc & AT_WUFC_MAG)
@@ -2581,14 +2599,14 @@ static const struct net_device_ops atl1c_netdev_ops = {
 	.ndo_stop		= atl1c_close,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_start_xmit		= atl1c_xmit_frame,
-	.ndo_set_mac_address 	= atl1c_set_mac_addr,
+	.ndo_set_mac_address	= atl1c_set_mac_addr,
 	.ndo_set_multicast_list = atl1c_set_multi,
 	.ndo_change_mtu		= atl1c_change_mtu,
 	.ndo_fix_features	= atl1c_fix_features,
+	.ndo_set_features	= atl1c_set_features,
 	.ndo_do_ioctl		= atl1c_ioctl,
 	.ndo_tx_timeout		= atl1c_tx_timeout,
 	.ndo_get_stats		= atl1c_get_stats,
-	.ndo_vlan_rx_register	= atl1c_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl1c_netpoll,
 #endif
@@ -2607,11 +2625,11 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	/* TODO: add when ready */
 	netdev->hw_features =	NETIF_F_SG	   |
 				NETIF_F_HW_CSUM	   |
-				NETIF_F_HW_VLAN_TX |
+				NETIF_F_HW_VLAN_RX |
 				NETIF_F_TSO	   |
 				NETIF_F_TSO6;
 	netdev->features =	netdev->hw_features |
-				NETIF_F_HW_VLAN_RX;
+				NETIF_F_HW_VLAN_TX;
 	return 0;
 }
 
-- 
1.7.6

