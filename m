From: Simon Arlott <simon@fire.lp0.eu>
Subject: "[IPV6]: Fix routing round-robin locking." breaks manual default
 route (bug 8349)
Date: Mon, 28 May 2007 22:13:04 +0100
Message-ID: <465B45E0.3040007@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, yoshfuji@linux-ipv6.org, berni@birkenwald.de,
	linkfanel@yahoo.fr
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:44756 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750934AbXE1VNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 17:13:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initial state - address, no routes:
# ip -6 a
2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
    inet6 2001:4b10:1005:0:202:44ff:fe50:91af/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::202:44ff:fe50:91af/64 scope link
       valid_lft forever preferred_lft forever
# ip -6 r
fe80::/64 dev eth0  metric 256  expires 21332290sec mtu 1500 advmss 1440
ff00::/8 dev eth0  metric 256  expires 21332290sec mtu 1500 advmss 1440
unreachable default dev lo  proto none  metric -1  error -101
# ping6 -c 1 2001:4b10:1005:0:205:b4ff:fe12:530
connect: Network is unreachable

Adding a 2000::/3 route works:
# ip -6 r a 2000::/3 via fe80::230:18ff:feb0:25c2 dev eth0
# ping6 -c 1 2001:4b10:1005:0:205:b4ff:fe12:530
64 bytes from 2001:4b10:1005:0:205:b4ff:fe12:530: icmp_seq=1 ttl=64 time=0.921 ms
# ip -6 r d 2000::/3 via fe80::230:18ff:feb0:25c2 dev eth0

Adding a ::/0 route doesn't work:
# ip -6 r a ::/0 via fe80::230:18ff:feb0:25c2 dev eth0
# ping6 -c 1 2001:4b10:1005:0:205:b4ff:fe12:530
connect: Network is unreachable

A route assigned by addrconf works.


Reverting this patch from 2.6.22-rc3 fixes it:
	commit f11e6659ce9058928d73ff440f9b40a818d628ab
	Author: David S. Miller <davem@sunset.davemloft.net>
	Date:   Sat Mar 24 20:36:25 2007 -0700
	    [IPV6]: Fix routing round-robin locking.

This patch is was added to 2.6.20.5, breaking -stable too.


With RT6_DEBUG 3 in route.c (plus some additional debug statements):

Manual default route:
[  535.981000] fib6_add_rt2node
[  535.981000] fib6_add_rt2node fn->fn_flags = 00000007 (RTN_TL_ROOT=00000001)
[  535.981000] fib6_add_rt2node fn->leaf = b0697be0 (ip6_null_entry = b0697be0)
[  535.981000] fib6_add_rt2node rt->rt6i_flags = 00000003 (RTF_DEFAULT = 00010000, RTF_ADDRCONF = 00040000)
[  535.981000] fib6_add_rt2node goto out...
[  535.981000] fib6_add_rt2node out:

Ping6:
[  570.903000] rt6_select(fn->leaf=b1b63140, oif=0)
[  570.903000] find_match rt->rt6i_gateway = 00000000 00000000 00000000 00000000
[  570.903000] find_match m = 10, *mpri = -1
[  570.904000] rt6_select() => b0697be0
[  570.904000] rt6_select(fn->leaf=b1b63140, oif=0)
[  570.904000] find_match rt->rt6i_gateway = 00000000 00000000 00000000 00000000
[  570.904000] find_match m = 10, *mpri = -1
[  570.904000] rt6_select() => b0697be0


