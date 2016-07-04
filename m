From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/9] net: r6040: Reclaim transmitted buffers in NAPI
Date: Mon,  4 Jul 2016 14:36:04 -0700
Message-ID: <1467668169-31547-5-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32869 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbcGDVgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:17 -0400
Received: by mail-oi0-f67.google.com with SMTP id w141so24984900oia.0
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:17 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of taking one interrupt per packet transmitted, re-use the same
NAPI context to free transmitted buffers. Since we are no longer in hard
IRQ context replace dev_kfree_skb_irq() by dev_kfree_skb().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 46ed093348da..4bf78f18a937 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -622,7 +622,7 @@ static void r6040_tx(struct net_device *dev)
 		pci_unmap_single(priv->pdev, le32_to_cpu(descptr->buf),
 			skb_ptr->len, PCI_DMA_TODEVICE);
 		/* Free buffer */
-		dev_kfree_skb_irq(skb_ptr);
+		dev_kfree_skb(skb_ptr);
 		descptr->skb_ptr = NULL;
 		/* To next descriptor */
 		descptr = descptr->vndescp;
@@ -643,12 +643,15 @@ static int r6040_poll(struct napi_struct *napi, int budget)
 	void __iomem *ioaddr = priv->base;
 	int work_done;
 
+	r6040_tx(dev);
+
 	work_done = r6040_rx(dev, budget);
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		/* Enable RX interrupt */
-		iowrite16(ioread16(ioaddr + MIER) | RX_INTS, ioaddr + MIER);
+		/* Enable RX/TX interrupt */
+		iowrite16(ioread16(ioaddr + MIER) | RX_INTS | TX_INTS,
+			  ioaddr + MIER);
 	}
 	return work_done;
 }
@@ -675,7 +678,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	}
 
 	/* RX interrupt request */
-	if (status & RX_INTS) {
+	if (status & (RX_INTS | TX_INTS)) {
 		if (status & RX_NO_DESC) {
 			/* RX descriptor unavailable */
 			dev->stats.rx_dropped++;
@@ -686,15 +689,11 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 
 		if (likely(napi_schedule_prep(&lp->napi))) {
 			/* Mask off RX interrupt */
-			misr &= ~RX_INTS;
+			misr &= ~(RX_INTS | TX_INTS);
 			__napi_schedule(&lp->napi);
 		}
 	}
 
-	/* TX interrupt request */
-	if (status & TX_INTS)
-		r6040_tx(dev);
-
 	/* Restore RDC MAC interrupt */
 	iowrite16(misr, ioaddr + MIER);
 
-- 
2.7.4
