From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 1/4] fib_trie: Convert fib_alias to hlist from
 list
Date: Wed, 25 Feb 2015 15:31:31 -0800
Message-ID: <20150225233131.1242.75208.stgit@ahduyck-vm-fedora20>
References: <20150225232731.1242.38553.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbbBYXbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 18:31:40 -0500
In-Reply-To: <20150225232731.1242.38553.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There isn't any advantage to having it as a list and by making it an hlist
we make the fib_alias more compatible with the list_info in terms of the
type of list used.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/net/ip_fib.h     |    2 +
 net/ipv4/fib_lookup.h    |    2 +
 net/ipv4/fib_semantics.c |    4 +-
 net/ipv4/fib_trie.c      |   80 +++++++++++++++++++++++++---------------------
 4 files changed, 48 insertions(+), 40 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5bd120e..cba4b7c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -136,7 +136,7 @@ struct fib_result {
 	u32		tclassid;
 	struct fib_info *fi;
 	struct fib_table *table;
-	struct list_head *fa_head;
+	struct hlist_head *fa_head;
 };
 
 struct fib_result_nl {
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 825981b..3cd444f 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -6,7 +6,7 @@
 #include <net/ip_fib.h>
 
 struct fib_alias {
-	struct list_head	fa_list;
+	struct hlist_node	fa_list;
 	struct fib_info		*fa_info;
 	u8			fa_tos;
 	u8			fa_type;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 1e2090e..c6d2674 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1163,12 +1163,12 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 void fib_select_default(struct fib_result *res)
 {
 	struct fib_info *fi = NULL, *last_resort = NULL;
-	struct list_head *fa_head = res->fa_head;
+	struct hlist_head *fa_head = res->fa_head;
 	struct fib_table *tb = res->table;
 	int order = -1, last_idx = -1;
 	struct fib_alias *fa;
 
-	list_for_each_entry_rcu(fa, fa_head, fa_list) {
+	hlist_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
 		if (next_fi->fib_scope != res->scope ||
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3daf022..f17e2239 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -116,7 +116,7 @@ struct leaf_info {
 	struct hlist_node hlist;
 	int plen;
 	u32 mask_plen; /* ntohl(inet_make_mask(plen)) */
-	struct list_head falh;
+	struct hlist_head falh;
 	struct rcu_head rcu;
 };
 
@@ -339,7 +339,7 @@ static struct leaf_info *leaf_info_new(int plen)
 	if (li) {
 		li->plen = plen;
 		li->mask_plen = ntohl(inet_make_mask(plen));
-		INIT_LIST_HEAD(&li->falh);
+		INIT_HLIST_HEAD(&li->falh);
 	}
 	return li;
 }
@@ -881,7 +881,7 @@ static struct leaf_info *find_leaf_info(struct tnode *l, int plen)
 	return NULL;
 }
 
-static inline struct list_head *get_fa_head(struct tnode *l, int plen)
+static inline struct hlist_head *get_fa_head(struct tnode *l, int plen)
 {
 	struct leaf_info *li = find_leaf_info(l, plen);
 
@@ -994,14 +994,15 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 /* Return the first fib alias matching TOS with
  * priority less than or equal to PRIO.
  */
-static struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
+static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 tos,
+					u32 prio)
 {
 	struct fib_alias *fa;
 
 	if (!fah)
 		return NULL;
 
-	list_for_each_entry(fa, fah, fa_list) {
+	hlist_for_each_entry(fa, fah, fa_list) {
 		if (fa->fa_tos > tos)
 			continue;
 		if (fa->fa_info->fib_priority >= prio || fa->fa_tos < tos)
@@ -1027,9 +1028,9 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 /* only used from updater-side */
 
-static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
+static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)
 {
-	struct list_head *fa_head = NULL;
+	struct hlist_head *fa_head = NULL;
 	struct tnode *l, *n, *tp = NULL;
 	struct leaf_info *li;
 
@@ -1130,7 +1131,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *new_fa;
-	struct list_head *fa_head = NULL;
+	struct hlist_head *fa_head = NULL;
 	struct fib_info *fi;
 	int plen = cfg->fc_dst_len;
 	u8 tos = cfg->fc_tos;
@@ -1171,10 +1172,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	 * exists or to the node before which we will insert new one.
 	 *
 	 * If fa is NULL, we will need to allocate a new one and
-	 * insert to the head of f.
-	 *
-	 * If f is NULL, no fib node matched the destination key
-	 * and we need to allocate a new one of those as well.
+	 * insert to the tail of the section matching the suffix length
+	 * of the new alias.
 	 */
 
 	if (fa && fa->fa_tos == tos &&
@@ -1192,8 +1191,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		 */
 		fa_match = NULL;
 		fa_first = fa;
-		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
-		list_for_each_entry_continue(fa, fa_head, fa_list) {
+		hlist_for_each_entry_from(fa, fa_list) {
 			if (fa->fa_tos != tos)
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
@@ -1227,7 +1225,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			state = fa->fa_state;
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 
-			list_replace_rcu(&fa->fa_list, &new_fa->fa_list);
+			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
 			alias_free_mem_rcu(fa);
 
 			fib_release_info(fi_drop);
@@ -1276,8 +1274,19 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	if (!plen)
 		tb->tb_num_default++;
 
-	list_add_tail_rcu(&new_fa->fa_list,
-			  (fa ? &fa->fa_list : fa_head));
+	if (fa) {
+		hlist_add_before_rcu(&new_fa->fa_list, &fa->fa_list);
+	} else {
+		struct fib_alias *last;
+
+		hlist_for_each_entry(last, fa_head, fa_list)
+			fa = last;
+
+		if (fa)
+			hlist_add_behind_rcu(&new_fa->fa_list, &fa->fa_list);
+		else
+			hlist_add_head_rcu(&new_fa->fa_list, fa_head);
+	}
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
@@ -1419,7 +1428,7 @@ found:
 		if ((key ^ n->key) & li->mask_plen)
 			continue;
 
-		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			struct fib_info *fi = fa->fa_info;
 			int nhsel, err;
 
@@ -1501,7 +1510,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	int plen = cfg->fc_dst_len;
 	u8 tos = cfg->fc_tos;
 	struct fib_alias *fa, *fa_to_delete;
-	struct list_head *fa_head;
+	struct hlist_head *fa_head;
 	struct tnode *l;
 	struct leaf_info *li;
 
@@ -1534,8 +1543,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	pr_debug("Deleting %08x/%d tos=%d t=%p\n", key, plen, tos, t);
 
 	fa_to_delete = NULL;
-	fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
-	list_for_each_entry_continue(fa, fa_head, fa_list) {
+	hlist_for_each_entry_from(fa, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fa->fa_tos != tos)
@@ -1561,12 +1569,12 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-	list_del_rcu(&fa->fa_list);
+	hlist_del_rcu(&fa->fa_list);
 
 	if (!plen)
 		tb->tb_num_default--;
 
-	if (list_empty(fa_head)) {
+	if (hlist_empty(fa_head)) {
 		remove_leaf_info(l, li);
 		free_leaf_info(li);
 	}
@@ -1582,16 +1590,17 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_list(struct list_head *head)
+static int trie_flush_list(struct hlist_head *head)
 {
-	struct fib_alias *fa, *fa_node;
+	struct hlist_node *tmp;
+	struct fib_alias *fa;
 	int found = 0;
 
-	list_for_each_entry_safe(fa, fa_node, head, fa_list) {
+	hlist_for_each_entry_safe(fa, tmp, head, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
-			list_del_rcu(&fa->fa_list);
+			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
 			found++;
@@ -1603,15 +1612,14 @@ static int trie_flush_list(struct list_head *head)
 static int trie_flush_leaf(struct tnode *l)
 {
 	int found = 0;
-	struct hlist_head *lih = &l->list;
 	struct hlist_node *tmp;
-	struct leaf_info *li = NULL;
+	struct leaf_info *li;
 	unsigned char plen = KEYLENGTH;
 
-	hlist_for_each_entry_safe(li, tmp, lih, hlist) {
+	hlist_for_each_entry_safe(li, tmp, &l->list, hlist) {
 		found += trie_flush_list(&li->falh);
 
-		if (list_empty(&li->falh)) {
+		if (hlist_empty(&li->falh)) {
 			hlist_del_rcu(&li->hlist);
 			free_leaf_info(li);
 			continue;
@@ -1731,7 +1739,7 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
-static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
+static int fn_trie_dump_fa(t_key key, int plen, struct hlist_head *fah,
 			   struct fib_table *tb,
 			   struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -1744,7 +1752,7 @@ static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
 
 	/* rcu_read_lock is hold by caller */
 
-	list_for_each_entry_rcu(fa, fah, fa_list) {
+	hlist_for_each_entry_rcu(fa, fah, fa_list) {
 		if (i < s_i) {
 			i++;
 			continue;
@@ -1787,7 +1795,7 @@ static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 		if (i > s_i)
 			cb->args[5] = 0;
 
-		if (list_empty(&li->falh))
+		if (hlist_empty(&li->falh))
 			continue;
 
 		if (fn_trie_dump_fa(l->key, li->plen, &li->falh, tb, skb, cb) < 0) {
@@ -2272,7 +2280,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		hlist_for_each_entry_rcu(li, &n->list, hlist) {
 			struct fib_alias *fa;
 
-			list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+			hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
 				char buf1[32], buf2[32];
 
 				seq_indent(seq, iter->depth+1);
@@ -2429,7 +2437,7 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		mask = inet_make_mask(li->plen);
 		prefix = htonl(l->key);
 
-		list_for_each_entry_rcu(fa, &li->falh, fa_list) {
+		hlist_for_each_entry_rcu(fa, &li->falh, fa_list) {
 			const struct fib_info *fi = fa->fa_info;
 			unsigned int flags = fib_flag_trans(fa->fa_type, mask, fi);
 
