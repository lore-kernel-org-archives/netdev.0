From: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 3/4] net: stmmac: dwmac-rk: abstract access to mac settings in
 GRF
Date: Wed, 17 Jun 2015 23:54:45 +0200
Message-ID: <1434578086-12209-4-git-send-email-heiko@sntech.de>
References: <1434578086-12209-1-git-send-email-heiko@sntech.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1434578086-12209-1-git-send-email-heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The mac settings like RGMII/RMII, speeds etc are done in the so called
"General Register Files", contain numerous other settings as well and
always seem to change between Rockchip SoCs. Therefore abstract the
register accesses into a per-soc ops struct to make this reusable on
other Rockchip SoCs.

Signed-off-by: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 116 ++++++++++++++++---------
 1 file changed, 75 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 4faa283..7ae17c6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -33,10 +33,20 @@
 
 #include "stmmac_platform.h"
 
+struct rk_priv_data;
+struct rk_gmac_ops {
+	void (*set_to_rgmii)(struct rk_priv_data *bsp_priv,
+			     int tx_delay, int rx_delay);
+	void (*set_to_rmii)(struct rk_priv_data *bsp_priv);
+	void (*set_rgmii_speed)(struct rk_priv_data *bsp_priv, int speed);
+	void (*set_rmii_speed)(struct rk_priv_data *bsp_priv, int speed);
+};
+
 struct rk_priv_data {
 	struct platform_device *pdev;
 	int phy_iface;
 	struct regulator *regulator;
+	struct rk_gmac_ops *ops;
 
 	bool clk_enabled;
 	bool clock_input;
@@ -66,30 +76,32 @@ struct rk_priv_data {
 #define RK3288_GRF_SOC_CON3	0x0250
 
 /*RK3288_GRF_SOC_CON1*/
-#define GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(6) | GRF_CLR_BIT(7) | GRF_CLR_BIT(8))
-#define GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(6) | GRF_CLR_BIT(7) | GRF_BIT(8))
-#define GMAC_FLOW_CTRL		GRF_BIT(9)
-#define GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(9)
-#define GMAC_SPEED_10M		GRF_CLR_BIT(10)
-#define GMAC_SPEED_100M		GRF_BIT(10)
-#define GMAC_RMII_CLK_25M	GRF_BIT(11)
-#define GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(11)
-#define GMAC_CLK_125M		(GRF_CLR_BIT(12) | GRF_CLR_BIT(13))
-#define GMAC_CLK_25M		(GRF_BIT(12) | GRF_BIT(13))
-#define GMAC_CLK_2_5M		(GRF_CLR_BIT(12) | GRF_BIT(13))
-#define GMAC_RMII_MODE		GRF_BIT(14)
-#define GMAC_RMII_MODE_CLR	GRF_CLR_BIT(14)
+#define RK3288_GMAC_PHY_INTF_SEL_RGMII	(GRF_BIT(6) | GRF_CLR_BIT(7) | \
+					 GRF_CLR_BIT(8))
+#define RK3288_GMAC_PHY_INTF_SEL_RMII	(GRF_CLR_BIT(6) | GRF_CLR_BIT(7) | \
+					 GRF_BIT(8))
+#define RK3288_GMAC_FLOW_CTRL		GRF_BIT(9)
+#define RK3288_GMAC_FLOW_CTRL_CLR	GRF_CLR_BIT(9)
+#define RK3288_GMAC_SPEED_10M		GRF_CLR_BIT(10)
+#define RK3288_GMAC_SPEED_100M		GRF_BIT(10)
+#define RK3288_GMAC_RMII_CLK_25M	GRF_BIT(11)
+#define RK3288_GMAC_RMII_CLK_2_5M	GRF_CLR_BIT(11)
+#define RK3288_GMAC_CLK_125M		(GRF_CLR_BIT(12) | GRF_CLR_BIT(13))
+#define RK3288_GMAC_CLK_25M		(GRF_BIT(12) | GRF_BIT(13))
+#define RK3288_GMAC_CLK_2_5M		(GRF_CLR_BIT(12) | GRF_BIT(13))
+#define RK3288_GMAC_RMII_MODE		GRF_BIT(14)
+#define RK3288_GMAC_RMII_MODE_CLR	GRF_CLR_BIT(14)
 
 /*RK3288_GRF_SOC_CON3*/
-#define GMAC_TXCLK_DLY_ENABLE	GRF_BIT(14)
-#define GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(14)
-#define GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
-#define GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
-#define GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
-#define GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
-
-static void set_to_rgmii(struct rk_priv_data *bsp_priv,
-			 int tx_delay, int rx_delay)
+#define RK3288_GMAC_TXCLK_DLY_ENABLE	GRF_BIT(14)
+#define RK3288_GMAC_TXCLK_DLY_DISABLE	GRF_CLR_BIT(14)
+#define RK3288_GMAC_RXCLK_DLY_ENABLE	GRF_BIT(15)
+#define RK3288_GMAC_RXCLK_DLY_DISABLE	GRF_CLR_BIT(15)
+#define RK3288_GMAC_CLK_RX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 7)
+#define RK3288_GMAC_CLK_TX_DL_CFG(val)	HIWORD_UPDATE(val, 0x7F, 0)
+
+static void rk3288_set_to_rgmii(struct rk_priv_data *bsp_priv,
+				int tx_delay, int rx_delay)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
 
@@ -99,14 +111,16 @@ static void set_to_rgmii(struct rk_priv_data *bsp_priv,
 	}
 
 	regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
-		     GMAC_PHY_INTF_SEL_RGMII | GMAC_RMII_MODE_CLR);
+		     RK3288_GMAC_PHY_INTF_SEL_RGMII |
+		     RK3288_GMAC_RMII_MODE_CLR);
 	regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON3,
