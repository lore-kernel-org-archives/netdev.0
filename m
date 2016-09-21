From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] fib: introduce FIB notification infrastructure
Date: Wed, 21 Sep 2016 13:53:09 +0200
Message-ID: <1474458794-5512-2-git-send-email-jiri@resnulli.us>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36759 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933101AbcIULxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 07:53:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id b184so8153289wma.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 04:53:20 -0700 (PDT)
In-Reply-To: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This allows to pass information about added/deleted FIB entries/rules to
whoever is interested. This is done in a very similar way as devinet
notifies address additions/removals.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h    | 34 ++++++++++++++++++++++++---
 net/ipv4/fib_frontend.c | 16 ++++++-------
 net/ipv4/fib_rules.c    | 10 ++++++++
 net/ipv4/fib_trie.c     | 62 ++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 108 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 7d4a72e..116a9c0 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -22,6 +22,7 @@
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
 #include <linux/percpu.h>
+#include <linux/notifier.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -185,6 +186,33 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 #define FIB_RES_PREFSRC(net, res)	((res).fi->fib_prefsrc ? : \
 					 FIB_RES_SADDR(net, res))
 
+struct fib_notifier_info {
+	struct net *net;
+};
+
+struct fib_entry_notifier_info {
+	struct fib_notifier_info info; /* must be first */
+	u32 dst;
+	int dst_len;
+	struct fib_info *fi;
+	u8 tos;
+	u8 type;
+	u32 tb_id;
+	u32 nlflags;
+};
+
+enum fib_event_type {
+	FIB_EVENT_ENTRY_ADD,
+	FIB_EVENT_ENTRY_DEL,
+	FIB_EVENT_RULE_ADD,
+	FIB_EVENT_RULE_DEL,
+};
+
+int register_fib_notifier(struct notifier_block *nb);
+int unregister_fib_notifier(struct notifier_block *nb);
+int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
+		       struct fib_notifier_info *info);
+
 struct fib_table {
 	struct hlist_node	tb_hlist;
 	u32			tb_id;
@@ -196,11 +224,11 @@ struct fib_table {
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags);
-int fib_table_insert(struct fib_table *, struct fib_config *);
-int fib_table_delete(struct fib_table *, struct fib_config *);
+int fib_table_insert(struct net *, struct fib_table *, struct fib_config *);
+int fib_table_delete(struct net *, struct fib_table *, struct fib_config *);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
-int fib_table_flush(struct fib_table *table);
+int fib_table_flush(struct net *net, struct fib_table *table);
 struct fib_table *fib_trie_unmerge(struct fib_table *main_tb);
 void fib_table_flush_external(struct fib_table *table);
 void fib_free_table(struct fib_table *tb);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4e56a4c..86c43dc 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -182,7 +182,7 @@ static void fib_flush(struct net *net)
 		struct fib_table *tb;
 
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist)
-			flushed += fib_table_flush(tb);
+			flushed += fib_table_flush(net, tb);
 	}
 
 	if (flushed)
@@ -590,13 +590,13 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			if (cmd == SIOCDELRT) {
 				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_delete(tb, &cfg);
+					err = fib_table_delete(net, tb, &cfg);
 				else
 					err = -ESRCH;
 			} else {
 				tb = fib_new_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_insert(tb, &cfg);
+					err = fib_table_insert(net, tb, &cfg);
 				else
 					err = -ENOBUFS;
 			}
@@ -719,7 +719,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = fib_table_delete(tb, &cfg);
+	err = fib_table_delete(net, tb, &cfg);
 errout:
 	return err;
 }
@@ -741,7 +741,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = fib_table_insert(tb, &cfg);
+	err = fib_table_insert(net, tb, &cfg);
 errout:
 	return err;
 }
@@ -828,9 +828,9 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		cfg.fc_scope = RT_SCOPE_HOST;
 
 	if (cmd == RTM_NEWROUTE)
-		fib_table_insert(tb, &cfg);
+		fib_table_insert(net, tb, &cfg);
 	else
