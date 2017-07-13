From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net] net: set fib rule refcount after malloc
Date: Thu, 13 Jul 2017 13:36:40 -0700
Message-ID: <1499978200-12331-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: edumazet@google.com, idosch@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36595 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752870AbdGMUgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 16:36:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so8125149pgy.3
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 13:36:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The configure callback of fib_rules_ops can change the refcnt of a
fib rule. For instance, mlxsw takes a refcnt when adding the processing
of the rule to a work queue. Thus the rule refcnt can not be reset to
to 1 afterwards. Move the refcnt setting to after the allocation.

Fixes: 5361e209dd30 ("net: avoid one splat in fib_nl_delrule()")
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/fib_rules.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index a0093e1b0235..fdcb1bcd2afa 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -400,6 +400,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 		err = -ENOMEM;
 		goto errout;
 	}
+	refcount_set(&rule->refcnt, 1);
 	rule->fr_net = net;
 
 	rule->pref = tb[FRA_PRIORITY] ? nla_get_u32(tb[FRA_PRIORITY])
@@ -517,8 +518,6 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 		last = r;
 	}
 
-	refcount_set(&rule->refcnt, 1);
-
 	if (last)
 		list_add_rcu(&rule->list, &last->list);
 	else
-- 
2.1.4
