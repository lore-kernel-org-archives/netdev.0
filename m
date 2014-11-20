From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 4/8] amd-xgbe: Separate Tx/Rx ring data fields
 into new structs
Date: Thu, 20 Nov 2014 11:03:44 -0600
Message-ID: <20141120170344.15397.21644.stgit@tlendack-t1.amdoffice.net>
References: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:50912
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758000AbaKTRDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 12:03:52 -0500
In-Reply-To: <20141120170320.15397.10583.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tx and Rx related fields within the xgbe_ring_data struct into
their own structs in order to more easily see what fields are used for
each operation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |   36 ++++++++++++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c  |   14 ++++++-----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   28 +++++++++++------------
 drivers/net/ethernet/amd/xgbe/xgbe.h      |   22 +++++++++++++-----
 4 files changed, 54 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index e6b9f54..3c7c386 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -335,11 +335,11 @@ static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
 	}
 
 	/* Set up the header page info */
-	xgbe_set_buffer_data(&rdata->rx_hdr, &ring->rx_hdr_pa,
+	xgbe_set_buffer_data(&rdata->rx.hdr, &ring->rx_hdr_pa,
 			     XGBE_SKB_ALLOC_SIZE);
 
 	/* Set up the buffer page info */
-	xgbe_set_buffer_data(&rdata->rx_buf, &ring->rx_buf_pa,
+	xgbe_set_buffer_data(&rdata->rx.buf, &ring->rx_buf_pa,
 			     pdata->rx_buf_size);
 
 	return 0;
@@ -451,31 +451,29 @@ static void xgbe_unmap_rdata(struct xgbe_prv_data *pdata,
 		rdata->skb = NULL;
 	}
 
-	if (rdata->rx_hdr.pa.pages)
-		put_page(rdata->rx_hdr.pa.pages);
+	if (rdata->rx.hdr.pa.pages)
+		put_page(rdata->rx.hdr.pa.pages);
 
-	if (rdata->rx_hdr.pa_unmap.pages) {
-		dma_unmap_page(pdata->dev, rdata->rx_hdr.pa_unmap.pages_dma,
-			       rdata->rx_hdr.pa_unmap.pages_len,
+	if (rdata->rx.hdr.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, rdata->rx.hdr.pa_unmap.pages_dma,
+			       rdata->rx.hdr.pa_unmap.pages_len,
 			       DMA_FROM_DEVICE);
-		put_page(rdata->rx_hdr.pa_unmap.pages);
+		put_page(rdata->rx.hdr.pa_unmap.pages);
 	}
 
-	if (rdata->rx_buf.pa.pages)
-		put_page(rdata->rx_buf.pa.pages);
+	if (rdata->rx.buf.pa.pages)
+		put_page(rdata->rx.buf.pa.pages);
 
-	if (rdata->rx_buf.pa_unmap.pages) {
-		dma_unmap_page(pdata->dev, rdata->rx_buf.pa_unmap.pages_dma,
-			       rdata->rx_buf.pa_unmap.pages_len,
+	if (rdata->rx.buf.pa_unmap.pages) {
+		dma_unmap_page(pdata->dev, rdata->rx.buf.pa_unmap.pages_dma,
+			       rdata->rx.buf.pa_unmap.pages_len,
 			       DMA_FROM_DEVICE);
-		put_page(rdata->rx_buf.pa_unmap.pages);
+		put_page(rdata->rx.buf.pa_unmap.pages);
 	}
 
-	memset(&rdata->rx_hdr, 0, sizeof(rdata->rx_hdr));
-	memset(&rdata->rx_buf, 0, sizeof(rdata->rx_buf));
+	memset(&rdata->tx, 0, sizeof(rdata->tx));
+	memset(&rdata->rx, 0, sizeof(rdata->rx));
 
-	rdata->tso_header = 0;
-	rdata->len = 0;
 	rdata->interrupt = 0;
 	rdata->mapped_as_page = 0;
 
@@ -534,7 +532,7 @@ static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
 		}
 		rdata->skb_dma = skb_dma;
 		rdata->skb_dma_len = packet->header_len;
-		rdata->tso_header = 1;
+		rdata->tx.tso_header = 1;
 
 		offset = packet->header_len;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 72425ff..2908ad1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1085,10 +1085,10 @@ static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
 	 *   Set buffer 2 (hi) address to buffer dma address (hi) and
 	 *     set control bits OWN and INTE
 	 */
-	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->rx_hdr.dma));
-	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->rx_hdr.dma));
-	rdesc->desc2 = cpu_to_le32(lower_32_bits(rdata->rx_buf.dma));
-	rdesc->desc3 = cpu_to_le32(upper_32_bits(rdata->rx_buf.dma));
+	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->rx.hdr.dma));
+	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->rx.hdr.dma));
+	rdesc->desc2 = cpu_to_le32(lower_32_bits(rdata->rx.buf.dma));
+	rdesc->desc3 = cpu_to_le32(upper_32_bits(rdata->rx.buf.dma));
 
 	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE,
 			  rdata->interrupt ? 1 : 0);
