From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2] net_sched: use idr to allocate bpf filter handles
Date: Mon, 25 Sep 2017 10:13:49 -0700
Message-ID: <20170925171351.4956-1-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Chris Mi <chrism@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33285 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934861AbdIYROB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 13:14:01 -0400
Received: by mail-pg0-f67.google.com with SMTP id i130so5188638pgc.0
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 10:14:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of calling cls_bpf_get() in a loop to find
a unused handle, just switch to idr API to allocate
new handles.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Chris Mi <chrism@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_bpf.c | 57 ++++++++++++++++++++++++++---------------------------
 1 file changed, 28 insertions(+), 29 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 520c5027646a..e19c3c3c27cc 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/filter.h>
 #include <linux/bpf.h>
+#include <linux/idr.h>
 
 #include <net/rtnetlink.h>
 #include <net/pkt_cls.h>
@@ -32,7 +33,7 @@ MODULE_DESCRIPTION("TC BPF based classifier");
 
 struct cls_bpf_head {
 	struct list_head plist;
-	u32 hgen;
+	struct idr handle_idr;
 	struct rcu_head rcu;
 };
 
@@ -238,6 +239,7 @@ static int cls_bpf_init(struct tcf_proto *tp)
 		return -ENOBUFS;
 
 	INIT_LIST_HEAD_RCU(&head->plist);
+	idr_init(&head->handle_idr);
 	rcu_assign_pointer(tp->root, head);
 
 	return 0;
@@ -264,6 +266,9 @@ static void cls_bpf_delete_prog_rcu(struct rcu_head *rcu)
 
 static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
+	struct cls_bpf_head *head = rtnl_dereference(tp->root);
+
+	idr_remove_ext(&head->handle_idr, prog->handle);
 	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
@@ -287,6 +292,7 @@ static void cls_bpf_destroy(struct tcf_proto *tp)
 	list_for_each_entry_safe(prog, tmp, &head->plist, link)
 		__cls_bpf_delete(tp, prog);
 
+	idr_destroy(&head->handle_idr);
 	kfree_rcu(head, rcu);
 }
 
@@ -421,27 +427,6 @@ static int cls_bpf_set_parms(struct net *net, struct tcf_proto *tp,
 	return 0;
 }
 
-static u32 cls_bpf_grab_new_handle(struct tcf_proto *tp,
-				   struct cls_bpf_head *head)
-{
-	unsigned int i = 0x80000000;
-	u32 handle;
-
-	do {
-		if (++head->hgen == 0x7FFFFFFF)
-			head->hgen = 1;
-	} while (--i > 0 && cls_bpf_get(tp, head->hgen));
-
-	if (unlikely(i == 0)) {
-		pr_err("Insufficient number of handles\n");
-		handle = 0;
-	} else {
-		handle = head->hgen;
-	}
-
-	return handle;
-}
-
 static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 			  struct tcf_proto *tp, unsigned long base,
 			  u32 handle, struct nlattr **tca,
@@ -451,6 +436,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_bpf_prog *oldprog = *arg;
 	struct nlattr *tb[TCA_BPF_MAX + 1];
 	struct cls_bpf_prog *prog;
+	unsigned long idr_index;
 	int ret;
 
 	if (tca[TCA_OPTIONS] == NULL)
@@ -476,21 +462,30 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		}
 	}
 
-	if (handle == 0)
-		prog->handle = cls_bpf_grab_new_handle(tp, head);
-	else
+	if (handle == 0) {
+		ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
+				    1, 0x7FFFFFFF, GFP_KERNEL);
+		if (ret)
+			goto errout;
+		prog->handle = idr_index;
+	} else {
+		if (!oldprog) {
+			ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
+					    handle, handle + 1, GFP_KERNEL);
+			if (ret)
+				goto errout;
+		}
 		prog->handle = handle;
-	if (prog->handle == 0) {
-		ret = -EINVAL;
-		goto errout;
 	}
 
 	ret = cls_bpf_set_parms(net, tp, prog, base, tb, tca[TCA_RATE], ovr);
 	if (ret < 0)
-		goto errout;
+		goto errout_idr;
 
 	ret = cls_bpf_offload(tp, prog, oldprog);
 	if (ret) {
+		if (!oldprog)
+			idr_remove_ext(&head->handle_idr, prog->handle);
 		__cls_bpf_delete_prog(prog);
 		return ret;
 	}
@@ -499,6 +494,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
 
 	if (oldprog) {
+		idr_replace_ext(&head->handle_idr, prog, handle);
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
 		call_rcu(&oldprog->rcu, cls_bpf_delete_prog_rcu);
@@ -509,6 +505,9 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	*arg = prog;
 	return 0;
 
+errout_idr:
+	if (!oldprog)
+		idr_remove_ext(&head->handle_idr, prog->handle);
 errout:
 	tcf_exts_destroy(&prog->exts);
 	kfree(prog);
-- 
2.13.0
