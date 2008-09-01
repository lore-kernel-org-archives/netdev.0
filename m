From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 46/52] sfc: Make queue flushes more reliable
Date: Mon, 1 Sep 2008 12:49:37 +0100
Message-ID: <20080901114936.GM7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:33609 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759325AbYIALtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:40 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the potential retry count for RX flushes from 5 to 100.

Stop polling the RX_DESC_PTR_TBL to infer that a flush might have
happened. Instead absolutely rely on the flush events, unless bug 7803
applies (Falcon rev A only).

To keep things quick, request flushes for every TX and RX queue up
front, and match up the events to requests.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   15 ++--
 drivers/net/sfc/falcon.c     |  247 ++++++++++++++++++++++--------------------
 drivers/net/sfc/falcon.h     |    1 +
 drivers/net/sfc/net_driver.h |    4 +
 4 files changed, 141 insertions(+), 126 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index ef72413..8e699a4 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -445,10 +445,17 @@ static void efx_fini_channels(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
+	rc = falcon_flush_queues(efx);
+	if (rc)
+		EFX_ERR(efx, "failed to flush queues\n");
+	else
+		EFX_LOG(efx, "successfully flushed all queues\n");
+
 	efx_for_each_channel(channel, efx) {
 		EFX_LOG(channel->efx, "shut down chan %d\n", channel->channel);
 
@@ -456,13 +463,6 @@ static void efx_fini_channels(struct efx_nic *efx)
 			efx_fini_rx_queue(rx_queue);
 		efx_for_each_channel_tx_queue(tx_queue, channel)
 			efx_fini_tx_queue(tx_queue);
-	}
-
-	/* Do the event queues last so that we can handle flush events
-	 * for all DMA queues. */
-	efx_for_each_channel(channel, efx) {
-		EFX_LOG(channel->efx, "shut down evq %d\n", channel->channel);
-
 		efx_fini_eventq(channel);
 	}
 }
@@ -1092,7 +1092,6 @@ static void efx_stop_all(struct efx_nic *efx)
 
 	/* Isolate the MAC from the TX and RX engines, so that queue
 	 * flushes will complete in a timely fashion. */
-	falcon_deconfigure_mac_wrapper(efx);
 	falcon_drain_tx_fifo(efx);
 
 	/* Stop the kernel transmit interface late, so the watchdog
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ad192f8..70c681e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -108,10 +108,10 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Max number of internal errors. After this resets will not be performed */
 #define FALCON_MAX_INT_ERRORS 4
 
-/* Maximum period that we wait for flush events. If the flush event
- * doesn't arrive in this period of time then we check if the queue
- * was disabled anyway. */
-#define FALCON_FLUSH_TIMEOUT 10 /* 10ms */
+/* We poll for events every FLUSH_INTERVAL ms, and check FLUSH_POLL_COUNT times
+ */
+#define FALCON_FLUSH_INTERVAL 10
+#define FALCON_FLUSH_POLL_COUNT 100
 
 /**************************************************************************
  *
@@ -452,6 +452,8 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
 
+	tx_queue->flushed = false;
+
 	/* Pin TX descriptor ring */
 	falcon_init_special_buffer(efx, &tx_queue->txd);
 
@@ -492,60 +494,16 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	}
 }
 
-static int falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
+static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
-	struct efx_channel *channel = &efx->channel[0];
 	efx_oword_t tx_flush_descq;
-	unsigned int read_ptr, i;
 
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     TX_FLUSH_DESCQ_CMD, 1,
 			     TX_FLUSH_DESCQ, tx_queue->queue);
 	falcon_write(efx, &tx_flush_descq, TX_FLUSH_DESCQ_REG_KER);
-	msleep(FALCON_FLUSH_TIMEOUT);
-
-	if (EFX_WORKAROUND_7803(efx))
-		return 0;
-
-	/* Look for a flush completed event */
-	read_ptr = channel->eventq_read_ptr;
-	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
-		efx_qword_t *event = falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue;
-		if (!falcon_event_present(event))
-			break;
-
-		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
-		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		ev_queue = EFX_QWORD_FIELD(*event, DRIVER_EV_TX_DESCQ_ID);
-		if ((ev_sub_code == TX_DESCQ_FLS_DONE_EV_DECODE) &&
-		    (ev_queue == tx_queue->queue)) {
-			EFX_LOG(efx, "tx queue %d flush command succesful\n",
-				tx_queue->queue);
-			return 0;
-		}
-
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
-	}
-
-	if (EFX_WORKAROUND_11557(efx)) {
-		efx_oword_t reg;
-		bool enabled;
-
-		falcon_read_table(efx, &reg, efx->type->txd_ptr_tbl_base,
-				  tx_queue->queue);
-		enabled = EFX_OWORD_FIELD(reg, TX_DESCQ_EN);
-		if (!enabled) {
-			EFX_LOG(efx, "tx queue %d disabled without a "
-				"flush event seen\n", tx_queue->queue);
-			return 0;
-		}
-	}
-
-	EFX_ERR(efx, "tx queue %d flush command timed out\n", tx_queue->queue);
-	return -ETIMEDOUT;
 }
 
 void falcon_fini_tx(struct efx_tx_queue *tx_queue)
