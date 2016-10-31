From: idosch@idosch.org
Subject: [PATCH net-next v2] ipv4: fib: Replay events when registering FIB notifier
Date: Mon, 31 Oct 2016 23:13:47 +0200
Message-ID: <1477948427-9189-1-git-send-email-idosch@idosch.org>
Cc: davem@davemloft.net, jiri@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, andy@greyhouse.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60106 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S946965AbcJaVOg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 17:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When registering a FIB notifier block we should notify the caller of
already existing FIB entries and rules, as it would otherwise have an
incomplete view of the FIB tables. This is especially important for
switchdev drivers that support FIB offloads. Failing to notify them of
existing entries may lead to packet loss.

Upon registration, walk the leafs of all the routing tables and for each
leaf send notification of existing FIB aliases. Similarly, when
unregistering the notifier synthesize a deletion event, thereby
relieving potential callers from the need to perform cleanup.

The above is consistent with the netdevice notification chain, where
"registration and up events are replayed to the new notifier" upon
registration.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
* Add #ifdef fixing compilation error reported by kbuild robot
---
 net/ipv4/fib_trie.c | 152 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 150 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 31cef36..455d94b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -86,15 +86,107 @@
 
 static BLOCKING_NOTIFIER_HEAD(fib_chain);
 
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
+/**
+ *	register_fib_notifier - register a fib notifier block
+ *	@nb: notifier
+ *
+ *	Register a notifier to be called when FIB entries or rules are
+ *	added or removed. A negative errno code is returned on failure.
+ *
+ *	When registered, all FIB addition events are replayed to the new
+ *	notifier to allow the caller to have a complete view of the FIB
+ *	tables.
+ */
+
 int register_fib_notifier(struct notifier_block *nb)
 {
-	return blocking_notifier_chain_register(&fib_chain, nb);
+	struct net *net;
+	int err;
+
+	rtnl_lock();
+	err = blocking_notifier_chain_register(&fib_chain, nb);
+	if (err)
+		goto unlock;
+	for_each_net(net) {
+		fib_rules_notify(net, nb, FIB_EVENT_RULE_ADD);
+		fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
+	}
+
+unlock:
+	rtnl_unlock();
+	return err;
 }
 EXPORT_SYMBOL(register_fib_notifier);
 
+/**
+ *	unregister_fib_notifier - unregister a fib notifier block
+ *	@nb: notifier
+ *
+ *	unregister a notifier previously registered by
+ *	register_fib_notifier(). A negative errno code is returned on
+ *	failure.
+ *
+ *	After unregistering, FIB deletion events are synthesized to the
+ *	removed notifier for all present FIB entries. This removes the
+ *	need for special case cleanup code.
+ */
+
 int unregister_fib_notifier(struct notifier_block *nb)
 {
-	return blocking_notifier_chain_unregister(&fib_chain, nb);
+	struct net *net;
+	int err;
+
+	rtnl_lock();
+	err = blocking_notifier_chain_unregister(&fib_chain, nb);
+	if (err)
+		goto unlock;
+	for_each_net(net) {
+		fib_notify(net, nb, FIB_EVENT_ENTRY_DEL);
+		fib_rules_notify(net, nb, FIB_EVENT_RULE_DEL);
+	}
+
+unlock:
+	rtnl_unlock();
+	return err;
 }
 EXPORT_SYMBOL(unregister_fib_notifier);
 
@@ -1834,6 +1926,62 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 	return found;
 }
 
+static void fib_leaf_notify(struct net *net, struct key_vector *l,
+			    struct fib_table *tb, struct notifier_block *nb,
+			    enum fib_event_type event_type)
+{
+	struct fib_alias *fa;
+
+	hlist_for_each_entry(fa, &l->leaf, fa_list) {
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
+		hlist_for_each_entry(tb, head, tb_hlist)
+			fib_table_notify(net, tb, nb, event_type);
+	}
+}
+
 static void __trie_free_rcu(struct rcu_head *head)
 {
 	struct fib_table *tb = container_of(head, struct fib_table, rcu);
-- 
2.7.4
