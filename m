From: Andrew Bresticker <abrestic@chromium.org>
Subject: [PATCH] stmmac: Add an optional register interface clock
Date: Tue,  7 Apr 2015 13:38:45 -0700
Message-ID: <1428439125-26023-1-git-send-email-abrestic@chromium.org>
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Bresticker <abrestic@chromium.org>,
	James Hartley <james.hartley@imgtec.com>,
	Arnd Bergmann <arnd@arndb.de>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DWMAC block on certain SoCs (such as IMG Pistachio) have a second
clock which must be enabled in order to access the peripheral's
register interface, so add support for requesting and enabling an
optional "pclk".

Signed-off-by: Andrew Bresticker <abrestic@chromium.org>
Cc: James Hartley <james.hartley@imgtec.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 Documentation/devicetree/bindings/net/stmmac.txt  |  7 ++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 15 +++++++++++++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 8ca65ce..29aca85 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -35,10 +35,11 @@ Optional properties:
 - reset-names: Should contain the reset signal name "stmmaceth", if a
 	reset phandle is given
 - max-frame-size: See ethernet.txt file in the same directory
-- clocks: If present, the first clock should be the GMAC main clock,
-  further clocks may be specified in derived bindings.
+- clocks: If present, the first clock should be the GMAC main clock and
+  the second clock should be peripheral's register interface clock. Further
+  clocks may be specified in derived bindings.
 - clock-names: One name for each entry in the clocks property, the
-  first one should be "stmmaceth".
+  first one should be "stmmaceth" and the second one should be "pclk".
 - clk_ptp_ref: this is the PTP reference clock; in case of the PTP is
   available this clock is used for programming the Timestamp Addend Register.
   If not passed then the system clock will be used and this is fine on some
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c0a3919..2ac9552 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -97,6 +97,7 @@ struct stmmac_priv {
 	int wolopts;
 	int wol_irq;
 	struct clk *stmmac_clk;
+	struct clk *pclk;
 	struct reset_control *stmmac_rst;
 	int clk_csr;
 	struct timer_list eee_ctrl_timer;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5336594..06103ca 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2849,6 +2849,16 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	}
 	clk_prepare_enable(priv->stmmac_clk);
 
+	priv->pclk = devm_clk_get(priv->device, "pclk");
+	if (IS_ERR(priv->pclk)) {
+		if (PTR_ERR(priv->pclk) == -EPROBE_DEFER) {
+			ret = -EPROBE_DEFER;
+			goto error_pclk_get;
+		}
+		priv->pclk = NULL;
+	}
+	clk_prepare_enable(priv->pclk);
+
 	priv->stmmac_rst = devm_reset_control_get(priv->device,
 						  STMMAC_RESOURCE_NAME);
 	if (IS_ERR(priv->stmmac_rst)) {
@@ -2934,6 +2944,8 @@ error_mdio_register:
 error_netdev_register:
 	netif_napi_del(&priv->napi);
 error_hw_init:
+	clk_disable_unprepare(priv->pclk);
+error_pclk_get:
 	clk_disable_unprepare(priv->stmmac_clk);
 error_clk_get:
 	free_netdev(ndev);
@@ -2965,6 +2977,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	unregister_netdev(ndev);
 	if (priv->stmmac_rst)
 		reset_control_assert(priv->stmmac_rst);
+	clk_disable_unprepare(priv->pclk);
 	clk_disable_unprepare(priv->stmmac_clk);
 	free_netdev(ndev);
 
@@ -3011,6 +3024,7 @@ int stmmac_suspend(struct net_device *ndev)
 		stmmac_set_mac(priv->ioaddr, false);
 		pinctrl_pm_select_sleep_state(priv->device);
 		/* Disable clock in case of PWM is off */
+		clk_disable(priv->pclk);
 		clk_disable(priv->stmmac_clk);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -3051,6 +3065,7 @@ int stmmac_resume(struct net_device *ndev)
 		pinctrl_pm_select_default_state(priv->device);
 		/* enable the clk prevously disabled */
 		clk_enable(priv->stmmac_clk);
+		clk_enable(priv->pclk);
 		/* reset the phy so that it's ready */
 		if (priv->mii)
 			stmmac_mdio_reset(priv->mii);
-- 
2.2.0.rc0.207.ga3a616c
