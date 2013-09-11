From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 4/4] ixgbe: Adding VSI support to ixgbe
Date: Wed, 11 Sep 2013 11:47:45 -0700
Message-ID: <20130911184744.26914.77691.stgit@nitbit.x32>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:58863 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037Ab3IKSsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:48:06 -0400
Received: by mail-ob0-f173.google.com with SMTP id ta17so8842004obb.18
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:48:04 -0700 (PDT)
In-Reply-To: <20130911184441.26914.10336.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds initial base support for VSI interfaces to the ixgbe
driver.

This supports up to 32 VSIs per physical function with each VSI
supporting up to 4 TX/RX queue pairs. The hardware has support
for modes using 2 queue pairs that enable up to 64 VSIs but they
are not enabled here. VSIs can be instantiated with 1,2, or 4
queues unfortunately due to hardware restrictions related to RSS
masking across queues 3 TX/RX queues is not supported. If a user
inputs a queue parameter of 3 for either TX or RX the vsi_add
will fail with EINVAL and a message will be printed to dmesg
explaining the error. EBUSY is returned if more than 32 VSIs are
added.

The driver uses a bitmask added to the ixgbe_adapter struct to
track VSIs. VSIs spawn net devices that can be independently
managed via their own ndo and ethtool ops.

Currently, MAC addresses must be added manually via 'ip link set'
or similar configuration (netlink) commands before bringing the
spawned devices online. I could easily generate random MAC addresses
if that is prefered although not required in my use case and seems
a bit arbitrary. I expect most users have a pool of known "good"
MAC addresses they can use or for testing can simply pick their
favorite address.

Additionally VSIs do not support promisc mode. It is not clear
to me at least what promiscuous mode means when the VSI is behind
a non-learning embedded bridge wich does not do flooding. The
hardware does not support flooding on the embedded bridge however
it does support mirroring which could be enabled to get something
that looks like promiscuous mode. Currently there is no kernel
support (netlink cmd?) to configure mirroring.

The embedded bridge that connects VSIs looks like an edge relay
in IEEE std terms. And can support both VEB and VEPA modes which
are managed independently of VSIs through the {set|get} bridge
APIs.

VSIs only support a single MAC addresses in this patch. This
is a software limitation and can/will be extended in subsequent
patches. For now a single MAC addresses is supported.

NOTE:
The SRIOV and VMDQ flags in ixgbe seem to be a bit overloaded
and convoluted. This patch uses these flags. A follow up patch
could clean up the ixgbe flag usage scheme.

RFC TODO: I'll complete these before sending the real patch
(1) interop with DCB/FCOE/SR-IOV
(2) vmdq_netdev can be dropped from tx_ring and just use
    correctly set netdev. In slowpath we can look up management
    netdev via vadapter->real_adapter->netdev and save the hotpath
    vmdq_netdev if/else branch.

Otherwise I've been adding/delete VSIs with multiple netperf
TCP sessions without any crashes but I still need to do some
more testing.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile        |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   32 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    4 
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   15 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  307 +++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c     |  428 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h     |   71 ++++
 7 files changed, 766 insertions(+), 94 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index be2989e..24136e7 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -34,7 +34,8 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o ixgbe_ptp.o
+              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o ixgbe_ptp.o \
+	      ixgbe_vsi.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 0ac6b11..ba2ab14 100644
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
+#define IXGBE_MAX_VSI_QUEUES 4
+#define IXGBE_MAX_VSI_QUEUES 4
+#define IXGBE_BAD_VSI_QUEUE 3
+
 struct ixgbe_ring_feature {
 	u16 limit;	/* upper limit on feature indices */
 	u16 indices;	/* current value of indices */
@@ -738,6 +743,7 @@ struct ixgbe_adapter {
 #endif /*CONFIG_DEBUG_FS*/
 
 	u8 default_up;
+	unsigned long vsi_bitmask; /* Bitmask indicating in use pools */
 };
 
 struct ixgbe_fdir_filter {
@@ -747,6 +753,17 @@ struct ixgbe_fdir_filter {
 	u16 action;
 };
 
+struct ixgbe_vsi_adapter {
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
index 0e1b973..48b2d81 100644
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
index 7aba452..3a2138a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -52,6 +52,7 @@
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
+#include "ixgbe_vsi.h"
 
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
+	for_each_set_bit(pool, &adapter->vsi_bitmask, 32)
+		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(pool)), psrtype);
 }
 
 static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
