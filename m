From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: use after free bug in socket code
Date: Tue, 7 Jul 2009 08:59:59 +0200
Message-ID: <19026.62063.501414.659047@ipc1.ka-ro>
References: <19020.39270.408816.360526@ipc1.ka-ro>
	<20090706.190709.214907244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:55994 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbZGGG75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 02:59:57 -0400
In-Reply-To: <20090706.190709.214907244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller writes:
> From: Lothar Wa=DFmann <LW@KARO-electronics.de>
> Date: Thu, 2 Jul 2009 13:26:30 +0200
>=20
> > Hi,
> >=20
> > while developing a canbus driver (with kernel 2.6.30-rc4) I
> > encountered a use-after-free bug that led to the following crash (d=
ue
> > to CONFIG_DEBUG_SLAB being enabled):
>  ...
> > With the following patch I could alleviate the problem and did not
> > find any negative side effects, but I'm not sure, whether this is t=
he
> > Right Thing(TM), since I'm not too familiar with the networking cod=
e:
>  ...
> > Any comments on this?
>=20
> A patch like this shouldn't be needed.
>=20
Could you explain why it shouldn't be needed?
To me it seems much more logical to invalidate any references from
some object 'B' (struct sock) to some object 'A' (struct socket) when
object 'A' is being released rather than invalidating them when object
'B' is being released.

As far as I understand the code the 'struct socket' can vanish any
time after sock_release() has been called. Thus the pointers in the
'struct sock' that point to the 'struct socket' should be invalidated
at that point and not when the 'struct sock' itself is being released.

Also, the messages I had added showed that sock_release() is being
called before sk_common_release() (from standard networking code that
has nothing to do with my can driver) leaving the 'struct sock' object
with dangling 'sk_sleep' and 'sk_socket' pointers for the time between
those two function calls. And I don't see anything preventing those
pointers being dereferenced during this time.


Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
