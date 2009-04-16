From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: [PATCH 2/2] macb: process the RX ring regardless of interrupt status
Date: Thu, 16 Apr 2009 11:32:11 +0200
Message-ID: <1239874331-9431-2-git-send-email-haavard.skinnemoen@atmel.com>
References: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Erik Waling <erik.waling@konftel.com>,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:62175 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbZDPJcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 05:32:16 -0400
In-Reply-To: <1239874331-9431-1-git-send-email-haavard.skinnemoen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Waling <erik.waling@konftel.com>

Suppose that we receive lots of frames, start processing them, but
exhaust our budget so that we return before we had a chance to look
at all of them.

Then, when the network layer calls us again, we will only continue
processing the buffers if the REC bit was set in the mean time, which it
might not be if there was a brief pause in the flow of packets. If this
happens, we'll simply display a warning and call netif_rx_complete()
with potentially lots of unprocessed packets in the RX ring...

Fix this by scanning the ring no matter what flags are set in the
interrupt status register.

Signed-off-by: Erik Waling <erik.waling@konftel.com>
Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
 drivers/net/macb.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 22a595c..d473540 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -521,27 +521,10 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	macb_writel(bp, RSR, status);
 
 	work_done = 0;
-	if (!status) {
-		/*
-		 * This may happen if an interrupt was pending before
-		 * this function was called last time, and no packets
-		 * have been received since.
-		 */
-		napi_complete(napi);
-		goto out;
-	}
 
 	dev_dbg(&bp->pdev->dev, "poll: status = %08lx, budget = %d\n",
 		(unsigned long)status, budget);
 
-	if (!(status & MACB_BIT(REC))) {
-		dev_warn(&bp->pdev->dev,
-			 "No RX buffers complete, status = %02lx\n",
-			 (unsigned long)status);
-		napi_complete(napi);
-		goto out;
-	}
-
 	work_done = macb_rx(bp, budget);
 	if (work_done < budget)
 		napi_complete(napi);
@@ -550,7 +533,6 @@ static int macb_poll(struct napi_struct *napi, int budget)
 	 * We've done what we can to clean the buffers. Make sure we
 	 * get notified when new packets arrive.
 	 */
-out:
 	macb_writel(bp, IER, MACB_RX_INT_FLAGS);
 
 	/* TODO: Handle errors */
-- 
1.6.0.4

