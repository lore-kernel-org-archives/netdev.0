From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH v2 2/2] ixgbe: enable l2 forwarding acceleration for macvlans
Date: Mon, 04 Nov 2013 11:01:55 -0800
Message-ID: <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: nhorman@tuxdriver.com, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36245 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab3KDTXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 14:23:07 -0500
In-Reply-To: <20131104185717.11802.69282.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that l2 acceleration ops are in place from the prior patch,
enable ixgbe to take advantage of these operations.  Allow it to
allocate queues for a macvlan so that when we transmit a frame,
we can do the switching in hardware inside the ixgbe card, rather
than in software.

For now this patch limits the hardware to 8 offloaded macvlan ports.
A follow on patch will remove this limitation but to simplify
review/validation of the new macvlan offload ops we leave it at 8
for now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   20 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |   12 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  463 +++++++++++++++++++++----
 3 files changed, 415 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 0914914..236d4fb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -223,6 +223,15 @@ enum ixgbe_ring_state_t {
 	__IXGBE_RX_FCOE,
 };
 
+struct ixgbe_fwd_adapter {
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	struct net_device *netdev;
+	struct ixgbe_adapter *real_adapter;
+	unsigned int tx_base_queue;
+	unsigned int rx_base_queue;
+	int pool;
+};
+
 #define check_for_tx_hang(ring) \
 	test_bit(__IXGBE_TX_DETECT_HANG, &(ring)->state)
 #define set_check_for_tx_hang(ring) \
@@ -240,6 +249,7 @@ struct ixgbe_ring {
 	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
 	struct net_device *netdev;	/* netdev ring belongs to */
 	struct device *dev;		/* device for DMA mapping */
+	struct ixgbe_fwd_adapter *l2_accel_priv;
 	void *desc;			/* descriptor ring memory */
 	union {
 		struct ixgbe_tx_buffer *tx_buffer_info;
@@ -292,11 +302,15 @@ enum ixgbe_ring_f_enum {
 };
 
 #define IXGBE_MAX_RSS_INDICES  16
-#define IXGBE_MAX_VMDQ_INDICES 64
+#define IXGBE_MAX_VMDQ_INDICES	8
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
@@ -766,6 +780,7 @@ struct ixgbe_adapter {
 #endif /*CONFIG_DEBUG_FS*/
 
 	u8 default_up;
+	unsigned long fwd_bitmask; /* Bitmask indicating in use pools */
 };
 
 struct ixgbe_fdir_filter {
@@ -939,4 +954,7 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
 void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter);
 #endif
 
+netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
+				  struct ixgbe_adapter *adapter,
+				  struct ixgbe_ring *tx_ring);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 90b4e10..5eae76a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -852,7 +852,11 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
 
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
@@ -895,7 +899,11 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
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
index 5191b3c..2d445f5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -44,6 +44,7 @@
 #include <linux/ethtool.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/if_macvlan.h>
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
@@ -870,11 +871,18 @@ static u64 ixgbe_get_tx_completed(struct ixgbe_ring *ring)
 
 static u64 ixgbe_get_tx_pending(struct ixgbe_ring *ring)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(ring->netdev);
-	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_adapter *adapter;
+	struct ixgbe_hw *hw;
+	u32 head, tail;
+
+	if (ring->l2_accel_priv)
+		adapter = ring->l2_accel_priv->real_adapter;
+	else
+		adapter = netdev_priv(ring->netdev);
 
-	u32 head = IXGBE_READ_REG(hw, IXGBE_TDH(ring->reg_idx));
-	u32 tail = IXGBE_READ_REG(hw, IXGBE_TDT(ring->reg_idx));
+	hw = &adapter->hw;
+	head = IXGBE_READ_REG(hw, IXGBE_TDH(ring->reg_idx));
+	tail = IXGBE_READ_REG(hw, IXGBE_TDT(ring->reg_idx));
 
 	if (head != tail)
 		return (head < tail) ?
@@ -3003,7 +3011,7 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 		struct ixgbe_q_vector *q_vector = ring->q_vector;
 
 		if (q_vector)
-			netif_set_xps_queue(adapter->netdev,
+			netif_set_xps_queue(ring->netdev,
 					    &q_vector->affinity_mask,
 					    ring->queue_index);
 	}
@@ -3393,7 +3401,7 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int rss_i = adapter->ring_feature[RING_F_RSS].indices;
-	int p;
+	u16 pool;
 
 	/* PSRTYPE must be initialized in non 82598 adapters */
 	u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
@@ -3410,9 +3418,8 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 	else if (rss_i > 1)
 		psrtype |= 1 << 29;
 
-	for (p = 0; p < adapter->num_rx_pools; p++)
-		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(p)),
-				psrtype);
+	for_each_set_bit(pool, &adapter->fwd_bitmask, 32)
+		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(VMDQ_P(pool)), psrtype);
 }
 
 static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
