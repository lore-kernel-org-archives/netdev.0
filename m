From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v10 net-next 1/2] net: filter: add "load 64-bit immediate" eBPF instruction
Date: Thu,  4 Sep 2014 22:17:17 -0700
Message-ID: <1409894238-9055-2-git-send-email-ast@plumgrid.com>
References: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409894238-9055-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

It helps eBPF programs load 64-bit constant into a register with one
instruction instead of using two registers and 4 instructions:
BPF_MOV32_IMM(R1, imm32)
BPF_ALU64_IMM(BPF_LSH, R1, 32)
BPF_MOV32_IMM(R2, imm32)
BPF_ALU64_REG(BPF_OR, R1, R2)

User space generated programs will use this instruction to load constants only.

To tell kernel that user space needs a pointer the _pseudo_ variant of
this instruction may be added later, which will use extra bits of encoding
to indicate what type of pointer user space is asking kernel to provide.
For example 'off' or 'src_reg' fields can be used for such purpose.
src_reg = 1 could mean that user space is asking kernel to validate and
load in-kernel map pointer.
src_reg = 2 could mean that user space needs readonly data section pointer
src_reg = 3 could mean that user space needs a pointer to per-cpu local data
All such future pseudo instructions will not be carrying the actual pointer
as part of the instruction, but rather will be treated as a request to kernel
to provide one. The kernel will verify the request_for_a_pointer, then
will drop _pseudo_ marking and will store actual internal pointer inside
the instruction, so the end result is the interpreter and JITs never
see pseudo BPF_LD_IMM64 insns and only operate on generic BPF_LD_IMM64 that
loads 64-bit immediate into a register. User space never operates on direct
pointers and verifier can easily recognize request_for_pointer vs other
instructions.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
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
index 39ccfbb4a723..06f8c17f5484 100644
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
index c78994593355..bf323da77950 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -166,6 +166,24 @@ enum {
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
index b54bb2c2e494..2c2bfaacce66 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -242,6 +242,7 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 		[BPF_LD | BPF_IND | BPF_W] = &&LD_IND_W,
 		[BPF_LD | BPF_IND | BPF_H] = &&LD_IND_H,
 		[BPF_LD | BPF_IND | BPF_B] = &&LD_IND_B,
+		[BPF_LD | BPF_IMM | BPF_DW] = &&LD_IMM_DW,
 	};
 	void *ptr;
 	int off;
@@ -301,6 +302,10 @@ select_insn:
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
index 9a67456ba29a..413890815d3e 100644
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
