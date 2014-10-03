From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: sched: cls_cgroup tear down exts and ematch from rcu
 callback
Date: Fri, 03 Oct 2014 09:33:35 -0700
Message-ID: <20141003163333.20118.59609.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:63589 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbaJCQdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 12:33:54 -0400
Received: by mail-ob0-f182.google.com with SMTP id uy5so1124141obc.41
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 09:33:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not RCU safe to destroy the action chain while there
is a possibility of readers accessing it. Move this code
into the rcu callback using the same rcu callback used in the
code patch to make a change to head.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_cgroup.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index d4fef3a..dead710 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -156,10 +156,8 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (head) {
-		tcf_exts_destroy(&head->exts);
-		tcf_em_tree_destroy(head->net, &head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
-		kfree_rcu(head, rcu);
+		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	}
 }
 
