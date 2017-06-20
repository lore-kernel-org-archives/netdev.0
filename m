From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: ipv6: Do not leak throw route references
Date: Tue, 20 Jun 2017 13:29:25 +0300
Message-ID: <1497954565-6589-1-git-send-email-serhe.popovych@gmail.com>
References: <20170619.142548.1263352241205374623.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34554 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdFTK3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 06:29:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id f134so4462652wme.1
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 03:29:42 -0700 (PDT)
In-Reply-To: <20170619.142548.1263352241205374623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While commit 73ba57bfae4a ("ipv6: fix backtracking for throw routes")
does good job on error propagation to the fib_rules_lookup()
in fib rules core framework that also corrects throw routes
handling, it does not solve route reference leakage problem
happened when we return -EAGAIN to the fib_rules_lookup()
and leave routing table entry referenced in arg->result.

If rule with matched throw route isn't last matched in the
list we overwrite arg->result losing reference on throw
route stored previously forever.

We also partially revert commit ab997ad40839 ("ipv6: fix the
incorrect return value of throw route") since we never return
routing table entry with dst.error == -EAGAIN when
CONFIG_IPV6_MULTIPLE_TABLES is on. Also there is no point
to check for RTF_REJECT flag since it is always set throw
route.

Fixes: 73ba57bfae4a ("ipv6: fix backtracking for throw routes")
Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
v2: Rebased to kernel/git/davem/net.git repository
    Address several scripts/checkpatch.pl issues.
 
 net/ipv6/fib6_rules.c | 22 ++++++----------------
 net/ipv6/ip6_fib.c    |  3 +--
 2 files changed, 7 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index eea23b5..ec849d8 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -32,7 +32,6 @@ struct fib6_rule {
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-	struct rt6_info *rt;
 	struct fib_lookup_arg arg = {
 		.lookup_ptr = lookup,
 		.flags = FIB_LOOKUP_NOREF,
@@ -44,21 +43,11 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
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
@@ -121,7 +110,8 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 			flp6->saddr = saddr;
 		}
 		err = rt->dst.error;
-		goto out;
+		if (err != -EAGAIN)
+			goto out;
 	}
 again:
 	ip6_rt_put(rt);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d4bf2c6..e6b78ba 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -289,8 +289,7 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 	struct rt6_info *rt;
 
 	rt = lookup(net, net->ipv6.fib6_main_tbl, fl6, flags);
-	if (rt->rt6i_flags & RTF_REJECT &&
-	    rt->dst.error == -EAGAIN) {
+	if (rt->dst.error == -EAGAIN) {
 		ip6_rt_put(rt);
 		rt = net->ipv6.ip6_null_entry;
 		dst_hold(&rt->dst);
-- 
1.8.3.1
