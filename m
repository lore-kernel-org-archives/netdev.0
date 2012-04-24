From: Viresh Kumar <viresh.kumar@st.com>
Subject: [PATCH V3 09/12] net/stmmac: Remove conditional compilation of clk code
Date: Tue, 24 Apr 2012 16:51:31 +0530
Message-ID: <89f56d84bec59d80f0f175ad6e6d9a3432892f9f.1335266056.git.viresh.kumar@st.com>
References: <cover.1335266056.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <spear-devel@list.st.com>, <viresh.linux@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <mturquette@linaro.org>,
	<sshtylyov@mvista.com>, <jgarzik@redhat.com>,
	<linux@arm.linux.org.uk>, Viresh Kumar <viresh.kumar@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1335266056.git.viresh.kumar@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With addition of dummy clk_*() calls for non CONFIG_HAVE_CLK cases in clk.h,
there is no need to have clk code enclosed in #ifdef CONFIG_HAVE_CLK, #endif
macros.

This also fixes error paths of probe(), as a goto is required in this patch.

Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   41 ---------------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   33 +++++++++--------
 2 files changed, 17 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index db2de9a..7f85895 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -81,9 +81,7 @@ struct stmmac_priv {
 	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
 	int hw_cap_support;
-#ifdef CONFIG_HAVE_CLK
 	struct clk *stmmac_clk;
-#endif
 	int clk_csr;
 };
 
@@ -103,42 +101,3 @@ int stmmac_dvr_remove(struct net_device *ndev);
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
 				     void __iomem *addr);
-
-#ifdef CONFIG_HAVE_CLK
-static inline int stmmac_clk_enable(struct stmmac_priv *priv)
-{
-	if (!IS_ERR(priv->stmmac_clk))
-		return clk_enable(priv->stmmac_clk);
-
-	return 0;
-}
-
-static inline void stmmac_clk_disable(struct stmmac_priv *priv)
-{
-	if (IS_ERR(priv->stmmac_clk))
-		return;
-
-	clk_disable(priv->stmmac_clk);
-}
-static inline int stmmac_clk_get(struct stmmac_priv *priv)
-{
-	priv->stmmac_clk = clk_get(priv->device, NULL);
-
-	if (IS_ERR(priv->stmmac_clk))
-		return PTR_ERR(priv->stmmac_clk);
-
-	return 0;
-}
-#else
-static inline int stmmac_clk_enable(struct stmmac_priv *priv)
-{
-	return 0;
-}
-static inline void stmmac_clk_disable(struct stmmac_priv *priv)
-{
-}
-static inline int stmmac_clk_get(struct stmmac_priv *priv)
-{
-	return 0;
-}
-#endif /* CONFIG_HAVE_CLK */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1a4cf81..bbdcb55 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -28,6 +28,7 @@
 	https://bugzilla.stlinux.com/
 *******************************************************************************/
 
+#include <linux/clk.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/ip.h>
@@ -165,12 +166,8 @@ static void stmmac_verify_args(void)
 
 static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 {
-#ifdef CONFIG_HAVE_CLK
 	u32 clk_rate;
 
-	if (IS_ERR(priv->stmmac_clk))
-		return;
-
 	clk_rate = clk_get_rate(priv->stmmac_clk);
 
 	/* Platform provided default clk_csr would be assumed valid
@@ -192,7 +189,6 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 	   * we can not estimate the proper divider as it is not known
 	   * the frequency of clk_csr_i. So we do not change the default
 	   * divider. */
-#endif
 }
 
 #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
@@ -971,7 +967,7 @@ static int stmmac_open(struct net_device *dev)
 	} else
 		priv->tm->enable = 1;
 #endif
-	stmmac_clk_enable(priv);
+	clk_enable(priv->stmmac_clk);
 
 	stmmac_check_ether_addr(priv);
 
@@ -1075,7 +1071,7 @@ open_error:
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
 
-	stmmac_clk_disable(priv);
+	clk_disable(priv->stmmac_clk);
 
 	return ret;
 }
@@ -1128,7 +1124,7 @@ static int stmmac_release(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	stmmac_exit_fs();
 #endif
-	stmmac_clk_disable(priv);
+	clk_disable(priv->stmmac_clk);
 
 	return 0;
 }
@@ -1922,11 +1918,14 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	ret = register_netdev(ndev);
 	if (ret) {
 		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
-		goto error;
+		goto error_netdev_register;
 	}
 
-	if (stmmac_clk_get(priv))
+	priv->stmmac_clk = clk_get(priv->device, NULL);
+	if (IS_ERR(priv->stmmac_clk)) {
 		pr_warning("%s: warning: cannot get CSR clock\n", __func__);
+		goto error_clk_get;
+	}
 
 	/* If a specific clk_csr value is passed from the platform
 	 * this means that the CSR Clock Range selection cannot be
@@ -1944,15 +1943,17 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (ret < 0) {
 		pr_debug("%s: MDIO bus (id: %d) registration failed",
 			 __func__, priv->plat->bus_id);
-		goto error;
+		goto error_mdio_register;
 	}
 
 	return priv;
 
-error:
-	netif_napi_del(&priv->napi);
-
+error_mdio_register:
+	clk_put(priv->stmmac_clk);
+error_clk_get:
 	unregister_netdev(ndev);
+error_netdev_register:
+	netif_napi_del(&priv->napi);
 	free_netdev(ndev);
 
 	return NULL;
@@ -2020,7 +2021,7 @@ int stmmac_suspend(struct net_device *ndev)
 	else {
 		stmmac_set_mac(priv->ioaddr, false);
 		/* Disable clock in case of PWM is off */
-		stmmac_clk_disable(priv);
+		clk_disable(priv->stmmac_clk);
 	}
 	spin_unlock(&priv->lock);
 	return 0;
@@ -2044,7 +2045,7 @@ int stmmac_resume(struct net_device *ndev)
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 	else
 		/* enable the clk prevously disabled */
-		stmmac_clk_enable(priv);
+		clk_enable(priv->stmmac_clk);
 
 	netif_device_attach(ndev);
 
-- 
1.7.9
