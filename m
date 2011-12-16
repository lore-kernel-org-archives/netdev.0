From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Fri, 16 Dec 2011 13:21:47 +0100
Message-ID: <20111216122147.GJ6348@secunet.com>
References: <4EE8C6A8.3060308@iki.fi>
 <20111214.125010.82857701285437834.davem@davemloft.net>
 <20111215134957.GI6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41278 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989Ab1LPMVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 07:21:51 -0500
Content-Disposition: inline
In-Reply-To: <20111215134957.GI6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 02:49:57PM +0100, Steffen Klassert wrote:
> On Wed, Dec 14, 2011 at 12:50:10PM -0500, David Miller wrote:
> > From: Timo Ter=E4s <timo.teras@iki.fi>
> > Date: Wed, 14 Dec 2011 17:54:16 +0200
> >=20
> > > So something is does not get updated here. This used to work thou=
gh.
> > > The current production boxes where I know this work is 2.6.38.8.
> >=20
> > We store the PMTU externally in inetpeer entries, Eric Dumazet
> > fixed recently but that fix hasn't been submitted to -stable
> > yet.
> >=20
>=20
> I think we still have at least two problems with pmtu handling.
> One is that "ip route flush cache" flushes the routing cache
> but not the cached metrics on the inetpeer.

"ip route flush cache" does not even flush the routing cache,
it just markes the routing cache as invalid by changing the
rt_genid which make the old routes invisible. And since we don't
have rt_check_expire() anymore, we have to wait until we have
collected gc_thresh (1024) useless routes before rt_garbage_collect()
starts to remove some of them (btw. is this intentional).

I think we need a trigger in rt_cache_invalidate() that expires
all cached pmtu values similar to the routing cache entries.
=46or a moment I thought we could just reset the __rt_peer_genid
value back to zero to mark all cached pmtu values as expired,
but that's apparently not save to do. So I came to no conclusion
how to fix this today. Any ideas?

>=20
> Another problem might be that we ignore the user configured
> fib_metrics in rt_init_metrics() if we have a cached metric
> on the inetpeer.
>=20

I think this could be fixed with something like the patch
below. With this it should be possible to overwrite cached
values from userspace. It has not much testing, so it's
just for review at the monent.

---------
Subject: [PATCH] route: Initialize with the fib_metrics in the non defa=
ult case

We initialize the routing metrics with the cached values in
rt_init_metrics(). So if we have the metrics cached on the
inetpeer, we ignore the user configured fib_metrics. So
initialize the routing metrics with the fib_metrics if they
are different from dst_default_metrics.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f30112f..26a6249 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1841,6 +1841,22 @@ static unsigned int ipv4_mtu(const struct dst_en=
try *dst)
 	return mtu;
 }
=20
+static void __rt_init_metrics(struct rtable *rt, struct fib_info *fi,
+			      struct inet_peer *peer)
+{
+	if (peer && fi->fib_metrics =3D=3D (u32 *) dst_default_metrics) {
+		dst_init_metrics(&rt->dst, peer->metrics, false);
+		return;
+	}
+
+	if (fi->fib_metrics !=3D (u32 *) dst_default_metrics) {
+		rt->fi =3D fi;
+		atomic_inc(&fi->fib_clntref);
+	}
+
+	dst_init_metrics(&rt->dst, fi->fib_metrics, true);
+}
+
 static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl=
4,
 			    struct fib_info *fi)
 {
@@ -1859,7 +1875,8 @@ static void rt_init_metrics(struct rtable *rt, co=
nst struct flowi4 *fl4,
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
-		dst_init_metrics(&rt->dst, peer->metrics, false);
+
+		__rt_init_metrics(rt, fi, peer);
=20
 		check_peer_pmtu(&rt->dst, peer);
 		if (peer->redirect_genid !=3D redirect_genid)
@@ -1869,13 +1886,8 @@ static void rt_init_metrics(struct rtable *rt, c=
onst struct flowi4 *fl4,
 			rt->rt_gateway =3D peer->redirect_learned.a4;
 			rt->rt_flags |=3D RTCF_REDIRECTED;
 		}
-	} else {
-		if (fi->fib_metrics !=3D (u32 *) dst_default_metrics) {
-			rt->fi =3D fi;
-			atomic_inc(&fi->fib_clntref);
-		}
-		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
-	}
+	} else
+		__rt_init_metrics(rt, fi, NULL);
 }
=20
 static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4=
,
--=20
1.7.0.4
