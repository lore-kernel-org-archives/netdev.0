From: Vincent Bernat <vincent@bernat.im>
Subject: [v3] net: ipv6: fallback to full lookup if table lookup is unsuitable
Date: Sun, 18 Sep 2016 17:46:07 +0200
Message-ID: <20160918154607.5474-1-vincent@bernat.im>
References: <8bce7180-e4c2-808c-20e0-0bd9634b8fc2@cumulusnetworks.com>
Cc: Vincent Bernat <vincent@bernat.im>
To: David Ahern <dsa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:60623 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbcIRPqR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 11:46:17 -0400
In-Reply-To: <8bce7180-e4c2-808c-20e0-0bd9634b8fc2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8c14586fc320 ("net: ipv6: Use passed in table for nexthop
lookups") introduced a regression: insertion of an IPv6 route in a table
not containing the appropriate connected route for the gateway but which
contained a non-connected route (like a default gateway) fails while it
was previously working:

    $ ip link add eth0 type dummy
    $ ip link set up dev eth0
    $ ip addr add 2001:db8::1/64 dev eth0
    $ ip route add ::/0 via 2001:db8::5 dev eth0 table 20
    $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
    RTNETLINK answers: No route to host
    $ ip -6 route show table 20
    default via 2001:db8::5 dev eth0  metric 1024  pref medium

After this patch, we get:

    $ ip route add 2001:db8:cafe::1/128 via 2001:db8::6 dev eth0 table 20
    $ ip -6 route show table 20
    2001:db8:cafe::1 via 2001:db8::6 dev eth0  metric 1024  pref medium
    default via 2001:db8::5 dev eth0  metric 1024  pref medium

Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/ipv6/route.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad4a7ff301fc..ec33c6d7eed5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1991,9 +1991,18 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 			if (!(gwa_type & IPV6_ADDR_UNICAST))
 				goto out;
 
-			if (cfg->fc_table)
+			if (cfg->fc_table) {
 				grt = ip6_nh_lookup_table(net, cfg, gw_addr);
 
+				if (grt) {
+					if (grt->rt6i_flags & RTF_GATEWAY ||
+					    (dev && dev != grt->dst.dev)) {
+						ip6_rt_put(grt);
+						grt = NULL;
+					}
+				}
+			}
+
 			if (!grt)
 				grt = rt6_lookup(net, gw_addr, NULL,
 						 cfg->fc_ifindex, 1);
-- 
2.9.3
