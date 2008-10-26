From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 09:30:22 +0100
Message-ID: <1225009822.3478.30.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-D6bqf31vr2doYO1OVEUn"
Cc: anders@anduras.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49322 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbYJZIaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:30:30 -0400
In-Reply-To: <1225009308.3478.22.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-D6bqf31vr2doYO1OVEUn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 09:21 +0100, Johannes Berg wrote:

> Of course, actually adding, say, %p4 and %p6 would be trivial, but
> making lots of code use it so it's useful would be another mass
> conversion I'm not too keen to do again right away :)

Actually... At least for ipv6 that isn't true, just do something like
this:

@@ include/linux/kernel.h
-#define NIP6(addr) \
-...
+#define NIP6(addr) &addr

-#define NIP6_FMT "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"
-#define NIP6_SEQFMT "%04x%04x%04x%04x%04x%04x%04x%04x"
+#define NIP6_FMT "%p6"
+#define NIP6_SEQFMT "%#p6"

and then add the correct stuff to pointer() in lib/vsprintf.c, something
like

static char *ip6_string(char *buf, char *end, be16 *addr, int field_width, =
int precision, int flags)
{
	char ip6[8*5];
	char *p =3D ip6;
	int i;
	u16 tmp;

	for (i=3D0; i<7; i++) {
		tmp =3D cpu_to_le16(addr[i]);
		p =3D pack_hex_byte(p, tmp >> 8);
		p =3D pack_hex_byte(p, tmp & 0xFF);
		if (!(flags & SPECIAL))
			*p++ =3D ':';
	}
	tmp =3D cpu_to_le16(addr[7]);
	p =3D pack_hex_byte(p, tmp >> 8);
	p =3D pack_hex_byte(p, tmp & 0xFF);
	*p =3D '\0';

	return string(buf, end, ip6, field_width, precision, flags & ~SPECIAL);
}


--=-D6bqf31vr2doYO1OVEUn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBCqaAAoJEKVg1VMiehFYhlwP/1hMkY9WEnyoiEt/d++oh4CL
E4VzNvPqFISAQrlooOMDpQ6vvISjweJV8Ev5GvYo7yUFGMEoafQEkjTJECAyOx7b
2IENIEYaTMSPygSlfEERxv58cKJCdWAOuDJjusnIpBPvbW89Ti+zDyqbZHyaBK3N
LwIc4PiagOTIzGRtBxS5oZ3Djl/R3MIhbbTHqImWpcDyFMIPM3vOVSVIZyjmE2h6
LZyiuqLXcRHnoB2DjnnkKH8e4xGBg+5qG7E3ltPOxHGyWFfw4vV5tw7Q+RVaeuPB
ZpgcYjW4SABGly6x1RvPspMuFBhBNO/DoddtORDT/8wkLhpL9W7xIecWA6LqWuAw
HSNWs4NaHAiecLp24Z3opI0wKs8MIoUZB4EM0bPiw+gNfY7/BbCWaKE6TuHDbQiF
B3eI7WAaPeF66Acmn25ezWSetO3KtLVf/+sfbPcbZK/u/PIXsjkoPd86tqHoMvbN
jovSJIf1br/j1iS9q9/x7jJ0wkW2OlzEkqmVim/VHWYLk30XS0yVz5Q95BvAaMV5
K1hXG44010p1CDY96kIbgaLIK7vK+AF6zOhLuXRtHrcQe/y/fXz/LgaiwwmlOGSM
5JLLKIyWSl7WEkxfbwUKIAct3e5MzLFSO0fG4xHB5/bEB6qoBcJxYvfkyoZCrlQU
e1lBOoGgMkjN1kiIzOOW
=93+S
-----END PGP SIGNATURE-----

--=-D6bqf31vr2doYO1OVEUn--

