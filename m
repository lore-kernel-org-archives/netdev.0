From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 26/47 V2] ixgbevf: do vlan cleanup
Date: Thu, 21 Jul 2011 15:25:09 +0200
Message-ID: <20110721132508.GE2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-27-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net,
	jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab1GUNZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 09:25:59 -0400
Content-Disposition: inline
In-Reply-To: <1311173689-17419-27-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and ixgbevf_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    6 ++--
 drivers/net/ixgbevf/ixgbevf_main.c |   64 ++++++++---------------------------
 2 files changed, 18 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index a2bbbb3..8857df4 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -29,9 +29,11 @@
 #define _IXGBEVF_H_
 
 #include <linux/types.h>
+#include <linux/bitops.h>
 #include <linux/timer.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 
 #include "vf.h"
 
@@ -185,9 +187,7 @@ struct ixgbevf_q_vector {
 /* board specific private data structure */
 struct ixgbevf_adapter {
 	struct timer_list watchdog_timer;
-#ifdef NETIF_F_HW_VLAN_TX
-	struct vlan_group *vlgrp;
-#endif
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbevf_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index fec36bd..3b880a2 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -30,6 +30,7 @@
  Copyright (c)2006 - 2007 Myricom, Inc. for some LRO specific code
 ******************************************************************************/
 #include <linux/types.h>
+#include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -288,21 +289,17 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
-	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-		if (adapter->vlgrp && is_vlan)
-			vlan_gro_receive(&q_vector->napi,
-					 adapter->vlgrp,
-					 tag, skb);
-		else
+	if (is_vlan) {
+		u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
+
+		__vlan_hwaccel_put_tag(skb, tag);
+	}
+
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
 			napi_gro_receive(&q_vector->napi, skb);
-	} else {
-		if (adapter->vlgrp && is_vlan)
-			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
-		else
+	else
 			netif_rx(skb);
-	}
 }
 
 /**
@@ -1401,24 +1398,6 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static void ixgbevf_vlan_rx_register(struct net_device *netdev,
-				     struct vlan_group *grp)
-{
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-	int i, j;
-	u32 ctrl;
-
-	adapter->vlgrp = grp;
-
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		j = adapter->rx_ring[i].reg_idx;
-		ctrl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
-		ctrl |= IXGBE_RXDCTL_VME;
-		IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(j), ctrl);
-	}
-}
-
 static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
@@ -1427,6 +1406,7 @@ static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	/* add VID to filter table */
 	if (hw->mac.ops.set_vfta)
 		hw->mac.ops.set_vfta(hw, vid, 0, true);
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -1434,31 +1414,18 @@ static void ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
-		ixgbevf_irq_disable(adapter);
-
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
-		ixgbevf_irq_enable(adapter, true, true);
-
 	/* remove VID from filter table */
 	if (hw->mac.ops.set_vfta)
 		hw->mac.ops.set_vfta(hw, vid, 0, false);
+	clear_bit(vid, adapter->active_vlans);
 }
 
 static void ixgbevf_restore_vlan(struct ixgbevf_adapter *adapter)
 {
-	ixgbevf_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	u16 vid;
 
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			ixgbevf_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		ixgbevf_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
@@ -1648,7 +1615,7 @@ static int ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	for (i = 0; i < num_rx_rings; i++) {
 		j = adapter->rx_ring[i].reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
-		rxdctl |= IXGBE_RXDCTL_ENABLE;
+		rxdctl |= IXGBE_RXDCTL_ENABLE | IXGBE_RXDCTL_VME;
 		if (hw->mac.type == ixgbe_mac_X540_vf) {
 			rxdctl &= ~IXGBE_RXDCTL_RLPMLMASK;
 			rxdctl |= ((netdev->mtu + ETH_HLEN + ETH_FCS_LEN) |
@@ -3258,7 +3225,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_mac_address	= ixgbevf_set_mac,
 	.ndo_change_mtu		= ixgbevf_change_mtu,
 	.ndo_tx_timeout		= ixgbevf_tx_timeout,
-	.ndo_vlan_rx_register	= ixgbevf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbevf_vlan_rx_kill_vid,
 };
-- 
1.7.6

