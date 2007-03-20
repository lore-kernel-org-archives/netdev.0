From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Fix fib_rules compatibility breakage
Date: Tue, 20 Mar 2007 19:15:47 +0100
Message-ID: <20070320181547.GO521@postel.suug.ch>
References: <200703190046.47021.luciano@lugmen.org.ar> <45FE2587.3050205@trash.net> <20070319152532.GL521@postel.suug.ch> <45FF7D07.4040103@trash.net> <45FF8269.3000606@trash.net> <20070320164004.GN521@postel.suug.ch> <46001300.90804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lartc@mailman.ds9a.nl
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42516 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbXCTSP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 14:15:27 -0400
Content-Disposition: inline
In-Reply-To: <46001300.90804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2007-03-20 17:59
> The presence of the attributes when src_len/dst_len is non-zero
> is only verified in fib_newrule, so this looks like it might crash
> when something broken sets src_len/dst_len to a non-zero value
> without actually adding the attributes.

You're right, we need to validate in fib_nl_delrule() as well.

Based on Patrick's patch:
The fib_rules netlink attribute policy introduced in 2.6.19 broke
userspace compatibilty. When specifying a rule with "from all"
or "to all", iproute adds a zero byte long netlink attribute,
but the policy requires all addresses to have a size equal to
sizeof(struct in_addr)/sizeof(struct in6_addr), resulting in a
validation error.

Check attribute length of FRA_SRC/FRA_DST in the generic framework
by letting the family specific rules implementation provide the
length of an address. Report an error if address length is non
zero but no address attribute is provided. Fix actual bug by
checking address length for non-zero instead of relying on
availability of attribute.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/include/net/fib_rules.h
===================================================================
--- net-2.6.orig/include/net/fib_rules.h	2007-03-20 16:49:06.000000000 +0100
+++ net-2.6/include/net/fib_rules.h	2007-03-20 17:22:35.000000000 +0100
@@ -34,6 +34,7 @@ struct fib_rules_ops
 	int			family;
 	struct list_head	list;
 	int			rule_size;
