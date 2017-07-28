From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/20] net: sched: cls_flow: no need to call tcf_exts_change for newly allocated struct
Date: Fri, 28 Jul 2017 16:40:40 +0200
Message-ID: <20170728144042.6380-19-jiri@resnulli.us>
References: <20170728144042.6380-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34239 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752223AbdG1Olj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:41:39 -0400
Received: by mail-wm0-f68.google.com with SMTP id x64so3366880wmg.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:41:38 -0700 (PDT)
In-Reply-To: <20170728144042.6380-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the fnew struct just was allocated, so no need to use tcf_exts_change
to do atomic change, and we can just fill-up the unused exts struct
directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flow.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index a2441c0..232f30b 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -388,7 +388,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	struct flow_filter *fold, *fnew;
 	struct nlattr *opt = tca[TCA_OPTIONS];
 	struct nlattr *tb[TCA_FLOW_MAX + 1];
-	struct tcf_exts e;
 	unsigned int nkeys = 0;
 	unsigned int perturb_period = 0;
 	u32 baseclass = 0;
@@ -424,27 +423,24 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
-	if (err < 0)
-		goto err1;
-
-	err = -ENOBUFS;
 	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
 	if (!fnew)
-		goto err1;
+		return -ENOBUFS;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_FLOW_EMATCHES], &fnew->ematches);
 	if (err < 0)
-		goto err2;
+		goto err1;
 
 	tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &fnew->exts, ovr);
+	if (err < 0)
+		goto err2;
 
 	fold = (struct flow_filter *)*arg;
 	if (fold) {
 		err = -EINVAL;
 		if (fold->handle != handle && handle)
-			goto err3;
+			goto err2;
 
 		/* Copy fold into fnew */
 		fnew->tp = fold->tp;
@@ -464,31 +460,31 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		if (tb[TCA_FLOW_MODE])
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err3;
+			goto err2;
 
 		if (mode == FLOW_MODE_HASH)
 			perturb_period = fold->perturb_period;
 		if (tb[TCA_FLOW_PERTURB]) {
 			if (mode != FLOW_MODE_HASH)
-				goto err3;
+				goto err2;
 			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
 		}
 	} else {
 		err = -EINVAL;
 		if (!handle)
-			goto err3;
+			goto err2;
 		if (!tb[TCA_FLOW_KEYS])
-			goto err3;
+			goto err2;
 
 		mode = FLOW_MODE_MAP;
 		if (tb[TCA_FLOW_MODE])
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
-			goto err3;
+			goto err2;
 
 		if (tb[TCA_FLOW_PERTURB]) {
 			if (mode != FLOW_MODE_HASH)
-				goto err3;
+				goto err2;
 			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
 		}
 
@@ -506,8 +502,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
 			       (unsigned long)fnew);
 
-	tcf_exts_change(&fnew->exts, &e);
-
 	netif_keep_dst(qdisc_dev(tp->q));
 
 	if (tb[TCA_FLOW_KEYS]) {
@@ -546,13 +540,11 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 		call_rcu(&fold->rcu, flow_destroy_filter);
 	return 0;
 
-err3:
+err2:
 	tcf_exts_destroy(&fnew->exts);
 	tcf_em_tree_destroy(&fnew->ematches);
-err2:
-	kfree(fnew);
 err1:
-	tcf_exts_destroy(&e);
+	kfree(fnew);
 	return err;
 }
 
-- 
2.9.3
