From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: [PATCH 1/1] net_cls: fix unconfigured struct tcf_proto keeps
 chaining and avoid kernel panic when we use cls_cgroup
Date: Tue, 2 Jun 2009 18:11:48 +0900
Message-ID: <20090602181148.e01f0417.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, hadi@cyberus.ca
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:41055 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbZFBJQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:16:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid kernel panic when we use cls_cgroup

This patch fixes a bug which unconfigured struct tcf_proto keeps chaining in tc_ctl_tfilter(),
and avoids kernel panic in cls_cgroup_classify() when we use cls_cgroup.

When we execute 'tc filter add', tcf_proto is allocated, initialized by classifier's init(), 
and chained.
After it's chained, tc_ctl_tfilter() calls classifier's change(). 
When classifier's change() fails, tc_ctl_tfilter() does not free and keeps tcf_proto. 

In addition, cls_cgroup is initialized in change() not in init().
It accesses unconfigured struct tcf_proto which is chained before change(), then hits Oops.

Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
Tested-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0759f32..09cdcdf 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -135,6 +135,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 	unsigned long cl;
 	unsigned long fh;
 	int err;
+	int tp_created = 0;
 
 	if (net != &init_net)
 		return -EINVAL;
@@ -266,10 +267,7 @@ replay:
 			goto errout;
 		}
 
-		spin_lock_bh(root_lock);
-		tp->next = *back;
-		*back = tp;
-		spin_unlock_bh(root_lock);
+		tp_created = 1;
 
 	} else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], tp->ops->kind))
 		goto errout;
@@ -296,8 +294,11 @@ replay:
 		switch (n->nlmsg_type) {
 		case RTM_NEWTFILTER:
 			err = -EEXIST;
-			if (n->nlmsg_flags & NLM_F_EXCL)
+			if (n->nlmsg_flags & NLM_F_EXCL) {
+				if (tp_created)
+					tcf_destroy(tp);
 				goto errout;
+			}
 			break;
 		case RTM_DELTFILTER:
 			err = tp->ops->delete(tp, fh);
@@ -314,8 +315,18 @@ replay:
 	}
 
 	err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
-	if (err == 0)
+	if (err == 0) {
+		if (tp_created) {
+			spin_lock_bh(root_lock);
+			tp->next = *back;
+			*back = tp;
+			spin_unlock_bh(root_lock);
+		}
 		tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
+	} else {
+		if (tp_created)
+			tcf_destroy(tp);
+	}
 
 errout:
 	if (cl)


-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
