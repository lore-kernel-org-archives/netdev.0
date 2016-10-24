From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Fix processing of RAs in presence of VRF
Date: Mon, 24 Oct 2016 10:39:02 -0700
Message-ID: <1477330742-9310-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34708 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbcJXRjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 13:39:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id r16so102593651pfg.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 10:39:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rt6_add_route_info and rt6_add_dflt_router were updated to pull the FIB
table from the device index, but the corresponding rt6_get_route_info
and rt6_get_dflt_router functions were not leading to the failure to
process RA's:

    ICMPv6: RA: ndisc_router_discovery failed to add default route

Fix the 'get' functions by using the table id associated with the
device when applicable.

Also, now that default routes can be added to tables other than the
default table, rt6_purge_dflt_routers needs to be updated as well to
look at all tables. To handle that efficiently, add a flag to the table
denoting if it is has a default route via RA.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip6_fib.h |  2 ++
 net/ipv6/route.c      | 68 ++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index fb961a576abe..a74e2aa40ef4 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -230,6 +230,8 @@ struct fib6_table {
 	rwlock_t		tb6_lock;
 	struct fib6_node	tb6_root;
 	struct inet_peer_base	tb6_peers;
+	unsigned int		flags;
+#define RT6_TABLE_HAS_DFLT_ROUTER	BIT(0)
 };
 
 #define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bdbc38e8bf29..3ac19eb81a86 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -102,11 +102,13 @@ static int rt6_score_route(struct rt6_info *rt, int oif, int strict);
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
-					   const struct in6_addr *gwaddr, int ifindex,
+					   const struct in6_addr *gwaddr,
+					   struct net_device *dev,
 					   unsigned int pref);
 static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
-					   const struct in6_addr *gwaddr, int ifindex);
+					   const struct in6_addr *gwaddr,
+					   struct net_device *dev);
 #endif
 
 struct uncached_list {
@@ -803,7 +805,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		rt = rt6_get_dflt_router(gwaddr, dev);
 	else
 		rt = rt6_get_route_info(net, prefix, rinfo->prefix_len,
-					gwaddr, dev->ifindex);
+					gwaddr, dev);
 
 	if (rt && !lifetime) {
 		ip6_del_rt(rt);
@@ -811,8 +813,8 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	}
 
 	if (!rt && lifetime)
-		rt = rt6_add_route_info(net, prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
-					pref);
+		rt = rt6_add_route_info(net, prefix, rinfo->prefix_len, gwaddr,
+					dev, pref);
 	else if (rt)
 		rt->rt6i_flags = RTF_ROUTEINFO |
 				 (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
@@ -2325,13 +2327,16 @@ static void ip6_rt_copy_init(struct rt6_info *rt, struct rt6_info *ort)
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_get_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
-					   const struct in6_addr *gwaddr, int ifindex)
+					   const struct in6_addr *gwaddr,
+					   struct net_device *dev)
 {
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO;
+	int ifindex = dev->ifindex;
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
-	table = fib6_get_table(net, RT6_TABLE_INFO);
+	table = fib6_get_table(net, tb_id);
 	if (!table)
 		return NULL;
 
@@ -2357,12 +2362,13 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 
 static struct rt6_info *rt6_add_route_info(struct net *net,
 					   const struct in6_addr *prefix, int prefixlen,
-					   const struct in6_addr *gwaddr, int ifindex,
+					   const struct in6_addr *gwaddr,
+					   struct net_device *dev,
 					   unsigned int pref)
 {
 	struct fib6_config cfg = {
 		.fc_metric	= IP6_RT_PRIO_USER,
-		.fc_ifindex	= ifindex,
+		.fc_ifindex	= dev->ifindex,
 		.fc_dst_len	= prefixlen,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
 				  RTF_UP | RTF_PREF(pref),
@@ -2371,7 +2377,7 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 		.fc_nlinfo.nl_net = net,
 	};
 
-	cfg.fc_table = l3mdev_fib_table_by_index(net, ifindex) ? : RT6_TABLE_INFO;
+	cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO,
 	cfg.fc_dst = *prefix;
 	cfg.fc_gateway = *gwaddr;
 
@@ -2381,16 +2387,17 @@ static struct rt6_info *rt6_add_route_info(struct net *net,
 
 	ip6_route_add(&cfg);
 
-	return rt6_get_route_info(net, prefix, prefixlen, gwaddr, ifindex);
+	return rt6_get_route_info(net, prefix, prefixlen, gwaddr, dev);
 }
 #endif
 
 struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_device *dev)
 {
+	u32 tb_id = l3mdev_fib_table(dev) ? : RT6_TABLE_DFLT;
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
-	table = fib6_get_table(dev_net(dev), RT6_TABLE_DFLT);
+	table = fib6_get_table(dev_net(dev), tb_id);
 	if (!table)
 		return NULL;
 
@@ -2424,20 +2431,20 @@ struct rt6_info *rt6_add_dflt_router(const struct in6_addr *gwaddr,
 
 	cfg.fc_gateway = *gwaddr;
 
-	ip6_route_add(&cfg);
+	if (!ip6_route_add(&cfg)) {
+		struct fib6_table *table;
+
+		table = fib6_get_table(dev_net(dev), cfg.fc_table);
+		if (table)
+			table->flags |= RT6_TABLE_HAS_DFLT_ROUTER;
+	}
 
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
-void rt6_purge_dflt_routers(struct net *net)
+static void __rt6_purge_dflt_routers(struct fib6_table *table)
 {
 	struct rt6_info *rt;
-	struct fib6_table *table;
-
-	/* NOTE: Keep consistent with rt6_get_dflt_router */
-	table = fib6_get_table(net, RT6_TABLE_DFLT);
-	if (!table)
-		return;
 
 restart:
 	read_lock_bh(&table->tb6_lock);
@@ -2451,6 +2458,27 @@ void rt6_purge_dflt_routers(struct net *net)
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
+
+	table->flags &= ~RT6_TABLE_HAS_DFLT_ROUTER;
+}
+
+void rt6_purge_dflt_routers(struct net *net)
+{
+	struct fib6_table *table;
+	struct hlist_head *head;
+	unsigned int h;
+
+	rcu_read_lock();
+
+	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
+		head = &net->ipv6.fib_table_hash[h];
+		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
+			if (table->flags & RT6_TABLE_HAS_DFLT_ROUTER)
+				__rt6_purge_dflt_routers(table);
+		}
+	}
+
+	rcu_read_unlock();
 }
 
 static void rtmsg_to_fib6_config(struct net *net,
-- 
2.1.4
