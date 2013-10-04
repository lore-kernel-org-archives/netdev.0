From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/33] netfilter: ipset: Support extensions which need a per data destroy function
Date: Fri,  4 Oct 2013 10:33:02 +0200
Message-ID: <1380875598-5250-18-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h  |   22 +++++++---
 net/netfilter/ipset/ip_set_bitmap_gen.h |   38 ++++++++++++++---
 net/netfilter/ipset/ip_set_hash_gen.h   |   71 ++++++++++++++++++++-----------
 net/netfilter/ipset/ip_set_list_set.c   |   19 ++++++---
 4 files changed, 107 insertions(+), 43 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 66d6bd4..6372ee2 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -49,11 +49,13 @@ enum ip_set_feature {
 
 /* Set extensions */
 enum ip_set_extension {
-	IPSET_EXT_NONE = 0,
-	IPSET_EXT_BIT_TIMEOUT = 1,
+	IPSET_EXT_BIT_TIMEOUT = 0,
 	IPSET_EXT_TIMEOUT = (1 << IPSET_EXT_BIT_TIMEOUT),
-	IPSET_EXT_BIT_COUNTER = 2,
+	IPSET_EXT_BIT_COUNTER = 1,
 	IPSET_EXT_COUNTER = (1 << IPSET_EXT_BIT_COUNTER),
+	/* Mark set with an extension which needs to call destroy */
+	IPSET_EXT_BIT_DESTROY = 7,
+	IPSET_EXT_DESTROY = (1 << IPSET_EXT_BIT_DESTROY),
 };
 
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
@@ -68,6 +70,8 @@ enum ip_set_ext_id {
 
 /* Extension type */
 struct ip_set_ext_type {
+	/* Destroy extension private data (can be NULL) */
+	void (*destroy)(void *ext);
 	enum ip_set_extension type;
 	enum ipset_cadt_flags flag;
 	/* Size and minimal alignment */
@@ -88,13 +92,21 @@ struct ip_set_counter {
 	atomic64_t packets;
 };
 
+struct ip_set;
+
+static inline void
+ip_set_ext_destroy(struct ip_set *set, void *data)
+{
+	/* Check that the extension is enabled for the set and
+	 * call it's destroy function for its extension part in data.
+	 */
+}
+
 #define ext_timeout(e, s)	\
 (unsigned long *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_TIMEOUT])
 #define ext_counter(e, s)	\
 (struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER])
 
-struct ip_set;
-
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   const struct ip_set_ext *ext,
 			   struct ip_set_ext *mext, u32 cmdflags);
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index f32ddbc..4515fe8 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -12,6 +12,7 @@
 #define mtype_gc_test		IPSET_TOKEN(MTYPE, _gc_test)
 #define mtype_is_filled		IPSET_TOKEN(MTYPE, _is_filled)
 #define mtype_do_add		IPSET_TOKEN(MTYPE, _do_add)
+#define mtype_ext_cleanup	IPSET_TOKEN(MTYPE, _ext_cleanup)
 #define mtype_do_del		IPSET_TOKEN(MTYPE, _do_del)
 #define mtype_do_list		IPSET_TOKEN(MTYPE, _do_list)
 #define mtype_do_head		IPSET_TOKEN(MTYPE, _do_head)
@@ -47,6 +48,17 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 }
 
 static void
+mtype_ext_cleanup(struct ip_set *set)
+{
+	struct mtype *map = set->data;
+	u32 id;
+
+	for (id = 0; id < map->elements; id++)
+		if (test_bit(id, map->members))
+			ip_set_ext_destroy(set, get_ext(set, map, id));
+}
+
+static void
 mtype_destroy(struct ip_set *set)
 {
 	struct mtype *map = set->data;
@@ -55,8 +67,11 @@ mtype_destroy(struct ip_set *set)
 		del_timer_sync(&map->gc);
 
 	ip_set_free(map->members);
-	if (set->dsize)
+	if (set->dsize) {
+		if (set->extensions & IPSET_EXT_DESTROY)
+			mtype_ext_cleanup(set);
 		ip_set_free(map->extensions);
+	}
 	kfree(map);
 
 	set->data = NULL;
@@ -67,6 +82,8 @@ mtype_flush(struct ip_set *set)
 {
 	struct mtype *map = set->data;
 
+	if (set->extensions & IPSET_EXT_DESTROY)
+		mtype_ext_cleanup(set);
 	memset(map->members, 0, map->memsize);
 }
 
@@ -132,6 +149,8 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			ret = 0;
 		else if (!(flags & IPSET_FLAG_EXIST))
 			return -IPSET_ERR_EXIST;
+		/* Element is re-added, cleanup extensions */
+		ip_set_ext_destroy(set, x);
 	}
 
 	if (SET_WITH_TIMEOUT(set))
@@ -152,11 +171,14 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct mtype *map = set->data;
 	const struct mtype_adt_elem *e = value;
-	const void *x = get_ext(set, map, e->id);
+	void *x = get_ext(set, map, e->id);
 
