From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 4/6] net_sched: introduce tcf_hash_copy()
Date: Thu,  1 Sep 2016 22:57:18 -0700
Message-ID: <1472795840-31901-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: jhs@mojatatu.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35798 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbcIBF5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 01:57:49 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so5134400pad.2
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 22:57:49 -0700 (PDT)
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  1 +
 net/sched/act_api.c   | 18 ++++++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index a374bab..17837af 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -166,6 +166,7 @@ void tcf_hash_cleanup(struct tc_action *a, struct nlattr *est);
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a);
 void tcf_hash_replace(struct tc_action_net *tn, struct tc_action **old,
 		      struct tc_action *new, int bind);
+bool tcf_hash_copy(struct tc_action *dst, const struct tc_action *src);
 
 int __tcf_hash_release(struct tc_action *a, bool bind, bool strict);
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index d0a7db2..2f8db3c 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -296,6 +296,24 @@ int tcf_hash_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 }
 EXPORT_SYMBOL(tcf_hash_create);
 
+bool tcf_hash_copy(struct tc_action *dst, const struct tc_action *src)
+{
+	if (src) {
+		memcpy(dst, src, sizeof(*src));
+		spin_lock_init(&dst->tcfa_lock);
+		INIT_HLIST_NODE(&dst->tcfa_head);
+		INIT_LIST_HEAD(&dst->list);
+
+		/* tcf_hash_check() is called before this */
+		dst->tcfa_refcnt = src->tcfa_refcnt - 1;
+		if (src->tcfa_bindcnt)
+			dst->tcfa_bindcnt = src->tcfa_bindcnt - 1;
+		return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL(tcf_hash_copy);
+
 void tcf_hash_insert(struct tc_action_net *tn, struct tc_action *a)
 {
 	struct tcf_hashinfo *hinfo = tn->hinfo;
-- 
2.1.0
