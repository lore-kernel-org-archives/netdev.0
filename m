From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/5] sfc: Validate IRQ moderation parameters in
 efx_init_irq_moderation()
Date: Mon, 05 Sep 2011 18:43:04 +0100
Message-ID: <1315244584.3028.16.camel@bwh-desktop>
References: <1315231921.3028.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1107 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab1IERnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:43:07 -0400
In-Reply-To: <1315231921.3028.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a range check, and move the check that RX and TX are consistent
from efx_ethtool_set_coalesce().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c     |   20 +++++++++++++++++---
 drivers/net/ethernet/sfc/efx.h     |    5 +++--
 drivers/net/ethernet/sfc/ethtool.c |   17 ++++++++---------
 drivers/net/ethernet/sfc/falcon.c  |    2 ++
 drivers/net/ethernet/sfc/nic.h     |    3 ++-
 drivers/net/ethernet/sfc/siena.c   |    2 ++
 6 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index e0157c0..76dcadf 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1357,7 +1357,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 	netif_set_real_num_rx_queues(efx->net_dev, efx->n_rx_channels);
 
 	/* Initialise the interrupt moderation settings */
-	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
+	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true,
+				true);
 
 	return 0;
 
@@ -1566,8 +1567,9 @@ static unsigned int irq_mod_ticks(unsigned int usecs, unsigned int resolution)
 }
 
 /* Set interrupt moderation parameters */
-void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
-			     unsigned int rx_usecs, bool rx_adaptive)
+int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
+			    unsigned int rx_usecs, bool rx_adaptive,
+			    bool rx_may_override_tx)
 {
 	struct efx_channel *channel;
 	unsigned tx_ticks = irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
@@ -1575,6 +1577,16 @@ void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
+	if (tx_ticks > EFX_IRQ_MOD_MAX || rx_ticks > EFX_IRQ_MOD_MAX)
+		return -EINVAL;
+
+	if (tx_ticks != rx_ticks && efx->tx_channel_offset == 0 &&
+	    !rx_may_override_tx) {
+		netif_err(efx, drv, efx->net_dev, "Channels are shared. "
+			  "RX and TX IRQ moderation must be equal\n");
+		return -EINVAL;
+	}
+
 	efx->irq_rx_adaptive = rx_adaptive;
 	efx->irq_rx_moderation = rx_ticks;
 	efx_for_each_channel(channel, efx) {
@@ -1583,6 +1595,8 @@ void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 		else if (efx_channel_has_tx_queues(channel))
 			channel->irq_moderation = tx_ticks;
 	}
+
+	return 0;
 }
 
 void efx_get_irq_moderation(struct efx_nic *efx, unsigned int *tx_usecs,
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 8ca6863..442f4d0 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -111,8 +111,9 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
-extern void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
-				    unsigned int rx_usecs, bool rx_adaptive);
+extern int efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
+				   unsigned int rx_usecs, bool rx_adaptive,
+				   bool rx_may_override_tx);
 extern void efx_get_irq_moderation(struct efx_nic *efx, unsigned int *tx_usecs,
 				   unsigned int *rx_usecs, bool *rx_adaptive);
 
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 1cb6ed0..98b363b 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -623,7 +623,8 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	unsigned int tx_usecs, rx_usecs;
-	bool adaptive;
+	bool adaptive, rx_may_override_tx;
+	int rc;
 
 	if (coalesce->use_adaptive_tx_coalesce)
 		return -EINVAL;
@@ -642,16 +643,14 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	/* If channels are shared, TX IRQ moderation can be quietly
 	 * overridden unless it is changed from its old value.
 	 */
-	if (efx->tx_channel_offset == 0 &&
-	    coalesce->tx_coalesce_usecs_irq != tx_usecs &&
-	    coalesce->tx_coalesce_usecs_irq != rx_usecs) {
-		netif_err(efx, drv, efx->net_dev, "Channels are shared. "
-			  "RX and TX IRQ moderation must be equal\n");
-		return -EINVAL;
-	}
+	rx_may_override_tx = coalesce->tx_coalesce_usecs_irq == tx_usecs;
 	tx_usecs = coalesce->tx_coalesce_usecs_irq;
 
-	efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive);
+	rc = efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive,
+				     rx_may_override_tx);
+	if (rc != 0)
+		return rc;
+
 	efx_for_each_channel(channel, efx)
 		efx->type->push_irq_moderation(channel);
 
diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 94bf4aa..4dd1748 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -104,6 +104,8 @@ static void falcon_push_irq_moderation(struct efx_channel *channel)
 	efx_dword_t timer_cmd;
 	struct efx_nic *efx = channel->efx;
 
+	BUILD_BUG_ON(EFX_IRQ_MOD_MAX > (1 << FRF_AB_TC_TIMER_VAL_WIDTH));
+
 	/* Set timer register */
 	if (channel->irq_moderation) {
 		EFX_POPULATE_DWORD_2(timer_cmd,
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 4bd1f28..b5b2886 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -204,7 +204,8 @@ extern irqreturn_t efx_nic_fatal_interrupt(struct efx_nic *efx);
 extern irqreturn_t falcon_legacy_interrupt_a1(int irq, void *dev_id);
 extern void falcon_irq_ack_a1(struct efx_nic *efx);
 
-#define EFX_IRQ_MOD_RESOLUTION 5
+#define EFX_IRQ_MOD_RESOLUTION	5
+#define EFX_IRQ_MOD_MAX		0x1000
 
 /* Global Resources */
 extern int efx_nic_flush_queues(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index 5735e84..4fdd148 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -36,6 +36,8 @@ static void siena_push_irq_moderation(struct efx_channel *channel)
 {
 	efx_dword_t timer_cmd;
 
+	BUILD_BUG_ON(EFX_IRQ_MOD_MAX > (1 << FRF_CZ_TC_TIMER_VAL_WIDTH));
+
 	if (channel->irq_moderation)
 		EFX_POPULATE_DWORD_2(timer_cmd,
 				     FRF_CZ_TC_TIMER_MODE,
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
