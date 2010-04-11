From: kaber@trash.net
Subject: [RFC PATCH 3/9] net: fib_rules: decouple address families from real address families
Date: Sun, 11 Apr 2010 19:37:09 +0200
Message-ID: <1271007435-20035-4-git-send-email-kaber@trash.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37501 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab0DKRhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 13:37:20 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by stinky.trash.net (Postfix) with ESMTP id D7B5DB2C4F
	for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 19:37:18 +0200 (MEST)
In-Reply-To: <1271007435-20035-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Decouple the address family values used for fib_rules from the real
address families in socket.h. This allows to use fib_rules for
code that is not a real address family without increasing AF_MAX/NPROTO.

Values up to 127 are reserved for real address families and map directly
to the corresponding AF value, values starting from 128 are for other
uses. rtnetlink is changed to invoke the AF_UNSPEC dumpit/doit handlers
for these families.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/fib_rules.h |    7 +++++++
 net/core/rtnetlink.c      |   15 ++++++++++-----
 net/decnet/dn_rules.c     |    2 +-
 net/ipv4/fib_rules.c      |    2 +-
 net/ipv6/fib6_rules.c     |    2 +-
 5 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 51da65b..405e411 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -15,6 +15,13 @@
 /* try to find source address in routing lookups */
 #define FIB_RULE_FIND_SADDR	0x00010000
 
+/* fib_rules families. values up to 127 are reserved for real address
+ * families, values above 128 may be used arbitrarily.
+ */
+#define FIB_RULES_IPV4		AF_INET
+#define FIB_RULES_IPV6		AF_INET6
+#define FIB_RULES_DECNET	AF_DECnet
+
 struct fib_rule_hdr {
 	__u8		family;
 	__u8		dst_len;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bf919b6..78c8598 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -118,7 +118,11 @@ static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
 {
 	struct rtnl_link *tab;
 
-	tab = rtnl_msg_handlers[protocol];
+	if (protocol < NPROTO)
+		tab = rtnl_msg_handlers[protocol];
+	else
+		tab = NULL;
+
 	if (tab == NULL || tab[msgindex].doit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
@@ -129,7 +133,11 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
 {
 	struct rtnl_link *tab;
 
-	tab = rtnl_msg_handlers[protocol];
+	if (protocol < NPROTO)
+		tab = rtnl_msg_handlers[protocol];
+	else
+		tab = NULL;
+
 	if (tab == NULL || tab[msgindex].dumpit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
@@ -1444,9 +1452,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return 0;
 
 	family = ((struct rtgenmsg *)NLMSG_DATA(nlh))->rtgen_family;
-	if (family >= NPROTO)
-		return -EAFNOSUPPORT;
-
 	sz_idx = type>>2;
 	kind = type&3;
 
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 1c8cc6d..af28dcc 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -217,7 +217,7 @@ static void dn_fib_rule_flush_cache(struct fib_rules_ops *ops)
 }
 
 static struct fib_rules_ops dn_fib_rules_ops_template = {
-	.family		= AF_DECnet,
+	.family		= FIB_RULES_DECNET,
 	.rule_size	= sizeof(struct dn_fib_rule),
 	.addr_size	= sizeof(u16),
 	.action		= dn_fib_rule_action,
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index a18355e..3ec84fe 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -246,7 +246,7 @@ static void fib4_rule_flush_cache(struct fib_rules_ops *ops)
 }
 
 static struct fib_rules_ops fib4_rules_ops_template = {
-	.family		= AF_INET,
+	.family		= FIB_RULES_IPV4,
 	.rule_size	= sizeof(struct fib4_rule),
 	.addr_size	= sizeof(u32),
 	.action		= fib4_rule_action,
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 92b2b7f..8124f16 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -238,7 +238,7 @@ static size_t fib6_rule_nlmsg_payload(struct fib_rule *rule)
 }
 
 static struct fib_rules_ops fib6_rules_ops_template = {
-	.family			= AF_INET6,
+	.family			= FIB_RULES_IPV6,
 	.rule_size		= sizeof(struct fib6_rule),
 	.addr_size		= sizeof(struct in6_addr),
 	.action			= fib6_rule_action,
-- 
1.7.0.4

