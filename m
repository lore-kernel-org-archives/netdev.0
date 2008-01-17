From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/3 net-2.6.25] Process FIB rule action in the context of the namespace.
Date: Thu, 17 Jan 2008 13:09:18 +0300
Message-ID: <1200564558-7869-3-git-send-email-den@openvz.org>
References: <478F2933.1000007@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org, dlezcano@fr.ibm.com,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:55127 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754548AbYAQKJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 05:09:18 -0500
In-Reply-To: <478F2933.1000007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save namespace context on the fib rule at the rule creation time and call
routing lookup in the correct namespace.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/fib_rules.h |    1 +
 net/core/fib_rules.c    |    2 ++
 net/ipv4/fib_rules.c    |    2 +-
 3 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 7f9f4ae..34349f9 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -22,6 +22,7 @@ struct fib_rule
 	u32			target;
 	struct fib_rule *	ctarget;
 	struct rcu_head		rcu;
+	struct net *		fr_net;
 };
 
 struct fib_lookup_arg
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 3cd4f13..42ccaf5 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -29,6 +29,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->pref = pref;
 	r->table = table;
 	r->flags = flags;
+	r->fr_net = ops->fro_net;
 
 	/* The lock is not required here, the list in unreacheable
 	 * at the moment this function is called */
@@ -242,6 +243,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		err = -ENOMEM;
 		goto errout;
 	}
+	rule->fr_net = net;
 
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 3b7affd..d2001f1 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -91,7 +91,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
 		goto errout;
 	}
 
-	if ((tbl = fib_get_table(&init_net, rule->table)) == NULL)
+	if ((tbl = fib_get_table(rule->fr_net, rule->table)) == NULL)
 		goto errout;
 
 	err = tbl->tb_lookup(tbl, flp, (struct fib_result *) arg->result);
-- 
1.5.3.rc5

