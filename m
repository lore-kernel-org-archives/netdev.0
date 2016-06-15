From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH v2 1/3] net: stmmac: allow to split suspend/resume from init/exit callbacks
Date: Wed, 15 Jun 2016 11:32:21 -0700
Message-ID: <a61d39032b6d31ca936b6a3bfe92c93246a5c833.1466015458.git.vpalatin@chromium.org>
References: <CAP_ceTxFuCsqRQJ_9GMc5PSKqczA8Qwaa0jX22wQ2Dq=+GZUuQ@mail.gmail.com>
 <cover.1466015458.git.vpalatin@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32968 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbcFOScs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 14:32:48 -0400
Received: by mail-pf0-f172.google.com with SMTP id i123so7471502pfg.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 11:32:48 -0700 (PDT)
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
References: <cover.1466015458.git.vpalatin@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let the stmmac platform drivers provide dedicated suspend and resume
callbacks rather than always re-using the init and exits callbacks.
If the driver does not provide the suspend or resume callback, we fall
back to the old behavior trying to use exit or init.

This allows a specific platform to perform only a partial power-down on
suspend if Wake-on-Lan is enabled but always perform the full shutdown
sequence if the module is unloaded.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 8 ++++++--
 include/linux/stmmac.h                                | 2 ++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 409db91..a96714d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -411,7 +411,9 @@ static int stmmac_pltfr_suspend(struct device *dev)
 	struct platform_device *pdev = to_platform_device(dev);
 
 	ret = stmmac_suspend(dev);
-	if (priv->plat->exit)
+	if (priv->plat->suspend)
+		priv->plat->suspend(pdev, priv->plat->bsp_priv);
+	else if (priv->plat->exit)
 		priv->plat->exit(pdev, priv->plat->bsp_priv);
 
 	return ret;
@@ -430,7 +432,9 @@ static int stmmac_pltfr_resume(struct device *dev)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct platform_device *pdev = to_platform_device(dev);
 
-	if (priv->plat->init)
+	if (priv->plat->resume)
+		priv->plat->resume(pdev, priv->plat->bsp_priv);
+	else if (priv->plat->init)
 		priv->plat->init(pdev, priv->plat->bsp_priv);
 
 	return stmmac_resume(dev);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index ffdaca9..0507dbf 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -135,6 +135,8 @@ struct plat_stmmacenet_data {
 	void (*bus_setup)(void __iomem *ioaddr);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
+	void (*suspend)(struct platform_device *pdev, void *priv);
+	void (*resume)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
 	struct stmmac_axi *axi;
 	int has_gmac4;
-- 
2.8.0.rc3.226.g39d4020
