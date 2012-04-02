From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 41/51] fib_rules: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:31 -0400
Message-ID: <1333335521-1348-42-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab2DBDAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:31 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/fib_rules.c |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index c02e63c..72cceb7 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -542,7 +542,8 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh = nlmsg_data(nlh);
 	frh->family = ops->family;
 	frh->table = rule->table;
-	NLA_PUT_U32(skb, FRA_TABLE, rule->table);
+	if (nla_put_u32(skb, FRA_TABLE, rule->table))
+		goto nla_put_failure;
 	frh->res1 = 0;
 	frh->res2 = 0;
 	frh->action = rule->action;
@@ -553,31 +554,28 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 		frh->flags |= FIB_RULE_UNRESOLVED;
 
 	if (rule->iifname[0]) {
-		NLA_PUT_STRING(skb, FRA_IIFNAME, rule->iifname);
-
+		if (nla_put_string(skb, FRA_IIFNAME, rule->iifname))
+			goto nla_put_failure;
 		if (rule->iifindex == -1)
 			frh->flags |= FIB_RULE_IIF_DETACHED;
 	}
 
 	if (rule->oifname[0]) {
-		NLA_PUT_STRING(skb, FRA_OIFNAME, rule->oifname);
-
+		if (nla_put_string(skb, FRA_OIFNAME, rule->oifname))
+			goto nla_put_failure;
 		if (rule->oifindex == -1)
 			frh->flags |= FIB_RULE_OIF_DETACHED;
 	}
 
-	if (rule->pref)
-		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
-
-	if (rule->mark)
-		NLA_PUT_U32(skb, FRA_FWMARK, rule->mark);
-
-	if (rule->mark_mask || rule->mark)
-		NLA_PUT_U32(skb, FRA_FWMASK, rule->mark_mask);
-
-	if (rule->target)
-		NLA_PUT_U32(skb, FRA_GOTO, rule->target);
-
+	if ((rule->pref &&
+	     nla_put_u32(skb, FRA_PRIORITY, rule->pref)) ||
+	    (rule->mark &&
+	     nla_put_u32(skb, FRA_FWMARK, rule->mark)) ||
+	    ((rule->mark_mask || rule->mark) &&
+	     nla_put_u32(skb, FRA_FWMASK, rule->mark_mask)) ||
+	    (rule->target &&
+	     nla_put_u32(skb, FRA_GOTO, rule->target)))
+		goto nla_put_failure;
 	if (ops->fill(rule, skb, frh) < 0)
 		goto nla_put_failure;
 
-- 
1.7.7.6
