From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 4/4] drivers/net/fec: Don't mess with configured MAC addresses.
Date: Tue, 22 Mar 2011 11:00:02 +0100
Message-ID: <e7cec31bec3eb7dad56688c4390a59f99625ea83.1300724245.git.LW@KARO-electronics.de>
References: <20110322092256.GG28098@S2100-06.ap.freescale.net>
 <49cf2dff25189eb7b7a0ff9eaceefab359f08b2e.1300724245.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>,
	<u.kleine-koenig@pengutronix.de>,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53113 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab1CVKAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 06:00:05 -0400
In-Reply-To: <49cf2dff25189eb7b7a0ff9eaceefab359f08b2e.1300724245.git.LW@KARO-electronics.de>
In-Reply-To: <49cf2dff25189eb7b7a0ff9eaceefab359f08b2e.1300724245.git.LW@KARO-electronics.de>
References: <4034db082a05693893d24f4b0db4063b84d8c268.1300724245.git.LW@KARO-electronics.de>,
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The FEC driver currently uses the MAC address assigned to the first
interface incremented by one for the second interface.

Change this to be able to configure distinct MAC addresses via
platform_data.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/fec.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3666524..9d89e99 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -736,7 +736,7 @@ static void __inline__ fec_get_mac(struct net_devic=
e *ndev)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct fec_platform_data *pdata =3D fep->pdev->dev.platform_data;
-	unsigned char *iap, tmpaddr[ETH_ALEN];
+	unsigned char iap[ETH_ALEN], tmpaddr[ETH_ALEN];
=20
 	/*
 	 * try to get mac address in following order:
@@ -744,7 +744,10 @@ static void __inline__ fec_get_mac(struct net_devi=
ce *ndev)
 	 * 1) module parameter via kernel command line in form
 	 *    fec.macaddr=3D0x00,0x04,0x9f,0x01,0x30,0xe0
 	 */
-	iap =3D macaddr;
+	if (fep->pdev->id =3D=3D 0)
+		memcpy(iap, macaddr, ETH_ALEN);
+	else
+		memset(iap, 0, ETH_ALEN);
=20
 	/*
 	 * 2) from flash or fuse (via platform data)
@@ -767,14 +770,10 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *ndev)
 			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
 		*((unsigned short *) &tmpaddr[4]) =3D
 			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
-		iap =3D &tmpaddr[0];
+		memcpy(iap, tmpaddr, ETH_ALEN);
 	}
=20
 	memcpy(ndev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using macaddr */
-	if (iap =3D=3D macaddr)
-		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev->id;
 }
=20
 /* -------------------------------------------------------------------=
------ */
--=20
1.5.6.5
