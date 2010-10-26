From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] fib_rules: __rcu annotates ctarget
Date: Tue, 26 Oct 2010 21:24:55 +0200
Message-ID: <1288121095.2652.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40615 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab0JZTY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:24:59 -0400
Received: by wyf28 with SMTP id 28so5003022wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 12:24:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds __rcu annotation to (struct fib_rule)->ctarget

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/fib_rules.h |    2 +-
 net/core/fib_rules.c    |   11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 106f309..075f1e3 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -20,7 +20,7 @@ struct fib_rule {
 	u32			table;
 	u8			action;
 	u32			target;
-	struct fib_rule *	ctarget;
+	struct fib_rule __rcu	*ctarget;
 	char			iifname[IFNAMSIZ];
 	char			oifname[IFNAMSIZ];
 	struct rcu_head		rcu;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 12b43cc..82a4369 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -351,12 +351,12 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 
 		list_for_each_entry(r, &ops->rules_list, list) {
 			if (r->pref == rule->target) {
-				rule->ctarget = r;
+				RCU_INIT_POINTER(rule->ctarget, r);
 				break;
 			}
 		}
 
-		if (rule->ctarget == NULL)
+		if (rcu_dereference_protected(rule->ctarget, 1) == NULL)
 			unresolved = 1;
 	} else if (rule->action == FR_ACT_GOTO)
 		goto errout_free;
@@ -386,7 +386,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		list_for_each_entry(r, &ops->rules_list, list) {
 			if (r->action == FR_ACT_GOTO &&
 			    r->target == rule->pref) {
-				BUG_ON(r->ctarget != NULL);
+				BUG_ON(rtnl_dereference(r->ctarget) != NULL);
 				rcu_assign_pointer(r->ctarget, rule);
 				if (--ops->unresolved_rules == 0)
 					break;
@@ -487,7 +487,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		 */
 		if (ops->nr_goto_rules > 0) {
 			list_for_each_entry(tmp, &ops->rules_list, list) {
-				if (tmp->ctarget == rule) {
+				if (rtnl_dereference(tmp->ctarget) == rule) {
 					rcu_assign_pointer(tmp->ctarget, NULL);
 					ops->unresolved_rules++;
 				}
@@ -545,7 +545,8 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	frh->action = rule->action;
 	frh->flags = rule->flags;
 
-	if (rule->action == FR_ACT_GOTO && rule->ctarget == NULL)
+	if (rule->action == FR_ACT_GOTO &&
+	    rcu_dereference_raw(rule->ctarget) == NULL)
 		frh->flags |= FIB_RULE_UNRESOLVED;
 
 	if (rule->iifname[0]) {


