From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: ipv6: Do not leak throw route references
Date: Fri, 16 Jun 2017 14:42:17 +0300
Message-ID: <1497613337-24027-1-git-send-email-serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36803 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdFPLmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 07:42:39 -0400
Received: by mail-lf0-f65.google.com with SMTP id x81so3885469lfb.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 04:42:33 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id 90sm544966lfs.9.2017.06.16.04.42.26
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 04:42:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While commit 73ba57b (ipv6: fix backtracking for throw routes)
does good job on error propagation to the fib_rules_lookup()
in fib rules core framework that also corrects throw routes
handling, it does not solve route reference leakage problem
happened when we return -EAGAIN to the fib_rules_lookup()
and leave routing table entry referenced in arg->result.

If rule with matched throw route isn't last matched in the
list we overwrite arg->result loosing reference on throw
route stored previously forever.

We also partially revert commit ab997ad (ipv6: fix the
incorrect return value of throw route) since we never return
routing table entry with dst.error == -EAGAIN when
CONFIG_IPV6_MULTIPLE_TABLES is on. Also there is no point
to check for RTF_REJECT flag since it is always set throw
route.

Fixes: 73ba57b (ipv6: fix backtracking for throw routes)
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/ipv6/fib6_rules.c |   22 ++++++----------------
 net/ipv6/ip6_fib.c    |    3 +--
 2 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 11318b7..65a3c62 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -33,7 +33,6 @@ struct fib6_rule
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-	struct rt6_info *rt;
 	struct fib_lookup_arg arg = {
 		.lookup_ptr = lookup,
 		.flags = FIB_LOOKUP_NOREF,
@@ -42,21 +41,11 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 	fib_rules_lookup(net->ipv6.fib6_rules_ops,
 			 flowi6_to_flowi(fl6), flags, &arg);
 
-	rt = arg.result;
+	if (arg.result)
+		return arg.result;
 
-	if (!rt) {
-		dst_hold(&net->ipv6.ip6_null_entry->dst);
-		return &net->ipv6.ip6_null_entry->dst;
-	}
-
-	if (rt->rt6i_flags & RTF_REJECT &&
-	    rt->dst.error == -EAGAIN) {
-		ip6_rt_put(rt);
-		rt = net->ipv6.ip6_null_entry;
-		dst_hold(&rt->dst);
-	}
-
-	return &rt->dst;
+	dst_hold(&net->ipv6.ip6_null_entry->dst);
+	return &net->ipv6.ip6_null_entry->dst;
 }
 
 static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
@@ -117,7 +106,8 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			ipv6_addr_copy(&flp6->saddr, &saddr);
 		}
 		err = rt->dst.error;
-		goto out;
+		if (err != -EAGAIN)
+			goto out;
 	}
 again:
 	ip6_rt_put(rt);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d3cd013..32f91cd 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -249,8 +249,7 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 	table = fib6_get_table(net, RT6_TABLE_MAIN);
 	if (table) {
 		rt = lookup(net, table, fl6, flags);
-		if (rt->rt6i_flags & RTF_REJECT &&
-		    rt->dst.error == -EAGAIN) {
+		if (rt->dst.error == -EAGAIN) {
 			ip6_rt_put(rt);
 			rt = NULL;
 		}
-- 
1.7.10.4
