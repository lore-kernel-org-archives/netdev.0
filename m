From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 11/15] net_sched: remove RCU callbacks in route filter
Date: Mon, 23 Oct 2017 15:03:00 -0700
Message-ID: <20171023220304.2268-12-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50903 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdJWWDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id b6so18105008pfh.7
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:45 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu().

Similarly, route4_destroy() is special here, because
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
 net/sched/cls_route.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 9ddde65915d2..b9b77baac1d2 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -38,7 +38,6 @@ struct route4_fastmap {
 struct route4_head {
 	struct route4_fastmap		fastmap[16];
 	struct route4_bucket __rcu	*table[256 + 1];
-	struct rcu_head			rcu;
 };
 
 struct route4_bucket {
@@ -57,7 +56,6 @@ struct route4_filter {
 	u32			handle;
 	struct route4_bucket	*bkt;
 	struct tcf_proto	*tp;
-	struct rcu_head		rcu;
 };
 
 #define ROUTE4_FAILURE ((struct route4_filter *)(-1L))
@@ -254,10 +252,8 @@ static int route4_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void route4_delete_filter(struct rcu_head *head)
+static void route4_delete_filter(struct route4_filter *f)
 {
-	struct route4_filter *f = container_of(head, struct route4_filter, rcu);
-
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
 }
@@ -270,6 +266,9 @@ static void route4_destroy(struct tcf_proto *tp)
 	if (head == NULL)
 		return;
 
+	RCU_INIT_POINTER(tp->root, NULL);
+	synchronize_rcu();
+
 	for (h1 = 0; h1 <= 256; h1++) {
 		struct route4_bucket *b;
 
@@ -284,14 +283,14 @@ static void route4_destroy(struct tcf_proto *tp)
 					next = rtnl_dereference(f->next);
 					RCU_INIT_POINTER(b->ht[h2], next);
 					tcf_unbind_filter(tp, &f->res);
-					call_rcu(&f->rcu, route4_delete_filter);
+					route4_delete_filter(f);
 				}
 			}
 			RCU_INIT_POINTER(head->table[h1], NULL);
-			kfree_rcu(b, rcu);
+			kfree(b);
 		}
 	}
-	kfree_rcu(head, rcu);
+	kfree(head);
 }
 
 static int route4_delete(struct tcf_proto *tp, void *arg, bool *last)
@@ -325,7 +324,8 @@ static int route4_delete(struct tcf_proto *tp, void *arg, bool *last)
 
 			/* Delete it */
 			tcf_unbind_filter(tp, &f->res);
-			call_rcu(&f->rcu, route4_delete_filter);
+			synchronize_rcu();
+			route4_delete_filter(f);
 
 			/* Strip RTNL protected tree */
 			for (i = 0; i <= 32; i++) {
@@ -528,7 +528,8 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
 	*arg = f;
 	if (fold) {
 		tcf_unbind_filter(tp, &fold->res);
-		call_rcu(&fold->rcu, route4_delete_filter);
+		synchronize_rcu();
+		route4_delete_filter(fold);
 	}
 	return 0;
 
-- 
2.13.0
