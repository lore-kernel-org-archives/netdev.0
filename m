From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 32/32] sfc: Replace efx_rx_buffer::is_page and
 other booleans with a flags field
Date: Fri, 27 Jan 2012 20:54:49 +0000
Message-ID: <1327697689.2503.40.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63904 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752835Ab2A0Uyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:54:52 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace checksummed and discard booleans from efx_handle_rx_event()
with a bitmask, added to the flags field.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    3 +-
 drivers/net/ethernet/sfc/efx.h        |    4 +-
 drivers/net/ethernet/sfc/net_driver.h |   16 +++++----
 drivers/net/ethernet/sfc/nic.c        |   32 ++++++++---------
 drivers/net/ethernet/sfc/rx.c         |   65 ++++++++++++++++-----------------
 5 files changed, 59 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index a352c55..952d0bf 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -229,8 +229,7 @@ static int efx_process_channel(struct efx_channel *channel, int budget)
 
 	/* Deliver last RX packet. */
 	if (channel->rx_pkt) {
-		__efx_rx_packet(channel, channel->rx_pkt,
-				channel->rx_pkt_csummed);
+		__efx_rx_packet(channel, channel->rx_pkt);
 		channel->rx_pkt = NULL;
 	}
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index e0b66d1..7f546e2 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -40,9 +40,9 @@ extern void efx_rx_strategy(struct efx_channel *channel);
 extern void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue);
 extern void efx_rx_slow_fill(unsigned long context);
 extern void __efx_rx_packet(struct efx_channel *channel,
-			    struct efx_rx_buffer *rx_buf, bool checksummed);
+			    struct efx_rx_buffer *rx_buf);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
-			  unsigned int len, bool checksummed, bool discard);
+			  unsigned int len, u16 flags);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 
 #define EFX_MAX_DMAQ_SIZE 4096UL
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c20483e..5386401 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -205,12 +205,12 @@ struct efx_tx_queue {
 /**
  * struct efx_rx_buffer - An Efx RX data buffer
  * @dma_addr: DMA base address of the buffer
- * @skb: The associated socket buffer, if any.
- *	If both this and page are %NULL, the buffer slot is currently free.
- * @page: The associated page buffer, if any.
- *	If both this and skb are %NULL, the buffer slot is currently free.
+ * @skb: The associated socket buffer. Valid iff !(@flags & %EFX_RX_BUF_PAGE).
+ *	Will be %NULL if the buffer slot is currently free.
+ * @page: The associated page buffer. Valif iff @flags & %EFX_RX_BUF_PAGE.
+ *	Will be %NULL if the buffer slot is currently free.
  * @len: Buffer length, in bytes.
- * @is_page: Indicates if @page is valid. If false, @skb is valid.
+ * @flags: Flags for buffer and packet state.
  */
 struct efx_rx_buffer {
 	dma_addr_t dma_addr;
@@ -219,8 +219,11 @@ struct efx_rx_buffer {
 		struct page *page;
 	} u;
 	unsigned int len;
-	bool is_page;
+	u16 flags;
 };
+#define EFX_RX_BUF_PAGE		0x0001
+#define EFX_RX_PKT_CSUMMED	0x0002
+#define EFX_RX_PKT_DISCARD	0x0004
 
 /**
  * struct efx_rx_page_state - Page-based rx buffer state
@@ -378,7 +381,6 @@ struct efx_channel {
 	 * access with prefetches.
 	 */
 	struct efx_rx_buffer *rx_pkt;
-	bool rx_pkt_csummed;
 
 	struct efx_rx_queue rx_queue;
 	struct efx_tx_queue tx_queue[EFX_TXQ_TYPES];
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index cd250f1..a43d1ca 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -743,10 +743,8 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 }
 
 /* Detect errors included in the rx_evt_pkt_ok bit. */
-static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
-				 const efx_qword_t *event,
-				 bool *rx_ev_pkt_ok,
-				 bool *discard)
+static u16 efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
+				const efx_qword_t *event)
 {
 	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	struct efx_nic *efx = rx_queue->efx;
@@ -791,10 +789,6 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			++channel->n_rx_tcp_udp_chksum_err;
 	}
 
