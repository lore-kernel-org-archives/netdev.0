From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 35/47 V2] e1000: do vlan cleanup
Date: Thu, 21 Jul 2011 15:26:31 +0200
Message-ID: <20110721132631.GF2107@minipsycho>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
 <1311173689-17419-36-git-send-email-jpirko@redhat.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:4688 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab1GUN1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 09:27:16 -0400
Content-Disposition: inline
In-Reply-To: <1311173689-17419-36-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill adapter->vlgrp and e1000_vlan_rx_register
- allow to turn on/off rx/tx vlan accel via ethtool (set_features)

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000/e1000.h      |    2 +-
 drivers/net/e1000/e1000_main.c |  168 +++++++++++++++++++++++++---------------
 2 files changed, 108 insertions(+), 62 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 8676899..24f41da 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -215,7 +215,7 @@ struct e1000_adapter {
 	struct timer_list tx_fifo_stall_timer;
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 mng_vlan_id;
 	u32 bd_number;
 	u32 rx_buffer_len;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 188d99a..acaebec 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -30,6 +30,8 @@
 #include <net/ip6_checksum.h>
 #include <linux/io.h>
 #include <linux/prefetch.h>
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>
 
 /* Intel Media SOC GbE MDIO physical base address */
 static unsigned long ce4100_gbe_mdio_base_phy;
@@ -166,7 +168,8 @@ static void e1000_smartspeed(struct e1000_adapter *adapter);
 static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
                                        struct sk_buff *skb);
 
-static void e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
+static bool e1000_vlan_used(struct e1000_adapter *adapter);
+static void e1000_vlan_mode(struct net_device *netdev, u32 features);
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -330,21 +333,24 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	u16 vid = hw->mng_cookie.vlan_id;
 	u16 old_vid = adapter->mng_vlan_id;
-	if (adapter->vlgrp) {
-		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
-			if (hw->mng_cookie.status &
-				E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) {
-				e1000_vlan_rx_add_vid(netdev, vid);
-				adapter->mng_vlan_id = vid;
-			} else
-				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 
-			if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
-					(vid != old_vid) &&
-			    !vlan_group_get_device(adapter->vlgrp, old_vid))
-				e1000_vlan_rx_kill_vid(netdev, old_vid);
-		} else
+	if (!e1000_vlan_used(adapter))
+		return;
+
+	if (!test_bit(vid, adapter->active_vlans)) {
+		if (hw->mng_cookie.status &
+		    E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) {
+			e1000_vlan_rx_add_vid(netdev, vid);
 			adapter->mng_vlan_id = vid;
+		} else {
+			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
+		}
+		if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
+		    (vid != old_vid) &&
+		    !test_bit(old_vid, adapter->active_vlans))
+			e1000_vlan_rx_kill_vid(netdev, old_vid);
+	} else {
+		adapter->mng_vlan_id = vid;
 	}
 }
 
@@ -797,11 +803,28 @@ static int e1000_is_need_ioport(struct pci_dev *pdev)
 	}
 }
 
+static u32 e1000_fix_features(struct net_device *netdev, u32 features)
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
 static int e1000_set_features(struct net_device *netdev, u32 features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	u32 changed = features ^ netdev->features;
 
+	if (changed & NETIF_F_HW_VLAN_RX)
+		e1000_vlan_mode(netdev, features);
+
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
 
@@ -822,18 +845,17 @@ static const struct net_device_ops e1000_netdev_ops = {
 	.ndo_get_stats		= e1000_get_stats,
 	.ndo_set_rx_mode	= e1000_set_rx_mode,
 	.ndo_set_mac_address	= e1000_set_mac,
-	.ndo_tx_timeout 	= e1000_tx_timeout,
+	.ndo_tx_timeout		= e1000_tx_timeout,
 	.ndo_change_mtu		= e1000_change_mtu,
 	.ndo_do_ioctl		= e1000_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
-
-	.ndo_vlan_rx_register	= e1000_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= e1000_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= e1000_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= e1000_netpoll,
 #endif
-	.ndo_set_features       = e1000_set_features,
+	.ndo_fix_features	= e1000_fix_features,
+	.ndo_set_features	= e1000_set_features,
 };
 
 /**
@@ -1036,9 +1058,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	if (hw->mac_type >= e1000_82543) {
 		netdev->hw_features = NETIF_F_SG |
-				   NETIF_F_HW_CSUM;
+				   NETIF_F_HW_CSUM |
+				   NETIF_F_HW_VLAN_RX;
 		netdev->features = NETIF_F_HW_VLAN_TX |
-				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
 	}
 
@@ -1197,6 +1219,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
+	e1000_vlan_mode(netdev, netdev->features);
+
 	/* print bus type/speed/width info */
 	e_info(probe, "(PCI%s:%dMHz:%d-bit) %pM\n",
 	       ((hw->bus_type == e1000_bus_type_pcix) ? "-X" : ""),
@@ -1441,8 +1465,7 @@ static int e1000_close(struct net_device *netdev)
 	 * the same ID is registered on the host OS (let 8021q kill it) */
 	if ((hw->mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
-	     !(adapter->vlgrp &&
-	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id))) {
+	     !test_bit(adapter->mng_vlan_id, adapter->active_vlans)) {
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 	}
 
@@ -2233,7 +2256,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		else
 			rctl &= ~E1000_RCTL_MPE;
 		/* Enable VLAN filter if there is a VLAN */
-		if (adapter->vlgrp)
+		if (e1000_vlan_used(adapter))
 			rctl |= E1000_RCTL_VFE;
 	}
 
@@ -3180,7 +3203,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
 	}
