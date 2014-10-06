From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 2/3] net: sched: cls_cgroup tear down exts and
 ematch from rcu callback
Date: Sun, 05 Oct 2014 21:28:20 -0700
Message-ID: <20141006042819.6010.32857.stgit@nitbit.x32>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:47621 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbaJFE2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:28:44 -0400
Received: by mail-oi0-f50.google.com with SMTP id i138so3122341oig.9
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 21:28:44 -0700 (PDT)
In-Reply-To: <20141006042335.6010.27000.stgit@nitbit.x32>
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
index 2f77a89..d61a801 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -156,10 +156,8 @@ static void cls_cgroup_destroy(struct tcf_proto *tp)
 	struct cls_cgroup_head *head = rtnl_dereference(tp->root);
 
 	if (head) {
-		tcf_exts_destroy(&head->exts);
-		tcf_em_tree_destroy(&head->ematches);
 		RCU_INIT_POINTER(tp->root, NULL);
-		kfree_rcu(head, rcu);
+		call_rcu(&head->rcu, cls_cgroup_destroy_rcu);
 	}
 }
 
