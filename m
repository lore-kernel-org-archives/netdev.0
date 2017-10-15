From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 04/10] net: korina: optimize tx/rx interrupt handlers
Date: Sun, 15 Oct 2017 19:23:18 +0300
Message-ID: <20171015162318.859-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52618 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdJOQ2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 7825219189D
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:22:39 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 30 ++++++++++++++----------------
 1 file changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 04c1a3f38a79..64ae32af7539 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -542,11 +542,10 @@ korina_tx_dma_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct korina_private *lp = netdev_priv(dev);
 	u32 dmas;
-	irqreturn_t retval;
 
 	dmas = readl(&lp->tx_dma_regs->dmas);
 
-	if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
+	if (likely(dmas & KORINA_INT_TX)) {
 		korina_int_disable_tx(lp);
 
 		korina_tx(dev);
@@ -559,14 +558,14 @@ korina_tx_dma_interrupt(int irq, void *dev_id)
 			lp->tx_chain_head = lp->tx_chain_tail;
 			netif_trans_update(dev);
 		}
-		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR "%s: DMA error\n", dev->name);
 
-		retval = IRQ_HANDLED;
-	} else
-		retval = IRQ_NONE;
+		if (unlikely(dmas & DMA_STAT_ERR))
+			lp->dma_halt_cnt++;
 
-	return retval;
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
 }
 
 /* Ethernet Rx DMA interrupt */
@@ -575,22 +574,21 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
 	struct net_device *dev = dev_id;
 	struct korina_private *lp = netdev_priv(dev);
 	u32 dmas;
-	irqreturn_t retval;
 
 	dmas = readl(&lp->rx_dma_regs->dmas);
-	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
+
+	if (likely(dmas & KORINA_INT_RX)) {
 		korina_int_disable_rx(lp);
 
 		napi_schedule(&lp->napi);
 
-		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR "%s: DMA error\n", dev->name);
+		if (unlikely(dmas & DMA_STAT_ERR))
+			lp->dma_halt_cnt++;
 
-		retval = IRQ_HANDLED;
-	} else
-		retval = IRQ_NONE;
+		return IRQ_HANDLED;
+	}
 
-	return retval;
+	return IRQ_NONE;
 }
 
 /*
-- 
2.11.0
