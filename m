From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/27] sfc: Eliminate indirect lookups of queue size
	constants
Date: Fri, 23 Oct 2009 19:30:58 +0100
Message-ID: <1256322658.2785.23.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8677 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbZJWSa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:30:56 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move size and mask definitions into efx.h; calculate page orders in falcon.c.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   14 ++------
 drivers/net/sfc/efx.h        |    6 +++
 drivers/net/sfc/falcon.c     |   70 +++++++++++++++--------------------------
 drivers/net/sfc/net_driver.h |    6 ---
 drivers/net/sfc/rx.c         |   16 +++------
 drivers/net/sfc/selftest.c   |    2 +-
 drivers/net/sfc/tx.c         |   46 ++++++++++++---------------
 7 files changed, 62 insertions(+), 98 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index cc4b2f9..8b67553 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -290,7 +290,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	napi_disable(&channel->napi_str);
 
 	/* Poll the channel */
-	efx_process_channel(channel, efx->type->evq_size);
+	efx_process_channel(channel, EFX_EVQ_SIZE);
 
 	/* Ack the eventq. This may cause an interrupt to be generated
 	 * when they are reenabled */
@@ -1981,17 +1981,9 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 
 	efx->type = type;
 
-	/* Sanity-check NIC type */
-	EFX_BUG_ON_PARANOID(efx->type->txd_ring_mask &
-			    (efx->type->txd_ring_mask + 1));
-	EFX_BUG_ON_PARANOID(efx->type->rxd_ring_mask &
-			    (efx->type->rxd_ring_mask + 1));
-	EFX_BUG_ON_PARANOID(efx->type->evq_size &
-			    (efx->type->evq_size - 1));
 	/* As close as we can get to guaranteeing that we don't overflow */
-	EFX_BUG_ON_PARANOID(efx->type->evq_size <
-			    (efx->type->txd_ring_mask + 1 +
-			     efx->type->rxd_ring_mask + 1));
+	BUILD_BUG_ON(EFX_EVQ_SIZE < EFX_TXQ_SIZE + EFX_RXQ_SIZE);
+
 	EFX_BUG_ON_PARANOID(efx->type->phys_addr_channels > EFX_MAX_CHANNELS);
 
 	/* Higher numbered interrupt modes are less capable! */
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index aecaf62..20c8d62 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -25,16 +25,22 @@ extern netdev_tx_t efx_xmit(struct efx_nic *efx,
 				  struct sk_buff *skb);
 extern void efx_stop_queue(struct efx_nic *efx);
 extern void efx_wake_queue(struct efx_nic *efx);
+#define EFX_TXQ_SIZE 1024
+#define EFX_TXQ_MASK (EFX_TXQ_SIZE - 1)
 
 /* RX */
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
+#define EFX_RXQ_SIZE 1024
+#define EFX_RXQ_MASK (EFX_RXQ_SIZE - 1)
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
 extern void efx_flush_queues(struct efx_nic *efx);
+#define EFX_EVQ_SIZE 4096
+#define EFX_EVQ_MASK (EFX_EVQ_SIZE - 1)
 
 /* Ports */
 extern void efx_stats_disable(struct efx_nic *efx);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 759f55a..3cb7e61 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -108,21 +108,6 @@ static int rx_xon_thresh_bytes = -1;
 module_param(rx_xon_thresh_bytes, int, 0644);
 MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 
