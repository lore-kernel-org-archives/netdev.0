From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 04/29] fib_trie: Remove leaf_info
Date: Tue, 24 Feb 2015 12:48:22 -0800
Message-ID: <20150224204822.26106.82010.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbbBXUsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:25 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmN7D018037
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:24 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmM6H029673
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:23 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point the leaf_info hash is redundant.  By adding the suffix length
to the fib_alias hash list we no longer have need of leaf_info as we can
determin the prefix length from fa_slen.  So we can compress things by
dropping the leaf_info structure from fib_trie and instead directly connect
the leaves to the fib_alias hash list.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  458 +++++++++++++++++----------------------------------
 1 file changed, 155 insertions(+), 303 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1c35261..8896617 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -108,17 +108,10 @@ struct tnode {
 			struct tnode __rcu *child[0];
 		};
 		/* This list pointer if valid if bits == 0 (LEAF) */
-		struct hlist_head list;
+		struct hlist_head leaf;
 	};
 };
 
-struct leaf_info {
-	struct hlist_node hlist;
-	unsigned char slen;
-	struct hlist_head falh;
-	struct rcu_head rcu;
-};
-
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 struct trie_use_stats {
 	unsigned int gets;
@@ -289,11 +282,6 @@ static void __node_free_rcu(struct rcu_head *head)
 
 #define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
 
-static inline void free_leaf_info(struct leaf_info *leaf)
-{
-	kfree_rcu(leaf, rcu);
-}
-
 static struct tnode *tnode_alloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
@@ -327,21 +315,11 @@ static struct tnode *leaf_new(t_key key)
 		/* set bits to 0 indicating we are not a tnode */
 		l->bits = 0;
 
-		INIT_HLIST_HEAD(&l->list);
+		INIT_HLIST_HEAD(&l->leaf);
 	}
 	return l;
 }
 
-static struct leaf_info *leaf_info_new(int plen)
-{
-	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
-	if (li) {
-		li->slen = KEYLENGTH - plen;
-		INIT_HLIST_HEAD(&li->falh);
-	}
-	return li;
-}
-
 static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
 	size_t sz = offsetof(struct tnode, child[1ul << bits]);
@@ -864,32 +842,6 @@ static void resize(struct trie *t, struct tnode *tn)
 	}
 }
 
-/* readside must use rcu_read_lock currently dump routines
- via get_fa_head and dump */
-
-static struct leaf_info *find_leaf_info(struct tnode *l, int plen)
-{
-	struct hlist_head *head = &l->list;
-	struct leaf_info *li;
-	int slen = KEYLENGTH - plen;
-
-	hlist_for_each_entry_rcu(li, head, hlist)
-		if (li->slen == slen)
-			return li;
-
-	return NULL;
-}
-
-static inline struct hlist_head *get_fa_head(struct tnode *l, int plen)
-{
-	struct leaf_info *li = find_leaf_info(l, plen);
-
-	if (!li)
-		return NULL;
-
-	return &li->falh;
-}
-
 static void leaf_pull_suffix(struct tnode *l)
 {
 	struct tnode *tp = node_parent(l);
@@ -914,43 +866,47 @@ static void leaf_push_suffix(struct tnode *l)
 	}
 }
 
-static void remove_leaf_info(struct tnode *l, struct leaf_info *old)
+static void fib_remove_alias(struct tnode *l, struct fib_alias *old)
 {
 	/* record the location of the previous list_info entry */
-	struct hlist_node **pprev = old->hlist.pprev;
-	struct leaf_info *li = hlist_entry(pprev, typeof(*li), hlist.next);
+	struct hlist_node **pprev = old->fa_list.pprev;
+	struct fib_alias *fa = hlist_entry(pprev, typeof(*fa), fa_list.next);
 
-	/* remove the leaf info from the list */
-	hlist_del_rcu(&old->hlist);
+	/* remove the fib_alias from the list */
+	hlist_del_rcu(&old->fa_list);
 
-	/* only access li if it is pointing at the last valid hlist_node */
-	if (hlist_empty(&l->list) || (*pprev))
+	/* only access fa if it is pointing at the last valid hlist_node */
+	if (hlist_empty(&l->leaf) || (*pprev))
 		return;
 
 	/* update the trie with the latest suffix length */
-	l->slen = li->slen;
+	l->slen = fa->fa_slen;
 	leaf_pull_suffix(l);
 }
 
