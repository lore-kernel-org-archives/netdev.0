From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [RFC PATCH v2 net-next 1/2] extended BPF
Date: Mon, 16 Sep 2013 19:48:38 -0700
Message-ID: <1379386119-4157-2-git-send-email-ast@plumgrid.com>
References: <1379386119-4157-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Xi Wang <xi.wang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1379386119-4157-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

extended BPF program = BPF insns + BPF tables

flexible instruction set:
- from two 32-bit registers (A and X) to ten 64-bit regs
- add conditional jump back, signed compare, bswap
- in addition to old load[1,2,4,8] bytes, add store[1,2,4,8] bytes
- fixed set of function calls via simple ABI:
  R0 - return register
  R1-R5 - argument passing
  R6-R9 - callee saved
  R10 - frame pointer
- bpf_table_lookup/bpf_table_update functions to access BPF tables
- generic 'struct bpf_context' = input/output argument to BPF program

BPF table is defined by
- type, id, number of elements, key size, element size

To use generic BPF engine other kernel components will define:
- the body of 'bpf_context' and access permission
- available function calls: their prototypes for BPF checker,
  body for BPF interpreter and JIT

BPF programs can be written in restricted C
GCC backend for BPF is available

BPF checker does full program validation before it is JITed or
run in interpreter

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 arch/x86/net/Makefile        |    2 +-
 arch/x86/net/bpf2_jit_comp.c |  610 ++++++++++++++++++++++++
 arch/x86/net/bpf_jit_comp.c  |   41 +-
 arch/x86/net/bpf_jit_comp.h  |   36 ++
 include/linux/filter.h       |   79 ++++
 include/uapi/linux/filter.h  |  125 ++++-
 net/core/Makefile            |    2 +-
 net/core/bpf_check.c         | 1043 ++++++++++++++++++++++++++++++++++++++++++
 net/core/bpf_run.c           |  412 +++++++++++++++++
 9 files changed, 2315 insertions(+), 35 deletions(-)
 create mode 100644 arch/x86/net/bpf2_jit_comp.c
 create mode 100644 arch/x86/net/bpf_jit_comp.h
 create mode 100644 net/core/bpf_check.c
 create mode 100644 net/core/bpf_run.c

diff --git a/arch/x86/net/Makefile b/arch/x86/net/Makefile
index 90568c3..54f57c9 100644
--- a/arch/x86/net/Makefile
+++ b/arch/x86/net/Makefile
@@ -1,4 +1,4 @@
 #
 # Arch-specific network modules
 #
