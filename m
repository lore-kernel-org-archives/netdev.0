From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/16] sfc: Use a global count of active queues
 instead of pending drains
Date: Fri, 30 Aug 2013 04:41:49 +0100
Message-ID: <1377834109.2552.36.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35036 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab3H3Dlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:41:53 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Rames <arames@solarflare.com>

On EF10, the firmware will initiate a queue flush in certain
error cases.  We need to accept that flush events might appear
at any time after a queue has been initialised, not just when
we try to flush them.

We can handle Falcon-architecture in just the same way.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |    5 ++++-
 drivers/net/ethernet/sfc/farch.c      |   18 ++++++++----------
 drivers/net/ethernet/sfc/net_driver.h |    4 ++--
 3 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b483223..34788fb 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -631,11 +631,14 @@ static void efx_start_datapath(struct efx_nic *efx)
 
 	/* Initialise the channels */
 	efx_for_each_channel(channel, efx) {
-		efx_for_each_channel_tx_queue(tx_queue, channel)
+		efx_for_each_channel_tx_queue(tx_queue, channel) {
 			efx_init_tx_queue(tx_queue);
+			atomic_inc(&efx->active_queues);
+		}
 
 		efx_for_each_channel_rx_queue(rx_queue, channel) {
 			efx_init_rx_queue(rx_queue);
+			atomic_inc(&efx->active_queues);
 			efx_nic_generate_fill_event(rx_queue);
 		}
 
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index eb754cf..842f92e 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -594,7 +594,7 @@ static bool efx_farch_flush_wake(struct efx_nic *efx)
 	/* Ensure that all updates are visible to efx_farch_flush_queues() */
 	smp_mb();
 
-	return (atomic_read(&efx->drain_pending) == 0 ||
+	return (atomic_read(&efx->active_queues) == 0 ||
 		(atomic_read(&efx->rxq_flush_outstanding) < EFX_RX_FLUSH_COUNT
 		 && atomic_read(&efx->rxq_flush_pending) > 0));
 }
@@ -626,7 +626,7 @@ static bool efx_check_tx_flush_complete(struct efx_nic *efx)
 				netif_dbg(efx, hw, efx->net_dev,
 					  "flush complete on TXQ %d, so drain "
 					  "the queue\n", tx_queue->queue);
-				/* Don't need to increment drain_pending as it
+				/* Don't need to increment active_queues as it
 				 * has already been incremented for the queues
 				 * which did not drain
 				 */
@@ -653,17 +653,15 @@ static int efx_farch_do_flush(struct efx_nic *efx)
 
 	efx_for_each_channel(channel, efx) {
 		efx_for_each_channel_tx_queue(tx_queue, channel) {
-			atomic_inc(&efx->drain_pending);
 			efx_farch_flush_tx_queue(tx_queue);
 		}
 		efx_for_each_channel_rx_queue(rx_queue, channel) {
-			atomic_inc(&efx->drain_pending);
 			rx_queue->flush_pending = true;
 			atomic_inc(&efx->rxq_flush_pending);
 		}
 	}
 
-	while (timeout && atomic_read(&efx->drain_pending) > 0) {
+	while (timeout && atomic_read(&efx->active_queues) > 0) {
 		/* If SRIOV is enabled, then offload receive queue flushing to
 		 * the firmware (though we will still have to poll for
 		 * completion). If that fails, fall back to the old scheme.
@@ -699,15 +697,15 @@ static int efx_farch_do_flush(struct efx_nic *efx)
 					     timeout);
 	}
 
-	if (atomic_read(&efx->drain_pending) &&
+	if (atomic_read(&efx->active_queues) &&
 	    !efx_check_tx_flush_complete(efx)) {
 		netif_err(efx, hw, efx->net_dev, "failed to flush %d queues "
-			  "(rx %d+%d)\n", atomic_read(&efx->drain_pending),
+			  "(rx %d+%d)\n", atomic_read(&efx->active_queues),
 			  atomic_read(&efx->rxq_flush_outstanding),
 			  atomic_read(&efx->rxq_flush_pending));
 		rc = -ETIMEDOUT;
 
-		atomic_set(&efx->drain_pending, 0);
+		atomic_set(&efx->active_queues, 0);
 		atomic_set(&efx->rxq_flush_pending, 0);
 		atomic_set(&efx->rxq_flush_outstanding, 0);
 	}
@@ -1123,8 +1121,8 @@ efx_farch_handle_drain_event(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
-	WARN_ON(atomic_read(&efx->drain_pending) == 0);
-	atomic_dec(&efx->drain_pending);
+	WARN_ON(atomic_read(&efx->active_queues) == 0);
+	atomic_dec(&efx->active_queues);
 	if (efx_farch_flush_wake(efx))
 		wake_up(&efx->flush_wq);
 }
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 5341c76..c9b6f2d 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -723,7 +723,7 @@ struct vfdi_status;
  * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
  *	indexed by filter ID
  * @rps_expire_index: Next index to check for expiry in @rps_flow_id
- * @drain_pending: Count of RX and TX queues that haven't been flushed and drained.
+ * @active_queues: Count of RX and TX queues that haven't been flushed and drained.
  * @rxq_flush_pending: Count of number of receive queues that need to be flushed.
  *	Decremented when the efx_flush_rx_queue() is called.
  * @rxq_flush_outstanding: Count of number of RX flushes started but not yet
@@ -864,7 +864,7 @@ struct efx_nic {
 	unsigned int rps_expire_index;
 #endif
 
-	atomic_t drain_pending;
+	atomic_t active_queues;
 	atomic_t rxq_flush_pending;
 	atomic_t rxq_flush_outstanding;
 	wait_queue_head_t flush_wq;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
