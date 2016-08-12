From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net v3 1/5] net_sched: remove the leftover cleanup_a()
Date: Thu, 11 Aug 2016 17:41:39 -0700
Message-ID: <1470962503-19682-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:32826 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbcHLAnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 20:43:53 -0400
Received: by mail-pa0-f67.google.com with SMTP id vy10so542332pac.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 17:43:53 -0700 (PDT)
In-Reply-To: <1470962503-19682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After refactoring tc_action into tcf_common, we no
longer need to cleanup temporary "actions" in list,
they are permanently stored in the hashtable.

Fixes: a85a970af265 ("net_sched: move tc_action into tcf_common")
Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index e4a5f26..cce6986 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -754,16 +754,6 @@ err_out:
 	return ERR_PTR(err);
 }
 
-static void cleanup_a(struct list_head *actions)
-{
-	struct tc_action *a, *tmp;
-
-	list_for_each_entry_safe(a, tmp, actions, list) {
-		list_del(&a->list);
-		kfree(a);
-	}
-}
-
 static int tca_action_flush(struct net *net, struct nlattr *nla,
 			    struct nlmsghdr *n, u32 portid)
 {
@@ -905,7 +895,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 		return ret;
 	}
 err:
-	cleanup_a(&actions);
+	tcf_action_destroy(&actions, 0);
 	return ret;
 }
 
@@ -942,15 +932,9 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 
 	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
 	if (ret)
-		goto done;
+		return ret;
 
-	/* dump then free all the actions after update; inserted policy
-	 * stays intact
-	 */
-	ret = tcf_add_notify(net, n, &actions, portid);
-	cleanup_a(&actions);
-done:
-	return ret;
+	return tcf_add_notify(net, n, &actions, portid);
 }
 
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
-- 
1.8.4.5
