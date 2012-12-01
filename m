From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/13] sfc: Work-around flush timeout when flushes
 have completed
Date: Sat, 1 Dec 2012 04:43:47 +0000
Message-ID: <1354337027.2640.49.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26187 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab2LAEnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:43:50 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 	Daniel Pieczko <dpieczko@solarflare.com>

We sometimes hit a "failed to flush" timeout on some TX queues, but the
flushes have completed and the flush completion events seem to go missing.
In this case, we can check the TX_DESC_PTR_TBL register and drain the
queues if the flushes had finished.

[bwh: Minor fixes to coding style]
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    1 +
 drivers/net/ethernet/sfc/nic.c        |   56 ++++++++++++++++++++++++++++++--
 2 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 1014556..2d756c1 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -200,6 +200,7 @@ struct efx_tx_queue {
 	/* Members shared between paths and sometimes updated */
 	unsigned int empty_read_count ____cacheline_aligned_in_smp;
 #define EFX_EMPTY_COUNT_VALID 0x80000000
+	atomic_t flush_outstanding;
 };
 
 /**
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 1327f29..0ad790c 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -73,6 +73,8 @@
 	_EFX_CHANNEL_MAGIC(_EFX_CHANNEL_MAGIC_TX_DRAIN,			\
 			   (_tx_queue)->queue)
 
+static void efx_magic_event(struct efx_channel *channel, u32 magic);
+
 /**************************************************************************
  *
  * Solarstorm hardware access
@@ -491,6 +493,9 @@ static void efx_flush_tx_queue(struct efx_tx_queue *tx_queue)
 	struct efx_nic *efx = tx_queue->efx;
 	efx_oword_t tx_flush_descq;
 
+	WARN_ON(atomic_read(&tx_queue->flush_outstanding));
+	atomic_set(&tx_queue->flush_outstanding, 1);
+
 	EFX_POPULATE_OWORD_2(tx_flush_descq,
 			     FRF_AZ_TX_FLUSH_DESCQ_CMD, 1,
 			     FRF_AZ_TX_FLUSH_DESCQ, tx_queue->queue);
@@ -666,6 +671,47 @@ static bool efx_flush_wake(struct efx_nic *efx)
 		 && atomic_read(&efx->rxq_flush_pending) > 0));
 }
 
+static bool efx_check_tx_flush_complete(struct efx_nic *efx)
+{
+	bool i = true;
+	efx_oword_t txd_ptr_tbl;
+	struct efx_channel *channel;
+	struct efx_tx_queue *tx_queue;
+
+	efx_for_each_channel(channel, efx) {
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
+			efx_reado_table(efx, &txd_ptr_tbl,
+					FR_BZ_TX_DESC_PTR_TBL, tx_queue->queue);
+			if (EFX_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_FLUSH) ||
+			    EFX_OWORD_FIELD(txd_ptr_tbl,
+					    FRF_AZ_TX_DESCQ_EN)) {
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush did not complete on TXQ %d\n",
+					  tx_queue->queue);
+				i = false;
+			} else if (atomic_cmpxchg(&tx_queue->flush_outstanding,
+						  1, 0)) {
+				/* The flush is complete, but we didn't
+				 * receive a flush completion event
+				 */
+				netif_dbg(efx, hw, efx->net_dev,
+					  "flush complete on TXQ %d, so drain "
+					  "the queue\n", tx_queue->queue);
+				/* Don't need to increment drain_pending as it
+				 * has already been incremented for the queues
+				 * which did not drain
+				 */
+				efx_magic_event(channel,
+						EFX_CHANNEL_MAGIC_TX_DRAIN(
+							tx_queue));
+			}
+		}
+	}
+
+	return i;
+}
+
 /* Flush all the transmit queues, and continue flushing receive queues until
  * they're all flushed. Wait for the DRAIN events to be recieved so that there
  * are no more RX and TX events left on any channel. */
@@ -726,7 +772,8 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 					     timeout);
 	}
 
-	if (atomic_read(&efx->drain_pending)) {
+	if (atomic_read(&efx->drain_pending) &&
+	    !efx_check_tx_flush_complete(efx)) {
 		netif_err(efx, hw, efx->net_dev, "failed to flush %d queues "
 			  "(rx %d+%d)\n", atomic_read(&efx->drain_pending),
 			  atomic_read(&efx->rxq_flush_outstanding),
@@ -1018,9 +1065,10 @@ efx_handle_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 	if (qid < EFX_TXQ_TYPES * efx->n_tx_channels) {
 		tx_queue = efx_get_tx_queue(efx, qid / EFX_TXQ_TYPES,
 					    qid % EFX_TXQ_TYPES);
-
-		efx_magic_event(tx_queue->channel,
-				EFX_CHANNEL_MAGIC_TX_DRAIN(tx_queue));
+		if (atomic_cmpxchg(&tx_queue->flush_outstanding, 1, 0)) {
+			efx_magic_event(tx_queue->channel,
+					EFX_CHANNEL_MAGIC_TX_DRAIN(tx_queue));
+		}
 	}
 }
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
