From: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: [RESEND PATCH v1 2/4] net: ethernet: arc: Keep emac compatibility for
 more Rockchip SoCs
Date: Mon, 28 Dec 2015 15:22:19 +0800
Message-ID: <1451287341-16453-3-git-send-email-zhengxing@rock-chips.com>
References: <1451287341-16453-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 leozwang-hpIqsD4AKlcxg7vii5yOFA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1451287341-16453-1-git-send-email-zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
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

On the RK3066/RK3188, there was fixed GRF offset configuration to set emac
and fixed DIV2 mac TX/RX clock. So, we need to easily set and fit to other
SoCs (RK3036) which maybe have different GRF offset, and need adjust mac
TX/RX clock.

Signed-off-by: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
---

 drivers/net/ethernet/arc/emac_rockchip.c |   66 ++++++++++++++++++++----------
 1 file changed, 44 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
index 36e9eb1..d1a9c28 100644
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
@@ -73,8 +68,14 @@ static void emac_rockchip_set_mac_speed(void *priv, unsigned int speed)
 }
 
 static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
-	{ .grf_offset = 0x154 }, /* rk3066 */
-	{ .grf_offset = 0x0a4 }, /* rk3188 */
+	{
+	  .grf_offset = 0x154,   .grf_mode_offset = 0,
+	  .grf_speed_offset = 1, .need_div_macclk = 0
+	}, /* rk3066 */
+	{
+	  .grf_offset = 0x0a4,   .grf_mode_offset = 0,
+	  .grf_speed_offset = 1, .need_div_macclk = 0
+	}, /* rk3188 */
 };
 
 static const struct of_device_id emac_rockchip_dt_ids[] = {
@@ -110,7 +111,7 @@ static int emac_rockchip_probe(struct platform_device *pdev)
 
 	interface = of_get_phy_mode(dev->of_node);
 
-	/* RK3066 and RK3188 SoCs only support RMII */
+	/* RK3036/RK3066/RK3188 SoCs only support RMII */
 	if (interface != PHY_INTERFACE_MODE_RMII) {
 		dev_err(dev, "unsupported phy interface mode %d\n", interface);
 		err = -ENOTSUPP;
@@ -164,11 +165,12 @@ static int emac_rockchip_probe(struct platform_device *pdev)
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
@@ -181,6 +183,26 @@ static int emac_rockchip_probe(struct platform_device *pdev)
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
