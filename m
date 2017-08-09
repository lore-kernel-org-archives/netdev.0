From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Thu, 10 Aug 2017 01:39:55 +0200
Message-ID: <bca86d84962539b66b21ec705d6d054e7ea1d6d5.1502320623.git.daniel@iogearbox.net>
References: <cover.1502320623.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35679 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752225AbdHIXkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:40:14 -0400
In-Reply-To: <cover.1502320623.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502320623.git.daniel@iogearbox.net>
References: <cover.1502320623.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, eBPF only understands BPF_JGT (>), BPF_JGE (>=),
BPF_JSGT (s>), BPF_JSGE (s>=) instructions, this means that
particularly *JLT/*JLE counterparts involving immediates need
to be rewritten from e.g. X < [IMM] by swapping arguments into
[IMM] > X, meaning the immediate first is required to be loaded
into a register Y := [IMM], such that then we can compare with
Y > X. Note that the destination operand is always required to
be a register.

This has the downside of having unnecessarily increased register
pressure, meaning complex program would need to spill other
registers temporarily to stack in order to obtain an unused
register for the [IMM]. Loading to registers will thus also
affect state pruning since we need to account for that register
use and potentially those registers that had to be spilled/filled
again. As a consequence slightly more stack space might have
been used due to spilling, and BPF programs are a bit longer
due to extra code involving the register load and potentially
required spill/fills.

Thus, add BPF_JLT (<), BPF_JLE (<=), BPF_JSLT (s<), BPF_JSLE (s<=)
counterparts to the eBPF instruction set. Modifying LLVM to
remove the NegateCC() workaround in a PoC patch at [1] and
allowing it to also emit the new instructions resulted in
cilium's BPF programs that are injected into the fast-path to
have a reduced program length in the range of 2-3% (e.g.
accumulated main and tail call sections from one of the object
file reduced from 4864 to 4729 insns), reduced complexity in
the range of 10-30% (e.g. accumulated sections reduced in one
of the cases from 116432 to 88428 insns), and reduced stack
usage in the range of 1-5% (e.g. accumulated sections from one
of the object files reduced from 824 to 784b).

The modification for LLVM will be incorporated in a backwards
compatible way. Plan is for LLVM to have i) a target specific
option to offer a possibility to explicitly enable the extension
by the user (as we have with -m target specific extensions today
for various CPU insns), and ii) have the kernel checked for
presence of the extensions and enable them transparently when
the user is selecting more aggressive options such as -march=native
in a bpf target context. (Other frontends generating BPF byte
code, e.g. ply can probe the kernel directly for its code
generation.)

  [1] https://github.com/borkmann/llvm/tree/bpf-insns

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Documentation/networking/filter.txt |   4 +
 include/uapi/linux/bpf.h            |   5 +
 kernel/bpf/core.c                   |  60 ++++++
 lib/test_bpf.c                      | 364 ++++++++++++++++++++++++++++++++++++
 net/core/filter.c                   |  21 ++-
 tools/include/uapi/linux/bpf.h      |   5 +
 6 files changed, 455 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index d0fdba7..6a0df8d 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -906,6 +906,10 @@ If BPF_CLASS(code) == BPF_JMP, BPF_OP(code) is one of:
   BPF_JSGE  0x70  /* eBPF only: signed '>=' */
   BPF_CALL  0x80  /* eBPF only: function call */
   BPF_EXIT  0x90  /* eBPF only: function return */
+  BPF_JLT   0xa0  /* eBPF only: unsigned '<' */
+  BPF_JLE   0xb0  /* eBPF only: unsigned '<=' */
+  BPF_JSLT  0xc0  /* eBPF only: signed '<' */
+  BPF_JSLE  0xd0  /* eBPF only: signed '<=' */
 
 So BPF_ADD | BPF_X | BPF_ALU means 32-bit addition in both classic BPF
 and eBPF. There are only two registers in classic BPF, so it means A += X.
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1d06be1..91da837 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -30,9 +30,14 @@
 #define BPF_FROM_LE	BPF_TO_LE
 #define BPF_FROM_BE	BPF_TO_BE
 
+/* jmp encodings */
 #define BPF_JNE		0x50	/* jump != */
+#define BPF_JLT		0xa0	/* LT is unsigned, '<' */
+#define BPF_JLE		0xb0	/* LE is unsigned, '<=' */
 #define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
 #define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
