From: Alexei Starovoitov <ast@plumgrid.com>
Subject: =?UTF-8?q?=5BRFC=20PATCH=20net-next=201/2=5D=20extended=20BPF?=
Date: Wed, 11 Sep 2013 20:12:41 -0700
Message-ID: <1378955562-3825-2-git-send-email-ast@plumgrid.com>
References: <1378955562-3825-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53404 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab3ILDMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 23:12:55 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so9910857pbb.5
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 20:12:54 -0700 (PDT)
In-Reply-To: <1378955562-3825-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

extended BPF program =3D BPF insns + BPF tables

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
- generic 'struct bpf_context' =3D input/output argument to BPF program

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

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/net/Makefile        |    2 +-
 arch/x86/net/bpf2_jit_comp.c |  610 ++++++++++++++++++++++++
 arch/x86/net/bpf_jit_comp.c  |   41 +-
 arch/x86/net/bpf_jit_comp.h  |   36 ++
 include/linux/filter.h       |   79 ++++
 include/uapi/linux/filter.h  |  125 ++++-
 net/core/Makefile            |    2 +-
 net/core/bpf_check.c         | 1043 ++++++++++++++++++++++++++++++++++=
++++++++
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
-obj-$(CONFIG_BPF_JIT) +=3D bpf_jit.o bpf_jit_comp.o
+obj-$(CONFIG_BPF_JIT) +=3D bpf_jit.o bpf_jit_comp.o bpf2_jit_comp.o
diff --git a/arch/x86/net/bpf2_jit_comp.c b/arch/x86/net/bpf2_jit_comp.=
c
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
+	if (len =3D=3D 1)
+		*ptr =3D bytes;
+	else if (len =3D=3D 2)
+		*(u16 *)ptr =3D bytes;
+	else
+		*(u32 *)ptr =3D bytes;
+	return ptr + len;
+}
+
+#define EMIT(bytes, len) (prog =3D emit_code(prog, (bytes), (len)))
+
+#define EMIT1(b1)		EMIT(b1, 1)
+#define EMIT2(b1, b2)		EMIT((b1) + ((b2) << 8), 2)
+#define EMIT3(b1, b2, b3)	EMIT((b1) + ((b2) << 8) + ((b3) << 16), 3)
+#define EMIT4(b1, b2, b3, b4)   EMIT((b1) + ((b2) << 8) + ((b3) << 16)=
 + ((b4) << 24), 4)
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
+	return value <=3D 127 && value >=3D -128;
+}
+
+static inline bool is_simm32(__s64 value)
+{
+	return value =3D=3D (__s64)(__s32)value;
+}
+
+static int bpf_size_to_x86_bytes(int bpf_size)
+{
+	if (bpf_size =3D=3D BPF_W)
+		return 4;
+	else if (bpf_size =3D=3D BPF_H)
+		return 2;
+	else if (bpf_size =3D=3D BPF_B)
+		return 1;
+	else if (bpf_size =3D=3D BPF_DW)
+		return 4; /* imm32 */
+	else
+		return 0;
+}
+
+#define AUX_REG 32
+
+/* avoid x86-64 R12 which if used as base address in memory access
+ * always needs an extra byte for index */
+static const int reg2hex[] =3D {
+	[R0] =3D 0, /* rax */
+	[R1] =3D 7, /* rdi */
+	[R2] =3D 6, /* rsi */
+	[R3] =3D 2, /* rdx */
+	[R4] =3D 1, /* rcx */
+	[R5] =3D 0, /* r8 */
+	[R6] =3D 3, /* rbx callee saved */
+	[R7] =3D 5, /* r13 callee saved */
+	[R8] =3D 6, /* r14 callee saved */
+	[R9] =3D 7, /* r15 callee saved */
+	[__fp__] =3D 5, /* rbp readonly */
+	[AUX_REG] =3D 1, /* r9 temp register */
+};
+
+/* is_ereg() =3D=3D true if r8 <=3D reg <=3D r15,
+ * rax,rcx,...,rbp don't need extra byte of encoding */
+static inline bool is_ereg(u32 reg)
+{
+	if (reg =3D=3D R5 || (reg >=3D R7 && reg <=3D R9) || reg =3D=3D AUX_R=
EG)
+		return true;
+	else
+		return false;
+}
+
+static inline u8 add_1mod(u8 byte, u32 reg)
+{
+	if (is_ereg(reg))
+		byte |=3D 1;
+	return byte;
+}
+static inline u8 add_2mod(u8 byte, u32 r1, u32 r2)
+{
+	if (is_ereg(r1))
+		byte |=3D 1;
+	if (is_ereg(r2))
+		byte |=3D 4;
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
+	if (id < 0 || id >=3D FUNC_bpf_max_id)
+		return NULL;
+	return prog->cb->jit_select_func(id);
+}
+
+static int do_jit(struct bpf_program *bpf_prog, int *addrs, u8 *image,
+		  int oldproglen)
+{
+	struct bpf_insn *insn =3D bpf_prog->insns;
+	int insn_cnt =3D bpf_prog->insn_cnt;
+	u8 temp[64];
+	int i;
+	int proglen =3D 0;
+	u8 *prog =3D temp;
+	int stacksize =3D 512;
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
+	for (i =3D 0; i < insn_cnt; i++, insn++) {
+		const __s32 K =3D insn->imm;
+		__u32 a_reg =3D insn->a_reg;
+		__u32 x_reg =3D insn->x_reg;
+		u8 b1 =3D 0, b2 =3D 0, b3 =3D 0;
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
+			b1 =3D 0x48;
+			b3 =3D 0xC0;
+			switch (BPF_OP(insn->code)) {
+			case BPF_ADD: b2 =3D 0x01; break;
+			case BPF_SUB: b2 =3D 0x29; break;
+			case BPF_AND: b2 =3D 0x21; break;
+			case BPF_OR: b2 =3D 0x09; break;
+			case BPF_XOR: b2 =3D 0x31; break;
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
+			b1 =3D add_1mod(0x48, a_reg);
+
+			switch (BPF_OP(insn->code)) {
+			case BPF_ADD: b3 =3D 0xC0; break;
+			case BPF_SUB: b3 =3D 0xE8; break;
+			case BPF_AND: b3 =3D 0xE0; break;
+			case BPF_OR: b3 =3D 0xC8; break;
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
+			b1 =3D add_1mod(0x48, a_reg);
+			b2 =3D 0xC7;
+			b3 =3D 0xC0;
+			EMIT3_off32(b1, b2, add_1reg(b3, a_reg), K);
+			break;
+
+			/* A %=3D X
+			 * A /=3D X */
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
+			/* if X=3D=3D0, skip divide, make A=3D0 */
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
+			if (BPF_OP(insn->code) =3D=3D BPF_MOD) {
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
+			b1 =3D add_1mod(0x48, a_reg);
+			switch (BPF_OP(insn->code)) {
+			case BPF_LSH: b3 =3D 0xE0; break;
+			case BPF_RSH: b3 =3D 0xE8; break;
+			case BPF_ARSH: b3 =3D 0xF8; break;
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
+			/* ST: *(u8*)(a_reg + off) =3D imm */
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
+			/* STX: *(u8*)(a_reg + off) =3D x_reg */
+		case BPF_STX | BPF_REL | BPF_B:
+			/* emit 'mov byte ptr [rax + off], al' */
+			if (is_ereg(a_reg) || is_ereg(x_reg) ||
+			    /* have to add extra byte for x86 SIL, DIL regs */
+			    x_reg =3D=3D R1 || x_reg =3D=3D R2)
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
+			/* LDX: a_reg =3D *(u8*)(x_reg + off) */
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
+ldx:			/* if insn->off =3D=3D 0 we can save one extra byte, but
+			 * special case of x86 R13 which always needs an offset
+			 * is not worth the pain */
+			if (is_imm8(insn->off))
+				EMIT2(add_2reg(0x40, x_reg, a_reg), insn->off);
+			else
+				EMIT1_off32(add_2reg(0x80, x_reg, a_reg), insn->off);
+			break;
+
+			/* STX XADD: lock *(u8*)(a_reg + off) +=3D x_reg */
+		case BPF_STX | BPF_XADD | BPF_B:
+			/* emit 'lock add byte ptr [rax + off], al' */
+			if (is_ereg(a_reg) || is_ereg(x_reg) ||
+			    /* have to add extra byte for x86 SIL, DIL regs */
+			    x_reg =3D=3D R1 || x_reg =3D=3D R2)
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
+			func =3D select_bpf_func(bpf_prog, K);
+			jmp_offset =3D func - (image + addrs[i]);
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
+			b1 =3D 0x48;
+			b2 =3D 0x39;
+			b3 =3D 0xC0;
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
+				jmp_cond =3D X86_JE;
+				break;
+			case BPF_JNE:
+				jmp_cond =3D X86_JNE;
+				break;
+			case BPF_JGT:
+				/* GT is unsigned '>', JA in x86 */
+				jmp_cond =3D X86_JA;
+				break;
+			case BPF_JGE:
+				/* GE is unsigned '>=3D', JAE in x86 */
+				jmp_cond =3D X86_JAE;
+				break;
+			case BPF_JSGT:
+				/* signed '>', GT in x86 */
+				jmp_cond =3D X86_JG;
+				break;
+			case BPF_JSGE:
+				/* signed '>=3D', GE in x86 */
+				jmp_cond =3D X86_JGE;
+				break;
+			default: /* to silence gcc warning */
+				return -EFAULT;
+			}
+			jmp_offset =3D addrs[i + insn->off] - addrs[i];
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
+			jmp_offset =3D addrs[i + insn->off] - addrs[i];
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
+		ilen =3D prog - temp;
+		if (image) {
+			if (proglen + ilen > oldproglen)
+				return -2;
+			memcpy(image + proglen, temp, ilen);
+		}
+		proglen +=3D ilen;
+		addrs[i] =3D proglen;
+		prog =3D temp;
+	}
+	return proglen;
+}
+
+void bpf2_jit_compile(struct bpf_program *prog)
+{
+	struct bpf_binary_header *header =3D NULL;
+	int proglen, oldproglen =3D 0;
+	int *addrs;
+	u8 *image =3D NULL;
+	int pass;
+	int i;
+
+	if (!prog || !prog->cb || !prog->cb->jit_select_func)
+		return;
+
+	addrs =3D kmalloc(prog->insn_cnt * sizeof(*addrs), GFP_KERNEL);
+	if (!addrs)
+		return;
+
+	for (proglen =3D 0, i =3D 0; i < prog->insn_cnt; i++) {
+		proglen +=3D 64;
+		addrs[i] =3D proglen;
+	}
+	for (pass =3D 0; pass < 10; pass++) {
+		proglen =3D do_jit(prog, addrs, image, oldproglen);
+		if (proglen <=3D 0) {
+			image =3D NULL;
+			goto out;
+		}
+		if (image) {
+			if (proglen !=3D oldproglen)
+				pr_err("bpf_jit: proglen=3D%d !=3D oldproglen=3D%d\n",
+				       proglen, oldproglen);
+			break;
+		}
+		if (proglen =3D=3D oldproglen) {
+			header =3D bpf_alloc_binary(proglen, &image);
+			if (!header)
+				goto out;
+		}
+		oldproglen =3D proglen;
+	}
+
+	if (image) {
+		bpf_flush_icache(header, image + proglen);
+		set_memory_ro((unsigned long)header, header->pages);
+	}
+out:
+	kfree(addrs);
+	prog->jit_image =3D (void (*)(struct bpf_context *ctx))image;
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
=20
 /*
  * Conventions :
@@ -112,16 +113,6 @@ do {								\
 #define SEEN_XREG    2 /* ebx is used */
 #define SEEN_MEM     4 /* use mem[] for temporary storage */
=20
-static inline void bpf_flush_icache(void *start, void *end)
-{
-	mm_segment_t old_fs =3D get_fs();
-
-	set_fs(KERNEL_DS);
-	smp_wmb();
-	flush_icache_range((unsigned long)start, (unsigned long)end);
-	set_fs(old_fs);
-}
-
 #define CHOOSE_LOAD_FUNC(K, func) \
 	((int)K < 0 ? ((int)K >=3D SKF_LL_OFF ? func##_negative_offset : func=
) : func##_positive_offset)
=20
@@ -145,16 +136,8 @@ static int pkt_type_offset(void)
 	return -1;
 }
=20
-struct bpf_binary_header {
-	unsigned int	pages;
-	/* Note : for security reasons, bpf code will follow a randomly
-	 * sized amount of int3 instructions
-	 */
-	u8		image[];
-};
-
-static struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen=
,
-						  u8 **image_ptr)
+struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen,
+					   u8 **image_ptr)
 {
 	unsigned int sz, hole;
 	struct bpf_binary_header *header;
@@ -772,13 +755,17 @@ out:
 	return;
 }
=20
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_free_binary(void *bpf_func)
 {
-	if (fp->bpf_func !=3D sk_run_filter) {
-		unsigned long addr =3D (unsigned long)fp->bpf_func & PAGE_MASK;
-		struct bpf_binary_header *header =3D (void *)addr;
+	unsigned long addr =3D (unsigned long)bpf_func & PAGE_MASK;
+	struct bpf_binary_header *header =3D (void *)addr;
=20
-		set_memory_rw(addr, header->pages);
-		module_free(NULL, header);
-	}
+	set_memory_rw(addr, header->pages);
+	module_free(NULL, header);
+}
+
+void bpf_jit_free(struct sk_filter *fp)
+{
+	if (fp->bpf_func !=3D sk_run_filter)
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
+	mm_segment_t old_fs =3D get_fs();
+
+	set_fs(KERNEL_DS);
+	smp_wmb();
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+	set_fs(old_fs);
+}
+
+extern struct bpf_binary_header *bpf_alloc_binary(unsigned int proglen=
,
+						  u8 **image_ptr);
+extern void bpf_free_binary(void *image_ptr);
+
+#endif
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a6ac848..63b3277 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -48,6 +48,77 @@ extern int sk_chk_filter(struct sock_filter *filter,=
 unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *f=
ilter, unsigned len);
 extern void sk_decode_filter(struct sock_filter *filt, struct sock_fil=
ter *to);
=20
+/* type of value stored in a BPF register or
+ * passed into function as an argument or
+ * returned from the function */
+enum bpf_reg_type {
+	INVALID_PTR,  /* reg doesn't contain a valid pointer */
+	PTR_TO_CTX,   /* reg points to bpf_context */
+	PTR_TO_TABLE, /* reg points to table element */
+	PTR_TO_TABLE_CONDITIONAL, /* points to table element or NULL */
+	PTR_TO_STACK,     /* reg =3D=3D frame_pointer */
+	PTR_TO_STACK_IMM, /* reg =3D=3D frame_pointer + imm */
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
+	BPF_READ =3D 1,
+	BPF_WRITE =3D 2
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
+	/* return address of func_id suitable to be called from JITed program=
 */
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
+extern void bpf_run(struct bpf_program *prog, struct bpf_context *ctx)=
;
+/* verify correctness of BPF program */
+extern int bpf_check(struct bpf_program *prog);
+/* pr_debug one insn */
+extern void pr_debug_bpf_insn(struct bpf_insn *insn, u64 *regs);
+
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
@@ -55,6 +126,8 @@ extern void sk_decode_filter(struct sock_filter *fil=
t, struct sock_filter *to);
=20
 extern void bpf_jit_compile(struct sk_filter *fp);
 extern void bpf_jit_free(struct sk_filter *fp);
+extern void bpf2_jit_compile(struct bpf_program *prog);
+extern void bpf2_jit_free(struct bpf_program *prog);
=20
 static inline void bpf_jit_dump(unsigned int flen, unsigned int progle=
n,
 				u32 pass, void *image)
@@ -73,6 +146,12 @@ static inline void bpf_jit_compile(struct sk_filter=
 *fp)
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
=20
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 8eb9cca..5783769 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -1,3 +1,4 @@
+/* extended BPF is Copyright (c) 2011-2013, PLUMgrid, http://plumgrid.=
com */
 /*
  * Linux Socket Filter Data Structures
  */
@@ -19,7 +20,7 @@
  *	Try and keep these values and structures similar to BSD, especially
  *	the BPF code definitions which need to match so you can share filte=
rs
  */
-=20
+
 struct sock_filter {	/* Filter block */
 	__u16	code;   /* Actual filter code */
 	__u8	jt;	/* Jump true */
@@ -46,11 +47,88 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTE=
R. */
 #define         BPF_RET         0x06
 #define         BPF_MISC        0x07
=20
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
+	BPF_TABLE_HASH =3D 1,
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
+/* pointer to bpf_context is the first and only argument to BPF progra=
m
+ * its definition is use-case specific */
+struct bpf_context;
+
+/* bpf_add|sub|...: a +=3D x
+ *         bpf_mov: a =3D x
+ *       bpf_bswap: bswap a */
+#define BPF_INSN_ALU(op, a, x) \
+	(struct bpf_insn){BPF_ALU|BPF_OP(op)|BPF_X, a, x, 0, 0}
+
+/* bpf_add|sub|...: a +=3D imm
+ *         bpf_mov: a =3D imm */
+#define BPF_INSN_ALU_IMM(op, a, imm) \
+	(struct bpf_insn){BPF_ALU|BPF_OP(op)|BPF_K, a, 0, 0, imm}
+
+/* a =3D *(uint *) (x + off) */
+#define BPF_INSN_LD(size, a, x, off) \
+	(struct bpf_insn){BPF_LDX|BPF_SIZE(size)|BPF_REL, a, x, off, 0}
+
+/* *(uint *) (a + off) =3D x */
+#define BPF_INSN_ST(size, a, off, x) \
+	(struct bpf_insn){BPF_STX|BPF_SIZE(size)|BPF_REL, a, x, off, 0}
+
+/* *(uint *) (a + off) =3D imm */
+#define BPF_INSN_ST_IMM(size, a, off, imm) \
+	(struct bpf_insn){BPF_ST|BPF_SIZE(size)|BPF_REL, a, 0, off, imm}
+
+/* lock *(uint *) (a + off) +=3D x */
+#define BPF_INSN_XADD(size, a, off, x) \
+	(struct bpf_insn){BPF_STX|BPF_SIZE(size)|BPF_XADD, a, x, off, 0}
+
+/* if (a 'op' x) pc +=3D off else fall through */
+#define BPF_INSN_JUMP(op, a, x, off) \
+	(struct bpf_insn){BPF_JMP|BPF_OP(op)|BPF_X, a, x, off, 0}
+
+/* if (a 'op' imm) pc +=3D off else fall through */
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
@@ -58,6 +136,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER=
=2E */
 #define         BPF_MEM         0x60
 #define         BPF_LEN         0x80
 #define         BPF_MSH         0xa0
+#define         BPF_REL         0xc0
+#define         BPF_XADD        0xe0 /* exclusive add */
=20
 /* alu/jmp fields */
 #define BPF_OP(code)    ((code) & 0xf0)
@@ -68,20 +148,54 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILT=
ER. */
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
=20
 #define         BPF_JA          0x00
-#define         BPF_JEQ         0x10
-#define         BPF_JGT         0x20
-#define         BPF_JGE         0x30
+#define         BPF_JEQ         0x10 /* jump =3D=3D */
+#define         BPF_JGT         0x20 /* GT is unsigned '>', JA in x86 =
*/
+#define         BPF_JGE         0x30 /* GE is unsigned '>=3D', JAE in =
x86 */
 #define         BPF_JSET        0x40
+#define         BPF_JNE         0x50 /* jump !=3D */
+#define         BPF_JSGT        0x60 /* SGT is signed '>', GT in x86 *=
/
+#define         BPF_JSGE        0x70 /* SGE is signed '>=3D', GE in x8=
6 */
+#define         BPF_CALL        0x80 /* function call */
 #define BPF_SRC(code)   ((code) & 0x08)
 #define         BPF_K           0x00
 #define         BPF_X           0x08
=20
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
+	FUNC_bpf_table_lookup =3D 1,
+	FUNC_bpf_table_update =3D 2,
+	FUNC_bpf_max_id =3D 1024
+};
+void *bpf_table_lookup(struct bpf_context *ctx, int table_id, const vo=
id *key);
+int bpf_table_update(struct bpf_context *ctx, int table_id, const void=
 *key,
+		     const void *leaf);
+
 /* ret - BPF_K and BPF_X also apply */
 #define BPF_RVAL(code)  ((code) & 0x18)
 #define         BPF_A           0x10
@@ -134,5 +248,4 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTE=
R. */
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
=20
-
 #endif /* _UAPI__LINUX_FILTER_H__ */
diff --git a/net/core/Makefile b/net/core/Makefile
index b33b996..f04e016 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) +=3D sysctl_net_core.o
=20
 obj-y		     +=3D dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o
+			sock_diag.o dev_ioctl.o bpf_run.o bpf_check.o
=20
 obj-$(CONFIG_XFRM) +=3D flow.o
 obj-y +=3D net-sysfs.o
diff --git a/net/core/bpf_check.c b/net/core/bpf_check.c
new file mode 100644
index 0000000..2fe9259
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
+ * At the first pass depth-first-search verifies that the BPF program =
is a DAG.
+ * It rejects the following programs:
+ * - larger than 32K insns or 128 tables
+ * - if loop is present (detected via back-edge)
+ * - unreachable insns exist (shouldn't be a forest. program =3D one f=
unction)
+ * - more than one ret insn
+ * - ret insn is not a last insn
+ * - out of bounds or malformed jumps
+ * The second pass is all possible path descent from the 1st insn.
+ * Conditional branch target insns keep a link list of verifier states=
=2E
+ * If the state already visited, this path can be pruned.
+ * If it wasn't a DAG, such state prunning would be incorrect, since i=
t would
+ * skip cycles. Since it's analyzing all pathes through the program,
+ * the length of the analysis is limited to 64k insn, which may be hit=
 even
+ * if insn_cnt < 32k, but there are too many branches that change stac=
k/regs.
+ * Number of 'branches to be analyzed' is limited to 8k
+ *
+ * All registers are 64-bit (even on 32-bit arch)
+ * R0 - return register
+ * R1-R5 argument passing registers
+ * R6-R9 callee saved registers
+ * R10 - frame pointer read-only
+ *
+ * At the start of BPF program the register R1 contains a pointer to b=
pf_context
+ * and has type PTR_TO_CTX.
+ *
+ * bpf_table_lookup() function returns ether pointer to table value or=
 NULL
+ * which is type PTR_TO_TABLE_CONDITIONAL. Once it passes through !=3D=
0 insn
+ * the register holding that pointer in the true branch changes state =
to
+ * PTR_TO_TABLE and the same register changes state to INVALID_PTR in =
the false
+ * branch. See check_cond_jmp_op()
+ *
+ * R10 has type PTR_TO_STACK. The sequence 'mov Rx, R10; add Rx, imm' =
changes
+ * Rx state to PTR_TO_STACK_IMM and immediate constant is saved for fu=
rther
+ * stack bounds checking
+ *
+ * registers used to pass pointers to function calls are verified agai=
nst
+ * function prototypes
+ * Ex: before the call to bpf_table_lookup(), R1 must have type PTR_TO=
_CTX
+ * R2 must contain integer constant and R3 PTR_TO_STACK_IMM
+ * Integer constant in R2 is a table_id. It's checked that 0 <=3D R2 <=
 table_cnt
+ * and corresponding table_info->key_size fetched to check that
+ * [R3, R3 + table_info->key_size) are within stack limits and all tha=
t stack
+ * memory was initiliazed earlier by BPF program.
+ * After bpf_table_lookup() call insn, R0 is set to PTR_TO_TABLE_CONDI=
TIONAL
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
+ * 8 + sizeof(u16) <=3D table_info->elem_size
+ *
+ * load/store to bpf_context checked against known fields
+ *
+ * Future improvements:
+ * stack size is hardcoded to 512 bytes maximum per program, relax it
+ */
+#define _(OP) ({ int ret =3D OP; if (ret < 0) return ret; })
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
+	if (env->head =3D=3D NULL)
+		return -1;
+	memcpy(&env->cur_state, &env->head->st, sizeof(env->cur_state));
+	insn_idx =3D env->head->insn_idx;
+	elem =3D env->head->next;
+	kfree(env->head);
+	env->head =3D elem;
+	env->stack_size--;
+	return insn_idx;
+}
+
+static struct verifier_state *push_stack(struct verifier_env *env, int=
 insn_idx)
+{
+	struct verifier_stack_elem *elem;
+	elem =3D kmalloc(sizeof(struct verifier_stack_elem), GFP_KERNEL);
+	memcpy(&elem->st, &env->cur_state, sizeof(env->cur_state));
+	elem->insn_idx =3D insn_idx;
+	elem->next =3D env->head;
+	env->head =3D elem;
+	env->stack_size++;
+	if (env->stack_size > 8192) {
+		pr_err("BPF program is too complex\n");
+		/* pop all elements and return */
+		while (pop_stack(env) >=3D 0);
+		return NULL;
+	}
+	return &elem->st;
+}
+
+#define CALLER_SAVED_REGS 6
+static const int caller_saved[CALLER_SAVED_REGS] =3D { R0, R1, R2, R3,=
 R4, R5 };
+
+static void init_reg_state(struct reg_state *regs)
+{
+	struct reg_state *reg;
+	int i;
+	for (i =3D 0; i < MAX_REG; i++) {
+		regs[i].ptr =3D INVALID_PTR;
+		regs[i].read_ok =3D false;
+		regs[i].imm =3D 0xbadbad;
+	}
+	reg =3D regs + __fp__;
+	reg->ptr =3D PTR_TO_STACK;
+	reg->read_ok =3D true;
+
+	reg =3D regs + R1;	/* 1st arg to a function */
+	reg->ptr =3D PTR_TO_CTX;
+	reg->read_ok =3D true;
+}
+
+static void mark_reg_no_ptr(struct reg_state *regs, int regno)
+{
+	regs[regno].ptr =3D INVALID_PTR;
+	regs[regno].imm =3D 0xbadbad;
+	regs[regno].read_ok =3D true;
+}
+
+static int check_reg_arg(struct reg_state *regs, int regno, bool is_sr=
c)
+{
+	if (is_src) {
+		if (!regs[regno].read_ok) {
+			pr_err("R%d !read_ok\n", regno);
+			return -EACCES;
+		}
+	} else {
+		if (regno =3D=3D __fp__)
+			/* frame pointer is read only */
+			return -EACCES;
+		mark_reg_no_ptr(regs, regno);
+	}
+	return 0;
+}
+
+static int bpf_size_to_bytes(int bpf_size)
+{
+	if (bpf_size =3D=3D BPF_W)
+		return 4;
+	else if (bpf_size =3D=3D BPF_H)
+		return 2;
+	else if (bpf_size =3D=3D BPF_B)
+		return 1;
+	else if (bpf_size =3D=3D BPF_DW)
+		return 8;
+	else
+		return -EACCES;
+}
+
+static int check_stack_write(struct verifier_state *state, int off, in=
t size,
+			     int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+	if (value_regno >=3D 0 &&
+	    (state->regs[value_regno].ptr =3D=3D PTR_TO_TABLE ||
+	     state->regs[value_regno].ptr =3D=3D PTR_TO_CTX)) {
+
+		/* register containing pointer is being spilled into stack */
+		if (size !=3D 8) {
+			pr_err("invalid size of register spill\n");
+			return -EACCES;
+		}
+
+		slot =3D &state->stack[MAX_BPF_STACK + off];
+		slot->type =3D STACK_SPILL;
+		/* save register state */
+		slot->ptr =3D state->regs[value_regno].ptr;
+		slot->imm =3D state->regs[value_regno].imm;
+		for (i =3D 1; i < 8; i++) {
+			slot =3D &state->stack[MAX_BPF_STACK + off + i];
+			slot->type =3D STACK_SPILL_PART;
+		}
+	} else {
+
+		/* regular write of data into stack */
+		for (i =3D 0; i < size; i++) {
+			slot =3D &state->stack[MAX_BPF_STACK + off + i];
+			slot->type =3D STACK_MISC;
+		}
+	}
+	return 0;
+}
+
+static int check_stack_read(struct verifier_state *state, int off, int=
 size,
+			    int value_regno)
+{
+	int i;
+	struct bpf_stack_slot *slot;
+
+	slot =3D &state->stack[MAX_BPF_STACK + off];
+
+	if (slot->type =3D=3D STACK_SPILL) {
+		if (size !=3D 8) {
+			pr_err("invalid size of register spill\n");
+			return -EACCES;
+		}
+		for (i =3D 1; i < 8; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].type !=3D
+			    STACK_SPILL_PART) {
+				pr_err("corrupted spill memory\n");
+				return -EACCES;
+			}
+		}
+
+		/* restore register state from stack */
+		state->regs[value_regno].ptr =3D slot->ptr;
+		state->regs[value_regno].imm =3D slot->imm;
+		state->regs[value_regno].read_ok =3D true;
+		return 0;
+	} else {
+		for (i =3D 0; i < size; i++) {
+			if (state->stack[MAX_BPF_STACK + off + i].type !=3D
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
+	if (table_id < 0 || table_id >=3D env->table_cnt) {
+		pr_err("invalid access to table_id=3D%d max_tables=3D%d\n",
+		       table_id, env->table_cnt);
+		return -EACCES;
+	}
+	*table =3D &env->tables[table_id];
+	return 0;
+}
+
+/* check read/write into table element returned by bpf_table_lookup() =
*/
+static int check_table_access(struct verifier_env *env, int regno, int=
 off,
+			      int size)
+{
+	struct bpf_table *table;
+	int table_id =3D env->cur_state.regs[regno].imm;
+
+	_(get_table_info(env, table_id, &table));
+
+	if (off < 0 || off + size > table->elem_size) {
+		pr_err("invalid access to table_id=3D%d leaf_size=3D%d off=3D%d size=
=3D%d\n",
+		       table_id, table->elem_size, off, size);
+		return -EACCES;
+	}
+	return 0;
+}
+
+/* check access to 'struct bpf_context' fields */
+static int check_ctx_access(struct verifier_env *env, int off, int siz=
e,
+			    enum bpf_access_type t)
+{
+	const struct bpf_context_access *access;
+
+	if (off < 0 || off >=3D 32768/* struct bpf_context shouldn't be huge =
*/)
+		goto error;
+
+	access =3D env->get_context_access(off);
+	if (!access)
+		goto error;
+
+	if (access->size =3D=3D size && (access->type & t))
+		return 0;
+error:
+	pr_err("invalid bpf_context access off=3D%d size=3D%d\n", off, size);
+	return -EACCES;
+}
+
+static int check_mem_access(struct verifier_env *env, int regno, int o=
ff,
+			    int bpf_size, enum bpf_access_type t,
+			    int value_regno)
+{
+	struct verifier_state *state =3D &env->cur_state;
+	int size;
+	_(size =3D bpf_size_to_bytes(bpf_size));
+
+	if (off % size !=3D 0) {
+		pr_err("misaligned access off %d size %d\n", off, size);
+		return -EACCES;
+	}
+
+	if (state->regs[regno].ptr =3D=3D PTR_TO_TABLE) {
+		_(check_table_access(env, regno, off, size));
+		if (t =3D=3D BPF_READ)
+			mark_reg_no_ptr(state->regs, value_regno);
+	} else if (state->regs[regno].ptr =3D=3D PTR_TO_CTX) {
+		_(check_ctx_access(env, off, size, t));
+		if (t =3D=3D BPF_READ)
+			mark_reg_no_ptr(state->regs, value_regno);
+	} else if (state->regs[regno].ptr =3D=3D PTR_TO_STACK) {
+		if (off >=3D 0 || off < -MAX_BPF_STACK) {
+			pr_err("invalid stack off=3D%d size=3D%d\n", off, size);
+			return -EACCES;
+		}
+		if (t =3D=3D BPF_WRITE)
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
+static const struct bpf_func_proto funcs[] =3D {
+	[FUNC_bpf_table_lookup] =3D {PTR_TO_TABLE_CONDITIONAL, PTR_TO_CTX,
+				   CONST_ARG, PTR_TO_STACK_IMM},
+	[FUNC_bpf_table_update] =3D {RET_INTEGER, PTR_TO_CTX, CONST_ARG,
+				   PTR_TO_STACK_IMM, PTR_TO_STACK_IMM},
+};
+
+static int check_func_arg(struct reg_state *regs, int regno,
+			  enum bpf_reg_type expected_type, int *reg_values)
+{
+	struct reg_state *reg =3D regs + regno;
+	if (expected_type =3D=3D INVALID_PTR)
+		return 0;
+
+	if (!reg->read_ok) {
+		pr_err("R%d !read_ok\n", regno);
+		return -EACCES;
+	}
+
+	if (reg->ptr !=3D expected_type) {
+		pr_err("R%d ptr=3D%d expected=3D%d\n", regno, reg->ptr,
+		       expected_type);
+		return -EACCES;
+	} else if (expected_type =3D=3D CONST_ARG) {
+		reg_values[regno] =3D reg->imm;
+	}
+
+	return 0;
+}
+
+/* when register 'regno' is passed into function that will read 'acces=
s_size'
+ * bytes from that pointer, make sure that it's within stack boundary
+ * and all elements of stack are initialized
+ */
+static int check_stack_boundary(struct verifier_state *state,
+				struct reg_state *regs, int regno,
+				int access_size)
+{
+	int off, i;
+
+	if (regs[regno].ptr !=3D PTR_TO_STACK_IMM)
+		return -EACCES;
+
+	off =3D regs[regno].imm;
+	if (off >=3D 0 || off < -MAX_BPF_STACK || off + access_size > 0 ||
+	    access_size <=3D 0) {
+		pr_err("invalid stack ptr R%d off=3D%d access_size=3D%d\n",
+		       regno, off, access_size);
+		return -EACCES;
+	}
+
+	for (i =3D 0; i < access_size; i++) {
+		if (state->stack[MAX_BPF_STACK + off + i].type !=3D STACK_MISC) {
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
+	int reg_values[MAX_REG] =3D {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, =
-1};
+	struct verifier_state *state =3D &env->cur_state;
+	const struct bpf_func_proto *fn =3D NULL;
+	struct reg_state *regs =3D state->regs;
+	struct reg_state *reg;
+	int i;
+
+	/* find function prototype */
+	if (func_id < 0 || func_id >=3D FUNC_bpf_max_id) {
+		pr_err("invalid func %d\n", func_id);
+		return -EINVAL;
+	}
+
+	if (func_id =3D=3D FUNC_bpf_table_lookup ||
+	    func_id =3D=3D FUNC_bpf_table_update) {
+		fn =3D &funcs[func_id];
+	} else {
+		if (env->get_func_proto)
+			fn =3D env->get_func_proto(func_id);
+		if (!fn || (fn->ret_type !=3D RET_INTEGER &&
+			    fn->ret_type !=3D RET_VOID)) {
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
+	if (func_id =3D=3D FUNC_bpf_table_lookup) {
+		struct bpf_table *table;
+		int table_id =3D reg_values[R2];
+
+		_(get_table_info(env, table_id, &table));
+
+		/* bpf_table_lookup(ctx, table_id, key) call: check that
+		 * [key, key + table_info->key_size) are within stack limits
+		 * and initialized
+		 */
+		_(check_stack_boundary(state, regs, R3, table->key_size));
+
+	} else if (func_id =3D=3D FUNC_bpf_table_update) {
+		struct bpf_table *table;
+		int table_id =3D reg_values[R2];
+
+		_(get_table_info(env, table_id, &table));
+
+		/* bpf_table_update(ctx, table_id, key, value) check
+		 * that key and value are valid
+		 */
+		_(check_stack_boundary(state, regs, R3, table->key_size));
+		_(check_stack_boundary(state, regs, R4, table->elem_size));
+
+	} else if (fn->arg1_type =3D=3D PTR_TO_STACK_IMM) {
+		/* bpf_xxx(buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R1, reg_values[R2]));
+
+	} else if (fn->arg2_type =3D=3D PTR_TO_STACK_IMM) {
+		/* bpf_yyy(arg1, buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R2, reg_values[R3]));
+
+	} else if (fn->arg3_type =3D=3D PTR_TO_STACK_IMM) {
+		/* bpf_zzz(arg1, arg2, buf, len) call will access 'len' bytes
+		 * from stack pointer 'buf'. Check it
+		 */
+		_(check_stack_boundary(state, regs, R3, reg_values[R4]));
+	}
+
+	/* reset caller saved regs */
+	for (i =3D 0; i < CALLER_SAVED_REGS; i++) {
+		reg =3D regs + caller_saved[i];
+		reg->read_ok =3D false;
+		reg->ptr =3D INVALID_PTR;
+		reg->imm =3D 0xbadbad;
+	}
+
+	/* update return register */
+	reg =3D regs + R0;
+	if (fn->ret_type =3D=3D RET_INTEGER) {
+		reg->read_ok =3D true;
+		reg->ptr =3D INVALID_PTR;
+	} else if (fn->ret_type !=3D RET_VOID) {
+		reg->read_ok =3D true;
+		reg->ptr =3D fn->ret_type;
+		if (func_id =3D=3D FUNC_bpf_table_lookup)
+			/* when ret_type =3D=3D PTR_TO_TABLE_CONDITIONAL
+			 * remember table_id, so that check_table_access()
+			 * can check 'elem_size' boundary of memory access
+			 * to table element returned from bpf_table_lookup()
+			 */
+			reg->imm =3D reg_values[R2];
+	}
+	return 0;
+}
+
+static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
+{
+	u16 opcode =3D BPF_OP(insn->code);
+
+	if (opcode =3D=3D BPF_BSWAP32 || opcode =3D=3D BPF_BSWAP64 ||
+	    opcode =3D=3D BPF_NEG) {
+		if (BPF_SRC(insn->code) !=3D BPF_X)
+			return -EINVAL;
+		/* check src operand */
+		_(check_reg_arg(regs, insn->a_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+	} else if (opcode =3D=3D BPF_MOV) {
+
+		if (BPF_SRC(insn->code) =3D=3D BPF_X)
+			/* check src operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+		if (BPF_SRC(insn->code) =3D=3D BPF_X) {
+			/* case: R1 =3D R2
+			 * copy register state to dest reg
+			 */
+			regs[insn->a_reg].ptr =3D regs[insn->x_reg].ptr;
+			regs[insn->a_reg].imm =3D regs[insn->x_reg].imm;
+		} else {
+			/* case: R =3D imm
+			 * remember the value we stored into this reg
+			 */
+			regs[insn->a_reg].ptr =3D CONST_ARG;
+			regs[insn->a_reg].imm =3D insn->imm;
+		}
+
+	} else {	/* all other ALU ops: and, sub, xor, add, ... */
+
+		int stack_relative =3D 0;
+
+		if (BPF_SRC(insn->code) =3D=3D BPF_X)
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+
+		/* check src2 operand */
+		_(check_reg_arg(regs, insn->a_reg, 1));
+
+		if (opcode =3D=3D BPF_ADD &&
+		    regs[insn->a_reg].ptr =3D=3D PTR_TO_STACK &&
+		    BPF_SRC(insn->code) =3D=3D BPF_K)
+			stack_relative =3D 1;
+
+		/* check dest operand */
+		_(check_reg_arg(regs, insn->a_reg, 0));
+
+		if (stack_relative) {
+			regs[insn->a_reg].ptr =3D PTR_TO_STACK_IMM;
+			regs[insn->a_reg].imm =3D insn->imm;
+		}
+	}
+
+	return 0;
+}
+
+static int check_cond_jmp_op(struct verifier_env *env, struct bpf_insn=
 *insn,
+			     int insn_idx)
+{
+	struct reg_state *regs =3D env->cur_state.regs;
+	struct verifier_state *other_branch;
+	u16 opcode =3D BPF_OP(insn->code);
+
+	if (BPF_SRC(insn->code) =3D=3D BPF_X)
+		/* check src1 operand */
+		_(check_reg_arg(regs, insn->x_reg, 1));
+
+	/* check src2 operand */
+	_(check_reg_arg(regs, insn->a_reg, 1));
+
+	other_branch =3D push_stack(env, insn_idx + insn->off + 1);
+	if (!other_branch)
+		return -EFAULT;
+
+	/* detect if R =3D=3D 0 where R is returned value from table_lookup()=
 */
+	if (BPF_SRC(insn->code) =3D=3D BPF_K &&
+	    insn->imm =3D=3D 0 && (opcode =3D=3D BPF_JEQ ||
+			       opcode =3D=3D BPF_JNE) &&
+	    regs[insn->a_reg].ptr =3D=3D PTR_TO_TABLE_CONDITIONAL) {
+		if (opcode =3D=3D BPF_JEQ) {
+			/* next fallthrough insn can access memory via
+			 * this register
+			 */
+			regs[insn->a_reg].ptr =3D PTR_TO_TABLE;
+			/* branch targer cannot access it, since reg =3D=3D 0 */
+			other_branch->regs[insn->a_reg].ptr =3D INVALID_PTR;
+		} else {
+			other_branch->regs[insn->a_reg].ptr =3D PTR_TO_TABLE;
+			regs[insn->a_reg].ptr =3D INVALID_PTR;
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
+ * 6            t =E2=86=90 S.pop()
+ * 7            if t is what we're looking for:
+ * 8                return t
+ * 9            for all edges e in G.adjacentEdges(t) do
+ * 10               if edge e is already labelled
+ * 11                   continue with the next edge
+ * 12               w =E2=86=90 G.adjacentVertex(t,e)
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
+		if (cur_stack >=3D insn_cnt) { \
+			ret =3D -E2BIG; \
+			goto free_st; \
+		} \
+		stack[cur_stack++] =3D I; \
+	} while (0)
+
+#define PEAK_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack =3D=3D 0) \
+			_ret =3D -1; \
+		else \
+			_ret =3D stack[cur_stack - 1]; \
+		_ret; \
+	 })
+
+#define POP_INT() \
+	({ \
+		int _ret; \
+		if (cur_stack =3D=3D 0) \
+			_ret =3D -1; \
+		else \
+			_ret =3D stack[--cur_stack]; \
+		_ret; \
+	 })
+
+#define PUSH_INSN(T, W, E) \
+	do { \
+		int w =3D W; \
+		if (E =3D=3D 1 && st[T] >=3D 2) \
+			break; \
+		if (E =3D=3D 2 && st[T] >=3D 3) \
+			break; \
+		if (w >=3D insn_cnt) { \
+			ret =3D -EACCES; \
+			goto free_st; \
+		} \
+		if (E =3D=3D 2) \
+			/* mark branch target for state pruning */ \
+			env->branch_landing[w] =3D STATE_END; \
+		if (st[w] =3D=3D 0) { \
+			/* tree-edge */ \
+			st[T] =3D 1 + E; \
+			st[w] =3D 1; /* discovered */ \
+			PUSH_INT(w); \
+			goto peak_stack; \
+		} else if (st[w] =3D=3D 1 || st[w] =3D=3D 2 || st[w] =3D=3D 3) { \
+			pr_err("back-edge from insn %d to %d\n", t, w); \
+			ret =3D -EINVAL; \
+			goto free_st; \
+		} else if (st[w] =3D=3D 4) { \
+			/* forward- or cross-edge */ \
+			st[T] =3D 1 + E; \
+		} else { \
+			pr_err("insn state internal bug\n"); \
+			ret =3D -EFAULT; \
+			goto free_st; \
+		} \
+	} while (0)
+
+/* non-recursive depth-first-search to detect loops in BPF program
+ * loop =3D=3D back-edge in directed graph
+ */
+static int check_cfg(struct verifier_env *env, struct bpf_insn *insns,
+		     int insn_cnt)
+{
+	int cur_stack =3D 0;
+	int *stack;
+	int ret =3D 0;
+	int *st;
+	int i, t;
+
+	if (insns[insn_cnt - 1].code !=3D (BPF_RET | BPF_K)) {
+		pr_err("last insn is not a 'ret'\n");
+		return -EINVAL;
+	}
+
+	st =3D kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!st)
+		return -ENOMEM;
+
+	stack =3D kzalloc(sizeof(int) * insn_cnt, GFP_KERNEL);
+	if (!stack) {
+		kfree(st);
+		return -ENOMEM;
+	}
+
+	st[0] =3D 1; /* mark 1st insn as discovered */
+	PUSH_INT(0);
+
+peak_stack:
+	while ((t =3D PEAK_INT()) !=3D -1) {
+		if (t =3D=3D insn_cnt - 1)
+			goto mark_explored;
+
+		if (BPF_CLASS(insns[t].code) =3D=3D BPF_RET) {
+			pr_err("extraneous 'ret'\n");
+			ret =3D -EINVAL;
+			goto free_st;
+		}
+
+		if (BPF_CLASS(insns[t].code) =3D=3D BPF_JMP) {
+			u16 opcode =3D BPF_OP(insns[t].code);
+			if (opcode =3D=3D BPF_CALL) {
+				PUSH_INSN(t, t + 1, 1);
+			} else if (opcode =3D=3D BPF_JA) {
+				if (BPF_SRC(insns[t].code) !=3D BPF_X) {
+					ret =3D -EINVAL;
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
+		st[t] =3D 4; /* explored */
+		if (POP_INT() =3D=3D -1) {
+			pr_err("pop_int internal bug\n");
+			ret =3D -EFAULT;
+			goto free_st;
+		}
+	}
+
+
+	for (i =3D 0; i < insn_cnt; i++) {
+		if (st[i] !=3D 4) {
+			pr_err("unreachable insn %d\n", i);
+			ret =3D -EINVAL;
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
+	sl =3D env->branch_landing[insn_idx];
+	if (!sl)
+		/* no branch jump to this insn, ignore it */
+		return 0;
+
+	while (sl !=3D STATE_END) {
+		if (memcmp(&sl->state, &env->cur_state,
+			   sizeof(env->cur_state)) =3D=3D 0)
+			/* reached the same register/stack state,
+			 * prune the search
+			 */
+			return 1;
+		sl =3D sl->next;
+	}
+	new_sl =3D kmalloc(sizeof(struct verifier_state_list), GFP_KERNEL);
+
+	if (!new_sl)
+		/* ignore kmalloc error, since it's rare and doesn't affect
+		 * correctness of algorithm
+		 */
+		return 0;
+	/* add new state to the head of linked list */
+	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	new_sl->next =3D env->branch_landing[insn_idx];
+	env->branch_landing[insn_idx] =3D new_sl;
+	return 0;
+}
+
+static int __bpf_check(struct verifier_env *env, struct bpf_insn *insn=
s,
+		       int insn_cnt)
+{
+	int insn_idx;
+	int insn_processed =3D 0;
+	struct verifier_state *state =3D &env->cur_state;
+	struct reg_state *regs =3D state->regs;
+
+	init_reg_state(regs);
+	insn_idx =3D 0;
+	for (;;) {
+		struct bpf_insn *insn;
+		u16 class;
+
+		if (insn_idx >=3D insn_cnt) {
+			pr_err("invalid insn idx %d insn_cnt %d\n",
+			       insn_idx, insn_cnt);
+			return -EFAULT;
+		}
+
+		insn =3D &insns[insn_idx];
+		class =3D BPF_CLASS(insn->code);
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
+		if (class =3D=3D BPF_ALU) {
+			_(check_alu_op(regs, insn));
+
+		} else if (class =3D=3D BPF_LDX) {
+			if (BPF_MODE(insn->code) !=3D BPF_REL)
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
+		} else if (class =3D=3D BPF_STX) {
+			/* check src1 operand */
+			_(check_reg_arg(regs, insn->x_reg, 1));
+			/* check src2 operand */
+			_(check_reg_arg(regs, insn->a_reg, 1));
+			_(check_mem_access(env, insn->a_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   insn->x_reg));
+
+		} else if (class =3D=3D BPF_ST) {
+			if (BPF_MODE(insn->code) !=3D BPF_REL)
+				return -EINVAL;
+			/* check src operand */
+			_(check_reg_arg(regs, insn->a_reg, 1));
+			_(check_mem_access(env, insn->a_reg, insn->off,
+					   BPF_SIZE(insn->code), BPF_WRITE,
+					   -1));
+
+		} else if (class =3D=3D BPF_JMP) {
+			u16 opcode =3D BPF_OP(insn->code);
+			if (opcode =3D=3D BPF_CALL) {
+				_(check_call(env, insn->imm));
+			} else if (opcode =3D=3D BPF_JA) {
+				if (BPF_SRC(insn->code) !=3D BPF_X)
+					return -EINVAL;
+				insn_idx +=3D insn->off + 1;
+				continue;
+			} else {
+				_(check_cond_jmp_op(env, insn, insn_idx));
+			}
+
+		} else if (class =3D=3D BPF_RET) {
+process_ret:
+			insn_idx =3D pop_stack(env);
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
+	for (i =3D 0; i < insn_cnt; i++) {
+		struct verifier_state_list *sl =3D env->branch_landing[i];
+		if (sl)
+			while (sl !=3D STATE_END) {
+				struct verifier_state_list *sln =3D sl->next;
+				kfree(sl);
+				sl =3D sln;
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
+	if (prog->insn_cnt <=3D 0 || prog->insn_cnt > 32768 ||
+	    prog->table_cnt < 0 || prog->table_cnt > 128) {
+		pr_err("BPF program has %d insn and %d tables. Max is 32K/128\n",
+		       prog->insn_cnt, prog->table_cnt);
+		return -E2BIG;
+	}
+
+	env =3D kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	env->tables =3D prog->tables;
+	env->table_cnt =3D prog->table_cnt;
+	env->get_func_proto =3D prog->cb->get_func_proto;
+	env->get_context_access =3D prog->cb->get_context_access;
+	env->branch_landing =3D kzalloc(sizeof(struct verifier_state_list *) =
*
+				      prog->insn_cnt, GFP_KERNEL);
+
+	if (!env->branch_landing) {
+		kfree(env);
+		return -ENOMEM;
+	}
+
+	ret =3D check_cfg(env, prog->insns, prog->insn_cnt);
+	if (ret)
+		goto free_env;
+	ret =3D __bpf_check(env, prog->insns, prog->insn_cnt);
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
+static const char *const bpf_class_string[] =3D {
+	"ld", "ldx", "st", "stx", "alu", "jmp", "ret", "misc"
+};
+
+static const char *const bpf_alu_string[] =3D {
+	"+=3D", "-=3D", "*=3D", "/=3D", "|=3D", "&=3D", "<<=3D", ">>=3D", "ne=
g",
+	"%=3D", "^=3D", "=3D", "s>>=3D", "bswap32", "bswap64", "BUG"
+};
+
+static const char *const bpf_ldst_string[] =3D {
+	"u32", "u16", "u8", "u64"
+};
+
+static const char *const bpf_jmp_string[] =3D {
+	"jmp", "=3D=3D", ">", ">=3D", "&", "!=3D", "s>", "s>=3D", "call"
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
+	u16 class =3D BPF_CLASS(insn->code);
+	if (class =3D=3D BPF_ALU) {
+		if (BPF_SRC(insn->code) =3D=3D BPF_X)
+			pr_debug("code_%02x r%d%s %s r%d%s\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_alu_string[BPF_OP(insn->code) >> 4],
+				 insn->x_reg, R(insn->x_reg));
+		else
+			pr_debug("code_%02x r%d%s %s %d\n",
+				 insn->code, insn->a_reg, R(insn->a_reg),
+				 bpf_alu_string[BPF_OP(insn->code) >> 4],
+				 insn->imm);
+	} else if (class =3D=3D BPF_STX) {
+		if (BPF_MODE(insn->code) =3D=3D BPF_REL)
+			pr_debug("code_%02x *(%s *)(r%d%s %+d) =3D r%d%s\n",
+				 insn->code,
+				 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				 insn->a_reg, R(insn->a_reg),
+				 insn->off, insn->x_reg, R(insn->x_reg));
+		else if (BPF_MODE(insn->code) =3D=3D BPF_XADD)
+			pr_debug("code_%02x lock *(%s *)(r%d%s %+d) +=3D r%d%s\n",
+				 insn->code,
+				 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+				 insn->a_reg, R(insn->a_reg), insn->off,
+				 insn->x_reg, R(insn->x_reg));
+		else
+			pr_debug("BUG_%02x\n", insn->code);
+	} else if (class =3D=3D BPF_ST) {
+		if (BPF_MODE(insn->code) !=3D BPF_REL) {
+			pr_debug("BUG_st_%02x\n", insn->code);
+			return;
+		}
+		pr_debug("code_%02x *(%s *)(r%d%s %+d) =3D %d\n",
+			 insn->code,
+			 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			 insn->a_reg, R(insn->a_reg),
+			 insn->off, insn->imm);
+	} else if (class =3D=3D BPF_LDX) {
+		if (BPF_MODE(insn->code) !=3D BPF_REL) {
+			pr_debug("BUG_ldx_%02x\n", insn->code);
+			return;
+		}
+		pr_debug("code_%02x r%d =3D *(%s *)(r%d%s %+d)\n",
+			 insn->code, insn->a_reg,
+			 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
+			 insn->x_reg, R(insn->x_reg), insn->off);
+	} else if (class =3D=3D BPF_JMP) {
+		u16 opcode =3D BPF_OP(insn->code);
+		if (opcode =3D=3D BPF_CALL) {
+			pr_debug("code_%02x call %d\n", insn->code, insn->imm);
+		} else if (insn->code =3D=3D (BPF_JMP | BPF_JA | BPF_X)) {
+			pr_debug("code_%02x goto pc%+d\n",
+				 insn->code, insn->off);
+		} else if (BPF_SRC(insn->code) =3D=3D BPF_X) {
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
+	struct bpf_insn *insn =3D prog->insns;
+	u64 stack[64];
+	u64 regs[16] =3D { };
+	regs[__fp__] =3D (u64) &stack[64];
+	regs[R1] =3D (u64) ctx;
+
+	for (;; insn++) {
+		const s32 K =3D insn->imm;
+		u64 *a_reg =3D &regs[insn->a_reg];
+		u64 *x_reg =3D &regs[insn->x_reg];
+#define A (*a_reg)
+#define X (*x_reg)
+		/*pr_debug_bpf_insn(insn, regs);*/
+		switch (insn->code) {
+			/* ALU */
+		case BPF_ALU | BPF_ADD | BPF_X:
+			A +=3D X;
+			continue;
+		case BPF_ALU | BPF_ADD | BPF_K:
+			A +=3D K;
+			continue;
+		case BPF_ALU | BPF_SUB | BPF_X:
+			A -=3D X;
+			continue;
+		case BPF_ALU | BPF_SUB | BPF_K:
+			A -=3D K;
+			continue;
+		case BPF_ALU | BPF_AND | BPF_X:
+			A &=3D X;
+			continue;
+		case BPF_ALU | BPF_AND | BPF_K:
+			A &=3D K;
+			continue;
+		case BPF_ALU | BPF_OR | BPF_X:
+			A |=3D X;
+			continue;
+		case BPF_ALU | BPF_OR | BPF_K:
+			A |=3D K;
+			continue;
+		case BPF_ALU | BPF_LSH | BPF_X:
+			A <<=3D X;
+			continue;
+		case BPF_ALU | BPF_LSH | BPF_K:
+			A <<=3D K;
+			continue;
+		case BPF_ALU | BPF_RSH | BPF_X:
+			A >>=3D X;
+			continue;
+		case BPF_ALU | BPF_RSH | BPF_K:
+			A >>=3D K;
+			continue;
+		case BPF_ALU | BPF_MOV | BPF_X:
+			A =3D X;
+			continue;
+		case BPF_ALU | BPF_MOV | BPF_K:
+			A =3D K;
+			continue;
+		case BPF_ALU | BPF_ARSH | BPF_X:
+			(*(s64 *) &A) >>=3D X;
+			continue;
+		case BPF_ALU | BPF_ARSH | BPF_K:
+			(*(s64 *) &A) >>=3D K;
+			continue;
+		case BPF_ALU | BPF_BSWAP32 | BPF_X:
+			A =3D __builtin_bswap32(A);
+			continue;
+		case BPF_ALU | BPF_BSWAP64 | BPF_X:
+			A =3D __builtin_bswap64(A);
+			continue;
+		case BPF_ALU | BPF_MOD | BPF_X:
+			A %=3D X;
+			continue;
+		case BPF_ALU | BPF_MOD | BPF_K:
+			A %=3D K;
+			continue;
+
+			/* CALL */
+		case BPF_JMP | BPF_CALL:
+			prog->cb->execute_func(K, regs);
+			continue;
+
+			/* JMP */
+		case BPF_JMP | BPF_JA | BPF_X:
+			insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JEQ | BPF_X:
+			if (A =3D=3D X)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JEQ | BPF_K:
+			if (A =3D=3D K)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JNE | BPF_X:
+			if (A !=3D X)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JNE | BPF_K:
+			if (A !=3D K)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JGT | BPF_X:
+			if (A > X)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JGT | BPF_K:
+			if (A > K)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JGE | BPF_X:
+			if (A >=3D X)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JGE | BPF_K:
+			if (A >=3D K)
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGT | BPF_X:
+			if (((s64)A) > ((s64)X))
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGT | BPF_K:
+			if (((s64)A) > ((s64)K))
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGE | BPF_X:
+			if (((s64)A) >=3D ((s64)X))
+				insn +=3D insn->off;
+			continue;
+		case BPF_JMP | BPF_JSGE | BPF_K:
+			if (((s64)A) >=3D ((s64)K))
+				insn +=3D insn->off;
+			continue;
+
+			/* STX */
+		case BPF_STX | BPF_REL | BPF_B:
+			*(u8 *)(A + insn->off) =3D X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_H:
+			*(u16 *)(A + insn->off) =3D X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_W:
+			*(u32 *)(A + insn->off) =3D X;
+			continue;
+		case BPF_STX | BPF_REL | BPF_DW:
+			*(u64 *)(A + insn->off) =3D X;
+			continue;
+
+			/* ST */
+		case BPF_ST | BPF_REL | BPF_B:
+			*(u8 *)(A + insn->off) =3D K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_H:
+			*(u16 *)(A + insn->off) =3D K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_W:
+			*(u32 *)(A + insn->off) =3D K;
+			continue;
+		case BPF_ST | BPF_REL | BPF_DW:
+			*(u64 *)(A + insn->off) =3D K;
+			continue;
+
+			/* LDX */
+		case BPF_LDX | BPF_REL | BPF_B:
+			A =3D *(u8 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_H:
+			A =3D *(u16 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_W:
+			A =3D *(u32 *)(X + insn->off);
+			continue;
+		case BPF_LDX | BPF_REL | BPF_DW:
+			A =3D *(u64 *)(X + insn->off);
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
+	if (image->insn_cnt <=3D 0 || image->insn_cnt > 32768 ||
+	    image->table_cnt < 0 || image->table_cnt > 128) {
+		pr_err("BPF program has %d insn and %d tables. Max is 32K/128\n",
+		       image->insn_cnt, image->table_cnt);
+		return -E2BIG;
+	}
+
+	prog =3D kzalloc(sizeof(struct bpf_program), GFP_KERNEL);
+	if (!prog)
+		return -ENOMEM;
+
+	prog->insn_cnt =3D image->insn_cnt;
+	prog->table_cnt =3D image->table_cnt;
+	prog->cb =3D cb;
+
+	prog->insns =3D kmalloc(sizeof(struct bpf_insn) * prog->insn_cnt,
+			      GFP_KERNEL);
+	if (!prog->insns) {
+		ret =3D -ENOMEM;
+		goto free_prog;
+	}
+
+	prog->tables =3D kmalloc(sizeof(struct bpf_table) * prog->table_cnt,
+			       GFP_KERNEL);
+	if (!prog->tables) {
+		ret =3D -ENOMEM;
+		goto free_insns;
+	}
+
+	if (copy_from_user(prog->insns, image->insns,
+			   sizeof(struct bpf_insn) * prog->insn_cnt)) {
+		ret =3D -EFAULT;
+		goto free_tables;
+	}
+
+	if (copy_from_user(prog->tables, image->tables,
+			   sizeof(struct bpf_table) * prog->table_cnt)) {
+		ret =3D -EFAULT;
+		goto free_tables;
+	}
+
+	/* verify BPF program */
+	ret =3D bpf_check(prog);
+	if (ret)
+		goto free_tables;
+
+	/* JIT it */
+	bpf2_jit_compile(prog);
+
+	*p_prog =3D prog;
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
--=20
1.7.9.5
