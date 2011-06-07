From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 hitting route max_size
Date: Tue, 07 Jun 2011 00:56:45 -0700 (PDT)
Message-ID: <20110607.005645.1883989402770213985.davem@davemloft.net>
References: <20110606213727.GB11757@hostway.ca>
	<20110606.150142.2071869702137894615.davem@davemloft.net>
	<20110606231521.GB22559@hostway.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: sim@hostway.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab1FGH5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 03:57:50 -0400
In-Reply-To: <20110606231521.GB22559@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kirby <sim@hostway.ca>
Date: Mon, 6 Jun 2011 16:15:21 -0700

> Ok, makes sense, but the result is now that ipv4 loads a full Internet
> table with no adjustments, while ipv6 does not. Would it make sense to
> change 4096 to 1048576, or would it be better to count only clones of
> the actual route or something along those lines?

Simon can you give this patch a try?

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
index de2b1de..7fb44b0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -228,7 +228,8 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 
 /* allocate dst with ip6_dst_ops */
 static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops,
-					     struct net_device *dev)
+					     struct net_device *dev,
+					     int flags)
 {
 	struct rt6_info *rt = dst_alloc(ops, dev, 0, 0, 0);
 
@@ -1042,7 +1043,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
@@ -1214,7 +1215,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL);
+	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, NULL, DST_NOCOUNT);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
@@ -1734,7 +1735,7 @@ static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct net *net = dev_net(ort->rt6i_dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    ort->dst.dev);
+					    ort->dst.dev, 0);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -2013,7 +2014,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops,
-					    net->loopback_dev);
+					    net->loopback_dev, 0);
 	struct neighbour *neigh;
 
 	if (rt == NULL) {
