From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/16] sfc: Fix bugs in RX queue flushing
Date: Thu, 26 Nov 2009 02:09:55 +0000
Message-ID: <1259201395.2806.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31191 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbZKZCJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid overrunning the hardware limit of 4 concurrent RX queue flushes.
Expand the queue flush state to support this.  Make similar changes to
TX flushing to keep the code symmetric.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |  103 ++++++++++++++++++++++++++----------------
 drivers/net/sfc/net_driver.h |   11 ++++-
 2 files changed, 73 insertions(+), 41 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 2f1f1fc..e1b9ce3 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -109,6 +109,9 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
 /* Size and alignment of special buffers (4KB) */
 #define FALCON_BUF_SIZE 4096
 
+/* Depth of RX flush request fifo */
+#define FALCON_RX_FLUSH_COUNT 4
+
 #define FALCON_IS_DUAL_FUNC(efx)		\
 	(falcon_rev(efx) < FALCON_REV_B0)
 
@@ -426,7 +429,7 @@ void falcon_init_tx(struct efx_tx_queue *tx_queue)
 	efx_oword_t tx_desc_ptr;
 	struct efx_nic *efx = tx_queue->efx;
 
-	tx_queue->flushed = false;
+	tx_queue->flushed = FLUSH_NONE;
 
 	/* Pin TX descriptor ring */
 	falcon_init_special_buffer(efx, &tx_queue->txd);
@@ -476,6 +479,8 @@ static void falcon_flush_tx_queue(struct efx_tx_queue *tx_queue)
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_flush_descq;
 
+	tx_queue->flushed = FLUSH_PENDING;
+
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
@@ -489,7 +494,7 @@ void falcon_fini_tx(struct efx_tx_queue *tx_queue)
 	efx_oword_t tx_desc_ptr;
 
 	/* The queue should have been flushed */
-	WARN_ON(!tx_queue->flushed);
+	WARN_ON(tx_queue->flushed != FLUSH_DONE);
 
 	/* Remove TX descriptor ring from card */
 	EFX_ZERO_OWORD(tx_desc_ptr);
@@ -578,7 +583,7 @@ void falcon_init_rx(struct efx_rx_queue *rx_queue)
 		rx_queue->queue, rx_queue->rxd.index,
 		rx_queue->rxd.index + rx_queue->rxd.entries - 1);
 
-	rx_queue->flushed = false;
+	rx_queue->flushed = FLUSH_NONE;
 
 	/* Pin RX descriptor ring */
 	falcon_init_special_buffer(efx, &rx_queue->rxd);
@@ -607,6 +612,8 @@ static void falcon_flush_rx_queue(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 	efx_oword_t rx_flush_descq;
 
+	rx_queue->flushed = FLUSH_PENDING;
+
 	/* Post a flush command */
 	EFX_POPULATE_OWORD_2(rx_flush_descq,
 			     FRF_AZ_RX_FLUSH_DESCQ_CMD, 1,
@@ -620,7 +627,7 @@ void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 	struct efx_nic *efx = rx_queue->efx;
 
 	/* The queue should already have been flushed */
-	WARN_ON(!rx_queue->flushed);
+	WARN_ON(rx_queue->flushed != FLUSH_DONE);
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
@@ -1181,7 +1188,7 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 						   FSF_AZ_DRIVER_EV_SUBDATA);
 			if (ev_queue < EFX_TX_QUEUE_COUNT) {
 				tx_queue = efx->tx_queue + ev_queue;
-				tx_queue->flushed = true;
+				tx_queue->flushed = FLUSH_DONE;
 			}
 		} else if (ev_code == FSE_AZ_EV_CODE_DRIVER_EV &&
 			   ev_sub_code == FSE_AZ_RX_DESCQ_FLS_DONE_EV) {
@@ -1191,17 +1198,29 @@ static void falcon_poll_flush_events(struct efx_nic *efx)
 				*event, FSF_AZ_DRIVER_EV_RX_FLUSH_FAIL);
 			if (ev_queue < efx->n_rx_queues) {
 				rx_queue = efx->rx_queue + ev_queue;
-
-				/* retry the rx flush */
-				if (ev_failed)
-					falcon_flush_rx_queue(rx_queue);
-				else
-					rx_queue->flushed = true;
+				rx_queue->flushed =
+					ev_failed ? FLUSH_FAILED : FLUSH_DONE;
 			}
 		}
 
+		/* We're about to destroy the queue anyway, so
+		 * it's ok to throw away every non-flush event */
+		EFX_SET_QWORD(*event);
+
 		read_ptr = (read_ptr + 1) & EFX_EVQ_MASK;
 	} while (read_ptr != end_ptr);
