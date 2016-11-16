From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 3/7] net: ethernet: ti: cpsw: fix deferred probe
Date: Wed, 16 Nov 2016 15:35:12 +0100
Message-ID: <1479306916-27673-4-git-send-email-johan@kernel.org>
References: <1479306916-27673-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479306916-27673-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to deregister all child devices also on probe errors to avoid
leaks and to fix probe deferral.

cpsw 4a100000.ethernet: omap_device: omap_device_enable() called from invalid state 1
cpsw 4a100000.ethernet: use pm_runtime_put_sync_suspend() in driver?
cpsw: probe of 4a100000.ethernet failed with error -22

Add generic helper to undo the effects of cpsw_probe_dt(), which will
also be used in a follow-on patch to fix further leaks that have been
introduced more recently.

Fixes: 1fb19aa730e4 ("net: cpsw: Add parent<->child relation support
between cpsw and mdio")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index ee1fae914abc..4374ba05610b 100644
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
@@ -2588,7 +2593,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (cpsw_probe_dt(&cpsw->data, pdev)) {
 		dev_err(&pdev->dev, "cpsw: platform data missing\n");
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	data = &cpsw->data;
 	cpsw->rx_ch_num = 1;
@@ -2609,7 +2614,7 @@ static int cpsw_probe(struct platform_device *pdev)
 				    GFP_KERNEL);
 	if (!cpsw->slaves) {
 		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	for (i = 0; i < data->slaves; i++)
 		cpsw->slaves[i].slave_num = i;
@@ -2621,7 +2626,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (IS_ERR(clk)) {
 		dev_err(priv->dev, "fck is not found\n");
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	cpsw->bus_freq_mhz = clk_get_rate(clk) / 1000000;
 
@@ -2629,7 +2634,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
 	if (IS_ERR(ss_regs)) {
 		ret = PTR_ERR(ss_regs);
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	cpsw->regs = ss_regs;
 
@@ -2639,7 +2644,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	ret = pm_runtime_get_sync(&pdev->dev);
 	if (ret < 0) {
 		pm_runtime_put_noidle(&pdev->dev);
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	cpsw->version = readl(&cpsw->regs->id_ver);
 	pm_runtime_put_sync(&pdev->dev);
@@ -2648,7 +2653,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	cpsw->wr_regs = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(cpsw->wr_regs)) {
 		ret = PTR_ERR(cpsw->wr_regs);
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 
 	memset(&dma_params, 0, sizeof(dma_params));
@@ -2685,7 +2690,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	default:
 		dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 	for (i = 0; i < cpsw->data.slaves; i++) {
 		struct cpsw_slave *slave = &cpsw->slaves[i];
@@ -2714,7 +2719,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (!cpsw->dma) {
 		dev_err(priv->dev, "error initializing dma\n");
 		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
+		goto clean_dt_ret;
 	}
 
 	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
@@ -2827,7 +2832,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	}
 clean_dma_ret:
 	cpdma_ctlr_destroy(cpsw->dma);
-clean_runtime_disable_ret:
+clean_dt_ret:
+	cpsw_remove_dt(pdev);
 	pm_runtime_disable(&pdev->dev);
 clean_ndev_ret:
 	free_netdev(priv->ndev);
@@ -2852,7 +2858,7 @@ static int cpsw_remove(struct platform_device *pdev)
 
 	cpsw_ale_destroy(cpsw->ale);
 	cpdma_ctlr_destroy(cpsw->dma);
-	of_platform_depopulate(&pdev->dev);
+	cpsw_remove_dt(pdev);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	if (cpsw->data.dual_emac)
-- 
2.7.3
