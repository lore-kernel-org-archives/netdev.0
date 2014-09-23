From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 15/29] fm10k: Add Tx/Rx hardware ring bring-up/tear-down
Date: Tue, 23 Sep 2014 04:16:43 -0700
Message-ID: <1411471017-28213-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33801 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755739AbaIWLRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:17 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for allocating, configuring, and freeing Tx/Rx ring
resources.  With these changes in place the descriptor queues are in a
state where they are ready to transmit or receive if provided buffers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |   8 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 343 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 302 +++++++++++++++++++++
 3 files changed, 653 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 26a30ba..a0e8331 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -407,6 +407,14 @@ void fm10k_update_rx_drop_en(struct fm10k_intfc *interface);
 
 /* Netdev */
 struct net_device *fm10k_alloc_netdev(void);
+int fm10k_setup_rx_resources(struct fm10k_ring *);
+int fm10k_setup_tx_resources(struct fm10k_ring *);
+void fm10k_free_rx_resources(struct fm10k_ring *);
+void fm10k_free_tx_resources(struct fm10k_ring *);
+void fm10k_clean_all_rx_rings(struct fm10k_intfc *);
+void fm10k_clean_all_tx_rings(struct fm10k_intfc *);
+void fm10k_unmap_and_free_tx_resource(struct fm10k_ring *,
+				      struct fm10k_tx_buffer *);
 void fm10k_restore_rx_state(struct fm10k_intfc *);
 void fm10k_reset_rx_state(struct fm10k_intfc *);
 int fm10k_open(struct net_device *netdev);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index b987bb6..52673d7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -19,6 +19,332 @@
  */
 
 #include "fm10k.h"
