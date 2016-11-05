From: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/4] stmmac: dwmac-rk: turn exit into standard driver
 remove callback
Date: Sat,  5 Nov 2016 14:04:50 +0100
Message-ID: <20161105130452.24226-3-manabian@gmail.com>
References: <20161105130452.24226-1-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 peppe.cavallaro-qxv4g6HH51o@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161105130452.24226-1-manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Convert the exit hook into a standard driver remove function as
the hook doesn't really buy us anything extra.

Eventually the exit hook will be deprecated in favor of the driver
remove function.

Signed-off-by: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index d91acd5..8506881 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -908,13 +908,6 @@ static int rk_gmac_init(struct platform_device *pdev, void *priv)
 	return rk_gmac_powerup(bsp_priv);
 }
 
-static void rk_gmac_exit(struct platform_device *pdev, void *priv)
-{
-	struct rk_priv_data *bsp_priv = priv;
-
-	rk_gmac_powerdown(bsp_priv);
-}
-
 static void rk_fix_speed(void *priv, unsigned int speed)
 {
 	struct rk_priv_data *bsp_priv = priv;
@@ -951,7 +944,6 @@ static int rk_gmac_probe(struct platform_device *pdev)
 
 	plat_dat->has_gmac = true;
 	plat_dat->init = rk_gmac_init;
-	plat_dat->exit = rk_gmac_exit;
 	plat_dat->fix_mac_speed = rk_fix_speed;
 
 	plat_dat->bsp_priv = rk_gmac_setup(pdev, data);
@@ -965,6 +957,16 @@ static int rk_gmac_probe(struct platform_device *pdev)
 	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 
+static int rk_gmac_remove(struct platform_device *pdev)
+{
+	struct rk_priv_data *bsp_priv = get_stmmac_bsp_priv(&pdev->dev);
+	int ret = stmmac_dvr_remove(&pdev->dev);
+
+	rk_gmac_powerdown(bsp_priv);
+
+	return ret;
+}
+
 #ifdef CONFIG_PM_SLEEP
 static int rk_gmac_suspend(struct device *dev)
 {
@@ -1008,7 +1010,7 @@ MODULE_DEVICE_TABLE(of, rk_gmac_dwmac_match);
 
 static struct platform_driver rk_gmac_dwmac_driver = {
 	.probe  = rk_gmac_probe,
-	.remove = stmmac_pltfr_remove,
+	.remove = rk_gmac_remove,
 	.driver = {
 		.name           = "rk_gmac-dwmac",
 		.pm		= &rk_gmac_pm_ops,
-- 
2.10.2
