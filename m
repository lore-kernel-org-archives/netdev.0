From: Christian Langrock <christian.langrock@secunet.com>
Subject: [PATCH] ip/link_vti6.c: Fix local/remote any handling
Date: Mon, 7 Aug 2017 08:41:23 +0200
Message-ID: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="0vQGOmGn6JVKT0Npbdv5AK5fiIl5CH0x5"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59538 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752065AbdHGGld (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 02:41:33 -0400
Received: from localhost (localhost [127.0.0.1])
        by a.mx.secunet.com (Postfix) with ESMTP id A636220068
        for <netdev@vger.kernel.org>; Mon,  7 Aug 2017 08:41:32 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
        by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id E6SSBiRLgACi for <netdev@vger.kernel.org>;
        Mon,  7 Aug 2017 08:41:32 +0200 (CEST)
Received: from mail-essen-01.secunet.de (mail-essen-01.secunet.de [10.53.40.204])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by a.mx.secunet.com (Postfix) with ESMTPS id 2F87020062
        for <netdev@vger.kernel.org>; Mon,  7 Aug 2017 08:41:32 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0vQGOmGn6JVKT0Npbdv5AK5fiIl5CH0x5
Content-Type: multipart/mixed; boundary="orjSnpAxxDtlvnteJOfvBCigoBIF0W3WB";
 protected-headers="v1"
From: Christian Langrock <christian.langrock@secunet.com>
To: netdev@vger.kernel.org
Message-ID: <4608c5ed-6b73-4bc2-f193-66e5129d855e@secunet.com>
Subject: [PATCH] ip/link_vti6.c: Fix local/remote any handling

--orjSnpAxxDtlvnteJOfvBCigoBIF0W3WB
Content-Type: multipart/mixed;
 boundary="------------56A24DA2DD07F1CF79450D27"
Content-Language: de-DE

This is a multi-part message in MIME format.
--------------56A24DA2DD07F1CF79450D27
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

According to the IPv4 behavior of 'ip' it should be possible to omit the
arguments for local and remote address.
Without this patch omitting these parameters would lead to
uninitialized memory being interpreted as IPv6 addresses.

Signed-off-by: Christian Langrock <christian.langrock@secunet.com>
---
 ip/link_vti6.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index be4e33c..220b7df 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -60,7 +60,9 @@ static int vti6_parse_opt(struct link_util *lu, int
argc, char **argv,
     struct rtattr *linkinfo[IFLA_INFO_MAX+1];
     struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
     struct in6_addr saddr;
+    bool use_saddr =3D false;
     struct in6_addr daddr;
+    bool use_daddr =3D false;
     unsigned int ikey =3D 0;
     unsigned int okey =3D 0;
     unsigned int link =3D 0;
@@ -167,6 +169,7 @@ get_failed:
=20
                 get_prefix(&addr, *argv, AF_INET6);
                 memcpy(&daddr, addr.data, addr.bytelen);
+                use_daddr =3D true;
             }
         } else if (!matches(*argv, "local")) {
             NEXT_ARG();
@@ -178,6 +181,7 @@ get_failed:
=20
                 get_prefix(&addr, *argv, AF_INET6);
                 memcpy(&saddr, addr.data, addr.bytelen);
+                use_saddr =3D true;
             }
         } else if (!matches(*argv, "dev")) {
             NEXT_ARG();
@@ -195,8 +199,10 @@ get_failed:
=20
     addattr32(n, 1024, IFLA_VTI_IKEY, ikey);
     addattr32(n, 1024, IFLA_VTI_OKEY, okey);
-    addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
-    addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
+    if (use_saddr)
+        addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
+    if (use_daddr)
+        addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
     addattr32(n, 1024, IFLA_VTI_FWMARK, fwmark);
     if (link)
         addattr32(n, 1024, IFLA_VTI_LINK, link);
--=20
2.7.4



--------------56A24DA2DD07F1CF79450D27
Content-Type: application/pgp-keys;
 name="0x82EB6B5E.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x82EB6B5E.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

mQENBFee7jkBCACkeMIuzZu/KBA1q3kKGr7d9iiZGF5IpJnIE9dMiK3uaz7uM26V
STJVp6jdGuSGGGmb81OSLEcIEIsYKXvjblAKUX1A74t3WMRcky3MwJbmN6AkN8Ql
P45mDddtPRf1ElB2S32i9OrEkvw8xcvHYPwbaHenXic4/8fHWEh+vtd/5/5TDTIU
/ag9tQfPea13ixXN0PuccMubFeUMpwFCg324+Z19iGvfDWWZmQQGlBjc3Q6z0hXO
b/deWL/+lPS4t+tTgpmmZO4XkIs+18KqxCVukCbnqV0y+04sj3G1GQ/DlGvZHxwy
wBceAL7BvmdeXQKAS0KRL5zrghIBCgnUyutDABEBAAG0M0NocmlzdGlhbiBMYW5n
cm9jayA8Y2hyaXN0aWFuLmxhbmdyb2NrQHNlY3VuZXQuY29tPokBNwQTAQgAIQUC
V57uOQIbAwULCQgHAgYVCAkKCwIEFgIDAQIeAQIXgAAKCRCjeMdfgutrXu3kCACI
Bx6UHReBtBciNUPkP3fRaGeSOADIrql72VKD9faLAHTt6w8kvyzb8Ctpa77jswJt
21c349mF3maPlpNtpswqH27bTlXYhNcXxcmHPCbNtN3yGUy0UuIJfBMZc8PLqiqY
oY5GKD3uimeVbDYjgNhebO2f1cUvwY2wTwX6b0tgKVK0xYYTDpXI1/2MVGsjXqak
7PQoqVq0sDu0gIAAi1QO0Fbb6jIaHj6CEM2hpBTBk8qbkPs/MqYGdLl4oXvkWTLd
uQjm6dMtjxvIt6WJWZQbLjTeQIfc21luNQKDmfT623pVTPPMMAciWfpdw63FblfG
cfBnAKCJ8JBj0z9T6/PmuQENBFee7jkBCADS7amJPbY2dWpeGtE+I9yLL53lSriP
4L6rI9UoEwNM1OkjnB7wFnH8dm8N68K2OJogkHwoX2OnzGhxJ28NHRuAh++3hIYY
+gU4HMLaX3onDK1oqAdYczhJ7f6UCPbYaghkzJ6Vg/FEWpA8u5vG/BX4y+F3/Y98
l6mzAX5wLmTapRwdfuRCXRA6jlIHIOwP3NPKK4Pz2E7witsimV1ucN4uXFiZ36CU
PAiXXlER9iPZnQUSyCobqJOJKm4C7wUNQ1negCXDBd3KjSyzTIafw/oYG4RrWGul
iI2ig/qTUC8cZdAJTMBjUJR6ugJazMB1Rg17p2GRD0AzUOV2qdqYFqQFABEBAAGJ
AR8EGAEIAAkFAlee7jkCGwwACgkQo3jHX4Lra17vtQgAg2g0JEXVTGT36BDJgVjI
UY1evnm1fWwTPpcokP/8/aO2ubmlxtWQ2hV5OPfL5nDday2S4Nq5j3kqQq+rvUrO
RVmvT4WxYZM1fr2nibuzaUbsJtxphNpjahrsEcLLTzBW4CbHTaL4YTT+ZD/GDeHo
xAh9JfMkdMBXHyWTuw+QSP0pp7WvNsDosukKFyQ0rve9PH2dry6A0oLP7UxtAzEE
RV2Se0BueZPQuVnU6Cvj3ZStK28JDhMjxIPkZPE5kCV8QNF8OsiwymA3aoPKe5Bw
0lOcjuuJkxRa5bazyuubX9pIIgTeGsecgpSgpfA9jsEHKFqoLuxUA+77VQ5hSydV
aQ=3D=3D
=3DO6Ea
-----END PGP PUBLIC KEY BLOCK-----

--------------56A24DA2DD07F1CF79450D27--

--orjSnpAxxDtlvnteJOfvBCigoBIF0W3WB--

--0vQGOmGn6JVKT0Npbdv5AK5fiIl5CH0x5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJZiAuTAAoJEKN4x1+C62tebKsIAIYhY2tTO2LenSfkx9M8rQ5N
g9qtalS6A3EIHalc66mA1o4AfyaSwkV6rH6xjng7usTiffZn4hFYM8MJGn4/neXd
AXmCPGWRUqZ+nPR1ctRoOEZI3t90Rom1H8HXQqv7ZZD/W35bB5WFqY8WunQbYytB
MDo588tn1Aa8uSKA4mRSNJnBygaLxxp0bLS+OoeLkzLaXJou3owO8hzLL4LnlZmd
pB243cZrV1V2dicHi8tnOKwvbmJdDFfKjp9qSNvuJYmqbfYbJlbuXVS7Bx+aemE9
wkyIN6y5l/abuLmgsilBaR7AeLPkAVHLhrRJYVutJ03ZE2yDW5NExyAEcDYrxN0=
=ByLn
-----END PGP SIGNATURE-----

--0vQGOmGn6JVKT0Npbdv5AK5fiIl5CH0x5--
