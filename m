From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 06/10] sfc: Abstract channel and index lookup
 for RX queues
Date: Fri, 10 Sep 2010 17:41:36 +0100
Message-ID: <1284136896.2267.100.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25645 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809Ab0IJQlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:39 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |   11 +++++++++++
 drivers/net/sfc/nic.c        |   31 +++++++++++++++++--------------
 drivers/net/sfc/rx.c         |   38 +++++++++++++++++++-------------------
 3 files changed, 47 insertions(+), 33 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 64e7caa..89c6e02 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -943,6 +943,17 @@ struct efx_nic_type {
 			continue;					\
 		else
 
+static inline struct efx_channel *
+efx_rx_queue_channel(struct efx_rx_queue *rx_queue)
+{
+	return rx_queue->channel;
+}
+
+static inline int efx_rx_queue_index(struct efx_rx_queue *rx_queue)
+{
+	return rx_queue->queue;
+}
+
 /* Returns a pointer to the specified receive buffer in the RX
  * descriptor queue.
  */
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 8efe1ca..be4d552 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -539,8 +539,8 @@ void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue)
 	wmb();
 	write_ptr = rx_queue->added_count & EFX_RXQ_MASK;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
-	efx_writed_page(rx_queue->efx, &reg,
-			FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
+	efx_writed_page(rx_queue->efx, &reg, FR_AZ_RX_DESC_UPD_DWORD_P0,
+			efx_rx_queue_index(rx_queue));
 }
 
 int efx_nic_probe_rx(struct efx_rx_queue *rx_queue)
@@ -561,7 +561,7 @@ void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
 
 	netif_dbg(efx, hw, efx->net_dev,
 		  "RX queue %d ring in special buffers %d-%d\n",
-		  rx_queue->queue, rx_queue->rxd.index,
+		  efx_rx_queue_index(rx_queue), rx_queue->rxd.index,
 		  rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
 	rx_queue->flushed = FLUSH_NONE;
@@ -575,9 +575,10 @@ void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
 			      FRF_AZ_RX_ISCSI_HDIG_EN, iscsi_digest_en,
 			      FRF_AZ_RX_DESCQ_BUF_BASE_ID, rx_queue->rxd.index,
 			      FRF_AZ_RX_DESCQ_EVQ_ID,
-			      rx_queue->channel->channel,
+			      efx_rx_queue_channel(rx_queue)->channel,
 			      FRF_AZ_RX_DESCQ_OWNER_ID, 0,
-			      FRF_AZ_RX_DESCQ_LABEL, rx_queue->queue,
+			      FRF_AZ_RX_DESCQ_LABEL,
+			      efx_rx_queue_index(rx_queue),
 			      FRF_AZ_RX_DESCQ_SIZE,
 			      __ffs(rx_queue->rxd.entries),
 			      FRF_AZ_RX_DESCQ_TYPE, 0 /* kernel queue */ ,
@@ -585,7 +586,7 @@ void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
 			      FRF_AZ_RX_DESCQ_JUMBO, !is_b0,
 			      FRF_AZ_RX_DESCQ_EN, 1);
 	efx_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
-			 rx_queue->queue);
+			 efx_rx_queue_index(rx_queue));
 }
 
 static void efx_flush_rx_queue(struct efx_rx_queue *rx_queue)
@@ -598,7 +599,8 @@ static void efx_flush_rx_queue(struct efx_rx_queue *rx_queue)
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(rx_flush_descq,
 			     FRF_AZ_RX_FLUSH_DESCQ_CMD, 1,
-			     FRF_AZ_RX_FLUSH_DESCQ, rx_queue->queue);
+			     FRF_AZ_RX_FLUSH_DESCQ,
+			     efx_rx_queue_index(rx_queue));
 	efx_writeo(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
 }
 
@@ -613,7 +615,7 @@ void efx_nic_fini_rx(struct efx_rx_queue *rx_queue)
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
 	efx_writeo_table(efx, &rx_desc_ptr, efx->type->rxd_ptr_tbl_base,
-			 rx_queue->queue);
+			 efx_rx_queue_index(rx_queue));
 
 	/* Unpin RX descriptor ring */
 	efx_fini_special_buffer(efx, &rx_queue->rxd);
@@ -714,6 +716,7 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 				 bool *rx_ev_pkt_ok,
 				 bool *discard)
 {
+	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	struct efx_nic *efx = rx_queue->efx;
 	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
 	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
@@ -746,14 +749,14 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	/* Count errors that are not in MAC stats.  Ignore expected
 	 * checksum errors during self-test. */
 	if (rx_ev_frm_trunc)
-		++rx_queue->channel->n_rx_frm_trunc;
+		++channel->n_rx_frm_trunc;
 	else if (rx_ev_tobe_disc)
-		++rx_queue->channel->n_rx_tobe_disc;
+		++channel->n_rx_tobe_disc;
 	else if (!efx->loopback_selftest) {
 		if (rx_ev_ip_hdr_chksum_err)
-			++rx_queue->channel->n_rx_ip_hdr_chksum_err;
+			++channel->n_rx_ip_hdr_chksum_err;
 		else if (rx_ev_tcp_udp_chksum_err)
-			++rx_queue->channel->n_rx_tcp_udp_chksum_err;
+			++channel->n_rx_tcp_udp_chksum_err;
 	}
 
 	/* The frame must be discarded if any of these are true. */
@@ -769,7 +772,7 @@ static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 		netif_dbg(efx, rx_err, efx->net_dev,
 			  " RX queue %d unexpected RX event "
 			  EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
-			  rx_queue->queue, EFX_QWORD_VAL(*event),
+			  efx_rx_queue_index(rx_queue), EFX_QWORD_VAL(*event),
 			  rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
 			  rx_ev_ip_hdr_chksum_err ?
 			  " [IP_HDR_CHKSUM_ERR]" : "",
@@ -1269,7 +1272,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		if (rx_queue->flushed != FLUSH_DONE)
 			netif_err(efx, hw, efx->net_dev,
 				  "rx queue %d flush command timed out\n",
-				  rx_queue->queue);
+				  efx_rx_queue_index(rx_queue));
 		rx_queue->flushed = FLUSH_DONE;
 	}
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index acb372e..1e6c8cf 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -341,7 +341,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
  */
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 {
-	struct efx_channel *channel = rx_queue->channel;
+	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	unsigned fill_level;
 	int space, rc = 0;
 
@@ -364,7 +364,8 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
 		   "RX queue %d fast-filling descriptor ring from"
 		   " level %d to level %d using %s allocation\n",
-		   rx_queue->queue, fill_level, rx_queue->fast_fill_limit,
+		   efx_rx_queue_index(rx_queue), fill_level,
+		   rx_queue->fast_fill_limit,
 		   channel->rx_alloc_push_pages ? "page" : "skb");
 
 	do {
@@ -382,7 +383,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 
 	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
 		   "RX queue %d fast-filled descriptor ring "
-		   "to level %d\n", rx_queue->queue,
+		   "to level %d\n", efx_rx_queue_index(rx_queue),
 		   rx_queue->added_count - rx_queue->removed_count);
 
  out:
