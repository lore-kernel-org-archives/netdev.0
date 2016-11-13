From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/39] netfilter: ipset: Count non-static extension memory for userspace
Date: Sun, 13 Nov 2016 23:25:20 +0100
Message-ID: <1479075933-4491-27-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47650 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965144AbcKMW0W (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:22 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id ADBECC1060
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 98A33DA848
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:21 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 601C0DA843
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:19 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Non-static (i.e. comment) extension was not counted into the memory
size. A new internal counter is introduced for this. In the case of
the hash types the sizes of the arrays are counted there as well so
that we can avoid to scan the whole set when just the header data
is requested.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         |  8 ++++++--
 include/linux/netfilter/ipset/ip_set_comment.h |  7 +++++--
 net/netfilter/ipset/ip_set_bitmap_gen.h        |  5 +++--
 net/netfilter/ipset/ip_set_core.c              |  2 +-
 net/netfilter/ipset/ip_set_hash_gen.h          | 26 ++++++++++++++------------
 net/netfilter/ipset/ip_set_list_set.c          |  5 +++--
 6 files changed, 32 insertions(+), 21 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 4671d740610f..8e42253e5d4d 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -79,10 +79,12 @@ enum ip_set_ext_id {
 	IPSET_EXT_ID_MAX,
 };
 
+struct ip_set;
+
 /* Extension type */
 struct ip_set_ext_type {
 	/* Destroy extension private data (can be NULL) */
-	void (*destroy)(void *ext);
+	void (*destroy)(struct ip_set *set, void *ext);
 	enum ip_set_extension type;
 	enum ipset_cadt_flags flag;
 	/* Size and minimal alignment */
@@ -252,6 +254,8 @@ struct ip_set {
 	u32 timeout;
 	/* Number of elements (vs timeout) */
 	u32 elements;
+	/* Size of the dynamic extensions (vs timeout) */
+	size_t ext_size;
 	/* Element data size */
 	size_t dsize;
 	/* Offsets to extensions in elements */
@@ -268,7 +272,7 @@ ip_set_ext_destroy(struct ip_set *set, void *data)
 	 */
 	if (SET_WITH_COMMENT(set))
 		ip_set_extensions[IPSET_EXT_ID_COMMENT].destroy(
-			ext_comment(data, set));
+			set, ext_comment(data, set));
 }
 
 static inline int
diff --git a/include/linux/netfilter/ipset/ip_set_comment.h b/include/linux/netfilter/ipset/ip_set_comment.h
index 5444b1bbe656..8e2bab1e8e90 100644
--- a/include/linux/netfilter/ipset/ip_set_comment.h
+++ b/include/linux/netfilter/ipset/ip_set_comment.h
@@ -20,13 +20,14 @@ ip_set_comment_uget(struct nlattr *tb)
  * The kadt functions don't use the comment extensions in any way.
  */
 static inline void
-ip_set_init_comment(struct ip_set_comment *comment,
+ip_set_init_comment(struct ip_set *set, struct ip_set_comment *comment,
 		    const struct ip_set_ext *ext)
 {
 	struct ip_set_comment_rcu *c = rcu_dereference_protected(comment->c, 1);
 	size_t len = ext->comment ? strlen(ext->comment) : 0;
 
 	if (unlikely(c)) {
+		set->ext_size -= sizeof(*c) + strlen(c->str) + 1;
 		kfree_rcu(c, rcu);
 		rcu_assign_pointer(comment->c, NULL);
 	}
@@ -38,6 +39,7 @@ ip_set_init_comment(struct ip_set_comment *comment,
 	if (unlikely(!c))
 		return;
 	strlcpy(c->str, ext->comment, len + 1);
+	set->ext_size += sizeof(*c) + strlen(c->str) + 1;
 	rcu_assign_pointer(comment->c, c);
 }
 
@@ -58,13 +60,14 @@ ip_set_put_comment(struct sk_buff *skb, const struct ip_set_comment *comment)
  * of the set data anymore.
  */
 static inline void
-ip_set_comment_free(struct ip_set_comment *comment)
+ip_set_comment_free(struct ip_set *set, struct ip_set_comment *comment)
 {
 	struct ip_set_comment_rcu *c;
 
 	c = rcu_dereference_protected(comment->c, 1);
 	if (unlikely(!c))
 		return;
+	set->ext_size -= sizeof(*c) + strlen(c->str) + 1;
 	kfree_rcu(c, rcu);
 	rcu_assign_pointer(comment->c, NULL);
 }
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 1810d1c06e3d..f8ea26cafa30 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -84,6 +84,7 @@ mtype_flush(struct ip_set *set)
 		mtype_ext_cleanup(set);
 	memset(map->members, 0, map->memsize);
 	set->elements = 0;
+	set->ext_size = 0;
 }
 
 /* Calculate the actual memory size of the set data */
@@ -99,7 +100,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 {
 	const struct mtype *map = set->data;
 	struct nlattr *nested;
-	size_t memsize = mtype_memsize(map, set->dsize);
+	size_t memsize = mtype_memsize(map, set->dsize) + set->ext_size;
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
@@ -173,7 +174,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(x, set), ext);
 	if (SET_WITH_COMMENT(set))
-		ip_set_init_comment(ext_comment(x, set), ext);
+		ip_set_init_comment(set, ext_comment(x, set), ext);
 	if (SET_WITH_SKBINFO(set))
 		ip_set_init_skbinfo(ext_skbinfo(x, set), ext);
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index bfacccff7196..23345d2d136a 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -324,7 +324,7 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
 
-typedef void (*destroyer)(void *);
+typedef void (*destroyer)(struct ip_set *, void *);
 /* ipset data extension types, in size order */
 
 const struct ip_set_ext_type ip_set_extensions[] = {
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 6e967f198d1e..0746405a1d14 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -343,21 +343,13 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 /* Calculate the actual memory size of the set data */
 static size_t
 mtype_ahash_memsize(const struct htype *h, const struct htable *t,
-		    u8 nets_length, size_t dsize)
+		    u8 nets_length)
 {
-	u32 i;
-	struct hbucket *n;
 	size_t memsize = sizeof(*h) + sizeof(*t);
 
 #ifdef IP_SET_HASH_WITH_NETS
 	memsize += sizeof(struct net_prefixes) * nets_length;
 #endif
-	for (i = 0; i < jhash_size(t->htable_bits); i++) {
-		n = rcu_dereference_bh(hbucket(t, i));
-		if (!n)
-			continue;
-		memsize += sizeof(struct hbucket) + n->size * dsize;
-	}
 
 	return memsize;
 }
@@ -400,6 +392,7 @@ mtype_flush(struct ip_set *set)
 	memset(h->nets, 0, sizeof(struct net_prefixes) * NLEN(set->family));
 #endif
 	set->elements = 0;
+	set->ext_size = 0;
 }
 
 /* Destroy the hashtable part of the set */
@@ -531,6 +524,7 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 				d++;
 			}
 			tmp->pos = d;
