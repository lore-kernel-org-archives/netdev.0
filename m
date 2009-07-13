From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: use after free bug in socket code
Date: Mon, 13 Jul 2009 18:00:05 +0200
Message-ID: <19035.23045.386506.297464@ipc1.ka-ro>
References: <19028.16049.907160.45293@ipc1.ka-ro>
	<20090709154533.GA27413@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:64621 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256AbZGMQAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 12:00:12 -0400
In-Reply-To: <20090709154533.GA27413@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu writes:
> Lothar Wa=DFmann <LW@karo-electronics.de> wrote:
> >
> > So, could you point me to the place where the reference count of th=
e
> > socket object is being incremented when a struct sock is associated
> > with it?
>=20
> It's implicit.  Anyway, you should remodel your release function
> on a working protocol.
>=20
OK. I checked the release functions of the can raw and bcm protocols
and found that they obviously are the culprits since they lack the
call to sock_orphan that other network protocol drivers have:

diff -ur linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
--- linux-2.6.30/net/can/bcm.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/bcm.c	2009-07-12 20:12:38.000000000 +0200
@@ -1469,6 +1469,9 @@
 		bo->ifindex =3D 0;
 	}
=20
+	sock_orphan(sk);
+	sock->sk =3D NULL;
+
 	release_sock(sk);
 	sock_put(sk);
=20
diff -ur linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
--- linux-2.6.30/net/can/raw.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/raw.c	2009-07-12 20:12:29.000000000 +0200
@@ -306,6 +306,9 @@
 	ro->bound   =3D 0;
 	ro->count   =3D 0;
=20
+	sock_orphan(sk);
+	sock->sk =3D NULL;
+
 	release_sock(sk);
 	sock_put(sk);
=20


Could someone of the CAN-Folks comment on this?


Best regards,
Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
