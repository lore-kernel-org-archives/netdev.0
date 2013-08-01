From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: fib6_rules should return exact return value
Date: Thu, 1 Aug 2013 08:48:46 +0200
Message-ID: <20130801064846.GD3688@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stefan.tomanek@wertarbyte.de, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:52804 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3HAGsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 02:48:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the addition of the suppress operation
(7764a45a8f1fe74d4f7d301eaca2e558e7e2831a ("fib_rules: add .suppress
operation") we rely on accurate error reporting of the fib_rules.actions.

fib6_rule_action always returned -EAGAIN in case we could not find a
matching route and 0 if a rule was matched. This also included a match
for blackhole or prohibited rule actions which could get suppressed by
the new logic.

So adapt fib6_rule_action to always return the correct error code as
its counterpart fib4_rule_action does. This also fixes a possiblity of
nullptr-deref, where we don't match the rule, thus rt == NULL. Because
the condition rt != ip6_null_entry still holdes it seems we could later
on dereference rt->dst.

Cc: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/fib6_rules.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index e64e6a5..554a4fb 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -55,26 +55,33 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	struct fib6_table *table;
 	struct net *net = rule->fr_net;
 	pol_lookup_t lookup = arg->lookup_ptr;
+	int err = 0;
 
 	switch (rule->action) {
 	case FR_ACT_TO_TBL:
 		break;
 	case FR_ACT_UNREACHABLE:
+		err = -ENETUNREACH;
 		rt = net->ipv6.ip6_null_entry;
 		goto discard_pkt;
 	default:
 	case FR_ACT_BLACKHOLE:
+		err = -EINVAL;
 		rt = net->ipv6.ip6_blk_hole_entry;
 		goto discard_pkt;
 	case FR_ACT_PROHIBIT:
+		err = -EACCES;
 		rt = net->ipv6.ip6_prohibit_entry;
 		goto discard_pkt;
 	}
 
 	table = fib6_get_table(net, rule->table);
-	if (table)
-		rt = lookup(net, table, flp6, flags);
+	if (!table) {
+		err = -EAGAIN;
+		goto out;
+	}
 
+	rt = lookup(net, table, flp6, flags);
 	if (rt != net->ipv6.ip6_null_entry) {
 		struct fib6_rule *r = (struct fib6_rule *)rule;
 
@@ -101,6 +108,7 @@ static int fib6_rule_action(struct fib_rule *rule, struct flowi *flp,
 	}
 again:
 	ip6_rt_put(rt);
+	err = -EAGAIN;
 	rt = NULL;
 	goto out;
 
@@ -108,7 +116,7 @@ discard_pkt:
 	dst_hold(&rt->dst);
 out:
 	arg->result = rt;
-	return rt == NULL ? -EAGAIN : 0;
+	return err;
 }
 
 static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg)
-- 
1.8.3.1
