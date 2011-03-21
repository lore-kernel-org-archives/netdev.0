From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 2/4] drivers/net/fec: Use constants instead of magic numbers
Date: Mon, 21 Mar 2011 17:37:34 +0100
Message-ID: <264d7eca14554038e57399850ddd7fa4491a7484.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
 <cae922ff2a4ba144baf3d50f5d9fddd13d50e68b.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <u.kleine-koenig@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:58249 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab1CUQkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 12:40:07 -0400
In-Reply-To: <cae922ff2a4ba144baf3d50f5d9fddd13d50e68b.1300724245.git.LW@KARO-electronics.de>
In-Reply-To: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- No functional change.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/fec.c |   29 +++++++++++++++--------------
 drivers/net/fec.h |   15 +++++++++++++++
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index f00ee7f..2436db8 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -341,10 +341,10 @@ fec_restart(struct net_device *ndev, int duplex)
 				platform_get_device_id(fep->pdev);
 	int i;
 	u32 temp_mac[2];
-	u32 rcntl =3D OPT_FRAME_SIZE | 0x04;
+	u32 rcntl =3D OPT_FRAME_SIZE | FEC_R_CNTRL_MII_MODE;
=20
 	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
+	writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
 	udelay(10);
=20
 	/*
@@ -391,10 +391,10 @@ fec_restart(struct net_device *ndev, int duplex)
 	/* Enable MII mode */
 	if (duplex) {
 		/* FD enable */
-		writel(0x04, fep->hwp + FEC_X_CNTRL);
+		writel(FEC_X_CNTRL_FDEN, fep->hwp + FEC_X_CNTRL);
 	} else {
 		/* No Rcv on Xmit */
-		rcntl |=3D 0x02;
+		rcntl |=3D FEC_R_CNTRL_DRT;
 		writel(0x0, fep->hwp + FEC_X_CNTRL);
 	}
=20
@@ -409,19 +409,19 @@ fec_restart(struct net_device *ndev, int duplex)
 	 */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
 		/* Enable flow control and length check */
-		rcntl |=3D 0x40000000 | 0x00000020;
+		rcntl |=3D FEC_R_CNTRL_NO_LEN_CHK | FEC_R_CNTRL_FCE;
=20
 		/* MII or RMII */
 		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
-			rcntl |=3D (1 << 8);
+			rcntl |=3D FEC_R_CNTRL_RMII_MODE;
 		else
-			rcntl &=3D ~(1 << 8);
+			rcntl &=3D ~FEC_R_CNTRL_RMII_MODE;
=20
 		/* 10M or 100M */
 		if (fep->phy_dev && fep->phy_dev->speed =3D=3D SPEED_100)
-			rcntl &=3D ~(1 << 9);
+			rcntl &=3D ~FEC_R_CNTRL_RMII_10T;
 		else
-			rcntl |=3D (1 << 9);
+			rcntl |=3D FEC_R_CNTRL_RMII_10T;
=20
 	} else {
 #ifdef FEC_MIIGSK_ENR
@@ -445,7 +445,7 @@ fec_restart(struct net_device *ndev, int duplex)
 	writel(rcntl, fep->hwp + FEC_R_CNTRL);
=20
 	/* And last, enable the transmit and receive processing */
-	writel(2, fep->hwp + FEC_ECNTRL);
+	writel(FEC_ECNTRL_ETHER_EN, fep->hwp + FEC_ECNTRL);
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
=20
 	/* Enable interrupts we wish to service */
@@ -459,14 +459,15 @@ fec_stop(struct net_device *ndev)
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
-		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
+		/* Graceful transmit stop */
+		writel(FEC_X_CNTRL_GTS, fep->hwp + FEC_X_CNTRL);
 		udelay(10);
 		if (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_GRA))
 			printk("fec_stop : Graceful transmit stop did not complete !\n");
 	}
=20
 	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
+	writel(FEC_ECNTRL_RESET, fep->hwp + FEC_ECNTRL);
 	udelay(10);
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
@@ -1198,13 +1199,13 @@ static void set_multicast_list(struct net_devic=
e *ndev)
=20
 	if (ndev->flags & IFF_PROMISC) {
 		tmp =3D readl(fep->hwp + FEC_R_CNTRL);
-		tmp |=3D 0x8;
+		tmp |=3D FEC_R_CNTRL_PROM;
 		writel(tmp, fep->hwp + FEC_R_CNTRL);
 		return;
 	}
=20
 	tmp =3D readl(fep->hwp + FEC_R_CNTRL);
-	tmp &=3D ~0x8;
+	tmp &=3D ~FEC_R_CNTRL_PROM;
 	writel(tmp, fep->hwp + FEC_R_CNTRL);
=20
 	if (ndev->flags & IFF_ALLMULTI) {
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 8697556..68f4049 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -144,5 +144,20 @@ struct bufdesc {
 #define BD_ENET_TX_STATS	((ushort)0x03ff)	/* All status bits */
=20
=20
+/* register bit assignments */
+#define FEC_ECNTRL_ETHER_EN		(1 << 1)
+#define FEC_ECNTRL_RESET		(1 << 0)
+
+#define FEC_X_CNTRL_GTS			(1 << 0)
+#define FEC_X_CNTRL_FDEN		(1 << 2)
+
+#define FEC_R_CNTRL_DRT			(1 << 1)
+#define FEC_R_CNTRL_MII_MODE		(1 << 2)
+#define FEC_R_CNTRL_PROM		(1 << 3)
+#define FEC_R_CNTRL_FCE			(1 << 5)
+#define FEC_R_CNTRL_RMII_MODE		(1 << 8)
+#define FEC_R_CNTRL_RMII_10T		(1 << 9)
+#define FEC_R_CNTRL_NO_LEN_CHK		(1 << 30)
+
 /*********************************************************************=
*******/
 #endif /* FEC_H */
--=20
1.5.6.5

