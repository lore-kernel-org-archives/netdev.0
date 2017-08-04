From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 14/20] net: sched: cls_basic: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:09 +0200
Message-ID: <20170804122915.15177-15-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38702 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbdHDM3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:43 -0400
Received: by mail-wr0-f195.google.com with SMTP id g32so2905588wrd.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:42 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the f struct was allocated right before basic_set_parms call, no need
to use tcf_exts_change to do atomic change, and we can just fill-up
the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_basic.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 979cd26..7c7a821 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -129,31 +129,22 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 			   struct nlattr *est, bool ovr)
 {
 	int err;
-	struct tcf_exts e;
 
-	err = tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &f->exts, ovr);
 	if (err < 0)
 		return err;
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
-	if (err < 0)
-		goto errout;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &f->ematches);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	if (tb[TCA_BASIC_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
 	f->tp = tp;
-
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static int basic_change(struct net *net, struct sk_buff *in_skb,
-- 
2.9.3
