From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 1/1] net: macb: replace macb_writel() call by queue_writel() to update queue ISR
Date: Thu, 24 Mar 2016 15:40:04 +0100
Message-ID: <1458830404-6213-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:19614 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbcCXOjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 10:39:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb_interrupt() should not use macb_writel(bp, ISR, <value>) but only
queue_writel(queue, ISR, <value>).

There is one IRQ and one set of {ISR, IER, IDR, IMR} [1] registers per
queue on gem hardware, though only queue0 is actually used for now to
receive frames: other queues can already be used to transmit frames.

The queue_readl() and queue_writel() helper macros are designed to access
the relevant IRQ registers.

[1]
ISR: Interrupt Status Register
IER: Interrupt Enable Register
IDR: Interrupt Disable Register
IMR: Interrupt Mask Register

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Fixes: bfbb92c44670 ("net: macb: Handle the RXUBR interrupt on all devices")
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 39447a337149..c9c6b2762a39 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1146,7 +1146,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			macb_writel(bp, NCR, ctrl | MACB_BIT(RE));
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(RXUBR));
+				queue_writel(queue, ISR, MACB_BIT(RXUBR));
 		}
 
 		if (status & MACB_BIT(ISR_ROVR)) {
-- 
1.8.2.2
