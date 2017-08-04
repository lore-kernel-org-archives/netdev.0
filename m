From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 13/20] net: sched: cls_matchall: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:08 +0200
Message-ID: <20170804122915.15177-14-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35095 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752516AbdHDM3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:41 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so2902888wra.2
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:41 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the head struct was allocated right before mall_set_parms call,
no need to use tcf_exts_change to do atomic change, and we can just
fill-up the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_matchall.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 9dc26c3..f35177b 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -120,27 +120,17 @@ static int mall_set_parms(struct net *net, struct tcf_proto *tp,
 			  unsigned long base, struct nlattr **tb,
 			  struct nlattr *est, bool ovr)
 {
-	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_MATCHALL_ACT, 0);
-	if (err)
-		return err;
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_validate(net, tp, tb, est, &head->exts, ovr);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	if (tb[TCA_MATCHALL_CLASSID]) {
 		head->res.classid = nla_get_u32(tb[TCA_MATCHALL_CLASSID]);
 		tcf_bind_filter(tp, &head->res, base);
 	}
-
-	tcf_exts_change(tp, &head->exts, &e);
-
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static int mall_change(struct net *net, struct sk_buff *in_skb,
-- 
2.9.3
