From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 12:24:41 +0200
Message-ID: <20130711102441.GC5207@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:38841 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab3GKKYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 06:24:42 -0400
Content-Disposition: inline
In-Reply-To: <51DE671F.5050706@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 11, 2013 at 10:04:47AM +0200, Nicolas Dichtel wrote:
> Le 10/07/2013 23:21, Hannes Frederic Sowa a =C3=A9crit :
> >On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
> >>I wonder why expires is 0. Even if this route is cached, the flag
> >>RTF_EXPIRES should be set. Am I wrong?
> >
> >rt6_set_from deliberately clears the RTF_EXPIRES when creating a cac=
hed=20
> >copy
> >of the route if the route is an autoconfigured default route.
> >
> >Maybe the criterion for exclusion of which routes can get into an ec=
mp=20
> >route
> >set should be revisited? This could result in strange effects for us=
ers
> >working with two interfaces, both receiving a RA with default routes=
=2E
> Agreed. Here is a proposal, what do you think?
>=20
> [PATCH] ipv6: don't use autoconfigured route for ecmp
>=20
> The intention was already there by checking the flag RTF_EXPIRES, but=
 this=20
> flag
> is removed from the default route by rt6_set_from() when this route i=
s=20
> cached.
>=20
> Let's add a check against RTF_ADDRCONF.
>=20
> Spotted-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I do think the patch is ok. I just wanted to show you a solution I did
on my laptop this night and did not have the time to send yesterday. It
is only compile-tested.

I did strengthen the RTF_EXPIRES check a bit. Also I am not sure what
did stop the search for the first route with the same metric to find a
RTF_EXPIRES route, so I also added the guard there, too.

I fear, I'll need to do a bit more research.

Thanks!

[PATCH RFC] ipv6: routes only qualify for ecmp if their original routes=
 do not expire

Cloned routes get their RTF_EXPIRES flag reset if they are autoconfigur=
ed
default routes. Because these routes should not end up in the ecmp rout=
e
set, we check if the original route has the RTF_EXPIRES flag set.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_fib.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 192dd1a..3bd5fcd 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -632,6 +632,18 @@ insert_above:
 	return ln;
 }
=20
+static bool rt6_qualify_for_ecmp(struct rt6_info *rt0)
+{
+	struct rt6_info *rt;
+
+	if (!(rt0->rt6i_flags & RTF_GATEWAY))
+		return false;
+
+	for (rt =3D rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES);
+	     rt =3D (struct rt6_info *)rt->dst.from);
+	return !(rt && (rt->rt6i_flags & RTF_EXPIRES));
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -691,9 +703,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, s=
truct rt6_info *rt,
 			 * To avoid long list, we only had siblings if the
 			 * route have a gateway.
 			 */
-			if (rt->rt6i_flags & RTF_GATEWAY &&
-			    !(rt->rt6i_flags & RTF_EXPIRES) &&
-			    !(iter->rt6i_flags & RTF_EXPIRES))
+			if (rt6_qualify_for_ecmp(rt) &&
+			    rt6_qualify_for_ecmp(iter))
 				rt->rt6i_nsiblings++;
 		}
=20
@@ -715,7 +726,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, s=
truct rt6_info *rt,
 		/* Find the first route that have the same metric */
 		sibling =3D fn->leaf;
 		while (sibling) {
-			if (sibling->rt6i_metric =3D=3D rt->rt6i_metric) {
+			if (sibling->rt6i_metric =3D=3D rt->rt6i_metric &&
+			    rt6_qualify_for_ecmp(sibling)) {
 				list_add_tail(&rt->rt6i_siblings,
 					      &sibling->rt6i_siblings);
 				break;
--=20
1.8.1.4
