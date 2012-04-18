From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2] stmmac: use custom init/exit functions in pm ops
Date: Wed, 18 Apr 2012 09:43:52 +0200
Message-ID: <1334735033-6969-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:58005 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750891Ab2DRHoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 03:44:06 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6553EC9
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:44:03 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D538F1E8C
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:44:02 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

Freeze and restore can call the custom init/exit functions.
Also the patch adds a custom data field that can be used
for storing platform data useful on restore the embedded
setup (e.g. GPIO, SYSCFG).

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   17 +++++++++++++----
 include/linux/stmmac.h                             |    1 +
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 116529a..727165e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -189,9 +189,6 @@ static int stmmac_pltfr_remove(struct platform_device *pdev)
 	if (priv->plat->exit)
 		priv->plat->exit(pdev);
 
-	if (priv->plat->exit)
-		priv->plat->exit(pdev);
-
 	platform_set_drvdata(pdev, NULL);
 
 	iounmap((void *)priv->ioaddr);
@@ -218,14 +215,26 @@ static int stmmac_pltfr_resume(struct device *dev)
 
 int stmmac_pltfr_freeze(struct device *dev)
 {
+	int ret;
+	struct plat_stmmacenet_data *plat_dat = dev_get_platdata(dev);
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
 
-	return stmmac_freeze(ndev);
+	ret = stmmac_freeze(ndev);
+	if (plat_dat->exit)
+		plat_dat->exit(pdev);
+
+	return ret;
 }
 
 int stmmac_pltfr_restore(struct device *dev)
 {
+	struct plat_stmmacenet_data *plat_dat = dev_get_platdata(dev);
 	struct net_device *ndev = dev_get_drvdata(dev);
+	struct platform_device *pdev = to_platform_device(dev);
+
+	if (plat_dat->init)
+		plat_dat->init(pdev);
 
 	return stmmac_restore(ndev);
 }
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..cab158d 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -56,6 +56,7 @@ struct plat_stmmacenet_data {
 	int (*init)(struct platform_device *pdev);
 	void (*exit)(struct platform_device *pdev);
 	void *custom_cfg;
+	void *custom_data;
 	void *bsp_priv;
 };
 #endif
-- 
1.7.4.4
