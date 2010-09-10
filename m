From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 09/10] sfc: Make the dmaq size a run-time
 setting (rather than compile-time)
Date: Fri, 10 Sep 2010 17:42:22 +0100
Message-ID: <1284136942.2267.104.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25782 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab0IJQm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:42:26 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

- Allow the ring size to be specified in non
   power-of-two sizes (for instance to limit
   the amount of receive buffers).
 - Automatically size the event queue.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   15 ++++++++---
 drivers/net/sfc/efx.h        |   13 +++++----
 drivers/net/sfc/net_driver.h |   13 +++++++--
 drivers/net/sfc/nic.c        |   53 +++++++++++++++++++++------------------
 drivers/net/sfc/rx.c         |   33 +++++++++++++++---------
 drivers/net/sfc/selftest.c   |    2 +-
 drivers/net/sfc/tx.c         |   56 +++++++++++++++++++++++------------------
 7 files changed, 109 insertions(+), 76 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4b42e61..6166e22 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -348,7 +348,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	napi_disable(&channel->napi_str);
 
 	/* Poll the channel */
-	efx_process_channel(channel, EFX_EVQ_SIZE);
+	efx_process_channel(channel, channel->eventq_mask + 1);
 
 	/* Ack the eventq. This may cause an interrupt to be generated
 	 * when they are reenabled */
@@ -365,9 +365,18 @@ void efx_process_channel_now(struct efx_channel *channel)
  */
 static int efx_probe_eventq(struct efx_channel *channel)
 {
+	struct efx_nic *efx = channel->efx;
+	unsigned long entries;
+
 	netif_dbg(channel->efx, probe, channel->efx->net_dev,
 		  "chan %d create event queue\n", channel->channel);
 
+	/* Build an event queue with room for one event per tx and rx buffer,
+	 * plus some extra for link state events and MCDI completions. */
+	entries = roundup_pow_of_two(efx->rxq_entries + efx->txq_entries + 128);
+	EFX_BUG_ON_PARANOID(entries > EFX_MAX_EVQ_SIZE);
+	channel->eventq_mask = max(entries, EFX_MIN_EVQ_SIZE) - 1;
+
 	return efx_nic_probe_eventq(channel);
 }
 
@@ -1191,6 +1200,7 @@ static int efx_probe_all(struct efx_nic *efx)
 	}
 
 	/* Create channels */
