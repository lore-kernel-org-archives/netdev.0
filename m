From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 2/3] fib6_rules: fix throw route support
Date: Tue,  6 May 2014 18:17:20 +0300
Message-ID: <1399389441-20095-2-git-send-email-popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:60727 "EHLO
	fallback6.mail.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757869AbaEFPXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:23:32 -0400
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru [94.100.177.106])
	by fallback6.mail.ru (mPOP.Fallback_MX) with ESMTP id A90AB384AAC9
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:17:38 +0400 (MSK)
Received: from [195.234.68.4] (port=52741 helo=tuxracer.skif.com.ua)
	by smtp46.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh7X-0007OK-J9
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:17:27 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consider sample Policy-Based Routing (PBR) setup for IPv6:

 # ip -6 route add throw 2a03:2880::/32 table 100
 # ip -6 route add prohibit default table 100
 # ip -6 rule add pref 0x7ff0 table 100

 # host -t aaaa facebook.com
 facebook.com has IPv6 address 2a03:2880:2110:df07:face:b00c:0:1

 # ping6 2a03:2880:2110:df07:face:b00c:0:1
 connect: Resource temporarily unavailable

 # ip -6 route show table 100
 throw 2a03:2880::/32 dev lo  metric 1024  error -11
 prohibit default dev lo  metric 1024  error -13

Seems ping6(1) receives -EAGAIN (-11) from kernel, where we expect
routing lookup should continue on next PBR rule (rule with 0x7ffe
preference in our case, performing lookup in "main" table).

Since rt != net->ipv6.ip6_null_entry for "throw" type routes and
not NULL we never return -EAGAIN from fib6_rule_action() and
fib_rules_lookup() returns just rt with dst.error set to -EAGAIN,
that is returned to ping6(1).

Make fib6_rule_action() return referenced rt entry for special-type
routes (e.g.: blackhole, unreachable, prohibit) among with error
code, and just error code for throw to let fib_rules_lookup()
continue on next rule in list.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv6/fib6_rules.c | 58 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 26 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b4d5e1d..d885148 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -50,12 +50,13 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			    int flags, struct fib_lookup_arg *arg)
 {
+	struct fib6_rule *r = (struct fib6_rule *) rule;
 	struct flowi6 *flp6 = &flp->u.ip6;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 	struct net *net = rule->fr_net;
 	pol_lookup_t lookup = arg->lookup_ptr;
-	int err = 0;
+	int err;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
@@ -82,30 +83,37 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	}
 
 	rt = lookup(net, table, flp6, flags);
-	if (rt != net->ipv6.ip6_null_entry) {
-		struct fib6_rule *r = (struct fib6_rule *)rule;
-
-		/*
-		 * If we need to find a source address for this traffic,
-		 * we check the result if it meets requirement of the rule.
-		 */
-		if ((rule->flags & FIB_RULE_FIND_SADDR) &&
-		    r->src.plen && !(flags & RT6_LOOKUP_F_HAS_SADDR)) {
-			struct in6_addr saddr;
-
-			if (ipv6_dev_get_saddr(net,
-					       ip6_dst_idev(&rt->dst)->dev,
-					       &flp6->daddr,
-					       rt6_flags2srcprefs(flags),
-					       &saddr))
-				goto again;
-			if (!ipv6_prefix_equal(&saddr, &r->src.addr,
-					       r->src.plen))
-				goto again;
-			flp6->saddr = saddr;
-		}
+	err = rt->dst.error;
+	if (err) {
+		if (err == -EAGAIN || rt == net->ipv6.ip6_null_entry)
+			goto again;
 		goto out;
 	}
+
+	/*
+	 * If we need to find a source address for this traffic,
+	 * we check the result if it meets requirement of the rule.
+	 */
+	if ((rule->flags & FIB_RULE_FIND_SADDR) &&
+	    r->src.plen && !(flags & RT6_LOOKUP_F_HAS_SADDR)) {
+		struct in6_addr saddr;
+
+		if (ipv6_dev_get_saddr(net,
+				       ip6_dst_idev(&rt->dst)->dev,
+				       &flp6->daddr,
+				       rt6_flags2srcprefs(flags),
+				       &saddr))
+			goto again;
+		if (!ipv6_prefix_equal(&saddr, &r->src.addr,
+				       r->src.plen))
+			goto again;
+		flp6->saddr = saddr;
+	}
+
+out:
+	arg->result = rt;
+	return err;
+
 again:
 	ip6_rt_put(rt);
 	err = -EAGAIN;
@@ -114,9 +122,7 @@ again:
 
 discard_pkt:
 	dst_hold(&rt->dst);
-out:
-	arg->result = rt;
-	return err;
+	goto out;
 }
 
 static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
-- 
1.8.3.4
