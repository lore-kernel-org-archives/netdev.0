From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/8] sfc: Do not attempt to flush queues if DMA is
 disabled
Date: Thu, 10 May 2012 03:27:53 +0100
Message-ID: <1336616873.2499.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51843 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751668Ab2EJC15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:27:57 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_nic_fatal_interrupt() disables DMA before scheduling a reset.
After this, we need not and *cannot* flush queues.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 3cbfbff..5cc58a3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -656,25 +656,30 @@ static void efx_stop_datapath(struct efx_nic *efx)
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	struct pci_dev *dev = efx->pci_dev;
 	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 	BUG_ON(efx->port_enabled);
 
-	rc = efx_nic_flush_queues(efx);
-	if (rc && EFX_WORKAROUND_7803(efx)) {
-		/* Schedule a reset to recover from the flush failure. The
-		 * descriptor caches reference memory we're about to free,
-		 * but falcon_reconfigure_mac_wrapper() won't reconnect
-		 * the MACs because of the pending reset. */
-		netif_err(efx, drv, efx->net_dev,
-			  "Resetting to recover from flush failure\n");
-		efx_schedule_reset(efx, RESET_TYPE_ALL);
-	} else if (rc) {
-		netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
-	} else {
-		netif_dbg(efx, drv, efx->net_dev,
-			  "successfully flushed all queues\n");
+	/* Only perform flush if dma is enabled */
+	if (dev->is_busmaster) {
+		rc = efx_nic_flush_queues(efx);
+
+		if (rc && EFX_WORKAROUND_7803(efx)) {
+			/* Schedule a reset to recover from the flush failure. The
+			 * descriptor caches reference memory we're about to free,
+			 * but falcon_reconfigure_mac_wrapper() won't reconnect
+			 * the MACs because of the pending reset. */
+			netif_err(efx, drv, efx->net_dev,
+				  "Resetting to recover from flush failure\n");
+			efx_schedule_reset(efx, RESET_TYPE_ALL);
+		} else if (rc) {
+			netif_err(efx, drv, efx->net_dev, "failed to flush queues\n");
+		} else {
+			netif_dbg(efx, drv, efx->net_dev,
+				  "successfully flushed all queues\n");
+		}
 	}
 
 	efx_for_each_channel(channel, efx) {
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
