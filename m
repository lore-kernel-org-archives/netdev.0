From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH net-next] net-ipv6: Fix alleged compiler warning in ipv6_exthdrs_len()
Date: Sun, 15 Dec 2013 18:48:07 -0800
Message-ID: <1387162087-5072-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:41655 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab3LPCsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 21:48:12 -0500
Received: by mail-oa0-f74.google.com with SMTP id o6so843638oag.3
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 18:48:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jerry Chu <hkchu@google.com>

It was reported that Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
("net-gro: Prepare GRO stack for the upcoming tunneling support")
triggered a compiler warning in ipv6_exthdrs_len():

net/ipv6/ip6_offload.c: In function =E2=80=98ipv6_gro_complete=E2=80=99=
:
net/ipv6/ip6_offload.c:178:24: warning: =E2=80=98optlen=E2=80=99 may be=
 used uninitialized in this function [-Wmaybe-u
    opth =3D (void *)opth + optlen;
    			^
    net/ipv6/ip6_offload.c:164:22: note: =E2=80=98optlen=E2=80=99 was d=
eclared here
    int len =3D 0, proto, optlen;
                        ^
Note that there was no real bug here - optlen was never uninitialized
before use. (Was the version of gcc I used smarter to not complain?)

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 net/ipv6/ip6_offload.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 08861f1..6fb4162 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -160,8 +160,8 @@ out:
 static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			    const struct net_offload **opps)
 {
-	struct ipv6_opt_hdr *opth =3D NULL;
-	int len =3D 0, optlen =3D 0, proto;
+	struct ipv6_opt_hdr *opth =3D (void *)iph;
+	int len =3D 0, proto, optlen =3D sizeof(*iph);
=20
 	proto =3D iph->nexthdr;
 	for (;;) {
@@ -172,12 +172,8 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			if (!((*opps)->flags & INET6_PROTO_GSO_EXTHDR))
 				break;
 		}
-		if (opth =3D=3D NULL) {
-			opth =3D (void *)(iph+1);
-		} else {
-			optlen =3D ipv6_optlen(opth);
-			opth =3D (void *)opth + optlen;
-		}
+		opth =3D (void *)opth + optlen;
+		optlen =3D ipv6_optlen(opth);
 		len +=3D optlen;
 		proto =3D opth->nexthdr;
 	}
--=20
1.8.5.1
