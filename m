From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/33] netfilter: ipset: Fix sparse warnings due to missing rcu annotations
Date: Fri,  4 Oct 2013 10:32:51 +0200
Message-ID: <1380875598-5250-7-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55926 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab3JDIex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:53 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Reported-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h |   87 +++++++++++++++++++++------------
 1 file changed, 55 insertions(+), 32 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 7ff20ec..09a21dd 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -15,6 +15,8 @@
 #define rcu_dereference_bh(p)	rcu_dereference(p)
 #endif
 
+#define rcu_dereference_bh_nfnl(p)	rcu_dereference_bh_check(p, 1)
+
 #define CONCAT(a, b)		a##b
 #define TOKEN(a, b)		CONCAT(a, b)
 
@@ -269,7 +271,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 
 /* The generic hash structure */
 struct htype {
-	struct htable *table;	/* the hash table */
+	struct htable __rcu *table; /* the hash table */
 	u32 maxelem;		/* max elements in the hash */
 	u32 elements;		/* current element (vs timeout) */
 	u32 initval;		/* random jhash init value */
@@ -347,10 +349,10 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length)
 
 /* Calculate the actual memory size of the set data */
 static size_t
-mtype_ahash_memsize(const struct htype *h, u8 nets_length)
+mtype_ahash_memsize(const struct htype *h, const struct htable *t,
+		    u8 nets_length)
 {
 	u32 i;
-	struct htable *t = h->table;
 	size_t memsize = sizeof(*h)
 			 + sizeof(*t)
 #ifdef IP_SET_HASH_WITH_NETS
@@ -369,10 +371,11 @@ static void
 mtype_flush(struct ip_set *set)
 {
 	struct htype *h = set->data;
-	struct htable *t = h->table;
+	struct htable *t;
 	struct hbucket *n;
 	u32 i;
 
+	t = rcu_dereference_bh_nfnl(h->table);
 	for (i = 0; i < jhash_size(t->htable_bits); i++) {
 		n = hbucket(t, i);
 		if (n->size) {
@@ -397,7 +400,7 @@ mtype_destroy(struct ip_set *set)
 	if (set->extensions & IPSET_EXT_TIMEOUT)
 		del_timer_sync(&h->gc);
 
-	ahash_destroy(h->table);
+	ahash_destroy(rcu_dereference_bh_nfnl(h->table));
 #ifdef IP_SET_HASH_WITH_RBTREE
 	rbtree_destroy(&h->rbtree);
 #endif
@@ -443,12 +446,14 @@ mtype_same_set(const struct ip_set *a, const struct ip_set *b)
 static void
 mtype_expire(struct htype *h, u8 nets_length, size_t dsize)
 {
-	struct htable *t = h->table;
+	struct htable *t;
 	struct hbucket *n;
 	struct mtype_elem *data;
 	u32 i;
 	int j;
 
+	rcu_read_lock_bh();
+	t = rcu_dereference_bh(h->table);
 	for (i = 0; i < jhash_size(t->htable_bits); i++) {
 		n = hbucket(t, i);
 		for (j = 0; j < n->pos; j++) {
@@ -481,6 +486,7 @@ mtype_expire(struct htype *h, u8 nets_length, size_t dsize)
 			n->value = tmp;
 		}
 	}
+	rcu_read_unlock_bh();
 }
 
 static void
@@ -505,7 +511,7 @@ static int
 mtype_resize(struct ip_set *set, bool retried)
 {
 	struct htype *h = set->data;
-	struct htable *t, *orig = h->table;
+	struct htable *t, *orig = rcu_dereference_bh_nfnl(h->table);
 	u8 htable_bits = orig->htable_bits;
 #ifdef IP_SET_HASH_WITH_NETS
 	u8 flags;
@@ -682,13 +688,15 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	  struct ip_set_ext *mext, u32 flags)
 {
 	struct htype *h = set->data;
-	struct htable *t = h->table;
+	struct htable *t;
 	const struct mtype_elem *d = value;
 	struct mtype_elem *data;
 	struct hbucket *n;
-	int i;
+	int i, ret = -IPSET_ERR_EXIST;
 	u32 key, multi = 0;
 
+	rcu_read_lock_bh();
+	t = rcu_dereference_bh(h->table);
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
@@ -697,7 +705,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			continue;
 		if (SET_WITH_TIMEOUT(set) &&
 		    ip_set_timeout_expired(ext_timeout(data, h)))
-			return -IPSET_ERR_EXIST;
+			goto out;
 		if (i != n->pos - 1)
 			/* Not last one */
 			memcpy(data, ahash_data(n, n->pos - 1, h->dsize),
@@ -712,17 +720,22 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
 					    * h->dsize,
 					    GFP_ATOMIC);
-			if (!tmp)
-				return 0;
+			if (!tmp) {
+				ret = 0;
+				goto out;
+			}
 			n->size -= AHASH_INIT_SIZE;
 			memcpy(tmp, n->value, n->size * h->dsize);
 			kfree(n->value);
 			n->value = tmp;
 		}
-		return 0;
+		ret = 0;
+		goto out;
 	}
 
-	return -IPSET_ERR_EXIST;
+out:
+	rcu_read_unlock_bh();
+	return ret;
 }
 
 static inline int
@@ -745,7 +758,7 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 		 struct ip_set_ext *mext, u32 flags)
 {
 	struct htype *h = set->data;
-	struct htable *t = h->table;
+	struct htable *t = rcu_dereference_bh(h->table);
 	struct hbucket *n;
 	struct mtype_elem *data;
 	int i, j = 0;
@@ -785,18 +798,22 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	   struct ip_set_ext *mext, u32 flags)
 {
 	struct htype *h = set->data;
-	struct htable *t = h->table;
+	struct htable *t;
 	struct mtype_elem *d = value;
 	struct hbucket *n;
 	struct mtype_elem *data;
-	int i;
+	int i, ret = 0;
 	u32 key, multi = 0;
 
+	rcu_read_lock_bh();
+	t = rcu_dereference_bh(h->table);
 #ifdef IP_SET_HASH_WITH_NETS
 	/* If we test an IP address and not a network address,
 	 * try all possible network sizes */
-	if (CIDR(d->cidr) == SET_HOST_MASK(set->family))
-		return mtype_test_cidrs(set, d, ext, mext, flags);
+	if (CIDR(d->cidr) == SET_HOST_MASK(set->family)) {
+		ret = mtype_test_cidrs(set, d, ext, mext, flags);
+		goto out;
+	}
 #endif
 
 	key = HKEY(d, h->initval, t->htable_bits);
@@ -805,10 +822,14 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		data = ahash_data(n, i, h->dsize);
 		if (mtype_data_equal(data, d, &multi) &&
 		    !(SET_WITH_TIMEOUT(set) &&
-		      ip_set_timeout_expired(ext_timeout(data, h))))
-			return mtype_data_match(data, ext, mext, set, flags);
+		      ip_set_timeout_expired(ext_timeout(data, h)))) {
+			ret = mtype_data_match(data, ext, mext, set, flags);
+			goto out;
+		}
 	}
