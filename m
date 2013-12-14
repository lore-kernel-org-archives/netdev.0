From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: fix compiler warning in ipv6_exthdrs_len
Date: Sat, 14 Dec 2013 07:29:29 +0100
Message-ID: <20131214062929.GA23563@order.stressinduktion.org>
References: <1386824025-27413-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54846 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682Ab3LNG3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:29:31 -0500
Content-Disposition: inline
In-Reply-To: <1386824025-27413-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36 ("net-gro: Prepare GRO
stack for the upcoming tunneling support") used an uninitialized variab=
le
which leads to the following compiler warning:

net/ipv6/ip6_offload.c: In function =E2=80=98ipv6_gro_complete=E2=80=99=
:
net/ipv6/ip6_offload.c:178:24: warning: =E2=80=98optlen=E2=80=99 may be=
 used uninitialized in this function [-Wmaybe-uninitialized]
    opth =3D (void *)opth + optlen;
                        ^
net/ipv6/ip6_offload.c:164:22: note: =E2=80=98optlen=E2=80=99 was decla=
red here
  int len =3D 0, proto, optlen;
                      ^
=46ix it up.

Cc: Jerry Chu <hkchu@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

I just noticed this and tried to fix it. Jerry, could you please review=
?
I hope I got it right. ;)

 net/ipv6/ip6_offload.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 7540a0e..08861f1 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -161,7 +161,7 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			    const struct net_offload **opps)
 {
 	struct ipv6_opt_hdr *opth =3D NULL;
-	int len =3D 0, proto, optlen;
+	int len =3D 0, optlen =3D 0, proto;
=20
 	proto =3D iph->nexthdr;
 	for (;;) {
@@ -172,11 +172,12 @@ static int ipv6_exthdrs_len(struct ipv6hdr *iph,
 			if (!((*opps)->flags & INET6_PROTO_GSO_EXTHDR))
 				break;
 		}
-		if (opth =3D=3D NULL)
+		if (opth =3D=3D NULL) {
 			opth =3D (void *)(iph+1);
-		else
+		} else {
+			optlen =3D ipv6_optlen(opth);
 			opth =3D (void *)opth + optlen;
-		optlen =3D ipv6_optlen(opth);
+		}
 		len +=3D optlen;
 		proto =3D opth->nexthdr;
 	}
--=20
1.8.3.1
