From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: enhance verifier to understand stack pointer arithmetic
Date: Sat, 29 Apr 2017 22:52:42 -0700
Message-ID: <20170430055242.2536070-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60432 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1427167AbdD3Fwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 01:52:46 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3U5ZQnm029702
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 22:52:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a4rh8t5tu-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 22:52:45 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 3a25d6c22d6911e7aedd0002c9521c9e-331c46e0 for <netdev@vger.kernel.org>;        Sat,
 29 Apr 2017 22:52:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>

llvm 4.0 and above generates the code like below:
....
440: (b7) r1 = 15
441: (05) goto pc+73
515: (79) r6 = *(u64 *)(r10 -152)
516: (bf) r7 = r10
517: (07) r7 += -112
518: (bf) r2 = r7
519: (0f) r2 += r1
520: (71) r1 = *(u8 *)(r8 +0)
521: (73) *(u8 *)(r2 +45) = r1
....
and the verifier complains "R2 invalid mem access 'inv'" for insn #521.
This is because verifier marks register r2 as unknown value after #519
where r2 is a stack pointer and r1 holds a constant value.

Teach verifier to recognize "stack_ptr + imm" and
"stack_ptr + reg with const val" as valid stack_ptr with new offset.

Signed-off-by: Yonghong Song <yhs@fb.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
technically it's 'net' material, but it's too late for 'net',
hence 'net-next' tag.
No 'Fixes' tag, since it's only seen with newer llvm.
---
 kernel/bpf/verifier.c                       | 11 +++++++++++
 tools/testing/selftests/bpf/test_verifier.c | 18 ++++++++++++------
 2 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6f8b6ed690be..c2ff608c1984 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1924,6 +1924,17 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			return 0;
 		} else if (opcode == BPF_ADD &&
 			   BPF_CLASS(insn->code) == BPF_ALU64 &&
+			   dst_reg->type == PTR_TO_STACK &&
+			   ((BPF_SRC(insn->code) == BPF_X &&
+			     regs[insn->src_reg].type == CONST_IMM) ||
+			    BPF_SRC(insn->code) == BPF_K)) {
+			if (BPF_SRC(insn->code) == BPF_X)
+				dst_reg->imm += regs[insn->src_reg].imm;
+			else
+				dst_reg->imm += insn->imm;
+			return 0;
+		} else if (opcode == BPF_ADD &&
+			   BPF_CLASS(insn->code) == BPF_ALU64 &&
 			   (dst_reg->type == PTR_TO_PACKET ||
 			    (BPF_SRC(insn->code) == BPF_X &&
 			     regs[insn->src_reg].type == PTR_TO_PACKET))) {
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 95a8d5f3ab80..0ea89456d478 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -1814,16 +1814,22 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 	},
 	{
-		"unpriv: obfuscate stack pointer",
+		"stack pointer arithmetic",
 		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_MOV64_IMM(BPF_REG_1, 4),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, -10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, -10),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_2, BPF_REG_1),
+			BPF_ST_MEM(0, BPF_REG_2, 4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_7),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 8),
+			BPF_ST_MEM(0, BPF_REG_2, 4, 0),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
-		.errstr_unpriv = "R2 pointer arithmetic",
-		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
-- 
2.9.3
