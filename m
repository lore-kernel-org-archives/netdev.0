From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 26/47] ixgbevf: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:28 +0200
Message-ID: <1311173689-17419-27-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, mirqus@gmail.com,
	john.ronciak@intel.com, shemminger@linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and ixgbevf_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    6 ++--
 drivers/net/ixgbevf/ixgbevf_main.c |   63 +++++++++++++++---------------------
 2 files changed, 29 insertions(+), 40 deletions(-)

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
index fec36bd..8212a80 100644
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
@@ -1401,16 +1398,12 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	}
 }
 
-static void ixgbevf_vlan_rx_register(struct net_device *netdev,
-				     struct vlan_group *grp)
+static void ixgbevf_vlan_enable(struct ixgbevf_adapter *adapter)
 {
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i, j;
 	u32 ctrl;
 
-	adapter->vlgrp = grp;
-
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		j = adapter->rx_ring[i].reg_idx;
 		ctrl = IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(j));
@@ -1419,9 +1412,9 @@ static void ixgbevf_vlan_rx_register(struct net_device *netdev,
 	}
 }
 
-static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+static void __ixgbevf_vlan_rx_add_vid(struct ixgbevf_adapter *adapter,
+				      u16 vid)
 {
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	/* add VID to filter table */
@@ -1429,36 +1422,33 @@ static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 		hw->mac.ops.set_vfta(hw, vid, 0, true);
 }
 
-static void ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+static void ixgbevf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
-		ixgbevf_irq_disable(adapter);
 
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
+	ixgbevf_vlan_enable(adapter);
+	__ixgbevf_vlan_rx_add_vid(adapter, vid);
+	set_bit(vid, adapter->active_vlans);
+}
 
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
-		ixgbevf_irq_enable(adapter, true, true);
+static void ixgbevf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
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
+	ixgbevf_vlan_enable(adapter);
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		__ixgbevf_vlan_rx_add_vid(adapter, vid);
 }
 
 static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
@@ -3258,7 +3248,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_set_mac_address	= ixgbevf_set_mac,
 	.ndo_change_mtu		= ixgbevf_change_mtu,
 	.ndo_tx_timeout		= ixgbevf_tx_timeout,
-	.ndo_vlan_rx_register	= ixgbevf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbevf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbevf_vlan_rx_kill_vid,
 };
-- 
1.7.6


------------------------------------------------------------------------------
10 Tips for Better Web Security
Learn 10 ways to better secure your business today. Topics covered include:
Web security, SSL, hacker attacks & Denial of Service (DoS), private keys,
security Microsoft Exchange, secure Instant Messaging, and much more.
http://www.accelacomm.com/jaw/sfnl/114/51426210/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
