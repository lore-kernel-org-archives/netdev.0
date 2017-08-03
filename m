From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/21] net: fib_rules: Implement notification logic in core
Date: Thu,  3 Aug 2017 13:28:14 +0200
Message-ID: <20170803112831.1831-5-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37864 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752123AbdHCL2n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:43 -0400
Received: by mail-wm0-f68.google.com with SMTP id t138so1806620wmt.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:42 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Unlike the routing tables, the FIB rules share a common core, so instead
of replicating the same logic for each address family we can simply dump
the rules and send notifications from the core itself.

To protect the integrity of the dump, a rules-specific sequence counter
is added for each address family and incremented whenever a rule is
added or deleted (under RTNL).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/fib_rules.h |  9 +++++++
 include/net/ip_fib.h    | 24 +++++++++----------
 net/core/fib_rules.c    | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/fib_notifier.c |  9 +++++--
 net/ipv4/fib_rules.c    | 45 ++++++++---------------------------
 5 files changed, 101 insertions(+), 49 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index c487bfa..3d7f1ce 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -8,6 +8,7 @@
 #include <linux/refcount.h>
 #include <net/flow.h>
 #include <net/rtnetlink.h>
+#include <net/fib_notifier.h>
 
 struct fib_kuid_range {
 	kuid_t start;
@@ -57,6 +58,7 @@ struct fib_rules_ops {
 	int			addr_size;
 	int			unresolved_rules;
 	int			nr_goto_rules;
+	unsigned int		fib_rules_seq;
 
 	int			(*action)(struct fib_rule *,
 					  struct flowi *, int,
@@ -89,6 +91,11 @@ struct fib_rules_ops {
 	struct rcu_head		rcu;
 };
 
+struct fib_rule_notifier_info {
+	struct fib_notifier_info info; /* must be first */
+	struct fib_rule *rule;
+};
+
 #define FRA_GENERIC_POLICY \
 	[FRA_IIFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
 	[FRA_OIFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
@@ -143,6 +150,8 @@ int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
 int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
 			 u32 flags);
 bool fib_rule_matchall(const struct fib_rule *rule);
+int fib_rules_dump(struct net *net, struct notifier_block *nb, int family);
+unsigned int fib_rules_seq_read(struct net *net, int family);
 
 int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 		   struct netlink_ext_ack *extack);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index c0295c3..1a7f7e4 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -199,11 +199,6 @@ struct fib_entry_notifier_info {
 	u32 tb_id;
 };
 
-struct fib_rule_notifier_info {
-	struct fib_notifier_info info; /* must be first */
-	struct fib_rule *rule;
-};
-
 struct fib_nh_notifier_info {
 	struct fib_notifier_info info; /* must be first */
 	struct fib_nh *fib_nh;
@@ -219,13 +214,6 @@ int __net_init fib4_notifier_init(struct net *net);
 void __net_exit fib4_notifier_exit(struct net *net);
 
 void fib_notify(struct net *net, struct notifier_block *nb);
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-void fib_rules_notify(struct net *net, struct notifier_block *nb);
-#else
-static inline void fib_rules_notify(struct net *net, struct notifier_block *nb)
-{
-}
-#endif
 
 struct fib_table {
 	struct hlist_node	tb_hlist;
@@ -298,6 +286,16 @@ static inline bool fib4_rule_default(const struct fib_rule *rule)
 	return true;
 }
 
+static inline int fib4_rules_dump(struct net *net, struct notifier_block *nb)
+{
+	return 0;
+}
+
+static inline unsigned int fib4_rules_seq_read(struct net *net)
+{
+	return 0;
+}
+
 #else /* CONFIG_IP_MULTIPLE_TABLES */
 int __net_init fib4_rules_init(struct net *net);
 void __net_exit fib4_rules_exit(struct net *net);
@@ -343,6 +341,8 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 }
 
 bool fib4_rule_default(const struct fib_rule *rule);
+int fib4_rules_dump(struct net *net, struct notifier_block *nb);
+unsigned int fib4_rules_seq_read(struct net *net);
 
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index fdcb1bc..fc0b650 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -299,6 +299,67 @@ int fib_rules_lookup(struct fib_rules_ops *ops, struct flowi *fl,
 }
 EXPORT_SYMBOL_GPL(fib_rules_lookup);
 
+static int call_fib_rule_notifier(struct notifier_block *nb, struct net *net,
+				  enum fib_event_type event_type,
+				  struct fib_rule *rule, int family)
+{
+	struct fib_rule_notifier_info info = {
+		.info.family = family,
+		.rule = rule,
+	};
+
+	return call_fib_notifier(nb, net, event_type, &info.info);
+}
+
+static int call_fib_rule_notifiers(struct net *net,
+				   enum fib_event_type event_type,
+				   struct fib_rule *rule,
+				   struct fib_rules_ops *ops)
+{
+	struct fib_rule_notifier_info info = {
+		.info.family = ops->family,
+		.rule = rule,
+	};
+
+	ops->fib_rules_seq++;
+	return call_fib_notifiers(net, event_type, &info.info);
+}
+
+/* Called with rcu_read_lock() */
+int fib_rules_dump(struct net *net, struct notifier_block *nb, int family)
+{
+	struct fib_rules_ops *ops;
+	struct fib_rule *rule;
+
+	ops = lookup_rules_ops(net, family);
+	if (!ops)
+		return -EAFNOSUPPORT;
+	list_for_each_entry_rcu(rule, &ops->rules_list, list)
+		call_fib_rule_notifier(nb, net, FIB_EVENT_RULE_ADD, rule,
+				       family);
+	rules_ops_put(ops);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(fib_rules_dump);
+
+unsigned int fib_rules_seq_read(struct net *net, int family)
+{
+	unsigned int fib_rules_seq;
+	struct fib_rules_ops *ops;
+
+	ASSERT_RTNL();
+
+	ops = lookup_rules_ops(net, family);
+	if (!ops)
+		return 0;
+	fib_rules_seq = ops->fib_rules_seq;
+	rules_ops_put(ops);
+
+	return fib_rules_seq;
+}
+EXPORT_SYMBOL_GPL(fib_rules_seq_read);
+
 static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
 			    struct fib_rules_ops *ops)
 {
@@ -548,6 +609,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rule->tun_id)
 		ip_tunnel_need_metadata();
 
+	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD, rule, ops);
 	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).portid);
 	flush_route_cache(ops);
 	rules_ops_put(ops);
