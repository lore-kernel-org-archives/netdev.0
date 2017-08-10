From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 08/11] net: stmmac: dwmac-rk: Add integrated PHY supprot for rk3328
Date: Thu, 10 Aug 2017 22:00:52 +0800
Message-ID: <1502373652-2716-1-git-send-email-david.wu@rock-chips.com>
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

There are two mac controllers in the rk3328, the one connects
to external PHY, and the other one connects to integrated PHY.
Like the mac of external PHY, the integrated PHY's mac also
needs to configure the related mac registers at GRF.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index b6db3ff..2176403 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -323,6 +323,8 @@ static void rk3288_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 
 #define RK3328_GRF_MAC_CON0	0x0900
 #define RK3328_GRF_MAC_CON1	0x0904
+#define RK3328_GRF_MAC_CON2	0x0908
+#define RK3328_GRF_MACPHY_CON1	0xb04
 
 /* RK3328_GRF_MAC_CON0 */
 #define RK3328_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
@@ -349,6 +351,9 @@ static void rk3288_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 #define RK3328_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(1)
 #define RK3328_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(0)
 
+/* RK3328_GRF_MACPHY_CON1 */
+#define RK3328_MACPHY_RMII_MODE		GRF_BIT(9)
+
 static void rk3328_set_to_rgmii(struct rk_priv_data *bsp_priv,
 				int tx_delay, int rx_delay)
 {
@@ -373,13 +378,17 @@ static void rk3328_set_to_rgmii(struct rk_priv_data *bsp_priv,
 static void rk3328_set_to_rmii(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
+	unsigned int reg;
 
 	if (IS_ERR(bsp_priv->grf)) {
 		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
-	regmap_write(bsp_priv->grf, RK3328_GRF_MAC_CON1,
+	reg = bsp_priv->integrated_phy ? RK3328_GRF_MAC_CON2 :
+		  RK3328_GRF_MAC_CON1;
+
+	regmap_write(bsp_priv->grf, reg,
 		     RK3328_GMAC_PHY_INTF_SEL_RMII |
 		     RK3328_GMAC_RMII_MODE);
 }
@@ -409,29 +418,40 @@ static void rk3328_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
 static void rk3328_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
+	unsigned int reg;
 
 	if (IS_ERR(bsp_priv->grf)) {
 		dev_err(dev, "Missing rockchip,grf property\n");
 		return;
 	}
 
+	reg = bsp_priv->integrated_phy ? RK3328_GRF_MAC_CON2 :
+		  RK3328_GRF_MAC_CON1;
+
 	if (speed == 10)
-		regmap_write(bsp_priv->grf, RK3328_GRF_MAC_CON1,
+		regmap_write(bsp_priv->grf, reg,
 			     RK3328_GMAC_RMII_CLK_2_5M |
 			     RK3328_GMAC_SPEED_10M);
 	else if (speed == 100)
-		regmap_write(bsp_priv->grf, RK3328_GRF_MAC_CON1,
+		regmap_write(bsp_priv->grf, reg,
 			     RK3328_GMAC_RMII_CLK_25M |
 			     RK3328_GMAC_SPEED_100M);
 	else
 		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
 }
 
+static void rk3328_integrated_phy_powerup(struct rk_priv_data *priv)
+{
+	regmap_write(priv->grf, RK3328_GRF_MACPHY_CON1,
+		     RK3328_MACPHY_RMII_MODE);
+}
+
 static const struct rk_gmac_ops rk3328_ops = {
 	.set_to_rgmii = rk3328_set_to_rgmii,
 	.set_to_rmii = rk3328_set_to_rmii,
 	.set_rgmii_speed = rk3328_set_rgmii_speed,
 	.set_rmii_speed = rk3328_set_rmii_speed,
+	.integrated_phy_powerup =  rk3328_integrated_phy_powerup,
 };
 
 #define RK3366_GRF_SOC_CON6	0x0418
-- 
1.9.1
