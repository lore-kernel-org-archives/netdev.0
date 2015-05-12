From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] test_bpf: add 173 new testcases for eBPF
Date: Tue, 12 May 2015 08:38:16 -0700
Message-ID: <1431445096-13698-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34305 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbbELPi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:38:29 -0400
Received: by pacyx8 with SMTP id yx8so16526419pac.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:38:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

add an exhaustive set of eBPF tests bringing total to:
test_bpf: Summary: 233 PASSED, 0 FAILED, [0/226 JIT'ed]

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net> 
---
V1->V2: removed double 'From', added 'Ack'

these tests found div64 bug in interpreter (already fixed)
and another cpu_to_be16 bug in x64 JIT (fix is being worked on).

 include/linux/filter.h |   10 +
 lib/test_bpf.c         | 2192 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 2202 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 3c03a6085b82..ce1d72d34382 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -207,6 +207,16 @@ struct bpf_prog_aux;
 		.off   = OFF,					\
 		.imm   = 0 })
 
+/* Atomic memory add, *(uint *)(dst_reg + off16) += src_reg */
+
+#define BPF_STX_XADD(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_XADD,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
 /* Memory store, *(uint *) (dst_reg + off16) = imm32 */
 
 #define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 3c41049d72d8..8bca780e3613 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1806,6 +1806,2198 @@ static struct bpf_test tests[] = {
 		  0x10, 0xbf, 0x48, 0xd6, 0x43, 0xd6},
 		{ { 38, 256 } }
 	},
