From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: [PATCH 1/2] macb: Handle Retry Limit Exceeded errors
Date: Thu, 16 Apr 2009 11:32:10 +0200
Message-ID: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Erik Waling <erik.waling@konftel.se>,
	Erik Waling <erik.waling@konftel.com>,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:54994 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbZDPJcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 05:32:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Waling <erik.waling@konftel.se>

When transfering large amounts of data we sometimes experienced that the
Retry Limit Exceeded (RLE) bit got set in TSR during transmission
attempts. When this happened the driver would stall in a state that
prevented any more data from being sent.

Signed-off-by: Erik Waling <erik.waling@konftel.com>
Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
 drivers/net/macb.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f505010..22a595c 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -316,10 +316,11 @@ static void macb_tx(struct macb *bp)
 	dev_dbg(&bp->pdev->dev, "macb_tx status = %02lx\n",
 		(unsigned long)status);
 
-	if (status & MACB_BIT(UND)) {
+	if (status & (MACB_BIT(UND) | MACB_BIT(TSR_RLE))) {
 		int i;
-		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
-			bp->dev->name);
+		printk(KERN_ERR "%s: TX %s, resetting buffers\n",
+			bp->dev->name, status & MACB_BIT(UND) ?
+			"underrun" : "retry limit exceeded");
 
 		/* Transfer ongoing, disable transmitter, to avoid confusion */
 		if (status & MACB_BIT(TGO))
@@ -590,7 +591,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			}
 		}
 
-		if (status & (MACB_BIT(TCOMP) | MACB_BIT(ISR_TUND)))
+		if (status & (MACB_BIT(TCOMP) | MACB_BIT(ISR_TUND) |
+			    MACB_BIT(ISR_RLE)))
 			macb_tx(bp);
 
 		/*
-- 
1.6.0.4

