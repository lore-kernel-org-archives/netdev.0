From: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [PATCH v3 07/11] net: stmmac: dwmac-rk: Add internal phy supprot for rk3328
Date: Wed,  2 Aug 2017 14:23:13 +0800
Message-ID: <1501654993-19637-1-git-send-email-david.wu@rock-chips.com>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org, olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1501654546-17292-1-git-send-email-david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There are two mac controllers in the rk3328, the one connects
to external phy, and the other one connects to internal phy.
Like the mac of external phy, the internal phy's mac also needs to
configure the related mac registers at GRF.

Signed-off-by: David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 74cf0bb..83471f3 100644
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
+	reg = bsp_priv->internal_phy ? RK3328_GRF_MAC_CON2 :
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
 
+	reg = bsp_priv->internal_phy ? RK3328_GRF_MAC_CON2 :
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
 
+static void rk3328_internal_phy_powerup(struct rk_priv_data *priv)
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
+	.internal_phy_powerup =  rk3328_internal_phy_powerup,
 };
 
 #define RK3366_GRF_SOC_CON6	0x0418
-- 
1.9.1


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