+#include <linux/vmalloc.h>
+
+/**
+ * fm10k_setup_tx_resources - allocate Tx resources (Descriptors)
+ * @tx_ring:    tx descriptor ring (for a specific queue) to setup
+ *
+ * Return 0 on success, negative on failure
+ **/
+int fm10k_setup_tx_resources(struct fm10k_ring *tx_ring)
+{
+	struct device *dev = tx_ring->dev;
+	int size;
+
+	size = sizeof(struct fm10k_tx_buffer) * tx_ring->count;
+
+	tx_ring->tx_buffer = vzalloc(size);
+	if (!tx_ring->tx_buffer)
+		goto err;
+
+	u64_stats_init(&tx_ring->syncp);
+
+	/* round up to nearest 4K */
+	tx_ring->size = tx_ring->count * sizeof(struct fm10k_tx_desc);
+	tx_ring->size = ALIGN(tx_ring->size, 4096);
+
+	tx_ring->desc = dma_alloc_coherent(dev, tx_ring->size,
+					   &tx_ring->dma, GFP_KERNEL);
+	if (!tx_ring->desc)
+		goto err;
+
+	return 0;
+
+err:
+	vfree(tx_ring->tx_buffer);
+	tx_ring->tx_buffer = NULL;
+	return -ENOMEM;
+}
+
+/**
+ * fm10k_setup_all_tx_resources - allocate all queues Tx resources
+ * @interface: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+static int fm10k_setup_all_tx_resources(struct fm10k_intfc *interface)
+{
+	int i, err = 0;
+
+	for (i = 0; i < interface->num_tx_queues; i++) {
+		err = fm10k_setup_tx_resources(interface->tx_ring[i]);
+		if (!err)
+			continue;
+
+		netif_err(interface, probe, interface->netdev,
+			  "Allocation for Tx Queue %u failed\n", i);
+		goto err_setup_tx;
+	}
+
+	return 0;
+err_setup_tx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		fm10k_free_tx_resources(interface->tx_ring[i]);
+	return err;
+}
+
+/**
+ * fm10k_setup_rx_resources - allocate Rx resources (Descriptors)
+ * @rx_ring:    rx descriptor ring (for a specific queue) to setup
+ *
+ * Returns 0 on success, negative on failure
+ **/
+int fm10k_setup_rx_resources(struct fm10k_ring *rx_ring)
+{
+	struct device *dev = rx_ring->dev;
+	int size;
+
+	size = sizeof(struct fm10k_rx_buffer) * rx_ring->count;
+
+	rx_ring->rx_buffer = vzalloc(size);
+	if (!rx_ring->rx_buffer)
+		goto err;
+
+	u64_stats_init(&rx_ring->syncp);
+
+	/* Round up to nearest 4K */
+	rx_ring->size = rx_ring->count * sizeof(union fm10k_rx_desc);
+	rx_ring->size = ALIGN(rx_ring->size, 4096);
+
+	rx_ring->desc = dma_alloc_coherent(dev, rx_ring->size,
+					   &rx_ring->dma, GFP_KERNEL);
+	if (!rx_ring->desc)
+		goto err;
+
+	return 0;
+err:
+	vfree(rx_ring->rx_buffer);
+	rx_ring->rx_buffer = NULL;
+	return -ENOMEM;
+}
+
+/**
+ * fm10k_setup_all_rx_resources - allocate all queues Rx resources
+ * @interface: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+static int fm10k_setup_all_rx_resources(struct fm10k_intfc *interface)
+{
+	int i, err = 0;
+
+	for (i = 0; i < interface->num_rx_queues; i++) {
+		err = fm10k_setup_rx_resources(interface->rx_ring[i]);
+		if (!err)
+			continue;
+
+		netif_err(interface, probe, interface->netdev,
+			  "Allocation for Rx Queue %u failed\n", i);
+		goto err_setup_rx;
+	}
+
+	return 0;
+err_setup_rx:
+	/* rewind the index freeing the rings as we go */
+	while (i--)
+		fm10k_free_rx_resources(interface->rx_ring[i]);
+	return err;
+}
+
+void fm10k_unmap_and_free_tx_resource(struct fm10k_ring *ring,
+				      struct fm10k_tx_buffer *tx_buffer)
+{
+	if (tx_buffer->skb) {
+		dev_kfree_skb_any(tx_buffer->skb);
+		if (dma_unmap_len(tx_buffer, len))
+			dma_unmap_single(ring->dev,
+					 dma_unmap_addr(tx_buffer, dma),
+					 dma_unmap_len(tx_buffer, len),
+					 DMA_TO_DEVICE);
+	} else if (dma_unmap_len(tx_buffer, len)) {
+		dma_unmap_page(ring->dev,
+			       dma_unmap_addr(tx_buffer, dma),
+			       dma_unmap_len(tx_buffer, len),
+			       DMA_TO_DEVICE);
+	}
+	tx_buffer->next_to_watch = NULL;
+	tx_buffer->skb = NULL;
+	dma_unmap_len_set(tx_buffer, len, 0);
+	/* tx_buffer must be completely set up in the transmit path */
+}
+
+/**
+ * fm10k_clean_tx_ring - Free Tx Buffers
+ * @tx_ring: ring to be cleaned
+ **/
+static void fm10k_clean_tx_ring(struct fm10k_ring *tx_ring)
+{
+	struct fm10k_tx_buffer *tx_buffer;
+	unsigned long size;
+	u16 i;
+
+	/* ring already cleared, nothing to do */
+	if (!tx_ring->tx_buffer)
+		return;
+
+	/* Free all the Tx ring sk_buffs */
+	for (i = 0; i < tx_ring->count; i++) {
+		tx_buffer = &tx_ring->tx_buffer[i];
+		fm10k_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+	}
+
+	/* reset BQL values */
+	netdev_tx_reset_queue(txring_txq(tx_ring));
+
+	size = sizeof(struct fm10k_tx_buffer) * tx_ring->count;
+	memset(tx_ring->tx_buffer, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(tx_ring->desc, 0, tx_ring->size);
+}
+
+/**
+ * fm10k_free_tx_resources - Free Tx Resources per Queue
+ * @tx_ring: Tx descriptor ring for a specific queue
+ *
+ * Free all transmit software resources
+ **/
+void fm10k_free_tx_resources(struct fm10k_ring *tx_ring)
+{
+	fm10k_clean_tx_ring(tx_ring);
+
+	vfree(tx_ring->tx_buffer);
+	tx_ring->tx_buffer = NULL;
+
+	/* if not set, then don't free */
+	if (!tx_ring->desc)
+		return;
+
+	dma_free_coherent(tx_ring->dev, tx_ring->size,
+			  tx_ring->desc, tx_ring->dma);
+	tx_ring->desc = NULL;
+}
+
+/**
+ * fm10k_clean_all_tx_rings - Free Tx Buffers for all queues
+ * @interface: board private structure
+ **/
+void fm10k_clean_all_tx_rings(struct fm10k_intfc *interface)
+{
+	int i;
+
+	for (i = 0; i < interface->num_tx_queues; i++)
+		fm10k_clean_tx_ring(interface->tx_ring[i]);
+}
+
+/**
+ * fm10k_free_all_tx_resources - Free Tx Resources for All Queues
+ * @interface: board private structure
+ *
+ * Free all transmit software resources
+ **/
+static void fm10k_free_all_tx_resources(struct fm10k_intfc *interface)
+{
+	int i = interface->num_tx_queues;
+
+	while (i--)
+		fm10k_free_tx_resources(interface->tx_ring[i]);
+}
+
+/**
+ * fm10k_clean_rx_ring - Free Rx Buffers per Queue
+ * @rx_ring: ring to free buffers from
+ **/
+static void fm10k_clean_rx_ring(struct fm10k_ring *rx_ring)
+{
+	unsigned long size;
+	u16 i;
+
+	if (!rx_ring->rx_buffer)
+		return;
+
+	if (rx_ring->skb)
+		dev_kfree_skb(rx_ring->skb);
+	rx_ring->skb = NULL;
+
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rx_ring->count; i++) {
+		struct fm10k_rx_buffer *buffer = &rx_ring->rx_buffer[i];
+		/* clean-up will only set page pointer to NULL */
+		if (!buffer->page)
+			continue;
+
+		dma_unmap_page(rx_ring->dev, buffer->dma,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+		__free_page(buffer->page);
+
+		buffer->page = NULL;
+	}
+
+	size = sizeof(struct fm10k_rx_buffer) * rx_ring->count;
+	memset(rx_ring->rx_buffer, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(rx_ring->desc, 0, rx_ring->size);
+
+	rx_ring->next_to_alloc = 0;
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+}
+
+/**
+ * fm10k_free_rx_resources - Free Rx Resources
+ * @rx_ring: ring to clean the resources from
+ *
+ * Free all receive software resources
+ **/
+void fm10k_free_rx_resources(struct fm10k_ring *rx_ring)
+{
+	fm10k_clean_rx_ring(rx_ring);
+
+	vfree(rx_ring->rx_buffer);
+	rx_ring->rx_buffer = NULL;
+
+	/* if not set, then don't free */
+	if (!rx_ring->desc)
+		return;
+
+	dma_free_coherent(rx_ring->dev, rx_ring->size,
+			  rx_ring->desc, rx_ring->dma);
+
+	rx_ring->desc = NULL;
+}
+
+/**
+ * fm10k_clean_all_rx_rings - Free Rx Buffers for all queues
+ * @interface: board private structure
+ **/
+void fm10k_clean_all_rx_rings(struct fm10k_intfc *interface)
+{
+	int i;
+
+	for (i = 0; i < interface->num_rx_queues; i++)
+		fm10k_clean_rx_ring(interface->rx_ring[i]);
+}
+
+/**
+ * fm10k_free_all_rx_resources - Free Rx Resources for All Queues
+ * @interface: board private structure
+ *
+ * Free all receive software resources
+ **/
+static void fm10k_free_all_rx_resources(struct fm10k_intfc *interface)
+{
+	int i = interface->num_rx_queues;
+
+	while (i--)
+		fm10k_free_rx_resources(interface->rx_ring[i]);
+}
 
 /**
  * fm10k_request_glort_range - Request GLORTs for use in configuring rules
@@ -59,6 +385,16 @@ int fm10k_open(struct net_device *netdev)
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	int err;
 
+	/* allocate transmit descriptors */
+	err = fm10k_setup_all_tx_resources(interface);
+	if (err)
+		goto err_setup_tx;
+
+	/* allocate receive descriptors */
+	err = fm10k_setup_all_rx_resources(interface);
+	if (err)
+		goto err_setup_rx;
+
 	/* allocate interrupt resources */
 	err = fm10k_qv_request_irq(interface);
 	if (err)
@@ -81,6 +417,10 @@ int fm10k_open(struct net_device *netdev)
 err_set_queues:
 	fm10k_qv_free_irq(interface);
 err_req_irq:
+	fm10k_free_all_rx_resources(interface);
+err_setup_rx:
+	fm10k_free_all_tx_resources(interface);
+err_setup_tx:
 	return err;
 }
 
@@ -103,6 +443,9 @@ int fm10k_close(struct net_device *netdev)
 
 	fm10k_qv_free_irq(interface);
 
+	fm10k_free_all_tx_resources(interface);
+	fm10k_free_all_rx_resources(interface);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 33d6f47..7529a84 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -485,6 +485,299 @@ static void fm10k_service_task(struct work_struct *work)
 	fm10k_service_event_complete(interface);
 }
 
