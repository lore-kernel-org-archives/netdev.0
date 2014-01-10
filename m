From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH v2 03/16] net: stmmac: Add support for optional
 reset control
Date: Fri, 10 Jan 2014 15:00:04 +0800
Message-ID: <1389337217-29032-4-git-send-email-wens@csie.org>
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
Return-path: <linux-sunxi+bncBCMILY6JWQBBBBNVX2LAKGQEJDFSV7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1389337217-29032-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

The DWMAC has a reset assert line, which is used on some SoCs. Add an
optional reset control to stmmac driver core.

To support reset control deferred probing, this patch changes the driver
probe function to return the actual error, instead of just -EINVAL.

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt      |  3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |  2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 19 ++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  4 ++--
 5 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index eba0e5e..d132513 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -30,6 +30,9 @@ Required properties:
 
 Optional properties:
 - mac-address: 6 bytes, mac address
+- resets: Should contain a phandle to the STMMAC reset signal, if any
+- reset-names: Should contain the reset signal name "stmmaceth", if a
+	reset phandle is given
 
 Examples:
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 22f89ff..f19a040 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -32,6 +32,7 @@
 #include <linux/pci.h>
 #include "common.h"
 #include <linux/ptp_clock_kernel.h>
+#include <linux/reset.h>
 
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
@@ -91,6 +92,7 @@ struct stmmac_priv {
 	int wolopts;
 	int wol_irq;
 	struct clk *stmmac_clk;
+	struct reset_control *stmmac_rst;
 	int clk_csr;
 	struct timer_list eee_ctrl_timer;
 	int lpi_irq;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 786b51c..af2a313 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -50,6 +50,7 @@
 #include <linux/net_tstamp.h>
 #include "stmmac_ptp.h"
 #include "stmmac.h"
+#include <linux/reset.h>
 
 #define STMMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
 #define JUMBO_LEN	9000
@@ -2683,10 +2684,24 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (IS_ERR(priv->stmmac_clk)) {
 		dev_warn(priv->device, "%s: warning: cannot get CSR clock\n",
 			 __func__);
+		ret = PTR_ERR(priv->stmmac_clk);
 		goto error_clk_get;
 	}
 	clk_prepare_enable(priv->stmmac_clk);
 
+	priv->stmmac_rst = devm_reset_control_get(priv->device,
+						  STMMAC_RESOURCE_NAME);
+	if (IS_ERR(priv->stmmac_rst)) {
+		if (PTR_ERR(priv->stmmac_rst) == -EPROBE_DEFER) {
+			ret = -EPROBE_DEFER;
+			goto error_hw_init;
+		}
+		dev_info(priv->device, "no reset control found\n");
+		priv->stmmac_rst = NULL;
+	}
+	if (priv->stmmac_rst)
+		reset_control_deassert(priv->stmmac_rst);
+
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
 	if (ret)
@@ -2763,7 +2778,7 @@ error_hw_init:
 error_clk_get:
 	free_netdev(ndev);
 
-	return NULL;
+	return ERR_PTR(ret);
 }
 
 /**
@@ -2787,6 +2802,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
 		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
+	if (priv->stmmac_rst)
+		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->stmmac_clk);
 	free_netdev(ndev);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 644d80e..f3f6218 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -100,9 +100,9 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	stmmac_default_data();
 
 	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
-	if (!priv) {
+	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
-		ret = -ENODEV;
+		ret = PTR_ERR(priv);
 		goto err_out;
 	}
 	priv->dev->irq = pdev->irq;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 51c9069..3974586 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -148,9 +148,9 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 	}
 
 	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
-	if (!priv) {
+	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
-		return -ENODEV;
+		return PTR_ERR(priv);
 	}
 
 	/* Get MAC address if available (DT) */
-- 
1.8.5.2
