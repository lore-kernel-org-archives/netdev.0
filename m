From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2] stmmac: Move the mdio_register/_unregister in probe/remove
Date: Wed, 18 Apr 2012 09:43:53 +0200
Message-ID: <1334735033-6969-2-git-send-email-peppe.cavallaro@st.com>
References: <1334735033-6969-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:59892 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750891Ab2DRHoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 03:44:16 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D6613F1
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:44:14 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 73A32196F
	for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 07:44:14 +0000 (GMT)
In-Reply-To: <1334735033-6969-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

This patch moves the mdio_register/_unregister in probe/remove
functions and this also is required when hibernation on disk
is done.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st,com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st,com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 48d56da..61a5f17 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -900,14 +900,6 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_check_ether_addr(priv);
 
-	/* MDIO bus Registration */
-	ret = stmmac_mdio_register(dev);
-	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed",
-			 __func__, priv->plat->bus_id);
-		return ret;
-	}
-
 #ifdef CONFIG_STMMAC_TIMER
 	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL))
@@ -1077,7 +1069,6 @@ static int stmmac_release(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	stmmac_exit_fs();
 #endif
-	stmmac_mdio_unregister(dev);
 
 	return 0;
 }
@@ -1856,6 +1847,14 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		goto error;
 	}
 
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
@@ -1883,6 +1882,7 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
+	stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-- 
1.7.4.4
