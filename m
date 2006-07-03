From: Patrick McHardy <kaber@trash.net>
Subject: [RFC IPV4 03/04]: Increase number of possible routing tables to 2^32
Date: Mon,  3 Jul 2006 09:53:04 +0200 (MEST)
Message-ID: <20060703075304.6286.58323.sendpatchset@localhost.localdomain>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:24784 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750745AbWGCHxF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 03:53:05 -0400
To: davem@davemloft.net
In-Reply-To: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Increase number of possible routing tables to 2^32

Increase the nubmer of possible routing tables to 2^32 by replacing the
fixed sized array of tables by a hash table.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit aab791510bc6fb2392ac361b0375f60a24b02659
tree f198102cd18b1a6233c573cf4f1f5f0b8827e724
parent 8cf1ae7345f935350dede855381dfbb620cabc1c
author Patrick McHardy <kaber@trash.net> Mon, 03 Jul 2006 09:21:22 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 03 Jul 2006 09:21:22 +0200

 include/linux/rtnetlink.h |    3 -
 include/net/ip_fib.h      |   25 ++---------
 net/ipv4/fib_frontend.c   |  100 ++++++++++++++++++++++++++++++---------------
 net/ipv4/fib_hash.c       |   26 ++++++------
 net/ipv4/fib_rules.c      |    4 +-
 net/ipv4/fib_trie.c       |   26 ++++++------
 6 files changed, 100 insertions(+), 84 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8f6efff..c1217e4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -238,9 +238,8 @@ enum rt_class_t
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
-	__RT_TABLE_MAX
 };
