From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [Stlinux-devel] [PATCH linux-stm 4/4] net:stmmac: convert driver to use devm_request_and_ioremap.
Date: Thu, 30 Aug 2012 16:51:09 +0100
Message-ID: <1346341869-20211-1-git-send-email-srinivas.kandagatla@st.com>
Cc: peppe.cavallaro@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:37846 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752544Ab2H3PwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 11:52:00 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 917BAC2
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:51:58 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 449E04E51
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 15:51:58 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch moves calls to ioremap and request_mem_region to
devm_request_and_ioremap call.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   40 ++++----------------
 1 files changed, 8 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index b4ffdc7..ed112b5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -78,6 +78,7 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 {
 	int ret = 0;
 	struct resource *res;
+	struct device *dev = &pdev->dev;
 	void __iomem *addr = NULL;
 	struct stmmac_priv *priv = NULL;
 	struct plat_stmmacenet_data *plat_dat = NULL;
@@ -87,18 +88,10 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 	if (!res)
 		return -ENODEV;
 
-	if (!request_mem_region(res->start, resource_size(res), pdev->name)) {
-		pr_err("%s: ERROR: memory allocation failed"
-		       "cannot get the I/O addr 0x%x\n",
-		       __func__, (unsigned int)res->start);
-		return -EBUSY;
-	}
-
-	addr = ioremap(res->start, resource_size(res));
+	addr = devm_request_and_ioremap(dev, res);
 	if (!addr) {
 		pr_err("%s: ERROR: memory mapping failed", __func__);
-		ret = -ENOMEM;
-		goto out_release_region;
+		return -ENOMEM;
 	}
 
 	if (pdev->dev.of_node) {
@@ -107,14 +100,13 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 					GFP_KERNEL);
 		if (!plat_dat) {
 			pr_err("%s: ERROR: no memory", __func__);
-			ret = -ENOMEM;
-			goto out_unmap;
+			return  -ENOMEM;
 		}
 
 		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
 			pr_err("%s: main dt probe failed", __func__);
-			goto out_unmap;
+			return ret;
 		}
 	} else {
 		plat_dat = pdev->dev.platform_data;
@@ -124,13 +116,13 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 	if (plat_dat->init) {
 		ret = plat_dat->init(pdev);
 		if (unlikely(ret))
-			goto out_unmap;
+			return ret;
 	}
 
 	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
 	if (!priv) {
 		pr_err("%s: main driver probe failed", __func__);
-		goto out_unmap;
+		return -ENODEV;
 	}
 
 	/* Get MAC address if available (DT) */
@@ -142,8 +134,7 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 	if (priv->dev->irq == -ENXIO) {
 		pr_err("%s: ERROR: MAC IRQ configuration "
 		       "information not found\n", __func__);
-		ret = -ENXIO;
-		goto out_unmap;
+		return -ENXIO;
 	}
 
 	/*
@@ -165,15 +156,6 @@ static int __devinit stmmac_pltfr_probe(struct platform_device *pdev)
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
-
-out_unmap:
-	iounmap(addr);
-	platform_set_drvdata(pdev, NULL);
-
-out_release_region:
-	release_mem_region(res->start, resource_size(res));
-
-	return ret;
 }
 
 /**
@@ -186,8 +168,6 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct stmmac_priv *priv = netdev_priv(ndev);
-	void __iomem *addr = priv->ioaddr;
-	struct resource *res;
 	int ret = stmmac_dvr_remove(ndev);
 
 	if (priv->plat->exit)
@@ -195,10 +175,6 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, NULL);
 
-	iounmap(addr);
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	release_mem_region(res->start, resource_size(res));
-
 	return ret;
 }
 
-- 
1.7.0.4
