From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 2/2] ixgbe: enable l2 forwarding acceleration for macvlans
Date: Wed, 25 Sep 2013 16:16:49 -0400
Message-ID: <1380140209-24587-3-git-send-email-nhorman@tuxdriver.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>, john.fastabend@intel.com,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48757 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3IYURU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 16:17:20 -0400
In-Reply-To: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that l2 acceleration ops are in place from the prior patch, enable ixgbe to
take advantage of these operations.  Allow it to allocate queues for a macvlan
so that when we transmit a frame, we can do the switching in hardware inside the
ixgbe card, rather than in software.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: john.fastabend@intel.com
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  32 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_l2a.h     |  54 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 360 +++++++++++++++++------
 5 files changed, 374 insertions(+), 91 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_l2a.h

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 0ac6b11..cfa6a8b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -244,6 +244,7 @@ struct ixgbe_ring {
 	unsigned long last_rx_timestamp;
 	unsigned long state;
 	u8 __iomem *tail;
+	struct net_device *vmdq_netdev;
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
 
@@ -288,11 +289,15 @@ enum ixgbe_ring_f_enum {
 };
 
 #define IXGBE_MAX_RSS_INDICES  16
-#define IXGBE_MAX_VMDQ_INDICES 64
+#define IXGBE_MAX_VMDQ_INDICES 32
 #define IXGBE_MAX_FDIR_INDICES 63	/* based on q_vector limit */
 #define IXGBE_MAX_FCOE_INDICES  8
 #define MAX_RX_QUEUES (IXGBE_MAX_FDIR_INDICES + 1)
 #define MAX_TX_QUEUES (IXGBE_MAX_FDIR_INDICES + 1)
+#define IXGBE_MAX_L2A_QUEUES 4
+#define IXGBE_MAX_L2A_QUEUES 4
+#define IXGBE_BAD_L2A_QUEUE 3
+
 struct ixgbe_ring_feature {
 	u16 limit;	/* upper limit on feature indices */
 	u16 indices;	/* current value of indices */
@@ -738,6 +743,7 @@ struct ixgbe_adapter {
 #endif /*CONFIG_DEBUG_FS*/
 
 	u8 default_up;
+	unsigned long l2a_bitmask; /* Bitmask indicating in use pools */
 };
 
 struct ixgbe_fdir_filter {
@@ -747,6 +753,17 @@ struct ixgbe_fdir_filter {
 	u16 action;
 };
 
+struct ixgbe_l2a_adapter {
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	struct net_device *netdev;
+	struct ixgbe_adapter *real_adapter;
+	unsigned int tx_base_queue;
+	unsigned int rx_base_queue;
+	struct net_device_stats net_stats;
+	int pool;
+	bool online;
+};
+
 enum ixgbe_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
@@ -879,9 +896,14 @@ static inline void ixgbe_dbg_adapter_exit(struct ixgbe_adapter *adapter) {}
 static inline void ixgbe_dbg_init(void) {}
 static inline void ixgbe_dbg_exit(void) {}
 #endif /* CONFIG_DEBUG_FS */
+static inline struct net_device *netdev_ring(const struct ixgbe_ring *ring)
+{
+	return ring->vmdq_netdev ? ring->vmdq_netdev : ring->netdev;
+}
+
 static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 {
-	return netdev_get_tx_queue(ring->netdev, ring->queue_index);
+	return netdev_get_tx_queue(netdev_ring(ring), ring->queue_index);
 }
 
 extern void ixgbe_ptp_init(struct ixgbe_adapter *adapter);
@@ -915,4 +937,10 @@ extern void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
 void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter);
 #endif
 
+int ixgbe_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd);
+int ixgbe_write_uc_addr_list(struct net_device *netdev);
+netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
+				  struct ixgbe_adapter *adapter,
+				  struct ixgbe_ring *tx_ring);
+void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index e8649ab..277af14 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -150,8 +150,8 @@ static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define IXGBE_TEST_LEN sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN
 
