From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: net: alignment problem in icmp code
Date: Mon, 22 Oct 2007 09:23:50 +0200
Message-ID: <20071022092350.5c75b3bd@poseidon.drzeus.cx>
References: <20071021232113.52ce1be7@poseidon.drzeus.cx>
	<20071021.160215.115679567.davem@davemloft.net>
	<20071022065443.2f3c1b8a@poseidon.drzeus.cx>
	<20071021.221524.49830652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_hera.drzeus.cx-18222-1193037801-0001-2"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.drzeus.cx ([85.8.24.16]:36455 "EHLO smtp.drzeus.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312AbXJVHX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 03:23:57 -0400
In-Reply-To: <20071021.221524.49830652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hera.drzeus.cx-18222-1193037801-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2007 22:15:24 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

>=20
> Sure.  But the language defines that the types in question
> must be 64-bit aligned, so it is legal for the compiler to
> emit this code.
>=20
> It's not a GCC bug.
>=20

I've confirmed this behaviour on the AVR32 arch, and had a second look in t=
he spec. The only way GCC can get away with this is by using a very creativ=
e interpretation of the result of casting a pointer to one type to a pointe=
r to another type (which ISO C leaves undefined). Basically:

1. A cast from a pointer to one type to a pointer to a second type does not=
 change the value. (GCC behaviour which we rely on heavily, even in your su=
ggested patch).

2. A cast from a pointer to one type to a pointer to a second type changes =
the value so that it properly aligns with the second type. (As a cast to vo=
id*, which memcpy() requires, is safe according to ISO C, the pointer modif=
ication must be from char* to struct icmphdr*).

As 1 and 2 conflict, GCC's behaviour for pointer casts is still rather unde=
fined. So although within the requirements of ISO C, it's rather user hosti=
le. And it casts doubt on every pointer cast used.

> If you want to let the compiler know that a pointer to a type might
> not be aligned, you have to tell it so.

Which you can't do within the confines of ISO C. The get_unaligned() macro =
uses some GCC trickery (even outside what GCC documents as defined behaviou=
r). To stay "clean", you have to avoid casting char* to foo*.

With all that said, as GCC does what it does, we can't really rely on a mem=
cpy() anyway, so I support your patch.

As for other instances of unaligned accesses, is there any active work on g=
etting rid of those? And would you accept more patches for fixing them? (Co=
de complexity being the downside)

Rgds
Pierre

--=_hera.drzeus.cx-18222-1193037801-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHHFAH7b8eESbyJLgRAs5DAJ4hNX+PwIf0sNHOaPmDaIAfvYqS6wCg5F3v
5Y8k/wmPOFsLARs7j4lnOEw=
=78cf
-----END PGP SIGNATURE-----

--=_hera.drzeus.cx-18222-1193037801-0001-2--
