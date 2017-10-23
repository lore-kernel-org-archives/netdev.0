From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 02/15] net_sched: remove RCU callbacks in bpf filter
Date: Mon, 23 Oct 2017 15:02:51 -0700
Message-ID: <20171023220304.2268-3-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56989 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbdJWWDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:34 -0400
Received: by mail-pg0-f68.google.com with SMTP id m18so12830790pgd.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:34 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu(), except in
cls_bpf_destroy() we have to use list_splice_init_rcu().

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_bpf.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 520c5027646a..11571b6539f2 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -33,7 +33,6 @@ MODULE_DESCRIPTION("TC BPF based classifier");
 struct cls_bpf_head {
 	struct list_head plist;
 	u32 hgen;
-	struct rcu_head rcu;
 };
 
 struct cls_bpf_prog {
@@ -49,7 +48,6 @@ struct cls_bpf_prog {
 	struct sock_filter *bpf_ops;
 	const char *bpf_name;
 	struct tcf_proto *tp;
-	struct rcu_head rcu;
 };
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
@@ -257,17 +255,11 @@ static void __cls_bpf_delete_prog(struct cls_bpf_prog *prog)
 	kfree(prog);
 }
 
-static void cls_bpf_delete_prog_rcu(struct rcu_head *rcu)
-{
-	__cls_bpf_delete_prog(container_of(rcu, struct cls_bpf_prog, rcu));
-}
-
 static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
-	call_rcu(&prog->rcu, cls_bpf_delete_prog_rcu);
 }
 
 static int cls_bpf_delete(struct tcf_proto *tp, void *arg, bool *last)
@@ -275,6 +267,8 @@ static int cls_bpf_delete(struct tcf_proto *tp, void *arg, bool *last)
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 
 	__cls_bpf_delete(tp, arg);
+	synchronize_rcu();
+	__cls_bpf_delete_prog((struct cls_bpf_prog *)arg);
 	*last = list_empty(&head->plist);
 	return 0;
 }
@@ -283,11 +277,16 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog, *tmp;
+	LIST_HEAD(local);
 
-	list_for_each_entry_safe(prog, tmp, &head->plist, link)
+	list_splice_init_rcu(&head->plist, &local, synchronize_rcu);
+
+	list_for_each_entry_safe(prog, tmp, &local, link) {
 		__cls_bpf_delete(tp, prog);
+		__cls_bpf_delete_prog(prog);
+	}
 
-	kfree_rcu(head, rcu);
+	kfree(head);
 }
 
 static void *cls_bpf_get(struct tcf_proto *tp, u32 handle)
@@ -501,7 +500,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
-		call_rcu(&oldprog->rcu, cls_bpf_delete_prog_rcu);
+		synchronize_rcu();
+		__cls_bpf_delete_prog(oldprog);
 	} else {
 		list_add_rcu(&prog->link, &head->plist);
 	}
-- 
2.13.0
