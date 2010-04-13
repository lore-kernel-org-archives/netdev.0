From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/9] net: fib_rules: consolidate IPv4 and DECnet ->default_pref() functions.
Date: Tue, 13 Apr 2010 17:03:15 +0200
Message-ID: <1271171003-11901-2-git-send-email-kaber@trash.net>
References: <1271171003-11901-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51252 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab0DMPD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:03:26 -0400
In-Reply-To: <1271171003-11901-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both functions are equivalent, consolidate them since a following patch
needs a third implementation for multicast routing.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/fib_rules.h |    1 +
 net/core/fib_rules.c    |   18 ++++++++++++++++++
 net/decnet/dn_rules.c   |   19 +------------------
 net/ipv4/fib_rules.c    |   19 +------------------
 4 files changed, 21 insertions(+), 36 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index c49086d..52bd9e6 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -114,4 +114,5 @@ extern int			fib_rules_lookup(struct fib_rules_ops *,
 extern int			fib_default_rule_add(struct fib_rules_ops *,
 						     u32 pref, u32 table,
 						     u32 flags);
+extern u32			fib_default_rule_pref(struct fib_rules_ops *ops);
 #endif
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 05cce4e..1eb3227 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -39,6 +39,24 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 }
 EXPORT_SYMBOL(fib_default_rule_add);
 
+u32 fib_default_rule_pref(struct fib_rules_ops *ops)
+{
+	struct list_head *pos;
+	struct fib_rule *rule;
+
+	if (!list_empty(&ops->rules_list)) {
+		pos = ops->rules_list.next;
+		if (pos->next != &ops->rules_list) {
+			rule = list_entry(pos->next, struct fib_rule, list);
+			if (rule->pref)
+				return rule->pref - 1;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(fib_default_rule_pref);
+
 static void notify_rule_change(int event, struct fib_rule *rule,
 			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
 			       u32 pid);
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 7466c54..2d14093 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -212,23 +212,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static u32 dn_fib_rule_default_pref(struct fib_rules_ops *ops)
-{
-	struct list_head *pos;
-	struct fib_rule *rule;
-
-	if (!list_empty(&dn_fib_rules_ops->rules_list)) {
-		pos = dn_fib_rules_ops->rules_list.next;
-		if (pos->next != &dn_fib_rules_ops->rules_list) {
-			rule = list_entry(pos->next, struct fib_rule, list);
-			if (rule->pref)
-				return rule->pref - 1;
-		}
-	}
-
-	return 0;
-}
-
 static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 {
 	dn_rt_cache_flush(-1);
@@ -243,7 +226,7 @@ static struct fib_rules_ops dn_fib_rules_ops_template = {
 	.configure	= dn_fib_rule_configure,
 	.compare	= dn_fib_rule_compare,
 	.fill		= dn_fib_rule_fill,
-	.default_pref	= dn_fib_rule_default_pref,
+	.default_pref	= fib_default_rule_pref,
 	.flush_cache	= dn_fib_rule_flush_cache,
 	.nlgroup	= RTNLGRP_DECnet_RULE,
 	.policy		= dn_fib_rule_policy,
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index ca2d07b..73b6784 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -234,23 +234,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-static u32 fib4_rule_default_pref(struct fib_rules_ops *ops)
-{
-	struct list_head *pos;
-	struct fib_rule *rule;
-
-	if (!list_empty(&ops->rules_list)) {
-		pos = ops->rules_list.next;
-		if (pos->next != &ops->rules_list) {
-			rule = list_entry(pos->next, struct fib_rule, list);
-			if (rule->pref)
-				return rule->pref - 1;
-		}
-	}
-
-	return 0;
-}
-
 static size_t fib4_rule_nlmsg_payload(struct fib_rule *rule)
 {
 	return nla_total_size(4) /* dst */
@@ -272,7 +255,7 @@ static struct fib_rules_ops fib4_rules_ops_template = {
 	.configure	= fib4_rule_configure,
 	.compare	= fib4_rule_compare,
 	.fill		= fib4_rule_fill,
-	.default_pref	= fib4_rule_default_pref,
+	.default_pref	= fib_default_rule_pref,
 	.nlmsg_payload	= fib4_rule_nlmsg_payload,
 	.flush_cache	= fib4_rule_flush_cache,
 	.nlgroup	= RTNLGRP_IPV4_RULE,
-- 
1.7.0.4