+/**
+ * fm10k_configure_tx_ring - Configure Tx ring after Reset
+ * @interface: board private structure
+ * @ring: structure containing ring specific data
+ *
+ * Configure the Tx descriptor ring after a reset.
+ **/
+static void fm10k_configure_tx_ring(struct fm10k_intfc *interface,
+				    struct fm10k_ring *ring)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	u64 tdba = ring->dma;
+	u32 size = ring->count * sizeof(struct fm10k_tx_desc);
+	u32 txint = FM10K_INT_MAP_DISABLE;
+	u32 txdctl = FM10K_TXDCTL_ENABLE | (1 << FM10K_TXDCTL_MAX_TIME_SHIFT);
+	u8 reg_idx = ring->reg_idx;
+
+	/* disable queue to avoid issues while updating state */
+	fm10k_write_reg(hw, FM10K_TXDCTL(reg_idx), 0);
+	fm10k_write_flush(hw);
+
+	/* possible poll here to verify ring resources have been cleaned */
+
+	/* set location and size for descriptor ring */
+	fm10k_write_reg(hw, FM10K_TDBAL(reg_idx), tdba & DMA_BIT_MASK(32));
+	fm10k_write_reg(hw, FM10K_TDBAH(reg_idx), tdba >> 32);
+	fm10k_write_reg(hw, FM10K_TDLEN(reg_idx), size);
+
+	/* reset head and tail pointers */
+	fm10k_write_reg(hw, FM10K_TDH(reg_idx), 0);
+	fm10k_write_reg(hw, FM10K_TDT(reg_idx), 0);
+
+	/* store tail pointer */
+	ring->tail = &interface->uc_addr[FM10K_TDT(reg_idx)];
+
+	/* reset ntu and ntc to place SW in sync with hardwdare */
+	ring->next_to_clean = 0;
+	ring->next_to_use = 0;
+
+	/* Map interrupt */
+	if (ring->q_vector) {
+		txint = ring->q_vector->v_idx + NON_Q_VECTORS(hw);
+		txint |= FM10K_INT_MAP_TIMER0;
+	}
+
+	fm10k_write_reg(hw, FM10K_TXINT(reg_idx), txint);
+
+	/* enable use of FTAG bit in Tx descriptor, register is RO for VF */
+	fm10k_write_reg(hw, FM10K_PFVTCTL(reg_idx),
+			FM10K_PFVTCTL_FTAG_DESC_ENABLE);
+
+	/* enable queue */
+	fm10k_write_reg(hw, FM10K_TXDCTL(reg_idx), txdctl);
+}
+
+/**
+ * fm10k_enable_tx_ring - Verify Tx ring is enabled after configuration
+ * @interface: board private structure
+ * @ring: structure containing ring specific data
+ *
+ * Verify the Tx descriptor ring is ready for transmit.
+ **/
+static void fm10k_enable_tx_ring(struct fm10k_intfc *interface,
+				 struct fm10k_ring *ring)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	int wait_loop = 10;
+	u32 txdctl;
+	u8 reg_idx = ring->reg_idx;
+
+	/* if we are already enabled just exit */
+	if (fm10k_read_reg(hw, FM10K_TXDCTL(reg_idx)) & FM10K_TXDCTL_ENABLE)
+		return;
+
+	/* poll to verify queue is enabled */
+	do {
+		usleep_range(1000, 2000);
+		txdctl = fm10k_read_reg(hw, FM10K_TXDCTL(reg_idx));
+	} while (!(txdctl & FM10K_TXDCTL_ENABLE) && --wait_loop);
+	if (!wait_loop)
+		netif_err(interface, drv, interface->netdev,
+			  "Could not enable Tx Queue %d\n", reg_idx);
+}
+
+/**
+ * fm10k_configure_tx - Configure Transmit Unit after Reset
+ * @interface: board private structure
+ *
+ * Configure the Tx unit of the MAC after a reset.
+ **/
+static void fm10k_configure_tx(struct fm10k_intfc *interface)
+{
+	int i;
+
+	/* Setup the HW Tx Head and Tail descriptor pointers */
+	for (i = 0; i < interface->num_tx_queues; i++)
+		fm10k_configure_tx_ring(interface, interface->tx_ring[i]);
+
+	/* poll here to verify that Tx rings are now enabled */
+	for (i = 0; i < interface->num_tx_queues; i++)
+		fm10k_enable_tx_ring(interface, interface->tx_ring[i]);
+}
+
+/**
+ * fm10k_configure_rx_ring - Configure Rx ring after Reset
+ * @interface: board private structure
+ * @ring: structure containing ring specific data
+ *
+ * Configure the Rx descriptor ring after a reset.
+ **/
+static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
+				    struct fm10k_ring *ring)
+{
+	u64 rdba = ring->dma;
+	struct fm10k_hw *hw = &interface->hw;
+	u32 size = ring->count * sizeof(union fm10k_rx_desc);
+	u32 rxqctl = FM10K_RXQCTL_ENABLE | FM10K_RXQCTL_PF;
+	u32 rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
+	u32 srrctl = FM10K_SRRCTL_BUFFER_CHAINING_EN;
+	u32 rxint = FM10K_INT_MAP_DISABLE;
+	u8 rx_pause = interface->rx_pause;
+	u8 reg_idx = ring->reg_idx;
+
+	/* disable queue to avoid issues while updating state */
+	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), 0);
+	fm10k_write_flush(hw);
+
+	/* possible poll here to verify ring resources have been cleaned */
+
+	/* set location and size for descriptor ring */
+	fm10k_write_reg(hw, FM10K_RDBAL(reg_idx), rdba & DMA_BIT_MASK(32));
+	fm10k_write_reg(hw, FM10K_RDBAH(reg_idx), rdba >> 32);
+	fm10k_write_reg(hw, FM10K_RDLEN(reg_idx), size);
+
+	/* reset head and tail pointers */
+	fm10k_write_reg(hw, FM10K_RDH(reg_idx), 0);
+	fm10k_write_reg(hw, FM10K_RDT(reg_idx), 0);
+
+	/* store tail pointer */
+	ring->tail = &interface->uc_addr[FM10K_RDT(reg_idx)];
+
+	/* reset ntu and ntc to place SW in sync with hardwdare */
+	ring->next_to_clean = 0;
+	ring->next_to_use = 0;
+	ring->next_to_alloc = 0;
+
+	/* Configure the Rx buffer size for one buff without split */
+	srrctl |= FM10K_RX_BUFSZ >> FM10K_SRRCTL_BSIZEPKT_SHIFT;
+
+	/* Configure the Rx ring to supress loopback packets */
+	srrctl |= FM10K_SRRCTL_LOOPBACK_SUPPRESS;
+	fm10k_write_reg(hw, FM10K_SRRCTL(reg_idx), srrctl);
+
+	/* Enable drop on empty */
+#if defined(HAVE_DCBNL_IEEE) && defined(CONFIG_DCB)
+	if (interface->pfc_en)
+		rx_pause = interface->pfc_en;
+#endif
+	if (!(rx_pause & (1 << ring->qos_pc)))
+		rxdctl |= FM10K_RXDCTL_DROP_ON_EMPTY;
+
+	fm10k_write_reg(hw, FM10K_RXDCTL(reg_idx), rxdctl);
+
+	/* assign default VLAN to queue */
+	ring->vid = hw->mac.default_vid;
+
+	/* Map interrupt */
+	if (ring->q_vector) {
+		rxint = ring->q_vector->v_idx + NON_Q_VECTORS(hw);
+		rxint |= FM10K_INT_MAP_TIMER1;
+	}
+
+	fm10k_write_reg(hw, FM10K_RXINT(reg_idx), rxint);
+
+	/* enable queue */
+	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), rxqctl);
+}
+
+/**
+ * fm10k_update_rx_drop_en - Configures the drop enable bits for Rx rings
+ * @interface: board private structure
+ *
+ * Configure the drop enable bits for the Rx rings.
+ **/
+void fm10k_update_rx_drop_en(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	u8 rx_pause = interface->rx_pause;
+	int i;
+
+#if defined(HAVE_DCBNL_IEEE) && defined(CONFIG_DCB)
+	if (interface->pfc_en)
+		rx_pause = interface->pfc_en;
+
+#endif
+	for (i = 0; i < interface->num_rx_queues; i++) {
+		struct fm10k_ring *ring = interface->rx_ring[i];
+		u32 rxdctl = FM10K_RXDCTL_WRITE_BACK_MIN_DELAY;
+		u8 reg_idx = ring->reg_idx;
+
+		if (!(rx_pause & (1 << ring->qos_pc)))
+			rxdctl |= FM10K_RXDCTL_DROP_ON_EMPTY;
+
+		fm10k_write_reg(hw, FM10K_RXDCTL(reg_idx), rxdctl);
+	}
+}
+
+/**
+ * fm10k_configure_dglort - Configure Receive DGLORT after reset
+ * @interface: board private structure
+ *
+ * Configure the DGLORT description and RSS tables.
+ **/
+static void fm10k_configure_dglort(struct fm10k_intfc *interface)
+{
+	struct fm10k_dglort_cfg dglort = { 0 };
+	struct fm10k_hw *hw = &interface->hw;
+	int i;
+	u32 mrqc;
+
+	/* Fill out hash function seeds */
+	for (i = 0; i < FM10K_RSSRK_SIZE; i++)
+		fm10k_write_reg(hw, FM10K_RSSRK(0, i), interface->rssrk[i]);
+
+	/* Write RETA table to hardware */
+	for (i = 0; i < FM10K_RETA_SIZE; i++)
+		fm10k_write_reg(hw, FM10K_RETA(0, i), interface->reta[i]);
+
+	/* Generate RSS hash based on packet types, TCP/UDP
+	 * port numbers and/or IPv4/v6 src and dst addresses
+	 */
+	mrqc = FM10K_MRQC_IPV4 |
+	       FM10K_MRQC_TCP_IPV4 |
+	       FM10K_MRQC_IPV6 |
+	       FM10K_MRQC_TCP_IPV6;
+
+	if (interface->flags & FM10K_FLAG_RSS_FIELD_IPV4_UDP)
+		mrqc |= FM10K_MRQC_UDP_IPV4;
+	if (interface->flags & FM10K_FLAG_RSS_FIELD_IPV6_UDP)
+		mrqc |= FM10K_MRQC_UDP_IPV6;
+
+	fm10k_write_reg(hw, FM10K_MRQC(0), mrqc);
+
+	/* configure default DGLORT mapping for RSS/DCB */
+	dglort.inner_rss = 1;
+	dglort.rss_l = fls(interface->ring_feature[RING_F_RSS].mask);
+	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
+	hw->mac.ops.configure_dglort_map(hw, &dglort);
+
+	/* assign GLORT per queue for queue mapped testing */
+	if (interface->glort_count > 64) {
+		memset(&dglort, 0, sizeof(dglort));
+		dglort.inner_rss = 1;
+		dglort.glort = interface->glort + 64;
+		dglort.idx = fm10k_dglort_pf_queue;
+		dglort.queue_l = fls(interface->num_rx_queues - 1);
+		hw->mac.ops.configure_dglort_map(hw, &dglort);
+	}
+
+	/* assign glort value for RSS/DCB specific to this interface */
+	memset(&dglort, 0, sizeof(dglort));
+	dglort.inner_rss = 1;
+	dglort.glort = interface->glort;
+	dglort.rss_l = fls(interface->ring_feature[RING_F_RSS].mask);
+	dglort.pc_l = fls(interface->ring_feature[RING_F_QOS].mask);
+	/* configure DGLORT mapping for RSS/DCB */
+	dglort.idx = fm10k_dglort_pf_rss;
+	hw->mac.ops.configure_dglort_map(hw, &dglort);
+}
+
+/**
+ * fm10k_configure_rx - Configure Receive Unit after Reset
+ * @interface: board private structure
+ *
+ * Configure the Rx unit of the MAC after a reset.
+ **/
+static void fm10k_configure_rx(struct fm10k_intfc *interface)
+{
+	int i;
+
+	/* Configure SWPRI to PC map */
+	fm10k_configure_swpri_map(interface);
+
+	/* Configure RSS and DGLORT map */
+	fm10k_configure_dglort(interface);
+
+	/* Setup the HW Rx Head and Tail descriptor pointers */
+	for (i = 0; i < interface->num_rx_queues; i++)
+		fm10k_configure_rx_ring(interface, interface->rx_ring[i]);
+
+	/* possible poll here to verify that Rx rings are now enabled */
+}
+
 static void fm10k_napi_enable_all(struct fm10k_intfc *interface)
 {
 	struct fm10k_q_vector *q_vector;
@@ -970,6 +1263,12 @@ void fm10k_up(struct fm10k_intfc *interface)
 	/* Enable Tx/Rx DMA */
 	hw->mac.ops.start_hw(hw);
 
+	/* configure Tx descriptor rings */
+	fm10k_configure_tx(interface);
+
+	/* configure Rx descriptor rings */
+	fm10k_configure_rx(interface);
+
 	/* configure interrupts */
 	hw->mac.ops.update_int_moderator(hw);
 
@@ -1031,6 +1330,9 @@ void fm10k_down(struct fm10k_intfc *interface)
 
 	/* Disable DMA engine for Tx/Rx */
 	hw->mac.ops.stop_hw(hw);
+
+	/* free any buffers still on the rings */
+	fm10k_clean_all_tx_rings(interface);
 }
 
 /**
-- 
1.9.3
