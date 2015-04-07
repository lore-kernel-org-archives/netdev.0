From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH RFCv3 1/4] bridge: multicast: call skb_checksum_{simple_,
 }validate
Date: Tue,  7 Apr 2015 21:57:29 +0200
Message-ID: <1428436652-4676-2-git-send-email-linus.luessing@c0d3.blue>
References: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
To: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.passe0815.de ([188.40.49.9]:40805 "EHLO mail.passe0815.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbbDGT5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 15:57:41 -0400
Received: from mail.passe0815.de (localhost [127.0.0.1])
	by mail.passe0815.de (Postfix) with ESMTP id 2A54F5863E7
	for <netdev@vger.kernel.org>; Tue,  7 Apr 2015 21:57:38 +0200 (CEST)
In-Reply-To: <1428436652-4676-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's use these new, neat helpers.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
 net/bridge/br_multicast.c |   28 ++++------------------------
 1 file changed, 4 insertions(+), 24 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c465876..3c630c7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1609,16 +1609,8 @@ static int br_multicast_ipv4_rcv(struct net_brid=
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
@@ -1736,20 +1728,8 @@ static int br_multicast_ipv6_rcv(struct net_brid=
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
