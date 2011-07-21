From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 18/47 V3] igbvf: do vlan cleanup
Date: Thu, 21 Jul 2011 18:30:00 +0200
Message-ID: <20110721162959.GI2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
	<1311173689-17419-19-git-send-email-jpirko@redhat.com>
	<20110721132229.GC2107@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	mirqus@gmail.com, john.ronciak@intel.com,
	shemminger@linux-foundation.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20110721132229.GC2107@minipsycho>
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
- kill adapter->vlgrp and igbvf_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/igbvf/igbvf.h  |    4 ++--
 drivers/net/igbvf/netdev.c |   44 ++++++++++++++------------------------------
 2 files changed, 16 insertions(+), 32 deletions(-)

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
index 64b47bf..1330c8e 100644
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
@@ -1167,12 +1167,10 @@ static int igbvf_poll(struct napi_struct *napi, int budget)
  */
 static void igbvf_set_rlpml(struct igbvf_adapter *adapter)
 {
-	int max_frame_size = adapter->max_frame_size;
+	int max_frame_size;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (adapter->vlgrp)
-		max_frame_size += VLAN_TAG_SIZE;
-
+	max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
 	e1000_rlpml_set_vf(hw, max_frame_size);
 }
 
@@ -1183,6 +1181,8 @@ static void igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 
 	if (hw->mac.ops.set_vfta(hw, vid, true))
 		dev_err(&adapter->pdev->dev, "Failed to add vlan id %d\n", vid);
+	else
+		set_bit(vid, adapter->active_vlans);
 }
 
 static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -1191,7 +1191,6 @@ static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 
 	igbvf_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
 	if (!test_bit(__IGBVF_DOWN, &adapter->state))
 		igbvf_irq_enable(adapter);
@@ -1199,30 +1198,16 @@ static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
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
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
 		igbvf_vlan_rx_add_vid(adapter->netdev, vid);
-	}
-
-	igbvf_set_rlpml(adapter);
 }
 
 /**
@@ -2203,7 +2188,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
-	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGBVF_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IGBVF_TX_FLAGS_VLAN_SHIFT);
 	}
@@ -2556,7 +2541,6 @@ static const struct net_device_ops igbvf_netdev_ops = {
 	.ndo_change_mtu                 = igbvf_change_mtu,
 	.ndo_do_ioctl                   = igbvf_ioctl,
 	.ndo_tx_timeout                 = igbvf_tx_timeout,
-	.ndo_vlan_rx_register           = igbvf_vlan_rx_register,
 	.ndo_vlan_rx_add_vid            = igbvf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid           = igbvf_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.6


------------------------------------------------------------------------------
5 Ways to Improve & Secure Unified Communications
Unified Communications promises greater efficiencies for business. UC can 
improve internal communications as well as offer faster, more efficient ways
to interact with customers and streamline customer service. Learn more!
http://www.accelacomm.com/jaw/sfnl/114/51426253/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