+
+	channel->eventq_read_ptr = read_ptr;
+}
+
+static void falcon_prepare_flush(struct efx_nic *efx)
+{
+	falcon_deconfigure_mac_wrapper(efx);
+
+	/* Wait for the tx and rx fifo's to get to the next packet boundary
+	 * (~1ms without back-pressure), then to drain the remainder of the
+	 * fifo's at data path speeds (negligible), with a healthy margin. */
+	msleep(10);
 }
 
 /* Handle tx and rx flushes at the same time, since they run in
@@ -1211,50 +1230,56 @@ int falcon_flush_queues(struct efx_nic *efx)
 {
 	struct efx_rx_queue *rx_queue;
 	struct efx_tx_queue *tx_queue;
-	int i;
-	bool outstanding;
+	int i, tx_pending, rx_pending;
 
-	/* Issue flush requests */
-	efx_for_each_tx_queue(tx_queue, efx) {
-		tx_queue->flushed = false;
+	falcon_prepare_flush(efx);
+
+	/* Flush all tx queues in parallel */
+	efx_for_each_tx_queue(tx_queue, efx)
 		falcon_flush_tx_queue(tx_queue);
-	}
-	efx_for_each_rx_queue(rx_queue, efx) {
-		rx_queue->flushed = false;
-		falcon_flush_rx_queue(rx_queue);
-	}
 
-	/* Poll the evq looking for flush completions. Since we're not pushing
-	 * any more rx or tx descriptors at this point, we're in no danger of
-	 * overflowing the evq whilst we wait */
+	/* The hardware supports four concurrent rx flushes, each of which may
+	 * need to be retried if there is an outstanding descriptor fetch */
 	for (i = 0; i < FALCON_FLUSH_POLL_COUNT; ++i) {
-		msleep(FALCON_FLUSH_INTERVAL);
-		falcon_poll_flush_events(efx);
+		rx_pending = tx_pending = 0;
+		efx_for_each_rx_queue(rx_queue, efx) {
+			if (rx_queue->flushed == FLUSH_PENDING)
+				++rx_pending;
+		}
+		efx_for_each_rx_queue(rx_queue, efx) {
+			if (rx_pending == FALCON_RX_FLUSH_COUNT)
+				break;
+			if (rx_queue->flushed == FLUSH_FAILED ||
+			    rx_queue->flushed == FLUSH_NONE) {
+				falcon_flush_rx_queue(rx_queue);
+				++rx_pending;
+			}
+		}
+		efx_for_each_tx_queue(tx_queue, efx) {
+			if (tx_queue->flushed != FLUSH_DONE)
+				++tx_pending;
+		}
 
-		/* Check if every queue has been succesfully flushed */
-		outstanding = false;
-		efx_for_each_tx_queue(tx_queue, efx)
-			outstanding |= !tx_queue->flushed;
-		efx_for_each_rx_queue(rx_queue, efx)
-			outstanding |= !rx_queue->flushed;
-		if (!outstanding)
+		if (rx_pending == 0 && tx_pending == 0)
 			return 0;
+
+		msleep(FALCON_FLUSH_INTERVAL);
+		falcon_poll_flush_events(efx);
 	}
 
 	/* Mark the queues as all flushed. We're going to return failure
-	 * leading to a reset, or fake up success anyway. "flushed" now
-	 * indicates that we tried to flush. */
+	 * leading to a reset, or fake up success anyway */
 	efx_for_each_tx_queue(tx_queue, efx) {
-		if (!tx_queue->flushed)
+		if (tx_queue->flushed != FLUSH_DONE)
 			EFX_ERR(efx, "tx queue %d flush command timed out\n",
 				tx_queue->queue);
-		tx_queue->flushed = true;
+		tx_queue->flushed = FLUSH_DONE;
 	}
 	efx_for_each_rx_queue(rx_queue, efx) {
-		if (!rx_queue->flushed)
+		if (rx_queue->flushed != FLUSH_DONE)
 			EFX_ERR(efx, "rx queue %d flush command timed out\n",
 				rx_queue->queue);
-		rx_queue->flushed = true;
+		rx_queue->flushed = FLUSH_DONE;
 	}
 
 	if (EFX_WORKAROUND_7803(efx))
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ac808d5..d0755ab 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -113,6 +113,13 @@ struct efx_special_buffer {
 	int entries;
 };
 
+enum efx_flush_state {
+	FLUSH_NONE,
+	FLUSH_PENDING,
+	FLUSH_FAILED,
+	FLUSH_DONE,
+};
+
 /**
  * struct efx_tx_buffer - An Efx TX buffer
  * @skb: The associated socket buffer.
@@ -189,7 +196,7 @@ struct efx_tx_queue {
 	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
-	bool flushed;
+	enum efx_flush_state flushed;
 
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
@@ -284,7 +291,7 @@ struct efx_rx_queue {
 	struct page *buf_page;
 	dma_addr_t buf_dma_addr;
 	char *buf_data;
-	bool flushed;
+	enum efx_flush_state flushed;
 };
 
 /**

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

