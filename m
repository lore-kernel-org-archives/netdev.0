From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 04/12] amd-xgbe: Use page allocations for Rx
 buffers
Date: Tue, 4 Nov 2014 16:06:44 -0600
Message-ID: <20141104220643.24738.69395.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0101.outbound.protection.outlook.com ([157.56.111.101]:3680
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752484AbaKDWGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:50 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use page allocations for Rx buffers instead of pre-allocating skbs
of a set size.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |  143 ++++++++++++++++++++---------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   60 +++---------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   95 ++++++++++++-------
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   25 ++++-
 4 files changed, 196 insertions(+), 127 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 6fc5da0..99911f4 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -117,7 +117,7 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-static void xgbe_unmap_skb(struct xgbe_prv_data *, struct xgbe_ring_data *);
+static void xgbe_unmap_rdata(struct xgbe_prv_data *, struct xgbe_ring_data *);
 
 static void xgbe_free_ring(struct xgbe_prv_data *pdata,
 			   struct xgbe_ring *ring)
@@ -131,13 +131,24 @@ static void xgbe_free_ring(struct xgbe_prv_data *pdata,
 	if (ring->rdata) {
 		for (i = 0; i < ring->rdesc_count; i++) {
 			rdata = XGBE_GET_DESC_DATA(ring, i);
-			xgbe_unmap_skb(pdata, rdata);
+			xgbe_unmap_rdata(pdata, rdata);
 		}
 
 		kfree(ring->rdata);
 		ring->rdata = NULL;
 	}
 
+	if (ring->rx_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_pa.pages_dma,
+			       ring->rx_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_pa.pages);
+
+		ring->rx_pa.pages = NULL;
+		ring->rx_pa.pages_len = 0;
+		ring->rx_pa.pages_offset = 0;
+		ring->rx_pa.pages_dma = 0;
+	}
+
 	if (ring->rdesc) {
 		dma_free_coherent(pdata->dev,
 				  (sizeof(struct xgbe_ring_desc) *
@@ -233,6 +244,65 @@ err_ring:
 	return ret;
 }
 
+static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
+			      struct xgbe_ring *ring,
+			      struct xgbe_ring_data *rdata)
+{
+	if (!ring->rx_pa.pages) {
+		struct page *pages = NULL;
+		dma_addr_t pages_dma;
+		gfp_t gfp;
+		int order, ret;
+
+		/* Try to obtain pages, decreasing order if necessary */
+		gfp = GFP_ATOMIC | __GFP_COLD | __GFP_COMP;
+		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER, 1);
+		while (--order >= 0) {
+			pages = alloc_pages(gfp, order);
+			if (pages)
+				break;
+		}
+		if (!pages)
+			return -ENOMEM;
+
+		/* Map the pages */
+		pages_dma = dma_map_page(pdata->dev, pages, 0,
+					 PAGE_SIZE << order, DMA_FROM_DEVICE);
+		ret = dma_mapping_error(pdata->dev, pages_dma);
+		if (ret) {
+			put_page(pages);
+			return ret;
+		}
+
+		/* Set the values for this ring */
+		ring->rx_pa.pages = pages;
+		ring->rx_pa.pages_len = PAGE_SIZE << order;
+		ring->rx_pa.pages_offset = 0;
+		ring->rx_pa.pages_dma = pages_dma;
+	}
+
+	get_page(ring->rx_pa.pages);
+	rdata->rx_pa = ring->rx_pa;
+
+	rdata->rx_dma = ring->rx_pa.pages_dma + ring->rx_pa.pages_offset;
+	rdata->rx_dma_len = pdata->rx_buf_size;
+
+	ring->rx_pa.pages_offset += pdata->rx_buf_size;
+	if ((ring->rx_pa.pages_offset + pdata->rx_buf_size) >
+	    ring->rx_pa.pages_len) {
+		/* This data descriptor is responsible for unmapping page(s) */
+		rdata->rx_unmap = ring->rx_pa;
+
+		/* Get a new allocation next time */
+		ring->rx_pa.pages = NULL;
+		ring->rx_pa.pages_len = 0;
+		ring->rx_pa.pages_offset = 0;
+		ring->rx_pa.pages_dma = 0;
+	}
+
+	return 0;
+}
+
 static void xgbe_wrapper_tx_descriptor_init(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
@@ -281,8 +351,7 @@ static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
 	struct xgbe_ring *ring;
 	struct xgbe_ring_desc *rdesc;
 	struct xgbe_ring_data *rdata;
-	dma_addr_t rdesc_dma, skb_dma;
-	struct sk_buff *skb = NULL;
+	dma_addr_t rdesc_dma;
 	unsigned int i, j;
 
 	DBGPR("-->xgbe_wrapper_rx_descriptor_init\n");
@@ -302,22 +371,8 @@ static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
 			rdata->rdesc = rdesc;
 			rdata->rdesc_dma = rdesc_dma;
 
-			/* Allocate skb & assign to each rdesc */
-			skb = dev_alloc_skb(pdata->rx_buf_size);
-			if (skb == NULL)
-				break;
-			skb_dma = dma_map_single(pdata->dev, skb->data,
-						 pdata->rx_buf_size,
-						 DMA_FROM_DEVICE);
-			if (dma_mapping_error(pdata->dev, skb_dma)) {
-				netdev_alert(pdata->netdev,
-					     "failed to do the dma map\n");
-				dev_kfree_skb_any(skb);
+			if (xgbe_map_rx_buffer(pdata, ring, rdata))
 				break;
-			}
-			rdata->skb = skb;
-			rdata->skb_dma = skb_dma;
-			rdata->skb_dma_len = pdata->rx_buf_size;
 
 			rdesc++;
 			rdesc_dma += sizeof(struct xgbe_ring_desc);
@@ -334,8 +389,8 @@ static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
 	DBGPR("<--xgbe_wrapper_rx_descriptor_init\n");
 }
 
-static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
-			   struct xgbe_ring_data *rdata)
+static void xgbe_unmap_rdata(struct xgbe_prv_data *pdata,
+			     struct xgbe_ring_data *rdata)
 {
 	if (rdata->skb_dma) {
 		if (rdata->mapped_as_page) {
@@ -354,6 +409,21 @@ static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
 		rdata->skb = NULL;
 	}
 
+	if (rdata->rx_pa.pages)
+		put_page(rdata->rx_pa.pages);
+
+	if (rdata->rx_unmap.pages) {
+		dma_unmap_page(pdata->dev, rdata->rx_unmap.pages_dma,
+			       rdata->rx_unmap.pages_len, DMA_FROM_DEVICE);
+		put_page(rdata->rx_unmap.pages);
+	}
+
+	memset(&rdata->rx_pa, 0, sizeof(rdata->rx_pa));
+	memset(&rdata->rx_unmap, 0, sizeof(rdata->rx_unmap));
+
+	rdata->rx_dma = 0;
+	rdata->rx_dma_len = 0;
+
 	rdata->tso_header = 0;
 	rdata->len = 0;
 	rdata->interrupt = 0;
@@ -494,7 +564,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 err_out:
 	while (start_index < cur_index) {
 		rdata = XGBE_GET_DESC_DATA(ring, start_index++);
-		xgbe_unmap_skb(pdata, rdata);
+		xgbe_unmap_rdata(pdata, rdata);
 	}
 
 	DBGPR("<--xgbe_map_tx_skb: count=0\n");
@@ -502,40 +572,25 @@ err_out:
 	return 0;
 }
 
-static void xgbe_realloc_skb(struct xgbe_channel *channel)
+static void xgbe_realloc_rx_buffer(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
-	struct sk_buff *skb = NULL;
-	dma_addr_t skb_dma;
 	int i;
 
-	DBGPR("-->xgbe_realloc_skb: rx_ring->rx.realloc_index = %u\n",
+	DBGPR("-->xgbe_realloc_rx_buffer: rx_ring->rx.realloc_index = %u\n",
 	      ring->rx.realloc_index);
 
 	for (i = 0; i < ring->dirty; i++) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->rx.realloc_index);
 
 		/* Reset rdata values */
-		xgbe_unmap_skb(pdata, rdata);
+		xgbe_unmap_rdata(pdata, rdata);
 
-		/* Allocate skb & assign to each rdesc */
-		skb = dev_alloc_skb(pdata->rx_buf_size);
-		if (skb == NULL)
+		if (xgbe_map_rx_buffer(pdata, ring, rdata))
 			break;
-		skb_dma = dma_map_single(pdata->dev, skb->data,
-					 pdata->rx_buf_size, DMA_FROM_DEVICE);
-		if (dma_mapping_error(pdata->dev, skb_dma)) {
-			netdev_alert(pdata->netdev,
-				     "failed to do the dma map\n");
-			dev_kfree_skb_any(skb);
-			break;
-		}
-		rdata->skb = skb;
-		rdata->skb_dma = skb_dma;
-		rdata->skb_dma_len = pdata->rx_buf_size;
 
 		hw_if->rx_desc_reset(rdata);
 
@@ -543,7 +598,7 @@ static void xgbe_realloc_skb(struct xgbe_channel *channel)
 	}
 	ring->dirty = 0;
 
-	DBGPR("<--xgbe_realloc_skb\n");
+	DBGPR("<--xgbe_realloc_rx_buffer\n");
 }
 
 void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *desc_if)
