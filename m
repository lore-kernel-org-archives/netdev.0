From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH] net: ethernet: stmmac: dwmac-rk: Add rv1108 gmac support
Date: Mon, 21 Aug 2017 18:12:55 +0800
Message-ID: <1503310375-30393-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, netdev@vger.kernel.org,
        linux-rockchip@lists.infradead.org, linux-kernel@vger.kernel.org,
        David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        linux@armlinux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It only supports rmii interface. Add constants and callback functions
for the dwmac on rv1108 socs. As can be seen, the base structure is
the same, only registers and the bits in them moved slightly.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 53 ++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
index 8f42755..c132538 100644
--- a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -10,6 +10,7 @@ Required properties:
    "rockchip,rk3366-gmac": found on RK3366 SoCs
    "rockchip,rk3368-gmac": found on RK3368 SoCs
    "rockchip,rk3399-gmac": found on RK3399 SoCs
+   "rockchip,rv1108-gmac": found on RV1108 SoCs
  - reg: addresses and length of the register sets for the device.
  - interrupts: Should contain the GMAC interrupts.
  - interrupt-names: Should contain the interrupt names "macirq".
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 2176403..99823f5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -787,6 +787,58 @@ static void rk3399_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	.set_rmii_speed = rk3399_set_rmii_speed,
 };
 
+#define RV1108_GRF_GMAC_CON0		0X0900
+
+/* RV1108_GRF_GMAC_CON0 */
+#define RV1108_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(4) | GRF_CLR_BIT(5) | \
+					GRF_BIT(6))
+#define RV1108_GMAC_FLOW_CTRL		GRF_BIT(3)
+#define RV1108_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(3)
+#define RV1108_GMAC_SPEED_10M		GRF_CLR_BIT(2)
+#define RV1108_GMAC_SPEED_100M		GRF_BIT(2)
+#define RV1108_GMAC_RMII_CLK_25M	GRF_BIT(7)
+#define RV1108_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(7)
+
+static void rv1108_set_to_rmii(struct rk_priv_data *bsp_priv)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	regmap_write(bsp_priv->grf, RV1108_GRF_GMAC_CON0,
+		     RV1108_GMAC_PHY_INTF_SEL_RMII);
+}
+
+static void rv1108_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+{
+	struct device *dev = &bsp_priv->pdev->dev;
+
+	if (IS_ERR(bsp_priv->grf)) {
+		dev_err(dev, "%s: Missing rockchip,grf property\n", __func__);
+		return;
+	}
+
+	if (speed == 10) {
+		regmap_write(bsp_priv->grf, RV1108_GRF_GMAC_CON0,
+			     RV1108_GMAC_RMII_CLK_2_5M |
+			     RV1108_GMAC_SPEED_10M);
+	} else if (speed == 100) {
+		regmap_write(bsp_priv->grf, RV1108_GRF_GMAC_CON0,
+			     RV1108_GMAC_RMII_CLK_25M |
+			     RV1108_GMAC_SPEED_100M);
+	} else {
+		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
+	}
+}
+
+static const struct rk_gmac_ops rv1108_ops = {
+	.set_to_rmii = rv1108_set_to_rmii,
+	.set_rmii_speed = rv1108_set_rmii_speed,
+};
+
 #define RK_GRF_MACPHY_CON0		0xb00
 #define RK_GRF_MACPHY_CON1		0xb04
 #define RK_GRF_MACPHY_CON2		0xb08
@@ -1267,6 +1319,7 @@ static int rk_gmac_resume(struct device *dev)
 	{ .compatible = "rockchip,rk3366-gmac", .data = &rk3366_ops },
 	{ .compatible = "rockchip,rk3368-gmac", .data = &rk3368_ops },
 	{ .compatible = "rockchip,rk3399-gmac", .data = &rk3399_ops },
+	{ .compatible = "rockchip,rv1108-gmac", .data = &rv1108_ops },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
-- 
1.9.1
