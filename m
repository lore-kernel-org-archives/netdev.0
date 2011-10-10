From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: net/fec on i.MX28: failure after network cable unplug or device down
Date: Mon, 10 Oct 2011 15:17:05 +0200
Message-ID: <20111010131705.GA25293@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42346 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753012Ab1JJNRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 09:17:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I currently see the problem on two different i.MX28 based system
(Freescale's mx28evk and a Karo TX28) that after unplugging and
reconnection of the network cable or ifconfig down; ifconfig up; the
network is dead. That means nothing is sent or received anymore.

ifconfig up dies with:

	[   32.120000] FEC: MDIO read timeout
	[   32.120000] eth0: could not attach to PHY
	ifconfig: SIOCSIFFLAGS: Connection timed out

after unplugging the network cable I get:

	[   25.520000] PHY: 1:00 - Link is Down
	[   26.530000] FEC: MDIO read timeout

In both cases the mdio read operation doesn't fire the mii irq, though
the FEC_MII_DATA contains data that looks right and the interrupt
register (FEC_IEVENT) has the mii bit set and according to the mask
register (FEC_IMASK) the irq isn't masked.

When commenting out

	writel(1, fep->hwp + FEC_ECNTRL);

(i.e. don't reset the network unit) in fec_stop it works (but Wolfram
seems to remember that doing so breaks e.g. i.MX35. We have not checked
yet).

Strange enough with the reset commented out in fec_stop, fec_restart
resets the fec (when the cable is reconnected) but without breaking it.

I tried to restore more registers in fec_stop (most notably FEC_R_CNTRL
that has some mii fields) but without success.

Do you see this problem, too? Maybe do you have an idea to fix it?
Currently I use the following patch:

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 5b631fe..8c1330f 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -458,6 +458,8 @@ static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	const struct platform_device_id *id_entry =3D
+				platform_get_device_id(fep->pdev);
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
@@ -467,11 +469,13 @@ fec_stop(struct net_device *ndev)
 			printk("fec_stop : Graceful transmit stop did not complete !\n");
 	}
=20
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
-	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	if (!(id_entry->driver_data & FEC_QUIRK_ENET_MAC)) {
+		/* Whack a reset.  We should wait for this. */
+		writel(1, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+		writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
+		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	}
 }
=20
but this feels wrong because sending and receiving isn't disabled in
hardware without link then.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
