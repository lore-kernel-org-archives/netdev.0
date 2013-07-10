From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 12:53:16 +0200
Message-ID: <20130710105316.GA5735@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:36515 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab3GJKxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 06:53:18 -0400
Content-Disposition: inline
In-Reply-To: <51DD2959.9060206@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 11:28:57AM +0200, Nicolas Dichtel wrote:
> Le 10/07/2013 09:54, Nicolas Dichtel a =C3=A9crit :
> >Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
> >>After starting a ping6 2000::1 the box should panic soon, after the
> >>first nexthop entry times out.
> >>
> >>Perhaps you could give me a hint?
> >I will run some tests with your patch. Will see.
> I don't reproduce this panic.

I just dumped the routes for which it does increase the rt6i_nsiblings
counter in this condition:

                        /* If we have the same destination and the same=
 metric,                                                               =
                                                                       =
                                                                       =
                                  =20
                         * but not the same gateway, then the route we =
try to                                                                 =
                                                                       =
                                                                       =
                                  =20
                         * add is sibling to this route, increment our =
counter                                                                =
                                                                       =
                                                                       =
                                  =20
                         * of siblings, and later we will add our route=
 to the                                                                =
                                                                       =
                                                                       =
                                  =20
                         * list.                                       =
                                                                       =
                                                                       =
                                                                       =
                                  =20
                         * Only static routes (which don't have flag   =
                                                                       =
                                                                       =
                                                                       =
                                  =20
                         * RTF_EXPIRES) are used for ECMPv6.           =
                                                                       =
                                                                       =
                                                                       =
                                  =20
                         *                                             =
                                                                       =
                                                                       =
                                                                       =
                                  =20
                         * To avoid long list, we only had siblings if =
the                                                                    =
                                                                       =
                                                                       =
                                  =20
                         * route have a gateway.                       =
                                                                       =
                                                                       =
                                                                       =
                                  =20
                         */
                        if (rt->rt6i_flags & RTF_GATEWAY &&
                            !(rt->rt6i_flags & RTF_EXPIRES) &&
                            !(iter->rt6i_flags & RTF_EXPIRES))
                                rt->rt6i_nsiblings++;
                                dump_route(iter, "(iter)");
                                dump_route(rt, "(rt)");
			}



Here:

[   42.497470] (iter): ffff88011796cc00 dst 2000::1 plen 128 gateway 20=
01:db8::32, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff8801139=
ddc00 dev ffff880117e83000
[   42.505912] (rt): ffff88011796d800 dst 2000::1 plen 128 gateway fe80=
::5054:ff:fe82:e153, siblings 1, metric 0, expires 0 gateway 2 idev6 ff=
ff880117edc400 dev ffff8801185cb000
[   42.527241] (iter): ffff88011796d380 dst 2000::1 plen 128 gateway 20=
01:db8::33, siblings 2, metric 0, expires 0 gateway 2 idev6 ffff8801139=
ddc00 dev ffff880117e83000
[   42.536440] (rt): ffff88011796d800 dst 2000::1 plen 128 gateway fe80=
::5054:ff:fe82:e153, siblings 2, metric 0, expires 0 gateway 2 idev6 ff=
ff880117edc400 dev ffff8801185cb000

=46rom my understanding these two routes should not be aggregated in on=
e ecmp
route set. Am I seeing this correct? (My configuration is like in the m=
ail
before.)

I wonder why the '(rt)' route does not have the expires flag, but it se=
ems we
have to special-case RTF_CACHE routes here which derive from different
levels of the fib6_tree. Does that make sense?

Greetings,

  Hannes