-	/* The frame must be discarded if any of these are true. */
-	*discard = (rx_ev_eth_crc_err | rx_ev_frm_trunc | rx_ev_drib_nib |
-		    rx_ev_tobe_disc | rx_ev_pause_frm);
-
 	/* TOBE_DISC is expected on unicast mismatches; don't print out an
 	 * error message.  FRM_TRUNC indicates RXDP dropped the packet due
 	 * to a FIFO overflow.
@@ -817,6 +811,11 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			  rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
+
+	/* The frame must be discarded if any of these are true. */
+	return (rx_ev_eth_crc_err | rx_ev_frm_trunc | rx_ev_drib_nib |
+		rx_ev_tobe_disc | rx_ev_pause_frm) ?
+		EFX_RX_PKT_DISCARD : 0;
 }
 
 /* Handle receive events that are not in-order. */
@@ -849,7 +848,8 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 	unsigned int rx_ev_desc_ptr, rx_ev_byte_cnt;
 	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned expected_ptr;
-	bool rx_ev_pkt_ok, discard = false, checksummed;
+	bool rx_ev_pkt_ok;
+	u16 flags;
 	struct efx_rx_queue *rx_queue;
 
 	/* Basic packet information */
@@ -872,12 +872,11 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 		/* If packet is marked as OK and packet type is TCP/IP or
 		 * UDP/IP, then we can rely on the hardware checksum.
 		 */
-		checksummed =
-			rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
-			rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP;
+		flags = (rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
+			 rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP) ?
+			EFX_RX_PKT_CSUMMED : 0;
 	} else {
-		efx_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok, &discard);
-		checksummed = false;
+		flags = efx_handle_rx_not_ok(rx_queue, event);
 	}
 
 	/* Detect multicast packets that didn't match the filter */
@@ -888,15 +887,14 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 
 		if (unlikely(!rx_ev_mcast_hash_match)) {
 			++channel->n_rx_mcast_mismatch;
-			discard = true;
+			flags |= EFX_RX_PKT_DISCARD;
 		}
 	}
 
 	channel->irq_mod_score += 2;
 
 	/* Handle received packet */
