From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 06/11] net: stmmac: dwmac-rk: Add integrated PHY support
Date: Thu, 10 Aug 2017 22:00:02 +0800
Message-ID: <1502373602-2613-1-git-send-email-david.wu@rock-chips.com>
References: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
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
In-Reply-To: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To make integrated PHY work, need to configure the PHY clock,
PHY cru reset and related registers.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
change in v4:
 - PHY is internal or not base on the phy-is-internal property via phy node.

changes in v5:
 - Use phy-is-integrated property via PHY node.
 - Get the PHY clock and reset control from PHY node of device tree.
 - Rename internal to integrated.

 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 99 ++++++++++++++++++++++++--
 1 file changed, 95 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index a8e8fd5..9019917 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -41,6 +41,7 @@ struct rk_gmac_ops {
 	void (*set_to_rmii)(struct rk_priv_data *bsp_priv);
 	void (*set_rgmii_speed)(struct rk_priv_data *bsp_priv, int speed);
 	void (*set_rmii_speed)(struct rk_priv_data *bsp_priv, int speed);
+	void (*integrated_phy_powerup)(struct rk_priv_data *bsp_priv);
 };
 
 struct rk_priv_data {
@@ -52,6 +53,7 @@ struct rk_priv_data {
 
 	bool clk_enabled;
 	bool clock_input;
+	bool integrated_phy;
 
 	struct clk *clk_mac;
 	struct clk *gmac_clkin;
@@ -61,6 +63,9 @@ struct rk_priv_data {
 	struct clk *clk_mac_refout;
 	struct clk *aclk_mac;
 	struct clk *pclk_mac;
+	struct clk *clk_phy;
+
+	struct reset_control *phy_reset;
 
 	int tx_delay;
 	int rx_delay;
@@ -750,9 +755,55 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	.set_rmii_speed = rk3399_set_rmii_speed,
 };
 
-static int gmac_clk_init(struct rk_priv_data *bsp_priv)
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
+static void rk_gmac_integrated_phy_powerup(struct rk_priv_data *priv)
+{
+	if (priv->ops->integrated_phy_powerup)
+		priv->ops->integrated_phy_powerup(priv);
+
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_CFG_CLK_50M);
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_GMAC2PHY_RMII_MODE);
+
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON2, RK_GRF_CON2_MACPHY_ID);
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON3, RK_GRF_CON3_MACPHY_ID);
+
+	if (priv->phy_reset) {
+		/* PHY needs to be disabled before trying to reset it */
+		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
+		if (priv->phy_reset)
+			reset_control_assert(priv->phy_reset);
+		usleep_range(10, 20);
+		if (priv->phy_reset)
+			reset_control_deassert(priv->phy_reset);
+		usleep_range(10, 20);
+		regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_ENABLE);
+		msleep(30);
+	}
+}
+
+static void rk_gmac_integrated_phy_powerdown(struct rk_priv_data *priv)
 {
+	regmap_write(priv->grf, RK_GRF_MACPHY_CON0, RK_MACPHY_DISABLE);
+	if (priv->phy_reset)
+		reset_control_assert(priv->phy_reset);
+}
+
+static int rk_gmac_clk_init(struct plat_stmmacenet_data *plat)
+{
+	struct rk_priv_data *bsp_priv = plat->bsp_priv;
 	struct device *dev = &bsp_priv->pdev->dev;
+	int ret;
 
 	bsp_priv->clk_enabled = false;
 
@@ -803,6 +854,16 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 			clk_set_rate(bsp_priv->clk_mac, 50000000);
 	}
 
+	if (plat->phy_node && bsp_priv->integrated_phy) {
+		bsp_priv->clk_phy = of_clk_get(plat->phy_node, 0);
+		if (IS_ERR(bsp_priv->clk_phy)) {
+			ret = PTR_ERR(bsp_priv->clk_phy);
+			dev_err(dev, "Cannot get PHY clock: %d\n", ret);
+			return -EINVAL;
+		}
+		clk_set_rate(bsp_priv->clk_phy, 50000000);
+	}
+
 	return 0;
 }
 
@@ -826,6 +887,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_phy))
+				clk_prepare_enable(bsp_priv->clk_phy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_prepare_enable(bsp_priv->aclk_mac);
 
@@ -858,6 +922,9 @@ static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 						bsp_priv->clk_mac_refout);
 			}
 
+			if (!IS_ERR(bsp_priv->clk_phy))
+				clk_disable_unprepare(bsp_priv->clk_phy);
+
 			if (!IS_ERR(bsp_priv->aclk_mac))
 				clk_disable_unprepare(bsp_priv->aclk_mac);
 
@@ -902,6 +969,7 @@ static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 }
 
 static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
+					  struct plat_stmmacenet_data *plat,
 					  const struct rk_gmac_ops *ops)
 {
 	struct rk_priv_data *bsp_priv;
@@ -964,9 +1032,22 @@ static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
 
 	bsp_priv->grf = syscon_regmap_lookup_by_phandle(dev->of_node,
 							"rockchip,grf");
-	bsp_priv->pdev = pdev;
 
-	gmac_clk_init(bsp_priv);
+	if (plat->phy_node) {
+		bsp_priv->integrated_phy = of_property_read_bool(plat->phy_node,
+								 "phy-is-integrated");
+		if (bsp_priv->integrated_phy) {
+			bsp_priv->phy_reset = of_reset_control_get(plat->phy_node, NULL);
+			if (IS_ERR(bsp_priv->phy_reset)) {
+				dev_err(&pdev->dev, "No PHY reset control found.\n");
+				bsp_priv->phy_reset = NULL;
+			}
+		}
+	}
+	dev_info(dev, "integrated PHY? (%s).\n",
+		 bsp_priv->integrated_phy ? "yes" : "no");
+
+	bsp_priv->pdev = pdev;
 
 	return bsp_priv;
 }
@@ -1014,6 +1095,9 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 	pm_runtime_enable(dev);
 	pm_runtime_get_sync(dev);
 
+	if (bsp_priv->integrated_phy)
+		rk_gmac_integrated_phy_powerup(bsp_priv);
+
 	return 0;
 }
 
@@ -1021,6 +1105,9 @@ static void rk_gmac_powerdown(struct rk_priv_data *gmac)
 {
 	struct device *dev = &gmac->pdev->dev;
 
+	if (gmac->integrated_phy)
+		rk_gmac_integrated_phy_powerdown(gmac);
+
 	pm_runtime_put_sync(dev);
 	pm_runtime_disable(dev);
 
@@ -1072,12 +1159,16 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	plat_dat->has_gmac = true;
 	plat_dat->fix_mac_speed = rk_fix_speed;
 
-	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
+	plat_dat->bsp_priv = rk_gmac_setup(pdev, plat_dat, data);
 	if (IS_ERR(plat_dat->bsp_priv)) {
 		ret = PTR_ERR(plat_dat->bsp_priv);
 		goto err_remove_config_dt;
 	}
 
+	ret = rk_gmac_clk_init(plat_dat);
+	if (ret)
+		return ret;
+
 	ret = rk_gmac_powerup(plat_dat->bsp_priv);
 	if (ret)
 		goto err_remove_config_dt;
-- 
1.9.1
