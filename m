From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/3] bpf: add various verifier test cases for self-tests
Date: Fri, 31 Mar 2017 02:24:04 +0200
Message-ID: <00ef5a8ac678ca38cb86bd8442739478090ceed3.1490918592.git.daniel@iogearbox.net>
References: <cover.1490918592.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@fb.com, jbacik@fb.com, kafai@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46186 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934658AbdCaAYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 20:24:19 -0400
In-Reply-To: <cover.1490918592.git.daniel@iogearbox.net>
In-Reply-To: <cover.1490918592.git.daniel@iogearbox.net>
References: <cover.1490918592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a couple of test cases, for example, probing for xadd on a spilled
pointer to packet and map_value_adj register, various other map_value_adj
tests including the unaligned load/store, and trying out pointer arithmetic
on map_value_adj register itself. For the unaligned load/store, we need
to figure out whether the architecture has efficient unaligned access and
need to mark affected tests accordingly.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/include/linux/filter.h                |  10 ++
 tools/testing/selftests/bpf/Makefile        |   9 +-
 tools/testing/selftests/bpf/test_verifier.c | 270 +++++++++++++++++++++++++++-
 3 files changed, 283 insertions(+), 6 deletions(-)

diff --git a/tools/include/linux/filter.h b/tools/include/linux/filter.h
index 122153b..390d7c9 100644
--- a/tools/include/linux/filter.h
+++ b/tools/include/linux/filter.h
@@ -168,6 +168,16 @@
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
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 6a1ad58..9af09e8 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,7 +1,14 @@
 LIBDIR := ../../../lib
 BPFDIR := $(LIBDIR)/bpf
+APIDIR := ../../../include/uapi
+GENDIR := ../../../../include/generated
+GENHDR := $(GENDIR)/autoconf.h
 
-CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
+ifneq ($(wildcard $(GENHDR)),)
+  GENFLAGS := -DHAVE_GENHDR
+endif
+
+CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS)
 LDLIBS += -lcap
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 7d761d4..c848e90 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -30,6 +30,14 @@
 
 #include <bpf/bpf.h>
 
+#ifdef HAVE_GENHDR
+# include "autoconf.h"
+#else
+# if defined(__i386) || defined(__x86_64) || defined(__s390x__) || defined(__aarch64__)
+#  define CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS 1
+# endif
+#endif
+
 #include "../../../include/linux/filter.h"
 
 #ifndef ARRAY_SIZE
@@ -39,6 +47,8 @@
 #define MAX_INSNS	512
 #define MAX_FIXUPS	8
 
