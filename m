From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 05/12] amd-xgbe: Implement split header receive
 support
Date: Tue, 4 Nov 2014 16:06:50 -0600
Message-ID: <20141104220650.24738.35279.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0145.outbound.protection.outlook.com ([157.56.111.145]:40496
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752138AbaKDWG4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:56 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide support for splitting IP packets so that the header and
payload can be sent to different DMA addresses.  This will allow
the IP header to be put into the linear part of the skb while the
payload can be added as frags.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    8 +
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c   |  176 +++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |   44 +++++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   63 +++++-----
 drivers/net/ethernet/amd/xgbe/xgbe.h        |   21 ++-
 5 files changed, 201 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index caade30..39bcb11 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -207,6 +207,8 @@
 /* DMA channel register entry bit positions and sizes */
 #define DMA_CH_CR_PBLX8_INDEX		16
 #define DMA_CH_CR_PBLX8_WIDTH		1
+#define DMA_CH_CR_SPH_INDEX		24
+#define DMA_CH_CR_SPH_WIDTH		1
 #define DMA_CH_IER_AIE_INDEX		15
 #define DMA_CH_IER_AIE_WIDTH		1
 #define DMA_CH_IER_FBEE_INDEX		12
@@ -429,6 +431,8 @@
 #define MAC_RCR_CST_WIDTH		1
 #define MAC_RCR_DCRCC_INDEX		3
 #define MAC_RCR_DCRCC_WIDTH		1
+#define MAC_RCR_HDSMS_INDEX		12
+#define MAC_RCR_HDSMS_WIDTH		3
 #define MAC_RCR_IPC_INDEX		9
 #define MAC_RCR_IPC_WIDTH		1
 #define MAC_RCR_JE_INDEX		8
@@ -847,6 +851,8 @@
 
 #define RX_NORMAL_DESC0_OVT_INDEX		0
 #define RX_NORMAL_DESC0_OVT_WIDTH		16
+#define RX_NORMAL_DESC2_HL_INDEX		0
+#define RX_NORMAL_DESC2_HL_WIDTH		10
 #define RX_NORMAL_DESC3_CDA_INDEX		27
 #define RX_NORMAL_DESC3_CDA_WIDTH		1
 #define RX_NORMAL_DESC3_CTXT_INDEX		30
@@ -855,6 +861,8 @@
 #define RX_NORMAL_DESC3_ES_WIDTH		1
 #define RX_NORMAL_DESC3_ETLT_INDEX		16
 #define RX_NORMAL_DESC3_ETLT_WIDTH		4
+#define RX_NORMAL_DESC3_FD_INDEX		29
+#define RX_NORMAL_DESC3_FD_WIDTH		1
 #define RX_NORMAL_DESC3_INTE_INDEX		30
 #define RX_NORMAL_DESC3_INTE_WIDTH		1
 #define RX_NORMAL_DESC3_LD_INDEX		28
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 99911f4..e6b9f54 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -138,15 +138,26 @@ static void xgbe_free_ring(struct xgbe_prv_data *pdata,
 		ring->rdata = NULL;
 	}
 
-	if (ring->rx_pa.pages) {
-		dma_unmap_page(pdata->dev, ring->rx_pa.pages_dma,
-			       ring->rx_pa.pages_len, DMA_FROM_DEVICE);
-		put_page(ring->rx_pa.pages);
-
-		ring->rx_pa.pages = NULL;
-		ring->rx_pa.pages_len = 0;
-		ring->rx_pa.pages_offset = 0;
-		ring->rx_pa.pages_dma = 0;
+	if (ring->rx_hdr_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_hdr_pa.pages_dma,
+			       ring->rx_hdr_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_hdr_pa.pages);
+
+		ring->rx_hdr_pa.pages = NULL;
+		ring->rx_hdr_pa.pages_len = 0;
+		ring->rx_hdr_pa.pages_offset = 0;
+		ring->rx_hdr_pa.pages_dma = 0;
+	}
+
+	if (ring->rx_buf_pa.pages) {
+		dma_unmap_page(pdata->dev, ring->rx_buf_pa.pages_dma,
+			       ring->rx_buf_pa.pages_len, DMA_FROM_DEVICE);
+		put_page(ring->rx_buf_pa.pages);
+
+		ring->rx_buf_pa.pages = NULL;
+		ring->rx_buf_pa.pages_len = 0;
+		ring->rx_buf_pa.pages_offset = 0;
+		ring->rx_buf_pa.pages_dma = 0;
 	}
 
 	if (ring->rdesc) {
@@ -244,62 +255,93 @@ err_ring:
 	return ret;
 }
 
-static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
-			      struct xgbe_ring *ring,
-			      struct xgbe_ring_data *rdata)
+static int xgbe_alloc_pages(struct xgbe_prv_data *pdata,
+			    struct xgbe_page_alloc *pa, gfp_t gfp, int order)
 {
-	if (!ring->rx_pa.pages) {
-		struct page *pages = NULL;
-		dma_addr_t pages_dma;
-		gfp_t gfp;
-		int order, ret;
-
-		/* Try to obtain pages, decreasing order if necessary */
-		gfp = GFP_ATOMIC | __GFP_COLD | __GFP_COMP;
-		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER, 1);
-		while (--order >= 0) {
-			pages = alloc_pages(gfp, order);
-			if (pages)
-				break;
-		}
-		if (!pages)
-			return -ENOMEM;
+	struct page *pages = NULL;
+	dma_addr_t pages_dma;
+	int ret;
 
-		/* Map the pages */
-		pages_dma = dma_map_page(pdata->dev, pages, 0,
-					 PAGE_SIZE << order, DMA_FROM_DEVICE);
-		ret = dma_mapping_error(pdata->dev, pages_dma);
-		if (ret) {
-			put_page(pages);
-			return ret;
-		}
+	/* Try to obtain pages, decreasing order if necessary */
+	gfp |= __GFP_COLD | __GFP_COMP;
+	while (order >= 0) {
+		pages = alloc_pages(gfp, order);
+		if (pages)
+			break;
 
-		/* Set the values for this ring */
-		ring->rx_pa.pages = pages;
-		ring->rx_pa.pages_len = PAGE_SIZE << order;
-		ring->rx_pa.pages_offset = 0;
-		ring->rx_pa.pages_dma = pages_dma;
+		order--;
 	}
+	if (!pages)
+		return -ENOMEM;
 
-	get_page(ring->rx_pa.pages);
-	rdata->rx_pa = ring->rx_pa;
+	/* Map the pages */
+	pages_dma = dma_map_page(pdata->dev, pages, 0,
+				 PAGE_SIZE << order, DMA_FROM_DEVICE);
+	ret = dma_mapping_error(pdata->dev, pages_dma);
+	if (ret) {
+		put_page(pages);
+		return ret;
+	}
 
-	rdata->rx_dma = ring->rx_pa.pages_dma + ring->rx_pa.pages_offset;
-	rdata->rx_dma_len = pdata->rx_buf_size;
+	pa->pages = pages;
+	pa->pages_len = PAGE_SIZE << order;
+	pa->pages_offset = 0;
+	pa->pages_dma = pages_dma;
 
-	ring->rx_pa.pages_offset += pdata->rx_buf_size;
-	if ((ring->rx_pa.pages_offset + pdata->rx_buf_size) >
-	    ring->rx_pa.pages_len) {
+	return 0;
+}
+
+static void xgbe_set_buffer_data(struct xgbe_buffer_data *bd,
+				 struct xgbe_page_alloc *pa,
+				 unsigned int len)
+{
+	get_page(pa->pages);
+	bd->pa = *pa;
+
+	bd->dma = pa->pages_dma + pa->pages_offset;
+	bd->dma_len = len;
+
+	pa->pages_offset += len;
+	if ((pa->pages_offset + len) > pa->pages_len) {
 		/* This data descriptor is responsible for unmapping page(s) */
-		rdata->rx_unmap = ring->rx_pa;
+		bd->pa_unmap = *pa;
 
 		/* Get a new allocation next time */
-		ring->rx_pa.pages = NULL;
-		ring->rx_pa.pages_len = 0;
-		ring->rx_pa.pages_offset = 0;
-		ring->rx_pa.pages_dma = 0;
+		pa->pages = NULL;
+		pa->pages_len = 0;
+		pa->pages_offset = 0;
+		pa->pages_dma = 0;
+	}
+}
+
+static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
+			      struct xgbe_ring *ring,
+			      struct xgbe_ring_data *rdata)
+{
+	int order, ret;
+
+	if (!ring->rx_hdr_pa.pages) {
+		ret = xgbe_alloc_pages(pdata, &ring->rx_hdr_pa, GFP_ATOMIC, 0);
+		if (ret)
+			return ret;
+	}
+
+	if (!ring->rx_buf_pa.pages) {
+		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
+		ret = xgbe_alloc_pages(pdata, &ring->rx_buf_pa, GFP_ATOMIC,
+				       order);
+		if (ret)
+			return ret;
 	}
 
+	/* Set up the header page info */
+	xgbe_set_buffer_data(&rdata->rx_hdr, &ring->rx_hdr_pa,
+			     XGBE_SKB_ALLOC_SIZE);
+
+	/* Set up the buffer page info */
+	xgbe_set_buffer_data(&rdata->rx_buf, &ring->rx_buf_pa,
+			     pdata->rx_buf_size);
+
 	return 0;
 }
 
