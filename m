From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 01/15] net_sched: remove RCU callbacks in basic filter
Date: Mon, 23 Oct 2017 15:02:50 -0700
Message-ID: <20171023220304.2268-2-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:53294 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJWWDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id t188so18110300pfd.10
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:33 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu(), except
in basic_destroy() we have to use list_splice_init_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_basic.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index d89ebafd2239..11bca8346e0f 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -24,7 +24,6 @@
 struct basic_head {
 	u32			hgenerator;
 	struct list_head	flist;
-	struct rcu_head		rcu;
 };
 
 struct basic_filter {
@@ -34,7 +33,6 @@ struct basic_filter {
 	struct tcf_result	res;
 	struct tcf_proto	*tp;
 	struct list_head	link;
-	struct rcu_head		rcu;
 };
 
 static int basic_classify(struct sk_buff *skb, const struct tcf_proto *tp,
@@ -82,10 +80,8 @@ static int basic_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void basic_delete_filter(struct rcu_head *head)
+static void basic_delete_filter(struct basic_filter *f)
 {
-	struct basic_filter *f = container_of(head, struct basic_filter, rcu);
-
 	tcf_exts_destroy(&f->exts);
 	tcf_em_tree_destroy(&f->ematches);
 	kfree(f);
@@ -95,13 +91,16 @@ static void basic_destroy(struct tcf_proto *tp)
 {
 	struct basic_head *head = rtnl_dereference(tp->root);
 	struct basic_filter *f, *n;
+	LIST_HEAD(local);
+
+	list_splice_init_rcu(&head->flist, &local, synchronize_rcu);
 
-	list_for_each_entry_safe(f, n, &head->flist, link) {
-		list_del_rcu(&f->link);
+	list_for_each_entry_safe(f, n, &local, link) {
+		list_del(&f->link);
 		tcf_unbind_filter(tp, &f->res);
-		call_rcu(&f->rcu, basic_delete_filter);
+		basic_delete_filter(f);
 	}
-	kfree_rcu(head, rcu);
+	kfree(head);
 }
 
 static int basic_delete(struct tcf_proto *tp, void *arg, bool *last)
@@ -111,7 +110,8 @@ static int basic_delete(struct tcf_proto *tp, void *arg, bool *last)
 
 	list_del_rcu(&f->link);
 	tcf_unbind_filter(tp, &f->res);
-	call_rcu(&f->rcu, basic_delete_filter);
+	synchronize_rcu();
+	basic_delete_filter(f);
 	*last = list_empty(&head->flist);
 	return 0;
 }
@@ -205,7 +205,8 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (fold) {
 		list_replace_rcu(&fold->link, &fnew->link);
 		tcf_unbind_filter(tp, &fold->res);
-		call_rcu(&fold->rcu, basic_delete_filter);
+		synchronize_rcu();
+		basic_delete_filter(fold);
 	} else {
 		list_add_rcu(&fnew->link, &head->flist);
 	}
-- 
2.13.0
