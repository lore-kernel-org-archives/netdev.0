From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 4/9] net: stmmac: Balance PTP reference clock enable/disable
Date: Fri, 10 Mar 2017 17:34:56 +0100
Message-ID: <20170310163501.31811-5-thierry.reding@gmail.com>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170310163501.31811-1-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

clk_prepare_enable() and clk_disable_unprepare() for this clock aren't
properly balanced, which can trigger a WARN_ON() in the common clock
framework.

Reviewed-By: Joao Pinto <jpinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 4 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6060410d2b9e..ce6d7e791f3f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1711,6 +1711,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	stmmac_mmc_setup(priv);
 
 	if (init_ptp) {
+		ret = clk_prepare_enable(priv->plat->clk_ptp_ref);
+		if (ret < 0)
+			netdev_warn(priv->dev, "failed to enable PTP reference clock: %d\n", ret);
+
 		ret = stmmac_init_ptp(priv);
 		if (ret == -EOPNOTSUPP)
 			netdev_warn(priv->dev, "PTP not supported by HW\n");
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f2d94eafeb0a..fe49c3105755 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -365,7 +365,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		plat->clk_ptp_ref = NULL;
 		dev_warn(&pdev->dev, "PTP uses main clock\n");
 	} else {
-		clk_prepare_enable(plat->clk_ptp_ref);
 		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
 		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
 	}
-- 
2.12.0
