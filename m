From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [net, 1/6] net: korina: don't use overflow and underflow interrupts
Date: Tue, 17 Jan 2017 19:32:05 +0200
Message-ID: <1484674325-22252-1-git-send-email-roman@advem.lv>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34814 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAQRcN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:32:13 -0500
Received: by mail-lf0-f66.google.com with SMTP id q89so17236041lfi.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:32:12 -0800 (PST)
Received: from ubrain.lan ([213.175.92.61])
        by smtp.googlemail.com with ESMTPSA id k7sm9465290lfe.26.2017.01.17.09.32.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 09:32:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When such interrupts occur there is not much we can do.
Dropping the whole ring doesn't help and only produces high packet loss.
If we just ignore the interrupt the mac will drop one or few packets instead of the whole ring.
Also this will lower the irq handling load, which is good.

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 83 +------------------------------------------
 1 file changed, 1 insertion(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 8037426..9bc375d 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -122,8 +122,6 @@ struct korina_private {
 
 	int rx_irq;
 	int tx_irq;
-	int ovr_irq;
-	int und_irq;
 
 	spinlock_t lock;        /* NIC xmit lock */
 
@@ -890,8 +888,6 @@ static void korina_restart_task(struct work_struct *work)
 	 */
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
-	disable_irq(lp->ovr_irq);
-	disable_irq(lp->und_irq);
 
 	writel(readl(&lp->tx_dma_regs->dmasm) |
 				DMA_STAT_FINI | DMA_STAT_ERR,
@@ -910,40 +906,10 @@ static void korina_restart_task(struct work_struct *work)
 	}
 	korina_multicast_list(dev);
 
-	enable_irq(lp->und_irq);
-	enable_irq(lp->ovr_irq);
 	enable_irq(lp->tx_irq);
 	enable_irq(lp->rx_irq);
 }
 
-static void korina_clear_and_restart(struct net_device *dev, u32 value)
-{
-	struct korina_private *lp = netdev_priv(dev);
-
-	netif_stop_queue(dev);
-	writel(value, &lp->eth_regs->ethintfc);
-	schedule_work(&lp->restart_task);
-}
-
-/* Ethernet Tx Underflow interrupt */
-static irqreturn_t korina_und_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct korina_private *lp = netdev_priv(dev);
-	unsigned int und;
-
-	spin_lock(&lp->lock);
-
-	und = readl(&lp->eth_regs->ethintfc);
-
-	if (und & ETH_INT_FC_UND)
-		korina_clear_and_restart(dev, und & ~ETH_INT_FC_UND);
-
-	spin_unlock(&lp->lock);
-
-	return IRQ_HANDLED;
-}
-
 static void korina_tx_timeout(struct net_device *dev)
 {
 	struct korina_private *lp = netdev_priv(dev);
@@ -951,25 +917,6 @@ static void korina_tx_timeout(struct net_device *dev)
 	schedule_work(&lp->restart_task);
 }
 
-/* Ethernet Rx Overflow interrupt */
-static irqreturn_t
-korina_ovr_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = dev_id;
-	struct korina_private *lp = netdev_priv(dev);
-	unsigned int ovr;
-
-	spin_lock(&lp->lock);
-	ovr = readl(&lp->eth_regs->ethintfc);
-
-	if (ovr & ETH_INT_FC_OVR)
-		korina_clear_and_restart(dev, ovr & ~ETH_INT_FC_OVR);
-
-	spin_unlock(&lp->lock);
-
-	return IRQ_HANDLED;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void korina_poll_controller(struct net_device *dev)
 {
@@ -992,8 +939,7 @@ static int korina_open(struct net_device *dev)
 	}
 
 	/* Install the interrupt handler
-	 * that handles the Done Finished
-	 * Ovr and Und Events */
+	 * that handles the Done Finished */
 	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
 			0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
@@ -1009,31 +955,10 @@ static int korina_open(struct net_device *dev)
 		goto err_free_rx_irq;
 	}
 
-	/* Install handler for overrun error. */
-	ret = request_irq(lp->ovr_irq, korina_ovr_interrupt,
-			0, "Ethernet Overflow", dev);
-	if (ret < 0) {
-		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
-		    dev->name, lp->ovr_irq);
-		goto err_free_tx_irq;
-	}
-
-	/* Install handler for underflow error. */
-	ret = request_irq(lp->und_irq, korina_und_interrupt,
-			0, "Ethernet Underflow", dev);
-	if (ret < 0) {
-		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
-		    dev->name, lp->und_irq);
-		goto err_free_ovr_irq;
-	}
 	mod_timer(&lp->media_check_timer, jiffies + 1);
 out:
 	return ret;
 
-err_free_ovr_irq:
-	free_irq(lp->ovr_irq, dev);
-err_free_tx_irq:
-	free_irq(lp->tx_irq, dev);
 err_free_rx_irq:
 	free_irq(lp->rx_irq, dev);
 err_release:
@@ -1051,8 +976,6 @@ static int korina_close(struct net_device *dev)
 	/* Disable interrupts */
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
-	disable_irq(lp->ovr_irq);
-	disable_irq(lp->und_irq);
 
 	korina_abort_tx(dev);
 	tmp = readl(&lp->tx_dma_regs->dmasm);
@@ -1072,8 +995,6 @@ static int korina_close(struct net_device *dev)
 
 	free_irq(lp->rx_irq, dev);
 	free_irq(lp->tx_irq, dev);
-	free_irq(lp->ovr_irq, dev);
-	free_irq(lp->und_irq, dev);
 
 	return 0;
 }
@@ -1112,8 +1033,6 @@ static int korina_probe(struct platform_device *pdev)
 
 	lp->rx_irq = platform_get_irq_byname(pdev, "korina_rx");
 	lp->tx_irq = platform_get_irq_byname(pdev, "korina_tx");
-	lp->ovr_irq = platform_get_irq_byname(pdev, "korina_ovr");
-	lp->und_irq = platform_get_irq_byname(pdev, "korina_und");
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs");
 	dev->base_addr = r->start;
-- 
2.7.4