@@ -393,7 +394,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 void efx_rx_slow_fill(unsigned long context)
 {
 	struct efx_rx_queue *rx_queue = (struct efx_rx_queue *)context;
-	struct efx_channel *channel = rx_queue->channel;
+	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 
 	/* Post an event to cause NAPI to run and refill the queue */
 	efx_nic_generate_fill_event(channel);
@@ -421,7 +422,7 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 			netif_err(efx, rx_err, efx->net_dev,
 				  " RX queue %d seriously overlength "
 				  "RX event (0x%x > 0x%x+0x%x). Leaking\n",
-				  rx_queue->queue, len, max_len,
+				  efx_rx_queue_index(rx_queue), len, max_len,
 				  efx->type->rx_buffer_padding);
 		/* If this buffer was skb-allocated, then the meta
 		 * data at the end of the skb will be trashed. So
@@ -434,10 +435,10 @@ static void efx_rx_packet__check_len(struct efx_rx_queue *rx_queue,
 			netif_err(efx, rx_err, efx->net_dev,
 				  " RX queue %d overlength RX event "
 				  "(0x%x > 0x%x)\n",
-				  rx_queue->queue, len, max_len);
+				  efx_rx_queue_index(rx_queue), len, max_len);
 	}
 
-	rx_queue->channel->n_rx_overlength++;
+	efx_rx_queue_channel(rx_queue)->n_rx_overlength++;
 }
 
 /* Pass a received packet up through the generic LRO stack
@@ -507,7 +508,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		   unsigned int len, bool checksummed, bool discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	struct efx_channel *channel = rx_queue->channel;
+	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	struct efx_rx_buffer *rx_buf;
 	bool leak_packet = false;
 
@@ -528,7 +529,7 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 
 	netif_vdbg(efx, rx_status, efx->net_dev,
 		   "RX queue %d received id %x at %llx+%x %s%s\n",
-		   rx_queue->queue, index,
+		   efx_rx_queue_index(rx_queue), index,
 		   (unsigned long long)rx_buf->dma_addr, len,
 		   (checksummed ? " [SUMMED]" : ""),
 		   (discard ? " [DISCARD]" : ""));
@@ -560,12 +561,11 @@ void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 	 */
 	rx_buf->len = len;
 out:
-	if (rx_queue->channel->rx_pkt)
-		__efx_rx_packet(rx_queue->channel,
-				rx_queue->channel->rx_pkt,
-				rx_queue->channel->rx_pkt_csummed);
-	rx_queue->channel->rx_pkt = rx_buf;
-	rx_queue->channel->rx_pkt_csummed = checksummed;
+	if (channel->rx_pkt)
+		__efx_rx_packet(channel,
+				channel->rx_pkt, channel->rx_pkt_csummed);
+	channel->rx_pkt = rx_buf;
+	channel->rx_pkt_csummed = checksummed;
 }
 
 /* Handle a received packet.  Second half: Touches packet payload. */
@@ -654,7 +654,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	int rc;
 
 	netif_dbg(efx, probe, efx->net_dev,
-		  "creating RX queue %d\n", rx_queue->queue);
+		  "creating RX queue %d\n", efx_rx_queue_index(rx_queue));
 
 	/* Allocate RX buffers */
 	rxq_size = EFX_RXQ_SIZE * sizeof(*rx_queue->buffer);
@@ -675,7 +675,7 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	unsigned int max_fill, trigger, limit;
 
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
-		  "initialising RX queue %d\n", rx_queue->queue);
+		  "initialising RX queue %d\n", efx_rx_queue_index(rx_queue));
 
 	/* Initialise ptr fields */
 	rx_queue->added_count = 0;
@@ -703,7 +703,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 	struct efx_rx_buffer *rx_buf;
 
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
-		  "shutting down RX queue %d\n", rx_queue->queue);
+		  "shutting down RX queue %d\n", efx_rx_queue_index(rx_queue));
 
 	del_timer_sync(&rx_queue->slow_fill);
 	efx_nic_fini_rx(rx_queue);
@@ -720,7 +720,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
-		  "destroying RX queue %d\n", rx_queue->queue);
+		  "destroying RX queue %d\n", efx_rx_queue_index(rx_queue));
 
 	efx_nic_remove_rx(rx_queue);
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

