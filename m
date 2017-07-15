From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next v1] ip6: fix PMTU discovery when using /127 subnets
Date: Sat, 15 Jul 2017 19:40:20 +0200
Message-ID: <20170715174020.6691-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: Martin KaFai Lau <kafai@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:34446 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751088AbdGORk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 15 Jul 2017 13:40:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The definition of an "anycast destination address" has been tweaked as a
side-effect of commit 2647a9b07032 ("ipv6: Remove external dependency on
rt6i_gateway and RTF_ANYCAST"). The first address of a point-to-point
/127 subnet is now considered as an anycast address. This prevents
ICMPv6 errors to be returned to a sender of such a subnet and breaks
PMTU discovery.

This can be reproduced with:

    ip link add name out6 type veth peer name in6
    ip link add name out7 type veth peer name in7
    ip link set mtu 1400 dev out7
    ip link set mtu 1400 dev in7
    ip netns add next-hop
    ip netns add next-next-hop
    ip link set netns next-hop dev in6
    ip link set netns next-hop dev out7
    ip link set netns next-next-hop dev in7
    ip link set up dev out6
    ip addr add 2001:db8:1::12/127 dev out6
    ip netns exec next-hop ip link set up dev in6
    ip netns exec next-hop ip link set up dev out7
    ip netns exec next-hop ip addr add 2001:db8:1::13/127 dev in6
    ip netns exec next-hop ip addr add 2001:db8:1::14/127 dev out7
    ip netns exec next-hop ip route add default via 2001:db8:1::15
    ip netns exec next-hop sysctl -qw net.ipv6.conf.all.forwarding=1
    ip netns exec next-next-hop ip link set up dev in7
    ip netns exec next-next-hop ip addr add 2001:db8:1::15/127 dev in7
    ip netns exec next-next-hop ip addr add 2001:db8:1::50/128 dev in7
    ip netns exec next-next-hop ip route add default via 2001:db8:1::14
    ip netns exec next-next-hop sysctl -qw net.ipv6.conf.all.forwarding=1
    ip route add 2001:db8:1::48/123 via 2001:db8:1::13
    sleep 4
    ping -M do -s 1452 -c 3 2001:db8:1::50 || true
    ip route get 2001:db8:1::50

Before the patch, we get:

    2001:db8:1::50 from :: via 2001:db8:1::13 dev out6 src 2001:db8:1::12 metric 1024  pref medium

After the patch, we get:

    2001:db8:1::50 via 2001:db8:1::13 dev out6 src 2001:db8:1::12 metric 0
        cache  expires 578sec mtu 1400 pref medium

Fixes: 2647a9b07032 ("ipv6: Remove external dependency on rt6i_gateway and RTF_ANYCAST")
Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 include/net/ip6_route.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 199056933dcb..907d39a42f6b 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -194,7 +194,7 @@ static inline bool ipv6_anycast_destination(const struct dst_entry *dst,
 	struct rt6_info *rt = (struct rt6_info *)dst;
 
 	return rt->rt6i_flags & RTF_ANYCAST ||
-		(rt->rt6i_dst.plen != 128 &&
+		(rt->rt6i_dst.plen < 127 &&
 		 ipv6_addr_equal(&rt->rt6i_dst.addr, daddr));
 }
 
-- 
2.13.2
