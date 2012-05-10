From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/8] sfc: By default refill RX rings as soon as
 space for a batch
Date: Thu, 10 May 2012 03:29:27 +0100
Message-ID: <1336616967.2499.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51874 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751759Ab2EJC3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:29:30 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Riddoch <driddoch@solarflare.com>

Previously we refilled with much larger batches, which caused large latency
spikes.  We now have many more much much smaller spikes!

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 254fec8..243e91f 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -76,7 +76,7 @@ static int rx_alloc_method = RX_ALLOC_METHOD_AUTO;
 /* This is the percentage fill level below which new RX descriptors
  * will be added to the RX descriptor ring.
  */
-static unsigned int rx_refill_threshold = 90;
+static unsigned int rx_refill_threshold;
 
 /*
  * RX maximum head room required.
@@ -363,8 +363,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 	}
 
 	space = rx_queue->max_fill - fill_level;
-	if (space < EFX_RX_BATCH)
-		goto out;
+	EFX_BUG_ON_PARANOID(space < EFX_RX_BATCH);
 
 	netif_vdbg(rx_queue->efx, rx_status, rx_queue->efx->net_dev,
 		   "RX queue %d fast-filling descriptor ring from"
@@ -676,7 +675,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	unsigned int max_fill, trigger;
+	unsigned int max_fill, trigger, max_trigger;
 
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
 		  "initialising RX queue %d\n", efx_rx_queue_index(rx_queue));
@@ -689,7 +688,14 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 
 	/* Initialise limit fields */
 	max_fill = efx->rxq_entries - EFX_RXD_HEAD_ROOM;
-	trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
+	max_trigger = max_fill - EFX_RX_BATCH;
+	if (rx_refill_threshold != 0) {
+		trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
+		if (trigger > max_trigger)
+			trigger = max_trigger;
+	} else {
+		trigger = max_trigger;
+	}
 
 	rx_queue->max_fill = max_fill;
 	rx_queue->fast_fill_trigger = trigger;
@@ -739,5 +745,5 @@ MODULE_PARM_DESC(rx_alloc_method, "Allocation method used for RX buffers");
 
 module_param(rx_refill_threshold, uint, 0444);
 MODULE_PARM_DESC(rx_refill_threshold,
-		 "RX descriptor ring fast/slow fill threshold (%)");
+		 "RX descriptor ring refill threshold (%)");
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