+			set->ext_size -= AHASH_INIT_SIZE * dsize;
 			rcu_assign_pointer(hbucket(t, i), tmp);
 			kfree_rcu(n, rcu);
 		}
@@ -562,7 +556,7 @@ mtype_resize(struct ip_set *set, bool retried)
 	struct htype *h = set->data;
 	struct htable *t, *orig;
 	u8 htable_bits;
-	size_t dsize = set->dsize;
+	size_t extsize, dsize = set->dsize;
 #ifdef IP_SET_HASH_WITH_NETS
 	u8 flags;
 	struct mtype_elem *tmp;
@@ -605,6 +599,7 @@ mtype_resize(struct ip_set *set, bool retried)
 	/* There can't be another parallel resizing, but dumping is possible */
 	atomic_set(&orig->ref, 1);
 	atomic_inc(&orig->uref);
+	extsize = 0;
 	pr_debug("attempt to resize set %s from %u to %u, t %p\n",
 		 set->name, orig->htable_bits, htable_bits, orig);
 	for (i = 0; i < jhash_size(orig->htable_bits); i++) {
@@ -635,6 +630,7 @@ mtype_resize(struct ip_set *set, bool retried)
 					goto cleanup;
 				}
 				m->size = AHASH_INIT_SIZE;
+				extsize = sizeof(*m) + AHASH_INIT_SIZE * dsize;
 				RCU_INIT_POINTER(hbucket(t, key), m);
 			} else if (m->pos >= m->size) {
 				struct hbucket *ht;
@@ -654,6 +650,7 @@ mtype_resize(struct ip_set *set, bool retried)
 				memcpy(ht, m, sizeof(struct hbucket) +
 					      m->size * dsize);
 				ht->size = m->size + AHASH_INIT_SIZE;
+				extsize += AHASH_INIT_SIZE * dsize;
 				kfree(m);
 				m = ht;
 				RCU_INIT_POINTER(hbucket(t, key), ht);
@@ -667,6 +664,7 @@ mtype_resize(struct ip_set *set, bool retried)
 		}
 	}
 	rcu_assign_pointer(h->table, t);