-		     GMAC_RXCLK_DLY_ENABLE | GMAC_TXCLK_DLY_ENABLE |
-		     GMAC_CLK_RX_DL_CFG(rx_delay) |
-		     GMAC_CLK_TX_DL_CFG(tx_delay));
+		     RK3288_GMAC_RXCLK_DLY_ENABLE |
+		     RK3288_GMAC_TXCLK_DLY_ENABLE |
+		     RK3288_GMAC_CLK_RX_DL_CFG(rx_delay) |
+		     RK3288_GMAC_CLK_TX_DL_CFG(tx_delay));
 }
 
-static void set_to_rmii(struct rk_priv_data *bsp_priv)
+static void rk3288_set_to_rmii(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
 
@@ -116,10 +130,10 @@ static void set_to_rmii(struct rk_priv_data *bsp_priv)
 	}
 
 	regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
-		     GMAC_PHY_INTF_SEL_RMII | GMAC_RMII_MODE);
+		     RK3288_GMAC_PHY_INTF_SEL_RMII | RK3288_GMAC_RMII_MODE);
 }
 
-static void set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
+static void rk3288_set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
 
@@ -129,16 +143,19 @@ static void set_rgmii_speed(struct rk_priv_data *bsp_priv, int speed)
 	}
 
 	if (speed == 10)
-		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1, GMAC_CLK_2_5M);
+		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
+			     RK3288_GMAC_CLK_2_5M);
 	else if (speed == 100)
-		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1, GMAC_CLK_25M);
+		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
+			     RK3288_GMAC_CLK_25M);
 	else if (speed == 1000)
-		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1, GMAC_CLK_125M);
+		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
+			     RK3288_GMAC_CLK_125M);
 	else
 		dev_err(dev, "unknown speed value for RGMII! speed=%d", speed);
 }
 
-static void set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
+static void rk3288_set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
 
@@ -149,15 +166,24 @@ static void set_rmii_speed(struct rk_priv_data *bsp_priv, int speed)
 
 	if (speed == 10) {
 		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
-			     GMAC_RMII_CLK_2_5M | GMAC_SPEED_10M);
+			     RK3288_GMAC_RMII_CLK_2_5M |
+			     RK3288_GMAC_SPEED_10M);
 	} else if (speed == 100) {
 		regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
-			     GMAC_RMII_CLK_25M | GMAC_SPEED_100M);
+			     RK3288_GMAC_RMII_CLK_25M |
+			     RK3288_GMAC_SPEED_100M);
 	} else {
 		dev_err(dev, "unknown speed value for RMII! speed=%d", speed);
 	}
 }
 
+struct rk_gmac_ops rk3288_ops = {
+	.set_to_rgmii = rk3288_set_to_rgmii,
+	.set_to_rmii = rk3288_set_to_rmii,
+	.set_rgmii_speed = rk3288_set_rgmii_speed,
+	.set_rmii_speed = rk3288_set_rmii_speed,
+};
+
 static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 {
 	struct device *dev = &bsp_priv->pdev->dev;
@@ -311,7 +337,8 @@ static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
 	return 0;
 }
 
-static void *rk_gmac_setup(struct platform_device *pdev)
+static struct rk_priv_data *rk_gmac_setup(struct platform_device *pdev,
+					  struct rk_gmac_ops *ops)
 {
 	struct rk_priv_data *bsp_priv;
 	struct device *dev = &pdev->dev;
@@ -324,6 +351,7 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 		return ERR_PTR(-ENOMEM);
 
 	bsp_priv->phy_iface = of_get_phy_mode(dev->of_node);
+	bsp_priv->ops = ops;
 
 	bsp_priv->regulator = devm_regulator_get_optional(dev, "phy");
 	if (IS_ERR(bsp_priv->regulator)) {
@@ -378,10 +406,11 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 	/*rmii or rgmii*/
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
 		dev_info(dev, "%s: init for RGMII\n", __func__);
-		set_to_rgmii(bsp_priv, bsp_priv->tx_delay, bsp_priv->rx_delay);
+		bsp_priv->ops->set_to_rgmii(bsp_priv, bsp_priv->tx_delay,
+					    bsp_priv->rx_delay);
 	} else if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
 		dev_info(dev, "%s: init for RMII\n", __func__);
-		set_to_rmii(bsp_priv);
+		bsp_priv->ops->set_to_rmii(bsp_priv);
 	} else {
 		dev_err(dev, "%s: NO interface defined!\n", __func__);
 	}
@@ -391,6 +420,11 @@ static void *rk_gmac_setup(struct platform_device *pdev)
 	return bsp_priv;
 }
 
+static void *rk3288_gmac_setup(struct platform_device *pdev)
+{
+	return rk_gmac_setup(pdev, &rk3288_ops);
+}
+
 static int rk_gmac_init(struct platform_device *pdev, void *priv)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -421,9 +455,9 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 	struct device *dev = &bsp_priv->pdev->dev;
 
 	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII)
-		set_rgmii_speed(bsp_priv, speed);
+		bsp_priv->ops->set_rgmii_speed(bsp_priv, speed);
 	else if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
-		set_rmii_speed(bsp_priv, speed);
+		bsp_priv->ops->set_rmii_speed(bsp_priv, speed);
 	else
 		dev_err(dev, "unsupported interface %d", bsp_priv->phy_iface);
 }
@@ -431,7 +465,7 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 static const struct stmmac_of_data rk3288_gmac_data = {
 	.has_gmac = 1,
 	.fix_mac_speed = rk_fix_speed,
-	.setup = rk_gmac_setup,
+	.setup = rk3288_gmac_setup,
 	.init = rk_gmac_init,
 	.exit = rk_gmac_exit,
 };
-- 
2.1.4
