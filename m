From: sfeldma@gmail.com
Subject: [PATCH net-next 4/4] switchdev: don't support custom ip rules, for now
Date: Mon,  2 Mar 2015 01:29:15 -0800
Message-ID: <1425288555-22598-5-git-send-email-sfeldma@gmail.com>
References: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44365 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbbCBJaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:30:13 -0500
Received: by padbj1 with SMTP id bj1so16430238pad.11
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:30:12 -0800 (PST)
In-Reply-To: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Keep switchdev FIB offload model simple for now and don't allow custom ip
rules.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/ip_fib.h      |    2 ++
 net/ipv4/fib_frontend.c   |   13 +++++++++++++
 net/ipv4/fib_rules.c      |    3 +++
 net/ipv4/fib_trie.c       |   27 +++++++++++++++++++++++++++
 net/switchdev/switchdev.c |    4 ++++
 5 files changed, 49 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index cba4b7c..894a75c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -195,6 +195,7 @@ int fib_table_delete(struct fib_table *, struct fib_config *);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
 int fib_table_flush(struct fib_table *table);
+void fib_table_flush_external(struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
 
 
@@ -294,6 +295,7 @@ static inline int fib_num_tclassid_users(struct net *net)
 	return 0;
 }
 #endif
+void fib_flush_external(struct net *net);
 
 /* Exported by fib_semantics.c */
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 57be71d..c33c19a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -146,6 +146,19 @@ static void fib_flush(struct net *net)
 		rt_cache_flush(net);
 }
 
+void fib_flush_external(struct net *net)
+{
+	struct fib_table *tb;
+	struct hlist_head *head;
+	unsigned int h;
+
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		head = &net->ipv4.fib_table_hash[h];
+		hlist_for_each_entry(tb, head, tb_hlist)
+			fib_table_flush_external(tb);
+	}
+}
+
 /*
  * Find address type as if only "dev" was present in the system. If
  * on_dev is NULL then all interfaces are taken into consideration.
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index d3db718..190d0d0 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -209,6 +209,8 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->tos = frh->tos;
 
 	net->ipv4.fib_has_custom_rules = true;
+	fib_flush_external(rule->fr_net);
+
 	err = 0;
 errout:
 	return err;
@@ -224,6 +226,7 @@ static void fib4_rule_delete(struct fib_rule *rule)
 		net->ipv4.fib_num_tclassid_users--;
 #endif
 	net->ipv4.fib_has_custom_rules = true;
+	fib_flush_external(rule->fr_net);
 }
 
 static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 90cd812..5a487a7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1517,6 +1517,23 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
+static void trie_flush_leaf_external(struct fib_table *tb, struct tnode *l)
+{
+	struct hlist_node *tmp;
+	struct fib_alias *fa;
+
+	hlist_for_each_entry_safe(fa, tmp, &l->leaf, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+
+		if (fi && (fi->fib_flags & RTNH_F_EXTERNAL)) {
+			netdev_switch_fib_ipv4_del(l->key,
+						   KEYLENGTH - fa->fa_slen,
+						   fi, fa->fa_tos,
+						   fa->fa_type, tb->tb_id);
+		}
+	}
+}
+
 static int trie_flush_leaf(struct fib_table *tb, struct tnode *l)
 {
 	struct hlist_node *tmp;
@@ -1643,6 +1660,16 @@ int fib_table_flush(struct fib_table *tb)
 	return found;
 }
 
+/* Caller must hold RTNL */
+void fib_table_flush_external(struct fib_table *tb)
+{
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct tnode *l;
+
+	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l))
+		trie_flush_leaf_external(tb, l);
+}
+
 void fib_free_table(struct fib_table *tb)
 {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a84bdb4..9f87f3f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -270,6 +270,10 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	const struct net_device_ops *ops;
 	int err = -EOPNOTSUPP;
 
+	/* Don't offload route if using custom ip rules */
+	if (fi->fib_net->ipv4.fib_has_custom_rules)
+		return -EOPNOTSUPP;
+
 	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
 	if (!dev)
 		return -EOPNOTSUPP;
-- 
1.7.10.4
