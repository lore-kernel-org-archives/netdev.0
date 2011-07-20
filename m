From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 35/47] e1000: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:37 +0200
Message-ID: <1311173689-17419-36-git-send-email-jpirko@redhat.com>
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
- kill adapter->vlgrp and e1000_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/e1000/e1000.h      |    2 +-
 drivers/net/e1000/e1000_main.c |  101 ++++++++++++++++++++++------------------
 2 files changed, 56 insertions(+), 47 deletions(-)

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
index 188d99a..4cce888 100644
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
@@ -166,7 +168,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter);
 static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
                                        struct sk_buff *skb);
 
-static void e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
+static bool e1000_vlan_used(struct e1000_adapter *adapter);
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -330,21 +332,21 @@ static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
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
 
@@ -822,12 +824,10 @@ static const struct net_device_ops e1000_netdev_ops = {
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
@@ -1441,8 +1441,7 @@ static int e1000_close(struct net_device *netdev)
 	 * the same ID is registered on the host OS (let 8021q kill it) */
 	if ((hw->mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
-	     !(adapter->vlgrp &&
-	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id))) {
+	     !test_bit(adapter->mng_vlan_id, adapter->active_vlans)) {
 		e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
 	}
 
@@ -2233,7 +2232,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		else
 			rctl &= ~E1000_RCTL_MPE;
 		/* Enable VLAN filter if there is a VLAN */
-		if (adapter->vlgrp)
+		if (e1000_vlan_used(adapter))
 			rctl |= E1000_RCTL_VFE;
 	}
 
@@ -3180,7 +3179,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	if (unlikely(vlan_tx_tag_present(skb))) {
+	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << E1000_TX_FLAGS_VLAN_SHIFT);
 	}
@@ -3735,12 +3734,12 @@ static void e1000_receive_skb(struct e1000_adapter *adapter, u8 status,
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
@@ -4523,8 +4522,16 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
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
+static void e1000_vlan_mode(struct net_device *netdev, bool vlan_on)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4532,9 +4539,8 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
-	adapter->vlgrp = grp;
 
-	if (grp) {
+	if (vlan_on) {
 		/* enable VLAN tag insert/strip */
 		ctrl = er32(CTRL);
 		ctrl |= E1000_CTRL_VME;
@@ -4557,11 +4563,6 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 		rctl = er32(RCTL);
 		rctl &= ~E1000_RCTL_VFE;
 		ew32(RCTL, rctl);
-
-		if (adapter->mng_vlan_id != (u16)E1000_MNG_VLAN_NONE) {
-			e1000_vlan_rx_kill_vid(netdev, adapter->mng_vlan_id);
-			adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-		}
 	}
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -4578,11 +4579,17 @@ static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
+
+	if (!e1000_vlan_used(adapter))
+		e1000_vlan_mode(netdev, true);
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
@@ -4593,7 +4600,6 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
 
@@ -4602,20 +4608,23 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
 	e1000_write_vfta(hw, index, vfta);
+
+	clear_bit(vid, adapter->active_vlans);
+
+	if (!e1000_vlan_used(adapter))
+		e1000_vlan_mode(netdev, false);
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
+	e1000_vlan_mode(adapter->netdev, true);
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		e1000_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
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
