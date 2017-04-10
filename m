From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 1/3] ipv6: Fix route handling when using l3mdev set to main table
Date: Mon, 10 Apr 2017 15:22:00 +0100
Message-ID: <1491834122-26252-2-git-send-email-rshearma@brocade.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51898 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753752AbdDJOWj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:22:39 -0400
In-Reply-To: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an l3mdev is set to use the main table then the use of the local
table is overridden. This means that when split local/main table is in
effect then local routes aren't added to the local table and so don't
respect the order of ip rules.

Fix this by assuming that no if no l3mdev is present then defaulting
to RT6_TABLE_MAIN and then subsequently doing a translation from
RT6_TABLE_MAIN to RT6_TABLE_LOCAL.

Do the same translations for RT6_TABLE_INFO, RT6_TABLE_DFLT and
RT6_TABLE_PREFIX even though they are just defined to RT6_TABLE_MAIN
in case someone decides to change that in the future.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv6/addrconf.c | 12 +++++++++---
 net/ipv6/route.c    | 23 ++++++++++++++++++-----
 2 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 67ec87ea5fb6..937c35581a28 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2244,7 +2244,6 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		      unsigned long expires, u32 flags)
 {
 	struct fib6_config cfg = {
-		.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX,
 		.fc_metric = IP6_RT_PRIO_ADDRCONF,
 		.fc_ifindex = dev->ifindex,
 		.fc_expires = expires,
@@ -2254,6 +2253,9 @@ addrconf_prefix_route(struct in6_addr *pfx, int plen, struct net_device *dev,
 		.fc_protocol = RTPROT_KERNEL,
 	};
 
+	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
+	if (cfg.fc_table == RT6_TABLE_MAIN)
+		cfg.fc_table = RT6_TABLE_PREFIX;
 	cfg.fc_dst = *pfx;
 
 	/* Prevent useless cloning on PtP SIT.
@@ -2277,8 +2279,10 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_PREFIX;
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
 
+	if (tb_id == RT6_TABLE_MAIN)
+		tb_id = RT6_TABLE_PREFIX;
 	table = fib6_get_table(dev_net(dev), tb_id);
 	if (!table)
 		return NULL;
@@ -2310,7 +2314,6 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 static void addrconf_add_mroute(struct net_device *dev)
 {
 	struct fib6_config cfg = {
-		.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_LOCAL,
 		.fc_metric = IP6_RT_PRIO_ADDRCONF,
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
@@ -2318,6 +2321,9 @@ static void addrconf_add_mroute(struct net_device *dev)
 		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
+	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
+	if (cfg.fc_table == RT6_TABLE_MAIN)
+		cfg.fc_table = RT6_TABLE_LOCAL;
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
 
 	ip6_route_add(&cfg);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9db1418993f2..490c74ed6a78 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2424,12 +2424,15 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *gwaddr,
 					   struct net_device *dev)
 {
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO;
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
 	int ifindex = dev->ifindex;
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
+	if (tb_id == RT6_TABLE_MAIN)
+		tb_id = RT6_TABLE_INFO;
+
 	table = fib6_get_table(net, tb_id);
 	if (!table)
 		return NULL;
@@ -2471,7 +2474,9 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_nlinfo.nl_net = net,
 	};
 
-	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO,
+	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
+	if (cfg.fc_table == RT6_TABLE_MAIN)
+		cfg.fc_table = RT6_TABLE_INFO;
 	cfg.fc_dst = *prefix;
 	cfg.fc_gateway = *gwaddr;
 
@@ -2487,10 +2492,13 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 
 struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_device *dev)
 {
-	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT;
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
+	if (tb_id == RT6_TABLE_MAIN)
+		tb_id = RT6_TABLE_DFLT;
+
 	table = fib6_get_table(dev_net(dev), tb_id);
 	if (!table)
 		return NULL;
@@ -2513,7 +2521,6 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 				     unsigned int pref)
 {
 	struct fib6_config cfg = {
-		.fc_table	= l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT,
 		.fc_metric	= IP6_RT_PRIO_USER,
 		.fc_ifindex	= dev->ifindex,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
@@ -2523,6 +2530,10 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 		.fc_nlinfo.nl_net = dev_net(dev),
 	};
 
+	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_MAIN;
+	if (cfg.fc_table == RT6_TABLE_MAIN)
+		cfg.fc_table = RT6_TABLE_DFLT;
+
 	cfg.fc_gateway = *gwaddr;
 
 	if (!ip6_route_add(&cfg)) {
@@ -2723,7 +2734,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->rt6i_gateway  = *addr;
 	rt->rt6i_dst.addr = *addr;
 	rt->rt6i_dst.plen = 128;
-	tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
+	tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_MAIN;
+	if (tb_id == RT6_TABLE_MAIN)
+		tb_id = RT6_TABLE_LOCAL;
 	rt->rt6i_table = fib6_get_table(net, tb_id);
 	rt->dst.flags |= DST_NOCACHE;
 
-- 
2.1.4