@@ -1586,8 +1586,8 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 
 	/* Get the header length */
 	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD))
-		rdata->hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
-						   RX_NORMAL_DESC2, HL);
+		rdata->rx.hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
+						      RX_NORMAL_DESC2, HL);
 
 	/* Get the RSS hash */
 	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, RSV)) {
@@ -1610,7 +1610,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	}
 
 	/* Get the packet length */
-	rdata->len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
+	rdata->rx.len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
 
 	if (!XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, LD)) {
 		/* Not all the data has been transferred for this packet */
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index eebb787..46ea423 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1747,14 +1747,14 @@ static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
 	u8 *packet;
 	unsigned int copy_len;
 
-	skb = netdev_alloc_skb_ip_align(netdev, rdata->rx_hdr.dma_len);
+	skb = netdev_alloc_skb_ip_align(netdev, rdata->rx.hdr.dma_len);
 	if (!skb)
 		return NULL;
 
-	packet = page_address(rdata->rx_hdr.pa.pages) +
-		 rdata->rx_hdr.pa.pages_offset;
-	copy_len = (rdata->hdr_len) ? rdata->hdr_len : *len;
-	copy_len = min(rdata->rx_hdr.dma_len, copy_len);
+	packet = page_address(rdata->rx.hdr.pa.pages) +
+		 rdata->rx.hdr.pa.pages_offset;
+	copy_len = (rdata->rx.hdr_len) ? rdata->rx.hdr_len : *len;
+	copy_len = min(rdata->rx.hdr.dma_len, copy_len);
 	skb_copy_to_linear_data(skb, packet, copy_len);
 	skb_put(skb, copy_len);
 
@@ -1900,13 +1900,13 @@ read_again:
 		}
 
 		if (!context) {
-			put_len = rdata->len - len;
+			put_len = rdata->rx.len - len;
 			len += put_len;
 
 			if (!skb) {
 				dma_sync_single_for_cpu(pdata->dev,
-							rdata->rx_hdr.dma,
-							rdata->rx_hdr.dma_len,
+							rdata->rx.hdr.dma,
+							rdata->rx.hdr.dma_len,
 							DMA_FROM_DEVICE);
 
 				skb = xgbe_create_skb(pdata, rdata, &put_len);
@@ -1918,15 +1918,15 @@ read_again:
 
 			if (put_len) {
 				dma_sync_single_for_cpu(pdata->dev,
-							rdata->rx_buf.dma,
-							rdata->rx_buf.dma_len,
+							rdata->rx.buf.dma,
+							rdata->rx.buf.dma_len,
 							DMA_FROM_DEVICE);
 
 				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-						rdata->rx_buf.pa.pages,
-						rdata->rx_buf.pa.pages_offset,
-						put_len, rdata->rx_buf.dma_len);
-				rdata->rx_buf.pa.pages = NULL;
+						rdata->rx.buf.pa.pages,
+						rdata->rx.buf.pa.pages_offset,
+						put_len, rdata->rx.buf.dma_len);
+				rdata->rx.buf.pa.pages = NULL;
 			}
 		}
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 46ce544..41ce6e3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -271,6 +271,20 @@ struct xgbe_buffer_data {
 	unsigned int dma_len;
 };
 
+/* Tx-related ring data */
+struct xgbe_tx_ring_data {
+	unsigned int tso_header;	/* TSO header indicator */
+};
+
+/* Rx-related ring data */
+struct xgbe_rx_ring_data {
+	struct xgbe_buffer_data hdr;	/* Header locations */
+	struct xgbe_buffer_data buf;	/* Payload locations */
+
+	unsigned short hdr_len;		/* Length of received header */
+	unsigned short len;		/* Length of received packet */
+};
+
 /* Structure used to hold information related to the descriptor
  * and the packet associated with the descriptor (always use
  * use the XGBE_GET_DESC_DATA macro to access this data from the ring)
@@ -282,13 +296,9 @@ struct xgbe_ring_data {
 	struct sk_buff *skb;		/* Virtual address of SKB */
 	dma_addr_t skb_dma;		/* DMA address of SKB data */
 	unsigned int skb_dma_len;	/* Length of SKB DMA area */
-	unsigned int tso_header;        /* TSO header indicator */
 
-	struct xgbe_buffer_data rx_hdr;	/* Header locations */
-	struct xgbe_buffer_data rx_buf; /* Payload locations */
-
-	unsigned short hdr_len;		/* Length of received header */
-	unsigned short len;		/* Length of received Rx packet */
+	struct xgbe_tx_ring_data tx;	/* Tx-related data */
+	struct xgbe_rx_ring_data rx;	/* Rx-related data */
 
 	unsigned int interrupt;		/* Interrupt indicator */
 
