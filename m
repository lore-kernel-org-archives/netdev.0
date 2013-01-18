From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch] isdn/gigaset: off by one check leading to oops
Date: Fri, 18 Jan 2013 13:18:00 +0100
Message-ID: <50F93D78.5010903@imap.cc>
References: <20130117074405.GA26270@elgon.mountain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDB9A78BFB621DCE29CBB6A66"
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39826 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751596Ab3ARMSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 07:18:12 -0500
In-Reply-To: <20130117074405.GA26270@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDB9A78BFB621DCE29CBB6A66
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Dan,

Am 17.01.2013 08:44, schrieb Dan Carpenter:
> If l =3D=3D 12 then later we subtract 12 leaving zero.  We do a zero si=
ze
> allocation, so "dbgline" points to the ZERO_SIZE_PTR.  It leads to an
> oops when we set the NUL terminator:
> 	dbgline[3 * l - 1] =3D '\0';

thanks for finding that bug, but NAK to your fix.

> @@ -239,7 +239,7 @@ static inline void dump_rawmsg(enum debuglevel leve=
l, const char *tag,
>  		return;
> =20
>  	l =3D CAPIMSG_LEN(data);
> -	if (l < 12) {
> +	if (l <=3D 12) {
>  		gig_dbg(level, "%s: ??? LEN=3D%04d", tag, l);
>  		return;
>  	}

CAPI messages of exactly 12 bytes are legal, and should be decoded
with the regular gig_dbg() call immediately after that hunk. It's
just the hex dump part that should be skipped in that case.
So I'd prefer to have it fixed this way instead:

@@ -248,6 +248,8 @@ static inline void dump_rawmsg(enum debuglevel
level, const char *tag,
                CAPIMSG_APPID(data), CAPIMSG_MSGID(data), l,
                CAPIMSG_CONTROL(data));
        l -=3D 12;
+       if (l <=3D 0)
+               return;
        dbgline =3D kmalloc(3 * l, GFP_ATOMIC);
        if (!dbgline)
                return;

I'll prepare a patch of my own, citing you as reporter, if that's
ok with you.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)




--------------enigDB9A78BFB621DCE29CBB6A66
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlD5PYEACgkQMdB4Whm86/kRvgCffgwtkuEePvzJvik4bxqzm5jI
83cAnibSdlasE2o/1y6AHazQDHD4+yt1
=KNVA
-----END PGP SIGNATURE-----

--------------enigDB9A78BFB621DCE29CBB6A66--
