From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: net: stmmac: don't use netdev_[dbg, info, ..] before net_device is
 registered
Date: Sun, 15 Jan 2017 19:17:56 +0100
Message-ID: <da21972e-87cd-370c-e9ff-219fc82ebd10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36521 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdAOSSE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 13:18:04 -0500
Received: by mail-wm0-f68.google.com with SMTP id r126so25464832wmr.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 10:18:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use netdev_info and friends before the net_device is registered.
This avoids ugly messages like
"meson8b-dwmac c9410000.ethernet (unnamed net_device) (uninitialized):
Enable RX Mitigation via HW Watchdog Timer"

Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d481c5f7..38e1fb75 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3305,9 +3305,9 @@ int stmmac_dvr_probe(struct device *device,
 	    (priv->plat->maxmtu >= ndev->min_mtu))
 		ndev->max_mtu = priv->plat->maxmtu;
 	else if (priv->plat->maxmtu < ndev->min_mtu)
-		netdev_warn(priv->dev,
-			    "%s: warning: maxmtu having invalid value (%d)\n",
-			    __func__, priv->plat->maxmtu);
+		dev_warn(priv->device,
+			 "%s: warning: maxmtu having invalid value (%d)\n",
+			 __func__, priv->plat->maxmtu);
 
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
@@ -3319,7 +3319,8 @@ int stmmac_dvr_probe(struct device *device,
 	 */
 	if ((priv->synopsys_id >= DWMAC_CORE_3_50) && (!priv->plat->riwt_off)) {
 		priv->use_riwt = 1;
-		netdev_info(priv->dev, "Enable RX Mitigation via HW Watchdog Timer\n");
+		dev_info(priv->device,
+			 "Enable RX Mitigation via HW Watchdog Timer\n");
 	}
 
 	netif_napi_add(ndev, &priv->napi, stmmac_poll, 64);
@@ -3345,17 +3346,17 @@ int stmmac_dvr_probe(struct device *device,
 		/* MDIO bus Registration */
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
-			netdev_err(priv->dev,
-				   "%s: MDIO bus (id: %d) registration failed",
-				   __func__, priv->plat->bus_id);
+			dev_err(priv->device,
+				"%s: MDIO bus (id: %d) registration failed",
+				__func__, priv->plat->bus_id);
 			goto error_mdio_register;
 		}
 	}
 
 	ret = register_netdev(ndev);
 	if (ret) {
-		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
-			   __func__, ret);
+		dev_err(priv->device, "%s: ERROR %i registering the device\n",
+			__func__, ret);
 		goto error_netdev_register;
 	}
 
-- 
2.11.0
