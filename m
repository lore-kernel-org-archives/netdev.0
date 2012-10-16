From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [stable 2.6.32.y] net/ipv4: fix cached ipv4 dsts never invalidated
Date: Tue, 16 Oct 2012 16:41:04 -0400
Message-ID: <20121016203449.GA25889@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56882 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab2JPUlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 16:41:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Teras <timo.teras@iki.fi>
commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92
Author: Timo Ter=E4s <timo.teras@iki.fi>
Date:   Thu Mar 18 23:20:20 2010 +0000

    ipv4: check rt_genid in dst_check
   =20
    Xfrm_dst keeps a reference to ipv4 rtable entries on each
    cached bundle. The only way to renew xfrm_dst when the underlying
    route has changed, is to implement dst_check for this. This is
    what ipv6 side does too.
   =20
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
   =20
    Signed-off-by: Timo Teras <timo.teras@iki.fi>
    Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>
---
Hi Willy,

Can you please consider applying d11a4dc18bf41719c9f0d7ed494d295dd2973b=
92=20
to 2.6.32.y?  This fixes an issue with cached IPv4 routes never being=20
invalidated.  For more details of the problem this causes, see=20
http://marc.info/?l=3Dlinux-netdev&m=3D135015076708950&w=3D2 .  Thanks!

		-ben

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a770df2..32d3961 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1441,7 +1441,7 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, =
__be32 new_gw,
 					dev_hold(rt->u.dst.dev);
 				if (rt->idev)
 					in_dev_hold(rt->idev);
-				rt->u.dst.obsolete	=3D 0;
+				rt->u.dst.obsolete	=3D -1;
 				rt->u.dst.lastuse	=3D jiffies;
 				rt->u.dst.path		=3D &rt->u.dst;
 				rt->u.dst.neighbour	=3D NULL;
@@ -1506,7 +1506,7 @@ static struct dst_entry *ipv4_negative_advice(str=
uct dst_entry *dst)
 	struct dst_entry *ret =3D dst;
=20
 	if (rt) {
-		if (dst->obsolete) {
+		if (dst->obsolete > 0) {
 			ip_rt_put(rt);
 			ret =3D NULL;
 		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
@@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *d=
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
@@ -1888,7 +1890,8 @@ static int ip_route_input_mc(struct sk_buff *skb,=
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
@@ -2054,6 +2057,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->fl.oif 	=3D 0;
 	rth->rt_spec_dst=3D spec_dst;
=20
+	rth->u.dst.obsolete =3D -1;
 	rth->u.dst.input =3D ip_forward;
 	rth->u.dst.output =3D ip_output;
 	rth->rt_genid =3D rt_genid(dev_net(rth->u.dst.dev));
@@ -2218,6 +2222,7 @@ local_input:
 		goto e_nobufs;
=20
 	rth->u.dst.output=3D ip_rt_bug;
+	rth->u.dst.obsolete =3D -1;
 	rth->rt_genid =3D rt_genid(net);
=20
 	atomic_set(&rth->u.dst.__refcnt, 1);
@@ -2444,6 +2449,7 @@ static int __mkroute_output(struct rtable **resul=
t,
 	rth->rt_spec_dst=3D fl->fl4_src;
=20
 	rth->u.dst.output=3Dip_output;
+	rth->u.dst.obsolete =3D -1;
 	rth->rt_genid =3D rt_genid(dev_net(dev_out));
=20
 	RT_CACHE_STAT_INC(out_slow_tot);
--=20
"Thought is the essence of where you are now."
