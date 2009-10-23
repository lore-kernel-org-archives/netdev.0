From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 18/27] sfc: Maintain interrupt moderation values in ticks,
	not microseconds
Date: Fri, 23 Oct 2009 19:32:13 +0100
Message-ID: <1256322733.2785.39.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8857 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbZJWScL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:11 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simplifies the implementation a lot.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   41 +++++++++++++++++++++++------------------
 drivers/net/sfc/ethtool.c    |    8 +++-----
 drivers/net/sfc/falcon.c     |   11 +----------
 drivers/net/sfc/net_driver.h |    2 +-
 4 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 862e483..30951fb 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -228,26 +228,20 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		if (channel->used_flags & EFX_USED_BY_RX &&
 		    efx->irq_rx_adaptive &&
 		    unlikely(++channel->irq_count == 1000)) {
-			unsigned old_irq_moderation = channel->irq_moderation;
-
 			if (unlikely(channel->irq_mod_score <
 				     irq_adapt_low_thresh)) {
-				channel->irq_moderation =
-					max_t(int,
-					      channel->irq_moderation -
-					      FALCON_IRQ_MOD_RESOLUTION,
-					      FALCON_IRQ_MOD_RESOLUTION);
+				if (channel->irq_moderation > 1) {
+					channel->irq_moderation -= 1;
+					falcon_set_int_moderation(channel);
+				}
 			} else if (unlikely(channel->irq_mod_score >
 					    irq_adapt_high_thresh)) {
-				channel->irq_moderation =
-					min(channel->irq_moderation +
-					    FALCON_IRQ_MOD_RESOLUTION,
-					    efx->irq_rx_moderation);
+				if (channel->irq_moderation <
+				    efx->irq_rx_moderation) {
+					channel->irq_moderation += 1;
+					falcon_set_int_moderation(channel);
+				}
 			}
-
-			if (channel->irq_moderation != old_irq_moderation)
-				falcon_set_int_moderation(channel);
-
 			channel->irq_count = 0;
 			channel->irq_mod_score = 0;
 		}
@@ -1220,22 +1214,33 @@ void efx_flush_queues(struct efx_nic *efx)
  *
  **************************************************************************/
 
+static unsigned irq_mod_ticks(int usecs, int resolution)
+{
+	if (usecs <= 0)
+		return 0; /* cannot receive interrupts ahead of time :-) */
+	if (usecs < resolution)
+		return 1; /* never round down to 0 */
+	return usecs / resolution;
+}
+
 /* Set interrupt moderation parameters */
 void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
 			     bool rx_adaptive)
 {
 	struct efx_tx_queue *tx_queue;
 	struct efx_rx_queue *rx_queue;
+	unsigned tx_ticks = irq_mod_ticks(tx_usecs, FALCON_IRQ_MOD_RESOLUTION);
+	unsigned rx_ticks = irq_mod_ticks(rx_usecs, FALCON_IRQ_MOD_RESOLUTION);
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	efx_for_each_tx_queue(tx_queue, efx)
-		tx_queue->channel->irq_moderation = tx_usecs;
+		tx_queue->channel->irq_moderation = tx_ticks;
 
 	efx->irq_rx_adaptive = rx_adaptive;
-	efx->irq_rx_moderation = rx_usecs;
+	efx->irq_rx_moderation = rx_ticks;
 	efx_for_each_rx_queue(rx_queue, efx)
-		rx_queue->channel->irq_moderation = rx_usecs;
+		rx_queue->channel->irq_moderation = rx_ticks;
 }
 
 /**************************************************************************
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 45018f2..a313b61 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -618,6 +618,9 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 	coalesce->use_adaptive_rx_coalesce = efx->irq_rx_adaptive;
 	coalesce->rx_coalesce_usecs_irq = efx->irq_rx_moderation;
 
+	coalesce->tx_coalesce_usecs_irq *= FALCON_IRQ_MOD_RESOLUTION;
+	coalesce->rx_coalesce_usecs_irq *= FALCON_IRQ_MOD_RESOLUTION;
+
 	return 0;
 }
 
@@ -656,11 +659,6 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	}
 
 	efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive);
-
-	/* Reset channel to pick up new moderation value.  Note that
-	 * this may change the value of the irq_moderation field
-	 * (e.g. to allow for hardware timer granularity).
-	 */
 	efx_for_each_channel(channel, efx)
 		falcon_set_int_moderation(channel);
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 1582df7..e3c33fa 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1063,20 +1063,11 @@ void falcon_set_int_moderation(struct efx_channel *channel)
 
 	/* Set timer register */
 	if (channel->irq_moderation) {
-		/* Round to resolution supported by hardware.  The value we
-		 * program is based at 0.  So actual interrupt moderation
-		 * achieved is ((x + 1) * res).
-		 */
-		channel->irq_moderation -= (channel->irq_moderation %
-					    FALCON_IRQ_MOD_RESOLUTION);
-		if (channel->irq_moderation < FALCON_IRQ_MOD_RESOLUTION)
-			channel->irq_moderation = FALCON_IRQ_MOD_RESOLUTION;
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_AB_TC_TIMER_MODE,
 				     FFE_BB_TIMER_MODE_INT_HLDOFF,
 				     FRF_AB_TC_TIMER_VAL,
-				     channel->irq_moderation /
-				     FALCON_IRQ_MOD_RESOLUTION - 1);
+				     channel->irq_moderation - 1);
 	} else {
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_AB_TC_TIMER_MODE,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 25b7933..c8b6998 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -327,7 +327,7 @@ enum efx_rx_alloc_method {
  * @used_flags: Channel is used by net driver
  * @enabled: Channel enabled indicator
  * @irq: IRQ number (MSI and MSI-X only)
- * @irq_moderation: IRQ moderation value (in us)
+ * @irq_moderation: IRQ moderation value (in hardware ticks)
  * @napi_dev: Net device used with NAPI
  * @napi_str: NAPI control structure
  * @reset_work: Scheduled reset work thread

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

