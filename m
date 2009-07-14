From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: use after free bug in socket code
Date: Tue, 14 Jul 2009 08:24:56 +0200
Message-ID: <19036.9400.263297.330963@ipc1.ka-ro>
References: <19028.16049.907160.45293@ipc1.ka-ro>
	<20090709154533.GA27413@gondor.apana.org.au>
	<19035.23045.386506.297464@ipc1.ka-ro>
	<4A5B730B.8090902@hartkopp.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:50416 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545AbZGNGZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 02:25:09 -0400
In-Reply-To: <4A5B730B.8090902@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Oliver Hartkopp writes:

> unfortunately i did not get any answer from Urs so far, who originall=
y created
> these lines of code.
>=20
> But from what i was able to get from browsing similar code in the Ker=
nel that
> at least sock_orphan() is called in the appropriate socket release fu=
nctions,
> which is indeed not done by the mentioned PF_CAN protocols right now.
>=20
> I assume you already tested this patch (at least with CAN_RAW) succes=
sfully,
> right?
>=20
Yes.

> If so, i would have no objections to add my Acked-by to these changes=
=2E
>=20
> Would you like to prepare a proper patch and post it on netdev?
>=20
I'll do.
I would also submit a second patch to add an appropriate MODULE_ALIAS
to the protocol drivers, so they can be autoloaded when compiled as
module:
diff -ur linux-2.6.30/net/can/bcm.c linux-2.6.30-karo/net/can/bcm.c
--- linux-2.6.30/net/can/bcm.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/bcm.c	2009-07-12 20:12:38.000000000 +0200
@@ -75,6 +75,7 @@
 MODULE_DESCRIPTION("PF_CAN broadcast manager protocol");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
+MODULE_ALIAS("can-proto-2");
=20
 /* easy access to can_frame payload */
 static inline u64 GET_U64(const struct can_frame *cp)
diff -ur linux-2.6.30/net/can/raw.c linux-2.6.30-karo/net/can/raw.c
--- linux-2.6.30/net/can/raw.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30-karo/net/can/raw.c	2009-07-12 20:12:29.000000000 +0200
@@ -62,6 +62,7 @@
 MODULE_DESCRIPTION("PF_CAN raw protocol");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
+MODULE_ALIAS("can-proto-1");
=20
 #define MASK_ALL 0
=20

> ps. This code section was stable for more than three years now. Can y=
ou tell
> me, how you kicked your system to run into this problem?
>=20
I was working on a chip driver for the i.MX25 flexcan controller. The
bug was visible due to CONFIG_DEBUG_SLAB=3Dy which makes sure that
memory is poisoned with a special pattern upon being freed.

The situation where this triggers a bug is when the chip driver's
hard_start_xmit function returns a NETDEV_TX_BUSY and subsequently the
can interface is deconfigured.

Maybe you could try this on different hardware?


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
