From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Check per channel DMA interrupt use in main
 ISR
Date: Thu, 5 Feb 2015 19:17:14 -0600
Message-ID: <20150206011714.2507.45712.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0113.outbound.protection.outlook.com ([65.55.169.113]:50688
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751407AbbBFBRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 20:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using per channel DMA interrupts the transmit interrupt (TI) and the
receive interrupt (RI) are masked off so as to not generate an interrupt
to the main ISR. However, should another interrupt fire for the DMA channel
that is handled by the main ISR the TI/RI bits can still be set. This
will cause the wrong and uninitialized napi structure to be used causing a
panic. Add a check to be sure per channel DMA interrupts are not enabled
before acting on those bit flags.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index e5ffb2c..477a7e3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -337,12 +337,13 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 		dma_ch_isr = XGMAC_DMA_IOREAD(channel, DMA_CH_SR);
 		DBGPR("  DMA_CH%u_ISR = %08x\n", i, dma_ch_isr);
 
-		/* If we get a TI or RI interrupt that means per channel DMA
-		 * interrupts are not enabled, so we use the private data napi
-		 * structure, not the per channel napi structure
+		/* The TI or RI interrupt bits may still be set even if using
+		 * per channel DMA interrupts. Check to be sure those are not
+		 * enabled before using the private data napi structure.
 		 */
-		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, TI) ||
-		    XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RI)) {
+		if (!pdata->per_channel_irq &&
+		    (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, TI) ||
+		     XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RI))) {
 			if (napi_schedule_prep(&pdata->napi)) {
 				/* Disable Tx and Rx interrupts */
 				xgbe_disable_rx_tx_ints(pdata);
