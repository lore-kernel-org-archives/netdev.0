From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 1/7] net: ethernet: ti: cpsw: fix bad register access in probe error path
Date: Thu, 17 Nov 2016 17:39:58 +0100
Message-ID: <1479400804-9847-2-git-send-email-johan@kernel.org>
References: <1479400804-9847-1-git-send-email-johan@kernel.org>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479400804-9847-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to keep the platform device runtime-resumed throughout probe
to avoid accessing the CPSW registers in the error path (e.g. for
deferred probe) with clocks disabled:

Unhandled fault: external abort on non-linefetch (0x1008) at 0xd0872d08
...
[<c04fabcc>] (cpsw_ale_control_set) from [<c04fb8b4>] (cpsw_ale_destroy+0x2c/0x44)
[<c04fb8b4>] (cpsw_ale_destroy) from [<c04fea58>] (cpsw_probe+0xbd0/0x10c4)
[<c04fea58>] (cpsw_probe) from [<c047b2a0>] (platform_drv_probe+0x5c/0xc0)

Fixes: df828598a755 ("netdev: driver: ethernet: Add TI CPSW driver")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/ti/cpsw.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d2ff05..f60f8ab7c1e3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2641,13 +2641,12 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_runtime_disable_ret;
 	}
 	cpsw->version = readl(&cpsw->regs->id_ver);
-	pm_runtime_put_sync(&pdev->dev);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	cpsw->wr_regs = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(cpsw->wr_regs)) {
 		ret = PTR_ERR(cpsw->wr_regs);
-		goto clean_runtime_disable_ret;
+		goto clean_pm_runtime_put_ret;
 	}
 
 	memset(&dma_params, 0, sizeof(dma_params));
@@ -2684,7 +2683,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	default:
 		dev_err(priv->dev, "unknown version 0x%08x\n", cpsw->version);
 		ret = -ENODEV;
-		goto clean_runtime_disable_ret;
+		goto clean_pm_runtime_put_ret;
 	}
 	for (i = 0; i < cpsw->data.slaves; i++) {
 		struct cpsw_slave *slave = &cpsw->slaves[i];
@@ -2713,7 +2712,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	if (!cpsw->dma) {
 		dev_err(priv->dev, "error initializing dma\n");
 		ret = -ENOMEM;
-		goto clean_runtime_disable_ret;
+		goto clean_pm_runtime_put_ret;
 	}
 
 	cpsw->txch[0] = cpdma_chan_create(cpsw->dma, 0, cpsw_tx_handler, 0);
@@ -2815,12 +2814,16 @@ static int cpsw_probe(struct platform_device *pdev)
 		}
 	}
 
+	pm_runtime_put(&pdev->dev);
+
 	return 0;
 
 clean_ale_ret:
 	cpsw_ale_destroy(cpsw->ale);
 clean_dma_ret:
 	cpdma_ctlr_destroy(cpsw->dma);
+clean_pm_runtime_put_ret:
+	pm_runtime_put_sync(&pdev->dev);
 clean_runtime_disable_ret:
 	pm_runtime_disable(&pdev->dev);
 clean_ndev_ret:
-- 
2.7.3
