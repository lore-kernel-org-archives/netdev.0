From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 27 Jul 2017 21:02:16 +0800
Message-ID: <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make internal phy work, need to configure the phy_clock,
phy cru_reset and related registers.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
changes in v2:
 - Use the standard "phy-mode" property for internal phy. (Florian)
 - Move the internal macphy clock to the optional properties. (Heiko)

 .../devicetree/bindings/net/rockchip-dwmac.txt     |  4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 94 +++++++++++++++++++++-
 2 files changed, 93 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 8f42755..ecebab8 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -25,7 +25,8 @@ Required properties:
  - clock-names: One name for each entry in the clocks property.
  - phy-mode: See ethernet.txt file in the same directory.
  - pinctrl-names: Names corresponding to the numbered pinctrl states.
- - pinctrl-0: pin-control mode. can be <&rgmii_pins> or <&rmii_pins>.
+ - pinctrl-0: pin-control mode. can be <&rgmii_pins>, <&rmii_pins> or led pins
+   for internal phy mode.
  - clock_in_out: For RGMII, it must be "input", means main clock(125MHz)
    is not sourced from SoC's PLL, but input from PHY; For RMII, "input" means
    PHY provides the reference clock(50MHz), "output" means GMAC provides the
@@ -40,6 +41,7 @@ Optional properties:
  - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
  - rx_delay: Delay value for RXD timing. Range value is 0~0x7F, 0x10 as default.
  - phy-supply: phandle to a regulator if the PHY needs one
+ - clocks: <&cru MAC_PHY>: clock for internal macphy
 
 Example:
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index a8e8fd5..ec280d1 100644
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
@@ -750,6 +755,50 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
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
+	if (priv->macphy_reset) {
+		/* macphy needs to be disabled before trying to reset it */
+		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
+		if (priv->macphy_reset)
+			reset_control_assert(priv->macphy_reset);
+		usleep_range(10, 20);
+		if (priv->macphy_reset)
+			reset_control_deassert(priv->macphy_reset);
+		usleep_range(10, 20);
+		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
+		msleep(30);
+	}
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
@@ -781,7 +830,8 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 		dev_err(dev, "cannot get clock %s\n",
 			"stmmaceth");
 
-	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
+	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII ||
+	    bsp_priv->phy_iface == PHY_INTERFACE_MODE_INTERNAL) {
 		bsp_priv->clk_mac_ref = devm_clk_get(dev, "clk_mac_ref");
 		if (IS_ERR(bsp_priv->clk_mac_ref))
 			dev_err(dev, "cannot get clock %s\n",
@@ -799,10 +849,19 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 	if (bsp_priv->clock_input) {
 		dev_info(dev, "clock input from PHY\n");
 	} else {
-		if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
+		if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII ||
+		    bsp_priv->phy_iface == PHY_INTERFACE_MODE_INTERNAL)
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
 
@@ -812,7 +871,8 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 
 	if (enable) {
 		if (!bsp_priv->clk_enabled) {
-			if (phy_iface == PHY_INTERFACE_MODE_RMII) {
+			if (phy_iface == PHY_INTERFACE_MODE_RMII ||
+			    phy_iface == PHY_INTERFACE_MODE_INTERNAL) {
 				if (!IS_ERR(bsp_priv->mac_clk_rx))
 					clk_prepare_enable(
 						bsp_priv->mac_clk_rx);
@@ -826,6 +886,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_macphy))
+				clk_prepare_enable(bsp_priv->clk_macphy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_prepare_enable(bsp_priv->aclk_mac);
 
@@ -844,7 +907,8 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 		}
 	} else {
 		if (bsp_priv->clk_enabled) {
-			if (phy_iface == PHY_INTERFACE_MODE_RMII) {
+			if (phy_iface == PHY_INTERFACE_MODE_RMII ||
+			    phy_iface == PHY_INTERFACE_MODE_INTERNAL) {
 				if (!IS_ERR(bsp_priv->mac_clk_rx))
 					clk_disable_unprepare(
 						bsp_priv->mac_clk_rx);
@@ -858,6 +922,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_macphy))
+				clk_disable_unprepare(bsp_priv->clk_macphy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_disable_unprepare(bsp_priv->aclk_mac);
 
@@ -940,6 +1007,17 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 			bsp_priv->clock_input = false;
 	}
 
+	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_INTERNAL) {
+		bsp_priv->internal_phy = true;
+		bsp_priv->macphy_reset = devm_reset_control_get(dev, "mac-phy");
+		if (IS_ERR(bsp_priv->macphy_reset)) {
+			dev_info(dev, "no macphy_reset control found\n");
+			bsp_priv->macphy_reset = NULL;
+		}
+	}
+	dev_info(dev, "internal PHY? (%s).\n",
+		 bsp_priv->internal_phy ? "yes" : "no");
+
 	ret = of_property_read_u32(dev->of_node, "tx_delay", &value);
 	if (ret) {
 		bsp_priv->tx_delay = 0x30;
@@ -1000,6 +1078,7 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 		bsp_priv->ops->set_to_rgmii(bsp_priv, 0, bsp_priv->rx_delay);
 		break;
 	case PHY_INTERFACE_MODE_RMII:
+	case PHY_INTERFACE_MODE_INTERNAL:
 		dev_info(dev, "init for RMII\n");
 		bsp_priv->ops->set_to_rmii(bsp_priv);
 		break;
@@ -1014,6 +1093,9 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	pm_runtime_enable(dev);
 	pm_runtime_get_sync(dev);
 
+	if (bsp_priv->internal_phy)
+		rk_gmac_internal_phy_powerup(bsp_priv);
+
 	return 0;
 }
 
@@ -1021,6 +1103,9 @@ static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
 	struct device *dev = &gmac->pdev->dev;
 
+	if (gmac->internal_phy)
+		rk_gmac_internal_phy_powerdown(gmac);
+
 	pm_runtime_put_sync(dev);
 	pm_runtime_disable(dev);
 
@@ -1041,6 +1126,7 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 		bsp_priv->ops->set_rgmii_speed(bsp_priv, speed);
 		break;
 	case PHY_INTERFACE_MODE_RMII:
+	case PHY_INTERFACE_MODE_INTERNAL:
 		bsp_priv->ops->set_rmii_speed(bsp_priv, speed);
 		break;
 	default:
-- 
1.9.1