@@ -3681,7 +3688,11 @@ static void ixgbe_vlan_strip_disable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			j = adapter->rx_ring[i]->reg_idx;
+			struct ixgbe_ring *ring = adapter->rx_ring[i];
+
+			if (ring->l2_accel_priv)
+				continue;
+			j = ring->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl &= ~IXGBE_RXDCTL_VME;
 			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), vlnctrl);
@@ -3711,7 +3722,11 @@ static void ixgbe_vlan_strip_enable(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			j = adapter->rx_ring[i]->reg_idx;
+			struct ixgbe_ring *ring = adapter->rx_ring[i];
+
+			if (ring->l2_accel_priv)
+				continue;
+			j = ring->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl |= IXGBE_RXDCTL_VME;
 			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), vlnctrl);
@@ -3748,7 +3763,7 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev)
 	unsigned int rar_entries = hw->mac.num_rar_entries - 1;
 	int count = 0;
 
-	/* In SR-IOV mode significantly less RAR entries are available */
+	/* In SR-IOV/VMDQ modes significantly less RAR entries are available */
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		rar_entries = IXGBE_MAX_PF_MACVLANS - 1;
 
@@ -4113,6 +4128,194 @@ static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
 	spin_unlock(&adapter->fdir_perfect_lock);
 }
 