@@ -553,8 +608,8 @@ void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *desc_if)
 	desc_if->alloc_ring_resources = xgbe_alloc_ring_resources;
 	desc_if->free_ring_resources = xgbe_free_ring_resources;
 	desc_if->map_tx_skb = xgbe_map_tx_skb;
-	desc_if->realloc_skb = xgbe_realloc_skb;
-	desc_if->unmap_skb = xgbe_unmap_skb;
+	desc_if->realloc_rx_buffer = xgbe_realloc_rx_buffer;
+	desc_if->unmap_rdata = xgbe_unmap_rdata;
 	desc_if->wrapper_tx_desc_init = xgbe_wrapper_tx_descriptor_init;
 	desc_if->wrapper_rx_desc_init = xgbe_wrapper_rx_descriptor_init;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 7b97d38..7748b75 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -880,13 +880,15 @@ static void xgbe_tx_desc_reset(struct xgbe_ring_data *rdata)
 	rdesc->desc1 = 0;
 	rdesc->desc2 = 0;
 	rdesc->desc3 = 0;
+
+	/* Make sure ownership is written to the descriptor */
+	wmb();
 }
 
 static void xgbe_tx_desc_init(struct xgbe_channel *channel)
 {
 	struct xgbe_ring *ring = channel->tx_ring;
 	struct xgbe_ring_data *rdata;
-	struct xgbe_ring_desc *rdesc;
 	int i;
 	int start_index = ring->cur;
 
@@ -895,26 +897,11 @@ static void xgbe_tx_desc_init(struct xgbe_channel *channel)
 	/* Initialze all descriptors */
 	for (i = 0; i < ring->rdesc_count; i++) {
 		rdata = XGBE_GET_DESC_DATA(ring, i);
-		rdesc = rdata->rdesc;
 
-		/* Initialize Tx descriptor
-		 *   Set buffer 1 (lo) address to zero
-		 *   Set buffer 1 (hi) address to zero
-		 *   Reset all other control bits (IC, TTSE, B2L & B1L)
-		 *   Reset all other control bits (OWN, CTXT, FD, LD, CPC, CIC,
-		 *     etc)
-		 */
-		rdesc->desc0 = 0;
-		rdesc->desc1 = 0;
-		rdesc->desc2 = 0;
-		rdesc->desc3 = 0;
+		/* Initialize Tx descriptor */
+		xgbe_tx_desc_reset(rdata);
 	}
 
-	/* Make sure everything is written to the descriptor(s) before
-	 * telling the device about them
-	 */
-	wmb();
-
 	/* Update the total number of Tx descriptors */
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDRLR, ring->rdesc_count - 1);
 
