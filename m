From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH] net: stmmac: dwmac-rk: Add RK3128 GMAC support
Date: Sat, 30 Sep 2017 17:47:23 +0800
Message-ID: <1506764843-24681-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, netdev@vger.kernel.org,
        linux-rockchip@lists.infradead.org, linux-kernel@vger.kernel.org,
        David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add constants and callback functions for the dwmac on rk3128 soc.
As can be seen, the base structure is the same, only registers
and the bits in them moved slightly.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 112 +++++++++++++++++++++
 2 files changed, 113 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 6af8eed..9c16ee2 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -4,6 +4,7 @@ The device node has following properties.
 
 Required properties:
  - compatible: should be "rockchip,<name>-gamc"
+   "rockchip,rk3128-gmac": found on RK312x SoCs
    "rockchip,rk3228-gmac": found on RK322x SoCs
    "rockchip,rk3288-gmac": found on RK3288 SoCs
    "rockchip,rk3328-gmac": found on RK3328 SoCs
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 99823f5..13133b3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -83,6 +83,117 @@ struct rk_priv_data {
 	(((tx) ? soc##_GMAC_TXCLK_DLY_ENABLE : soc##_GMAC_TXCLK_DLY_DISABLE) | \
 	 ((rx) ? soc##_GMAC_RXCLK_DLY_ENABLE : soc##_GMAC_RXCLK_DLY_DISABLE))
 
+#define RK3128_GRF_MAC_CON0	0x0168
+#define RK3128_GRF_MAC_CON1	0x016c
+
+/* RK3128_GRF_MAC_CON0 */
+#define RK3128_GMAC_TXCLK_DLY_ENABLE   GRF_BIT(14)
+#define RK3128_GMAC_TXCLK_DLY_DISABLE  GRF_CLR_BIT(14)
+#define RK3128_GMAC_RXCLK_DLY_ENABLE   GRF_BIT(15)
+#define RK3128_GMAC_RXCLK_DLY_DISABLE  GRF_CLR_BIT(15)
+#define RK3128_GMAC_CLK_RX_DL_CFG(val) HIWORD_UPDATE(val, 0x7F, 7)
+#define RK3128_GMAC_CLK_TX_DL_CFG(val) HIWORD_UPDATE(val, 0x7F, 0)
+
+/* RK3128_GRF_MAC_CON1 */
+#define RK3128_GMAC_PHY_INTF_SEL_RGMII	\
+		(GRF_BIT(6) | GRF_CLR_BIT(7) | GRF_CLR_BIT(8))
+#define RK3128_GMAC_PHY_INTF_SEL_RMII	\
+		(GRF_CLR_BIT(6) | GRF_CLR_BIT(7) | GRF_BIT(8))
+#define RK3128_GMAC_FLOW_CTRL          GRF_BIT(9)
+#define RK3128_GMAC_FLOW_CTRL_CLR      GRF_CLR_BIT(9)
+#define RK3128_GMAC_SPEED_10M          GRF_CLR_BIT(10)
+#define RK3128_GMAC_SPEED_100M         GRF_BIT(10)
+#define RK3128_GMAC_RMII_CLK_25M       GRF_BIT(11)
+#define RK3128_GMAC_RMII_CLK_2_5M      GRF_CLR_BIT(11)
+#define RK3128_GMAC_CLK_125M           (GRF_CLR_BIT(12) | GRF_CLR_BIT(13))
+#define RK3128_GMAC_CLK_25M            (GRF_BIT(12) | GRF_BIT(13))
+#define RK3128_GMAC_CLK_2_5M           (GRF_CLR_BIT(12) | GRF_BIT(13))
+#define RK3128_GMAC_RMII_MODE          GRF_BIT(14)
+#define RK3128_GMAC_RMII_MODE_CLR      GRF_CLR_BIT(14)
+
+static void rk3128_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+		     RK3128_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3128_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON0,
+		     DELAY_ENABLE(RK3128, tx_delay, rx_delay) |
+		     RK3128_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3128_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3128_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+		     RK3128_GMAC_PHY_INTF_SEL_RMII | RK3128_GMAC_RMII_MODE);
+}
+
+static void rk3128_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+			     RK3128_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+			     RK3128_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+			     RK3128_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3128_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "Missing rockchip,grf property\n");
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+			     RK3128_GMAC_RMII_CLK_2_5M |
+			     RK3128_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3128_GRF_MAC_CON1,
+			     RK3128_GMAC_RMII_CLK_25M |
+			     RK3128_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rk3128_ops = {
+	.set_to_rgmii = rk3128_set_to_rgmii,
+	.set_to_rmii = rk3128_set_to_rmii,
+	.set_rgmii_speed = rk3128_set_rgmii_speed,
+	.set_rmii_speed = rk3128_set_rmii_speed,
+};
+
 #define RK3228_GRF_MAC_CON0	0x0900
 #define RK3228_GRF_MAC_CON1	0x0904
 
@@ -1313,6 +1424,7 @@ static int rk_gmac_resume(struct device *dev)
 static SIMPLE_DEV_PM_OPS(rk_gmac_pm_ops, rk_gmac_suspend, rk_gmac_resume);
 
 static const struct of_device_id rk_gmac_dwmac_match[] = {
+	{ .compatible = "rockchip,rk3128-gmac", .data = &rk3128_ops },
 	{ .compatible = "rockchip,rk3228-gmac", .data = &rk3228_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
 	{ .compatible = "rockchip,rk3328-gmac", .data = &rk3328_ops },
-- 
1.9.1
