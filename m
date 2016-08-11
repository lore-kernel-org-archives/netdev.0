From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH 1/3] net: stmmac: dwmac-rk: add rk3366 & rk3399 specific data
Date: Thu, 11 Aug 2016 15:24:46 +0800
Message-ID: <1470900288-10109-2-git-send-email-roger.chen@rock-chips.com>
References: <1470900288-10109-1-git-send-email-roger.chen@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, zhengxing@rock-chips.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, alexandre.torgue@st.com,
	davem@davemloft.net, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470900288-10109-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add constants and callback functions for the dwmac on rk3228/rk3229 socs.
As can be seen, the base structure is the same, only registers and the
bits in them moved slightly.

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |   4 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 226 +++++++++++++++++++++
 2 files changed, 228 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index cccd945..8c066e6 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -3,8 +3,8 @@ Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
 The device node has following properties.
 
 Required properties:
- - compatible: Can be one of "rockchip,rk3228-gmac", "rockchip,rk3288-gmac",
-                             "rockchip,rk3368-gmac"
+ - compatible: Can be one of "rockchip,rk3288-gmac", "rockchip,rk3366-gmac",
+                             "rockchip,rk3368-gmac", "rockchip,rk3399-gmac"
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 9210591..4e6a270 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -301,6 +301,118 @@ static const struct rk_gmac_ops rk3288_ops = {
 	.set_rmii_speed = rk3288_set_rmii_speed,
 };
 
+#define RK3366_GRF_SOC_CON6	0x0418
+#define RK3366_GRF_SOC_CON7	0x041c
+
+/* RK3366_GRF_SOC_CON6 */
+#define RK3366_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_CLR_BIT(11))
+#define RK3366_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_BIT(11))
+#define RK3366_GMAC_FLOW_CTRL		GRF_BIT(8)
+#define RK3366_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(8)
+#define RK3366_GMAC_SPEED_10M		GRF_CLR_BIT(7)
+#define RK3366_GMAC_SPEED_100M		GRF_BIT(7)
+#define RK3366_GMAC_RMII_CLK_25M	GRF_BIT(3)
+#define RK3366_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(3)
+#define RK3366_GMAC_CLK_125M		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5))
+#define RK3366_GMAC_CLK_25M		(GRF_BIT(4) | GRF_BIT(5))
+#define RK3366_GMAC_CLK_2_5M		(GRF_CLR_BIT(4) | GRF_BIT(5))
+#define RK3366_GMAC_RMII_MODE		GRF_BIT(6)
+#define RK3366_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(6)
+
+/* RK3366_GRF_SOC_CON7 */
+#define RK3366_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(7)
+#define RK3366_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(7)
+#define RK3366_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3366_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3366_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 8)
+#define RK3366_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3366_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+		     RK3366_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3366_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON7,
+		     RK3366_GMAC_RXCLK_DLY_ENABLE |
+		     RK3366_GMAC_TXCLK_DLY_ENABLE |
+		     RK3366_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3366_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3366_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+		     RK3366_GMAC_PHY_INTF_SEL_RMII | RK3366_GMAC_RMII_MODE);
+}
+
+static void rk3366_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3366_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_RMII_CLK_2_5M |
+			     RK3366_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON6,
+			     RK3366_GMAC_RMII_CLK_25M |
+			     RK3366_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rk3366_ops = {
+	.set_to_rgmii = rk3366_set_to_rgmii,
+	.set_to_rmii = rk3366_set_to_rmii,
+	.set_rgmii_speed = rk3366_set_rgmii_speed,
+	.set_rmii_speed = rk3366_set_rmii_speed,
+};
+
 #define RK3368_GRF_SOC_CON15	0x043c
 #define RK3368_GRF_SOC_CON16	0x0440
 
@@ -413,6 +525,118 @@ static const struct rk_gmac_ops rk3368_ops = {
 	.set_rmii_speed = rk3368_set_rmii_speed,
 };
 
+#define RK3399_GRF_SOC_CON5	0xc214
+#define RK3399_GRF_SOC_CON6	0xc218
+
+/* RK3399_GRF_SOC_CON5 */
+#define RK3399_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_CLR_BIT(11))
+#define RK3399_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(9) | GRF_CLR_BIT(10) | \
+					 GRF_BIT(11))
+#define RK3399_GMAC_FLOW_CTRL		GRF_BIT(8)
+#define RK3399_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(8)
+#define RK3399_GMAC_SPEED_10M		GRF_CLR_BIT(7)
+#define RK3399_GMAC_SPEED_100M		GRF_BIT(7)
+#define RK3399_GMAC_RMII_CLK_25M	GRF_BIT(3)
+#define RK3399_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(3)
+#define RK3399_GMAC_CLK_125M		(GRF_CLR_BIT(4) | GRF_CLR_BIT(5))
+#define RK3399_GMAC_CLK_25M		(GRF_BIT(4) | GRF_BIT(5))
+#define RK3399_GMAC_CLK_2_5M		(GRF_CLR_BIT(4) | GRF_BIT(5))
+#define RK3399_GMAC_RMII_MODE		GRF_BIT(6)
+#define RK3399_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(6)
+
+/* RK3399_GRF_SOC_CON6 */
+#define RK3399_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(7)
+#define RK3399_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(7)
+#define RK3399_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3399_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3399_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 8)
+#define RK3399_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3399_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+		     RK3399_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3399_GMAC_RMII_MODE_CLR);
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON6,
+		     RK3399_GMAC_RXCLK_DLY_ENABLE |
+		     RK3399_GMAC_TXCLK_DLY_ENABLE |
+		     RK3399_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3399_GMAC_CLK_TX_DL_CFG(tx_delay));
+}
+
+static void rk3399_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+		     RK3399_GMAC_PHY_INTF_SEL_RMII | RK3399_GMAC_RMII_MODE);
+}
+
+static void rk3399_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_2_5M);
+	else if (speed == 100)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_25M);
+	else if (speed == 1000)
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_CLK_125M);
+	else
+		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
+}
+
+static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_RMII_CLK_2_5M |
+			     RK3399_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON5,
+			     RK3399_GMAC_RMII_CLK_25M |
+			     RK3399_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rk3399_ops = {
+	.set_to_rgmii = rk3399_set_to_rgmii,
+	.set_to_rmii = rk3399_set_to_rmii,
+	.set_rgmii_speed = rk3399_set_rgmii_speed,
+	.set_rmii_speed = rk3399_set_rmii_speed,
+};
+
 static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
@@ -760,7 +984,9 @@ static int rk_gmac_probe(struct platform_device *pdev)
 static const struct of_device_id rk_gmac_dwmac_match[] = {
 	{ .compatible = "rockchip,rk3228-gmac", .data = &rk3228_ops },
 	{ .compatible = "rockchip,rk3288-gmac", .data = &rk3288_ops },
+	{ .compatible = "rockchip,rk3366-gmac", .data = &rk3366_ops },
 	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
+	{ .compatible = "rockchip,rk3399-gmac", .data = &rk3399_ops },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
-- 
1.9.1
