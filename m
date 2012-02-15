From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Eliminate spurious argument to __ipv4_neigh_lookup
Date: Wed, 15 Feb 2012 17:55:46 -0500 (EST)
Message-ID: <20120215.175546.1765200851698890734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab2BOWzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 17:55:48 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q1FMtk6F030933
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 14:55:47 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


'tbl' is always arp_tbl, so specifying it is pointless.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h |    4 ++--
 net/ipv4/route.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 0013dc8..4a1f3fb 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -15,14 +15,14 @@ static inline u32 arp_hashfn(u32 key, const struct net_device *dev, u32 hash_rnd
 	return val * hash_rnd;
 }
 
-static inline struct neighbour *__ipv4_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, u32 key)
+static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32 key)
 {
 	struct neigh_hash_table *nht;
 	struct neighbour *n;
 	u32 hash_val;
 
 	rcu_read_lock_bh();
-	nht = rcu_dereference_bh(tbl->nht);
+	nht = rcu_dereference_bh(arp_tbl.nht);
 	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4eeb8ce..0489ced 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1127,7 +1127,7 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst, const vo
 	else if (rt->rt_gateway)
 		pkey = (const __be32 *) &rt->rt_gateway;
 
-	n = __ipv4_neigh_lookup(&arp_tbl, dev, *(__force u32 *)pkey);
+	n = __ipv4_neigh_lookup(dev, *(__force u32 *)pkey);
 	if (n)
 		return n;
 	return neigh_create(&arp_tbl, pkey, dev);
-- 
1.7.7.6
