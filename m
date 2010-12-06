From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Misuse of LRO, how widespread
Date: Mon, 6 Dec 2010 14:33:01 -0800
Message-ID: <20101206143301.6b6dd17d@nehalam>
References: <20101206121829.5b8c852e@nehalam>
	<1291667408.3443.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Olof Johansson <olof@lixom.net>,
	Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45616 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753174Ab0LFWdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Dec 2010 17:33:06 -0500
In-Reply-To: <1291667408.3443.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How about this?

Subject: sfc: convert references to LRO to GRO

This driver now uses Generic Receive Offload, not the older LRO.
Change references to LRO in names and comments.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sfc/rx.c	2010-12-06 14:28:25.320929804 -0800
+++ b/drivers/net/sfc/rx.c	2010-12-06 14:29:54.424930087 -0800
@@ -37,7 +37,7 @@
  * This driver supports two methods for allocating and using RX buffers:
  * each RX buffer may be backed by an skb or by an order-n page.
  *
- * When LRO is in use then the second method has a lower overhead,
+ * When GRO is in use then the second method has a lower overhead,
  * since we don't have to allocate then free skbs on reassembled frames.
  *
  * Values:
@@ -50,25 +50,25 @@
  *
  *   - Since pushing and popping descriptors are separated by the rx_queue
  *     size, so the watermarks should be ~rxd_size.
- *   - The performance win by using page-based allocation for LRO is less
- *     than the performance hit of using page-based allocation of non-LRO,
+ *   - The performance win by using page-based allocation for GRO is less
+ *     than the performance hit of using page-based allocation of non-GRO,
  *     so the watermarks should reflect this.
  *
  * Per channel we maintain a single variable, updated by each channel:
  *
- *   rx_alloc_level += (lro_performed ? RX_ALLOC_FACTOR_LRO :
+ *   rx_alloc_level += (gro_performed ? RX_ALLOC_FACTOR_GRO :
  *                      RX_ALLOC_FACTOR_SKB)
  * Per NAPI poll interval, we constrain rx_alloc_level to 0..MAX (which
  * limits the hysteresis), and update the allocation strategy:
  *
- *   rx_alloc_method = (rx_alloc_level > RX_ALLOC_LEVEL_LRO ?
+ *   rx_alloc_method = (rx_alloc_level > RX_ALLOC_LEVEL_GRO ?
  *                      RX_ALLOC_METHOD_PAGE : RX_ALLOC_METHOD_SKB)
  */
 static int rx_alloc_method = RX_ALLOC_METHOD_AUTO;
 
-#define RX_ALLOC_LEVEL_LRO 0x2000
+#define RX_ALLOC_LEVEL_GRO 0x2000
 #define RX_ALLOC_LEVEL_MAX 0x3000
-#define RX_ALLOC_FACTOR_LRO 1
+#define RX_ALLOC_FACTOR_GRO 1
 #define RX_ALLOC_FACTOR_SKB (-2)
 
 /* This is the percentage fill level below which new RX descriptors
@@ -441,19 +441,19 @@ static void efx_rx_packet__check_len(str
 	efx_rx_queue_channel(rx_queue)->n_rx_overlength++;
 }
 
-/* Pass a received packet up through the generic LRO stack
+/* Pass a received packet up through the generic GRO stack
  *
  * Handles driverlink veto, and passes the fragment up via
- * the appropriate LRO method
+ * the appropriate GRO method
  */
-static void efx_rx_packet_lro(struct efx_channel *channel,
+static void efx_rx_packet_gro(struct efx_channel *channel,
 			      struct efx_rx_buffer *rx_buf,
 			      bool checksummed)
 {
 	struct napi_struct *napi = &channel->napi_str;
 	gro_result_t gro_result;
 
-	/* Pass the skb/page into the LRO engine */
+	/* Pass the skb/page into the GRO engine */
 	if (rx_buf->page) {
 		struct efx_nic *efx = channel->efx;
 		struct page *page = rx_buf->page;
@@ -499,7 +499,7 @@ static void efx_rx_packet_lro(struct efx
 	if (gro_result == GRO_NORMAL) {
 		channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
 	} else if (gro_result != GRO_DROP) {
-		channel->rx_alloc_level += RX_ALLOC_FACTOR_LRO;
+		channel->rx_alloc_level += RX_ALLOC_FACTOR_GRO;
 		channel->irq_mod_score += 2;
 	}
 }
@@ -605,7 +605,7 @@ void __efx_rx_packet(struct efx_channel
 	}
 
 	if (likely(checksummed || rx_buf->page)) {
-		efx_rx_packet_lro(channel, rx_buf, checksummed);
+		efx_rx_packet_gro(channel, rx_buf, checksummed);
 		return;
 	}
 
@@ -628,7 +628,7 @@ void efx_rx_strategy(struct efx_channel
 {
 	enum efx_rx_alloc_method method = rx_alloc_method;
 
-	/* Only makes sense to use page based allocation if LRO is enabled */
+	/* Only makes sense to use page based allocation if GRO is enabled */
 	if (!(channel->efx->net_dev->features & NETIF_F_GRO)) {
 		method = RX_ALLOC_METHOD_SKB;
 	} else if (method == RX_ALLOC_METHOD_AUTO) {
@@ -639,7 +639,7 @@ void efx_rx_strategy(struct efx_channel
 			channel->rx_alloc_level = RX_ALLOC_LEVEL_MAX;
 
 		/* Decide on the allocation method */
-		method = ((channel->rx_alloc_level > RX_ALLOC_LEVEL_LRO) ?
+		method = ((channel->rx_alloc_level > RX_ALLOC_LEVEL_GRO) ?
 			  RX_ALLOC_METHOD_PAGE : RX_ALLOC_METHOD_SKB);
 	}
 