+static void ixgbe_macvlan_set_rx_mode(struct net_device *dev, unsigned int pool,
+				      struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 vmolr;
+
+	/* No unicast promiscuous support for VMDQ devices. */
+	vmolr = IXGBE_READ_REG(hw, IXGBE_VMOLR(pool));
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
+	IXGBE_WRITE_REG(hw, IXGBE_VMOLR(pool), vmolr);
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
+static void ixgbe_fwd_psrtype(struct ixgbe_fwd_adapter *vadapter)
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
+/**
+ * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
+ * @rx_ring: ring to free buffers from
+ **/
+static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
+{
+	struct device *dev = rx_ring->dev;
+	unsigned long size;
+	u16 i;
+
+	/* ring already cleared, nothing to do */
+	if (!rx_ring->rx_buffer_info)
+		return;
+
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rx_ring->count; i++) {
+		struct ixgbe_rx_buffer *rx_buffer;
+
+		rx_buffer = &rx_ring->rx_buffer_info[i];
+		if (rx_buffer->skb) {
+			struct sk_buff *skb = rx_buffer->skb;
+			if (IXGBE_CB(skb)->page_released) {
+				dma_unmap_page(dev,
+					       IXGBE_CB(skb)->dma,
+					       ixgbe_rx_bufsz(rx_ring),
+					       DMA_FROM_DEVICE);
+				IXGBE_CB(skb)->page_released = false;
+			}
+			dev_kfree_skb(skb);
+		}
+		rx_buffer->skb = NULL;
+		if (rx_buffer->dma)
+			dma_unmap_page(dev, rx_buffer->dma,
+				       ixgbe_rx_pg_size(rx_ring),
+				       DMA_FROM_DEVICE);
+		rx_buffer->dma = 0;
+		if (rx_buffer->page)
+			__free_pages(rx_buffer->page,
+				     ixgbe_rx_pg_order(rx_ring));
+		rx_buffer->page = NULL;
+	}
+
+	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
+	memset(rx_ring->rx_buffer_info, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(rx_ring->desc, 0, rx_ring->size);
+
+	rx_ring->next_to_alloc = 0;
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+}
+
+static void ixgbe_disable_fwd_ring(struct ixgbe_fwd_adapter *vadapter,
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
+	rx_ring->l2_accel_priv = NULL;
+}
+
+static int ixgbe_fwd_ring_up(struct net_device *vdev,
+			     struct ixgbe_fwd_adapter *accel)
+{
+	struct ixgbe_adapter *adapter = accel->real_adapter;
+	unsigned int rxbase;
+	unsigned int txbase;
+	int i, baseq;
+
+	/* Configure VSI adapter structure */
+	baseq = accel->pool * adapter->num_rx_queues_per_pool;
+
+	netdev_dbg(vdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   accel->pool, adapter->num_rx_pools,
+		   baseq, baseq + adapter->num_rx_queues_per_pool,
+		   adapter->fwd_bitmask);
+
+	accel->netdev = vdev;
+	accel->rx_base_queue = rxbase = baseq;
+	accel->tx_base_queue = txbase = baseq;
+
+	for (i = 0; i < vdev->num_rx_queues; i++)
+		ixgbe_disable_fwd_ring(accel, adapter->rx_ring[rxbase + i]);
+
+	for (i = 0; i < vdev->num_rx_queues; i++) {
+		adapter->rx_ring[rxbase + i]->netdev = vdev;
+		adapter->rx_ring[rxbase + i]->l2_accel_priv = accel;
+		ixgbe_configure_rx_ring(adapter, adapter->rx_ring[rxbase + i]);
+	}
+
+	for (i = 0; i < vdev->num_tx_queues; i++) {
+		adapter->tx_ring[txbase + i]->netdev = vdev;
+		adapter->tx_ring[txbase + i]->l2_accel_priv = accel;
+	}
+
+	if (is_valid_ether_addr(vdev->dev_addr))
+		ixgbe_add_mac_filter(adapter, vdev->dev_addr, accel->pool);
+
+	ixgbe_fwd_psrtype(accel);
+	ixgbe_macvlan_set_rx_mode(vdev, accel->pool, adapter);
+	return 0;
+}
+
+static void ixgbe_configure_vsi(struct ixgbe_adapter *adapter)
+{
+	struct net_device *upper;
+	struct list_head *iter;
+	int err;
+
+	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+		if (netif_is_macvlan(upper)) {
+			struct macvlan_dev *vlan = netdev_priv(upper);
+			struct ixgbe_fwd_adapter *vadapter = vlan->fwd_priv;
+
+			if (vlan->fwd_priv) {
+				err = ixgbe_fwd_ring_up(upper, vadapter);
+				if (err)
+					continue;
+				ixgbe_macvlan_set_rx_mode(upper,
+							  vadapter->pool,
+							  adapter);
+			}
+		}
+	}
+}
+
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -4164,6 +4367,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 #endif /* IXGBE_FCOE */
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
+	ixgbe_configure_vsi(adapter);
 }
 
 static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
@@ -4317,6 +4521,8 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *upper;
+	struct list_head *iter;
 	int err;
 	u32 ctrl_ext;
 
@@ -4360,6 +4566,16 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	/* enable transmits */
 	netif_tx_start_all_queues(adapter->netdev);
 