-		fib_table_delete(tb, &cfg);
+		fib_table_delete(net, tb, &cfg);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
@@ -1254,7 +1254,7 @@ static void ip_fib_net_exit(struct net *net)
 
 		hlist_for_each_entry_safe(tb, tmp, head, tb_hlist) {
 			hlist_del(&tb->tb_hlist);
-			fib_table_flush(tb);
+			fib_table_flush(net, tb);
 			fib_free_table(tb);
 		}
 	}
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 770bebe..ebadf6b 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -164,6 +164,14 @@ static struct fib_table *fib_empty_table(struct net *net)
 	return NULL;
 }
 
+static int call_fib_rule_notifiers(struct net *net,
+				   enum fib_event_type event_type)
+{
+	struct fib_notifier_info info;
+
+	return call_fib_notifiers(net, event_type, &info);
+}
+
 static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 	[FRA_FLOW]	= { .type = NLA_U32 },
@@ -221,6 +229,7 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 
 	net->ipv4.fib_has_custom_rules = true;
 	fib_flush_external(rule->fr_net);
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD);
 
 	err = 0;
 errout:
@@ -243,6 +252,7 @@ static int fib4_rule_delete(struct fib_rule *rule)
 #endif
 	net->ipv4.fib_has_custom_rules = true;
 	fib_flush_external(rule->fr_net);
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL);
 errout:
 	return err;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 241f27b..51a4537 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -73,6 +73,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <linux/vmalloc.h>
+#include <linux/notifier.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -84,6 +85,44 @@
 #include <trace/events/fib.h>
 #include "fib_lookup.h"
 
+static BLOCKING_NOTIFIER_HEAD(fib_chain);
+
+int register_fib_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&fib_chain, nb);
+}
+EXPORT_SYMBOL(register_fib_notifier);
+
+int unregister_fib_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&fib_chain, nb);
+}
+EXPORT_SYMBOL(unregister_fib_notifier);
+
+int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
+		       struct fib_notifier_info *info)
+{
+	info->net = net;
+	return blocking_notifier_call_chain(&fib_chain, event_type, info);
+}
+
+static int call_fib_entry_notifiers(struct net *net,
+				    enum fib_event_type event_type, u32 dst,
+				    int dst_len, struct fib_info *fi,
+				    u8 tos, u8 type, u32 tb_id, u32 nlflags)
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
+	return call_fib_notifiers(net, event_type, &info.info);
+}
+
 #define MAX_STAT_DEPTH 32
 
 #define KEYLENGTH	(8*sizeof(t_key))
@@ -1076,7 +1115,8 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 }
 
 /* Caller must hold RTNL. */
-int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_insert(struct net *net, struct fib_table *tb,
+		     struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
@@ -1193,6 +1233,11 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(cfg->fc_nlinfo.nl_net);
+
+			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD,
+						 key, plen, fi,
+						 new_fa->fa_tos, cfg->fc_type,
+						 tb->tb_id, cfg->fc_nlflags);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				tb->tb_id, &cfg->fc_nlinfo, nlflags);
 
@@ -1245,6 +1290,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
+	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD, key, plen, fi, tos,
+				 cfg->fc_type, tb->tb_id, cfg->fc_nlflags);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, nlflags);
 succeeded:
@@ -1490,7 +1537,8 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 }
 
 /* Caller must hold RTNL. */
-int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
+int fib_table_delete(struct net *net, struct fib_table *tb,
+		     struct fib_config *cfg)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
@@ -1546,6 +1594,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	switchdev_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
 			       cfg->fc_type, tb->tb_id);
 
+	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
+				 fa_to_delete->fa_info, tos, cfg->fc_type,
+				 tb->tb_id, 0);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1809,7 +1860,7 @@ void fib_table_flush_external(struct fib_table *tb)
 }
 
 /* Caller must hold RTNL. */
-int fib_table_flush(struct fib_table *tb)
+int fib_table_flush(struct net *net, struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct key_vector *pn = t->kv;
@@ -1861,6 +1912,11 @@ int fib_table_flush(struct fib_table *tb)
 			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
 					       fi, fa->fa_tos, fa->fa_type,
 					       tb->tb_id);
+			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL,
+						 n->key,
+						 KEYLENGTH - fa->fa_slen,
+						 fi, fa->fa_tos, fa->fa_type,
+						 tb->tb_id, 0);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
-- 
2.5.5
