From: Xing Zheng <zhengxing@rock-chips.com>
Subject: [PATCH v2 2/3] net: ethernet: arc: Keep emac compatibility for more Rockchip SoCs
Date: Fri,  8 Jan 2016 09:35:01 +0800
Message-ID: <1452216902-21063-3-git-send-email-zhengxing@rock-chips.com>
References: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Cc: keescook@google.com, leozwang@google.com, heiko@sntech.de,
	davem@davemloft.net, netdev@vger.kernel.org,
	Xing Zheng <zhengxing@rock-chips.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: linux-rockchip@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On the RK3066/RK3188, there was fixed GRF offset configuration to set emac
and fixed DIV2 mac TX/RX clock. So, we need to easily set and fit to other
SoCs (RK3036) which maybe have different GRF offset, and need adjust mac
TX/RX clock.

Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
---

Changes in v2: None

 drivers/net/ethernet/arc/emac_rockchip.c |   69 +++++++++++++++++++-----------
 1 file changed, 45 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
index 36e9eb1..e951c8f 100644
--- a/drivers/net/ethernet/arc/emac_rockchip.c
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -25,17 +25,13 @@
 #include "emac.h"
 
 #define DRV_NAME        "rockchip_emac"
-#define DRV_VERSION     "1.0"
-
-#define GRF_MODE_MII		(1UL << 0)
-#define GRF_MODE_RMII		(0UL << 0)
-#define GRF_SPEED_10M		(0UL << 1)
-#define GRF_SPEED_100M		(1UL << 1)
-#define GRF_SPEED_ENABLE_BIT	(1UL << 17)
-#define GRF_MODE_ENABLE_BIT	(1UL << 16)
+#define DRV_VERSION     "1.1"
 
 struct emac_rockchip_soc_data {
-	int grf_offset;
+	unsigned int grf_offset;
+	unsigned int grf_mode_offset;
+	unsigned int grf_speed_offset;
+	bool need_div_macclk;
 };
 
 struct rockchip_priv_data {
@@ -44,23 +40,22 @@ struct rockchip_priv_data {
 	const struct emac_rockchip_soc_data *soc_data;
 	struct regulator *regulator;
 	struct clk *refclk;
+	struct clk *macclk;
 };
 
 static void emac_rockchip_set_mac_speed(void *priv, unsigned int speed)
 {
 	struct rockchip_priv_data *emac = priv;
+	u32 speed_offset = emac->soc_data->grf_speed_offset;
 	u32 data;
 	int err = 0;
 
-	/* write-enable bits */
-	data = GRF_SPEED_ENABLE_BIT;
-
 	switch(speed) {
 	case 10:
-		data |= GRF_SPEED_10M;
+		data = (1 << (speed_offset + 16)) | (0 << speed_offset);
 		break;
 	case 100:
-		data |= GRF_SPEED_100M;
+		data = (1 << (speed_offset + 16)) | (1 << speed_offset);
 		break;
 	default:
 		pr_err("speed %u not supported\n", speed);
@@ -72,14 +67,19 @@ static void emac_rockchip_set_mac_speed(void *priv, unsigned int speed)
 		pr_err("unable to apply speed %u to grf (%d)\n", speed, err);
 }
 
-static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
-	{ .grf_offset = 0x154 }, /* rk3066 */
-	{ .grf_offset = 0x0a4 }, /* rk3188 */
+static const struct emac_rockchip_soc_data emac_rk3066_emac_data = {
+	.grf_offset = 0x154,   .grf_mode_offset = 0,
+	.grf_speed_offset = 1, .need_div_macclk = 0,
+};
+
+static const struct emac_rockchip_soc_data emac_rk3188_emac_data = {
+	.grf_offset = 0x0a4,   .grf_mode_offset = 0,
+	.grf_speed_offset = 1, .need_div_macclk = 0,
 };
 
 static const struct of_device_id emac_rockchip_dt_ids[] = {
-	{ .compatible = "rockchip,rk3066-emac", .data = &emac_rockchip_dt_data[0] },
-	{ .compatible = "rockchip,rk3188-emac", .data = &emac_rockchip_dt_data[1] },
+	{ .compatible = "rockchip,rk3066-emac", .data = &emac_rk3066_emac_data },
+	{ .compatible = "rockchip,rk3188-emac", .data = &emac_rk3188_emac_data },
 	{ /* Sentinel */ }
 };
 
@@ -164,11 +164,12 @@ static int emac_rockchip_probe(struct platform_device *pdev)
 		}
 	}
 
-	/* write-enable bits */
-	data = GRF_MODE_ENABLE_BIT | GRF_SPEED_ENABLE_BIT;
-
-	data |= GRF_SPEED_100M;
-	data |= GRF_MODE_RMII;
+	/* Set speed 100M */
+	data = (1 << (priv->soc_data->grf_speed_offset + 16)) |
+	       (1 << priv->soc_data->grf_speed_offset);
+	/* Set RMII mode */
+	data |= (1 << (priv->soc_data->grf_mode_offset + 16)) |
+		(0 << priv->soc_data->grf_mode_offset);
 
 	err = regmap_write(priv->grf, priv->soc_data->grf_offset, data);
 	if (err) {
@@ -181,6 +182,26 @@ static int emac_rockchip_probe(struct platform_device *pdev)
 	if (err)
 		dev_err(dev, "failed to change reference clock rate (%d)\n", err);
 
+	if (priv->soc_data->need_div_macclk) {
+		priv->macclk = devm_clk_get(dev, "macclk");
+		if (IS_ERR(priv->macclk)) {
+			dev_err(dev, "failed to retrieve mac clock (%ld)\n", PTR_ERR(priv->macclk));
+			err = PTR_ERR(priv->macclk);
+			goto out_regulator_disable;
+		}
+
+		err = clk_prepare_enable(priv->macclk);
+		if (err) {
+			dev_err(dev, "failed to enable mac clock (%d)\n", err);
+			goto out_regulator_disable;
+		}
+
+		/* RMII TX/RX needs always a rate of 25MHz */
+		err = clk_set_rate(priv->macclk, 25000000);
+		if (err)
+			dev_err(dev, "failed to change mac clock rate (%d)\n", err);
+	}
+
 	err = arc_emac_probe(ndev, interface);
 	if (err) {
 		dev_err(dev, "failed to probe arc emac (%d)\n", err);
-- 
1.7.9.5
