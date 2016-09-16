From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] net: ipv6: fallback to full lookup if table lookup is unsuitable
Date: Fri, 16 Sep 2016 14:55:31 +0200
Message-ID: <20160916125531.3486-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:44097 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757429AbcIPMzp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 08:55:45 -0400
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

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 net/ipv6/route.c | 48 +++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad4a7ff301fc..c2aaddcfed9e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1808,6 +1808,30 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
 	return rt;
 }
 
+static int ip6_nh_valid(struct rt6_info *grt,
+			struct net_device **dev, struct inet6_dev **idev) {
+	int ret = 0;
+
+	if (!grt)
+		goto out;
+	if (grt->rt6i_flags & RTF_GATEWAY)
+		goto out;
+	if (*dev) {
+		if (*dev != grt->dst.dev)
+			goto out;
+	} else {
+		*dev = grt->dst.dev;
+		*idev = grt->rt6i_idev;
+		dev_hold(*dev);
+		in6_dev_hold(*idev);
+	}
+	ret = 1;
+out:
+	if (grt)
+		ip6_rt_put(grt);
+	return ret;
+}
+
 static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 {
 	struct net *net = cfg->fc_nlinfo.nl_net;
@@ -1991,33 +2015,15 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 			if (!(gwa_type & IPV6_ADDR_UNICAST))
 				goto out;
 
+			err = -EHOSTUNREACH;
 			if (cfg->fc_table)
 				grt = ip6_nh_lookup_table(net, cfg, gw_addr);
-
-			if (!grt)
+			if (!ip6_nh_valid(grt, &dev, &idev)) {
 				grt = rt6_lookup(net, gw_addr, NULL,
 						 cfg->fc_ifindex, 1);
-
-			err = -EHOSTUNREACH;
-			if (!grt)
-				goto out;
-			if (dev) {
-				if (dev != grt->dst.dev) {
-					ip6_rt_put(grt);
+				if (!ip6_nh_valid(grt, &dev, &idev))
 					goto out;
-				}
-			} else {
-				dev = grt->dst.dev;
-				idev = grt->rt6i_idev;
-				dev_hold(dev);
-				in6_dev_hold(grt->rt6i_idev);
 			}
-			if (!(grt->rt6i_flags & RTF_GATEWAY))
-				err = 0;
-			ip6_rt_put(grt);
-
-			if (err)
-				goto out;
 		}
 		err = -EINVAL;
 		if (!dev || (dev->flags & IFF_LOOPBACK))
-- 
2.9.3
