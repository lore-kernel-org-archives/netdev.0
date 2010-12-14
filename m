From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] ixgb: Convert to new vlan model.
Date: Mon, 13 Dec 2010 19:42:43 -0800
Message-ID: <1292298163-30343-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:37848 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab0LNDmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 22:42:51 -0500
Received: by qwa26 with SMTP id 26so276232qwa.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 19:42:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches the ixgb driver to use the new vlan interfaces.
In doing this, it completes the work begun in
ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
hardware vlan insertion without having a vlan group configured.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Emil Tantilov <emil.s.tantilov@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Alex Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ixgb/ixgb.h         |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c |   41 +++++++++++++++++++++++++++++
 drivers/net/ixgb/ixgb_main.c    |   54 ++++++++------------------------------
 3 files changed, 54 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 521c0c7..8f3df04 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -149,7 +149,7 @@ struct ixgb_desc_ring {
 
 struct ixgb_adapter {
 	struct timer_list watchdog_timer;
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u32 bd_number;
 	u32 rx_buffer_len;
 	u32 part_num;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 43994c1..0e4c527 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -706,6 +706,45 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static int ixgb_set_flags(struct net_device *netdev, u32 data)
+{
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
+	bool need_reset;
+	int rc;
+
+	/* The hardware requires that RX vlan stripping and TX vlan insertion
+	 * be configured together.  Therefore, if one setting changes adjust the
+	 * other one to match.
+	 */
+	if (!!(data & ETH_FLAG_RXVLAN) != !!(data & ETH_FLAG_TXVLAN)) {
+		if ((data & ETH_FLAG_RXVLAN) !=
+		    (netdev->features & NETIF_F_HW_VLAN_RX))
+			data ^= ETH_FLAG_TXVLAN;
+		else if ((data & ETH_FLAG_TXVLAN) !=
+		    (netdev->features & NETIF_F_HW_VLAN_TX))
+			data ^= ETH_FLAG_RXVLAN;
+	}
+
+	need_reset = (data & ETH_FLAG_RXVLAN) !=
+		     (netdev->features & NETIF_F_HW_VLAN_RX);
+
+	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
+						ETH_FLAG_TXVLAN);
+	if (rc)
+		return rc;
+
+	if (need_reset) {
+		if (netif_running(netdev)) {
+			ixgb_down(adapter, true);
+			ixgb_up(adapter);
+			ixgb_set_speed_duplex(netdev);
+		} else
+			ixgb_reset(adapter);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgb_ethtool_ops = {
 	.get_settings = ixgb_get_settings,
 	.set_settings = ixgb_set_settings,
@@ -732,6 +771,8 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.phys_id = ixgb_phys_id,
 	.get_sset_count = ixgb_get_sset_count,
 	.get_ethtool_stats = ixgb_get_ethtool_stats,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ixgb_set_flags,
 };
 
 void ixgb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index b021798..053ae02 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -100,8 +100,6 @@ static void ixgb_tx_timeout_task(struct work_struct *work);
 
 static void ixgb_vlan_strip_enable(struct ixgb_adapter *adapter);
 static void ixgb_vlan_strip_disable(struct ixgb_adapter *adapter);
-static void ixgb_vlan_rx_register(struct net_device *netdev,
-                                  struct vlan_group *grp);
 static void ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
@@ -336,7 +334,6 @@ static const struct net_device_ops ixgb_netdev_ops = {
 	.ndo_set_mac_address	= ixgb_set_mac,
 	.ndo_change_mtu		= ixgb_change_mtu,
 	.ndo_tx_timeout		= ixgb_tx_timeout,
-	.ndo_vlan_rx_register	= ixgb_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgb_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgb_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1508,7 +1505,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
                      DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGB_TX_FLAGS_VLAN;
 		vlan_id = vlan_tx_tag_get(skb);
 	}
@@ -2049,12 +2046,11 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 		ixgb_rx_checksum(adapter, rx_desc, skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
-		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-			                        le16_to_cpu(rx_desc->special));
-		} else {
-			netif_receive_skb(skb);
-		}
+		if (status & IXGB_RX_DESC_STATUS_VP)
+			__vlan_hwaccel_put_tag(skb,
+					       le16_to_cpu(rx_desc->special));
+
+		netif_receive_skb(skb);
 
 rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
@@ -2152,20 +2148,6 @@ map_skb:
 	}
 }
 
-/**
- * ixgb_vlan_rx_register - enables or disables vlan tagging/stripping.
- *
- * @param netdev network interface device structure
- * @param grp indicates to enable or disable tagging/stripping
- **/
-static void
-ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
-{
-	struct ixgb_adapter *adapter = netdev_priv(netdev);
-
-	adapter->vlgrp = grp;
-}
-
 static void
 ixgb_vlan_strip_enable(struct ixgb_adapter *adapter)
 {
@@ -2200,6 +2182,7 @@ ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	vfta = IXGB_READ_REG_ARRAY(&adapter->hw, VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
 	ixgb_write_vfta(&adapter->hw, index, vfta);
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void
@@ -2208,35 +2191,22 @@ ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	u32 vfta, index;
 
-	ixgb_irq_disable(adapter);
-
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-
-	/* don't enable interrupts unless we are UP */
-	if (adapter->netdev->flags & IFF_UP)
-		ixgb_irq_enable(adapter);
-
 	/* remove VID from filter table */
 
 	index = (vid >> 5) & 0x7F;
 	vfta = IXGB_READ_REG_ARRAY(&adapter->hw, VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
 	ixgb_write_vfta(&adapter->hw, index, vfta);
+	clear_bit(vid, adapter->active_vlans);
 }
 
 static void
 ixgb_restore_vlan(struct ixgb_adapter *adapter)
 {
-	ixgb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	u16 vid;
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		ixgb_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.1

