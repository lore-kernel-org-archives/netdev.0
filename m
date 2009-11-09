From: Sven Anders <sven@anduras.de>
Subject: [PATCH] iproute2: ip route flush bugfix
Date: Mon, 09 Nov 2009 20:39:15 +0100
Message-ID: <4AF86FE3.4090005@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig800283F193E6B9F4535650E6"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:42424 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbZKIUNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 15:13:06 -0500
Received: from popper.anduras.office (p54918733.dip0.t-ipconnect.de [84.145.135.51])
	(Authenticated sender: anduras@anduras.priv)
	by metropolitan.anduras.de (Postfix) with ESMTP id EE7DA1E5553
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 20:39:27 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by popper.anduras.office (Postfix) with ESMTP id 793BD2140A5
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 20:39:27 +0100 (CET)
Received: from popper.anduras.office ([127.0.0.1])
	by localhost (popper.anduras.office [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 12342-06 for <netdev@vger.kernel.org>;
	Mon, 9 Nov 2009 20:39:27 +0100 (CET)
Received: from [192.168.10.15] (suburban.anduras.office [10.10.20.242])
	by popper.anduras.office (Postfix) with ESMTP id 4B48B214001
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 20:39:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig800283F193E6B9F4535650E6
Content-Type: multipart/mixed;
 boundary="------------030108030105050301040202"

This is a multi-part message in MIME format.
--------------030108030105050301040202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello!

I experienced an error, if I try to perform a

  ip route flush proto 4

with many routes in a complex environment, it
gave me the following error:

  Failed to send flush request: Success
  Flush terminated

I'm using version 2.6.29.
I check GIT, but there was only the "MSG_PEEK" fix.

I tracked it down to the rtnl_send_check() function
in lib/libnetlink.c.

In this function there is the following for loop:

        for (h =3D (struct nlmsghdr *)resp; NLMSG_OK(h, status);
             h =3D NLMSG_NEXT(h, status)) {
                if (h->nlmsg_type =3D=3D NLMSG_ERROR) {
                        struct nlmsgerr *err =3D (struct nlmsgerr*)NLMSG_=
DATA(h);
                        if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlm=
sgerr)))
                                fprintf(stderr, "ERROR truncated\n");
                        else
                                errno =3D -err->error;
		}
                return -1;
        }

I think the "return -1;" should be inside the if statement.

I attached a patch for this. The first part of the patch is taken from
one of the late git commits.

Please note me, if the fix is wrong...


Regards
 Sven

PS: This is a repost, because I neither received a confirmation nor a rem=
ark, that
    the fix is wrong. Moreover the fix didn't make it in the GIT reposito=
ry yet...
--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 Weidestra=DFe 19 - 30453 Hannover || H=F6llgasse 28 - 94032 Passau  @  G=
ermany
 Web: http://staff2.anduras.de/anders/kim/ - Tel: +49 (0)170 / 80 911 80

--------------030108030105050301040202
Content-Type: text/x-patch;
 name="iproute-2.6.29-flush.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="iproute-2.6.29-flush.patch"

--- iproute2-2.6.29/lib/libnetlink.c.orig	2009-09-23 14:47:03.000000000 +=
0200
+++ iproute2-2.6.29/lib/libnetlink.c	2009-09-23 14:48:09.000000000 +0200
@@ -122,7 +122,7 @@ int rtnl_send_check(struct rtnl_handle *
 		return status;
=20
 	/* Check for errors */
-	status =3D recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT);
+	status =3D recv(rth->fd, resp, sizeof(resp), MSG_DONTWAIT|MSG_PEEK);
 	if (status < 0) {
 		if (errno =3D=3D EAGAIN)
 			return 0;
@@ -137,8 +137,8 @@ int rtnl_send_check(struct rtnl_handle *
 				fprintf(stderr, "ERROR truncated\n");
 			else=20
 				errno =3D -err->error;
-		}
 		return -1;
+		}
 	}
=20
 	return 0;


--------------030108030105050301040202
Content-Type: text/x-vcard; charset=utf-8;
 name="sven.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="sven.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
adr;quoted-printable:;;Weidestra=3DC3=3D9Fe 19;Hannover;Niedersachsen;304=
53;Deutschland
email;internet:sven@anduras.de
tel;home:+49 (0)511 / 2123090
tel;cell:+49 (0)170 / 8091180
x-mozilla-html:FALSE
url:http://staff.anduras.de/anders
version:2.1
end:vcard


--------------030108030105050301040202--

--------------enig800283F193E6B9F4535650E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkr4b+gACgkQ5lKZ7Feg4EfMdgCfa+ifqME2zHa+xJBKLyLaoey4
9/cAniyU5pKLxKitDkN11IQt57yxAjNm
=YRqe
-----END PGP SIGNATURE-----

--------------enig800283F193E6B9F4535650E6--
