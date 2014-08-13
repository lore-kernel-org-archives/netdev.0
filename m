From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit immediate" eBPF instruction
Date: Wed, 13 Aug 2014 00:57:12 -0700
Message-ID: <1407916658-8731-2-git-send-email-ast@plumgrid.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add BPF_LD_IMM64 instruction to load 64-bit immediate value into register.
All previous instructions were 8-byte. This is first 16-byte instruction.
Two consecutive 'struct bpf_insn' blocks are interpreted as single instruction:
insn[0/1].code = BPF_LD | BPF_DW | BPF_IMM
insn[0/1].dst_reg = destination register
insn[0].imm = lower 32-bit
insn[1].imm = upper 32-bit

Classic BPF has similar instruction: BPF_LD | BPF_W | BPF_IMM
which loads 32-bit immediate value into a register.

x64 JITs it as single 'movabsq %rax, imm64'
arm64 may JIT as sequence of four 'movk x0, #imm16, lsl #shift' insn

Note that old eBPF programs are binary compatible with new interpreter.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |    8 +++++++-
 arch/x86/net/bpf_jit_comp.c         |    9 +++++++++
 include/linux/filter.h              |   11 +++++++++++
 kernel/bpf/core.c                   |    5 +++++
 lib/test_bpf.c                      |   22 ++++++++++++++++++++++
 5 files changed, 54 insertions(+), 1 deletion(-)

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
index 5c8cb8043c5a..67b666aab20e 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -393,6 +393,15 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			EMIT1_off32(add_1reg(0xB8, dst_reg), imm32);
 			break;
 
+		case BPF_LD | BPF_IMM | BPF_DW:
+			/* movabsq %rax, imm64 */
+			EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
+			EMIT(insn->imm, 4);
+			insn++;
+			i++;
+			EMIT(insn->imm, 4);
+			break;
+
 			/* dst %= src, dst /= src, dst %= imm32, dst /= imm32 */
 		case BPF_ALU | BPF_MOD | BPF_X:
 		case BPF_ALU | BPF_DIV | BPF_X:
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a5227ab8ccb1..73a6d505e729 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -161,6 +161,17 @@ enum {
 		.off   = 0,					\
 		.imm   = IMM })
 
+/* use two of BPF_LD_IMM64 to encode single move 64-bit insn
+ * first macro to carry lower 32-bits and second for higher 32-bits
+ */
+#define BPF_LD_IMM64(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
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
index 89e0345733bd..d59444262dc0 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1697,6 +1697,28 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 1, 0 } },
 	},
+	{
+		"load 64-bit immediate",
+		.u.insns_int = {
+			BPF_LD_IMM64(R1, 0x1234), /* lower 32-bit */
+			BPF_LD_IMM64(R1, 0x5678), /* higher 32-bit */
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