Addrconf default route:
[  624.846000] rt6_select(fn->leaf=b1b63300, oif=2)
[  624.846000] find_match rt->rt6i_gateway = 000002ff 00000000 00000000 01000000
[  624.846000] find_match m = 10, *mpri = -1
[  624.846000] rt6_select() => b1b63300
[  624.846000] rt6_select(fn->leaf=b1b63300, oif=2)
[  624.846000] find_match rt->rt6i_gateway = 000002ff 00000000 00000000 01000000
[  624.846000] find_match m = 10, *mpri = -1
[  624.846000] rt6_select() => b1b63300
[  624.846000] fib6_add_rt2node
[  624.846000] fib6_add_rt2node fn->fn_flags = 00000007 (RTN_TL_ROOT=00000001)
[  624.846000] fib6_add_rt2node fn->leaf = b0697be0 (ip6_null_entry = b0697be0)
[  624.846000] fib6_add_rt2node rt->rt6i_flags = 00450003 (RTF_DEFAULT = 00010000, RTF_ADDRCONF = 00040000)
[  624.846000] fib6_add_rt2node out:

Ping6:
[  689.245000] rt6_select(fn->leaf=b1b63140, oif=0)
[  689.245000] find_match rt->rt6i_gateway = 104b0120 00000510 ffb40502 300512fe
[  689.245000] find_match m = 10, *mpri = -1
[  689.245000] rt6_select() => b1b63140
[  689.245000] rt6_select(fn->leaf=b1b63140, oif=0)
[  689.245000] find_match rt->rt6i_gateway = 104b0120 00000510 ffb40502 300512fe
[  689.245000] find_match m = 10, *mpri = -1
[  689.245000] rt6_select() => b1b63140
[  689.248000] rt6_select(fn->leaf=b1b63140, oif=0)
[  689.248000] find_match rt->rt6i_gateway = 104b0120 00000510 ffb40502 300512fe
[  689.248000] find_match m = 10, *mpri = -1
[  689.248000] rt6_select() => b1b63140
[  689.248000] rt6_select(fn->leaf=b1b63140, oif=0)
[  689.248000] find_match rt->rt6i_gateway = 104b0120 00000510 ffb40502 300512fe
[  689.248000] find_match m = 10, *mpri = -1
[  689.248000] rt6_select() => b1b63140
[  689.248000] rt6_select(fn->leaf=b1b63ae0, oif=2)
[  689.248000] find_match rt->rt6i_gateway = 00000000 00000000 00000000 00000000
[  689.248000] find_match m = 9, *mpri = -1
[  689.248000] rt6_select() => b1b63ae0
[  689.702000] rt6_select(fn->leaf=b1b63ae0, oif=2)
[  689.702000] find_match rt->rt6i_gateway = 00000000 00000000 00000000 00000000
[  689.702000] find_match m = 9, *mpri = -1
[  689.702000] rt6_select() => b1b63ae0


Manual 2000::/3 route:
[  765.424000] fib6_add_rt2node
[  765.424000] fib6_add_rt2node fn->fn_flags = 00000000 (RTN_TL_ROOT=00000001)
[  765.424000] fib6_add_rt2node fn->leaf = 00000000 (ip6_null_entry = b0697be0)
[  765.424000] fib6_add_rt2node rt->rt6i_flags = 00000003 (RTF_DEFAULT = 00010000, RTF_ADDRCONF = 00040000)
[  765.424000] fib6_add_rt2node out:
[  765.424000] fib6_add_rt2node fn->fn_flags |= RTN_RTINFO;

Ping6:
[  779.705000] rt6_select(fn->leaf=b1b63060, oif=0)
[  779.705000] find_match rt->rt6i_gateway = 000080fe 00000000 ff183002 c225b0fe
[  779.705000] find_match m = 10, *mpri = -1
[  779.705000] rt6_select() => b1b63060
[  779.713000] rt6_select(fn->leaf=b1b63060, oif=0)
[  779.713000] find_match rt->rt6i_gateway = 000080fe 00000000 ff183002 c225b0fe
[  779.713000] find_match m = 10, *mpri = -1
[  779.713000] rt6_select() => b1b63060
[  779.714000] rt6_select(fn->leaf=b1b63ae0, oif=2)
[  779.714000] find_match rt->rt6i_gateway = 00000000 00000000 00000000 00000000
[  779.714000] find_match m = 9, *mpri = -1
[  779.714000] rt6_select() => b1b63ae0

-- 
Simon Arlott
