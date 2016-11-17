From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 3/7] net: ethernet: ti: cpsw: fix deferred probe
Date: Thu, 17 Nov 2016 17:40:00 +0100
Message-ID: <1479400804-9847-4-git-send-email-johan@kernel.org>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister all child devices also on probe errors to avoid
leaks and to fix probe deferral:

cpsw 4a100000.ethernet: omap_device: omap_device_enable() called from invalid state 1
cpsw 4a100000.ethernet: use pm_runtime_put_sync_suspend() in driver?
cpsw: probe of 4a100000.ethernet failed with error -22

Add generic helper to undo the effects of cpsw_probe_dt(), which will
also be used in a follow-on patch to fix further leaks that have been
introduced more recently.

Note that the platform device is now runtime-resumed before registering
any child devices in order to make sure that it is synchronously
suspended after having deregistered the children in the error path.

Fixes: 1fb19aa730e4 ("net: cpsw: Add parent<->child relation support
between cpsw and mdio")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 41 ++++++++++++++++++++++++-----------------
 1 file changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 84c5d214557e..5d14abb06486 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2441,6 +2441,11 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	return 0;
 }
 
+static void cpsw_remove_dt(struct platform_device *pdev)
+{
+	of_platform_depopulate(&pdev->dev);
+}
+
 static int cpsw_probe_dual_emac(struct cpsw_priv *priv)
 {
 	struct cpsw_common		*cpsw = priv->cpsw;
@@ -2585,10 +2590,19 @@ static int cpsw_probe(struct platform_device *pdev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(&pdev->dev);
 
+	/* Need to enable clocks with runtime PM api to access module
+	 * registers
+	 */
+	ret = pm_runtime_get_sync(&pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&pdev->dev);
+		goto clean_runtime_disable_ret;
+	}
+
 	if (cpsw_probe_dt(&cpsw->data, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	data = &cpsw->data;
 	cpsw->rx_ch_num = 1;
@@ -2609,7 +2623,7 @@ static int cpsw_probe(struct platform_device *pdev)
 				    GFP_KERNEL);
 	if (!cpsw->slaves) {
 		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	for (i = 0; i < data->slaves; i++)
 		cpsw->slaves[i].slave_num = i;
@@ -2621,7 +2635,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (IS_ERR(clk)) {
 		dev_err(priv->dev, "fck is not found\n");
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	cpsw->bus_freq_mhz = clk_get_rate(clk) / 1000000;
 
@@ -2629,25 +2643,17 @@ static int cpsw_probe(struct platform_device *pdev)
 	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
 	if (IS_ERR(ss_regs)) {
 		ret = PTR_ERR(ss_regs);
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	cpsw->regs = ss_regs;
 
-	/* Need to enable clocks with runtime PM api to access module
-	 * registers
-	 */
-	ret = pm_runtime_get_sync(&pdev->dev);
-	if (ret < 0) {
-		pm_runtime_put_noidle(&pdev->dev);
-		goto clean_runtime_disable_ret;
-	}
 	cpsw->version = readl(&cpsw->regs->id_ver);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	cpsw->wr_regs = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(cpsw->wr_regs)) {
 		ret = PTR_ERR(cpsw->wr_regs);
-		goto clean_pm_runtime_put_ret;
+		goto clean_dt_ret;
 	}
 
 	memset(&dma_params, 0, sizeof(dma_params));
@@ -2684,7 +2690,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	default:
 		dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
 		ret = -ENODEV;
-		goto clean_pm_runtime_put_ret;
+		goto clean_dt_ret;
 	}
 	for (i = 0; i < cpsw->data.slaves; i++) {
 		struct cpsw_slave *slave = &cpsw->slaves[i];
@@ -2713,7 +2719,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (!cpsw->dma) {
 		dev_err(priv->dev, "error initializing dma\n");
 		ret = -ENOMEM;
-		goto clean_pm_runtime_put_ret;
+		goto clean_dt_ret;
 	}
 
 	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
@@ -2823,7 +2829,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
 	cpdma_ctlr_destroy(cpsw->dma);
-clean_pm_runtime_put_ret:
+clean_dt_ret:
+	cpsw_remove_dt(pdev);
 	pm_runtime_put_sync(&pdev->dev);
 clean_runtime_disable_ret:
 	pm_runtime_disable(&pdev->dev);
@@ -2850,7 +2857,7 @@ static int cpsw_remove(struct platform_device *pdev)
 
 	cpsw_ale_destroy(cpsw->ale);
 	cpdma_ctlr_destroy(cpsw->dma);
-	of_platform_depopulate(&pdev->dev);
+	cpsw_remove_dt(pdev);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	if (cpsw->data.dual_emac)
-- 
2.7.3
