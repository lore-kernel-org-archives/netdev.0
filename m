From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH net-next v2] net/sched: cls_matchall: Fix error path
Date: Tue,  3 Jan 2017 19:20:24 +0200
Message-ID: <1483464024-25745-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, eladr@mellanox.com,
        jiri@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55846 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1759925AbdACRSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 12:18:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix several error paths in matchall:
 - Release reference to actions in case the hardware fails offloading
   (relevant to skip_sw only)
 - Fix error path in case tcf_exts initialization/validation fail

Fixes: bf3994d2ed31 ("net/sched: introduce Match-all classifier")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
v1->v2:
 - Add check for tcf_exts_init return code and fix error path for it too
---
 net/sched/cls_matchall.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f935429..fcecf5a 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -141,10 +141,12 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 	struct tcf_exts e;
 	int err;
 
-	tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
+	err = tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
+	if (err)
+		return err;
 	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
 	if (err < 0)
-		return err;
+		goto errout;
 
 	if (tb[TCA_MATCHALL_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
@@ -154,6 +156,9 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 	tcf_exts_change(tp, &f->exts, &e);
 
 	return 0;
+errout:
+	tcf_exts_destroy(&e);
+	return err;
 }
 
 static int mall_change(struct net *net, struct sk_buff *in_skb,
@@ -193,7 +198,9 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 	if (!f)
 		return -ENOBUFS;
 
-	tcf_exts_init(&f->exts, TCA_MATCHALL_ACT, 0);
+	err = tcf_exts_init(&f->exts, TCA_MATCHALL_ACT, 0);
+	if (err)
+		goto err_exts_init;
 
 	if (!handle)
 		handle = 1;
@@ -202,13 +209,13 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 
 	err = mall_set_parms(net, tp, f, base, tb, tca[TCA_RATE], ovr);
 	if (err)
-		goto errout;
+		goto err_set_parms;
 
 	if (tc_should_offload(dev, tp, flags)) {
 		err = mall_replace_hw_filter(tp, f, (unsigned long) f);
 		if (err) {
 			if (tc_skip_sw(flags))
-				goto errout;
+				goto err_replace_hw_filter;
 			else
 				err = 0;
 		}
@@ -219,7 +226,10 @@ static int mall_change(struct net *net, struct sk_buff *in_skb,
 
 	return 0;
 
-errout:
+err_replace_hw_filter:
+err_set_parms:
+	tcf_exts_destroy(&f->exts);
+err_exts_init:
 	kfree(f);
 	return err;
 }
-- 
2.4.11
