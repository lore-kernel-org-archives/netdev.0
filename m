From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2 PATCH] rhashtable: Add cap on number of elements in hash table
Date: Fri, 15 May 2015 11:30:47 +0800
Message-ID: <20150515033047.GA15288@gondor.apana.org.au>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <20150513080640.GA27800@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org, kaber@trash.net,
	tgraf@suug.ch, johannes.berg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45347 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423143AbbEODa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 23:30:56 -0400
Content-Disposition: inline
In-Reply-To: <20150513080640.GA27800@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently have no limit on the number of elements in a hash table.
This is a problem because some users (tipc) set a ceiling on the
maximum table size and when that is reached the hash table may
degenerate.  Others may encounter OOM when growing and if we allow
insertions when that happens the hash table perofrmance may also
suffer.

This patch adds a new paramater insecure_max_entries which becomes
the cap on the table.  If unset it defaults to max_size * 2.  If
it is also zero it means that there is no cap on the number of
elements in the table.  However, the table will grow whenever the
utilisation hits 100% and if that growth fails, you will get ENOMEM
on insertion.

As allowing oversubscription is potentially dangerous, the name
contains the word insecure.

Note that the cap is not a hard limit.  This is done for performance
reasons as enforcing a hard limit will result in use of atomic ops
that are heavier than the ones we currently use.

The reasoning is that we're only guarding against a gross over-
subscription of the table, rather than a small breach of the limit.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index dbcbcc5..843ceca 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -17,6 +17,7 @@
 #ifndef _LINUX_RHASHTABLE_H
 #define _LINUX_RHASHTABLE_H
 
+#include <linux/atomic.h>
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/jhash.h>
@@ -100,6 +101,7 @@ struct rhashtable;
  * @key_len: Length of key
  * @key_offset: Offset of key in struct to be hashed
  * @head_offset: Offset of rhash_head in struct to be hashed
+ * @insecure_max_entries: Maximum number of entries (may be exceeded)
  * @max_size: Maximum size while expanding
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
@@ -115,6 +117,7 @@ struct rhashtable_params {
 	size_t			key_len;
 	size_t			key_offset;
 	size_t			head_offset;
+	unsigned int		insecure_max_entries;
 	unsigned int		max_size;
 	unsigned int		min_size;
 	u32			nulls_base;
@@ -286,6 +289,18 @@ static inline bool rht_grow_above_100(const struct rhashtable *ht,
 		(!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
+/**
+ * rht_grow_above_max - returns true if table is above maximum
+ * @ht:		hash table
+ * @tbl:	current table
+ */
+static inline bool rht_grow_above_max(const struct rhashtable *ht,
+				      const struct bucket_table *tbl)
+{
+	return ht->p.insecure_max_entries &&
+	       atomic_read(&ht->nelems) >= ht->p.insecure_max_entries;
+}
+
 /* The bucket lock is selected based on the hash and protects mutations
  * on a group of hash buckets.
  *
@@ -589,6 +604,10 @@ restart:
 		goto out;
 	}
 
+	err = -E2BIG;
+	if (unlikely(rht_grow_above_max(ht, tbl)))
+		goto out;
+
 	if (unlikely(rht_grow_above_100(ht, tbl))) {
 slow_path:
 		spin_unlock_bh(lock);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4936fc4..ca66a0e 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -14,6 +14,7 @@
  * published by the Free Software Foundation.
  */
 
+#include <linux/atomic.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/log2.h>
@@ -446,6 +447,10 @@ int rhashtable_insert_slow(struct rhashtable *ht, const void *key,
 	if (key && rhashtable_lookup_fast(ht, key, ht->p))
 		goto exit;
 
+	err = -E2BIG;
+	if (unlikely(rht_grow_above_max(ht, tbl)))
+		goto exit;
+
 	err = -EAGAIN;
 	if (rhashtable_check_elasticity(ht, tbl, hash) ||
 	    rht_grow_above_100(ht, tbl))
@@ -734,6 +739,12 @@ int rhashtable_init(struct rhashtable *ht,
 	if (params->max_size)
 		ht->p.max_size = rounddown_pow_of_two(params->max_size);
 
+	if (params->insecure_max_entries)
+		ht->p.insecure_max_entries =
+			rounddown_pow_of_two(params->insecure_max_entries);
+	else
+		ht->p.insecure_max_entries = ht->p.max_size * 2;
+
 	ht->p.min_size = max(ht->p.min_size, HASH_MIN_SIZE);
 
 	/* The maximum (not average) chain length grows with the
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
