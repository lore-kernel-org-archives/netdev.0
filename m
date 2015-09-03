From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: kill default_pref field of struct fib_rules_ops
Date: Thu,  3 Sep 2015 13:10:22 +0200
Message-ID: <1441278622-24679-1-git-send-email-phil@nwl.cc>
References: <1441198992-25359-1-git-send-email-phil@nwl.cc>
Cc: tgraf@suug.ch, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48308 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142AbbICLKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 07:10:25 -0400
In-Reply-To: <1441198992-25359-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since now all users of that field have been converted to use the generic
function fib_default_rule_pref() when assigning to it, fib_nl_newrule()
may just use it directly instead.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/net/fib_rules.h |  1 -
 net/core/fib_rules.c    | 10 +++-------
 net/decnet/dn_rules.c   |  1 -
 net/ipv4/fib_rules.c    |  1 -
 net/ipv4/ipmr.c         |  1 -
 net/ipv6/fib6_rules.c   |  1 -
 net/ipv6/ip6mr.c        |  1 -
 7 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 4e8f804..75cda93 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -66,7 +66,6 @@ struct fib_rules_ops {
 					   struct nlattr **);
 	int			(*fill)(struct fib_rule *, struct sk_buff *,
 					struct fib_rule_hdr *);
-	u32			(*default_pref)(struct fib_rules_ops *ops);
 	size_t			(*nlmsg_payload)(struct fib_rule *);
 
 	/* Called after modifications to the rules set, must flush
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index ae8306e..bf77e36 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -44,7 +44,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 }
 EXPORT_SYMBOL(fib_default_rule_add);
 
-u32 fib_default_rule_pref(struct fib_rules_ops *ops)
+static u32 fib_default_rule_pref(struct fib_rules_ops *ops)
 {
 	struct list_head *pos;
 	struct fib_rule *rule;
@@ -60,7 +60,6 @@ u32 fib_default_rule_pref(struct fib_rules_ops *ops)
 
 	return 0;
 }
-EXPORT_SYMBOL(fib_default_rule_pref);
 
 static void notify_rule_change(int event, struct fib_rule *rule,
 			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
@@ -299,8 +298,8 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	}
 	rule->fr_net = net;
 
-	if (tb[FRA_PRIORITY])
-		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
+	rule->pref = tb[FRA_PRIORITY] ? nla_get_u32(tb[FRA_PRIORITY])
+	                              : fib_default_rule_pref(ops);
 
 	if (tb[FRA_IIFNAME]) {
 		struct net_device *dev;
@@ -350,9 +349,6 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	else
 		rule->suppress_ifgroup = -1;
 
-	if (!tb[FRA_PRIORITY] && ops->default_pref)
-		rule->pref = ops->default_pref(ops);
-
 	err = -EINVAL;
 	if (tb[FRA_GOTO]) {
 		if (rule->action != FR_ACT_GOTO)
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 9d66a0f..295bbd6 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -229,7 +229,6 @@ static const struct fib_rules_ops __net_initconst dn_fib_rules_ops_template = {
 	.configure	= dn_fib_rule_configure,
 	.compare	= dn_fib_rule_compare,
 	.fill		= dn_fib_rule_fill,
-	.default_pref	= fib_default_rule_pref,
 	.flush_cache	= dn_fib_rule_flush_cache,
 	.nlgroup	= RTNLGRP_DECnet_RULE,
 	.policy		= dn_fib_rule_policy,
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 18123d5..f2bda9e 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -318,7 +318,6 @@ static const struct fib_rules_ops __net_initconst fib4_rules_ops_template = {
 	.delete		= fib4_rule_delete,
 	.compare	= fib4_rule_compare,
 	.fill		= fib4_rule_fill,
-	.default_pref	= fib_default_rule_pref,
 	.nlmsg_payload	= fib4_rule_nlmsg_payload,
 	.flush_cache	= fib4_rule_flush_cache,
 	.nlgroup	= RTNLGRP_IPV4_RULE,
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3a2c016..866ee89 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -233,7 +233,6 @@ static const struct fib_rules_ops __net_initconst ipmr_rules_ops_template = {
 	.match		= ipmr_rule_match,
 	.configure	= ipmr_rule_configure,
 	.compare	= ipmr_rule_compare,
-	.default_pref	= fib_default_rule_pref,
 	.fill		= ipmr_rule_fill,
 	.nlgroup	= RTNLGRP_IPV4_RULE,
 	.policy		= ipmr_rule_policy,
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index a859ad2..9f777ec 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -274,7 +274,6 @@ static const struct fib_rules_ops __net_initconst fib6_rules_ops_template = {
 	.configure		= fib6_rule_configure,
 	.compare		= fib6_rule_compare,
 	.fill			= fib6_rule_fill,
-	.default_pref		= fib_default_rule_pref,
 	.nlmsg_payload		= fib6_rule_nlmsg_payload,
 	.nlgroup		= RTNLGRP_IPV6_RULE,
 	.policy			= fib6_rule_policy,
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 74ceb73..774c95e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -217,7 +217,6 @@ static const struct fib_rules_ops __net_initconst ip6mr_rules_ops_template = {
 	.match		= ip6mr_rule_match,
 	.configure	= ip6mr_rule_configure,
 	.compare	= ip6mr_rule_compare,
-	.default_pref	= fib_default_rule_pref,
 	.fill		= ip6mr_rule_fill,
 	.nlgroup	= RTNLGRP_IPV6_RULE,
 	.policy		= ip6mr_rule_policy,
-- 
2.1.2
