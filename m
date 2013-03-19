From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 3/4][net-next] gianfar: Remove redundant programming of [rt]xic registers
Date: Tue, 19 Mar 2013 19:40:04 +0200
Message-ID: <1363714805-9142-4-git-send-email-claudiu.manoil@freescale.com>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:16029 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757097Ab3CSRkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:40:36 -0400
In-Reply-To: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For Multi Q Multi Group (MQ_MG_MODE) mode, the Rx/Tx colescing registers [rt]xic
are aliased with the [rt]xic0 registers (coalescing setting regs for Q0). This
avoids programming twice in a row the coalescing registers for the Rx/Tx hw Q0.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3f07dbd..e28b3e6 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1821,20 +1821,9 @@ void gfar_configure_coalescing(struct gfar_private *priv,
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
+		int i = 0;
 		baddr = &regs->txic0;
 		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
 			gfar_write(baddr + i, 0);
@@ -1848,6 +1837,17 @@ void gfar_configure_coalescing(struct gfar_private *priv,
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
+		if (unlikely(priv->rx_queue[0]->rxcoalescing))
+			gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
 	}
 }
 
-- 
1.7.11.3
