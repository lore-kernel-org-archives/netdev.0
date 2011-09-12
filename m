From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: [PATCH resend] fib:fix BUG_ON in fib_nl_newrule when add new fib rule
Date: Mon, 12 Sep 2011 09:36:05 +0800
Message-ID: <1315791365-5324-1-git-send-email-wanlong.gao@gmail.com>
References: <1315675150-3012-1-git-send-email-wanlong.gao@gmail.com>
Cc: davem@davemloft.net, Gao feng <omarapazanadi@gmail.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315675150-3012-1-git-send-email-wanlong.gao@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

add new fib rule can cause BUG_ON happen
the reproduce shell is
ip rule add pref 38
ip rule add pref 38
ip rule add to 192.168.3.0/24 goto 38
ip rule del pref 38
ip rule add to 192.168.3.0/24 goto 38
ip rule add pref 38

then the BUG_ON will happen
del BUG_ON and use (ctarget == NULL) identify whether this rule is unresolved

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/fib_rules.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index e7ab0c0..3231b46 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -384,8 +384,8 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 		 */
 		list_for_each_entry(r, &ops->rules_list, list) {
 			if (r->action == FR_ACT_GOTO &&
-			    r->target == rule->pref) {
-				BUG_ON(rtnl_dereference(r->ctarget) != NULL);
+			    r->target == rule->pref &&
+			    rtnl_dereference(r->ctarget) == NULL) {
 				rcu_assign_pointer(r->ctarget, rule);
 				if (--ops->unresolved_rules == 0)
 					break;
-- 
1.7.6
