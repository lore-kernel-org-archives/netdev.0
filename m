From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: add helpers to handle extended actions
Date: Fri, 28 Apr 2017 18:13:26 +0200
Message-ID: <1493396006-11084-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35692 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2999261AbdD1QN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:13:29 -0400
Received: by mail-wr0-f195.google.com with SMTP id g12so7595364wrg.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 09:13:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jump is now the only one using value action opcode. This is going to
change soon. So introduce helpers to work with this. Convert TC_ACT_JUMP.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_cls.h | 15 ++++++++++++++-
 net/sched/act_api.c          |  2 +-
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index f1129e3..d613be3 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -37,7 +37,20 @@ enum {
 #define TC_ACT_QUEUED		5
 #define TC_ACT_REPEAT		6
 #define TC_ACT_REDIRECT		7
-#define TC_ACT_JUMP		0x10000000
+
+/* There is a special kind of actions called "extended actions",
+ * which need a value parameter. These have a local opcode located in
+ * the highest nibble, starting from 1. The rest of the bits
+ * are used to carry the value. These two parts together make
+ * a combined opcode.
+ */
+#define __TC_ACT_EXT_SHIFT 28
+#define __TC_ACT_EXT(local) ((local) << __TC_ACT_EXT_SHIFT)
+#define TC_ACT_EXT_VAL_MASK ((1 << __TC_ACT_EXT_SHIFT) - 1)
+#define TC_ACT_EXT_CMP(combined, opcode) \
+	(((combined) & (~TC_ACT_EXT_VAL_MASK)) == opcode)
+
+#define TC_ACT_JUMP __TC_ACT_EXT(1)
 
 /* Action type identifiers*/
 enum {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 7f2cd70..a90e8f3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -453,7 +453,7 @@ int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		if (ret == TC_ACT_REPEAT)
 			goto repeat;	/* we need a ttl - JHS */
 
-		if (ret & TC_ACT_JUMP) {
+		if (TC_ACT_EXT_CMP(ret, TC_ACT_JUMP)) {
 			jmp_prgcnt = ret & TCA_ACT_MAX_PRIO_MASK;
 			if (!jmp_prgcnt || (jmp_prgcnt > nr_actions)) {
 				/* faulty opcode, stop pipeline */
-- 
2.7.4
