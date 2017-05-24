From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 5/5] bpf: add various verifier test cases
Date: Thu, 25 May 2017 01:05:09 +0200
Message-ID: <05b91ecbad5b0eb533e520d0c84b5dd6972fd95d.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40354 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033668AbdEXXFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 19:05:42 -0400
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
In-Reply-To: <cover.1495665905.git.daniel@iogearbox.net>
References: <cover.1495665905.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds various verifier test cases:

1) A test case for the pruning issue when tracking alignment
   is used.
2) Various PTR_TO_MAP_VALUE_OR_NULL tests to make sure pointer
   arithmetic turns such register into UNKNOWN_VALUE type.
3) Test cases for the special treatment of LD_ABS/LD_IND to
   make sure verifier doesn't break calling convention here.
   Latter is needed, since f.e. arm64 JIT uses r1 - r5 for
   storing temporary data, so they really must be marked as
   NOT_INIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/filter.h                      |  10 ++
 tools/include/linux/filter.h                |  10 ++
 tools/testing/selftests/bpf/test_verifier.c | 239 +++++++++++++++++++++++++++-
 3 files changed, 255 insertions(+), 4 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 56197f8..62d948f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -272,6 +272,16 @@
 		.off   = OFF,					\
 		.imm   = IMM })
 
+/* Unconditional jumps, goto pc + off16 */
+
+#define BPF_JMP_A(OFF)						\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_JA,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
 /* Function call */
 
 #define BPF_EMIT_CALL(FUNC)					\
diff --git a/tools/include/linux/filter.h b/tools/include/linux/filter.h
index 390d7c9..4ce25d4 100644
--- a/tools/include/linux/filter.h
+++ b/tools/include/linux/filter.h
@@ -208,6 +208,16 @@
 		.off   = OFF,					\
 		.imm   = IMM })
 
+/* Unconditional jumps, goto pc + off16 */
+
+#define BPF_JMP_A(OFF)						\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_JA,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
 /* Function call */
 
 #define BPF_EMIT_CALL(FUNC)					\
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 3773562..cabb19b 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -49,6 +49,7 @@
 #define MAX_NR_MAPS	4
 
 #define F_NEEDS_EFFICIENT_UNALIGNED_ACCESS	(1 << 0)
+#define F_LOAD_WITH_STRICT_ALIGNMENT		(1 << 1)
 
 struct bpf_test {
 	const char *descr;
@@ -2615,6 +2616,30 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test17 (pruning, alignment)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 14),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_7, 1, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_W, BPF_REG_0, BPF_REG_0, -4),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 1),
+			BPF_JMP_A(-6),
+		},
+		.errstr = "misaligned packet access off 2+15+-4 size 4",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.flags = F_LOAD_WITH_STRICT_ALIGNMENT,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
@@ -3341,6 +3366,70 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS
 	},
 	{
+		"alu ops on ptr_to_map_value_or_null, 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, -2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.errstr = "R4 invalid mem access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
+		"alu ops on ptr_to_map_value_or_null, 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_4, -1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.errstr = "R4 invalid mem access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
+		"alu ops on ptr_to_map_value_or_null, 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_4, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_4, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.errstr = "R4 invalid mem access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS
+	},
+	{
 		"invalid memory access with multiple map_lookup_elem calls",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_1, 10),
@@ -4937,7 +5026,149 @@ struct test_val {
 		.fixup_map_in_map = { 3 },
 		.errstr = "R1 type=map_value_or_null expected=map_ptr",
 		.result = REJECT,
-	}
+	},
+	{
+		"ld_abs: check calling conv, r1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R1 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_abs: check calling conv, r2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_abs: check calling conv, r3",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R3 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_abs: check calling conv, r4",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R4 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_abs: check calling conv, r5",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_5),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R5 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_abs: check calling conv, r7",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_7, 0),
+			BPF_LD_ABS(BPF_W, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_7),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"ld_ind: check calling conv, r1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_1, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_1, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R1 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_ind: check calling conv, r2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_2, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_2, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_ind: check calling conv, r3",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_3, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_3, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R3 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_ind: check calling conv, r4",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_4, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_4, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R4 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_ind: check calling conv, r5",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_5, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_5, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_5),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R5 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"ld_ind: check calling conv, r7",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_7, 1),
+			BPF_LD_IND(BPF_W, BPF_REG_7, -0x200000),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_7),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
@@ -5059,9 +5290,9 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	do_test_fixup(test, prog, map_fds);
 
-	fd_prog = bpf_load_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
-				   prog, prog_len, "GPL", 0, bpf_vlog,
-				   sizeof(bpf_vlog));
+	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
+				     prog, prog_len, test->flags & F_LOAD_WITH_STRICT_ALIGNMENT,
+				     "GPL", 0, bpf_vlog, sizeof(bpf_vlog));
 
 	expected_ret = unpriv && test->result_unpriv != UNDEF ?
 		       test->result_unpriv : test->result;
-- 
1.9.3
