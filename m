From: David Miller <davem@davemloft.net>
Subject: [PATCH 08/16] ipv4: Kill ip_rt_redirect().
Date: Thu, 12 Jul 2012 01:11:29 -0700 (PDT)
Message-ID: <20120712.011129.1512977418089187228.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2GLILa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:30 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E71085824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer needed, as the protocol handlers now all properly
propagate the redirect back into the routing code.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    1 -
 net/ipv4/icmp.c     |    1 -
 net/ipv4/route.c    |   44 --------------------------------------------
 3 files changed, 46 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 6ab93ee..ace3cb4 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -108,7 +108,6 @@ extern struct ip_rt_acct __percpu *ip_rt_acct;
 
 struct in_device;
 extern int		ip_rt_init(void);
-extern void		ip_rt_redirect(struct sk_buff *skb, __be32 new_gw);
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
 extern struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 70a7935..d01aeb4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -763,7 +763,6 @@ static void icmp_redirect(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		return;
 
-	ip_rt_redirect(skb, icmp_hdr(skb)->un.gateway);
 	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index aabece6..e98207d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1345,50 +1345,6 @@ reject_redirect:
 	;
 }
 
-/* called in rcu_read_lock() section */
-void ip_rt_redirect(struct sk_buff *skb, __be32 new_gw)
-{
-	const struct iphdr *iph = (const struct iphdr *) skb->data;
-	__be32 daddr = iph->daddr;
-	__be32 saddr = iph->saddr;
-	struct net_device *dev = skb->dev;
-	int    ikeys[2] = { dev->ifindex, 0 };
-	__be32 skeys[2] = { saddr, 0 };
-	struct net *net;
-	int s, i;
-
-	net = dev_net(dev);
-	for (s = 0; s < 2; s++) {
-		for (i = 0; i < 2; i++) {
-			unsigned int hash;
-			struct rtable __rcu **rthp;
-			struct rtable *rt;
-
-			hash = rt_hash(daddr, skeys[s], ikeys[i], rt_genid(net));
-
-			rthp = &rt_hash_table[hash].chain;
-
-			while ((rt = rcu_dereference(*rthp)) != NULL) {
-				rthp = &rt->dst.rt_next;
-
-				if (rt->rt_key_dst != daddr ||
-				    rt->rt_key_src != skeys[s] ||
-				    rt->rt_oif != ikeys[i] ||
-				    rt_is_input_route(rt) ||
-				    rt_is_expired(rt) ||
-				    !net_eq(dev_net(rt->dst.dev), net) ||
-				    rt->dst.error ||
-				    rt->dst.dev != dev)
-					continue;
-
-				ip_do_redirect(&rt->dst, skb);
-			}
-		}
-	}
-	return;
-
-}
-
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *)dst;
-- 
1.7.10.4