-	return 0;
+out:
+	rcu_read_unlock_bh();
+	return ret;
 }
 
 /* Reply a HEADER request: fill out the header part of the set */
@@ -816,18 +837,18 @@ static int
 mtype_head(struct ip_set *set, struct sk_buff *skb)
 {
 	const struct htype *h = set->data;
+	const struct htable *t;
 	struct nlattr *nested;
 	size_t memsize;
 
-	read_lock_bh(&set->lock);
-	memsize = mtype_ahash_memsize(h, NETS_LENGTH(set->family));
-	read_unlock_bh(&set->lock);
+	t = rcu_dereference_bh_nfnl(h->table);
+	memsize = mtype_ahash_memsize(h, t, NETS_LENGTH(set->family));
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
 		goto nla_put_failure;
 	if (nla_put_net32(skb, IPSET_ATTR_HASHSIZE,
-			  htonl(jhash_size(h->table->htable_bits))) ||
+			  htonl(jhash_size(t->htable_bits))) ||
 	    nla_put_net32(skb, IPSET_ATTR_MAXELEM, htonl(h->maxelem)))
 		goto nla_put_failure;
 #ifdef IP_SET_HASH_WITH_NETMASK
@@ -856,7 +877,7 @@ mtype_list(const struct ip_set *set,
 	   struct sk_buff *skb, struct netlink_callback *cb)
 {
 	const struct htype *h = set->data;
-	const struct htable *t = h->table;
+	const struct htable *t = rcu_dereference_bh_nfnl(h->table);
 	struct nlattr *atd, *nested;
 	const struct hbucket *n;
 	const struct mtype_elem *e;
@@ -956,6 +977,7 @@ TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 #endif
 	size_t hsize;
 	struct HTYPE *h;
+	struct htable *t;
 
 	if (!(set->family == NFPROTO_IPV4 || set->family == NFPROTO_IPV6))
 		return -IPSET_ERR_INVALID_FAMILY;
@@ -1013,12 +1035,13 @@ TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		kfree(h);
 		return -ENOMEM;
 	}
-	h->table = ip_set_alloc(hsize);
-	if (!h->table) {
+	t = ip_set_alloc(hsize);
+	if (!t) {
 		kfree(h);
 		return -ENOMEM;
 	}
-	h->table->htable_bits = hbits;
+	t->htable_bits = hbits;
+	rcu_assign_pointer(h->table, t);
 
 	set->data = h;
 	if (set->family ==  NFPROTO_IPV4)
@@ -1096,8 +1119,8 @@ TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	}
 
 	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
-		 set->name, jhash_size(h->table->htable_bits),
-		 h->table->htable_bits, h->maxelem, set->data, h->table);
+		 set->name, jhash_size(t->htable_bits),
+		 t->htable_bits, h->maxelem, set->data, t);
 
 	return 0;
 }
-- 
1.7.10.4
