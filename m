From: Geoff Levand <geoff@infradead.org>
Subject: [PATCH] net/ps3: Fix gelic RX DMA restart
Date: Thu, 14 Jul 2011 10:15:26 -0700
Message-ID: <4E1F242E.7070509@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"cbe-oss-dev@lists.ozlabs.org" <cbe-oss-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:8912
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932134Ab1GNRRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 13:17:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the condition where PS3 network RX hangs when no network
TX is occurring by calling gelic_card_enable_rxdmac() during
RX_DMA_CHAIN_END event processing.

The gelic hardware automatically clears its RX_DMA_EN flag when
it detects an RX_DMA_CHAIN_END event.  In its processing of
RX_DMA_CHAIN_END the gelic driver is required to set RX_DMA_EN
(with a call to gelic_card_enable_rxdmac()) to restart RX DMA
transfers.  The existing gelic driver code does not set
RX_DMA_EN directly in its processing of the RX_DMA_CHAIN_END
event, but uses a flag variable card->rx_dma_restart_required
to schedule the setting of RX_DMA_EN until next inside the
interrupt handler.

It seems this delayed setting of RX_DMA_EN causes the hang since
the next RX interrupt after the RX_DMA_CHAIN_END event where
RX_DMA_EN is scheduled to be set will not occur since RX_DMA_EN
was not set.  In the case were network TX is occuring, RX_DMA_EN
is set in the next TX interrupt and RX processing continues.

Signed-off-by: Geoff Levand <geoff@infradead.org>
---
 drivers/net/ps3_gelic_net.c |   21 ++++++++-------------
 drivers/net/ps3_gelic_net.h |    1 -
 2 files changed, 8 insertions(+), 14 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -986,10 +986,6 @@ static int gelic_card_decode_one_descr(s
 	int dmac_chain_ended;
 
 	status = gelic_descr_get_status(descr);
-	/* is this descriptor terminated with next_descr == NULL? */
-	dmac_chain_ended =
-		be32_to_cpu(descr->dmac_cmd_status) &
-		GELIC_DESCR_RX_DMA_CHAIN_END;
 
 	if (status == GELIC_DESCR_DMA_CARDOWNED)
 		return 0;
@@ -1052,6 +1048,11 @@ static int gelic_card_decode_one_descr(s
 	/* ok, we've got a packet in descr */
 	gelic_net_pass_skb_up(descr, card, netdev);
 refill:
+
+	/* is the current descriptor terminated with next_descr == NULL? */
+	dmac_chain_ended =
+		be32_to_cpu(descr->dmac_cmd_status) &
+		GELIC_DESCR_RX_DMA_CHAIN_END;
 	/*
 	 * So that always DMAC can see the end
 	 * of the descriptor chain to avoid
@@ -1080,10 +1081,9 @@ refill:
 	 * If dmac chain was met, DMAC stopped.
 	 * thus re-enable it
 	 */
-	if (dmac_chain_ended) {
-		card->rx_dma_restart_required = 1;
-		dev_dbg(ctodev(card), "reenable rx dma scheduled\n");
-	}
+
+	if (dmac_chain_ended)
+		gelic_card_enable_rxdmac(card);
 
 	return 1;
 }
@@ -1149,11 +1149,6 @@ static irqreturn_t gelic_card_interrupt(
 
 	status &= card->irq_mask;
 
-	if (card->rx_dma_restart_required) {
-		card->rx_dma_restart_required = 0;
-		gelic_card_enable_rxdmac(card);
-	}
-
 	if (status & GELIC_CARD_RXINT) {
 		gelic_card_rx_irq_off(card);
 		napi_schedule(&card->napi);
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -289,7 +289,6 @@ struct gelic_card {
 
 	struct gelic_descr_chain tx_chain;
 	struct gelic_descr_chain rx_chain;
-	int rx_dma_restart_required;
 	/*
 	 * tx_lock guards tx descriptor list and
 	 * tx_dma_progress.