-/* TX descriptor ring size - min 512 max 4k */
-#define FALCON_TXD_RING_ORDER FFE_AZ_TX_DESCQ_SIZE_1K
-#define FALCON_TXD_RING_SIZE 1024
-#define FALCON_TXD_RING_MASK (FALCON_TXD_RING_SIZE - 1)
-
-/* RX descriptor ring size - min 512 max 4k */
-#define FALCON_RXD_RING_ORDER FFE_AZ_RX_DESCQ_SIZE_1K
-#define FALCON_RXD_RING_SIZE 1024
-#define FALCON_RXD_RING_MASK (FALCON_RXD_RING_SIZE - 1)
-
-/* Event queue size - max 32k */
-#define FALCON_EVQ_ORDER FFE_AZ_EVQ_SIZE_4K
-#define FALCON_EVQ_SIZE 4096
-#define FALCON_EVQ_MASK (FALCON_EVQ_SIZE - 1)
-
 /* If FALCON_MAX_INT_ERRORS internal errors occur within
  * FALCON_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
  * disable it.
@@ -420,7 +405,7 @@ static inline void falcon_notify_tx_desc(struct efx_tx_queue *tx_queue)
 	unsigned write_ptr;
 	efx_dword_t reg;
 
-	write_ptr = tx_queue->write_count & FALCON_TXD_RING_MASK;
+	write_ptr = tx_queue->write_count & EFX_TXQ_MASK;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_TX_DESC_WPTR_DWORD, write_ptr);
 	efx_writed_page(tx_queue->efx, &reg,
 			FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
@@ -441,7 +426,7 @@ void falcon_push_buffers(struct efx_tx_queue *tx_queue)
 	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
 
 	do {
-		write_ptr = tx_queue->write_count & FALCON_TXD_RING_MASK;
+		write_ptr = tx_queue->write_count & EFX_TXQ_MASK;
 		buffer = &tx_queue->buffer[write_ptr];
 		txd = falcon_tx_desc(tx_queue, write_ptr);
 		++tx_queue->write_count;
@@ -462,9 +447,10 @@ void falcon_push_buffers(struct efx_tx_queue *tx_queue)
 int falcon_probe_tx(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
+	BUILD_BUG_ON(EFX_TXQ_SIZE < 512 || EFX_TXQ_SIZE > 4096 ||
+		     EFX_TXQ_SIZE & EFX_TXQ_MASK);
 	return falcon_alloc_special_buffer(efx, &tx_queue->txd,
-					   FALCON_TXD_RING_SIZE *
-					   sizeof(efx_qword_t));
+					   EFX_TXQ_SIZE * sizeof(efx_qword_t));
 }
 
 void falcon_init_tx(struct efx_tx_queue *tx_queue)
@@ -487,7 +473,8 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 			      tx_queue->channel->channel,
 			      FRF_AZ_TX_DESCQ_OWNER_ID, 0,
 			      FRF_AZ_TX_DESCQ_LABEL, tx_queue->queue,
-			      FRF_AZ_TX_DESCQ_SIZE, FALCON_TXD_RING_ORDER,
+			      FRF_AZ_TX_DESCQ_SIZE,
+			      __ffs(tx_queue->txd.entries),
 			      FRF_AZ_TX_DESCQ_TYPE, 0,
 			      FRF_BZ_TX_NON_IP_DROP_DIS, 1);
 
@@ -592,12 +579,12 @@ void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
 	while (rx_queue->notified_count != rx_queue->added_count) {
 		falcon_build_rx_desc(rx_queue,
 				     rx_queue->notified_count &
-				     FALCON_RXD_RING_MASK);
+				     EFX_RXQ_MASK);
 		++rx_queue->notified_count;
 	}
 
 	wmb();
-	write_ptr = rx_queue->added_count & FALCON_RXD_RING_MASK;
+	write_ptr = rx_queue->added_count & EFX_RXQ_MASK;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
 	efx_writed_page(rx_queue->efx, &reg,
 			FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
@@ -606,9 +593,10 @@ void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
 int falcon_probe_rx(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
+	BUILD_BUG_ON(EFX_RXQ_SIZE < 512 || EFX_RXQ_SIZE > 4096 ||
+		     EFX_RXQ_SIZE & EFX_RXQ_MASK);
 	return falcon_alloc_special_buffer(efx, &rx_queue->rxd,
-					   FALCON_RXD_RING_SIZE *
-					   sizeof(efx_qword_t));
+					   EFX_RXQ_SIZE * sizeof(efx_qword_t));
 }
 
 void falcon_init_rx(struct efx_rx_queue *rx_queue)
@@ -636,7 +624,8 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 			      rx_queue->channel->channel,
 			      FRF_AZ_RX_DESCQ_OWNER_ID, 0,
 			      FRF_AZ_RX_DESCQ_LABEL, rx_queue->queue,
-			      FRF_AZ_RX_DESCQ_SIZE, FALCON_RXD_RING_ORDER,
+			      FRF_AZ_RX_DESCQ_SIZE,
+			      __ffs(rx_queue->rxd.entries),
 			      FRF_AZ_RX_DESCQ_TYPE, 0 /* kernel queue */ ,
 			      /* For >=B0 this is scatter so disable */
 			      FRF_AZ_RX_DESCQ_JUMBO, !is_b0,
