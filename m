From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6.22] [IPV6] FIB6RULE: Find source address during
 looking up route.
Date: Tue, 27 Mar 2007 22:45:37 +0900 (JST)
Message-ID: <20070327.224537.09436398.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, takamiya@po.ntts.co.jp,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:35257 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855AbXC0Now (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 09:44:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When looking up route for destination with rules with
source address restrictions, we may need to find a source
address for the traffic if not given.

Based on patch from Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/fib_rules.h |    7 +++++--
 net/ipv6/fib6_rules.c     |   34 +++++++++++++++++++++++++++++++---
 2 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 8270aac..2bbfa87 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -5,8 +5,11 @@
 #include <linux/rtnetlink.h>
 
 /* rule is permanent, and cannot be deleted */
-#define FIB_RULE_PERMANENT	1
-#define FIB_RULE_INVERT		2
+#define FIB_RULE_PERMANENT	0x00000001
+#define FIB_RULE_INVERT		0x00000002
+
+/* try to find source address in routing lookups */
+#define	FIB_RULE_FIND_SADDR	0x00010000
 
 struct fib_rule_hdr
 {
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index f0f0e8c..514a743 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -17,6 +17,7 @@
 
 #include <net/fib_rules.h>
 #include <net/ipv6.h>
+#include <net/addrconf.h>
 #include <net/ip6_route.h>
 #include <net/netlink.h>
 
@@ -95,8 +96,27 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	if (table)
 		rt = lookup(table, flp, flags);
 
-	if (rt != &ip6_null_entry)
+	if (rt != &ip6_null_entry) {
+		struct fib6_rule *r = (struct fib6_rule *)rule;
+
+		/*
+		 * If we need to find a source address for this traffic,
+		 * we check the result if it meets requirement of the rule.
+		 */
+		if ((rule->flags & FIB_RULE_FIND_SADDR) &&
+		    r->src.plen && !(flags & RT6_LOOKUP_F_HAS_SADDR)) {
+			struct in6_addr saddr;
+			if (ipv6_get_saddr(&rt->u.dst, &flp->fl6_dst,
+					   &saddr))
+				goto again;
+			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
+					       r->src.plen))
+				goto again;
+			ipv6_addr_copy(&flp->fl6_src, &saddr);
+		}
 		goto out;
+	}
+again:
 	dst_release(&rt->u.dst);
 	rt = NULL;
 	goto out;
@@ -117,9 +137,17 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 	    !ipv6_prefix_equal(&fl->fl6_dst, &r->dst.addr, r->dst.plen))
 		return 0;
 
+	/*
+	 * If FIB_RULE_FIND_SADDR is set and we do not have a
+	 * source address for the traffic, we defer check for
+	 * source address.
+	 */
 	if (r->src.plen) {
-		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
-		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
+		if (flags & RT6_LOOKUP_F_HAS_SADDR) {
+			if (!ipv6_prefix_equal(&fl->fl6_src, &r->src.addr,
+					       r->src.plen))
+				return 0;
+		} else if (!(r->common.flags & FIB_RULE_FIND_SADDR))
 			return 0;
 	}
 
-- 
1.4.4.1.g562ce

