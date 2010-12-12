From: Pierre Ossman <pierre-list@ossman.eu>
Subject: [RFC][PATCH] Export all RA options that we don't handle to
 userspace
Date: Sun, 12 Dec 2010 14:47:06 +0100
Message-ID: <20101212144706.1d2be015@mjolnir.ossman.eu>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-23783-1292161628-0001-2"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:36305 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736Ab0LLNwc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 08:52:32 -0500
In-Reply-To: <20101212144300.68e0fb16@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-23783-1292161628-0001-2
Content-Type: multipart/mixed; boundary="MP_/8ZunQNfEzZk3HrkHEVeb1ac"

--MP_/8ZunQNfEzZk3HrkHEVeb1ac
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Second patch that exports everything. If noone objects to this model,
then merge the two patches and just use the commit message from the
second one.

Pros:
- Kernel doesn't need to be updated for every new RA option that might
  show up.

Cons:
- Possible security issue if it requires less privilege to read these
  netlink messages than to open a raw ICMPv6 socket.
- List of types the kernel is interested in is now in two places in the
  code, creating a risk for getting out of sync. I tried to come up
  with a structure that would prevent this, but couldn't think of
  anything that wouldn't require large changes. Ideas welcome...

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--MP_/8ZunQNfEzZk3HrkHEVeb1ac
Content-Type: text/x-patch
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename=0002-ipv6-give-userspace-all-RA-options-that-we-do-not-ca.patch

=46rom 00cdbb6f65ad4c8d71aec12a615a83aeedcf541c Mon Sep 17 00:00:00 2001
From: Pierre Ossman <pierre@ossman.eu>
Date: Sun, 12 Dec 2010 12:49:29 +0100
Subject: [PATCH 2/2] ipv6: give userspace all RA options that we do not car=
e about

Instead of having to update the kernel for every new RA option that needs
to be dealt with in userspace, just send over everything that we don't
handle ourselves in the kernel.

Signed-off-by: Pierre Ossman <pierre@ossman.eu>
---
 net/ipv6/ndisc.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c5b01e3..192e90b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -233,12 +233,17 @@ static struct nd_opt_hdr *ndisc_next_option(struct nd=
_opt_hdr *cur,
=20
 static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
 {
+	/* Keep in sync with ndisc_parse_options() ! */
 	switch (opt->nd_opt_type) {
-	case ND_OPT_RDNSS:
-	case ND_OPT_DNSSL:
-		return 1;
-	default:
+	case ND_OPT_SOURCE_LL_ADDR:
+	case ND_OPT_TARGET_LL_ADDR:
+	case ND_OPT_MTU:
+	case ND_OPT_REDIRECT_HDR:
+	case ND_OPT_PREFIX_INFO:
+	case ND_OPT_ROUTE_INFO:
 		return 0;
+	default:
+		return 1;
 	}
 }
=20
@@ -268,6 +273,7 @@ static struct ndisc_options *ndisc_parse_options(u8 *op=
t, int opt_len,
 		l =3D nd_opt->nd_opt_len << 3;
 		if (opt_len < l || l =3D=3D 0)
 			return NULL;
+		/* Keep in sync with ndisc_is_useropt() ! */
 		switch (nd_opt->nd_opt_type) {
 		case ND_OPT_SOURCE_LL_ADDR:
 		case ND_OPT_TARGET_LL_ADDR:
@@ -295,21 +301,15 @@ static struct ndisc_options *ndisc_parse_options(u8 *=
opt, int opt_len,
 			break;
 #endif
 		default:
-			if (ndisc_is_useropt(nd_opt)) {
-				ndopts->nd_useropts_end =3D nd_opt;
-				if (!ndopts->nd_useropts)
-					ndopts->nd_useropts =3D nd_opt;
-			} else {
-				/*
-				 * Unknown options must be silently ignored,
-				 * to accommodate future extension to the
-				 * protocol.
-				 */
-				ND_PRINTK2(KERN_NOTICE
-					   "%s(): ignored unsupported option; type=3D%d, len=3D%d\n",
-					   __func__,
-					   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
-			}
+			/*
+			 * Unknown options must be silently ignored,
+			 * to accommodate future extension to the
+			 * protocol. We also provide them to userspace
+			 * for things like DNS configuration.
+			 */
+			ndopts->nd_useropts_end =3D nd_opt;
+			if (!ndopts->nd_useropts)
+				ndopts->nd_useropts =3D nd_opt;
 		}
 		opt_len -=3D l;
 		nd_opt =3D ((void *)nd_opt) + l;
--=20
1.7.2.3


--MP_/8ZunQNfEzZk3HrkHEVeb1ac--

--=_freyr.ossman.eu-23783-1292161628-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iF4EAREIAAYFAk0E0lwACgkQopDLsoqlmEKNzQD/aShY5Zfro9IKrlUvmxL2VE/q
JKP/FOWkfvroPM9rjZEA/ipEKjMkS9qpKFg6jlpHvH88uMoimsSouAd7jCnmM8JG
=Mfwx
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-23783-1292161628-0001-2--