@@ -741,7 +730,7 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 		tx_queue = &efx->tx_queue[tx_ev_q_label];
 		channel->irq_mod_score +=
 			(tx_ev_desc_ptr - tx_queue->read_count) &
-			efx->type->txd_ring_mask;
+			EFX_TXQ_MASK;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
@@ -848,9 +837,8 @@ static void falcon_handle_rx_bad_index(struct efx_rx_queue *rx_queue,
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned expected, dropped;
 
-	expected = rx_queue->removed_count & FALCON_RXD_RING_MASK;
-	dropped = ((index + FALCON_RXD_RING_SIZE - expected) &
-		   FALCON_RXD_RING_MASK);
+	expected = rx_queue->removed_count & EFX_RXQ_MASK;
+	dropped = (index - expected) & EFX_RXQ_MASK;
 	EFX_INFO(efx, "dropped %d events (index=%d expected=%d)\n",
 		dropped, index, expected);
 
@@ -887,7 +875,7 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 	rx_queue = &efx->rx_queue[channel->channel];
 
 	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
-	expected_ptr = rx_queue->removed_count & FALCON_RXD_RING_MASK;
+	expected_ptr = rx_queue->removed_count & EFX_RXQ_MASK;
 	if (unlikely(rx_ev_desc_ptr != expected_ptr))
 		falcon_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
 
@@ -1075,7 +1063,7 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 		}
 
 		/* Increment read pointer */
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
+		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
 
 	} while (rx_packets < rx_quota);
 
@@ -1120,10 +1108,10 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 int falcon_probe_eventq(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
-	unsigned int evq_size;
-
-	evq_size = FALCON_EVQ_SIZE * sizeof(efx_qword_t);
-	return falcon_alloc_special_buffer(efx, &channel->eventq, evq_size);
+	BUILD_BUG_ON(EFX_EVQ_SIZE < 512 || EFX_EVQ_SIZE > 32768 ||
+		     EFX_EVQ_SIZE & EFX_EVQ_MASK);
+	return falcon_alloc_special_buffer(efx, &channel->eventq,
+					   EFX_EVQ_SIZE * sizeof(efx_qword_t));
 }
 
 void falcon_init_eventq(struct efx_channel *channel)
@@ -1144,7 +1132,7 @@ void falcon_init_eventq(struct efx_channel *channel)
 	/* Push event queue to card */
 	EFX_POPULATE_OWORD_3(evq_ptr,
 			     FRF_AZ_EVQ_EN, 1,
-			     FRF_AZ_EVQ_SIZE, FALCON_EVQ_ORDER,
+			     FRF_AZ_EVQ_SIZE, __ffs(channel->eventq.entries),
 			     FRF_AZ_EVQ_BUF_BASE_ID, channel->eventq.index);
 	efx_writeo_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
@@ -1214,7 +1202,7 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	unsigned int read_ptr = channel->eventq_read_ptr;
-	unsigned int end_ptr = (read_ptr - 1) & FALCON_EVQ_MASK;
+	unsigned int end_ptr = (read_ptr - 1) & EFX_EVQ_MASK;
 
 	do {
 		efx_qword_t *event = falcon_event(channel, read_ptr);
@@ -1252,7 +1240,7 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 			}
 		}
 
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
+		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
 	} while (read_ptr != end_ptr);
 }
 
