From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Subject: [PATCHv2 2.6.32-rc5] r8169: fix Ethernet Hangup for RTL8110SC rev d
Date: Fri, 23 Oct 2009 08:57:17 +0200
Message-ID: <20091023065717.GA22484@pandem0nium>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2oS5YaxWCcQjTEyO"
To: netdev@vger.kernel.org, simon.wunderlich@saxnet.de,
	David Miller <davem@davemloft.net>, bernhard.schmidt@saxnet.de,
	romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jessica.hrz.tu-chemnitz.de ([134.109.132.47]:52303 "EHLO
	jessica.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbZJWG5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 02:57:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=utf8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The 8110SC rev d chip on our board shows a regression which the 8110SB chip
did not have. When inbound traffic is overflowing the receive descriptor qu=
eue,
"holes" in the ring buffer may occur which lead to a hangup until the buffer
is filled again. The packets are than completely processed, but the ring
remains porous and no packets are processed until the next overflow. Setting
the interface down and up can fix the problem temporary from userspace.

For some reason we don't know, this behaviour is not occuring if the RxVlan
bit for hardware VLAN untagging is set. There is another "Work around for
AMD plateform" in the current code which checks the VLAN status
word in receive descriptors, but does never come to effect when hardware
VLAN support is enabled. We assume that this is a bug in the chip.

The following patch fixes the problem. Without the patch we could reproduce
the hang within minutes (given other devices also generating lots of
interrupts), without we couldn't reproduce within a few days of long term
testing.

This version contains minor style adjustments and is sent with mutt which
will hopefully not destroy the formatting again.

Signed-off-by: Bernhard Schmidt <bernhard.schmidt@saxnet.de>
Signed-off-by: Simon Wunderlich <simon.wunderlich@saxnet.de>
Acked-by: Francois Romieu <romieu@zoreil.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 83c47d9..f98ef52 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1029,7 +1029,10 @@ static void rtl8169_vlan_rx_register(struct net_devi=
ce *dev,
=20
 	spin_lock_irqsave(&tp->lock, flags);
 	tp->vlgrp =3D grp;
-	if (tp->vlgrp)
+	/*
+	 * Do not disable RxVlan on 8110SCd.
+	 */
+	if (tp->vlgrp || (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05))
 		tp->cp_cmd |=3D RxVlan;
 	else
 		tp->cp_cmd &=3D ~RxVlan;
@@ -3197,6 +3200,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
 	}
=20
 	rtl8169_init_phy(dev, tp);
+
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
+	if (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)
+		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
+
 	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);
=20
 out:

--2oS5YaxWCcQjTEyO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkrhU80ACgkQrzg/fFk7axblGQCeOgOXC1KRLZKOzObDZpLGC47h
YMIAoLPPKbv72uMiNbO6dJSFjZAe2QlZ
=zn5l
-----END PGP SIGNATURE-----

--2oS5YaxWCcQjTEyO--
