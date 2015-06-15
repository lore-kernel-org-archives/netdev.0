From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/32] netfilter: ipset: Fix parallel resizing and listing of the same set
Date: Mon, 15 Jun 2015 23:26:17 +0200
Message-ID: <1434403589-24796-21-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When elements added to a hash:* type of set and resizing triggered,
parallel listing could start to list the original set (before resizing)
and "continue" with listing the new set. Fix it by references and
using the original hash table for listing. Therefore the destroying of
the original hash table may happen from the resizing or listing functions.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h |   13 ++++++----
 net/netfilter/ipset/ip_set_core.c      |   29 ++++++++++++---------
 net/netfilter/ipset/ip_set_hash_gen.h  |   44 +++++++++++++++++++++++++++++---
 3 files changed, 66 insertions(+), 20 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index a6fe1ce..5674b6a 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -176,6 +176,9 @@ struct ip_set_type_variant {
 	/* List elements */
 	int (*list)(const struct ip_set *set, struct sk_buff *skb,
 		    struct netlink_callback *cb);
+	/* Keep listing private when resizing runs parallel */
+	void (*uref)(struct ip_set *set, struct netlink_callback *cb,
+		     bool start);
 
 	/* Return true if "b" set is the same as "a"
 	 * according to the create set parameters */
@@ -380,12 +383,12 @@ ip_set_init_counter(struct ip_set_counter *counter,
 
 /* Netlink CB args */
 enum {
-	IPSET_CB_NET = 0,
-	IPSET_CB_DUMP,
-	IPSET_CB_INDEX,
-	IPSET_CB_ARG0,
+	IPSET_CB_NET = 0,	/* net namespace */
+	IPSET_CB_DUMP,		/* dump single set/all sets */
+	IPSET_CB_INDEX,		/* set index */
+	IPSET_CB_PRIVATE,	/* set private data */
+	IPSET_CB_ARG0,		/* type specific */
 	IPSET_CB_ARG1,
-	IPSET_CB_ARG2,
 };
 
 /* register and unregister set references */
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 68ae551..777cac6 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1211,12 +1211,16 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 static int
 ip_set_dump_done(struct netlink_callback *cb)
 {
-	struct ip_set_net *inst = (struct ip_set_net *)cb->args[IPSET_CB_NET];
 	if (cb->args[IPSET_CB_ARG0]) {
-		pr_debug("release set %s\n",
-			 ip_set(inst, cb->args[IPSET_CB_INDEX])->name);
-		__ip_set_put_byindex(inst,
-			(ip_set_id_t) cb->args[IPSET_CB_INDEX]);
+		struct ip_set_net *inst =
+			(struct ip_set_net *)cb->args[IPSET_CB_NET];
+		ip_set_id_t index = (ip_set_id_t)cb->args[IPSET_CB_INDEX];
+		struct ip_set *set = ip_set(inst, index);
+
+		if (set->variant->uref)
+			set->variant->uref(set, cb, false);
+		pr_debug("release set %s\n", set->name);
+		__ip_set_put_byindex(inst, index);
 	}
 	return 0;
 }
@@ -1247,12 +1251,6 @@ dump_init(struct netlink_callback *cb, struct ip_set_net *inst)
 	nla_parse(cda, IPSET_ATTR_CMD_MAX,
 		  attr, nlh->nlmsg_len - min_len, ip_set_setname_policy);
 
-	/* cb->args[IPSET_CB_NET]:	net namespace
-	 *         [IPSET_CB_DUMP]:	dump single set/all sets
-	 *         [IPSET_CB_INDEX]: 	set index
-	 *         [IPSET_CB_ARG0]:	type specific
-	 */
-
 	if (cda[IPSET_ATTR_SETNAME]) {
 		struct ip_set *set;
 
@@ -1359,6 +1357,8 @@ dump_last:
 				goto release_refcount;
 			if (dump_flags & IPSET_FLAG_LIST_HEADER)
 				goto next_set;
+			if (set->variant->uref)
+				set->variant->uref(set, cb, true);
 			/* Fall through and add elements */
 		default:
 			read_lock_bh(&set->lock);
@@ -1375,6 +1375,8 @@ dump_last:
 		dump_type = DUMP_LAST;
 		cb->args[IPSET_CB_DUMP] = dump_type | (dump_flags << 16);
 		cb->args[IPSET_CB_INDEX] = 0;
+		if (set && set->variant->uref)
+			set->variant->uref(set, cb, false);
 		goto dump_last;
 	}
 	goto out;
@@ -1389,7 +1391,10 @@ next_set:
 release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[IPSET_CB_ARG0]) {
-		pr_debug("release set %s\n", ip_set(inst, index)->name);
+		set = ip_set(inst, index);
+		if (set->variant->uref)
+			set->variant->uref(set, cb, false);
+		pr_debug("release set %s\n", set->name);
 		__ip_set_put_byindex(inst, index);
 		cb->args[IPSET_CB_ARG0] = 0;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 2f1985e..5fcf70b 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -71,6 +71,8 @@ struct hbucket {
 
 /* The hash table: the table size stored here in order to make resizing easy */
 struct htable {
+	atomic_t ref;		/* References for resizing */
+	atomic_t uref;		/* References for dumping */
 	u8 htable_bits;		/* size of hash table == 2^htable_bits */
 	struct hbucket bucket[0]; /* hashtable buckets */
 };
@@ -207,6 +209,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #undef mtype_del
 #undef mtype_test_cidrs
 #undef mtype_test
+#undef mtype_uref
 #undef mtype_expire
 #undef mtype_resize
 #undef mtype_head
@@ -248,6 +251,7 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define mtype_del		IPSET_TOKEN(MTYPE, _del)
 #define mtype_test_cidrs	IPSET_TOKEN(MTYPE, _test_cidrs)
 #define mtype_test		IPSET_TOKEN(MTYPE, _test)
+#define mtype_uref		IPSET_TOKEN(MTYPE, _uref)
 #define mtype_expire		IPSET_TOKEN(MTYPE, _expire)
 #define mtype_resize		IPSET_TOKEN(MTYPE, _resize)
 #define mtype_head		IPSET_TOKEN(MTYPE, _head)
@@ -595,6 +599,9 @@ retry:
 	t->htable_bits = htable_bits;
 
 	read_lock_bh(&set->lock);
+	/* There can't be another parallel resizing, but dumping is possible */
+	atomic_set(&orig->ref, 1);
+	atomic_inc(&orig->uref);
 	for (i = 0; i < jhash_size(orig->htable_bits); i++) {
 		n = hbucket(orig, i);
 		for (j = 0; j < n->pos; j++) {
@@ -609,6 +616,8 @@ retry:
 #ifdef IP_SET_HASH_WITH_NETS
 				mtype_data_reset_flags(data, &flags);
 #endif
+				atomic_set(&orig->ref, 0);
+				atomic_dec(&orig->uref);
 				read_unlock_bh(&set->lock);
 				mtype_ahash_destroy(set, t, false);
 				if (ret == -EAGAIN)
@@ -631,7 +640,11 @@ retry:
 
 	pr_debug("set %s resized from %u (%p) to %u (%p)\n", set->name,
 		 orig->htable_bits, orig, t->htable_bits, t);
-	mtype_ahash_destroy(set, orig, false);
+	/* If there's nobody else dumping the table, destroy it */
+	if (atomic_dec_and_test(&orig->uref)) {
+		pr_debug("Table destroy by resize %p\n", orig);
+		mtype_ahash_destroy(set, orig, false);
+	}
 
 	return 0;
 }
@@ -961,13 +974,36 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+/* Make possible to run dumping parallel with resizing */
+static void
+mtype_uref(struct ip_set *set, struct netlink_callback *cb, bool start)
+{
+	struct htype *h = set->data;
+	struct htable *t;
+
+	if (start) {
+		rcu_read_lock_bh();
+		t = rcu_dereference_bh_nfnl(h->table);
+		atomic_inc(&t->uref);
+		cb->args[IPSET_CB_PRIVATE] = (unsigned long)t;
+		rcu_read_unlock_bh();
+	} else if (cb->args[IPSET_CB_PRIVATE]) {
+		t = (struct htable *)cb->args[IPSET_CB_PRIVATE];
+		if (atomic_dec_and_test(&t->uref) && atomic_read(&t->ref)) {
+			/* Resizing didn't destroy the hash table */
+			pr_debug("Table destroy by dump: %p\n", t);
+			mtype_ahash_destroy(set, t, false);
+		}
+		cb->args[IPSET_CB_PRIVATE] = 0;
+	}
+}
+
 /* Reply a LIST/SAVE request: dump the elements of the specified set */
 static int
 mtype_list(const struct ip_set *set,
 	   struct sk_buff *skb, struct netlink_callback *cb)
 {
-	const struct htype *h = set->data;
-	const struct htable *t = rcu_dereference_bh_nfnl(h->table);
+	const struct htable *t;
 	struct nlattr *atd, *nested;
 	const struct hbucket *n;
 	const struct mtype_elem *e;
@@ -980,6 +1016,7 @@ mtype_list(const struct ip_set *set,
 	if (!atd)
 		return -EMSGSIZE;
 	pr_debug("list hash set %s\n", set->name);
+	t = (const struct htable *)cb->args[IPSET_CB_PRIVATE];
 	for (; cb->args[IPSET_CB_ARG0] < jhash_size(t->htable_bits);
 	     cb->args[IPSET_CB_ARG0]++) {
 		incomplete = skb_tail_pointer(skb);
@@ -1047,6 +1084,7 @@ static const struct ip_set_type_variant mtype_variant = {
 	.flush	= mtype_flush,
 	.head	= mtype_head,
 	.list	= mtype_list,
+	.uref	= mtype_uref,
 	.resize	= mtype_resize,
 	.same_set = mtype_same_set,
 };
-- 
1.7.10.4

