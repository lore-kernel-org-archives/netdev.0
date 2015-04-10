From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH 1/2] bridge: multicast: call skb_checksum_{simple_,}validate
Date: Fri, 10 Apr 2015 19:46:38 +0200
Message-ID: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:60778 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933113AbbDJRqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 13:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's use these new, neat helpers.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
 net/bridge/br_multicast.c |   28 ++++------------------------
 1 file changed, 4 insertions(+), 24 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 4b6722f..b52f4cb 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1610,16 +1610,8 @@ static int br_multicast_ipv4_rcv(struct net_brid=
ge *br,
 	if (!pskb_may_pull(skb2, sizeof(*ih)))
 		goto out;
=20
-	switch (skb2->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!csum_fold(skb2->csum))
-			break;
-		/* fall through */
-	case CHECKSUM_NONE:
-		skb2->csum =3D 0;
-		if (skb_checksum_complete(skb2))
-			goto out;
-	}
+	if (skb_checksum_simple_validate(skb2))
+		goto out;
=20
 	err =3D 0;
=20
@@ -1737,20 +1729,8 @@ static int br_multicast_ipv6_rcv(struct net_brid=
ge *br,
=20
 	ip6h =3D ipv6_hdr(skb2);
=20
-	switch (skb2->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->len,
-					IPPROTO_ICMPV6, skb2->csum))
-			break;
-		/*FALLTHROUGH*/
-	case CHECKSUM_NONE:
-		skb2->csum =3D ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
-							&ip6h->daddr,
-							skb2->len,
-							IPPROTO_ICMPV6, 0));
-		if (__skb_checksum_complete(skb2))
-			goto out;
-	}
+	if (skb_checksum_validate(skb2, IPPROTO_ICMPV6, ip6_compute_pseudo))
+		goto out;
=20
 	err =3D 0;
=20
--=20
1.7.10.4
