From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH] net: fec: fix enet_out clock handling
Date: Fri, 27 Nov 2015 14:39:10 +0100
Message-ID: <1448631550-943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Kevin Hao <haokexin@gmail.com>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Lucas Stach <l.stach@pengutronix.de>,
	Nimrod Andy <B38611@freescale.com>,
	Philippe Reynes <tremyfr@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	=?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:59308 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbK0NmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 08:42:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ENET_OUT is being used as reference clock for an external PHY,
the clock must not be disabled while the PHY is active. Otherwise the
PHY may lose its internal state and require a reset to become
functional again.

A symptom for this bug is a network interface that constantly toggles
between UP and DOWN state:
fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx=
/tx
fec 800f0000.ethernet eth0: Link is Down
fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx=
/tx
fec 800f0000.ethernet eth0: Link is Down
[...]

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 34 +++++++++++++----------=
--------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index d2328fc..d9df4c5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1857,11 +1857,6 @@ static int fec_enet_clk_enable(struct net_device=
 *ndev, bool enable)
 		ret =3D clk_prepare_enable(fep->clk_ahb);
 		if (ret)
 			return ret;
-		if (fep->clk_enet_out) {
-			ret =3D clk_prepare_enable(fep->clk_enet_out);
-			if (ret)
-				goto failed_clk_enet_out;
-		}
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			ret =3D clk_prepare_enable(fep->clk_ptp);
@@ -1873,35 +1868,26 @@ static int fec_enet_clk_enable(struct net_devic=
e *ndev, bool enable)
 			}
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref) {
-			ret =3D clk_prepare_enable(fep->clk_ref);
-			if (ret)
-				goto failed_clk_ref;
-		}
+		ret =3D clk_prepare_enable(fep->clk_ref);
+		if (ret)
+			goto failed_clk_ref;
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
-		if (fep->clk_enet_out)
-			clk_disable_unprepare(fep->clk_enet_out);
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			clk_disable_unprepare(fep->clk_ptp);
 			fep->ptp_clk_on =3D false;
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref)
-			clk_disable_unprepare(fep->clk_ref);
+		clk_disable_unprepare(fep->clk_ref);
 	}
=20
 	return 0;
=20
 failed_clk_ref:
-	if (fep->clk_ref)
-		clk_disable_unprepare(fep->clk_ref);
+	clk_disable_unprepare(fep->clk_ref);
 failed_clk_ptp:
-	if (fep->clk_enet_out)
-		clk_disable_unprepare(fep->clk_enet_out);
-failed_clk_enet_out:
-		clk_disable_unprepare(fep->clk_ahb);
+	clk_disable_unprepare(fep->clk_ahb);
=20
 	return ret;
 }
@@ -3425,6 +3411,10 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_clk;
=20
+	ret =3D clk_prepare_enable(fep->clk_enet_out);
+	if (ret)
+		goto failed_clk_enet_out;
+
 	ret =3D clk_prepare_enable(fep->clk_ipg);
 	if (ret)
 		goto failed_clk_ipg;
@@ -3509,6 +3499,8 @@ failed_init:
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 failed_regulator:
+	clk_disable_unprepare(fep->clk_enet_out);
+failed_clk_enet_out:
 	clk_disable_unprepare(fep->clk_ipg);
 failed_clk_ipg:
 	fec_enet_clk_enable(ndev, false);
@@ -3531,6 +3523,8 @@ fec_drv_remove(struct platform_device *pdev)
 	fec_ptp_stop(pdev);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
+	fec_enet_clk_enable(ndev, false);
+	clk_disable_unprepare(fep->clk_enet_out);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	of_node_put(fep->phy_node);
--=20
2.1.4
