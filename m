From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 9/32] rt2x00: Fix antenna configuration
Date: Fri, 28 Apr 2006 00:03:00 +0200
Message-ID: <200604280003.00692.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2344990.MPujecZFZf";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751783AbWD0WBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:53 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:52 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2344990.MPujecZFZf
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

The handling of the antenna configuration was not
completely correct. For all modules the double clearing
of some bits can be reduced, and for rt2500pci and rt2500usb
some registers were not corretly changed.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:41:20.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:41:52.000000000 +0200
@@ -485,6 +485,9 @@ rt2400pci_config_antenna(struct rt2x00_p
 	rt2x00_bbp_read(rt2x00pci, 4, &reg_rx);
 	rt2x00_bbp_read(rt2x00pci, 1, &reg_tx);
=20
+	/*
+	 * Clear current config antenna bits.
+	 */
 	reg_rx &=3D ~0x06;
 	reg_tx &=3D ~0x03;
=20
@@ -495,18 +498,18 @@ rt2400pci_config_antenna(struct rt2x00_p
 	 */
 	if (antenna =3D=3D 0) {
 		/* Diversity. */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x02;
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x01;
+		reg_rx |=3D 0x02;
+		reg_tx |=3D 0x01;
 	} else if (antenna =3D=3D 1) {
 		/* RX: Antenna B */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x04;
+		reg_rx |=3D 0x04;
 		/* TX: Antenna A */
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x00;
+		reg_tx |=3D 0x00;
 	} else if (antenna =3D=3D 2) {
 		/* RX: Antenna A */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x00;
+		reg_rx |=3D 0x00;
 		/* TX: Antenna B */
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x02;
+		reg_tx |=3D 0x02;
 	}
=20
 	rt2x00_bbp_write(rt2x00pci, 4, reg_rx);
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:41:20.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:41:52.000000000 +0200
@@ -506,12 +506,17 @@ rt2500pci_config_channel(struct rt2x00_p
 static void
 rt2500pci_config_antenna(struct rt2x00_pci *rt2x00pci, int antenna)
 {
+	u32			reg;
 	u8			reg_rx;
 	u8			reg_tx;
=20
+	rt2x00_register_read(rt2x00pci, BBPCSR1, &reg);
 	rt2x00_bbp_read(rt2x00pci, 14, &reg_rx);
 	rt2x00_bbp_read(rt2x00pci, 2, &reg_tx);
=20
+	/*
+	 * Clear current config antenna bits.
+	 */
 	reg_rx &=3D ~0x06;
 	reg_tx &=3D ~0x03;
=20
@@ -522,20 +527,46 @@ rt2500pci_config_antenna(struct rt2x00_p
 	 */
 	if (antenna =3D=3D 0) {
 		/* Diversity. */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x02;
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x01;
+		reg_rx |=3D 0x02;
+		reg_tx |=3D 0x01;
+		rt2x00_set_field32(&reg, BBPCSR1_CCK, 2);
+		rt2x00_set_field32(&reg, BBPCSR1_OFDM, 2);
 	} else if (antenna =3D=3D 1) {
 		/* RX: Antenna B */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x04;
+		reg_rx |=3D 0x04;
 		/* TX: Antenna A */
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x00;
+		reg_tx |=3D 0x00;
+		rt2x00_set_field32(&reg, BBPCSR1_CCK, 0);
+		rt2x00_set_field32(&reg, BBPCSR1_OFDM, 0);
 	} else if (antenna =3D=3D 2) {
 		/* RX: Antenna A */
=2D		reg_rx =3D (reg_rx & 0xf9) | 0x00;
+		reg_rx |=3D 0x00;
 		/* TX: Antenna B */
=2D		reg_tx =3D (reg_tx & 0xfc) | 0x02;
+		reg_tx |=3D 0x02;
+		rt2x00_set_field32(&reg, BBPCSR1_CCK, 2);
+		rt2x00_set_field32(&reg, BBPCSR1_OFDM, 2);
+	}
+
+	/*
+	 * RT2525E and RT5222 need to flip TX I/Q
+	 */
+	if (rt2x00_rf(&rt2x00pci->chip, RF2525E)
+	|| rt2x00_rf(&rt2x00pci->chip, RF5222)) {
+		reg_tx |=3D 0x04;
+		rt2x00_set_field32(&reg, BBPCSR1_CCK_FLIP, 1);
+		rt2x00_set_field32(&reg, BBPCSR1_OFDM_FLIP, 1);
+
+		/*
+		 * RT2525E does not need RX I/Q Flip.
+		 */
+		if (rt2x00_rf(&rt2x00pci->chip, RF2525E))
+			reg_rx &=3D ~0x04;
+	} else {
+		rt2x00_set_field32(&reg, BBPCSR1_CCK_FLIP, 0);
+		rt2x00_set_field32(&reg, BBPCSR1_OFDM_FLIP, 0);
 	}
=20
+	rt2x00_register_write(rt2x00pci, BBPCSR1, reg);
 	rt2x00_bbp_write(rt2x00pci, 14, reg_rx);
 	rt2x00_bbp_write(rt2x00pci, 2, reg_tx);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:41:20.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:41:52.000000000 +0200
@@ -372,8 +372,9 @@ rt2500usb_config_antenna(struct rt2x00_u
 	rt2x00_register_read(rt2x00usb, PHY_CSR5, &csr5_reg);
 	rt2x00_register_read(rt2x00usb, PHY_CSR6, &csr6_reg);
=20
=2D	csr5_reg &=3D ~0x0003;
=2D	csr6_reg &=3D ~0x0003;
+	/*
+	 * Clear current config antenna bits.
+	 */
 	reg_tx &=3D ~0x03;
 	reg_rx &=3D ~0x03;
=20
@@ -386,40 +387,41 @@ rt2500usb_config_antenna(struct rt2x00_u
 		/* Diversity. */
 		reg_rx |=3D 0x01;
 		reg_tx |=3D 0x01;
=2D		csr5_reg |=3D 0x0001;
=2D		csr6_reg |=3D 0x0001;
+		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK, 1);
+		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM, 1);
 	} else if (antenna =3D=3D 1) {
 		/* RX: Antenna B */
 		reg_rx |=3D 0x02;
 		/* TX: Antenna A */
 		reg_tx |=3D 0x00;
=2D		csr5_reg |=3D 0x0000;
=2D		csr6_reg |=3D 0x0000;
+		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK, 0);
+		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM, 0);
 	} else if (antenna =3D=3D 2) {
 		/* RX: Antenna A */
 		reg_tx |=3D 0x02;
=2D		csr5_reg |=3D 0x0002;
=2D		csr6_reg |=3D 0x0002;
 		/* TX: Antenna B */
 		reg_rx |=3D 0x00;
+		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK, 2);
+		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM, 2);
 	}