+#define BPF_JSLT	0xc0	/* SLT is signed, '<' */
+#define BPF_JSLE	0xd0	/* SLE is signed, '<=' */
 #define BPF_CALL	0x80	/* function call */
 #define BPF_EXIT	0x90	/* function return */
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index ad5f559..c69e7f5 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -595,9 +595,13 @@ static int bpf_jit_blind_insn(const struct bpf_insn *from,
 	case BPF_JMP | BPF_JEQ  | BPF_K:
 	case BPF_JMP | BPF_JNE  | BPF_K:
 	case BPF_JMP | BPF_JGT  | BPF_K:
+	case BPF_JMP | BPF_JLT  | BPF_K:
 	case BPF_JMP | BPF_JGE  | BPF_K:
+	case BPF_JMP | BPF_JLE  | BPF_K:
 	case BPF_JMP | BPF_JSGT | BPF_K:
+	case BPF_JMP | BPF_JSLT | BPF_K:
 	case BPF_JMP | BPF_JSGE | BPF_K:
+	case BPF_JMP | BPF_JSLE | BPF_K:
 	case BPF_JMP | BPF_JSET | BPF_K:
 		/* Accommodate for extra offset in case of a backjump. */
 		off = from->off;
@@ -833,12 +837,20 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 		[BPF_JMP | BPF_JNE | BPF_K] = &&JMP_JNE_K,
 		[BPF_JMP | BPF_JGT | BPF_X] = &&JMP_JGT_X,
 		[BPF_JMP | BPF_JGT | BPF_K] = &&JMP_JGT_K,
+		[BPF_JMP | BPF_JLT | BPF_X] = &&JMP_JLT_X,
+		[BPF_JMP | BPF_JLT | BPF_K] = &&JMP_JLT_K,
 		[BPF_JMP | BPF_JGE | BPF_X] = &&JMP_JGE_X,
 		[BPF_JMP | BPF_JGE | BPF_K] = &&JMP_JGE_K,
+		[BPF_JMP | BPF_JLE | BPF_X] = &&JMP_JLE_X,
+		[BPF_JMP | BPF_JLE | BPF_K] = &&JMP_JLE_K,
 		[BPF_JMP | BPF_JSGT | BPF_X] = &&JMP_JSGT_X,
 		[BPF_JMP | BPF_JSGT | BPF_K] = &&JMP_JSGT_K,
+		[BPF_JMP | BPF_JSLT | BPF_X] = &&JMP_JSLT_X,
+		[BPF_JMP | BPF_JSLT | BPF_K] = &&JMP_JSLT_K,
 		[BPF_JMP | BPF_JSGE | BPF_X] = &&JMP_JSGE_X,
 		[BPF_JMP | BPF_JSGE | BPF_K] = &&JMP_JSGE_K,
+		[BPF_JMP | BPF_JSLE | BPF_X] = &&JMP_JSLE_X,
+		[BPF_JMP | BPF_JSLE | BPF_K] = &&JMP_JSLE_K,
 		[BPF_JMP | BPF_JSET | BPF_X] = &&JMP_JSET_X,
 		[BPF_JMP | BPF_JSET | BPF_K] = &&JMP_JSET_K,
 		/* Program return */
@@ -1073,6 +1085,18 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 			CONT_JMP;
 		}
 		CONT;
+	JMP_JLT_X:
+		if (DST < SRC) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
+	JMP_JLT_K:
+		if (DST < IMM) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
 	JMP_JGE_X:
 		if (DST >= SRC) {
 			insn += insn->off;
@@ -1085,6 +1109,18 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 			CONT_JMP;
 		}
 		CONT;
+	JMP_JLE_X:
+		if (DST <= SRC) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
+	JMP_JLE_K:
+		if (DST <= IMM) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
 	JMP_JSGT_X:
 		if (((s64) DST) > ((s64) SRC)) {
 			insn += insn->off;
@@ -1097,6 +1133,18 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 			CONT_JMP;
 		}
 		CONT;
