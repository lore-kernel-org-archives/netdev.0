From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 16/20] net: sched: cls_cgroup: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:11 +0200
Message-ID: <20170804122915.15177-17-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33231 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752545AbdHDM3q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:29:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so5558261wmd.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:29:45 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the new struct just was allocated, so no need to use tcf_exts_change
to do atomic change, and we can just fill-up the unused exts struct
directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_cgroup.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index ce7d38b..df7a582 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -76,7 +76,6 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *tb[TCA_CGROUP_MAX + 1];
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 	struct cls_cgroup_head *new;
-	struct tcf_exts e;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -102,22 +101,13 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (err < 0)
 		goto errout;
 
-	err = tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
+	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &new->exts, ovr);
 	if (err < 0)
 		goto errout;
-	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
-	if (err < 0) {
-		tcf_exts_destroy(&e);
-		goto errout;
-	}
 
 	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &new->ematches);
-	if (err < 0) {
-		tcf_exts_destroy(&e);
+	if (err < 0)
 		goto errout;
-	}
-
-	tcf_exts_change(tp, &new->exts, &e);
 
 	rcu_assign_pointer(tp->root, new);
 	if (head)
-- 
2.9.3
