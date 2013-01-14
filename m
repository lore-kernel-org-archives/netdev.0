From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next] ipv6: look up neighbours on demand in ip6_finish_output2()
Date: Mon, 14 Jan 2013 21:35:15 +0800
Message-ID: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Roland Dreier <roland@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:36490 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051Ab3ANNfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 08:35:36 -0500
Received: by mail-pb0-f51.google.com with SMTP id ro12so2158943pbb.24
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 05:35:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Roland reported that we may use a "stray" neigh entry if someone else
holds a refcount of this entry. Therefore leads to neigh_blackhole().

And David said:

"Another reason we must make ipv6 like ipv4, which looks up neighbours
on demand at packet output time rather than caching them in the route
entries."

Thus, we just follow what IPv4 does, call __ipv6_neigh_lookup_noref()
to avoid using the "stray" neighbour.

Roland, could you test if this could fix your problem? I don't
have the environment.

Reported-by: Roland Dreier <roland@purestorage.com>
Cc: Roland Dreier <roland@purestorage.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 23b3a7c..a5fe1b3 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -148,14 +148,16 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 		(p32[3] * hash_rnd[3]));
 }
 
-static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const void *pkey)
+static inline
+struct neighbour *__ipv6_neigh_lookup_noref(struct neigh_table *tbl,
+					    struct net_device *dev,
+					    const void *pkey)
 {
 	struct neigh_hash_table *nht;
 	const u32 *p32 = pkey;
 	struct neighbour *n;
 	u32 hash_val;
 
-	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(tbl->nht);
 	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
@@ -165,11 +167,23 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, str
 		if (n->dev == dev &&
 		    ((n32[0] ^ p32[0]) | (n32[1] ^ p32[1]) |
 		     (n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0) {
-			if (!atomic_inc_not_zero(&n->refcnt))
-				n = NULL;
 			break;
 		}
 	}
+
+	return n;
+}
+
+static inline
+struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl,
+				      struct net_device *dev, const void *pkey)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv6_neigh_lookup_noref(tbl, dev, pkey);
+	if (n && (!atomic_inc_not_zero(&n->refcnt)))
+		n = NULL;
 	rcu_read_unlock_bh();
 
 	return n;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9250c69..20f2e86 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -89,11 +89,12 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	struct net_device *dev = dst->dev;
 	struct neighbour *neigh;
 	struct rt6_info *rt;
+	const void *daddr = &ipv6_hdr(skb)->daddr;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
 
-	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
+	if (ipv6_addr_is_multicast(daddr)) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(skb->sk) &&
@@ -124,9 +125,17 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	}
 
 	rt = (struct rt6_info *) dst;
-	neigh = rt->n;
-	if (neigh)
+	rcu_read_lock_bh();
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		daddr = &rt->rt6i_gateway;
+	neigh = __ipv6_neigh_lookup_noref(&nd_tbl, dev, daddr);
+	if (unlikely(!neigh))
+		neigh = __neigh_create(&nd_tbl, daddr, dev, false);
+	if (!IS_ERR(neigh)) {
+		rcu_read_unlock_bh();
 		return dst_neigh_output(dst, neigh, skb);
+	}
+	rcu_read_unlock_bh();
 
 	IP6_INC_STATS_BH(dev_net(dst->dev),
 			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
