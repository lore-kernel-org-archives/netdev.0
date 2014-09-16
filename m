From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 3/4] net: sched: cls_cgroup fix possible memory
 leak of 'new'
Date: Mon, 15 Sep 2014 23:31:17 -0700
Message-ID: <20140916063115.2905.53827.stgit@nitbit.x32>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:35314 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaIPGbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 02:31:35 -0400
Received: by mail-oa0-f49.google.com with SMTP id m19so3337414oag.22
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 23:31:35 -0700 (PDT)
In-Reply-To: <20140916063024.2905.55403.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   54996b529ab70ca1d6f40677cd2698c4f7127e87
commit: c7953ef23042b7c4fc2be5ecdd216aacff6df5eb [625/646] net: sched: cls_cgroup use RCU

net/sched/cls_cgroup.c:130 cls_cgroup_change() warn: possible memory leak of 'new'
net/sched/cls_cgroup.c:135 cls_cgroup_change() warn: possible memory leak of 'new'
net/sched/cls_cgroup.c:139 cls_cgroup_change() warn: possible memory leak of 'new'

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_cgroup.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3b75487..10c7ffd 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -127,16 +127,18 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	err = nla_parse_nested(tb, TCA_CGROUP_MAX, tca[TCA_OPTIONS],
 			       cgroup_policy);
 	if (err < 0)
-		return err;
+		goto errout;
 
 	tcf_exts_init(&e, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
 	err = tcf_exts_validate(net, tp, tb, tca[TCA_RATE], &e, ovr);
 	if (err < 0)
-		return err;
+		goto errout;
 
 	err = tcf_em_tree_validate(tp, tb[TCA_CGROUP_EMATCHES], &t);
-	if (err < 0)
-		return err;
+	if (err < 0) {
+		tcf_exts_destroy(tp, &e);
+		goto errout;
+	}
 
 	tcf_exts_change(tp, &new->exts, &e);
 	tcf_em_tree_change(tp, &new->ematches, &t);
@@ -145,6 +147,9 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (head)
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	return 0;
+errout:
+	kfree(new);
+	return err;
 }
 
 static void cls_cgroup_destroy(struct tcf_proto *tp)
