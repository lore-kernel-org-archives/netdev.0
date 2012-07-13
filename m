From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Don't store a rule pointer in fib_result.
Date: Fri, 13 Jul 2012 08:22:09 -0700 (PDT)
Message-ID: <20120713.082209.894933013734590974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755669Ab2GMPWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 11:22:10 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id EF5C358397D
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 08:22:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We only use it to fetch the rule's tclassid, so just store the
tclassid there instead.

This also decreases the size of fib_result by a full 8 bytes on
64-bit.  On 32-bits it's a wash.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip_fib.h    |   12 +++---------
 net/ipv4/fib_frontend.c |    8 --------
 net/ipv4/fib_rules.c    |   15 ++++++---------
 net/ipv4/route.c        |    6 ++----
 4 files changed, 11 insertions(+), 30 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index e91fedd..5697ace 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -106,12 +106,10 @@ struct fib_result {
 	unsigned char	nh_sel;
 	unsigned char	type;
 	unsigned char	scope;
+	u32		tclassid;
 	struct fib_info *fi;
 	struct fib_table *table;
 	struct list_head *fa_head;
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	struct fib_rule	*r;
-#endif
 };
 
 struct fib_result_nl {
@@ -215,10 +213,6 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 extern int __net_init fib4_rules_init(struct net *net);
 extern void __net_exit fib4_rules_exit(struct net *net);
 
-#ifdef CONFIG_IP_ROUTE_CLASSID
-extern u32 fib_rules_tclass(const struct fib_result *res);
-#endif
-
 extern struct fib_table *fib_new_table(struct net *net, u32 id);
 extern struct fib_table *fib_get_table(struct net *net, u32 id);
 
@@ -229,7 +223,7 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 			     struct fib_result *res)
 {
 	if (!net->ipv4.fib_has_custom_rules) {
-		res->r = NULL;
+		res->tclassid = 0;
 		if (net->ipv4.fib_local &&
 		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
 				      FIB_LOOKUP_NOREF))
@@ -289,7 +283,7 @@ static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 #endif
 	*itag = FIB_RES_NH(*res).nh_tclassid<<16;
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	rtag = fib_rules_tclass(res);
+	rtag = res->tclassid;
 	if (*itag == 0)
 		*itag = (rtag<<16);
 	*itag |= (rtag>>16);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 81f8571..7a31194 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -169,10 +169,6 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	if (ipv4_is_multicast(addr))
 		return RTN_MULTICAST;
 
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	res.r = NULL;
-#endif
-
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
 	if (local_table) {
 		ret = RTN_UNICAST;
@@ -934,10 +930,6 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		.flowi4_scope = frn->fl_scope,
 	};
 
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	res.r = NULL;
-#endif
-
 	frn->err = -ENOENT;
 	if (tb) {
 		local_bh_disable();
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index c06da93..a83d74e 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -47,13 +47,6 @@ struct fib4_rule {
 #endif
 };
 
-#ifdef CONFIG_IP_ROUTE_CLASSID
-u32 fib_rules_tclass(const struct fib_result *res)
-{
-	return res->r ? ((struct fib4_rule *) res->r)->tclassid : 0;
-}
-#endif
-
 int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_lookup_arg arg = {
@@ -63,8 +56,12 @@ int __fib_lookup(struct net *net, struct flowi4 *flp, struct fib_result *res)
 	int err;
 
 	err = fib_rules_lookup(net->ipv4.rules_ops, flowi4_to_flowi(flp), 0, &arg);
-	res->r = arg.rule;
-
+#ifdef CONFIG_IP_ROUTE_CLASSID
+	if (arg.rule)
+		res->tclassid = ((struct fib4_rule *)arg.rule)->tclassid;
+	else
+		res->tclassid = 0;
+#endif
 	return err;
 }
 EXPORT_SYMBOL_GPL(__fib_lookup);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9319bf1..aad2181 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1735,7 +1735,7 @@ static void rt_set_nexthop(struct rtable *rt, const struct flowi4 *fl4,
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	set_class_tag(rt, fib_rules_tclass(res));
+	set_class_tag(rt, res->tclassid);
 #endif
 	set_class_tag(rt, itag);
 #endif
@@ -2353,11 +2353,9 @@ static struct rtable *ip_route_output_slow(struct net *net, struct flowi4 *fl4)
 	__be32 orig_saddr;
 	int orig_oif;
 
+	res.tclassid	= 0;
 	res.fi		= NULL;
 	res.table	= NULL;
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	res.r		= NULL;
-#endif
 
 	orig_daddr = fl4->daddr;
 	orig_saddr = fl4->saddr;
-- 
1.7.10.4
