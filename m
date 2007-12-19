From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: [PATCH] MACB: clear transmit buffers properly on transmit underrun
Date: Wed, 19 Dec 2007 18:23:44 +0100
Message-ID: <1198085024-17362-1-git-send-email-hskinnemoen@atmel.com>
Cc: netdev@vger.kernel.org, Gregory CLEMENT <gclement00@gmail.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:56026 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750830AbXLSR0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 12:26:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory CLEMENT <gclement00@gmail.com>

Initially transmit buffer pointers were only reset. But buffer
descriptors were possibly still set as ready, and buffer in upper
layer was not freed. This caused driver hang under big load.  Now
reset clean properly the buffer descriptor and freed upper layer.

Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
---
 drivers/net/macb.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 047ea7b..e10528e 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -307,8 +307,31 @@ static void macb_tx(struct macb *bp)
 		(unsigned long)status);
 
 	if (status & MACB_BIT(UND)) {
+		int i;
 		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
-		       bp->dev->name);
+			bp->dev->name);
+
+		head = bp->tx_head;
+
+		/*Mark all the buffer as used to avoid sending a lost buffer*/
+		for (i = 0; i < TX_RING_SIZE; i++)
+			bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+
+		/* free transmit buffer in upper layer*/
+		for (tail = bp->tx_tail; tail != head; tail = NEXT_TX(tail)) {
+			struct ring_info *rp = &bp->tx_skb[tail];
+			struct sk_buff *skb = rp->skb;
+
+			BUG_ON(skb == NULL);
+
+			rmb();
+
+			dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
+							 DMA_TO_DEVICE);
+			rp->skb = NULL;
+			dev_kfree_skb_irq(skb);
+		}
+
 		bp->tx_head = bp->tx_tail = 0;
 	}
 
-- 
1.5.3.4

