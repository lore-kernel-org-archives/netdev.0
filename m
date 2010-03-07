From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] ipv6: Optmize translation between IPV6_PREFER_SRC_xxx and RT6_LOOKUP_F_xxx.
Date: Sun, 7 Mar 2010 19:14:44 +0900
Message-ID: <201003071014.o27AEio4001703@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52385 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab0CGKOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 05:14:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPV6_PREFER_SRC_xxx definitions:
| #define IPV6_PREFER_SRC_TMP             0x0001
| #define IPV6_PREFER_SRC_PUBLIC          0x0002
| #define IPV6_PREFER_SRC_COA             0x0004

RT6_LOOKUP_F_xxx definitions:
| #define RT6_LOOKUP_F_SRCPREF_TMP        0x00000008
| #define RT6_LOOKUP_F_SRCPREF_PUBLIC     0x00000010
| #define RT6_LOOKUP_F_SRCPREF_COA        0x00000020

So, we can translate between these two groups by shift operation
instead of multiple 'if's.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_route.h |   18 ++++++++++++++++++
 net/ipv6/fib6_rules.c   |   11 ++---------
 net/ipv6/route.c        |   11 ++---------
 3 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 4a808de..68f6783 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -37,6 +37,24 @@ struct route_info {
 #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
 #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
 
+/*
+ * rt6_srcprefs2flags() and rt6_flags2srcprefs() translate
+ * between IPV6_ADDR_PREFERENCES socket option values
+ *	IPV6_PREFER_SRC_TMP    = 0x1
+ *	IPV6_PREFER_SRC_PUBLIC = 0x2
+ *	IPV6_PREFER_SRC_COA    = 0x4
+ * and above RT6_LOOKUP_F_SRCPREF_xxx flags.
+ */
+static inline int rt6_srcprefs2flags(unsigned int srcprefs)
+{
+	/* No need to bitmask because srcprefs have only 3 bits. */
+	return srcprefs << 3;
+}
+
+static inline unsigned int rt6_flags2srcprefs(int flags)
+{
+	return (flags >> 3) & 7;
+}
 
 extern void			ip6_route_input(struct sk_buff *skb);
 
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 551882b..5e463c4 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -84,18 +84,11 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 		if ((rule->flags & FIB_RULE_FIND_SADDR) &&
 		    r->src.plen && !(flags & RT6_LOOKUP_F_HAS_SADDR)) {
 			struct in6_addr saddr;
-			unsigned int srcprefs = 0;
-
-			if (flags & RT6_LOOKUP_F_SRCPREF_TMP)
-				srcprefs |= IPV6_PREFER_SRC_TMP;
-			if (flags & RT6_LOOKUP_F_SRCPREF_PUBLIC)
-				srcprefs |= IPV6_PREFER_SRC_PUBLIC;
-			if (flags & RT6_LOOKUP_F_SRCPREF_COA)
-				srcprefs |= IPV6_PREFER_SRC_COA;
 
 			if (ipv6_dev_get_saddr(net,
 					       ip6_dst_idev(&rt->u.dst)->dev,
-					       &flp->fl6_dst, srcprefs,
+					       &flp->fl6_dst,
+					       rt6_flags2srcprefs(flags),
 					       &saddr))
 				goto again;
 			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b08879e..52cd3ef 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -819,15 +819,8 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 
 	if (!ipv6_addr_any(&fl->fl6_src))
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
-	else if (sk) {
-		unsigned int prefs = inet6_sk(sk)->srcprefs;
-		if (prefs & IPV6_PREFER_SRC_TMP)
-			flags |= RT6_LOOKUP_F_SRCPREF_TMP;
-		if (prefs & IPV6_PREFER_SRC_PUBLIC)
-			flags |= RT6_LOOKUP_F_SRCPREF_PUBLIC;
-		if (prefs & IPV6_PREFER_SRC_COA)
-			flags |= RT6_LOOKUP_F_SRCPREF_COA;
-	}
+	else if (sk)
+		flags |= rt6_srcprefs2flags(inet6_sk(sk)->srcprefs);
 
 	return fib6_rule_lookup(net, fl, flags, ip6_pol_route_output);
 }
-- 
1.5.6.5

