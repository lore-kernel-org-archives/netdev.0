From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fib_hash: embed initial hash table in fn_zone
Date: Thu, 14 Oct 2010 18:24:18 +0200
Message-ID: <1287073458.2712.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48099 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab0JNQYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 12:24:23 -0400
Received: by wyb28 with SMTP id 28so2282973wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 09:24:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking for false sharing problems, I noticed 
sizeof(struct fn_zone) was small (28 bytes) and possibly sharing a cache
line with an often written kernel structure.

Most of the time, fn_zone uses its initial hash table of 16 slots.

We can avoid the false sharing problem by embedding this initial hash
table in fn_zone itself, so that sizeof(fn_zone) > L1_CACHE_BYTES

We did a similar optimization in commit a6501e080c (Reduce memory needs
and speedup lookups)

Add a fz_revorder field to speedup fn_hash() a bit.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_hash.c |   50 ++++++++++++++++++------------------------
 1 files changed, 22 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 83cca68..0e14dbd 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -54,23 +54,23 @@ struct fib_node {
 	struct fib_alias        fn_embedded_alias;
 };
 
+#define EMBEDDED_HASH_SIZE (L1_CACHE_BYTES / sizeof(struct hlist_head))
+
 struct fn_zone {
 	struct fn_zone		*fz_next;	/* Next not empty zone	*/
 	struct hlist_head	*fz_hash;	/* Hash table pointer	*/
-	int			fz_nent;	/* Number of entries	*/
-
-	int			fz_divisor;	/* Hash divisor		*/
 	u32			fz_hashmask;	/* (fz_divisor - 1)	*/
-#define FZ_HASHMASK(fz)		((fz)->fz_hashmask)
 
-	int			fz_order;	/* Zone order		*/
-	__be32			fz_mask;
+	u8			fz_order;	/* Zone order (0..32)	*/
+	u8			fz_revorder;	/* 32 - fz_order	*/
+	__be32			fz_mask;	/* inet_make_mask(order) */
 #define FZ_MASK(fz)		((fz)->fz_mask)
-};
 
-/* NOTE. On fast computers evaluation of fz_hashmask and fz_mask
- * can be cheaper than memory lookup, so that FZ_* macros are used.
- */
+	struct hlist_head	fz_embedded_hash[EMBEDDED_HASH_SIZE];
+
+	int			fz_nent;	/* Number of entries	*/
+	int			fz_divisor;	/* Hash size (mask+1)	*/
+};
 
 struct fn_hash {
 	struct fn_zone	*fn_zones[33];
@@ -79,11 +79,11 @@ struct fn_hash {
 
 static inline u32 fn_hash(__be32 key, struct fn_zone *fz)
 {
-	u32 h = ntohl(key)>>(32 - fz->fz_order);
+	u32 h = ntohl(key) >> fz->fz_revorder;
 	h ^= (h>>20);
 	h ^= (h>>10);
 	h ^= (h>>5);
-	h &= FZ_HASHMASK(fz);
+	h &= fz->fz_hashmask;
 	return h;
 }
 
@@ -150,11 +150,11 @@ static void fn_rehash_zone(struct fn_zone *fz)
 	old_divisor = fz->fz_divisor;
 
 	switch (old_divisor) {
-	case 16:
-		new_divisor = 256;
+	case EMBEDDED_HASH_SIZE:
+		new_divisor *= EMBEDDED_HASH_SIZE;
 		break;
-	case 256:
-		new_divisor = 1024;
+	case EMBEDDED_HASH_SIZE*EMBEDDED_HASH_SIZE:
+		new_divisor *= (EMBEDDED_HASH_SIZE/2);
 		break;
 	default:
 		if ((old_divisor << 1) > FZ_MAX_DIVISOR) {
@@ -184,7 +184,8 @@ static void fn_rehash_zone(struct fn_zone *fz)
 		fib_hash_genid++;
 		write_unlock_bh(&fib_hash_lock);
 
-		fz_hash_free(old_ht, old_divisor);
+		if (old_ht != fz->fz_embedded_hash)
+			fz_hash_free(old_ht, old_divisor);
 	}
 }
 
@@ -210,18 +211,11 @@ fn_new_zone(struct fn_hash *table, int z)
 	if (!fz)
 		return NULL;
 
-	if (z) {
-		fz->fz_divisor = 16;
-	} else {
-		fz->fz_divisor = 1;
-	}
-	fz->fz_hashmask = (fz->fz_divisor - 1);
-	fz->fz_hash = fz_hash_alloc(fz->fz_divisor);
-	if (!fz->fz_hash) {
-		kfree(fz);
-		return NULL;
-	}
+	fz->fz_divisor = z ? EMBEDDED_HASH_SIZE : 1;
+	fz->fz_hashmask = fz->fz_divisor - 1;
+	fz->fz_hash = fz->fz_embedded_hash;
 	fz->fz_order = z;
+	fz->fz_revorder = 32 - z;
 	fz->fz_mask = inet_make_mask(z);
 
 	/* Find the first not empty zone with more specific mask */


