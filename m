From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2 v2] ipv6: Don't put artificial limit on routing table
 size.
Date: Fri, 24 Jun 2011 16:47:14 -0700 (PDT)
Message-ID: <20110624.164714.818703999938385913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@hostway.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758624Ab1FXXrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 19:47:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPV6, unlike IPV4, doesn't have a routing cache.

Routing table entries, as well as clones made in response
to route lookup requests, all live in the same table.  And
all of these things are together collected in the destination
cache table for ipv6.

This means that routing table entries count against the garbage
collection limits, even though such entries cannot ever be reclaimed
and are added explicitly by the administrator (rather than being
created in response to lookups).

Therefore it makes no sense to count ipv6 routing table entries
against the GC limits.

Add a DST_NOCOUNT destination cache entry flag, and skip the counting
if it is set.  Use this flag bit in ipv6 when adding routing table
entries.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h |    1 +
 net/core/dst.c    |    6 ++++--
 net/ipv6/route.c  |   13 +++++++------
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 7d15d23..e12ddfb 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -77,6 +77,7 @@ struct dst_entry {
 #define DST_NOPOLICY		0x0004
 #define DST_NOHASH		0x0008
 #define DST_NOCACHE		0x0010
+#define DST_NOCOUNT		0x0020
 	union {
 		struct dst_entry	*next;
 		struct rtable __rcu	*rt_next;
diff --git a/net/core/dst.c b/net/core/dst.c
index 9ccca03..6135f36 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -190,7 +190,8 @@ void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 	dst->lastuse = jiffies;
 	dst->flags = flags;
 	dst->next = NULL;
-	dst_entries_add(ops, 1);
+	if (!(flags & DST_NOCOUNT))
+		dst_entries_add(ops, 1);
 	return dst;
 }
 EXPORT_SYMBOL(dst_alloc);
@@ -243,7 +244,8 @@ again:
 		neigh_release(neigh);
 	}
 
-	dst_entries_add(dst->ops, -1);
+	if (!(dst->flags & DST_NOCOUNT))
+		dst_entries_add(dst->ops, -1);
 
 	if (dst->ops->destroy)
 		dst->ops->destroy(dst);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2af4da..0ef1f08 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -228,9 +228,10 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 
 /* allocate dst with ip6_dst_ops */
 static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
-					     struct net_device *dev)
+					     struct net_device *dev,
+					     int flags)
 {
-	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, 0);
+	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, flags);
 
 	memset(&rt->rt6i_table, 0, sizeof(*rt) - sizeof(struct dst_entry));
 
@@ -1042,7 +1043,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
@@ -1206,7 +1207,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, DST_NOCOUNT);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
@@ -1726,7 +1727,7 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct net *net = dev_net(ort->rt6i_dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    ort->dst.dev);
+					    ort->dst.dev, 0);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -2005,7 +2006,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    net->loopback_dev);
+					    net->loopback_dev, 0);
 	struct neighbour *neigh;
 
 	if (rt == NULL) {
-- 
1.7.5.4

