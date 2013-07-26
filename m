From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fib_rules: add .suppress operation
Date: Fri, 26 Jul 2013 12:46:57 +0200
Message-ID: <20130726104657.GF10216@zirkel.wertarbyte.de>
References: <20130725221116.GC10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:47753 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab3GZKq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 06:46:59 -0400
Content-Disposition: inline
In-Reply-To: <20130725221116.GC10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a new operation to the fib_rules_ops struct; it allows the
suppression of routing decisions if certain criteria are not met by its
results.

The first implemented constraint is a minimum prefix length added to the
structures of routing rules. If a rule is added with a minimum prefix length
>0, only routes meeting this threshold will be considered. Any other (more
general) routing table entries will be ignored.

When configuring a system with multiple network uplinks and default routes, it
is often convinient to reference the main routing table multiple times - but
omitting the default route. Using this patch and a modified "ip" utility, this
can be achieved by using the following command sequence:

  $ ip route add table secuplink default via 10.42.23.1

  $ ip rule add pref 100            table main prefixlength 1
  $ ip rule add pref 150 fwmark 0xA table secuplink

With this setup, packets marked 0xA will be processed by the additional routing
table "secuplink", but only if no suitable route in the main routing table can
be found. By using a minimal prefixlength of 1, the default route (/0) of the
table "main" is hidden to packets processed by rule 100; packets traveling to
destinations with more specific routing entries are processed as usual.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/net/fib_rules.h        |    4 ++++
 include/uapi/linux/fib_rules.h |    2 +-
 net/core/fib_rules.c           |    8 ++++++++
 net/ipv4/fib_rules.c           |    9 +++++++++
 net/ipv6/fib6_rules.c          |   12 ++++++++++++
 5 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e361f48..bb15664 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -18,6 +18,7 @@ struct fib_rule {
 	u32			pref;
 	u32			flags;
 	u32			table;
+	u8			table_prefixlen_min;
 	u8			action;
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
@@ -46,6 +47,8 @@ struct fib_rules_ops {
 	int			(*action)(struct fib_rule *,
 					  struct flowi *, int,
 					  struct fib_lookup_arg *);
+	int			(*suppress)(struct fib_rule *,
+					    struct fib_lookup_arg *);
 	int			(*match)(struct fib_rule *,
 					 struct flowi *, int);
 	int			(*configure)(struct fib_rule *,
@@ -80,6 +83,7 @@ struct fib_rules_ops {
 	[FRA_FWMARK]	= { .type = NLA_U32 }, \
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
 	[FRA_TABLE]     = { .type = NLA_U32 }, \
+	[FRA_TABLE_PREFIXLEN_MIN] = { .type = NLA_U8 }, \
 	[FRA_GOTO]	= { .type = NLA_U32 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 51da65b..59cd31b 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -45,7 +45,7 @@ enum {
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,
-	FRA_UNUSED8,
+	FRA_TABLE_PREFIXLEN_MIN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 2173544..1e0e1f4 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -227,6 +227,9 @@ jumped:
 			err = ops->action(rule, fl, flags, arg);
 
 		if (err != -EAGAIN) {
+			if (ops->suppress && ops->suppress(rule, arg)) {
+				continue;
+			}
 			if ((arg->flags & FIB_LOOKUP_NOREF) ||
 			    likely(atomic_inc_not_zero(&rule->refcnt))) {
 				arg->rule = rule;
@@ -337,6 +340,8 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
+	if (tb[FRA_TABLE_PREFIXLEN_MIN])
+		rule->table_prefixlen_min = nla_get_u8(tb[FRA_TABLE_PREFIXLEN_MIN]);
 
 	if (!tb[FRA_PRIORITY] && ops->default_pref)
 		rule->pref = ops->default_pref(ops);
@@ -523,6 +528,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(IFNAMSIZ) /* FRA_OIFNAME */
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
+			 + nla_total_size(1) /* FRA_TABLE_PREFIXLEN_MIN */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4); /* FRA_FWMASK */
 
@@ -548,6 +554,8 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh->table = rule->table;
 	if (nla_put_u32(skb, FRA_TABLE, rule->table))
 		goto nla_put_failure;
+	if (nla_put_u8(skb, FRA_TABLE_PREFIXLEN_MIN, rule->table_prefixlen_min))
+		goto nla_put_failure;
 	frh->res1 = 0;
 	frh->res2 = 0;
 	frh->action = rule->action;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 26aa65d..cb5fcc1 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -101,6 +101,14 @@ errout:
 	return err;
 }
 
+static int fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
+	/* do not accept result if the route does not meet the required prefix length */
+	struct fib_result *result = (struct fib_result *) arg->result;
+	if (result->prefixlen < rule->table_prefixlen_min) {
+		return 1;
+	}
+	return 0;
+}
 
 static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
@@ -267,6 +275,7 @@ static const struct fib_rules_ops __net_initconst fib4_rules_ops_template = {
 	.rule_size	= sizeof(struct fib4_rule),
 	.addr_size	= sizeof(u32),
 	.action		= fib4_rule_action,
+	.suppress	= fib4_rule_suppress,
 	.match		= fib4_rule_match,
 	.configure	= fib4_rule_configure,
 	.delete		= fib4_rule_delete,
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 2e1a432..dcba659 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -111,6 +111,17 @@ out:
 	return rt == NULL ? -EAGAIN : 0;
 }
 
+static int fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
+	struct rt6_info *rt = (struct rt6_info *) arg->result;
+	/*
+	 * do not accept result if the route does
+	 * not meet the required prefix length
+	 */
+	if (rt->rt6i_dst.plen < rule->table_prefixlen_min) {
+		return 1;
+	}
+	return 0;
+}
 
 static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 {
@@ -244,6 +255,7 @@ static const struct fib_rules_ops __net_initconst fib6_rules_ops_template = {
 	.addr_size		= sizeof(struct in6_addr),
 	.action			= fib6_rule_action,
 	.match			= fib6_rule_match,
+	.suppress		= fib6_rule_suppress,
 	.configure		= fib6_rule_configure,
 	.compare		= fib6_rule_compare,
 	.fill			= fib6_rule_fill,
-- 
1.7.10.4
