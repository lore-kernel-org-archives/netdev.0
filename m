From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/12] sfc: Separate shared NIC code from Falcon-specific
 and rename accordingly
Date: Sun, 29 Nov 2009 13:43:56 +0000
Message-ID: <1259502236.3709.51.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29207 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbZK2Nny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 08:43:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c      |   30 ++--
 drivers/net/sfc/ethtool.c  |    4 +-
 drivers/net/sfc/falcon.c   |  507 ++++++++++++++++++++++---------------------
 drivers/net/sfc/falcon.h   |   80 +++++---
 drivers/net/sfc/rx.c       |   10 +-
 drivers/net/sfc/selftest.c |    4 +-
 drivers/net/sfc/tx.c       |   12 +-
 7 files changed, 341 insertions(+), 306 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4b7168f..e5c33c6 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -213,7 +213,7 @@ static int efx_process_channel(struct efx_channel *channel, int rx_quota)
 		     !channel->enabled))
 		return 0;
 
-	rx_packets = falcon_process_eventq(channel, rx_quota);
+	rx_packets = efx_nic_process_eventq(channel, rx_quota);
 	if (rx_packets == 0)
 		return 0;
 
@@ -245,7 +245,7 @@ static inline void efx_channel_processed(struct efx_channel *channel)
 	channel->work_pending = false;
 	smp_wmb();
 
-	falcon_eventq_read_ack(channel);
+	efx_nic_eventq_read_ack(channel);
 }
 
 /* NAPI poll handler
@@ -316,7 +316,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	BUG_ON(!channel->enabled);
 
 	/* Disable interrupts and wait for ISRs to complete */
-	falcon_disable_interrupts(efx);
+	efx_nic_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
 	if (channel->irq)
@@ -333,7 +333,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	efx_channel_processed(channel);
 
 	napi_enable(&channel->napi_str);
-	falcon_enable_interrupts(efx);
+	efx_nic_enable_interrupts(efx);
 }
 
 /* Create event queue
@@ -345,7 +345,7 @@ static int efx_probe_eventq(struct efx_channel *channel)
 {
 	EFX_LOG(channel->efx, "chan %d create event queue\n", channel->channel);
 
-	return falcon_probe_eventq(channel);
+	return efx_nic_probe_eventq(channel);
 }
 
 /* Prepare channel's event queue */
@@ -355,21 +355,21 @@ static void efx_init_eventq(struct efx_channel *channel)
 
 	channel->eventq_read_ptr = 0;
 
-	falcon_init_eventq(channel);
+	efx_nic_init_eventq(channel);
 }
 
 static void efx_fini_eventq(struct efx_channel *channel)
 {
 	EFX_LOG(channel->efx, "chan %d fini event queue\n", channel->channel);
 
-	falcon_fini_eventq(channel);
+	efx_nic_fini_eventq(channel);
 }
 
 static void efx_remove_eventq(struct efx_channel *channel)
 {
 	EFX_LOG(channel->efx, "chan %d remove event queue\n", channel->channel);
 
-	falcon_remove_eventq(channel);
+	efx_nic_remove_eventq(channel);
 }
 
 /**************************************************************************
@@ -535,7 +535,7 @@ static void efx_fini_channels(struct efx_nic *efx)
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
-	rc = falcon_flush_queues(efx);
+	rc = efx_nic_flush_queues(efx);
 	if (rc)
 		EFX_ERR(efx, "failed to flush queues\n");
 	else
@@ -1172,7 +1172,7 @@ static void efx_start_all(struct efx_nic *efx)
 	efx_for_each_channel(channel, efx)
 		efx_start_channel(channel);
 
-	falcon_enable_interrupts(efx);
+	efx_nic_enable_interrupts(efx);
 
 	/* Start the hardware monitor if there is one. Otherwise (we're link
 	 * event driven), we have to poll the PHY because after an event queue
@@ -1226,7 +1226,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	efx->type->stop_stats(efx);
 
 	/* Disable interrupts and wait for ISR to complete */
-	falcon_disable_interrupts(efx);
+	efx_nic_disable_interrupts(efx);
 	if (efx->legacy_irq)
 		synchronize_irq(efx->legacy_irq);
 	efx_for_each_channel(channel, efx) {
@@ -1286,8 +1286,8 @@ void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
-	unsigned tx_ticks = irq_mod_ticks(tx_usecs, FALCON_IRQ_MOD_RESOLUTION);
-	unsigned rx_ticks = irq_mod_ticks(rx_usecs, FALCON_IRQ_MOD_RESOLUTION);
+	unsigned tx_ticks = irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
+	unsigned rx_ticks = irq_mod_ticks(rx_usecs, EFX_IRQ_MOD_RESOLUTION);
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
@@ -2042,7 +2042,7 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
-	falcon_fini_interrupt(efx);
+	efx_nic_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
 	efx->type->fini(efx);
@@ -2119,7 +2119,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 
 	efx_init_channels(efx);
 
-	rc = falcon_init_interrupt(efx);
+	rc = efx_nic_init_interrupt(efx);
 	if (rc)
 		goto fail5;
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 5063975..e86cbca 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -611,8 +611,8 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 	coalesce->use_adaptive_rx_coalesce = efx->irq_rx_adaptive;
 	coalesce->rx_coalesce_usecs_irq = efx->irq_rx_moderation;
 
-	coalesce->tx_coalesce_usecs_irq *= FALCON_IRQ_MOD_RESOLUTION;
-	coalesce->rx_coalesce_usecs_irq *= FALCON_IRQ_MOD_RESOLUTION;
+	coalesce->tx_coalesce_usecs_irq *= EFX_IRQ_MOD_RESOLUTION;
+	coalesce->rx_coalesce_usecs_irq *= EFX_IRQ_MOD_RESOLUTION;
 
 	return 0;
 }
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 61cc994..2e4c711 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -69,8 +69,8 @@ default_flash_type = ((17 << SPI_DEV_TYPE_SIZE_LBN)
  * watermark send XOFF. Only used if RX flow control is enabled (ethtool -A)
  * This also has an effect on RX/TX arbitration
  */
-static int rx_xoff_thresh_bytes = -1;
-module_param(rx_xoff_thresh_bytes, int, 0644);
+int efx_nic_rx_xoff_thresh = -1;
+module_param_named(rx_xoff_thresh_bytes, efx_nic_rx_xoff_thresh, int, 0644);
 MODULE_PARM_DESC(rx_xoff_thresh_bytes, "RX fifo XOFF threshold");
 
 /* RX FIFO XON watermark
@@ -79,21 +79,21 @@ MODULE_PARM_DESC(rx_xoff_thresh_bytes, "RX fifo XOFF threshold");
  * watermark send XON. Only used if TX flow control is enabled (ethtool -A)
  * This also has an effect on RX/TX arbitration
  */
-static int rx_xon_thresh_bytes = -1;
-module_param(rx_xon_thresh_bytes, int, 0644);
+int efx_nic_rx_xon_thresh = -1;
+module_param_named(rx_xon_thresh_bytes, efx_nic_rx_xon_thresh, int, 0644);
 MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 
-/* If FALCON_MAX_INT_ERRORS internal errors occur within
- * FALCON_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
+/* If EFX_MAX_INT_ERRORS internal errors occur within
+ * EFX_INT_ERROR_EXPIRE seconds, we consider the NIC broken and
  * disable it.
  */
-#define FALCON_INT_ERROR_EXPIRE 3600
-#define FALCON_MAX_INT_ERRORS 5
+#define EFX_INT_ERROR_EXPIRE 3600
+#define EFX_MAX_INT_ERRORS 5
 
 /* We poll for events every FLUSH_INTERVAL ms, and check FLUSH_POLL_COUNT times
  */
-#define FALCON_FLUSH_INTERVAL 10
-#define FALCON_FLUSH_POLL_COUNT 100
+#define EFX_FLUSH_INTERVAL 10
+#define EFX_FLUSH_POLL_COUNT 100
 
 /**************************************************************************
  *
@@ -103,30 +103,27 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
  */
 
 /* Size and alignment of special buffers (4KB) */
-#define FALCON_BUF_SIZE 4096
+#define EFX_BUF_SIZE 4096
 
 /* Depth of RX flush request fifo */
-#define FALCON_RX_FLUSH_COUNT 4
-
-#define FALCON_IS_DUAL_FUNC(efx)		\
-	(efx_nic_rev(efx) < EFX_REV_FALCON_B0)
+#define EFX_RX_FLUSH_COUNT 4
 
 /**************************************************************************
  *
- * Falcon hardware access
+ * Solarstorm hardware access
  *
  **************************************************************************/
 
-static inline void falcon_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
-					unsigned int index)
+static inline void efx_write_buf_tbl(struct efx_nic *efx, efx_qword_t *value,
+				     unsigned int index)
 {
 	efx_sram_writeq(efx, efx->membase + efx->type->buf_tbl_base,
 			value, index);
 }
 
 /* Read the current event from the event queue */