-obj-$(CONFIG_BPF_JIT) += bpf_jit.o bpf_jit_comp.o
+obj-$(CONFIG_BPF_JIT) += bpf_jit.o bpf_jit_comp.o bpf2_jit_comp.o
diff --git a/arch/x86/net/bpf2_jit_comp.c b/arch/x86/net/bpf2_jit_comp.c
new file mode 100644
index 0000000..2558ed7
--- /dev/null
+++ b/arch/x86/net/bpf2_jit_comp.c
@@ -0,0 +1,610 @@
+/*
+ * Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/filter.h>
+#include <linux/moduleloader.h>
+#include "bpf_jit_comp.h"
+
+static inline u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
+{
+	if (len == 1)
+		*ptr = bytes;
+	else if (len == 2)
+		*(u16 *)ptr = bytes;
+	else
+		*(u32 *)ptr = bytes;
+	return ptr + len;
+}
+
+#define EMIT(bytes, len) (prog = emit_code(prog, (bytes), (len)))
+
+#define EMIT1(b1)		EMIT(b1, 1)
+#define EMIT2(b1, b2)		EMIT((b1) + ((b2) << 8), 2)
+#define EMIT3(b1, b2, b3)	EMIT((b1) + ((b2) << 8) + ((b3) << 16), 3)
+#define EMIT4(b1, b2, b3, b4)   EMIT((b1) + ((b2) << 8) + ((b3) << 16) + ((b4) << 24), 4)
+/* imm32 is sign extended by cpu */
+#define EMIT1_off32(b1, off) \
+	do {EMIT1(b1); EMIT(off, 4); } while (0)
+#define EMIT2_off32(b1, b2, off) \
+	do {EMIT2(b1, b2); EMIT(off, 4); } while (0)
+#define EMIT3_off32(b1, b2, b3, off) \
+	do {EMIT3(b1, b2, b3); EMIT(off, 4); } while (0)
+#define EMIT4_off32(b1, b2, b3, b4, off) \
+	do {EMIT4(b1, b2, b3, b4); EMIT(off, 4); } while (0)
+
+/* mov A, X */
+#define EMIT_mov(A, X) \
+	EMIT3(add_2mod(0x48, A, X), 0x89, add_2reg(0xC0, A, X))
+
+#define X86_JAE 0x73
+#define X86_JE  0x74
+#define X86_JNE 0x75
+#define X86_JA  0x77
+#define X86_JGE 0x7D
+#define X86_JG  0x7F
+
+static inline bool is_imm8(__s32 value)
+{
+	return value <= 127 && value >= -128;
+}
+
+static inline bool is_simm32(__s64 value)
+{
+	return value == (__s64)(__s32)value;
+}
+
+static int bpf_size_to_x86_bytes(int bpf_size)
+{
+	if (bpf_size == BPF_W)
+		return 4;
+	else if (bpf_size == BPF_H)
+		return 2;
+	else if (bpf_size == BPF_B)
+		return 1;
+	else if (bpf_size == BPF_DW)
+		return 4; /* imm32 */
+	else
+		return 0;
+}
+
+#define AUX_REG 32
+
+/* avoid x86-64 R12 which if used as base address in memory access
+ * always needs an extra byte for index */
+static const int reg2hex[] = {
+	[R0] = 0, /* rax */
+	[R1] = 7, /* rdi */
+	[R2] = 6, /* rsi */
+	[R3] = 2, /* rdx */
+	[R4] = 1, /* rcx */
+	[R5] = 0, /* r8 */
+	[R6] = 3, /* rbx callee saved */
+	[R7] = 5, /* r13 callee saved */
+	[R8] = 6, /* r14 callee saved */
+	[R9] = 7, /* r15 callee saved */
+	[__fp__] = 5, /* rbp readonly */
+	[AUX_REG] = 1, /* r9 temp register */
+};
+
+/* is_ereg() == true if r8 <= reg <= r15,
+ * rax,rcx,...,rbp don't need extra byte of encoding */
+static inline bool is_ereg(u32 reg)
+{
+	if (reg == R5 || (reg >= R7 && reg <= R9) || reg == AUX_REG)
+		return true;
+	else
+		return false;
+}
+
+static inline u8 add_1mod(u8 byte, u32 reg)
+{
+	if (is_ereg(reg))
+		byte |= 1;
+	return byte;
+}
+static inline u8 add_2mod(u8 byte, u32 r1, u32 r2)
+{
+	if (is_ereg(r1))
+		byte |= 1;
+	if (is_ereg(r2))
+		byte |= 4;
+	return byte;
+}
+
+static inline u8 add_1reg(u8 byte, u32 a_reg)
+{
+	return byte + reg2hex[a_reg];
+}
+static inline u8 add_2reg(u8 byte, u32 a_reg, u32 x_reg)
+{
+	return byte + reg2hex[a_reg] + (reg2hex[x_reg] << 3);
+}
+
+static u8 *select_bpf_func(struct bpf_program *prog, int id)
+{
+	if (id < 0 || id >= FUNC_bpf_max_id)
+		return NULL;
+	return prog->cb->jit_select_func(id);
+}
+
+static int do_jit(struct bpf_program *bpf_prog, int *addrs, u8 *image,
+		  int oldproglen)
+{
+	struct bpf_insn *insn = bpf_prog->insns;
+	int insn_cnt = bpf_prog->insn_cnt;
+	u8 temp[64];
+	int i;
+	int proglen = 0;
+	u8 *prog = temp;
+	int stacksize = 512;
+
+	EMIT1(0x55); /* push rbp */
+	EMIT3(0x48, 0x89, 0xE5); /* mov rbp,rsp */
+
+	/* sub rsp, stacksize */
+	EMIT3_off32(0x48, 0x81, 0xEC, stacksize);
+	/* mov qword ptr [rbp-X],rbx */
+	EMIT3_off32(0x48, 0x89, 0x9D, -stacksize);
+	/* mov qword ptr [rbp-X],r13 */
+	EMIT3_off32(0x4C, 0x89, 0xAD, -stacksize + 8);
+	/* mov qword ptr [rbp-X],r14 */
+	EMIT3_off32(0x4C, 0x89, 0xB5, -stacksize + 16);
+	/* mov qword ptr [rbp-X],r15 */
+	EMIT3_off32(0x4C, 0x89, 0xBD, -stacksize + 24);
+
+	for (i = 0; i < insn_cnt; i++, insn++) {
+		const __s32 K = insn->imm;
+		__u32 a_reg = insn->a_reg;
+		__u32 x_reg = insn->x_reg;
+		u8 b1 = 0, b2 = 0, b3 = 0;
+		u8 jmp_cond;
+		__s64 jmp_offset;
+		int ilen;
+		u8 *func;
+
+		switch (insn->code) {
+			/* ALU */
+		case BPF_ALU | BPF_ADD | BPF_X:
+		case BPF_ALU | BPF_SUB | BPF_X:
+		case BPF_ALU | BPF_AND | BPF_X:
+		case BPF_ALU | BPF_OR | BPF_X:
+		case BPF_ALU | BPF_XOR | BPF_X:
+			b1 = 0x48;
+			b3 = 0xC0;
+			switch (BPF_OP(insn->code)) {
+			case BPF_ADD: b2 = 0x01; break;
+			case BPF_SUB: b2 = 0x29; break;
+			case BPF_AND: b2 = 0x21; break;
+			case BPF_OR: b2 = 0x09; break;
+			case BPF_XOR: b2 = 0x31; break;
+			}
+			EMIT3(add_2mod(b1, a_reg, x_reg), b2,
+			      add_2reg(b3, a_reg, x_reg));
+			break;
+
+			/* mov A, X */
+		case BPF_ALU | BPF_MOV | BPF_X:
+			EMIT_mov(a_reg, x_reg);
+			break;
+
+			/* neg A */
+		case BPF_ALU | BPF_NEG | BPF_X:
+			EMIT3(add_1mod(0x48, a_reg), 0xF7,
+			      add_1reg(0xD8, a_reg));
+			break;
+
+		case BPF_ALU | BPF_ADD | BPF_K:
+		case BPF_ALU | BPF_SUB | BPF_K:
+		case BPF_ALU | BPF_AND | BPF_K:
+		case BPF_ALU | BPF_OR | BPF_K:
+			b1 = add_1mod(0x48, a_reg);
+
+			switch (BPF_OP(insn->code)) {
+			case BPF_ADD: b3 = 0xC0; break;
+			case BPF_SUB: b3 = 0xE8; break;
+			case BPF_AND: b3 = 0xE0; break;
+			case BPF_OR: b3 = 0xC8; break;
+			}
+
+			if (is_imm8(K))
+				EMIT4(b1, 0x83, add_1reg(b3, a_reg), K);
+			else
+				EMIT3_off32(b1, 0x81, add_1reg(b3, a_reg), K);
+			break;
+
+		case BPF_ALU | BPF_MOV | BPF_K:
+			/* 'mov rax, imm32' sign extends imm32.
+			 * possible optimization: if imm32 is positive,
+			 * use 'mov eax, imm32' (which zero-extends imm32)
+			 * to save 2 bytes */
+			b1 = add_1mod(0x48, a_reg);
+			b2 = 0xC7;
+			b3 = 0xC0;
+			EMIT3_off32(b1, b2, add_1reg(b3, a_reg), K);
+			break;
+
+			/* A %= X
+			 * A /= X */
+		case BPF_ALU | BPF_MOD | BPF_X:
+		case BPF_ALU | BPF_DIV | BPF_X:
+			EMIT1(0x50); /* push rax */
+			EMIT1(0x52); /* push rdx */
+
+			/* mov r9, X */
+			EMIT_mov(AUX_REG, x_reg);
+
+			/* mov rax, A */
+			EMIT_mov(R0, a_reg);
+
+			/* xor rdx, rdx */
+			EMIT3(0x48, 0x31, 0xd2);
+
+			/* if X==0, skip divide, make A=0 */
+
+			/* cmp r9, 0 */
+			EMIT4(0x49, 0x83, 0xF9, 0x00);
+
+			/* je .+3 */
+			EMIT2(X86_JE, 3);
+
+			/* div r9 */
+			EMIT3(0x49, 0xF7, 0xF1);
+
+			if (BPF_OP(insn->code) == BPF_MOD) {
+				/* mov r9, rdx */
+				EMIT3(0x49, 0x89, 0xD1);
+			} else {
+				/* mov r9, rax */
+				EMIT3(0x49, 0x89, 0xC1);
+			}
+
+			EMIT1(0x5A); /* pop rdx */
+			EMIT1(0x58); /* pop rax */
+
+			/* mov A, r9 */
+			EMIT_mov(a_reg, AUX_REG);
+			break;
+
+			/* shifts */
+		case BPF_ALU | BPF_LSH | BPF_K:
+		case BPF_ALU | BPF_RSH | BPF_K:
+		case BPF_ALU | BPF_ARSH | BPF_K:
+			b1 = add_1mod(0x48, a_reg);
+			switch (BPF_OP(insn->code)) {
+			case BPF_LSH: b3 = 0xE0; break;
+			case BPF_RSH: b3 = 0xE8; break;
+			case BPF_ARSH: b3 = 0xF8; break;
+			}
+			EMIT4(b1, 0xC1, add_1reg(b3, a_reg), K);
+			break;
+
+		case BPF_ALU | BPF_BSWAP32 | BPF_X:
+			/* emit 'bswap eax' to swap lower 4-bytes */
+			if (is_ereg(a_reg))
+				EMIT2(0x41, 0x0F);
+			else
+				EMIT1(0x0F);
+			EMIT1(add_1reg(0xC8, a_reg));
+			break;
+
+		case BPF_ALU | BPF_BSWAP64 | BPF_X:
+			/* emit 'bswap rax' to swap 8-bytes */
+			EMIT3(add_1mod(0x48, a_reg), 0x0F, add_1reg(0xC8, a_reg));
+			break;
+
+			/* ST: *(u8*)(a_reg + off) = imm */
+		case BPF_ST | BPF_REL | BPF_B:
+			if (is_ereg(a_reg))
+				EMIT2(0x41, 0xC6);
+			else
+				EMIT1(0xC6);
+			goto st;
+		case BPF_ST | BPF_REL | BPF_H:
+			if (is_ereg(a_reg))
+				EMIT3(0x66, 0x41, 0xC7);
+			else
+				EMIT2(0x66, 0xC7);
+			goto st;
+		case BPF_ST | BPF_REL | BPF_W:
+			if (is_ereg(a_reg))
+				EMIT2(0x41, 0xC7);
+			else
+				EMIT1(0xC7);
+			goto st;
+		case BPF_ST | BPF_REL | BPF_DW:
+			EMIT2(add_1mod(0x48, a_reg), 0xC7);
+
+st:			if (is_imm8(insn->off))
+				EMIT2(add_1reg(0x40, a_reg), insn->off);
+			else
+				EMIT1_off32(add_1reg(0x80, a_reg), insn->off);
+
+			EMIT(K, bpf_size_to_x86_bytes(BPF_SIZE(insn->code)));
+			break;
+
+			/* STX: *(u8*)(a_reg + off) = x_reg */
+		case BPF_STX | BPF_REL | BPF_B:
+			/* emit 'mov byte ptr [rax + off], al' */
+			if (is_ereg(a_reg) || is_ereg(x_reg) ||
+			    /* have to add extra byte for x86 SIL, DIL regs */
+			    x_reg == R1 || x_reg == R2)
+				EMIT2(add_2mod(0x40, a_reg, x_reg), 0x88);
+			else
+				EMIT1(0x88);
+			goto stx;
+		case BPF_STX | BPF_REL | BPF_H:
+			if (is_ereg(a_reg) || is_ereg(x_reg))
+				EMIT3(0x66, add_2mod(0x40, a_reg, x_reg), 0x89);
+			else
+				EMIT2(0x66, 0x89);
+			goto stx;
+		case BPF_STX | BPF_REL | BPF_W:
+			if (is_ereg(a_reg) || is_ereg(x_reg))
+				EMIT2(add_2mod(0x40, a_reg, x_reg), 0x89);
+			else
+				EMIT1(0x89);
+			goto stx;
+		case BPF_STX | BPF_REL | BPF_DW:
+			EMIT2(add_2mod(0x48, a_reg, x_reg), 0x89);
+stx:			if (is_imm8(insn->off))
+				EMIT2(add_2reg(0x40, a_reg, x_reg), insn->off);
+			else
+				EMIT1_off32(add_2reg(0x80, a_reg, x_reg), insn->off);
+			break;
+
+			/* LDX: a_reg = *(u8*)(x_reg + off) */
+		case BPF_LDX | BPF_REL | BPF_B:
+			/* emit 'movzx rax, byte ptr [rax + off]' */
+			EMIT3(add_2mod(0x48, x_reg, a_reg), 0x0F, 0xB6);
+			goto ldx;
+		case BPF_LDX | BPF_REL | BPF_H:
+			/* emit 'movzx rax, word ptr [rax + off]' */
+			EMIT3(add_2mod(0x48, x_reg, a_reg), 0x0F, 0xB7);
+			goto ldx;
+		case BPF_LDX | BPF_REL | BPF_W:
+			/* emit 'mov eax, dword ptr [rax+0x14]' */
+			if (is_ereg(a_reg) || is_ereg(x_reg))
+				EMIT2(add_2mod(0x40, x_reg, a_reg), 0x8B);
+			else
+				EMIT1(0x8B);
+			goto ldx;
+		case BPF_LDX | BPF_REL | BPF_DW:
+			/* emit 'mov rax, qword ptr [rax+0x14]' */
+			EMIT2(add_2mod(0x48, x_reg, a_reg), 0x8B);
+ldx:			/* if insn->off == 0 we can save one extra byte, but
+			 * special case of x86 R13 which always needs an offset
+			 * is not worth the pain */
+			if (is_imm8(insn->off))
+				EMIT2(add_2reg(0x40, x_reg, a_reg), insn->off);
+			else
+				EMIT1_off32(add_2reg(0x80, x_reg, a_reg), insn->off);
+			break;
+
+			/* STX XADD: lock *(u8*)(a_reg + off) += x_reg */
+		case BPF_STX | BPF_XADD | BPF_B:
+			/* emit 'lock add byte ptr [rax + off], al' */
+			if (is_ereg(a_reg) || is_ereg(x_reg) ||
+			    /* have to add extra byte for x86 SIL, DIL regs */
+			    x_reg == R1 || x_reg == R2)
+				EMIT3(0xF0, add_2mod(0x40, a_reg, x_reg), 0x00);
+			else
+				EMIT2(0xF0, 0x00);
+			goto xadd;
+		case BPF_STX | BPF_XADD | BPF_H:
+			if (is_ereg(a_reg) || is_ereg(x_reg))
+				EMIT4(0x66, 0xF0, add_2mod(0x40, a_reg, x_reg), 0x01);
+			else
+				EMIT3(0x66, 0xF0, 0x01);
+			goto xadd;
+		case BPF_STX | BPF_XADD | BPF_W:
+			if (is_ereg(a_reg) || is_ereg(x_reg))
+				EMIT3(0xF0, add_2mod(0x40, a_reg, x_reg), 0x01);
+			else
+				EMIT2(0xF0, 0x01);
+			goto xadd;
+		case BPF_STX | BPF_XADD | BPF_DW:
+			EMIT3(0xF0, add_2mod(0x48, a_reg, x_reg), 0x01);
+xadd:			if (is_imm8(insn->off))
+				EMIT2(add_2reg(0x40, a_reg, x_reg), insn->off);
+			else
+				EMIT1_off32(add_2reg(0x80, a_reg, x_reg), insn->off);
+			break;
+
+			/* call */
+		case BPF_JMP | BPF_CALL:
+			func = select_bpf_func(bpf_prog, K);
+			jmp_offset = func - (image + addrs[i]);
+			if (!func || !is_simm32(jmp_offset)) {
+				pr_err("unsupported bpf func %d addr %p image %p\n",
+				       K, func, image);
+				return -EINVAL;
+			}
+			EMIT1_off32(0xE8, jmp_offset);
+			break;
+
+			/* cond jump */
+		case BPF_JMP | BPF_JEQ | BPF_X:
+		case BPF_JMP | BPF_JNE | BPF_X:
+		case BPF_JMP | BPF_JGT | BPF_X:
+		case BPF_JMP | BPF_JGE | BPF_X:
+		case BPF_JMP | BPF_JSGT | BPF_X:
+		case BPF_JMP | BPF_JSGE | BPF_X:
+			/* emit 'cmp a_reg, x_reg' insn */
+			b1 = 0x48;
+			b2 = 0x39;
+			b3 = 0xC0;
+			EMIT3(add_2mod(b1, a_reg, x_reg), b2,
+			      add_2reg(b3, a_reg, x_reg));
+			goto emit_jump;
+		case BPF_JMP | BPF_JEQ | BPF_K:
+		case BPF_JMP | BPF_JNE | BPF_K:
+		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JSGT | BPF_K:
+		case BPF_JMP | BPF_JSGE | BPF_K:
+			/* emit 'cmp a_reg, imm8/32' */
+			EMIT1(add_1mod(0x48, a_reg));
+
+			if (is_imm8(K))
+				EMIT3(0x83, add_1reg(0xF8, a_reg), K);
+			else
+				EMIT2_off32(0x81, add_1reg(0xF8, a_reg), K);
+
+emit_jump:		/* convert BPF opcode to x86 */
+			switch (BPF_OP(insn->code)) {
+			case BPF_JEQ:
+				jmp_cond = X86_JE;
+				break;
+			case BPF_JNE:
+				jmp_cond = X86_JNE;
+				break;
+			case BPF_JGT:
+				/* GT is unsigned '>', JA in x86 */
+				jmp_cond = X86_JA;
+				break;
+			case BPF_JGE:
+				/* GE is unsigned '>=', JAE in x86 */
+				jmp_cond = X86_JAE;
+				break;
+			case BPF_JSGT:
+				/* signed '>', GT in x86 */
+				jmp_cond = X86_JG;
+				break;
+			case BPF_JSGE:
+				/* signed '>=', GE in x86 */
+				jmp_cond = X86_JGE;
+				break;
+			default: /* to silence gcc warning */
+				return -EFAULT;
+			}
+			jmp_offset = addrs[i + insn->off] - addrs[i];
+			if (is_imm8(jmp_offset)) {
+				EMIT2(jmp_cond, jmp_offset);
+			} else if (is_simm32(jmp_offset)) {
+				EMIT2_off32(0x0F, jmp_cond + 0x10, jmp_offset);
+			} else {
+				pr_err("cond_jmp gen bug %llx\n", jmp_offset);
+				return -EFAULT;
+			}
+
+			break;
+
+		case BPF_JMP | BPF_JA | BPF_X:
+			jmp_offset = addrs[i + insn->off] - addrs[i];
+			if (is_imm8(jmp_offset)) {
+				EMIT2(0xEB, jmp_offset);
+			} else if (is_simm32(jmp_offset)) {
+				EMIT1_off32(0xE9, jmp_offset);
+			} else {
+				pr_err("jmp gen bug %llx\n", jmp_offset);
+				return -EFAULT;
+			}
+
+			break;
+
+		case BPF_RET | BPF_K:
+			/* mov rbx, qword ptr [rbp-X] */
+			EMIT3_off32(0x48, 0x8B, 0x9D, -stacksize);
+			/* mov r13, qword ptr [rbp-X] */
+			EMIT3_off32(0x4C, 0x8B, 0xAD, -stacksize + 8);
+			/* mov r14, qword ptr [rbp-X] */
+			EMIT3_off32(0x4C, 0x8B, 0xB5, -stacksize + 16);
+			/* mov r15, qword ptr [rbp-X] */
+			EMIT3_off32(0x4C, 0x8B, 0xBD, -stacksize + 24);
+
+			EMIT1(0xC9); /* leave */
+			EMIT1(0xC3); /* ret */
+			break;
+
+		default:
+			/*pr_debug_bpf_insn(insn, NULL);*/
+			pr_err("bpf_jit: unknown opcode %02x\n", insn->code);
+			return -EINVAL;
+		}
+
+		ilen = prog - temp;
+		if (image) {
+			if (proglen + ilen > oldproglen)
+				return -2;
+			memcpy(image + proglen, temp, ilen);
+		}
+		proglen += ilen;
+		addrs[i] = proglen;
+		prog = temp;
+	}
+	return proglen;
+}
+
+void bpf2_jit_compile(struct bpf_program *prog)
+{
+	struct bpf_binary_header *header = NULL;
+	int proglen, oldproglen = 0;
+	int *addrs;
+	u8 *image = NULL;
+	int pass;
+	int i;
+
+	if (!prog || !prog->cb || !prog->cb->jit_select_func)
+		return;
+
+	addrs = kmalloc(prog->insn_cnt * sizeof(*addrs), GFP_KERNEL);
+	if (!addrs)
+		return;
+
+	for (proglen = 0, i = 0; i < prog->insn_cnt; i++) {
+		proglen += 64;
+		addrs[i] = proglen;
+	}
+	for (pass = 0; pass < 10; pass++) {
+		proglen = do_jit(prog, addrs, image, oldproglen);
+		if (proglen <= 0) {
+			image = NULL;
+			goto out;
+		}
+		if (image) {
+			if (proglen != oldproglen)
+				pr_err("bpf_jit: proglen=%d != oldproglen=%d\n",
+				       proglen, oldproglen);
+			break;
+		}
+		if (proglen == oldproglen) {
+			header = bpf_alloc_binary(proglen, &image);
+			if (!header)
+				goto out;
+		}
+		oldproglen = proglen;
+	}
+
+	if (image) {
+		bpf_flush_icache(header, image + proglen);
+		set_memory_ro((unsigned long)header, header->pages);
+	}
+out:
+	kfree(addrs);
+	prog->jit_image = (void (*)(struct bpf_context *ctx))image;
+	return;
+}
+
+
+void bpf2_jit_free(struct bpf_program *prog)
+{
+	if (prog->jit_image)
+		bpf_free_binary(prog->jit_image);
+}
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 79c216a..37ebea8 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -13,6 +13,7 @@
 #include <linux/filter.h>
 #include <linux/if_vlan.h>
 #include <linux/random.h>