@@ -939,8 +926,8 @@ static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
 	 *   Set buffer 2 (hi) address to zero and set control bits
 	 *     OWN and INTE
 	 */
-	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->skb_dma));
-	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->skb_dma));
+	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->rx_dma));
+	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->rx_dma));
 	rdesc->desc2 = 0;
 
 	rdesc->desc3 = 0;
@@ -964,7 +951,6 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
-	struct xgbe_ring_desc *rdesc;
 	unsigned int start_index = ring->cur;
 	unsigned int rx_coalesce, rx_frames;
 	unsigned int i;
@@ -977,34 +963,16 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 	/* Initialize all descriptors */
 	for (i = 0; i < ring->rdesc_count; i++) {
 		rdata = XGBE_GET_DESC_DATA(ring, i);
-		rdesc = rdata->rdesc;
 
-		/* Initialize Rx descriptor
-		 *   Set buffer 1 (lo) address to dma address (lo)
-		 *   Set buffer 1 (hi) address to dma address (hi)
-		 *   Set buffer 2 (lo) address to zero
-		 *   Set buffer 2 (hi) address to zero and set control
-		 *     bits OWN and INTE appropriateley
-		 */
-		rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->skb_dma));
-		rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->skb_dma));
-		rdesc->desc2 = 0;
-		rdesc->desc3 = 0;
-		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN, 1);
-		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE, 1);
-		rdata->interrupt = 1;
-		if (rx_coalesce && (!rx_frames || ((i + 1) % rx_frames))) {
-			/* Clear interrupt on completion bit */
-			XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE,
-					  0);
+		/* Set interrupt on completion bit as appropriate */
+		if (rx_coalesce && (!rx_frames || ((i + 1) % rx_frames)))
 			rdata->interrupt = 0;