-static void insert_leaf_info(struct tnode *l, struct leaf_info *new)
+static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
+			     struct fib_alias *new)
 {
-	struct hlist_head *head = &l->list;
-	struct leaf_info *li, *last = NULL;
+	struct hlist_head *head = &l->leaf;
 
-	hlist_for_each_entry(li, head, hlist) {
-		if (new->slen < li->slen)
-			break;
-		last = li;
+	if (!fa) {
+		struct fib_alias *last;
+
+		hlist_for_each_entry(last, head, fa_list) {
+			if (new->fa_slen < last->fa_slen)
+				break;
+			fa = last;
+		}
 	}
 
-	if (last)
-		hlist_add_behind_rcu(&new->hlist, &last->hlist);
+	if (fa)
+		hlist_add_behind_rcu(&new->fa_list, &fa->fa_list);
 	else
-		hlist_add_head_rcu(&new->hlist, head);
+		hlist_add_head_rcu(&new->fa_list, head);
 
 	/* if we added to the tail node then we need to update slen */
-	if (l->slen < new->slen) {
-		l->slen = new->slen;
+	if (l->slen < new->fa_slen) {
+		l->slen = new->fa_slen;
 		leaf_push_suffix(l);
 	}
 }
@@ -989,8 +945,8 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 /* Return the first fib alias matching TOS with
  * priority less than or equal to PRIO.
  */
-static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 tos,
-					u32 prio)
+static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
+					u8 tos, u32 prio)
 {
 	struct fib_alias *fa;
 
@@ -998,6 +954,10 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 tos,
 		return NULL;
 
 	hlist_for_each_entry(fa, fah, fa_list) {
+		if (fa->fa_slen < slen)
+			continue;
+		if (fa->fa_slen != slen)
+			break;
 		if (fa->fa_tos > tos)
 			continue;
 		if (fa->fa_info->fib_priority >= prio || fa->fa_tos < tos)
@@ -1023,16 +983,9 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 /* only used from updater-side */
 
-static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
+static struct tnode *fib_insert_node(struct trie *t, u32 key, int plen)
 {
-	struct hlist_head *fa_head = NULL;
 	struct tnode *l, *n, *tp = NULL;
-	struct leaf_info *li;
-
-	li = leaf_info_new(plen);
-	if (!li)
-		return NULL;
-	fa_head = &li->falh;
 
 	n = rtnl_dereference(t->trie);
 
@@ -1063,8 +1016,7 @@ static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		/* we have found a leaf. Prefixes have already been compared */
 		if (IS_LEAF(n)) {
 			/* Case 1: n is a leaf, and prefixes match*/
-			insert_leaf_info(n, li);
-			return fa_head;
+			return n;
 		}
 
 		tp = n;
@@ -1072,12 +1024,8 @@ static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
 	}
 
 	l = leaf_new(key);
-	if (!l) {
-		free_leaf_info(li);
+	if (!l)
 		return NULL;
-	}
-
-	insert_leaf_info(l, li);
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1090,7 +1038,6 @@ static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 		tn = tnode_new(key, __fls(key ^ n->key), 1);
 		if (!tn) {
-			free_leaf_info(li);
 			node_free(l);
 			return NULL;
 		}
@@ -1116,7 +1063,7 @@ static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		rcu_assign_pointer(t->trie, l);
 	}
 
-	return fa_head;
+	return l;
 }
 
 /*
@@ -1126,9 +1073,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *new_fa;
-	struct hlist_head *fa_head = NULL;
 	struct fib_info *fi;
-	int plen = cfg->fc_dst_len;
+	u8 plen = cfg->fc_dst_len;
+	u8 slen = KEYLENGTH - plen;
 	u8 tos = cfg->fc_tos;
 	u32 key, mask;
 	int err;
@@ -1146,8 +1093,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	if (key & ~mask)
 		return -EINVAL;
 
-	key = key & mask;
-
 	fi = fib_create_info(cfg);
 	if (IS_ERR(fi)) {
 		err = PTR_ERR(fi);
@@ -1155,12 +1100,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	}
 
 	l = fib_find_node(t, key);
-	fa = NULL;
-
-	if (l) {
-		fa_head = get_fa_head(l, plen);
-		fa = fib_find_alias(fa_head, tos, fi->fib_priority);
-	}
+	fa = l ? fib_find_alias(&l->leaf, slen, tos, fi->fib_priority) : NULL;
 
 	/* Now fa, if non-NULL, points to the first fib alias
 	 * with the same keys [prefix,tos,priority], if such key already
@@ -1189,7 +1129,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		fa_match = NULL;
 		fa_first = fa;
 		hlist_for_each_entry_from(fa, fa_list) {
-			if (fa->fa_tos != tos)
+			if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
@@ -1257,12 +1197,12 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
 	new_fa->fa_state = 0;
-	new_fa->fa_slen = KEYLENGTH - plen;
+	new_fa->fa_slen = slen;
 
 	/* Insert new entry to the list. */
