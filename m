From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 6/8] fib_trie: Make fib_table rcu safe
Date: Wed, 04 Mar 2015 15:02:44 -0800
Message-ID: <20150304230239.1612.65771.stgit@ahduyck-vm-fedora20>
References: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736AbbCDXCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 18:02:47 -0500
In-Reply-To: <20150304225459.1612.45514.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib_table was wrapped in several places with an
rcu_read_lock/rcu_read_unlock however after looking over the code I found
several spots where the tables were being accessed as just standard
pointers without any protections.  This change fixes that so that all of
the proper protections are in place when accessing the table to take RCU
replacement or removal of the table into account.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/net/ip_fib.h     |   70 ++++++++++++++++++++++++++++------------------
 include/net/netns/ipv4.h |    7 +++--
 net/ipv4/fib_frontend.c  |   52 ++++++++++++++++++++++++----------
 net/ipv4/fib_trie.c      |   21 ++++++++++----
 4 files changed, 98 insertions(+), 52 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index cba4b7c..825cb28 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -185,6 +185,7 @@ struct fib_table {
 	u32			tb_id;
 	int			tb_default;
 	int			tb_num_default;
+	struct rcu_head		rcu;
 	unsigned long		tb_data[0];
 };
 
@@ -206,12 +207,16 @@ void fib_free_table(struct fib_table *tb);
 
 static inline struct fib_table *fib_get_table(struct net *net, u32 id)
 {
+	struct hlist_node *tb_hlist;
 	struct hlist_head *ptr;
 
 	ptr = id == RT_TABLE_LOCAL ?
 		&net->ipv4.fib_table_hash[TABLE_LOCAL_INDEX] :
 		&net->ipv4.fib_table_hash[TABLE_MAIN_INDEX];
-	return hlist_entry(ptr->first, struct fib_table, tb_hlist);
+
+	tb_hlist = rcu_dereference_rtnl(hlist_first_rcu(ptr));
+
+	return hlist_entry(tb_hlist, struct fib_table, tb_hlist);
 }
 
 static inline struct fib_table *fib_new_table(struct net *net, u32 id)
