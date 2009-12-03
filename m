From: Patrick McHardy <kaber@trash.net>
Subject: net 03/05: fib_rules: add oif classification
Date: Thu,  3 Dec 2009 12:25:56 +0100 (MET)
Message-ID: <20091203112554.15100.36256.sendpatchset@x2.localnet>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60319 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755959AbZLCLZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 06:25:50 -0500
In-Reply-To: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 68144d350f4f6c348659c825cde6a82b34c27a91
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Dec 3 12:05:25 2009 +0100

    net: fib_rules: add oif classification
    
    Support routing table lookup based on the flow's oif. This is useful to
    classify packets originating from sockets bound to interfaces differently.
    
    The route cache already includes the oif and needs no changes.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 7e11bb2..51da65b 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -10,6 +10,7 @@
 #define FIB_RULE_UNRESOLVED	0x00000004
 #define FIB_RULE_IIF_DETACHED	0x00000008
 #define FIB_RULE_DEV_DETACHED	FIB_RULE_IIF_DETACHED
+#define FIB_RULE_OIF_DETACHED	0x00000010
 
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
@@ -47,6 +48,7 @@ enum {
 	FRA_UNUSED8,
 	FRA_TABLE,	/* Extended table id */
 	FRA_FWMASK,	/* mask for netfilter mark */
+	FRA_OIFNAME,
 	__FRA_MAX
 };
 
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 62bebcb..d4e875a 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -11,6 +11,7 @@ struct fib_rule {
 	struct list_head	list;
 	atomic_t		refcnt;
 	int			iifindex;
+	int			oifindex;
 	u32			mark;
 	u32			mark_mask;
 	u32			pref;
@@ -20,6 +21,7 @@ struct fib_rule {
 	u32			target;
 	struct fib_rule *	ctarget;
 	char			iifname[IFNAMSIZ];
+	char			oifname[IFNAMSIZ];
 	struct rcu_head		rcu;
 	struct net *		fr_net;
 };
@@ -68,6 +70,7 @@ struct fib_rules_ops {
 
 #define FRA_GENERIC_POLICY \
 	[FRA_IIFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
+	[FRA_OIFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
 	[FRA_PRIORITY]	= { .type = NLA_U32 }, \
 	[FRA_FWMARK]	= { .type = NLA_U32 }, \
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 8e8028c..d1a70ad 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -138,6 +138,9 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if (rule->iifindex && (rule->iifindex != fl->iif))
 		goto out;
 
+	if (rule->oifindex && (rule->oifindex != fl->oif))
+		goto out;
+
 	if ((rule->mark ^ fl->mark) & rule->mark_mask)
 		goto out;
 
@@ -258,6 +261,16 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 			rule->iifindex = dev->ifindex;
 	}
 
+	if (tb[FRA_OIFNAME]) {
+		struct net_device *dev;
+
+		rule->oifindex = -1;
+		nla_strlcpy(rule->oifname, tb[FRA_OIFNAME], IFNAMSIZ);
+		dev = __dev_get_by_name(net, rule->oifname);
+		if (dev)
+			rule->oifindex = dev->ifindex;
+	}
+
 	if (tb[FRA_FWMARK]) {
 		rule->mark = nla_get_u32(tb[FRA_FWMARK]);
 		if (rule->mark)
@@ -392,6 +405,10 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		    nla_strcmp(tb[FRA_IIFNAME], rule->iifname))
 			continue;
 
+		if (tb[FRA_OIFNAME] &&
+		    nla_strcmp(tb[FRA_OIFNAME], rule->oifname))
+			continue;
+
 		if (tb[FRA_FWMARK] &&
 		    (rule->mark != nla_get_u32(tb[FRA_FWMARK])))
 			continue;
@@ -448,6 +465,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 {
 	size_t payload = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
 			 + nla_total_size(IFNAMSIZ) /* FRA_IIFNAME */
+			 + nla_total_size(IFNAMSIZ) /* FRA_OIFNAME */
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
 			 + nla_total_size(4) /* FRA_FWMARK */
@@ -488,6 +506,13 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 			frh->flags |= FIB_RULE_IIF_DETACHED;
 	}
 
+	if (rule->oifname[0]) {
+		NLA_PUT_STRING(skb, FRA_OIFNAME, rule->oifname);
+
+		if (rule->oifindex == -1)
+			frh->flags |= FIB_RULE_OIF_DETACHED;
+	}
+
 	if (rule->pref)
 		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
 
@@ -603,6 +628,9 @@ static void attach_rules(struct list_head *rules, struct net_device *dev)
 		if (rule->iifindex == -1 &&
 		    strcmp(dev->name, rule->iifname) == 0)
 			rule->iifindex = dev->ifindex;
+		if (rule->oifindex == -1 &&
+		    strcmp(dev->name, rule->oifname) == 0)
+			rule->oifindex = dev->ifindex;
 	}
 }
 
@@ -610,9 +638,12 @@ static void detach_rules(struct list_head *rules, struct net_device *dev)
 {
 	struct fib_rule *rule;
 
-	list_for_each_entry(rule, rules, list)
+	list_for_each_entry(rule, rules, list) {
 		if (rule->iifindex == dev->ifindex)
 			rule->iifindex = -1;
+		if (rule->oifindex == dev->ifindex)
+			rule->oifindex = -1;
+	}
 }
 
 
