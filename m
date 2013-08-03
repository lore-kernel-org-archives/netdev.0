From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fib_rules: fix suppressor names and default values
Date: Sat, 3 Aug 2013 14:14:43 +0200
Message-ID: <20130803121443.GL21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:52677 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab3HCMOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 08:14:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change brings the suppressor attribute names into line; it also changes
the data types to provide a more consistent interface.

While -1 indicates that the suppressor is not enabled, values >= 0 for
suppress_prefixlen or suppress_ifgroup  reject routing decisions violating the
constraint.

This changes the previously presented behaviour of suppress_prefixlen, where a
prefix length _less_ than the attribute value was rejected. After this change,
a prefix length less than *or* equal to the value is considered a violation of
the rule constraint.

It also changes the default values for default and newly added rules (disabling
any suppression for those).

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/net/fib_rules.h        |    4 ++--
 include/uapi/linux/fib_rules.h |    2 +-
 net/core/fib_rules.c           |   15 +++++++++++----
 net/ipv4/fib_rules.c           |    2 +-
 net/ipv6/fib6_rules.c          |    2 +-
 5 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index d13c461..9d0fcbaa 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -19,7 +19,7 @@ struct fib_rule {
 	u32			flags;
 	u32			table;
 	int			suppress_ifgroup;
-	u8			table_prefixlen_min;
+	int			suppress_prefixlen;
 	u8			action;
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
@@ -84,7 +84,7 @@ struct fib_rules_ops {
 	[FRA_FWMARK]	= { .type = NLA_U32 }, \
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
 	[FRA_TABLE]     = { .type = NLA_U32 }, \
-	[FRA_TABLE_PREFIXLEN_MIN] = { .type = NLA_U8 }, \
+	[FRA_SUPPRESS_PREFIXLEN] = { .type = NLA_U32 }, \
 	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
 	[FRA_GOTO]	= { .type = NLA_U32 }
 
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 63e3116..2b82d7e 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -45,7 +45,7 @@ enum {
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_SUPPRESS_IFGROUP,
-	FRA_TABLE_PREFIXLEN_MIN,
+	FRA_SUPPRESS_PREFIXLEN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
 	FRA_OIFNAME,
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 5040a61..47916b0 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -33,6 +33,9 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->flags = flags;
 	r->fr_net = hold_net(ops->fro_net);
 
+	r->suppress_prefixlen = -1;
+	r->suppress_ifgroup = -1;
+
 	/* The lock is not required here, the list in unreacheable
 	 * at the moment this function is called */
 	list_add_tail(&r->list, &ops->rules_list);
@@ -340,11 +343,15 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
-	if (tb[FRA_TABLE_PREFIXLEN_MIN])
-		rule->table_prefixlen_min = nla_get_u8(tb[FRA_TABLE_PREFIXLEN_MIN]);
+	if (tb[FRA_SUPPRESS_PREFIXLEN])
+		rule->suppress_prefixlen = nla_get_u32(tb[FRA_SUPPRESS_PREFIXLEN]);
+	else
+		rule->suppress_prefixlen = -1;
 
 	if (tb[FRA_SUPPRESS_IFGROUP])
 		rule->suppress_ifgroup = nla_get_u32(tb[FRA_SUPPRESS_IFGROUP]);
+	else
+		rule->suppress_ifgroup -1;
 
 	if (!tb[FRA_PRIORITY] && ops->default_pref)
 		rule->pref = ops->default_pref(ops);
@@ -531,7 +538,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(IFNAMSIZ) /* FRA_OIFNAME */
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
-			 + nla_total_size(1) /* FRA_TABLE_PREFIXLEN_MIN */
+			 + nla_total_size(4) /* FRA_SUPPRESS_PREFIXLEN */
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4); /* FRA_FWMASK */
@@ -558,7 +565,7 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh->table = rule->table;
 	if (nla_put_u32(skb, FRA_TABLE, rule->table))
 		goto nla_put_failure;
-	if (nla_put_u8(skb, FRA_TABLE_PREFIXLEN_MIN, rule->table_prefixlen_min))
+	if (nla_put_u32(skb, FRA_SUPPRESS_PREFIXLEN, rule->suppress_prefixlen))
 		goto nla_put_failure;
 	frh->res1 = 0;
 	frh->res2 = 0;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index b78fd28..523be38 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -109,7 +109,7 @@ static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-	if (result->prefixlen < rule->table_prefixlen_min)
+	if (result->prefixlen <= rule->suppress_prefixlen)
 		goto suppress_route;
 
 	/* do not accept result if the route uses a device
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 3628326..a6c58ce 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -126,7 +126,7 @@ static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-	if (rt->rt6i_dst.plen < rule->table_prefixlen_min)
+	if (rt->rt6i_dst.plen <= rule->suppress_prefixlen)
 		goto suppress_route;
 
 	/* do not accept result if the route uses a device
-- 
1.7.10.4