@@ -3735,12 +3758,12 @@ static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
 {
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 
-	if ((unlikely(adapter->vlgrp && (status & E1000_RXD_STAT_VP))))
-		vlan_gro_receive(&adapter->napi, adapter->vlgrp,
-				 le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK,
-				 skb);
-	else
-		napi_gro_receive(&adapter->napi, skb);
+	if (status & E1000_RXD_STAT_VP) {
+		u16 vid = le16_to_cpu(vlan) & E1000_RXD_SPC_VLAN_MASK;
+
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+	napi_gro_receive(&adapter->napi, skb);
 }
 
 /**
@@ -4523,46 +4546,61 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
 	outl(value, port);
 }
 
-static void e1000_vlan_rx_register(struct net_device *netdev,
-				   struct vlan_group *grp)
+static bool e1000_vlan_used(struct e1000_adapter *adapter)
+{
+	u16 vid;
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		return true;
+	return false;
+}
+
+static void e1000_vlan_filter_on_off(struct e1000_adapter *adapter,
+				     bool filter_on)
 {
-	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl, rctl;
+	u32 rctl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
-	adapter->vlgrp = grp;
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl = er32(CTRL);
-		ctrl |= E1000_CTRL_VME;
-		ew32(CTRL, ctrl);
 
+	if (filter_on) {
 		/* enable VLAN receive filtering */
 		rctl = er32(RCTL);
 		rctl &= ~E1000_RCTL_CFIEN;
-		if (!(netdev->flags & IFF_PROMISC))
+		if (!(adapter->netdev->flags & IFF_PROMISC))
 			rctl |= E1000_RCTL_VFE;
 		ew32(RCTL, rctl);
 		e1000_update_mng_vlan(adapter);
 	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl = er32(CTRL);
-		ctrl &= ~E1000_CTRL_VME;
-		ew32(CTRL, ctrl);
-
 		/* disable VLAN receive filtering */
 		rctl = er32(RCTL);
 		rctl &= ~E1000_RCTL_VFE;
 		ew32(RCTL, rctl);
+	}
 
-		if (adapter->mng_vlan_id != (u16)E1000_MNG_VLAN_NONE) {
-			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
-			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-		}
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
+}
+
+static void e1000_vlan_mode(struct net_device *netdev, u32 features)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl;
+
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
+
+	ctrl = er32(CTRL);
+	if (features & NETIF_F_HW_VLAN_RX) {
+		/* enable VLAN tag insert/strip */
+		ctrl |= E1000_CTRL_VME;
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl &= ~E1000_CTRL_VME;
 	}
+	ew32(CTRL, ctrl);
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
@@ -4578,11 +4616,17 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
+
+	if (!e1000_vlan_used(adapter))
+		e1000_vlan_filter_on_off(adapter, true);
+
 	/* add VID to filter table */
 	index = (vid >> 5) & 0x7F;
 	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
 	e1000_write_vfta(hw, index, vfta);
+
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -4593,7 +4637,6 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
 
@@ -4602,20 +4645,23 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
 	e1000_write_vfta(hw, index, vfta);
+
+	clear_bit(vid, adapter->active_vlans);
+
+	if (!e1000_vlan_used(adapter))
+		e1000_vlan_filter_on_off(adapter, false);
 }
 
 static void e1000_restore_vlan(struct e1000_adapter *adapter)
 {
-	e1000_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+	u16 vid;
 
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			e1000_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
+	if (!e1000_vlan_used(adapter))
+		return;
+
+	e1000_vlan_filter_on_off(adapter, true);
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		e1000_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
-- 
1.7.6

