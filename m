From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/20] net: sched: cls_flower: no need to call tcf_exts_change for newly allocated struct
Date: Fri, 28 Jul 2017 16:40:34 +0200
Message-ID: <20170728144042.6380-13-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33175 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752147AbdG1OlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id q189so16543790wmd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:20 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the f struct was allocated right before fl_set_parms call, no need
to use tcf_exts_change to do atomic change, and we can just fill-up
the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 4bba357..32cbbb3 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -852,13 +852,11 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 			unsigned long base, struct nlattr **tb,
 			struct nlattr *est, bool ovr)
 {
-	struct tcf_exts e;
 	int err;
 
-	tcf_exts_init(&e, TCA_FLOWER_ACT, 0);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_validate(net, tp, tb, est, &f->exts, ovr);
 	if (err < 0)
-		goto errout;
+		return err;
 
 	if (tb[TCA_FLOWER_CLASSID]) {
 		f->res.classid = nla_get_u32(tb[TCA_FLOWER_CLASSID]);
@@ -867,17 +865,12 @@ static int fl_set_parms(struct net *net, struct tcf_proto *tp,
 
 	err = fl_set_key(net, tb, &f->key, &mask->key);
 	if (err)
-		goto errout;
+		return err;
 
 	fl_mask_update_range(mask);
 	fl_set_masked_key(&f->mkey, &f->key, mask);
 
-	tcf_exts_change(&f->exts, &e);
-
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static u32 fl_grab_new_handle(struct tcf_proto *tp,
-- 
2.9.3
