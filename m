From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 37/47 V2] igb: do vlan cleanup
Date: Thu, 21 Jul 2011 15:27:27 +0200
Message-ID: <20110721132726.GG2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-38-git-send-email-jpirko@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:20659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab1GUN2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 09:28:10 -0400
Content-Disposition: inline
In-Reply-To: <1311173689-17419-38-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and igb_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/igb/igb.h      |    4 +-
 drivers/net/igb/igb_main.c |   90 +++++++++++++++++++++----------------------
 2 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 0389ff6..265e151 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -37,6 +37,8 @@
 #include <linux/clocksource.h>
 #include <linux/timecompare.h>
 #include <linux/net_tstamp.h>
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>
 
 struct igb_adapter;
 
@@ -252,7 +254,7 @@ static inline int igb_desc_unused(struct igb_ring *ring)
 struct igb_adapter {
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 mng_vlan_id;
 	u32 bd_number;
 	u32 wol;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f4d82b2..cb8c6bb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -28,6 +28,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
+#include <linux/bitops.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/netdevice.h>
@@ -46,6 +47,7 @@
 #include <linux/if_ether.h>
 #include <linux/aer.h>
 #include <linux/prefetch.h>
+#include <linux/if_vlan.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
@@ -140,7 +142,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *, int *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
-static void igb_vlan_rx_register(struct net_device *, struct vlan_group *);
+static void igb_vlan_mode(struct net_device *netdev, u32 features);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
@@ -1362,7 +1364,7 @@ static void igb_update_mng_vlan(struct igb_adapter *adapter)
 
 	if ((old_vid != (u16)IGB_MNG_VLAN_NONE) &&
 	    (vid != old_vid) &&
-	    !vlan_group_get_device(adapter->vlgrp, old_vid)) {
+	    !test_bit(old_vid, adapter->active_vlans)) {
 		/* remove VID from filter table */
 		igb_vfta_set(hw, old_vid, false);
 	}
@@ -1748,10 +1750,25 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_get_phy_info(hw);
 }
 
+static u32 igb_fix_features(struct net_device *netdev, u32 features)
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
 static int igb_set_features(struct net_device *netdev, u32 features)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	int i;
+	u32 changed = netdev->features ^ features;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		if (features & NETIF_F_RXCSUM)
@@ -1760,6 +1777,9 @@ static int igb_set_features(struct net_device *netdev, u32 features)
 			adapter->rx_ring[i]->flags &= ~IGB_RING_FLAG_RX_CSUM;
 	}
 
+	if (changed & NETIF_F_HW_VLAN_RX)
+		igb_vlan_mode(netdev, features);
+
 	return 0;
 }
 
@@ -1775,7 +1795,6 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_do_ioctl		= igb_ioctl,
 	.ndo_tx_timeout		= igb_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register	= igb_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= igb_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= igb_vlan_rx_kill_vid,
 	.ndo_set_vf_mac		= igb_ndo_set_vf_mac,
@@ -1785,7 +1804,8 @@ static const struct net_device_ops igb_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= igb_netpoll,
 #endif
-	.ndo_set_features       = igb_set_features,
+	.ndo_fix_features	= igb_fix_features,
+	.ndo_set_features	= igb_set_features,
 };
 
 /**
@@ -1930,11 +1950,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			   NETIF_F_IPV6_CSUM |
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
-			   NETIF_F_RXCSUM;
+			   NETIF_F_RXCSUM |
+			   NETIF_F_HW_VLAN_RX;
 
 	netdev->features = netdev->hw_features |
 			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->vlan_features |= NETIF_F_TSO;
@@ -2057,6 +2077,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+	igb_vlan_mode(netdev, netdev->features);
+
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
@@ -2939,12 +2961,11 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
  **/
 static void igb_rlpml_set(struct igb_adapter *adapter)
 {
-	u32 max_frame_size = adapter->max_frame_size;
+	u32 max_frame_size;
 	struct e1000_hw *hw = &adapter->hw;
 	u16 pf_id = adapter->vfs_allocated_count;
 
-	if (adapter->vlgrp)
-		max_frame_size += VLAN_TAG_SIZE;
+	max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
 
 	/* if vfs are enabled we set RLPML to the largest possible request
 	 * size and set the VMOLR RLPML to the size we need */
@@ -5693,25 +5714,6 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	return count < tx_ring->count;
 }
 
-/**
- * igb_receive_skb - helper function to handle rx indications
- * @q_vector: structure containing interrupt and ring information
- * @skb: packet to send up
- * @vlan_tag: vlan tag for packet
- **/
-static void igb_receive_skb(struct igb_q_vector *q_vector,
-                            struct sk_buff *skb,
-                            u16 vlan_tag)
-{
-	struct igb_adapter *adapter = q_vector->adapter;
-
-	if (vlan_tag && adapter->vlgrp)
-		vlan_gro_receive(&q_vector->napi, adapter->vlgrp,
-		                 vlan_tag, skb);
-	else
-		napi_gro_receive(&q_vector->napi, skb);
-}
-
 static inline void igb_rx_checksum_adv(struct igb_ring *ring,
 				       u32 status_err, struct sk_buff *skb)
 {
@@ -5809,7 +5811,6 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 	unsigned int i;
 	u32 staterr;
 	u16 length;
-	u16 vlan_tag;
 
 	i = rx_ring->next_to_clean;
 	buffer_info = &rx_ring->buffer_info[i];
@@ -5894,10 +5895,12 @@ send_up:
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, rx_ring->queue_index);
 
-		vlan_tag = ((staterr & E1000_RXD_STAT_VP) ?
-		            le16_to_cpu(rx_desc->wb.upper.vlan) : 0);
+		if (staterr & E1000_RXD_STAT_VP) {
+			u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-		igb_receive_skb(q_vector, skb, vlan_tag);
+			__vlan_hwaccel_put_tag(skb, vid);
+		}
+		napi_gro_receive(&q_vector->napi, skb);
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
@@ -6290,17 +6293,15 @@ s32 igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 	return 0;
 }
 
-static void igb_vlan_rx_register(struct net_device *netdev,
-				 struct vlan_group *grp)
+static void igb_vlan_mode(struct net_device *netdev, u32 features)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
 
 	igb_irq_disable(adapter);
-	adapter->vlgrp = grp;
 
-	if (grp) {
+	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
 		ctrl = rd32(E1000_CTRL);
 		ctrl |= E1000_CTRL_VME;
@@ -6334,6 +6335,8 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 
 	/* add the filter since PF can receive vlans w/o entry in vlvf */
 	igb_vfta_set(hw, vid, true);
+
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -6344,7 +6347,6 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	s32 err;
 
 	igb_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		igb_irq_enable(adapter);
@@ -6355,20 +6357,16 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	/* if vid was not present in VLVF just remove it from table */
 	if (err)
 		igb_vfta_set(hw, vid, false);
+
+	clear_bit(vid, adapter->active_vlans);
 }
 
 static void igb_restore_vlan(struct igb_adapter *adapter)
 {
-	igb_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	u16 vid;
 
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			igb_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		igb_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
-- 
1.7.6

