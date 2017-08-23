From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] net: sched: add couple of goto_chain helpers
Date: Wed, 23 Aug 2017 10:08:19 +0200
Message-ID: <20170823080822.14898-2-jiri@resnulli.us>
References: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32978 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753386AbdHWII0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:08:26 -0400
Received: by mail-wm0-f66.google.com with SMTP id q189so1528096wmd.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:08:26 -0700 (PDT)
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add helpers to find out if a gact instance is goto_chain termination
action and to get chain index.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/tc_act/tc_gact.h | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/net/tc_act/tc_gact.h b/include/net/tc_act/tc_gact.h
index d576374..41afe1c 100644
--- a/include/net/tc_act/tc_gact.h
+++ b/include/net/tc_act/tc_gact.h
@@ -15,7 +15,8 @@ struct tcf_gact {
 };
 #define to_gact(a) ((struct tcf_gact *)a)
 
-static inline bool __is_tcf_gact_act(const struct tc_action *a, int act)
+static inline bool __is_tcf_gact_act(const struct tc_action *a, int act,
+				     bool is_ext)
 {
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_gact *gact;
@@ -24,7 +25,8 @@ static inline bool __is_tcf_gact_act(const struct tc_action *a, int act)
 		return false;
 
 	gact = to_gact(a);
-	if (gact->tcf_action == act)
+	if ((!is_ext && gact->tcf_action == act) ||
+	    (is_ext && TC_ACT_EXT_CMP(gact->tcf_action, act)))
 		return true;
 
 #endif
@@ -33,12 +35,22 @@ static inline bool __is_tcf_gact_act(const struct tc_action *a, int act)
 
 static inline bool is_tcf_gact_shot(const struct tc_action *a)
 {
-	return __is_tcf_gact_act(a, TC_ACT_SHOT);
+	return __is_tcf_gact_act(a, TC_ACT_SHOT, false);
 }
 
 static inline bool is_tcf_gact_trap(const struct tc_action *a)
 {
-	return __is_tcf_gact_act(a, TC_ACT_TRAP);
+	return __is_tcf_gact_act(a, TC_ACT_TRAP, false);
+}
+
+static inline bool is_tcf_gact_goto_chain(const struct tc_action *a)
+{
+	return __is_tcf_gact_act(a, TC_ACT_GOTO_CHAIN, true);
+}
+
+static inline u32 tcf_gact_goto_chain_index(const struct tc_action *a)
+{
+	return a->goto_chain->index;
 }
 
 #endif /* __NET_TC_GACT_H */
-- 
2.9.3
