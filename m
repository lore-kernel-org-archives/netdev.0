From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/6] bpf: refactor fixup_bpf_calls()
Date: Wed, 15 Mar 2017 18:26:40 -0700
Message-ID: <1489627604-2288703-3-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60574 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750865AbdCPB0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:26:50 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1JhxZ007348
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297dn5gu2t-6
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:49 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 9da93d0609e711e7bbc30002c99331b0-74ef99a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reduce indent and make it iterate over instructions similar to
convert_ctx_accesses(). Also convert hard BUG_ON into soft verifier error.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 76 ++++++++++++++++++++++++---------------------------
 1 file changed, 35 insertions(+), 41 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e41da6c57053..5dfa9b8111da 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3233,59 +3233,53 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 	return 0;
 }
 
-/* fixup insn->imm field of bpf_call instructions:
- * if (insn->imm == BPF_FUNC_map_lookup_elem)
- *      insn->imm = bpf_map_lookup_elem - __bpf_call_base;
- * else if (insn->imm == BPF_FUNC_map_update_elem)
- *      insn->imm = bpf_map_update_elem - __bpf_call_base;
- * else ...
+/* fixup insn->imm field of bpf_call instructions
  *
  * this function is called after eBPF program passed verification
  */
-static void fixup_bpf_calls(struct bpf_prog *prog)
+static int fixup_bpf_calls(struct bpf_verifier_env *env)
 {
+	struct bpf_prog *prog = env->prog;
+	struct bpf_insn *insn = prog->insnsi;
 	const struct bpf_func_proto *fn;
+	const int insn_cnt = prog->len;
 	int i;
 
-	for (i = 0; i < prog->len; i++) {
-		struct bpf_insn *insn = &prog->insnsi[i];
+	for (i = 0; i < insn_cnt; i++, insn++) {
+		if (insn->code != (BPF_JMP | BPF_CALL))
+			continue;
 
-		if (insn->code == (BPF_JMP | BPF_CALL)) {
-			/* we reach here when program has bpf_call instructions
-			 * and it passed bpf_check(), means that
-			 * ops->get_func_proto must have been supplied, check it
+		if (insn->imm == BPF_FUNC_get_route_realm)
+			prog->dst_needed = 1;
+		if (insn->imm == BPF_FUNC_get_prandom_u32)
+			bpf_user_rnd_init_once();
+		if (insn->imm == BPF_FUNC_xdp_adjust_head)
+			prog->xdp_adjust_head = 1;
+		if (insn->imm == BPF_FUNC_tail_call) {
+			/* mark bpf_tail_call as different opcode to avoid
+			 * conditional branch in the interpeter for every normal
+			 * call and to prevent accidental JITing by JIT compiler
+			 * that doesn't support bpf_tail_call yet
 			 */
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
+			insn->imm = 0;
+			insn->code |= BPF_X;
+			continue;
+		}
 
-			fn = prog->aux->ops->get_func_proto(insn->imm);
-			/* all functions that have prototype and verifier allowed
-			 * programs to call them, must be real in-kernel functions
-			 */
-			BUG_ON(!fn->func);
-			insn->imm = fn->func - __bpf_call_base;
+		fn = prog->aux->ops->get_func_proto(insn->imm);
+		/* all functions that have prototype and verifier allowed
+		 * programs to call them, must be real in-kernel functions
+		 */
+		if (!fn->func) {
+			verbose("kernel subsystem misconfigured func %s#%d\n",
+				func_id_name(insn->imm), insn->imm);
+			return -EFAULT;
 		}
+		insn->imm = fn->func - __bpf_call_base;
 	}
-}
 
+	return 0;
+}
 
 static void free_states(struct bpf_verifier_env *env)
 {
@@ -3383,7 +3377,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		ret = convert_ctx_accesses(env);
 
 	if (ret == 0)
-		fixup_bpf_calls(env->prog);
+		ret = fixup_bpf_calls(env);
 
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
-- 
2.8.0
