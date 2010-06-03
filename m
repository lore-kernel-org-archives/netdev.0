From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 03 Jun 2010 23:37:16 +0200
Message-ID: <1275601036.2533.63.camel@edumazet-laptop>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	 <20100603130235.c372b38f.akpm@linux-foundation.org>
	 <1275599603.2533.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63835 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab0FCVvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 17:51:39 -0400
Received: by wyi11 with SMTP id 11so425131wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 14:51:38 -0700 (PDT)
In-Reply-To: <1275599603.2533.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 23:13 +0200, Eric Dumazet a =C3=A9crit :

> MTU=3D9000 on a system with 4K pages... Oh well...
>=20
> maybe net/ipv6/mcast.c should cap dev->mtu to PAGE_SIZE-128 or
> something, so that order-0 allocations are done.
>=20
>=20

Something like this patch (completely untested) :

[PATCH] ipv6: avoid high order allocations

With mtu=3D9000, mld_newpack() use order-2 GFP_ATOMIC allocations, that
are very unreliable, on machines where PAGE_SIZE=3D4K

Limit allocated skbs to be at most one page. (order-0 allocations)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/mcast.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 59f1881..3484794 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1356,7 +1356,10 @@ static struct sk_buff *mld_newpack(struct net_de=
vice *dev, int size)
 		     IPV6_TLV_PADN, 0 };
=20
 	/* we assume size > sizeof(ra) here */
-	skb =3D sock_alloc_send_skb(sk, size + LL_ALLOCATED_SPACE(dev), 1, &e=
rr);
+	size +=3D LL_ALLOCATED_SPACE(dev);
+	/* limit our allocations to order-0 page */
+	size =3D min(size, SKB_MAX_ORDER(0, 0));
+	skb =3D sock_alloc_send_skb(sk, size, 1, &err);
=20
 	if (!skb)
 		return NULL;


