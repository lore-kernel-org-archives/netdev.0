From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 18:35:37 +0200
Message-ID: <20130710163537.GJ15411@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710152001.GH15411@order.stressinduktion.org> <20130710155904.GI15411@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:37230 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095Ab3GJQfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 12:35:38 -0400
Content-Disposition: inline
In-Reply-To: <20130710155904.GI15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 05:59:04PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Jul 10, 2013 at 05:20:01PM +0200, Hannes Frederic Sowa wrote:
> > On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
> > > Le 10/07/2013 15:21, Hannes Frederic Sowa a =C3=A9crit :
> > > >On Wed, Jul 10, 2013 at 02:22:55PM +0200, Nicolas Dichtel wrote:
> > > >>Le 10/07/2013 12:53, Hannes Frederic Sowa a =C3=A9crit :
> > > >The route with rt6i_gateway does actually expire because I got i=
t from
> > > >autoconf and ip -6 r l confirms this, too. It seems this is only=
 the cached
> > > >route (I will confirm shortly). Is this still ok?
> > > I wonder why expires is 0. Even if this route is cached, the flag=
=20
> > > RTF_EXPIRES should be set. Am I wrong?
> >=20
> > It seems it is possible cached route gets its expiration updated. A=
s
> > such it is not counted in the iteration but it is found as a siblin=
g and its
> > nsiblings count is updated again.
>=20
> ip6_link_failure is the problem. We need to remove the route directly=
 instead
> of calling rt6_update_expires:
>=20
> static void ip6_link_failure(struct sk_buff *skb)
> {
>         struct rt6_info *rt;
>=20
>         icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0)=
;
>=20
>         rt =3D (struct rt6_info *) skb_dst(skb);
>         if (rt) {
>                 if (rt->rt6i_flags & RTF_CACHE)
>                         rt6_update_expires(rt, 0);
>                 else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAU=
LT))
>                         rt->rt6i_node->fn_sernum =3D -1;
>         }
> }

With this patch I do not get the panic any more and the routing table
stabilizes and discarded all NUD nonavailable routes. I'll need to revi=
ew
it myself, first. Thanks for your help!

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1096,10 +1096,12 @@ static void ip6_link_failure(struct sk_buff *sk=
b)
=20
        rt =3D (struct rt6_info *) skb_dst(skb);
        if (rt) {
-               if (rt->rt6i_flags & RTF_CACHE)
-                       rt6_update_expires(rt, 0);
-               else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAULT=
))
+               if (rt->rt6i_flags & RTF_CACHE) {
+                       dst_hold(&rt->dst);
+                       ip6_del_rt(rt);
+               } else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEFAU=
LT)) {
                        rt->rt6i_node->fn_sernum =3D -1;
+               }
        }
 }
=20
