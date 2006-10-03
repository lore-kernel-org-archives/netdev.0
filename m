From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] neigh: always use hash_mask under tbl lock
Date: Tue, 3 Oct 2006 03:05:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0610030124220.3580@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:18187 "EHLO u.domain.uli")
	by vger.kernel.org with ESMTP id S965536AbWJCADL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 20:03:11 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Make sure hash_mask is protected with tbl->lock in all
cases just like the hash_buckets.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
	I just noticed this in sources. Let me know if such change
is valid and desired for 2.4 or stable tree. Compiles on 2.6.18 and
2.6.18-git18.

diff -urp v2.6.18-git18/linux/net/core/neighbour.c linux/net/core/neighbour.c
--- v2.6.18-git18/linux/net/core/neighbour.c	2006-10-03 01:50:15.000000000 +0300
+++ linux/net/core/neighbour.c	2006-10-03 01:50:32.000000000 +0300
@@ -344,12 +344,12 @@ struct neighbour *neigh_lookup(struct ne
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
+	u32 hash_val = tbl->hash(pkey, dev);

 	NEIGH_CACHE_STAT_INC(tbl, lookups);

 	read_lock_bh(&tbl->lock);
-	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
 		if (dev == n->dev && !memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -364,12 +364,12 @@ struct neighbour *neigh_lookup_nodev(str
 {
 	struct neighbour *n;
 	int key_len = tbl->key_len;
-	u32 hash_val = tbl->hash(pkey, NULL) & tbl->hash_mask;
+	u32 hash_val = tbl->hash(pkey, NULL);

 	NEIGH_CACHE_STAT_INC(tbl, lookups);

 	read_lock_bh(&tbl->lock);
-	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+	for (n = tbl->hash_buckets[hash_val & tbl->hash_mask]; n; n = n->next) {
 		if (!memcmp(n->primary_key, pkey, key_len)) {
 			neigh_hold(n);
 			NEIGH_CACHE_STAT_INC(tbl, hits);
@@ -1998,12 +1998,12 @@ static int neigh_dump_table(struct neigh
 	int rc, h, s_h = cb->args[1];
 	int idx, s_idx = idx = cb->args[2];

+	read_lock_bh(&tbl->lock);
 	for (h = 0; h <= tbl->hash_mask; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
 			s_idx = 0;
-		read_lock_bh(&tbl->lock);
 		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next, idx++) {
 			if (idx < s_idx)
 				continue;
@@ -2016,8 +2016,8 @@ static int neigh_dump_table(struct neigh
 				goto out;
 			}
 		}
-		read_unlock_bh(&tbl->lock);
 	}
+	read_unlock_bh(&tbl->lock);
 	rc = skb->len;
 out:
 	cb->args[1] = h;

