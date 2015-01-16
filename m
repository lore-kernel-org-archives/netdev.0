From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 06/12] amd-xgbe: Simplify the Rx desciptor ring
 tracking
Date: Fri, 16 Jan 2015 12:46:50 -0600
Message-ID: <20150116184650.18809.3865.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44022 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751896AbbAPSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:29 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the Rx descriptor ring processing similar to the Tx descriptor
ring processing.  Remove the realloc_index and realloc_threshold
variables and base everything on the current index counter and the
dirty index counter.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |   32 +----------------------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   25 +++++++++++++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   11 +++-------
 3 files changed, 25 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index a50891f..d81fc6b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -422,7 +422,6 @@ static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
 
 		ring->cur = 0;
 		ring->dirty = 0;
-		memset(&ring->rx, 0, sizeof(ring->rx));
 
 		hw_if->rx_desc_init(channel);
 	}
@@ -621,35 +620,6 @@ err_out:
 	return 0;
 }
 
-static void xgbe_realloc_rx_buffer(struct xgbe_channel *channel)
-{
-	struct xgbe_prv_data *pdata = channel->pdata;
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	struct xgbe_ring *ring = channel->rx_ring;
-	struct xgbe_ring_data *rdata;
-	int i;
-
-	DBGPR("-->xgbe_realloc_rx_buffer: rx_ring->rx.realloc_index = %u\n",
-	      ring->rx.realloc_index);
-
-	for (i = 0; i < ring->dirty; i++) {
-		rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index);
-
-		/* Reset rdata values */
-		xgbe_unmap_rdata(pdata, rdata);
-
-		if (xgbe_map_rx_buffer(pdata, ring, rdata))
-			break;
-
-		hw_if->rx_desc_reset(rdata);
-
-		ring->rx.realloc_index++;
-	}
-	ring->dirty = 0;
-
-	DBGPR("<--xgbe_realloc_rx_buffer\n");
-}
-
 void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *desc_if)
 {
 	DBGPR("-->xgbe_init_function_ptrs_desc\n");
@@ -657,7 +627,7 @@ void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *desc_if)
 	desc_if->alloc_ring_resources = xgbe_alloc_ring_resources;
 	desc_if->free_ring_resources = xgbe_free_ring_resources;
 	desc_if->map_tx_skb = xgbe_map_tx_skb;
-	desc_if->realloc_rx_buffer = xgbe_realloc_rx_buffer;
+	desc_if->map_rx_buffer = xgbe_map_rx_buffer;
 	desc_if->unmap_rdata = xgbe_unmap_rdata;
 	desc_if->wrapper_tx_desc_init = xgbe_wrapper_tx_descriptor_init;
 	desc_if->wrapper_rx_desc_init = xgbe_wrapper_rx_descriptor_init;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index bdb373c..e2f560f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -225,6 +225,11 @@ static inline unsigned int xgbe_tx_avail_desc(struct xgbe_ring *ring)
 	return (ring->rdesc_count - (ring->cur - ring->dirty));
 }
 
+static inline unsigned int xgbe_rx_dirty_desc(struct xgbe_ring *ring)
+{
+	return (ring->cur - ring->dirty);
+}
+
 static int xgbe_maybe_stop_tx_queue(struct xgbe_channel *channel,
 				    struct xgbe_ring *ring, unsigned int count)
 {
@@ -1775,15 +1780,28 @@ struct net_device_ops *xgbe_get_netdev_ops(void)
 static void xgbe_rx_refresh(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
 
-	desc_if->realloc_rx_buffer(channel);
+	while (ring->dirty != ring->cur) {
+		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
+
+		/* Reset rdata values */
+		desc_if->unmap_rdata(pdata, rdata);
+
+		if (desc_if->map_rx_buffer(pdata, ring, rdata))
+			break;
+
+		hw_if->rx_desc_reset(rdata);
+
+		ring->dirty++;
+	}
 
 	/* Update the Rx Tail Pointer Register with address of
 	 * the last cleaned entry */
-	rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
+	rdata = XGBE_GET_DESC_DATA(ring, ring->dirty - 1);
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
 			  lower_32_bits(rdata->rdesc_dma));
 }
@@ -1933,7 +1951,7 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 read_again:
 		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 
-		if (ring->dirty > (XGBE_RX_DESC_CNT >> 3))
+		if (xgbe_rx_dirty_desc(ring) > (XGBE_RX_DESC_CNT >> 3))
 			xgbe_rx_refresh(channel);
 
 		if (hw_if->dev_read(channel))
@@ -1941,7 +1959,6 @@ read_again:
 
 		received++;
 		ring->cur++;
-		ring->dirty++;
 
 		incomplete = XGMAC_GET_BITS(packet->attributes,
 					    RX_PACKET_ATTRIBUTES,
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 2af6aff..e6ee64e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -361,8 +361,7 @@ struct xgbe_ring {
 	 *  cur   - Tx: index of descriptor to be used for current transfer
 	 *          Rx: index of descriptor to check for packet availability
 	 *  dirty - Tx: index of descriptor to check for transfer complete
-	 *          Rx: count of descriptors in which a packet has been received
-	 *              (used with skb_realloc_index to refresh the ring)
+	 *          Rx: index of descriptor to check for buffer reallocation
 	 */
 	unsigned int cur;
 	unsigned int dirty;
@@ -377,11 +376,6 @@ struct xgbe_ring {
 			unsigned short cur_mss;
 			unsigned short cur_vlan_ctag;
 		} tx;
-
-		struct {
-			unsigned int realloc_index;
-			unsigned int realloc_threshold;
-		} rx;
 	};
 } ____cacheline_aligned;
 
@@ -596,7 +590,8 @@ struct xgbe_desc_if {
 	int (*alloc_ring_resources)(struct xgbe_prv_data *);
 	void (*free_ring_resources)(struct xgbe_prv_data *);
 	int (*map_tx_skb)(struct xgbe_channel *, struct sk_buff *);
-	void (*realloc_rx_buffer)(struct xgbe_channel *);
+	int (*map_rx_buffer)(struct xgbe_prv_data *, struct xgbe_ring *,
+			     struct xgbe_ring_data *);
 	void (*unmap_rdata)(struct xgbe_prv_data *, struct xgbe_ring_data *);
 	void (*wrapper_tx_desc_init)(struct xgbe_prv_data *);
 	void (*wrapper_rx_desc_init)(struct xgbe_prv_data *);