@@ -3676,6 +3629,8 @@ static void ixgbe_vlan_strip_disable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			if (adapter->rx_ring[i]->vmdq_netdev)
+				continue;
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl &= ~IXGBE_RXDCTL_VME;
@@ -3706,6 +3661,8 @@ static void ixgbe_vlan_strip_enable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			if (adapter->rx_ring[i]->vmdq_netdev)
+				continue;
 			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl |= IXGBE_RXDCTL_VME;
@@ -3736,15 +3693,16 @@ static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
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
@@ -3765,6 +3723,7 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 			count++;
 		}
 	}
+
 	/* write the addresses in reverse order to avoid write combining */
 	for (; rar_entries > 0 ; rar_entries--)
 		hw->mac.ops.clear_rar(hw, rar_entries);
@@ -4114,6 +4073,8 @@ static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *upper;
+	struct list_head *iter;
 
 	ixgbe_configure_pb(adapter);
 #ifdef CONFIG_IXGBE_DCB
@@ -4126,6 +4087,13 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_virtualization(adapter);
 
 	ixgbe_set_rx_mode(adapter->netdev);
+	netdev_for_each_upper_dev_rcu(adapter->netdev, upper, iter) {
+		if (!netif_is_vsi_port(upper))
+			continue;
+
+		ixgbe_vsi_set_rx_mode(upper);
+	}
+
 	ixgbe_restore_vlan(adapter);
 
 	switch (hw->mac.type) {
@@ -4452,7 +4420,7 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
  * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
  * @rx_ring: ring to free buffers from
  **/
-static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
+void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
 	unsigned long size;
@@ -4576,8 +4544,9 @@ static void ixgbe_fdir_filter_exit(struct ixgbe_adapter *adapter)
 
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *upper, *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct list_head *iter;
 	u32 rxctrl;
 	int i;
 
@@ -4588,6 +4557,14 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
+	/* disable all VSIs */
+	netdev_for_each_upper_dev_rcu(netdev, upper, iter) {
+		if (!netif_is_vsi_port(upper))
+			continue;
+		if (netif_running(upper))
+			ixgbe_vsi_down(upper);
+	}
+
 	/* disable all enabled rx queues */
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		/* this call also flushes the previous write */
@@ -4831,6 +4808,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
+	/* PF holds first pool slot */
+	set_bit(0, &adapter->vsi_bitmask);
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -5136,7 +5115,9 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int err;
+	struct net_device *upper;
+	struct list_head *iter;
+	int err, queues;
 
 	/* disallow open during test */
 	if (test_bit(__IXGBE_TESTING, &adapter->state))
@@ -5161,16 +5142,22 @@ static int ixgbe_open(struct net_device *netdev)
 		goto err_req_irq;
 
 	/* Notify the stack of the actual queue counts. */
-	err = netif_set_real_num_tx_queues(netdev,
-					   adapter->num_rx_pools > 1 ? 1 :
-					   adapter->num_tx_queues);
+	if (adapter->num_rx_pools > 1 &&
+	    adapter->num_tx_queues > IXGBE_MAX_VSI_QUEUES)
+		queues = IXGBE_MAX_VSI_QUEUES;
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
+	    adapter->num_rx_queues > IXGBE_MAX_VSI_QUEUES)
+		queues = IXGBE_MAX_VSI_QUEUES;
+	else
+		queues = adapter->num_rx_queues;
+	err = netif_set_real_num_rx_queues(netdev, queues);
 	if (err)
 		goto err_set_queues;
 
@@ -5178,6 +5165,16 @@ static int ixgbe_open(struct net_device *netdev)
 
 	ixgbe_up_complete(adapter);
 
