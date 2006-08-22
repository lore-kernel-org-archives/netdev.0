From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2] [NETLINK]: Make use of NLA_STRING/NLA_NUL_STRING attribute validation
Date: Tue, 22 Aug 2006 14:53:56 +0200
Message-ID: <20060822125840.588411880@postel.suug.ch>
References: <20060822125354.196502354@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48861 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932219AbWHVM7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 08:59:36 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_string_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Converts existing NLA_STRING attributes to use the new
validation features, saving a couple of temporary buffers.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -369,8 +369,8 @@ static int rtnl_dump_ifinfo(struct sk_bu
 }
 
 static struct nla_policy ifla_policy[IFLA_MAX+1] __read_mostly = {
-	[IFLA_IFNAME]		= { .type = NLA_STRING },
-	[IFLA_MAP]		= { .minlen = sizeof(struct rtnl_link_ifmap) },
+	[IFLA_IFNAME]		= { .type = NLA_STRING, .len = IFNAMSIZ-1 },
+	[IFLA_MAP]		= { .len = sizeof(struct rtnl_link_ifmap) },
 	[IFLA_MTU]		= { .type = NLA_U32 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
 	[IFLA_WEIGHT]		= { .type = NLA_U32 },
@@ -390,9 +390,8 @@ static int rtnl_setlink(struct sk_buff *
 	if (err < 0)
 		goto errout;
 
-	if (tb[IFLA_IFNAME] &&
-	    nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ) >= IFNAMSIZ)
-		return -EINVAL;
+	if (tb[IFLA_IFNAME])
+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
 
 	err = -EINVAL;
 	ifm = nlmsg_data(nlh);
Index: net-2.6.19.git/net/netlink/genetlink.c
===================================================================
--- net-2.6.19.git.orig/net/netlink/genetlink.c
+++ net-2.6.19.git/net/netlink/genetlink.c
@@ -455,7 +455,8 @@ static struct sk_buff *ctrl_build_msg(st
 
 static struct nla_policy ctrl_policy[CTRL_ATTR_MAX+1] __read_mostly = {
 	[CTRL_ATTR_FAMILY_ID]	= { .type = NLA_U16 },
-	[CTRL_ATTR_FAMILY_NAME]	= { .type = NLA_STRING },
+	[CTRL_ATTR_FAMILY_NAME]	= { .type = NLA_NUL_STRING,
+				    .len = GENL_NAMSIZ - 1 },
 };
 
 static int ctrl_getfamily(struct sk_buff *skb, struct genl_info *info)
@@ -470,12 +471,9 @@ static int ctrl_getfamily(struct sk_buff
 	}
 
 	if (info->attrs[CTRL_ATTR_FAMILY_NAME]) {
-		char name[GENL_NAMSIZ];
-
-		if (nla_strlcpy(name, info->attrs[CTRL_ATTR_FAMILY_NAME],
-				GENL_NAMSIZ) >= GENL_NAMSIZ)
-			goto errout;
+		char *name;
 
+		name = nla_data(info->attrs[CTRL_ATTR_FAMILY_NAME]);
 		res = genl_family_find_byname(name);
 	}
 
Index: net-2.6.19.git/net/core/fib_rules.c
===================================================================
--- net-2.6.19.git.orig/net/core/fib_rules.c
+++ net-2.6.19.git/net/core/fib_rules.c
@@ -161,9 +161,6 @@ int fib_nl_newrule(struct sk_buff *skb, 
 	if (err < 0)
 		goto errout;
 
-	if (tb[FRA_IFNAME] && nla_len(tb[FRA_IFNAME]) > IFNAMSIZ)
-		goto errout;
-
 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
 	if (rule == NULL) {
 		err = -ENOMEM;
@@ -177,10 +174,7 @@ int fib_nl_newrule(struct sk_buff *skb, 
 		struct net_device *dev;
 
 		rule->ifindex = -1;
-		if (nla_strlcpy(rule->ifname, tb[FRA_IFNAME],
-				IFNAMSIZ) >= IFNAMSIZ)
-			goto errout_free;
-
+		nla_strlcpy(rule->ifname, tb[FRA_IFNAME], IFNAMSIZ);
 		dev = __dev_get_by_name(rule->ifname);
 		if (dev)
 			rule->ifindex = dev->ifindex;
Index: net-2.6.19.git/net/decnet/dn_rules.c
===================================================================
--- net-2.6.19.git.orig/net/decnet/dn_rules.c
+++ net-2.6.19.git/net/decnet/dn_rules.c
@@ -111,7 +111,7 @@ errout:
 }
 
 static struct nla_policy dn_fib_rule_policy[FRA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
 	[FRA_SRC]	= { .type = NLA_U16 },
 	[FRA_DST]	= { .type = NLA_U16 },
Index: net-2.6.19.git/net/ipv4/devinet.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/devinet.c
+++ net-2.6.19.git/net/ipv4/devinet.c
@@ -85,7 +85,7 @@ static struct nla_policy ifa_ipv4_policy
 	[IFA_ADDRESS]   	= { .type = NLA_U32 },
 	[IFA_BROADCAST] 	= { .type = NLA_U32 },
 	[IFA_ANYCAST]   	= { .type = NLA_U32 },
-	[IFA_LABEL]     	= { .type = NLA_STRING },
+	[IFA_LABEL]     	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 };
 
 static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
Index: net-2.6.19.git/net/ipv4/fib_rules.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_rules.c
+++ net-2.6.19.git/net/ipv4/fib_rules.c
@@ -178,7 +178,7 @@ static struct fib_table *fib_empty_table
 }
 
 static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
 	[FRA_SRC]	= { .type = NLA_U32 },
 	[FRA_DST]	= { .type = NLA_U32 },
Index: net-2.6.19.git/net/ipv6/fib6_rules.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/fib6_rules.c
+++ net-2.6.19.git/net/ipv6/fib6_rules.c
@@ -125,10 +125,10 @@ static int fib6_rule_match(struct fib_ru
 }
 
 static struct nla_policy fib6_rule_policy[RTA_MAX+1] __read_mostly = {
-	[FRA_IFNAME]	= { .type = NLA_STRING },
+	[FRA_IFNAME]	= { .type = NLA_STRING, .len = IFNAMSIZ - 1 },
 	[FRA_PRIORITY]	= { .type = NLA_U32 },
-	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },
-	[FRA_DST]	= { .minlen = sizeof(struct in6_addr) },
+	[FRA_SRC]	= { .len = sizeof(struct in6_addr) },
+	[FRA_DST]	= { .len = sizeof(struct in6_addr) },
 	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
Index: net-2.6.19.git/net/ipv4/fib_frontend.c
===================================================================
--- net-2.6.19.git.orig/net/ipv4/fib_frontend.c
+++ net-2.6.19.git/net/ipv4/fib_frontend.c
@@ -462,7 +462,7 @@ struct nla_policy rtm_ipv4_policy[RTA_MA
 	[RTA_PRIORITY]		= { .type = NLA_U32 },
 	[RTA_PREFSRC]		= { .type = NLA_U32 },
 	[RTA_METRICS]		= { .type = NLA_NESTED },
-	[RTA_MULTIPATH]		= { .minlen = sizeof(struct rtnexthop) },
+	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_PROTOINFO]		= { .type = NLA_U32 },
 	[RTA_FLOW]		= { .type = NLA_U32 },
 	[RTA_MP_ALGO]		= { .type = NLA_U32 },
Index: net-2.6.19.git/net/ipv6/route.c
===================================================================
--- net-2.6.19.git.orig/net/ipv6/route.c
+++ net-2.6.19.git/net/ipv6/route.c
@@ -1827,7 +1827,7 @@ void rt6_mtu_change(struct net_device *d
 }
 
 static struct nla_policy rtm_ipv6_policy[RTA_MAX+1] __read_mostly = {
-	[RTA_GATEWAY]           = { .minlen = sizeof(struct in6_addr) },
+	[RTA_GATEWAY]           = { .len = sizeof(struct in6_addr) },
 	[RTA_OIF]               = { .type = NLA_U32 },
 	[RTA_IIF]		= { .type = NLA_U32 },
 	[RTA_PRIORITY]          = { .type = NLA_U32 },

