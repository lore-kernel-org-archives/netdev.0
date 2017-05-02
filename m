From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next repost] net: sched: add helpers to handle extended actions
Date: Tue,  2 May 2017 10:12:00 +0200
Message-ID: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34247 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdEBIMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 04:12:03 -0400
Received: by mail-wm0-f65.google.com with SMTP id z129so2343717wmb.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 01:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Jump is now the only one using value action opcode. This is going to
change soon. So introduce helpers to work with this. Convert TC_ACT_JUMP.

This also fixes the TC_ACT_JUMP check, which is incorrectly done as a
bit check, not a value check.

Fixes: e0ee84ded796 ("net sched actions: Complete the JUMPX opcode")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
Dave, I'm sending this for -net-next although I know it is closed. But
the mentioned commit is not yet in -net. Feel free to take this either
to -net-next or -net, whatever suits you better. Thanks.
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