-		}
-	}
+		else
+			rdata->interrupt = 1;
 
-	/* Make sure everything is written to the descriptors before
-	 * telling the device about them
-	 */
-	wmb();
+		/* Initialize Rx descriptor */
+		xgbe_rx_desc_reset(rdata);
+	}
 
 	/* Update the total number of Rx descriptors */
 	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDRLR, ring->rdesc_count - 1);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 8cb2372..d65f5aa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -218,8 +218,8 @@ static int xgbe_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
 	}
 
 	rx_buf_size = mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
-	if (rx_buf_size < XGBE_RX_MIN_BUF_SIZE)
-		rx_buf_size = XGBE_RX_MIN_BUF_SIZE;
+	rx_buf_size = clamp_val(rx_buf_size, XGBE_RX_MIN_BUF_SIZE, PAGE_SIZE);
+
 	rx_buf_size = (rx_buf_size + XGBE_RX_BUF_ALIGN - 1) &
 		      ~(XGBE_RX_BUF_ALIGN - 1);
 
@@ -546,7 +546,7 @@ void xgbe_init_rx_coalesce(struct xgbe_prv_data *pdata)
 	DBGPR("<--xgbe_init_rx_coalesce\n");
 }
 
-static void xgbe_free_tx_skbuff(struct xgbe_prv_data *pdata)
+static void xgbe_free_tx_data(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
 	struct xgbe_channel *channel;
@@ -554,7 +554,7 @@ static void xgbe_free_tx_skbuff(struct xgbe_prv_data *pdata)
 	struct xgbe_ring_data *rdata;
 	unsigned int i, j;
 
-	DBGPR("-->xgbe_free_tx_skbuff\n");
+	DBGPR("-->xgbe_free_tx_data\n");
 
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
@@ -564,14 +564,14 @@ static void xgbe_free_tx_skbuff(struct xgbe_prv_data *pdata)
 
 		for (j = 0; j < ring->rdesc_count; j++) {
 			rdata = XGBE_GET_DESC_DATA(ring, j);
-			desc_if->unmap_skb(pdata, rdata);
+			desc_if->unmap_rdata(pdata, rdata);
 		}
 	}
 