-static int ixgbe_get_settings(struct net_device *netdev,
-                              struct ethtool_cmd *ecmd)
+int ixgbe_get_settings(struct net_device *netdev,
+		       struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_l2a.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_l2a.h
new file mode 100644
index 0000000..2f36584
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_l2a.h
@@ -0,0 +1,54 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2013 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+#include "ixgbe.h"
+
+
+static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
+					   u64 qmask)
+{
+	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mask = (qmask & 0xFFFFFFFF);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
+		mask = (qmask >> 32);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
+		break;
+	default:
+		break;
+	}
+	/* skip the flush */
+}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 90b4e10..e2dd635 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -500,7 +500,8 @@ static bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
 #endif
 
 	/* only proceed if SR-IOV is enabled */
-	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
+	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
+	    !(adapter->flags & IXGBE_FLAG_VMDQ_ENABLED))
 		return false;
 
 	/* Add starting offset to total pool count */
@@ -852,7 +853,11 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 
 		/* apply Tx specific ring traits */
 		ring->count = adapter->tx_ring_count;
-		ring->queue_index = txr_idx;
+		if (adapter->num_rx_pools > 1)
+			ring->queue_index =
+				txr_idx % adapter->num_rx_queues_per_pool;
+		else
+			ring->queue_index = txr_idx;
 
 		/* assign ring to adapter */
 		adapter->tx_ring[txr_idx] = ring;
@@ -895,7 +900,11 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 #endif /* IXGBE_FCOE */
 		/* apply Rx specific ring traits */
 		ring->count = adapter->rx_ring_count;
-		ring->queue_index = rxr_idx;
+		if (adapter->num_rx_pools > 1)
+			ring->queue_index =
+				rxr_idx % adapter->num_rx_queues_per_pool;
+		else
+			ring->queue_index = rxr_idx;
 
 		/* assign ring to adapter */
 		adapter->rx_ring[rxr_idx] = ring;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0ade0cd..dccec86 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -52,6 +52,7 @@
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
+#include "ixgbe_l2a.h"
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
@@ -872,7 +873,8 @@ static u64 ixgbe_get_tx_completed(struct ixgbe_ring *ring)
 
 static u64 ixgbe_get_tx_pending(struct ixgbe_ring *ring)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(ring->netdev);
+	struct net_device *dev = ring->netdev;
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	u32 head = IXGBE_READ_REG(hw, IXGBE_TDH(ring->reg_idx));
@@ -1055,7 +1057,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			tx_ring->next_to_use, i,
 			tx_ring->tx_buffer_info[i].time_stamp, jiffies);
 
