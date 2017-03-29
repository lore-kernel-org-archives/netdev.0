From: Wadim Egorov <w.egorov@phytec.de>
Subject: [PATCH v2] net: stmmac: dwmac-rk: Add handling for RGMII_ID/RXID/TXID
Date: Wed, 29 Mar 2017 14:12:19 +0200
Message-ID: <1490789539-43920-1-git-send-email-w.egorov@phytec.de>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rockchip@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ATM dwmac-rk will always set and enable it's internal delay lines.
Using PHY internal delays in combination with the phy-mode
rgmii-id/rxid/txid was not possible. Only rgmii was supported.

Now we can disable rockchip's gmac delay lines and also use
rgmii-id/rxid/txid.

Tested only with a RK3288 based board.

Signed-off-by: Wadim Egorov <w.egorov@phytec.de>
---
Changes in v2: Added parenthesis around both expressions in DELAY_ENABLE
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 53 ++++++++++++++++++--------
 1 file changed, 37 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index e5db6ac..f0df519 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -74,6 +74,10 @@ struct rk_priv_data {
 #define GRF_BIT(nr)	(BIT(nr) | BIT(nr+16))
 #define GRF_CLR_BIT(nr)	(BIT(nr+16))
 
+#define DELAY_ENABLE(soc, tx, rx) \
+	(((tx) ? soc##_GMAC_TXCLK_DLY_ENABLE : soc##_GMAC_TXCLK_DLY_DISABLE) | \
+	 ((rx) ? soc##_GMAC_RXCLK_DLY_ENABLE : soc##_GMAC_RXCLK_DLY_DISABLE))
+
 #define RK3228_GRF_MAC_CON0	0x0900
 #define RK3228_GRF_MAC_CON1	0x0904
 
@@ -115,8 +119,7 @@ static void rk3228_set_to_rgmii(struct rk_priv_data *bsp_priv,
 	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON1,
 		     RK3228_GMAC_PHY_INTF_SEL_RGMII |
 		     RK3228_GMAC_RMII_MODE_CLR |
-		     RK3228_GMAC_RXCLK_DLY_ENABLE |
-		     RK3228_GMAC_TXCLK_DLY_ENABLE);
+		     DELAY_ENABLE(RK3228, tx_delay, rx_delay));
 
 	regmap_write(bsp_priv->grf, RK3228_GRF_MAC_CON0,
 		     RK3228_GMAC_CLK_RX_DL_CFG(rx_delay) |
@@ -232,8 +235,7 @@ static void rk3288_set_to_rgmii(struct rk_priv_data *bsp_priv,
 		     RK3288_GMAC_PHY_INTF_SEL_RGMII |
 		     RK3288_GMAC_RMII_MODE_CLR);
 	regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON3,
-		     RK3288_GMAC_RXCLK_DLY_ENABLE |
-		     RK3288_GMAC_TXCLK_DLY_ENABLE |
+		     DELAY_ENABLE(RK3288, tx_delay, rx_delay) |
 		     RK3288_GMAC_CLK_RX_DL_CFG(rx_delay) |
 		     RK3288_GMAC_CLK_TX_DL_CFG(tx_delay));
 }
@@ -460,8 +462,7 @@ static void rk3366_set_to_rgmii(struct rk_priv_data *bsp_priv,
 		     RK3366_GMAC_PHY_INTF_SEL_RGMII |
 		     RK3366_GMAC_RMII_MODE_CLR);
 	regmap_write(bsp_priv->grf, RK3366_GRF_SOC_CON7,
-		     RK3366_GMAC_RXCLK_DLY_ENABLE |
-		     RK3366_GMAC_TXCLK_DLY_ENABLE |
+		     DELAY_ENABLE(RK3366, tx_delay, rx_delay) |
 		     RK3366_GMAC_CLK_RX_DL_CFG(rx_delay) |
 		     RK3366_GMAC_CLK_TX_DL_CFG(tx_delay));
 }
@@ -572,8 +573,7 @@ static void rk3368_set_to_rgmii(struct rk_priv_data *bsp_priv,
 		     RK3368_GMAC_PHY_INTF_SEL_RGMII |
 		     RK3368_GMAC_RMII_MODE_CLR);
 	regmap_write(bsp_priv->grf, RK3368_GRF_SOC_CON16,
-		     RK3368_GMAC_RXCLK_DLY_ENABLE |
-		     RK3368_GMAC_TXCLK_DLY_ENABLE |
+		     DELAY_ENABLE(RK3368, tx_delay, rx_delay) |
 		     RK3368_GMAC_CLK_RX_DL_CFG(rx_delay) |
 		     RK3368_GMAC_CLK_TX_DL_CFG(tx_delay));
 }
