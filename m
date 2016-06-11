From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH 1/3] net: stmmac: allow to split suspend/resume from init/exit callbacks
Date: Fri, 10 Jun 2016 18:00:37 -0700
Message-ID: <1465606839-7722-2-git-send-email-vpalatin@chromium.org>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com>
 <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
