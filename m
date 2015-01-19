From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v1 3/4] net: stmmac: dwmac-rk: Use standard devicetree property for phy regulator
Date: Mon, 19 Jan 2015 18:08:08 +0000
Message-ID: <1421690889-11901-4-git-send-email-romain.perier@gmail.com>
References: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	roger.chen@rock-chips.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, dwmac-rk uses a custom propety "phy_regulator" to get the name of the
right regulator to use to power on or power off the phy. This commit converts the
driver to use phy-supply devicetree property and the corresponding API, it cleans
the code a bit and make it simpler to maintain.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 61 ++++++++------------------
 1 file changed, 19 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 06e1637..8a8091c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -32,7 +32,7 @@
 struct rk_priv_data {
 	struct platform_device *pdev;
 	int phy_iface;
-	char regulator[32];
+	struct regulator *regulator;
 
 	bool clk_enabled;
 	bool clock_input;
@@ -287,46 +287,25 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 
 static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 {
-	struct regulator *ldo;
-	char *ldostr = bsp_priv->regulator;
+	struct regulator *ldo = bsp_priv->regulator;
 	int ret;
 	struct device *dev = &bsp_priv->pdev->dev;
 
-	if (!ldostr) {
-		dev_err(dev, "%s: no ldo found\n", __func__);
+	if (!ldo) {
+		dev_err(dev, "%s: no regulator found\n", __func__);
 		return -1;
 	}
 
-	ldo = regulator_get(NULL, ldostr);
-	if (!ldo) {
-		dev_err(dev, "\n%s get ldo %s failed\n", __func__, ldostr);
+	if (enable) {
+		ret = regulator_enable(ldo);
+		if (ret)
+			dev_err(dev, "%s: fail to enable phy-supply\n",
+				__func__);
 	} else {
-		if (enable) {
-			if (!regulator_is_enabled(ldo)) {
-				ret = regulator_enable(ldo);
-				if (ret != 0)
-					dev_err(dev, "%s: fail to enable %s\n",
-						__func__, ldostr);
-				else
-					dev_info(dev, "turn on ldo done.\n");
-			} else {
-				dev_warn(dev, "%s is enabled before enable",
-					 ldostr);
-			}
-		} else {
-			if (regulator_is_enabled(ldo)) {
-				ret = regulator_disable(ldo);
-				if (ret != 0)
-					dev_err(dev, "%s: fail to disable %s\n",
-						__func__, ldostr);
-				else
-					dev_info(dev, "turn off ldo done.\n");
-			} else {
-				dev_warn(dev, "%s is disabled before disable",
-					 ldostr);
-			}
-		}
-		regulator_put(ldo);
+		ret = regulator_disable(ldo);
+		if (ret)
+			dev_err(dev, "%s: fail to disable phy-supply\n",
+				__func__);
 	}
 
 	return 0;
@@ -346,14 +325,12 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 
 	bsp_priv->phy_iface = of_get_phy_mode(dev->of_node);
 
-	ret = of_property_read_string(dev->of_node, "phy_regulator", &strings);
-	if (ret) {
-		dev_warn(dev, "%s: Can not read property: phy_regulator.\n",
-			 __func__);
-	} else {
-		dev_info(dev, "%s: PHY power controlled by regulator(%s).\n",
-			 __func__, strings);
-		strcpy(bsp_priv->regulator, strings);
+	bsp_priv->regulator = devm_regulator_get_optional(dev, "phy");
+	if (IS_ERR(bsp_priv->regulator)) {
+		if (PTR_ERR(bsp_priv->regulator) == -EPROBE_DEFER)
+			return -EPROBE_DEFER;
+		dev_err(dev, "no regulator found\n");
+		bsp_priv->regulator = NULL;
 	}
 
 	ret = of_property_read_string(dev->of_node, "clock_in_out", &strings);
-- 
1.9.1