+#include "bpf_jit_comp.h"
 
 /*
  * Conventions :
@@ -112,16 +113,6 @@ do {								\
 #define SEEN_XREG    2 /* ebx is used */
 #define SEEN_MEM     4 /* use mem[] for temporary storage */
 
-static inline void bpf_flush_icache(void *start, void *end)
-{
-	mm_segment_t old_fs = get_fs();
-
-	set_fs(KERNEL_DS);
-	smp_wmb();
-	flush_icache_range((unsigned long)start, (unsigned long)end);
-	set_fs(old_fs);
-}
-
 #define CHOOSE_LOAD_FUNC(K, func) \
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
@@ -145,16 +136,8 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
-struct bpf_binary_header {
-	unsigned int	pages;
-	/* Note : for security reasons, bpf code will follow a randomly
-	 * sized amount of int3 instructions
-	 */
-	u8		image[];
-};
-
-static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
-						  u8 **image_ptr)
+struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
+					   u8 **image_ptr)
 {
 	unsigned int sz, hole;
 	struct bpf_binary_header *header;
@@ -772,13 +755,17 @@ out:
 	return;
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_free_binary(void *bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-		struct bpf_binary_header *header = (void *)addr;
+	unsigned long addr = (unsigned long)bpf_func & PAGE_MASK;
+	struct bpf_binary_header *header = (void *)addr;
 
-		set_memory_rw(addr, header->pages);
-		module_free(NULL, header);
-	}
+	set_memory_rw(addr, header->pages);
+	module_free(NULL, header);
+}
+
+void bpf_jit_free(struct sk_filter *fp)
+{
+	if (fp->bpf_func != sk_run_filter)
+		bpf_free_binary(fp->bpf_func);
 }
diff --git a/arch/x86/net/bpf_jit_comp.h b/arch/x86/net/bpf_jit_comp.h
new file mode 100644
index 0000000..7b70de6
--- /dev/null
+++ b/arch/x86/net/bpf_jit_comp.h
@@ -0,0 +1,36 @@
+/* bpf_jit_comp.h : BPF filter alloc/free routines
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#ifndef __BPF_JIT_COMP_H
+#define __BPF_JIT_COMP_H
+
+#include <linux/uaccess.h>
+#include <asm/cacheflush.h>
+
+struct bpf_binary_header {
+	unsigned int	pages;
+	/* Note : for security reasons, bpf code will follow a randomly
+	 * sized amount of int3 instructions
+	 */
+	u8		image[];
+};
+
+static inline void bpf_flush_icache(void *start, void *end)
+{
+	mm_segment_t old_fs = get_fs();
+
+	set_fs(KERNEL_DS);
+	smp_wmb();
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+	set_fs(old_fs);
+}
+
+extern struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
+						  u8 **image_ptr);
+extern void bpf_free_binary(void *image_ptr);
+
+#endif
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a6ac848..63b3277 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -48,6 +48,77 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
 
+/* type of value stored in a BPF register or
+ * passed into function as an argument or
+ * returned from the function */
+enum bpf_reg_type {
+	INVALID_PTR,  /* reg doesn't contain a valid pointer */
+	PTR_TO_CTX,   /* reg points to bpf_context */
+	PTR_TO_TABLE, /* reg points to table element */
+	PTR_TO_TABLE_CONDITIONAL, /* points to table element or NULL */
+	PTR_TO_STACK,     /* reg == frame_pointer */
+	PTR_TO_STACK_IMM, /* reg == frame_pointer + imm */
+	RET_INTEGER, /* function returns integer */
+	RET_VOID,    /* function returns void */
+	CONST_ARG    /* function expects integer constant argument */
+};
+
+/* BPF function prototype */
+struct bpf_func_proto {
+	enum bpf_reg_type ret_type;
+	enum bpf_reg_type arg1_type;
+	enum bpf_reg_type arg2_type;
+	enum bpf_reg_type arg3_type;
+	enum bpf_reg_type arg4_type;
+};
+
+/* struct bpf_context access type */
+enum bpf_access_type {
+	BPF_READ = 1,
+	BPF_WRITE = 2
+};
+
+struct bpf_context_access {
+	int size;
+	enum bpf_access_type type;
+};
+
+struct bpf_callbacks {
+	/* execute BPF func_id with given registers */
+	void (*execute_func)(int id, u64 *regs);
+
+	/* return address of func_id suitable to be called from JITed program */
+	void *(*jit_select_func)(int id);
+
+	/* return BPF function prototype for verification */
+	const struct bpf_func_proto* (*get_func_proto)(int id);
+
+	/* return expected bpf_context access size and permissions
+	 * for given byte offset within bpf_context */
+	const struct bpf_context_access *(*get_context_access)(int off);
+};
+
+struct bpf_program {
+	u16   insn_cnt;
+	u16   table_cnt;
+	struct bpf_insn *insns;
+	struct bpf_table *tables;
+	struct bpf_callbacks *cb;
+	void (*jit_image)(struct bpf_context *ctx);
+};
+/* load BPF program from user space, setup callback extensions
+ * and run through verifier */
+extern int bpf_load(struct bpf_image *image, struct bpf_callbacks *cb,
+		    struct bpf_program **prog);
+/* free BPF program */
+extern void bpf_free(struct bpf_program *prog);
+/* execture BPF program */
+extern void bpf_run(struct bpf_program *prog, struct bpf_context *ctx);
+/* verify correctness of BPF program */
+extern int bpf_check(struct bpf_program *prog);
+/* pr_debug one insn */
+extern void pr_debug_bpf_insn(struct bpf_insn *insn, u64 *regs);
+
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
@@ -55,6 +126,8 @@ extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
 
 extern void bpf_jit_compile(struct sk_filter *fp);
 extern void bpf_jit_free(struct sk_filter *fp);
