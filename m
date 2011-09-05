From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/5] sfc: Correct reporting and validation of TX
 interrupt coalescing
Date: Mon, 05 Sep 2011 18:42:25 +0100
Message-ID: <1315244545.3028.15.camel@bwh-desktop>
References: <1315231921.3028.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:1061 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab1IERm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:42:28 -0400
In-Reply-To: <1315231921.3028.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reported TX IRQ moderation is generated in a completely crazy way.
Make it simple and correct.

When channels are shared between RX and TX, TX IRQ moderation must be
the same as RX IRQ moderation, but must be specified as 0!  Allow it
to be either specified as the same, or left at its previous value
in which case it will be quietly overridden.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c     |   18 ++++++++++
 drivers/net/ethernet/sfc/efx.h     |    2 +
 drivers/net/ethernet/sfc/ethtool.c |   67 +++++++++++++++++------------------
 3 files changed, 53 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 097ed8b..e0157c0 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1585,6 +1585,24 @@ void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 	}
 }
 
+void efx_get_irq_moderation(struct efx_nic *efx, unsigned int *tx_usecs,
+			    unsigned int *rx_usecs, bool *rx_adaptive)
+{
+	*rx_adaptive = efx->irq_rx_adaptive;
+	*rx_usecs = efx->irq_rx_moderation * EFX_IRQ_MOD_RESOLUTION;
+
+	/* If channels are shared between RX and TX, so is IRQ
+	 * moderation.  Otherwise, IRQ moderation is the same for all
+	 * TX channels and is not adaptive.
+	 */
+	if (efx->tx_channel_offset == 0)
+		*tx_usecs = *rx_usecs;
+	else
+		*tx_usecs =
+			efx->channel[efx->tx_channel_offset]->irq_moderation *
+			EFX_IRQ_MOD_RESOLUTION;
+}
+
 /**************************************************************************
  *
  * Hardware monitor
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 8f5acae..8ca6863 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -113,6 +113,8 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
 extern void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
 				    unsigned int rx_usecs, bool rx_adaptive);
+extern void efx_get_irq_moderation(struct efx_nic *efx, unsigned int *tx_usecs,
+				   unsigned int *rx_usecs, bool *rx_adaptive);
 
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index dedaa2c..1cb6ed0 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -586,40 +586,37 @@ static int efx_ethtool_nway_reset(struct net_device *net_dev)
 	return mdio45_nway_restart(&efx->mdio);
 }
 
+/*
+ * Each channel has a single IRQ and moderation timer, started by any
+ * completion (or other event).  Unless the module parameter
+ * separate_tx_channels is set, IRQs and moderation are therefore
+ * shared between RX and TX completions.  In this case, when RX IRQ
+ * moderation is explicitly changed then TX IRQ moderation is
+ * automatically changed too, but otherwise we fail if the two values
+ * are requested to be different.
+ *
+ * We implement adaptive IRQ moderation, but use a different algorithm
+ * from that assumed in the definition of struct ethtool_coalesce.
+ * Therefore we do not use any of the adaptive moderation parameters
+ * in it.
+ */
+
 static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct efx_channel *channel;
-
-	memset(coalesce, 0, sizeof(*coalesce));
-
-	/* Find lowest IRQ moderation across all used TX queues */
-	coalesce->tx_coalesce_usecs_irq = ~((u32) 0);
-	efx_for_each_channel(channel, efx) {
-		if (!efx_channel_has_tx_queues(channel))
-			continue;
-		if (channel->irq_moderation < coalesce->tx_coalesce_usecs_irq) {
-			if (channel->channel < efx->n_rx_channels)
-				coalesce->tx_coalesce_usecs_irq =
-					channel->irq_moderation;
-			else
-				coalesce->tx_coalesce_usecs_irq = 0;
-		}
-	}
+	unsigned int tx_usecs, rx_usecs;
+	bool rx_adaptive;
 
-	coalesce->use_adaptive_rx_coalesce = efx->irq_rx_adaptive;
-	coalesce->rx_coalesce_usecs_irq = efx->irq_rx_moderation;
+	efx_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &rx_adaptive);
 
-	coalesce->tx_coalesce_usecs_irq *= EFX_IRQ_MOD_RESOLUTION;
-	coalesce->rx_coalesce_usecs_irq *= EFX_IRQ_MOD_RESOLUTION;
+	coalesce->tx_coalesce_usecs_irq = tx_usecs;
+	coalesce->rx_coalesce_usecs_irq = rx_usecs;
+	coalesce->use_adaptive_rx_coalesce = rx_adaptive;
 
 	return 0;
 }
 
-/* Set coalescing parameters
- * The difficulties occur for shared channels
- */
 static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
@@ -637,20 +634,22 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 		return -EINVAL;
 	}
 
+	efx_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &adaptive);
+
 	rx_usecs = coalesce->rx_coalesce_usecs_irq;
-	tx_usecs = coalesce->tx_coalesce_usecs_irq;
 	adaptive = coalesce->use_adaptive_rx_coalesce;
 
-	/* If the channel is shared only allow RX parameters to be set */
-	efx_for_each_channel(channel, efx) {
-		if (efx_channel_has_rx_queue(channel) &&
-		    efx_channel_has_tx_queues(channel) &&
-		    tx_usecs) {
-			netif_err(efx, drv, efx->net_dev, "Channel is shared. "
-				  "Only RX coalescing may be set\n");
-			return -EINVAL;
-		}
+	/* If channels are shared, TX IRQ moderation can be quietly
+	 * overridden unless it is changed from its old value.
+	 */
+	if (efx->tx_channel_offset == 0 &&
+	    coalesce->tx_coalesce_usecs_irq != tx_usecs &&
+	    coalesce->tx_coalesce_usecs_irq != rx_usecs) {
+		netif_err(efx, drv, efx->net_dev, "Channels are shared. "
+			  "RX and TX IRQ moderation must be equal\n");
+		return -EINVAL;
 	}
+	tx_usecs = coalesce->tx_coalesce_usecs_irq;
 
 	efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive);
 	efx_for_each_channel(channel, efx)
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
