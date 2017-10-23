From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 10/15] net_sched: remove RCU callbacks in fw filter
Date: Mon, 23 Oct 2017 15:02:59 -0700
Message-ID: <20171023220304.2268-11-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:54177 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdJWWDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:44 -0400
Received: by mail-pg0-f68.google.com with SMTP id s2so12832480pge.10
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:44 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Similarly, fw_destroy() is special here, because
it deletes all elements from a hashtable, we definitely
don't want to wait for each element, however we can
unpublish the whole hashtable from upper layer first,
so that after one grace period, the whole hashtable is
safe to remove too.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_fw.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 941245ad07fd..2e7171d3da6d 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -46,7 +46,6 @@ struct fw_filter {
 #endif /* CONFIG_NET_CLS_IND */
 	struct tcf_exts		exts;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
 };
 
 static u32 fw_hash(u32 handle)
@@ -119,10 +118,8 @@ static int fw_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void fw_delete_filter(struct rcu_head *head)
+static void fw_delete_filter(struct fw_filter *f )
 {
-	struct fw_filter *f = container_of(head, struct fw_filter, rcu);
-
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
 }
@@ -136,15 +133,18 @@ static void fw_destroy(struct tcf_proto *tp)
 	if (head == NULL)
 		return;
 
+	RCU_INIT_POINTER(tp->root, NULL);
+	synchronize_rcu();
+
 	for (h = 0; h < HTSIZE; h++) {
 		while ((f = rtnl_dereference(head->ht[h])) != NULL) {
 			RCU_INIT_POINTER(head->ht[h],
 					 rtnl_dereference(f->next));
 			tcf_unbind_filter(tp, &f->res);
-			call_rcu(&f->rcu, fw_delete_filter);
+			fw_delete_filter(f);
 		}
 	}
-	kfree_rcu(head, rcu);
+	kfree(head);
 }
 
 static int fw_delete(struct tcf_proto *tp, void *arg, bool *last)
@@ -166,7 +166,8 @@ static int fw_delete(struct tcf_proto *tp, void *arg, bool *last)
 		if (pfp == f) {
 			RCU_INIT_POINTER(*fp, rtnl_dereference(f->next));
 			tcf_unbind_filter(tp, &f->res);
-			call_rcu(&f->rcu, fw_delete_filter);
+			synchronize_rcu();
+			fw_delete_filter(f);
 			ret = 0;
 			break;
 		}
@@ -286,7 +287,8 @@ static int fw_change(struct net *net, struct sk_buff *in_skb,
 		RCU_INIT_POINTER(fnew->next, rtnl_dereference(pfp->next));
 		rcu_assign_pointer(*fp, fnew);
 		tcf_unbind_filter(tp, &f->res);
-		call_rcu(&f->rcu, fw_delete_filter);
+		synchronize_rcu();
+		fw_delete_filter(f);
 
 		*arg = fnew;
 		return err;
-- 
2.13.0
