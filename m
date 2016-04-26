From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 1/5] stmmac: let remove/resume/suspend functions take device pointer
Date: Tue, 26 Apr 2016 23:24:55 +0200
Message-ID: <1461705899-17015-2-git-send-email-manabian@gmail.com>
References: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, marex@denx.de,
	dinguyen@opensource.altera.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35616 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbcDZVZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 17:25:28 -0400
Received: by mail-lf0-f66.google.com with SMTP id u64so4285862lff.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 14:25:27 -0700 (PDT)
In-Reply-To: <1461705899-17015-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change stmmac_remove/resume/suspend to take a device pointer so
they can be used directly by drivers that doesn't need to perform
anything device specific.

This lets us remove the PCI pm functions and later simplifiy the
platform drivers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Tested-by: Marek Vasut <marex@denx.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 15 ++++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   | 24 ++--------------------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  6 +++---
 4 files changed, 17 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index ff67506..59ae608 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -148,9 +148,9 @@ void stmmac_set_ethtool_ops(struct net_device *netdev);
 
 int stmmac_ptp_register(struct stmmac_priv *priv);
 void stmmac_ptp_unregister(struct stmmac_priv *priv);
-int stmmac_resume(struct net_device *ndev);
-int stmmac_suspend(struct net_device *ndev);
-int stmmac_dvr_remove(struct net_device *ndev);
+int stmmac_resume(struct device *dev);
+int stmmac_suspend(struct device *dev);
+int stmmac_dvr_remove(struct device *dev);
 int stmmac_dvr_probe(struct device *device,
 		     struct plat_stmmacenet_data *plat_dat,
 		     struct stmmac_resources *res);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b87edb7..fd5ab7b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3350,12 +3350,13 @@ EXPORT_SYMBOL_GPL(stmmac_dvr_probe);
 
 /**
  * stmmac_dvr_remove
- * @ndev: net device pointer
+ * @dev: device pointer
  * Description: this function resets the TX/RX processes, disables the MAC RX/TX
  * changes the link status, releases the DMA descriptor rings.
  */
-int stmmac_dvr_remove(struct net_device *ndev)
+int stmmac_dvr_remove(struct device *dev)
 {
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 
 	pr_info("%s:\n\tremoving driver", __func__);
@@ -3381,13 +3382,14 @@ EXPORT_SYMBOL_GPL(stmmac_dvr_remove);
 
 /**
  * stmmac_suspend - suspend callback
- * @ndev: net device pointer
+ * @dev: device pointer
  * Description: this is the function to suspend the device and it is called
  * by the platform driver to stop the network queue, release the resources,
  * program the PMT register (for WoL), clean and release driver resources.
  */
-int stmmac_suspend(struct net_device *ndev)
+int stmmac_suspend(struct device *dev)
 {
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long flags;
 
@@ -3430,12 +3432,13 @@ EXPORT_SYMBOL_GPL(stmmac_suspend);
 
 /**
  * stmmac_resume - resume callback
- * @ndev: net device pointer
+ * @dev: device pointer
  * Description: when resume this function is invoked to setup the DMA and CORE
  * in a usable state.
  */
-int stmmac_resume(struct net_device *ndev)
+int stmmac_resume(struct device *dev)
 {
+	struct net_device *ndev = dev_get_drvdata(dev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	unsigned long flags;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index ae43887..56c8a23 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -231,30 +231,10 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
  */
 static void stmmac_pci_remove(struct pci_dev *pdev)
 {
-	struct net_device *ndev = pci_get_drvdata(pdev);
-
-	stmmac_dvr_remove(ndev);
-}
-
-#ifdef CONFIG_PM_SLEEP
-static int stmmac_pci_suspend(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *ndev = pci_get_drvdata(pdev);
-
-	return stmmac_suspend(ndev);
-}
-
-static int stmmac_pci_resume(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *ndev = pci_get_drvdata(pdev);
-
-	return stmmac_resume(ndev);
+	stmmac_dvr_remove(&pdev->dev);
 }
-#endif
 
-static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_pci_suspend, stmmac_pci_resume);
+static SIMPLE_DEV_PM_OPS(stmmac_pm_ops, stmmac_suspend, stmmac_resume);
 
 #define STMMAC_VENDOR_ID 0x700
 #define STMMAC_QUARK_ID  0x0937
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index effaa4f..409db91 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -386,7 +386,7 @@ int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	int ret = stmmac_dvr_remove(ndev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
 
 	if (priv->plat->exit)
 		priv->plat->exit(pdev, priv->plat->bsp_priv);
@@ -410,7 +410,7 @@ static int stmmac_pltfr_suspend(struct device *dev)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(dev);
 
-	ret = stmmac_suspend(ndev);
+	ret = stmmac_suspend(dev);
 	if (priv->plat->exit)
 		priv->plat->exit(pdev, priv->plat->bsp_priv);
 
@@ -433,7 +433,7 @@ static int stmmac_pltfr_resume(struct device *dev)
 	if (priv->plat->init)
 		priv->plat->init(pdev, priv->plat->bsp_priv);
 
-	return stmmac_resume(ndev);
+	return stmmac_resume(dev);
 }
 #endif /* CONFIG_PM_SLEEP */
 
-- 
2.8.0
