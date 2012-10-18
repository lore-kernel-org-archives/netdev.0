From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 06/14] net/at91_ether: use pclk member instead of ether_clk
Date: Thu, 18 Oct 2012 23:01:11 +0200
Message-ID: <1350594079-4337-7-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59632 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319Ab2JRVBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:39 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so6209827lbo.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:38 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old at91_priv member and use pclk member from macb.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c | 24 ++++++++++++------------
 drivers/net/ethernet/cadence/macb.h       |  1 -
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 09f3746..4da36b8 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -765,7 +765,7 @@ static int at91ether_open(struct net_device *dev)
 	if (!is_valid_ether_addr(dev->dev_addr))
 		return -EADDRNOTAVAIL;
 
-	clk_enable(lp->ether_clk);		/* Re-enable Peripheral clock */
+	clk_enable(lp->pclk);		/* Re-enable Peripheral clock */
 
 	/* Clear internal statistics */
 	ctl = macb_readl(lp, NCR);
@@ -817,7 +817,7 @@ static int at91ether_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	clk_disable(lp->ether_clk);		/* Disable Peripheral clock */
+	clk_disable(lp->pclk);		/* Disable Peripheral clock */
 
 	return 0;
 }
@@ -1070,12 +1070,12 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	}
 
 	/* Clock */
-	lp->ether_clk = clk_get(&pdev->dev, "ether_clk");
-	if (IS_ERR(lp->ether_clk)) {
-		res = PTR_ERR(lp->ether_clk);
+	lp->pclk = clk_get(&pdev->dev, "ether_clk");
+	if (IS_ERR(lp->pclk)) {
+		res = PTR_ERR(lp->pclk);
 		goto err_ioumap;
 	}
-	clk_enable(lp->ether_clk);
+	clk_enable(lp->pclk);
 
 	/* Install the interrupt handler */
 	dev->irq = platform_get_irq(pdev, 0);
@@ -1173,7 +1173,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	else if (lp->phy_type == MII_LAN83C185_ID)
 		printk(KERN_INFO "%s: SMSC LAN83C185 PHY\n", dev->name);
 
-	clk_disable(lp->ether_clk);					/* Disable Peripheral clock */
+	clk_disable(lp->pclk);					/* Disable Peripheral clock */
 
 	return 0;
 
@@ -1184,8 +1184,8 @@ err_free_dmamem:
 err_free_irq:
 	free_irq(dev->irq, dev);
 err_disable_clock:
-	clk_disable(lp->ether_clk);
-	clk_put(lp->ether_clk);
+	clk_disable(lp->pclk);
+	clk_put(lp->pclk);
 err_ioumap:
 	iounmap(lp->regs);
 err_free_dev:
@@ -1204,7 +1204,7 @@ static int __devexit at91ether_remove(struct platform_device *pdev)
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
-	clk_put(lp->ether_clk);
+	clk_put(lp->pclk);
 
 	platform_set_drvdata(pdev, NULL);
 	free_netdev(dev);
@@ -1227,7 +1227,7 @@ static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
 		netif_stop_queue(net_dev);
 		netif_device_detach(net_dev);
 
-		clk_disable(lp->ether_clk);
+		clk_disable(lp->pclk);
 	}
 	return 0;
 }
@@ -1238,7 +1238,7 @@ static int at91ether_resume(struct platform_device *pdev)
 	struct macb *lp = netdev_priv(net_dev);
 
 	if (netif_running(net_dev)) {
-		clk_enable(lp->ether_clk);
+		clk_enable(lp->pclk);
 
 		netif_device_attach(net_dev);
 		netif_start_queue(net_dev);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 5661094..138311f 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -559,7 +559,6 @@ struct macb {
 	struct macb_platform_data board_data;	/* board-specific
 						 * configuration (shared with
 						 * macb for common data */
-	struct clk *ether_clk;			/* clock */
 
 	/* PHY */
 	unsigned long phy_type;			/* type of PHY (PHY_ID) */
-- 
1.7.12.3
