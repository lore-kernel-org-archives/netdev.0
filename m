From: weidong <weid@np.css.fujitsu.com>
Subject: (usagi-users 03778) [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
	packets
Date: Tue, 30 Jan 2007 07:02:00 +0000 (UTC)
Message-ID: <1172042666.4512.8.camel@LINE>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org, yoshifuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <usagi-users-admin@linux-ipv6.org>
Date: Wed, 21 Feb 2007 02:24:26 -0500
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
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