+	netdev_for_each_upper_dev_rcu(netdev, upper, iter) {
+		struct ixgbe_vsi_adapter *vadapter;
+
+		if (!netif_is_vsi_port(upper))
+			continue;
+		vadapter = netdev_priv(upper);
+		if (vadapter->online)
+			ixgbe_vsi_up(upper);
+	}
+
 	return 0;
 
 err_set_queues:
@@ -5208,7 +5205,6 @@ static int ixgbe_close(struct net_device *netdev)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	ixgbe_ptp_stop(adapter);
-
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
 
@@ -5383,9 +5379,10 @@ static void ixgbe_shutdown(struct pci_dev *pdev)
  **/
 void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
+	struct net_device *vsi, *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_hw_stats *hwstats = &adapter->stats;
+	struct list_head *iter;
 	u64 total_mpc = 0;
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 	u64 non_eop_descs = 0, restart_queue = 0, tx_busy = 0;
@@ -5407,6 +5404,34 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		adapter->rsc_total_flush = rsc_flush;
 	}
 
+	netdev_for_each_upper_dev_rcu(netdev, vsi, iter) {
+		struct net_device_stats *vmdq_net_stats;
+		struct ixgbe_ring *rx_ring, *tx_ring;
+		struct ixgbe_vsi_adapter *vadapter;
+		unsigned int txq, rxq;
+		int j;
+
+		if (!netif_is_vsi_port(vsi))
+			continue;
+
+		vmdq_net_stats = &vsi->stats;
+		vadapter = netdev_priv(vsi);
+		txq = vadapter->tx_base_queue;
+		rxq = vadapter->rx_base_queue;
+
+		for (j = txq; j < txq + adapter->num_rx_queues_per_pool; j++) {
+			tx_ring = adapter->tx_ring[j];
+			vmdq_net_stats->tx_packets = tx_ring->stats.packets;
+			vmdq_net_stats->tx_bytes = tx_ring->stats.bytes;
+		}
+
+		for (j = rxq; j < rxq + adapter->num_rx_queues_per_pool; j++) {
+			rx_ring = adapter->rx_ring[j];
+			vmdq_net_stats->rx_packets = rx_ring->stats.packets;
+			vmdq_net_stats->rx_bytes = rx_ring->stats.bytes;
+		}
+	}
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct ixgbe_ring *rx_ring = adapter->rx_ring[i];
 		non_eop_descs += rx_ring->rx_stats.non_eop_descs;
@@ -5743,6 +5768,8 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 link_speed = adapter->link_speed;
+	struct net_device *upper;
+	struct list_head *iter;
 	bool flow_rx, flow_tx;
 
 	/* only continue if link was previously down */
@@ -5798,6 +5825,11 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 
 	/* ping all the active vfs to let them know link has changed */
 	ixgbe_ping_all_vfs(adapter);
+	netdev_for_each_upper_dev_rcu(netdev, upper, iter) {
+		if (!netif_is_vsi_port(upper))
+			continue;
+		netif_carrier_on(upper);
+	}
 }
 
 /**
@@ -5809,6 +5841,8 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *upper;
+	struct list_head *iter;
 
 	adapter->link_up = false;
 	adapter->link_speed = 0;
@@ -5829,6 +5863,11 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 
 	/* ping all the active vfs to let them know link has changed */
 	ixgbe_ping_all_vfs(adapter);
+	netdev_for_each_upper_dev_rcu(netdev, upper, iter) {
+		if (!netif_is_vsi_port(upper))
+			continue;
+		netif_carrier_off(upper);
+	}
 }
 
 /**
@@ -6561,7 +6600,7 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 
 static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 {
-	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	netif_stop_subqueue(netdev_ring(tx_ring), tx_ring->queue_index);
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -6573,7 +6612,7 @@ static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	netif_start_subqueue(netdev_ring(tx_ring), tx_ring->queue_index);
 	++tx_ring->tx_stats.restart_queue;
 	return 0;
 }
@@ -6624,6 +6663,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 			  struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *first;
+#ifdef IXGBE_FCOE
+	struct net_device *dev;
+#endif
 	int tso;
 	u32 tx_flags = 0;
 	unsigned short f;
@@ -6715,9 +6757,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
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
@@ -7042,6 +7085,7 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	 */
 	if (netif_running(dev))
 		ixgbe_close(dev);