=20
 	/*
=2D	 * RT2525E needs to flip TX I/Q but not RX I/Q.
+	 * RT2525E and RT5222 need to flip TX I/Q
 	 */
=2D	if (rt2x00_rf(&rt2x00usb->chip, RF2525E)) {
+	if (rt2x00_rf(&rt2x00usb->chip, RF2525E)
+	|| rt2x00_rf(&rt2x00usb->chip, RF5222)) {
 		reg_tx |=3D 0x04;
=2D		reg_rx &=3D ~0x04;
=2D		csr5_reg |=3D 0x0004;
=2D		csr6_reg |=3D 0x0004;
=2D	}
=2D	/*
=2D	 * RT5222 needs to flip TX I/Q.
=2D	 */
=2D	if (rt2x00_rf(&rt2x00usb->chip, RF5222)) {
=2D		reg_tx |=3D 0x04;
=2D		csr5_reg |=3D 0x0004;
=2D		csr6_reg |=3D 0x0004;
+		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK_FLIP, 1);
+		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM_FLIP, 1);
+
+		/*
+		 * RT2525E does not need RX I/Q Flip.
+		 */
+		if (rt2x00_rf(&rt2x00usb->chip, RF2525E))
+			reg_rx &=3D ~0x04;
+	} else {
+		rt2x00_set_field16_nb(&csr5_reg, PHY_CSR5_CCK_FLIP, 0);
+		rt2x00_set_field16_nb(&csr6_reg, PHY_CSR6_OFDM_FLIP, 0);
 	}
=20
 	rt2x00_bbp_write(rt2x00usb, 2, reg_tx);

--nextPart2344990.MPujecZFZf
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+UaqndE37Em0gRAmnRAJ4xdEnxhpy+noZPttghMANM3AaCnwCg0Cnb
uVHECCQFBFhH7hdaxNOl9kI=
=u+bR
-----END PGP SIGNATURE-----

--nextPart2344990.MPujecZFZf--