-	efx_rx_packet(rx_queue, rx_ev_desc_ptr, rx_ev_byte_cnt,
-		      checksummed, discard);
+	efx_rx_packet(rx_queue, rx_ev_desc_ptr, rx_ev_byte_cnt, flags);
 }
 
 static void
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index d97c6eb..a33aef2 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -108,7 +108,7 @@ static inline unsigned int efx_rx_buf_size(struct efx_nic *efx)
 
 static u8 *efx_rx_buf_eh(struct efx_nic *efx, struct efx_rx_buffer *buf)
 {
-	if (buf->is_page)
+	if (buf->flags & EFX_RX_BUF_PAGE)
 		return page_address(buf->u.page) + efx_rx_buf_offset(efx, buf);
 	else
 		return (u8 *)buf->u.skb->data + efx->type->rx_buffer_hash_size;
@@ -158,7 +158,7 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 		/* Adjust the SKB for padding and checksum */
 		skb_reserve(skb, NET_IP_ALIGN);
 		rx_buf->len = skb_len - NET_IP_ALIGN;
-		rx_buf->is_page = false;
+		rx_buf->flags = 0;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 		rx_buf->dma_addr = pci_map_single(efx->pci_dev,
@@ -227,7 +227,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->u.page = page;
 		rx_buf->len = efx->rx_buffer_len - EFX_PAGE_IP_ALIGN;
-		rx_buf->is_page = true;
+		rx_buf->flags = EFX_RX_BUF_PAGE;
 		++rx_queue->added_count;
 		++rx_queue->alloc_page_count;
 		++state->refcnt;
@@ -248,7 +248,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				struct efx_rx_buffer *rx_buf)
 {
-	if (rx_buf->is_page && rx_buf->u.page) {
+	if ((rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.page) {
 		struct efx_rx_page_state *state;
 
 		state = page_address(rx_buf->u.page);
@@ -258,7 +258,7 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 				       efx_rx_buf_size(efx),
 				       PCI_DMA_FROMDEVICE);
 		}
-	} else if (!rx_buf->is_page && rx_buf->u.skb) {
+	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
 		pci_unmap_single(efx->pci_dev, rx_buf->dma_addr,
 				 rx_buf->len, PCI_DMA_FROMDEVICE);
 	}
@@ -267,10 +267,10 @@ static void efx_unmap_rx_buffer(struct efx_nic *efx,
 static void efx_free_rx_buffer(struct efx_nic *efx,
 			       struct efx_rx_buffer *rx_buf)
 {
-	if (rx_buf->is_page && rx_buf->u.page) {
+	if ((rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.page) {
 		__free_pages(rx_buf->u.page, efx->rx_buffer_order);
 		rx_buf->u.page = NULL;
-	} else if (!rx_buf->is_page && rx_buf->u.skb) {
+	} else if (!(rx_buf->flags & EFX_RX_BUF_PAGE) && rx_buf->u.skb) {
 		dev_kfree_skb_any(rx_buf->u.skb);
 		rx_buf->u.skb = NULL;
 	}
@@ -310,7 +310,7 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->u.page = rx_buf->u.page;
 	new_buf->len = rx_buf->len;
-	new_buf->is_page = true;
+	new_buf->flags = EFX_RX_BUF_PAGE;
 	++rx_queue->added_count;
 }
 
@@ -324,7 +324,10 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 	struct efx_rx_buffer *new_buf;
 	unsigned index;
 
-	if (rx_buf->is_page && efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
+	rx_buf->flags &= EFX_RX_BUF_PAGE;
+
+	if ((rx_buf->flags & EFX_RX_BUF_PAGE) &&
+	    efx->rx_buffer_len <= EFX_RX_HALF_PAGE &&
 	    page_count(rx_buf->u.page) == 1)
 		efx_resurrect_rx_buffer(rx_queue, rx_buf);
 
@@ -411,8 +414,7 @@ void efx_rx_slow_fill(unsigned long context)
 
 static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 				     struct efx_rx_buffer *rx_buf,
-				     int len, bool *discard,
-				     bool *leak_packet)
+				     int len, bool *leak_packet)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned max_len = rx_buf->len - efx->type->rx_buffer_padding;
@@ -423,7 +425,7 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 	/* The packet must be discarded, but this is only a fatal error
 	 * if the caller indicated it was
 	 */
-	*discard = true;
+	rx_buf->flags |= EFX_RX_PKT_DISCARD;
 
 	if ((len > rx_buf->len) && EFX_WORKAROUND_8071(efx)) {
 		if (net_ratelimit())
@@ -436,7 +438,7 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 		 * data at the end of the skb will be trashed. So
 		 * we have no choice but to leak the fragment.
 		 */
-		*leak_packet = !rx_buf->is_page;
+		*leak_packet = !(rx_buf->flags & EFX_RX_BUF_PAGE);
 		efx_schedule_reset(efx, RESET_TYPE_RX_RECOVERY);
 	} else {
 		if (net_ratelimit())
@@ -456,13 +458,13 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
  */
 static void efx_rx_packet_gro(struct efx_channel *channel,
 			      struct efx_rx_buffer *rx_buf,
-			      const u8 *eh, bool checksummed)
+			      const u8 *eh)
 {
 	struct napi_struct *napi = &channel->napi_str;
 	gro_result_t gro_result;
 
 	/* Pass the skb/page into the GRO engine */
-	if (rx_buf->is_page) {
+	if (rx_buf->flags & EFX_RX_BUF_PAGE) {
 		struct efx_nic *efx = channel->efx;
 		struct page *page = rx_buf->u.page;
 		struct sk_buff *skb;
@@ -484,8 +486,8 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 		skb->len = rx_buf->len;
 		skb->data_len = rx_buf->len;
 		skb->truesize += rx_buf->len;
-		skb->ip_summed =
-			checksummed ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
+		skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
+				  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
 
 		skb_record_rx_queue(skb, channel->channel);
 
@@ -493,7 +495,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 	} else {
 		struct sk_buff *skb = rx_buf->u.skb;
 
-		EFX_BUG_ON_PARANOID(!checksummed);
+		EFX_BUG_ON_PARANOID(!(rx_buf->flags & EFX_RX_PKT_CSUMMED));
 		rx_buf->u.skb = NULL;
 
 		gro_result = napi_gro_receive(napi, skb);
@@ -508,7 +510,7 @@ static void efx_rx_packet_gro(struct efx_channel *channel,
 }
 
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
-		   unsigned int len, bool checksummed, bool discard)
+		   unsigned int len, u16 flags)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
@@ -516,6 +518,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	bool leak_packet = false;
 
 	rx_buf = efx_rx_buffer(rx_queue, index);
+	rx_buf->flags |= flags;
 
 	/* This allows the refill path to post another buffer.
 	 * EFX_RXD_HEAD_ROOM ensures that the slot we are using
@@ -524,18 +527,17 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	rx_queue->removed_count++;
 
 	/* Validate the length encoded in the event vs the descriptor pushed */
-	efx_rx_packet__check_len(rx_queue, rx_buf, len,
-				 &discard, &leak_packet);
+	efx_rx_packet__check_len(rx_queue, rx_buf, len, &leak_packet);
 
 	netif_vdbg(efx, rx_status, efx->net_dev,
 		   "RX queue %d received id %x at %llx+%x %s%s\n",
 		   efx_rx_queue_index(rx_queue), index,
 		   (unsigned long long)rx_buf->dma_addr, len,
-		   (checksummed ? " [SUMMED]" : ""),
-		   (discard ? " [DISCARD]" : ""));
+		   (rx_buf->flags & EFX_RX_PKT_CSUMMED) ? " [SUMMED]" : "",
+		   (rx_buf->flags & EFX_RX_PKT_DISCARD) ? " [DISCARD]" : "");
 
 	/* Discard packet, if instructed to do so */
-	if (unlikely(discard)) {
+	if (unlikely(rx_buf->flags & EFX_RX_PKT_DISCARD)) {
 		if (unlikely(leak_packet))
 			channel->n_skbuff_leaks++;
 		else
@@ -562,10 +564,8 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	rx_buf->len = len - efx->type->rx_buffer_hash_size;
 out:
 	if (channel->rx_pkt)
-		__efx_rx_packet(channel,
-				channel->rx_pkt, channel->rx_pkt_csummed);
+		__efx_rx_packet(channel, channel->rx_pkt);
 	channel->rx_pkt = rx_buf;
-	channel->rx_pkt_csummed = checksummed;
 }
 
 static void efx_rx_deliver(struct efx_channel *channel,
@@ -588,8 +588,7 @@ static void efx_rx_deliver(struct efx_channel *channel,
 }
 
 /* Handle a received packet.  Second half: Touches packet payload. */
-void __efx_rx_packet(struct efx_channel *channel,
-		     struct efx_rx_buffer *rx_buf, bool checksummed)
+void __efx_rx_packet(struct efx_channel *channel, struct efx_rx_buffer *rx_buf)
 {
 	struct efx_nic *efx = channel->efx;
 	u8 *eh = efx_rx_buf_eh(efx, rx_buf);
@@ -603,7 +602,7 @@ void __efx_rx_packet(struct efx_channel *channel,
 		return;
 	}
 
-	if (!rx_buf->is_page) {
+	if (!(rx_buf->flags & EFX_RX_BUF_PAGE)) {
 		struct sk_buff *skb = rx_buf->u.skb;
 
 		prefetch(skb_shinfo(skb));
@@ -622,10 +621,10 @@ void __efx_rx_packet(struct efx_channel *channel,
 	}
 
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
-		checksummed = false;
+		rx_buf->flags &= ~EFX_RX_PKT_CSUMMED;
 
-	if (likely(checksummed || rx_buf->is_page))
-		efx_rx_packet_gro(channel, rx_buf, eh, checksummed);
+	if (likely(rx_buf->flags & (EFX_RX_BUF_PAGE | EFX_RX_PKT_CSUMMED)))
+		efx_rx_packet_gro(channel, rx_buf, eh);
 	else
 		efx_rx_deliver(channel, rx_buf);
 }
-- 
1.7.7.5


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
