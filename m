From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v3 net 1/1] net sched actions: fix GETing actions
Date: Mon, 12 Sep 2016 19:07:38 -0400
Message-ID: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33071 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcILXHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:07:47 -0400
Received: by mail-oi0-f67.google.com with SMTP id y2so20437915oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:07:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

With the batch changes that translated transient actions into
a temporary list lost in the translation was the fact that
tcf_action_destroy() will eventually delete the action from
the permanent location if the refcount is zero.

Example of what broke:
...add a gact action to drop
sudo $TC actions add action drop index 10
...now retrieve it, looks good
sudo $TC actions get action gact index 10
...retrieve it again and find it is gone!
sudo $TC actions get action gact index 10

Fixes:
commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
commit 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
commit f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d09d068..50720b1 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -592,6 +592,16 @@ err_out:
 	return ERR_PTR(err);
 }
 
+static void cleanup_a(struct list_head *actions, int ovr)
+{
+	struct tc_action *a;
+
+	list_for_each_entry(a, actions, list) {
+		if (ovr)
+			a->tcfa_refcnt -= 1;
+	}
+}
+
 int tcf_action_init(struct net *net, struct nlattr *nla,
 				  struct nlattr *est, char *name, int ovr,
 				  int bind, struct list_head *actions)
@@ -612,8 +622,15 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
 			goto err;
 		}
 		act->order = i;
+		if (ovr)
+			act->tcfa_refcnt += 1;
 		list_add_tail(&act->list, actions);
 	}
+
+	/* Remove the temp refcnt which was necessary to protect against
+	 * destroying an existing action which was being replaced
+	 */
+	cleanup_a(actions, ovr);
 	return 0;
 
 err:
@@ -883,6 +900,8 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 			goto err;
 		}
 		act->order = i;
+		if (event == RTM_GETACTION)
+			act->tcfa_refcnt += 1;
 		list_add_tail(&act->list, &actions);
 	}
 
-- 
1.9.1
