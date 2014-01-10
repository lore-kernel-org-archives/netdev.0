From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH v2 02/16] net: stmmac: Enable stmmac main clock
 when probing hardware
Date: Fri, 10 Jan 2014 15:00:03 +0800
Message-ID: <1389337217-29032-3-git-send-email-wens@csie.org>
References: <1389337217-29032-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Emilio Lopez <emilio-0Z03zUJReD5OxF6Tv1QG9Q@public.gmane.org>,
	Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBBFVX2LAKGQEXIGKBXQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389337217-29032-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Guiseppe previously stated that the "stmmaceth" clock is the main clock
that drives the IP. The stmmac driver does not enable this clock during
the probe phase. If the clock was not enabled by the boot loader or
disabled by the kernel, hardware features and the MDIO bus would not be
probed properly.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 26 +++++++++++------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8a7a23a..786b51c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1604,8 +1604,6 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	clk_prepare_enable(priv->stmmac_clk);
-
 	stmmac_check_ether_addr(priv);
 
 	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
@@ -1796,7 +1794,6 @@ static int stmmac_release(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	stmmac_exit_fs();
 #endif
-	clk_disable_unprepare(priv->stmmac_clk);
 
 	stmmac_release_ptp(priv);
 
@@ -2682,10 +2679,18 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if ((phyaddr >= 0) && (phyaddr <= 31))
 		priv->plat->phy_addr = phyaddr;
 
+	priv->stmmac_clk = devm_clk_get(priv->device, STMMAC_RESOURCE_NAME);
+	if (IS_ERR(priv->stmmac_clk)) {
+		dev_warn(priv->device, "%s: warning: cannot get CSR clock\n",
+			 __func__);
+		goto error_clk_get;
+	}
+	clk_prepare_enable(priv->stmmac_clk);
+
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
 	if (ret)
-		goto error_free_netdev;
+		goto error_hw_init;
 
 	ndev->netdev_ops = &stmmac_netdev_ops;
 
@@ -2723,12 +2728,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		goto error_netdev_register;
 	}
 
-	priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
-	if (IS_ERR(priv->stmmac_clk)) {
-		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
-		goto error_clk_get;
-	}
-
 	/* If a specific clk_csr value is passed from the platform
 	 * this means that the CSR Clock Range selection cannot be
 	 * changed at run-time and it is fixed. Viceversa the driver'll try to
@@ -2756,12 +2755,12 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	return priv;
 
 error_mdio_register:
-	clk_put(priv->stmmac_clk);
-error_clk_get:
 	unregister_netdev(ndev);
 error_netdev_register:
 	netif_napi_del(&priv->napi);
-error_free_netdev:
+error_hw_init:
+	clk_disable_unprepare(priv->stmmac_clk);
+error_clk_get:
 	free_netdev(ndev);
 
 	return NULL;
@@ -2788,6 +2787,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
+	clk_disable_unprepare(priv->stmmac_clk);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.8.5.2