+	/* enable any upper devices */
+	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+		if (netif_is_macvlan(upper)) {
+			struct macvlan_dev *vlan = netdev_priv(upper);
+
+			if (vlan->fwd_priv)
+				netif_tx_start_all_queues(upper);
+		}
+	}
+
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
@@ -4451,59 +4667,6 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
- * @rx_ring: ring to free buffers from
- **/
-static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
-{
-	struct device *dev = rx_ring->dev;
-	unsigned long size;
-	u16 i;
-
-	/* ring already cleared, nothing to do */
-	if (!rx_ring->rx_buffer_info)
-		return;
-
-	/* Free all the Rx ring sk_buffs */
-	for (i = 0; i < rx_ring->count; i++) {
-		struct ixgbe_rx_buffer *rx_buffer;
-
-		rx_buffer = &rx_ring->rx_buffer_info[i];
-		if (rx_buffer->skb) {
-			struct sk_buff *skb = rx_buffer->skb;
-			if (IXGBE_CB(skb)->page_released) {
-				dma_unmap_page(dev,
-					       IXGBE_CB(skb)->dma,
-					       ixgbe_rx_bufsz(rx_ring),
-					       DMA_FROM_DEVICE);
-				IXGBE_CB(skb)->page_released = false;
-			}
-			dev_kfree_skb(skb);
-		}
-		rx_buffer->skb = NULL;
-		if (rx_buffer->dma)
-			dma_unmap_page(dev, rx_buffer->dma,
-				       ixgbe_rx_pg_size(rx_ring),
-				       DMA_FROM_DEVICE);
-		rx_buffer->dma = 0;
-		if (rx_buffer->page)
-			__free_pages(rx_buffer->page,
-				     ixgbe_rx_pg_order(rx_ring));
-		rx_buffer->page = NULL;
-	}
-
-	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	memset(rx_ring->rx_buffer_info, 0, size);
-
-	/* Zero out the descriptor ring */
-	memset(rx_ring->desc, 0, rx_ring->size);
-
-	rx_ring->next_to_alloc = 0;
-	rx_ring->next_to_clean = 0;
-	rx_ring->next_to_use = 0;
-}
-
-/**
  * ixgbe_clean_tx_ring - Free Tx Buffers
  * @tx_ring: ring to be cleaned
  **/
@@ -4580,6 +4743,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *upper;
+	struct list_head *iter;
 	u32 rxctrl;
 	int i;
 
@@ -4603,6 +4768,19 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
+	/* disable any upper devices */
+	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+		if (netif_is_macvlan(upper)) {
+			struct macvlan_dev *vlan = netdev_priv(upper);
+
+			if (vlan->fwd_priv) {
+				netif_tx_stop_all_queues(upper);
+				netif_carrier_off(upper);
+				netif_tx_disable(upper);
+			}
+		}
+	}
+
 	ixgbe_irq_disable(adapter);
 
 	ixgbe_napi_disable_all(adapter);
@@ -4833,6 +5011,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
+	/* PF holds first pool slot */
+	set_bit(0, &adapter->fwd_bitmask);
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -5138,7 +5318,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	int err;
+	int err, queues;
 
 	/* disallow open during test */
 	if (test_bit(__IXGBE_TESTING, &adapter->state))
@@ -5163,16 +5343,22 @@ static int ixgbe_open(struct net_device *netdev)
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
 
@@ -6762,8 +6948,9 @@ out_drop:
 	return NETDEV_TX_OK;
 }
 
-static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
-				    struct net_device *netdev)
+static netdev_tx_t __ixgbe_xmit_frame(struct sk_buff *skb,
+				      struct net_device *netdev,
+				      struct ixgbe_ring *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
@@ -6779,10 +6966,17 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		skb_set_tail_pointer(skb, 17);
 	}
 
-	tx_ring = adapter->tx_ring[skb->queue_mapping];
+	tx_ring = ring ? ring : adapter->tx_ring[skb->queue_mapping];
+
 	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);
 }
 
