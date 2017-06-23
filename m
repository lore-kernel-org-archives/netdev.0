From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Fri, 23 Jun 2017 12:59:07 +0800
Message-ID: <1498193947-8011-1-git-send-email-david.wu@rock-chips.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
        olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498192929-7519-1-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

To make internal phy worked, need to configure the phy_clock,
phy cru_reset and related registers.

Change-Id: I6971c0a769754b824b1b908b56080cbaf7867d13
Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |  3 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 82 ++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 8f42755..0514f69 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -22,6 +22,7 @@ Required properties:
 	   <&cru SCLK_MACREF_OUT> clock gate for RMII reference clock output
 	   <&cru ACLK_GMAC>: AXI clock gate for GMAC
 	   <&cru PCLK_GMAC>: APB clock gate for GMAC
+	   <&cru MAC_PHY>: clock for internal macphy
  - clock-names: One name for each entry in the clocks property.
  - phy-mode: See ethernet.txt file in the same directory.
  - pinctrl-names: Names corresponding to the numbered pinctrl states.
@@ -35,6 +36,8 @@ Required properties:
  - assigned-clocks: main clock, should be <&cru SCLK_MAC>;
  - assigned-clock-parents = parent of main clock.
    can be <&ext_gmac> or <&cru SCLK_MAC_PLL>.
+ - phy-type: For internal phy, it must be "internal"; For external phy, no need
+   to configure this.
 
 Optional properties:
  - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index a8e8fd5..c1a1413 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -41,6 +41,7 @@ struct rk_gmac_ops {
 	void (*set_to_rmii)(struct rk_priv_data *bsp_priv);
 	void (*set_rgmii_speed)(struct rk_priv_data *bsp_priv, int speed);
 	void (*set_rmii_speed)(struct rk_priv_data *bsp_priv, int speed);
+	void (*internal_phy_powerup)(struct rk_priv_data *bsp_priv);
 };
 
 struct rk_priv_data {
@@ -52,6 +53,7 @@ struct rk_priv_data {
 
 	bool clk_enabled;
 	bool clock_input;
+	bool internal_phy;
 
 	struct clk *clk_mac;
 	struct clk *gmac_clkin;
@@ -61,6 +63,9 @@ struct rk_priv_data {
 	struct clk *clk_mac_refout;
 	struct clk *aclk_mac;
 	struct clk *pclk_mac;
+	struct clk *clk_macphy;
+
+	struct reset_control *macphy_reset;
 
 	int tx_delay;
 	int rx_delay;
@@ -750,6 +755,48 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	.set_rmii_speed = rk3399_set_rmii_speed,
 };
 
+#define RK_GRF_MACPHY_CON0		0xb00
+#define RK_GRF_MACPHY_CON1		0xb04
+#define RK_GRF_MACPHY_CON2		0xb08
+#define RK_GRF_MACPHY_CON3		0xb0c
+
+#define RK_MACPHY_ENABLE		GRF_BIT(0)
+#define RK_MACPHY_DISABLE		GRF_CLR_BIT(0)
+#define RK_MACPHY_CFG_CLK_50M		GRF_BIT(14)
+#define RK_GMAC2PHY_RMII_MODE		(GRF_BIT(6) | GRF_CLR_BIT(7))
+#define RK_GRF_CON2_MACPHY_ID		HIWORD_UPDATE(0x1234, 0xffff, 0)
+#define RK_GRF_CON3_MACPHY_ID		HIWORD_UPDATE(0x35, 0x3f, 0)
+
+static void rk_gmac_internal_phy_powerup(struct rk_priv_data *priv)
+{
+	if (priv->ops->internal_phy_powerup)
+		priv->ops->internal_phy_powerup(priv);
+
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_CFG_CLK_50M);
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_GMAC2PHY_RMII_MODE);
+
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON2, RK_GRF_CON2_MACPHY_ID);
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON3, RK_GRF_CON3_MACPHY_ID);
+
+	/* disable macphy, the default value is enabled */
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
+	if (priv->macphy_reset)
+		reset_control_assert(priv->macphy_reset);
+	usleep_range(10, 20);
+	if (priv->macphy_reset)
+		reset_control_deassert(priv->macphy_reset);
+	usleep_range(10, 20);
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
+	msleep(30);
+}
+
+static void rk_gmac_internal_phy_powerdown(struct rk_priv_data *priv)
+{
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
+	if (priv->macphy_reset)
+		reset_control_assert(priv->macphy_reset);
+}
+
 static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
@@ -803,6 +850,14 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 			clk_set_rate(bsp_priv->clk_mac, 50000000);
 	}
 
+	if (bsp_priv->internal_phy) {
+		bsp_priv->clk_macphy = devm_clk_get(dev, "clk_macphy");
+		if (IS_ERR(bsp_priv->clk_macphy))
+			dev_err(dev, "cannot get %s clock\n", "clk_macphy");
+		else
+			clk_set_rate(bsp_priv->clk_macphy, 50000000);
+	}
+
 	return 0;
 }
 
@@ -826,6 +881,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_macphy))
+				clk_prepare_enable(bsp_priv->clk_macphy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_prepare_enable(bsp_priv->aclk_mac);
 
@@ -858,6 +916,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_macphy))
+				clk_disable_unprepare(bsp_priv->clk_macphy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_disable_unprepare(bsp_priv->aclk_mac);
 
@@ -940,6 +1001,21 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 			bsp_priv->clock_input = false;
 	}
 
+	ret = of_property_read_string(dev->of_node, "phy-type", &strings);
+	if (!ret && !strcmp(strings, "internal")) {
+		bsp_priv->internal_phy = true;
+		bsp_priv->macphy_reset = devm_reset_control_get(dev,
+				  "mac-phy");
+		if (IS_ERR(bsp_priv->macphy_reset)) {
+			dev_info(dev, "no macphy_reset control found\n");
+			bsp_priv->macphy_reset = NULL;
+		}
+	} else {
+		bsp_priv->internal_phy = false;
+	}
+	dev_info(dev, "internal PHY? (%s).\n",
+		 bsp_priv->internal_phy ? "yes" : "no");
+
 	ret = of_property_read_u32(dev->of_node, "tx_delay", &value);
 	if (ret) {
 		bsp_priv->tx_delay = 0x30;
@@ -1014,6 +1090,9 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	pm_runtime_enable(dev);
 	pm_runtime_get_sync(dev);
 
+	if (bsp_priv->internal_phy)
+		rk_gmac_internal_phy_powerup(bsp_priv);
+
 	return 0;
 }
 
@@ -1021,6 +1100,9 @@ static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
 	struct device *dev = &gmac->pdev->dev;
 
+	if (gmac->internal_phy)
+		rk_gmac_internal_phy_powerdown(gmac);
+
 	pm_runtime_put_sync(dev);
 	pm_runtime_disable(dev);
 
-- 
1.9.1


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
