From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 08/10] sfc: Allocate each channel separately,
 along with its RX and TX queues
Date: Fri, 10 Sep 2010 17:41:57 +0100
Message-ID: <1284136917.2267.103.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25735 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab0IJQmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:42:01 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow for reallocation of channel structures and rings.

Change module parameter separate_tx_channels to be read-only, since we
now require its value to be constant.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   61 +++++++++++++++++++++++------------------
 drivers/net/sfc/falcon.c     |   14 +++-------
 drivers/net/sfc/net_driver.h |   62 +++++++++++++++--------------------------
 3 files changed, 61 insertions(+), 76 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 3dd71aa..4b42e61 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -114,7 +114,7 @@ static struct workqueue_struct *reset_workqueue;
  * This is only used in MSI-X interrupt mode
  */
 static unsigned int separate_tx_channels;
-module_param(separate_tx_channels, uint, 0644);
+module_param(separate_tx_channels, uint, 0444);
 MODULE_PARM_DESC(separate_tx_channels,
 		 "Use separate channels for TX and RX");
 
@@ -334,6 +334,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
+	BUG_ON(channel->channel >= efx->n_channels);
 	BUG_ON(!channel->enabled);
 
 	/* Disable interrupts and wait for ISRs to complete */
@@ -1098,26 +1099,32 @@ static void efx_remove_interrupts(struct efx_nic *efx)
 	efx->legacy_irq = 0;
 }
 
+struct efx_tx_queue *
+efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
+{
+	unsigned tx_channel_offset =
+		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
+	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
+			    type >= EFX_TXQ_TYPES);
+	return &efx->channel[tx_channel_offset + index]->tx_queue[type];
+}
+
 static void efx_set_channels(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
-	struct efx_rx_queue *rx_queue;
 	unsigned tx_channel_offset =
 		separate_tx_channels ? efx->n_channels - efx->n_tx_channels : 0;
 
+	/* Channel pointers were set in efx_init_struct() but we now
+	 * need to clear them for TX queues in any RX-only channels. */
 	efx_for_each_channel(channel, efx) {
-		if (channel->channel - tx_channel_offset < efx->n_tx_channels) {
-			channel->tx_queue = &efx->tx_queue[
-				(channel->channel - tx_channel_offset) *
-				EFX_TXQ_TYPES];
+		if (channel->channel - tx_channel_offset >=
+		    efx->n_tx_channels) {
 			efx_for_each_channel_tx_queue(tx_queue, channel)
-				tx_queue->channel = channel;
+				tx_queue->channel = NULL;
 		}
 	}
-
-	efx_for_each_rx_queue(rx_queue, efx)
-		rx_queue->channel = &efx->channel[rx_queue->queue];
 }
 
 static int efx_probe_nic(struct efx_nic *efx)
@@ -2044,7 +2051,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	int i;
+	int i, j;
 
 	/* Initialise common structures */
 	memset(efx, 0, sizeof(*efx));
@@ -2072,27 +2079,22 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	INIT_WORK(&efx->mac_work, efx_mac_work);
 
 	for (i = 0; i < EFX_MAX_CHANNELS; i++) {
-		channel = &efx->channel[i];
+		efx->channel[i] = kzalloc(sizeof(*channel), GFP_KERNEL);
+		channel = efx->channel[i];
 		channel->efx = efx;
 		channel->channel = i;
-		channel->work_pending = false;
 		spin_lock_init(&channel->tx_stop_lock);
 		atomic_set(&channel->tx_stop_count, 1);
-	}
-	for (i = 0; i < EFX_MAX_TX_QUEUES; i++) {
-		tx_queue = &efx->tx_queue[i];
-		tx_queue->efx = efx;
-		tx_queue->queue = i;
-		tx_queue->buffer = NULL;
-		tx_queue->channel = &efx->channel[0]; /* for safety */
-		tx_queue->tso_headers_free = NULL;
-	}
-	for (i = 0; i < EFX_MAX_RX_QUEUES; i++) {
-		rx_queue = &efx->rx_queue[i];
+
+		for (j = 0; j < EFX_TXQ_TYPES; j++) {
+			tx_queue = &channel->tx_queue[j];
+			tx_queue->efx = efx;
+			tx_queue->queue = i * EFX_TXQ_TYPES + j;
+			tx_queue->channel = channel;
+		}
+
+		rx_queue = &channel->rx_queue;
 		rx_queue->efx = efx;
-		rx_queue->queue = i;
-		rx_queue->channel = &efx->channel[0]; /* for safety */
-		rx_queue->buffer = NULL;
 		setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
 			    (unsigned long)rx_queue);
 	}
