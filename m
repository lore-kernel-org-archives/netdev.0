From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Fri, 16 Sep 2016 12:36:04 -0600
Message-ID: <adff2e07-75e1-d44c-4799-0920ffcd2622@cumulusnetworks.com>
References: <20160916125531.3486-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34037 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcIPSgH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 14:36:07 -0400
Received: by mail-pa0-f50.google.com with SMTP id wk8so28300934pab.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:36:06 -0700 (PDT)
In-Reply-To: <20160916125531.3486-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/16 6:55 AM, Vincent Bernat wrote:
> Commit 8c14586fc320 ("net: ipv6: Use passed in table for nexthop
> lookups") introduced a regression: insertion of an IPv6 route in a table
> not containing the appropriate connected route for the gateway but which
> contained a non-connected route (like a default gateway) fails while it
> was previously working:
> 
>     $ ip link add eth0 type dummy
>     $ ip link set up dev eth0
>     $ ip addr add 2001:db8::1/64 dev eth0
>     $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
>     $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
>     RTNETLINK answers: No route to host
>     $ ip -6 route show table 20
>     default via 2001:db8::5 dev eth0  metric 1024  pref medium

so your table 20 is not complete in that it lacks a connected route to resolve 2001:db8::6 as a nexthop, so you are relying on a fallback to other tables (main in this case).

-----8<-----

> @@ -1991,33 +2015,15 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
>  			if (!(gwa_type & IPV6_ADDR_UNICAST))
>  				goto out;
>  
> +			err = -EHOSTUNREACH;
>  			if (cfg->fc_table)
>  				grt = ip6_nh_lookup_table(net, cfg, gw_addr);

-----8<-----

> -			if (!(grt->rt6i_flags & RTF_GATEWAY))
> -				err = 0;

This is the check that is failing for your use case. ip6_nh_lookup_table is returning the default route and nexthops can not rely on a gateway. Given that a simpler and more direct change is (whitespace mangled on paste):

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad4a7ff301fc..48bae2ee2e18 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1991,9 +1991,19 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
                        if (!(gwa_type & IPV6_ADDR_UNICAST))
                                goto out;

-                       if (cfg->fc_table)
+                       if (cfg->fc_table) {
                                grt = ip6_nh_lookup_table(net, cfg, gw_addr);

+                               /* a nexthop lookup can not go through a gw.
+                                * if this happens on a table based lookup
+                                * then fallback to a full lookup
+                                */
+                               if (grt && grt->rt6i_flags & RTF_GATEWAY) {
+                                       ip6_rt_put(grt);
+                                       grt = NULL;
+                               }
+                       }
+
                        if (!grt)
                                grt = rt6_lookup(net, gw_addr, NULL,
                                                 cfg->fc_ifindex, 1);