+	/* BPF_ALU | BPF_MOV | BPF_X */
+	{
+		"ALU_MOV_X: dst = 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_MOV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_MOV_X: dst = 4294967295",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_ALU32_REG(BPF_MOV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	{
+		"ALU64_MOV_X: dst = 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_MOV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_MOV_X: dst = 4294967295",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_ALU64_REG(BPF_MOV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	/* BPF_ALU | BPF_MOV | BPF_K */
+	{
+		"ALU_MOV_K: dst = 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_MOV_K: dst = 4294967295",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 4294967295),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	{
+		"ALU_MOV_K: 0x0000ffffffff0000 = 0x00000000ffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x00000000ffffffff),
+			BPF_ALU32_IMM(BPF_MOV, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_MOV_K: dst = 2",
+		.u.insns_int = {
+			BPF_ALU64_IMM(BPF_MOV, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_MOV_K: dst = 2147483647",
+		.u.insns_int = {
+			BPF_ALU64_IMM(BPF_MOV, R0, 2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2147483647 } },
+	},
+	{
+		"ALU64_OR_K: dst = 0x0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x0),
+			BPF_ALU64_IMM(BPF_MOV, R2, 0x0),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_MOV_K: dst = -1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_MOV, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_ADD | BPF_X */
+	{
+		"ALU_ADD_X: 1 + 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_ADD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_ADD_X: 1 + 4294967294 = 4294967295",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU32_REG(BPF_ADD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	{
+		"ALU64_ADD_X: 1 + 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_ADD_X: 1 + 4294967294 = 4294967295",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	/* BPF_ALU | BPF_ADD | BPF_K */
+	{
+		"ALU_ADD_K: 1 + 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_ADD, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_ADD_K: 3 + 0 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_ADD, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_ADD_K: 1 + 4294967294 = 4294967295",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_ADD, R0, 4294967294),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 4294967295 } },
+	},
+	{
+		"ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0x00000000ffffffff),
+			BPF_ALU32_IMM(BPF_ADD, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_ADD_K: 1 + 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_ADD, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_ADD_K: 3 + 0 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_ADD, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_ADD_K: 1 + 2147483646 = 2147483647",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_ADD, R0, 2147483646),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2147483647 } },
+	},
+	{
+		"ALU64_ADD_K: 2147483646 + -2147483647 = -1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483646),
+			BPF_ALU64_IMM(BPF_ADD, R0, -2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -1 } },
+	},
+	{
+		"ALU64_ADD_K: 1 + 0 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x1),
+			BPF_LD_IMM64(R3, 0x1),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0x0),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_ADD_K: 0 + (-1) = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_ADD, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_SUB | BPF_X */
+	{
+		"ALU_SUB_X: 3 - 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU32_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_SUB_X: 4294967295 - 4294967294 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU32_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_SUB_X: 3 - 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU64_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_SUB_X: 4294967295 - 4294967294 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU64_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_ALU | BPF_SUB | BPF_K */
+	{
+		"ALU_SUB_K: 3 - 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_SUB, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_SUB_K: 3 - 0 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_SUB, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_SUB_K: 4294967295 - 4294967294 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_SUB, R0, 4294967294),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_SUB_K: 3 - 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_SUB, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_SUB_K: 3 - 0 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_SUB, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_SUB_K: 4294967294 - 4294967295 = -1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967294),
+			BPF_ALU64_IMM(BPF_SUB, R0, 4294967295),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -1 } },
+	},
+	{
+		"ALU64_ADD_K: 2147483646 - 2147483647 = -1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483646),
+			BPF_ALU64_IMM(BPF_SUB, R0, 2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -1 } },
+	},
+	/* BPF_ALU | BPF_MUL | BPF_X */
+	{
+		"ALU_MUL_X: 2 * 3 = 6",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R1, 3),
+			BPF_ALU32_REG(BPF_MUL, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 6 } },
+	},
+	{
+		"ALU_MUL_X: 2 * 0x7FFFFFF8 = 0xFFFFFFF0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0x7FFFFFF8),
+			BPF_ALU32_REG(BPF_MUL, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xFFFFFFF0 } },
+	},
+	{
+		"ALU_MUL_X: -1 * -1 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, -1),
+			BPF_ALU32_IMM(BPF_MOV, R1, -1),
+			BPF_ALU32_REG(BPF_MUL, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_MUL_X: 2 * 3 = 6",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R1, 3),
+			BPF_ALU64_REG(BPF_MUL, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 6 } },
+	},
+	{
+		"ALU64_MUL_X: 1 * 2147483647 = 2147483647",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2147483647),
+			BPF_ALU64_REG(BPF_MUL, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2147483647 } },
+	},
+	/* BPF_ALU | BPF_MUL | BPF_K */
+	{
+		"ALU_MUL_K: 2 * 3 = 6",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MUL, R0, 3),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 6 } },
+	},
+	{
+		"ALU_MUL_K: 3 * 1 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MUL, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_MUL_K: 2 * 0x7FFFFFF8 = 0xFFFFFFF0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MUL, R0, 0x7FFFFFF8),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xFFFFFFF0 } },
+	},
+	{
+		"ALU_MUL_K: 1 * (-1) = 0x00000000ffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x1),
+			BPF_LD_IMM64(R3, 0x00000000ffffffff),
+			BPF_ALU32_IMM(BPF_MUL, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_MUL_K: 2 * 3 = 6",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU64_IMM(BPF_MUL, R0, 3),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 6 } },
+	},
+	{
+		"ALU64_MUL_K: 3 * 1 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_MUL, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_MUL_K: 1 * 2147483647 = 2147483647",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_MUL, R0, 2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2147483647 } },
+	},
+	{
+		"ALU64_MUL_K: 1 * -2147483647 = -2147483647",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_MUL, R0, -2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -2147483647 } },
+	},
+	{
+		"ALU64_MUL_K: 1 * (-1) = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x1),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_MUL, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_DIV | BPF_X */
+	{
+		"ALU_DIV_X: 6 / 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 6),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_DIV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_DIV_X: 4294967295 / 4294967295 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_ALU32_REG(BPF_DIV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_DIV_X: 6 / 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 6),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_DIV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_DIV_X: 2147483647 / 2147483647 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483647),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2147483647),
+			BPF_ALU64_REG(BPF_DIV, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_DIV_X: 0xffffffffffffffff / (-1) = 0x0000000000000001",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R4, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R3, 0x0000000000000001UL),
+			BPF_ALU64_REG(BPF_DIV, R2, R4),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_DIV | BPF_K */
+	{
+		"ALU_DIV_K: 6 / 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 6),
+			BPF_ALU32_IMM(BPF_DIV, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_DIV_K: 3 / 1 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_DIV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_DIV_K: 4294967295 / 4294967295 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_DIV, R0, 4294967295),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU_DIV_K: 0xffffffffffffffff / (-1) = 0x1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R3, 0x1UL),
+			BPF_ALU32_IMM(BPF_DIV, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_DIV_K: 6 / 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 6),
+			BPF_ALU64_IMM(BPF_DIV, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_DIV_K: 3 / 1 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_DIV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_DIV_K: 2147483647 / 2147483647 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483647),
+			BPF_ALU64_IMM(BPF_DIV, R0, 2147483647),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_DIV_K: 0xffffffffffffffff / (-1) = 0x0000000000000001",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R3, 0x0000000000000001UL),
+			BPF_ALU64_IMM(BPF_DIV, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_MOD | BPF_X */
+	{
+		"ALU_MOD_X: 3 % 2 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_MOD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU_MOD_X: 4294967295 % 4294967293 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967293),
+			BPF_ALU32_REG(BPF_MOD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_MOD_X: 3 % 2 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_MOD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_MOD_X: 2147483647 % 2147483645 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483647),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2147483645),
+			BPF_ALU64_REG(BPF_MOD, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	/* BPF_ALU | BPF_MOD | BPF_K */
+	{
+		"ALU_MOD_K: 3 % 2 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOD, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU_MOD_K: 3 % 1 = 0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOD, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0 } },
+	},
+	{
+		"ALU_MOD_K: 4294967295 % 4294967293 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOD, R0, 4294967293),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_MOD_K: 3 % 2 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_MOD, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_MOD_K: 3 % 1 = 0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_MOD, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0 } },
+	},
+	{
+		"ALU64_MOD_K: 2147483647 % 2147483645 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2147483647),
+			BPF_ALU64_IMM(BPF_MOD, R0, 2147483645),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	/* BPF_ALU | BPF_AND | BPF_X */
+	{
+		"ALU_AND_X: 3 & 2 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_AND, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_AND_X: 0xffffffff & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffff),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU32_REG(BPF_AND, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_AND_X: 3 & 2 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_AND, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_AND_X: 0xffffffff & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffff),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU64_REG(BPF_AND, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	/* BPF_ALU | BPF_AND | BPF_K */
+	{
+		"ALU_AND_K: 3 & 2 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU32_IMM(BPF_AND, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_AND_K: 0xffffffff & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffff),
+			BPF_ALU32_IMM(BPF_AND, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_AND_K: 3 & 2 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_AND, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_AND_K: 0xffffffff & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffff),
+			BPF_ALU64_IMM(BPF_AND, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_AND_K: 0x0000ffffffff0000 & 0x0 = 0x0000ffff00000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x0000000000000000),
+			BPF_ALU64_IMM(BPF_AND, R2, 0x0),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_AND_K: 0x0000ffffffff0000 & -1 = 0x0000ffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_ALU64_IMM(BPF_AND, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_AND_K: 0xffffffffffffffff & -1 = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0xffffffffffffffff),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_AND, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_OR | BPF_X */
+	{
+		"ALU_OR_X: 1 | 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU32_REG(BPF_OR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_OR_X: 0x0 | 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU32_REG(BPF_OR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_OR_X: 1 | 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 2),
+			BPF_ALU64_REG(BPF_OR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_OR_X: 0 | 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU64_REG(BPF_OR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	/* BPF_ALU | BPF_OR | BPF_K */
+	{
+		"ALU_OR_K: 1 | 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_OR, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_OR_K: 0 & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_ALU32_IMM(BPF_OR, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_OR_K: 1 | 2 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_OR, R0, 2),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_OR_K: 0 & 0xffffffff = 0xffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_ALU64_IMM(BPF_OR, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ALU64_OR_K: 0x0000ffffffff0000 | 0x0 = 0x0000ffff00000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_ALU64_IMM(BPF_OR, R2, 0x0),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_OR_K: 0x0000ffffffff0000 | -1 = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_OR, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_OR_K: 0x000000000000000 | -1 = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000000000000000),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_OR, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_XOR | BPF_X */
+	{
+		"ALU_XOR_X: 5 ^ 6 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 5),
+			BPF_ALU32_IMM(BPF_MOV, R1, 6),
+			BPF_ALU32_REG(BPF_XOR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_XOR_X: 0x1 ^ 0xffffffff = 0xfffffffe",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU32_REG(BPF_XOR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfffffffe } },
+	},
+	{
+		"ALU64_XOR_X: 5 ^ 6 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 5),
+			BPF_ALU32_IMM(BPF_MOV, R1, 6),
+			BPF_ALU64_REG(BPF_XOR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_XOR_X: 1 ^ 0xffffffff = 0xfffffffe",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0xffffffff),
+			BPF_ALU64_REG(BPF_XOR, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfffffffe } },
+	},
+	/* BPF_ALU | BPF_XOR | BPF_K */
+	{
+		"ALU_XOR_K: 5 ^ 6 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 5),
+			BPF_ALU32_IMM(BPF_XOR, R0, 6),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU_XOR_K: 1 ^ 0xffffffff = 0xfffffffe",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_XOR, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfffffffe } },
+	},
+	{
+		"ALU64_XOR_K: 5 ^ 6 = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 5),
+			BPF_ALU64_IMM(BPF_XOR, R0, 6),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_XOR_K: 1 & 0xffffffff = 0xfffffffe",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_XOR, R0, 0xffffffff),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfffffffe } },
+	},
+	{
+		"ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 = 0x0000ffffffff0000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_ALU64_IMM(BPF_XOR, R2, 0x0),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 = 0xffff00000000ffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R3, 0xffff00000000ffff),
+			BPF_ALU64_IMM(BPF_XOR, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ALU64_XOR_K: 0x000000000000000 ^ -1 = 0xffffffffffffffff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0x0000000000000000),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ALU64_IMM(BPF_XOR, R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	/* BPF_ALU | BPF_LSH | BPF_X */
+	{
+		"ALU_LSH_X: 1 << 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU32_REG(BPF_LSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_LSH_X: 1 << 31 = 0x80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 31),
+			BPF_ALU32_REG(BPF_LSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x80000000 } },
+	},
+	{
+		"ALU64_LSH_X: 1 << 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU64_REG(BPF_LSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_LSH_X: 1 << 31 = 0x80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_MOV, R1, 31),
+			BPF_ALU64_REG(BPF_LSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x80000000 } },
+	},
+	/* BPF_ALU | BPF_LSH | BPF_K */
+	{
+		"ALU_LSH_K: 1 << 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_LSH, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU_LSH_K: 1 << 31 = 0x80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU32_IMM(BPF_LSH, R0, 31),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x80000000 } },
+	},
+	{
+		"ALU64_LSH_K: 1 << 1 = 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_LSH, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 2 } },
+	},
+	{
+		"ALU64_LSH_K: 1 << 31 = 0x80000000",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 1),
+			BPF_ALU64_IMM(BPF_LSH, R0, 31),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x80000000 } },
+	},
+	/* BPF_ALU | BPF_RSH | BPF_X */
+	{
+		"ALU_RSH_X: 2 >> 1 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU32_REG(BPF_RSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU_RSH_X: 0x80000000 >> 31 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x80000000),
+			BPF_ALU32_IMM(BPF_MOV, R1, 31),
+			BPF_ALU32_REG(BPF_RSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_RSH_X: 2 >> 1 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R1, 1),
+			BPF_ALU64_REG(BPF_RSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_RSH_X: 0x80000000 >> 31 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x80000000),
+			BPF_ALU32_IMM(BPF_MOV, R1, 31),
+			BPF_ALU64_REG(BPF_RSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_ALU | BPF_RSH | BPF_K */
+	{
+		"ALU_RSH_K: 2 >> 1 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU32_IMM(BPF_RSH, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU_RSH_K: 0x80000000 >> 31 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x80000000),
+			BPF_ALU32_IMM(BPF_RSH, R0, 31),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_RSH_K: 2 >> 1 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_ALU64_IMM(BPF_RSH, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"ALU64_RSH_K: 0x80000000 >> 31 = 1",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x80000000),
+			BPF_ALU64_IMM(BPF_RSH, R0, 31),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_ALU | BPF_ARSH | BPF_X */
+	{
+		"ALU_ARSH_X: 0xff00ff0000000000 >> 40 = 0xffffffffffff00ff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xff00ff0000000000LL),
+			BPF_ALU32_IMM(BPF_MOV, R1, 40),
+			BPF_ALU64_REG(BPF_ARSH, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffff00ff } },
+	},
+	/* BPF_ALU | BPF_ARSH | BPF_K */
+	{
+		"ALU_ARSH_K: 0xff00ff0000000000 >> 40 = 0xffffffffffff00ff",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xff00ff0000000000LL),
+			BPF_ALU64_IMM(BPF_ARSH, R0, 40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffff00ff } },
+	},
+	/* BPF_ALU | BPF_NEG */
+	{
+		"ALU_NEG: -(3) = -3",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 3),
+			BPF_ALU32_IMM(BPF_NEG, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -3 } },
+	},
+	{
+		"ALU_NEG: -(-3) = 3",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, -3),
+			BPF_ALU32_IMM(BPF_NEG, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	{
+		"ALU64_NEG: -(3) = -3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 3),
+			BPF_ALU64_IMM(BPF_NEG, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -3 } },
+	},
+	{
+		"ALU64_NEG: -(-3) = 3",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, -3),
+			BPF_ALU64_IMM(BPF_NEG, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 3 } },
+	},
+	/* BPF_ALU | BPF_END | BPF_FROM_BE */
+	{
+		"ALU_END_FROM_BE 16: 0x0123456789abcdef -> 0xcdef",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_BE, R0, 16),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0,  cpu_to_be16(0xcdef) } },
+	},
+	{
+		"ALU_END_FROM_BE 32: 0x0123456789abcdef -> 0x89abcdef",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_BE, R0, 32),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, cpu_to_be32(0x89abcdef) } },
+	},
+	{
+		"ALU_END_FROM_BE 64: 0x0123456789abcdef -> 0x89abcdef",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_BE, R0, 64),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, (u32) cpu_to_be64(0x0123456789abcdefLL) } },
+	},
+	/* BPF_ALU | BPF_END | BPF_FROM_LE */
+	{
+		"ALU_END_FROM_LE 16: 0x0123456789abcdef -> 0xefcd",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_LE, R0, 16),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, cpu_to_le16(0xcdef) } },
+	},
+	{
+		"ALU_END_FROM_LE 32: 0x0123456789abcdef -> 0xefcdab89",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_LE, R0, 32),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, cpu_to_le32(0x89abcdef) } },
+	},
+	{
+		"ALU_END_FROM_LE 64: 0x0123456789abcdef -> 0x67452301",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0x0123456789abcdefLL),
+			BPF_ENDIAN(BPF_FROM_LE, R0, 64),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, (u32) cpu_to_le64(0x0123456789abcdefLL) } },
+	},
+	/* BPF_ST(X) | BPF_MEM | BPF_B/H/W/DW */
+	{
+		"ST_MEM_B: Store/Load byte: max negative",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_B, R10, -40, 0xff),
+			BPF_LDX_MEM(BPF_B, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xff } },
+	},
+	{
+		"ST_MEM_B: Store/Load byte: max positive",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_H, R10, -40, 0x7f),
+			BPF_LDX_MEM(BPF_H, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x7f } },
+	},
+	{
+		"STX_MEM_B: Store/Load byte: max negative",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_LD_IMM64(R1, 0xffLL),
+			BPF_STX_MEM(BPF_B, R10, R1, -40),
+			BPF_LDX_MEM(BPF_B, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xff } },
+	},
+	{
+		"ST_MEM_H: Store/Load half word: max negative",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_H, R10, -40, 0xffff),
+			BPF_LDX_MEM(BPF_H, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffff } },
+	},
+	{
+		"ST_MEM_H: Store/Load half word: max positive",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_H, R10, -40, 0x7fff),
+			BPF_LDX_MEM(BPF_H, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x7fff } },
+	},
+	{
+		"STX_MEM_H: Store/Load half word: max negative",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_LD_IMM64(R1, 0xffffLL),
+			BPF_STX_MEM(BPF_H, R10, R1, -40),
+			BPF_LDX_MEM(BPF_H, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffff } },
+	},
+	{
+		"ST_MEM_W: Store/Load word: max negative",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_W, R10, -40, 0xffffffff),
+			BPF_LDX_MEM(BPF_W, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ST_MEM_W: Store/Load word: max positive",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_W, R10, -40, 0x7fffffff),
+			BPF_LDX_MEM(BPF_W, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x7fffffff } },
+	},
+	{
+		"STX_MEM_W: Store/Load word: max negative",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffLL),
+			BPF_STX_MEM(BPF_W, R10, R1, -40),
+			BPF_LDX_MEM(BPF_W, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ST_MEM_DW: Store/Load double word: max negative",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0xffffffff),
+			BPF_LDX_MEM(BPF_DW, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	{
+		"ST_MEM_DW: Store/Load double word: max negative 2",
+		.u.insns_int = {
+			BPF_LD_IMM64(R2, 0xffff00000000ffff),
+			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0xffffffff),
+			BPF_LDX_MEM(BPF_DW, R2, R10, -40),
+			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
+			BPF_MOV32_IMM(R0, 2),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x1 } },
+	},
+	{
+		"ST_MEM_DW: Store/Load double word: max positive",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0x7fffffff),
+			BPF_LDX_MEM(BPF_DW, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x7fffffff } },
+	},
+	{
+		"STX_MEM_DW: Store/Load double word: max negative",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_STX_MEM(BPF_W, R10, R1, -40),
+			BPF_LDX_MEM(BPF_W, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffff } },
+	},
+	/* BPF_STX | BPF_XADD | BPF_W/DW */
+	{
+		"STX_XADD_W: Test: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_W, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_W, R10, R0, -40),
+			BPF_LDX_MEM(BPF_W, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x22 } },
+	},
+	{
+		"STX_XADD_DW: Test: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_DW, R10, R0, -40),
+			BPF_LDX_MEM(BPF_DW, R0, R10, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x22 } },
+	},
+	/* BPF_JMP | BPF_EXIT */
+	{
+		"JMP_EXIT",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x4711),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x4712),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x4711 } },
+	},
+	/* BPF_JMP | BPF_JA */
+	{
+		"JMP_JA: Unconditional jump: if (true) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSGT | BPF_K */
+	{
+		"JMP_JSGT_K: Signed jump: if (-1 > -2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSGT, R1, -2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSGT_K: Signed jump: if (-1 > -1) return 0",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSGT, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSGE | BPF_K */
+	{
+		"JMP_JSGE_K: Signed jump: if (-1 >= -2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSGE, R1, -2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSGE_K: Signed jump: if (-1 >= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSGE, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JGT | BPF_K */
+	{
+		"JMP_JGT_K: if (3 > 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JGT, R1, 2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JGE | BPF_K */
+	{
+		"JMP_JGE_K: if (3 >= 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JGE, R1, 2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JGE_K: if (3 >= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JGE, R1, 3, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JNE | BPF_K */
+	{
+		"JMP_JNE_K: if (3 != 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JNE, R1, 2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JEQ | BPF_K */
+	{
+		"JMP_JEQ_K: if (3 == 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JEQ, R1, 3, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSET | BPF_K */
+	{
+		"JMP_JSET_K: if (0x3 & 0x2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JNE, R1, 2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSET_K: if (0x3 & 0xffffffff) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JNE, R1, 0xffffffff, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSGT | BPF_X */
+	{
+		"JMP_JSGT_X: Signed jump: if (-1 > -2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -2),
+			BPF_JMP_REG(BPF_JSGT, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSGT_X: Signed jump: if (-1 > -1) return 0",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -1),
+			BPF_JMP_REG(BPF_JSGT, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSGE | BPF_X */
+	{
+		"JMP_JSGE_X: Signed jump: if (-1 >= -2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -2),
+			BPF_JMP_REG(BPF_JSGE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSGE_X: Signed jump: if (-1 >= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -1),
+			BPF_JMP_REG(BPF_JSGE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JGT | BPF_X */
+	{
+		"JMP_JGT_X: if (3 > 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JGT, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JGE | BPF_X */
+	{
+		"JMP_JGE_X: if (3 >= 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JGE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JGE_X: if (3 >= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 3),
+			BPF_JMP_REG(BPF_JGE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JNE | BPF_X */
+	{
+		"JMP_JNE_X: if (3 != 2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JEQ | BPF_X */
+	{
+		"JMP_JEQ_X: if (3 == 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 3),
+			BPF_JMP_REG(BPF_JEQ, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	/* BPF_JMP | BPF_JSET | BPF_X */
+	{
+		"JMP_JSET_X: if (0x3 & 0x2) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSET_X: if (0x3 & 0xffffffff) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 0xffffffff),
+			BPF_JMP_REG(BPF_JNE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 };
 
 static struct net_device dev;
-- 
1.7.9.5