+#define F_NEEDS_EFFICIENT_UNALIGNED_ACCESS	(1 << 0)
+
 struct bpf_test {
 	const char *descr;
 	struct bpf_insn	insns[MAX_INSNS];
@@ -53,6 +63,7 @@ struct bpf_test {
 		REJECT
 	} result, result_unpriv;
 	enum bpf_prog_type prog_type;
+	uint8_t flags;
 };
 
 /* Note we want this to be 64 bit aligned so that the end of our array is
@@ -2432,6 +2443,30 @@ struct test_val {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test15 (spill with xadd)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 8),
+			BPF_MOV64_IMM(BPF_REG_5, 4096),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_4, BPF_REG_2, 0),
+			BPF_STX_XADD(BPF_DW, BPF_REG_4, BPF_REG_5, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_4, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_2, BPF_REG_5, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 invalid mem access 'inv'",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
@@ -2934,6 +2969,7 @@ struct test_val {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a variable",
@@ -2957,6 +2993,7 @@ struct test_val {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"valid map access into an array with a signed variable",
@@ -2984,6 +3021,7 @@ struct test_val {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a constant",
@@ -3025,6 +3063,7 @@ struct test_val {
 		.errstr = "R0 min value is outside of the array range",
 		.result_unpriv = REJECT,
 		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a variable",
@@ -3048,6 +3087,7 @@ struct test_val {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with no floor check",
@@ -3074,6 +3114,7 @@ struct test_val {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a invalid max check",
@@ -3100,6 +3141,7 @@ struct test_val {
 		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
 		.result_unpriv = REJECT,
 		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid map access into an array with a invalid max check",
@@ -3129,6 +3171,7 @@ struct test_val {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result_unpriv = REJECT,
 		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"multiple registers share map_lookup_elem result",
@@ -3252,6 +3295,7 @@ struct test_val {
 		.result = REJECT,
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"constant register |= constant should keep constant type",
@@ -3981,7 +4025,208 @@ struct test_val {
 		.result_unpriv = REJECT,
 	},
 	{
-		"map element value (adjusted) is preserved across register spilling",
+		"map element value or null is marked on register spilling",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -152),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_1, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_3, 0, 42),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 leaks addr",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value store of cleared call register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R1 !read_ok",
+		.errstr = "R1 !read_ok",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value with unaligned store",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 17),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 42),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 2, 43),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, -2, 44),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, 0, 32),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, 2, 33),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, -2, 34),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_8, 5),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, 0, 22),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, 4, 23),
+			BPF_ST_MEM(BPF_DW, BPF_REG_8, -7, 24),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_8),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_7, 0, 22),
+			BPF_ST_MEM(BPF_DW, BPF_REG_7, 4, 23),
+			BPF_ST_MEM(BPF_DW, BPF_REG_7, -4, 24),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
+	},
+	{
+		"map element value with unaligned load",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 11),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES, 9),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 3),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_0, 2),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_8, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_8, 2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 5),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_0, 4),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
+	},
+	{
+		"map element value illegal alu op, 1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 22),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "invalid mem access 'inv'",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value illegal alu op, 2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ALU32_IMM(BPF_ADD, BPF_REG_0, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 22),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "invalid mem access 'inv'",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value illegal alu op, 3",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ALU64_IMM(BPF_DIV, BPF_REG_0, 42),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 22),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "invalid mem access 'inv'",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value illegal alu op, 4",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ENDIAN(BPF_FROM_BE, BPF_REG_0, 64),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 22),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "invalid mem access 'inv'",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value illegal alu op, 5",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_MOV64_IMM(BPF_REG_3, 4096),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_0, 0),
+			BPF_STX_XADD(BPF_DW, BPF_REG_2, BPF_REG_3, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 22),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 invalid mem access 'inv'",
+		.errstr = "R0 invalid mem access 'inv'",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"map element value is preserved across register spilling",
 		.insns = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
@@ -4003,6 +4248,7 @@ struct test_val {
 		.errstr_unpriv = "R0 pointer arithmetic prohibited",
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"helper access to variable memory: stack, bitwise AND + JMP, correct bounds",
@@ -4441,6 +4687,7 @@ struct test_val {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
 	{
 		"invalid range check",
@@ -4472,6 +4719,7 @@ struct test_val {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	}
 };
 
@@ -4550,11 +4798,11 @@ static void do_test_fixup(struct bpf_test *test, struct bpf_insn *prog,
 static void do_test_single(struct bpf_test *test, bool unpriv,
 			   int *passes, int *errors)
 {
+	int fd_prog, expected_ret, reject_from_alignment;
 	struct bpf_insn *prog = test->insns;
 	int prog_len = probe_filter_length(prog);
 	int prog_type = test->prog_type;
 	int fd_f1 = -1, fd_f2 = -1, fd_f3 = -1;
-	int fd_prog, expected_ret;
 	const char *expected_err;
 
 	do_test_fixup(test, prog, &fd_f1, &fd_f2, &fd_f3);
@@ -4567,8 +4815,19 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 		       test->result_unpriv : test->result;
 	expected_err = unpriv && test->errstr_unpriv ?
 		       test->errstr_unpriv : test->errstr;
+
+	reject_from_alignment = fd_prog < 0 &&
+				(test->flags & F_NEEDS_EFFICIENT_UNALIGNED_ACCESS) &&
+				strstr(bpf_vlog, "Unknown alignment.");
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (reject_from_alignment) {
+		printf("FAIL\nFailed due to alignment despite having efficient unaligned access: '%s'!\n",
+		       strerror(errno));
+		goto fail_log;
+	}
+#endif
 	if (expected_ret == ACCEPT) {
-		if (fd_prog < 0) {
+		if (fd_prog < 0 && !reject_from_alignment) {
 			printf("FAIL\nFailed to load prog '%s'!\n",
 			       strerror(errno));
 			goto fail_log;
@@ -4578,14 +4837,15 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 			printf("FAIL\nUnexpected success to load!\n");
 			goto fail_log;
 		}
-		if (!strstr(bpf_vlog, expected_err)) {
+		if (!strstr(bpf_vlog, expected_err) && !reject_from_alignment) {
 			printf("FAIL\nUnexpected error message!\n");
 			goto fail_log;
 		}
 	}
 
 	(*passes)++;
-	printf("OK\n");
+	printf("OK%s\n", reject_from_alignment ?
+	       " (NOTE: reject due to unknown alignment)" : "");
 close_fds:
 	close(fd_prog);
 	close(fd_f1);
-- 
1.9.3