-		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+		netif_stop_subqueue(netdev_ring(tx_ring), tx_ring->queue_index);
 
 		e_info(probe,
 		       "tx hang %d detected on queue %d, resetting adapter\n",
@@ -1072,16 +1074,16 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 				  total_packets, total_bytes);
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
-	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
+	if (unlikely(total_packets && netif_carrier_ok(netdev_ring(tx_ring)) &&
 		     (ixgbe_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
-		if (__netif_subqueue_stopped(tx_ring->netdev,
+		if (__netif_subqueue_stopped(netdev_ring(tx_ring),
 					     tx_ring->queue_index)
 		    && !test_bit(__IXGBE_DOWN, &adapter->state)) {
-			netif_wake_subqueue(tx_ring->netdev,
+			netif_wake_subqueue(netdev_ring(tx_ring),
 					    tx_ring->queue_index);
 			++tx_ring->tx_stats.restart_queue;
 		}
@@ -1226,7 +1228,7 @@ static inline void ixgbe_rx_hash(struct ixgbe_ring *ring,
 				 union ixgbe_adv_rx_desc *rx_desc,
 				 struct sk_buff *skb)
 {
-	if (ring->netdev->features & NETIF_F_RXHASH)
+	if (netdev_ring(ring)->features & NETIF_F_RXHASH)
 		skb->rxhash = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
 }
 
@@ -1260,10 +1262,12 @@ static inline void ixgbe_rx_checksum(struct ixgbe_ring *ring,
 				     union ixgbe_adv_rx_desc *rx_desc,
 				     struct sk_buff *skb)
 {
+	struct net_device *dev = netdev_ring(ring);
+
 	skb_checksum_none_assert(skb);
 
 	/* Rx csum disabled */
-	if (!(ring->netdev->features & NETIF_F_RXCSUM))
+	if (!(dev->features & NETIF_F_RXCSUM))
 		return;
 
 	/* if IP and error */
@@ -1559,7 +1563,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 				     union ixgbe_adv_rx_desc *rx_desc,
 				     struct sk_buff *skb)
 {
-	struct net_device *dev = rx_ring->netdev;
+	struct net_device *dev = netdev_ring(rx_ring);
 
 	ixgbe_update_rsc_stats(rx_ring, skb);
 
@@ -1739,7 +1743,7 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 				  union ixgbe_adv_rx_desc *rx_desc,
 				  struct sk_buff *skb)
 {
-	struct net_device *netdev = rx_ring->netdev;
+	struct net_device *netdev = netdev_ring(rx_ring);
 
 	/* verify that the packet does not have any known errors */
 	if (unlikely(ixgbe_test_staterr(rx_desc,
@@ -1905,7 +1909,7 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 #endif
 
 		/* allocate a skb to store the frags */
-		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+		skb = netdev_alloc_skb_ip_align(netdev_ring(rx_ring),
 						IXGBE_RX_HDR_SIZE);
 		if (unlikely(!skb)) {
 			rx_ring->rx_stats.alloc_rx_buff_failed++;
@@ -1986,6 +1990,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int ddp_bytes;
 	unsigned int mss = 0;
+	struct net_device *netdev = netdev_ring(rx_ring);
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
 
@@ -2041,7 +2046,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			/* include DDPed FCoE data */
 			if (ddp_bytes > 0) {
 				if (!mss) {
-					mss = rx_ring->netdev->mtu -
+					mss = netdev->mtu -
 						sizeof(struct fcoe_hdr) -
 						sizeof(struct fc_frame_header) -
 						sizeof(struct fcoe_crc_eof);
@@ -2455,58 +2460,6 @@ static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 	}
 }
 
-static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
-					   u64 qmask)
-{
-	u32 mask;
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	switch (hw->mac.type) {
-	case ixgbe_mac_82598EB:
-		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, mask);
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask = (qmask & 0xFFFFFFFF);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(0), mask);
-		mask = (qmask >> 32);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS_EX(1), mask);
-		break;
-	default:
-		break;
-	}
-	/* skip the flush */
-}
-
-static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
-					    u64 qmask)
-{
-	u32 mask;
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	switch (hw->mac.type) {
-	case ixgbe_mac_82598EB:
-		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(hw, IXGBE_EIMC, mask);
-		break;
-	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
-		mask = (qmask & 0xFFFFFFFF);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
-		mask = (qmask >> 32);
-		if (mask)
-			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
-		break;
-	default:
-		break;
-	}
-	/* skip the flush */
-}
-
 /**
  * ixgbe_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
@@ -2946,6 +2899,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 			     struct ixgbe_ring *ring)
 {
+	struct net_device *netdev = netdev_ring(ring);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 tdba = ring->dma;
 	int wait_loop = 10;
@@ -3005,7 +2959,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 		struct ixgbe_q_vector *q_vector = ring->q_vector;
 
 		if (q_vector)
-			netif_set_xps_queue(adapter->netdev,
+			netif_set_xps_queue(netdev,
 					    &q_vector->affinity_mask,
 					    ring->queue_index);
 	}
@@ -3395,7 +3349,7 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int rss_i = adapter->ring_feature[RING_F_RSS].indices;
-	int p;
+	u16 pool;
 
 	/* PSRTYPE must be initialized in non 82598 adapters */
 	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
@@ -3412,9 +3366,8 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 	else if (rss_i > 1)
 		psrtype |= 1 << 29;
 
-	for (p = 0; p < adapter->num_rx_pools; p++)
-		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(p)),
-				psrtype);
+	for_each_set_bit(pool, &adapter->l2a_bitmask, 32)
+		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(pool)), psrtype);
 }
 
 static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
@@ -3683,6 +3636,8 @@ static void ixgbe_vlan_strip_disable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			if (adapter->rx_ring[i]->vmdq_netdev)
+				continue;
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl &= ~IXGBE_RXDCTL_VME;
@@ -3713,6 +3668,8 @@ static void ixgbe_vlan_strip_enable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			if (adapter->rx_ring[i]->vmdq_netdev)
+				continue;
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl |= IXGBE_RXDCTL_VME;
@@ -3743,15 +3700,16 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
  *                0 on no addresses written
  *                X on writing X addresses to the RAR table
  **/
-static int ixgbe_write_uc_addr_list(struct net_device *netdev)
+int ixgbe_write_uc_addr_list(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	unsigned int rar_entries = hw->mac.num_rar_entries - 1;
 	int count = 0;
 
-	/* In SR-IOV mode significantly less RAR entries are available */
-	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+	/* In SR-IOV/VMDQ modes significantly less RAR entries are available */
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED ||
+	    adapter->flags & IXGBE_FLAG_VMDQ_ENABLED)
 		rar_entries = IXGBE_MAX_PF_MACVLANS - 1;
 
 	/* return ENOMEM indicating insufficient memory for addresses */
@@ -3772,6 +3730,7 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 			count++;
 		}
 	}
