From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 5/6] ipv6: use net->rt_genid to check dst validity
Date: Fri, 19 Oct 2012 15:22:16 -0400
Message-ID: <20121019192216.GE8315@kvack.org>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43184 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789Ab2JSTWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:22:16 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6f3118b571b8a4c06c7985dc3172c3526cb86253
Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date:   Mon Sep 10 22:09:46 2012 +0000

    ipv6: use net->rt_genid to check dst validity

    IPv6 dst should take care of rt_genid too. When a xfrm policy is inserted or
    deleted, all dst should be invalidated.
    To force the validation, dst entries should be created with ->obsolete set t
o
    DST_OBSOLETE_FORCE_CHK. This was already the case for all functions calling
    ip6_dst_alloc(), except for ip6_rt_copy().

    As a consequence, we can remove the specific code in inet6_connection_sock.

    Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This version of the above commit is slightly modified to compensate for
differences in ip6_dst_alloc().

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 include/net/ip6_fib.h            |    4 +---
 net/ipv6/inet6_connection_sock.c |   24 +-----------------------
 net/ipv6/route.c                 |   29 +++++++++++++++++++++--------
 3 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 15b492a..c6672d6 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -115,9 +115,7 @@ struct rt6_info
 
 	struct rt6key			rt6i_dst;
 
-#ifdef CONFIG_XFRM
-	u32				rt6i_flow_cache_genid;
-#endif
+	u32				rt6i_genid;
 
 	struct rt6key			rt6i_src;
 };
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index cc4797d..835bfe4 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -148,34 +148,12 @@ void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
 			   struct in6_addr *daddr, struct in6_addr *saddr)
 {
 	__ip6_dst_store(sk, dst, daddr, saddr);
-
-#ifdef CONFIG_XFRM
-	{
-		struct rt6_info *rt = (struct rt6_info  *)dst;
-		rt->rt6i_flow_cache_genid = atomic_read(&flow_cache_genid);
-	}
-#endif
 }
 
 static inline
 struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 {
-	struct dst_entry *dst;
-
-	dst = __sk_dst_check(sk, cookie);
-
-#ifdef CONFIG_XFRM
-	if (dst) {
-		struct rt6_info *rt = (struct rt6_info *)dst;
-		if (rt->rt6i_flow_cache_genid != atomic_read(&flow_cache_genid)) {
-			sk->sk_dst_cache = NULL;
-			dst_release(dst);
-			dst = NULL;
-		}
-	}
-#endif
-
-	return dst;
+	return __sk_dst_check(sk, cookie);
 }
 
 int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b420ea9..80ab9cd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -186,9 +186,17 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 #endif
 
 /* allocate dst with ip6_dst_ops */
-static inline struct rt6_info *ip6_dst_alloc(struct dst_ops *ops)
+static inline struct rt6_info *ip6_dst_alloc(struct net *net,
+					     struct dst_ops *ops)
 {
-	return (struct rt6_info *)dst_alloc(ops);
+	struct rt6_info *rt = (struct rt6_info *)dst_alloc(ops);
+
+	if (rt) {
+		rt->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
+		rt->rt6i_genid = rt_genid(net);
+	}
+
+	return rt;
 }
 
 static void ip6_dst_destroy(struct dst_entry *dst)
@@ -886,6 +894,13 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 
 	rt = (struct rt6_info *) dst;
 
+	/* All IPV6 dsts are created with ->obsolete set to the value
+	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
+	 * into this function always.
+	 */
+	if (rt->rt6i_genid != rt_genid(dev_net(rt->u.dst.dev)))
+		return NULL;
+
 	if (rt && rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
 		return dst;
 
@@ -970,7 +985,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(idev == NULL))
 		return NULL;
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(net, &net->ipv6.ip6_dst_ops);
 	if (unlikely(rt == NULL)) {
 		in6_dev_put(idev);
 		goto out;
@@ -1154,14 +1169,13 @@ int ip6_route_add(struct fib6_config *cfg)
 		goto out;
 	}
 
-	rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	rt = ip6_dst_alloc(net, &net->ipv6.ip6_dst_ops);
 
 	if (rt == NULL) {
 		err = -ENOMEM;
 		goto out;
 	}
 
-	rt->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 	rt->rt6i_expires = (cfg->fc_flags & RTF_EXPIRES) ?
 				jiffies + clock_t_to_jiffies(cfg->fc_expires) :
 				0;
@@ -1663,7 +1677,7 @@ void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *saddr,
 static struct rt6_info * ip6_rt_copy(struct rt6_info *ort)
 {
 	struct net *net = dev_net(ort->rt6i_dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(net, &net->ipv6.ip6_dst_ops);
 
 	if (rt) {
 		rt->u.dst.input = ort->u.dst.input;
@@ -1943,7 +1957,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 				    int anycast)
 {
 	struct net *net = dev_net(idev->dev);
-	struct rt6_info *rt = ip6_dst_alloc(&net->ipv6.ip6_dst_ops);
+	struct rt6_info *rt = ip6_dst_alloc(net, &net->ipv6.ip6_dst_ops);
 	struct neighbour *neigh;
 
 	if (rt == NULL)
@@ -1960,7 +1974,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(net, dst_mtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
-	rt->u.dst.obsolete = DST_OBSOLETE_FORCE_CHK;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (anycast)
-- 
1.7.1


-- 
"Thought is the essence of where you are now."
