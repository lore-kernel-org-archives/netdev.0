From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 24/29] bpf: verifier test
Date: Sun, 24 Aug 2014 13:21:25 -0700
Message-ID: <1408911690-7598-25-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

verifier testsuite from user space. Tests valid and invalid programs
and expects predefined error log messages from kernel.
42 tests so far.

$ sudo ./test_verifier
 #0 add+sub+mul OK
 #1 dropmon OK
 #2 dropmon with non-looping jump back OK
 #3 unreachable OK
 ...
 #40 access memory with incorrect alignment OK
 #41 sometimes access memory with incorrect alignment OK

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile        |    3 +-
 samples/bpf/test_verifier.c |  599 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 601 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/test_verifier.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 8dfbacaef9ba..7264ba51d496 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,9 +2,10 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := dropmon
+hostprogs-y := dropmon test_verifier
 
 dropmon-objs := dropmon.o libbpf.o
+test_verifier-objs := test_verifier.o libbpf.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
new file mode 100644
index 000000000000..aa70aa33d84c
--- /dev/null
+++ b/samples/bpf/test_verifier.c
@@ -0,0 +1,599 @@
+/*
+ * Testsuite for eBPF verifier
+ *
+ * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <linux/unistd.h>
+#include <string.h>
+#include <linux/filter.h>
+#include "libbpf.h"
+
+#define MAX_INSNS 512
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+
+struct bpf_test {
+	const char *descr;
+	struct bpf_insn	insns[MAX_INSNS];
+	int fixup[32];
+	const char *errstr;
+	enum {
+		ACCEPT,
+		REJECT
+	} result;
+};
+
+static struct bpf_test tests[] = {
+	{
+		"add+sub+mul",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 2),
+			BPF_MOV64_IMM(BPF_REG_2, 3),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -1),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_1, 3),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"dropmon",
+		.insns = {
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+			BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {4, 16},
+		.result = ACCEPT,
+	},
+	{
+		"dropmon with non-looping jump back",
+		.insns = {
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, 8), /* r2 = *(u64 *)(r1 + 8) */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -8), /* *(u64 *)(fp - 8) = r2 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+			BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, 1), /* *(u64 *)(fp - 16) = 1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, -16), /* r3 = fp - 16 */
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8), /* r2 = fp - 8 */
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -10),
+		},
+		.fixup = {4, 16},
+		.result = ACCEPT,
+	},
+	{
+		"unreachable",
+		.insns = {
+			BPF_EXIT_INSN(),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"unreachable2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"out of range jump",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"out of range jump2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"test1 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.result = REJECT,
+	},
+	{
+		"test2 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.result = REJECT,
+	},
+	{
+		"test3 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test4 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test5 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"no bpf_exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"loop (back-edge)",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"loop2 (back-edge)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"conditional loop",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, -3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"read uninitialized register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"read invalid register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"program doesn't init R0 before exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"stack out of bounds",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn1",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL | BPF_X, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn2",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid function call",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, 1234567),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid func 1234567",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {2},
+		.errstr = "invalid indirect read from stack",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid read from stack",
+		.result = REJECT,
+	},
+	{
+		"check valid spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+
+			/* fill it back into R2 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
+
+			/* should be able to access R0 = *(R2 + 8) */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check corrupted spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+
+			/* mess up with R1 pointer on stack */
+			BPF_ST_MEM(BPF_B, BPF_REG_10, -7, 0x23),
+
+			/* fill back into R0 should fail */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "corrupted spill",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, BPF_REG_10, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, 14, BPF_REG_10, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in ST",
+		.insns = {
+			BPF_ST_MEM(BPF_B, 14, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, 12, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R12 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, 11, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R11 is invalid",
+		.result = REJECT,
+	},
+	{
+		"junk insn",
+		.insns = {
+			BPF_RAW_INSN(0, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM",
+		.result = REJECT,
+	},
+	{
+		"junk insn2",
+		.insns = {
+			BPF_RAW_INSN(1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_LDX uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"junk insn3",
+		.insns = {
+			BPF_RAW_INSN(-1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn4",
+		.insns = {
+			BPF_RAW_INSN(-1, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn5",
+		.insns = {
+			BPF_RAW_INSN(0x7f, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_ALU uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"misaligned read from stack",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"invalid map_fd for function call",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "fd 0 is not pointing to valid bpf_map",
+		.result = REJECT,
+	},
+	{
+		"don't check return value before access",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access 'map_value_or_null'",
+		.result = REJECT,
+	},
+	{
+		"access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"sometimes access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access",
+		.result = REJECT,
+	},
+};
+
+static int probe_filter_length(struct bpf_insn *fp)
+{
+	int len = 0;
+
+	for (len = MAX_INSNS - 1; len > 0; --len)
+		if (fp[len].code != 0 || fp[len].imm != 0)
+			break;
+
+	return len + 1;
+}
+
+static int create_map(void)
+{
+	long long key, value = 0;
+	int map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 1024);
+	if (map_fd < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+	}
+
+	return map_fd;
+}
+
+static int test(void)
+{
+	int prog_fd, i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		struct bpf_insn *prog = tests[i].insns;
+		int prog_len = probe_filter_length(prog);
+		int *fixup = tests[i].fixup;
+		int map_fd = -1;
+
+		if (*fixup) {
+
+			map_fd = create_map();
+
+			do {
+				prog[*fixup].imm = map_fd;
+				fixup++;
+			} while (*fixup);
+		}
+		printf("#%d %s ", i, tests[i].descr);
+
+		prog_fd = bpf_prog_load(BPF_PROG_TYPE_TRACING_FILTER, prog,
+					prog_len * sizeof(struct bpf_insn),
+					"GPL");
+
+		if (tests[i].result == ACCEPT) {
+			if (prog_fd < 0) {
+				printf("FAIL\nfailed to load prog '%s'\n",
+				       strerror(errno));
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+		} else {
+			if (prog_fd >= 0) {
+				printf("FAIL\nunexpected success to load\n");
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+			if (strstr(bpf_log_buf, tests[i].errstr) == 0) {
+				printf("FAIL\nunexpected error message: %s",
+				       bpf_log_buf);
+				goto fail;
+			}
+		}
+
+		printf("OK\n");
+fail:
+		if (map_fd >= 0)
+			close(map_fd);
+		close(prog_fd);
+
+	}
+
+	return 0;
+}
+
+int main(void)
+{
+	return test();
+}
-- 
1.7.9.5
