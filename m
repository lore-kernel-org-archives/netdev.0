From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: fix the incorrect return value of throw route
Date: Fri, 23 Oct 2015 15:36:53 +0800
Message-ID: <13819cbd31a50ae677a94763be27e16118e90322.1445585813.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34522 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbJWHg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 03:36:58 -0400
Received: by padhk11 with SMTP id hk11so111183775pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 00:36:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The error condition -EAGAIN, which is signaled by throw routes, tells
the rules framework to walk on searching for next matches. If the walk
ends and we stop walking the rules with the result of a throw route we
have to translate the error conditions to -ENETUNREACH.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/fib6_rules.c | 19 +++++++++++++++----
 net/ipv6/ip6_fib.c    | 12 +++++++++++-
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 9f777ec..ed33abf 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -32,6 +32,7 @@ struct fib6_rule {
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
+	struct rt6_info *rt;
 	struct fib_lookup_arg arg = {
 		.lookup_ptr = lookup,
 		.flags = FIB_LOOKUP_NOREF,
@@ -40,11 +41,21 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 	fib_rules_lookup(net->ipv6.fib6_rules_ops,
 			 flowi6_to_flowi(fl6), flags, &arg);
 
-	if (arg.result)
-		return arg.result;
+	rt = arg.result;
 
-	dst_hold(&net->ipv6.ip6_null_entry->dst);
-	return &net->ipv6.ip6_null_entry->dst;
+	if (!rt) {
+		dst_hold(&net->ipv6.ip6_null_entry->dst);
+		return &net->ipv6.ip6_null_entry->dst;
+	}
+
+	if (rt->rt6i_flags & RTF_REJECT &&
+	    rt->dst.error == -EAGAIN) {
+		ip6_rt_put(rt);
+		rt = net->ipv6.ip6_null_entry;
+		dst_hold(&rt->dst);
+	}
+
+	return &rt->dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 7d2e002..6cedc62 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -285,7 +285,17 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(net, net->ipv6.fib6_main_tbl, fl6, flags);
+	struct rt6_info *rt;
+
+	rt = lookup(net, net->ipv6.fib6_main_tbl, fl6, flags);
+	if (rt->rt6i_flags & RTF_REJECT &&
+	    rt->dst.error == -EAGAIN) {
+		ip6_rt_put(rt);
+		rt = net->ipv6.ip6_null_entry;
+		dst_hold(&rt->dst);
+	}
+
+	return &rt->dst;
 }
 
 static void __net_init fib6_tables_init(struct net *net)
-- 
2.1.0
