From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 10/14] ixgbe: Update ixgbe to use new vlan accleration.
Date: Wed, 20 Oct 2010 16:56:10 -0700
Message-ID: <1287618974-4714-11-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755492Ab0JTX4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:38 -0400
Received: by mail-vw0-f46.google.com with SMTP id 2so2600261vws.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:37 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the ixgbe driver use the new vlan accleration model.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
CC: Emil Tantilov <emil.s.tantilov@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    4 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |   12 +++-
 drivers/net/ixgbe/ixgbe_main.c    |  137 ++++++++++++++++---------------------
 3 files changed, 74 insertions(+), 79 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a8c47b0..5e38de7 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -28,11 +28,13 @@
 #ifndef _IXGBE_H_
 #define _IXGBE_H_
 
+#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/cpumask.h>
 #include <linux/aer.h>
+#include <linux/if_vlan.h>
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -287,7 +289,7 @@ struct ixgbe_q_vector {
 /* board specific private data structure */
 struct ixgbe_adapter {
 	struct timer_list watchdog_timer;
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index d4ac943..dbfd62f 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2113,7 +2113,17 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	bool need_reset = false;
 	int rc;
 
-	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO | ETH_FLAG_NTUPLE);
+#ifdef CONFIG_IXGBE_DCB
+	if ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
+	    !(data & ETH_FLAG_RXVLAN))
+		return -EINVAL;
+#endif
+
+	need_reset = (data & ETH_FLAG_RXVLAN) !=
+		     (netdev->features & NETIF_F_HW_VLAN_RX);
+
+	rc = ethtool_op_set_flags(netdev, data, ETH_FLAG_LRO |
+					ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 998debe..56f6b80 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -954,17 +954,13 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-		if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
-			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
-		else
-			napi_gro_receive(napi, skb);
-	} else {
-		if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
-			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
-		else
-			netif_rx(skb);
-	}
+	if (is_vlan && (tag & VLAN_VID_MASK))
+		__vlan_hwaccel_put_tag(skb, tag);
+
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+		napi_gro_receive(napi, skb);
+	else
+		netif_rx(skb);
 }
 
 /**
@@ -3065,6 +3061,7 @@ static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 
 	/* add VID to filter table */
 	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, true);
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -3073,16 +3070,9 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int pool_ndx = adapter->num_vfs;
 
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_disable(adapter);
-
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter, true, true);
-
 	/* remove VID from filter table */
 	hw->mac.ops.set_vfta(&adapter->hw, vid, pool_ndx, false);
+	clear_bit(vid, adapter->active_vlans);
 }
 
 /**
@@ -3092,27 +3082,45 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 static void ixgbe_vlan_filter_disable(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	u32 vlnctrl;
+
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	vlnctrl &= ~(IXGBE_VLNCTRL_VFE | IXGBE_VLNCTRL_CFIEN);
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+}
+
+/**
+ * ixgbe_vlan_filter_enable - helper to enable hw vlan filtering
+ * @adapter: driver data
+ */
+static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vlnctrl;
+
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	vlnctrl |= IXGBE_VLNCTRL_VFE;
+	vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+}
+
+/**
+ * ixgbe_vlan_strip_disable - helper to disable hw vlan stripping
+ * @adapter: driver data
+ */
+static void ixgbe_vlan_strip_disable(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vlnctrl;
 	int i, j;
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
-#ifdef CONFIG_IXGBE_DCB
-		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
-			vlnctrl &= ~IXGBE_VLNCTRL_VME;
-#endif
-		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+		vlnctrl &= ~IXGBE_VLNCTRL_VME;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		break;
 	case ixgbe_mac_82599EB:
-		vlnctrl &= ~IXGBE_VLNCTRL_VFE;
-		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
-#ifdef CONFIG_IXGBE_DCB
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
-			break;
-#endif
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
@@ -3126,25 +3134,22 @@ static void ixgbe_vlan_filter_disable(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_vlan_filter_enable - helper to enable hw vlan filtering
+ * ixgbe_vlan_strip_enable - helper to enable hw vlan stripping
  * @adapter: driver data
  */
-static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
+static void ixgbe_vlan_strip_enable(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	u32 vlnctrl;
 	int i, j;
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		vlnctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
-		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+		vlnctrl |= IXGBE_VLNCTRL_VME;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		break;
 	case ixgbe_mac_82599EB:
-		vlnctrl |= IXGBE_VLNCTRL_VFE;
-		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
@@ -3157,40 +3162,14 @@ static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
 	}
 }
 
-static void ixgbe_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_disable(adapter);
-	adapter->vlgrp = grp;
-
-	/*
-	 * For a DCB driver, always enable VLAN tag stripping so we can
-	 * still receive traffic from a DCB-enabled host even if we're
-	 * not in DCB mode.
-	 */
-	ixgbe_vlan_filter_enable(adapter);
-
-	ixgbe_vlan_rx_add_vid(netdev, 0);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter, true, true);
-}
-
 static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 {
-	ixgbe_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	u16 vid;
 
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	ixgbe_vlan_rx_add_vid(adapter->netdev, 0);
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 /**
@@ -3305,6 +3284,11 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+
+	if (netdev->features & NETIF_F_HW_VLAN_RX)
+		ixgbe_vlan_strip_enable(adapter);
+	else
+		ixgbe_vlan_strip_disable(adapter);
 }
 
 static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
@@ -3388,7 +3372,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
 	/* Enable VLAN tag insert/strip */
-	ixgbe_vlan_filter_enable(adapter);
+	adapter->netdev->features |= NETIF_F_HW_VLAN_RX;
 
 	hw->mac.ops.set_vfta(&adapter->hw, 0, 0, true);
 }
@@ -3400,13 +3384,13 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
-	ixgbe_set_rx_mode(netdev);
-
-	ixgbe_restore_vlan(adapter);
 #ifdef CONFIG_IXGBE_DCB
 	ixgbe_configure_dcb(adapter);
 #endif
 
+	ixgbe_set_rx_mode(netdev);
+	ixgbe_restore_vlan(adapter);
+
 #ifdef IXGBE_FCOE
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		ixgbe_configure_fcoe(adapter);
@@ -6569,7 +6553,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_mac_address	= ixgbe_set_mac,
 	.ndo_change_mtu		= ixgbe_change_mtu,
 	.ndo_tx_timeout		= ixgbe_tx_timeout,
-	.ndo_vlan_rx_register	= ixgbe_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
 	.ndo_do_ioctl		= ixgbe_ioctl,
-- 
1.7.1

