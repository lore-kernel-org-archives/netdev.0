From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/20] net: sched: use tcf_exts_has_actions in tcf_exts_exec
Date: Fri, 28 Jul 2017 16:40:26 +0200
Message-ID: <20170728144042.6380-5-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33299 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdG1OlJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:09 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so26682002wrd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:08 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use the tcf_exts_has_actions helper instead or directly testing
exts->nr_actions in tcf_exts_exec.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 7f25636..322a282 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -177,29 +177,6 @@ tcf_exts_stats_update(const struct tcf_exts *exts,
 }
 
 /**
- * tcf_exts_exec - execute tc filter extensions
- * @skb: socket buffer
- * @exts: tc filter extensions handle
- * @res: desired result
- *
- * Executes all configured extensions. Returns 0 on a normal execution,
- * a negative number if the filter must be considered unmatched or
- * a positive action code (TC_ACT_*) which must be returned to the
- * underlying layer.
- */
-static inline int
-tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
-	       struct tcf_result *res)
-{
-#ifdef CONFIG_NET_CLS_ACT
-	if (exts->nr_actions)
-		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
-				       res);
-#endif
-	return 0;
-}
-
-/**
  * tcf_exts_has_actions - check if at least one action is present
  * @exts: tc filter extensions handle
  *
@@ -229,6 +206,29 @@ static inline bool tcf_exts_has_one_action(struct tcf_exts *exts)
 #endif
 }
 
+/**
+ * tcf_exts_exec - execute tc filter extensions
+ * @skb: socket buffer
+ * @exts: tc filter extensions handle
+ * @res: desired result
+ *
+ * Executes all configured extensions. Returns 0 on a normal execution,
+ * a negative number if the filter must be considered unmatched or
+ * a positive action code (TC_ACT_*) which must be returned to the
+ * underlying layer.
+ */
+static inline int
+tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
+	      struct tcf_result *res)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (tcf_exts_has_actions(exts))
+		return tcf_action_exec(skb, exts->actions, exts->nr_actions,
+				       res);
+#endif
+	return 0;
+}
+
 int tcf_exts_validate(struct net *net, struct tcf_proto *tp,
 		      struct nlattr **tb, struct nlattr *rate_tlv,
 		      struct tcf_exts *exts, bool ovr);
-- 
2.9.3
