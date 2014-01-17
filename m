From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/6] net_sched: act: export tcf_hash_search() instead of tcf_hash_lookup()
Date: Fri, 17 Jan 2014 11:37:03 -0800
Message-ID: <1389987427-14085-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:63129 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbaAQThW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:37:22 -0500
Received: by mail-pd0-f177.google.com with SMTP id x10so3078428pdj.36
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 11:37:22 -0800 (PST)
In-Reply-To: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that we will not expose struct tcf_common to modules.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h  | 2 +-
 net/sched/act_api.c    | 6 +++---
 net/sched/act_police.c | 8 ++------
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index ca1dcf5..3b76a30 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -99,7 +99,7 @@ struct tc_action_ops {
 	int     (*walk)(struct sk_buff *, struct netlink_callback *, int, struct tc_action *);
 };
 
-struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo);
+int tcf_hash_search(struct tc_action *a, u32 index);
 void tcf_hash_destroy(struct tcf_common *p, struct tcf_hashinfo *hinfo);
 int tcf_hash_release(struct tcf_common *p, int bind,
 		     struct tcf_hashinfo *hinfo);
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index b948253..72bdc71 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -156,7 +156,7 @@ static int tcf_generic_walker(struct sk_buff *skb, struct netlink_callback *cb,
 	}
 }
 
-struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
+static struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 {
 	struct tcf_common *p = NULL;
 	struct hlist_head *head;
@@ -170,7 +170,6 @@ struct tcf_common *tcf_hash_lookup(u32 index, struct tcf_hashinfo *hinfo)
 
 	return p;
 }
-EXPORT_SYMBOL(tcf_hash_lookup);
 
 u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo)
 {
@@ -186,7 +185,7 @@ u32 tcf_hash_new_index(struct tcf_hashinfo *hinfo)
 }
 EXPORT_SYMBOL(tcf_hash_new_index);
 
-static int tcf_hash_search(struct tc_action *a, u32 index)
+int tcf_hash_search(struct tc_action *a, u32 index)
 {
 	struct tcf_hashinfo *hinfo = a->ops->hinfo;
 	struct tcf_common *p = tcf_hash_lookup(index, hinfo);
@@ -197,6 +196,7 @@ static int tcf_hash_search(struct tc_action *a, u32 index)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(tcf_hash_search);
 
 struct tcf_common *tcf_hash_check(u32 index, struct tc_action *a, int bind)
 {
diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 30d4f4b..e51f7d9 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -140,12 +140,8 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
 	parm = nla_data(tb[TCA_POLICE_TBF]);
 
 	if (parm->index) {
-		struct tcf_common *pc;
-
-		pc = tcf_hash_lookup(parm->index, hinfo);
-		if (pc != NULL) {
-			a->priv = pc;
-			police = to_police(pc);
+		if (tcf_hash_search(a, parm->index)) {
+			police = to_police(a->priv);
 			if (bind) {
 				police->tcf_bindcnt += 1;
 				police->tcf_refcnt += 1;
-- 
1.8.3.1
