From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: [PATCH v2 1/2] fib6_rules: make error handling consistent with IPv4
Date: Tue, 30 Jul 2013 08:52:58 +0200
Message-ID: <20130730065258.GG13357@zirkel.wertarbyte.de>
References: <20130727070758.GA23904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Collins <bsderandrew@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:55830 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565Ab3G3GxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 02:53:00 -0400
Content-Disposition: inline
In-Reply-To: <20130727070758.GA23904@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(by Hannes Frederic Sowa <hannes@stressinduktion.org>)

This compile-only-tested patch would make the error reporting consistent
with its ipv4 counterpart. arg->result should only be NULL iff the
function returns -EAGAIN. So we are clean here.

(It seems this patch also fixes a potential nullptr dereference.)

Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
---
 net/ipv6/fib6_rules.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 2e1a432..4c8bac7 100644
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
 
 
-- 
1.7.10.4