@@ -409,20 +451,28 @@ static void xgbe_unmap_rdata(struct xgbe_prv_data *pdata,
 		rdata->skb = NULL;
 	}
 
-	if (rdata->rx_pa.pages)
-		put_page(rdata->rx_pa.pages);
+	if (rdata->rx_hdr.pa.pages)
+		put_page(rdata->rx_hdr.pa.pages);
 
-	if (rdata->rx_unmap.pages) {
-		dma_unmap_page(pdata->dev, rdata->rx_unmap.pages_dma,
-			       rdata->rx_unmap.pages_len, DMA_FROM_DEVICE);
-		put_page(rdata->rx_unmap.pages);
+	if (rdata->rx_hdr.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, rdata->rx_hdr.pa_unmap.pages_dma,
+			       rdata->rx_hdr.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(rdata->rx_hdr.pa_unmap.pages);
 	}
 
-	memset(&rdata->rx_pa, 0, sizeof(rdata->rx_pa));
-	memset(&rdata->rx_unmap, 0, sizeof(rdata->rx_unmap));
+	if (rdata->rx_buf.pa.pages)
+		put_page(rdata->rx_buf.pa.pages);
+
+	if (rdata->rx_buf.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, rdata->rx_buf.pa_unmap.pages_dma,
+			       rdata->rx_buf.pa_unmap.pages_len,
+			       DMA_FROM_DEVICE);
+		put_page(rdata->rx_buf.pa_unmap.pages);
+	}
 
