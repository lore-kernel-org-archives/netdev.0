From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH] fib_rules: add minimum prefix length
Date: Wed, 24 Jul 2013 00:02:21 +0200
Message-ID: <20130723220221.GP10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:52187 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933930Ab3GWWVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 18:21:36 -0400
Received: from stefan by zirkel.wertarbyte.de with local (Exim 4.72)
	(envelope-from <stefan.tomanek@wertarbyte.de>)
	id 1V1kez-000573-WB
	for netdev@vger.kernel.org; Wed, 24 Jul 2013 00:02:22 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a minimum prefix length to the structures of routing rules.
If a rule is added with a minimum prefix length >0, only routes meeting this
threshold will be considered. Any other (more general) routing table entries
will be ignored.

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
 include/net/fib_rules.h        |    1 +
 include/uapi/linux/fib_rules.h |    2 +-
 net/core/fib_rules.c           |    5 +++++
 net/ipv4/fib_rules.c           |   11 ++++++++++-
 4 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index e361f48..b098a9d 100644
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
index 2173544..8a15621 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -337,6 +337,8 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
+	if (tb[FRA_TABLE_PREFIXLEN_MIN])
+		rule->table_prefixlen_min = nla_get_u8(tb[FRA_TABLE_PREFIXLEN_MIN]);
 
 	if (!tb[FRA_PRIORITY] && ops->default_pref)
 		rule->pref = ops->default_pref(ops);
@@ -523,6 +525,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(IFNAMSIZ) /* FRA_OIFNAME */
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
+			 + nla_total_size(1) /* FRA_TABLE_PREFIXLEN_MIN */
 			 + nla_total_size(4) /* FRA_FWMARK */
 			 + nla_total_size(4); /* FRA_FWMASK */
 
@@ -548,6 +551,8 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh->table = rule->table;
 	if (nla_put_u32(skb, FRA_TABLE, rule->table))
 		goto nla_put_failure;
+	if (nla_put_u8(skb, FRA_TABLE_PREFIXLEN_MIN, rule->table_prefixlen_min))
+		goto nla_put_failure;
 	frh->res1 = 0;
 	frh->res2 = 0;
 	frh->action = rule->action;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 26aa65d..94e9051 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -95,8 +95,17 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto errout;
 
 	err = fib_table_lookup(tbl, &flp->u.ip4, (struct fib_result *) arg->result, arg->flags);
-	if (err > 0)
+	if (err > 0) {
 		err = -EAGAIN;
+		goto errout;
+	}
+	/* do not accept result if the route does not meet the required prefix length */
+	if (arg->result) {
+		if (((struct fib_result *)arg->result)->prefixlen < rule->table_prefixlen_min) {
+			err = -EAGAIN;
+			goto errout;
+		}
+	}
 errout:
 	return err;
 }
-- 
1.7.10.4
