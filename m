From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/6] bpf: move fixup_bpf_calls() function
Date: Wed, 15 Mar 2017 18:26:39 -0700
Message-ID: <1489627604-2288703-2-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:40405 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750919AbdCPB2e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:28:34 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1J1x1003790
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297e3ngmyf-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:57 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 9db4a09c09e711e7924b0002c9dfb610-bc1fb9a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

no functional change.
move fixup_bpf_calls() to verifier.c
it's being refactored in the next patch

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c  | 56 --------------------------------------------------
 kernel/bpf/verifier.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+), 56 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 7af0dcc5d755..48c914b983bd 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -586,59 +586,6 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl)
 	list_add(&tl->list_node, &bpf_prog_types);
 }
 
-/* fixup insn->imm field of bpf_call instructions:
- * if (insn->imm == BPF_FUNC_map_lookup_elem)
- *      insn->imm = bpf_map_lookup_elem - __bpf_call_base;
- * else if (insn->imm == BPF_FUNC_map_update_elem)
- *      insn->imm = bpf_map_update_elem - __bpf_call_base;
- * else ...
- *
- * this function is called after eBPF program passed verification
- */
-static void fixup_bpf_calls(struct bpf_prog *prog)
-{
-	const struct bpf_func_proto *fn;
-	int i;
-
-	for (i = 0; i < prog->len; i++) {
-		struct bpf_insn *insn = &prog->insnsi[i];
-
-		if (insn->code == (BPF_JMP | BPF_CALL)) {
-			/* we reach here when program has bpf_call instructions
-			 * and it passed bpf_check(), means that
-			 * ops->get_func_proto must have been supplied, check it
-			 */
-			BUG_ON(!prog->aux->ops->get_func_proto);
-
-			if (insn->imm == BPF_FUNC_get_route_realm)
-				prog->dst_needed = 1;
-			if (insn->imm == BPF_FUNC_get_prandom_u32)
-				bpf_user_rnd_init_once();
-			if (insn->imm == BPF_FUNC_xdp_adjust_head)
-				prog->xdp_adjust_head = 1;
-			if (insn->imm == BPF_FUNC_tail_call) {
-				/* mark bpf_tail_call as different opcode
-				 * to avoid conditional branch in
-				 * interpeter for every normal call
-				 * and to prevent accidental JITing by
-				 * JIT compiler that doesn't support
-				 * bpf_tail_call yet
-				 */
-				insn->imm = 0;
-				insn->code |= BPF_X;
-				continue;
-			}
-
-			fn = prog->aux->ops->get_func_proto(insn->imm);
-			/* all functions that have prototype and verifier allowed
-			 * programs to call them, must be real in-kernel functions
-			 */
-			BUG_ON(!fn->func);
-			insn->imm = fn->func - __bpf_call_base;
-		}
-	}
-}
-
 /* drop refcnt on maps used by eBPF program and free auxilary data */
 static void free_used_maps(struct bpf_prog_aux *aux)
 {
@@ -892,9 +839,6 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_used_maps;
 
-	/* fixup BPF_CALL->imm field */
-	fixup_bpf_calls(prog);
-
 	/* eBPF program is ready to be JITed */
 	prog = bpf_prog_select_runtime(prog, &err);
 	if (err < 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 796b68d00119..e41da6c57053 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3233,6 +3233,60 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 	return 0;
 }
 
+/* fixup insn->imm field of bpf_call instructions:
+ * if (insn->imm == BPF_FUNC_map_lookup_elem)
+ *      insn->imm = bpf_map_lookup_elem - __bpf_call_base;
+ * else if (insn->imm == BPF_FUNC_map_update_elem)
+ *      insn->imm = bpf_map_update_elem - __bpf_call_base;
+ * else ...
+ *
+ * this function is called after eBPF program passed verification
+ */
+static void fixup_bpf_calls(struct bpf_prog *prog)
+{
+	const struct bpf_func_proto *fn;
+	int i;
+
+	for (i = 0; i < prog->len; i++) {
+		struct bpf_insn *insn = &prog->insnsi[i];
+
+		if (insn->code == (BPF_JMP | BPF_CALL)) {
+			/* we reach here when program has bpf_call instructions
+			 * and it passed bpf_check(), means that
+			 * ops->get_func_proto must have been supplied, check it
+			 */
+			BUG_ON(!prog->aux->ops->get_func_proto);
+
+			if (insn->imm == BPF_FUNC_get_route_realm)
+				prog->dst_needed = 1;
+			if (insn->imm == BPF_FUNC_get_prandom_u32)
+				bpf_user_rnd_init_once();
+			if (insn->imm == BPF_FUNC_xdp_adjust_head)
+				prog->xdp_adjust_head = 1;
+			if (insn->imm == BPF_FUNC_tail_call) {
+				/* mark bpf_tail_call as different opcode
+				 * to avoid conditional branch in
+				 * interpeter for every normal call
+				 * and to prevent accidental JITing by
+				 * JIT compiler that doesn't support
+				 * bpf_tail_call yet
+				 */
+				insn->imm = 0;
+				insn->code |= BPF_X;
+				continue;
+			}
+
+			fn = prog->aux->ops->get_func_proto(insn->imm);
+			/* all functions that have prototype and verifier allowed
+			 * programs to call them, must be real in-kernel functions
+			 */
+			BUG_ON(!fn->func);
+			insn->imm = fn->func - __bpf_call_base;
+		}
+	}
+}
+
+
 static void free_states(struct bpf_verifier_env *env)
 {
 	struct bpf_verifier_state_list *sl, *sln;
@@ -3328,6 +3382,9 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		/* program is valid, convert *(u32*)(ctx + off) accesses */
 		ret = convert_ctx_accesses(env);
 
+	if (ret == 0)
+		fixup_bpf_calls(env->prog);
+
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
 		/* verifier log exceeded user supplied buffer */
-- 
2.8.0
