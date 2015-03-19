From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 10/10] amd-xgbe: Rework the Rx path SKB
 allocation
Date: Thu, 19 Mar 2015 15:09:08 -0500
Message-ID: <20150319200908.28321.60118.stgit@tlendack-t1.amdoffice.net>
References: <20150319200808.28321.37307.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0118.outbound.protection.outlook.com ([65.55.169.118]:59328
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751545AbbCSUJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 16:09:14 -0400
In-Reply-To: <20150319200808.28321.37307.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver creates an SKB it currently only copies the header
buffer data (which can be just the header if split header processing
succeeded or header plus data if split header processing did not
succeed) into the SKB. The receive buffer data is always added as a
frag, even if it could fit in the SKB. As part of SKB creation, inline
the receive buffer data if it will fit in the the SKB, otherwise add it
as a frag during SKB creation.

Also, Update the code to trigger off of the first/last descriptor
indicators and remove the incomplete indicator.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   14 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c   |    2 -
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |   17 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   87 +++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    2 -
 5 files changed, 74 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 34c28aa..44dded5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -871,15 +871,17 @@
 #define RX_PACKET_ATTRIBUTES_CSUM_DONE_WIDTH	1
 #define RX_PACKET_ATTRIBUTES_VLAN_CTAG_INDEX	1
 #define RX_PACKET_ATTRIBUTES_VLAN_CTAG_WIDTH	1
-#define RX_PACKET_ATTRIBUTES_INCOMPLETE_INDEX	2
-#define RX_PACKET_ATTRIBUTES_INCOMPLETE_WIDTH	1
-#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_INDEX	3
+#define RX_PACKET_ATTRIBUTES_FIRST_DESC_INDEX	2
+#define RX_PACKET_ATTRIBUTES_FIRST_DESC_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_LAST_DESC_INDEX	3
+#define RX_PACKET_ATTRIBUTES_LAST_DESC_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_INDEX	4
 #define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_WIDTH	1
-#define RX_PACKET_ATTRIBUTES_CONTEXT_INDEX	4
+#define RX_PACKET_ATTRIBUTES_CONTEXT_INDEX	5
 #define RX_PACKET_ATTRIBUTES_CONTEXT_WIDTH	1
-#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_INDEX	5
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_INDEX	6
 #define RX_PACKET_ATTRIBUTES_RX_TSTAMP_WIDTH	1
-#define RX_PACKET_ATTRIBUTES_RSS_HASH_INDEX	6
+#define RX_PACKET_ATTRIBUTES_RSS_HASH_INDEX	7
 #define RX_PACKET_ATTRIBUTES_RSS_HASH_WIDTH	1
 
 #define RX_NORMAL_DESC0_OVT_INDEX		0
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index d81fc6b..585ee66 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -476,8 +476,6 @@ static void xgbe_unmap_rdata(struct xgbe_prv_data *pdata,
 
 	if (rdata->state_saved) {
 		rdata->state_saved = 0;
-		rdata->state.incomplete = 0;
-		rdata->state.context_next = 0;
 		rdata->state.skb = NULL;
 		rdata->state.len = 0;
 		rdata->state.error = 0;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 80dd7a9..7f6f0ff 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1641,9 +1641,16 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 			       CONTEXT_NEXT, 1);
 
 	/* Get the header length */
-	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD))
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD)) {
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       FIRST_DESC, 1);
 		rdata->rx.hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
 						      RX_NORMAL_DESC2, HL);
+	} else {
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       FIRST_DESC, 0);
+		rdata->rx.hdr_len = 0;
+	}
 
 	/* Get the RSS hash */
 	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, RSV)) {
@@ -1668,16 +1675,12 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	/* Get the packet length */
 	rdata->rx.len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
 
-	if (!XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, LD)) {
+	if (!XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, LD))
 		/* Not all the data has been transferred for this packet */
-		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
-			       INCOMPLETE, 1);
 		return 0;
-	}
 
 	/* This is the last of the data for this packet */
-	XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
-		       INCOMPLETE, 0);
+	XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES, LAST_DESC, 1);
 
 	/* Set checksum done indicator as appropriate */
 	if (channel->pdata->netdev->features & NETIF_F_RXCSUM)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 347fe24..e357b69 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1821,26 +1821,59 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 			  lower_32_bits(rdata->rdesc_dma));
 }
 
