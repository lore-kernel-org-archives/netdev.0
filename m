From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: fec: setup right value for mdio hold time
Date: Fri, 27 Mar 2015 11:08:32 +0100
Message-ID: <1427450912-9793-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	kernel@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53190 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbC0KJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 06:09:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC modules used on i.MX28 and newer have a register to tune the MD=
IO
output hold time that should be at least 10 ns. Up to now this value wa=
s not
explicitly set and so resulted in less hold time if the fec clock was
faster than 100 MHz.

This was noticed on an i.MX28 machine that uses an input clock of ~150
Mhz which resulted in unreliable communication with a Marvell switch.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 30 +++++++++++++++++++++++=
++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 78e1ce09b1ab..f6a3a7abd468 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1954,6 +1954,7 @@ static int fec_enet_mii_init(struct platform_devi=
ce *pdev)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct device_node *node;
 	int err =3D -ENXIO, i;
+	u32 mii_speed, holdtime;
=20
 	/*
 	 * The i.MX28 dual fec interfaces are not equal.
@@ -1991,10 +1992,33 @@ static int fec_enet_mii_init(struct platform_de=
vice *pdev)
 	 * Reference Manual has an error on this, and gets fixed on i.MX6Q
 	 * document.
 	 */
-	fep->phy_speed =3D DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 5000000);
+	mii_speed =3D DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 5000000);
 	if (fep->quirks & FEC_QUIRK_ENET_MAC)
-		fep->phy_speed--;
-	fep->phy_speed <<=3D 1;
+		mii_speed--;
+	if (mii_speed > 63) {
+		dev_err(&pdev->dev,
+			"fec clock (%lu) to fast to get right mii speed\n",
+			clk_get_rate(fep->clk_ipg));
+		err =3D -EINVAL;
+		goto err_out;
+	}
+
+	/*
+	 * The i.MX28 and i.MX6 types have another filed in the MSCR (aka
+	 * MII_SPEED) register that defines the MDIO output hold time. Earlie=
r
+	 * versions are RAZ there, so just ignore the difference and write th=
e
+	 * register always.
+	 * The minimal hold time according to IEE802.3 (clause 22) is 10 ns.
+	 * HOLDTIME + 1 is the number of clk cycles the fec is holding the
+	 * output.
+	 * The HOLDTIME bitfield takes values between 0 and 7 (inclusive).
+	 * Given that ceil(clkrate / 5000000) <=3D 64, the calculation for
+	 * holdtime cannot result in a value greater than 3.
+	 */
+	holdtime =3D DIV_ROUND_UP(clk_get_rate(fep->clk_ipg), 100000000) - 1;
+
+	fep->phy_speed =3D mii_speed << 1 | holdtime << 8;
+
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
=20
 	fep->mii_bus =3D mdiobus_alloc();
--=20
2.1.4