-#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
+#define RT_TABLE_MAX 0xFFFFFFFF
 
 
 
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ddc3ced..4b764e2 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -149,6 +149,7 @@ #define FIB_RES_NETMASK(res)	        (0)
 #endif /* CONFIG_IP_ROUTE_MULTIPATH_WRANDOM */
 
 struct fib_table {
+	struct hlist_node tb_hlist;
 	u32		tb_id;
 	unsigned	tb_stamp;
 	int		(*tb_lookup)(struct fib_table *tb, const struct flowi *flp, struct fib_result *res);
@@ -199,30 +200,14 @@ static inline void fib_select_default(co
 }
 
 #else /* CONFIG_IP_MULTIPLE_TABLES */
-#define ip_fib_local_table (fib_tables[RT_TABLE_LOCAL])
-#define ip_fib_main_table (fib_tables[RT_TABLE_MAIN])
+#define ip_fib_local_table fib_get_table(RT_TABLE_LOCAL)
+#define ip_fib_main_table fib_get_table(RT_TABLE_MAIN)
 
-extern struct fib_table * fib_tables[RT_TABLE_MAX+1];
 extern int fib_lookup(const struct flowi *flp, struct fib_result *res);
-extern struct fib_table *__fib_new_table(u32 id);
+extern struct fib_table *fib_new_table(u32 id);
+extern struct fib_table *fib_get_table(u32 id);
 extern void fib_rule_put(struct fib_rule *r);
 
-static inline struct fib_table *fib_get_table(u32 id)
-{
-	if (id == 0)
-		id = RT_TABLE_MAIN;
-
-	return fib_tables[id];
-}
-
-static inline struct fib_table *fib_new_table(u32 id)
-{
-	if (id == 0)
-		id = RT_TABLE_MAIN;
-
-	return fib_tables[id] ? : __fib_new_table(id);
-}
-
 extern void fib_select_default(const struct flowi *flp, struct fib_result *res);
 
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2f54f22..3c49e6b 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -36,6 +36,7 @@ #include <linux/if_arp.h>
 #include <linux/skbuff.h>
 #include <linux/netlink.h>
 #include <linux/init.h>
+#include <linux/list.h>
 
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -50,48 +51,67 @@ #define FFprint(a...) printk(KERN_DEBUG 
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
-#define RT_TABLE_MIN RT_TABLE_MAIN
-
 struct fib_table *ip_fib_local_table;
 struct fib_table *ip_fib_main_table;
 
-#else
+#define FIB_TABLE_HASHSZ 1
+static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
 
-#define RT_TABLE_MIN 1
+#else
 
-struct fib_table *fib_tables[RT_TABLE_MAX+1];
+#define FIB_TABLE_HASHSZ 256
+static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
 
-struct fib_table *__fib_new_table(u32 id)
+struct fib_table *fib_new_table(u32 id)
 {
 	struct fib_table *tb;
+	unsigned int h;
 
+	if (id == 0)
+		id = RT_TABLE_MAIN;
+	tb = fib_get_table(id);
+	if (tb)
+		return tb;
 	tb = fib_hash_init(id);
 	if (!tb)
 		return NULL;
-	fib_tables[id] = tb;
+	h = id & (FIB_TABLE_HASHSZ - 1);
+	hlist_add_head_rcu(&tb->tb_hlist, &fib_table_hash[h]);
 	return tb;
 }
 
+struct fib_table *fib_get_table(u32 id)
+{
+	struct fib_table *tb;
+	struct hlist_node *node;
+	unsigned int h;
 
+	if (id == 0)
+		id = RT_TABLE_MAIN;
+	h = id & (FIB_TABLE_HASHSZ - 1);
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tb, node, &fib_table_hash[h], tb_hlist) {
+		if (tb->tb_id == id) {
+			rcu_read_unlock();
+			return tb;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
-
 static void fib_flush(void)
 {
 	int flushed = 0;
-#ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_table *tb;
-	u32 id;
+	struct hlist_node *node;
+	unsigned int h;
 
-	for (id = RT_TABLE_MAX; id>0; id--) {
-		if ((tb = fib_get_table(id))==NULL)
-			continue;
-		flushed += tb->tb_flush(tb);
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		hlist_for_each_entry(tb, node, &fib_table_hash[h], tb_hlist)
+			flushed += tb->tb_flush(tb);
 	}
-#else /* CONFIG_IP_MULTIPLE_TABLES */
-	flushed += ip_fib_main_table->tb_flush(ip_fib_main_table);
-	flushed += ip_fib_local_table->tb_flush(ip_fib_local_table);
-#endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 	if (flushed)
 		rt_cache_flush(-1);
@@ -333,29 +353,35 @@ int inet_rtm_newroute(struct sk_buff *sk
 
 int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	u32 t;
-	u32 s_t;
+	unsigned int h, s_h;
+	unsigned int e = 0, s_e;
 	struct fib_table *tb;
+	struct hlist_node *node;
 
 	if (NLMSG_PAYLOAD(cb->nlh, 0) >= sizeof(struct rtmsg) &&
 	    ((struct rtmsg*)NLMSG_DATA(cb->nlh))->rtm_flags&RTM_F_CLONED)
 		return ip_rt_dump(skb, cb);
 
-	s_t = cb->args[0];
-	if (s_t == 0)
-		s_t = cb->args[0] = RT_TABLE_MIN;
-
-	for (t=s_t; t<=RT_TABLE_MAX; t++) {
-		if (t < s_t) continue;
-		if (t > s_t)
-			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
-		if ((tb = fib_get_table(t))==NULL)
-			continue;
-		if (tb->tb_dump(tb, skb, cb) < 0) 
-			break;
+	s_h = cb->args[0];
+	s_e = cb->args[1];
+
+	for (h = s_h; h < FIB_TABLE_HASHSZ; h++) {
+		e = 0;
+		hlist_for_each_entry(tb, node, &fib_table_hash[h], tb_hlist) {
+			if (e < s_e)
+				goto next;
+			if (e > s_e)
+				memset(&cb->args[1], 0, sizeof(cb->args) -
+				                 2 * sizeof(cb->args[0]));
+			if (tb->tb_dump(tb, skb, cb) < 0)
+				goto out;
+next:
+			e++;
+		}
 	}
-
-	cb->args[0] = t;
+out:
+	cb->args[1] = e;
+	cb->args[0] = h;
 
 	return skb->len;
 }
@@ -653,9 +679,15 @@ static struct notifier_block fib_netdev_
 
 void __init ip_fib_init(void)
 {
+	unsigned int i;
+
+	for (i = 0; i < FIB_TABLE_HASHSZ; i++)
+		INIT_HLIST_HEAD(&fib_table_hash[i]);
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
+	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
 	ip_fib_main_table  = fib_hash_init(RT_TABLE_MAIN);
+	hlist_add_head_rcu(&ip_fib_main_table->tb_hlist, &fib_table_hash[0]);
 #else
 	fib_rules_init();
 #endif
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 4b79173..fcbf2d6 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -685,7 +685,7 @@ fn_hash_dump_bucket(struct sk_buff *skb,
 	struct fib_node *f;
 	int i, s_i;
 
-	s_i = cb->args[3];
+	s_i = cb->args[4];
 	i = 0;
 	hlist_for_each_entry(f, node, head, fn_hash) {
 		struct fib_alias *fa;
@@ -705,14 +705,14 @@ fn_hash_dump_bucket(struct sk_buff *skb,
 					  fa->fa_tos,
 					  fa->fa_info,
 					  NLM_F_MULTI) < 0) {
-				cb->args[3] = i;
+				cb->args[4] = i;
 				return -1;
 			}
 		next:
 			i++;
 		}
 	}
-	cb->args[3] = i;
+	cb->args[4] = i;
 	return skb->len;
 }
 
@@ -723,21 +723,21 @@ fn_hash_dump_zone(struct sk_buff *skb, s
 {
 	int h, s_h;
 
-	s_h = cb->args[2];
+	s_h = cb->args[3];
 	for (h=0; h < fz->fz_divisor; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
-			memset(&cb->args[3], 0,
-			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+			memset(&cb->args[4], 0,
+			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
 		if (fz->fz_hash == NULL ||
 		    hlist_empty(&fz->fz_hash[h]))
 			continue;
 		if (fn_hash_dump_bucket(skb, cb, tb, fz, &fz->fz_hash[h])<0) {
-			cb->args[2] = h;
+			cb->args[3] = h;
 			return -1;
 		}
 	}
-	cb->args[2] = h;
+	cb->args[3] = h;
 	return skb->len;
 }
 
@@ -747,21 +747,21 @@ static int fn_hash_dump(struct fib_table
 	struct fn_zone *fz;
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
 
-	s_m = cb->args[1];
+	s_m = cb->args[2];
 	read_lock(&fib_hash_lock);
 	for (fz = table->fn_zone_list, m=0; fz; fz = fz->fz_next, m++) {
 		if (m < s_m) continue;
 		if (m > s_m)
-			memset(&cb->args[2], 0,
-			       sizeof(cb->args) - 2*sizeof(cb->args[0]));
+			memset(&cb->args[3], 0,
+			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
 		if (fn_hash_dump_zone(skb, cb, tb, fz) < 0) {
-			cb->args[1] = m;
+			cb->args[2] = m;
 			read_unlock(&fib_hash_lock);
 			return -1;
 		}
 	}
 	read_unlock(&fib_hash_lock);
-	cb->args[1] = m;
+	cb->args[2] = m;
 	return skb->len;
 }
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index e6d1f5a..a41ab4b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -149,8 +149,8 @@ static struct fib_table *fib_empty_table
 	u32 id;
 
 	for (id = 1; id <= RT_TABLE_MAX; id++)
-		if (fib_tables[id] == NULL)
-			return __fib_new_table(id);
+		if (fib_get_table(id) == NULL)
+			return fib_new_table(id);
 	return NULL;
 }
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3936f16..92b1d77 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1848,7 +1848,7 @@ static int fn_trie_dump_fa(t_key key, in
 
 	u32 xkey = htonl(key);
 
-	s_i = cb->args[3];
+	s_i = cb->args[4];
 	i = 0;
 
 	/* rcu_read_lock is hold by caller */
@@ -1870,12 +1870,12 @@ static int fn_trie_dump_fa(t_key key, in
 				  plen,
 				  fa->fa_tos,
 				  fa->fa_info, 0) < 0) {
-			cb->args[3] = i;
+			cb->args[4] = i;
 			return -1;
 		}
 		i++;
 	}
-	cb->args[3] = i;
+	cb->args[4] = i;
 	return skb->len;
 }
 
@@ -1886,14 +1886,14 @@ static int fn_trie_dump_plen(struct trie
 	struct list_head *fa_head;
 	struct leaf *l = NULL;
 
-	s_h = cb->args[2];
+	s_h = cb->args[3];
 
 	for (h = 0; (l = nextleaf(t, l)) != NULL; h++) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)
-			memset(&cb->args[3], 0,
-			       sizeof(cb->args) - 3*sizeof(cb->args[0]));
+			memset(&cb->args[4], 0,
+			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
 
 		fa_head = get_fa_head(l, plen);
 
@@ -1904,11 +1904,11 @@ static int fn_trie_dump_plen(struct trie
 			continue;
 
 		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb)<0) {
-			cb->args[2] = h;
+			cb->args[3] = h;
 			return -1;
 		}
 	}
-	cb->args[2] = h;
+	cb->args[3] = h;
 	return skb->len;
 }
 
@@ -1917,23 +1917,23 @@ static int fn_trie_dump(struct fib_table
 	int m, s_m;
 	struct trie *t = (struct trie *) tb->tb_data;
 
-	s_m = cb->args[1];
+	s_m = cb->args[2];
 
 	rcu_read_lock();
 	for (m = 0; m <= 32; m++) {
 		if (m < s_m)
 			continue;
 		if (m > s_m)
-			memset(&cb->args[2], 0,
-				sizeof(cb->args) - 2*sizeof(cb->args[0]));
+			memset(&cb->args[3], 0,
+				sizeof(cb->args) - 3*sizeof(cb->args[0]));
 
 		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb)<0) {
-			cb->args[1] = m;
+			cb->args[2] = m;
 			goto out;
 		}
 	}
 	rcu_read_unlock();
-	cb->args[1] = m;
+	cb->args[2] = m;
 	return skb->len;
 out:
 	rcu_read_unlock();