+	efx->rxq_entries = efx->txq_entries = EFX_DEFAULT_DMAQ_SIZE;
 	efx_for_each_channel(channel, efx) {
 		rc = efx_probe_channel(channel);
 		if (rc) {
@@ -2101,9 +2111,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 
 	efx->type = type;
 
-	/* As close as we can get to guaranteeing that we don't overflow */
-	BUILD_BUG_ON(EFX_EVQ_SIZE < EFX_TXQ_SIZE + EFX_RXQ_SIZE);
-
 	EFX_BUG_ON_PARANOID(efx->type->phys_addr_channels > EFX_MAX_CHANNELS);
 
 	/* Higher numbered interrupt modes are less capable! */
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d6b172b..c15a2d3 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -37,8 +37,6 @@ efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_stop_queue(struct efx_channel *channel);
 extern void efx_wake_queue(struct efx_channel *channel);
-#define EFX_TXQ_SIZE 1024
-#define EFX_TXQ_MASK (EFX_TXQ_SIZE - 1)
 
 /* RX */
 extern int efx_probe_rx_queue(struct efx_rx_queue *rx_queue);
@@ -53,13 +51,16 @@ extern void __efx_rx_packet(struct efx_channel *channel,
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
-#define EFX_RXQ_SIZE 1024
-#define EFX_RXQ_MASK (EFX_RXQ_SIZE - 1)
+
+#define EFX_MAX_DMAQ_SIZE 4096UL
+#define EFX_DEFAULT_DMAQ_SIZE 1024UL
+#define EFX_MIN_DMAQ_SIZE 512UL
+
+#define EFX_MAX_EVQ_SIZE 16384UL
+#define EFX_MIN_EVQ_SIZE 512UL
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
-#define EFX_EVQ_SIZE 4096
-#define EFX_EVQ_MASK (EFX_EVQ_SIZE - 1)
 
 /* Ports */
 extern int efx_reconfigure_port(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index cfc65f5..ac622ab 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -137,6 +137,7 @@ struct efx_tx_buffer {
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
+ * @ptr_mask: The size of the ring minus 1.
  * @flushed: Used when handling queue flushing
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
@@ -170,6 +171,7 @@ struct efx_tx_queue {
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
+	unsigned int ptr_mask;
 	enum efx_flush_state flushed;
 
 	/* Members used mainly on the completion path */
@@ -227,6 +229,7 @@ struct efx_rx_page_state {
  * @efx: The associated Efx NIC
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
+ * @ptr_mask: The size of the ring minus 1.
  * @added_count: Number of buffers added to the receive queue.
  * @notified_count: Number of buffers given to NIC (<= @added_count).
  * @removed_count: Number of buffers removed from the receive queue.
@@ -238,9 +241,6 @@ struct efx_rx_page_state {
  * @min_fill: RX descriptor minimum non-zero fill level.
  *	This records the minimum fill level observed when a ring
  *	refill was triggered.
- * @min_overfill: RX descriptor minimum overflow fill level.
- *	This records the minimum fill level at which RX queue
- *	overflow was observed.  It should never be set.
  * @alloc_page_count: RX allocation strategy counter.
  * @alloc_skb_count: RX allocation strategy counter.
  * @slow_fill: Timer used to defer efx_nic_generate_fill_event().
@@ -250,6 +250,7 @@ struct efx_rx_queue {
 	struct efx_nic *efx;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
+	unsigned int ptr_mask;
 
 	int added_count;
 	int notified_count;
@@ -307,6 +308,7 @@ enum efx_rx_alloc_method {
  * @reset_work: Scheduled reset work thread
  * @work_pending: Is work pending via NAPI?
  * @eventq: Event queue buffer
+ * @eventq_mask: Event queue pointer mask
  * @eventq_read_ptr: Event queue read pointer
  * @last_eventq_read_ptr: Last event queue read pointer value.
  * @magic_count: Event queue test event count
@@ -339,6 +341,7 @@ struct efx_channel {
 	struct napi_struct napi_str;
 	bool work_pending;
 	struct efx_special_buffer eventq;
+	unsigned int eventq_mask;
 	unsigned int eventq_read_ptr;
 	unsigned int last_eventq_read_ptr;
 	unsigned int magic_count;
@@ -641,6 +644,8 @@ union efx_multicast_hash {
  * @tx_queue: TX DMA queues
  * @rx_queue: RX DMA queues
  * @channel: Channels
+ * @rxq_entries: Size of receive queues requested by user.
+ * @txq_entries: Size of transmit queues requested by user.
  * @next_buffer_table: First available buffer table id
  * @n_channels: Number of channels in use
  * @n_rx_channels: Number of channels used for RX (= number of RX queues)
@@ -726,6 +731,8 @@ struct efx_nic {
 
 	struct efx_channel *channel[EFX_MAX_CHANNELS];
 
+	unsigned rxq_entries;
+	unsigned txq_entries;
 	unsigned next_buffer_table;
 	unsigned n_channels;
 	unsigned n_rx_channels;
diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index 9e35633..0deb5c3 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -356,7 +356,7 @@ static inline void efx_notify_tx_desc(struct efx_tx_queue *tx_queue)
 	unsigned write_ptr;
 	efx_dword_t reg;
 
-	write_ptr = tx_queue->write_count & EFX_TXQ_MASK;
+	write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_TX_DESC_WPTR_DWORD, write_ptr);
 	efx_writed_page(tx_queue->efx, &reg,
 			FR_AZ_TX_DESC_UPD_DWORD_P0, tx_queue->queue);
@@ -377,7 +377,7 @@ void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 	BUG_ON(tx_queue->write_count == tx_queue->insert_count);
 
 	do {
-		write_ptr = tx_queue->write_count & EFX_TXQ_MASK;
+		write_ptr = tx_queue->write_count & tx_queue->ptr_mask;
 		buffer = &tx_queue->buffer[write_ptr];
 		txd = efx_tx_desc(tx_queue, write_ptr);
 		++tx_queue->write_count;
@@ -398,10 +398,11 @@ void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 int efx_nic_probe_tx(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	BUILD_BUG_ON(EFX_TXQ_SIZE < 512 || EFX_TXQ_SIZE > 4096 ||
-		     EFX_TXQ_SIZE & EFX_TXQ_MASK);
+	unsigned entries;
+
+	entries = tx_queue->ptr_mask + 1;
 	return efx_alloc_special_buffer(efx, &tx_queue->txd,
-					EFX_TXQ_SIZE * sizeof(efx_qword_t));
+					entries * sizeof(efx_qword_t));
 }
 
 void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
@@ -526,30 +527,32 @@ efx_build_rx_desc(struct efx_rx_queue *rx_queue, unsigned index)
  */
 void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue)
 {
+	struct efx_nic *efx = rx_queue->efx;
 	efx_dword_t reg;
 	unsigned write_ptr;
 
 	while (rx_queue->notified_count != rx_queue->added_count) {
-		efx_build_rx_desc(rx_queue,
-				  rx_queue->notified_count &
-				  EFX_RXQ_MASK);
+		efx_build_rx_desc(
+			rx_queue,
+			rx_queue->notified_count & rx_queue->ptr_mask);
 		++rx_queue->notified_count;
 	}
 
 	wmb();
-	write_ptr = rx_queue->added_count & EFX_RXQ_MASK;
+	write_ptr = rx_queue->added_count & rx_queue->ptr_mask;
 	EFX_POPULATE_DWORD_1(reg, FRF_AZ_RX_DESC_WPTR_DWORD, write_ptr);
-	efx_writed_page(rx_queue->efx, &reg, FR_AZ_RX_DESC_UPD_DWORD_P0,
+	efx_writed_page(efx, &reg, FR_AZ_RX_DESC_UPD_DWORD_P0,
 			efx_rx_queue_index(rx_queue));
 }
 
 int efx_nic_probe_rx(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	BUILD_BUG_ON(EFX_RXQ_SIZE < 512 || EFX_RXQ_SIZE > 4096 ||
-		     EFX_RXQ_SIZE & EFX_RXQ_MASK);
+	unsigned entries;
+
+	entries = rx_queue->ptr_mask + 1;
 	return efx_alloc_special_buffer(efx, &rx_queue->rxd,
-					EFX_RXQ_SIZE * sizeof(efx_qword_t));
+					entries * sizeof(efx_qword_t));
 }
 
 void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
@@ -685,7 +688,7 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 		tx_queue = efx_channel_get_tx_queue(
 			channel, tx_ev_q_label % EFX_TXQ_TYPES);
 		tx_packets = ((tx_ev_desc_ptr - tx_queue->read_count) &
-			      EFX_TXQ_MASK);
+			      tx_queue->ptr_mask);
 		channel->irq_mod_score += tx_packets;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
@@ -796,8 +799,8 @@ efx_handle_rx_bad_index(struct efx_rx_queue *rx_queue, unsigned index)
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned expected, dropped;
 
-	expected = rx_queue->removed_count & EFX_RXQ_MASK;
-	dropped = (index - expected) & EFX_RXQ_MASK;
+	expected = rx_queue->removed_count & rx_queue->ptr_mask;
+	dropped = (index - expected) & rx_queue->ptr_mask;
 	netif_info(efx, rx_err, efx->net_dev,
 		   "dropped %d events (index=%d expected=%d)\n",
 		   dropped, index, expected);
@@ -835,7 +838,7 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 	rx_queue = efx_channel_get_rx_queue(channel);
 
 	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
-	expected_ptr = rx_queue->removed_count & EFX_RXQ_MASK;
+	expected_ptr = rx_queue->removed_count & rx_queue->ptr_mask;
 	if (unlikely(rx_ev_desc_ptr != expected_ptr))
 		efx_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
 
@@ -1002,6 +1005,7 @@ efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 
 int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 {
+	struct efx_nic *efx = channel->efx;
 	unsigned int read_ptr;
 	efx_qword_t event, *p_event;
 	int ev_code;
@@ -1026,7 +1030,7 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 		EFX_SET_QWORD(*p_event);
 
 		/* Increment read pointer */
-		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
+		read_ptr = (read_ptr + 1) & channel->eventq_mask;
 
 		ev_code = EFX_QWORD_FIELD(event, FSF_AZ_EV_CODE);
 
@@ -1038,7 +1042,7 @@ int efx_nic_process_eventq(struct efx_channel *channel, int budget)
 			break;
 		case FSE_AZ_EV_CODE_TX_EV:
 			tx_packets += efx_handle_tx_event(channel, &event);
-			if (tx_packets >= EFX_TXQ_SIZE) {
+			if (tx_packets > efx->txq_entries) {
 				spent = budget;
 				goto out;
 			}
@@ -1073,10 +1077,11 @@ out:
 int efx_nic_probe_eventq(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
-	BUILD_BUG_ON(EFX_EVQ_SIZE < 512 || EFX_EVQ_SIZE > 32768 ||
-		     EFX_EVQ_SIZE & EFX_EVQ_MASK);
+	unsigned entries;
+
+	entries = channel->eventq_mask + 1;
 	return efx_alloc_special_buffer(efx, &channel->eventq,
-					EFX_EVQ_SIZE * sizeof(efx_qword_t));
+					entries * sizeof(efx_qword_t));
 }
 
 void efx_nic_init_eventq(struct efx_channel *channel)
@@ -1172,7 +1177,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
 	unsigned int read_ptr = channel->eventq_read_ptr;
-	unsigned int end_ptr = (read_ptr - 1) & EFX_EVQ_MASK;
+	unsigned int end_ptr = (read_ptr - 1) & channel->eventq_mask;
 
 	do {
 		efx_qword_t *event = efx_event(channel, read_ptr);
@@ -1212,7 +1217,7 @@ static void efx_poll_flush_events(struct efx_nic *efx)
 		 * it's ok to throw away every non-flush event */
 		EFX_SET_QWORD(*event);
 
-		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
+		read_ptr = (read_ptr + 1) & channel->eventq_mask;
 	} while (read_ptr != end_ptr);
 
 	channel->eventq_read_ptr = read_ptr;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 6651d93..6d0959b 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -133,7 +133,7 @@ static int efx_init_rx_buffers_skb(struct efx_rx_queue *rx_queue)
 	unsigned index, count;
 
 	for (count = 0; count < EFX_RX_BATCH; ++count) {
-		index = rx_queue->added_count & EFX_RXQ_MASK;
+		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 
 		rx_buf->skb = netdev_alloc_skb(net_dev, skb_len);
@@ -208,7 +208,7 @@ static int efx_init_rx_buffers_page(struct efx_rx_queue *rx_queue)
 		dma_addr += sizeof(struct efx_rx_page_state);
 
 	split:
-		index = rx_queue->added_count & EFX_RXQ_MASK;
+		index = rx_queue->added_count & rx_queue->ptr_mask;
 		rx_buf = efx_rx_buffer(rx_queue, index);
 		rx_buf->dma_addr = dma_addr + EFX_PAGE_IP_ALIGN;
 		rx_buf->skb = NULL;
@@ -285,7 +285,7 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 	 * we'd like to insert an additional descriptor whilst leaving
 	 * EFX_RXD_HEAD_ROOM for the non-recycle path */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count + 2);
-	if (unlikely(fill_level >= EFX_RXQ_SIZE - EFX_RXD_HEAD_ROOM)) {
+	if (unlikely(fill_level > rx_queue->max_fill)) {
 		/* We could place "state" on a list, and drain the list in
 		 * efx_fast_push_rx_descriptors(). For now, this will do. */
 		return;
@@ -294,7 +294,7 @@ static void efx_resurrect_rx_buffer(struct efx_rx_queue *rx_queue,
 	++state->refcnt;
 	get_page(rx_buf->page);
 
-	index = rx_queue->added_count & EFX_RXQ_MASK;
+	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
 	new_buf->dma_addr = rx_buf->dma_addr ^ (PAGE_SIZE >> 1);
 	new_buf->skb = NULL;
@@ -319,7 +319,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 	    page_count(rx_buf->page) == 1)
 		efx_resurrect_rx_buffer(rx_queue, rx_buf);
 
-	index = rx_queue->added_count & EFX_RXQ_MASK;
+	index = rx_queue->added_count & rx_queue->ptr_mask;
 	new_buf = efx_rx_buffer(rx_queue, index);
 
 	memcpy(new_buf, rx_buf, sizeof(*new_buf));
@@ -347,7 +347,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 
 	/* Calculate current fill level, and exit if we don't need to fill */
 	fill_level = (rx_queue->added_count - rx_queue->removed_count);
-	EFX_BUG_ON_PARANOID(fill_level > EFX_RXQ_SIZE);
+	EFX_BUG_ON_PARANOID(fill_level > rx_queue->efx->rxq_entries);
 	if (fill_level >= rx_queue->fast_fill_trigger)
 		goto out;
 
@@ -650,15 +650,22 @@ void efx_rx_strategy(struct efx_channel *channel)
 int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	unsigned int rxq_size;
+	unsigned int entries;
 	int rc;
 
+	/* Create the smallest power-of-two aligned ring */
+	entries = max(roundup_pow_of_two(efx->rxq_entries), EFX_MIN_DMAQ_SIZE);
+	EFX_BUG_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
+	rx_queue->ptr_mask = entries - 1;
+
 	netif_dbg(efx, probe, efx->net_dev,
-		  "creating RX queue %d\n", efx_rx_queue_index(rx_queue));
+		  "creating RX queue %d size %#x mask %#x\n",
+		  efx_rx_queue_index(rx_queue), efx->rxq_entries,
+		  rx_queue->ptr_mask);
 
 	/* Allocate RX buffers */
-	rxq_size = EFX_RXQ_SIZE * sizeof(*rx_queue->buffer);
-	rx_queue->buffer = kzalloc(rxq_size, GFP_KERNEL);
+	rx_queue->buffer = kzalloc(entries * sizeof(*rx_queue->buffer),
+				   GFP_KERNEL);
 	if (!rx_queue->buffer)
 		return -ENOMEM;
 
@@ -672,6 +679,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
+	struct efx_nic *efx = rx_queue->efx;
 	unsigned int max_fill, trigger, limit;
 
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
@@ -682,10 +690,9 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	rx_queue->notified_count = 0;
 	rx_queue->removed_count = 0;
 	rx_queue->min_fill = -1U;
-	rx_queue->min_overfill = -1U;
 
 	/* Initialise limit fields */
-	max_fill = EFX_RXQ_SIZE - EFX_RXD_HEAD_ROOM;
+	max_fill = efx->rxq_entries - EFX_RXD_HEAD_ROOM;
 	trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
 	limit = max_fill * min(rx_refill_limit, 100U) / 100U;
 
@@ -710,7 +717,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 
 	/* Release RX buffers NB start at index 0 not current HW ptr */
 	if (rx_queue->buffer) {
-		for (i = 0; i <= EFX_RXQ_MASK; i++) {
+		for (i = 0; i <= rx_queue->ptr_mask; i++) {
 			rx_buf = efx_rx_buffer(rx_queue, i);
 			efx_fini_rx_buffer(rx_queue, rx_buf);
 		}
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 11153d9..da4473b 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -506,7 +506,7 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 
 	for (i = 0; i < 3; i++) {
 		/* Determine how many packets to send */
-		state->packet_count = EFX_TXQ_SIZE / 3;
+		state->packet_count = efx->txq_entries / 3;
 		state->packet_count = min(1 << (i << 2), state->packet_count);
 		state->skbs = kzalloc(sizeof(state->skbs[0]) *
 				      state->packet_count, GFP_KERNEL);
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 6a6acc4..1172698 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -28,7 +28,7 @@
  * The tx_queue descriptor ring fill-level must fall below this value
  * before we restart the netif queue
  */
-#define EFX_TXQ_THRESHOLD (EFX_TXQ_MASK / 2u)
+#define EFX_TXQ_THRESHOLD(_efx) ((_efx)->txq_entries / 2u)
 
 /* We need to be able to nest calls to netif_tx_stop_queue(), partly
  * because of the 2 hardware queues associated with each core queue,
@@ -207,7 +207,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	}
 
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
-	q_space = EFX_TXQ_MASK - 1 - fill_level;
+	q_space = efx->txq_entries - 1 - fill_level;
 
 	/* Map for DMA.  Use pci_map_single rather than pci_map_page
 	 * since this is more efficient on machines with sparse
@@ -244,14 +244,14 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 					&tx_queue->read_count;
 				fill_level = (tx_queue->insert_count
 					      - tx_queue->old_read_count);
-				q_space = EFX_TXQ_MASK - 1 - fill_level;
+				q_space = efx->txq_entries - 1 - fill_level;
 				if (unlikely(q_space-- <= 0))
 					goto stop;
 				smp_mb();
 				--tx_queue->stopped;
 			}
 
-			insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
+			insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
 			buffer = &tx_queue->buffer[insert_ptr];
 			efx_tsoh_free(tx_queue, buffer);
 			EFX_BUG_ON_PARANOID(buffer->tsoh);
@@ -320,7 +320,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	/* Work backwards until we hit the original insert pointer value */
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		--tx_queue->insert_count;
-		insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
+		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
 		buffer = &tx_queue->buffer[insert_ptr];
 		efx_dequeue_buffer(tx_queue, buffer);
 		buffer->len = 0;
@@ -350,8 +350,8 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 	struct efx_nic *efx = tx_queue->efx;
 	unsigned int stop_index, read_ptr;
 
-	stop_index = (index + 1) & EFX_TXQ_MASK;
-	read_ptr = tx_queue->read_count & EFX_TXQ_MASK;
+	stop_index = (index + 1) & tx_queue->ptr_mask;
+	read_ptr = tx_queue->read_count & tx_queue->ptr_mask;
 
 	while (read_ptr != stop_index) {
 		struct efx_tx_buffer *buffer = &tx_queue->buffer[read_ptr];
@@ -368,7 +368,7 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 		buffer->len = 0;
 
 		++tx_queue->read_count;
-		read_ptr = tx_queue->read_count & EFX_TXQ_MASK;
+		read_ptr = tx_queue->read_count & tx_queue->ptr_mask;
 	}
 }
 
@@ -402,7 +402,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	unsigned fill_level;
 	struct efx_nic *efx = tx_queue->efx;
 
-	EFX_BUG_ON_PARANOID(index > EFX_TXQ_MASK);
+	EFX_BUG_ON_PARANOID(index > tx_queue->ptr_mask);
 
 	efx_dequeue_buffers(tx_queue, index);
 
@@ -412,7 +412,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	smp_mb();
 	if (unlikely(tx_queue->stopped) && likely(efx->port_enabled)) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
-		if (fill_level < EFX_TXQ_THRESHOLD) {
+		if (fill_level < EFX_TXQ_THRESHOLD(efx)) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
 
 			/* Do this under netif_tx_lock(), to avoid racing
@@ -430,18 +430,24 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	unsigned int txq_size;
+	unsigned int entries;
 	int i, rc;
 
-	netif_dbg(efx, probe, efx->net_dev, "creating TX queue %d\n",
-		  tx_queue->queue);
+	/* Create the smallest power-of-two aligned ring */
+	entries = max(roundup_pow_of_two(efx->txq_entries), EFX_MIN_DMAQ_SIZE);
+	EFX_BUG_ON_PARANOID(entries > EFX_MAX_DMAQ_SIZE);
+	tx_queue->ptr_mask = entries - 1;
+
+	netif_dbg(efx, probe, efx->net_dev,
+		  "creating TX queue %d size %#x mask %#x\n",
+		  tx_queue->queue, efx->txq_entries, tx_queue->ptr_mask);
 
 	/* Allocate software ring */
-	txq_size = EFX_TXQ_SIZE * sizeof(*tx_queue->buffer);
-	tx_queue->buffer = kzalloc(txq_size, GFP_KERNEL);
+	tx_queue->buffer = kzalloc(entries * sizeof(*tx_queue->buffer),
+				   GFP_KERNEL);
 	if (!tx_queue->buffer)
 		return -ENOMEM;
-	for (i = 0; i <= EFX_TXQ_MASK; ++i)
+	for (i = 0; i <= tx_queue->ptr_mask; ++i)
 		tx_queue->buffer[i].continuation = true;
 
 	/* Allocate hardware ring */
@@ -481,7 +487,7 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 
 	/* Free any buffers left in the ring */
 	while (tx_queue->read_count != tx_queue->write_count) {
-		buffer = &tx_queue->buffer[tx_queue->read_count & EFX_TXQ_MASK];
+		buffer = &tx_queue->buffer[tx_queue->read_count & tx_queue->ptr_mask];
 		efx_dequeue_buffer(tx_queue, buffer);
 		buffer->continuation = true;
 		buffer->len = 0;
@@ -741,7 +747,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 
 	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
 	/* -1 as there is no way to represent all descriptors used */
-	q_space = EFX_TXQ_MASK - 1 - fill_level;
+	q_space = efx->txq_entries - 1 - fill_level;
 
 	while (1) {
 		if (unlikely(q_space-- <= 0)) {
@@ -757,7 +763,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 				*(volatile unsigned *)&tx_queue->read_count;
 			fill_level = (tx_queue->insert_count
 				      - tx_queue->old_read_count);
-			q_space = EFX_TXQ_MASK - 1 - fill_level;
+			q_space = efx->txq_entries - 1 - fill_level;
 			if (unlikely(q_space-- <= 0)) {
 				*final_buffer = NULL;
 				return 1;
@@ -766,13 +772,13 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			--tx_queue->stopped;
 		}
 
-		insert_ptr = tx_queue->insert_count & EFX_TXQ_MASK;
+		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
 		buffer = &tx_queue->buffer[insert_ptr];
 		++tx_queue->insert_count;
 
 		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
-				    tx_queue->read_count >
-				    EFX_TXQ_MASK);
+				    tx_queue->read_count >=
+				    efx->txq_entries);
 
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->len);
@@ -813,7 +819,7 @@ static void efx_tso_put_header(struct efx_tx_queue *tx_queue,
 {
 	struct efx_tx_buffer *buffer;
 
-	buffer = &tx_queue->buffer[tx_queue->insert_count & EFX_TXQ_MASK];
+	buffer = &tx_queue->buffer[tx_queue->insert_count & tx_queue->ptr_mask];
 	efx_tsoh_free(tx_queue, buffer);
 	EFX_BUG_ON_PARANOID(buffer->len);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
@@ -838,7 +844,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 	while (tx_queue->insert_count != tx_queue->write_count) {
 		--tx_queue->insert_count;
 		buffer = &tx_queue->buffer[tx_queue->insert_count &
-					   EFX_TXQ_MASK];
+					   tx_queue->ptr_mask];
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->skb);
 		if (buffer->unmap_len) {
@@ -1168,7 +1174,7 @@ static void efx_fini_tso(struct efx_tx_queue *tx_queue)
 	unsigned i;
 
 	if (tx_queue->buffer) {
-		for (i = 0; i <= EFX_TXQ_MASK; ++i)
+		for (i = 0; i <= tx_queue->ptr_mask; ++i)
 			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
 	}
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

