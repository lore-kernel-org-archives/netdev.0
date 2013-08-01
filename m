From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fib_rules: add route suppression based on ifgroup
Date: Thu, 1 Aug 2013 17:18:09 +0200
Message-ID: <20130801151809.GB21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:51098 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab3HAPSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 11:18:11 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V4udl-0002bb-CF
	for netdev@vger.kernel.org; Thu, 01 Aug 2013 17:18:09 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the ability to suppress a routing decision based upon the
interface group the selected interface belongs to.

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 include/net/fib_rules.h        |    2 ++
 include/uapi/linux/fib_rules.h |    2 +-
 net/core/fib_rules.c           |   10 ++++++++++
 net/ipv4/fib_rules.c           |   23 +++++++++++++++++------
 net/ipv6/fib6_rules.c          |   16 +++++++++++++---
 5 files changed, 43 insertions(+), 10 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 2f286dc..4d32ecc 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -19,6 +19,7 @@ struct fib_rule {
 	u32			flags;
 	u32			table;
 	u8			table_prefixlen_min;
+	int			suppress_ifgroup;
 	u8			action;
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
@@ -84,6 +85,7 @@ struct fib_rules_ops {
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
 	[FRA_TABLE]     = { .type = NLA_U32 }, \
 	[FRA_TABLE_PREFIXLEN_MIN] = { .type = NLA_U8 }, \
+	[FRA_SUPPRESS_IFGROUP] = { .type = NLA_U32 }, \
 	[FRA_GOTO]	= { .type = NLA_U32 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 59cd31b..63e3116 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -44,7 +44,7 @@ enum {
 	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
-	FRA_UNUSED7,
+	FRA_SUPPRESS_IFGROUP,
 	FRA_TABLE_PREFIXLEN_MIN,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 2ef5040..5040a61 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -343,6 +343,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (tb[FRA_TABLE_PREFIXLEN_MIN])
 		rule->table_prefixlen_min = nla_get_u8(tb[FRA_TABLE_PREFIXLEN_MIN]);
 
+	if (tb[FRA_SUPPRESS_IFGROUP])
+		rule->suppress_ifgroup = nla_get_u32(tb[FRA_SUPPRESS_IFGROUP]);
+
 	if (!tb[FRA_PRIORITY] && ops->default_pref)
 		rule->pref = ops->default_pref(ops);
 
@@ -529,6 +532,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
 			 + nla_total_size(1) /* FRA_TABLE_PREFIXLEN_MIN */
+			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4); /* FRA_FWMASK */
 
@@ -588,6 +592,12 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    (rule->target &&
 	     nla_put_u32(skb, FRA_GOTO, rule->target)))
 		goto nla_put_failure;
+
+	if (rule->suppress_ifgroup != -1) {
+		if (nla_put_u32(skb, FRA_SUPPRESS_IFGROUP, rule->suppress_ifgroup))
+			goto nla_put_failure;
+	}
+
 	if (ops->fill(rule, skb, frh) < 0)
 		goto nla_put_failure;
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 9f29066..234b085 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -103,16 +103,27 @@ errout:
 
 static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
+	struct fib_result *result = (struct fib_result *) arg->result;
+	struct net_device *dev = result->fi->fib_dev;
+
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-	struct fib_result *result = (struct fib_result *) arg->result;
-	if (result->prefixlen < rule->table_prefixlen_min) {
-		if (!(arg->flags & FIB_LOOKUP_NOREF))
-			fib_info_put(result->fi);
-		return true;
-	}
+	if (result->prefixlen < rule->table_prefixlen_min)
+		goto suppress_route;
+
+	/* do not accept result if the route uses a device
+	 * belonging to a forbidden interface group (!= 0)
+	 */
+	if (rule->suppress_ifgroup != -1 && dev && dev->group == rule->suppress_ifgroup)
+		goto suppress_route;
+
 	return false;
+
+suppress_route:
+	if (!(arg->flags & FIB_LOOKUP_NOREF))
+		fib_info_put(result->fi);
+	return true;
 }
 
 static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 554a4fb..84cf125 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -122,14 +122,24 @@ out:
 static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
 {
 	struct rt6_info *rt = (struct rt6_info *) arg->result;
+	struct net_device *dev = rt->rt6i_idev->dev;
 	/* do not accept result if the route does
 	 * not meet the required prefix length
 	 */
-	if (rt->rt6i_dst.plen < rule->table_prefixlen_min) {
+	if (rt->rt6i_dst.plen < rule->table_prefixlen_min)
+		goto suppress_route;
+
+	/* do not accept result if the route uses a device
+	 * belonging to a forbidden interface group (!= 0)
+	 */
+	if (rule->suppress_ifgroup != -1 && dev && dev->group == rule->suppress_ifgroup)
+		goto suppress_route;
+
+	return false;
+
+suppress_route:
 		ip6_rt_put(rt);
 		return true;
-	}
-	return false;
 }
 
 static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
-- 
1.7.10.4
