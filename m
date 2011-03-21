From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 3/4] drivers/net/fec: Fix dual MAC support on i.MX28
Date: Mon, 21 Mar 2011 17:37:35 +0100
Message-ID: <e8566dc34c4fd544ac630cf7908e4fb613e3ec1a.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <cae922ff2a4ba144baf3d50f5d9fddd13d50e68b.1300724245.git.LW@KARO-electronics.de>
 <264d7eca14554038e57399850ddd7fa4491a7484.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58253 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab1CUQkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:40:18 -0400
In-Reply-To: <264d7eca14554038e57399850ddd7fa4491a7484.1300724245.git.LW@KARO-electronics.de>
In-Reply-To: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variant of the FEC chip found on i.MX28 features two distinct
ethernet MACs that both share a single MII interface. When
deconfiguring the eth0 interface, the MII interface is currently being
switched off, so that the second MAC won't work any more.

Make sure, the first MAC is never disabled when the second FEC device
is registered.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/fec.c |   38 +++++++++++++++++++++++++++++++++-----
 1 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2436db8..3666524 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -82,6 +82,9 @@ static unsigned char macaddr[ETH_ALEN];
 module_param_array(macaddr, byte, NULL, 0);
 MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
=20
+static int dual_mac;
+module_param(dual_mac, int, S_IRUGO);
+
 #if defined(CONFIG_M5272)
 /*
  * Some hardware gets it MAC address out of local flash memory.
@@ -456,6 +459,8 @@ static void
 fec_stop(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	const struct platform_device_id *id_entry =3D
+				platform_get_device_id(fep->pdev);
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
@@ -466,11 +471,22 @@ fec_stop(struct net_device *ndev)
 			printk("fec_stop : Graceful transmit stop did not complete !\n");
 	}
=20
-	/* Whack a reset.  We should wait for this. */
-	writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
-	udelay(10);
-	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && dual_mac &&
+		fep->pdev->id =3D=3D 0) {
+		/* clear the RDAR/TDAR bits to stop recv/xmit,
+		 * but do not reset the controller since the second MAC
+		 * may still be using the MII interface and requires ETHER_EN
+		 * on the first MAC to be asserted for MII interrupts!
+		 */
+		writel(0, fep->hwp + FEC_ECNTRL);
+		writel(FEC_ECNTRL_ETHER_EN, fep->hwp + FEC_ECNTRL);
+	} else {
+		/* Whack a reset.  We should wait for this. */
+		writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+		writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
+		writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	}
 }
=20
 static void
@@ -1135,6 +1151,8 @@ static int
 fec_enet_open(struct net_device *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	const struct platform_device_id *id_entry =3D
+				platform_get_device_id(fep->pdev);
 	int ret;
=20
 	/* I should reset the ring buffers here, but I don't yet know
@@ -1145,6 +1163,14 @@ fec_enet_open(struct net_device *ndev)
 	if (ret)
 		return ret;
=20
+	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) &&
+		fep->pdev->id =3D=3D 0) {
+		/* ETHER_EN on first MAC has to be asserted
+		 * in order to generate MII interrupts
+		 */
+		fec_restart(ndev, 0);
+	}
+
 	/* Probe and connect to PHY when open the interface */
 	ret =3D fec_enet_mii_probe(ndev);
 	if (ret) {
@@ -1435,6 +1461,8 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
=20
+	if (pdev->id > 0)
+		dual_mac =3D 1;
 	return 0;
=20
 failed_register:
--=20
1.5.6.5

