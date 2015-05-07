From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH RFC 1/2] stmac: support standalone platform drivers
Date: Thu,  7 May 2015 20:19:24 +0200
Message-ID: <1431022765-30715-2-git-send-email-manabian@gmail.com>
References: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:36591 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbbEGSTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 14:19:34 -0400
Received: by lagv1 with SMTP id v1so36763054lag.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 11:19:32 -0700 (PDT)
In-Reply-To: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prepare the stmmac platform code to support standalone drivers
by exporting the need functions and having of_match_device use
the match table reference already present in the driver struct.

Reorder the build order so that the most specific drivers are
built and registered first.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile          | 10 ++++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 14 +++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h |  4 ++++
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
index 73c2715a27f3..f35e2bcde55f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -4,9 +4,15 @@ stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o norm_desc.o	\
 	      mmc_core.o stmmac_hwtstamp.o stmmac_ptp.o $(stmmac-y)
 
+# ordering matters; keep stmmac_platform.o at the bottom
 obj-$(CONFIG_STMMAC_PLATFORM) += stmmac-platform.o
-stmmac-platform-objs:= stmmac_platform.o dwmac-meson.o dwmac-sunxi.o	\
-		       dwmac-sti.o dwmac-socfpga.o dwmac-rk.o
+stmmac-platform-objs:= \
+		dwmac-meson.o		\
+		dwmac-rk.o		\
+		dwmac-socfpga.o		\
+		dwmac-sti.o		\
+		dwmac-sunxi.o		\
+		stmmac_platform.o
 
 obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
 stmmac-pci-objs:= stmmac_pci.o
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 705bbdf93940..3263d40e00a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -128,11 +128,12 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 	struct device_node *np = pdev->dev.of_node;
 	struct stmmac_dma_cfg *dma_cfg;
 	const struct of_device_id *device;
+	struct device *dev = &pdev->dev;
 
 	if (!np)
 		return -ENODEV;
 
-	device = of_match_device(stmmac_dt_ids, &pdev->dev);
+	device = of_match_device(dev->driver->of_match_table, dev);
 	if (!device)
 		return -ENODEV;
 
@@ -267,7 +268,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
  * the necessary platform resources, invoke custom helper (if required) and
  * invoke the main probe function.
  */
-static int stmmac_pltfr_probe(struct platform_device *pdev)
+int stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
@@ -373,6 +374,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_probe);
 
 /**
  * stmmac_pltfr_remove
@@ -380,7 +382,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
  * Description: this function calls the main to free the net resources
  * and calls the platforms hook and release the resources (e.g. mem).
  */
-static int stmmac_pltfr_remove(struct platform_device *pdev)
+int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
@@ -394,6 +396,7 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(stmmac_pltfr_remove);
 
 #ifdef CONFIG_PM_SLEEP
 /**
@@ -437,8 +440,9 @@ static int stmmac_pltfr_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-static SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops,
-			 stmmac_pltfr_suspend, stmmac_pltfr_resume);
+SIMPLE_DEV_PM_OPS(stmmac_pltfr_pm_ops, stmmac_pltfr_suspend,
+				       stmmac_pltfr_resume);
+EXPORT_SYMBOL_GPL(stmmac_pltfr_pm_ops);
 
 static struct platform_driver stmmac_pltfr_driver = {
 	.probe = stmmac_pltfr_probe,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
index 093eb99e5ffd..23d10f6e8846 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
@@ -19,6 +19,10 @@
 #ifndef __STMMAC_PLATFORM_H__
 #define __STMMAC_PLATFORM_H__
 
+int stmmac_pltfr_probe(struct platform_device *pdev);
+int stmmac_pltfr_remove(struct platform_device *pdev);
+extern const struct dev_pm_ops stmmac_pltfr_pm_ops;
+
 extern const struct stmmac_of_data meson6_dwmac_data;
 extern const struct stmmac_of_data sun7i_gmac_data;
 extern const struct stmmac_of_data stih4xx_dwmac_data;
-- 
1.8.0
