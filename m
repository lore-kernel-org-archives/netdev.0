From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net 1/1] net sched actions: fix GETing actions
Date: Thu,  8 Sep 2016 08:12:34 -0400
Message-ID: <1473336754-24930-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34903 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbcIHMMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 08:12:46 -0400
Received: by mail-qt0-f193.google.com with SMTP id 38so1637058qte.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 05:12:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Example of what broke:
...add a gact action to drop
sudo $TC actions add action drop index 10
...now retrieve it, looks good
sudo $TC actions get action gact index 10
...retrieve it again and find it is gone!
sudo $TC actions get action gact index 10

Fixes: f07fed82ad79 ("net_sched: remove the leftover cleanup_a())

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d09d068..d4b4704 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -612,6 +612,8 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
 			goto err;
 		}
 		act->order = i;
+		if (ovr)
+			act->tcfa_refcnt+=1;
 		list_add_tail(&act->list, actions);
 	}
 	return 0;
@@ -856,6 +858,15 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
 	return ret;
 }
 
+static void cleanup_a(struct list_head *actions)
+{
+	struct tc_action *a, *tmp;
+
+	list_for_each_entry_safe(a, tmp, actions, list) {
+		list_del(&a->list);
+	}
+}
+
 static int
 tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	      u32 portid, int event)
@@ -883,6 +894,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 			goto err;
 		}
 		act->order = i;
+		act->tcfa_refcnt+=1;
 		list_add_tail(&act->list, &actions);
 	}
 
@@ -892,10 +904,12 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 		ret = tcf_del_notify(net, n, &actions, portid);
 		if (ret)
 			goto err;
+		cleanup_a(&actions);
 		return ret;
 	}
 err:
 	tcf_action_destroy(&actions, 0);
+	cleanup_a(&actions);
 	return ret;
 }
 
@@ -931,10 +945,10 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
 	LIST_HEAD(actions);
 
 	ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
-	if (ret)
-		return ret;
 
-	return tcf_add_notify(net, n, &actions, portid);
+	ret = tcf_add_notify(net, n, &actions, portid);
+	cleanup_a(&actions);
+	return ret;
 }
 
 static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
-- 
1.9.1
