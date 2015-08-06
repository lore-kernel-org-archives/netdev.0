From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] net: track link status of ipv6 nexthops
Date: Thu,  6 Aug 2015 11:42:33 -0400
Message-ID: <1438875754-28025-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36640 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754187AbbHFPno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 11:43:44 -0400
Received: by qgeh16 with SMTP id h16so55480720qge.3
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 08:43:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to track current link status of ipv6 nexthops to match
recent changes that added support for ipv4 nexthops.  There was not a
field already available that could track these and no space available in
the existing rt6i_flags field, so this patch adds rt6i_nhflags to struct
rt6_info.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
---
 include/net/ip6_fib.h   |  1 +
 include/net/ip6_route.h |  1 +
 net/ipv6/addrconf.c     |  2 ++
 net/ipv6/route.c        | 47 ++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 276328e..371780b 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -119,6 +119,7 @@ struct rt6_info {
 	/* These are in a separate cache line. */
 	struct rt6key			rt6i_dst ____cacheline_aligned_in_smp;
 	u32				rt6i_flags;
+	u32				rt6i_nhflags;
 	struct rt6key			rt6i_src;
 	struct rt6key			rt6i_prefsrc;
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 297629a..6ba5e9e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -125,6 +125,7 @@ struct rt6_rtnl_dump_arg {
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg);
 void rt6_ifdown(struct net *net, struct net_device *dev);
+void rt6_link_change(struct net *net, struct net_device *dev);
 void rt6_mtu_change(struct net_device *dev, unsigned int mtu);
 void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
 void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 53e3a9d..3fc8ee2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3126,6 +3126,8 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				run_pending = 1;
 			}
 		} else {
+			rt6_link_change(dev_net(dev), dev);
+
 			if (!addrconf_qdisc_ok(dev)) {
 				/* device is still not ready. */
 				break;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 54fccf0..a5c8c6a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1919,6 +1919,9 @@ install_route:
 	rt->rt6i_idev = idev;
 	rt->rt6i_table = table;
 
+	if (!netif_carrier_ok(dev))
+		rt->rt6i_nhflags |= RTNH_F_LINKDOWN;
+
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
 	err = ip6_convert_metrics(&mxc, cfg);
@@ -2161,6 +2164,7 @@ static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
 	rt->rt6i_prefsrc = ort->rt6i_prefsrc;
 	rt->rt6i_table = ort->rt6i_table;
 	rt->rt6i_lwtstate = lwtstate_get(ort->rt6i_lwtstate);
+	rt->rt6i_nhflags = ort->rt6i_nhflags;
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
@@ -2526,6 +2530,30 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
+static int fib6_linkup(struct rt6_info *rt, void *arg)
+{
+	const struct arg_dev_net *adn = arg;
+	const struct net_device *dev = adn->dev;
+
+	if (rt->dst.dev == dev || !dev)
+		rt->rt6i_nhflags &= ~RTNH_F_LINKDOWN;
+	return 0;
+}
+
+static int fib6_linkdown(struct rt6_info *rt, void *arg)
+{
+	const struct arg_dev_net *adn = arg;
+	const struct net_device *dev = adn->dev;
+
+	if (rt->dst.dev == dev || !dev) {
+		rt->rt6i_nhflags |= RTNH_F_LINKDOWN;
+
+		if (rt->rt6i_flags & RTF_CACHE)
+			return -1;
+	}
+	return 0;
+}
+
 void rt6_ifdown(struct net *net, struct net_device *dev)
 {
 	struct arg_dev_net adn = {
@@ -2538,6 +2566,23 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 	rt6_uncached_list_flush_dev(net, dev);
 }
 
+void rt6_link_change(struct net *net, struct net_device *dev)
+{
+	struct arg_dev_net adn = {
+		.dev = dev,
+		.net = net,
+	};
+	unsigned int flags = dev_get_flags(dev);
+
+	if (flags & (IFF_RUNNING | IFF_LOWER_UP)) {
+		fib6_clean_all(net, fib6_linkup, &adn);
+		icmp6_clean_all(fib6_linkup, &adn);
+	} else {
+		fib6_clean_all(net, fib6_linkdown, &adn);
+		icmp6_clean_all(fib6_linkdown, &adn);
+	}
+}
+
 struct rt6_mtu_change_arg {
 	struct net_device *dev;
 	unsigned int mtu;
@@ -2884,7 +2929,7 @@ static int rt6_fill_node(struct net *net,
 		rtm->rtm_type = RTN_LOCAL;
 	else
 		rtm->rtm_type = RTN_UNICAST;
-	rtm->rtm_flags = 0;
+	rtm->rtm_flags = rt->rt6i_nhflags;
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
-- 
1.9.3
