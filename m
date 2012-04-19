From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/4] stmmac: use custom init/exit functions in pm ops
Date: Thu, 19 Apr 2012 07:48:19 +0200
Message-ID: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:52820 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab2DSFse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 01:48:34 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 29B99205
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:31 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 647AA18C0
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:31 +0000 (GMT)
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
index 12bd221..ba30d38 100644
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
index cf64031..f85c93d 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -109,6 +109,7 @@ struct plat_stmmacenet_data {
 	int (*init)(struct platform_device *pdev);
 	void (*exit)(struct platform_device *pdev);
 	void *custom_cfg;
+	void *custom_data;
 	void *bsp_priv;
 };
 #endif
-- 
1.7.4.4
