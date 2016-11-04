From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 3/7] stmmac: dwmac-sti: add PM ops and resume function
Date: Fri,  4 Nov 2016 18:54:07 +0100
Message-ID: <20161104175411.12943-4-manabian@gmail.com>
References: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35404 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935546AbcKDRz1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:27 -0400
Received: by mail-lf0-f66.google.com with SMTP id p100so5009021lfg.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:26 -0700 (PDT)
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement PM callbacks and driver remove in the driver instead
of relying on the init/exit hooks in stmmac_platform. This gives
the driver more flexibility in how the code is organized.

Eventually the init/exit callbacks will be deprecated in favor
of the standard PM callbacks and driver remove function.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 47 +++++++++++++++++++------
 1 file changed, 37 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index f009bf4..bd6db22 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -253,12 +253,6 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-static void sti_dwmac_exit(struct platform_device *pdev, void *priv)
-{
-	struct sti_dwmac *dwmac = priv;
-
-	clk_disable_unprepare(dwmac->clk);
-}
 static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 				struct platform_device *pdev)
 {
@@ -352,8 +346,6 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	dwmac->fix_retime_src = data->fix_retime_src;
 
 	plat_dat->bsp_priv = dwmac;
-	plat_dat->init = sti_dwmac_init;
-	plat_dat->exit = sti_dwmac_exit;
 	plat_dat->fix_mac_speed = data->fix_retime_src;
 
 	ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);
@@ -363,6 +355,41 @@ static int sti_dwmac_probe(struct platform_device *pdev)
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
+static int sti_dwmac_remove(struct platform_device *pdev)
+{
+	struct sti_dwmac *dwmac = get_stmmac_bsp_priv(&pdev->dev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
+
+	clk_disable_unprepare(dwmac->clk);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int sti_dwmac_suspend(struct device *dev)
+{
+	struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
+	int ret = stmmac_suspend(dev);
+
+	clk_disable_unprepare(dwmac->clk);
+
+	return ret;
+}
+
+static int sti_dwmac_resume(struct device *dev)
+{
+	struct sti_dwmac *dwmac = get_stmmac_bsp_priv(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+
+	sti_dwmac_init(pdev, dwmac);
+
+	return stmmac_resume(dev);
+}
+#endif /* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(sti_dwmac_pm_ops, sti_dwmac_suspend,
+					   sti_dwmac_resume);
+
 static const struct sti_dwmac_of_data stih4xx_dwmac_data = {
 	.fix_retime_src = stih4xx_fix_retime_src,
 };
@@ -382,10 +409,10 @@ MODULE_DEVICE_TABLE(of, sti_dwmac_match);
 
 static struct platform_driver sti_dwmac_driver = {
 	.probe  = sti_dwmac_probe,
-	.remove = stmmac_pltfr_remove,
+	.remove = sti_dwmac_remove,
 	.driver = {
 		.name           = "sti-dwmac",
-		.pm		= &stmmac_pltfr_pm_ops,
+		.pm		= &sti_dwmac_pm_ops,
 		.of_match_table = sti_dwmac_match,
 	},
 };
-- 
2.10.2