-	if (!fa_head) {
-		fa_head = fib_insert_node(t, key, plen);
-		if (unlikely(!fa_head)) {
+	if (!l) {
+		l = fib_insert_node(t, key, plen);
+		if (unlikely(!l)) {
 			err = -ENOMEM;
 			goto out_free_new_fa;
 		}
@@ -1271,17 +1211,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	if (!plen)
 		tb->tb_num_default++;
 
-	if (!fa) {
-		struct fib_alias *last;
-
-		hlist_for_each_entry(last, fa_head, fa_list)
-			fa = last;
-	}
-
-	if (fa)
-		hlist_add_behind_rcu(&new_fa->fa_list, &fa->fa_list);
-	else
-		hlist_add_head_rcu(&new_fa->fa_list, fa_head);
+	fib_insert_alias(l, fa, new_fa);
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
@@ -1314,7 +1244,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 #endif
 	const t_key key = ntohl(flp->daddr);
 	struct tnode *n, *pn;
-	struct leaf_info *li;
+	struct fib_alias *fa;
 	t_key cindex;
 
 	n = rcu_dereference(t->trie);
@@ -1417,55 +1347,51 @@ backtrace:
 
 found:
 	/* Step 3: Process the leaf, if that fails fall back to backtracing */
-	hlist_for_each_entry_rcu(li, &n->list, hlist) {
-		struct fib_alias *fa;
-
-		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
-			struct fib_info *fi = fa->fa_info;
-			int nhsel, err;
+	hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+		int nhsel, err;
 
-			if (((key ^ n->key) >> fa->fa_slen) &&
-			    (fa->fa_slen != KEYLENGTH))
-				continue;
-			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
-				continue;
-			if (fi->fib_dead)
-				continue;
-			if (fa->fa_info->fib_scope < flp->flowi4_scope)
-				continue;
-			fib_alias_accessed(fa);
-			err = fib_props[fa->fa_type].error;
-			if (unlikely(err < 0)) {
+		if (((key ^ n->key) >> fa->fa_slen) &&
+		    (fa->fa_slen != KEYLENGTH))
+			continue;
+		if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
+			continue;
+		if (fi->fib_dead)
+			continue;
+		if (fa->fa_info->fib_scope < flp->flowi4_scope)
+			continue;
+		fib_alias_accessed(fa);
+		err = fib_props[fa->fa_type].error;
+		if (unlikely(err < 0)) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-				this_cpu_inc(stats->semantic_match_passed);
+			this_cpu_inc(stats->semantic_match_passed);
 #endif
-				return err;
-			}
-			if (fi->fib_flags & RTNH_F_DEAD)
+			return err;
+		}
+		if (fi->fib_flags & RTNH_F_DEAD)
+			continue;
+		for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
+			const struct fib_nh *nh = &fi->fib_nh[nhsel];
+
+			if (nh->nh_flags & RTNH_F_DEAD)
 				continue;
-			for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
-				const struct fib_nh *nh = &fi->fib_nh[nhsel];
-
-				if (nh->nh_flags & RTNH_F_DEAD)
-					continue;
-				if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
-					continue;
-
-				if (!(fib_flags & FIB_LOOKUP_NOREF))
-					atomic_inc(&fi->fib_clntref);
-
-				res->prefixlen = KEYLENGTH - fa->fa_slen;
-				res->nh_sel = nhsel;
-				res->type = fa->fa_type;
-				res->scope = fi->fib_scope;
-				res->fi = fi;
-				res->table = tb;
-				res->fa_head = &li->falh;
+			if (flp->flowi4_oif && flp->flowi4_oif != nh->nh_oif)
+				continue;
+
+			if (!(fib_flags & FIB_LOOKUP_NOREF))
+				atomic_inc(&fi->fib_clntref);
+
+			res->prefixlen = KEYLENGTH - fa->fa_slen;
+			res->nh_sel = nhsel;
+			res->type = fa->fa_type;
+			res->scope = fi->fib_scope;
+			res->fi = fi;
+			res->table = tb;
+			res->fa_head = &n->leaf;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-				this_cpu_inc(stats->semantic_match_passed);
+			this_cpu_inc(stats->semantic_match_passed);
 #endif
-				return err;
-			}
+			return err;
 		}
 	}
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -1500,15 +1426,14 @@ static void trie_leaf_remove(struct trie *t, struct tnode *l)
 int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
