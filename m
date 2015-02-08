From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: [PATCH] rt6_probe_deferred: Do not depend on struct ordering
Date: Sun, 8 Feb 2015 10:14:07 +0100
Message-ID: <20150208101407.517bcfa7@wiggum>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/60e+hgm9NbzPZEoKzdtz.GT"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:57156 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755732AbbBHJxo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2015 04:53:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/60e+hgm9NbzPZEoKzdtz.GT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

rt6_probe allocates a struct __rt6_probe_work and schedules a work handler =
rt6_probe_deferred.
But rt6_probe_deferred kfree's the struct work_struct instead of struct __r=
t6_probe_work.
This works, because struct work_struct is the first element of struct __rt6=
_probe_work.

Change it to kfree struct __rt6_probe_work to not implicitly depend on
struct work_struct being the first element.

This does not affect the generated code.

Signed-off-by: Michael Buesch <m@bues.ch>

---

The affected code was introduced in c2f17e827b419918c856131f592df9521e1a38e3


Index: linux/net/ipv6/route.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/net/ipv6/route.c
+++ linux/net/ipv6/route.c
@@ -499,7 +499,7 @@ static void rt6_probe_deferred(struct wo
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
 	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL);
 	dev_put(work->dev);
-	kfree(w);
+	kfree(work);
 }
=20
 static void rt6_probe(struct rt6_info *rt)

--Sig_/60e+hgm9NbzPZEoKzdtz.GT
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU1yjiAAoJEPUyvh2QjYsO27IQAL5xZKHxtGloEiHL8n2jeA+L
T89RH65czgnal0nbyG6zzNyNFLJztPER7M3hK5kDxN5gH/aV+tj/HalGlNPp8cZM
hYkJ7NLIc2NAHGII0DK1QHxV2VZr0XAIhLCKOQiVl+xUIByHt15oIEBGINZJ/qsG
5RSe2TV7bINOGCJSPcu1Ckcep8JT3HWHNZ27y6i0WfSdIWiQyZcJZUVXAGSrekmR
mrDwDRwOzKNmdXUx0J5SN3m8vc3QExXjrH+7ESDGBaobIJTcOn7jebNUNYE5YuQB
hx5ezhP81RIhTylTMvxCmtaA0kfU8Fd/KFf10s96n73ZEPiHGeLVrnkplviDc3Ip
uqRzTIg0Q2D6VXH8NDz8n+a2s3fR+lFmATL4MomUCliGQOGNP5sGmqG2C5Ij6L5k
Fg6Qc7hcjvjRRMxxcBLrzgS7ETPCjg1iniW5m9b1QvtVVjhEnMyTS4JVVGDxX/oQ
5ZmwjlsLC/EQAwxyuxSUuxFlkJH19+oBpuUWJVdc9qkENmCckV2IRjPvgIb6doK+
oKWAcpfwu1Q2YQG8bCbyGleHLe20Aw5cr+08jAhxBbDwm1yRP/vTEPoRCkY7M6zP
EYgXr+O9vcBpzuPl9zNnY8svGwRPuoX69Qk8swl//twEWZB1pgw1SW14SmkWlf7n
SEJKP+fOXRgYavqZVc4R
=wwT4
-----END PGP SIGNATURE-----

--Sig_/60e+hgm9NbzPZEoKzdtz.GT--
