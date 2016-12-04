From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf, cls: consolidate prog deletion path
Date: Sun,  4 Dec 2016 23:19:40 +0100
Message-ID: <2d9a3193e4060cc3426744df798e524e492a1575.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40041 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbcLDWTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 17:19:44 -0500
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 18cdb37ebf4c ("net: sched: do not use tcf_proto 'tp' argument from
call_rcu") removed the last usage of tp from cls_bpf_delete_prog(), so also
remove it from the function as argument to not give a wrong impression. tp
is illegal to access from this callback, since it could already have been
freed.

Refactor the deletion code a bit, so that cls_bpf_destroy() can call into
the same code for prog deletion as cls_bpf_delete() op, instead of having
it unnecessarily duplicated.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/sched/cls_bpf.c | 30 +++++++++++++-----------------
 1 file changed, 13 insertions(+), 17 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index c37aa8b..f70e03d 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -241,7 +241,7 @@ static int cls_bpf_init(struct tcf_proto *tp)
 	return 0;
 }
 
-static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
+static void __cls_bpf_delete_prog(struct cls_bpf_prog *prog)
 {
 	tcf_exts_destroy(&prog->exts);
 
@@ -255,22 +255,22 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	kfree(prog);
 }
 
-static void __cls_bpf_delete_prog(struct rcu_head *rcu)
+static void cls_bpf_delete_prog_rcu(struct rcu_head *rcu)
 {
-	struct cls_bpf_prog *prog = container_of(rcu, struct cls_bpf_prog, rcu);
-
-	cls_bpf_delete_prog(prog->tp, prog);
+	__cls_bpf_delete_prog(container_of(rcu, struct cls_bpf_prog, rcu));
 }
 
-static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
+static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
-	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
-
 	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
-	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
+	call_rcu(&prog->rcu, cls_bpf_delete_prog_rcu);
+}
 
+static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	__cls_bpf_delete(tp, (struct cls_bpf_prog *) arg);
 	return 0;
 }
 
@@ -282,12 +282,8 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
 	if (!force && !list_empty(&head->plist))
 		return false;
 
-	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
-		cls_bpf_stop_offload(tp, prog);
-		list_del_rcu(&prog->link);
-		tcf_unbind_filter(tp, &prog->res);
-		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
-	}
+	list_for_each_entry_safe(prog, tmp, &head->plist, link)
+		__cls_bpf_delete(tp, prog);
 
 	kfree_rcu(head, rcu);
 	return true;
@@ -511,14 +507,14 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 
 	ret = cls_bpf_offload(tp, prog, oldprog);
 	if (ret) {
-		cls_bpf_delete_prog(tp, prog);
+		__cls_bpf_delete_prog(prog);
 		return ret;
 	}
 
 	if (oldprog) {
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
-		call_rcu(&oldprog->rcu, __cls_bpf_delete_prog);
+		call_rcu(&oldprog->rcu, cls_bpf_delete_prog_rcu);
 	} else {
 		list_add_rcu(&prog->link, &head->plist);
 	}
-- 
1.9.3
