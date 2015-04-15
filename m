From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: fix two bugs in verification logic when accessing 'ctx' pointer
Date: Wed, 15 Apr 2015 16:19:33 -0700
Message-ID: <1429139973-5473-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33837 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbbDOXTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 19:19:41 -0400
Received: by pdbqa5 with SMTP id qa5so69108041pdb.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 16:19:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1.
first bug is a silly mistake. It broke tracing examples and prevented
simple bpf programs from loading.

In the following code:
if (insn->imm == 0 && BPF_SIZE(insn->code) == BPF_W) {
} else if (...) {
  // this part should have been executed when
  // insn->code == BPF_W and insn->imm != 0
}

Obviously it's not doing that. So simple instructions like:
r2 = *(u64 *)(r1 + 8)
will be rejected. Note the comments in the code around these branches
were and still valid and indicate the true intent.

Replace it with:
if (BPF_SIZE(insn->code) != BPF_W)
  continue;

if (insn->imm == 0) {
} else if (...) {
  // now this code will be executed when
  // insn->code == BPF_W and insn->imm != 0
}

2.
second bug is more subtle.
If malicious code is using the same dest register as source register,
the checks designed to prevent the same instruction to be used with different
pointer types will fail to trigger, since we were assigning src_reg_type
when it was already overwritten by check_mem_access().
The fix is trivial. Just move line:
src_reg_type = regs[insn->src_reg].type;
before check_mem_access().
Add new 'access skb fields bad4' test to check this case.

Fixes: 9bac3d6d548e ("bpf: allow extended BPF programs access skb fields")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
I would love to add the testcase for bug#1 as well, but it needs bigger
refactoring of test_verifier, so will do it after net-next reopens.

 kernel/bpf/verifier.c       |    9 +++++++--
 samples/bpf/test_verifier.c |   22 ++++++++++++++++++++++
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 66bec36ec1ec..47dcd3aa6e23 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1637,6 +1637,8 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
+			src_reg_type = regs[insn->src_reg].type;
+
 			/* check that memory (src_reg + off) is readable,
 			 * the state of dst_reg will be updated by this func
 			 */
@@ -1646,9 +1648,12 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
-			src_reg_type = regs[insn->src_reg].type;
+			if (BPF_SIZE(insn->code) != BPF_W) {
+				insn_idx++;
+				continue;
+			}
 
-			if (insn->imm == 0 && BPF_SIZE(insn->code) == BPF_W) {
+			if (insn->imm == 0) {
 				/* saw a valid insn
 				 * dst_reg = *(u32 *)(src_reg + off)
 				 * use reserved 'imm' field to mark this insn
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 9ab645698ffb..12f3780af73f 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -721,6 +721,28 @@ static struct bpf_test tests[] = {
 		.errstr = "different pointers",
 		.result = REJECT,
 	},
+	{
+		"access skb fields bad4",
+		.insns = {
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 3),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, len)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -13),
+		},
+		.fixup = {7},
+		.errstr = "different pointers",
+		.result = REJECT,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
1.7.9.5
