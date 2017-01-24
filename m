From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/5] bpf: enable verifier to better track const alu ops
Date: Tue, 24 Jan 2017 01:06:30 +0100
Message-ID: <41914154d137b47e3c9400da58e7e2b15ef5d43a.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        William Tu <u9012063@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44968 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdAXAGr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:47 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William reported couple of issues in relation to direct packet
access. Typical scheme is to check for data + [off] <= data_end,
where [off] can be either immediate or coming from a tracked
register that contains an immediate, depending on the branch, we
can then access the data. However, in case of calculating [off]
for either the mentioned test itself or for access after the test
in a more "complex" way, then the verifier will stop tracking the
CONST_IMM marked register and will mark it as UNKNOWN_VALUE one.

Adding that UNKNOWN_VALUE typed register to a pkt() marked
register, the verifier then bails out in check_packet_ptr_add()
as it finds the registers imm value below 48. In the first below
example, that is due to evaluate_reg_imm_alu() not handling right
shifts and thus marking the register as UNKNOWN_VALUE via helper
__mark_reg_unknown_value() that resets imm to 0.

In the second case the same happens at the time when r4 is set
to r4 &= r5, where it transitions to UNKNOWN_VALUE from
evaluate_reg_imm_alu(). Later on r4 we shift right by 3 inside
evaluate_reg_alu(), where the register's imm turns into 3. That
is, for registers with type UNKNOWN_VALUE, imm of 0 means that
we don't know what value the register has, and for imm > 0 it
means that the value has [imm] upper zero bits. F.e. when shifting
an UNKNOWN_VALUE register by 3 to the right, no matter what value
it had, we know that the 3 upper most bits must be zero now.
This is to make sure that ALU operations with unknown registers
don't overflow. Meaning, once we know that we have more than 48
upper zero bits, or, in other words cannot go beyond 0xffff offset
with ALU ops, such an addition will track the target register
as a new pkt() register with a new id, but 0 offset and 0 range,
so for that a new data/data_end test will be required. Is the source
register a CONST_IMM one that is to be added to the pkt() register,
or the source instruction is an add instruction with immediate
value, then it will get added if it stays within max 0xffff bounds.
>From there, pkt() type, can be accessed should reg->off + imm be
within the access range of pkt().

  [...]
  from 28 to 30: R0=imm1,min_value=1,max_value=1
    R1=pkt(id=0,off=0,r=22) R2=pkt_end
    R3=imm144,min_value=144,max_value=144
    R4=imm0,min_value=0,max_value=0
    R5=inv48,min_value=2054,max_value=2054 R10=fp
  30: (bf) r5 = r3
  31: (07) r5 += 23
  32: (77) r5 >>= 3
  33: (bf) r6 = r1
  34: (0f) r6 += r5
  cannot add integer value with 0 upper zero bits to ptr_to_packet

  [...]
  from 52 to 80: R0=imm1,min_value=1,max_value=1
    R1=pkt(id=0,off=0,r=34) R2=pkt_end R3=inv
    R4=imm272 R5=inv56,min_value=17,max_value=17
    R6=pkt(id=0,off=26,r=34) R10=fp
  80: (07) r4 += 71
  81: (18) r5 = 0xfffffff8
  83: (5f) r4 &= r5
  84: (77) r4 >>= 3
  85: (0f) r1 += r4
  cannot add integer value with 3 upper zero bits to ptr_to_packet

Thus to get above use-cases working, evaluate_reg_imm_alu() has
been extended for further ALU ops. This is fine, because we only
operate strictly within realm of CONST_IMM types, so here we don't
care about overflows as they will happen in the simulated but also
real execution and interaction with pkt() in check_packet_ptr_add()
will check actual imm value once added to pkt(), but it's irrelevant
before.

