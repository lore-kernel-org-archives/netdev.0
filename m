From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 02/29] net: filter: add "load 64-bit immediate" eBPF instruction
Date: Sun, 24 Aug 2014 13:21:03 -0700
Message-ID: <1408911690-7598-3-git-send-email-ast@plumgrid.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:38201 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbaHXUVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 16:21:46 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so19255069pab.34
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 13:21:45 -0700 (PDT)
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add BPF_LD_IMM64 instruction to load 64-bit immediate value into a register.
All previous instructions were 8-byte. This is first 16-byte instruction.
Two consecutive 'struct bpf_insn' blocks are interpreted as single instruction:
insn[0].code = BPF_LD | BPF_DW | BPF_IMM
insn[0].dst_reg = destination register
insn[0].imm = lower 32-bit
insn[1].code = 0
insn[1].imm = upper 32-bit
All unused fields must be zero.

Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM
which loads 32-bit immediate value into a register.

x64 JITs it as single 'movabsq %rax, imm64'
arm64 may JIT as sequence of four 'movk x0, #imm16, lsl #shift' insn

Note that old eBPF programs are binary compatible with new interpreter.

In the following patches this instruction is used to store eBPF map pointers:
 BPF_LD_IMM64(R1, const_imm_map_ptr)
 BPF_CALL(BPF_FUNC_map_lookup_elem)
and verifier is introduced to check validity of the programs.

Later LLVM compiler is using this insn as generic load of 64-bit immediate
constant and as a load of map pointer with relocation.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |    8 +++++++-
 arch/x86/net/bpf_jit_comp.c         |   17 +++++++++++++++++
 include/linux/filter.h              |   18 ++++++++++++++++++
 kernel/bpf/core.c                   |    5 +++++
 lib/test_bpf.c                      |   21 +++++++++++++++++++++
 5 files changed, 68 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index c48a9704bda8..81916ab5d96f 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -951,7 +951,7 @@ Size modifier is one of ...
 
 Mode modifier is one of:
 
-  BPF_IMM  0x00  /* classic BPF only, reserved in eBPF */
+  BPF_IMM  0x00  /* used for 32-bit mov in classic BPF and 64-bit in eBPF */
   BPF_ABS  0x20
   BPF_IND  0x40
   BPF_MEM  0x60
@@ -995,6 +995,12 @@ BPF_XADD | BPF_DW | BPF_STX: lock xadd *(u64 *)(dst_reg + off16) += src_reg
 Where size is one of: BPF_B or BPF_H or BPF_W or BPF_DW. Note that 1 and
 2 byte atomic increments are not supported.
 
+eBPF has one 16-byte instruction: BPF_LD | BPF_DW | BPF_IMM which consists
+of two consecutive 'struct bpf_insn' 8-byte blocks and interpreted as single
+instruction that loads 64-bit immediate value into a dst_reg.
+Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM which loads
+32-bit immediate value into a register.
+
 Testing
 -------
 
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index b08a98c59530..98837147ee57 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -393,6 +393,23 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			EMIT1_off32(add_1reg(0xB8, dst_reg), imm32);
 			break;
 
+		case BPF_LD | BPF_IMM | BPF_DW:
+			if (insn[1].code != 0 || insn[1].src_reg != 0 ||
+			    insn[1].dst_reg != 0 || insn[1].off != 0) {
+				/* verifier must catch invalid insns */
+				pr_err("invalid BPF_LD_IMM64 insn\n");
+				return -EINVAL;
+			}
+
+			/* movabsq %rax, imm64 */
+			EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
+			EMIT(insn[0].imm, 4);
+			EMIT(insn[1].imm, 4);
+
+			insn++;
+			i++;
+			break;
+
 			/* dst %= src, dst /= src, dst %= imm32, dst /= imm32 */
 		case BPF_ALU | BPF_MOD | BPF_X:
 		case BPF_ALU | BPF_DIV | BPF_X:
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a5227ab8ccb1..f3262b598262 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -161,6 +161,24 @@ enum {
 		.off   = 0,					\
 		.imm   = IMM })
 
+/* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
+#define BPF_LD_IMM64(DST, IMM)					\
+	BPF_LD_IMM64_RAW(DST, 0, IMM)
+
+#define BPF_LD_IMM64_RAW(DST, SRC, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = (__u32) (IMM) }),			\
+	((struct bpf_insn) {					\
+		.code  = 0, /* zero is reserved opcode */	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((__u64) (IMM)) >> 32 })
+
 /* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
 
 #define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 7f0dbcbb34af..0434c2170f2b 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -180,6 +180,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		[BPF_LD | BPF_IND | BPF_W] = &&LD_IND_W,
 		[BPF_LD | BPF_IND | BPF_H] = &&LD_IND_H,
 		[BPF_LD | BPF_IND | BPF_B] = &&LD_IND_B,
+		[BPF_LD | BPF_IMM | BPF_DW] = &&LD_IMM_DW,
 	};
 	void *ptr;
 	int off;
@@ -239,6 +240,10 @@ select_insn:
 	ALU64_MOV_K:
 		DST = IMM;
 		CONT;
+	LD_IMM_DW:
+		DST = (u64) (u32) insn[0].imm | ((u64) (u32) insn[1].imm) << 32;
+		insn++;
+		CONT;
 	ALU64_ARSH_X:
 		(*(s64 *) &DST) >>= SRC;
 		CONT;
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 8c66c6aace04..46ab1a7ef135 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1735,6 +1735,27 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 1, 0 } },
 	},
+	{
+		"load 64-bit immediate",
+		.u.insns_int = {
+			BPF_LD_IMM64(R1, 0x567800001234L),
+			BPF_MOV64_REG(R2, R1),
+			BPF_MOV64_REG(R3, R2),
+			BPF_ALU64_IMM(BPF_RSH, R2, 32),
+			BPF_ALU64_IMM(BPF_LSH, R3, 32),
+			BPF_ALU64_IMM(BPF_RSH, R3, 32),
+			BPF_ALU64_IMM(BPF_MOV, R0, 0),
+			BPF_JMP_IMM(BPF_JEQ, R2, 0x5678, 1),
+			BPF_EXIT_INSN(),
+			BPF_JMP_IMM(BPF_JEQ, R3, 0x1234, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU64_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } }
+	},
 };
 
 static struct net_device dev;
-- 
1.7.9.5
