From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Fix input route performance regression.
Date: Thu, 26 Jul 2012 14:14:38 -0700 (PDT)
Message-ID: <20120726.141438.1996323620706359167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab2GZVOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 17:14:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With the routing cache removal we lost the "noref" code paths on
input, and this can kill some routing workloads.

Reinstate the noref path when we hit a cached route in the FIB
nexthops.

With help from Eric Dumazet.

Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/route.h b/include/net/route.h
index c29ef27..8c52bc6 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -30,6 +30,7 @@
 #include <net/inet_sock.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
+#include <linux/rcupdate.h>
 #include <linux/route.h>
 #include <linux/ip.h>
 #include <linux/cache.h>
@@ -157,8 +158,22 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 	return ip_route_output_key(net, fl4);
 }
 
-extern int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
-			  u8 tos, struct net_device *devin);
+extern int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
+				u8 tos, struct net_device *devin);
+
+static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
+				 u8 tos, struct net_device *devin)
+{
+	int err;
+
+	rcu_read_lock();
+	err = ip_route_input_noref(skb, dst, src, tos, devin);
+	if (!err)
+		skb_dst_force(skb);
+	rcu_read_unlock();
+
+	return err;
+}
 
 extern void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 			     int oif, u32 mark, u8 protocol, int flow_flags);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index a0124eb..77e87af 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -827,7 +827,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input_noref(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e55171f..da0cc2e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -172,9 +172,9 @@ static void free_fib_info_rcu(struct rcu_head *head)
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
 		if (nexthop_nh->nh_rth_output)
-			dst_release(&nexthop_nh->nh_rth_output->dst);
+			dst_free(&nexthop_nh->nh_rth_output->dst);
 		if (nexthop_nh->nh_rth_input)
-			dst_release(&nexthop_nh->nh_rth_input->dst);
+			dst_free(&nexthop_nh->nh_rth_input->dst);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 7ad88e5..8d07c97 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -258,8 +258,8 @@ static void ip_expire(unsigned long arg)
 		/* skb dst is stale, drop it, and perform route lookup again */
 		skb_dst_drop(head);
 		iph = ip_hdr(head);
-		err = ip_route_input(head, iph->daddr, iph->saddr,
-				     iph->tos, head->dev);
+		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
+					   iph->tos, head->dev);
 		if (err)
 			goto out_rcu_unlock;
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 93134b0..bda8cac 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -339,8 +339,8 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (!skb_dst(skb)) {
-		int err = ip_route_input(skb, iph->daddr, iph->saddr,
-					 iph->tos, skb->dev);
+		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					       iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EXDEV)
 				NET_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f7bb71..fc1a81c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1199,10 +1199,9 @@ restart:
 	fnhe->fnhe_stamp = jiffies;
 }
 
-static inline void rt_release_rcu(struct rcu_head *head)
+static inline void rt_free(struct rtable *rt)
 {
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-	dst_release(dst);
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
@@ -1216,9 +1215,15 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
-		dst_clone(&rt->dst);
 		if (orig)
-			call_rcu_bh(&orig->dst.rcu_head, rt_release_rcu);
+			rt_free(orig);
+	} else {
+		/* Routes we intend to cache in the FIB nexthop have
+		 * the DST_NOCACHE bit clear.  However, if we are
+		 * unsuccessful at storing this route into the cache
+		 * we really need to set it.
+		 */
+		rt->dst.flags |= DST_NOCACHE;
 	}
 }
 
@@ -1245,7 +1250,7 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
-		if (!(rt->dst.flags & DST_HOST))
+		if (!(rt->dst.flags & DST_NOCACHE))
 			rt_cache_route(nh, rt);
 	}
 
@@ -1261,7 +1266,7 @@ static struct rtable *rt_dst_alloc(struct net_device *dev,
 				   bool nopolicy, bool noxfrm, bool will_cache)
 {
 	return dst_alloc(&ipv4_dst_ops, dev, 1, DST_OBSOLETE_FORCE_CHK,
-			 (will_cache ? 0 : DST_HOST) | DST_NOCACHE |
+			 (will_cache ? 0 : (DST_HOST | DST_NOCACHE)) |
 			 (nopolicy ? DST_NOPOLICY : 0) |
 			 (noxfrm ? DST_NOXFRM : 0));
 }
@@ -1366,8 +1371,7 @@ static void ip_handle_martian_source(struct net_device *dev,
 static int __mkroute_input(struct sk_buff *skb,
 			   const struct fib_result *res,
 			   struct in_device *in_dev,
-			   __be32 daddr, __be32 saddr, u32 tos,
-			   struct rtable **result)
+			   __be32 daddr, __be32 saddr, u32 tos)
 {
 	struct rtable *rth;
 	int err;
@@ -1418,7 +1422,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		if (!itag) {
 			rth = FIB_RES_NH(*res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
-				dst_hold(&rth->dst);
+				skb_dst_set_noref(skb, &rth->dst);
 				goto out;
 			}
 			do_cache = true;
@@ -1445,8 +1449,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, NULL, res->fi, res->type, itag);
+	skb_dst_set(skb, &rth->dst);
 out:
-	*result = rth;
 	err = 0;
  cleanup:
 	return err;
@@ -1458,21 +1462,13 @@ static int ip_mkroute_input(struct sk_buff *skb,
 			    struct in_device *in_dev,
 			    __be32 daddr, __be32 saddr, u32 tos)
 {
-	struct rtable *rth = NULL;
-	int err;
-
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
 		fib_select_multipath(res);
 #endif
 
 	/* create a routing cache entry */
-	err = __mkroute_input(skb, res, in_dev, daddr, saddr, tos, &rth);
-	if (err)
-		return err;
-
-	skb_dst_set(skb, &rth->dst);
-	return 0;
+	return __mkroute_input(skb, res, in_dev, daddr, saddr, tos);
 }
 
 /*
@@ -1588,8 +1584,9 @@ local_input:
 		if (!itag) {
 			rth = FIB_RES_NH(res).nh_rth_input;
 			if (rt_cache_valid(rth)) {
-				dst_hold(&rth->dst);
-				goto set_and_out;
+				skb_dst_set_noref(skb, &rth->dst);
+				err = 0;
+				goto out;
 			}
 			do_cache = true;
 		}
@@ -1620,7 +1617,6 @@ local_input:
 	}
 	if (do_cache)
 		rt_cache_route(&FIB_RES_NH(res), rth);
-set_and_out:
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
@@ -1658,8 +1654,8 @@ martian_source_keep_err:
 	goto out;
 }
 
-int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-		   u8 tos, struct net_device *dev)
+int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			 u8 tos, struct net_device *dev)
 {
 	int res;
 
@@ -1702,7 +1698,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rcu_read_unlock();
 	return res;
 }
-EXPORT_SYMBOL(ip_route_input);
+EXPORT_SYMBOL(ip_route_input_noref);
 
 /* called with rcu_read_lock() */
 static struct rtable *__mkroute_output(const struct fib_result *res,
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 58d23a5..06814b6 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -27,8 +27,8 @@ static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 	if (skb_dst(skb) == NULL) {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (ip_route_input(skb, iph->daddr, iph->saddr,
-				   iph->tos, skb->dev))
+		if (ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					 iph->tos, skb->dev))
 			goto drop;
 	}
 	return dst_input(skb);
