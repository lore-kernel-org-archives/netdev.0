From: Florian Lohoff <flo@rfc822.org>
Subject: dmfe claiming incompatible device
Date: Sat, 8 Dec 2007 12:17:49 +0100
Message-ID: <20071208111749.GA20529@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qDbXVdCdHGoSgWSk"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.gt.owl.de ([195.71.99.218]:59253 "EHLO hydra.gt.owl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704AbXLHLpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 06:45:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,
i was trying to use the debian etch installer on an Sun Netra X1
and discovered that the netinstall would not work. Cause of this
was the dmfe driver claiming an tulip based network and failing
to read the mac address and most likely not beeing able to drive the
card. I tried an 2.6.18 and 2.6.22 based installer.

Cause of this problem is an identical PCI ID for 2 different cards.
Whatsoever it seems the DMFE does do much to identify a potential=20
wrong card and just ignore it and leave of for the tulip driver.

A quick hack i thought of was to let the DMFE driver ignore cards=20
which read an all 0 mac address. As the DMFE fails to read the=20
SROM for the tulip based card this would be a quick hack. I guess there
are more elegant ways to differentiate the 2 cards and let the right
driver take control but this would be something somebody more intimate with=
=20
dmfe and tulip based cards needs to do ...

This was my idea although i know that sometimes producers fail to
program a correct mac address and this would prevent those cards from
beeing usable.

Other ideas ?

Flo

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index b4891ca..c023ec0 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -362,6 +362,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pde=
v,
 	struct net_device *dev;
 	u32 pci_pmr;
 	int i, err;
+	u8 macor=3D0;
 	DECLARE_MAC_BUF(mac);
=20
 	DMFE_DBUG(0, "dmfe_init_one()", 0);
@@ -464,8 +465,15 @@ static int __devinit dmfe_init_one (struct pci_dev *pd=
ev,
 			cpu_to_le16(read_srom_word(db->ioaddr, i));
=20
 	/* Set Node address */
-	for (i =3D 0; i < 6; i++)
+	for (i =3D 0; i < 6; i++) {
 		dev->dev_addr[i] =3D db->srom[20 + i];
+		macor |=3D db->srom[20 + i];
+	}
+
+	if (!macor) {
+		err =3D -ENODEV;
+		goto err_out_res;
+	}
=20
 	err =3D register_netdev (dev);
 	if (err)

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--qDbXVdCdHGoSgWSk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHWn1cUaz2rXW+gJcRAqPaAJoCsOeKN3Pz/PHXI0BqAgrpGJ9DqgCfX7cT
bqRfQSi/T6IlfTyXMfS+EIE=
=oJGS
-----END PGP SIGNATURE-----

--qDbXVdCdHGoSgWSk--
