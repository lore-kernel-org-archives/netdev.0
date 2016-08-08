From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 4/5] net_sched: move tc offload macros to pkt_cls.h
Date: Mon,  8 Aug 2016 13:46:48 -0700
Message-ID: <1470689209-17682-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Ido Schimmel <idosch@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36310 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbcHHUrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:47:02 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so24544862pab.3
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 13:47:02 -0700 (PDT)
In-Reply-To: <1470689209-17682-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct tcf_exts belongs to filters, should not be visible
to plain tc actions.

Cc: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/act_api.h | 16 ----------------
 include/net/pkt_cls.h | 20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index f53ee9d..3fc88ad 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -189,15 +189,6 @@ int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
 int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
 
-#define tc_no_actions(_exts) \
-	(list_empty(&(_exts)->actions))
-
-#define tc_for_each_action(_a, _exts) \
-	list_for_each_entry(_a, &(_exts)->actions, list)
-
-#define tc_single_action(_exts) \
-	(list_is_singular(&(_exts)->actions))
-
 static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 					   u64 packets, u64 lastuse)
 {
@@ -207,12 +198,5 @@ static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 	a->ops->stats_update(a, bytes, packets, lastuse);
 }
 
-#else /* CONFIG_NET_CLS_ACT */
-
-#define tc_no_actions(_exts) true
-#define tc_for_each_action(_a, _exts) while ((void)(_a), 0)
-#define tc_single_action(_exts) false
-#define tcf_action_stats_update(a, bytes, packets, lastuse)
-
 #endif /* CONFIG_NET_CLS_ACT */
 #endif
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 6f8d653..f15aa1e 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -130,6 +130,26 @@ tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
 	return 0;
 }
 
+#ifdef CONFIG_NET_CLS_ACT
+
+#define tc_no_actions(_exts) \
+	(list_empty(&(_exts)->actions))
+
+#define tc_for_each_action(_a, _exts) \
+	list_for_each_entry(_a, &(_exts)->actions, list)
+
+#define tc_single_action(_exts) \
+	(list_is_singular(&(_exts)->actions))
+
+#else /* CONFIG_NET_CLS_ACT */
+
+#define tc_no_actions(_exts) true
+#define tc_for_each_action(_a, _exts) while ((void)(_a), 0)
+#define tc_single_action(_exts) false
+#define tcf_action_stats_update(a, bytes, packets, lastuse)
+
+#endif /* CONFIG_NET_CLS_ACT */
+
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
-- 
2.1.0
