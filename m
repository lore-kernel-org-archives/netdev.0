From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: RCU conversion of
 ip_route_input_slow/ip_route_input_mc
Date: Thu, 03 Jun 2010 07:21:31 +0200
Message-ID: <1275542491.29413.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60046 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab0FCFVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 01:21:38 -0400
Received: by wyi11 with SMTP id 11so2484648wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 22:21:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David

Following patch on net-next-2.6 if previous patch touching
net/ipv4/route.c is applied before.

(ipv4: add LINUX_MIB_IPRPFILTER snmp counter)

Thanks

[PATCH] ipv4: rcu conversion of ip_route_input_slow/ip_route_input_mc

Avoid two atomic ops on struct in_device refcount per incoming packet,
if slow path taken, (or route cache disabled)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d377b45..1cfe0d1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1843,13 +1843,14 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 	rt->rt_type = res->type;
 }
 
+/* called in rcu_read_lock() section */
 static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct rtable *rth;
 	__be32 spec_dst;
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	u32 itag = 0;
 	int err;
 
@@ -1914,18 +1915,14 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	RT_CACHE_STAT_INC(in_slow_mc);
 
-	in_dev_put(in_dev);
 	hash = rt_hash(daddr, saddr, dev->ifindex, rt_genid(dev_net(dev)));
 	return rt_intern_hash(hash, rth, NULL, skb, dev->ifindex);
 
 e_nobufs:
-	in_dev_put(in_dev);
 	return -ENOBUFS;
-
 e_inval:
-	err = -EINVAL;
+	return -EINVAL;
 e_err:
-	in_dev_put(in_dev);
 	return err;
 }
 
@@ -2101,7 +2098,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 			       u8 tos, struct net_device *dev)
 {
 	struct fib_result res;
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct flowi fl = { .nl_u = { .ip4_u =
 				      { .daddr = daddr,
 					.saddr = saddr,
@@ -2179,7 +2176,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
 done:
-	in_dev_put(in_dev);
 	if (free_res)
 		fib_res_put(&res);
 out:	return err;
@@ -2288,16 +2284,18 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	unsigned	hash;
 	int iif = dev->ifindex;
 	struct net *net;
+	int res;
 
 	net = dev_net(dev);
 
+	rcu_read_lock();
+
 	if (!rt_caching(net))
 		goto skip_cache;
 
 	tos &= IPTOS_RT_MASK;
 	hash = rt_hash(daddr, saddr, iif, rt_genid(net));
 
-	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->u.dst.rt_next)) {
 		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
@@ -2321,7 +2319,6 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
 	}
-	rcu_read_unlock();
 
 skip_cache:
 	/* Multicast recognition logic is moved from route cache to here.
@@ -2336,12 +2333,11 @@ skip_cache:
 	   route cache entry is created eventually.
 	 */
 	if (ipv4_is_multicast(daddr)) {
-		struct in_device *in_dev;
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
 
-		rcu_read_lock();
-		if ((in_dev = __in_dev_get_rcu(dev)) != NULL) {
+		if (in_dev) {
 			int our = ip_check_mc(in_dev, daddr, saddr,
-				ip_hdr(skb)->protocol);
+					      ip_hdr(skb)->protocol);
 			if (our
 #ifdef CONFIG_IP_MROUTE
 				||
@@ -2349,15 +2345,18 @@ skip_cache:
 			     IN_DEV_MFORWARD(in_dev))
 #endif
 			   ) {
+				int res = ip_route_input_mc(skb, daddr, saddr,
+							    tos, dev, our);
 				rcu_read_unlock();
-				return ip_route_input_mc(skb, daddr, saddr,
-							 tos, dev, our);
+				return res;
 			}
 		}
 		rcu_read_unlock();
 		return -EINVAL;
 	}
-	return ip_route_input_slow(skb, daddr, saddr, tos, dev);
+	res = ip_route_input_slow(skb, daddr, saddr, tos, dev);
+	rcu_read_unlock();
+	return res;
 }
 EXPORT_SYMBOL(ip_route_input_common);
 


