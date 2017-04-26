From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/6] bpf: bpf_progs stores all loaded programs
Date: Wed, 26 Apr 2017 20:24:16 +0200
Message-ID: <20170426182419.14574-4-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:44331 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933467AbdDZSYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:55 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We later want to give users a quick dump of what is possible with procfs,
so store a list of all currently loaded bpf programs. Later this list
will be printed in procfs.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/filter.h |  4 ++--
 kernel/bpf/core.c      | 51 +++++++++++++++++++++++---------------------------
 kernel/bpf/syscall.c   |  4 ++--
 3 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9a7786db14fa53..63624c619e371b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -753,8 +753,8 @@ bpf_address_lookup(unsigned long addr, unsigned long *size,
 	return ret;
 }
 
-void bpf_prog_kallsyms_add(struct bpf_prog *fp);
-void bpf_prog_kallsyms_del(struct bpf_prog *fp);
+void bpf_prog_link(struct bpf_prog *fp);
+void bpf_prog_unlink(struct bpf_prog *fp);
 
 #else /* CONFIG_BPF_JIT */
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 043f634ff58d87..2139118258cdf8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -365,22 +365,6 @@ static struct latch_tree_root bpf_tree __cacheline_aligned;
 
 int bpf_jit_kallsyms __read_mostly;
 
-static void bpf_prog_ksym_node_add(struct bpf_prog_aux *aux)
-{
-	WARN_ON_ONCE(!list_empty(&aux->bpf_progs_head));
-	list_add_tail_rcu(&aux->bpf_progs_head, &bpf_progs);
-	latch_tree_insert(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
-}
-
-static void bpf_prog_ksym_node_del(struct bpf_prog_aux *aux)
-{
-	if (list_empty(&aux->bpf_progs_head))
-		return;
-
-	latch_tree_erase(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
-	list_del_rcu(&aux->bpf_progs_head);
-}
-
 static bool bpf_prog_kallsyms_candidate(const struct bpf_prog *fp)
 {
 	return fp->jited && !bpf_prog_was_classic(fp);
@@ -392,38 +376,45 @@ static bool bpf_prog_kallsyms_verify_off(const struct bpf_prog *fp)
 	       fp->aux->bpf_progs_head.prev == LIST_POISON2;
 }
 
-void bpf_prog_kallsyms_add(struct bpf_prog *fp)
+void bpf_prog_link(struct bpf_prog *fp)
 {
-	if (!bpf_prog_kallsyms_candidate(fp) ||
-	    !capable(CAP_SYS_ADMIN))
-		return;
+	struct bpf_prog_aux *aux = fp->aux;
 
 	spin_lock_bh(&bpf_lock);
-	bpf_prog_ksym_node_add(fp->aux);
+	list_add_tail_rcu(&aux->bpf_progs_head, &bpf_progs);
+	if (bpf_prog_kallsyms_candidate(fp))
+		latch_tree_insert(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
 	spin_unlock_bh(&bpf_lock);
 }
 
-void bpf_prog_kallsyms_del(struct bpf_prog *fp)
+void bpf_prog_unlink(struct bpf_prog *fp)
 {
-	if (!bpf_prog_kallsyms_candidate(fp))
-		return;
+	struct bpf_prog_aux *aux = fp->aux;
 
 	spin_lock_bh(&bpf_lock);
-	bpf_prog_ksym_node_del(fp->aux);
+	list_del_rcu(&aux->bpf_progs_head);
+	if (bpf_prog_kallsyms_candidate(fp))
+		latch_tree_erase(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
 	spin_unlock_bh(&bpf_lock);
 }
 
 static struct bpf_prog *bpf_prog_kallsyms_find(unsigned long addr)
 {
 	struct latch_tree_node *n;
+	struct bpf_prog *prog;
 
 	if (!bpf_jit_kallsyms_enabled())
 		return NULL;
 
 	n = latch_tree_find((void *)addr, &bpf_tree, &bpf_tree_ops);
-	return n ?
-	       container_of(n, struct bpf_prog_aux, ksym_tnode)->prog :
-	       NULL;
+	if (!n)
+		return NULL;
+
+	prog = container_of(n, struct bpf_prog_aux, ksym_tnode)->prog;
+	if (!prog->priv_cap_sys_admin)
+		return NULL;
+
+	return prog;
 }
 
 const char *__bpf_address_lookup(unsigned long addr, unsigned long *size,
@@ -474,6 +465,10 @@ int bpf_get_kallsym(unsigned int symnum, unsigned long *value, char *type,
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(aux, &bpf_progs, bpf_progs_head) {
+		if (!bpf_prog_kallsyms_candidate(aux->prog) ||
+		    !aux->prog->priv_cap_sys_admin)
+			continue;
+
 		if (it++ != symnum)
 			continue;
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 13642c73dca0b4..d61d1bd3e6fee6 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -664,7 +664,7 @@ void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
 		trace_bpf_prog_put_rcu(prog);
-		bpf_prog_kallsyms_del(prog);
+		bpf_prog_unlink(prog);
 		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
 	}
 }
@@ -858,7 +858,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		/* failed to allocate fd */
 		goto free_used_maps;
 
-	bpf_prog_kallsyms_add(prog);
+	bpf_prog_link(prog);
 	trace_bpf_prog_load(prog, err);
 	return err;
 
-- 
2.9.3