+	int			addr_size;
 
 	int			(*action)(struct fib_rule *,
 					  struct flowi *, int,
Index: net-2.6/net/core/fib_rules.c
===================================================================
--- net-2.6.orig/net/core/fib_rules.c	2007-03-20 16:49:06.000000000 +0100
+++ net-2.6/net/core/fib_rules.c	2007-03-20 19:09:52.000000000 +0100
@@ -152,6 +152,28 @@ out:
 
 EXPORT_SYMBOL_GPL(fib_rules_lookup);
 
+static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
+			    struct fib_rules_ops *ops)
+{
+	int err = -EINVAL;
+
+	if (frh->src_len)
+		if (tb[FRA_SRC] == NULL ||
+		    frh->src_len > (ops->addr_size * 8) ||
+		    nla_len(tb[FRA_SRC]) != ops->addr_size)
+			goto errout;
+
+	if (frh->dst_len)
+		if (tb[FRA_DST] == NULL ||
+		    frh->dst_len > (ops->addr_size * 8) ||
+		    nla_len(tb[FRA_DST]) != ops->addr_size)
+			goto errout;
+
+	err = 0;
+errout:
+	return err;
+}
+
 int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -173,6 +195,10 @@ int fib_nl_newrule(struct sk_buff *skb, 
 	if (err < 0)
 		goto errout;
 
+	err = validate_rulemsg(frh, tb, ops);
+	if (err < 0)
+		goto errout;
+
 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
 	if (rule == NULL) {
 		err = -ENOMEM;
@@ -260,6 +286,10 @@ int fib_nl_delrule(struct sk_buff *skb, 
 	if (err < 0)
 		goto errout;
 
+	err = validate_rulemsg(frh, tb, ops);
+	if (err < 0)
+		goto errout;
+
 	list_for_each_entry(rule, ops->rules_list, list) {
 		if (frh->action && (frh->action != rule->action))
 			continue;
Index: net-2.6/net/decnet/dn_rules.c
===================================================================
--- net-2.6.orig/net/decnet/dn_rules.c	2007-03-20 16:49:06.000000000 +0100
+++ net-2.6/net/decnet/dn_rules.c	2007-03-20 17:22:35.000000000 +0100
@@ -109,8 +109,6 @@ errout:
 
 static struct nla_policy dn_fib_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .type = NLA_U16 },
-	[FRA_DST]	= { .type = NLA_U16 },
 };
 
 static int dn_fib_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
@@ -133,7 +131,7 @@ static int dn_fib_rule_configure(struct 
 	int err = -EINVAL;
 	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
 
-	if (frh->src_len > 16 || frh->dst_len > 16 || frh->tos)
+	if (frh->tos)
 		goto  errout;
 
 	if (rule->table == RT_TABLE_UNSPEC) {
@@ -150,10 +148,10 @@ static int dn_fib_rule_configure(struct 
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len)
 		r->src = nla_get_le16(tb[FRA_SRC]);
 
-	if (tb[FRA_DST])
+	if (frh->dst_len)
 		r->dst = nla_get_le16(tb[FRA_DST]);
 
 	r->src_len = frh->src_len;
@@ -176,10 +174,10 @@ static int dn_fib_rule_compare(struct fi
 	if (frh->dst_len && (r->dst_len != frh->dst_len))
 		return 0;
 
-	if (tb[FRA_SRC] && (r->src != nla_get_le16(tb[FRA_SRC])))
+	if (frh->src_len && (r->src != nla_get_le16(tb[FRA_SRC])))
 		return 0;
 
-	if (tb[FRA_DST] && (r->dst != nla_get_le16(tb[FRA_DST])))
+	if (frh->dst_len && (r->dst != nla_get_le16(tb[FRA_DST])))
 		return 0;
 
 	return 1;
@@ -249,6 +247,7 @@ int dn_fib_dump_rules(struct sk_buff *sk
 static struct fib_rules_ops dn_fib_rules_ops = {
 	.family		= AF_DECnet,
 	.rule_size	= sizeof(struct dn_fib_rule),
+	.addr_size	= sizeof(u16),
 	.action		= dn_fib_rule_action,
 	.match		= dn_fib_rule_match,
 	.configure	= dn_fib_rule_configure,
Index: net-2.6/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.orig/net/ipv4/fib_rules.c	2007-03-20 16:49:06.000000000 +0100
+++ net-2.6/net/ipv4/fib_rules.c	2007-03-20 17:22:35.000000000 +0100
@@ -171,8 +171,6 @@ static struct fib_table *fib_empty_table
 
 static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .type = NLA_U32 },
-	[FRA_DST]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
 };
 
@@ -183,8 +181,7 @@ static int fib4_rule_configure(struct fi
 	int err = -EINVAL;
 	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
-	if (frh->src_len > 32 || frh->dst_len > 32 ||
-	    (frh->tos & ~IPTOS_TOS_MASK))
+	if (frh->tos & ~IPTOS_TOS_MASK)
 		goto errout;
 
 	if (rule->table == RT_TABLE_UNSPEC) {
@@ -201,10 +198,10 @@ static int fib4_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len)
 		rule4->src = nla_get_be32(tb[FRA_SRC]);
 
-	if (tb[FRA_DST])
+	if (frh->dst_len)
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -242,10 +239,10 @@ static int fib4_rule_compare(struct fib_
 		return 0;
 #endif
 
-	if (tb[FRA_SRC] && (rule4->src != nla_get_be32(tb[FRA_SRC])))
+	if (frh->src_len && (rule4->src != nla_get_be32(tb[FRA_SRC])))
 		return 0;
 
-	if (tb[FRA_DST] && (rule4->dst != nla_get_be32(tb[FRA_DST])))
+	if (frh->dst_len && (rule4->dst != nla_get_be32(tb[FRA_DST])))
 		return 0;
 
 	return 1;
@@ -309,6 +306,7 @@ static size_t fib4_rule_nlmsg_payload(st
 static struct fib_rules_ops fib4_rules_ops = {
 	.family		= AF_INET,
 	.rule_size	= sizeof(struct fib4_rule),
+	.addr_size	= sizeof(u32),
 	.action		= fib4_rule_action,
 	.match		= fib4_rule_match,
 	.configure	= fib4_rule_configure,
Index: net-2.6/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.orig/net/ipv6/fib6_rules.c	2007-03-20 16:49:06.000000000 +0100
+++ net-2.6/net/ipv6/fib6_rules.c	2007-03-20 17:22:35.000000000 +0100
@@ -131,8 +131,6 @@ static int fib6_rule_match(struct fib_ru
 
 static struct nla_policy fib6_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .len = sizeof(struct in6_addr) },
-	[FRA_DST]	= { .len = sizeof(struct in6_addr) },
 };
 
 static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
@@ -142,9 +140,6 @@ static int fib6_rule_configure(struct fi
 	int err = -EINVAL;
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
-	if (frh->src_len > 128 || frh->dst_len > 128)
-		goto errout;
-
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
@@ -155,11 +150,11 @@ static int fib6_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len)
 		nla_memcpy(&rule6->src.addr, tb[FRA_SRC],
 			   sizeof(struct in6_addr));
 
-	if (tb[FRA_DST])
+	if (frh->dst_len)
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
@@ -186,11 +181,11 @@ static int fib6_rule_compare(struct fib_
 	if (frh->tos && (rule6->tclass != frh->tos))
 		return 0;
 
-	if (tb[FRA_SRC] &&
+	if (frh->src_len &&
 	    nla_memcmp(tb[FRA_SRC], &rule6->src.addr, sizeof(struct in6_addr)))
 		return 0;
 
-	if (tb[FRA_DST] &&
+	if (frh->dst_len &&
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 
@@ -240,6 +235,7 @@ static size_t fib6_rule_nlmsg_payload(st
 static struct fib_rules_ops fib6_rules_ops = {
 	.family			= AF_INET6,
 	.rule_size		= sizeof(struct fib6_rule),
+	.addr_size		= sizeof(struct in6_addr),
 	.action			= fib6_rule_action,
 	.match			= fib6_rule_match,
 	.configure		= fib6_rule_configure,
