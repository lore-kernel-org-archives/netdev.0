From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip/link_vti6.c: Fix local/remote any handling
Date: Mon, 7 Aug 2017 08:12:25 -0700
Message-ID: <20170807081225.7cd10477@xeon-e3>
References: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/LBcc6S+EnhHdZqy5bFClnpy"; protocol="application/pgp-signature"
Cc: <netdev@vger.kernel.org>
To: Christian Langrock <christian.langrock@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34066 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGPM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 11:12:29 -0400
Received: by mail-pg0-f42.google.com with SMTP id u185so2842716pgb.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 08:12:29 -0700 (PDT)
In-Reply-To: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/LBcc6S+EnhHdZqy5bFClnpy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 7 Aug 2017 08:41:23 +0200
Christian Langrock <christian.langrock@secunet.com> wrote:

> According to the IPv4 behavior of 'ip' it should be possible to omit the
> arguments for local and remote address.
> Without this patch omitting these parameters would lead to
> uninitialized memory being interpreted as IPv6 addresses.
>=20
> Signed-off-by: Christian Langrock <christian.langrock@secunet.com>

I don't like extra flag values.  Why not just:

diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index be4e33cee606..6ea1fc2306ce 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -59,8 +59,8 @@ static int vti6_parse_opt(struct link_util *lu, int argc,=
 char **argv,
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
-	struct in6_addr saddr;
-	struct in6_addr daddr;
+	struct in6_addr saddr =3D IN6ADDR_ANY_INIT;
+	struct in6_addr daddr =3D IN6ADDR_ANY_INIT;
 	unsigned int ikey =3D 0;
 	unsigned int okey =3D 0;
 	unsigned int link =3D 0;
@@ -195,8 +195,11 @@ get_failed:
=20
 	addattr32(n, 1024, IFLA_VTI_IKEY, ikey);
 	addattr32(n, 1024, IFLA_VTI_OKEY, okey);
-	addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
-	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
+
+	if (memcmp(&saddr, &in6addr_any, sizeof(in6addr_any)))
+	    addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
+	if (memcmp(&daddr, &in6addr_any, sizeof(in6addr_any)))
+	    addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
 	addattr32(n, 1024, IFLA_VTI_FWMARK, fwmark);
 	if (link)
 		addattr32(n, 1024, IFLA_VTI_LINK, link);

--Sig_/LBcc6S+EnhHdZqy5bFClnpy
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlmIg1oACgkQgKd/YJXN
5H4SmBAAlFqJfDLVQbwznDCrBRXg2hgGLMzFL3qDn55E5chVpGbXDUYgCK5H8lQ6
8Z5xS54MPstqI5GmY+akZVa01jj+U0Aqq01arizStcwb4DBziDTJuOK1p24i+tDd
K33SQnF83NRtQo2vG3HOz63vLldfKlrV36Wx7E7dXU7epOG8NkrktC3Ih1va190I
vcB4QNdY0eqi0dhW5wRSTj35w0jx+L0nldgzCLq7ZBXZuRDGT5bo6jrR391dfcFG
ZNfIAJhVRdPLINJYRlg5sLh3IacvenS0nmX2+9pUKodLRAWhHdeURA4+uwM6LXQD
RcN3rfSJMw4Hn/tJ78ZFo0dWyAtozsPnwfJR13NdZzbPULYRbjaR6GmjTLHHRoFb
Se32ZBNMlSkzd9PsxiUSBgOH9EeDQLKOnwyb504HEPjh8DBzWi1IV/8Z2+GD3L6v
lNu7+iVIKG5Es0fd7HbpB9IDkEHnfhJFiOyB1AI6GeF3E9UJa3efF5b9781vUPfe
aIVNSV6W2QNDXEbbCktS3eaYv+zw8lpseCbuUOE9WbPJEUH15mekDI2n51GWmZDq
F3axbxkSyB9PeOv/VSbbli85zwC8O7SUXY0rjkcokJ3X8rWCutn/R700dRdO5k25
Hn6MH7oq3MwmI6kn1uwDsSyYUD9CwOZfM22y7FRfzohnfEuQSAc=
=Yrp+
-----END PGP SIGNATURE-----

--Sig_/LBcc6S+EnhHdZqy5bFClnpy--
