From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 04/16] [NET] fib_rules: Convert fib rule notification to use rtnl_notify()
Date: Mon, 14 Aug 2006 00:00:04 +0200
Message-ID: <20060814214340.099350250@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:15822 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964977AbWHNVog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:36 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_convert_fib_rules
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds support for NLM_F_ECHO to simplify the process of identifying
inserted rules with an auto generated priority.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/fib_rules.c
===================================================================
--- net-2.6.19.git.orig/net/core/fib_rules.c
+++ net-2.6.19.git/net/core/fib_rules.c
@@ -18,7 +18,8 @@ static LIST_HEAD(rules_ops);
 static DEFINE_SPINLOCK(rules_mod_lock);
 
 static void notify_rule_change(int event, struct fib_rule *rule,
-			       struct fib_rules_ops *ops);
+			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
+			       u32 pid);
 
 static struct fib_rules_ops *lookup_rules_ops(int family)
 {
@@ -209,7 +210,7 @@ int fib_nl_newrule(struct sk_buff *skb, 
 	else
 		list_add_rcu(&rule->list, ops->rules_list);
 
-	notify_rule_change(RTM_NEWRULE, rule, ops);
+	notify_rule_change(RTM_NEWRULE, rule, ops, nlh, NETLINK_CB(skb).pid);
 	rules_ops_put(ops);
 	return 0;
 
@@ -266,7 +267,8 @@ int fib_nl_delrule(struct sk_buff *skb, 
 
 		list_del_rcu(&rule->list);
 		synchronize_rcu();
-		notify_rule_change(RTM_DELRULE, rule, ops);
+		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
+				   NETLINK_CB(skb).pid);
 		fib_rule_put(rule);
 		rules_ops_put(ops);
 		return 0;
@@ -344,18 +346,26 @@ skip:
 EXPORT_SYMBOL_GPL(fib_rules_dump);
 
 static void notify_rule_change(int event, struct fib_rule *rule,
-			       struct fib_rules_ops *ops)
+			       struct fib_rules_ops *ops, struct nlmsghdr *nlh,
+			       u32 pid)
 {
-	int size = nlmsg_total_size(sizeof(struct fib_rule_hdr) + 128);
-	struct sk_buff *skb = alloc_skb(size, GFP_KERNEL);
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
 
+	skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (skb == NULL)
-		netlink_set_err(rtnl, 0, ops->nlgroup, ENOBUFS);
-	else if (fib_nl_fill_rule(skb, rule, 0, 0, event, 0, ops) < 0) {
+		goto errout;
+
+	err = fib_nl_fill_rule(skb, rule, pid, nlh->nlmsg_seq, event, 0, ops);
+	if (err < 0) {
 		kfree_skb(skb);
-		netlink_set_err(rtnl, 0, ops->nlgroup, EINVAL);
-	} else
-		netlink_broadcast(rtnl, skb, 0, ops->nlgroup, GFP_KERNEL);
+		goto errout;
+	}
+
+	err = rtnl_notify(skb, pid, ops->nlgroup, nlh, GFP_KERNEL);
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(ops->nlgroup, err);
 }
 
 static void attach_rules(struct list_head *rules, struct net_device *dev)