+	set->ext_size = extsize;
 
 	spin_unlock_bh(&set->lock);
 
@@ -740,6 +738,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		if (!n)
 			return -ENOMEM;
 		n->size = AHASH_INIT_SIZE;
+		set->ext_size += sizeof(*n) + AHASH_INIT_SIZE * set->dsize;
 		goto copy_elem;
 	}
 	for (i = 0; i < n->pos; i++) {
@@ -803,6 +802,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		memcpy(n, old, sizeof(struct hbucket) +
 		       old->size * set->dsize);
 		n->size = old->size + AHASH_INIT_SIZE;
+		set->ext_size += AHASH_INIT_SIZE * set->dsize;
 	}
 
 copy_elem:
@@ -823,7 +823,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(data, set), ext);
 	if (SET_WITH_COMMENT(set))
-		ip_set_init_comment(ext_comment(data, set), ext);
+		ip_set_init_comment(set, ext_comment(data, set), ext);
 	if (SET_WITH_SKBINFO(set))
 		ip_set_init_skbinfo(ext_skbinfo(data, set), ext);
 	/* Must come last for the case when timed out entry is reused */
@@ -895,6 +895,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 				k++;
 		}
 		if (n->pos == 0 && k == 0) {
+			set->ext_size -= sizeof(*n) + n->size * dsize;
 			rcu_assign_pointer(hbucket(t, key), NULL);
 			kfree_rcu(n, rcu);
 		} else if (k >= AHASH_INIT_SIZE) {
@@ -913,6 +914,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 				k++;
 			}
 			tmp->pos = k;
+			set->ext_size -= AHASH_INIT_SIZE * dsize;
 			rcu_assign_pointer(hbucket(t, key), tmp);
 			kfree_rcu(n, rcu);
 		}
@@ -1061,7 +1063,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh_nfnl(h->table);
-	memsize = mtype_ahash_memsize(h, t, NLEN(set->family), set->dsize);
+	memsize = mtype_ahash_memsize(h, t, NLEN(set->family)) + set->ext_size;
 	htable_bits = t->htable_bits;
 	rcu_read_unlock_bh();
 
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index c45516695934..dede343a662b 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -228,7 +228,7 @@ list_set_init_extensions(struct ip_set *set, const struct ip_set_ext *ext,
 	if (SET_WITH_COUNTER(set))
 		ip_set_init_counter(ext_counter(e, set), ext);
 	if (SET_WITH_COMMENT(set))
-		ip_set_init_comment(ext_comment(e, set), ext);
+		ip_set_init_comment(set, ext_comment(e, set), ext);
 	if (SET_WITH_SKBINFO(set))
 		ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
 	/* Update timeout last */
@@ -422,6 +422,7 @@ list_set_flush(struct ip_set *set)
 	list_for_each_entry_safe(e, n, &map->members, list)
 		list_set_del(set, e);
 	set->elements = 0;
+	set->ext_size = 0;
 }
 
 static void
@@ -467,7 +468,7 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 {
 	const struct list_set *map = set->data;
 	struct nlattr *nested;
-	size_t memsize = list_set_memsize(map, set->dsize);
+	size_t memsize = list_set_memsize(map, set->dsize) + set->ext_size;
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
-- 
2.1.4
