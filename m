From: David Miller <davem@davemloft.net>
Subject: ipv6: Move xfrm_lookup() call down into icmp6_dst_alloc().
Date: Tue, 06 Dec 2011 17:20:59 -0500 (EST)
Message-ID: <20111206.172059.1345587598050915679.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab1LFWVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:21:01 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6MKx62027447
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 14:21:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And return error pointers.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    2 +-
 net/ipv6/mcast.c        |   18 ++----------------
 net/ipv6/ndisc.c        |    9 +--------
 net/ipv6/route.c        |   12 ++++++++----
 4 files changed, 12 insertions(+), 29 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f9dbf47..789d5f4 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -95,7 +95,7 @@ extern struct rt6_info		*rt6_lookup(struct net *net,
 
 extern struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 					 struct neighbour *neigh,
-					 const struct in6_addr *addr);
+					 struct flowi6 *fl6);
 extern int icmp6_dst_gc(void);
 
 extern void fib6_force_start_gc(struct net *net);
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 518cbb9..ea34d58 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1410,18 +1410,11 @@ static void mld_sendpack(struct sk_buff *skb)
 					   csum_partial(skb_transport_header(skb),
 							mldlen, 0));
 
-	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
-
-	if (!dst) {
-		err = -ENOMEM;
-		goto err_out;
-	}
-
 	icmpv6_flow_init(net->ipv6.igmp_sk, &fl6, ICMPV6_MLD2_REPORT,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
+	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
 
-	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	err = 0;
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -1785,17 +1778,10 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	rcu_read_lock();
 	idev = __in6_dev_get(skb->dev);
 
-	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
-	if (!dst) {
-		err = -ENOMEM;
-		goto err_out;
-	}
-
 	icmpv6_flow_init(sk, &fl6, type,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
-
-	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
+	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto err_out;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index e72c8af..f3e50c2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -516,14 +516,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 	type = icmp6h->icmp6_type;
 
 	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-
-	dst = icmp6_dst_alloc(dev, neigh, daddr);
-	if (!dst) {
-		kfree_skb(skb);
-		return;
-	}
-
-	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
+	dst = icmp6_dst_alloc(dev, neigh, &fl6);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f0b582b..d98cf41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1068,8 +1068,9 @@ static DEFINE_SPINLOCK(icmp6_dst_lock);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 				  struct neighbour *neigh,
-				  const struct in6_addr *addr)
+				  struct flowi6 *fl6)
 {
+	struct dst_entry *dst;
 	struct rt6_info *rt;
 	struct inet6_dev *idev = in6_dev_get(dev);
 	struct net *net = dev_net(dev);
@@ -1080,13 +1081,14 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
 	if (unlikely(!rt)) {
 		in6_dev_put(idev);
+		dst = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 
 	if (neigh)
 		neigh_hold(neigh);
 	else {
-		neigh = __neigh_lookup_errno(&nd_tbl, addr, dev);
+		neigh = __neigh_lookup_errno(&nd_tbl, &fl6->daddr, dev);
 		if (IS_ERR(neigh))
 			neigh = NULL;
 	}
@@ -1095,7 +1097,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->dst.output  = ip6_output;
 	dst_set_neighbour(&rt->dst, neigh);
 	atomic_set(&rt->dst.__refcnt, 1);
-	rt->rt6i_dst.addr = *addr;
+	rt->rt6i_dst.addr = fl6->daddr;
 	rt->rt6i_dst.plen = 128;
 	rt->rt6i_idev     = idev;
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 255);
@@ -1107,8 +1109,10 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 
 	fib6_force_start_gc(net);
 
+	dst = xfrm_lookup(net, &rt->dst, flowi6_to_flowi(fl6), NULL, 0);
+
 out:
-	return &rt->dst;
+	return dst;
 }
 
 int icmp6_dst_gc(void)
-- 
1.7.7.3
