From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/24] e1000e: convert to new VLAN model
Date: Wed, 13 Apr 2011 18:02:03 -0700
Message-ID: <1302742940-22141-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jesse Gross <jesse@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11318 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758043Ab1DNBCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:31 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches the e1000e driver to use the new VLAN interfaces.

CC: Jesse Gross <jesse@nicira.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
---
 drivers/net/e1000e/e1000.h   |    4 +-
 drivers/net/e1000e/ethtool.c |   26 +++++++
 drivers/net/e1000e/netdev.c  |  170 ++++++++++++++++++++++--------------------
 3 files changed, 119 insertions(+), 81 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 00bf595..500896e 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -31,6 +31,7 @@
 #ifndef _E1000_H_
 #define _E1000_H_
 
+#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
@@ -39,6 +40,7 @@
 #include <linux/pci.h>
 #include <linux/pci-aspm.h>
 #include <linux/crc32.h>
+#include <linux/if_vlan.h>
 
 #include "hw.h"
 
@@ -280,7 +282,7 @@ struct e1000_adapter {
 
 	const struct e1000_info *ei;
 
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u32 bd_number;
 	u32 rx_buffer_len;
 	u16 mng_vlan_id;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 5b4cf90..a31d280 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -2020,6 +2020,31 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 	}
 }
 
+static int e1000e_set_flags(struct net_device *netdev, u32 data)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	bool need_reset = false;
+	int rc;
+
+	need_reset = (data & ETH_FLAG_RXVLAN) !=
+		     (netdev->features & NETIF_F_HW_VLAN_RX);
+
+	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
+				  ETH_FLAG_TXVLAN);
+
+	if (rc)
+		return rc;
+
+	if (need_reset) {
+		if (netif_running(netdev))
+			e1000e_reinit_locked(adapter);
+		else
+			e1000e_reset(adapter);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_settings		= e1000_get_settings,
 	.set_settings		= e1000_set_settings,
@@ -2055,6 +2080,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_coalesce		= e1000_get_coalesce,
 	.set_coalesce		= e1000_set_coalesce,
 	.get_flags		= ethtool_op_get_flags,
+	.set_flags		= e1000e_set_flags,
 };
 
 void e1000e_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 99c8c7c..8812eb2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -459,13 +459,13 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 			      struct net_device *netdev, struct sk_buff *skb,
 			      u8 status, __le16 vlan)
 {
+	u16 tag = le16_to_cpu(vlan);
 	skb->protocol = eth_type_trans(skb, netdev);
 
-	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
-		vlan_gro_receive(&adapter->napi, adapter->vlgrp,
-				 le16_to_cpu(vlan), skb);
-	else
-		napi_gro_receive(&adapter->napi, skb);
+	if (status & E1000_RXD_STAT_VP)
+		__vlan_hwaccel_put_tag(skb, tag);
+
+	napi_gro_receive(&adapter->napi, skb);
 }
 
 /**
@@ -2433,6 +2433,8 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 		vfta |= (1 << (vid & 0x1F));
 		hw->mac.ops.write_vfta(hw, index, vfta);
 	}
+
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -2441,13 +2443,6 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
 
-	if (!test_bit(__E1000_DOWN, &adapter->state))
-		e1000_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-
-	if (!test_bit(__E1000_DOWN, &adapter->state))
-		e1000_irq_enable(adapter);
-
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
 	    (vid == adapter->mng_vlan_id)) {
@@ -2463,93 +2458,105 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 		vfta &= ~(1 << (vid & 0x1F));
 		hw->mac.ops.write_vfta(hw, index, vfta);
 	}
+
+	clear_bit(vid, adapter->active_vlans);
 }
 
-static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
+/**
+ * e1000e_vlan_filter_disable - helper to disable hw VLAN filtering
+ * @adapter: board private structure to initialize
+ **/
+static void e1000e_vlan_filter_disable(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	u16 vid = adapter->hw.mng_cookie.vlan_id;
-	u16 old_vid = adapter->mng_vlan_id;
-
-	if (!adapter->vlgrp)
-		return;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rctl;
 
-	if (!vlan_group_get_device(adapter->vlgrp, vid)) {
-		adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-		if (adapter->hw.mng_cookie.status &
-			E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
-			e1000_vlan_rx_add_vid(netdev, vid);
-			adapter->mng_vlan_id = vid;
+	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
+		/* disable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl &= ~(E1000_RCTL_VFE | E1000_RCTL_CFIEN);
+		ew32(RCTL, rctl);
+
+		if (adapter->mng_vlan_id != (u16)E1000_MNG_VLAN_NONE) {
+			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
+			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 		}
-
-		if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
-				(vid != old_vid) &&
-		    !vlan_group_get_device(adapter->vlgrp, old_vid))
-			e1000_vlan_rx_kill_vid(netdev, old_vid);
-	} else {
-		adapter->mng_vlan_id = vid;
 	}
 }
 
+/**
+ * e1000e_vlan_filter_enable - helper to enable HW VLAN filtering
+ * @adapter: board private structure to initialize
+ **/
+static void e1000e_vlan_filter_enable(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 rctl;
+
+	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
+		/* enable VLAN receive filtering */
+		rctl = er32(RCTL);
+		rctl |= E1000_RCTL_VFE;
+		rctl &= ~E1000_RCTL_CFIEN;
+		ew32(RCTL, rctl);
+	}
+}
 
-static void e1000_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+/**
+ * e1000e_vlan_strip_enable - helper to disable HW VLAN stripping
+ * @adapter: board private structure to initialize
+ **/
+static void e1000e_vlan_strip_disable(struct e1000_adapter *adapter)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl, rctl;
+	u32 ctrl;
 
-	if (!test_bit(__E1000_DOWN, &adapter->state))
-		e1000_irq_disable(adapter);
-	adapter->vlgrp = grp;
+	/* disable VLAN tag insert/strip */
+	ctrl = er32(CTRL);
+	ctrl &= ~E1000_CTRL_VME;
+	ew32(CTRL, ctrl);
+}
 
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = er32(CTRL);
-		ctrl |= E1000_CTRL_VME;
-		ew32(CTRL, ctrl);
+/**
+ * e1000e_vlan_strip_enable - helper to enable HW VLAN stripping
+ * @adapter: board private structure to initialize
+ **/
+static void e1000e_vlan_strip_enable(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl;
 
-		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
-			/* enable VLAN receive filtering */
-			rctl = er32(RCTL);
-			rctl &= ~E1000_RCTL_CFIEN;
-			ew32(RCTL, rctl);
-			e1000_update_mng_vlan(adapter);
-		}
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = er32(CTRL);
-		ctrl &= ~E1000_CTRL_VME;
-		ew32(CTRL, ctrl);
+	/* enable VLAN tag insert/strip */
+	ctrl = er32(CTRL);
+	ctrl |= E1000_CTRL_VME;
+	ew32(CTRL, ctrl);
+}
 
