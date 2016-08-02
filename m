From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: remove the leftover cleanup_a()
Date: Tue,  2 Aug 2016 10:30:45 -0700
Message-ID: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34608 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757223AbcHBSc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 14:32:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so13002979pfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 11:31:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After refactoring tc_action into tcf_common, we no
longer need to cleanup temporary "actions" in list,
they are permanently stored in the hashtable.

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
@@ -754,16 +754,6 @@ static struct tc_action *tcf_action_get_1(struct net *net, struct nlattr *nla,
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
2.1.0
