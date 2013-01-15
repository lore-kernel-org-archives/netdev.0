From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 03/13] ndisc: Introduce __ipv6_neigh_lookup_noref().
Date: Wed, 16 Jan 2013 01:44:53 +0900
Message-ID: <50F58785.6010208@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41300 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756066Ab3AOQoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:44:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index bbc938e..ec48f42 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -148,14 +148,13 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
 		(p32[3] * hash_rnd[3]));
 }
 
-static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, const void *pkey)
+static inline struct neighbour *__ipv6_neigh_lookup_noref(struct net_device *dev, const void *pkey)
 {
 	struct neigh_hash_table *nht;
 	const u32 *p32 = pkey;
 	struct neighbour *n;
 	u32 hash_val;
 
-	rcu_read_lock_bh();
 	nht = rcu_dereference_bh(nd_tbl.nht);
 	hash_val = ndisc_hashfn(pkey, dev, nht->hash_rnd) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
@@ -164,12 +163,21 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 		u32 *n32 = (u32 *) n->primary_key;
 		if (n->dev == dev &&
 		    ((n32[0] ^ p32[0]) | (n32[1] ^ p32[1]) |
-		     (n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0) {
-			if (!atomic_inc_not_zero(&n->refcnt))
-				n = NULL;
-			break;
-		}
+		     (n32[2] ^ p32[2]) | (n32[3] ^ p32[3])) == 0)
+			return n;
 	}
+
+	return NULL;
+}
+
+static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, const void *pkey)
+{
+	struct neighbour *n;
+
+	rcu_read_lock_bh();
+	n = __ipv6_neigh_lookup_noref(dev, pkey);
+	if (n && !atomic_inc_not_zero(&n->refcnt))
+		n = NULL;
 	rcu_read_unlock_bh();
 
 	return n;
-- 
1.7.9.5
