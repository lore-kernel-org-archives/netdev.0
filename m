From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 09/17] stmmac: dwmac-rk: create a new probe function
Date: Wed, 29 Jul 2015 00:08:56 +0200
Message-ID: <1438121344-5304-10-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1438121344-5304-1-git-send-email-manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Create a new probe functions that call the necessary setup
functions. This is done in preparation for a code refactor
in this driver and dropping the common probe function in
stmmac_platform.c.

Signed-off-by: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 40 ++++++++++++++++++++------
 1 file changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 00a1e1e09d4f..21193a73acfc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -576,20 +576,42 @@ static void rk_fix_speed(void *priv, unsigned int speed)
 		dev_err(dev, "unsupported interface %d", bsp_priv->phy_iface);
 }
 
+static int rk_gmac_probe(struct platform_device *pdev)
+{
+	struct plat_stmmacenet_data *plat_dat;
+	struct stmmac_resources stmmac_res;
+	int ret;
+
+	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
+	if (ret)
+		return ret;
+
+	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
+	if (IS_ERR(plat_dat))
+		return PTR_ERR(plat_dat);
+
+	plat_dat->has_gmac = true;
+	plat_dat->init = rk_gmac_init;
+	plat_dat->exit = rk_gmac_exit;
+	plat_dat->fix_mac_speed = rk_fix_speed;
+
+	plat_dat->bsp_priv = plat_dat->setup(pdev);
+	if (IS_ERR(plat_dat->bsp_priv))
+		return PTR_ERR(plat_dat->bsp_priv);
+
+	ret = rk_gmac_init(pdev, plat_dat->bsp_priv);
+	if (ret)
+		return ret;
+
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
+}
+
 static const struct stmmac_of_data rk3288_gmac_data = {
-	.has_gmac = 1,
-	.fix_mac_speed = rk_fix_speed,
 	.setup = rk3288_gmac_setup,
-	.init = rk_gmac_init,
-	.exit = rk_gmac_exit,
 };
 
 static const struct stmmac_of_data rk3368_gmac_data = {
-	.has_gmac = 1,
-	.fix_mac_speed = rk_fix_speed,
 	.setup = rk3368_gmac_setup,
-	.init = rk_gmac_init,
-	.exit = rk_gmac_exit,
 };
 
 static const struct of_device_id rk_gmac_dwmac_match[] = {
@@ -600,7 +622,7 @@ static const struct of_device_id rk_gmac_dwmac_match[] = {
 MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
 
 static struct platform_driver rk_gmac_dwmac_driver = {
-	.probe  = stmmac_pltfr_probe,
+	.probe  = rk_gmac_probe,
 	.remove = stmmac_pltfr_remove,
 	.driver = {
 		.name           = "rk_gmac-dwmac",
-- 
1.8.0