-	rdata->rx_dma = 0;
-	rdata->rx_dma_len = 0;
+	memset(&rdata->rx_hdr, 0, sizeof(rdata->rx_hdr));
+	memset(&rdata->rx_buf, 0, sizeof(rdata->rx_buf));
 
 	rdata->tso_header = 0;
 	rdata->len = 0;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 7748b75..b3719f1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -335,6 +335,22 @@ static void xgbe_config_tso_mode(struct xgbe_prv_data *pdata)
 	}
 }
 
+static void xgbe_config_sph_mode(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_CR, SPH, 1);
+	}
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, HDSMS, XGBE_SPH_HDSMS_SIZE);
+}
+
 static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
 {
 	unsigned int max_q_count, q_count;
@@ -920,19 +936,19 @@ static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
 	struct xgbe_ring_desc *rdesc = rdata->rdesc;
 
 	/* Reset the Rx descriptor
-	 *   Set buffer 1 (lo) address to dma address (lo)
-	 *   Set buffer 1 (hi) address to dma address (hi)
-	 *   Set buffer 2 (lo) address to zero
-	 *   Set buffer 2 (hi) address to zero and set control bits
-	 *     OWN and INTE
+	 *   Set buffer 1 (lo) address to header dma address (lo)
+	 *   Set buffer 1 (hi) address to header dma address (hi)
+	 *   Set buffer 2 (lo) address to buffer dma address (lo)
+	 *   Set buffer 2 (hi) address to buffer dma address (hi) and
+	 *     set control bits OWN and INTE
 	 */
-	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->rx_dma));
-	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->rx_dma));
-	rdesc->desc2 = 0;
+	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->rx_hdr.dma));
+	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->rx_hdr.dma));
+	rdesc->desc2 = cpu_to_le32(lower_32_bits(rdata->rx_buf.dma));
+	rdesc->desc3 = cpu_to_le32(upper_32_bits(rdata->rx_buf.dma));
 
