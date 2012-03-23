From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 07/10] stmmac: add clk management support
Date: Fri, 23 Mar 2012 10:08:38 +0100
Message-ID: <1332493721-28309-8-git-send-email-peppe.cavallaro@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com,
	deepak.sikri@st.com, spear-devel@list.st.com, shiraz.hashim@st.com,
	viresh.kumar@st.com, bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:58294 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757293Ab2CWJJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:09:36 -0400
In-Reply-To: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch adds the way to enable/disable the MAC
clock when call the open/close and resume/restore
functions.
This has been tested on ST platforms and SPEAr; thanks
to Francesco and Deepak.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
Tested-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   43 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   25 ++++++++++--
 2 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b65d787..7182f15 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -22,6 +22,8 @@
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
 #define DRV_MODULE_VERSION	"Feb_2012"
+
+#include <linux/clk.h>
 #include <linux/stmmac.h>
 #include <linux/phy.h>
 #include "common.h"
@@ -79,6 +81,9 @@ struct stmmac_priv {
 	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
 	int hw_cap_support;
+#ifdef CONFIG_HAVE_CLK
+	struct clk *stmmac_clk;
+#endif
 };
 
 extern int phyaddr;
@@ -97,3 +102,41 @@ int stmmac_dvr_remove(struct net_device *ndev);
 struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 				     struct plat_stmmacenet_data *plat_dat,
 				     void __iomem *addr);
+
+#ifdef CONFIG_HAVE_CLK
+static inline int stmmac_clk_enable(struct stmmac_priv *priv)
+{
+	if (priv->stmmac_clk)
+		return clk_enable(priv->stmmac_clk);
+
+	return 0;
+}
+
+static inline void stmmac_clk_disable(struct stmmac_priv *priv)
+{
+	if (priv->stmmac_clk)
+		clk_disable(priv->stmmac_clk);
+}
+static inline int stmmac_clk_get(struct stmmac_priv *priv)
+{
+	priv->stmmac_clk = clk_get(priv->device, NULL);
+
+	if (IS_ERR(priv->stmmac_clk)) {
+		pr_err("%s: ERROR clk_get failed\n", __func__);
+		return PTR_ERR(priv->stmmac_clk);
+	}
+	return 0;
+}
+#else
+static inline int stmmac_clk_enable(struct stmmac_priv *priv)
+{
+	return 0;
+}
+static inline void stmmac_clk_disable(struct stmmac_priv *priv)
+{
+}
+static inline int stmmac_clk_get(struct stmmac_priv *priv)
+{
+	return 0;
+}
+#endif /* CONFIG_HAVE_CLK */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7ac13d5..08b4d05 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -904,6 +904,8 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
+	stmmac_clk_enable(priv);
+
 	stmmac_check_ether_addr(priv);
 
 	/* MDIO bus Registration */
@@ -911,13 +913,15 @@ static int stmmac_open(struct net_device *dev)
 	if (ret < 0) {
 		pr_debug("%s: MDIO bus (id: %d) registration failed",
 			 __func__, priv->plat->bus_id);
-		return ret;
+		goto open_clk_dis;
 	}
 
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
-	if (unlikely(priv->tm == NULL))
-		return -ENOMEM;
+	if (unlikely(priv->tm == NULL)) {
+		ret = -ENOMEM;
+		goto open_clk_dis;
+	}
 
 	priv->tm->freq = tmrate;
 
@@ -1034,6 +1038,8 @@ open_error:
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
 
+open_clk_dis:
+	stmmac_clk_disable(priv);
 	return ret;
 }
 
@@ -1086,6 +1092,7 @@ static int stmmac_release(struct net_device *dev)
 	stmmac_exit_fs();
 #endif
 	stmmac_mdio_unregister(dev);
+	stmmac_clk_disable(priv);
 
 	return 0;
 }
@@ -1872,6 +1879,9 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		goto error;
 	}
 
+	if (stmmac_clk_get(priv))
+		goto error;
+
 	return priv;
 
 error:
@@ -1941,9 +1951,11 @@ int stmmac_suspend(struct net_device *ndev)
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device))
 		priv->hw->mac->pmt(priv->ioaddr, priv->wolopts);
-	else
+	else {
 		stmmac_set_mac(priv->ioaddr, false);
-
+		/* Disable clock in case of PWM is off */
+		stmmac_clk_disable(priv);
+	}
 	spin_unlock(&priv->lock);
 	return 0;
 }
@@ -1964,6 +1976,9 @@ int stmmac_resume(struct net_device *ndev)
 	 * from another devices (e.g. serial console). */
 	if (device_may_wakeup(priv->device))
 		priv->hw->mac->pmt(priv->ioaddr, 0);
+	else
+		/* enable the clk prevously disabled */
+		stmmac_clk_enable(priv);
 
 	netif_device_attach(ndev);
 
-- 
1.7.4.4
