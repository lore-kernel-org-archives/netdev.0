From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 17/20] net: sched: cls_flow: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:12 +0200
Message-ID: <20170804122915.15177-18-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32886 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752465AbdHDM3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:48 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so2904572wrd.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:47 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the fnew struct just was allocated, so no need to use tcf_exts_change
to do atomic change, and we can just fill-up the unused exts struct
directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flow.c | 41 ++++++++++++++++-------------------------
 1 file changed, 16 insertions(+), 25 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 71fd1af..55e281b2 100644
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
@@ -424,31 +423,27 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			return -EOPNOTSUPP;
 	}
 
-	err = tcf_exts_init(&e, TCA_FLOW_ACT, TCA_FLOW_POLICE);
-	if (err < 0)
-		goto err1;
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
 
 	err = tcf_exts_init(&fnew->exts, TCA_FLOW_ACT, TCA_FLOW_POLICE);
 	if (err < 0)
-		goto err3;
+		goto err2;
+
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
@@ -468,31 +463,31 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
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
 
@@ -510,8 +505,6 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 	setup_deferrable_timer(&fnew->perturb_timer, flow_perturbation,
 			       (unsigned long)fnew);
 
-	tcf_exts_change(tp, &fnew->exts, &e);
-
 	netif_keep_dst(qdisc_dev(tp->q));
 
 	if (tb[TCA_FLOW_KEYS]) {
@@ -550,13 +543,11 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
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
