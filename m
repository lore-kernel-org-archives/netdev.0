From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 1/7] net: korina: don't use overflow and underflow interrupts
Date: Sun, 17 Sep 2017 20:24:15 +0300
Message-ID: <20170917172415.32291-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:37686 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdIQRYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:24:17 -0400
Received: by mail-lf0-f67.google.com with SMTP id q132so3432736lfe.4
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:24:16 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id l14sm1117048lfb.71.2017.09.17.10.24.14
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:24:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When such interrupts occur there is not much we can do.
Dropping the whole ring doesn't help and only produces high packet loss.
If we just ignore the interrupt the mac will drop one or few packets instead of the whole ring.
Also this will lower the irq handling load and increase performance.

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 83 +------------------------------------------
 1 file changed, 1 insertion(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 3c0a6451273d..98d686ed69a9 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -122,8 +122,6 @@ struct korina_private {
 
 	int rx_irq;
 	int tx_irq;
-	int ovr_irq;
-	int und_irq;
 
 	spinlock_t lock;        /* NIC xmit lock */
 
@@ -891,8 +889,6 @@ static void korina_restart_task(struct work_struct *work)
 	 */
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
-	disable_irq(lp->ovr_irq);
-	disable_irq(lp->und_irq);
 
 	writel(readl(&lp->tx_dma_regs->dmasm) |
 				DMA_STAT_FINI | DMA_STAT_ERR,
@@ -911,40 +907,10 @@ static void korina_restart_task(struct work_struct *work)
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
@@ -952,25 +918,6 @@ static void korina_tx_timeout(struct net_device *dev)
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
@@ -993,8 +940,7 @@ static int korina_open(struct net_device *dev)
 	}
 
 	/* Install the interrupt handler
-	 * that handles the Done Finished
-	 * Ovr and Und Events */
+	 * that handles the Done Finished */
 	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
 			0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
@@ -1010,31 +956,10 @@ static int korina_open(struct net_device *dev)
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
@@ -1052,8 +977,6 @@ static int korina_close(struct net_device *dev)
 	/* Disable interrupts */
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
-	disable_irq(lp->ovr_irq);
-	disable_irq(lp->und_irq);
 
 	korina_abort_tx(dev);
 	tmp = readl(&lp->tx_dma_regs->dmasm);
@@ -1073,8 +996,6 @@ static int korina_close(struct net_device *dev)
 
 	free_irq(lp->rx_irq, dev);
 	free_irq(lp->tx_irq, dev);
-	free_irq(lp->ovr_irq, dev);
-	free_irq(lp->und_irq, dev);
 
 	return 0;
 }
@@ -1113,8 +1034,6 @@ static int korina_probe(struct platform_device *pdev)
 
 	lp->rx_irq = platform_get_irq_byname(pdev, "korina_rx");
 	lp->tx_irq = platform_get_irq_byname(pdev, "korina_tx");
-	lp->ovr_irq = platform_get_irq_byname(pdev, "korina_ovr");
-	lp->und_irq = platform_get_irq_byname(pdev, "korina_und");
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs");
 	dev->base_addr = r->start;
-- 
2.11.0