@@ -2120,6 +2122,11 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 
 static void efx_fini_struct(struct efx_nic *efx)
 {
+	int i;
+
+	for (i = 0; i < EFX_MAX_CHANNELS; i++)
+		kfree(efx->channel[i]);
+
 	if (efx->workqueue) {
 		destroy_workqueue(efx->workqueue);
 		efx->workqueue = NULL;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 4f9d33f..b4d8efe 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -159,7 +159,6 @@ irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 {
 	struct efx_nic *efx = dev_id;
 	efx_oword_t *int_ker = efx->irq_status.addr;
-	struct efx_channel *channel;
 	int syserr;
 	int queues;
 
@@ -194,15 +193,10 @@ irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	wmb(); /* Ensure the vector is cleared before interrupt ack */
 	falcon_irq_ack_a1(efx);
 
-	/* Schedule processing of any interrupting queues */
-	channel = &efx->channel[0];
-	while (queues) {
-		if (queues & 0x01)
-			efx_schedule_channel(channel);
-		channel++;
-		queues >>= 1;
-	}
-
+	if (queues & 1)
+		efx_schedule_channel(efx_get_channel(efx, 0));
+	if (queues & 2)
+		efx_schedule_channel(efx_get_channel(efx, 1));
 	return IRQ_HANDLED;
 }
 /**************************************************************************
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index eb35375..cfc65f5 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -225,8 +225,6 @@ struct efx_rx_page_state {
 /**
  * struct efx_rx_queue - An Efx RX queue
  * @efx: The associated Efx NIC
- * @queue: DMA queue number
- * @channel: The associated channel
  * @buffer: The software buffer ring
  * @rxd: The hardware descriptor ring
  * @added_count: Number of buffers added to the receive queue.
@@ -250,8 +248,6 @@ struct efx_rx_page_state {
  */
 struct efx_rx_queue {
 	struct efx_nic *efx;
-	int queue;
-	struct efx_channel *channel;
 	struct efx_rx_buffer *buffer;
 	struct efx_special_buffer rxd;
 
@@ -327,9 +323,10 @@ enum efx_rx_alloc_method {
  * @n_rx_frm_trunc: Count of RX_FRM_TRUNC errors
  * @n_rx_overlength: Count of RX_OVERLENGTH errors
  * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
- * @tx_queue: Pointer to first TX queue, or %NULL if not used for TX
+ * @rx_queue: RX queue for this channel
  * @tx_stop_count: Core TX queue stop count
  * @tx_stop_lock: Core TX queue stop lock
+ * @tx_queue: TX queues for this channel
  */
 struct efx_channel {
 	struct efx_nic *efx;
@@ -366,9 +363,12 @@ struct efx_channel {
 	struct efx_rx_buffer *rx_pkt;
 	bool rx_pkt_csummed;
 
-	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue rx_queue;
+
 	atomic_t tx_stop_count;
 	spinlock_t tx_stop_lock;
+
+	struct efx_tx_queue tx_queue[2];
 };
 
 enum efx_led_mode {
@@ -724,9 +724,7 @@ struct efx_nic {
 	enum nic_state state;
 	enum reset_type reset_pending;
 
-	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
-	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
-	struct efx_channel channel[EFX_MAX_CHANNELS];
+	struct efx_channel *channel[EFX_MAX_CHANNELS];
 
 	unsigned next_buffer_table;
 	unsigned n_channels;
@@ -913,34 +911,30 @@ static inline struct efx_channel *
 efx_get_channel(struct efx_nic *efx, unsigned index)
 {
 	EFX_BUG_ON_PARANOID(index >= efx->n_channels);
-	return &efx->channel[index];
+	return efx->channel[index];
 }
 
 /* Iterate over all used channels */
 #define efx_for_each_channel(_channel, _efx)				\
-	for (_channel = &((_efx)->channel[0]);				\
-	     _channel < &((_efx)->channel[(efx)->n_channels]);		\
-	     _channel++)
+	for (_channel = (_efx)->channel[0];				\
+	     _channel;							\
+	     _channel = (_channel->channel + 1 < (_efx)->n_channels) ?	\
+		     (_efx)->channel[_channel->channel + 1] : NULL)
 
-static inline struct efx_tx_queue *
-efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type)
-{
-	EFX_BUG_ON_PARANOID(index >= efx->n_tx_channels ||
-			    type >= EFX_TXQ_TYPES);
-	return &efx->tx_queue[index * EFX_TXQ_TYPES + type];
-}
+extern struct efx_tx_queue *
+efx_get_tx_queue(struct efx_nic *efx, unsigned index, unsigned type);
 
 static inline struct efx_tx_queue *
 efx_channel_get_tx_queue(struct efx_channel *channel, unsigned type)
 {
 	struct efx_tx_queue *tx_queue = channel->tx_queue;
 	EFX_BUG_ON_PARANOID(type >= EFX_TXQ_TYPES);
-	return tx_queue ? tx_queue + type : NULL;
+	return tx_queue->channel ? tx_queue + type : NULL;
 }
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
-	for (_tx_queue = (_channel)->tx_queue;				\
+	for (_tx_queue = efx_channel_get_tx_queue(channel, 0);		\
 	     _tx_queue && _tx_queue < (_channel)->tx_queue + EFX_TXQ_TYPES; \
 	     _tx_queue++)
 
@@ -948,41 +942,31 @@ static inline struct efx_rx_queue *
 efx_get_rx_queue(struct efx_nic *efx, unsigned index)
 {
 	EFX_BUG_ON_PARANOID(index >= efx->n_rx_channels);
-	return &efx->rx_queue[index];
+	return &efx->channel[index]->rx_queue;
 }
 
-/* Iterate over all used RX queues */
-#define efx_for_each_rx_queue(_rx_queue, _efx)				\
-	for (_rx_queue = &((_efx)->rx_queue[0]);			\
-	     _rx_queue < &((_efx)->rx_queue[(_efx)->n_rx_channels]);	\
-	     _rx_queue++)
-
 static inline struct efx_rx_queue *
 efx_channel_get_rx_queue(struct efx_channel *channel)
 {
-	struct efx_rx_queue *rx_queue =
-		&channel->efx->rx_queue[channel->channel];
-	return rx_queue->channel == channel ? rx_queue : NULL;
+	return channel->channel < channel->efx->n_rx_channels ?
+		&channel->rx_queue : NULL;
 }
 
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
-	for (_rx_queue = &((_channel)->efx->rx_queue[(_channel)->channel]); \
+	for (_rx_queue = efx_channel_get_rx_queue(channel);		\
 	     _rx_queue;							\
-	     _rx_queue = NULL)						\
-		if (_rx_queue->channel != (_channel))			\
-			continue;					\
-		else
+	     _rx_queue = NULL)
 
 static inline struct efx_channel *
 efx_rx_queue_channel(struct efx_rx_queue *rx_queue)
 {
-	return rx_queue->channel;
+	return container_of(rx_queue, struct efx_channel, rx_queue);
 }
 
 static inline int efx_rx_queue_index(struct efx_rx_queue *rx_queue)
 {
-	return rx_queue->queue;
+	return efx_rx_queue_channel(rx_queue)->channel;
 }
 
 /* Returns a pointer to the specified receive buffer in the RX
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

