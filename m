From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25] [IPV4] fib_rules_unregister is essentially void.
Date: Mon, 14 Jan 2008 16:48:21 +0300
Message-ID: <1200318504-18215-2-git-send-email-den@openvz.org>
References: <1200318504-18215-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	den1/0006-ARP-Move-inet_addr_type-call-after-simple-error-ch.patch@sw.ru,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:63218 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751325AbYANNs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 08:48:28 -0500
In-Reply-To: <1200318504-18215-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_rules_unregister is called only after successful register and the return
code is never checked.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/fib_rules.h |    2 +-
 net/core/fib_rules.c    |   21 ++++-----------------
 2 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 88f870f..34349f9 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -104,7 +104,7 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 }
 
 extern int fib_rules_register(struct net *, struct fib_rules_ops *);
-extern int fib_rules_unregister(struct net *, struct fib_rules_ops *);
+extern void fib_rules_unregister(struct net *, struct fib_rules_ops *);
 extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
 
 extern int			fib_rules_lookup(struct fib_rules_ops *,
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 0eecf4c..42ccaf5 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -115,29 +115,16 @@ void fib_rules_cleanup_ops(struct fib_rules_ops *ops)
 }
 EXPORT_SYMBOL_GPL(fib_rules_cleanup_ops);
 
-int fib_rules_unregister(struct net *net, struct fib_rules_ops *ops)
+void fib_rules_unregister(struct net *net, struct fib_rules_ops *ops)
 {
-	int err = 0;
-	struct fib_rules_ops *o;
 
 	spin_lock(&net->rules_mod_lock);
-	list_for_each_entry(o, &net->rules_ops, list) {
-		if (o == ops) {
-			list_del_rcu(&o->list);
-			fib_rules_cleanup_ops(ops);
-			goto out;
-		}
-	}
-
-	err = -ENOENT;
-out:
+	list_del_rcu(&ops->list);
+	fib_rules_cleanup_ops(ops);
 	spin_unlock(&net->rules_mod_lock);
 
 	synchronize_rcu();
-	if (!err)
-		release_net(net);
-
-	return err;
+	release_net(net);
 }
 
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
-- 
1.5.3.rc5

