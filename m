From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH] gianfar: Fix RXICr/TXICr programming for multi-queue mode
Date: Thu, 28 Jun 2012 17:40:53 +0300
Message-ID: <1340894453-28556-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.13] ([65.55.88.13]:25387 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752214Ab2F1Om3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 10:42:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The correct behavior is to program the interrupt coalescing regs
(RXICr/TXICr) in accordance with the Rx/Tx Q's "rx/txcoalescing"
flag. That is, if the coalescing flag is 0 for a given Rx/Tx queue
then the corresponding coalescing register should be cleared.
This behavior is correctly implemented for the single-queue mode
(SQ_SG_MODE), but not for the multi-queue mode (MQ_MG_MODE).
This fixes the later case.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index f00a095..af16f9f 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1815,18 +1815,16 @@ void gfar_configure_coalescing(struct gfar_private *priv,
 	if (priv->mode == MQ_MG_MODE) {
 		baddr = &regs->txic0;
 		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
-			if (likely(priv->tx_queue[i]->txcoalescing)) {
-				gfar_write(baddr + i, 0);
+			gfar_write(baddr + i, 0);
+			if (likely(priv->tx_queue[i]->txcoalescing))
 				gfar_write(baddr + i, priv->tx_queue[i]->txic);
-			}
 		}
 
 		baddr = &regs->rxic0;
 		for_each_set_bit(i, &rx_mask, priv->num_rx_queues) {
-			if (likely(priv->rx_queue[i]->rxcoalescing)) {
-				gfar_write(baddr + i, 0);
+			gfar_write(baddr + i, 0);
+			if (likely(priv->rx_queue[i]->rxcoalescing))
 				gfar_write(baddr + i, priv->rx_queue[i]->rxic);
-			}
 		}
 	}
 }
-- 
1.6.6
