From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [RFC net-next 1/4] gianfar: Remove redundant programming of [rt]xic registers
Date: Wed, 8 Aug 2012 15:26:47 +0300
Message-ID: <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:28076
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753563Ab2HHM1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 08:27:02 -0400
In-Reply-To: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Multi Q Multi Group (MQ_MG_MODE) mode, the Rx/Tx colescing registers [rt]xic
are aliased with the [rt]xic0 registers (coalescing setting regs for Q0). This
avoids programming twice in a row the coalescing registers for the Rx/Tx hw Q0.
Also, replaced inconsistent "unlikely" in the process.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4605f72..e9feeb9 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1799,20 +1799,9 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 {
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
 	u32 __iomem *baddr;
-	int i = 0;
-
-	/* Backward compatible case ---- even if we enable
-	 * multiple queues, there's only single reg to program
-	 */
-	gfar_write(&regs->txic, 0);
-	if (likely(priv->tx_queue[0]->txcoalescing))
-		gfar_write(&regs->txic, priv->tx_queue[0]->txic);
-
-	gfar_write(&regs->rxic, 0);
-	if (unlikely(priv->rx_queue[0]->rxcoalescing))
-		gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
 
 	if (priv->mode == MQ_MG_MODE) {
+		int i;
 		baddr = &regs->txic0;
 		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
 			gfar_write(baddr + i, 0);
@@ -1826,6 +1815,17 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 			if (likely(priv->rx_queue[i]->rxcoalescing))
 				gfar_write(baddr + i, priv->rx_queue[i]->rxic);
 		}
+	} else {
+		/* Backward compatible case ---- even if we enable
+		 * multiple queues, there's only single reg to program
+		 */
+		gfar_write(&regs->txic, 0);
+		if (likely(priv->tx_queue[0]->txcoalescing))
+			gfar_write(&regs->txic, priv->tx_queue[0]->txic);
+
+		gfar_write(&regs->rxic, 0);
+		if (likely(priv->rx_queue[0]->rxcoalescing))
+			gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
 	}
 }
 
-- 
1.6.6
