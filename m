From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: remove rcu locking from fib_rules_event()
Date: Wed, 10 Mar 2010 07:03:38 +0100
Message-ID: <1268201018.2872.139.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35368 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab0CJGDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 01:03:44 -0500
Received: by bwz1 with SMTP id 1so4632992bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 22:03:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We hold RTNL at this point and dont use RCU variants of list traversals,
we dont need rcu_read_lock()/rcu_read_unlock()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/fib_rules.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a24377..2ff3489 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -108,7 +108,7 @@ fib_rules_register(struct fib_rules_ops *tmpl, struct net *net)
 	struct fib_rules_ops *ops;
 	int err;
 
-	ops = kmemdup(tmpl, sizeof (*ops), GFP_KERNEL);
+	ops = kmemdup(tmpl, sizeof(*ops), GFP_KERNEL);
 	if (ops == NULL)
 		return ERR_PTR(-ENOMEM);
 
@@ -123,7 +123,6 @@ fib_rules_register(struct fib_rules_ops *tmpl, struct net *net)
 
 	return ops;
 }
-
 EXPORT_SYMBOL_GPL(fib_rules_register);
 
 void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
@@ -157,7 +156,6 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 
 	call_rcu(&ops->rcu, fib_rules_put_rcu);
 }
-
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
 
 static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
@@ -220,7 +218,6 @@ out:
 
 	return err;
 }
-
 EXPORT_SYMBOL_GPL(fib_rules_lookup);
 
 static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
@@ -613,7 +610,7 @@ static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
 			break;
 
 		cb->args[1] = 0;
-	skip:
+skip:
 		idx++;
 	}
 	rcu_read_unlock();
@@ -685,7 +682,6 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
 	struct fib_rules_ops *ops;
 
 	ASSERT_RTNL();
-	rcu_read_lock();
 
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -699,8 +695,6 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
 		break;
 	}
 
-	rcu_read_unlock();
-
 	return NOTIFY_DONE;
 }
 


