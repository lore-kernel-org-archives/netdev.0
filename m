From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Wed, 25 Jul 2012 17:54:06 -0700 (PDT)
Message-ID: <20120725.175406.1331203183232530233.davem@davemloft.net>
References: <CAKgT0UdcqE52WFCT-t2om0SN3Yq5GqiwN+JbwCcnBv4LDOB6BQ@mail.gmail.com>
	<20120725.161732.91008692477078715.davem@davemloft.net>
	<20120725.163939.581743307449189972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646Ab2GZAyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 20:54:10 -0400
In-Reply-To: <20120725.163939.581743307449189972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 25 Jul 2012 16:39:39 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Wed, 25 Jul 2012 16:17:32 -0700 (PDT)
> 
>> From: Alexander Duyck <alexander.duyck@gmail.com>
>> Date: Wed, 25 Jul 2012 16:02:45 -0700
>> 
>>> Since your patches are in I have started to re-run my tests. I am
>>> seeing a significant drop in throughput with 8 flows which I expected,
>>> however it looks like one of the biggest issues I am seeing is that
>>> the dst_hold and dst_release calls seem to be causing some serious
>>> cache thrash.  I was at 12.5Mpps w/ 8 flows before the patches, after
>>> your patches it drops to 8.3Mpps.
>> 
>> Yes, this is something we knew would start happening.
>> 
>> One idea is to make cached dsts be per-cpu in the nexthops.
> 
> Actually I think what really kills your case is the removal of the
> noref path for route lookups.  I'll work on a patch to restore that
> in the case where we use cached routes from the FIB nexthops.

Alex, here is something I tossed together, does it help with the
dst_hold()/dst_release() overhead at all?

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
index 3f7bb71..68887e3 100644
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
+		 * the DST_NOCACHE bit set.  However, if we are
+		 * unsuccessful at storing this route into the cache
+		 * we really need to clear that bit.
+		 */
+		rt->dst.flags &= ~DST_NOCACHE;
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
@@ -1588,8 +1593,9 @@ local_input:
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
@@ -1620,7 +1626,6 @@ local_input:
 	}
 	if (do_cache)
 		rt_cache_route(&FIB_RES_NH(res), rth);
-set_and_out:
 	skb_dst_set(skb, &rth->dst);
 	err = 0;
 	goto out;
@@ -1658,8 +1663,8 @@ martian_source_keep_err:
 	goto out;
 }
 
-int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-		   u8 tos, struct net_device *dev)
+int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			 u8 tos, struct net_device *dev)
 {
 	int res;
 
@@ -1702,7 +1707,7 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
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
