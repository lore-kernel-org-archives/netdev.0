From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 3/3] net: sched: cls_cgroup fix possible memory
 leak of 'new'
Date: Mon, 15 Sep 2014 19:48:34 -0700
Message-ID: <20140916024831.3010.64477.stgit@nitbit.x32>
References: <20140916024729.3010.47421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:40477 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbaIPCs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 22:48:57 -0400
Received: by mail-oi0-f42.google.com with SMTP id e131so2849799oig.15
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 19:48:56 -0700 (PDT)
In-Reply-To: <20140916024729.3010.47421.stgit@nitbit.x32>
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
 net/sched/cls_cgroup.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 3b75487..52b7900 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -127,16 +127,16 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
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
 	if (err < 0)
-		return err;
+		goto errout;
 
 	tcf_exts_change(tp, &new->exts, &e);
 	tcf_em_tree_change(tp, &new->ematches, &t);
@@ -145,6 +145,9 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
 	if (head)
 		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	return 0;
+errout:
+	kfree(new);
+	return err;
 }
 
 static void cls_cgroup_destroy(struct tcf_proto *tp)
