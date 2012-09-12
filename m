From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] ipv6: dont cache cloned routes
Date: Wed, 12 Sep 2012 14:01:47 +0200
Message-ID: <1347451307.13103.885.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40794 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab2ILMBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 08:01:52 -0400
Received: by eekc1 with SMTP id c1so1209846eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 05:01:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

We can now destroy cloned routes immediately from dst_release() instead
of depending on garbage collection.

Set DST_NOCACHE in rt6_alloc_clone() so that :

1) we avoid calling ip6_ins_rt() on such routes

2) dst_release() can call destroy when refcount becomes 0

This allows machines to resist to DDOS.

Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv6/route.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d4ba3fc..fedbb41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -840,6 +840,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt6_=
info *ort,
 	struct rt6_info *rt =3D ip6_rt_copy(ort, daddr);
=20
 	if (rt) {
+		rt->dst.flags |=3D DST_NOCACHE;
 		rt->rt6i_flags |=3D RTF_CACHE;
 		rt->n =3D neigh_clone(ort->n);
 	}
@@ -887,7 +888,7 @@ restart:
=20
 	dst_hold(&rt->dst);
 	if (nrt) {
-		err =3D ip6_ins_rt(nrt);
+		err =3D (nrt->dst.flags & DST_NOCACHE) ? 0 : ip6_ins_rt(nrt);
 		if (!err)
 			goto out2;
 	}
