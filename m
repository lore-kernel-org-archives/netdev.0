From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 37/47] igb: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:39 +0200
Message-ID: <1311173689-17419-38-git-send-email-jpirko@redhat.com>
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
- kill adapter->vlgrp and igb_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/igb/igb.h      |    4 ++-
 drivers/net/igb/igb_main.c |   79 +++++++++++++++++++++-----------------------
 2 files changed, 41 insertions(+), 42 deletions(-)

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
index f4d82b2..50f264f 100644
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
+static bool igb_vlan_used(struct igb_adapter *adapter);
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
@@ -1775,7 +1777,6 @@ static const struct net_device_ops igb_netdev_ops = {
 	.ndo_do_ioctl		= igb_ioctl,
 	.ndo_tx_timeout		= igb_tx_timeout,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register	= igb_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= igb_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= igb_vlan_rx_kill_vid,
 	.ndo_set_vf_mac		= igb_ndo_set_vf_mac,
@@ -2943,7 +2944,7 @@ static void igb_rlpml_set(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u16 pf_id = adapter->vfs_allocated_count;
 
-	if (adapter->vlgrp)
+	if (igb_vlan_used(adapter))
 		max_frame_size += VLAN_TAG_SIZE;
 
 	/* if vfs are enabled we set RLPML to the largest possible request
@@ -5693,25 +5694,6 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
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
@@ -5809,7 +5791,6 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 	unsigned int i;
 	u32 staterr;
 	u16 length;
-	u16 vlan_tag;
 
 	i = rx_ring->next_to_clean;
 	buffer_info = &rx_ring->buffer_info[i];
@@ -5894,10 +5875,12 @@ send_up:
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
@@ -6290,17 +6273,24 @@ s32 igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 	return 0;
 }
 
-static void igb_vlan_rx_register(struct net_device *netdev,
-				 struct vlan_group *grp)
+static bool igb_vlan_used(struct igb_adapter *adapter)
+{
+	u16 vid;
+
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		return true;
+	return false;
+}
+
+static void igb_vlan_mode(struct net_device *netdev, bool vlan_on)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
 
 	igb_irq_disable(adapter);
-	adapter->vlgrp = grp;
 
-	if (grp) {
+	if (vlan_on) {
 		/* enable VLAN tag insert/strip */
 		ctrl = rd32(E1000_CTRL);
 		ctrl |= E1000_CTRL_VME;
@@ -6329,11 +6319,16 @@ static void igb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 	struct e1000_hw *hw = &adapter->hw;
 	int pf_id = adapter->vfs_allocated_count;
 
+	if (!igb_vlan_used(adapter))
+		igb_vlan_mode(netdev, true);
+
 	/* attempt to add filter to vlvf array */
 	igb_vlvf_set(adapter, vid, true, pf_id);
 
 	/* add the filter since PF can receive vlans w/o entry in vlvf */
 	igb_vfta_set(hw, vid, true);
+
+	set_bit(vid, adapter->active_vlans);
 }
 
 static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
@@ -6344,7 +6339,6 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	s32 err;
 
 	igb_irq_disable(adapter);
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
 
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		igb_irq_enable(adapter);
@@ -6355,20 +6349,23 @@ static void igb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	/* if vid was not present in VLVF just remove it from table */
 	if (err)
 		igb_vfta_set(hw, vid, false);
+
+	clear_bit(vid, adapter->active_vlans);
+
+	if (!igb_vlan_used(adapter))
+		igb_vlan_mode(netdev, false);
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
+	if (!igb_vlan_used(adapter))
+		return;
+
+	igb_vlan_mode(adapter->netdev, true);
+	for_each_set_bit(vid, adapter->active_vlans, VLAN_N_VID)
+		igb_vlan_rx_add_vid(adapter->netdev, vid);
 }
 
 int igb_set_spd_dplx(struct igb_adapter *adapter, u32 spd, u8 dplx)
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
