From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] ipv4: fib: Remove redundant argument
Date: Fri, 10 Mar 2017 08:56:19 +0100
Message-ID: <1489132579-12664-3-git-send-email-jiri@resnulli.us>
References: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34203 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754918AbdCJH40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:56:26 -0500
Received: by mail-wm0-f65.google.com with SMTP id u132so940259wmg.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:56:25 -0800 (PST)
In-Reply-To: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We always pass the same event type to fib_notify() and
fib_rules_notify(), so we can safely drop this argument.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h    |  9 +++------
 net/ipv4/fib_notifier.c |  4 ++--
 net/ipv4/fib_rules.c    |  5 ++---
 net/ipv4/fib_trie.c     | 15 ++++++---------
 4 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 3ad8706..d9cee96 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -238,14 +238,11 @@ int call_fib_notifier(struct notifier_block *nb, struct net *net,
 int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
 		       struct fib_notifier_info *info);
 
-void fib_notify(struct net *net, struct notifier_block *nb,
-		enum fib_event_type event_type);
+void fib_notify(struct net *net, struct notifier_block *nb);
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-void fib_rules_notify(struct net *net, struct notifier_block *nb,
-		      enum fib_event_type event_type);
+void fib_rules_notify(struct net *net, struct notifier_block *nb);
 #else
-static inline void fib_rules_notify(struct net *net, struct notifier_block *nb,
-				    enum fib_event_type event_type)
+static inline void fib_rules_notify(struct net *net, struct notifier_block *nb)
 {
 }
 #endif
diff --git a/net/ipv4/fib_notifier.c b/net/ipv4/fib_notifier.c
index 91f8f18..e0714d9 100644
--- a/net/ipv4/fib_notifier.c
+++ b/net/ipv4/fib_notifier.c
@@ -66,8 +66,8 @@ int register_fib_notifier(struct notifier_block *nb,
 		 */
 		rcu_read_lock();
 		for_each_net_rcu(net) {
-			fib_rules_notify(net, nb, FIB_EVENT_RULE_ADD);
-			fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
+			fib_rules_notify(net, nb);
+			fib_notify(net, nb);
 		}
 		rcu_read_unlock();
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index bbd57f0..2892109 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -172,13 +172,12 @@ static int call_fib_rule_notifiers(struct net *net,
 	return call_fib_notifiers(net, event_type, &info);
 }
 
-void fib_rules_notify(struct net *net, struct notifier_block *nb,
-		      enum fib_event_type event_type)
+void fib_rules_notify(struct net *net, struct notifier_block *nb)
 {
 	struct fib_notifier_info info;
 
 	if (net->ipv4.fib_has_custom_rules)
-		call_fib_notifier(nb, net, event_type, &info);
+		call_fib_notifier(nb, net, FIB_EVENT_RULE_ADD, &info);
 }
 
 static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5639e8a..1201409 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1902,8 +1902,7 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 }
 
 static void fib_leaf_notify(struct net *net, struct key_vector *l,
-			    struct fib_table *tb, struct notifier_block *nb,
-			    enum fib_event_type event_type)
+			    struct fib_table *tb, struct notifier_block *nb)
 {
 	struct fib_alias *fa;
 
@@ -1919,22 +1918,21 @@ static void fib_leaf_notify(struct net *net, struct key_vector *l,
 		if (tb->tb_id != fa->tb_id)
 			continue;
 
-		call_fib_entry_notifier(nb, net, event_type, l->key,
+		call_fib_entry_notifier(nb, net, FIB_EVENT_ENTRY_ADD, l->key,
 					KEYLENGTH - fa->fa_slen, fi, fa->fa_tos,
 					fa->fa_type, fa->tb_id);
 	}
 }
 
 static void fib_table_notify(struct net *net, struct fib_table *tb,
-			     struct notifier_block *nb,
-			     enum fib_event_type event_type)
+			     struct notifier_block *nb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct key_vector *l, *tp = t->kv;
 	t_key key = 0;
 
 	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
-		fib_leaf_notify(net, l, tb, nb, event_type);
+		fib_leaf_notify(net, l, tb, nb);
 
 		key = l->key + 1;
 		/* stop in case of wrap around */
@@ -1943,8 +1941,7 @@ static void fib_table_notify(struct net *net, struct fib_table *tb,
 	}
 }
 
-void fib_notify(struct net *net, struct notifier_block *nb,
-		enum fib_event_type event_type)
+void fib_notify(struct net *net, struct notifier_block *nb)
 {
 	unsigned int h;
 
@@ -1953,7 +1950,7 @@ void fib_notify(struct net *net, struct notifier_block *nb,
 		struct fib_table *tb;
 
 		hlist_for_each_entry_rcu(tb, head, tb_hlist)
-			fib_table_notify(net, tb, nb, event_type);
+			fib_table_notify(net, tb, nb);
 	}
 }
 
-- 
2.7.4
