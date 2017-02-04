From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 4/4] catc: Use heap buffer for memory size test
Date: Sat, 4 Feb 2017 16:57:04 +0000
Message-ID: <20170204165704.GY3442@decadent.org.uk>
References: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="DejVYFcqCV4p9T4J"
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53603 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751273AbdBDQ5G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:57:06 -0500
Content-Disposition: inline
In-Reply-To: <20170204165451.GU3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DejVYFcqCV4p9T4J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Allocating USB buffers on the stack is not portable, and no longer
works on x86_64 (with VMAP_STACK enabled as per default).

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/catc.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 985909eab72c..0acc9b640419 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -776,7 +776,7 @@ static int catc_probe(struct usb_interface *intf, const=
 struct usb_device_id *id
 	struct net_device *netdev;
 	struct catc *catc;
 	u8 broadcast[ETH_ALEN];
-	int i, pktsz, ret;
+	int pktsz, ret;
=20
 	if (usb_set_interface(usbdev,
 			intf->altsetting->desc.bInterfaceNumber, 1)) {
@@ -840,15 +840,24 @@ static int catc_probe(struct usb_interface *intf, con=
st struct usb_device_id *id
                 catc->irq_buf, 2, catc_irq_done, catc, 1);
=20
 	if (!catc->is_f5u011) {
+		u32 *buf;
+		int i;
+
 		dev_dbg(dev, "Checking memory size\n");
=20
-		i =3D 0x12345678;
-		catc_write_mem(catc, 0x7a80, &i, 4);
-		i =3D 0x87654321;=09
-		catc_write_mem(catc, 0xfa80, &i, 4);
-		catc_read_mem(catc, 0x7a80, &i, 4);
+		buf =3D kmalloc(4, GFP_KERNEL);
+		if (!buf) {
+			ret =3D -ENOMEM;
+			goto fail_free;
+		}
+
+		*buf =3D 0x12345678;
+		catc_write_mem(catc, 0x7a80, buf, 4);
+		*buf =3D 0x87654321;
+		catc_write_mem(catc, 0xfa80, buf, 4);
+		catc_read_mem(catc, 0x7a80, buf, 4);
 	 =20
-		switch (i) {
+		switch (*buf) {
 		case 0x12345678:
 			catc_set_reg(catc, TxBufCount, 8);
 			catc_set_reg(catc, RxBufCount, 32);
@@ -863,6 +872,8 @@ static int catc_probe(struct usb_interface *intf, const=
 struct usb_device_id *id
 			dev_dbg(dev, "32k Memory\n");
 			break;
 		}
+
+		kfree(buf);
 	 =20
 		dev_dbg(dev, "Getting MAC from SEEROM.\n");
 	 =20

--DejVYFcqCV4p9T4J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJYH4Oe/yOyVhhEJAQorfA/+NueKtPeebaxXXBFsjIN52RoUKthUap2s
xRE+GoLcPDs+BKNEGmzSl6vzqJlUqbdQ3S4QYsZcqfAmHqcATLeYsAxEMKTL5hXn
Jvjy1Uxfy9sE9QvsFBhZ5N98QTe1Y1mTP1IWa9DDsqDIikOiqSm7excliSxcKyvM
fi2O7GrI2V6u0E263rmjN4EeJRCR4trLFna1fJNGyqEuBDKrK0Bk3rpkq1R2nK+g
3iUrzeJm2K44upAKBwuLp4vbTrqMwJV9Le9E1RuvAcM8O6cXehu8u0xKAnJkUlHt
+f6kJBLB3As+hyJX4hbGNXBcT+6v/+RM81A76nUCfR8xLB1OB23wiFh9gabtd8fa
I7XUNQnQNzKKBvyUn5xTqptXbFpEa2XOzxtrRj22BgkrKjkyJ95gb02P0aJ/sdiE
7U490YEoJ9qppX09ELxYSPEgtG1+QQybcdb1uGIzAqshjWzVEq1C244wJqdgpZCh
4su5ttYi0osrN6ezDoZfGJd9BwnP+Stpc0dfSnUQ+6ByOAqltP8zYYdlS2Fps7hQ
7l6tOXrvG2NCeYBhh2kS4fHPGIU9PppaRso6jddIJwWgqYvZEqwOkYDFSQB+zjST
n/2/SH3lewwynmDrjQLmIGz5hNsANGpUETJy49J9DaxshcApwNWNV0lN8lsWUrBR
aZ76mekUUH4=
=Trcn
-----END PGP SIGNATURE-----

--DejVYFcqCV4p9T4J--