+
 	ixgbe_clear_interrupt_scheme(adapter);
 
 #ifdef CONFIG_IXGBE_DCB
@@ -7290,6 +7334,94 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
 }
 
+static const struct net_device_ops ixgbe_vsi_netdev_ops = {
+	.ndo_init		= ixgbe_vsi_init,
+	.ndo_open		= ixgbe_vsi_open,
+	.ndo_stop		= ixgbe_vsi_close,
+	.ndo_start_xmit		= ixgbe_vsi_xmit_frame,
+	.ndo_set_rx_mode	= ixgbe_vsi_set_rx_mode,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= ixgbe_vsi_set_mac,
+	.ndo_change_mtu		= ixgbe_vsi_change_mtu,
+	.ndo_tx_timeout		= ixgbe_vsi_tx_timeout,
+	.ndo_vlan_rx_add_vid	= ixgbe_vsi_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= ixgbe_vsi_vlan_rx_kill_vid,
+	.ndo_set_features	= ixgbe_vsi_set_features,
+};
+
+static int ixgbe_vsi_add(struct net_device *dev, struct net_device *vsi)
+{
+	struct ixgbe_vsi_adapter *vsi_adapter = netdev_priv(vsi);
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int pool, vmdq_pool, base_queue;
+
+	/* Check for hardware restriction on number of rx/tx queues */
+	if (vsi->num_rx_queues != vsi->num_tx_queues ||
+	    vsi->num_tx_queues > IXGBE_MAX_VSI_QUEUES ||
+	    vsi->num_tx_queues == IXGBE_BAD_VSI_QUEUE) {
+		e_info(drv, "%s: Supports RX/TX Queue counts 1,2, and 4\n",
+		       dev->name);
+		return -EINVAL;
+	}
+
+	if (adapter->num_rx_pools > IXGBE_MAX_VMDQ_INDICES)
+		return -EBUSY;
+
+	pool = find_first_zero_bit(&adapter->vsi_bitmask, 32);
+	adapter->num_rx_pools++;
+	set_bit(pool, &adapter->vsi_bitmask);
+
+	/* Enable VMDq flag so device will be set in VM mode */
+	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_SRIOV_ENABLED;
+	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
+	adapter->ring_feature[RING_F_VMDQ].offset = 0;
+	adapter->ring_feature[RING_F_RSS].limit = IXGBE_MAX_VSI_QUEUES;
+
+	/* Force reinit of ring allocation with VMDQ enabled */
+	ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
+
+	/* Configure VSI adapter structure */
+	vmdq_pool = VMDQ_P(pool);
+	base_queue = vmdq_pool * adapter->num_rx_queues_per_pool;
+
+	netdev_dbg(dev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   pool, adapter->num_rx_pools,
+		   base_queue, base_queue + adapter->num_rx_queues_per_pool,
+		   adapter->vsi_bitmask);
+
+	vsi_adapter->pool = pool;
+	vsi_adapter->netdev = vsi;
+	vsi_adapter->real_adapter = adapter;
+	vsi_adapter->rx_base_queue = base_queue;
+	vsi_adapter->tx_base_queue = base_queue;
+
+	vsi->netdev_ops = &ixgbe_vsi_netdev_ops;
+	ixgbe_vsi_set_ethtool_ops(vsi);
+
+	return 0;
+}
+
+static void ixgbe_vsi_del(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+
+	ixgbe_vsi_close(dev);
+	clear_bit(vadapter->pool, &adapter->vsi_bitmask);
+	adapter->num_rx_pools--;
+
+	netdev_dbg(dev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   vadapter->pool, adapter->num_rx_pools,
+		   vadapter->rx_base_queue,
+		   vadapter->rx_base_queue + adapter->num_rx_queues_per_pool,
+		   adapter->vsi_bitmask);
+}
+
+size_t ixgbe_vsi_size(struct net_device *dev)
+{
+	return sizeof(struct ixgbe_vsi_adapter);
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7334,6 +7466,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
+	.ndo_vsi_add		= ixgbe_vsi_add,
+	.ndo_vsi_del		= ixgbe_vsi_del,
+	.ndo_vsi_size		= ixgbe_vsi_size
 };
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c
new file mode 100644
index 0000000..48ad793
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.c
@@ -0,0 +1,428 @@
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
+#include <linux/tcp.h>
+
+#include "ixgbe.h"
+#include "ixgbe_vsi.h"
+
+/**
+ * ixgbe_del_mac_filter - Add a mac filter for the VSI netdev
+ * @adapter: pointer to private adapter struct
+ * @p: pointer to mac address (u8*) to program
+ * @pool: VSI pool to configure with MAC address
+ */
+static void ixgbe_del_mac_filter(struct ixgbe_adapter *adapter, u16 pool)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned int entry;
+
+	entry = hw->mac.num_rar_entries - pool - 1;
+	hw->mac.ops.clear_vmdq(hw, entry, VMDQ_P(pool));
+}
+
+/**
+ * ixgbe_add_mac_filter - Add a mac filter for the VSI netdev
+ * @adapter: pointer to private adapter struct
+ * @p: pointer to mac address (u8*) to program
+ * @pool: VSI pool to configure with MAC address
+ */
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
+/**
+ * ixgbe_disable_vsi_ring - shutdown hw queue and release buffers
+ * @adapter: pointer to private adapter struct
+ * @rx_ring: ring to free
+ */
+static void ixgbe_disable_vsi_ring(struct ixgbe_vsi_adapter *vadapter,
+				    struct ixgbe_ring *rx_ring)
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
+/**
+ * ixgbe_enable_vsi_ring - allocate rx buffers and start queue
+ * @adapter: pointer to private adapter struct
+ * @rx_ring: ring to enable with queue
+ */
+static void ixgbe_enable_vsi_ring(struct ixgbe_adapter *adapter,
+				   struct ixgbe_ring *rx_ring)
+{
+	ixgbe_configure_rx_ring(adapter, rx_ring);
+}
+
+int ixgbe_vsi_init(struct net_device *dev)
+{
+	struct net_device *lower;
+	struct list_head *iter;
+
+	/* There can only be one lower dev at this point */
+	netdev_for_each_lower_dev_rcu(dev, lower, iter) {
+		dev->features		= lower->features;
+		dev->vlan_features	= lower->vlan_features;
+		dev->gso_max_size	= lower->gso_max_size;
+		dev->iflink		= lower->ifindex;
+		dev->hard_header_len	= lower->hard_header_len;
+	}
+
+	return 0;
+}
+
+static void ixgbe_vsi_psrtype(struct ixgbe_vsi_adapter *vadapter)
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
+int ixgbe_vsi_open(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	int err = 0;
+
+	if (test_bit(__IXGBE_DOWN, &adapter->state)) {
+		e_dev_info("%s is down\n", adapter->netdev->name);
+		return -EBUSY;
+	}
+
+	vadapter->online = true;
+	err = ixgbe_vsi_up(dev);
+	if (!err)
+		netif_carrier_on(dev);
+	return err;
+}
+
+int ixgbe_vsi_up(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	unsigned int rxbase = vadapter->pool * adapter->num_rx_queues_per_pool;
+	unsigned int txbase = vadapter->pool * adapter->num_rx_queues_per_pool;
+	int err, i;
+
+	netif_carrier_off(dev);
+
+	vadapter->rx_base_queue = rxbase;
+	vadapter->tx_base_queue = txbase;
+
+	for (i = 0; i < dev->num_rx_queues; i++)
+		ixgbe_disable_vsi_ring(vadapter, adapter->rx_ring[rxbase + i]);
+
+	for (i = 0; i < dev->num_rx_queues; i++) {
+		adapter->rx_ring[rxbase + i]->vmdq_netdev = dev;
+		ixgbe_enable_vsi_ring(adapter, adapter->rx_ring[rxbase + i]);
+	}
+
+	for (i = 0; i < dev->num_tx_queues; i++)
+		adapter->tx_ring[txbase + i]->vmdq_netdev = dev;
+
+	if (is_valid_ether_addr(dev->dev_addr))
+		ixgbe_add_mac_filter(adapter, dev->dev_addr, vadapter->pool);
+
+	err = netif_set_real_num_tx_queues(dev, dev->num_tx_queues);
+	if (err)
+		goto err_set_queues;
+	err = netif_set_real_num_rx_queues(dev, dev->num_rx_queues);
+	if (err)
+		goto err_set_queues;
+
+	ixgbe_vsi_psrtype(vadapter);
+	netif_tx_start_all_queues(dev);
+	return 0;
+err_set_queues:
+	for (i = 0; i < dev->num_rx_queues; i++)
+		ixgbe_disable_vsi_ring(vadapter, adapter->rx_ring[rxbase + i]);
+	return err;
+}
+
+int ixgbe_vsi_close(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+
+	vadapter->online = false;
+	return ixgbe_vsi_down(dev);
+}
+
+int ixgbe_vsi_down(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	unsigned int rxbase = vadapter->rx_base_queue;
+	int i;
+
+	netif_tx_stop_all_queues(dev);
+	netif_carrier_off(dev);
+	netif_tx_disable(dev);
+
+	for (i = 0; i < dev->num_rx_queues; i++)
+		ixgbe_disable_vsi_ring(vadapter, adapter->rx_ring[rxbase + i]);
+
+	return 0;
+}
+
+netdev_tx_t ixgbe_vsi_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_ring *tx_ring;
+	unsigned int queue;
+
+	queue = skb->queue_mapping + vadapter->tx_base_queue;
+	tx_ring = vadapter->real_adapter->tx_ring[queue];
+
+	return ixgbe_xmit_frame_ring(skb, vadapter->real_adapter, tx_ring);
+}
+
+struct net_device_stats *ixgbe_vsi_get_stats(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+
+	/* only return the current stats */
+	return &vadapter->net_stats;
+}
+
+int ixgbe_vsi_set_features(struct net_device *dev, netdev_features_t features)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vlnctrl;
+	int i;
+
+	for (i = 0; i < dev->num_rx_queues; i++) {
+		unsigned int index = i + vadapter->rx_base_queue;
+		int reg_idx = adapter->rx_ring[index]->reg_idx;
+
+		vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
+			vlnctrl |= IXGBE_RXDCTL_VME;
+		else
+			vlnctrl &= ~IXGBE_RXDCTL_VME;
+		IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), vlnctrl);
+	}
+
+	return 0;
+}
+
+void ixgbe_vsi_set_rx_mode(struct net_device *dev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmolr;
+
+	/* No unicast promiscuous support for VMDQ devices. */
+	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(vadapter->pool));
+	vmolr |= (IXGBE_VMOLR_ROMPE | IXGBE_VMOLR_BAM | IXGBE_VMOLR_AUPE);
+
+	/* clear the affected bit */
+	vmolr &= ~IXGBE_VMOLR_MPE;
+
+	if (dev->flags & IFF_ALLMULTI) {
+		vmolr |= IXGBE_VMOLR_MPE;
+	} else {
+		vmolr |= IXGBE_VMOLR_ROMPE;
+		hw->mac.ops.update_mc_addr_list(hw, dev);
+	}
+	ixgbe_write_uc_addr_list(adapter->netdev);
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(vadapter->pool), vmolr);
+}
+
+int ixgbe_vsi_set_mac(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	ixgbe_del_mac_filter(adapter, vadapter->pool);
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	ixgbe_add_mac_filter(adapter, dev->dev_addr, vadapter->pool);
+	return 0;
+}
+
+int ixgbe_vsi_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+
+	if (adapter->netdev->mtu < new_mtu) {
+		e_warn(probe,
+		       "Set MTU on %s to >= %d before changing MTU on %s\n",
+			adapter->netdev->name, new_mtu, dev->name);
+		return -EINVAL;
+	}
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+void ixgbe_vsi_tx_timeout(struct net_device *dev)
+{
+	return;
+}
+
+int ixgbe_vsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &vadapter->real_adapter->hw;
+
+	hw->mac.ops.set_vfta(hw, vid, vadapter->pool, true);
+	return 0;
+}
+
+int ixgbe_vsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &vadapter->real_adapter->hw;
+
+	hw->mac.ops.set_vfta(hw, vid, vadapter->pool, false);
+	return 0;
+}
+
+static int ixgbe_vsi_get_settings(struct net_device *netdev,
+				   struct ethtool_cmd *ecmd)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(netdev);
+	struct net_device *real_netdev = vadapter->real_adapter->netdev;
+
+	return ixgbe_get_settings(real_netdev, ecmd);
+}
+
+static u32 ixgbe_vsi_get_msglevel(struct net_device *netdev)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(netdev);
+
+	return vadapter->real_adapter->msg_enable;
+}
+
+static void ixgbe_vsi_get_drvinfo(struct net_device *netdev,
+				   struct ethtool_drvinfo *drvinfo)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(netdev);
+	struct ixgbe_adapter *adapter = vadapter->real_adapter;
+	struct net_device *main_netdev = adapter->netdev;
+
+	strncpy(drvinfo->driver, ixgbe_driver_name, 32);
+	strncpy(drvinfo->version, ixgbe_driver_version, 32);
+
+	strncpy(drvinfo->fw_version, "N/A", 4);
+	snprintf(drvinfo->bus_info, 32, "%s VSI %d",
+		 main_netdev->name, vadapter->pool);
+	drvinfo->n_stats = 0;
+	drvinfo->testinfo_len = 0;
+	drvinfo->regdump_len = 0;
+}
+
+static void ixgbe_vsi_get_ringparam(struct net_device *netdev,
+				     struct ethtool_ringparam *ring)
+{
+	struct ixgbe_vsi_adapter *vadapter = netdev_priv(netdev);
+	unsigned int txr = vadapter->tx_base_queue;
+	unsigned int rxr = vadapter->rx_base_queue;
+	struct ixgbe_ring *tx_ring, *rx_ring;
+
+	tx_ring = vadapter->real_adapter->tx_ring[txr];
+	rx_ring = vadapter->real_adapter->rx_ring[rxr];
+
+	ring->rx_max_pending = IXGBE_MAX_RXD;
+	ring->tx_max_pending = IXGBE_MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rx_ring->count;
+	ring->tx_pending = tx_ring->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static struct ethtool_ops ixgbe_vsi_ethtool_ops = {
+	.get_settings	= ixgbe_vsi_get_settings,
+	.get_drvinfo	= ixgbe_vsi_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+	.get_ringparam	= ixgbe_vsi_get_ringparam,
+	.get_msglevel	= ixgbe_vsi_get_msglevel,
+};
+
+void ixgbe_vsi_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &ixgbe_vsi_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h
new file mode 100644
index 0000000..509f485
--- /dev/null
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_vsi.h
@@ -0,0 +1,71 @@
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
+void ixgbe_ping_all_vadapters(struct net_device *dev);
+int ixgbe_vsi_init(struct net_device *dev);
+int ixgbe_vsi_up(struct net_device *dev);
+int ixgbe_vsi_open(struct net_device *dev);
+int ixgbe_vsi_close(struct net_device *dev);
+int ixgbe_vsi_down(struct net_device *dev);
+netdev_tx_t ixgbe_vsi_xmit_frame(struct sk_buff *skb, struct net_device *dev);
+struct net_device_stats *ixgbe_vsi_get_stats(struct net_device *dev);
+void ixgbe_vsi_set_rx_mode(struct net_device *dev);
+int ixgbe_vsi_set_mac(struct net_device *dev, void *addr);
+int ixgbe_vsi_change_mtu(struct net_device *dev, int new_mtu);
+void ixgbe_vsi_tx_timeout(struct net_device *dev);
+int ixgbe_vsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid);
+int ixgbe_vsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid);
+void ixgbe_vsi_set_ethtool_ops(struct net_device *netdev);
+int ixgbe_vsi_set_features(struct net_device *netdev,
+			   netdev_features_t features);
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
