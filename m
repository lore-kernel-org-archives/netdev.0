From: Jesse Gross <jesse@nicira.com>
Subject: [RFC PATCH 4/7] ixgbe: Update ixgbe to use new vlan accleration.
Date: Wed, 13 Oct 2010 13:02:54 -0700
Message-ID: <1287000177-7126-5-git-send-email-jesse@nicira.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:47432 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab0JMUDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 16:03:09 -0400
Received: by pxi16 with SMTP id 16so842013pxi.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 13:03:09 -0700 (PDT)
In-Reply-To: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the ixgbe driver use the new vlan accleration model.

Signed-off-by: Jesse Gross <jesse@nicira.com>
CC: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
CC: Emil Tantilov <emil.s.tantilov@intel.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    4 ++-
 drivers/net/ixgbe/ixgbe_main.c |   60 ++++++++++------------------------------
 2 files changed, 18 insertions(+), 46 deletions(-)

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
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 95dbf60..58b3363 100644
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
@@ -3157,14 +3147,9 @@ static void ixgbe_vlan_filter_enable(struct ixgbe_adapter *adapter)
 	}
 }
 
-static void ixgbe_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_disable(adapter);
-	adapter->vlgrp = grp;
+	u16 vid;
 
 	/*
 	 * For a DCB driver, always enable VLAN tag stripping so we can
@@ -3173,24 +3158,10 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	 */
 	ixgbe_vlan_filter_enable(adapter);
 
-	ixgbe_vlan_rx_add_vid(netdev, 0);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable(adapter, true, true);
-}
+	ixgbe_vlan_rx_add_vid(adapter->netdev, 0);
 
-static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
-{
-	ixgbe_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 /**
@@ -6312,7 +6283,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev
 	int count = 0;
 	unsigned int f;
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= vlan_tx_tag_get(skb);
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
 			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
@@ -6570,7 +6541,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_mac_address	= ixgbe_set_mac,
 	.ndo_change_mtu		= ixgbe_change_mtu,
 	.ndo_tx_timeout		= ixgbe_tx_timeout,
-	.ndo_vlan_rx_register	= ixgbe_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
 	.ndo_do_ioctl		= ixgbe_ioctl,
-- 
1.7.0.4