@@ -684,8 +684,7 @@ static void rk3399_set_to_rgmii(struct rk_priv_data *bsp_priv,
 		     RK3399_GMAC_PHY_INTF_SEL_RGMII |
 		     RK3399_GMAC_RMII_MODE_CLR);
 	regmap_write(bsp_priv->grf, RK3399_GRF_SOC_CON6,
-		     RK3399_GMAC_RXCLK_DLY_ENABLE |
-		     RK3399_GMAC_TXCLK_DLY_ENABLE |
+		     DELAY_ENABLE(RK3399, tx_delay, rx_delay) |
 		     RK3399_GMAC_CLK_RX_DL_CFG(rx_delay) |
 		     RK3399_GMAC_CLK_TX_DL_CFG(tx_delay));
 }
@@ -985,14 +984,29 @@ static int rk_gmac_powerup(struct rk_priv_data *bsp_priv)
 		return ret;
 
 	/*rmii or rgmii*/
-	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII) {
+	switch (bsp_priv->phy_iface) {
+	case PHY_INTERFACE_MODE_RGMII:
 		dev_info(dev, "init for RGMII\n");
 		bsp_priv->ops->set_to_rgmii(bsp_priv, bsp_priv->tx_delay,
 					    bsp_priv->rx_delay);
-	} else if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII) {
+		break;
+	case PHY_INTERFACE_MODE_RGMII_ID:
+		dev_info(dev, "init for RGMII_ID\n");
+		bsp_priv->ops->set_to_rgmii(bsp_priv, 0, 0);
+		break;
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+		dev_info(dev, "init for RGMII_RXID\n");
+		bsp_priv->ops->set_to_rgmii(bsp_priv, bsp_priv->tx_delay, 0);
+		break;
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		dev_info(dev, "init for RGMII_TXID\n");
+		bsp_priv->ops->set_to_rgmii(bsp_priv, 0, bsp_priv->rx_delay);
+		break;
+	case PHY_INTERFACE_MODE_RMII:
 		dev_info(dev, "init for RMII\n");
 		bsp_priv->ops->set_to_rmii(bsp_priv);
-	} else {
+		break;
+	default:
 		dev_err(dev, "NO interface defined!\n");
 	}
 
@@ -1022,12 +1036,19 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 	struct rk_priv_data *bsp_priv = priv;
 	struct device *dev = &bsp_priv->pdev->dev;
 
-	if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RGMII)
+	switch (bsp_priv->phy_iface) {
+	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_TXID:
 		bsp_priv->ops->set_rgmii_speed(bsp_priv, speed);
-	else if (bsp_priv->phy_iface == PHY_INTERFACE_MODE_RMII)
+		break;
+	case PHY_INTERFACE_MODE_RMII:
 		bsp_priv->ops->set_rmii_speed(bsp_priv, speed);
-	else
+		break;
+	default:
 		dev_err(dev, "unsupported interface %d", bsp_priv->phy_iface);
+	}
 }
 
 static int rk_gmac_probe(struct platform_device *pdev)
-- 
1.9.1
