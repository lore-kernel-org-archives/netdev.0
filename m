From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 02/11] ndisc: Remove tbl argument for __ipv6_neigh_lookup().
Date: Fri, 18 Jan 2013 07:53:09 +0900
Message-ID: <50F880D5.2000003@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44752 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754318Ab3AQWxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:53:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can refer to nd_tbl directly.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |    4 ++--
 net/ipv6/route.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 23b3a7c..bbc938e 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -148,7 +148,7 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 		(p32[3] * hash_rnd[3]));
 }
 
-static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const void *pkey)
+static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, const void *pkey)
 {
 	struct neigh_hash_table *nht;
 	const u32 *p32 = pkey;
@@ -156,7 +156,7 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, str
 	u32 hash_val;
 
 	rcu_read_lock_bh();
-	nht = rcu_dereference_bh(tbl->nht);
+	nht = rcu_dereference_bh(nd_tbl.nht);
 	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1341f68..5d9ca27 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -145,7 +145,7 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 	struct neighbour *n;
 
 	daddr = choose_neigh_daddr(rt, skb, daddr);
-	n = __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
+	n = __ipv6_neigh_lookup(dst->dev, daddr);
 	if (n)
 		return n;
 	return neigh_create(&nd_tbl, daddr, dst->dev);
@@ -153,7 +153,7 @@ static struct neighbour *ip6_neigh_lookup(const struct dst_entry *dst,
 
 static int rt6_bind_neighbour(struct rt6_info *rt, struct net_device *dev)
 {
-	struct neighbour *n = __ipv6_neigh_lookup(&nd_tbl, dev, &rt->rt6i_gateway);
+	struct neighbour *n = __ipv6_neigh_lookup(dev, &rt->rt6i_gateway);
 	if (!n) {
 		n = neigh_create(&nd_tbl, &rt->rt6i_gateway, dev);
 		if (IS_ERR(n))
-- 
1.7.9.5