-	rdesc->desc3 = 0;
-	if (rdata->interrupt)
-		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE, 1);
+	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE,
+			  rdata->interrupt ? 1 : 0);
 
 	/* Since the Rx DMA engine is likely running, make sure everything
 	 * is written to the descriptor(s) before setting the OWN bit
@@ -1422,6 +1438,11 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
 			       CONTEXT_NEXT, 1);
 
+	/* Get the header length */
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD))
+		rdata->hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
+						   RX_NORMAL_DESC2, HL);
+
 	/* Get the packet length */
 	rdata->len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
 
@@ -2453,6 +2474,7 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	xgbe_config_tx_coalesce(pdata);
 	xgbe_config_rx_buffer_size(pdata);
 	xgbe_config_tso_mode(pdata);
+	xgbe_config_sph_mode(pdata);
 	desc_if->wrapper_tx_desc_init(pdata);
 	desc_if->wrapper_rx_desc_init(pdata);
 	xgbe_enable_dma_interrupts(pdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index d65f5aa..07e2d21 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1620,31 +1620,25 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 
 static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
 				       struct xgbe_ring_data *rdata,
-				       unsigned int len)
+				       unsigned int *len)
 {
 	struct net_device *netdev = pdata->netdev;
 	struct sk_buff *skb;
 	u8 *packet;
 	unsigned int copy_len;
 
-	skb = netdev_alloc_skb_ip_align(netdev, XGBE_SKB_ALLOC_SIZE);
+	skb = netdev_alloc_skb_ip_align(netdev, rdata->rx_hdr.dma_len);
 	if (!skb)
 		return NULL;
 
-	packet = page_address(rdata->rx_pa.pages) + rdata->rx_pa.pages_offset;
-	copy_len = min_t(unsigned int, XGBE_SKB_ALLOC_SIZE, len);
+	packet = page_address(rdata->rx_hdr.pa.pages) +
+		 rdata->rx_hdr.pa.pages_offset;
+	copy_len = (rdata->hdr_len) ? rdata->hdr_len : *len;
+	copy_len = min(rdata->rx_hdr.dma_len, copy_len);
 	skb_copy_to_linear_data(skb, packet, copy_len);
 	skb_put(skb, copy_len);
 
-	rdata->rx_pa.pages_offset += copy_len;
-	len -= copy_len;
-	if (len)
-		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-				rdata->rx_pa.pages,
-				rdata->rx_pa.pages_offset,
-				len, rdata->rx_dma_len);
-	else
-		put_page(rdata->rx_pa.pages);
+	*len -= copy_len;
 
 	return skb;
 }
@@ -1757,10 +1751,6 @@ read_again:
 		ring->cur++;
 		ring->dirty++;
 
-		dma_sync_single_for_cpu(pdata->dev, rdata->rx_dma,
-					rdata->rx_dma_len,
-					DMA_FROM_DEVICE);
-
 		incomplete = XGMAC_GET_BITS(packet->attributes,
 					    RX_PACKET_ATTRIBUTES,
 					    INCOMPLETE);
@@ -1787,19 +1777,30 @@ read_again:
 			len += put_len;
 
 			if (!skb) {
-				skb = xgbe_create_skb(pdata, rdata, put_len);
+				dma_sync_single_for_cpu(pdata->dev,
+							rdata->rx_hdr.dma,
+							rdata->rx_hdr.dma_len,
+							DMA_FROM_DEVICE);
+
+				skb = xgbe_create_skb(pdata, rdata, &put_len);
 				if (!skb) {
 					error = 1;
 					goto read_again;
 				}
-			} else {
-				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-						rdata->rx_pa.pages,
-						rdata->rx_pa.pages_offset,
-						put_len, rdata->rx_dma_len);
 			}
 
-			rdata->rx_pa.pages = NULL;
+			if (put_len) {
+				dma_sync_single_for_cpu(pdata->dev,
+							rdata->rx_buf.dma,
+							rdata->rx_buf.dma_len,
+							DMA_FROM_DEVICE);
+
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						rdata->rx_buf.pa.pages,
+						rdata->rx_buf.pa.pages_offset,
+						put_len, rdata->rx_buf.dma_len);
+				rdata->rx_buf.pa.pages = NULL;
+			}
 		}
 
 		if (incomplete || context_next)
