From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 3/7] bpf: improve verifier state equivalence
Date: Thu, 5 May 2016 19:49:11 -0700
Message-ID: <1462502955-1731797-4-git-send-email-ast@fb.com>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33075 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756364AbcEFCtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 22:49:19 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u462jlHh027669
	for <netdev@vger.kernel.org>; Thu, 5 May 2016 19:49:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22rh7ugj8s-2
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 05 May 2016 19:49:17 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1f9f98e6133511e69fe30002c9dfb610-afee4c50 for <netdev@vger.kernel.org>;	Thu,
 05 May 2016 19:49:16 -0700
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since UNKNOWN_VALUE type is weaker than CONST_IMM we can un-teach
verifier its recognition of constants in conditional branches
without affecting safety.
Ex:
if (reg == 123) {
  .. here verifier was marking reg->type as CONST_IMM
     instead keep reg as UNKNOWN_VALUE
}

Two verifier states with UNKNOWN_VALUE are equivalent, whereas
CONST_IMM_X != CONST_IMM_Y, since CONST_IMM is used for stack range
verification and other cases.
So help search pruning by marking registers as UNKNOWN_VALUE
where possible instead of CONST_IMM.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 23 +++--------------------
 1 file changed, 3 insertions(+), 20 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6338c61fc2a1..84bff68cf80e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1704,12 +1704,11 @@ static int check_cond_jmp_op(struct verifier_env *env,
 			 */
 			regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
 			/* branch targer cannot access it, since reg == 0 */
-			other_branch->regs[insn->dst_reg].type = CONST_IMM;
-			other_branch->regs[insn->dst_reg].imm = 0;
+			mark_reg_unknown_value(other_branch->regs,
+					       insn->dst_reg);
 		} else {
 			other_branch->regs[insn->dst_reg].type = PTR_TO_MAP_VALUE;
-			regs[insn->dst_reg].type = CONST_IMM;
-			regs[insn->dst_reg].imm = 0;
+			mark_reg_unknown_value(regs, insn->dst_reg);
 		}
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
@@ -1718,22 +1717,6 @@ static int check_cond_jmp_op(struct verifier_env *env,
 	} else if (is_pointer_value(env, insn->dst_reg)) {
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
 		return -EACCES;
-	} else if (BPF_SRC(insn->code) == BPF_K &&
-		   (opcode == BPF_JEQ || opcode == BPF_JNE)) {
-
-		if (opcode == BPF_JEQ) {
-			/* detect if (R == imm) goto
-			 * and in the target state recognize that R = imm
-			 */
-			other_branch->regs[insn->dst_reg].type = CONST_IMM;
-			other_branch->regs[insn->dst_reg].imm = insn->imm;
-		} else {
-			/* detect if (R != imm) goto
-			 * and in the fall-through state recognize that R = imm
-			 */
-			regs[insn->dst_reg].type = CONST_IMM;
-			regs[insn->dst_reg].imm = insn->imm;
-		}
 	}
 	if (log_level)
 		print_verifier_state(&env->cur_state);
-- 
2.8.0
