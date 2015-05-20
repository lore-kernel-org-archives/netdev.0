From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 2/4] stmmac: let stmmac_dvr_probe take a struct of resources
Date: Wed, 20 May 2015 20:03:07 +0200
Message-ID: <1432144989-28283-3-git-send-email-manabian@gmail.com>
References: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36570 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757AbbETSDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:03:31 -0400
Received: by lagv1 with SMTP id v1so85677893lag.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:03:29 -0700 (PDT)
In-Reply-To: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creat a struct that contain all the resources that needs to be
assigned to the priv struct in stmmac_dvr_probe. This makes it
possible to factor out more common code from the other probe
functions and also use this struct to hold the resources as
they are fetched.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       | 10 ++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 15 ++++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   | 10 +++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 45 +++++++++-------------
 4 files changed, 45 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 2ac9552d1fa3..b1687adb8e02 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -34,6 +34,14 @@
 #include <linux/ptp_clock_kernel.h>
 #include <linux/reset.h>
 
+struct stmmac_resources {
+	void __iomem *addr;
+	const char *mac;
+	int wol_irq;
+	int lpi_irq;
+	int irq;
+};
+
 struct stmmac_tx_info {
 	dma_addr_t buf;
 	bool map_as_page;
@@ -131,7 +139,7 @@ int stmmac_suspend(struct net_device *ndev);
 int stmmac_dvr_remove(struct net_device *ndev);
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
-				     void __iomem *addr);
+				     struct stmmac_resources *res);
 void stmmac_disable_eee_mode(struct stmmac_priv *priv);
 bool stmmac_eee_init(struct stmmac_priv *priv);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index fae9195c8ff7..e8b630a1f1ef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2799,7 +2799,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
  * stmmac_dvr_probe
  * @device: device pointer
  * @plat_dat: platform data pointer
- * @addr: iobase memory address
+ * @res: stmmac resource pointer
  * Description: this is the main probe function used to
  * call the alloc_etherdev, allocate the priv structure.
  * Return:
@@ -2808,7 +2808,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
  */
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
-				     void __iomem *addr)
+				     struct stmmac_resources *res)
 {
 	int ret = 0;
 	struct net_device *ndev = NULL;
@@ -2827,8 +2827,15 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	stmmac_set_ethtool_ops(ndev);
 	priv->pause = pause;
 	priv->plat = plat_dat;
-	priv->ioaddr = addr;
-	priv->dev->base_addr = (unsigned long)addr;
+	priv->ioaddr = res->addr;
+	priv->dev->base_addr = (unsigned long)res->addr;
+
+	priv->dev->irq = res->irq;
+	priv->wol_irq = res->wol_irq;
+	priv->lpi_irq = res->lpi_irq;
+
+	if (res->mac)
+		memcpy(priv->dev->dev_addr, res->mac, ETH_ALEN);
 
 	dev_set_drvdata(device, priv);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 4743d0017d79..2c663ec2dfb3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -163,6 +163,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 {
 	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
 	struct plat_stmmacenet_data *plat;
+	struct stmmac_resources res;
 	struct stmmac_priv *priv;
 	int i;
 	int ret;
@@ -214,13 +215,16 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 
 	pci_enable_msi(pdev);
 
-	priv = stmmac_dvr_probe(&pdev->dev, plat, pcim_iomap_table(pdev)[i]);
+	memset(&res, 0, sizeof(res));
+	res.addr = pcim_iomap_table(pdev)[i];
+	res.wol_irq = pdev->irq;
+	res.irq = pdev->irq;
+
+	priv = stmmac_dvr_probe(&pdev->dev, plat, &res);
 	if (IS_ERR(priv)) {
 		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
 		return PTR_ERR(priv);
 	}
-	priv->dev->irq = pdev->irq;
-	priv->wol_irq = pdev->irq;
 
 	dev_dbg(&pdev->dev, "STMMAC PCI driver registration completed\n");
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6db27dee0901..6b7481afbdf7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -251,25 +251,25 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
  */
 int stmmac_pltfr_probe(struct platform_device *pdev)
 {
+	struct stmmac_resources stmmac_res;
 	int ret = 0;
 	struct resource *res;
 	struct device *dev = &pdev->dev;
-	void __iomem *addr = NULL;
 	struct stmmac_priv *priv = NULL;
 	struct plat_stmmacenet_data *plat_dat = NULL;
-	const char *mac = NULL;
-	int irq, wol_irq, lpi_irq;
+
+	memset(&stmmac_res, 0, sizeof(stmmac_res));
 
 	/* Get IRQ information early to have an ability to ask for deferred
 	 * probe if needed before we went too far with resource allocation.
 	 */
-	irq = platform_get_irq_byname(pdev, "macirq");
-	if (irq < 0) {
-		if (irq != -EPROBE_DEFER) {
+	stmmac_res.irq = platform_get_irq_byname(pdev, "macirq");
+	if (stmmac_res.irq < 0) {
+		if (stmmac_res.irq != -EPROBE_DEFER) {
 			dev_err(dev,
 				"MAC IRQ configuration information not found\n");
 		}
-		return irq;
+		return stmmac_res.irq;
 	}
 
 	/* On some platforms e.g. SPEAr the wake up irq differs from the mac irq
@@ -279,21 +279,21 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	 * In case the wake up interrupt is not passed from the platform
 	 * so the driver will continue to use the mac irq (ndev->irq)
 	 */
-	wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
-	if (wol_irq < 0) {
-		if (wol_irq == -EPROBE_DEFER)
+	stmmac_res.wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
+	if (stmmac_res.wol_irq < 0) {
+		if (stmmac_res.wol_irq == -EPROBE_DEFER)
 			return -EPROBE_DEFER;
-		wol_irq = irq;
+		stmmac_res.wol_irq = stmmac_res.irq;
 	}
 
-	lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
-	if (lpi_irq == -EPROBE_DEFER)
+	stmmac_res.lpi_irq = platform_get_irq_byname(pdev, "eth_lpi");
+	if (stmmac_res.lpi_irq == -EPROBE_DEFER)
 		return -EPROBE_DEFER;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	addr = devm_ioremap_resource(dev, res);
-	if (IS_ERR(addr))
-		return PTR_ERR(addr);
+	stmmac_res.addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(stmmac_res.addr))
+		return PTR_ERR(stmmac_res.addr);
 
 	plat_dat = dev_get_platdata(&pdev->dev);
 
@@ -313,7 +313,7 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	plat_dat->unicast_filter_entries = 1;
 
 	if (pdev->dev.of_node) {
-		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
+		ret = stmmac_probe_config_dt(pdev, plat_dat, &stmmac_res.mac);
 		if (ret) {
 			pr_err("%s: main dt probe failed", __func__);
 			return ret;
@@ -334,21 +334,12 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 			return ret;
 	}
 
-	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
+	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, &stmmac_res);
 	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
 		return PTR_ERR(priv);
 	}
 
-	/* Copy IRQ values to priv structure which is now avaialble */
-	priv->dev->irq = irq;
-	priv->wol_irq = wol_irq;
-	priv->lpi_irq = lpi_irq;
-
-	/* Get MAC address if available (DT) */
-	if (mac)
-		memcpy(priv->dev->dev_addr, mac, ETH_ALEN);
-
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
-- 
1.8.0
