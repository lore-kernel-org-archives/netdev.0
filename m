From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 7/8] ebpf: move read-only fields to bpf_prog and shrink bpf_prog_aux
Date: Sun,  1 Mar 2015 12:31:47 +0100
Message-ID: <2100dda7ab0668cb902c0468fb88074e5529e020.1425208502.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52029 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbbCALcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 06:32:16 -0500
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

is_gpl_compatible and prog_type should be moved directly into bpf_prog
as they stay immutable during bpf_prog's lifetime, are core attributes
and they can be locked as read-only later on via bpf_prog_select_runtime().

With a bit of rearranging, this also allows us to shrink bpf_prog_aux
to exactly 1 cacheline.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h    | 4 +---
 include/linux/filter.h | 4 +++-
 kernel/bpf/syscall.c   | 7 +++----
 kernel/bpf/verifier.c  | 4 ++--
 net/core/filter.c      | 4 ++--
 5 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 9c45814..a1a7ff2 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -117,11 +117,9 @@ struct bpf_prog;
 
 struct bpf_prog_aux {
 	atomic_t refcnt;
-	bool is_gpl_compatible;
-	enum bpf_prog_type prog_type;
+	u32 used_map_cnt;
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
-	u32 used_map_cnt;
 	struct bpf_prog *prog;
 	struct work_struct work;
 };
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 5e3863d..9ee8c67 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -308,9 +308,11 @@ struct bpf_binary_header {
 struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	bool			jited;		/* Is our filter JIT'ed? */
+	bool			gpl_compatible;	/* Is our filter GPL compatible? */
 	u32			len;		/* Number of filter blocks */
-	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+	enum bpf_prog_type	type;		/* Type of BPF program */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
+	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
 	/* Instructions for interpreter */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 536edc2..0d69449 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -354,10 +354,11 @@ static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
 	list_for_each_entry(tl, &bpf_prog_types, list_node) {
 		if (tl->type == type) {
 			prog->aux->ops = tl->ops;
-			prog->aux->prog_type = type;
+			prog->type = type;
 			return 0;
 		}
 	}
+
 	return -EINVAL;
 }
 
@@ -508,7 +509,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	prog->jited = false;
 
 	atomic_set(&prog->aux->refcnt, 1);
-	prog->aux->is_gpl_compatible = is_gpl;
+	prog->gpl_compatible = is_gpl;
 
 	/* find program type: socket_filter vs tracing_filter */
 	err = find_prog_type(type, prog);
@@ -517,7 +518,6 @@ static int bpf_prog_load(union bpf_attr *attr)
 
 	/* run eBPF verifier */
 	err = bpf_check(prog, attr);
-
 	if (err < 0)
 		goto free_used_maps;
 
@@ -528,7 +528,6 @@ static int bpf_prog_load(union bpf_attr *attr)
 	bpf_prog_select_runtime(prog);
 
 	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
-
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_used_maps;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 594d341..bdf4192 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -852,7 +852,7 @@ static int check_call(struct verifier_env *env, int func_id)
 	}
 
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
-	if (!env->prog->aux->is_gpl_compatible && fn->gpl_only) {
+	if (!env->prog->gpl_compatible && fn->gpl_only) {
 		verbose("cannot call GPL only function from proprietary program\n");
 		return -EINVAL;
 	}
@@ -1205,7 +1205,7 @@ static int check_ld_abs(struct verifier_env *env, struct bpf_insn *insn)
 	struct reg_state *reg;
 	int i, err;
 
-	if (!may_access_skb(env->prog->aux->prog_type)) {
+	if (!may_access_skb(env->prog->type)) {
 		verbose("BPF_LD_ABS|IND instructions not allowed for this program type\n");
 		return -EINVAL;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index 514d408..ff000cb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -814,7 +814,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
 
 static void __bpf_prog_release(struct bpf_prog *prog)
 {
-	if (prog->aux->prog_type == BPF_PROG_TYPE_SOCKET_FILTER) {
+	if (prog->type == BPF_PROG_TYPE_SOCKET_FILTER) {
 		bpf_prog_put(prog);
 	} else {
 		bpf_release_orig_filter(prog);
@@ -1105,7 +1105,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	if (prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
+	if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
 		bpf_prog_put(prog);
 		return -EINVAL;
 	}
-- 
1.9.3
