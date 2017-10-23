From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 03/15] net_sched: remove RCU callbacks in flower filter
Date: Mon, 23 Oct 2017 15:02:52 -0700
Message-ID: <20171023220304.2268-4-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:55850 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdJWWDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:36 -0400
Received: by mail-pg0-f68.google.com with SMTP id 15so8155126pgc.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:36 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu(), except
in fl_destroy() we have to use list_splice_init_rcu().

As a bonus, this also drops the ugly code in commit
d936377414fa ("net, sched: respect rcu grace period on cls destruction").

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_flower.c | 46 ++++++++++++++--------------------------------
 1 file changed, 14 insertions(+), 32 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index b480d7c792ba..ad33bd00b4f0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -61,7 +61,6 @@ struct fl_flow_mask_range {
 struct fl_flow_mask {
 	struct fl_flow_key key;
 	struct fl_flow_mask_range range;
-	struct rcu_head	rcu;
 };
 
 struct cls_fl_head {
@@ -71,10 +70,6 @@ struct cls_fl_head {
 	bool mask_assigned;
 	struct list_head filters;
 	struct rhashtable_params ht_params;
-	union {
-		struct work_struct work;
-		struct rcu_head	rcu;
-	};
 	struct idr handle_idr;
 };
 
@@ -87,7 +82,6 @@ struct cls_fl_filter {
 	struct list_head list;
 	u32 handle;
 	u32 flags;
-	struct rcu_head	rcu;
 	struct net_device *hw_dev;
 };
 
@@ -215,10 +209,8 @@ static int fl_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void fl_destroy_filter(struct rcu_head *head)
+static void fl_destroy_filter(struct cls_fl_filter *f)
 {
-	struct cls_fl_filter *f = container_of(head, struct cls_fl_filter, rcu);
-
 	tcf_exts_destroy(&f->exts);
 	kfree(f);
 }
@@ -305,38 +297,25 @@ static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 	if (!tc_skip_hw(f->flags))
 		fl_hw_destroy_filter(tp, f);
 	tcf_unbind_filter(tp, &f->res);
-	call_rcu(&f->rcu, fl_destroy_filter);
-}
-
-static void fl_destroy_sleepable(struct work_struct *work)
-{
-	struct cls_fl_head *head = container_of(work, struct cls_fl_head,
-						work);
-	if (head->mask_assigned)
-		rhashtable_destroy(&head->ht);
-	kfree(head);
-	module_put(THIS_MODULE);
-}
-
-static void fl_destroy_rcu(struct rcu_head *rcu)
-{
-	struct cls_fl_head *head = container_of(rcu, struct cls_fl_head, rcu);
-
-	INIT_WORK(&head->work, fl_destroy_sleepable);
-	schedule_work(&head->work);
 }
 
 static void fl_destroy(struct tcf_proto *tp)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *f, *next;
+	LIST_HEAD(local);
+
+	list_splice_init_rcu(&head->filters, &local, synchronize_rcu);
 
-	list_for_each_entry_safe(f, next, &head->filters, list)
+	list_for_each_entry_safe(f, next, &local, list) {
 		__fl_delete(tp, f);
+		fl_destroy_filter(f);
+	}
 	idr_destroy(&head->handle_idr);
 
-	__module_get(THIS_MODULE);
-	call_rcu(&head->rcu, fl_destroy_rcu);
+	if (head->mask_assigned)
+		rhashtable_destroy(&head->ht);
+	kfree(head);
 }
 
 static void *fl_get(struct tcf_proto *tp, u32 handle)
@@ -975,7 +954,8 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
 		list_replace_rcu(&fold->list, &fnew->list);
 		tcf_unbind_filter(tp, &fold->res);
-		call_rcu(&fold->rcu, fl_destroy_filter);
+		synchronize_rcu();
+		fl_destroy_filter(fold);
 	} else {
 		list_add_tail_rcu(&fnew->list, &head->filters);
 	}
@@ -1003,6 +983,8 @@ static int fl_delete(struct tcf_proto *tp, void *arg, bool *last)
 		rhashtable_remove_fast(&head->ht, &f->ht_node,
 				       head->ht_params);
 	__fl_delete(tp, f);
+	synchronize_rcu();
+	fl_destroy_filter(f);
 	*last = list_empty(&head->filters);
 	return 0;
 }
-- 
2.13.0
