From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_matchall: Fix error path
Date: Tue,  3 Jan 2017 17:47:02 +0200
Message-ID: <1483458422-13607-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, eladr@mellanox.com,
        jiri@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40802 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752763AbdACPpl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 10:45:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix several error paths in matchall:
 - Release reference to actions in case the hardware fails offloading
   (relevant to skip_sw only)
 - Fix error path in case tcf_exts initialization fails

Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 net/sched/cls_matchall.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f935429..ce7d28b 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -144,7 +144,7 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 	tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
-		return err;
+		goto errout;
 
 	if (tb[TCA_MATCHALL_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
@@ -154,6 +154,9 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 	tcf_exts_change(tp, &f->exts, &e);
 
 	return 0;
+errout:
+	tcf_exts_destroy(&e);
+	return err;
 }
 
 static int mall_change(struct net *net, struct sk_buff *in_skb,
@@ -220,6 +223,7 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	return 0;
 
 errout:
+	tcf_exts_destroy(&f->exts);
 	kfree(f);
 	return err;
 }
-- 
2.4.11
