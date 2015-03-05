From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH] ipv4: FIB Local/MAIN table collapse
Date: Thu, 05 Mar 2015 15:12:12 -0800
Message-ID: <20150305230029.1987.68126.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752512AbbCEXMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 18:12:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is meant to collapse local and main into one by converting
tb_data from an array to a pointer.  Doing this allows us to point the
local table into the main while maintaining the same variables in the
table.

As such the tb_data was converted from an array to a pointer, and a new
array called data is added in order to still provide an object for tb_data
to point to.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

---

This is the latest version I have for the combined local/main trie.  It
applies on top of the patches I submitted earlier today.

The performance gains with this patch applied are fairly impressive.  I
have seen reductions of up to 40ns (from ~120ns to ~80ns) for routing
look-ups with the depth 7 local and main trie.

However, I belive this breaks things if custom rules are defined that try
to place another table between the local and main look-ups.  As such this
approach may only be usable if there are no custom rules or
CONFIG_IP_MULTIPLE_TABLES is not defined.  Another patch would be needed to
split or merge the tables depending on if custom rules are enabled or not.

 include/net/ip_fib.h    |   12 +++---------
 net/ipv4/fib_frontend.c |   17 ++++++++++-------
 net/ipv4/fib_trie.c     |   23 +++++++++++++++++++----
 3 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 825cb28..29b9e63 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -186,7 +186,8 @@ struct fib_table {
 	int			tb_default;
 	int			tb_num_default;
 	struct rcu_head		rcu;
-	unsigned long		tb_data[0];
+	unsigned long 		*tb_data;
+	unsigned long		__data[0];
 };
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
@@ -233,9 +234,6 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 	rcu_read_lock();
 
 	for (err = 0; !err; err = -ENETUNREACH) {
-		tb = fib_get_table(net, RT_TABLE_LOCAL);
-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
-			break;
 		tb = fib_get_table(net, RT_TABLE_MAIN);
 		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
 			break;
@@ -269,10 +267,6 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 	res->tclassid = 0;
 
 	for (err = 0; !err; err = -ENETUNREACH) {
-		tb = rcu_dereference_rtnl(net->ipv4.fib_local);
-		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
-			break;
-
 		tb = rcu_dereference_rtnl(net->ipv4.fib_main);
 		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
 			break;
@@ -318,7 +312,7 @@ void fib_select_multipath(struct fib_result *res);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
-struct fib_table *fib_trie_table(u32 id);
+struct fib_table *fib_trie_table(u32 id, struct fib_table *alias);
 
 static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 {
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 220c4b4..b1adda9 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -52,14 +52,14 @@ static int __net_init fib4_rules_init(struct net *net)
 {
 	struct fib_table *local_table, *main_table;
 
-	local_table = fib_trie_table(RT_TABLE_LOCAL);
-	if (local_table == NULL)
-		return -ENOMEM;
-
-	main_table  = fib_trie_table(RT_TABLE_MAIN);
+	main_table  = fib_trie_table(RT_TABLE_MAIN, NULL);
 	if (main_table == NULL)
 		goto fail;
 
+	local_table = fib_trie_table(RT_TABLE_LOCAL, main_table);
+	if (local_table == NULL)
+		return -ENOMEM;
+
 	hlist_add_head_rcu(&local_table->tb_hlist,
 				&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX]);
 	hlist_add_head_rcu(&main_table->tb_hlist,
@@ -74,7 +74,7 @@ fail:
 
 struct fib_table *fib_new_table(struct net *net, u32 id)
 {
-	struct fib_table *tb;
+	struct fib_table *tb, *alias = NULL;
 	unsigned int h;
 
 	if (id == 0)
@@ -83,7 +83,10 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 	if (tb)
 		return tb;
 
-	tb = fib_trie_table(id);
+	if (id == RT_TABLE_LOCAL)
+		alias = fib_new_table(net, RT_TABLE_MAIN);
+
+	tb = fib_trie_table(id, alias);
 	if (!tb)
 		return NULL;
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 86f2d50..cf3ff18 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1220,7 +1220,7 @@ static inline t_key prefix_mismatch(t_key key, struct key_vector *n)
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags)
 {
-	struct trie *t = (struct trie *)tb->tb_data;
+	struct trie *t = (struct trie *) tb->tb_data;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
@@ -1628,7 +1628,8 @@ static void __trie_free_rcu(struct rcu_head *head)
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie *t = (struct trie *)tb->tb_data;
 
-	free_percpu(t->stats);
+	if (tb->tb_data == tb->__data)
+		free_percpu(t->stats);
 #endif /* CONFIG_IP_FIB_TRIE_STATS */
 	kfree(tb);
 }
@@ -1655,6 +1656,12 @@ static int fn_trie_dump_leaf(struct key_vector *l, struct fib_table *tb,
 			continue;
 		}
 
+		if (tb->tb_id == ((fa->fa_type == RTN_LOCAL) ? RT_TABLE_MAIN :
+							       RT_TABLE_LOCAL)) {
+			i++;
+			continue;
+		}
+
 		if (fib_dump_info(skb, NETLINK_CB(cb->skb).portid,
 				  cb->nlh->nlmsg_seq,
 				  RTM_NEWROUTE,
@@ -1721,18 +1728,26 @@ void __init fib_trie_init(void)
 					   0, SLAB_PANIC, NULL);
 }
 
-struct fib_table *fib_trie_table(u32 id)
+struct fib_table *fib_trie_table(u32 id, struct fib_table *alias)
 {
 	struct fib_table *tb;
 	struct trie *t;
+	size_t sz = sizeof(*tb);
 
-	tb = kzalloc(sizeof(*tb) + sizeof(struct trie), GFP_KERNEL);
+	if (!alias)
+		sz += sizeof(struct trie);
+
+	tb = kzalloc(sz, GFP_KERNEL);
 	if (tb == NULL)
 		return NULL;
 
 	tb->tb_id = id;
 	tb->tb_default = -1;
 	tb->tb_num_default = 0;
+	tb->tb_data = (alias ? alias->__data : tb->__data);
+
+	if (alias)
+		return tb;
 
 	t = (struct trie *) tb->tb_data;
 	t->kv[0].pos = KEYLENGTH;
