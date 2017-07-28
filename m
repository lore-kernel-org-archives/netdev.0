From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/20] net: sched: cls_basic: no need to call tcf_exts_change for newly allocated struct
Date: Fri, 28 Jul 2017 16:40:37 +0200
Message-ID: <20170728144042.6380-16-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35038 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752205AbdG1Olf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:35 -0400
Received: by mail-wr0-f195.google.com with SMTP id c24so23179982wra.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:34 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the f struct was allocated right before basic_set_parms call, no need
to use tcf_exts_change to do atomic change, and we can just fill-up
the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_basic.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index dc12d79..0a35cb5 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -129,29 +129,22 @@ static int basic_set_parms(struct net *net, struct tcf_proto *tp,
 			   struct nlattr *est, bool ovr)
 {
 	int err;
-	struct tcf_exts e;
 
-	tcf_exts_init(&e, TCA_BASIC_ACT, TCA_BASIC_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_validate(net, tp, tb, est, &f->exts, ovr);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_BASIC_EMATCHES], &f->ematches);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	if (tb[TCA_BASIC_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_BASIC_CLASSID]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(&f->exts, &e);
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
