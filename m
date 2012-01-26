From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4/ipv6: Prepare for new route gateway semantics.
Date: Thu, 26 Jan 2012 15:55:44 -0500 (EST)
Message-ID: <20120126.155544.2054995753871805122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab2AZUzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:55:51 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0QKtihw010224
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:55:50 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In the future the ipv4/ipv6 route gateway will take on two types
of values:

1) INADDR_ANY/IN6ADDR_ANY, for local network routes, and in this case
   the neighbour must be obtained using the destination address in
   ipv4/ipv6 header as the lookup key.

2) Everything else, the actual nexthop route address.

So if the gateway is not inaddr-any we use it, otherwise we must use
the packet's destination address.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    5 +++++
 net/ipv6/route.c |   16 +++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcacf54..4eeb8ce 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1117,10 +1117,15 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const vo
 	static const __be32 inaddr_any = 0;
 	struct net_device *dev = dst->dev;
 	const __be32 *pkey = daddr;
+	const struct rtable *rt;
 	struct neighbour *n;
 
+	rt = (const struct rtable *) dst;
+
 	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
 		pkey = &inaddr_any;
+	else if (rt->rt_gateway)
+		pkey = (const __be32 *) &rt->rt_gateway;
 
 	n = __ipv4_neigh_lookup(&arp_tbl, dev, *(__force u32 *)pkey);
 	if (n)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c2e3ab..7d7f306 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -121,9 +121,23 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 	return p;
 }
 
+static inline const void *choose_neigh_daddr(struct rt6_info *rt, const void *daddr)
+{
+	struct in6_addr *p = &rt->rt6i_gateway;
+
+	if (p->s6_addr32[0] | p->s6_addr32[1] |
+	    p->s6_addr32[2] | p->s6_addr32[3])
+		return (const void *) p;
+	return daddr;
+}
+
 static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
-	struct neighbour *n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
+	struct rt6_info *rt = (struct rt6_info *) dst;
+	struct neighbour *n;
+
+	daddr = choose_neigh_daddr(rt, daddr);
+	n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
 	if (n)
 		return n;
 	return neigh_create(&nd_tbl, daddr, dst->dev);
-- 
1.7.7.6
