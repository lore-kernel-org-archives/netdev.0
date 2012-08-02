From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Thu,  2 Aug 2012 21:43:35 +0200
Message-ID: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Cc: devicetree-discuss@lists.ozlabs.org, koen@dominion.thruhere.net,
	mugunthanvnm@ti.com, linux-arm-kernel@lists.infradead.org,
	paul@pwsan.com, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:32775 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab2HBToB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 15:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the driver control the device clocks. Appearantly, the Davinci
platform probes this driver with the clock all powered up, but on OMAP,
this isn't the case.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index cd7ee20..b4b6015 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -332,6 +332,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
+	clk_enable(data->clk);
+
 	dev_set_drvdata(dev, data);
 	data->dev = dev;
 	spin_lock_init(&data->lock);
@@ -379,8 +381,11 @@ bail_out:
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk)
+	if (data->clk) {
+		clk_disable(data->clk);
 		clk_put(data->clk);
+	}
+
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
@@ -397,8 +402,11 @@ static int __devexit davinci_mdio_remove(struct platform_device *pdev)
 	if (data->bus)
 		mdiobus_free(data->bus);
 
-	if (data->clk)
+	if (data->clk) {
+		clk_disable(data->clk);
 		clk_put(data->clk);
+	}
+
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
@@ -427,6 +435,8 @@ static int davinci_mdio_suspend(struct device *dev)
 	data->suspended = true;
 	spin_unlock(&data->lock);
 
+	clk_disable(data->clk);
+
 	return 0;
 }
 
@@ -435,6 +445,8 @@ static int davinci_mdio_resume(struct device *dev)
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	u32 ctrl;
 
+	clk_enable(data->clk);
+
 	spin_lock(&data->lock);
 	pm_runtime_put_sync(data->dev);
 
-- 
1.7.11.2
