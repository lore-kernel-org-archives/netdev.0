From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 11/15] net: sched: rcu'ify cls_bpf
Date: Sun, 24 Aug 2014 17:52:37 -0700
Message-ID: <20140825005236.2180.5698.stgit@nitbit.x32>
References: <20140825004659.2180.35028.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:34789 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbaHYAw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 20:52:57 -0400
Received: by mail-oa0-f42.google.com with SMTP id n16so10358966oag.1
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 17:52:57 -0700 (PDT)
In-Reply-To: <20140825004659.2180.35028.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the cls_bpf classifier RCU safe. The tcf_lock
was being used to protect a list of cls_bpf_prog now this list
is RCU safe and updates occur with rcu_replace.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_bpf.c |   93 ++++++++++++++++++++++++++-------------------------
 1 file changed, 47 insertions(+), 46 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 0e30d58..f2ba58a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -27,6 +27,7 @@ MODULE_DESCRIPTION("TC BPF based classifier");
 struct cls_bpf_head {
 	struct list_head plist;
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
 		int filter_res = BPF_PROG_RUN(prog->filter, skb);
 
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
@@ -98,18 +101,22 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	kfree(prog);
 }
 
+static void __cls_bpf_delete_prog(struct rcu_head *rcu)
+{
+	struct cls_bpf_prog *prog = container_of(rcu, struct cls_bpf_prog, rcu);
+
+	cls_bpf_delete_prog(prog->tp, prog);
+}
+
 static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 {
-	struct cls_bpf_head *head = tp->root;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog, *todel = (struct cls_bpf_prog *) arg;
 
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
@@ -119,27 +126,28 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
 
 static void cls_bpf_destroy(struct tcf_proto *tp)
 {
-	struct cls_bpf_head *head = tp->root;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog, *tmp;
 
 	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
-		list_del(&prog->link);
-		cls_bpf_delete_prog(tp, prog);
+		list_del_rcu(&prog->link);
+		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
 	}
 
-	kfree(head);
+	RCU_INIT_POINTER(tp->root, NULL);
+	kfree_rcu(head, rcu);
 }
 
 static unsigned long cls_bpf_get(struct tcf_proto *tp, u32 handle)
 {
-	struct cls_bpf_head *head = tp->root;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog;
 	unsigned long ret = 0UL;
 
 	if (head == NULL)
 		return 0UL;
 
-	list_for_each_entry(prog, &head->plist, link) {
+	list_for_each_entry_rcu(prog, &head->plist, link) {
 		if (prog->handle == handle) {
 			ret = (unsigned long) prog;
 			break;
@@ -158,10 +166,10 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 				   unsigned long base, struct nlattr **tb,
 				   struct nlattr *est, bool ovr)
 {
-	struct sock_filter *bpf_ops, *bpf_old;
+	struct sock_filter *bpf_ops;
 	struct tcf_exts exts;
 	struct sock_fprog_kern tmp;
-	struct bpf_prog *fp, *fp_old;
+	struct bpf_prog *fp;
 	u16 bpf_size, bpf_len;
 	u32 classid;
 	int ret;
@@ -197,26 +205,15 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
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
 
-	if (fp_old)
-		bpf_prog_destroy(fp_old);
-	if (bpf_old)
-		kfree(bpf_old);
-
 	return 0;
-
 errout_free:
 	kfree(bpf_ops);
 errout:
@@ -244,9 +241,10 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 			  u32 handle, struct nlattr **tca,
 			  unsigned long *arg, bool ovr)
 {
-	struct cls_bpf_head *head = tp->root;
-	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) *arg;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
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
-					       tca[TCA_RATE], ovr);
-	}
-
 	prog = kzalloc(sizeof(*prog), GFP_KERNEL);
-	if (prog == NULL)
+	if (!prog)
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
@@ -339,10 +340,10 @@ nla_put_failure:
 
 static void cls_bpf_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 {
-	struct cls_bpf_head *head = tp->root;
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 	struct cls_bpf_prog *prog;
 
-	list_for_each_entry(prog, &head->plist, link) {
+	list_for_each_entry_rcu(prog, &head->plist, link) {
 		if (arg->count < arg->skip)
 			goto skip;
 		if (arg->fn(tp, (unsigned long) prog, arg) < 0) {
