From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: [PATCH 1/2] net/can bugfix: use after free bug in can protocol drivers
Date: Wed, 15 Jul 2009 11:10:21 +0200
Message-ID: <19037.40189.520170.8242@ipc1.ka-ro>
References: <19028.16049.907160.45293@ipc1.ka-ro>
	<20090709154533.GA27413@gondor.apana.org.au>
	<19035.23045.386506.297464@ipc1.ka-ro>
	<4A5B730B.8090902@hartkopp.net>
	<19036.9400.263297.330963@ipc1.ka-ro>
	<4A5C990E.3080703@hartkopp.net>
	<19036.41388.634723.358236@ipc1.ka-ro>
	<4A5CC626.8020800@grandegger.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:65103 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbZGOJKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 05:10:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix a use after free bug in can protocol drivers

The release functions of the can protocol drivers lack a call to
sock_orphan() which leads to referencing freed memory under certain
circumstances.

This patch fixes a bug reported here:
https://lists.berlios.de/pipermail/socketcan-users/2009-July/000985.htm=
l

Signed-off-by: Lothar Wassmann <LW@KARO-electronics.de>
Acked-by: Oliver Hartkopp <oliver@hartkopp.net>
---
diff -upr linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
--- linux-2.6.30/net/can/bcm.c  2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/bcm.c        2009-07-14 14:13:01.00000000=
0 +0200
@@ -1469,6 +1469,9 @@ static int bcm_release(struct socket *so
 		bo->ifindex =3D 0;
 	}
=20
+	sock_orphan(sk);
+	sock->sk =3D NULL;
+
 	release_sock(sk);
 	sock_put(sk);
=20
diff -upr linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
--- linux-2.6.30/net/can/raw.c  2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/raw.c        2009-07-14 14:13:07.00000000=
0 +0200
@@ -306,6 +306,9 @@ static int raw_release(struct socket *so
 	ro->bound   =3D 0;
 	ro->count   =3D 0;
=20
+	sock_orphan(sk);
+	sock->sk =3D NULL;
+
 	release_sock(sk);
 	sock_put(sk);
=20



Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
