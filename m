From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 2/2] driver: net: ethernet: cpsw: runtime PM support
Date: Tue, 17 Jul 2012 23:39:50 +0530
Message-ID: <1342548590-12502-3-git-send-email-mugunthanvnm@ti.com>
References: <1342548590-12502-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35385 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756140Ab2GQSJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 14:09:57 -0400
In-Reply-To: <1342548590-12502-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enabling runtime PM support for cpsw driver

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ca381d3..1e5d85b 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -27,6 +27,7 @@
 #include <linux/phy.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>
+#include <linux/pm_runtime.h>
 
 #include <linux/platform_data/cpsw.h>
 
@@ -494,11 +495,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	cpsw_intr_disable(priv);
 	netif_carrier_off(ndev);
 
-	ret = clk_enable(priv->clk);
-	if (ret < 0) {
-		dev_err(priv->dev, "unable to turn on device clock\n");
-		return ret;
-	}
+	pm_runtime_get_sync(&priv->pdev->dev);
 
 	reg = __raw_readl(&priv->regs->id_ver);
 
@@ -569,7 +566,7 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 	netif_carrier_off(priv->ndev);
 	cpsw_ale_stop(priv->ale);
 	for_each_slave(priv, cpsw_slave_stop, priv);
-	clk_disable(priv->clk);
+	pm_runtime_put_sync(&priv->pdev->dev);
 	return 0;
 }
 
@@ -763,10 +760,12 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 	for (i = 0; i < data->slaves; i++)
 		priv->slaves[i].slave_num = i;
 
-	priv->clk = clk_get(&pdev->dev, NULL);
+	pm_runtime_enable(&pdev->dev);
+	priv->clk = clk_get(&pdev->dev, "fck");
 	if (IS_ERR(priv->clk)) {
-		dev_err(priv->dev, "failed to get device clock)\n");
-		ret = -EBUSY;
+		dev_err(&pdev->dev, "fck is not found\n");
+		ret = -ENODEV;
+		goto clean_slave_ret;
 	}
 
 	priv->cpsw_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -935,6 +934,8 @@ clean_cpsw_iores_ret:
 			   resource_size(priv->cpsw_res));
 clean_clk_ret:
 	clk_put(priv->clk);
+clean_slave_ret:
+	pm_runtime_disable(&pdev->dev);
 	kfree(priv->slaves);
 clean_ndev_ret:
 	free_netdev(ndev);
@@ -959,6 +960,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
 			   resource_size(priv->cpsw_res));
 	release_mem_region(priv->cpsw_ss_res->start,
 			   resource_size(priv->cpsw_ss_res));
+	pm_runtime_disable(&pdev->dev);
 	clk_put(priv->clk);
 	kfree(priv->slaves);
 	free_netdev(ndev);
@@ -973,6 +975,8 @@ static int cpsw_suspend(struct device *dev)
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
+	pm_runtime_put_sync(&pdev->dev);
+
 	return 0;
 }
 
@@ -981,6 +985,7 @@ static int cpsw_resume(struct device *dev)
 	struct platform_device	*pdev = to_platform_device(dev);
 	struct net_device	*ndev = platform_get_drvdata(pdev);
 
+	pm_runtime_get_sync(&pdev->dev);
 	if (netif_running(ndev))
 		cpsw_ndo_open(ndev);
 	return 0;
-- 
1.7.0.4
