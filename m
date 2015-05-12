From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/7] amd-xgbe: Rework the Rx path SKB allocation
Date: Tue, 12 May 2015 14:22:48 -0500
Message-ID: <20150512192248.14091.58347.stgit@tlendack-t1.amdoffice.net>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0142.outbound.protection.outlook.com ([65.55.169.142]:38197
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933471AbbELTWz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 15:22:55 -0400
In-Reply-To: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework the SKB allocation so that all of the buffers of the first
descriptor are handled in the SKB allocation routine. After copying the
data in the header buffer (which can be just the header if split header
processing succeeded for header plus data if split header processing did
not succeed) into the SKB, check for remaining data in the receive
buffer. If there is data remaining in the receive buffer, add that as a
frag to the SKB. Once an SKB has been allocated, all other descriptors
are added as frags to the SKB.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    2 -
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c  |   66 ++++++++++++++++-------------
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    2 -
 3 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 6f2a914..0ad54c1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -484,8 +484,6 @@ static void xgbe_unmap_rdata(struct xgbe_prv_data *pdata,
 
 	if (rdata->state_saved) {
 		rdata->state_saved = 0;
-		rdata->state.incomplete = 0;
-		rdata->state.context_next = 0;
 		rdata->state.skb = NULL;
 		rdata->state.len = 0;
 		rdata->state.error = 0;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index a93bbc6..102e354 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1829,9 +1829,10 @@ static void xgbe_rx_refresh(struct xgbe_channel *channel)
 			  lower_32_bits(rdata->rdesc_dma));
 }
 
-static struct sk_buff *xgbe_create_skb(struct napi_struct *napi,
+static struct sk_buff *xgbe_create_skb(struct xgbe_prv_data *pdata,
+				       struct napi_struct *napi,
 				       struct xgbe_ring_data *rdata,
-				       unsigned int *len)
+				       unsigned int len)
 {
 	struct sk_buff *skb;
 	u8 *packet;
@@ -1841,14 +1842,31 @@ static struct sk_buff *xgbe_create_skb(struct napi_struct *napi,
 	if (!skb)
 		return NULL;
 
+	/* Start with the header buffer which may contain just the header
+	 * or the header plus data
+	 */
+	dma_sync_single_for_cpu(pdata->dev, rdata->rx.hdr.dma,
+				rdata->rx.hdr.dma_len, DMA_FROM_DEVICE);
+
 	packet = page_address(rdata->rx.hdr.pa.pages) +
 		 rdata->rx.hdr.pa.pages_offset;
-	copy_len = (rdata->rx.hdr_len) ? rdata->rx.hdr_len : *len;
+	copy_len = (rdata->rx.hdr_len) ? rdata->rx.hdr_len : len;
 	copy_len = min(rdata->rx.hdr.dma_len, copy_len);
 	skb_copy_to_linear_data(skb, packet, copy_len);
 	skb_put(skb, copy_len);
 
-	*len -= copy_len;
+	len -= copy_len;
+	if (len) {
+		/* Add the remaining data as a frag */
+		dma_sync_single_for_cpu(pdata->dev, rdata->rx.buf.dma,
+					rdata->rx.buf.dma_len, DMA_FROM_DEVICE);
+
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+				rdata->rx.buf.pa.pages,
+				rdata->rx.buf.pa.pages_offset,
+				len, rdata->rx.buf.dma_len);
+		rdata->rx.buf.pa.pages = NULL;
+	}
 
 	return skb;
 }
@@ -1930,7 +1948,7 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	struct sk_buff *skb;
 	struct skb_shared_hwtstamps *hwtstamps;
 	unsigned int incomplete, error, context_next, context;
-	unsigned int len, put_len, max_len;
+	unsigned int len, rdesc_len, max_len;
 	unsigned int received = 0;
 	int packet_count = 0;
 
@@ -1940,6 +1958,9 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	if (!ring)
 		return 0;
 
+	incomplete = 0;
+	context_next = 0;
+
 	napi = (pdata->per_channel_irq) ? &channel->napi : &pdata->napi;
 
 	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
@@ -1949,15 +1970,11 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 
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
@@ -1998,23 +2015,16 @@ read_again:
 		}
 
 		if (!context) {
-			put_len = rdata->rx.len - len;
-			len += put_len;
-
-			if (!skb) {
-				dma_sync_single_for_cpu(pdata->dev,
-							rdata->rx.hdr.dma,
-							rdata->rx.hdr.dma_len,
-							DMA_FROM_DEVICE);
-
-				skb = xgbe_create_skb(napi, rdata, &put_len);
-				if (!skb) {
+			/* Length is cumulative, get this descriptor's length */
+			rdesc_len = rdata->rx.len - len;
+			len += rdesc_len;
+
+			if (rdesc_len && !skb) {
+				skb = xgbe_create_skb(pdata, napi, rdata,
+						      rdesc_len);
+				if (!skb)
 					error = 1;
-					goto skip_data;
-				}
-			}
-
-			if (put_len) {
+			} else if (rdesc_len) {
 				dma_sync_single_for_cpu(pdata->dev,
 							rdata->rx.buf.dma,
 							rdata->rx.buf.dma_len,
@@ -2023,12 +2033,12 @@ read_again:
 				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
 						rdata->rx.buf.pa.pages,
 						rdata->rx.buf.pa.pages_offset,
-						put_len, rdata->rx.buf.dma_len);
+						rdesc_len,
+						rdata->rx.buf.dma_len);
 				rdata->rx.buf.pa.pages = NULL;
 			}
 		}
 
-skip_data:
 		if (incomplete || context_next)
 			goto read_again;
 
@@ -2093,8 +2103,6 @@ next_packet:
 	if (received && (incomplete || context_next)) {
 		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 		rdata->state_saved = 1;
-		rdata->state.incomplete = incomplete;
-		rdata->state.context_next = context_next;
 		rdata->state.skb = skb;
 		rdata->state.len = len;
 		rdata->state.error = error;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 8313b07..e182b25 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -334,8 +334,6 @@ struct xgbe_ring_data {
 	 */
 	unsigned int state_saved;
 	struct {
-		unsigned int incomplete;
-		unsigned int context_next;
 		struct sk_buff *skb;
 		unsigned int len;
 		unsigned int error;
