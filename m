From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: reorder pernet ops and act ops registrations
Date: Tue, 11 Oct 2016 10:56:45 -0700
Message-ID: <1476208605-16199-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: kjlx@templeofstupid.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35707 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753068AbcJKR4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 13:56:55 -0400
Received: by mail-pa0-f67.google.com with SMTP id qn10so2017593pac.2
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 10:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krister reported a kernel NULL pointer dereference after
tcf_action_init_1() invokes a_o->init(), it is a race condition
where one thread calling tcf_register_action() to initialize
the netns data after putting act ops in the global list and
the other thread searching the list and then calling
a_o->init(net, ...).

Fix this by moving the pernet ops registration before making
the action ops visible. This is fine because: a) we don't
rely on act_base in pernet ops->init(), b) in the worst case we
have a fully initialized netns but ops is still not ready so
new actions still can't be created.

Reported-by: Krister Johansen <kjlx@templeofstupid.com>
Tested-by: Krister Johansen <kjlx@templeofstupid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/act_api.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index c910217..a512b18 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -341,22 +341,25 @@ int tcf_register_action(struct tc_action_ops *act,
 	if (!act->act || !act->dump || !act->init || !act->walk || !act->lookup)
 		return -EINVAL;
 
+	/* We have to register pernet ops before making the action ops visible,
+	 * otherwise tcf_action_init_1() could get a partially initialized
+	 * netns.
+	 */
+	ret = register_pernet_subsys(ops);
+	if (ret)
+		return ret;
+
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
+			unregister_pernet_subsys(ops);
 			return -EEXIST;
 		}
 	}
 	list_add_tail(&act->head, &act_base);
 	write_unlock(&act_mod_lock);
 
-	ret = register_pernet_subsys(ops);
-	if (ret) {
-		tcf_unregister_action(act, ops);
-		return ret;
-	}
-
 	return 0;
 }
 EXPORT_SYMBOL(tcf_register_action);
@@ -367,8 +370,6 @@ int tcf_unregister_action(struct tc_action_ops *act,
 	struct tc_action_ops *a;
 	int err = -ENOENT;
 
-	unregister_pernet_subsys(ops);
-
 	write_lock(&act_mod_lock);
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
@@ -378,6 +379,8 @@ int tcf_unregister_action(struct tc_action_ops *act,
 		}
 	}
 	write_unlock(&act_mod_lock);
+	if (!err)
+		unregister_pernet_subsys(ops);
 	return err;
 }
 EXPORT_SYMBOL(tcf_unregister_action);
-- 
2.1.0
