From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 13/14] net/at91_ether: convert to devm_* functions
Date: Thu, 18 Oct 2012 23:01:18 +0200
Message-ID: <1350594079-4337-14-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59632 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932574Ab2JRVBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:46 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so6209827lbo.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:46 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/at91_ether.c | 25 +++++++------------------
 1 file changed, 7 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 68b7e2a..375d272 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -30,9 +30,8 @@
 #include <linux/clk.h>
 #include <linux/gfp.h>
 #include <linux/phy.h>
+#include <linux/io.h>
 
-#include <asm/io.h>
-#include <asm/uaccess.h>
 #include <asm/mach-types.h>
 
 #include "macb.h"
@@ -472,26 +471,25 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	spin_lock_init(&lp->lock);
 
 	dev->base_addr = regs->start;		/* physical base address */
-	lp->regs = ioremap(regs->start, regs->end - regs->start + 1);
+	lp->regs = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
 	if (!lp->regs) {
 		res = -ENOMEM;
 		goto err_free_dev;
 	}
 
 	/* Clock */
-	lp->pclk = clk_get(&pdev->dev, "ether_clk");
+	lp->pclk = devm_clk_get(&pdev->dev, "ether_clk");
 	if (IS_ERR(lp->pclk)) {
 		res = PTR_ERR(lp->pclk);
-		goto err_ioumap;
+		goto err_free_dev;
 	}
 	clk_enable(lp->pclk);
 
 	/* Install the interrupt handler */
 	dev->irq = platform_get_irq(pdev, 0);
-	if (request_irq(dev->irq, at91ether_interrupt, 0, dev->name, dev)) {
-		res = -EBUSY;
+	res = devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt, 0, dev->name, dev);
+	if (res)
 		goto err_disable_clock;
-	}
 
 	ether_setup(dev);
 	dev->netdev_ops = &at91ether_netdev_ops;
@@ -515,7 +513,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
 	/* Register the network interface */
 	res = register_netdev(dev);
 	if (res)
-		goto err_free_irq;
+		goto err_disable_clock;
 
 	if (macb_mii_init(lp) != 0)
 		goto err_out_unregister_netdev;
@@ -537,14 +535,8 @@ static int __init at91ether_probe(struct platform_device *pdev)
 
 err_out_unregister_netdev:
 	unregister_netdev(dev);
-err_free_irq:
-	platform_set_drvdata(pdev, NULL);
-	free_irq(dev->irq, dev);
 err_disable_clock:
 	clk_disable(lp->pclk);
-	clk_put(lp->pclk);
-err_ioumap:
-	iounmap(lp->regs);
 err_free_dev:
 	free_netdev(dev);
 	return res;
@@ -562,10 +554,7 @@ static int __devexit at91ether_remove(struct platform_device *pdev)
 	kfree(lp->mii_bus->irq);
 	mdiobus_free(lp->mii_bus);
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
-	iounmap(lp->regs);
 	clk_disable(lp->pclk);
-	clk_put(lp->pclk);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
 
-- 
1.7.12.3
