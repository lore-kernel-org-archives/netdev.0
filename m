From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 10:04:47 +0200
Message-ID: <51DE671F.5050706@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710212149.GA26122@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:57975 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644Ab3GKIEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:04:51 -0400
Received: by mail-we0-f182.google.com with SMTP id p60so6602308wes.41
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 01:04:49 -0700 (PDT)
In-Reply-To: <20130710212149.GA26122@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 23:21, Hannes Frederic Sowa a =C3=A9crit :
> On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
>> I wonder why expires is 0. Even if this route is cached, the flag
>> RTF_EXPIRES should be set. Am I wrong?
>
> rt6_set_from deliberately clears the RTF_EXPIRES when creating a cach=
ed copy
> of the route if the route is an autoconfigured default route.
>
> Maybe the criterion for exclusion of which routes can get into an ecm=
p route
> set should be revisited? This could result in strange effects for use=
rs
> working with two interfaces, both receiving a RA with default routes.
Agreed. Here is a proposal, what do you think?

[PATCH] ipv6: don't use autoconfigured route for ecmp

The intention was already there by checking the flag RTF_EXPIRES, but t=
his flag
is removed from the default route by rt6_set_from() when this route is =
cached.

Let's add a check against RTF_ADDRCONF.

Spotted-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
  net/ipv6/ip6_fib.c | 6 +++---
  1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 192dd1a..87e31c6 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -686,14 +686,14 @@ static int fib6_add_rt2node(struct fib6_node *fn,=
 struct=20
rt6_info *rt,
  			 * of siblings, and later we will add our route to the
  			 * list.
  			 * Only static routes (which don't have flag
-			 * RTF_EXPIRES) are used for ECMPv6.
+			 * RTF_EXPIRES nor RTF_ADDRCONF) are used for ECMPv6.
  			 *
  			 * To avoid long list, we only had siblings if the
  			 * route have a gateway.
  			 */
  			if (rt->rt6i_flags & RTF_GATEWAY &&
-			    !(rt->rt6i_flags & RTF_EXPIRES) &&
-			    !(iter->rt6i_flags & RTF_EXPIRES))
+			    !(rt->rt6i_flags & (RTF_EXPIRES|RTF_ADDRCONF)) &&
+			    !(iter->rt6i_flags & (RTF_EXPIRES|RTF_ADDRCONF)))
  				rt->rt6i_nsiblings++;
  		}

--=20
1.8.2.1
