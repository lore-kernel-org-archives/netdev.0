From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH net-next] net-ipv6: Fix alleged compiler warning in ipv6_exthdrs_len()
Date: Sun, 15 Dec 2013 09:19:07 -0800
Message-ID: <1387127947-2075-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:49416 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab3LORrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 12:47:37 -0500
Received: by mail-yh0-f74.google.com with SMTP id a41so399719yho.1
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 09:47:35 -0800 (PST)
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
 net/ipv6/ip6_offload.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 7540a0e..6fb4162 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -160,8 +160,8 @@ out:
 static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			    const struct net_offload **opps)
 {
-	struct ipv6_opt_hdr *opth =3D NULL;
-	int len =3D 0, proto, optlen;
+	struct ipv6_opt_hdr *opth =3D (void *)iph;
+	int len =3D 0, proto, optlen =3D sizeof(*iph);
=20
 	proto =3D iph->nexthdr;
 	for (;;) {
@@ -172,10 +172,7 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			if (!((*opps)->flags & INET6_PROTO_GSO_EXTHDR))
 				break;
 		}
-		if (opth =3D=3D NULL)
-			opth =3D (void *)(iph+1);
-		else
-			opth =3D (void *)opth + optlen;
+		opth =3D (void *)opth + optlen;
 		optlen =3D ipv6_optlen(opth);
 		len +=3D optlen;
 		proto =3D opth->nexthdr;
--=20
1.8.5.1
