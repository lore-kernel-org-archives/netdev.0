From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix memory leaks when rmmod tc action modules
Date: Fri, 19 Feb 2016 16:06:19 -0800
Message-ID: <1455926779-9379-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34616 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948035AbcBTAGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 19:06:35 -0500
Received: by mail-pa0-f48.google.com with SMTP id fy10so58143406pac.1
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 16:06:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only release the memory of the hashtable itself, not its
entries inside. We need to do both.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h |  5 -----
 net/sched/act_api.c   | 32 +++++++++++++++++++++++++++++---
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 9d446f13..8c4e3ff 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -65,11 +65,6 @@ static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
 	return 0;
 }
 
-static inline void tcf_hashinfo_destroy(struct tcf_hashinfo *hf)
-{
-	kfree(hf->htab);
-}
-
 /* Update lastuse only if needed, to avoid dirtying a cache line.
  * We use a temp variable to avoid fetching jiffies twice.
  */
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 06e7c4a..acafaf7 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -69,7 +69,7 @@ int __tcf_hash_release(struct tc_action *a, bool bind, bool strict)
 			if (a->ops->cleanup)
 				a->ops->cleanup(a, bind);
 			tcf_hash_destroy(a);
-			ret = 1;
+			ret = ACT_P_DELETED;
 		}
 	}
 
@@ -302,6 +302,32 @@ void tcf_hash_insert(struct tc_action *a)
 }
 EXPORT_SYMBOL(tcf_hash_insert);
 
+static void tcf_hashinfo_destroy(const struct tc_action_ops *ops)
+{
+	struct tcf_hashinfo *hinfo = ops->hinfo;
+	struct tc_action a = {
+		.ops = ops,
+	};
+	int i;
+
+	for (i = 0; i < hinfo->hmask + 1; i++) {
+		struct tcf_common *p;
+		struct hlist_node *n;
+
+		hlist_for_each_entry_safe(p, n, &hinfo->htab[i], tcfc_head) {
+			int ret;
+
+			a.priv = p;
+			ret = __tcf_hash_release(&a, false, true);
+			if (ret == ACT_P_DELETED)
+				module_put(ops->owner);
+			else if (ret < 0)
+				return;
+		}
+	}
+	kfree(hinfo->htab);
+}
+
 static LIST_HEAD(act_base);
 static DEFINE_RWLOCK(act_mod_lock);
 
@@ -333,7 +359,7 @@ int tcf_register_action(struct tc_action_ops *act, unsigned int mask)
 	list_for_each_entry(a, &act_base, head) {
 		if (act->type == a->type || (strcmp(act->kind, a->kind) == 0)) {
 			write_unlock(&act_mod_lock);
-			tcf_hashinfo_destroy(act->hinfo);
+			tcf_hashinfo_destroy(act);
 			kfree(act->hinfo);
 			return -EEXIST;
 		}
@@ -353,7 +379,7 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	list_for_each_entry(a, &act_base, head) {
 		if (a == act) {
 			list_del(&act->head);
-			tcf_hashinfo_destroy(act->hinfo);
+			tcf_hashinfo_destroy(act);
 			kfree(act->hinfo);
 			err = 0;
 			break;
-- 
2.1.0
