From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/6] bpf: rename bpf_kallsyms to bpf_progs, ksym_lnode to bpf_progs_head
Date: Wed, 26 Apr 2017 20:24:15 +0200
Message-ID: <20170426182419.14574-3-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46027 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933327AbdDZSYj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:39 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon put all bpf programs on this list, thus use apropriate names.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/bpf.h |  2 +-
 kernel/bpf/core.c   | 18 +++++++++---------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6bb38d76faf42a..0fbf6a76555cc9 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -172,7 +172,7 @@ struct bpf_prog_aux {
 	u32 used_map_cnt;
 	u32 max_ctx_offset;
 	struct latch_tree_node ksym_tnode;
-	struct list_head ksym_lnode;
+	struct list_head bpf_progs_head;
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 6f81e0f5a0faa2..043f634ff58d87 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -98,7 +98,7 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 	fp->aux = aux;
 	fp->aux->prog = fp;
 
-	INIT_LIST_HEAD_RCU(&fp->aux->ksym_lnode);
+	INIT_LIST_HEAD_RCU(&fp->aux->bpf_progs_head);
 
 	return fp;
 }
@@ -360,25 +360,25 @@ static const struct latch_tree_ops bpf_tree_ops = {
 };
 
 static DEFINE_SPINLOCK(bpf_lock);
-static LIST_HEAD(bpf_kallsyms);
+static LIST_HEAD(bpf_progs);
 static struct latch_tree_root bpf_tree __cacheline_aligned;
 
 int bpf_jit_kallsyms __read_mostly;
 
 static void bpf_prog_ksym_node_add(struct bpf_prog_aux *aux)
 {
-	WARN_ON_ONCE(!list_empty(&aux->ksym_lnode));
-	list_add_tail_rcu(&aux->ksym_lnode, &bpf_kallsyms);
+	WARN_ON_ONCE(!list_empty(&aux->bpf_progs_head));
+	list_add_tail_rcu(&aux->bpf_progs_head, &bpf_progs);
 	latch_tree_insert(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
 }
 
 static void bpf_prog_ksym_node_del(struct bpf_prog_aux *aux)
 {
-	if (list_empty(&aux->ksym_lnode))
+	if (list_empty(&aux->bpf_progs_head))
 		return;
 
 	latch_tree_erase(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
-	list_del_rcu(&aux->ksym_lnode);
+	list_del_rcu(&aux->bpf_progs_head);
 }
 
 static bool bpf_prog_kallsyms_candidate(const struct bpf_prog *fp)
@@ -388,8 +388,8 @@ static bool bpf_prog_kallsyms_candidate(const struct bpf_prog *fp)
 
 static bool bpf_prog_kallsyms_verify_off(const struct bpf_prog *fp)
 {
-	return list_empty(&fp->aux->ksym_lnode) ||
-	       fp->aux->ksym_lnode.prev == LIST_POISON2;
+	return list_empty(&fp->aux->bpf_progs_head) ||
+	       fp->aux->bpf_progs_head.prev == LIST_POISON2;
 }
 
 void bpf_prog_kallsyms_add(struct bpf_prog *fp)
@@ -473,7 +473,7 @@ int bpf_get_kallsym(unsigned int symnum, unsigned long *value, char *type,
 		return ret;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(aux, &bpf_kallsyms, ksym_lnode) {
+	list_for_each_entry_rcu(aux, &bpf_progs, bpf_progs_head) {
 		if (it++ != symnum)
 			continue;
 
-- 
2.9.3
