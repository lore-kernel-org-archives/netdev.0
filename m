From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: cls_api: make reclassify return all the way back to the original tp
Date: Tue, 23 May 2017 09:11:59 +0200
Message-ID: <20170523071159.1951-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35018 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966019AbdEWHMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 03:12:02 -0400
Received: by mail-wm0-f68.google.com with SMTP id g15so17591313wmc.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 00:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

With the introduction of chain goto action, the reclassification would
cause the re-iteration of the actual chain. It makes more sense to restart
the whole thing and re-iterate starting from the original tp - start
of chain 0.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_api.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 01a8b8b..89fbb35 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -300,7 +300,8 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	__be16 protocol = tc_skb_protocol(skb);
 #ifdef CONFIG_NET_CLS_ACT
 	const int max_reclassify_loop = 4;
-	const struct tcf_proto *old_tp = tp;
+	const struct tcf_proto *orig_tp = tp;
+	const struct tcf_proto *first_tp;
 	int limit = 0;
 
 reclassify:
@@ -315,9 +316,10 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		err = tp->classify(skb, tp, res);
 #ifdef CONFIG_NET_CLS_ACT
 		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode)) {
+			first_tp = orig_tp;
 			goto reset;
 		} else if (unlikely(TC_ACT_EXT_CMP(err, TC_ACT_GOTO_CHAIN))) {
-			old_tp = res->goto_tp;
+			first_tp = res->goto_tp;
 			goto reset;
 		}
 #endif
@@ -335,7 +337,7 @@ int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		return TC_ACT_SHOT;
 	}
 
-	tp = old_tp;
+	tp = first_tp;
 	protocol = tc_skb_protocol(skb);
 	goto reclassify;
 #endif
-- 
2.9.3
