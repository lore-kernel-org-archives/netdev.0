From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH v2 2/3] net: stmmac: dwmac-rk: keep the PHY up for WoL
Date: Wed, 15 Jun 2016 11:32:22 -0700
Message-ID: <ddca4f2f83c02f15722121aa4c0d00d8ee82eee1.1466015458.git.vpalatin@chromium.org>
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
Received: from mail-pf0-f171.google.com ([209.85.192.171]:32976 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933066AbcFOSc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 14:32:57 -0400
Received: by mail-pf0-f171.google.com with SMTP id i123so7471915pfg.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 11:32:56 -0700 (PDT)
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
In-Reply-To: <cover.1466015458.git.vpalatin@chromium.org>
References: <cover.1466015458.git.vpalatin@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When suspending the machine, do not shutdown the external PHY by cutting
its regulator in the mac platform driver suspend code if Wake-on-Lan is enabled,
else it cannot wake us up.
In order to do this, split the suspend/resume callbacks from the
init/exit callbacks, so we can condition the power-down on the lack of
need to wake-up from the LAN but do it unconditionally when unloading the
module.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 48 +++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 0cd3ecf..63c2e4f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -46,6 +46,7 @@ struct rk_priv_data {
 	struct platform_device *pdev;
 	int phy_iface;
 	struct regulator *regulator;
+	bool suspended;
 	const struct rk_gmac_ops *ops;
 
 	bool clk_enabled;
@@ -529,9 +530,8 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 	return bsp_priv;
 }
 
-static int rk_gmac_init(struct platform_device *pdev, void *priv)
+static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 {
-	struct rk_priv_data *bsp_priv = priv;
 	int ret;
 
 	ret = phy_power_on(bsp_priv, true);
@@ -545,14 +545,50 @@ static int rk_gmac_init(struct platform_device *pdev, void *priv)
 	return 0;
 }
 
-static void rk_gmac_exit(struct platform_device *pdev, void *priv)
+static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
-	struct rk_priv_data *gmac = priv;
-
 	phy_power_on(gmac, false);
 	gmac_clk_enable(gmac, false);
 }
 
+static int rk_gmac_init(struct platform_device *pdev, void *priv)
+{
+	struct rk_priv_data *bsp_priv = priv;
+
+	return rk_gmac_powerup(bsp_priv);
+}
+
+static void rk_gmac_exit(struct platform_device *pdev, void *priv)
+{
+	struct rk_priv_data *bsp_priv = priv;
+
+	rk_gmac_powerdown(bsp_priv);
+}
+
+static void rk_gmac_suspend(struct platform_device *pdev, void *priv)
+{
+	struct rk_priv_data *bsp_priv = priv;
+
+	/* Keep the PHY up if we use Wake-on-Lan. */
+	if (device_may_wakeup(&pdev->dev))
+		return;
+
+	rk_gmac_powerdown(bsp_priv);
+	bsp_priv->suspended = true;
+}
+
+static void rk_gmac_resume(struct platform_device *pdev, void *priv)
+{
+	struct rk_priv_data *bsp_priv = priv;
+
+	/* The PHY was up for Wake-on-Lan. */
+	if (!bsp_priv->suspended)
+		return;
+
+	rk_gmac_powerup(bsp_priv);
+	bsp_priv->suspended = false;
+}
+
 static void rk_fix_speed(void *priv, unsigned int speed)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -591,6 +627,8 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	plat_dat->init = rk_gmac_init;
 	plat_dat->exit = rk_gmac_exit;
 	plat_dat->fix_mac_speed = rk_fix_speed;
+	plat_dat->suspend = rk_gmac_suspend;
+	plat_dat->resume = rk_gmac_resume;
 
 	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
 	if (IS_ERR(plat_dat->bsp_priv))
-- 
2.8.0.rc3.226.g39d4020
