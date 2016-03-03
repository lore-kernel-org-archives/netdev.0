From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V1 03/10] net/sched: Macro instead of CONFIG_NET_CLS_ACT ifdef
Date: Thu,  3 Mar 2016 11:23:19 +0200
Message-ID: <1456997006-18538-4-git-send-email-amir@vadai.me>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33232 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757099AbcCCJTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:19:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id n186so3047575wmn.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:19:41 -0800 (PST)
In-Reply-To: <1456997006-18538-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the macros tc_no_actions and tc_for_each_action to make code
clearer.

CC: John Fastabend <john.r.fastabend@intel.com>
Suggested-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
---
John hi,

I wanted to change ixgbe code to use this, but it is not a trivial change
there, so would prefer you do it.

 include/net/act_api.h        | 21 ++++++++++++++++-----
 include/net/tc_act/tc_gact.h |  4 ++--
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 342be6c..e30856f 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -78,11 +78,6 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
 		tm->lastuse = now;
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-
-#define ACT_P_CREATED 1
-#define ACT_P_DELETED 1
-
 struct tc_action {
 	void			*priv;
 	const struct tc_action_ops	*ops;
@@ -92,6 +87,11 @@ struct tc_action {
 	struct tcf_hashinfo	*hinfo;
 };
 
+#ifdef CONFIG_NET_CLS_ACT
+
+#define ACT_P_CREATED 1
+#define ACT_P_DELETED 1
+
 struct tc_action_ops {
 	struct list_head head;
 	char    kind[IFNAMSIZ];
@@ -171,5 +171,16 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *, int, int);
 int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
+
+#define tc_no_actions(_exts) \
+	(list_empty(&(_exts)->actions))
+
+#define tc_for_each_action(_a, _exts) \
+	list_for_each_entry(a, &(_exts)->actions, list)
+#else /* CONFIG_NET_CLS_ACT */
+
+#define tc_no_actions(_exts) false
+#define tc_for_each_action(_a, _exts) while (0)
+
 #endif /* CONFIG_NET_CLS_ACT */
 #endif
diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index 04a3183..93c520b 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -16,9 +16,9 @@ struct tcf_gact {
 #define to_gact(a) \
 	container_of(a->priv, struct tcf_gact, common)
 
-#ifdef CONFIG_NET_CLS_ACT
 static inline bool is_tcf_gact_shot(const struct tc_action *a)
 {
+#ifdef CONFIG_NET_CLS_ACT
 	struct tcf_gact *gact;
 
 	if (a->ops && a->ops->type != TCA_ACT_GACT)
@@ -28,7 +28,7 @@ static inline bool is_tcf_gact_shot(const struct tc_action *a)
 	if (gact->tcf_action == TC_ACT_SHOT)
 		return true;
 
+#endif
 	return false;
 }
-#endif
 #endif /* __NET_TC_GACT_H */
-- 
2.7.0