With regards to 06c1c049721a ("bpf: allow helpers access to variable
memory") that works on UNKNOWN_VALUE registers, the verifier becomes
now a bit smarter as it can better resolve ALU ops, so we need to
adapt two test cases there, as min/max bound tracking only becomes
necessary when registers were spilled to stack. So while mask was
set before to track upper bound for UNKNOWN_VALUE case, it's now
resolved directly as CONST_IMM, and such contructs are only necessary
when f.e. registers are spilled.

For commit 6b17387307ba ("bpf: recognize 64bit immediate loads as
consts") that initially enabled dw load tracking only for nfp jit/
analyzer, I did couple of tests on large, complex programs and we
don't increase complexity badly (my tests were in ~3% range on avg).
I've added a couple of tests similar to affected code above, and
it works fine with verifier now.

Reported-by: William Tu <u9012063@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Gianluca Borello <g.borello@gmail.com>
Cc: William Tu <u9012063@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       | 64 +++++++++++++++-------
 tools/testing/selftests/bpf/test_verifier.c | 82 +++++++++++++++++++++++++++++
 2 files changed, 127 insertions(+), 19 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8f69df7..fb3513b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1566,22 +1566,54 @@ static int evaluate_reg_imm_alu(struct bpf_verifier_env *env,
 	struct bpf_reg_state *dst_reg = &regs[insn->dst_reg];
 	struct bpf_reg_state *src_reg = &regs[insn->src_reg];
 	u8 opcode = BPF_OP(insn->code);
+	u64 dst_imm = dst_reg->imm;
 
-	/* dst_reg->type == CONST_IMM here, simulate execution of 'add'/'or'
-	 * insn. Don't care about overflow or negative values, just add them
+	/* dst_reg->type == CONST_IMM here. Simulate execution of insns
+	 * containing ALU ops. Don't care about overflow or negative
+	 * values, just add/sub/... them; registers are in u64.
 	 */
-	if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_K)
-		dst_reg->imm += insn->imm;
-	else if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_X &&
-		 src_reg->type == CONST_IMM)
-		dst_reg->imm += src_reg->imm;
-	else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_K)
-		dst_reg->imm |= insn->imm;
-	else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_X &&
-		 src_reg->type == CONST_IMM)
-		dst_reg->imm |= src_reg->imm;
-	else
+	if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm += insn->imm;
+	} else if (opcode == BPF_ADD && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm += src_reg->imm;
+	} else if (opcode == BPF_SUB && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm -= insn->imm;
+	} else if (opcode == BPF_SUB && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm -= src_reg->imm;
+	} else if (opcode == BPF_MUL && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm *= insn->imm;
+	} else if (opcode == BPF_MUL && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm *= src_reg->imm;
+	} else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm |= insn->imm;
+	} else if (opcode == BPF_OR && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm |= src_reg->imm;
+	} else if (opcode == BPF_AND && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm &= insn->imm;
+	} else if (opcode == BPF_AND && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm &= src_reg->imm;
+	} else if (opcode == BPF_RSH && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm >>= insn->imm;
+	} else if (opcode == BPF_RSH && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm >>= src_reg->imm;
+	} else if (opcode == BPF_LSH && BPF_SRC(insn->code) == BPF_K) {
+		dst_imm <<= insn->imm;
+	} else if (opcode == BPF_LSH && BPF_SRC(insn->code) == BPF_X &&
+		   src_reg->type == CONST_IMM) {
+		dst_imm <<= src_reg->imm;
+	} else {
 		mark_reg_unknown_value(regs, insn->dst_reg);
+		goto out;
+	}
+
+	dst_reg->imm = dst_imm;
+out:
 	return 0;
 }
 
@@ -2225,14 +2257,8 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		return err;
 
 	if (insn->src_reg == 0) {
-		/* generic move 64-bit immediate into a register,
-		 * only analyzer needs to collect the ld_imm value.
-		 */
 		u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
 
-		if (!env->analyzer_ops)
-			return 0;
-
 		regs[insn->dst_reg].type = CONST_IMM;
 		regs[insn->dst_reg].imm = imm;
 		return 0;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 1aa7324..0d0912c 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2326,6 +2326,84 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test11 (shift, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 22),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 144),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 23),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_5, 3),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test12 (and, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 22),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 144),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 23),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_5, 15),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test13 (branches, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 22),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 13),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_MOV64_IMM(BPF_REG_4, 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_3, BPF_REG_4, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 14),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_MOV64_IMM(BPF_REG_3, 24),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 23),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_5, 15),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
@@ -4208,6 +4286,8 @@ struct test_val {
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_1, 0),
 			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
 			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
 			BPF_MOV64_IMM(BPF_REG_4, 0),
@@ -4251,6 +4331,8 @@ struct test_val {
 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
 			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
 			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 63),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
 			BPF_MOV64_IMM(BPF_REG_3, 0),
-- 
1.9.3