@@ -222,15 +227,19 @@ static inline struct fib_table *fib_new_table(struct net *net, u32 id)
 static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 			     struct fib_result *res)
 {
-	int err = -ENETUNREACH;
+	struct fib_table *tb;
+	int err;
 
 	rcu_read_lock();
 
-	if (!fib_table_lookup(fib_get_table(net, RT_TABLE_LOCAL), flp, res,
-			      FIB_LOOKUP_NOREF) ||
-	    !fib_table_lookup(fib_get_table(net, RT_TABLE_MAIN), flp, res,
-			      FIB_LOOKUP_NOREF))
-		err = 0;
+	for (err = 0; !err; err = -ENETUNREACH) {
+		tb = fib_get_table(net, RT_TABLE_LOCAL);
+		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+			break;
+		tb = fib_get_table(net, RT_TABLE_MAIN);
+		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+			break;
+	}
 
 	rcu_read_unlock();
 
@@ -249,28 +258,33 @@ int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res);
 static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			     struct fib_result *res)
 {
-	if (!net->ipv4.fib_has_custom_rules) {
-		int err = -ENETUNREACH;
-
-		rcu_read_lock();
-
-		res->tclassid = 0;
-		if ((net->ipv4.fib_local &&
-		     !fib_table_lookup(net->ipv4.fib_local, flp, res,
-				       FIB_LOOKUP_NOREF)) ||
-		    (net->ipv4.fib_main &&
-		     !fib_table_lookup(net->ipv4.fib_main, flp, res,
-				       FIB_LOOKUP_NOREF)) ||
-		    (net->ipv4.fib_default &&
-		     !fib_table_lookup(net->ipv4.fib_default, flp, res,
-				       FIB_LOOKUP_NOREF)))
-			err = 0;
-
-		rcu_read_unlock();
-
-		return err;
+	struct fib_table *tb;
+	int err;
+
+	if (net->ipv4.fib_has_custom_rules)
+		return __fib_lookup(net, flp, res);
+
+	rcu_read_lock();
+
+	res->tclassid = 0;
+
+	for (err = 0; !err; err = -ENETUNREACH) {
+		tb = rcu_dereference_rtnl(net->ipv4.fib_local);
+		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+			break;
+
+		tb = rcu_dereference_rtnl(net->ipv4.fib_main);
+		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+			break;
+
+		tb = rcu_dereference_rtnl(net->ipv4.fib_default);
+		if (tb && !fib_table_lookup(tb, flp, res, FIB_LOOKUP_NOREF))
+			break;
 	}
-	return __fib_lookup(net, flp, res);
+
+	rcu_read_unlock();
+
+	return err;
 }
 
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1b26c6c..db1db15 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -7,6 +7,7 @@
 
 #include <linux/uidgid.h>
 #include <net/inet_frag.h>
+#include <linux/rcupdate.h>
 
 struct tcpm_hash_bucket;
 struct ctl_table_header;
@@ -38,9 +39,9 @@ struct netns_ipv4 {
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	struct fib_rules_ops	*rules_ops;
 	bool			fib_has_custom_rules;
-	struct fib_table	*fib_local;
-	struct fib_table	*fib_main;
-	struct fib_table	*fib_default;
+	struct fib_table __rcu	*fib_local;
+	struct fib_table __rcu	*fib_main;
+	struct fib_table __rcu	*fib_default;
 #endif
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	int			fib_num_tclassid_users;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 57be71d..220c4b4 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -89,17 +89,14 @@ struct fib_table *fib_new_table(struct net *net, u32 id)
 
 	switch (id) {
 	case RT_TABLE_LOCAL:
-		net->ipv4.fib_local = tb;
+		rcu_assign_pointer(net->ipv4.fib_local, tb);
 		break;
-
 	case RT_TABLE_MAIN:
-		net->ipv4.fib_main = tb;
+		rcu_assign_pointer(net->ipv4.fib_main, tb);
 		break;
-
 	case RT_TABLE_DEFAULT:
-		net->ipv4.fib_default = tb;
+		rcu_assign_pointer(net->ipv4.fib_default, tb);
 		break;
-
 	default:
 		break;
 	}
@@ -132,13 +129,14 @@ struct fib_table *fib_get_table(struct net *net, u32 id)
 static void fib_flush(struct net *net)
 {
 	int flushed = 0;
-	struct fib_table *tb;
-	struct hlist_head *head;
 	unsigned int h;
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
-		head = &net->ipv4.fib_table_hash[h];
-		hlist_for_each_entry(tb, head, tb_hlist)
+		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
+		struct hlist_node *tmp;
+		struct fib_table *tb;
+
+		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
 			flushed += fib_table_flush(tb);
 	}
 
@@ -665,10 +663,12 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[0];
 	s_e = cb->args[1];
 
+	rcu_read_lock();
+
 	for (h = s_h; h < FIB_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
 		head = &net->ipv4.fib_table_hash[h];
-		hlist_for_each_entry(tb, head, tb_hlist) {
+		hlist_for_each_entry_rcu(tb, head, tb_hlist) {
 			if (e < s_e)
 				goto next;
 			if (dumped)
@@ -682,6 +682,8 @@ next:
 		}
 	}
 out:
+	rcu_read_unlock();
+
 	cb->args[1] = e;
 	cb->args[0] = h;
 
@@ -1117,14 +1119,34 @@ static void ip_fib_net_exit(struct net *net)
 
 	rtnl_lock();
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
-		struct fib_table *tb;
-		struct hlist_head *head;
+		struct hlist_head *head = &net->ipv4.fib_table_hash[i];
 		struct hlist_node *tmp;
+		struct fib_table *tb;
+
+		/* this is done in two passes as flushing the table could
+		 * cause it to be reallocated in order to accommodate new
+		 * tnodes at the root as the table shrinks.
+		 */
+		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
+			fib_table_flush(tb);
 
-		head = &net->ipv4.fib_table_hash[i];
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist) {
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+			switch (tb->tb_id) {
+			case RT_TABLE_LOCAL:
+				RCU_INIT_POINTER(net->ipv4.fib_local, NULL);
+				break;
+			case RT_TABLE_MAIN:
+				RCU_INIT_POINTER(net->ipv4.fib_main, NULL);
+				break;
+			case RT_TABLE_DEFAULT:
+				RCU_INIT_POINTER(net->ipv4.fib_default, NULL);
+				break;
+			default:
+				break;
+			}
+#endif
 			hlist_del(&tb->tb_hlist);
-			fib_table_flush(tb);
 			fib_free_table(tb);
 		}
 	}
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2233ebf2..3642b17 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -193,6 +193,13 @@ static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn,
 	return rcu_dereference_rtnl(tn->tnode[i]);
 }
 
+static inline struct fib_table *trie_get_table(struct trie *t)
+{
+	unsigned long *tb_data = (unsigned long *)t;
+
+	return container_of(tb_data, struct fib_table, tb_data[0]);
+}
+
 /* To understand this stuff, an understanding of keys and all their bits is
  * necessary. Every node in the trie has a key associated with it, but not
  * all of the bits in that key are significant.
@@ -1593,8 +1600,9 @@ flush_complete:
 	return found;
 }
 
-void fib_free_table(struct fib_table *tb)
+static void __trie_free_rcu(struct rcu_head *head)
 {
+	struct fib_table *tb = container_of(head, struct fib_table, rcu);
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	struct trie *t = (struct trie *)tb->tb_data;
 
@@ -1603,6 +1611,11 @@ void fib_free_table(struct fib_table *tb)
 	kfree(tb);
 }
 
+void fib_free_table(struct fib_table *tb)
+{
+	call_rcu(&tb->rcu, __trie_free_rcu);
+}
+
 static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 			     struct sk_buff *skb, struct netlink_callback *cb)
 {
@@ -1639,6 +1652,7 @@ static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 	return skb->len;
 }
 
+/* rcu_read_lock needs to be hold by caller from readside */
 int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 		   struct netlink_callback *cb)
 {
@@ -1650,15 +1664,12 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 	int count = cb->args[2];
 	t_key key = cb->args[3];
 
-	rcu_read_lock();
-
 	tp = rcu_dereference_rtnl(t->trie);
 
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
 			cb->args[3] = key;
 			cb->args[2] = count;
-			rcu_read_unlock();
 			return -1;
 		}
 
@@ -1673,8 +1684,6 @@ int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 			break;
 	}
 
-	rcu_read_unlock();
-
 	cb->args[3] = key;
 	cb->args[2] = count;
 