@@ -553,9 +511,8 @@ void falcon_fini_tx(struct efx_tx_queue *tx_queue)
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_desc_ptr;
 
-	/* Stop the hardware using the queue */
-	if (falcon_flush_tx_queue(tx_queue))
-		EFX_ERR(efx, "failed to flush tx queue %d\n", tx_queue->queue);
+	/* The queue should have been flushed */
+	WARN_ON(!tx_queue->flushed);
 
 	/* Remove TX descriptor ring from card */
 	EFX_ZERO_OWORD(tx_desc_ptr);
@@ -643,6 +600,8 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 		rx_queue->queue, rx_queue->rxd.index,
 		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
+	rx_queue->flushed = false;
+
 	/* Pin RX descriptor ring */
 	falcon_init_special_buffer(efx, &rx_queue->rxd);
 
@@ -663,11 +622,9 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 			   rx_queue->queue);
 }
 
-static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
+static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	struct efx_channel *channel = &efx->channel[0];
-	unsigned int read_ptr, i;
 	efx_oword_t rx_flush_descq;
 
 	/* Post a flush command */
@@ -675,76 +632,15 @@ static int falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 			     RX_FLUSH_DESCQ_CMD, 1,
 			     RX_FLUSH_DESCQ, rx_queue->queue);
 	falcon_write(efx, &rx_flush_descq, RX_FLUSH_DESCQ_REG_KER);
-	msleep(FALCON_FLUSH_TIMEOUT);
-
-	if (EFX_WORKAROUND_7803(efx))
-		return 0;
-
-	/* Look for a flush completed event */
-	read_ptr = channel->eventq_read_ptr;
-	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
-		efx_qword_t *event = falcon_event(channel, read_ptr);
-		int ev_code, ev_sub_code, ev_queue;
-		bool ev_failed;
-		if (!falcon_event_present(event))
-			break;
-
-		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
-		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
-		ev_queue = EFX_QWORD_FIELD(*event, DRIVER_EV_RX_DESCQ_ID);
-		ev_failed = EFX_QWORD_FIELD(*event, DRIVER_EV_RX_FLUSH_FAIL);
-
-		if ((ev_sub_code == RX_DESCQ_FLS_DONE_EV_DECODE) &&
-		    (ev_queue == rx_queue->queue)) {
-			if (ev_failed) {
-				EFX_INFO(efx, "rx queue %d flush command "
-					 "failed\n", rx_queue->queue);
-				return -EAGAIN;
-			} else {
-				EFX_LOG(efx, "rx queue %d flush command "
-					"succesful\n", rx_queue->queue);
-				return 0;
-			}
-		}
-
-		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
-	}
-
-	if (EFX_WORKAROUND_11557(efx)) {
-		efx_oword_t reg;
-		bool enabled;
-
-		falcon_read_table(efx, &reg, efx->type->rxd_ptr_tbl_base,
-				  rx_queue->queue);
-		enabled = EFX_OWORD_FIELD(reg, RX_DESCQ_EN);
-		if (!enabled) {
-			EFX_LOG(efx, "rx queue %d disabled without a "
-				"flush event seen\n", rx_queue->queue);
-			return 0;
-		}
-	}
-
-	EFX_ERR(efx, "rx queue %d flush command timed out\n", rx_queue->queue);
-	return -ETIMEDOUT;
 }
 
 void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 {
 	efx_oword_t rx_desc_ptr;
 	struct efx_nic *efx = rx_queue->efx;
-	int i, rc;
 
-	/* Try and flush the rx queue. This may need to be repeated */
-	for (i = 0; i < 5; i++) {
-		rc = falcon_flush_rx_queue(rx_queue);
-		if (rc == -EAGAIN)
-			continue;
-		break;
-	}
-	if (rc) {
-		EFX_ERR(efx, "failed to flush rx queue %d\n", rx_queue->queue);
-		efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
-	}
+	/* The queue should already have been flushed */
+	WARN_ON(!rx_queue->flushed);
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
@@ -1255,6 +1151,121 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
 	falcon_generate_event(channel, &test_event);
 }
 