+
 	/* write the addresses in reverse order to avoid write combining */
 	for (; rar_entries > 0 ; rar_entries--)
 		hw->mac.ops.clear_rar(hw, rar_entries);
@@ -4133,6 +4092,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_set_rx_mode(adapter->netdev);
+
 	ixgbe_restore_vlan(adapter);
 
 	switch (hw->mac.type) {
@@ -4459,7 +4419,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
  * @rx_ring: ring to free buffers from
  **/
-static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
+void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
 	unsigned long size;
@@ -4838,6 +4798,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
+	/* PF holds first pool slot */
+	set_bit(0, &adapter->l2a_bitmask);
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -5143,7 +5105,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int err;
+	int err, queues;
 
 	/* disallow open during test */
 	if (test_bit(__IXGBE_TESTING, &adapter->state))
@@ -5168,16 +5130,22 @@ static int ixgbe_open(struct net_device *netdev)
 		goto err_req_irq;
 
 	/* Notify the stack of the actual queue counts. */
-	err = netif_set_real_num_tx_queues(netdev,
-					   adapter->num_rx_pools > 1 ? 1 :
-					   adapter->num_tx_queues);
+	if (adapter->num_rx_pools > 1 &&
+	    adapter->num_tx_queues > IXGBE_MAX_L2A_QUEUES)
+		queues = IXGBE_MAX_L2A_QUEUES;
+	else
+		queues = adapter->num_tx_queues;
+
+	err = netif_set_real_num_tx_queues(netdev, queues);
 	if (err)
 		goto err_set_queues;
 
-
-	err = netif_set_real_num_rx_queues(netdev,
-					   adapter->num_rx_pools > 1 ? 1 :
-					   adapter->num_rx_queues);
+	if (adapter->num_rx_pools > 1 &&
+	    adapter->num_rx_queues > IXGBE_MAX_L2A_QUEUES)
+		queues = IXGBE_MAX_L2A_QUEUES;
+	else
+		queues = adapter->num_rx_queues;
+	err = netif_set_real_num_rx_queues(netdev, queues);
 	if (err)
 		goto err_set_queues;
 
@@ -5215,7 +5183,6 @@ static int ixgbe_close(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	ixgbe_ptp_stop(adapter);
-
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
 
@@ -6576,7 +6543,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 
 static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 {
-	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	netif_stop_subqueue(netdev_ring(tx_ring), tx_ring->queue_index);
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -6588,7 +6555,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	netif_start_subqueue(netdev_ring(tx_ring), tx_ring->queue_index);
 	++tx_ring->tx_stats.restart_queue;
 	return 0;
 }
@@ -6639,6 +6606,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *first;
+#ifdef IXGBE_FCOE
+	struct net_device *dev;
+#endif
 	int tso;
 	u32 tx_flags = 0;
 	unsigned short f;
@@ -6730,9 +6700,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	first->protocol = protocol;
 
 #ifdef IXGBE_FCOE
+	dev = netdev_ring(tx_ring);
 	/* setup tx offload for FCoE */
 	if ((protocol == __constant_htons(ETH_P_FCOE)) &&
-	    (tx_ring->netdev->features & (NETIF_F_FSO | NETIF_F_FCOE_CRC))) {
+	    (dev->features & (NETIF_F_FSO | NETIF_F_FCOE_CRC))) {
 		tso = ixgbe_fso(tx_ring, first, &hdr_len);
 		if (tso < 0)
 			goto out_drop;
@@ -7057,6 +7028,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	 */
 	if (netif_running(dev))
 		ixgbe_close(dev);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_IXGBE_DCB
@@ -7305,6 +7277,219 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
 }
 
+static void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter, u64 qmask)
+{
+	u32 mask;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(hw, IXGBE_EIMC, mask);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		mask = (qmask & 0xFFFFFFFF);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(0), mask);
+		mask = (qmask >> 32);
+		if (mask)
+			IXGBE_WRITE_REG(hw, IXGBE_EIMC_EX(1), mask);
+		break;
+	default:
+		break;
+	}
+}
+
+static void ixgbe_add_mac_filter(struct ixgbe_adapter *adapter,
+				 u8 *addr, u16 pool)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned int entry;
+
+	entry = hw->mac.num_rar_entries - pool;
+	hw->mac.ops.set_rar(hw, entry, addr, VMDQ_P(pool), IXGBE_RAH_AV);
+}
+
+static void ixgbe_l2a_psrtype(struct ixgbe_l2a_adapter *vadapter)
+{
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	int rss_i = vadapter->netdev->real_num_rx_queues;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 pool = vadapter->pool;
+	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
+		      IXGBE_PSRTYPE_UDPHDR |
+		      IXGBE_PSRTYPE_IPV4HDR |
+		      IXGBE_PSRTYPE_L2HDR |
+		      IXGBE_PSRTYPE_IPV6HDR;
+
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		return;
+
+	if (rss_i > 3)
+		psrtype |= 2 << 29;
+	else if (rss_i > 1)
+		psrtype |= 1 << 29;
+
+	IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(pool)), psrtype);
+}
+
+static void ixgbe_enable_l2a_ring(struct ixgbe_adapter *adapter,
+				  struct ixgbe_ring *rx_ring)
+{
+	ixgbe_configure_rx_ring(adapter, rx_ring);
+}
+
+
+static void ixgbe_disable_l2a_ring(struct ixgbe_l2a_adapter *vadapter,
+				   struct ixgbe_ring *rx_ring)
+{
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	int index = rx_ring->queue_index + vadapter->rx_base_queue;
+
+	/* shutdown specific queue receive and wait for dma to settle */
+	ixgbe_disable_rx_queue(adapter, rx_ring);
+	usleep_range(10000, 20000);
+	ixgbe_irq_disable_queues(adapter, ((u64)1 << index));
+	ixgbe_clean_rx_ring(rx_ring);
+}
+
+int ixgbe_l2a_ring_up(struct net_device *vdev, struct ixgbe_l2a_adapter *accel)
+{
+	struct ixgbe_adapter *adapter = accel->real_adapter;
+	unsigned int rxbase = accel->pool * adapter->num_rx_queues_per_pool;
+	unsigned int txbase = accel->pool * adapter->num_rx_queues_per_pool;
+	int err, i;
+
+
+	accel->rx_base_queue = rxbase;
+	accel->tx_base_queue = txbase;
+
+	for (i = 0; i < vdev->num_rx_queues; i++)
+		ixgbe_disable_l2a_ring(accel, adapter->rx_ring[rxbase + i]);
+
+	for (i = 0; i < vdev->num_rx_queues; i++) {
+		adapter->rx_ring[rxbase + i]->vmdq_netdev = vdev;
+		ixgbe_enable_l2a_ring(adapter, adapter->rx_ring[rxbase + i]);
+	}
+
+	for (i = 0; i < vdev->num_tx_queues; i++)
+		adapter->tx_ring[txbase + i]->vmdq_netdev = vdev;
+
+	if (is_valid_ether_addr(vdev->dev_addr))
+		ixgbe_add_mac_filter(adapter, vdev->dev_addr, accel->pool);
+
+	err = netif_set_real_num_tx_queues(vdev, vdev->num_tx_queues);
+	if (err)
+		goto err_set_queues;
+	err = netif_set_real_num_rx_queues(vdev, vdev->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
+	ixgbe_l2a_psrtype(accel);
+	netif_tx_start_all_queues(vdev);
+	return 0;
+err_set_queues:
+	for (i = 0; i < vdev->num_rx_queues; i++)
+		ixgbe_disable_l2a_ring(accel, adapter->rx_ring[rxbase + i]);
+	return err;
+}
+
+int ixgbe_l2a_ring_down(struct net_device *vdev, struct ixgbe_l2a_adapter *accel)
+{
+	struct ixgbe_adapter *adapter = accel->real_adapter;
+	unsigned int rxbase = accel->rx_base_queue;
+	int i;
+
+	netif_tx_stop_all_queues(vdev);
+
+	for (i = 0; i < vdev->num_rx_queues; i++)
+		ixgbe_disable_l2a_ring(accel, adapter->rx_ring[rxbase + i]);
+
+	return 0;
+}
+
+static int ixgbe_l2a_add(struct net_device *pdev, struct net_device *vdev,
+			 void *priv)
+{
+	struct ixgbe_l2a_adapter *l2a_adapter = priv;
+	struct ixgbe_adapter *adapter = netdev_priv(pdev);
+	int pool, vmdq_pool, base_queue;
+	int err;
+
+	/* Check for hardware restriction on number of rx/tx queues */
+	if (vdev->num_rx_queues != vdev->num_tx_queues ||
+	    vdev->num_tx_queues > IXGBE_MAX_L2A_QUEUES ||
+	    vdev->num_tx_queues == IXGBE_BAD_L2A_QUEUE) {
+		netdev_info(pdev, "%s: Supports RX/TX Queue counts 1,2, and 4\n",
+		       pdev->name);
+		return -EINVAL;
+	}
+
+	if (adapter->num_rx_pools > IXGBE_MAX_VMDQ_INDICES)
+		return -EBUSY;
+
+	pool = find_first_zero_bit(&adapter->l2a_bitmask, 32);
+	adapter->num_rx_pools++;
+	set_bit(pool, &adapter->l2a_bitmask);
+
+	/* Enable VMDq flag so device will be set in VM mode */
+	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_SRIOV_ENABLED;
+	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
+	adapter->ring_feature[RING_F_VMDQ].offset = 0;
+	adapter->ring_feature[RING_F_RSS].limit = IXGBE_MAX_L2A_QUEUES;
+
+	/* Force reinit of ring allocation with VMDQ enabled */
+	ixgbe_setup_tc(pdev, netdev_get_num_tc(pdev));
+
+	/* Configure VSI adapter structure */
+	vmdq_pool = VMDQ_P(pool);
+	base_queue = vmdq_pool * adapter->num_rx_queues_per_pool;
+
+	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   pool, adapter->num_rx_pools,
+		   base_queue, base_queue + adapter->num_rx_queues_per_pool,
+		   adapter->l2a_bitmask);
+
+	l2a_adapter->pool = pool;
+	l2a_adapter->netdev = vdev;
+	l2a_adapter->real_adapter = adapter;
+	l2a_adapter->rx_base_queue = base_queue;
+	l2a_adapter->tx_base_queue = base_queue;
+
+	err = ixgbe_l2a_ring_up(vdev, l2a_adapter);	
+	return err;
+}
+
+static void ixgbe_l2a_del(struct net_device *pdev, void *priv)
+{
+	struct ixgbe_l2a_adapter *l2a_adapter = priv; 
+	struct ixgbe_adapter *adapter = l2a_adapter->real_adapter;
+
+	clear_bit(l2a_adapter->pool, &adapter->l2a_bitmask);
+	adapter->num_rx_pools--;
+
+	ixgbe_l2a_ring_down(l2a_adapter->netdev, l2a_adapter);
+
+	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   l2a_adapter->pool, adapter->num_rx_pools,
+		   l2a_adapter->rx_base_queue,
+		   l2a_adapter->rx_base_queue + adapter->num_rx_queues_per_pool,
+		   adapter->l2a_bitmask);
+}
+
+netdev_tx_t ixgbe_l2a_xmit_frame(struct sk_buff *skb, void *priv)
+{
+	struct ixgbe_l2a_adapter *l2a_adapter = priv;
+	struct ixgbe_ring *tx_ring;
+	unsigned int queue;
+
+	queue = skb->queue_mapping + l2a_adapter->tx_base_queue;
+	tx_ring = l2a_adapter->real_adapter->tx_ring[queue];
+
+	return ixgbe_xmit_frame_ring(skb, l2a_adapter->real_adapter, tx_ring);
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7351,6 +7536,13 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 };
 
+const struct l2_forwarding_accel_ops  ixgbe_l2a_ops = {
+	.priv_size = sizeof(struct ixgbe_l2a_adapter),
+	.l2_accel_add_dev = ixgbe_l2a_add,
+	.l2_accel_del_dev = ixgbe_l2a_del,
+	.l2_accel_xmit = ixgbe_l2a_xmit_frame,
+};
+
 /**
  * ixgbe_enumerate_functions - Get the number of ports this device has
  * @adapter: adapter structure
-- 
1.8.3.1
