From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 20/20] net: sched: cls_u32: no need to call tcf_exts_change for newly allocated struct
Date: Fri, 28 Jul 2017 16:40:42 +0200
Message-ID: <20170728144042.6380-21-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33303 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752229AbdG1Olm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:42 -0400
Received: by mail-wm0-f66.google.com with SMTP id q189so16544747wmd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:41 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the n struct was allocated right before u32_set_parms call,
no need to use tcf_exts_change to do atomic change, and we can just
fill-up the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_u32.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 2c834f3..b8b0786 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -723,27 +723,24 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 			 struct tc_u_knode *n, struct nlattr **tb,
 			 struct nlattr *est, bool ovr)
 {
-	struct tcf_exts e;
 	int err;
 
-	tcf_exts_init(&e, TCA_U32_ACT, TCA_U32_POLICE);
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
+	err = tcf_exts_validate(net, tp, tb, est, &n->exts, ovr);
 	if (err < 0)
-		goto errout;
+		return err;
 
-	err = -EINVAL;
 	if (tb[TCA_U32_LINK]) {
 		u32 handle = nla_get_u32(tb[TCA_U32_LINK]);
 		struct tc_u_hnode *ht_down = NULL, *ht_old;
 
 		if (TC_U32_KEY(handle))
-			goto errout;
+			return -EINVAL;
 
 		if (handle) {
 			ht_down = u32_lookup_ht(ht->tp_c, handle);
 
 			if (ht_down == NULL)
-				goto errout;
+				return -EINVAL;
 			ht_down->refcnt++;
 		}
 
@@ -763,16 +760,11 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 		int ret;
 		ret = tcf_change_indev(net, tb[TCA_U32_INDEV]);
 		if (ret < 0)
-			goto errout;
+			return -EINVAL;
 		n->ifindex = ret;
 	}
 #endif
-	tcf_exts_change(&n->exts, &e);
-
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static void u32_replace_knode(struct tcf_proto *tp, struct tc_u_common *tp_c,
-- 
2.9.3