-	DBGPR("<--xgbe_free_tx_skbuff\n");
+	DBGPR("<--xgbe_free_tx_data\n");
 }
 
-static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
+static void xgbe_free_rx_data(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_desc_if *desc_if = &pdata->desc_if;
 	struct xgbe_channel *channel;
@@ -579,7 +579,7 @@ static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
 	struct xgbe_ring_data *rdata;
 	unsigned int i, j;
 
-	DBGPR("-->xgbe_free_rx_skbuff\n");
+	DBGPR("-->xgbe_free_rx_data\n");
 
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
@@ -589,11 +589,11 @@ static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
 
 		for (j = 0; j < ring->rdesc_count; j++) {
 			rdata = XGBE_GET_DESC_DATA(ring, j);
-			desc_if->unmap_skb(pdata, rdata);
+			desc_if->unmap_rdata(pdata, rdata);
 		}
 	}
 
-	DBGPR("<--xgbe_free_rx_skbuff\n");
+	DBGPR("<--xgbe_free_rx_data\n");
 }
 
 static void xgbe_adjust_link(struct net_device *netdev)
@@ -839,8 +839,8 @@ static void xgbe_restart_dev(struct xgbe_prv_data *pdata, unsigned int reset)
 	xgbe_stop(pdata);
 	synchronize_irq(pdata->irq_number);
 
-	xgbe_free_tx_skbuff(pdata);
-	xgbe_free_rx_skbuff(pdata);
+	xgbe_free_tx_data(pdata);
+	xgbe_free_rx_data(pdata);
 
 	/* Issue software reset to device if requested */
 	if (reset)
@@ -1609,7 +1609,7 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
 
-	desc_if->realloc_skb(channel);
+	desc_if->realloc_rx_buffer(channel);
 
 	/* Update the Rx Tail Pointer Register with address of
 	 * the last cleaned entry */
@@ -1618,6 +1618,37 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 			  lower_32_bits(rdata->rdesc_dma));
 }
 