+/**************************************************************************
+ *
+ * Flush handling
+ *
+ **************************************************************************/
+
+
+static void falcon_poll_flush_events(struct efx_nic *efx)
+{
+	struct efx_channel *channel = &efx->channel[0];
+	struct efx_tx_queue *tx_queue;
+	struct efx_rx_queue *rx_queue;
+	unsigned int read_ptr, i;
+
+	read_ptr = channel->eventq_read_ptr;
+	for (i = 0; i < FALCON_EVQ_SIZE; ++i) {
+		efx_qword_t *event = falcon_event(channel, read_ptr);
+		int ev_code, ev_sub_code, ev_queue;
+		bool ev_failed;
+		if (!falcon_event_present(event))
+			break;
+
+		ev_code = EFX_QWORD_FIELD(*event, EV_CODE);
+		if (ev_code != DRIVER_EV_DECODE)
+			continue;
+
+		ev_sub_code = EFX_QWORD_FIELD(*event, DRIVER_EV_SUB_CODE);
+		switch (ev_sub_code) {
+		case TX_DESCQ_FLS_DONE_EV_DECODE:
+			ev_queue = EFX_QWORD_FIELD(*event,
+						   DRIVER_EV_TX_DESCQ_ID);
+			if (ev_queue < EFX_TX_QUEUE_COUNT) {
+				tx_queue = efx->tx_queue + ev_queue;
+				tx_queue->flushed = true;
+			}
+			break;
+		case RX_DESCQ_FLS_DONE_EV_DECODE:
+			ev_queue = EFX_QWORD_FIELD(*event,
+						   DRIVER_EV_RX_DESCQ_ID);
+			ev_failed = EFX_QWORD_FIELD(*event,
+						    DRIVER_EV_RX_FLUSH_FAIL);
+			if (ev_queue < efx->n_rx_queues) {
+				rx_queue = efx->rx_queue + ev_queue;
+
+				/* retry the rx flush */
+				if (ev_failed)
+					falcon_flush_rx_queue(rx_queue);
+				else
+					rx_queue->flushed = true;
+			}
+			break;
+		}
+
+		read_ptr = (read_ptr + 1) & FALCON_EVQ_MASK;
+	}
+}
+
+/* Handle tx and rx flushes at the same time, since they run in
+ * parallel in the hardware and there's no reason for us to
+ * serialise them */
+int falcon_flush_queues(struct efx_nic *efx)
+{
+	struct efx_rx_queue *rx_queue;
+	struct efx_tx_queue *tx_queue;
+	int i;
+	bool outstanding;
+
+	/* Issue flush requests */
+	efx_for_each_tx_queue(tx_queue, efx) {
+		tx_queue->flushed = false;
+		falcon_flush_tx_queue(tx_queue);
+	}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		rx_queue->flushed = false;
+		falcon_flush_rx_queue(rx_queue);
+	}
+
+	/* Poll the evq looking for flush completions. Since we're not pushing
+	 * any more rx or tx descriptors at this point, we're in no danger of
+	 * overflowing the evq whilst we wait */
+	for (i = 0; i < FALCON_FLUSH_POLL_COUNT; ++i) {
+		msleep(FALCON_FLUSH_INTERVAL);
+		falcon_poll_flush_events(efx);
+
+		/* Check if every queue has been succesfully flushed */
+		outstanding = false;
+		efx_for_each_tx_queue(tx_queue, efx)
+			outstanding |= !tx_queue->flushed;
+		efx_for_each_rx_queue(rx_queue, efx)
+			outstanding |= !rx_queue->flushed;
+		if (!outstanding)
+			return 0;
+	}
+
+	/* Mark the queues as all flushed. We're going to return failure
+	 * leading to a reset, or fake up success anyway. "flushed" now
+	 * indicates that we tried to flush. */
+	efx_for_each_tx_queue(tx_queue, efx) {
+		if (!tx_queue->flushed)
+			EFX_ERR(efx, "tx queue %d flush command timed out\n",
+				tx_queue->queue);
+		tx_queue->flushed = true;
+	}
+	efx_for_each_rx_queue(rx_queue, efx) {
+		if (!rx_queue->flushed)
+			EFX_ERR(efx, "rx queue %d flush command timed out\n",
+				rx_queue->queue);
+		rx_queue->flushed = true;
+	}
+
+	if (EFX_WORKAROUND_7803(efx))
+		return 0;
+
+	return -ETIMEDOUT;
+}
 
 /**************************************************************************
  *
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 30d61e4..be025ba 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -86,6 +86,7 @@ extern void falcon_fini_interrupt(struct efx_nic *efx);
 extern int falcon_probe_nic(struct efx_nic *efx);
 extern int falcon_probe_resources(struct efx_nic *efx);
 extern int falcon_init_nic(struct efx_nic *efx);
+extern int falcon_flush_queues(struct efx_nic *efx);
 extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
 extern void falcon_remove_resources(struct efx_nic *efx);
 extern void falcon_remove_nic(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index be3d2ba..868ad1e 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -160,6 +160,7 @@ struct efx_tx_buffer {
  * @channel: The associated channel
  * @buffer: The software buffer ring
  * @txd: The hardware descriptor ring
+ * @flushed: Used when handling queue flushing
  * @read_count: Current read pointer.
  *	This is the number of buffers that have been removed from both rings.
  * @stopped: Stopped count.
@@ -192,6 +193,7 @@ struct efx_tx_queue {
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
+	bool flushed;
 
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
@@ -260,6 +262,7 @@ struct efx_rx_buffer {
  *	the remaining space in the allocation.
  * @buf_dma_addr: Page's DMA address.
  * @buf_data: Page's host address.
+ * @flushed: Use when handling queue flushing
  */
 struct efx_rx_queue {
 	struct efx_nic *efx;
@@ -285,6 +288,7 @@ struct efx_rx_queue {
 	struct page *buf_page;
 	dma_addr_t buf_dma_addr;
 	char *buf_data;
+	bool flushed;
 };
 
 /**
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

