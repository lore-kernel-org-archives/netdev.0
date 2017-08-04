From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 12/20] net: sched: cls_fw: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:07 +0200
Message-ID: <20170804122915.15177-13-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:38843 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbdHDM3k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:40 -0400
Received: by mail-wm0-f66.google.com with SMTP id y206so5510251wmd.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:40 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the f struct was allocated right before fw_set_parms call, no need
to use tcf_exts_change to do atomic change, and we can just fill-up
the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_fw.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 358bf34..11f178f 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -195,16 +195,12 @@ static int fw_set_parms(struct net *net, struct tcf_proto *tp,
 			struct nlattr **tca, unsigned long base, bool ovr)
 {
 	struct fw_head *head = rtnl_dereference(tp->root);
-	struct tcf_exts e;
 	u32 mask;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_FW_ACT, TCA_FW_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &f->exts, ovr);
 	if (err < 0)
 		return err;
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
-	if (err < 0)
-		goto errout;
 
 	if (tb[TCA_FW_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FW_CLASSID]);
@@ -215,10 +211,8 @@ static int fw_set_parms(struct net *net, struct tcf_proto *tp,
 	if (tb[TCA_FW_INDEV]) {
 		int ret;
 		ret = tcf_change_indev(net, tb[TCA_FW_INDEV]);
-		if (ret < 0) {
-			err = ret;
-			goto errout;
-		}
+		if (ret < 0)
+			return ret;
 		f->ifindex = ret;
 	}
 #endif /* CONFIG_NET_CLS_IND */
@@ -227,16 +221,11 @@ static int fw_set_parms(struct net *net, struct tcf_proto *tp,
 	if (tb[TCA_FW_MASK]) {
 		mask = nla_get_u32(tb[TCA_FW_MASK]);
 		if (mask != head->mask)
-			goto errout;
+			return err;
 	} else if (head->mask != 0xFFFFFFFF)
-		goto errout;
-
-	tcf_exts_change(tp, &f->exts, &e);
+		return err;
 
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static int fw_change(struct net *net, struct sk_buff *in_skb,
-- 
2.9.3
