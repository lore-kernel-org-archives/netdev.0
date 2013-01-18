From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6: Remove unused neigh argument for icmp6_dst_alloc()
 and its callers.
Date: Fri, 18 Jan 2013 21:00:24 +0900
Message-ID: <50F93958.6080603@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45588 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750980Ab3ARMA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 07:00:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because of rt->n removal, we do not need neigh argument any more.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_route.h |    1 -
 net/ipv6/mcast.c        |    4 ++--
 net/ipv6/ndisc.c        |   15 +++++----------
 net/ipv6/route.c        |    1 -
 4 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 30cbb15..260f83f 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -103,7 +103,6 @@ extern struct rt6_info		*rt6_lookup(struct net *net,
 					    int oif, int flags);
 
 extern struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
-					 struct neighbour *neigh,
 					 struct flowi6 *fl6);
 extern int icmp6_dst_gc(void);
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8237ee1..587a845 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1391,7 +1391,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	icmpv6_flow_init(net->ipv6.igmp_sk, &fl6, ICMPV6_MLD2_REPORT,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
-	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
+	dst = icmp6_dst_alloc(skb->dev, &fl6);
 
 	err = 0;
 	if (IS_ERR(dst)) {
@@ -1759,7 +1759,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	icmpv6_flow_init(sk, &fl6, type,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
-	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
+	dst = icmp6_dst_alloc(skb->dev, &fl6);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto err_out;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5733cd2..429622d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -432,7 +432,6 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 }
 
 static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
-			   struct neighbour *neigh,
 			   const struct in6_addr *daddr,
 			   const struct in6_addr *saddr,
 			   struct icmp6hdr *icmp6h)
@@ -448,7 +447,7 @@ static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
 	type = icmp6h->icmp6_type;
 
 	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-	dst = icmp6_dst_alloc(dev, neigh, &fl6);
+	dst = icmp6_dst_alloc(dev, &fl6);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
@@ -474,7 +473,6 @@ static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
  *	Send a Neighbour Discover packet
  */
 static void __ndisc_send(struct net_device *dev,
-			 struct neighbour *neigh,
 			 const struct in6_addr *daddr,
 			 const struct in6_addr *saddr,
 			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
@@ -486,7 +484,7 @@ static void __ndisc_send(struct net_device *dev,
 	if (!skb)
 		return;
 
-	ndisc_send_skb(skb, dev, neigh, daddr, saddr, icmp6h);
+	ndisc_send_skb(skb, dev, daddr, saddr, icmp6h);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
@@ -521,8 +519,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	__ndisc_send(dev, neigh, daddr, src_addr,
-		     &icmp6h, solicited_addr,
+	__ndisc_send(dev, daddr, src_addr, &icmp6h, solicited_addr,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
 }
 
@@ -563,8 +560,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	__ndisc_send(dev, neigh, daddr, saddr,
-		     &icmp6h, solicit,
+	__ndisc_send(dev, daddr, saddr, &icmp6h, solicit,
 		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
@@ -598,8 +594,7 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	__ndisc_send(dev, NULL, daddr, saddr,
-		     &icmp6h, NULL,
+	__ndisc_send(dev, daddr, saddr, &icmp6h, NULL,
 		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3a562a1..2d94d5a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1203,7 +1203,6 @@ static struct dst_entry *icmp6_dst_gc_list;
 static DEFINE_SPINLOCK(icmp6_dst_lock);
 
 struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
-				  struct neighbour *neigh,
 				  struct flowi6 *fl6)
 {
 	struct dst_entry *dst;
-- 
1.7.9.5
