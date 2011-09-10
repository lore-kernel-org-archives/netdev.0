From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH] fib:fix BUG_ON in fib_nl_newrule when add new fib rule
Date: Sun, 11 Sep 2011 01:19:10 +0800
Message-ID: <1315675150-3012-1-git-send-email-wanlong.gao@gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	omarapazanadi@gmail.com, Gao feng <gaofeng@cn.fujitsu.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

add new fib rule can cause BUG_ON
the reproduce shell is

#ip rule add pref 38
#ip rule add pref 38
#ip rule add to 192.168.3.0/24 goto 38
#ip rule del pref 38
#ip rule add to 192.168.3.0/24 goto 38
#ip rule add pref 38

then the BUG_ON will happen
add a var unresolved in struct fib_rule
and use it to identify whether this rule is unresolved

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/fib_rules.h |    1 +
 net/core/fib_rules.c    |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 075f1e3..e4bae01 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -19,6 +19,7 @@ struct fib_rule {
 	u32			flags;
 	u32			table;
 	u8			action;
+	u8			unresolved;
 	u32			target;
 	struct fib_rule __rcu	*ctarget;
 	char			iifname[IFNAMSIZ];
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index e7ab0c0..aa20560 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -384,9 +384,11 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		 */
 		list_for_each_entry(r, &ops->rules_list, list) {
 			if (r->action == FR_ACT_GOTO &&
-			    r->target == rule->pref) {
+			    r->target == rule->pref &&
+			    r->unresolved) {
 				BUG_ON(rtnl_dereference(r->ctarget) != NULL);
 				rcu_assign_pointer(r->ctarget, rule);
+				r->unresolved = 0;
 				if (--ops->unresolved_rules == 0)
 					break;
 			}
@@ -488,6 +490,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 			list_for_each_entry(tmp, &ops->rules_list, list) {
 				if (rtnl_dereference(tmp->ctarget) == rule) {
 					rcu_assign_pointer(tmp->ctarget, NULL);
+					tmp->unresolved = 1;
 					ops->unresolved_rules++;
 				}
 			}
-- 
1.7.6
