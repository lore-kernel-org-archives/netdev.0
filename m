From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3.17 .. v3.19] lib/rhashtable: fix race between
 rhashtable_lookup_compare and hashtable resize
Date: Fri, 26 Jun 2015 13:48:17 +0300
Message-ID: <20150626104817.16520.77222.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stable <stable@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1o.mail.yandex.net ([37.140.190.172]:47415 "EHLO
	forward-corp1o.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbbFZK4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 06:56:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hash value passed as argument into rhashtable_lookup_compare could be
computed using different hash table than rhashtable_lookup_compare sees.

This patch passes key into rhashtable_lookup_compare() instead of hash and
compures hash value right in place using the same table as for lookup.

Also it adds comment for rhashtable_hashfn and rhashtable_obj_hashfn:
user must prevent concurrent insert/remove otherwise returned hash value
could be invalid.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
Link: http://lkml.kernel.org/r/20150514042151.GA5482@gondor.apana.org.au
Cc: Stable <stable@vger.kernel.org> (v3.17 .. v3.19)
---
 include/linux/rhashtable.h |    2 +-
 lib/rhashtable.c           |   12 ++++++++----
 net/netlink/af_netlink.c   |    5 +----
 3 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index fb298e9d6d3a..84056743780a 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -108,7 +108,7 @@ int rhashtable_expand(struct rhashtable *ht, gfp_t flags);
 int rhashtable_shrink(struct rhashtable *ht, gfp_t flags);
 
 void *rhashtable_lookup(const struct rhashtable *ht, const void *key);
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, void *key,
 				bool (*compare)(void *, void *), void *arg);
 
 void rhashtable_destroy(const struct rhashtable *ht);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 624a0b7c05ef..cb22073fe687 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -61,6 +61,8 @@ static u32 __hashfn(const struct rhashtable *ht, const void *key,
  * Computes the hash value using the hash function provided in the 'hashfn'
  * of struct rhashtable_params. The returned value is guaranteed to be
  * smaller than the number of buckets in the hash table.
+ *
+ * The caller must ensure that no concurrent table mutations occur.
  */
 u32 rhashtable_hashfn(const struct rhashtable *ht, const void *key, u32 len)
 {
@@ -92,6 +94,8 @@ static u32 obj_hashfn(const struct rhashtable *ht, const void *ptr, u32 hsize)
  * 'obj_hashfn' depending on whether the hash table is set up to work with
  * a fixed length key. The returned value is guaranteed to be smaller than
  * the number of buckets in the hash table.
+ *
+ * The caller must ensure that no concurrent table mutations occur.
  */
 u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr)
 {
@@ -474,7 +478,7 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
 /**
  * rhashtable_lookup_compare - search hash table with compare function
  * @ht:		hash table
- * @hash:	hash value of desired entry
+ * @key:	pointer to key
  * @compare:	compare function, must return true on match
  * @arg:	argument passed on to compare function
  *
@@ -486,14 +490,14 @@ EXPORT_SYMBOL_GPL(rhashtable_lookup);
  *
  * Returns the first entry on which the compare function returned true.
  */
-void *rhashtable_lookup_compare(const struct rhashtable *ht, u32 hash,
+void *rhashtable_lookup_compare(const struct rhashtable *ht, void *key,
 				bool (*compare)(void *, void *), void *arg)
 {
 	const struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	struct rhash_head *he;
+	u32 hash;
 
-	if (unlikely(hash >= tbl->size))
-		return NULL;
+	hash = __hashfn(ht, key, ht->p.key_len, tbl->size);
 
 	rht_for_each_rcu(he, tbl->buckets[hash], ht) {
 		if (!compare(rht_obj(ht, he), arg))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c0a418766f9c..c82b2e37e652 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1003,11 +1003,8 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 		.net = net,
 		.portid = portid,
 	};
-	u32 hash;
 
-	hash = rhashtable_hashfn(&table->hash, &portid, sizeof(portid));
-
-	return rhashtable_lookup_compare(&table->hash, hash,
+	return rhashtable_lookup_compare(&table->hash, &portid,
 					 &netlink_compare, &arg);
 }
 