+static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
+{
+	return __ixgbe_xmit_frame(skb, netdev, NULL);
+}
+
 /**
  * ixgbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -7300,6 +7494,117 @@ static int ixgbe_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode);
 }
 
+int ixgbe_fwd_ring_down(struct net_device *vdev,
+			struct ixgbe_fwd_adapter *accel)
+{
+	struct ixgbe_adapter *adapter = accel->real_adapter;
+	unsigned int rxbase = accel->rx_base_queue;
+	unsigned int txbase = accel->tx_base_queue;
+	int i;
+
+	netif_tx_stop_all_queues(vdev);
+
+	for (i = 0; i < vdev->num_rx_queues; i++) {
+		ixgbe_disable_fwd_ring(accel, adapter->rx_ring[rxbase + i]);
+		adapter->rx_ring[rxbase + i]->netdev = adapter->netdev;
+	}
+
+	for (i = 0; i < vdev->num_tx_queues; i++) {
+		adapter->tx_ring[txbase + i]->l2_accel_priv = NULL;
+		adapter->tx_ring[txbase + i]->netdev = adapter->netdev;
+	}
+
+
+	return 0;
+}
+
+static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
+{
+	struct ixgbe_fwd_adapter *fwd_adapter = NULL;
+	struct ixgbe_adapter *adapter = netdev_priv(pdev);
+	int pool, err;
+
+	/* Check for hardware restriction on number of rx/tx queues */
+	if (vdev->num_rx_queues != vdev->num_tx_queues ||
+	    vdev->num_tx_queues > IXGBE_MAX_L2A_QUEUES ||
+	    vdev->num_tx_queues == IXGBE_BAD_L2A_QUEUE) {
+		netdev_info(pdev, "%s: Supports RX/TX Queue counts 1,2, and 4\n",
+		       pdev->name);
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (adapter->num_rx_pools >= IXGBE_MAX_VMDQ_INDICES)
+		return ERR_PTR(-EBUSY);
+
+	fwd_adapter = kcalloc(1, sizeof(struct ixgbe_fwd_adapter), GFP_KERNEL);
+	if (!fwd_adapter)
+		return ERR_PTR(-ENOMEM);
+
+	pool = find_first_zero_bit(&adapter->fwd_bitmask, 32);
+	adapter->num_rx_pools++;
+	set_bit(pool, &adapter->fwd_bitmask);
+
+	/* Enable VMDq flag so device will be set in VM mode */
+	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_SRIOV_ENABLED;
+	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
+	adapter->ring_feature[RING_F_RSS].limit = IXGBE_MAX_L2A_QUEUES;
+
+	/* Force reinit of ring allocation with VMDQ enabled */
+	ixgbe_setup_tc(pdev, netdev_get_num_tc(pdev));
+	fwd_adapter->pool = pool;
+	fwd_adapter->real_adapter = adapter;
+	err = ixgbe_fwd_ring_up(vdev, fwd_adapter);
+	if (err)
+		goto fwd_add_err;
+
+	err = netif_set_real_num_tx_queues(vdev, vdev->num_tx_queues);
+	if (err)
+		goto fwd_queue_err;
+	err = netif_set_real_num_rx_queues(vdev, vdev->num_rx_queues);
+	if (err)
+		goto fwd_queue_err;
+
+	netif_tx_start_all_queues(vdev);
+
+	return fwd_adapter;
+fwd_queue_err:
+	ixgbe_fwd_ring_down(vdev, fwd_adapter);
+fwd_add_err:
+	kfree(fwd_adapter);
+	return ERR_PTR(err);
+}
+
+static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
+{
+	struct ixgbe_fwd_adapter *fwd_adapter = priv;
+	struct ixgbe_adapter *adapter = fwd_adapter->real_adapter;
+
+	clear_bit(fwd_adapter->pool, &adapter->fwd_bitmask);
+	adapter->num_rx_pools--;
+
+	ixgbe_fwd_ring_down(fwd_adapter->netdev, fwd_adapter);
+
+	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
+		   fwd_adapter->pool, adapter->num_rx_pools,
+		   fwd_adapter->rx_base_queue,
+		   fwd_adapter->rx_base_queue + adapter->num_rx_queues_per_pool,
+		   adapter->fwd_bitmask);
+}
+
+static netdev_tx_t ixgbe_fwd_xmit(struct sk_buff *skb,
+				  struct net_device *dev,
+				  void *priv)
+{
+	struct ixgbe_fwd_adapter *fwd_adapter = priv;
+	unsigned int queue;
+	struct ixgbe_ring *tx_ring;
+
+	queue = skb->queue_mapping + fwd_adapter->tx_base_queue;
+	tx_ring = fwd_adapter->real_adapter->tx_ring[queue];
+
+	return __ixgbe_xmit_frame(skb, dev, tx_ring);
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7344,6 +7649,9 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_fdb_add		= ixgbe_ndo_fdb_add,
 	.ndo_bridge_setlink	= ixgbe_ndo_bridge_setlink,
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
+	.ndo_dfwd_add_station	= ixgbe_fwd_add,
+	.ndo_dfwd_del_station	= ixgbe_fwd_del,
+	.ndo_dfwd_start_xmit	= ixgbe_fwd_xmit,
 };
 
 /**
@@ -7645,7 +7953,8 @@ skip_sriov:
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
-			   NETIF_F_RXCSUM;
+			   NETIF_F_RXCSUM |
+			   NETIF_F_HW_L2FW_DOFFLOAD;
 
 	netdev->hw_features = netdev->features;
 
