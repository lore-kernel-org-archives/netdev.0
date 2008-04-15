From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 7/8 net-2.6.26] [NETNS]: Add netns refcnt debug to fib rules.
Date: Tue, 15 Apr 2008 16:37:54 +0400
Message-ID: <1208263075-28016-7-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7353 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168AbYDOMij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:38:39 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/fib_rules.h |    1 +
 net/core/fib_rules.c    |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 34349f9..a5c6ccc 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -87,6 +87,7 @@ static inline void fib_rule_get(struct fib_rule *rule)
 static inline void fib_rule_put_rcu(struct rcu_head *head)
 {
 	struct fib_rule *rule = container_of(head, struct fib_rule, rcu);
+	release_net(rule->fr_net);
 	kfree(rule);
 }
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 540c072..e3e9ab0 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -29,7 +29,7 @@ int fib_default_rule_add(struct fib_rules_ops *ops,
 	r->pref = pref;
 	r->table = table;
 	r->flags = flags;
-	r->fr_net = ops->fro_net;
+	r->fr_net = hold_net(ops->fro_net);
 
 	/* The lock is not required here, the list in unreacheable
 	 * at the moment this function is called */
@@ -243,7 +243,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		err = -ENOMEM;
 		goto errout;
 	}
-	rule->fr_net = net;
+	rule->fr_net = hold_net(net);
 
 	if (tb[FRA_PRIORITY])
 		rule->pref = nla_get_u32(tb[FRA_PRIORITY]);
@@ -344,6 +344,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	return 0;
 
 errout_free:
+	release_net(rule->fr_net);
 	kfree(rule);
 errout:
 	rules_ops_put(ops);
-- 
1.5.3.rc5