+static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
+				       struct xgbe_ring_data *rdata,
+				       unsigned int len)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct sk_buff *skb;
+	u8 *packet;
+	unsigned int copy_len;
+
+	skb = netdev_alloc_skb_ip_align(netdev, XGBE_SKB_ALLOC_SIZE);
+	if (!skb)
+		return NULL;
+
+	packet = page_address(rdata->rx_pa.pages) + rdata->rx_pa.pages_offset;
+	copy_len = min_t(unsigned int, XGBE_SKB_ALLOC_SIZE, len);
+	skb_copy_to_linear_data(skb, packet, copy_len);
+	skb_put(skb, copy_len);
+
+	rdata->rx_pa.pages_offset += copy_len;
+	len -= copy_len;
+	if (len)
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				rdata->rx_pa.pages,
+				rdata->rx_pa.pages_offset,
+				len, rdata->rx_dma_len);
+	else
+		put_page(rdata->rx_pa.pages);
+
+	return skb;
+}
+
 static int xgbe_tx_poll(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
@@ -1651,7 +1682,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
 #endif
 
 		/* Free the SKB and reset the descriptor for re-use */
-		desc_if->unmap_skb(pdata, rdata);
+		desc_if->unmap_rdata(pdata, rdata);
 		hw_if->tx_desc_reset(rdata);
 
 		processed++;
@@ -1726,9 +1757,9 @@ read_again:
 		ring->cur++;
 		ring->dirty++;
 
-		dma_unmap_single(pdata->dev, rdata->skb_dma,
-				 rdata->skb_dma_len, DMA_FROM_DEVICE);
-		rdata->skb_dma = 0;
+		dma_sync_single_for_cpu(pdata->dev, rdata->rx_dma,
+					rdata->rx_dma_len,
+					DMA_FROM_DEVICE);
 
 		incomplete = XGMAC_GET_BITS(packet->attributes,
 					    RX_PACKET_ATTRIBUTES,
@@ -1753,26 +1784,22 @@ read_again:
 
 		if (!context) {
 			put_len = rdata->len - len;
-			if (skb) {
-				if (pskb_expand_head(skb, 0, put_len,
-						     GFP_ATOMIC)) {
-					DBGPR("pskb_expand_head error\n");
-					if (incomplete) {
-						error = 1;
-						goto read_again;
-					}
-
-					dev_kfree_skb(skb);
-					goto next_packet;
+			len += put_len;
+
+			if (!skb) {
+				skb = xgbe_create_skb(pdata, rdata, put_len);
+				if (!skb) {
+					error = 1;
+					goto read_again;
 				}
-				memcpy(skb_tail_pointer(skb), rdata->skb->data,
-				       put_len);
 			} else {
-				skb = rdata->skb;
-				rdata->skb = NULL;
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						rdata->rx_pa.pages,
+						rdata->rx_pa.pages_offset,
+						put_len, rdata->rx_dma_len);
 			}
-			skb_put(skb, put_len);
-			len += put_len;
+
+			rdata->rx_pa.pages = NULL;
 		}
 
 		if (incomplete || context_next)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 19f1d90..d3aa055 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -142,6 +142,7 @@
 
 #define XGBE_RX_MIN_BUF_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 #define XGBE_RX_BUF_ALIGN	64
+#define XGBE_SKB_ALLOC_SIZE	256
 
 #define XGBE_MAX_DMA_CHANNELS	16
 #define XGBE_MAX_QUEUES		16
@@ -240,6 +241,15 @@ struct xgbe_ring_desc {
 	u32 desc3;
 };
 
+/* Page allocation related values */
+struct xgbe_page_alloc {
+	struct page *pages;
+	unsigned int pages_len;
+	unsigned int pages_offset;
+
+	dma_addr_t pages_dma;
+};
+
 /* Structure used to hold information related to the descriptor
  * and the packet associated with the descriptor (always use
  * use the XGBE_GET_DESC_DATA macro to access this data from the ring)
@@ -253,6 +263,12 @@ struct xgbe_ring_data {
 	unsigned int skb_dma_len;	/* Length of SKB DMA area */
 	unsigned int tso_header;        /* TSO header indicator */
 
+	struct xgbe_page_alloc rx_pa;	/* Rx buffer page allocation */
+	struct xgbe_page_alloc rx_unmap;
+
+	dma_addr_t rx_dma;		/* DMA address of Rx buffer */
+	unsigned int rx_dma_len;	/* Length of the Rx DMA buffer */
+
 	unsigned short len;		/* Length of received Rx packet */
 
 	unsigned int interrupt;		/* Interrupt indicator */
@@ -291,6 +307,9 @@ struct xgbe_ring {
 	 */
 	struct xgbe_ring_data *rdata;
 
+	/* Page allocation for RX buffers */
+	struct xgbe_page_alloc rx_pa;
+
 	/* Ring index values
 	 *  cur   - Tx: index of descriptor to be used for current transfer
 	 *          Rx: index of descriptor to check for packet availability
@@ -515,8 +534,8 @@ struct xgbe_desc_if {
 	int (*alloc_ring_resources)(struct xgbe_prv_data *);
 	void (*free_ring_resources)(struct xgbe_prv_data *);
 	int (*map_tx_skb)(struct xgbe_channel *, struct sk_buff *);
-	void (*realloc_skb)(struct xgbe_channel *);
-	void (*unmap_skb)(struct xgbe_prv_data *, struct xgbe_ring_data *);
+	void (*realloc_rx_buffer)(struct xgbe_channel *);
+	void (*unmap_rdata)(struct xgbe_prv_data *, struct xgbe_ring_data *);
 	void (*wrapper_tx_desc_init)(struct xgbe_prv_data *);
 	void (*wrapper_rx_desc_init)(struct xgbe_prv_data *);
 };
@@ -624,7 +643,7 @@ struct xgbe_prv_data {
 	unsigned int rx_riwt;
 	unsigned int rx_frames;
 
-	/* Current MTU */
+	/* Current Rx buffer size */
 	unsigned int rx_buf_size;
 
 	/* Flow control settings */
