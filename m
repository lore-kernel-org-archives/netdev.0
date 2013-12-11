From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH v2 3/5] net: macb: Use devm_ioremap()
Date: Tue, 10 Dec 2013 16:07:21 -0800
Message-ID: <1386720443-24100-4-git-send-email-soren.brinkmann@xilinx.com>
References: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60423 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab3LKAHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 19:07:45 -0500
In-Reply-To: <1386720443-24100-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the device managed version of ioremap to remap IO memory,
simplifying error paths.

Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 62aa136889a4..436aecc31732 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -17,6 +17,7 @@
 #include <linux/circ_buf.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/io.h>
 #include <linux/gpio.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
@@ -1816,7 +1817,7 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_disable_pclk;
 	}
 
-	bp->regs = ioremap(regs->start, resource_size(regs));
+	bp->regs = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
 	if (!bp->regs) {
 		dev_err(&pdev->dev, "failed to map registers, aborting.\n");
 		err = -ENOMEM;
@@ -1828,7 +1829,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	if (err) {
 		dev_err(&pdev->dev, "Unable to request IRQ %d (error %d)\n",
 			dev->irq, err);
-		goto err_out_iounmap;
+		goto err_out_disable_clocks;
 	}
 
 	dev->netdev_ops = &macb_netdev_ops;
@@ -1916,8 +1917,6 @@ err_out_unregister_netdev:
 	unregister_netdev(dev);
 err_out_free_irq:
 	free_irq(dev->irq, dev);
-err_out_iounmap:
-	iounmap(bp->regs);
 err_out_disable_clocks:
 	clk_disable_unprepare(bp->hclk);
 err_out_disable_pclk:
@@ -1944,7 +1943,6 @@ static int __exit macb_remove(struct platform_device *pdev)
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
-		iounmap(bp->regs);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
 		free_netdev(dev);
-- 
1.8.5.1
