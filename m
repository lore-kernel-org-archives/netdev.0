From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [Upstream PATCH 1/2] driver: net: ethernet: davinci_mdio: runtime PM support
Date: Tue, 17 Jul 2012 23:35:52 +0530
Message-ID: <1342548353-12153-2-git-send-email-mugunthanvnm@ti.com>
References: <1342548353-12153-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35108 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab2GQSGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 14:06:01 -0400
In-Reply-To: <1342548353-12153-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling runtime PM support for davinci mdio device

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index e4e4708..cd7ee20 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -34,6 +34,7 @@
 #include <linux/clk.h>
 #include <linux/err.h>
 #include <linux/io.h>
+#include <linux/pm_runtime.h>
 #include <linux/davinci_emac.h>
 
 /*
@@ -321,7 +322,9 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		pdev->name, pdev->id);
 
-	data->clk = clk_get(dev, NULL);
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
+	data->clk = clk_get(&pdev->dev, "fck");
 	if (IS_ERR(data->clk)) {
 		dev_err(dev, "failed to get device clock\n");
 		ret = PTR_ERR(data->clk);
@@ -329,8 +332,6 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
-	clk_enable(data->clk);
-
 	dev_set_drvdata(dev, data);
 	data->dev = dev;
 	spin_lock_init(&data->lock);
@@ -378,10 +379,10 @@ bail_out:
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk) {
-		clk_disable(data->clk);
+	if (data->clk)
 		clk_put(data->clk);
-	}
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
 
 	kfree(data);
 
@@ -396,10 +397,10 @@ static int __devexit davinci_mdio_remove(struct platform_device *pdev)
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk) {
-		clk_disable(data->clk);
+	if (data->clk)
 		clk_put(data->clk);
-	}
+	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
 
 	dev_set_drvdata(dev, NULL);
 
@@ -421,8 +422,7 @@ static int davinci_mdio_suspend(struct device *dev)
 	__raw_writel(ctrl, &data->regs->control);
 	wait_for_idle(data);
 
-	if (data->clk)
-		clk_disable(data->clk);
+	pm_runtime_put_sync(data->dev);
 
 	data->suspended = true;
 	spin_unlock(&data->lock);
@@ -436,8 +436,7 @@ static int davinci_mdio_resume(struct device *dev)
 	u32 ctrl;
 
 	spin_lock(&data->lock);
-	if (data->clk)
-		clk_enable(data->clk);
+	pm_runtime_put_sync(data->dev);
 
 	/* restart the scan state machine */
 	ctrl = __raw_readl(&data->regs->control);
-- 
1.7.0.4