-static inline efx_qword_t *falcon_event(struct efx_channel *channel,
-					unsigned int index)
+static inline efx_qword_t *efx_event(struct efx_channel *channel,
+				     unsigned int index)
 {
 	return (((efx_qword_t *) (channel->eventq.addr)) + index);
 }
@@ -141,7 +138,7 @@ static inline efx_qword_t *falcon_event(struct efx_channel *channel,
  * Note that using a single 64-bit comparison is incorrect; even
  * though the CPU read will be atomic, the DMA write may not be.
  */
-static inline int falcon_event_present(efx_qword_t *event)
+static inline int efx_event_present(efx_qword_t *event)
 {
 	return (!(EFX_DWORD_IS_ALL_ONES(event->dword[0]) |
 		  EFX_DWORD_IS_ALL_ONES(event->dword[1])));
@@ -205,22 +202,21 @@ static struct i2c_algo_bit_data falcon_i2c_bit_operations = {
 
 /**************************************************************************
  *
- * Falcon special buffer handling
+ * Special buffer handling
  * Special buffers are used for event queues and the TX and RX
  * descriptor rings.
  *
  *************************************************************************/
 
 /*
- * Initialise a Falcon special buffer
+ * Initialise a special buffer
  *
  * This will define a buffer (previously allocated via
- * falcon_alloc_special_buffer()) in Falcon's buffer table, allowing
+ * efx_alloc_special_buffer()) in the buffer table, allowing
  * it to be used for event queues, descriptor rings etc.
  */
 static void
-falcon_init_special_buffer(struct efx_nic *efx,
-			   struct efx_special_buffer *buffer)
+efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
 	efx_qword_t buf_desc;
 	int index;
@@ -239,14 +235,13 @@ falcon_init_special_buffer(struct efx_nic *efx,
 				     FRF_AZ_BUF_ADR_REGION, 0,
 				     FRF_AZ_BUF_ADR_FBUF, dma_addr >> 12,
 				     FRF_AZ_BUF_OWNER_ID_FBUF, 0);
-		falcon_write_buf_tbl(efx, &buf_desc, index);
+		efx_write_buf_tbl(efx, &buf_desc, index);
 	}
 }
 
-/* Unmaps a buffer from Falcon and clears the buffer table entries */
+/* Unmaps a buffer and clears the buffer table entries */
 static void
-falcon_fini_special_buffer(struct efx_nic *efx,
-			   struct efx_special_buffer *buffer)
+efx_fini_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
 	efx_oword_t buf_tbl_upd;
 	unsigned int start = buffer->index;
@@ -267,27 +262,27 @@ falcon_fini_special_buffer(struct efx_nic *efx,
 }
 
 /*
- * Allocate a new Falcon special buffer
+ * Allocate a new special buffer
  *
  * This allocates memory for a new buffer, clears it and allocates a
- * new buffer ID range.  It does not write into Falcon's buffer table.
+ * new buffer ID range.  It does not write into the buffer table.
  *
- * This call will allocate 4KB buffers, since Falcon can't use 8KB
- * buffers for event queues and descriptor rings.
+ * This call will allocate 4KB buffers, since 8KB buffers can't be
+ * used for event queues and descriptor rings.
  */
-static int falcon_alloc_special_buffer(struct efx_nic *efx,
-				       struct efx_special_buffer *buffer,
-				       unsigned int len)
+static int efx_alloc_special_buffer(struct efx_nic *efx,
+				    struct efx_special_buffer *buffer,
+				    unsigned int len)
 {
-	len = ALIGN(len, FALCON_BUF_SIZE);
+	len = ALIGN(len, EFX_BUF_SIZE);
 
 	buffer->addr = pci_alloc_consistent(efx->pci_dev, len,
 					    &buffer->dma_addr);
 	if (!buffer->addr)
 		return -ENOMEM;
 	buffer->len = len;
-	buffer->entries = len / FALCON_BUF_SIZE;
-	BUG_ON(buffer->dma_addr & (FALCON_BUF_SIZE - 1));
+	buffer->entries = len / EFX_BUF_SIZE;
+	BUG_ON(buffer->dma_addr & (EFX_BUF_SIZE - 1));
 
 	/* All zeros is a potentially valid event so memset to 0xff */
 	memset(buffer->addr, 0xff, len);
@@ -305,8 +300,8 @@ static int falcon_alloc_special_buffer(struct efx_nic *efx,
 	return 0;
 }
 
-static void falcon_free_special_buffer(struct efx_nic *efx,
-				       struct efx_special_buffer *buffer)
+static void
+efx_free_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
 	if (!buffer->addr)
 		return;
@@ -325,13 +320,13 @@ static void falcon_free_special_buffer(struct efx_nic *efx,
 
 /**************************************************************************
  *
- * Falcon generic buffer handling
+ * Generic buffer handling
  * These buffers are used for interrupt status and MAC stats
  *
  **************************************************************************/
 
-static int falcon_alloc_buffer(struct efx_nic *efx,
-			       struct efx_buffer *buffer, unsigned int len)
+int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
+			 unsigned int len)
 {
 	buffer->addr = pci_alloc_consistent(efx->pci_dev, len,
 					    &buffer->dma_addr);
@@ -342,7 +337,7 @@ static int falcon_alloc_buffer(struct efx_nic *efx,
 	return 0;
 }
 
-static void falcon_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
+void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
 {
 	if (buffer->addr) {
 		pci_free_consistent(efx->pci_dev, buffer->len,
@@ -353,21 +348,21 @@ static void falcon_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer)
 
 /**************************************************************************
  *
- * Falcon TX path
+ * TX path
  *
  **************************************************************************/
 
 /* Returns a pointer to the specified transmit descriptor in the TX
  * descriptor queue belonging to the specified channel.
  */
-static inline efx_qword_t *falcon_tx_desc(struct efx_tx_queue *tx_queue,
-					       unsigned int index)
+static inline efx_qword_t *
+efx_tx_desc(struct efx_tx_queue *tx_queue, unsigned int index)
 {
 	return (((efx_qword_t *) (tx_queue->txd.addr)) + index);
 }
 
 /* This writes to the TX_DESC_WPTR; write pointer for TX descriptor ring */
-static inline void falcon_notify_tx_desc(struct efx_tx_queue *tx_queue)
+static inline void efx_notify_tx_desc(struct efx_tx_queue *tx_queue)
 {
 	unsigned write_ptr;
 	efx_dword_t reg;
@@ -383,7 +378,7 @@ static inline void falcon_notify_tx_desc(struct efx_tx_queue *tx_queue)
  * descriptor in the hardware TX descriptor ring (in host memory), and
  * write a doorbell.
  */
-void falcon_push_buffers(struct efx_tx_queue *tx_queue)
+void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 {
 
 	struct efx_tx_buffer *buffer;
@@ -395,7 +390,7 @@ void falcon_push_buffers(struct efx_tx_queue *tx_queue)
 	do {
 		write_ptr = tx_queue->write_count & EFX_TXQ_MASK;
 		buffer = &tx_queue->buffer[write_ptr];
-		txd = falcon_tx_desc(tx_queue, write_ptr);
+		txd = efx_tx_desc(tx_queue, write_ptr);
 		++tx_queue->write_count;
 
 		/* Create TX descriptor ring entry */
@@ -407,20 +402,20 @@ void falcon_push_buffers(struct efx_tx_queue *tx_queue)
 	} while (tx_queue->write_count != tx_queue->insert_count);
 
 	wmb(); /* Ensure descriptors are written before they are fetched */
-	falcon_notify_tx_desc(tx_queue);
+	efx_notify_tx_desc(tx_queue);
 }
 
 /* Allocate hardware resources for a TX queue */
-int falcon_probe_tx(struct efx_tx_queue *tx_queue)
+int efx_nic_probe_tx(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	BUILD_BUG_ON(EFX_TXQ_SIZE < 512 || EFX_TXQ_SIZE > 4096 ||
 		     EFX_TXQ_SIZE & EFX_TXQ_MASK);
-	return falcon_alloc_special_buffer(efx, &tx_queue->txd,
-					   EFX_TXQ_SIZE * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(efx, &tx_queue->txd,
+					EFX_TXQ_SIZE * sizeof(efx_qword_t));
 }
 
-void falcon_init_tx(struct efx_tx_queue *tx_queue)
+void efx_nic_init_tx(struct efx_tx_queue *tx_queue)
 {
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
@@ -428,7 +423,7 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	tx_queue->flushed = FLUSH_NONE;
 
 	/* Pin TX descriptor ring */
-	falcon_init_special_buffer(efx, &tx_queue->txd);
+	efx_init_special_buffer(efx, &tx_queue->txd);
 
 	/* Push TX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(tx_desc_ptr,
@@ -470,7 +465,7 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	}
 }
 
-static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
+static void efx_flush_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_flush_descq;
@@ -484,7 +479,7 @@ static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 	efx_writeo(efx, &tx_flush_descq, FR_AZ_TX_FLUSH_DESCQ);
 }
 
-void falcon_fini_tx(struct efx_tx_queue *tx_queue)
+void efx_nic_fini_tx(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_desc_ptr;
@@ -498,36 +493,36 @@ void falcon_fini_tx(struct efx_tx_queue *tx_queue)
 			 tx_queue->queue);
 
 	/* Unpin TX descriptor ring */
-	falcon_fini_special_buffer(efx, &tx_queue->txd);
+	efx_fini_special_buffer(efx, &tx_queue->txd);
 }
 
 /* Free buffers backing TX queue */
-void falcon_remove_tx(struct efx_tx_queue *tx_queue)
+void efx_nic_remove_tx(struct efx_tx_queue *tx_queue)
 {
-	falcon_free_special_buffer(tx_queue->efx, &tx_queue->txd);
+	efx_free_special_buffer(tx_queue->efx, &tx_queue->txd);
 }
 
 /**************************************************************************
  *
- * Falcon RX path
+ * RX path
  *
  **************************************************************************/
 
 /* Returns a pointer to the specified descriptor in the RX descriptor queue */
-static inline efx_qword_t *falcon_rx_desc(struct efx_rx_queue *rx_queue,
-					       unsigned int index)
+static inline efx_qword_t *
+efx_rx_desc(struct efx_rx_queue *rx_queue, unsigned int index)
 {
 	return (((efx_qword_t *) (rx_queue->rxd.addr)) + index);
 }
 
 /* This creates an entry in the RX descriptor queue */
-static inline void falcon_build_rx_desc(struct efx_rx_queue *rx_queue,
-					unsigned index)
+static inline void
+efx_build_rx_desc(struct efx_rx_queue *rx_queue, unsigned index)
 {
 	struct efx_rx_buffer *rx_buf;
 	efx_qword_t *rxd;
 
-	rxd = falcon_rx_desc(rx_queue, index);
+	rxd = efx_rx_desc(rx_queue, index);
 	rx_buf = efx_rx_buffer(rx_queue, index);
 	EFX_POPULATE_QWORD_3(*rxd,
 			     FSF_AZ_RX_KER_BUF_SIZE,
@@ -540,15 +535,15 @@ static inline void falcon_build_rx_desc(struct efx_rx_queue *rx_queue,
 /* This writes to the RX_DESC_WPTR register for the specified receive
  * descriptor ring.
  */
-void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
+void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue)
 {
 	efx_dword_t reg;
 	unsigned write_ptr;
 
 	while (rx_queue->notified_count != rx_queue->added_count) {
-		falcon_build_rx_desc(rx_queue,
-				     rx_queue->notified_count &
-				     EFX_RXQ_MASK);
+		efx_build_rx_desc(rx_queue,
+				  rx_queue->notified_count &
+				  EFX_RXQ_MASK);
 		++rx_queue->notified_count;
 	}
 
@@ -559,16 +554,16 @@ void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue)
 			FR_AZ_RX_DESC_UPD_DWORD_P0, rx_queue->queue);
 }
 
-int falcon_probe_rx(struct efx_rx_queue *rx_queue)
+int efx_nic_probe_rx(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	BUILD_BUG_ON(EFX_RXQ_SIZE < 512 || EFX_RXQ_SIZE > 4096 ||
 		     EFX_RXQ_SIZE & EFX_RXQ_MASK);
-	return falcon_alloc_special_buffer(efx, &rx_queue->rxd,
-					   EFX_RXQ_SIZE * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(efx, &rx_queue->rxd,
+					EFX_RXQ_SIZE * sizeof(efx_qword_t));
 }
 
-void falcon_init_rx(struct efx_rx_queue *rx_queue)
+void efx_nic_init_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
@@ -582,7 +577,7 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 	rx_queue->flushed = FLUSH_NONE;
 
 	/* Pin RX descriptor ring */
-	falcon_init_special_buffer(efx, &rx_queue->rxd);
+	efx_init_special_buffer(efx, &rx_queue->rxd);
 
 	/* Push RX descriptor ring to card */
 	EFX_POPULATE_OWORD_10(rx_desc_ptr,
@@ -603,7 +598,7 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 			 rx_queue->queue);
 }
 
-static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
+static void efx_flush_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	efx_oword_t rx_flush_descq;
@@ -617,7 +612,7 @@ static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 	efx_writeo(efx, &rx_flush_descq, FR_AZ_RX_FLUSH_DESCQ);
 }
 
-void falcon_fini_rx(struct efx_rx_queue *rx_queue)
+void efx_nic_fini_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
@@ -631,18 +626,18 @@ void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 			 rx_queue->queue);
 
 	/* Unpin RX descriptor ring */
-	falcon_fini_special_buffer(efx, &rx_queue->rxd);
+	efx_fini_special_buffer(efx, &rx_queue->rxd);
 }
 
 /* Free buffers backing RX queue */
-void falcon_remove_rx(struct efx_rx_queue *rx_queue)
+void efx_nic_remove_rx(struct efx_rx_queue *rx_queue)
 {
-	falcon_free_special_buffer(rx_queue->efx, &rx_queue->rxd);
+	efx_free_special_buffer(rx_queue->efx, &rx_queue->rxd);
 }
 
 /**************************************************************************
  *
- * Falcon event queue processing
+ * Event queue processing
  * Event queues are processed by per-channel tasklets.
  *
  **************************************************************************/
@@ -656,7 +651,7 @@ void falcon_remove_rx(struct efx_rx_queue *rx_queue)
  * whereas channel->eventq_read_ptr contains the index of the "next to
  * read" event.
  */
-void falcon_eventq_read_ack(struct efx_channel *channel)
+void efx_nic_eventq_read_ack(struct efx_channel *channel)
 {
 	efx_dword_t reg;
 	struct efx_nic *efx = channel->efx;
@@ -667,7 +662,7 @@ void falcon_eventq_read_ack(struct efx_channel *channel)
 }
 
 /* Use HW to insert a SW defined event */
-void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
+void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	efx_oword_t drv_ev_reg;
 
@@ -683,11 +678,11 @@ void falcon_generate_event(struct efx_channel *channel, efx_qword_t *event)
 
 /* Handle a transmit completion event
  *
- * Falcon batches TX completion events; the message we receive is of
+ * The NIC batches TX completion events; the message we receive is of
  * the form "complete all TX events up to this index".
  */
-static void falcon_handle_tx_event(struct efx_channel *channel,
-				   efx_qword_t *event)
+static void
+efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	unsigned int tx_ev_desc_ptr;
 	unsigned int tx_ev_q_label;
@@ -710,7 +705,7 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 
 		if (efx_dev_registered(efx))
 			netif_tx_lock(efx->net_dev);
-		falcon_notify_tx_desc(tx_queue);
+		efx_notify_tx_desc(tx_queue);
 		if (efx_dev_registered(efx))
 			netif_tx_unlock(efx->net_dev);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_PKT_ERR) &&
@@ -724,10 +719,10 @@ static void falcon_handle_tx_event(struct efx_channel *channel,
 }
 
 /* Detect errors included in the rx_evt_pkt_ok bit. */
-static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
-				    const efx_qword_t *event,
-				    bool *rx_ev_pkt_ok,
-				    bool *discard)
+static void efx_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
+				 const efx_qword_t *event,
+				 bool *rx_ev_pkt_ok,
+				 bool *discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	bool rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
@@ -799,8 +794,8 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 }
 
 /* Handle receive events that are not in-order. */
-static void falcon_handle_rx_bad_index(struct efx_rx_queue *rx_queue,
-				       unsigned index)
+static void
+efx_handle_rx_bad_index(struct efx_rx_queue *rx_queue, unsigned index)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned expected, dropped;
@@ -816,13 +811,13 @@ static void falcon_handle_rx_bad_index(struct efx_rx_queue *rx_queue,
 
 /* Handle a packet received event
  *
- * Falcon silicon gives a "discard" flag if it's a unicast packet with the
+ * The NIC gives a "discard" flag if it's a unicast packet with the
  * wrong destination address
  * Also "is multicast" and "matches multicast filter" flags can be used to
  * discard non-matching multicast packets.
  */
-static void falcon_handle_rx_event(struct efx_channel *channel,
-				   const efx_qword_t *event)
+static void
+efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 {
 	unsigned int rx_ev_desc_ptr, rx_ev_byte_cnt;
 	unsigned int rx_ev_hdr_type, rx_ev_mcast_pkt;
@@ -845,19 +840,18 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_DESC_PTR);
 	expected_ptr = rx_queue->removed_count & EFX_RXQ_MASK;
 	if (unlikely(rx_ev_desc_ptr != expected_ptr))
-		falcon_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
+		efx_handle_rx_bad_index(rx_queue, rx_ev_desc_ptr);
 
 	if (likely(rx_ev_pkt_ok)) {
-		/* If packet is marked as OK and packet type is TCP/IPv4 or
-		 * UDP/IPv4, then we can rely on the hardware checksum.
+		/* If packet is marked as OK and packet type is TCP/IP or
+		 * UDP/IP, then we can rely on the hardware checksum.
 		 */
 		checksummed =
 			likely(efx->rx_checksum_enabled) &&
-			(rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP ||
-			 rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP);
+			(rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
+			 rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP);
 	} else {
-		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
-					&discard);
+		efx_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok, &discard);
 		checksummed = false;
 	}
 
