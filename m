From: Patrick McHardy <kaber@trash.net>
Subject: net 02/05: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
Date: Mon, 30 Nov 2009 18:55:32 +0100 (MET)
Message-ID: <20091130175532.7555.11857.sendpatchset@x2.localnet>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56503 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZK3Rz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:55:27 -0500
In-Reply-To: <20091130175529.7555.10132.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit dc4427ae3647195508b4df883050a9f0ef111165
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 30 15:54:05 2009 +0100

    net: fib_rules: rename ifindex/ifname/FRA_IFNAME to iifindex/iifname/FRA_IIFNAME
    
    The next patch will add oif classification, rename interface related members
    and attributes to reflect that they're used for iif classification.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index c7e5b70..e3c91af 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -8,7 +8,8 @@
 #define FIB_RULE_PERMANENT	0x00000001
 #define FIB_RULE_INVERT		0x00000002
 #define FIB_RULE_UNRESOLVED	0x00000004
-#define FIB_RULE_DEV_DETACHED	0x00000008
+#define FIB_RULE_IIF_DETACHED	0x00000008
+#define FIB_RULE_DEV_DETACHED	FIB_RULE_DEV_DETACHED
 
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
@@ -31,7 +32,8 @@ enum {
 	FRA_UNSPEC,
 	FRA_DST,	/* destination address */
 	FRA_SRC,	/* source address */
-	FRA_IFNAME,	/* interface name */
+	FRA_IIFNAME,	/* interface name */
+#define FRA_IFNAME	FRA_IIFNAME
 	FRA_GOTO,	/* target to jump to (FR_ACT_GOTO) */
 	FRA_UNUSED2,
 	FRA_PRIORITY,	/* priority/preference */
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 22fb323..62bebcb 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -10,7 +10,7 @@
 struct fib_rule {
 	struct list_head	list;
 	atomic_t		refcnt;
-	int			ifindex;
+	int			iifindex;
 	u32			mark;
 	u32			mark_mask;
 	u32			pref;
@@ -19,7 +19,7 @@ struct fib_rule {
 	u8			action;
 	u32			target;
 	struct fib_rule *	ctarget;
-	char			ifname[IFNAMSIZ];
+	char			iifname[IFNAMSIZ];
 	struct rcu_head		rcu;
 	struct net *		fr_net;
 };
@@ -67,7 +67,7 @@ struct fib_rules_ops {
 };
 
 #define FRA_GENERIC_POLICY \
-	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
+	[FRA_IIFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 }, \
 	[FRA_PRIORITY]	= { .type = NLA_U32 }, \
 	[FRA_FWMARK]	= { .type = NLA_U32 }, \
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index bd30938..8e8028c 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -135,7 +135,7 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 {
 	int ret = 0;
 
-	if (rule->ifindex && (rule->ifindex != fl->iif))
+	if (rule->iifindex && (rule->iifindex != fl->iif))
 		goto out;
 
 	if ((rule->mark ^ fl->mark) & rule->mark_mask)
@@ -248,14 +248,14 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
 
-	if (tb[FRA_IFNAME]) {
+	if (tb[FRA_IIFNAME]) {
 		struct net_device *dev;
 
-		rule->ifindex = -1;
-		nla_strlcpy(rule->ifname, tb[FRA_IFNAME], IFNAMSIZ);
-		dev = __dev_get_by_name(net, rule->ifname);
+		rule->iifindex = -1;
+		nla_strlcpy(rule->iifname, tb[FRA_IIFNAME], IFNAMSIZ);
+		dev = __dev_get_by_name(net, rule->iifname);
 		if (dev)
-			rule->ifindex = dev->ifindex;
+			rule->iifindex = dev->ifindex;
 	}
 
 	if (tb[FRA_FWMARK]) {
@@ -388,8 +388,8 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		    (rule->pref != nla_get_u32(tb[FRA_PRIORITY])))
 			continue;
 
-		if (tb[FRA_IFNAME] &&
-		    nla_strcmp(tb[FRA_IFNAME], rule->ifname))
+		if (tb[FRA_IIFNAME] &&
+		    nla_strcmp(tb[FRA_IIFNAME], rule->iifname))
 			continue;
 
 		if (tb[FRA_FWMARK] &&
@@ -447,7 +447,7 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 					 struct fib_rule *rule)
 {
 	size_t payload = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
-			 + nla_total_size(IFNAMSIZ) /* FRA_IFNAME */
+			 + nla_total_size(IFNAMSIZ) /* FRA_IIFNAME */
 			 + nla_total_size(4) /* FRA_PRIORITY */
 			 + nla_total_size(4) /* FRA_TABLE */
 			 + nla_total_size(4) /* FRA_FWMARK */
@@ -481,11 +481,11 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	if (rule->action == FR_ACT_GOTO && rule->ctarget == NULL)
 		frh->flags |= FIB_RULE_UNRESOLVED;
 
-	if (rule->ifname[0]) {
-		NLA_PUT_STRING(skb, FRA_IFNAME, rule->ifname);
+	if (rule->iifname[0]) {
+		NLA_PUT_STRING(skb, FRA_IIFNAME, rule->iifname);
 
-		if (rule->ifindex == -1)
-			frh->flags |= FIB_RULE_DEV_DETACHED;
+		if (rule->iifindex == -1)
+			frh->flags |= FIB_RULE_IIF_DETACHED;
 	}
 
 	if (rule->pref)
@@ -600,9 +600,9 @@ static void attach_rules(struct list_head *rules, struct net_device *dev)
 	struct fib_rule *rule;
 
 	list_for_each_entry(rule, rules, list) {
-		if (rule->ifindex == -1 &&
-		    strcmp(dev->name, rule->ifname) == 0)
-			rule->ifindex = dev->ifindex;
+		if (rule->iifindex == -1 &&
+		    strcmp(dev->name, rule->iifname) == 0)
+			rule->iifindex = dev->ifindex;
 	}
 }
 
@@ -611,8 +611,8 @@ static void detach_rules(struct list_head *rules, struct net_device *dev)
 	struct fib_rule *rule;
 
 	list_for_each_entry(rule, rules, list)
-		if (rule->ifindex == dev->ifindex)
-			rule->ifindex = -1;
+		if (rule->iifindex == dev->ifindex)
+			rule->iifindex = -1;
 }
 
 
