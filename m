From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: Add backwards compatible Single Queue mode polling
Date: Mon, 10 Jun 2013 20:19:48 +0300
Message-ID: <1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
References: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <michael.guntsche@it-loops.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:32619
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751751Ab3FJRUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 13:20:30 -0400
In-Reply-To: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Older Single Queue (SQ_SG_MODE) devices like TSEC (i.e. mpc83xx)
don't feature the frame receive indication bits (RXF) in RSTAT.
For these and for the rest of the SQ_SG_MODE devices, provide the
appropiate polling routine that handles a single pair of Rx/Tx
BD rings, removing the overhead incurred by the multiple queues/
multiple interrupt group devices (veTSEC/ eTSEC2.0 devices).
So this is primarily a fix for the TSEC devices.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 51 ++++++++++++++++++++++++++++++--
 1 file changed, 49 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 96fbe35..ac9bb63 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -128,6 +128,7 @@ static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
 static int gfar_poll(struct napi_struct *napi, int budget);
+static int gfar_poll_sq(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void gfar_netpoll(struct net_device *dev);
 #endif
@@ -1038,9 +1039,13 @@ static int gfar_probe(struct platform_device *ofdev)
 	dev->ethtool_ops = &gfar_ethtool_ops;
 
 	/* Register for napi ...We are registering NAPI for each grp */
-	for (i = 0; i < priv->num_grps; i++)
-		netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll,
+	if (priv->mode == SQ_SG_MODE)
+		netif_napi_add(dev, &priv->gfargrp[0].napi, gfar_poll_sq,
 			       GFAR_DEV_WEIGHT);
+	else
+		for (i = 0; i < priv->num_grps; i++)
+			netif_napi_add(dev, &priv->gfargrp[i].napi, gfar_poll,
+				       GFAR_DEV_WEIGHT);
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
@@ -2824,6 +2829,48 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 	return howmany;
 }
 
+static int gfar_poll_sq(struct napi_struct *napi, int budget)
+{
+	struct gfar_priv_grp *gfargrp =
+		container_of(napi, struct gfar_priv_grp, napi);
+	struct gfar __iomem *regs = gfargrp->regs;
+	struct gfar_priv_tx_q *tx_queue = gfargrp->priv->tx_queue[0];
+	struct gfar_priv_rx_q *rx_queue = gfargrp->priv->rx_queue[0];
+	int work_done = 0;
+
+	/* Clear IEVENT, so interrupts aren't called again
+	 * because of the packets that have already arrived
+	 */
+	gfar_write(&regs->ievent, IEVENT_RTX_MASK);
+
+	/* run Tx cleanup to completion */
+	if (tx_queue->tx_skbuff[tx_queue->skb_dirtytx])
+		gfar_clean_tx_ring(tx_queue);
+
+	work_done = gfar_clean_rx_ring(rx_queue, budget);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+		/* Clear the halt bit in RSTAT */
+		gfar_write(&regs->rstat, gfargrp->rstat);
+
+		gfar_write(&regs->imask, IMASK_DEFAULT);
+
+		/* If we are coalescing interrupts, update the timer
+		 * Otherwise, clear it
+		 */
+		gfar_write(&regs->txic, 0);
+		if (likely(tx_queue->txcoalescing))
+			gfar_write(&regs->txic, tx_queue->txic);
+
+		gfar_write(&regs->rxic, 0);
+		if (unlikely(rx_queue->rxcoalescing))
+			gfar_write(&regs->rxic, rx_queue->rxic);
+	}
+
+	return work_done;
+}
+
 static int gfar_poll(struct napi_struct *napi, int budget)
 {
 	struct gfar_priv_grp *gfargrp =
-- 
1.7.11.3
