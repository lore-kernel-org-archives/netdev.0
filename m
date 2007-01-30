From: weidong <weid@np.css.fujitsu.com>
Subject: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
	packets
Date: Tue, 30 Jan 2007 07:12:27 +0000 (UTC)
Message-ID: <1172042666.4512.8.camel__28506.5354932614$1170141147$gmane$org@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, yoshifuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail8.fujitsu.co.jp ([192.51.44.38]:39308 "EHLO
	fgwmail8.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965128AbXA3HMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 02:12:14 -0500
Received: from fgwmail7.fujitsu.co.jp (fgwmail7.fujitsu.co.jp [192.51.44.37])
	by fgwmail8.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l0U6eNGk009743
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Tue, 30 Jan 2007 15:40:23 +0900
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id l0U6cxJS031164
	for <netdev@vger.kernel.org> (envelope-from weid@np.css.fujitsu.com);
	Tue, 30 Jan 2007 15:38:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A203E2AC028
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 15:38:59 +0900 (JST)
Received: from s0.gw.fujitsu.co.jp (s0.gw.fujitsu.co.jp [10.0.50.90])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AADE12C095
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 15:38:59 +0900 (JST)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FCF9161C007
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 15:38:59 +0900 (JST)
Received: from ml0b.s.css.fujitsu.com (ml0b.s.css.fujitsu.com [10.23.4.188])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id DC268161C006
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 15:38:58 +0900 (JST)
Date: Wed, 21 Feb 2007 02:24:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, all
	When I tested linux-2.6.19.2, and found maybe there're some packet
routing bugs in linux kernel. My test topology is shown as the
following:

         eth0: fe80::20c:29ff:fe24:fa0a
            |                     eth1: fe80::20c:29ff:fe24:fa14 
            |                      |
------------------------------------------------
            |                      |
            |                      |
            | LAN1                 |LAN2
            |                      |
          -----
            ^
            |  
     Send Echo Request(src addr = fe80::200:ff:fe00:100)

Now we send Echo Request to eth1(ipv6 src addr is fe80::200:ff:fe00:100,
ipv6 dst addr is fe80::20c:29ff:fe24:fa14) on LAN1. Linux will send
ICMPv6 Redirect Packet to us. And the TargetAddress =
fe80::20c:29ff:fe24:fa14, DestinationAddress = fe80::20c:29ff:fe24:fa14.
Obviously, Linux considers that fe80::200:ff:fe00:100 and
fe80::20c:29ff:fe24:fa14 is on the SAME link(LAN0). In fact, kernel
invoke function ip6_foward().

When Linux decides whether or not making use of a rt6_info entry, it
will match the rt->rt6i_idev and rt->rt6_dev. This is done in function
rt6_check_dev(). If nothing matched, rt6_check_dev() return 0. Then
function rt6_score_route() will check whether the matched ipv6 addr
(fe80::20c:29ff:fe24:fa14 in our example) is a link local ipv6 address.
If it is a link local address, and "rt->rt6i_idev" "rt->rt6_dev" match
failed -- rt6_check_dev() return 0. Function rt6_score_route() return -1
directly. I think here is a problem. 

When kernel match eth1 addr with rt6_info entries, it will lookup in
local_table first. In rt6_check_dev() matching "rt->rt6i_idev" "rt-
>rt6_dev" will fail. The reason is oif = 2 , rt->rt6i_idev->dev->ifindex
is 3 and rt->rt6i_dev->ifindex is 1. I think even this match failed,
rt6_score_route() should not return -1, but return 0. And I think check
for RT6_LOOKUP_F_IFACE flag isn't needed here. Checking for this flag is
only needed in route cache when matching dst addr.

Due to the reason mentioned above, all entries in local table matching
dst addr fe80::20c:29ff:fe24:fa14 are failed. And then kernel matches
main table. fe80::/64 entry in main table will match successfully. Later
ip6_rt_copy() will copy the function pointer rt->u.dst.input. Obviously
rt->u.dst.input in main table is ip6_forward().

The following is my patch.

signed-off-by: Wei Dong <weid@np.css.fujitsu.com>

diff -ruN old/net/ipv6/route.c new/net/ipv6/route.c
--- old/net/ipv6/route.c	2007-01-10 14:10:37.000000000 -0500
+++ new/net/ipv6/route.c	2007-01-17 18:24:51.336774016 -0500
@@ -343,7 +343,7 @@
 	int m, n;
 		
 	m = rt6_check_dev(rt, oif);
-	if (!m && (strict & RT6_LOOKUP_F_IFACE))
+	if (!m && (rt->rt6i_flags & RTF_CACHE) && (strict & RT6_LOOKUP_F_IFACE))
 		return -1;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;