-	u32 key, mask;
-	int plen = cfg->fc_dst_len;
-	u8 tos = cfg->fc_tos;
 	struct fib_alias *fa, *fa_to_delete;
-	struct hlist_head *fa_head;
+	u8 plen = cfg->fc_dst_len;
+	u8 tos = cfg->fc_tos;
+	u8 slen = KEYLENGTH - plen;
 	struct tnode *l;
-	struct leaf_info *li;
+	u32 key, mask;
 
-	if (plen > 32)
+	if (plen > KEYLENGTH)
 		return -EINVAL;
 
 	key = ntohl(cfg->fc_dst);
@@ -1517,19 +1442,11 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (key & ~mask)
 		return -EINVAL;
 
-	key = key & mask;
 	l = fib_find_node(t, key);
-
 	if (!l)
 		return -ESRCH;
 
-	li = find_leaf_info(l, plen);
-
-	if (!li)
-		return -ESRCH;
-
-	fa_head = &li->falh;
-	fa = fib_find_alias(fa_head, tos, 0);
+	fa = fib_find_alias(&l->leaf, slen, tos, 0);
 
 	if (!fa)
 		return -ESRCH;
@@ -1540,7 +1457,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	hlist_for_each_entry_from(fa, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
-		if (fa->fa_tos != tos)
+		if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
 			break;
 
 		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
@@ -1563,17 +1480,12 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-	hlist_del_rcu(&fa->fa_list);
+	fib_remove_alias(l, fa);
 
 	if (!plen)
 		tb->tb_num_default--;
 
-	if (hlist_empty(fa_head)) {
-		remove_leaf_info(l, li);
-		free_leaf_info(li);
-	}
-
-	if (hlist_empty(&l->list))
+	if (hlist_empty(&l->leaf))
 		trie_leaf_remove(t, l);
 
 	if (fa->fa_state & FA_S_ACCESSED)
@@ -1584,13 +1496,14 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_list(struct hlist_head *head)
+static int trie_flush_leaf(struct tnode *l)
 {
 	struct hlist_node *tmp;
+	unsigned char slen = 0;
 	struct fib_alias *fa;
 	int found = 0;
 
-	hlist_for_each_entry_safe(fa, tmp, head, fa_list) {
+	hlist_for_each_entry_safe(fa, tmp, &l->leaf, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
@@ -1598,28 +1511,11 @@ static int trie_flush_list(struct hlist_head *head)
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
 			found++;
-		}
-	}
-	return found;
-}
-
-static int trie_flush_leaf(struct tnode *l)
-{
-	int found = 0;
-	struct hlist_node *tmp;
-	struct leaf_info *li;
-	unsigned char slen = 0;
 
-	hlist_for_each_entry_safe(li, tmp, &l->list, hlist) {
-		found += trie_flush_list(&li->falh);
-
-		if (hlist_empty(&li->falh)) {
-			hlist_del_rcu(&li->hlist);
-			free_leaf_info(li);
 			continue;
 		}
 
-		slen = li->slen;
+		slen = fa->fa_slen;
 	}
 
 	l->slen = slen;
@@ -1627,8 +1523,7 @@ static int trie_flush_leaf(struct tnode *l)
 	return found;
 }
 
-/*
- * Scan for the next right leaf starting at node p->child[idx]
+/* Scan for the next right leaf starting at node p->child[idx]
  * Since we have back pointer, no recursion necessary.
  */
 static struct tnode *leaf_walk_rcu(struct tnode *p, struct tnode *c)
@@ -1703,7 +1598,7 @@ int fib_table_flush(struct fib_table *tb)
 		found += trie_flush_leaf(l);
 
 		if (ll) {
-			if (hlist_empty(&ll->list))
+			if (hlist_empty(&ll->leaf))
 				trie_leaf_remove(t, ll);
 			else
 				leaf_pull_suffix(ll);
@@ -1713,7 +1608,7 @@ int fib_table_flush(struct fib_table *tb)
 	}
 
 	if (ll) {
-		if (hlist_empty(&ll->list))
+		if (hlist_empty(&ll->leaf))
 			trie_leaf_remove(t, ll);
 		else
 			leaf_pull_suffix(ll);
@@ -1733,20 +1628,18 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
-static int fn_trie_dump_fa(t_key key, struct hlist_head *fah,
-			   struct fib_table *tb,
-			   struct sk_buff *skb, struct netlink_callback *cb)
+static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
+			     struct sk_buff *skb, struct netlink_callback *cb)
 {
-	int i, s_i;
+	__be32 xkey = htonl(l->key);
 	struct fib_alias *fa;
-	__be32 xkey = htonl(key);
+	int i, s_i;
 
-	s_i = cb->args[5];
+	s_i = cb->args[4];
 	i = 0;
 
 	/* rcu_read_lock is hold by caller */
-
-	hlist_for_each_entry_rcu(fa, fah, fa_list) {
+	hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
 		if (i < s_i) {
 			i++;
 			continue;
@@ -1761,38 +1654,6 @@ static int fn_trie_dump_fa(t_key key, struct hlist_head *fah,
 				  KEYLENGTH - fa->fa_slen,
 				  fa->fa_tos,
 				  fa->fa_info, NLM_F_MULTI) < 0) {
-			cb->args[5] = i;
-			return -1;
-		}
-		i++;
-	}
-	cb->args[5] = i;
-	return skb->len;
-}
-
-static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
-			struct sk_buff *skb, struct netlink_callback *cb)
-{
-	struct leaf_info *li;
-	int i, s_i;
-
-	s_i = cb->args[4];
-	i = 0;
-
-	/* rcu_read_lock is hold by caller */
-	hlist_for_each_entry_rcu(li, &l->list, hlist) {
-		if (i < s_i) {
-			i++;
-			continue;
-		}
-
-		if (i > s_i)
-			cb->args[5] = 0;
-
-		if (hlist_empty(&li->falh))
-			continue;
-
-		if (fn_trie_dump_fa(l->key, &li->falh, tb, skb, cb) < 0) {
 			cb->args[4] = i;
 			return -1;
 		}
@@ -1852,8 +1713,7 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   max(sizeof(struct tnode),
-					       sizeof(struct leaf_info)),
+					   sizeof(struct tnode),
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1975,14 +1835,14 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 	rcu_read_lock();
 	for (n = fib_trie_get_first(&iter, t); n; n = fib_trie_get_next(&iter)) {
 		if (IS_LEAF(n)) {
-			struct leaf_info *li;
+			struct fib_alias *fa;
 
 			s->leaves++;
 			s->totdepth += iter.depth;
 			if (iter.depth > s->maxdepth)
 				s->maxdepth = iter.depth;
 
-			hlist_for_each_entry_rcu(li, &n->list, hlist)
+			hlist_for_each_entry_rcu(fa, &n->leaf, fa_list)
 				++s->prefixes;
 		} else {
 			s->tnodes++;
@@ -2014,7 +1874,7 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	bytes = sizeof(struct tnode) * stat->leaves;
 
 	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
-	bytes += sizeof(struct leaf_info) * stat->prefixes;
+	bytes += sizeof(struct fib_alias) * stat->prefixes;
 
 	seq_printf(seq, "\tInternal nodes: %u\n\t", stat->tnodes);
 	bytes += sizeof(struct tnode) * stat->tnodes;
@@ -2265,29 +2125,25 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 			   &prf, KEYLENGTH - n->pos - n->bits, n->bits,
 			   n->full_children, n->empty_children);
 	} else {
-		struct leaf_info *li;
 		__be32 val = htonl(n->key);
+		struct fib_alias *fa;
 
 		seq_indent(seq, iter->depth);
 		seq_printf(seq, "  |-- %pI4\n", &val);
 
-		hlist_for_each_entry_rcu(li, &n->list, hlist) {
-			struct fib_alias *fa;
-
-			hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
-				char buf1[32], buf2[32];
-
-				seq_indent(seq, iter->depth+1);
-				seq_printf(seq, "  /%zu %s %s",
-					   KEYLENGTH - fa->fa_slen,
-					   rtn_scope(buf1, sizeof(buf1),
-						     fa->fa_info->fib_scope),
-					   rtn_type(buf2, sizeof(buf2),
-						    fa->fa_type));
-				if (fa->fa_tos)
-					seq_printf(seq, " tos=%d", fa->fa_tos);
-				seq_putc(seq, '\n');
-			}
+		hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
+			char buf1[32], buf2[32];
+
+			seq_indent(seq, iter->depth + 1);
+			seq_printf(seq, "  /%zu %s %s",
+				   KEYLENGTH - fa->fa_slen,
+				   rtn_scope(buf1, sizeof(buf1),
+					     fa->fa_info->fib_scope),
+				   rtn_type(buf2, sizeof(buf2),
+					    fa->fa_type));
+			if (fa->fa_tos)
+				seq_printf(seq, " tos=%d", fa->fa_tos);
+			seq_putc(seq, '\n');
 		}
 	}
 
@@ -2415,8 +2271,8 @@ static unsigned int fib_flag_trans(int type, __be32 mask, const struct fib_info
  */
 static int fib_route_seq_show(struct seq_file *seq, void *v)
 {
+	struct fib_alias *fa;
 	struct tnode *l = v;
-	struct leaf_info *li;
 	__be32 prefix;
 
 	if (v == SEQ_START_TOKEN) {
@@ -2428,42 +2284,38 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 
 	prefix = htonl(l->key);
 
-	hlist_for_each_entry_rcu(li, &l->list, hlist) {
-		struct fib_alias *fa;
-
-		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
-			const struct fib_info *fi = fa->fa_info;
-			__be32 mask = inet_make_mask(KEYLENGTH - fa->fa_slen);
-			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
+	hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
+		const struct fib_info *fi = fa->fa_info;
+		__be32 mask = inet_make_mask(KEYLENGTH - fa->fa_slen);
+		unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
 
-			if (fa->fa_type == RTN_BROADCAST
-			    || fa->fa_type == RTN_MULTICAST)
-				continue;
+		if ((fa->fa_type == RTN_BROADCAST) ||
+		    (fa->fa_type == RTN_MULTICAST))
+			continue;
 
-			seq_setwidth(seq, 127);
-
-			if (fi)
-				seq_printf(seq,
-					 "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u",
-					 fi->fib_dev ? fi->fib_dev->name : "*",
-					 prefix,
-					 fi->fib_nh->nh_gw, flags, 0, 0,
-					 fi->fib_priority,
-					 mask,
-					 (fi->fib_advmss ?
-					  fi->fib_advmss + 40 : 0),
-					 fi->fib_window,
-					 fi->fib_rtt >> 3);
-			else
-				seq_printf(seq,
-					 "*\t%08X\t%08X\t%04X\t%d\t%u\t"
-					 "%d\t%08X\t%d\t%u\t%u",
-					 prefix, 0, flags, 0, 0, 0,
-					 mask, 0, 0, 0);
+		seq_setwidth(seq, 127);
+
+		if (fi)
+			seq_printf(seq,
+				   "%s\t%08X\t%08X\t%04X\t%d\t%u\t"
+				   "%d\t%08X\t%d\t%u\t%u",
+				   fi->fib_dev ? fi->fib_dev->name : "*",
+				   prefix,
+				   fi->fib_nh->nh_gw, flags, 0, 0,
+				   fi->fib_priority,
+				   mask,
+				   (fi->fib_advmss ?
+				    fi->fib_advmss + 40 : 0),
+				   fi->fib_window,
+				   fi->fib_rtt >> 3);
+		else
+			seq_printf(seq,
+				   "*\t%08X\t%08X\t%04X\t%d\t%u\t"
+				   "%d\t%08X\t%d\t%u\t%u",
+				   prefix, 0, flags, 0, 0, 0,
+				   mask, 0, 0, 0);
 
-			seq_pad(seq, '\n');
-		}
+		seq_pad(seq, '\n');
 	}
 
 	return 0;
