From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] net: build_ehash_secret() and
 rt_bind_peer() cleanups
Date: Thu, 19 Aug 2010 18:10:45 +0200
Message-ID: <1282234245.25476.3.camel@edumazet-laptop>
References: <1282232815.2549.61.camel@edumazet-laptop>
	 <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34423 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab0HSQKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 12:10:49 -0400
Received: by wwi17 with SMTP id 17so2642386wwi.1
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 09:10:48 -0700 (PDT)
In-Reply-To: <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 ao=C3=BBt 2010 =C3=A0 23:58 +0800, Changli Gao a =C3=A9crit=
 :

> > -       if (peer)
> > +       peer =3D cmpxchg(&rt->peer, NULL, peer);
> > +
> > +       if (unlikely(peer))
>=20
> It isn't correct, and should be
>      if (unlikely(cmpxchg(&rt->peer, NULL, peer) !=3D NULL))
>=20
> >                inet_putpeer(peer);
> >  }
>=20
>=20

Good catch, thanks !

I was trying to take into account peer being NULL...

[PATCH net-next-2.6] net: build_ehash_secret() and rt_bind_peer() clean=
ups

Now cmpxchg() is available on all arches, we can use it in
build_ehash_secret() and rt_bind_peer() instead of using spinlocks.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
---
 net/ipv4/af_inet.c |    8 +++-----
 net/ipv4/route.c   |    9 +--------
 2 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6a1100c..f581f77 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -227,18 +227,16 @@ EXPORT_SYMBOL(inet_ehash_secret);
=20
 /*
  * inet_ehash_secret must be set exactly once
- * Instead of using a dedicated spinlock, we (ab)use inetsw_lock
  */
 void build_ehash_secret(void)
 {
 	u32 rnd;
+
 	do {
 		get_random_bytes(&rnd, sizeof(rnd));
 	} while (rnd =3D=3D 0);
-	spin_lock_bh(&inetsw_lock);
-	if (!inet_ehash_secret)
-		inet_ehash_secret =3D rnd;
-	spin_unlock_bh(&inetsw_lock);
+
+	cmpxchg(&inet_ehash_secret, 0, rnd);
 }
 EXPORT_SYMBOL(build_ehash_secret);
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f56b6e..85a67c9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1268,18 +1268,11 @@ skip_hashing:
=20
 void rt_bind_peer(struct rtable *rt, int create)
 {
-	static DEFINE_SPINLOCK(rt_peer_lock);
 	struct inet_peer *peer;
=20
 	peer =3D inet_getpeer(rt->rt_dst, create);
=20
-	spin_lock_bh(&rt_peer_lock);
-	if (rt->peer =3D=3D NULL) {
-		rt->peer =3D peer;
-		peer =3D NULL;
-	}
-	spin_unlock_bh(&rt_peer_lock);
-	if (peer)
+	if (peer && cmpxchg(&rt->peer, NULL, peer) !=3D NULL)
 		inet_putpeer(peer);
 }
=20


