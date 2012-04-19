From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/4 (v2)] stmmac: Move the mdio_register/_unregister in probe/remove
Date: Thu, 19 Apr 2012 07:48:20 +0200
Message-ID: <1334814502-29707-2-git-send-email-peppe.cavallaro@st.com>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:45863 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751798Ab2DSFsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 01:48:37 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D90BB201
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:35 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 81D4118B5
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:35 +0000 (GMT)
In-Reply-To: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

This patch moves the mdio_register/_unregister in probe/remove
functions and this also is required when hibernation on disk
is done.

---

v2: remove useless open_clk_dis label and do a simple tidy-up
in the open function.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st,com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st,com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   34 ++++++++++-----------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a64f0d4..9ecd6cf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -933,24 +933,10 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
-	stmmac_clk_enable(priv);
-
-	stmmac_check_ether_addr(priv);
-
-	/* MDIO bus Registration */
-	ret = stmmac_mdio_register(dev);
-	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed",
-			 __func__, priv->plat->bus_id);
-		goto open_clk_dis;
-	}
-
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
-	if (unlikely(priv->tm == NULL)) {
-		ret = -ENOMEM;
-		goto open_clk_dis;
-	}
+	if (unlikely(priv->tm == NULL))
+		return -ENOMEM;
 
 	priv->tm->freq = tmrate;
 
@@ -964,6 +950,10 @@ static int stmmac_open(struct net_device *dev)
 	} else
 		priv->tm->enable = 1;
 #endif
+	stmmac_clk_enable(priv);
+
+	stmmac_check_ether_addr(priv);
+
 	ret = stmmac_init_phy(dev);
 	if (unlikely(ret)) {
 		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
@@ -1067,8 +1057,8 @@ open_error:
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
 
-open_clk_dis:
 	stmmac_clk_disable(priv);
+
 	return ret;
 }
 
@@ -1120,7 +1110,6 @@ static int stmmac_release(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	stmmac_exit_fs();
 #endif
-	stmmac_mdio_unregister(dev);
 	stmmac_clk_disable(priv);
 
 	return 0;
@@ -1932,6 +1921,14 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	else
 		priv->clk_csr = priv->plat->clk_csr;
 
+	/* MDIO bus Registration */
+	ret = stmmac_mdio_register(ndev);
+	if (ret < 0) {
+		pr_debug("%s: MDIO bus (id: %d) registration failed",
+			 __func__, priv->plat->bus_id);
+		goto error;
+	}
+
 	return priv;
 
 error:
@@ -1959,6 +1956,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
+	stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-- 
1.7.4.4
