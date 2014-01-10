From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 11/12] net: make cls_bpf rcu safe
Date: Fri, 10 Jan 2014 01:43:52 -0800
Message-ID: <20140110094345.7193.1550.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:46914 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbaAJJoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:44:22 -0500
Received: by mail-ob0-f172.google.com with SMTP id gq1so4538027obb.17
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:44:21 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the cls_bpf classifier RCU safe. The tcf_lock
was being used to protect a list of cls_bpf_prog now this list
is RCU safe and updates occur with rcu_replace.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_bpf.c |   79 ++++++++++++++++++++++++++-------------------------
 1 file changed, 40 insertions(+), 39 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 00a5a58..e69adc330 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -25,8 +25,9 @@ MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
 MODULE_DESCRIPTION("TC BPF based classifier");
 
 struct cls_bpf_head {
-	struct list_head plist;
+	struct list_head __rcu plist;
 	u32 hgen;
+	struct rcu_head rcu;
 };
 
 struct cls_bpf_prog {
@@ -37,6 +38,8 @@ struct cls_bpf_prog {
 	struct list_head link;
 	u32 handle;
 	u16 bpf_len;
+	struct tcf_proto *tp;
+	struct rcu_head rcu;
 };
 
 static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
@@ -49,11 +52,11 @@ static const struct nla_policy bpf_policy[TCA_BPF_MAX + 1] = {
 static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			    struct tcf_result *res)
 {
-	struct cls_bpf_head *head = tp->root;
+	struct cls_bpf_head *head = rcu_dereference(tp->root);
 	struct cls_bpf_prog *prog;
 	int ret;
 
-	list_for_each_entry(prog, &head->plist, link) {
+	list_for_each_entry_rcu(prog, &head->plist, link) {
 		int filter_res = SK_RUN_FILTER(prog->filter, skb);
 
 		if (filter_res == 0)
@@ -81,8 +84,8 @@ static int cls_bpf_init(struct tcf_proto *tp)
 	if (head == NULL)
 		return -ENOBUFS;
 
-	INIT_LIST_HEAD(&head->plist);
-	tp->root = head;
+	INIT_LIST_HEAD_RCU(&head->plist);
+	rcu_assign_pointer(tp->root, head);
 
 	return 0;
 }
@@ -98,6 +101,13 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	kfree(prog);
 }
 
+void __cls_bpf_delete_prog(struct rcu_head *rcu)
+{
+	struct cls_bpf_prog *prog = container_of(rcu, struct cls_bpf_prog, rcu);
+
+	cls_bpf_delete_prog(prog->tp, prog);
+}
+
 static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct cls_bpf_head *head = tp->root;
@@ -105,11 +115,8 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 
 	list_for_each_entry(prog, &head->plist, link) {
 		if (prog == todel) {
-			tcf_tree_lock(tp);
-			list_del(&prog->link);
-			tcf_tree_unlock(tp);
-
-			cls_bpf_delete_prog(tp, prog);
+			list_del_rcu(&prog->link);
+			call_rcu(&prog->rcu, __cls_bpf_delete_prog);
 			return 0;
 		}
 	}
@@ -123,11 +130,12 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 	struct cls_bpf_prog *prog, *tmp;
 
 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
-		list_del(&prog->link);
-		cls_bpf_delete_prog(tp, prog);
+		list_del_rcu(&prog->link);
+		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
 	}
 
-	kfree(head);
+	rcu_assign_pointer(tp->root, NULL);
+	kfree_rcu(head, rcu);
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
@@ -158,10 +166,10 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 				   unsigned long base, struct nlattr **tb,
 				   struct nlattr *est)
 {
-	struct sock_filter *bpf_ops, *bpf_old;
+	struct sock_filter *bpf_ops;
 	struct tcf_exts exts;
 	struct sock_fprog tmp;
-	struct sk_filter *fp, *fp_old;
+	struct sk_filter *fp;
 	u16 bpf_size, bpf_len;
 	u32 classid;
 	int ret;
@@ -197,24 +205,13 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	if (ret)
 		goto errout_free;
 
-	tcf_tree_lock(tp);
-	fp_old = prog->filter;
-	bpf_old = prog->bpf_ops;
-
 	prog->bpf_len = bpf_len;
 	prog->bpf_ops = bpf_ops;
 	prog->filter = fp;
 	prog->res.classid = classid;
-	tcf_tree_unlock(tp);
 
 	tcf_bind_filter(tp, &prog->res, base);
 	tcf_exts_change(tp, &prog->exts, &exts);
-
-	if (fp_old)
-		sk_unattached_filter_destroy(fp_old);
-	if (bpf_old)
-		kfree(bpf_old);
-
 	return 0;
 
 errout_free:
@@ -245,8 +242,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 			  unsigned long *arg)
 {
 	struct cls_bpf_head *head = tp->root;
-	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) *arg;
+	struct cls_bpf_prog *oldprog = (struct cls_bpf_prog *) *arg;
 	struct nlattr *tb[TCA_BPF_MAX + 1];
+	struct cls_bpf_prog *prog;
 	int ret;
 
 	if (tca[TCA_OPTIONS] == NULL)
@@ -256,18 +254,19 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (ret < 0)
 		return ret;
 
-	if (prog != NULL) {
-		if (handle && prog->handle != handle)
-			return -EINVAL;
-		return cls_bpf_modify_existing(net, tp, prog, base, tb,
-					       tca[TCA_RATE]);
-	}
-
 	prog = kzalloc(sizeof(*prog), GFP_KERNEL);
 	if (prog == NULL)
 		return -ENOBUFS;
 
 	tcf_exts_init(&prog->exts, TCA_BPF_ACT, TCA_BPF_POLICE);
+
+	if (oldprog) {
+		if (handle && oldprog->handle != handle) {
+			ret = -EINVAL;
+			goto errout;
+		}
+	}
+
 	if (handle == 0)
 		prog->handle = cls_bpf_grab_new_handle(tp, head);
 	else
@@ -281,15 +280,17 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	if (ret < 0)
 		goto errout;
 
-	tcf_tree_lock(tp);
-	list_add(&prog->link, &head->plist);
-	tcf_tree_unlock(tp);
+	if (oldprog) {
+		list_replace_rcu(&prog->link, &oldprog->link);
+		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
+	} else {
+		list_add_rcu(&prog->link, &head->plist);
+	}
 
 	*arg = (unsigned long) prog;
-
 	return 0;
 errout:
-	if (*arg == 0UL && prog)
+	if (prog)
 		kfree(prog);
 
 	return ret;