@@ -687,6 +749,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 			}
 		}
 
+		call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL, rule, ops);
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).portid);
 		fib_rule_put(rule);
diff --git a/net/ipv4/fib_notifier.c b/net/ipv4/fib_notifier.c
index 7cf1954..5d7afb1 100644
--- a/net/ipv4/fib_notifier.c
+++ b/net/ipv4/fib_notifier.c
@@ -29,12 +29,17 @@ static unsigned int fib4_seq_read(struct net *net)
 {
 	ASSERT_RTNL();
 
-	return net->ipv4.fib_seq;
+	return net->ipv4.fib_seq + fib4_rules_seq_read(net);
 }
 
 static int fib4_dump(struct net *net, struct notifier_block *nb)
 {
-	fib_rules_notify(net, nb);
+	int err;
+
+	err = fib4_rules_dump(net, nb);
+	if (err)
+		return err;
+
 	fib_notify(net, nb);
 
 	return 0;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index acdbf5a..35d646a 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -32,7 +32,6 @@
 #include <net/tcp.h>
 #include <net/ip_fib.h>
 #include <net/fib_rules.h>
-#include <net/fib_notifier.h>
 
 struct fib4_rule {
 	struct fib_rule		common;
@@ -69,6 +68,16 @@ bool fib4_rule_default(const struct fib_rule *rule)
 }
 EXPORT_SYMBOL_GPL(fib4_rule_default);
 
+int fib4_rules_dump(struct net *net, struct notifier_block *nb)
+{
+	return fib_rules_dump(net, nb, AF_INET);
+}
+
+unsigned int fib4_rules_seq_read(struct net *net)
+{
+	return fib_rules_seq_read(net, AF_INET);
+}
+
 int __fib_lookup(struct net *net, struct flowi4 *flp,
 		 struct fib_result *res, unsigned int flags)
 {
@@ -186,38 +195,6 @@ static struct fib_table *fib_empty_table(struct net *net)
 	return NULL;
 }
 
-static int call_fib_rule_notifier(struct notifier_block *nb, struct net *net,
-				  enum fib_event_type event_type,
-				  struct fib_rule *rule)
-{
-	struct fib_rule_notifier_info info = {
-		.rule = rule,
-	};
-
-	return call_fib4_notifier(nb, net, event_type, &info.info);
-}
-
-static int call_fib_rule_notifiers(struct net *net,
-				   enum fib_event_type event_type,
-				   struct fib_rule *rule)
-{
-	struct fib_rule_notifier_info info = {
-		.rule = rule,
-	};
-
-	return call_fib4_notifiers(net, event_type, &info.info);
-}
-
-/* Called with rcu_read_lock() */
-void fib_rules_notify(struct net *net, struct notifier_block *nb)
-{
-	struct fib_rules_ops *ops = net->ipv4.rules_ops;
-	struct fib_rule *rule;
-
-	list_for_each_entry_rcu(rule, &ops->rules_list, list)
-		call_fib_rule_notifier(nb, net, FIB_EVENT_RULE_ADD, rule);
-}
-
 static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 	[FRA_FLOW]	= { .type = NLA_U32 },
@@ -274,7 +251,6 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->tos = frh->tos;
 
 	net->ipv4.fib_has_custom_rules = true;
-	call_fib_rule_notifiers(net, FIB_EVENT_RULE_ADD, rule);
 
 	err = 0;
 errout:
@@ -296,7 +272,6 @@ static int fib4_rule_delete(struct fib_rule *rule)
 		net->ipv4.fib_num_tclassid_users--;
 #endif
 	net->ipv4.fib_has_custom_rules = true;
-	call_fib_rule_notifiers(net, FIB_EVENT_RULE_DEL, rule);
 errout:
 	return err;
 }
-- 
2.9.3