@@ -3160,9 +3148,6 @@ struct efx_nic_type falcon_a_nic_type = {
 	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
 	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
 	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
-	.txd_ring_mask = FALCON_TXD_RING_MASK,
-	.rxd_ring_mask = FALCON_RXD_RING_MASK,
-	.evq_size = FALCON_EVQ_SIZE,
 	.max_dma_mask = FALCON_DMA_MASK,
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0xf,
@@ -3184,9 +3169,6 @@ struct efx_nic_type falcon_b_nic_type = {
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
 	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
 	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
-	.txd_ring_mask = FALCON_TXD_RING_MASK,
-	.rxd_ring_mask = FALCON_RXD_RING_MASK,
-	.evq_size = FALCON_EVQ_SIZE,
 	.max_dma_mask = FALCON_DMA_MASK,
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 479a6fe..3afadc6 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -869,9 +869,6 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @buf_tbl_base: Buffer table base address
  * @evq_ptr_tbl_base: Event queue pointer table base address
  * @evq_rptr_tbl_base: Event queue read-pointer table base address
- * @txd_ring_mask: TX descriptor ring size - 1 (must be a power of two - 1)
- * @rxd_ring_mask: RX descriptor ring size - 1 (must be a power of two - 1)
- * @evq_size: Event queue size (must be a power of two)
  * @max_dma_mask: Maximum possible DMA mask
  * @tx_dma_mask: TX DMA mask
  * @bug5391_mask: Address mask for bug 5391 workaround
@@ -890,9 +887,6 @@ struct efx_nic_type {
 	unsigned int evq_ptr_tbl_base;
 	unsigned int evq_rptr_tbl_base;
 
-	unsigned int txd_ring_mask;
-	unsigned int rxd_ring_mask;
-	unsigned int evq_size;
 	u64 max_dma_mask;
 	unsigned int tx_dma_mask;
 	unsigned bug5391_mask;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 01f9432..ea59ed2 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -293,8 +293,7 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 	 * fill anyway.
 	 */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
-	EFX_BUG_ON_PARANOID(fill_level >
-			    rx_queue->efx->type->rxd_ring_mask + 1);
+	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
 
 	/* Don't fill if we don't need to */
 	if (fill_level >= rx_queue->fast_fill_trigger)
@@ -316,8 +315,7 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
  retry:
 	/* Recalculate current fill level now that we have the lock */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
-	EFX_BUG_ON_PARANOID(fill_level >
-			    rx_queue->efx->type->rxd_ring_mask + 1);
+	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
 	space = rx_queue->fast_fill_limit - fill_level;
 	if (space < EFX_RX_BATCH)
 		goto out_unlock;
@@ -329,8 +327,7 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 
 	do {
 		for (i = 0; i < EFX_RX_BATCH; ++i) {
-			index = (rx_queue->added_count &
-				 rx_queue->efx->type->rxd_ring_mask);
+			index = rx_queue->added_count & EFX_RXQ_MASK;
 			rx_buf = efx_rx_buffer(rx_queue, index);
 			rc = efx_init_rx_buffer(rx_queue, rx_buf);
 			if (unlikely(rc))
@@ -629,7 +626,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	EFX_LOG(efx, "creating RX queue %d\n", rx_queue->queue);
 
 	/* Allocate RX buffers */
-	rxq_size = (efx->type->rxd_ring_mask + 1) * sizeof(*rx_queue->buffer);
+	rxq_size = EFX_RXQ_SIZE * sizeof(*rx_queue->buffer);
 	rx_queue->buffer = kzalloc(rxq_size, GFP_KERNEL);
 	if (!rx_queue->buffer)
 		return -ENOMEM;
@@ -644,7 +641,6 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
-	struct efx_nic *efx = rx_queue->efx;
 	unsigned int max_fill, trigger, limit;
 
 	EFX_LOG(rx_queue->efx, "initialising RX queue %d\n", rx_queue->queue);
@@ -657,7 +653,7 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	rx_queue->min_overfill = -1U;
 
 	/* Initialise limit fields */
-	max_fill = efx->type->rxd_ring_mask + 1 - EFX_RXD_HEAD_ROOM;
+	max_fill = EFX_RXQ_SIZE - EFX_RXD_HEAD_ROOM;
 	trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
 	limit = max_fill * min(rx_refill_limit, 100U) / 100U;
 
@@ -680,7 +676,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 
 	/* Release RX buffers NB start at index 0 not current HW ptr */
 	if (rx_queue->buffer) {
-		for (i = 0; i <= rx_queue->efx->type->rxd_ring_mask; i++) {
+		for (i = 0; i <= EFX_RXQ_MASK; i++) {
 			rx_buf = efx_rx_buffer(rx_queue, i);
 			efx_fini_rx_buffer(rx_queue, rx_buf);
 		}
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index e5c4c9c..7a9386f 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -526,7 +526,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 
 	for (i = 0; i < 3; i++) {
 		/* Determine how many packets to send */
-		state->packet_count = (efx->type->txd_ring_mask + 1) / 3;
+		state->packet_count = EFX_TXQ_SIZE / 3;
 		state->packet_count = min(1 << (i << 2), state->packet_count);
 		state->skbs = kzalloc(sizeof(state->skbs[0]) *
 				      state->packet_count, GFP_KERNEL);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 489c4de..ae554ee 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -26,8 +26,7 @@
  * The tx_queue descriptor ring fill-level must fall below this value
  * before we restart the netif queue
  */
-#define EFX_NETDEV_TX_THRESHOLD(_tx_queue)	\
-	(_tx_queue->efx->type->txd_ring_mask / 2u)
+#define EFX_TXQ_THRESHOLD (EFX_TXQ_MASK / 2u)
 
 /* We want to be able to nest calls to netif_stop_queue(), since each
  * channel can have an individual stop on the queue.
@@ -171,7 +170,7 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	}
 
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
-	q_space = efx->type->txd_ring_mask - 1 - fill_level;
+	q_space = EFX_TXQ_MASK - 1 - fill_level;
 
 	/* Map for DMA.  Use pci_map_single rather than pci_map_page
 	 * since this is more efficient on machines with sparse
@@ -208,16 +207,14 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 					&tx_queue->read_count;
 				fill_level = (tx_queue->insert_count
 					      - tx_queue->old_read_count);
-				q_space = (efx->type->txd_ring_mask - 1 -
-					   fill_level);
+				q_space = EFX_TXQ_MASK - 1 - fill_level;
 				if (unlikely(q_space-- <= 0))
 					goto stop;
 				smp_mb();
 				--tx_queue->stopped;
 			}
 
-			insert_ptr = (tx_queue->insert_count &
-				      efx->type->txd_ring_mask);
+			insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
 			buffer = &tx_queue->buffer[insert_ptr];
 			efx_tsoh_free(tx_queue, buffer);
 			EFX_BUG_ON_PARANOID(buffer->tsoh);
@@ -289,7 +286,7 @@ static netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		--tx_queue->insert_count;
-		insert_ptr = tx_queue->insert_count & efx->type->txd_ring_mask;
+		insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
 		buffer = &tx_queue->buffer[insert_ptr];
 		efx_dequeue_buffer(tx_queue, buffer);
 		buffer->len = 0;
@@ -318,10 +315,9 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 {
 	struct efx_nic *efx = tx_queue->efx;
 	unsigned int stop_index, read_ptr;
-	unsigned int mask = tx_queue->efx->type->txd_ring_mask;
 
-	stop_index = (index + 1) & mask;
-	read_ptr = tx_queue->read_count & mask;
+	stop_index = (index + 1) & EFX_TXQ_MASK;
+	read_ptr = tx_queue->read_count & EFX_TXQ_MASK;
 
 	while (read_ptr != stop_index) {
 		struct efx_tx_buffer *buffer = &tx_queue->buffer[read_ptr];
@@ -338,7 +334,7 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 		buffer->len = 0;
 
 		++tx_queue->read_count;
-		read_ptr = tx_queue->read_count & mask;
+		read_ptr = tx_queue->read_count & EFX_TXQ_MASK;
 	}
 }
 
@@ -391,7 +387,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	unsigned fill_level;
 	struct efx_nic *efx = tx_queue->efx;
 
-	EFX_BUG_ON_PARANOID(index > efx->type->txd_ring_mask);
+	EFX_BUG_ON_PARANOID(index > EFX_TXQ_MASK);
 
 	efx_dequeue_buffers(tx_queue, index);
 
@@ -401,7 +397,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	smp_mb();
 	if (unlikely(tx_queue->stopped) && likely(efx->port_enabled)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
-		if (fill_level < EFX_NETDEV_TX_THRESHOLD(tx_queue)) {
+		if (fill_level < EFX_TXQ_THRESHOLD) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
 
 			/* Do this under netif_tx_lock(), to avoid racing
@@ -425,11 +421,11 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 	EFX_LOG(efx, "creating TX queue %d\n", tx_queue->queue);
 
 	/* Allocate software ring */
-	txq_size = (efx->type->txd_ring_mask + 1) * sizeof(*tx_queue->buffer);
+	txq_size = EFX_TXQ_SIZE * sizeof(*tx_queue->buffer);
 	tx_queue->buffer = kzalloc(txq_size, GFP_KERNEL);
 	if (!tx_queue->buffer)
 		return -ENOMEM;
-	for (i = 0; i <= efx->type->txd_ring_mask; ++i)
+	for (i = 0; i <= EFX_TXQ_MASK; ++i)
 		tx_queue->buffer[i].continuation = true;
 
 	/* Allocate hardware ring */
@@ -468,8 +464,7 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 
 	/* Free any buffers left in the ring */
 	while (tx_queue->read_count != tx_queue->write_count) {
-		buffer = &tx_queue->buffer[tx_queue->read_count &
-					   tx_queue->efx->type->txd_ring_mask];
+		buffer = &tx_queue->buffer[tx_queue->read_count & EFX_TXQ_MASK];
 		efx_dequeue_buffer(tx_queue, buffer);
 		buffer->continuation = true;
 		buffer->len = 0;
@@ -715,7 +710,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
 	/* -1 as there is no way to represent all descriptors used */
-	q_space = efx->type->txd_ring_mask - 1 - fill_level;
+	q_space = EFX_TXQ_MASK - 1 - fill_level;
 
 	while (1) {
 		if (unlikely(q_space-- <= 0)) {
@@ -731,7 +726,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 				*(volatile unsigned *)&tx_queue->read_count;
 			fill_level = (tx_queue->insert_count
 				      - tx_queue->old_read_count);
-			q_space = efx->type->txd_ring_mask - 1 - fill_level;
+			q_space = EFX_TXQ_MASK - 1 - fill_level;
 			if (unlikely(q_space-- <= 0)) {
 				*final_buffer = NULL;
 				return 1;
@@ -740,13 +735,13 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			--tx_queue->stopped;
 		}
 
-		insert_ptr = tx_queue->insert_count & efx->type->txd_ring_mask;
+		insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
 		buffer = &tx_queue->buffer[insert_ptr];
 		++tx_queue->insert_count;
 
 		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
 				    tx_queue->read_count >
-				    efx->type->txd_ring_mask);
+				    EFX_TXQ_MASK);
 
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->len);
@@ -792,8 +787,7 @@ static void efx_tso_put_header(struct efx_tx_queue *tx_queue,
 {
 	struct efx_tx_buffer *buffer;
 
-	buffer = &tx_queue->buffer[tx_queue->insert_count &
-				   tx_queue->efx->type->txd_ring_mask];
+	buffer = &tx_queue->buffer[tx_queue->insert_count & EFX_TXQ_MASK];
 	efx_tsoh_free(tx_queue, buffer);
 	EFX_BUG_ON_PARANOID(buffer->len);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
@@ -818,7 +812,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		--tx_queue->insert_count;
 		buffer = &tx_queue->buffer[tx_queue->insert_count &
-					   tx_queue->efx->type->txd_ring_mask];
+					   EFX_TXQ_MASK];
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->skb);
 		buffer->len = 0;
@@ -1135,7 +1129,7 @@ static void efx_fini_tso(struct efx_tx_queue *tx_queue)
 	unsigned i;
 
 	if (tx_queue->buffer) {
-		for (i = 0; i <= tx_queue->efx->type->txd_ring_mask; ++i)
+		for (i = 0; i <= EFX_TXQ_MASK; ++i)
 			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
 	}
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

