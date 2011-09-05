From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/5] sfc: Use correct fields of struct
 ethtool_coalesce
Date: Mon, 05 Sep 2011 18:43:49 +0100
Message-ID: <1315244629.3028.17.camel@bwh-desktop>
References: <1315231921.3028.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1156 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab1IERnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:43:52 -0400
In-Reply-To: <1315231921.3028.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An earlier developer misunderstood the meaning of the 'irq' fields and
the driver did not support the standard fields.  To avoid invalidating
existing user documentation, we report and accept changes through
either the standard or 'irq' fields.  If both are changed at the same
time, we prefer the standard field.

Also explain why we don't currently use the 'max_frames' fields.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c |   36 +++++++++++++++++++++++++++---------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 98b363b..93f1fb9 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -595,6 +595,20 @@ static int efx_ethtool_nway_reset(struct net_device *net_dev)
  * automatically changed too, but otherwise we fail if the two values
  * are requested to be different.
  *
+ * The hardware does not support a limit on the number of completions
+ * before an IRQ, so we do not use the max_frames fields.  We should
+ * report and require that max_frames == (usecs != 0), but this would
+ * invalidate existing user documentation.
+ *
+ * The hardware does not have distinct settings for interrupt
+ * moderation while the previous IRQ is being handled, so we should
+ * not use the 'irq' fields.  However, an earlier developer
+ * misunderstood the meaning of the 'irq' fields and the driver did
+ * not support the standard fields.  To avoid invalidating existing
+ * user documentation, we report and accept changes through either the
+ * standard or 'irq' fields.  If both are changed at the same time, we
+ * prefer the standard field.
+ *
  * We implement adaptive IRQ moderation, but use a different algorithm
  * from that assumed in the definition of struct ethtool_coalesce.
  * Therefore we do not use any of the adaptive moderation parameters
@@ -610,7 +624,9 @@ static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 
 	efx_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &rx_adaptive);
 
+	coalesce->tx_coalesce_usecs = tx_usecs;
 	coalesce->tx_coalesce_usecs_irq = tx_usecs;
+	coalesce->rx_coalesce_usecs = rx_usecs;
 	coalesce->rx_coalesce_usecs_irq = rx_usecs;
 	coalesce->use_adaptive_rx_coalesce = rx_adaptive;
 
@@ -629,22 +645,24 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 	if (coalesce->use_adaptive_tx_coalesce)
 		return -EINVAL;
 
-	if (coalesce->rx_coalesce_usecs || coalesce->tx_coalesce_usecs) {
-		netif_err(efx, drv, efx->net_dev, "invalid coalescing setting. "
-			  "Only rx/tx_coalesce_usecs_irq are supported\n");
-		return -EINVAL;
-	}
-
 	efx_get_irq_moderation(efx, &tx_usecs, &rx_usecs, &adaptive);
 
-	rx_usecs = coalesce->rx_coalesce_usecs_irq;
+	if (coalesce->rx_coalesce_usecs != rx_usecs)
+		rx_usecs = coalesce->rx_coalesce_usecs;
+	else
+		rx_usecs = coalesce->rx_coalesce_usecs_irq;
+
 	adaptive = coalesce->use_adaptive_rx_coalesce;
 
 	/* If channels are shared, TX IRQ moderation can be quietly
 	 * overridden unless it is changed from its old value.
 	 */
-	rx_may_override_tx = coalesce->tx_coalesce_usecs_irq == tx_usecs;
-	tx_usecs = coalesce->tx_coalesce_usecs_irq;
+	rx_may_override_tx = (coalesce->tx_coalesce_usecs == tx_usecs &&
+			      coalesce->tx_coalesce_usecs_irq == tx_usecs);
+	if (coalesce->tx_coalesce_usecs != tx_usecs)
+		tx_usecs = coalesce->tx_coalesce_usecs;
+	else
+		tx_usecs = coalesce->tx_coalesce_usecs_irq;
 
 	rc = efx_init_irq_moderation(efx, tx_usecs, rx_usecs, adaptive,
 				     rx_may_override_tx);
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
