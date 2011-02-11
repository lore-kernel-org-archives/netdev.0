From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 14/14] net/fec: enable flow control and length check on enet-mac
Date: Fri, 11 Feb 2011 11:32:22 +0100
Message-ID: <1297420342-17739-14-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45154 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034Ab1BKKcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:55 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also optimize not to reread the value written to FEC_R_CNTRL.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index c322971..74798be 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -339,7 +339,8 @@ fec_restart(struct net_device *ndev, int duplex)
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
 	int i;
-	u32 val, temp_mac[2];
+	u32 temp_mac[2];
+	u32 rcntl =3D OPT_FRAME_SIZE | 0x04;
=20
 	/* Whack a reset.  We should wait for this. */
 	writel(1, fep->hwp + FEC_ECNTRL);
@@ -388,14 +389,14 @@ fec_restart(struct net_device *ndev, int duplex)
=20
 	/* Enable MII mode */
 	if (duplex) {
-		/* MII enable / FD enable */
-		writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
+		/* FD enable */
 		writel(0x04, fep->hwp + FEC_X_CNTRL);
 	} else {
-		/* MII enable / No Rcv on Xmit */
-		writel(OPT_FRAME_SIZE | 0x06, fep->hwp + FEC_R_CNTRL);
+		/* No Rcv on Xmit */
+		rcntl |=3D 0x02;
 		writel(0x0, fep->hwp + FEC_X_CNTRL);
 	}
+
 	fep->full_duplex =3D duplex;
=20
 	/* Set MII speed */
@@ -406,21 +407,21 @@ fec_restart(struct net_device *ndev, int duplex)
 	 * differently on enet-mac.
 	 */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
-		val =3D readl(fep->hwp + FEC_R_CNTRL);
+		/* Enable flow control and length check */
+		rcntl |=3D 0x40000000 | 0x00000020;
=20
 		/* MII or RMII */
 		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
-			val |=3D (1 << 8);
+			rcntl |=3D (1 << 8);
 		else
-			val &=3D ~(1 << 8);
+			rcntl &=3D ~(1 << 8);
=20
 		/* 10M or 100M */
 		if (fep->phy_dev && fep->phy_dev->speed =3D=3D SPEED_100)
-			val &=3D ~(1 << 9);
+			rcntl &=3D ~(1 << 9);
 		else
-			val |=3D (1 << 9);
+			rcntl |=3D (1 << 9);
=20
-		writel(val, fep->hwp + FEC_R_CNTRL);
 	} else {
 #ifdef FEC_MIIGSK_ENR
 		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII) {
@@ -440,6 +441,7 @@ fec_restart(struct net_device *ndev, int duplex)
 		}
 #endif
 	}
+	writel(rcntl, fep->hwp + FEC_R_CNTRL);
=20
 	/* And last, enable the transmit and receive processing */
 	writel(2, fep->hwp + FEC_ECNTRL);
--=20
1.7.2.3