+	JMP_JSLT_X:
+		if (((s64) DST) < ((s64) SRC)) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
+	JMP_JSLT_K:
+		if (((s64) DST) < ((s64) IMM)) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
 	JMP_JSGE_X:
 		if (((s64) DST) >= ((s64) SRC)) {
 			insn += insn->off;
@@ -1109,6 +1157,18 @@ static unsigned int ___bpf_prog_run(u64 *regs, const struct bpf_insn *insn,
 			CONT_JMP;
 		}
 		CONT;
+	JMP_JSLE_X:
+		if (((s64) DST) <= ((s64) SRC)) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
+	JMP_JSLE_K:
+		if (((s64) DST) <= ((s64) IMM)) {
+			insn += insn->off;
+			CONT_JMP;
+		}
+		CONT;
 	JMP_JSET_X:
 		if (DST & SRC) {
 			insn += insn->off;
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index d9d5a41..aa8812a 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -952,6 +952,32 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ { 2, 0 }, { 3, 1 }, { 4, MAX_K } },
 	},
 	{
+		"JGE (jt 0), test 1",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_LEN, 0),
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 2),
+			BPF_JUMP(BPF_JMP | BPF_JGE | BPF_X, 0, 0, 1),
+			BPF_STMT(BPF_RET | BPF_K, 1),
+			BPF_STMT(BPF_RET | BPF_K, MAX_K)
+		},
+		CLASSIC,
+		{ 4, 4, 4, 3, 3 },
+		{ { 2, 0 }, { 3, 1 }, { 4, 1 } },
+	},
+	{
+		"JGE (jt 0), test 2",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_LEN, 0),
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 2),
+			BPF_JUMP(BPF_JMP | BPF_JGE | BPF_X, 0, 0, 1),
+			BPF_STMT(BPF_RET | BPF_K, 1),
+			BPF_STMT(BPF_RET | BPF_K, MAX_K)
+		},
+		CLASSIC,
+		{ 4, 4, 5, 3, 3 },
+		{ { 4, 1 }, { 5, 1 }, { 6, MAX_K } },
+	},
+	{
 		"JGE",
 		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
@@ -4492,6 +4518,35 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JSLT | BPF_K */
+	{
+		"JMP_JSLT_K: Signed jump: if (-2 < -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xfffffffffffffffeLL),
+			BPF_JMP_IMM(BPF_JSLT, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLT_K: Signed jump: if (-1 < -1) return 0",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSLT, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JSGT | BPF_K */
 	{
 		"JMP_JSGT_K: Signed jump: if (-1 > -2) return 1",
@@ -4521,6 +4576,73 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JSLE | BPF_K */
+	{
+		"JMP_JSLE_K: Signed jump: if (-2 <= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xfffffffffffffffeLL),
+			BPF_JMP_IMM(BPF_JSLE, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLE_K: Signed jump: if (-1 <= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 0xffffffffffffffffLL),
+			BPF_JMP_IMM(BPF_JSLE, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLE_K: Signed jump: value walk 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 6),
+			BPF_ALU64_IMM(BPF_SUB, R1, 1),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 4),
+			BPF_ALU64_IMM(BPF_SUB, R1, 1),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 2),
+			BPF_ALU64_IMM(BPF_SUB, R1, 1),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 1),
+			BPF_EXIT_INSN(),		/* bad exit */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),	/* good exit */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLE_K: Signed jump: value walk 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 4),
+			BPF_ALU64_IMM(BPF_SUB, R1, 2),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 2),
+			BPF_ALU64_IMM(BPF_SUB, R1, 2),
+			BPF_JMP_IMM(BPF_JSLE, R1, 0, 1),
+			BPF_EXIT_INSN(),		/* bad exit */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),	/* good exit */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JSGE | BPF_K */
 	{
 		"JMP_JSGE_K: Signed jump: if (-1 >= -2) return 1",
@@ -4617,6 +4739,35 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JLT | BPF_K */
+	{
+		"JMP_JLT_K: if (2 < 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 2),
+			BPF_JMP_IMM(BPF_JLT, R1, 3, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JGT_K: Unsigned jump: if (1 < -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 1),
+			BPF_JMP_IMM(BPF_JLT, R1, -1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JGE | BPF_K */
 	{
 		"JMP_JGE_K: if (3 >= 2) return 1",
@@ -4632,6 +4783,21 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JLE | BPF_K */
+	{
+		"JMP_JLE_K: if (2 <= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 2),
+			BPF_JMP_IMM(BPF_JLE, R1, 3, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JGT | BPF_K jump backwards */
 	{
 		"JMP_JGT_K: if (3 > 2) return 1 (jump backwards)",
@@ -4662,6 +4828,36 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JLT | BPF_K jump backwards */
+	{
+		"JMP_JGT_K: if (2 < 3) return 1 (jump backwards)",
+		.u.insns_int = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2), /* goto start */
+			BPF_ALU32_IMM(BPF_MOV, R0, 1), /* out: */
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0), /* start: */
+			BPF_LD_IMM64(R1, 2), /* note: this takes 2 insns */
+			BPF_JMP_IMM(BPF_JLT, R1, 3, -6), /* goto out */
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JLE_K: if (3 <= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_JMP_IMM(BPF_JLE, R1, 3, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JNE | BPF_K */
 	{
 		"JMP_JNE_K: if (3 != 2) return 1",
@@ -4752,6 +4948,37 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JSLT | BPF_X */
+	{
+		"JMP_JSLT_X: Signed jump: if (-2 < -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -2),
+			BPF_JMP_REG(BPF_JSLT, R2, R1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLT_X: Signed jump: if (-1 < -1) return 0",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -1),
+			BPF_JMP_REG(BPF_JSLT, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JSGE | BPF_X */
 	{
 		"JMP_JSGE_X: Signed jump: if (-1 >= -2) return 1",
@@ -4783,6 +5010,37 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JSLE | BPF_X */
+	{
+		"JMP_JSLE_X: Signed jump: if (-2 <= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -2),
+			BPF_JMP_REG(BPF_JSLE, R2, R1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JSLE_X: Signed jump: if (-1 <= -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, -1),
+			BPF_JMP_REG(BPF_JSLE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JGT | BPF_X */
 	{
 		"JMP_JGT_X: if (3 > 2) return 1",
@@ -4814,6 +5072,37 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JLT | BPF_X */
+	{
+		"JMP_JLT_X: if (2 < 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JLT, R2, R1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JLT_X: Unsigned jump: if (1 < -1) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, -1),
+			BPF_LD_IMM64(R2, 1),
+			BPF_JMP_REG(BPF_JLT, R2, R1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JGE | BPF_X */
 	{
 		"JMP_JGE_X: if (3 >= 2) return 1",
@@ -4845,6 +5134,37 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	/* BPF_JMP | BPF_JLE | BPF_X */
+	{
+		"JMP_JLE_X: if (2 <= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JLE, R2, R1, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
+		"JMP_JLE_X: if (3 <= 3) return 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 3),
+			BPF_JMP_REG(BPF_JLE, R1, R2, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	{
 		/* Mainly testing JIT + imm64 here. */
 		"JMP_JGE_X: ldimm64 test 1",
@@ -4890,6 +5210,50 @@ static int bpf_fill_stxdw(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	{
+		"JMP_JLE_X: ldimm64 test 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JLE, R2, R1, 2),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeULL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xeeeeeeeeU } },
+	},
+	{
+		"JMP_JLE_X: ldimm64 test 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JLE, R2, R1, 0),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffffU } },
+	},
+	{
+		"JMP_JLE_X: ldimm64 test 3",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JLE, R2, R1, 4),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeULL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JNE | BPF_X */
 	{
 		"JMP_JNE_X: if (3 != 2) return 1",
diff --git a/net/core/filter.c b/net/core/filter.c
index 78d0093..5afe3ac 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -514,14 +514,27 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 				break;
 			}
 
-			/* Convert JEQ into JNE when 'jump_true' is next insn. */
-			if (fp->jt == 0 && BPF_OP(fp->code) == BPF_JEQ) {
-				insn->code = BPF_JMP | BPF_JNE | bpf_src;
+			/* Convert some jumps when 'jump_true' is next insn. */
+			if (fp->jt == 0) {
+				switch (BPF_OP(fp->code)) {
+				case BPF_JEQ:
+					insn->code = BPF_JMP | BPF_JNE | bpf_src;
+					break;
+				case BPF_JGT:
+					insn->code = BPF_JMP | BPF_JLE | bpf_src;
+					break;
+				case BPF_JGE:
+					insn->code = BPF_JMP | BPF_JLT | bpf_src;
+					break;
+				default:
+					goto jmp_rest;
+				}
+
 				target = i + fp->jf + 1;
 				BPF_EMIT_JMP;
 				break;
 			}
-
+jmp_rest:
 			/* Other jumps are mapped into two insns: Jxx and JA. */
 			target = i + fp->jt + 1;
 			insn->code = BPF_JMP | BPF_OP(fp->code) | bpf_src;
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 8d9bfcc..bf3b2e2 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -30,9 +30,14 @@
 #define BPF_FROM_LE	BPF_TO_LE
 #define BPF_FROM_BE	BPF_TO_BE
 
+/* jmp encodings */
 #define BPF_JNE		0x50	/* jump != */
+#define BPF_JLT		0xa0	/* LT is unsigned, '<' */
+#define BPF_JLE		0xb0	/* LE is unsigned, '<=' */
 #define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
 #define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
+#define BPF_JSLT	0xc0	/* SLT is signed, '<' */
+#define BPF_JSLE	0xd0	/* SLE is signed, '<=' */
 #define BPF_CALL	0x80	/* function call */
 #define BPF_EXIT	0x90	/* function return */
 
-- 
1.9.3
