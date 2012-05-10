From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/8] sfc: Fill RX rings completely full, rather
 than to 95% full
Date: Thu, 10 May 2012 03:28:54 +0100
Message-ID: <1336616934.2499.35.camel@bwh-desktop.uk.solarflarecom.com>
References: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51865 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751668Ab2EJC25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:28:57 -0400
In-Reply-To: <1336616799.2499.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Riddoch <driddoch@solarflare.com>

There was no runtime control of the fast_fill_limit in any case, so purged
that field.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    3 ---
 drivers/net/ethernet/sfc/rx.c         |   15 ++++-----------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f0385e1..eaca447 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -252,8 +252,6 @@ struct efx_rx_page_state {
  * @max_fill: RX descriptor maximum fill level (<= ring size)
  * @fast_fill_trigger: RX descriptor fill level that will trigger a fast fill
  *	(<= @max_fill)
- * @fast_fill_limit: The level to which a fast fill will fill
- *	(@fast_fill_trigger <= @fast_fill_limit <= @max_fill)
  * @min_fill: RX descriptor minimum non-zero fill level.
  *	This records the minimum fill level observed when a ring
  *	refill was triggered.
@@ -274,7 +272,6 @@ struct efx_rx_queue {
 	int removed_count;
 	unsigned int max_fill;
 	unsigned int fast_fill_trigger;
-	unsigned int fast_fill_limit;
 	unsigned int min_fill;
 	unsigned int min_overfill;
 	unsigned int alloc_page_count;
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 763fa2f..254fec8 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -78,11 +78,6 @@ static int rx_alloc_method = RX_ALLOC_METHOD_AUTO;
  */
 static unsigned int rx_refill_threshold = 90;
 
-/* This is the percentage fill level to which an RX queue will be refilled
- * when the "RX refill threshold" is reached.
- */
-static unsigned int rx_refill_limit = 95;
-
 /*
  * RX maximum head room required.
  *
@@ -342,7 +337,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
  * efx_fast_push_rx_descriptors - push new RX descriptors quickly
  * @rx_queue:		RX descriptor queue
  * This will aim to fill the RX descriptor queue up to
- * @rx_queue->@fast_fill_limit. If there is insufficient atomic
+ * @rx_queue->@max_fill. If there is insufficient atomic
  * memory to do so, a slow fill will be scheduled.
  *
  * The caller must provide serialisation (none is used here). In practise,
@@ -367,7 +362,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 			rx_queue->min_fill = fill_level;
 	}
 
-	space = rx_queue->fast_fill_limit - fill_level;
+	space = rx_queue->max_fill - fill_level;
 	if (space < EFX_RX_BATCH)
 		goto out;
 
@@ -375,7 +370,7 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue)
 		   "RX queue %d fast-filling descriptor ring from"
 		   " level %d to level %d using %s allocation\n",
 		   efx_rx_queue_index(rx_queue), fill_level,
-		   rx_queue->fast_fill_limit,
+		   rx_queue->max_fill,
 		   channel->rx_alloc_push_pages ? "page" : "skb");
 
 	do {
@@ -681,7 +676,7 @@ int efx_probe_rx_queue(struct efx_rx_queue *rx_queue)
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 {
 	struct efx_nic *efx = rx_queue->efx;
-	unsigned int max_fill, trigger, limit;
+	unsigned int max_fill, trigger;
 
 	netif_dbg(rx_queue->efx, drv, rx_queue->efx->net_dev,
 		  "initialising RX queue %d\n", efx_rx_queue_index(rx_queue));
@@ -695,11 +690,9 @@ void efx_init_rx_queue(struct efx_rx_queue *rx_queue)
 	/* Initialise limit fields */
 	max_fill = efx->rxq_entries - EFX_RXD_HEAD_ROOM;
 	trigger = max_fill * min(rx_refill_threshold, 100U) / 100U;
-	limit = max_fill * min(rx_refill_limit, 100U) / 100U;
 
 	rx_queue->max_fill = max_fill;
 	rx_queue->fast_fill_trigger = trigger;
-	rx_queue->fast_fill_limit = limit;
 
 	/* Set up RX descriptor ring */
 	rx_queue->enabled = true;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
