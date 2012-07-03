From: David Miller <davem@davemloft.net>
Subject: [PATCH 13/19] decnet: Use neighbours privately in dn_route struct.
Date: Tue, 03 Jul 2012 02:46:48 -0700 (PDT)
Message-ID: <20120703.024648.672742499325548150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36850 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab2GCJqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:46:49 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 42386584122
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:46:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This allows an easy conversion away from dst_get_neighbour*().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn_route.h |    2 ++
 net/decnet/dn_neigh.c  |    2 +-
 net/decnet/dn_route.c  |   36 +++++++++++++++++++++++++++++-------
 3 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index c507e05..4f7d6a1 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -67,6 +67,8 @@ extern void dn_rt_cache_flush(int delay);
 struct dn_route {
 	struct dst_entry dst;
 
+	struct neighbour *n;
+
 	struct flowidn fld;
 
 	__le16 rt_saddr;
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 8e9a35b..3aede1b 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -202,7 +202,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
-	struct neighbour *neigh = dst_get_neighbour_noref(dst);
+	struct neighbour *neigh = rt->n;
 	struct net_device *dev = neigh->dev;
 	char mac_addr[ETH_ALEN];
 	unsigned int seq;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 60e4c6e..6e74b3f 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -114,6 +114,7 @@ static struct dst_entry *dn_dst_check(struct dst_entry *, __u32);
 static unsigned int dn_dst_default_advmss(const struct dst_entry *dst);
 static unsigned int dn_dst_mtu(const struct dst_entry *dst);
 static void dn_dst_destroy(struct dst_entry *);
+static void dn_dst_ifdown(struct dst_entry *, struct net_device *dev, int how);
 static struct dst_entry *dn_dst_negative_advice(struct dst_entry *);
 static void dn_dst_link_failure(struct sk_buff *);
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu);
@@ -140,6 +141,7 @@ static struct dst_ops dn_dst_ops = {
 	.mtu =			dn_dst_mtu,
 	.cow_metrics =		dst_cow_metrics_generic,
 	.destroy =		dn_dst_destroy,
+	.ifdown =		dn_dst_ifdown,
 	.negative_advice =	dn_dst_negative_advice,
 	.link_failure =		dn_dst_link_failure,
 	.update_pmtu =		dn_dst_update_pmtu,
@@ -148,9 +150,27 @@ static struct dst_ops dn_dst_ops = {
 
 static void dn_dst_destroy(struct dst_entry *dst)
 {
+	struct dn_route *rt = (struct dn_route *) dst;
+
+	if (rt->n)
+		neigh_release(rt->n);
 	dst_destroy_metrics_generic(dst);
 }
 
+static void dn_dst_ifdown(struct dst_entry *dst, struct net_device *dev, int how)
+{
+	if (how) {
+		struct dn_route *rt = (struct dn_route *) dst;
+		struct neighbour *n = rt->n;
+
+		if (n && n->dev == dev) {
+			n->dev = dev_net(dev)->loopback_dev;
+			dev_hold(n->dev);
+			dev_put(dev);
+		}
+	}
+}
+
 static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 {
 	__u16 tmp = (__u16 __force)(src ^ dst);
@@ -246,7 +266,8 @@ static int dn_dst_gc(struct dst_ops *ops)
  */
 static void dn_dst_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	struct neighbour *n = dst_get_neighbour_noref(dst);
+	struct dn_route *rt = (struct dn_route *) dst;
+	struct neighbour *n = rt->n;
 	u32 min_mtu = 230;
 	struct dn_dev *dn;
 
@@ -715,7 +736,8 @@ out:
 static int dn_to_neigh_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *n = dst_get_neighbour_noref(dst);
+	struct dn_route *rt = (struct dn_route *) dst;
+	struct neighbour *n = rt->n;
 
 	return n->output(n, skb);
 }
@@ -729,7 +751,7 @@ static int dn_output(struct sk_buff *skb)
 
 	int err = -EINVAL;
 
-	if (dst_get_neighbour_noref(dst) == NULL)
+	if (rt->n == NULL)
 		goto error;
 
 	skb->dev = dev;
@@ -852,11 +874,11 @@ static int dn_rt_set_next_hop(struct dn_route *rt, struct dn_fib_res *res)
 	}
 	rt->rt_type = res->type;
 
-	if (dev != NULL && dst_get_neighbour_noref(&rt->dst) == NULL) {
+	if (dev != NULL && rt->n == NULL) {
 		n = __neigh_lookup_errno(&dn_neigh_table, &rt->rt_gateway, dev);
 		if (IS_ERR(n))
 			return PTR_ERR(n);
-		dst_set_neighbour(&rt->dst, n);
+		rt->n = n;
 	}
 
 	if (dst_metric(&rt->dst, RTAX_MTU) > rt->dst.dev->mtu)
@@ -1163,7 +1185,7 @@ make_route:
 	rt->rt_dst_map    = fld.daddr;
 	rt->rt_src_map    = fld.saddr;
 
-	dst_set_neighbour(&rt->dst, neigh);
+	rt->n = neigh;
 	neigh = NULL;
 
 	rt->dst.lastuse = jiffies;
@@ -1433,7 +1455,7 @@ make_route:
 	rt->fld.flowidn_iif  = in_dev->ifindex;
 	rt->fld.flowidn_mark = fld.flowidn_mark;
 
-	dst_set_neighbour(&rt->dst, neigh);
+	rt->n = neigh;
 	rt->dst.lastuse = jiffies;
 	rt->dst.output = dn_rt_bug;
 	switch (res.type) {
-- 
1.7.10
