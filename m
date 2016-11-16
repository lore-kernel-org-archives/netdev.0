From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] ipv4: fib: Add an API to request a FIB dump
Date: Wed, 16 Nov 2016 15:09:01 +0100
Message-ID: <1479305343-13167-7-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34371 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753568AbcKPOJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:14 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so11560752wme.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:13 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Commit b90eb7549499 ("fib: introduce FIB notification infrastructure")
introduced a new notification chain to notify listeners (f.e., switchdev
drivers) about addition and deletion of routes.

However, upon registration to the chain the FIB tables can already be
populated, which means potential listeners will have an incomplete view
of the tables.

Solve that by adding an API to request a FIB dump. The dump itself it
done using RCU in order not to starve consumers that need RTNL to make
progress.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h |   1 +
 net/ipv4/fib_trie.c  | 108 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index b9314b4..095a374 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -221,6 +221,7 @@ enum fib_event_type {
 	FIB_EVENT_RULE_DEL,
 };
 
+void fib_notifier_dump(struct notifier_block *nb);
 int register_fib_notifier(struct notifier_block *nb);
 int unregister_fib_notifier(struct notifier_block *nb);
 int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2195601..9670f3f 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -86,6 +86,58 @@
 
 static ATOMIC_NOTIFIER_HEAD(fib_chain);
 
+static int call_fib_notifier(struct notifier_block *nb, struct net *net,
+			     enum fib_event_type event_type,
+			     struct fib_notifier_info *info)
+{
+	info->net = net;
+	return nb->notifier_call(nb, event_type, info);
+}
+
+static void fib_rules_notify(struct net *net, struct notifier_block *nb,
+			     enum fib_event_type event_type)
+{
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+	struct fib_notifier_info info;
+
+	if (net->ipv4.fib_has_custom_rules)
+		call_fib_notifier(nb, net, event_type, &info);
+#endif
+}
+
+static void fib_notify(struct net *net, struct notifier_block *nb,
+		       enum fib_event_type event_type);
+
+static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
+				   enum fib_event_type event_type, u32 dst,
+				   int dst_len, struct fib_info *fi,
+				   u8 tos, u8 type, u32 tb_id, u32 nlflags)
+{
+	struct fib_entry_notifier_info info = {
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.tb_id = tb_id,
+		.nlflags = nlflags,
+	};
+	return call_fib_notifier(nb, net, event_type, &info.info);
+}
+
+void fib_notifier_dump(struct notifier_block *nb)
+{
+	struct net *net;
+
+	rcu_read_lock();
+	for_each_net_rcu(net) {
+		fib_rules_notify(net, nb, FIB_EVENT_RULE_ADD);
+		fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
+	}
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL(fib_notifier_dump);
+
 int register_fib_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_register(&fib_chain, nb);
@@ -1834,6 +1886,62 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 	return found;
 }
 
+static void fib_leaf_notify(struct net *net, struct key_vector *l,
+			    struct fib_table *tb, struct notifier_block *nb,
+			    enum fib_event_type event_type)
+{
+	struct fib_alias *fa;
+
+	hlist_for_each_entry_rcu(fa, &l->leaf, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+
+		if (!fi)
+			continue;
+
+		/* local and main table can share the same trie,
+		 * so don't notify twice for the same entry.
+		 */
+		if (tb->tb_id != fa->tb_id)
+			continue;
+
+		call_fib_entry_notifier(nb, net, event_type, l->key,
+					KEYLENGTH - fa->fa_slen, fi, fa->fa_tos,
+					fa->fa_type, fa->tb_id, 0);
+	}
+}
+
+static void fib_table_notify(struct net *net, struct fib_table *tb,
+			     struct notifier_block *nb,
+			     enum fib_event_type event_type)
+{
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct key_vector *l, *tp = t->kv;
+	t_key key = 0;
+
+	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
+		fib_leaf_notify(net, l, tb, nb, event_type);
+
+		key = l->key + 1;
+		/* stop in case of wrap around */
+		if (key < l->key)
+			break;
+	}
+}
+
+static void fib_notify(struct net *net, struct notifier_block *nb,
+		       enum fib_event_type event_type)
+{
+	unsigned int h;
+
+	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
+		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
+		struct fib_table *tb;
+
+		hlist_for_each_entry_rcu(tb, head, tb_hlist)
+			fib_table_notify(net, tb, nb, event_type);
+	}
+}
+
 static void __trie_free_rcu(struct rcu_head *head)
 {
 	struct fib_table *tb = container_of(head, struct fib_table, rcu);
-- 
2.7.4
