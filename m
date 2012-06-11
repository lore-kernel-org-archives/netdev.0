From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] inet: Use FIB table peer roots in routes.
Date: Mon, 11 Jun 2012 02:29:20 -0700 (PDT)
Message-ID: <20120611.022920.1985101064843460396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2FKJ3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:20 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 9153258426D
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    8 ++++++--
 net/ipv6/route.c |   14 ++++++++------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 456a947..4c33ce3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2125,7 +2125,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= daddr;
 	rth->rt_spec_dst= spec_dst;
 	rth->rt_peer_genid = 0;
-	rt_init_peer(rth, dev_net(rth->dst.dev)->ipv4.peers);
+	rt_init_peer(rth, &res->table->tb_peers);
 	rth->fi = NULL;
 
 	rth->dst.input = ip_forward;
@@ -2512,7 +2512,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_gateway = fl4->daddr;
 	rth->rt_spec_dst= fl4->saddr;
 	rth->rt_peer_genid = 0;
-	rt_init_peer(rth, dev_net(dev_out)->ipv4.peers);
+	rt_init_peer(rth, (res->table ?
+			   &res->table->tb_peers :
+			   dev_net(dev_out)->ipv4.peers));
 	rth->fi = NULL;
 
 	RT_CACHE_STAT_INC(out_slow_tot);
@@ -2561,6 +2563,7 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 	int orig_oif;
 
 	res.fi		= NULL;
+	res.table	= NULL;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	res.r		= NULL;
 #endif
@@ -2666,6 +2669,7 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 
 	if (fib_lookup(net, fl4, &res)) {
 		res.fi = NULL;
+		res.table = NULL;
 		if (fl4->flowi4_oif) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 17a9b86..d9ba480 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -260,7 +260,8 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 /* allocate dst with ip6_dst_ops */
 static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 					     struct net_device *dev,
-					     int flags)
+					     int flags,
+					     struct fib6_table *table)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
 					0, 0, flags);
@@ -268,7 +269,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 	if (rt) {
 		memset(&rt->rt6i_table, 0,
 		       sizeof(*rt) - sizeof(struct dst_entry));
-		rt6_init_peer(rt, net->ipv6.peers);
+		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 	}
 	return rt;
 }
@@ -1114,7 +1115,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(!idev))
 		return ERR_PTR(-ENODEV);
 
-	rt = ip6_dst_alloc(net, dev, 0);
+	rt = ip6_dst_alloc(net, dev, 0, NULL);
 	if (unlikely(!rt)) {
 		in6_dev_put(idev);
 		dst = ERR_PTR(-ENOMEM);
@@ -1296,7 +1297,7 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (!table)
 		goto out;
 
-	rt = ip6_dst_alloc(net, NULL, DST_NOCOUNT);
+	rt = ip6_dst_alloc(net, NULL, DST_NOCOUNT, table);
 
 	if (!rt) {
 		err = -ENOMEM;
@@ -1818,7 +1819,8 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 				    const struct in6_addr *dest)
 {
 	struct net *net = dev_net(ort->dst.dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, ort->dst.dev, 0);
+	struct rt6_info *rt = ip6_dst_alloc(net, ort->dst.dev, 0,
+					    ort->rt6i_table);
 
 	if (rt) {
 		rt->dst.input = ort->dst.input;
@@ -2102,7 +2104,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    bool anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0);
+	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev, 0, NULL);
 	int err;
 
 	if (!rt) {
-- 
1.7.10
