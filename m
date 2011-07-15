From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 12/21] igbvf: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:30 +0200
Message-ID: <1310765619-27827-13-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094Ab1GOVeK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:10 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and igbvf_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/igbvf/igbvf.h  |    4 +-
 drivers/net/igbvf/netdev.c |   51 +++++++++++++++++++------------------------
 2 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index d5dad5d..fd4a7b7 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -34,7 +34,7 @@
 #include <linux/timer.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
-
+#include <linux/if_vlan.h>
 
 #include "vf.h"
 
@@ -173,7 +173,7 @@ struct igbvf_adapter {
 
 	const struct igbvf_info *ei;
 
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u32 bd_number;
 	u32 rx_buffer_len;
 	u32 polling_interval;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 64b47bf..bf3f585 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -100,12 +100,12 @@ static void igbvf_receive_skb(struct igbvf_adapter *adapter,
                               struct sk_buff *skb,
                               u32 status, u16 vlan)
 {
-	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-		                         le16_to_cpu(vlan) &
-		                         E1000_RXD_SPC_VLAN_MASK);
-	else
-		netif_receive_skb(skb);
+	if (status & E1000_RXD_STAT_VP) {
+		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
+
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+	netif_receive_skb(skb);
 }
 
 static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
@@ -1170,19 +1170,28 @@ static void igbvf_set_rlpml(struct igbvf_adapter *adapter)
 	int max_frame_size = adapter->max_frame_size;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (adapter->vlgrp)
+	if (adapter->netdev->features & NETIF_F_HW_VLAN_RX)
 		max_frame_size += VLAN_TAG_SIZE;
 
 	e1000_rlpml_set_vf(hw, max_frame_size);
 }
 
-static void igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static bool __igbvf_vlan_rx_add_vid(struct igbvf_adapter *adapter, u16 vid)
 {
-	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (hw->mac.ops.set_vfta(hw, vid, true))
 		dev_err(&adapter->pdev->dev, "Failed to add vlan id %d\n", vid);
+		return false;
+	return true;
+}
+
+static void igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (__igbvf_vlan_rx_add_vid(adapter, vid))
+		set_bit(vid, adapter->active_vlans);
 }
 
 static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -1191,7 +1200,6 @@ static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 
 	igbvf_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
 	if (!test_bit(__IGBVF_DOWN, &adapter->state))
 		igbvf_irq_enable(adapter);
@@ -1199,28 +1207,16 @@ static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	if (hw->mac.ops.set_vfta(hw, vid, false))
 		dev_err(&adapter->pdev->dev,
 		        "Failed to remove vlan id %d\n", vid);
-}
-
-static void igbvf_vlan_rx_register(struct net_device *netdev,
-                                   struct vlan_group *grp)
-{
-	struct igbvf_adapter *adapter = netdev_priv(netdev);
-
-	adapter->vlgrp = grp;
+	else
+		clear_bit(vid, adapter->active_vlans);
 }
 
 static void igbvf_restore_vlan(struct igbvf_adapter *adapter)
 {
 	u16 vid;
 
-	if (!adapter->vlgrp)
-		return;
-
-	for (vid = 0; vid < VLAN_N_VID; vid++) {
-		if (!vlan_group_get_device(adapter->vlgrp, vid))
-			continue;
-		igbvf_vlan_rx_add_vid(adapter->netdev, vid);
-	}
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		__igbvf_vlan_rx_add_vid(adapter, vid);
 
 	igbvf_set_rlpml(adapter);
 }
@@ -2203,7 +2199,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGBVF_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IGBVF_TX_FLAGS_VLAN_SHIFT);
 	}
@@ -2556,7 +2552,6 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_change_mtu                 = igbvf_change_mtu,
 	.ndo_do_ioctl                   = igbvf_ioctl,
 	.ndo_tx_timeout                 = igbvf_tx_timeout,
-	.ndo_vlan_rx_register           = igbvf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid            = igbvf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid           = igbvf_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.6

