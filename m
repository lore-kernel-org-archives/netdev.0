From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 1/6] ipv4: check rt_genid in dst_check
Date: Fri, 19 Oct 2012 15:21:01 -0400
Message-ID: <20121019192101.GA8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43169 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753212Ab2JSTVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:21:03 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92
Author: Timo Ter=E4s <timo.teras@iki.fi>
Date:   Thu Mar 18 23:20:20 2010 +0000

    ipv4: check rt_genid in dst_check

    Xfrm_dst keeps a reference to ipv4 rtable entries on each
    cached bundle. The only way to renew xfrm_dst when the underlying
    route has changed, is to implement dst_check for this. This is
    what ipv6 side does too.

    The problems started after 87c1e12b5eeb7b30b4b41291bef8e0b41fc3dde9
    ("ipsec: Fix bogus bundle flowi") which fixed a bug causing xfrm_ds=
t
    to not get reused, until that all lookups always generated new
    xfrm_dst with new route reference and path mtu worked. But after th=
e
    fix, the old routes started to get reused even after they were expi=
red
    causing pmtu to break (well it would occationally work if the rtabl=
e
    gc had run recently and marked the route obsolete causing dst_check=
 to
    get called).

    Signed-off-by: Timo Teras <timo.teras@iki.fi>
    Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This commit is based on the above, with the addition of verifying black=
hole
routes in the same manner.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv4/route.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 58f141b..f16d19b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1412,7 +1412,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, =
__be32 new_gw,
 					dev_hold(rt->u.dst.dev);
 				if (rt->idev)
 					in_dev_hold(rt->idev);
-				rt->u.dst.obsolete	=3D 0;
+				rt->u.dst.obsolete	=3D -1;
 				rt->u.dst.lastuse	=3D jiffies;
 				rt->u.dst.path		=3D &rt->u.dst;
 				rt->u.dst.neighbour	=3D NULL;
@@ -1477,7 +1477,7 @@ static struct dst_entry *ipv4_negative_advice(str=
uct dst_entry *dst)
 	struct dst_entry *ret =3D dst;
=20
 	if (rt) {
-		if (dst->obsolete) {
+		if (dst->obsolete > 0) {
 			ip_rt_put(rt);
 			ret =3D NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
@@ -1700,7 +1700,9 @@ static void ip_rt_update_pmtu(struct dst_entry *d=
st, u32 mtu)
=20
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 coo=
kie)
 {
-	return NULL;
+	if (rt_is_expired((struct rtable *)dst))
+		return NULL;
+	return dst;
 }
=20
 static void ipv4_dst_destroy(struct dst_entry *dst)
@@ -1862,7 +1864,8 @@ static int ip_route_input_mc(struct sk_buff *skb,=
 __be32 daddr, __be32 saddr,
 	if (!rth)
 		goto e_nobufs;
=20
-	rth->u.dst.output=3D ip_rt_bug;
+	rth->u.dst.output =3D ip_rt_bug;
+	rth->u.dst.obsolete =3D -1;
=20
 	atomic_set(&rth->u.dst.__refcnt, 1);
 	rth->u.dst.flags=3D DST_HOST;
@@ -2023,6 +2026,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->fl.oif 	=3D 0;
 	rth->rt_spec_dst=3D spec_dst;
=20
+	rth->u.dst.obsolete =3D -1;
 	rth->u.dst.input =3D ip_forward;
 	rth->u.dst.output =3D ip_output;
 	rth->rt_genid =3D rt_genid(dev_net(rth->u.dst.dev));
@@ -2187,6 +2191,7 @@ local_input:
 		goto e_nobufs;
=20
 	rth->u.dst.output=3D ip_rt_bug;
+	rth->u.dst.obsolete =3D -1;
 	rth->rt_genid =3D rt_genid(net);
=20
 	atomic_set(&rth->u.dst.__refcnt, 1);
@@ -2411,7 +2416,8 @@ static int __mkroute_output(struct rtable **resul=
t,
 	rth->rt_gateway =3D fl->fl4_dst;
 	rth->rt_spec_dst=3D fl->fl4_src;
=20
-	rth->u.dst.output=3Dip_output;
+	rth->u.dst.output =3D ip_output;
+	rth->u.dst.obsolete =3D -1;
 	rth->rt_genid =3D rt_genid(dev_net(dev_out));
=20
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2741,6 +2747,7 @@ static int ipv4_dst_blackhole(struct net *net, st=
ruct rtable **rp, struct flowi
 	if (rt) {
 		struct dst_entry *new =3D &rt->u.dst;
=20
+		new->obsolete =3D -1;
 		atomic_set(&new->__refcnt, 1);
 		new->__use =3D 1;
 		new->input =3D dst_discard;
--=20
1.7.1


--=20
"Thought is the essence of where you are now."