-static struct sk_buff *xgbe_create_skb(struct napi_struct *napi,
-				       struct xgbe_ring_data *rdata,
-				       unsigned int *len)
+static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
+				       struct napi_struct *napi,
+				       struct xgbe_ring_data *rdata)
 {
 	struct sk_buff *skb;
 	u8 *packet;
-	unsigned int copy_len;
+	unsigned int skb_len, hdr_len, data_len, copy_len;
 
-	skb = napi_alloc_skb(napi, rdata->rx.hdr.dma_len);
+	skb_len = rdata->rx.hdr.dma_len;
+	skb = napi_alloc_skb(napi, skb_len);
 	if (!skb)
 		return NULL;
 
+	hdr_len = rdata->rx.hdr_len;
+	data_len = rdata->rx.len;
+
+	/* Start with the header buffer which may contain
+	 * just the header or the header plus data
+	 */
+	dma_sync_single_for_cpu(pdata->dev, rdata->rx.hdr.dma,
+				rdata->rx.hdr.dma_len, DMA_FROM_DEVICE);
+
+	copy_len = (hdr_len) ? hdr_len : data_len;
+	copy_len = min(copy_len, skb_len);
+
 	packet = page_address(rdata->rx.hdr.pa.pages) +
 		 rdata->rx.hdr.pa.pages_offset;
-	copy_len = (rdata->rx.hdr_len) ? rdata->rx.hdr_len : *len;
-	copy_len = min(rdata->rx.hdr.dma_len, copy_len);
 	skb_copy_to_linear_data(skb, packet, copy_len);
 	skb_put(skb, copy_len);
 
-	*len -= copy_len;
+	data_len -= copy_len;
+	if (!data_len)
+		return skb;
+
+	/* More data, see if it can be inlined */
+	dma_sync_single_for_cpu(pdata->dev, rdata->rx.buf.dma,
+				rdata->rx.buf.dma_len, DMA_FROM_DEVICE);
+
+	skb_len -= copy_len;
+	if (data_len < skb_len) {
+		/* Inline the remaining data */
+		packet = page_address(rdata->rx.buf.pa.pages) +
+			 rdata->rx.buf.pa.pages_offset;
+		skb_copy_to_linear_data_offset(skb, copy_len, packet, data_len);
+		skb_put(skb, data_len);
+	} else {
+		/* Add the remaining data as a frag */
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				rdata->rx.buf.pa.pages,
+				rdata->rx.buf.pa.pages_offset,
+				data_len, rdata->rx.buf.dma_len);
+		rdata->rx.buf.pa.pages = NULL;
+	}
 
 	return skb;
 }
@@ -1922,7 +1955,7 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	struct napi_struct *napi;
 	struct sk_buff *skb;
 	struct skb_shared_hwtstamps *hwtstamps;
-	unsigned int incomplete, error, context_next, context;
+	unsigned int first_desc, last_desc, error, context_next, context;
 	unsigned int len, put_len, max_len;
 	unsigned int received = 0;
 	int packet_count = 0;
@@ -1935,6 +1968,9 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 
 	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
 
+	last_desc = 0;
+	context_next = 0;
+
 	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	packet = &ring->packet_data;
 	while (packet_count < budget) {
@@ -1942,15 +1978,11 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 
 		/* First time in loop see if we need to restore state */
 		if (!received && rdata->state_saved) {
-			incomplete = rdata->state.incomplete;
-			context_next = rdata->state.context_next;
 			skb = rdata->state.skb;
 			error = rdata->state.error;
 			len = rdata->state.len;
 		} else {
 			memset(packet, 0, sizeof(*packet));
-			incomplete = 0;
-			context_next = 0;
 			skb = NULL;
 			error = 0;
 			len = 0;
@@ -1968,9 +2000,10 @@ read_again:
 		received++;
 		ring->cur++;
 
-		incomplete = XGMAC_GET_BITS(packet->attributes,
-					    RX_PACKET_ATTRIBUTES,
-					    INCOMPLETE);
+		first_desc = XGMAC_GET_BITS(packet->attributes,
+					    RX_PACKET_ATTRIBUTES, FIRST_DESC);
+		last_desc = XGMAC_GET_BITS(packet->attributes,
+					   RX_PACKET_ATTRIBUTES, LAST_DESC);
 		context_next = XGMAC_GET_BITS(packet->attributes,
 					      RX_PACKET_ATTRIBUTES,
 					      CONTEXT_NEXT);
@@ -1979,7 +2012,7 @@ read_again:
 					 CONTEXT);
 
 		/* Earlier error, just drain the remaining data */
-		if ((incomplete || context_next) && error)
+		if ((!last_desc || context_next) && error)
 			goto read_again;
 
 		if (error || packet->errors) {
@@ -1990,23 +2023,17 @@ read_again:
 		}
 
 		if (!context) {
+			/* Returned data length is cumulative */
 			put_len = rdata->rx.len - len;
 			len += put_len;
 
-			if (!skb) {
-				dma_sync_single_for_cpu(pdata->dev,
-							rdata->rx.hdr.dma,
-							rdata->rx.hdr.dma_len,
-							DMA_FROM_DEVICE);
-
-				skb = xgbe_create_skb(napi, rdata, &put_len);
+			if (first_desc) {
+				skb = xgbe_create_skb(pdata, napi, rdata);
 				if (!skb) {
 					error = 1;
 					goto skip_data;
 				}
-			}
-
-			if (put_len) {
+			} else {
 				dma_sync_single_for_cpu(pdata->dev,
 							rdata->rx.buf.dma,
 							rdata->rx.buf.dma_len,
@@ -2021,7 +2048,7 @@ read_again:
 		}
 
 skip_data:
-		if (incomplete || context_next)
+		if (!last_desc || context_next)
 			goto read_again;
 
 		if (!skb)
@@ -2081,11 +2108,9 @@ next_packet:
 	}
 
 	/* Check if we need to save state before leaving */
-	if (received && (incomplete || context_next)) {
+	if (received && (!last_desc || context_next)) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 		rdata->state_saved = 1;
-		rdata->state.incomplete = incomplete;
-		rdata->state.context_next = context_next;
 		rdata->state.skb = skb;
 		rdata->state.len = len;
 		rdata->state.error = error;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index dd74242..296ad26 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -336,8 +336,6 @@ struct xgbe_ring_data {
 	 */
 	unsigned int state_saved;
 	struct {
-		unsigned int incomplete;
-		unsigned int context_next;
 		struct sk_buff *skb;
 		unsigned int len;
 		unsigned int error;
