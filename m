From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: fec: Fix build for MCF5272
Date: Mon, 17 Jun 2013 13:16:19 -0700
Message-ID: <1371500179-4733-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm7.access.bullet.mail.mud.yahoo.com ([66.94.237.208]:27162
	"EHLO nm7.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752587Ab3FQUQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 16:16:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits 4c09eed9 (net: fec: Enable imx6 enet checksum acceleration) and
baa70a5c (net: fec: enable pause frame to improve rx prefomance for 1G
network) introduced functionality into the FEC driver which is not
supported on MCF5272. As result, building images for MCF5272 fails,
complaining about several undefined symbols.

Disabled the added functionality for MCF5272 builds.

Cc: Frank Li <Frank.Li@freescale.com>
Cc: Jim Baxter <jim_baxter@mentor.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Sorry for the added ifdefs. If anyone has a better idea on how to fix
the problems, let me know.

This problem exists in 3.9 as well.

 drivers/net/ethernet/freescale/fec_main.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a667015..d48099f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -516,6 +516,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	/* Set MII speed */
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
+#if !defined(CONFIG_M5272)
 	/* set RX checksum */
 	val = readl(fep->hwp + FEC_RACC);
 	if (fep->csum_flags & FLAG_RX_CSUM_ENABLED)
@@ -523,6 +524,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	else
 		val &= ~FEC_RACC_OPTIONS;
 	writel(val, fep->hwp + FEC_RACC);
+#endif
 
 	/*
 	 * The phy interface and speed need to get configured
@@ -575,6 +577,7 @@ fec_restart(struct net_device *ndev, int duplex)
 #endif
 	}
 
+#if !defined(CONFIG_M5272)
 	/* enable pause frame*/
 	if ((fep->pause_flag & FEC_PAUSE_FLAG_ENABLE) ||
 	    ((fep->pause_flag & FEC_PAUSE_FLAG_AUTONEG) &&
@@ -592,6 +595,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	} else {
 		rcntl &= ~FEC_ENET_FCE;
 	}
+#endif /* !defined(CONFIG_M5272) */
 
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
 
@@ -1205,7 +1209,9 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	/* mask with MAC supported features */
 	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
 		phy_dev->supported &= PHY_GBIT_FEATURES;
+#if !defined(CONFIG_M5272)
 		phy_dev->supported |= SUPPORTED_Pause;
+#endif
 	}
 	else
 		phy_dev->supported &= PHY_BASIC_FEATURES;
@@ -1390,6 +1396,8 @@ static int fec_enet_get_ts_info(struct net_device *ndev,
 	}
 }
 
+#if !defined(CONFIG_M5272)
+
 static void fec_enet_get_pauseparam(struct net_device *ndev,
 				    struct ethtool_pauseparam *pause)
 {
@@ -1436,9 +1444,13 @@ static int fec_enet_set_pauseparam(struct net_device *ndev,
 	return 0;
 }
 
+#endif /* !defined(CONFIG_M5272) */
+
 static const struct ethtool_ops fec_enet_ethtool_ops = {
+#if !defined(CONFIG_M5272)
 	.get_pauseparam		= fec_enet_get_pauseparam,
 	.set_pauseparam		= fec_enet_set_pauseparam,
+#endif
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
@@ -1874,10 +1886,12 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep = netdev_priv(ndev);
 
+#if !defined(CONFIG_M5272)
 	/* default enable pause frame auto negotiation */
 	if (pdev->id_entry &&
 	    (pdev->id_entry->driver_data & FEC_QUIRK_HAS_GBIT))
 		fep->pause_flag |= FEC_PAUSE_FLAG_AUTONEG;
+#endif
 
 	fep->hwp = devm_request_and_ioremap(&pdev->dev, r);
 	fep->pdev = pdev;
-- 
1.7.9.7