-	if (mtype_do_del(e, map) ||
-	    (SET_WITH_TIMEOUT(set) &&
-	     ip_set_timeout_expired(ext_timeout(x, set))))
+	if (mtype_do_del(e, map))
+		return -IPSET_ERR_EXIST;
+
+	ip_set_ext_destroy(set, x);
+	if (SET_WITH_TIMEOUT(set) &&
+	    ip_set_timeout_expired(ext_timeout(x, set)))
 		return -IPSET_ERR_EXIST;
 
 	return 0;
@@ -235,7 +257,7 @@ mtype_gc(unsigned long ul_set)
 {
 	struct ip_set *set = (struct ip_set *) ul_set;
 	struct mtype *map = set->data;
-	const void *x;
+	void *x;
 	u32 id;
 
 	/* We run parallel with other readers (test element)
@@ -244,8 +266,10 @@ mtype_gc(unsigned long ul_set)
 	for (id = 0; id < map->elements; id++)
 		if (mtype_gc_test(id, map, set->dsize)) {
 			x = get_ext(set, map, id);
-			if (ip_set_timeout_expired(ext_timeout(x, set)))
+			if (ip_set_timeout_expired(ext_timeout(x, set))) {
 				clear_bit(id, map->members);
+				ip_set_ext_destroy(set, x);
+			}
 		}
 	read_unlock_bh(&set->lock);
 
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 3999f17..3c26e5b 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -117,23 +117,6 @@ htable_bits(u32 hashsize)
 	return bits;
 }
 
-/* Destroy the hashtable part of the set */
-static void
-ahash_destroy(struct htable *t)
-{
-	struct hbucket *n;
-	u32 i;
-
-	for (i = 0; i < jhash_size(t->htable_bits); i++) {
-		n = hbucket(t, i);
-		if (n->size)
-			/* FIXME: use slab cache */
-			kfree(n->value);
-	}
-
-	ip_set_free(t);
-}
-
 static int
 hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 {
@@ -192,6 +175,8 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #undef mtype_data_next
 #undef mtype_elem
 
+#undef mtype_ahash_destroy
+#undef mtype_ext_cleanup
 #undef mtype_add_cidr
 #undef mtype_del_cidr
 #undef mtype_ahash_memsize
@@ -230,6 +215,8 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_data_list		IPSET_TOKEN(MTYPE, _data_list)
 #define mtype_data_next		IPSET_TOKEN(MTYPE, _data_next)
 #define mtype_elem		IPSET_TOKEN(MTYPE, _elem)
+#define mtype_ahash_destroy	IPSET_TOKEN(MTYPE, _ahash_destroy)
+#define mtype_ext_cleanup	IPSET_TOKEN(MTYPE, _ext_cleanup)
 #define mtype_add_cidr		IPSET_TOKEN(MTYPE, _add_cidr)
 #define mtype_del_cidr		IPSET_TOKEN(MTYPE, _del_cidr)
 #define mtype_ahash_memsize	IPSET_TOKEN(MTYPE, _ahash_memsize)
@@ -359,6 +346,19 @@ mtype_ahash_memsize(const struct htype *h, const struct htable *t,
 	return memsize;
 }
 
+/* Get the ith element from the array block n */
+#define ahash_data(n, i, dsize)	\
+	((struct mtype_elem *)((n)->value + ((i) * (dsize))))
+
+static void
+mtype_ext_cleanup(struct ip_set *set, struct hbucket *n)
+{
+	int i;
+
+	for (i = 0; i < n->pos; i++)
+		ip_set_ext_destroy(set, ahash_data(n, i, set->dsize));
+}
+
 /* Flush a hash type of set: destroy all elements */
 static void
 mtype_flush(struct ip_set *set)
@@ -372,6 +372,8 @@ mtype_flush(struct ip_set *set)
 	for (i = 0; i < jhash_size(t->htable_bits); i++) {
 		n = hbucket(t, i);
 		if (n->size) {
+			if (set->extensions & IPSET_EXT_DESTROY)
+				mtype_ext_cleanup(set, n);
 			n->size = n->pos = 0;
 			/* FIXME: use slab cache */
 			kfree(n->value);
@@ -383,6 +385,26 @@ mtype_flush(struct ip_set *set)
 	h->elements = 0;
 }
 
+/* Destroy the hashtable part of the set */
+static void
+mtype_ahash_destroy(struct ip_set *set, struct htable *t)
+{
+	struct hbucket *n;
+	u32 i;
+
+	for (i = 0; i < jhash_size(t->htable_bits); i++) {
+		n = hbucket(t, i);
+		if (n->size) {
+			if (set->extensions & IPSET_EXT_DESTROY)
+				mtype_ext_cleanup(set, n);
+			/* FIXME: use slab cache */
+			kfree(n->value);
+		}
+	}
+
+	ip_set_free(t);
+}
+
 /* Destroy a hash type of set */
 static void
 mtype_destroy(struct ip_set *set)
@@ -392,7 +414,7 @@ mtype_destroy(struct ip_set *set)
 	if (set->extensions & IPSET_EXT_TIMEOUT)
 		del_timer_sync(&h->gc);
 
-	ahash_destroy(rcu_dereference_bh_nfnl(h->table));
+	mtype_ahash_destroy(set, rcu_dereference_bh_nfnl(h->table));
 #ifdef IP_SET_HASH_WITH_RBTREE
 	rbtree_destroy(&h->rbtree);
 #endif
@@ -430,10 +452,6 @@ mtype_same_set(const struct ip_set *a, const struct ip_set *b)
 	       a->extensions == b->extensions;
 }
 
-/* Get the ith element from the array block n */
-#define ahash_data(n, i, dsize)	\
-	((struct mtype_elem *)((n)->value + ((i) * (dsize))))
-
 /* Delete expired elements from the hashtable */
 static void
 mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
@@ -456,6 +474,7 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 				mtype_del_cidr(h, CIDR(data->cidr),
 					       nets_length, 0);
 #endif
+				ip_set_ext_destroy(set, data);
 				if (j != n->pos - 1)
 					/* Not last one */
 					memcpy(data,
@@ -557,7 +576,7 @@ retry:
 				mtype_data_reset_flags(data, &flags);
 #endif
 				read_unlock_bh(&set->lock);
-				ahash_destroy(t);
+				mtype_ahash_destroy(set, t);
 				if (ret == -EAGAIN)
 					goto retry;
 				return ret;
@@ -578,7 +597,7 @@ retry:
 
 	pr_debug("set %s resized from %u (%p) to %u (%p)\n", set->name,
 		 orig->htable_bits, orig, t->htable_bits, t);
-	ahash_destroy(orig);
+	mtype_ahash_destroy(set, orig);
 
 	return 0;
 }
@@ -642,6 +661,7 @@ reuse_slot:
 		mtype_del_cidr(h, CIDR(data->cidr), NLEN(set->family), 0);
 		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
+		ip_set_ext_destroy(set, data);
 	} else {
 		/* Use/create a new slot */
 		TUNE_AHASH_MAX(h, multi);
@@ -707,6 +727,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 #ifdef IP_SET_HASH_WITH_NETS
 		mtype_del_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
+		ip_set_ext_destroy(set, data);
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
 					    * set->dsize,
@@ -1033,7 +1054,7 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	rcu_assign_pointer(h->table, t);
 
 	set->data = h;
-	if (set->family ==  NFPROTO_IPV4) {
+	if (set->family == NFPROTO_IPV4) {
 		set->variant = &IPSET_TOKEN(HTYPE, 4_variant);
 		set->dsize = ip_set_elem_len(set, tb,
 				sizeof(struct IPSET_TOKEN(HTYPE, 4_elem)));
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 7fd11c7..e44986a 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -168,16 +168,19 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 	struct set_elem *e = list_set_elem(set, map, i);
 
 	if (e->id != IPSET_INVALID_ID) {
-		if (i == map->size - 1)
+		if (i == map->size - 1) {
 			/* Last element replaced: e.g. add new,before,last */
 			ip_set_put_byindex(e->id);
-		else {
+			ip_set_ext_destroy(set, e);
+		} else {
 			struct set_elem *x = list_set_elem(set, map,
 							   map->size - 1);
 
 			/* Last element pushed off */
-			if (x->id != IPSET_INVALID_ID)
+			if (x->id != IPSET_INVALID_ID) {
 				ip_set_put_byindex(x->id);
+				ip_set_ext_destroy(set, x);
+			}
 			memmove(list_set_elem(set, map, i + 1), e,
 				set->dsize * (map->size - (i + 1)));
 		}
@@ -198,6 +201,7 @@ list_set_del(struct ip_set *set, u32 i)
 	struct set_elem *e = list_set_elem(set, map, i);
 
 	ip_set_put_byindex(e->id);
+	ip_set_ext_destroy(set, e);
 
 	if (i < map->size - 1)
 		memmove(e, list_set_elem(set, map, i + 1),
@@ -266,14 +270,14 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
 	u32 i, ret = 0;
 
+	if (SET_WITH_TIMEOUT(set))
+		set_cleanup_entries(set);
+
 	/* Check already added element */
 	for (i = 0; i < map->size; i++) {
 		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			goto insert;
-		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, set)))
-			continue;
 		else if (e->id != d->id)
 			continue;
 
@@ -286,6 +290,8 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			/* Can't re-add */
 			return -IPSET_ERR_EXIST;
 		/* Update extensions */
+		ip_set_ext_destroy(set, e);
+
 		if (SET_WITH_TIMEOUT(set))
 			ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 		if (SET_WITH_COUNTER(set))
@@ -423,6 +429,7 @@ list_set_flush(struct ip_set *set)
 		e = list_set_elem(set, map, i);
 		if (e->id != IPSET_INVALID_ID) {
 			ip_set_put_byindex(e->id);
+			ip_set_ext_destroy(set, e);
 			e->id = IPSET_INVALID_ID;
 		}
 	}
-- 
1.7.10.4

