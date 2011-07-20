From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 32/47] atl2: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:34 +0200
Message-ID: <1311173689-17419-33-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jcliburn@gmail.com, chris.snook@gmail.com, jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543Ab1GTOz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:57 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and atl2_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/atlx/atl2.c |   78 +++++++++++++++++++++++++++++------------------
 drivers/net/atlx/atl2.h |    3 --
 2 files changed, 48 insertions(+), 33 deletions(-)

diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 24e1592..e0f87cf 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -361,36 +361,59 @@ static inline void atl2_irq_disable(struct atl2_adapter *adapter)
     synchronize_irq(adapter->pdev->irq);
 }
 
-#ifdef NETIF_F_HW_VLAN_TX
-static void atl2_vlan_rx_register(struct net_device *netdev,
-	struct vlan_group *grp)
+static void __atl2_vlan_mode(u32 features, u32 *ctrl)
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
+static void atl2_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
 
 	atl2_irq_disable(adapter);
-	adapter->vlgrp = grp;
 
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = ATL2_READ_REG(&adapter->hw, REG_MAC_CTRL);
-		ctrl |= MAC_CTRL_RMV_VLAN;
-		ATL2_WRITE_REG(&adapter->hw, REG_MAC_CTRL, ctrl);
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = ATL2_READ_REG(&adapter->hw, REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_RMV_VLAN;
-		ATL2_WRITE_REG(&adapter->hw, REG_MAC_CTRL, ctrl);
-	}
+	ctrl = ATL2_READ_REG(&adapter->hw, REG_MAC_CTRL);
+	__atl2_vlan_mode(features, &ctrl);
+	ATL2_WRITE_REG(&adapter->hw, REG_MAC_CTRL, ctrl);
 
 	atl2_irq_enable(adapter);
 }
 
 static void atl2_restore_vlan(struct atl2_adapter *adapter)
 {
-	atl2_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	atl2_vlan_mode(adapter->netdev, adapter->netdev->features);
+}
+
+static u32 atl2_fix_features(struct net_device *netdev, u32 features)
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
+static int atl2_set_features(struct net_device *netdev, u32 features)
+{
+	u32 changed = netdev->features ^ features;
+
+	if (changed & NETIF_F_HW_VLAN_RX)
+		atl2_vlan_mode(netdev, features);
+
+	return 0;
 }
-#endif
 
 static void atl2_intr_rx(struct atl2_adapter *adapter)
 {
@@ -424,14 +447,13 @@ static void atl2_intr_rx(struct atl2_adapter *adapter)
 			memcpy(skb->data, rxd->packet, rx_size);
 			skb_put(skb, rx_size);
 			skb->protocol = eth_type_trans(skb, netdev);
-#ifdef NETIF_F_HW_VLAN_TX
-			if (adapter->vlgrp && (rxd->status.vlan)) {
+			if (rxd->status.vlan) {
 				u16 vlan_tag = (rxd->status.vtag>>4) |
 					((rxd->status.vtag&7) << 13) |
 					((rxd->status.vtag&8) << 9);
-				vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
-			} else
-#endif
+
+				__vlan_hwaccel_put_tag(skb, vlan_tag);
+			}
 			netif_rx(skb);
 			netdev->stats.rx_bytes += rx_size;
 			netdev->stats.rx_packets++;
@@ -704,9 +726,7 @@ static int atl2_open(struct net_device *netdev)
 	atl2_set_multi(netdev);
 	init_ring_ptrs(adapter);
 
-#ifdef NETIF_F_HW_VLAN_TX
 	atl2_restore_vlan(adapter);
-#endif
 
 	if (atl2_configure(adapter)) {
 		err = -EIO;
@@ -1082,9 +1102,7 @@ static int atl2_up(struct atl2_adapter *adapter)
 	atl2_set_multi(netdev);
 	init_ring_ptrs(adapter);
 
-#ifdef NETIF_F_HW_VLAN_TX
 	atl2_restore_vlan(adapter);
-#endif
 
 	if (atl2_configure(adapter)) {
 		err = -EIO;
@@ -1145,8 +1163,7 @@ static void atl2_setup_mac_ctrl(struct atl2_adapter *adapter)
 		MAC_CTRL_PRMLEN_SHIFT);
 
 	/* vlan */
-	if (adapter->vlgrp)
-		value |= MAC_CTRL_RMV_VLAN;
+	__atl2_vlan_mode(netdev->features, &value);
 
 	/* filter mode */
 	value |= MAC_CTRL_BC_EN;
@@ -1312,9 +1329,10 @@ static const struct net_device_ops atl2_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= atl2_set_mac,
 	.ndo_change_mtu		= atl2_change_mtu,
+	.ndo_fix_features	= atl2_fix_features,
+	.ndo_set_features	= atl2_set_features,
 	.ndo_do_ioctl		= atl2_ioctl,
 	.ndo_tx_timeout		= atl2_tx_timeout,
-	.ndo_vlan_rx_register	= atl2_vlan_rx_register,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= atl2_poll_controller,
 #endif
@@ -1410,7 +1428,7 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 
 	err = -EIO;
 
-	netdev->hw_features = NETIF_F_SG;
+	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_VLAN_RX;
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 
 	/* Init PHY as early as possible due to power saving issue  */
diff --git a/drivers/net/atlx/atl2.h b/drivers/net/atlx/atl2.h
index 927e4de..78344dd 100644
--- a/drivers/net/atlx/atl2.h
+++ b/drivers/net/atlx/atl2.h
@@ -453,9 +453,6 @@ struct atl2_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-#ifdef NETIF_F_HW_VLAN_TX
-	struct vlan_group *vlgrp;
-#endif
 	u32 wol;
 	u16 link_speed;
 	u16 link_duplex;
-- 
1.7.6

