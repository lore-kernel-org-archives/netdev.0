From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH v2 2/5] stmmac: dwmac-socfpga: add PM ops and resume function
Date: Sun,  1 May 2016 22:58:20 +0200
Message-ID: <1462136303-16825-3-git-send-email-manabian@gmail.com>
References: <1462136303-16825-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36783 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbcEAU7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:59:22 -0400
Received: by mail-lf0-f66.google.com with SMTP id y84so23149733lfc.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:59:21 -0700 (PDT)
In-Reply-To: <1462136303-16825-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the needed PM callbacks in the driver instead of
relying on the init/exit hooks in stmmac_platform. This gives
the driver more flexibility in how the code is organized.

Eventually the init/exit callbacks will be deprecated in favor
of the standard PM callbacks and driver remove function.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Marek Vasut <marex@denx.de>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index 784eb53..789013a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -261,7 +261,6 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	}
 
 	plat_dat->bsp_priv = dwmac;
-	plat_dat->init = socfpga_dwmac_init;
 	plat_dat->fix_mac_speed = socfpga_dwmac_fix_mac_speed;
 
 	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
@@ -271,6 +270,21 @@ static int socfpga_dwmac_probe(struct platform_device *pdev)
 	return ret;
 }
 
+#ifdef CONFIG_PM_SLEEP
+static int socfpga_dwmac_resume(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct stmmac_priv *priv = netdev_priv(ndev);
+
+	socfpga_dwmac_init(pdev, priv->plat->bsp_priv);
+
+	return stmmac_resume(dev);
+}
+#endif /* CONFIG_PM_SLEEP */
+
+SIMPLE_DEV_PM_OPS(socfpga_dwmac_pm_ops, stmmac_suspend, socfpga_dwmac_resume);
+
 static const struct of_device_id socfpga_dwmac_match[] = {
 	{ .compatible = "altr,socfpga-stmmac" },
 	{ }
@@ -282,7 +296,7 @@ static struct platform_driver socfpga_dwmac_driver = {
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "socfpga-dwmac",
-		.pm		= &stmmac_pltfr_pm_ops,
+		.pm		= &socfpga_dwmac_pm_ops,
 		.of_match_table = socfpga_dwmac_match,
 	},
 };
-- 
2.8.0
