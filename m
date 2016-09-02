From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 2/6] net_sched: introduce tcf_hash_replace()
Date: Thu,  1 Sep 2016 22:57:16 -0700
Message-ID: <1472795840-31901-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33876 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751858AbcIBF5s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:48 -0400
Received: by mail-pa0-f65.google.com with SMTP id hm5so615318pac.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:47 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This API is used to replace the old action in hash table
with the new one. It is used by the following patch.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  2 ++
 net/sched/act_api.c   | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 82f3c91..a374bab 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -164,6 +164,8 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		    bool cpustats);
 void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a);
+void tcf_hash_replace(struct tc_action_net *tn, struct tc_action **old,
+		      struct tc_action *new, int bind);
 
 int __tcf_hash_release(struct tc_action *a, bool bind, bool strict);
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 06111aa..db907e5 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -306,6 +306,26 @@ void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
+void tcf_hash_replace(struct tc_action_net *tn, struct tc_action **old,
+		      struct tc_action *new, int bind)
+{
+	struct tcf_hashinfo *hinfo = tn->hinfo;
+	unsigned int h = tcf_hash(new->tcfa_index, hinfo->hmask);
+
+	spin_lock_bh(&hinfo->lock);
+	if (*old)
+		hlist_replace_rcu(&(*old)->tcfa_head, &new->tcfa_head);
+	else
+		hlist_add_head_rcu(&new->tcfa_head, &hinfo->htab[h]);
+	spin_unlock_bh(&hinfo->lock);
+
+	if (*old)
+		tcf_hash_release(*old, bind);
+
+	rcu_assign_pointer(*old, new);
+}
+EXPORT_SYMBOL(tcf_hash_replace);
+
 void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
 			  struct tcf_hashinfo *hinfo)
 {
-- 
2.1.0