+extern void bpf2_jit_compile(struct bpf_program *prog);
+extern void bpf2_jit_free(struct bpf_program *prog);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
@@ -73,6 +146,12 @@ static inline void bpf_jit_compile(struct sk_filter *fp)
 static inline void bpf_jit_free(struct sk_filter *fp)
 {
 }
+static inline void bpf2_jit_compile(struct bpf_program *prog)
+{
+}
+static inline void bpf2_jit_free(struct bpf_program *prog)
+{
+}
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
 #endif
 
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 8eb9cca..5783769 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -1,3 +1,4 @@
+/* extended BPF is Copyright (c) 2011-2013, PLUMgrid, http://plumgrid.com */
 /*
  * Linux Socket Filter Data Structures
  */
@@ -19,7 +20,7 @@
  *	Try and keep these values and structures similar to BSD, especially
  *	the BPF code definitions which need to match so you can share filters
  */
- 
+
 struct sock_filter {	/* Filter block */
 	__u16	code;   /* Actual filter code */
 	__u8	jt;	/* Jump true */
@@ -46,11 +47,88 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_RET         0x06
 #define         BPF_MISC        0x07
 
+struct bpf_insn {
+	__u8	code;    /* opcode */
+	__u8    a_reg:4; /* dest register*/
+	__u8    x_reg:4; /* source register */
+	__s16	off;     /* signed offset */
+	__s32	imm;     /* signed immediate constant */
+};
+
+struct bpf_table {
+	__u32   id;
+	__u32   type;
+	__u32   key_size;
+	__u32   elem_size;
+	__u32   max_entries;
+	__u32   param1;         /* meaning is table-dependent */
+};
+
+enum bfp_table_type {
+	BPF_TABLE_HASH = 1,
+};
+
+struct bpf_image {
+	/* version > 4096 to be binary compatible with original bpf */
+	__u16   version;
+	__u16   rsvd;
+	__u16   insn_cnt;
+	__u16   table_cnt;
+	struct bpf_insn __user  *insns;
+	struct bpf_table __user *tables;
+};
+
+/* pointer to bpf_context is the first and only argument to BPF program
+ * its definition is use-case specific */
+struct bpf_context;
+
+/* bpf_add|sub|...: a += x
+ *         bpf_mov: a = x
+ *       bpf_bswap: bswap a */
+#define BPF_INSN_ALU(op, a, x) \
+	(struct bpf_insn){BPF_ALU|BPF_OP(op)|BPF_X, a, x, 0, 0}
+
+/* bpf_add|sub|...: a += imm
+ *         bpf_mov: a = imm */
+#define BPF_INSN_ALU_IMM(op, a, imm) \
+	(struct bpf_insn){BPF_ALU|BPF_OP(op)|BPF_K, a, 0, 0, imm}
+
+/* a = *(uint *) (x + off) */
+#define BPF_INSN_LD(size, a, x, off) \
+	(struct bpf_insn){BPF_LDX|BPF_SIZE(size)|BPF_REL, a, x, off, 0}
+
+/* *(uint *) (a + off) = x */
+#define BPF_INSN_ST(size, a, off, x) \
+	(struct bpf_insn){BPF_STX|BPF_SIZE(size)|BPF_REL, a, x, off, 0}
+
+/* *(uint *) (a + off) = imm */
+#define BPF_INSN_ST_IMM(size, a, off, imm) \
+	(struct bpf_insn){BPF_ST|BPF_SIZE(size)|BPF_REL, a, 0, off, imm}
+
+/* lock *(uint *) (a + off) += x */
+#define BPF_INSN_XADD(size, a, off, x) \
+	(struct bpf_insn){BPF_STX|BPF_SIZE(size)|BPF_XADD, a, x, off, 0}
+
+/* if (a 'op' x) pc += off else fall through */
+#define BPF_INSN_JUMP(op, a, x, off) \
+	(struct bpf_insn){BPF_JMP|BPF_OP(op)|BPF_X, a, x, off, 0}
+
+/* if (a 'op' imm) pc += off else fall through */
+#define BPF_INSN_JUMP_IMM(op, a, imm, off) \
+	(struct bpf_insn){BPF_JMP|BPF_OP(op)|BPF_K, a, 0, off, imm}
+
+#define BPF_INSN_RET() \
+	(struct bpf_insn){BPF_RET|BPF_K, 0, 0, 0, 0}
+
+#define BPF_INSN_CALL(fn_code) \
+	(struct bpf_insn){BPF_JMP|BPF_CALL, 0, 0, 0, fn_code}
+
 /* ld/ldx fields */
 #define BPF_SIZE(code)  ((code) & 0x18)
 #define         BPF_W           0x00
 #define         BPF_H           0x08
 #define         BPF_B           0x10
+#define         BPF_DW          0x18
 #define BPF_MODE(code)  ((code) & 0xe0)
 #define         BPF_IMM         0x00
 #define         BPF_ABS         0x20
@@ -58,6 +136,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_MEM         0x60
 #define         BPF_LEN         0x80
 #define         BPF_MSH         0xa0
+#define         BPF_REL         0xc0
+#define         BPF_XADD        0xe0 /* exclusive add */
 
 /* alu/jmp fields */
 #define BPF_OP(code)    ((code) & 0xf0)
@@ -68,20 +148,54 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_OR          0x40
 #define         BPF_AND         0x50
 #define         BPF_LSH         0x60
-#define         BPF_RSH         0x70
+#define         BPF_RSH         0x70 /* logical shift right */
 #define         BPF_NEG         0x80
 #define		BPF_MOD		0x90
 #define		BPF_XOR		0xa0
+#define		BPF_MOV		0xb0 /* mov reg to reg */
+#define		BPF_ARSH	0xc0 /* sign extending arithmetic shift right */
+#define		BPF_BSWAP32	0xd0 /* swap lower 4 bytes of 64-bit register */
+#define		BPF_BSWAP64	0xe0 /* swap all 8 bytes of 64-bit register */
 
 #define         BPF_JA          0x00
-#define         BPF_JEQ         0x10
-#define         BPF_JGT         0x20
-#define         BPF_JGE         0x30
+#define         BPF_JEQ         0x10 /* jump == */
+#define         BPF_JGT         0x20 /* GT is unsigned '>', JA in x86 */
+#define         BPF_JGE         0x30 /* GE is unsigned '>=', JAE in x86 */
 #define         BPF_JSET        0x40
+#define         BPF_JNE         0x50 /* jump != */
+#define         BPF_JSGT        0x60 /* SGT is signed '>', GT in x86 */
+#define         BPF_JSGE        0x70 /* SGE is signed '>=', GE in x86 */
+#define         BPF_CALL        0x80 /* function call */
 #define BPF_SRC(code)   ((code) & 0x08)
 #define         BPF_K           0x00
 #define         BPF_X           0x08
 
+/* 64-bit registers */
+#define         R0              0
+#define         R1              1
+#define         R2              2
+#define         R3              3
+#define         R4              4
+#define         R5              5
+#define         R6              6
+#define         R7              7
+#define         R8              8
+#define         R9              9
+#define         __fp__          10
+
+/* all types of BPF programs support at least two functions:
+ * bpf_table_lookup() and bpf_table_update()
+ * contents of bpf_context are use-case specific
+ * BPF engine can be extended with additional functions */
+enum {
+	FUNC_bpf_table_lookup = 1,
+	FUNC_bpf_table_update = 2,
+	FUNC_bpf_max_id = 1024
+};
+void *bpf_table_lookup(struct bpf_context *ctx, int table_id, const void *key);
+int bpf_table_update(struct bpf_context *ctx, int table_id, const void *key,
+		     const void *leaf);
+
 /* ret - BPF_K and BPF_X also apply */
 #define BPF_RVAL(code)  ((code) & 0x18)
 #define         BPF_A           0x10
@@ -134,5 +248,4 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
-
 #endif /* _UAPI__LINUX_FILTER_H__ */
diff --git a/net/core/Makefile b/net/core/Makefile
index b33b996..f04e016 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o
+			sock_diag.o dev_ioctl.o bpf_run.o bpf_check.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/bpf_check.c b/net/core/bpf_check.c
new file mode 100644
index 0000000..bf2521e
--- /dev/null
+++ b/net/core/bpf_check.c
@@ -0,0 +1,1043 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/filter.h>
+
+/* bpf_check() is a static code analyzer that walks the BPF program
+ * instruction by instruction and updates register/stack state.
+ * All paths of conditional branches are analyzed until 'ret' insn.
+ *
+ * At the first pass depth-first-search verifies that the BPF program is a DAG.
+ * It rejects the following programs:
+ * - larger than 32K insns or 128 tables
+ * - if loop is present (detected via back-edge)
+ * - unreachable insns exist (shouldn't be a forest. program = one function)
+ * - more than one ret insn
+ * - ret insn is not a last insn
+ * - out of bounds or malformed jumps
+ * The second pass is all possible path descent from the 1st insn.
+ * Conditional branch target insns keep a link list of verifier states.
+ * If the state already visited, this path can be pruned.
+ * If it wasn't a DAG, such state prunning would be incorrect, since it would
+ * skip cycles. Since it's analyzing all pathes through the program,
+ * the length of the analysis is limited to 64k insn, which may be hit even
+ * if insn_cnt < 32k, but there are too many branches that change stack/regs.
+ * Number of 'branches to be analyzed' is limited to 8k
+ *
+ * All registers are 64-bit (even on 32-bit arch)
+ * R0 - return register
+ * R1-R5 argument passing registers
+ * R6-R9 callee saved registers
+ * R10 - frame pointer read-only
+ *
+ * At the start of BPF program the register R1 contains a pointer to bpf_context
+ * and has type PTR_TO_CTX.
+ *
+ * bpf_table_lookup() function returns ether pointer to table value or NULL
+ * which is type PTR_TO_TABLE_CONDITIONAL. Once it passes through !=0 insn
+ * the register holding that pointer in the true branch changes state to
+ * PTR_TO_TABLE and the same register changes state to INVALID_PTR in the false
+ * branch. See check_cond_jmp_op()
+ *
+ * R10 has type PTR_TO_STACK. The sequence 'mov Rx, R10; add Rx, imm' changes
+ * Rx state to PTR_TO_STACK_IMM and immediate constant is saved for further
+ * stack bounds checking
+ *
+ * registers used to pass pointers to function calls are verified against
+ * function prototypes
+ * Ex: before the call to bpf_table_lookup(), R1 must have type PTR_TO_CTX
+ * R2 must contain integer constant and R3 PTR_TO_STACK_IMM
+ * Integer constant in R2 is a table_id. It's checked that 0 <= R2 < table_cnt
+ * and corresponding table_info->key_size fetched to check that
+ * [R3, R3 + table_info->key_size) are within stack limits and all that stack
+ * memory was initiliazed earlier by BPF program.
+ * After bpf_table_lookup() call insn, R0 is set to PTR_TO_TABLE_CONDITIONAL
+ * R1-R5 are cleared and no longer readable (but still writeable).
+ *
+ * load/store alignment is checked
+ * Ex: stx [Rx + 3], (u32)Ry is rejected
+ *
+ * load/store to stack bounds checked and register spill is tracked
+ * Ex: stx [R10 + 0], (u8)Rx is rejected
+ *
+ * load/store to table bounds checked and table_id provides table size
+ * Ex: stx [Rx + 8], (u16)Ry is ok, if Rx is PTR_TO_TABLE and
+ * 8 + sizeof(u16) <= table_info->elem_size
+ *
+ * load/store to bpf_context checked against known fields
+ *
+ * Future improvements:
+ * stack size is hardcoded to 512 bytes maximum per program, relax it
+ */
+#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })
+
+/* JITed code allocates 512 bytes and used bottom 4 slots
+ * to save R6-R9
+ */
+#define MAX_BPF_STACK (512 - 4 * 8)
+
+struct reg_state {
+	enum bpf_reg_type ptr;
+	bool read_ok;
+	int imm;
+};
+
+#define MAX_REG 11
+
+enum bpf_stack_slot_type {
+	STACK_INVALID,    /* nothing was stored in this stack slot */
+	STACK_SPILL,      /* 1st byte of register spilled into stack */
+	STACK_SPILL_PART, /* other 7 bytes of register spill */
+	STACK_MISC	  /* BPF program wrote some data into this slot */
+};
+
+struct bpf_stack_slot {
+	enum bpf_stack_slot_type type;
+	enum bpf_reg_type ptr;
+	int imm;
+};
+
+/* state of the program:
+ * type of all registers and stack info
+ */
+struct verifier_state {
+	struct reg_state regs[MAX_REG];
+	struct bpf_stack_slot stack[MAX_BPF_STACK];
+};
+
+/* linked list of verifier states
+ * used to prune search
+ */
+struct verifier_state_list {
+	struct verifier_state state;
+	struct verifier_state_list *next;
+};
+
+/* verifier_state + insn_idx are pushed to stack
+ * when branch is encountered
+ */
+struct verifier_stack_elem {
+	struct verifier_state st;
+	int insn_idx; /* at insn 'insn_idx' the program state is 'st' */
+	struct verifier_stack_elem *next;
+};
+
+/* single container for all structs
+ * one verifier_env per bpf_check() call
+ */
+struct verifier_env {
+	struct bpf_table *tables;
+	int table_cnt;
+	struct verifier_stack_elem *head;
+	int stack_size;
+	struct verifier_state cur_state;
+	struct verifier_state_list **branch_landing;
+	const struct bpf_func_proto* (*get_func_proto)(int id);
+	const struct bpf_context_access *(*get_context_access)(int off);
+};
+
+static int pop_stack(struct verifier_env *env)
+{
+	int insn_idx;
+	struct verifier_stack_elem *elem;
+	if (env->head == NULL)
+		return -1;
+	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
+	insn_idx = env->head->insn_idx;
+	elem = env->head->next;
+	kfree(env->head);
+	env->head = elem;
+	env->stack_size--;
+	return insn_idx;
+}
+
+static struct verifier_state *push_stack(struct verifier_env *env, int insn_idx)
+{
+	struct verifier_stack_elem *elem;
+	elem = kmalloc(sizeof(struct verifier_stack_elem), GFP_KERNEL);
+	memcpy(&elem->st, &env->cur_state, sizeof(env->cur_state));
+	elem->insn_idx = insn_idx;
+	elem->next = env->head;
+	env->head = elem;
+	env->stack_size++;
+	if (env->stack_size > 8192) {
+		pr_err("BPF program is too complex\n");
+		/* pop all elements and return */
+		while (pop_stack(env) >= 0);
+		return NULL;
+	}
+	return &elem->st;
+}
+
+#define CALLER_SAVED_REGS 6
+static const int caller_saved[CALLER_SAVED_REGS] = { R0, R1, R2, R3, R4, R5 };
+
+static void init_reg_state(struct reg_state *regs)
+{
+	struct reg_state *reg;
+	int i;
+	for (i = 0; i < MAX_REG; i++) {
+		regs[i].ptr = INVALID_PTR;
+		regs[i].read_ok = false;
+		regs[i].imm = 0xbadbad;
+	}
+	reg = regs + __fp__;
+	reg->ptr = PTR_TO_STACK;
+	reg->read_ok = true;
+
+	reg = regs + R1;	/* 1st arg to a function */
+	reg->ptr = PTR_TO_CTX;
+	reg->read_ok = true;
+}
+
+static void mark_reg_no_ptr(struct reg_state *regs, int regno)
+{
+	regs[regno].ptr = INVALID_PTR;
+	regs[regno].imm = 0xbadbad;
+	regs[regno].read_ok = true;
+}
+
+static int check_reg_arg(struct reg_state *regs, int regno, bool is_src)
+{
+	if (is_src) {
+		if (!regs[regno].read_ok) {
+			pr_err("R%d !read_ok\n", regno);
+			return -EACCES;
+		}
+	} else {
+		if (regno == __fp__)
+			/* frame pointer is read only */
+			return -EACCES;
+		mark_reg_no_ptr(regs, regno);
+	}
+	return 0;
+}
+
+static int bpf_size_to_bytes(int bpf_size)
+{
+	if (bpf_size == BPF_W)
+		return 4;
+	else if (bpf_size == BPF_H)
+		return 2;
+	else if (bpf_size == BPF_B)
+		return 1;
+	else if (bpf_size == BPF_DW)
+		return 8;
+	else
+		return -EACCES;
+}
+
+static int check_stack_write(struct verifier_state *state, int off, int size,
+			     int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+	if (value_regno >= 0 &&
+	    (state->regs[value_regno].ptr == PTR_TO_TABLE ||
+	     state->regs[value_regno].ptr == PTR_TO_CTX)) {
+
+		/* register containing pointer is being spilled into stack */
+		if (size != 8) {
+			pr_err("invalid size of register spill\n");
+			return -EACCES;
+		}
+
+		slot = &state->stack[MAX_BPF_STACK + off];
+		slot->type = STACK_SPILL;
+		/* save register state */
+		slot->ptr = state->regs[value_regno].ptr;
+		slot->imm = state->regs[value_regno].imm;
+		for (i = 1; i < 8; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->type = STACK_SPILL_PART;
+		}
+	} else {
+
+		/* regular write of data into stack */
+		for (i = 0; i < size; i++) {
+			slot = &state->stack[MAX_BPF_STACK + off + i];
+			slot->type = STACK_MISC;
+		}
+	}
+	return 0;
+}
+
+static int check_stack_read(struct verifier_state *state, int off, int size,
+			    int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+
+	slot = &state->stack[MAX_BPF_STACK + off];
+
+	if (slot->type == STACK_SPILL) {
+		if (size != 8) {
+			pr_err("invalid size of register spill\n");
+			return -EACCES;
+		}
+		for (i = 1; i < 8; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].type !=
+			    STACK_SPILL_PART) {
+				pr_err("corrupted spill memory\n");
+				return -EACCES;
+			}
+		}
+
+		/* restore register state from stack */
+		state->regs[value_regno].ptr = slot->ptr;
+		state->regs[value_regno].imm = slot->imm;
+		state->regs[value_regno].read_ok = true;
+		return 0;
+	} else {
+		for (i = 0; i < size; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].type !=
+			    STACK_MISC) {
+				pr_err("invalid read from stack off %d+%d size %d\n",
+				       off, i, size);
+				return -EACCES;
+			}
+		}
+		/* have read misc data from the stack */
+		mark_reg_no_ptr(state->regs, value_regno);
+		return 0;
+	}
+}
+
+static int get_table_info(struct verifier_env *env, int table_id,
+			  struct bpf_table **table)
+{
+	/* if BPF program contains bpf_table_lookup(ctx, 1024, key)
+	 * the incorrect table_id will be caught here
+	 */
+	if (table_id < 0 || table_id >= env->table_cnt) {
+		pr_err("invalid access to table_id=%d max_tables=%d\n",
+		       table_id, env->table_cnt);
+		return -EACCES;
+	}
+	*table = &env->tables[table_id];
+	return 0;
+}
+
+/* check read/write into table element returned by bpf_table_lookup() */
+static int check_table_access(struct verifier_env *env, int regno, int off,
+			      int size)
+{
+	struct bpf_table *table;
+	int table_id = env->cur_state.regs[regno].imm;
+
+	_(get_table_info(env, table_id, &table));
+
+	if (off < 0 || off + size > table->elem_size) {
+		pr_err("invalid access to table_id=%d leaf_size=%d off=%d size=%d\n",
+		       table_id, table->elem_size, off, size);
+		return -EACCES;
+	}
+	return 0;
+}
+
+/* check access to 'struct bpf_context' fields */
+static int check_ctx_access(struct verifier_env *env, int off, int size,
+			    enum bpf_access_type t)
+{
+	const struct bpf_context_access *access;
+
+	if (off < 0 || off >= 32768/* struct bpf_context shouldn't be huge */)
+		goto error;
+
+	access = env->get_context_access(off);
+	if (!access)
+		goto error;
+
+	if (access->size == size && (access->type & t))
+		return 0;
+error:
+	pr_err("invalid bpf_context access off=%d size=%d\n", off, size);
+	return -EACCES;
+}
+
+static int check_mem_access(struct verifier_env *env, int regno, int off,
+			    int bpf_size, enum bpf_access_type t,
+			    int value_regno)
+{
+	struct verifier_state *state = &env->cur_state;
+	int size;
+	_(size = bpf_size_to_bytes(bpf_size));
+
+	if (off % size != 0) {
+		pr_err("misaligned access off %d size %d\n", off, size);
+		return -EACCES;
+	}
+
+	if (state->regs[regno].ptr == PTR_TO_TABLE) {
+		_(check_table_access(env, regno, off, size));
+		if (t == BPF_READ)
+			mark_reg_no_ptr(state->regs, value_regno);
+	} else if (state->regs[regno].ptr == PTR_TO_CTX) {
+		_(check_ctx_access(env, off, size, t));
+		if (t == BPF_READ)
+			mark_reg_no_ptr(state->regs, value_regno);
+	} else if (state->regs[regno].ptr == PTR_TO_STACK) {
+		if (off >= 0 || off < -MAX_BPF_STACK) {
+			pr_err("invalid stack off=%d size=%d\n", off, size);
+			return -EACCES;
+		}
+		if (t == BPF_WRITE)
+			_(check_stack_write(state, off, size, value_regno));
+		else
+			_(check_stack_read(state, off, size, value_regno));
+	} else {
+		pr_err("invalid mem access %d\n", state->regs[regno].ptr);
+		return -EACCES;
+	}
+	return 0;
+}
+
+static const struct bpf_func_proto funcs[] = {
+	[FUNC_bpf_table_lookup] = {PTR_TO_TABLE_CONDITIONAL, PTR_TO_CTX,
+				   CONST_ARG, PTR_TO_STACK_IMM},
+	[FUNC_bpf_table_update] = {RET_INTEGER, PTR_TO_CTX, CONST_ARG,
+				   PTR_TO_STACK_IMM, PTR_TO_STACK_IMM},
+};
+
+static int check_func_arg(struct reg_state *regs, int regno,
+			  enum bpf_reg_type expected_type, int *reg_values)
+{
+	struct reg_state *reg = regs + regno;
+	if (expected_type == INVALID_PTR)
+		return 0;
+
+	if (!reg->read_ok) {
+		pr_err("R%d !read_ok\n", regno);
+		return -EACCES;
+	}
+
+	if (reg->ptr != expected_type) {
+		pr_err("R%d ptr=%d expected=%d\n", regno, reg->ptr,
+		       expected_type);
+		return -EACCES;
+	} else if (expected_type == CONST_ARG) {
+		reg_values[regno] = reg->imm;
+	}
+
+	return 0;
+}
+
+/* when register 'regno' is passed into function that will read 'access_size'
+ * bytes from that pointer, make sure that it's within stack boundary
+ * and all elements of stack are initialized
+ */
+static int check_stack_boundary(struct verifier_state *state,
+				struct reg_state *regs, int regno,
+				int access_size)
+{
+	int off, i;
+
+	if (regs[regno].ptr != PTR_TO_STACK_IMM)
+		return -EACCES;
+
+	off = regs[regno].imm;
+	if (off >= 0 || off < -MAX_BPF_STACK || off + access_size > 0 ||
+	    access_size <= 0) {
+		pr_err("invalid stack ptr R%d off=%d access_size=%d\n",
+		       regno, off, access_size);
+		return -EACCES;
+	}
+
+	for (i = 0; i < access_size; i++) {
+		if (state->stack[MAX_BPF_STACK + off + i].type != STACK_MISC) {
+			pr_err("invalid indirect read from stack off %d+%d size %d\n",
+			       off, i, access_size);
+			return -EACCES;
+		}
+	}
+	return 0;
+}
+
+static int check_call(struct verifier_env *env, int func_id)
+{
+	int reg_values[MAX_REG] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
+	struct verifier_state *state = &env->cur_state;
+	const struct bpf_func_proto *fn = NULL;
+	struct reg_state *regs = state->regs;
+	struct reg_state *reg;
+	int i;
+
+	/* find function prototype */
+	if (func_id < 0 || func_id >= FUNC_bpf_max_id) {
+		pr_err("invalid func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	if (func_id == FUNC_bpf_table_lookup ||
+	    func_id == FUNC_bpf_table_update) {
+		fn = &funcs[func_id];
+	} else {
+		if (env->get_func_proto)
+			fn = env->get_func_proto(func_id);
+		if (!fn || (fn->ret_type != RET_INTEGER &&
+			    fn->ret_type != RET_VOID)) {
+			pr_err("unknown func %d\n", func_id);
+			return -EINVAL;
+		}
+	}
+
+	/* check args */
+	_(check_func_arg(regs, R1, fn->arg1_type, reg_values));
+	_(check_func_arg(regs, R2, fn->arg2_type, reg_values));
+	_(check_func_arg(regs, R3, fn->arg3_type, reg_values));
+	_(check_func_arg(regs, R4, fn->arg4_type, reg_values));
+
+	if (func_id == FUNC_bpf_table_lookup) {
+		struct bpf_table *table;
+		int table_id = reg_values[R2];
+
+		_(get_table_info(env, table_id, &table));
+
+		/* bpf_table_lookup(ctx, table_id, key) call: check that
+		 * [key, key + table_info->key_size) are within stack limits
+		 * and initialized
+		 */
+		_(check_stack_boundary(state, regs, R3, table->key_size));
+
+	} else if (func_id == FUNC_bpf_table_update) {
+		struct bpf_table *table;
+		int table_id = reg_values[R2];
+
+		_(get_table_info(env, table_id, &table));
+
+		/* bpf_table_update(ctx, table_id, key, value) check
+		 * that key and value are valid
+		 */
+		_(check_stack_boundary(state, regs, R3, table->key_size));
+		_(check_stack_boundary(state, regs, R4, table->elem_size));
+
+	} else if (fn->arg1_type == PTR_TO_STACK_IMM) {
+		/* bpf_xxx(buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R1, reg_values[R2]));
+
+	} else if (fn->arg2_type == PTR_TO_STACK_IMM) {
+		/* bpf_yyy(arg1, buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R2, reg_values[R3]));
+
+	} else if (fn->arg3_type == PTR_TO_STACK_IMM) {
+		/* bpf_zzz(arg1, arg2, buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R3, reg_values[R4]));
+	}
+
+	/* reset caller saved regs */
+	for (i = 0; i < CALLER_SAVED_REGS; i++) {
+		reg = regs + caller_saved[i];
+		reg->read_ok = false;
+		reg->ptr = INVALID_PTR;
+		reg->imm = 0xbadbad;
+	}
+
+	/* update return register */
+	reg = regs + R0;
+	if (fn->ret_type == RET_INTEGER) {
+		reg->read_ok = true;
+		reg->ptr = INVALID_PTR;
+	} else if (fn->ret_type != RET_VOID) {
+		reg->read_ok = true;
+		reg->ptr = fn->ret_type;
+		if (func_id == FUNC_bpf_table_lookup)
+			/* when ret_type == PTR_TO_TABLE_CONDITIONAL
+			 * remember table_id, so that check_table_access()
+			 * can check 'elem_size' boundary of memory access
+			 * to table element returned from bpf_table_lookup()
+			 */
+			reg->imm = reg_values[R2];
+	}
+	return 0;
+}
+
+static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
+{
+	u16 opcode = BPF_OP(insn->code);
+
+	if (opcode == BPF_BSWAP32 || opcode == BPF_BSWAP64 ||
+	    opcode == BPF_NEG) {
+		if (BPF_SRC(insn->code) != BPF_X)
+			return -EINVAL;
+		/* check src operand */
+		_(check_reg_arg(regs, insn->a_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+	} else if (opcode == BPF_MOV) {
+
+		if (BPF_SRC(insn->code) == BPF_X)
+			/* check src operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+		if (BPF_SRC(insn->code) == BPF_X) {
+			/* case: R1 = R2
+			 * copy register state to dest reg
+			 */
+			regs[insn->a_reg].ptr = regs[insn->x_reg].ptr;
+			regs[insn->a_reg].imm = regs[insn->x_reg].imm;
+		} else {
+			/* case: R = imm
+			 * remember the value we stored into this reg
+			 */
+			regs[insn->a_reg].ptr = CONST_ARG;
+			regs[insn->a_reg].imm = insn->imm;
+		}
+
+	} else {	/* all other ALU ops: and, sub, xor, add, ... */
+
+		int stack_relative = 0;
+
+		if (BPF_SRC(insn->code) == BPF_X)
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+
+		/* check src2 operand */
+		_(check_reg_arg(regs, insn->a_reg, 1));
+
+		if (opcode == BPF_ADD &&
+		    regs[insn->a_reg].ptr == PTR_TO_STACK &&
+		    BPF_SRC(insn->code) == BPF_K)
+			stack_relative = 1;
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+		if (stack_relative) {
+			regs[insn->a_reg].ptr = PTR_TO_STACK_IMM;
+			regs[insn->a_reg].imm = insn->imm;
+		}
+	}
+
+	return 0;
+}
+
+static int check_cond_jmp_op(struct verifier_env *env, struct bpf_insn *insn,
+			     int insn_idx)
+{
+	struct reg_state *regs = env->cur_state.regs;
+	struct verifier_state *other_branch;
+	u16 opcode = BPF_OP(insn->code);
+
+	if (BPF_SRC(insn->code) == BPF_X)
+		/* check src1 operand */
+		_(check_reg_arg(regs, insn->x_reg, 1));
+
+	/* check src2 operand */
+	_(check_reg_arg(regs, insn->a_reg, 1));
+
+	other_branch = push_stack(env, insn_idx + insn->off + 1);
+	if (!other_branch)
+		return -EFAULT;
+
+	/* detect if R == 0 where R is returned value from table_lookup() */
+	if (BPF_SRC(insn->code) == BPF_K &&
+	    insn->imm == 0 && (opcode == BPF_JEQ ||
+			       opcode == BPF_JNE) &&
+	    regs[insn->a_reg].ptr == PTR_TO_TABLE_CONDITIONAL) {
+		if (opcode == BPF_JEQ) {
+			/* next fallthrough insn can access memory via
+			 * this register
+			 */
+			regs[insn->a_reg].ptr = PTR_TO_TABLE;
+			/* branch targer cannot access it, since reg == 0 */
+			other_branch->regs[insn->a_reg].ptr = INVALID_PTR;
+		} else {
+			other_branch->regs[insn->a_reg].ptr = PTR_TO_TABLE;
+			regs[insn->a_reg].ptr = INVALID_PTR;
+		}
+	}
+	return 0;
+}
+
+
+/* non-recursive DFS pseudo code
+ * 1  procedure DFS-iterative(G,v):
+ * 2      label v as discovered
+ * 3      let S be a stack
+ * 4      S.push(v)
+ * 5      while S is not empty
+ * 6            t <- S.pop()
+ * 7            if t is what we're looking for:
+ * 8                return t
+ * 9            for all edges e in G.adjacentEdges(t) do
+ * 10               if edge e is already labelled
+ * 11                   continue with the next edge
+ * 12               w <- G.adjacentVertex(t,e)
+ * 13               if vertex w is not discovered and not explored
+ * 14                   label e as tree-edge
+ * 15                   label w as discovered
+ * 16                   S.push(w)
+ * 17                   continue at 5
+ * 18               else if vertex w is discovered
+ * 19                   label e as back-edge
+ * 20               else
+ * 21                   // vertex w is explored
+ * 22                   label e as forward- or cross-edge
+ * 23           label t as explored
+ * 24           S.pop()
+ *
+ * convention:
+ * 1 - discovered
+ * 2 - discovered and 1st branch labelled
+ * 3 - discovered and 1st and 2nd branch labelled
+ * 4 - explored
+ */
+
+#define STATE_END ((struct verifier_state_list *)-1)
+
+#define PUSH_INT(I) \
+	do { \
+		if (cur_stack >= insn_cnt) { \
+			ret = -E2BIG; \
+			goto free_st; \
+		} \
+		stack[cur_stack++] = I; \
+	} while (0)
+
+#define PEAK_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[cur_stack - 1]; \
+		_ret; \
+	 })
+
+#define POP_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack == 0) \
+			_ret = -1; \
+		else \
+			_ret = stack[--cur_stack]; \
+		_ret; \
+	 })
+
+#define PUSH_INSN(T, W, E) \
+	do { \
+		int w = W; \
+		if (E == 1 && st[T] >= 2) \
+			break; \
+		if (E == 2 && st[T] >= 3) \
+			break; \
+		if (w >= insn_cnt) { \
+			ret = -EACCES; \
+			goto free_st; \
+		} \
+		if (E == 2) \
+			/* mark branch target for state pruning */ \
+			env->branch_landing[w] = STATE_END; \
+		if (st[w] == 0) { \
+			/* tree-edge */ \
+			st[T] = 1 + E; \
+			st[w] = 1; /* discovered */ \
+			PUSH_INT(w); \
+			goto peak_stack; \
+		} else if (st[w] == 1 || st[w] == 2 || st[w] == 3) { \
+			pr_err("back-edge from insn %d to %d\n", t, w); \
+			ret = -EINVAL; \
+			goto free_st; \
+		} else if (st[w] == 4) { \
+			/* forward- or cross-edge */ \
+			st[T] = 1 + E; \
+		} else { \
+			pr_err("insn state internal bug\n"); \
+			ret = -EFAULT; \
+			goto free_st; \
+		} \
+	} while (0)
+
+/* non-recursive depth-first-search to detect loops in BPF program
+ * loop == back-edge in directed graph
+ */
+static int check_cfg(struct verifier_env *env, struct bpf_insn *insns,
+		     int insn_cnt)
+{
+	int cur_stack = 0;
+	int *stack;
+	int ret = 0;
+	int *st;
+	int i, t;
+
+	if (insns[insn_cnt - 1].code != (BPF_RET | BPF_K)) {
+		pr_err("last insn is not a 'ret'\n");
+		return -EINVAL;
+	}
+
+	st = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!st)
+		return -ENOMEM;
+
+	stack = kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!stack) {
+		kfree(st);
+		return -ENOMEM;
+	}
+
+	st[0] = 1; /* mark 1st insn as discovered */
+	PUSH_INT(0);
+
+peak_stack:
+	while ((t = PEAK_INT()) != -1) {
+		if (t == insn_cnt - 1)
+			goto mark_explored;
+
+		if (BPF_CLASS(insns[t].code) == BPF_RET) {
+			pr_err("extraneous 'ret'\n");
+			ret = -EINVAL;
+			goto free_st;
+		}
+
+		if (BPF_CLASS(insns[t].code) == BPF_JMP) {
+			u16 opcode = BPF_OP(insns[t].code);
+			if (opcode == BPF_CALL) {
+				PUSH_INSN(t, t + 1, 1);
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insns[t].code) != BPF_X) {
+					ret = -EINVAL;
+					goto free_st;
+				}
+				PUSH_INSN(t, t + insns[t].off + 1, 1);
+			} else {
+				PUSH_INSN(t, t + 1, 1);
+				PUSH_INSN(t, t + insns[t].off + 1, 2);
+			}
+		} else {
+			PUSH_INSN(t, t + 1, 1);
+		}
+
+mark_explored:
+		st[t] = 4; /* explored */
+		if (POP_INT() == -1) {
+			pr_err("pop_int internal bug\n");
+			ret = -EFAULT;
+			goto free_st;
+		}
+	}
+
+
+	for (i = 0; i < insn_cnt; i++) {
+		if (st[i] != 4) {
+			pr_err("unreachable insn %d\n", i);
+			ret = -EINVAL;
+			goto free_st;
+		}
+	}
+
+free_st:
+	kfree(st);
+	kfree(stack);
+	return ret;
+}
+
+static int is_state_visited(struct verifier_env *env, int insn_idx)
+{
+	struct verifier_state_list *sl;
+	struct verifier_state_list *new_sl;
+	sl = env->branch_landing[insn_idx];
+	if (!sl)
+		/* no branch jump to this insn, ignore it */
+		return 0;
+
+	while (sl != STATE_END) {
+		if (memcmp(&sl->state, &env->cur_state,
+			   sizeof(env->cur_state)) == 0)
+			/* reached the same register/stack state,
+			 * prune the search
+			 */
+			return 1;
+		sl = sl->next;
+	}
+	new_sl = kmalloc(sizeof(struct verifier_state_list), GFP_KERNEL);
+
+	if (!new_sl)
+		/* ignore kmalloc error, since it's rare and doesn't affect
+		 * correctness of algorithm
+		 */
+		return 0;
+	/* add new state to the head of linked list */
+	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	new_sl->next = env->branch_landing[insn_idx];
+	env->branch_landing[insn_idx] = new_sl;
+	return 0;
+}
+
+static int __bpf_check(struct verifier_env *env, struct bpf_insn *insns,
+		       int insn_cnt)
+{
+	int insn_idx;
+	int insn_processed = 0;
+	struct verifier_state *state = &env->cur_state;
+	struct reg_state *regs = state->regs;
+
+	init_reg_state(regs);
+	insn_idx = 0;
+	for (;;) {
+		struct bpf_insn *insn;
+		u16 class;
+
+		if (insn_idx >= insn_cnt) {
+			pr_err("invalid insn idx %d insn_cnt %d\n",
+			       insn_idx, insn_cnt);
+			return -EFAULT;
+		}
+
+		insn = &insns[insn_idx];
+		class = BPF_CLASS(insn->code);
+
+		if (++insn_processed > 65536) {
+			pr_err("BPF program is too large. Proccessed %d insn\n",
+			       insn_processed);
+			return -E2BIG;
+		}
+
+		/* pr_debug_bpf_insn(insn, NULL); */
+
+		if (is_state_visited(env, insn_idx))
+			goto process_ret;
+
+		if (class == BPF_ALU) {
+			_(check_alu_op(regs, insn));
+
+		} else if (class == BPF_LDX) {
+			if (BPF_MODE(insn->code) != BPF_REL)
+				return -EINVAL;
+
+			/* check src operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+
+			_(check_mem_access(env, insn->x_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_READ,
+					   insn->a_reg));
+
+			/* dest reg state will be updated by mem_access */
+
+		} else if (class == BPF_STX) {
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+			/* check src2 operand */
+			_(check_reg_arg(regs, insn->a_reg, 1));
+			_(check_mem_access(env, insn->a_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   insn->x_reg));
+
+		} else if (class == BPF_ST) {
+			if (BPF_MODE(insn->code) != BPF_REL)
+				return -EINVAL;
+			/* check src operand */
+			_(check_reg_arg(regs, insn->a_reg, 1));
+			_(check_mem_access(env, insn->a_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   -1));
+
+		} else if (class == BPF_JMP) {
+			u16 opcode = BPF_OP(insn->code);
+			if (opcode == BPF_CALL) {
+				_(check_call(env, insn->imm));
+			} else if (opcode == BPF_JA) {
+				if (BPF_SRC(insn->code) != BPF_X)
+					return -EINVAL;
+				insn_idx += insn->off + 1;
+				continue;
+			} else {
+				_(check_cond_jmp_op(env, insn, insn_idx));
+			}
+
+		} else if (class == BPF_RET) {
+process_ret:
+			insn_idx = pop_stack(env);
+			if (insn_idx < 0)
+				break;
+			else
+				continue;
+		}
+
+		insn_idx++;
+	}
+
+	/* pr_debug("insn_processed %d\n", insn_processed); */
+	return 0;
+}
+
+static void free_states(struct verifier_env *env, int insn_cnt)
+{
+	int i;
+
+	for (i = 0; i < insn_cnt; i++) {
+		struct verifier_state_list *sl = env->branch_landing[i];
+		if (sl)
+			while (sl != STATE_END) {
+				struct verifier_state_list *sln = sl->next;
+				kfree(sl);
+				sl = sln;
+			}
+	}
+
+	kfree(env->branch_landing);
+}
+
+int bpf_check(struct bpf_program *prog)
+{
+	int ret;
+	struct verifier_env *env;
+
+	if (prog->insn_cnt <= 0 || prog->insn_cnt > 32768 ||
+	    prog->table_cnt < 0 || prog->table_cnt > 128) {
+		pr_err("BPF program has %d insn and %d tables. Max is 32K/128\n",
+		       prog->insn_cnt, prog->table_cnt);
+		return -E2BIG;
+	}
+
+	env = kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	env->tables = prog->tables;
+	env->table_cnt = prog->table_cnt;
+	env->get_func_proto = prog->cb->get_func_proto;
+	env->get_context_access = prog->cb->get_context_access;
+	env->branch_landing = kzalloc(sizeof(struct verifier_state_list *) *
+				      prog->insn_cnt, GFP_KERNEL);
+
+	if (!env->branch_landing) {
+		kfree(env);
+		return -ENOMEM;
+	}
+
+	ret = check_cfg(env, prog->insns, prog->insn_cnt);
+	if (ret)
+		goto free_env;
+	ret = __bpf_check(env, prog->insns, prog->insn_cnt);
+free_env:
+	free_states(env, prog->insn_cnt);
+	kfree(env);
+	return ret;
+}
diff --git a/net/core/bpf_run.c b/net/core/bpf_run.c
new file mode 100644
index 0000000..919da4e
--- /dev/null
+++ b/net/core/bpf_run.c
@@ -0,0 +1,412 @@
+/* Copyright (c) 2011-2013 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/filter.h>
+
+static const char *const bpf_class_string[] = {
+	"ld", "ldx", "st", "stx", "alu", "jmp", "ret", "misc"
+};
+
+static const char *const bpf_alu_string[] = {
+	"+=", "-=", "*=", "/=", "|=", "&=", "<<=", ">>=", "neg",
+	"%=", "^=", "=", "s>>=", "bswap32", "bswap64", "BUG"
+};
+
+static const char *const bpf_ldst_string[] = {
+	"u32", "u16", "u8", "u64"
+};
+
+static const char *const bpf_jmp_string[] = {
+	"jmp", "==", ">", ">=", "&", "!=", "s>", "s>=", "call"
+};
+
+static const char *debug_reg(int regno, u64 *regs)
+{
+	static char reg_value[16][32];
+	if (!regs)
+		return "";
+	snprintf(reg_value[regno], sizeof(reg_value[regno]), "(0x%llx)",
+		 regs[regno]);
+	return reg_value[regno];
+}
+
+#define R(regno) debug_reg(regno, regs)
+
+void pr_debug_bpf_insn(struct bpf_insn *insn, u64 *regs)
+{
+	u16 class = BPF_CLASS(insn->code);
+	if (class == BPF_ALU) {
+		if (BPF_SRC(insn->code) == BPF_X)
+			pr_debug("code_%02x r%d%s %s r%d%s\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_alu_string[BPF_OP(insn->code) >> 4],
+				 insn->x_reg, R(insn->x_reg));
+		else
+			pr_debug("code_%02x r%d%s %s %d\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_alu_string[BPF_OP(insn->code) >> 4],
+				 insn->imm);
+	} else if (class == BPF_STX) {
+		if (BPF_MODE(insn->code) == BPF_REL)
+			pr_debug("code_%02x *(%s *)(r%d%s %+d) = r%d%s\n",
+				 insn->code,
+				 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				 insn->a_reg, R(insn->a_reg),
+				 insn->off, insn->x_reg, R(insn->x_reg));
+		else if (BPF_MODE(insn->code) == BPF_XADD)
+			pr_debug("code_%02x lock *(%s *)(r%d%s %+d) += r%d%s\n",
+				 insn->code,
+				 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				 insn->a_reg, R(insn->a_reg), insn->off,
+				 insn->x_reg, R(insn->x_reg));
+		else
+			pr_debug("BUG_%02x\n", insn->code);
+	} else if (class == BPF_ST) {
+		if (BPF_MODE(insn->code) != BPF_REL) {
+			pr_debug("BUG_st_%02x\n", insn->code);
+			return;
+		}
+		pr_debug("code_%02x *(%s *)(r%d%s %+d) = %d\n",
+			 insn->code,
+			 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			 insn->a_reg, R(insn->a_reg),
+			 insn->off, insn->imm);
+	} else if (class == BPF_LDX) {
+		if (BPF_MODE(insn->code) != BPF_REL) {
+			pr_debug("BUG_ldx_%02x\n", insn->code);
+			return;
+		}
+		pr_debug("code_%02x r%d = *(%s *)(r%d%s %+d)\n",
+			 insn->code, insn->a_reg,
+			 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			 insn->x_reg, R(insn->x_reg), insn->off);
+	} else if (class == BPF_JMP) {
+		u16 opcode = BPF_OP(insn->code);
+		if (opcode == BPF_CALL) {
+			pr_debug("code_%02x call %d\n", insn->code, insn->imm);
+		} else if (insn->code == (BPF_JMP | BPF_JA | BPF_X)) {
+			pr_debug("code_%02x goto pc%+d\n",
+				 insn->code, insn->off);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
+			pr_debug("code_%02x if r%d%s %s r%d%s goto pc%+d\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				 insn->x_reg, R(insn->x_reg), insn->off);
+		} else {
+			pr_debug("code_%02x if r%d%s %s 0x%x goto pc%+d\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_jmp_string[BPF_OP(insn->code) >> 4],
+				 insn->imm, insn->off);
+		}
+	} else {
+		pr_debug("code_%02x %s\n", insn->code, bpf_class_string[class]);
+	}
+}
+
+void bpf_run(struct bpf_program *prog, struct bpf_context *ctx)
+{
+	struct bpf_insn *insn = prog->insns;
+	u64 stack[64];
+	u64 regs[16] = { };
+	regs[__fp__] = (u64) &stack[64];
+	regs[R1] = (u64) ctx;
+
+	for (;; insn++) {
+		const s32 K = insn->imm;
+		u64 *a_reg = &regs[insn->a_reg];
+		u64 *x_reg = &regs[insn->x_reg];
+#define A (*a_reg)
+#define X (*x_reg)
+		/*pr_debug_bpf_insn(insn, regs);*/
+		switch (insn->code) {
+			/* ALU */
+		case BPF_ALU | BPF_ADD | BPF_X:
+			A += X;
+			continue;
+		case BPF_ALU | BPF_ADD | BPF_K:
+			A += K;
+			continue;
+		case BPF_ALU | BPF_SUB | BPF_X:
+			A -= X;
+			continue;
+		case BPF_ALU | BPF_SUB | BPF_K:
+			A -= K;
+			continue;
+		case BPF_ALU | BPF_AND | BPF_X:
+			A &= X;
+			continue;
+		case BPF_ALU | BPF_AND | BPF_K:
+			A &= K;
+			continue;
+		case BPF_ALU | BPF_OR | BPF_X:
+			A |= X;
+			continue;
+		case BPF_ALU | BPF_OR | BPF_K:
+			A |= K;
+			continue;
+		case BPF_ALU | BPF_LSH | BPF_X:
+			A <<= X;
+			continue;
+		case BPF_ALU | BPF_LSH | BPF_K:
+			A <<= K;
+			continue;
+		case BPF_ALU | BPF_RSH | BPF_X:
+			A >>= X;
+			continue;
+		case BPF_ALU | BPF_RSH | BPF_K:
+			A >>= K;
+			continue;
+		case BPF_ALU | BPF_MOV | BPF_X:
+			A = X;
+			continue;
+		case BPF_ALU | BPF_MOV | BPF_K:
+			A = K;
+			continue;
+		case BPF_ALU | BPF_ARSH | BPF_X:
+			(*(s64 *) &A) >>= X;
+			continue;
+		case BPF_ALU | BPF_ARSH | BPF_K:
+			(*(s64 *) &A) >>= K;
+			continue;
+		case BPF_ALU | BPF_BSWAP32 | BPF_X:
+			A = __builtin_bswap32(A);
+			continue;
+		case BPF_ALU | BPF_BSWAP64 | BPF_X:
+			A = __builtin_bswap64(A);
+			continue;
+		case BPF_ALU | BPF_MOD | BPF_X:
+			A %= X;
+			continue;
+		case BPF_ALU | BPF_MOD | BPF_K:
+			A %= K;
+			continue;
+
+			/* CALL */
+		case BPF_JMP | BPF_CALL:
+			prog->cb->execute_func(K, regs);
+			continue;
+
+			/* JMP */
+		case BPF_JMP | BPF_JA | BPF_X:
+			insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JEQ | BPF_X:
+			if (A == X)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JEQ | BPF_K:
+			if (A == K)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JNE | BPF_X:
+			if (A != X)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JNE | BPF_K:
+			if (A != K)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JGT | BPF_X:
+			if (A > X)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JGT | BPF_K:
+			if (A > K)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JGE | BPF_X:
+			if (A >= X)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JGE | BPF_K:
+			if (A >= K)
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGT | BPF_X:
+			if (((s64)A) > ((s64)X))
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGT | BPF_K:
+			if (((s64)A) > ((s64)K))
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGE | BPF_X:
+			if (((s64)A) >= ((s64)X))
+				insn += insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGE | BPF_K:
+			if (((s64)A) >= ((s64)K))
+				insn += insn->off;
+			continue;
+
+			/* STX */
+		case BPF_STX | BPF_REL | BPF_B:
+			*(u8 *)(A + insn->off) = X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_H:
+			*(u16 *)(A + insn->off) = X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_W:
+			*(u32 *)(A + insn->off) = X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_DW:
+			*(u64 *)(A + insn->off) = X;
+			continue;
+
+			/* ST */
+		case BPF_ST | BPF_REL | BPF_B:
+			*(u8 *)(A + insn->off) = K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_H:
+			*(u16 *)(A + insn->off) = K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_W:
+			*(u32 *)(A + insn->off) = K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_DW:
+			*(u64 *)(A + insn->off) = K;
+			continue;
+
+			/* LDX */
+		case BPF_LDX | BPF_REL | BPF_B:
+			A = *(u8 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_H:
+			A = *(u16 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_W:
+			A = *(u32 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_DW:
+			A = *(u64 *)(X + insn->off);
+			continue;
+
+			/* STX XADD */
+		case BPF_STX | BPF_XADD | BPF_B:
+			__sync_fetch_and_add((u8 *)(A + insn->off), (u8)X);
+			continue;
+		case BPF_STX | BPF_XADD | BPF_H:
+			__sync_fetch_and_add((u16 *)(A + insn->off), (u16)X);
+			continue;
+		case BPF_STX | BPF_XADD | BPF_W:
+			__sync_fetch_and_add((u32 *)(A + insn->off), (u32)X);
+			continue;
+		case BPF_STX | BPF_XADD | BPF_DW:
+			__sync_fetch_and_add((u64 *)(A + insn->off), (u64)X);
+			continue;
+
+			/* RET */
+		case BPF_RET | BPF_K:
+			return;
+		default:
+			/* bpf_check() will guarantee that
+			 * we never reach here
+			 */
+			pr_err("unknown opcode %02x\n", insn->code);
+			return;
+		}
+	}
+}
+EXPORT_SYMBOL(bpf_run);
+
+int bpf_load(struct bpf_image *image, struct bpf_callbacks *cb,
+	     struct bpf_program **p_prog)
+{
+	struct bpf_program *prog;
+	int ret;
+
+	if (!image || !cb || !cb->execute_func || !cb->get_func_proto ||
+	    !cb->get_context_access)
+		return -EINVAL;
+
+	if (image->insn_cnt <= 0 || image->insn_cnt > 32768 ||
+	    image->table_cnt < 0 || image->table_cnt > 128) {
+		pr_err("BPF program has %d insn and %d tables. Max is 32K/128\n",
+		       image->insn_cnt, image->table_cnt);
+		return -E2BIG;
+	}
+
+	prog = kzalloc(sizeof(struct bpf_program), GFP_KERNEL);
+	if (!prog)
+		return -ENOMEM;
+
+	prog->insn_cnt = image->insn_cnt;
+	prog->table_cnt = image->table_cnt;
+	prog->cb = cb;
+
+	prog->insns = kmalloc(sizeof(struct bpf_insn) * prog->insn_cnt,
+			      GFP_KERNEL);
+	if (!prog->insns) {
+		ret = -ENOMEM;
+		goto free_prog;
+	}
+
+	prog->tables = kmalloc(sizeof(struct bpf_table) * prog->table_cnt,
+			       GFP_KERNEL);
+	if (!prog->tables) {
+		ret = -ENOMEM;
+		goto free_insns;
+	}
+
+	if (copy_from_user(prog->insns, image->insns,
+			   sizeof(struct bpf_insn) * prog->insn_cnt)) {
+		ret = -EFAULT;
+		goto free_tables;
+	}
+
+	if (copy_from_user(prog->tables, image->tables,
+			   sizeof(struct bpf_table) * prog->table_cnt)) {
+		ret = -EFAULT;
+		goto free_tables;
+	}
+
+	/* verify BPF program */
+	ret = bpf_check(prog);
+	if (ret)
+		goto free_tables;
+
+	/* JIT it */
+	bpf2_jit_compile(prog);
+
+	*p_prog = prog;
+
+	return 0;
+
+free_tables:
+	kfree(prog->tables);
+free_insns:
+	kfree(prog->insns);
+free_prog:
+	kfree(prog);
+	return ret;
+}
+EXPORT_SYMBOL(bpf_load);
+
+void bpf_free(struct bpf_program *prog)
+{
+	if (!prog)
+		return;
+	bpf2_jit_free(prog);
+	kfree(prog->tables);
+	kfree(prog->insns);
+	kfree(prog);
+}
+EXPORT_SYMBOL(bpf_free);
+
-- 
1.7.9.5