@@ -881,8 +875,8 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 }
 
 /* Global events are basically PHY events */
-static void falcon_handle_global_event(struct efx_channel *channel,
-				       efx_qword_t *event)
+static void
+efx_handle_global_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
 	bool handled = false;
@@ -918,8 +912,8 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 			EFX_QWORD_VAL(*event));
 }
 
-static void falcon_handle_driver_event(struct efx_channel *channel,
-				       efx_qword_t *event)
+static void
+efx_handle_driver_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	struct efx_nic *efx = channel->efx;
 	unsigned int ev_sub_code;
@@ -980,7 +974,7 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 	}
 }
 
-int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
+int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota)
 {
 	unsigned int read_ptr;
 	efx_qword_t event, *p_event;
@@ -990,10 +984,10 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 	read_ptr = channel->eventq_read_ptr;
 
 	do {
-		p_event = falcon_event(channel, read_ptr);
+		p_event = efx_event(channel, read_ptr);
 		event = *p_event;
 
-		if (!falcon_event_present(&event))
+		if (!efx_event_present(&event))
 			/* End of events */
 			break;
 
@@ -1007,11 +1001,11 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 
 		switch (ev_code) {
 		case FSE_AZ_EV_CODE_RX_EV:
-			falcon_handle_rx_event(channel, &event);
+			efx_handle_rx_event(channel, &event);
 			++rx_packets;
 			break;
 		case FSE_AZ_EV_CODE_TX_EV:
-			falcon_handle_tx_event(channel, &event);
+			efx_handle_tx_event(channel, &event);
 			break;
 		case FSE_AZ_EV_CODE_DRV_GEN_EV:
 			channel->eventq_magic = EFX_QWORD_FIELD(
@@ -1021,10 +1015,10 @@ int falcon_process_eventq(struct efx_channel *channel, int rx_quota)
 				EFX_QWORD_VAL(event));
 			break;
 		case FSE_AZ_EV_CODE_GLOBAL_EV:
-			falcon_handle_global_event(channel, &event);
+			efx_handle_global_event(channel, &event);
 			break;
 		case FSE_AZ_EV_CODE_DRIVER_EV:
-			falcon_handle_driver_event(channel, &event);
+			efx_handle_driver_event(channel, &event);
 			break;
 		default:
 			EFX_ERR(channel->efx, "channel %d unknown event type %d"
@@ -1066,16 +1060,16 @@ static void falcon_push_irq_moderation(struct efx_channel *channel)
 }
 
 /* Allocate buffer table entries for event queue */
-int falcon_probe_eventq(struct efx_channel *channel)
+int efx_nic_probe_eventq(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 	BUILD_BUG_ON(EFX_EVQ_SIZE < 512 || EFX_EVQ_SIZE > 32768 ||
 		     EFX_EVQ_SIZE & EFX_EVQ_MASK);
-	return falcon_alloc_special_buffer(efx, &channel->eventq,
-					   EFX_EVQ_SIZE * sizeof(efx_qword_t));
+	return efx_alloc_special_buffer(efx, &channel->eventq,
+					EFX_EVQ_SIZE * sizeof(efx_qword_t));
 }
 
-void falcon_init_eventq(struct efx_channel *channel)
+void efx_nic_init_eventq(struct efx_channel *channel)
 {
 	efx_oword_t evq_ptr;
 	struct efx_nic *efx = channel->efx;
@@ -1085,7 +1079,7 @@ void falcon_init_eventq(struct efx_channel *channel)
 		channel->eventq.index + channel->eventq.entries - 1);
 
 	/* Pin event queue buffer */
-	falcon_init_special_buffer(efx, &channel->eventq);
+	efx_init_special_buffer(efx, &channel->eventq);
 
 	/* Fill event queue with all ones (i.e. empty events) */
 	memset(channel->eventq.addr, 0xff, channel->eventq.len);
@@ -1098,10 +1092,10 @@ void falcon_init_eventq(struct efx_channel *channel)
 	efx_writeo_table(efx, &evq_ptr, efx->type->evq_ptr_tbl_base,
 			 channel->channel);
 
-	falcon_push_irq_moderation(channel);
+	efx->type->push_irq_moderation(channel);
 }
 
-void falcon_fini_eventq(struct efx_channel *channel)
+void efx_nic_fini_eventq(struct efx_channel *channel)
 {
 	efx_oword_t eventq_ptr;
 	struct efx_nic *efx = channel->efx;
@@ -1112,13 +1106,13 @@ void falcon_fini_eventq(struct efx_channel *channel)
 			 channel->channel);
 
 	/* Unpin event queue */
-	falcon_fini_special_buffer(efx, &channel->eventq);
+	efx_fini_special_buffer(efx, &channel->eventq);
 }
 
 /* Free buffers backing event queue */
-void falcon_remove_eventq(struct efx_channel *channel)
+void efx_nic_remove_eventq(struct efx_channel *channel)
 {
-	falcon_free_special_buffer(channel->efx, &channel->eventq);
+	efx_free_special_buffer(channel->efx, &channel->eventq);
 }
 

@@ -1126,14 +1120,14 @@ void falcon_remove_eventq(struct efx_channel *channel)
  * process_eventq() should pick up the event and place the value of
  * "magic" into channel->eventq_magic;
  */
-void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
+void efx_nic_generate_test_event(struct efx_channel *channel, unsigned int magic)
 {
 	efx_qword_t test_event;
 
 	EFX_POPULATE_QWORD_2(test_event, FSF_AZ_EV_CODE,
 			     FSE_AZ_EV_CODE_DRV_GEN_EV,
 			     FSF_AZ_DRV_GEN_EV_MAGIC, magic);
-	falcon_generate_event(channel, &test_event);
+	efx_generate_event(channel, &test_event);
 }
 
 /**************************************************************************
@@ -1143,7 +1137,7 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
  **************************************************************************/
 

-static void falcon_poll_flush_events(struct efx_nic *efx)
+static void efx_poll_flush_events(struct efx_nic *efx)
 {
 	struct efx_channel *channel = &efx->channel[0];
 	struct efx_tx_queue *tx_queue;
@@ -1152,11 +1146,11 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 	unsigned int end_ptr = (read_ptr - 1) & EFX_EVQ_MASK;
 
 	do {
-		efx_qword_t *event = falcon_event(channel, read_ptr);
+		efx_qword_t *event = efx_event(channel, read_ptr);
 		int ev_code, ev_sub_code, ev_queue;
 		bool ev_failed;
 
-		if (!falcon_event_present(event))
+		if (!efx_event_present(event))
 			break;
 
 		ev_code = EFX_QWORD_FIELD(*event, FSF_AZ_EV_CODE);
@@ -1208,7 +1202,7 @@ static void falcon_prepare_flush(struct efx_nic *efx)
 /* Handle tx and rx flushes at the same time, since they run in
  * parallel in the hardware and there's no reason for us to
  * serialise them */
-int falcon_flush_queues(struct efx_nic *efx)
+int efx_nic_flush_queues(struct efx_nic *efx)
 {
 	struct efx_rx_queue *rx_queue;
 	struct efx_tx_queue *tx_queue;
@@ -1219,22 +1213,22 @@ int falcon_flush_queues(struct efx_nic *efx)
 
 	/* Flush all tx queues in parallel */
 	efx_for_each_tx_queue(tx_queue, efx)
-		falcon_flush_tx_queue(tx_queue);
+		efx_flush_tx_queue(tx_queue);
 
 	/* The hardware supports four concurrent rx flushes, each of which may
 	 * need to be retried if there is an outstanding descriptor fetch */
-	for (i = 0; i < FALCON_FLUSH_POLL_COUNT; ++i) {
+	for (i = 0; i < EFX_FLUSH_POLL_COUNT; ++i) {
 		rx_pending = tx_pending = 0;
 		efx_for_each_rx_queue(rx_queue, efx) {
 			if (rx_queue->flushed == FLUSH_PENDING)
 				++rx_pending;
 		}
 		efx_for_each_rx_queue(rx_queue, efx) {
-			if (rx_pending == FALCON_RX_FLUSH_COUNT)
+			if (rx_pending == EFX_RX_FLUSH_COUNT)
 				break;
 			if (rx_queue->flushed == FLUSH_FAILED ||
 			    rx_queue->flushed == FLUSH_NONE) {
-				falcon_flush_rx_queue(rx_queue);
+				efx_flush_rx_queue(rx_queue);
 				++rx_pending;
 			}
 		}
@@ -1246,8 +1240,8 @@ int falcon_flush_queues(struct efx_nic *efx)
 		if (rx_pending == 0 && tx_pending == 0)
 			return 0;
 
-		msleep(FALCON_FLUSH_INTERVAL);
-		falcon_poll_flush_events(efx);
+		msleep(EFX_FLUSH_INTERVAL);
+		efx_poll_flush_events(efx);
 	}
 
 	/* Mark the queues as all flushed. We're going to return failure
@@ -1273,15 +1267,15 @@ int falcon_flush_queues(struct efx_nic *efx)
 
 /**************************************************************************
  *
- * Falcon hardware interrupts
+ * Hardware interrupts
  * The hardware interrupt handler does very little work; all the event
  * queue processing is carried out by per-channel tasklets.
  *
  **************************************************************************/
 
-/* Enable/disable/generate Falcon interrupts */
-static inline void falcon_interrupts(struct efx_nic *efx, int enabled,
-				     int force)
+/* Enable/disable/generate interrupts */
+static inline void efx_nic_interrupts(struct efx_nic *efx,
+				      bool enabled, bool force)
 {
 	efx_oword_t int_en_reg_ker;
 
@@ -1291,7 +1285,7 @@ static inline void falcon_interrupts(struct efx_nic *efx, int enabled,
 	efx_writeo(efx, &int_en_reg_ker, FR_AZ_INT_EN_KER);
 }
 
-void falcon_enable_interrupts(struct efx_nic *efx)
+void efx_nic_enable_interrupts(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 
@@ -1299,7 +1293,7 @@ void falcon_enable_interrupts(struct efx_nic *efx)
 	wmb(); /* Ensure interrupt vector is clear before interrupts enabled */
 
 	/* Enable interrupts */
-	falcon_interrupts(efx, 1, 0);
+	efx_nic_interrupts(efx, true, false);
 
 	/* Force processing of all the channels to get the EVQ RPTRs up to
 	   date */
@@ -1307,19 +1301,19 @@ void falcon_enable_interrupts(struct efx_nic *efx)
 		efx_schedule_channel(channel);
 }
 
-void falcon_disable_interrupts(struct efx_nic *efx)
+void efx_nic_disable_interrupts(struct efx_nic *efx)
 {
 	/* Disable interrupts */
-	falcon_interrupts(efx, 0, 0);
+	efx_nic_interrupts(efx, false, false);
 }
 
-/* Generate a Falcon test interrupt
+/* Generate a test interrupt
  * Interrupt must already have been enabled, otherwise nasty things
  * may happen.
  */
-void falcon_generate_interrupt(struct efx_nic *efx)
+void efx_nic_generate_interrupt(struct efx_nic *efx)
 {
-	falcon_interrupts(efx, 1, 1);
+	efx_nic_interrupts(efx, true, true);
 }
 
 /* Acknowledge a legacy interrupt from Falcon
@@ -1332,7 +1326,7 @@ void falcon_generate_interrupt(struct efx_nic *efx)
  *
  * NB most hardware supports MSI interrupts
  */
-static inline void falcon_irq_ack_a1(struct efx_nic *efx)
+inline void falcon_irq_ack_a1(struct efx_nic *efx)
 {
 	efx_dword_t reg;
 
@@ -1344,7 +1338,7 @@ static inline void falcon_irq_ack_a1(struct efx_nic *efx)
 /* Process a fatal interrupt
  * Disable bus mastering ASAP and schedule a reset
  */
-static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
+irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 	efx_oword_t *int_ker = efx->irq_status.addr;
@@ -1372,18 +1366,18 @@ static irqreturn_t falcon_fatal_interrupt(struct efx_nic *efx)
 
 	/* Disable both devices */
 	pci_clear_master(efx->pci_dev);
-	if (FALCON_IS_DUAL_FUNC(efx))
+	if (efx_nic_is_dual_func(efx))
 		pci_clear_master(nic_data->pci_dev2);
-	falcon_disable_interrupts(efx);
+	efx_nic_disable_interrupts(efx);
 
 	/* Count errors and reset or disable the NIC accordingly */
 	if (efx->int_error_count == 0 ||
 	    time_after(jiffies, efx->int_error_expire)) {
 		efx->int_error_count = 0;
 		efx->int_error_expire =
-			jiffies + FALCON_INT_ERROR_EXPIRE * HZ;
+			jiffies + EFX_INT_ERROR_EXPIRE * HZ;
 	}
-	if (++efx->int_error_count < FALCON_MAX_INT_ERRORS) {
+	if (++efx->int_error_count < EFX_MAX_INT_ERRORS) {
 		EFX_ERR(efx, "SYSTEM ERROR - reset scheduled\n");
 		efx_schedule_reset(efx, RESET_TYPE_INT_ERROR);
 	} else {
@@ -1395,10 +1389,10 @@ out:
 	return IRQ_HANDLED;
 }
 
-/* Handle a legacy interrupt from Falcon
+/* Handle a legacy interrupt
  * Acknowledges the interrupt and schedule event queue processing.
  */
-static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
+static irqreturn_t efx_legacy_interrupt(int irq, void *dev_id)
 {
 	struct efx_nic *efx = dev_id;
 	efx_oword_t *int_ker = efx->irq_status.addr;
@@ -1415,13 +1409,13 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 	/* Check to see if we have a serious error condition */
 	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
-		return falcon_fatal_interrupt(efx);
+		return efx_nic_fatal_interrupt(efx);
 
 	/* Schedule processing of any interrupting queues */
 	efx_for_each_channel(channel, efx) {
 		if ((queues & 1) ||
-		    falcon_event_present(
-			    falcon_event(channel, channel->eventq_read_ptr))) {
+		    efx_event_present(
+			    efx_event(channel, channel->eventq_read_ptr))) {
 			efx_schedule_channel(channel);
 			result = IRQ_HANDLED;
 		}
@@ -1438,7 +1432,7 @@ static irqreturn_t falcon_legacy_interrupt_b0(int irq, void *dev_id)
 }
 

-static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
+irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 {
 	struct efx_nic *efx = dev_id;
 	efx_oword_t *int_ker = efx->irq_status.addr;
@@ -1461,7 +1455,7 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	/* Check to see if we have a serious error condition */
 	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
-		return falcon_fatal_interrupt(efx);
+		return efx_nic_fatal_interrupt(efx);
 
 	/* Determine interrupting queues, clear interrupt status
 	 * register and acknowledge the device interrupt.
@@ -1484,14 +1478,14 @@ static irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/* Handle an MSI interrupt from Falcon
+/* Handle an MSI interrupt
  *
  * Handle an MSI hardware interrupt.  This routine schedules event
  * queue processing.  No interrupt acknowledgement cycle is necessary.
  * Also, we never need to check that the interrupt is for us, since
  * MSI interrupts cannot be shared.
  */
-static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
+static irqreturn_t efx_msi_interrupt(int irq, void *dev_id)
 {
 	struct efx_channel *channel = dev_id;
 	struct efx_nic *efx = channel->efx;
@@ -1505,7 +1499,7 @@ static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
 	/* Check to see if we have a serious error condition */
 	syserr = EFX_OWORD_FIELD(*int_ker, FSF_AZ_NET_IVEC_FATAL_INT);
 	if (unlikely(syserr))
-		return falcon_fatal_interrupt(efx);
+		return efx_nic_fatal_interrupt(efx);
 
 	/* Schedule processing of the channel */
 	efx_schedule_channel(channel);
@@ -1517,7 +1511,7 @@ static irqreturn_t falcon_msi_interrupt(int irq, void *dev_id)
 /* Setup RSS indirection table.
  * This maps from the hash value of the packet to RXQ
  */
-static void falcon_setup_rss_indir_table(struct efx_nic *efx)
+static void efx_setup_rss_indir_table(struct efx_nic *efx)
 {
 	int i = 0;
 	unsigned long offset;
@@ -1539,7 +1533,7 @@ static void falcon_setup_rss_indir_table(struct efx_nic *efx)
 /* Hook interrupt handler(s)
  * Try MSI and then legacy interrupts.
  */
-int falcon_init_interrupt(struct efx_nic *efx)
+int efx_nic_init_interrupt(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 	int rc;
@@ -1547,7 +1541,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	if (!EFX_INT_MODE_USE_MSI(efx)) {
 		irq_handler_t handler;
 		if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-			handler = falcon_legacy_interrupt_b0;
+			handler = efx_legacy_interrupt;
 		else
 			handler = falcon_legacy_interrupt_a1;
 
@@ -1563,7 +1557,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 
 	/* Hook MSI or MSI-X interrupt */
 	efx_for_each_channel(channel, efx) {
-		rc = request_irq(channel->irq, falcon_msi_interrupt,
+		rc = request_irq(channel->irq, efx_msi_interrupt,
 				 IRQF_PROBE_SHARED, /* Not shared */
 				 channel->name, channel);
 		if (rc) {
@@ -1581,7 +1575,7 @@ int falcon_init_interrupt(struct efx_nic *efx)
 	return rc;
 }
 
-void falcon_fini_interrupt(struct efx_nic *efx)
+void efx_nic_fini_interrupt(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
 	efx_oword_t reg;
@@ -2322,8 +2316,8 @@ static int falcon_probe_port(struct efx_nic *efx)
 		efx->wanted_fc = EFX_FC_RX;
 
 	/* Allocate buffer for stats */
-	rc = falcon_alloc_buffer(efx, &efx->stats_buffer,
-				 FALCON_MAC_STATS_SIZE);
+	rc = efx_nic_alloc_buffer(efx, &efx->stats_buffer,
+				  FALCON_MAC_STATS_SIZE);
 	if (rc)
 		return rc;
 	EFX_LOG(efx, "stats buffer at %llx (virt %p phys %llx)\n",
@@ -2336,7 +2330,7 @@ static int falcon_probe_port(struct efx_nic *efx)
 
 static void falcon_remove_port(struct efx_nic *efx)
 {
-	falcon_free_buffer(efx, &efx->stats_buffer);
+	efx_nic_free_buffer(efx, &efx->stats_buffer);
 }
 
 /**************************************************************************
@@ -2414,11 +2408,7 @@ static int falcon_test_nvram(struct efx_nic *efx)
 	return falcon_read_nvram(efx, NULL);
 }
 
-/* Registers tested in the falcon register test */
-static struct {
-	unsigned address;
-	efx_oword_t mask;
-} efx_test_registers[] = {
+static const struct efx_nic_register_test falcon_b0_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
 	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
 	{ FR_AZ_RX_CFG,
@@ -2464,7 +2454,9 @@ static bool efx_masked_compare_oword(const efx_oword_t *a, const efx_oword_t *b,
 		((a->u64[1] ^ b->u64[1]) & mask->u64[1]);
 }
 
-static int falcon_b0_test_registers(struct efx_nic *efx)
+int efx_nic_test_registers(struct efx_nic *efx,
+			   const struct efx_nic_register_test *regs,
+			   size_t n_regs)
 {
 	unsigned address = 0, i, j;
 	efx_oword_t mask, imask, original, reg, buf;
@@ -2472,9 +2464,9 @@ static int falcon_b0_test_registers(struct efx_nic *efx)
 	/* Falcon should be in loopback to isolate the XMAC from the PHY */
 	WARN_ON(!LOOPBACK_INTERNAL(efx));
 
-	for (i = 0; i < ARRAY_SIZE(efx_test_registers); ++i) {
-		address = efx_test_registers[i].address;
-		mask = imask = efx_test_registers[i].mask;
+	for (i = 0; i < n_regs; ++i) {
+		address = regs[i].address;
+		mask = imask = regs[i].mask;
 		EFX_INVERT_OWORD(imask);
 
 		efx_reado(efx, &original, address);
@@ -2517,6 +2509,12 @@ fail:
 	return -EIO;
 }
 
+static int falcon_b0_test_registers(struct efx_nic *efx)
+{
+	return efx_nic_test_registers(efx, falcon_b0_register_tests,
+				      ARRAY_SIZE(falcon_b0_register_tests));
+}
+
 /**************************************************************************
  *
  * Device reset
@@ -2542,7 +2540,7 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 				"function prior to hardware reset\n");
 			goto fail1;
 		}
-		if (FALCON_IS_DUAL_FUNC(efx)) {
+		if (efx_nic_is_dual_func(efx)) {
 			rc = pci_save_state(nic_data->pci_dev2);
 			if (rc) {
 				EFX_ERR(efx, "failed to backup PCI state of "
@@ -2577,7 +2575,7 @@ static int falcon_reset_hw(struct efx_nic *efx, enum reset_type method)
 
 	/* Restore PCI configuration if needed */
 	if (method == RESET_TYPE_WORLD) {
-		if (FALCON_IS_DUAL_FUNC(efx)) {
+		if (efx_nic_is_dual_func(efx)) {
 			rc = pci_restore_state(nic_data->pci_dev2);
 			if (rc) {
 				EFX_ERR(efx, "failed to restore PCI config for "
@@ -2800,16 +2798,22 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	return rc;
 }
 
+u32 efx_nic_fpga_ver(struct efx_nic *efx)
+{
+	efx_oword_t altera_build;
+
+	efx_reado(efx, &altera_build, FR_AZ_ALTERA_BUILD);
+	return EFX_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER);
+}
+
 /* Probe the NIC variant (revision, ASIC vs FPGA, function count, port
  * count, port speed).  Set workaround and feature flags accordingly.
  */
 static int falcon_probe_nic_variant(struct efx_nic *efx)
 {
-	efx_oword_t altera_build;
 	efx_oword_t nic_stat;
 
-	efx_reado(efx, &altera_build, FR_AZ_ALTERA_BUILD);
-	if (EFX_OWORD_FIELD(altera_build, FRF_AZ_ALTERA_BUILD_VER)) {
+	if (efx_nic_fpga_ver(efx) != 0) {
 		EFX_ERR(efx, "Falcon FPGA not supported\n");
 		return -ENODEV;
 	}
@@ -2893,7 +2897,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 		goto fail1;
 
 	/* Probe secondary function if expected */
-	if (FALCON_IS_DUAL_FUNC(efx)) {
+	if (efx_nic_is_dual_func(efx)) {
 		struct pci_dev *dev = pci_dev_get(efx->pci_dev);
 
 		while ((dev = pci_get_device(EFX_VENDID_SFC, FALCON_A_S_DEVID,
@@ -2919,7 +2923,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	}
 
 	/* Allocate memory for INT_KER */
-	rc = falcon_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
+	rc = efx_nic_alloc_buffer(efx, &efx->irq_status, sizeof(efx_oword_t));
 	if (rc)
 		goto fail4;
 	BUG_ON(efx->irq_status.dma_addr & 0x0f);
@@ -2965,7 +2969,7 @@ static int falcon_probe_nic(struct efx_nic *efx)
 	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
  fail5:
 	falcon_remove_spi_devices(efx);
-	falcon_free_buffer(efx, &efx->irq_status);
+	efx_nic_free_buffer(efx, &efx->irq_status);
  fail4:
  fail3:
 	if (nic_data->pci_dev2) {
@@ -2988,8 +2992,8 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	const unsigned ctrl_xon_thr = 20;
 	const unsigned ctrl_xoff_thr = 25;
 	/* RX data FIFO thresholds (256-byte units; size varies) */
-	int data_xon_thr = rx_xon_thresh_bytes >> 8;
-	int data_xoff_thr = rx_xoff_thresh_bytes >> 8;
+	int data_xon_thr = efx_nic_rx_xon_thresh >> 8;
+	int data_xoff_thr = efx_nic_rx_xoff_thresh >> 8;
 	efx_oword_t reg;
 
 	efx_reado(efx, &reg, FR_AZ_RX_CFG);
@@ -3027,33 +3031,9 @@ static void falcon_init_rx_cfg(struct efx_nic *efx)
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 }
 
-/* This call performs hardware-specific global initialisation, such as
- * defining the descriptor cache sizes and number of RSS channels.
- * It does not set up any buffers, descriptor rings or event queues.
- */
-static int falcon_init_nic(struct efx_nic *efx)
+void efx_nic_init_common(struct efx_nic *efx)
 {
 	efx_oword_t temp;
-	int rc;
-
-	/* Use on-chip SRAM */
-	efx_reado(efx, &temp, FR_AB_NIC_STAT);
-	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
-	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
-
-	/* Set the source of the GMAC clock */
-	if (efx_nic_rev(efx) == EFX_REV_FALCON_B0) {
-		efx_reado(efx, &temp, FR_AB_GPIO_CTL);
-		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
-		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
-	}
-
-	/* Select the correct MAC */
-	falcon_clock_mac(efx);
-
-	rc = falcon_reset_sram(efx);
-	if (rc)
-		return rc;
 
 	/* Set positions of descriptor caches in SRAM. */
 	EFX_POPULATE_OWORD_1(temp, FRF_AZ_SRM_TX_DC_BASE_ADR,
@@ -3084,15 +3064,6 @@ static int falcon_init_nic(struct efx_nic *efx)
 			     FRF_AZ_INT_ADR_KER, efx->irq_status.dma_addr);
 	efx_writeo(efx, &temp, FR_AZ_INT_ADR_KER);
 
-	/* Clear the parity enables on the TX data fifos as
-	 * they produce false parity errors because of timing issues
-	 */
-	if (EFX_WORKAROUND_5129(efx)) {
-		efx_reado(efx, &temp, FR_AZ_CSR_SPARE);
-		EFX_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
-		efx_writeo(efx, &temp, FR_AZ_CSR_SPARE);
-	}
-
 	/* Enable all the genuinely fatal interrupts.  (They are still
 	 * masked by the overall interrupt mask, controlled by
 	 * falcon_interrupts()).
@@ -3106,6 +3077,64 @@ static int falcon_init_nic(struct efx_nic *efx)
 	EFX_INVERT_OWORD(temp);
 	efx_writeo(efx, &temp, FR_AZ_FATAL_INTR_KER);
 
+	efx_setup_rss_indir_table(efx);
+
+	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
+	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
+	 */
+	efx_reado(efx, &temp, FR_AZ_TX_RESERVED);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 0);
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_DIS_NON_IP_EV, 1);
+	/* Enable SW_EV to inherit in char driver - assume harmless here */
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
+	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
+	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
+	/* Squash TX of packets of 16 bytes or less */
+	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
+		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
+	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
+}
+
+/* This call performs hardware-specific global initialisation, such as
+ * defining the descriptor cache sizes and number of RSS channels.
+ * It does not set up any buffers, descriptor rings or event queues.
+ */
+static int falcon_init_nic(struct efx_nic *efx)
+{
+	efx_oword_t temp;
+	int rc;
+
+	/* Use on-chip SRAM */
+	efx_reado(efx, &temp, FR_AB_NIC_STAT);
+	EFX_SET_OWORD_FIELD(temp, FRF_AB_ONCHIP_SRAM, 1);
+	efx_writeo(efx, &temp, FR_AB_NIC_STAT);
+
+	/* Set the source of the GMAC clock */
+	if (efx_nic_rev(efx) == EFX_REV_FALCON_B0) {
+		efx_reado(efx, &temp, FR_AB_GPIO_CTL);
+		EFX_SET_OWORD_FIELD(temp, FRF_AB_USE_NIC_CLK, true);
+		efx_writeo(efx, &temp, FR_AB_GPIO_CTL);
+	}
+
+	/* Select the correct MAC */
+	falcon_clock_mac(efx);
+
+	rc = falcon_reset_sram(efx);
+	if (rc)
+		return rc;
+
+	/* Clear the parity enables on the TX data fifos as
+	 * they produce false parity errors because of timing issues
+	 */
+	if (EFX_WORKAROUND_5129(efx)) {
+		efx_reado(efx, &temp, FR_AZ_CSR_SPARE);
+		EFX_SET_OWORD_FIELD(temp, FRF_AB_MEM_PERR_EN_TX_DATA, 0);
+		efx_writeo(efx, &temp, FR_AZ_CSR_SPARE);
+	}
+
 	if (EFX_WORKAROUND_7244(efx)) {
 		efx_reado(efx, &temp, FR_BZ_RX_FILTER_CTL);
 		EFX_SET_OWORD_FIELD(temp, FRF_BZ_UDP_FULL_SRCH_LIMIT, 8);
@@ -3115,8 +3144,6 @@ static int falcon_init_nic(struct efx_nic *efx)
 		efx_writeo(efx, &temp, FR_BZ_RX_FILTER_CTL);
 	}
 
-	falcon_setup_rss_indir_table(efx);
-
 	/* XXX This is documented only for Falcon A0/A1 */
 	/* Setup RX.  Wait for descriptor is broken and must
 	 * be disabled.  RXDP recovery shouldn't be needed, but is.
@@ -3128,24 +3155,6 @@ static int falcon_init_nic(struct efx_nic *efx)
 		EFX_SET_OWORD_FIELD(temp, FRF_AA_RX_ISCSI_DIS, 1);
 	efx_writeo(efx, &temp, FR_AA_RX_SELF_RST);
 
-	/* Disable the ugly timer-based TX DMA backoff and allow TX DMA to be
-	 * controlled by the RX FIFO fill level. Set arbitration to one pkt/Q.
-	 */
-	efx_reado(efx, &temp, FR_AZ_TX_RESERVED);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER, 0xfe);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_RX_SPACER_EN, 1);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_ONE_PKT_PER_Q, 1);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PUSH_EN, 0);
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_DIS_NON_IP_EV, 1);
-	/* Enable SW_EV to inherit in char driver - assume harmless here */
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_SOFT_EVT_EN, 1);
-	/* Prefetch threshold 2 => fetch when descriptor cache half empty */
-	EFX_SET_OWORD_FIELD(temp, FRF_AZ_TX_PREF_THRESHOLD, 2);
-	/* Squash TX of packets of 16 bytes or less */
-	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0)
-		EFX_SET_OWORD_FIELD(temp, FRF_BZ_TX_FLUSH_MIN_LEN_EN, 1);
-	efx_writeo(efx, &temp, FR_AZ_TX_RESERVED);
-
 	/* Do not enable TX_NO_EOP_DISC_EN, since it limits packets to 16
 	 * descriptors (which is bad).
 	 */
@@ -3161,6 +3170,8 @@ static int falcon_init_nic(struct efx_nic *efx)
 		efx_writeo(efx, &temp, FR_BZ_DP_CTRL);
 	}
 
+	efx_nic_init_common(efx);
+
 	return 0;
 }
 
@@ -3178,7 +3189,7 @@ static void falcon_remove_nic(struct efx_nic *efx)
 	memset(&board->i2c_adap, 0, sizeof(board->i2c_adap));
 
 	falcon_remove_spi_devices(efx);
-	falcon_free_buffer(efx, &efx->irq_status);
+	efx_nic_free_buffer(efx, &efx->irq_status);
 
 	falcon_reset_hw(efx, RESET_TYPE_ALL);
 
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 464c274..875b58e 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -30,6 +30,14 @@ static inline int efx_nic_rev(struct efx_nic *efx)
 	return efx->type->revision;
 }
 
+extern u32 efx_nic_fpga_ver(struct efx_nic *efx);
+
+/* NIC has two interlinked PCI functions for the same port. */
+static inline bool efx_nic_is_dual_func(struct efx_nic *efx)
+{
+	return efx_nic_rev(efx) < EFX_REV_FALCON_B0;
+}
+
 /**
  * struct falcon_board_type - board operations and type information
  * @id: Board type id, as found in NVRAM
@@ -108,49 +116,65 @@ extern struct efx_nic_type falcon_b0_nic_type;
 extern void falcon_probe_board(struct efx_nic *efx, u16 revision_info);
 
 /* TX data path */
-extern int falcon_probe_tx(struct efx_tx_queue *tx_queue);
-extern void falcon_init_tx(struct efx_tx_queue *tx_queue);
-extern void falcon_fini_tx(struct efx_tx_queue *tx_queue);
-extern void falcon_remove_tx(struct efx_tx_queue *tx_queue);
-extern void falcon_push_buffers(struct efx_tx_queue *tx_queue);
+extern int efx_nic_probe_tx(struct efx_tx_queue *tx_queue);
+extern void efx_nic_init_tx(struct efx_tx_queue *tx_queue);
+extern void efx_nic_fini_tx(struct efx_tx_queue *tx_queue);
+extern void efx_nic_remove_tx(struct efx_tx_queue *tx_queue);
+extern void efx_nic_push_buffers(struct efx_tx_queue *tx_queue);
 
 /* RX data path */
-extern int falcon_probe_rx(struct efx_rx_queue *rx_queue);
-extern void falcon_init_rx(struct efx_rx_queue *rx_queue);
-extern void falcon_fini_rx(struct efx_rx_queue *rx_queue);
-extern void falcon_remove_rx(struct efx_rx_queue *rx_queue);
-extern void falcon_notify_rx_desc(struct efx_rx_queue *rx_queue);
+extern int efx_nic_probe_rx(struct efx_rx_queue *rx_queue);
+extern void efx_nic_init_rx(struct efx_rx_queue *rx_queue);
+extern void efx_nic_fini_rx(struct efx_rx_queue *rx_queue);
+extern void efx_nic_remove_rx(struct efx_rx_queue *rx_queue);
+extern void efx_nic_notify_rx_desc(struct efx_rx_queue *rx_queue);
 
 /* Event data path */
-extern int falcon_probe_eventq(struct efx_channel *channel);
-extern void falcon_init_eventq(struct efx_channel *channel);
-extern void falcon_fini_eventq(struct efx_channel *channel);
-extern void falcon_remove_eventq(struct efx_channel *channel);
-extern int falcon_process_eventq(struct efx_channel *channel, int rx_quota);
-extern void falcon_eventq_read_ack(struct efx_channel *channel);
+extern int efx_nic_probe_eventq(struct efx_channel *channel);
+extern void efx_nic_init_eventq(struct efx_channel *channel);
+extern void efx_nic_fini_eventq(struct efx_channel *channel);
+extern void efx_nic_remove_eventq(struct efx_channel *channel);
+extern int efx_nic_process_eventq(struct efx_channel *channel, int rx_quota);
+extern void efx_nic_eventq_read_ack(struct efx_channel *channel);
 
 /* MAC/PHY */
 extern void falcon_drain_tx_fifo(struct efx_nic *efx);
 extern void falcon_reconfigure_mac_wrapper(struct efx_nic *efx);
+extern int efx_nic_rx_xoff_thresh, efx_nic_rx_xon_thresh;
 
 /* Interrupts and test events */
-extern int falcon_init_interrupt(struct efx_nic *efx);
-extern void falcon_enable_interrupts(struct efx_nic *efx);
-extern void falcon_generate_test_event(struct efx_channel *channel,
-				       unsigned int magic);
-extern void falcon_generate_interrupt(struct efx_nic *efx);
-extern void falcon_disable_interrupts(struct efx_nic *efx);
-extern void falcon_fini_interrupt(struct efx_nic *efx);
-
-#define FALCON_IRQ_MOD_RESOLUTION 5
+extern int efx_nic_init_interrupt(struct efx_nic *efx);
+extern void efx_nic_enable_interrupts(struct efx_nic *efx);
+extern void efx_nic_generate_test_event(struct efx_channel *channel,
+					unsigned int magic);
+extern void efx_nic_generate_interrupt(struct efx_nic *efx);
+extern void efx_nic_disable_interrupts(struct efx_nic *efx);
+extern void efx_nic_fini_interrupt(struct efx_nic *efx);
+extern irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx);
+extern irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id);
+extern void falcon_irq_ack_a1(struct efx_nic *efx);
+
+#define EFX_IRQ_MOD_RESOLUTION 5
 
 /* Global Resources */
-extern int falcon_flush_queues(struct efx_nic *efx);
+extern int efx_nic_flush_queues(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
+extern void efx_nic_init_common(struct efx_nic *efx);
+
+int efx_nic_alloc_buffer(struct efx_nic *efx, struct efx_buffer *buffer,
+			 unsigned int len);
+void efx_nic_free_buffer(struct efx_nic *efx, struct efx_buffer *buffer);
 
 /* Tests */
+struct efx_nic_register_test {
+	unsigned address;
+	efx_oword_t mask;
+};
+extern int efx_nic_test_registers(struct efx_nic *efx,
+				  const struct efx_nic_register_test *regs,
+				  size_t n_regs);
 
 /**************************************************************************
  *
@@ -186,8 +210,8 @@ extern int falcon_reset_xaui(struct efx_nic *efx);
 #define MAC_DATA_LBN 0
 #define MAC_DATA_WIDTH 32
 
-extern void falcon_generate_event(struct efx_channel *channel,
-				  efx_qword_t *event);
+extern void efx_nic_generate_event(struct efx_channel *channel,
+				   efx_qword_t *event);
 
 extern void falcon_poll_xmac(struct efx_nic *efx);
 
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index accf055..8fffd37 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -341,7 +341,7 @@ static int __efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue,
 
  out:
 	/* Send write pointer to card. */
-	falcon_notify_rx_desc(rx_queue);
+	efx_nic_notify_rx_desc(rx_queue);
 
 	/* If the fast fill is running inside from the refill tasklet, then
 	 * for SMP systems it may be running on a different CPU to
@@ -640,7 +640,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 	if (!rx_queue->buffer)
 		return -ENOMEM;
 
-	rc = falcon_probe_rx(rx_queue);
+	rc = efx_nic_probe_rx(rx_queue);
 	if (rc) {
 		kfree(rx_queue->buffer);
 		rx_queue->buffer = NULL;
@@ -671,7 +671,7 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	rx_queue->fast_fill_limit = limit;
 
 	/* Set up RX descriptor ring */
-	falcon_init_rx(rx_queue);
+	efx_nic_init_rx(rx_queue);
 }
 
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
@@ -681,7 +681,7 @@ void efx_fini_rx_queue(struct efx_rx_queue *rx_queue)
 
 	EFX_LOG(rx_queue->efx, "shutting down RX queue %d\n", rx_queue->queue);
 
-	falcon_fini_rx(rx_queue);
+	efx_nic_fini_rx(rx_queue);
 
 	/* Release RX buffers NB start at index 0 not current HW ptr */
 	if (rx_queue->buffer) {
@@ -706,7 +706,7 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	EFX_LOG(rx_queue->efx, "destroying RX queue %d\n", rx_queue->queue);
 
-	falcon_remove_rx(rx_queue);
+	efx_nic_remove_rx(rx_queue);
 
 	kfree(rx_queue->buffer);
 	rx_queue->buffer = NULL;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index fa56e2e..9a24053 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -164,7 +164,7 @@ static int efx_test_interrupts(struct efx_nic *efx,
 			goto success;
 	}
 
-	falcon_generate_interrupt(efx);
+	efx_nic_generate_interrupt(efx);
 
 	/* Wait for arrival of test interrupt. */
 	EFX_LOG(efx, "waiting for test interrupt\n");
@@ -202,7 +202,7 @@ static int efx_test_eventq_irq(struct efx_channel *channel,
 	channel->eventq_magic = 0;
 	smp_wmb();
 
-	falcon_generate_test_event(channel, magic);
+	efx_nic_generate_test_event(channel, magic);
 
 	/* Wait for arrival of interrupt */
 	count = 0;
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index c54fa30..2531d02 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -278,7 +278,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	buffer->continuation = false;
 
 	/* Pass off to hardware */
-	falcon_push_buffers(tx_queue);
+	efx_nic_push_buffers(tx_queue);
 
 	return NETDEV_TX_OK;
 
@@ -426,7 +426,7 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 		tx_queue->buffer[i].continuation = true;
 
 	/* Allocate hardware ring */
-	rc = falcon_probe_tx(tx_queue);
+	rc = efx_nic_probe_tx(tx_queue);
 	if (rc)
 		goto fail;
 
@@ -449,7 +449,7 @@ void efx_init_tx_queue(struct efx_tx_queue *tx_queue)
 	BUG_ON(tx_queue->stopped);
 
 	/* Set up TX descriptor ring */
-	falcon_init_tx(tx_queue);
+	efx_nic_init_tx(tx_queue);
 }
 
 void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
@@ -475,7 +475,7 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 	EFX_LOG(tx_queue->efx, "shutting down TX queue %d\n", tx_queue->queue);
 
 	/* Flush TX queue, remove descriptor ring */
-	falcon_fini_tx(tx_queue);
+	efx_nic_fini_tx(tx_queue);
 
 	efx_release_tx_buffers(tx_queue);
 
@@ -492,7 +492,7 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	EFX_LOG(tx_queue->efx, "destroying TX queue %d\n", tx_queue->queue);
-	falcon_remove_tx(tx_queue);
+	efx_nic_remove_tx(tx_queue);
 
 	kfree(tx_queue->buffer);
 	tx_queue->buffer = NULL;
@@ -1078,7 +1078,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	}
 
 	/* Pass off to hardware */
-	falcon_push_buffers(tx_queue);
+	efx_nic_push_buffers(tx_queue);
 
 	tx_queue->tso_bursts++;
 	return NETDEV_TX_OK;
-- 
1.6.5.3



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