-		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER) {
-			if (adapter->mng_vlan_id !=
-			    (u16)E1000_MNG_VLAN_NONE) {
-				e1000_vlan_rx_kill_vid(netdev,
-						       adapter->mng_vlan_id);
-				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-			}
-		}
+static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	u16 vid = adapter->hw.mng_cookie.vlan_id;
+	u16 old_vid = adapter->mng_vlan_id;
+
+	if (adapter->hw.mng_cookie.status &
+	    E1000_MNG_DHCP_COOKIE_STATUS_VLAN) {
+		e1000_vlan_rx_add_vid(netdev, vid);
+		adapter->mng_vlan_id = vid;
 	}
 
-	if (!test_bit(__E1000_DOWN, &adapter->state))
-		e1000_irq_enable(adapter);
+	if ((old_vid != (u16)E1000_MNG_VLAN_NONE) && (vid != old_vid))
+		e1000_vlan_rx_kill_vid(netdev, old_vid);
 }
 
 static void e1000_restore_vlan(struct e1000_adapter *adapter)
 {
 	u16 vid;
 
-	e1000_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-
-	if (!adapter->vlgrp)
-		return;
+	e1000_vlan_rx_add_vid(adapter->netdev, 0);
 
-	for (vid = 0; vid < VLAN_N_VID; vid++) {
-		if (!vlan_group_get_device(adapter->vlgrp, vid))
-			continue;
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
 		e1000_vlan_rx_add_vid(adapter->netdev, vid);
-	}
 }
 
 static void e1000_init_manageability_pt(struct e1000_adapter *adapter)
@@ -3039,6 +3046,8 @@ static void e1000_set_multi(struct net_device *netdev)
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 		rctl &= ~E1000_RCTL_VFE;
+		/* Do not hardware filter VLANs in promisc mode */
+		e1000e_vlan_filter_disable(adapter);
 	} else {
 		if (netdev->flags & IFF_ALLMULTI) {
 			rctl |= E1000_RCTL_MPE;
@@ -3046,8 +3055,7 @@ static void e1000_set_multi(struct net_device *netdev)
 		} else {
 			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
 		}
-		if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
-			rctl |= E1000_RCTL_VFE;
+		e1000e_vlan_filter_enable(adapter);
 	}
 
 	ew32(RCTL, rctl);
@@ -3072,6 +3080,11 @@ static void e1000_set_multi(struct net_device *netdev)
 		 */
 		e1000_update_mc_addr_list(hw, NULL, 0);
 	}
+
+	if (netdev->features & NETIF_F_HW_VLAN_RX)
+		e1000e_vlan_strip_enable(adapter);
+	else
+		e1000e_vlan_strip_disable(adapter);
 }
 
 /**
@@ -3721,10 +3734,8 @@ static int e1000_close(struct net_device *netdev)
 	 * kill manageability vlan ID if supported, but not if a vlan with
 	 * the same ID is registered on the host OS (let 8021q kill it)
 	 */
-	if ((adapter->hw.mng_cookie.status &
-			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN) &&
-	     !(adapter->vlgrp &&
-	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id)))
+	if (adapter->hw.mng_cookie.status &
+	    E1000_MNG_DHCP_COOKIE_STATUS_VLAN)
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 
 	/*
@@ -5759,7 +5770,6 @@ static const struct net_device_ops e1000e_netdev_ops = {
 	.ndo_tx_timeout		= e1000_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
 
-	.ndo_vlan_rx_register	= e1000_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= e1000_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.4.2