@@ -1924,10 +1925,10 @@ void xgbe_dump_tx_desc(struct xgbe_ring *ring, unsigned int idx,
 	while (count--) {
 		rdata = XGBE_GET_DESC_DATA(ring, idx);
 		rdesc = rdata->rdesc;
-		DBGPR("TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
-		      (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
-		      le32_to_cpu(rdesc->desc0), le32_to_cpu(rdesc->desc1),
-		      le32_to_cpu(rdesc->desc2), le32_to_cpu(rdesc->desc3));
+		pr_alert("TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
+			 (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
+			 le32_to_cpu(rdesc->desc0), le32_to_cpu(rdesc->desc1),
+			 le32_to_cpu(rdesc->desc2), le32_to_cpu(rdesc->desc3));
 		idx++;
 	}
 }
@@ -1935,9 +1936,9 @@ void xgbe_dump_tx_desc(struct xgbe_ring *ring, unsigned int idx,
 void xgbe_dump_rx_desc(struct xgbe_ring *ring, struct xgbe_ring_desc *desc,
 		       unsigned int idx)
 {
-	DBGPR("RX_NORMAL_DESC[%d RX BY DEVICE] = %08x:%08x:%08x:%08x\n", idx,
-	      le32_to_cpu(desc->desc0), le32_to_cpu(desc->desc1),
-	      le32_to_cpu(desc->desc2), le32_to_cpu(desc->desc3));
+	pr_alert("RX_NORMAL_DESC[%d RX BY DEVICE] = %08x:%08x:%08x:%08x\n", idx,
+		 le32_to_cpu(desc->desc0), le32_to_cpu(desc->desc1),
+		 le32_to_cpu(desc->desc2), le32_to_cpu(desc->desc3));
 }
 
 void xgbe_print_pkt(struct net_device *netdev, struct sk_buff *skb, bool tx_rx)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index d3aa055..1480c9d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -143,6 +143,7 @@
 #define XGBE_RX_MIN_BUF_SIZE	(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 #define XGBE_RX_BUF_ALIGN	64
 #define XGBE_SKB_ALLOC_SIZE	256
+#define XGBE_SPH_HDSMS_SIZE	2	/* Keep in sync with SKB_ALLOC_SIZE */
 
 #define XGBE_MAX_DMA_CHANNELS	16
 #define XGBE_MAX_QUEUES		16
@@ -250,6 +251,15 @@ struct xgbe_page_alloc {
 	dma_addr_t pages_dma;
 };
 
+/* Ring entry buffer data */
+struct xgbe_buffer_data {
+	struct xgbe_page_alloc pa;
+	struct xgbe_page_alloc pa_unmap;
+
+	dma_addr_t dma;
+	unsigned int dma_len;
+};
+
 /* Structure used to hold information related to the descriptor
  * and the packet associated with the descriptor (always use
  * use the XGBE_GET_DESC_DATA macro to access this data from the ring)
@@ -263,12 +273,10 @@ struct xgbe_ring_data {
 	unsigned int skb_dma_len;	/* Length of SKB DMA area */
 	unsigned int tso_header;        /* TSO header indicator */
 
-	struct xgbe_page_alloc rx_pa;	/* Rx buffer page allocation */
-	struct xgbe_page_alloc rx_unmap;
-
-	dma_addr_t rx_dma;		/* DMA address of Rx buffer */
-	unsigned int rx_dma_len;	/* Length of the Rx DMA buffer */
+	struct xgbe_buffer_data rx_hdr;	/* Header locations */
+	struct xgbe_buffer_data rx_buf; /* Payload locations */
 
+	unsigned short hdr_len;		/* Length of received header */
 	unsigned short len;		/* Length of received Rx packet */
 
 	unsigned int interrupt;		/* Interrupt indicator */
@@ -308,7 +316,8 @@ struct xgbe_ring {
 	struct xgbe_ring_data *rdata;
 
 	/* Page allocation for RX buffers */
-	struct xgbe_page_alloc rx_pa;
+	struct xgbe_page_alloc rx_hdr_pa;
+	struct xgbe_page_alloc rx_buf_pa;
 
 	/* Ring index values
 	 *  cur   - Tx: index of descriptor to be used for current transfer
