From: Matt Evans <matt@ozlabs.org>
Subject: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 12:13:59 +1000
Message-ID: <4E24E867.9050909@ozlabs.org>
References: <4E23E5C3.1070209@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59626 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab1GSCNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 22:13:32 -0400
In-Reply-To: <4E23E5C3.1070209@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An implementation of a code generator for BPF programs to speed up packet
filtering on PPC64, inspired by Eric Dumazet's x86-64 version.

Filter code is generated as an ABI-compliant function in module_alloc()'d mem
with stackframe & prologue/epilogue generated if required (simple filters don't
need anything more than an li/blr).  The filter's local variables, M[], live in
registers.  Supports all BPF opcodes, although "complicated" loads from negative
packet offsets (e.g. SKF_LL_OFF) are not yet supported.

There are a couple of further optimisations left for future work; many-pass
assembly with branch-reach reduction and a register allocator to push M[]
variables into volatile registers would improve the code quality further.

This currently supports big-endian 64-bit PowerPC only (but is fairly simple
to port to PPC32 or LE!).

Enabled in the same way as x86-64:

	echo 1 > /proc/sys/net/core/bpf_jit_enable

Or, enabled with extra debug output:

	echo 2 > /proc/sys/net/core/bpf_jit_enable

Signed-off-by: Matt Evans <matt@ozlabs.org>
---

V2: Removed some cut/paste woe in setting SEEN_X even on writes.
    Merci for le review, Eric!

 arch/powerpc/Kconfig                  |    1 +
 arch/powerpc/Makefile                 |    3 +-
 arch/powerpc/include/asm/ppc-opcode.h |   40 ++
 arch/powerpc/net/Makefile             |    4 +
 arch/powerpc/net/bpf_jit.S            |  138 +++++++
 arch/powerpc/net/bpf_jit.h            |  227 +++++++++++
 arch/powerpc/net/bpf_jit_comp.c       |  690 +++++++++++++++++++++++++++++++++
 7 files changed, 1102 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2729c66..39860fc 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -134,6 +134,7 @@ config PPC
 	select GENERIC_IRQ_SHOW_LEVEL
 	select HAVE_RCU_TABLE_FREE if SMP
 	select HAVE_SYSCALL_TRACEPOINTS
+	select HAVE_BPF_JIT if PPC64
 
 config EARLY_PRINTK
 	bool
diff --git a/arch/powerpc/Makefile b/arch/powerpc/Makefile
index b7212b6..b94740f 100644
--- a/arch/powerpc/Makefile
+++ b/arch/powerpc/Makefile
@@ -154,7 +154,8 @@ core-y				+= arch/powerpc/kernel/ \
 				   arch/powerpc/lib/ \
 				   arch/powerpc/sysdev/ \
 				   arch/powerpc/platforms/ \
-				   arch/powerpc/math-emu/
+				   arch/powerpc/math-emu/ \
+				   arch/powerpc/net/
 core-$(CONFIG_XMON)		+= arch/powerpc/xmon/
 core-$(CONFIG_KVM) 		+= arch/powerpc/kvm/
 
diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index e472659..e980faa 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -71,6 +71,42 @@
 #define PPC_INST_ERATSX			0x7c000126
 #define PPC_INST_ERATSX_DOT		0x7c000127
 
+/* Misc instructions for BPF compiler */
+#define PPC_INST_LD			0xe8000000
+#define PPC_INST_LHZ			0xa0000000
+#define PPC_INST_LWZ			0x80000000
+#define PPC_INST_STD			0xf8000000
+#define PPC_INST_STDU			0xf8000001
+#define PPC_INST_MFLR			0x7c0802a6
+#define PPC_INST_MTLR			0x7c0803a6
+#define PPC_INST_CMPWI			0x2c000000
+#define PPC_INST_CMPDI			0x2c200000
+#define PPC_INST_CMPLW			0x7c000040
+#define PPC_INST_CMPLWI			0x28000000
+#define PPC_INST_ADDI			0x38000000
+#define PPC_INST_ADDIS			0x3c000000
+#define PPC_INST_ADD			0x7c000214
+#define PPC_INST_SUB			0x7c000050
+#define PPC_INST_BLR			0x4e800020
+#define PPC_INST_BLRL			0x4e800021
+#define PPC_INST_MULLW			0x7c0001d6
+#define PPC_INST_MULHWU			0x7c000016
+#define PPC_INST_MULLI			0x1c000000
+#define PPC_INST_DIVWU			0x7c0003d6
+#define PPC_INST_RLWINM			0x54000000
+#define PPC_INST_RLDICR			0x78000004
+#define PPC_INST_SLW			0x7c000030
+#define PPC_INST_SRW			0x7c000430
+#define PPC_INST_AND			0x7c000038
+#define PPC_INST_ANDDOT			0x7c000039
+#define PPC_INST_OR			0x7c000378
+#define PPC_INST_ANDI			0x70000000
+#define PPC_INST_ORI			0x60000000
+#define PPC_INST_ORIS			0x64000000
+#define PPC_INST_NEG			0x7c0000d0
+#define PPC_INST_BRANCH			0x48000000
+#define PPC_INST_BRANCH_COND		0x40800000
+
 /* macros to insert fields into opcodes */
 #define __PPC_RA(a)	(((a) & 0x1f) << 16)
 #define __PPC_RB(b)	(((b) & 0x1f) << 11)
@@ -83,6 +119,10 @@
 #define __PPC_T_TLB(t)	(((t) & 0x3) << 21)
 #define __PPC_WC(w)	(((w) & 0x3) << 21)
 #define __PPC_WS(w)	(((w) & 0x1f) << 11)
+#define __PPC_SH(s)	__PPC_WS(s)
+#define __PPC_MB(s)	(((s) & 0x1f) << 6)
+#define __PPC_ME(s)	(((s) & 0x1f) << 1)
+#define __PPC_BI(s)	(((s) & 0x1f) << 16)
 
 /*
  * Only use the larx hint bit on 64bit CPUs. e500v1/v2 based CPUs will treat a
diff --git a/arch/powerpc/net/Makefile b/arch/powerpc/net/Makefile
new file mode 100644
index 0000000..90568c3
--- /dev/null
+++ b/arch/powerpc/net/Makefile
@@ -0,0 +1,4 @@
+#
+# Arch-specific network modules
+#
+obj-$(CONFIG_BPF_JIT) += bpf_jit.o bpf_jit_comp.o
diff --git a/arch/powerpc/net/bpf_jit.S b/arch/powerpc/net/bpf_jit.S
new file mode 100644
index 0000000..ff4506e
--- /dev/null
+++ b/arch/powerpc/net/bpf_jit.S
@@ -0,0 +1,138 @@
+/* bpf_jit.S: Packet/header access helper functions
+ * for PPC64 BPF compiler.
+ *
+ * Copyright 2011 Matt Evans <matt@ozlabs.org>, IBM Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <asm/ppc_asm.h>
+#include "bpf_jit.h"
+
+/*
+ * All of these routines are called directly from generated code,
+ * whose register usage is:
+ *
+ * r3		skb
+ * r4,r5	A,X
+ * r6		*** address parameter to helper ***
+ * r7-r10	scratch
+ * r14		skb->data
+ * r15		skb headlen
+ * r16-31	M[]
+ */
+
+/*
+ * To consider: These helpers are so small it could be better to just
+ * generate them inline.  Inline code can do the simple headlen check
+ * then branch directly to slow_path_XXX if required.  (In fact, could
+ * load a spare GPR with the address of slow_path_generic and pass size
+ * as an argument, making the call site a mtlr, li and bllr.)
+ *
+ * Technically, the "is addr < 0" check is unnecessary & slowing down
+ * the ABS path, as it's statically checked on generation.
+ */
+	.globl	sk_load_word
+sk_load_word:
+	cmpdi	r_addr, 0
+	blt	bpf_error
+	/* Are we accessing past headlen? */
+	subi	r_scratch1, r_HL, 4
+	cmpd	r_scratch1, r_addr
+	blt	bpf_slow_path_word
+	/* Nope, just hitting the header.  cr0 here is eq or gt! */
+	lwzx	r_A, r_D, r_addr
+	/* When big endian we don't need to byteswap. */
+	blr	/* Return success, cr0 != LT */
+
+	.globl	sk_load_half
+sk_load_half:
+	cmpdi	r_addr, 0
+	blt	bpf_error
+	subi	r_scratch1, r_HL, 2
+	cmpd	r_scratch1, r_addr
+	blt	bpf_slow_path_half
+	lhzx	r_A, r_D, r_addr
+	blr
+
+	.globl	sk_load_byte
+sk_load_byte:
+	cmpdi	r_addr, 0
+	blt	bpf_error
+	cmpd	r_HL, r_addr
+	ble	bpf_slow_path_byte
+	lbzx	r_A, r_D, r_addr
+	blr
+
+/*
+ * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * r_addr is the offset value, already known positive
+ */
+	.globl sk_load_byte_msh
+sk_load_byte_msh:
+	cmpd	r_HL, r_addr
+	ble	bpf_slow_path_byte_msh
+	lbzx	r_X, r_D, r_addr
+	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
+	blr
+
+bpf_error:
+	/* Entered with cr0 = lt */
+	li	r3, 0
+	/* Generated code will 'blt epilogue', returning 0. */
+	blr
+
+/* Call out to skb_copy_bits:
+ * We'll need to back up our volatile regs first; we have
+ * local variable space at r1+(BPF_PPC_STACK_BASIC).
+ * Allocate a new stack frame here to remain ABI-compliant in
+ * stashing LR.
+ */
+#define bpf_slow_path_common(SIZE)				\
+	mflr	r0;						\
+	std	r0, 16(r1);					\
+	/* R3 goes in parameter space of caller's frame */	\
+	std	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	std	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	std	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	addi	r5, r1, BPF_PPC_STACK_BASIC+(2*8);		\
+	stdu	r1, -BPF_PPC_SLOWPATH_FRAME(r1);		\
+	/* R3 = r_skb, as passed */				\
+	mr	r4, r_addr;					\
+	li	r6, SIZE;					\
+	bl	skb_copy_bits;					\
+	/* R3 = 0 on success */					\
+	addi	r1, r1, BPF_PPC_SLOWPATH_FRAME;			\
+	ld	r0, 16(r1);					\
+	ld	r_A, (BPF_PPC_STACK_BASIC+(0*8))(r1);		\
+	ld	r_X, (BPF_PPC_STACK_BASIC+(1*8))(r1);		\
+	mtlr	r0;						\
+	cmpdi	r3, 0;						\
+	blt	bpf_error;	/* cr0 = LT */			\
+	ld	r_skb, (BPF_PPC_STACKFRAME+48)(r1);		\
+	/* Great success! */
+
+bpf_slow_path_word:
+	bpf_slow_path_common(4)
+	/* Data value is on stack, and cr0 != LT */
+	lwz	r_A, BPF_PPC_STACK_BASIC+(2*8)(r1)
+	blr
+
+bpf_slow_path_half:
+	bpf_slow_path_common(2)
+	lhz	r_A, BPF_PPC_STACK_BASIC+(2*8)(r1)
+	blr
+
+bpf_slow_path_byte:
+	bpf_slow_path_common(1)
+	lbz	r_A, BPF_PPC_STACK_BASIC+(2*8)(r1)
+	blr
+
+bpf_slow_path_byte_msh:
+	bpf_slow_path_common(1)
+	lbz	r_X, BPF_PPC_STACK_BASIC+(2*8)(r1)
+	rlwinm	r_X, r_X, 2, 32-4-2, 31-2
+	blr
diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
new file mode 100644
index 0000000..af1ab5e
--- /dev/null
+++ b/arch/powerpc/net/bpf_jit.h
@@ -0,0 +1,227 @@
+/* bpf_jit.h: BPF JIT compiler for PPC64
+ *
+ * Copyright 2011 Matt Evans <matt@ozlabs.org>, IBM Corporation
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#ifndef _BPF_JIT_H
+#define _BPF_JIT_H
+
+#define BPF_PPC_STACK_LOCALS	32
+#define BPF_PPC_STACK_BASIC	(48+64)
+#define BPF_PPC_STACK_SAVE	(18*8)
+#define BPF_PPC_STACKFRAME	(BPF_PPC_STACK_BASIC+BPF_PPC_STACK_LOCALS+ \
+				 BPF_PPC_STACK_SAVE)
+#define BPF_PPC_SLOWPATH_FRAME	(48+64)
+
+/*
+ * Generated code register usage:
+ *
+ * As normal PPC C ABI (e.g. r1=sp, r2=TOC), with:
+ *
+ * skb		r3	(Entry parameter)
+ * A register	r4
+ * X register	r5
+ * addr param	r6
+ * r7-r10	scratch
+ * skb->data	r14
+ * skb headlen	r15	(skb->len - skb->data_len)
+ * m[0]		r16
+ * m[...]	...
+ * m[15]	r31
+ */
+#define r_skb		3
+#define r_ret		3
+#define r_A		4
+#define r_X		5
+#define r_addr		6
+#define r_scratch1	7
+#define r_D		14
+#define r_HL		15
+#define r_M		16
+
+#ifndef __ASSEMBLY__
+
+/*
+ * Assembly helpers from arch/powerpc/net/bpf_jit.S:
+ */
+extern u8 sk_load_word[], sk_load_half[], sk_load_byte[], sk_load_byte_msh[];
+
+#define FUNCTION_DESCR_SIZE	24
+
+/*
+ * 16-bit immediate helper macros: HA() is for use with sign-extending instrs
+ * (e.g. LD, ADDI).  If the bottom 16 bits is "-ve", add another bit into the
+ * top half to negate the effect (i.e. 0xffff + 1 = 0x(1)0000).
+ */
+#define IMM_H(i)		((uintptr_t)(i)>>16)
+#define IMM_HA(i)		(((uintptr_t)(i)>>16) +			      \
+				 (((uintptr_t)(i) & 0x8000) >> 15))
+#define IMM_L(i)		((uintptr_t)(i) & 0xffff)
+
+#define PLANT_INSTR(d, idx, instr)					      \
+	do { if (d) { (d)[idx] = instr; } idx++; } while (0)
+#define EMIT(instr)		PLANT_INSTR(image, ctx->idx, instr)
+
+#define PPC_NOP()		EMIT(PPC_INST_NOP)
+#define PPC_BLR()		EMIT(PPC_INST_BLR)
+#define PPC_BLRL()		EMIT(PPC_INST_BLRL)
+#define PPC_MTLR(r)		EMIT(PPC_INST_MTLR | __PPC_RT(r))
+#define PPC_ADDI(d, a, i)	EMIT(PPC_INST_ADDI | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | IMM_L(i))
+#define PPC_MR(d, a)		PPC_OR(d, a, a)
+#define PPC_LI(r, i)		PPC_ADDI(r, 0, i)
+#define PPC_ADDIS(d, a, i)	EMIT(PPC_INST_ADDIS |			      \
+				     __PPC_RS(d) | __PPC_RA(a) | IMM_L(i))
+#define PPC_LIS(r, i)		PPC_ADDIS(r, 0, i)
+#define PPC_STD(r, base, i)	EMIT(PPC_INST_STD | __PPC_RS(r) |	      \
+				     __PPC_RA(base) | ((i) & 0xfffc))
+
+#define PPC_LD(r, base, i)	EMIT(PPC_INST_LD | __PPC_RT(r) |	      \
+				     __PPC_RA(base) | IMM_L(i))
+#define PPC_LWZ(r, base, i)	EMIT(PPC_INST_LWZ | __PPC_RT(r) |	      \
+				     __PPC_RA(base) | IMM_L(i))
+#define PPC_LHZ(r, base, i)	EMIT(PPC_INST_LHZ | __PPC_RT(r) |	      \
+				     __PPC_RA(base) | IMM_L(i))
+/* Convenience helpers for the above with 'far' offsets: */
+#define PPC_LD_OFFS(r, base, i) do { if ((i) < 32768) PPC_LD(r, base, i);     \
+		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
+			PPC_LD(r, r, IMM_L(i)); } } while(0)
+
+#define PPC_LWZ_OFFS(r, base, i) do { if ((i) < 32768) PPC_LWZ(r, base, i);   \
+		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
+			PPC_LWZ(r, r, IMM_L(i)); } } while(0)
+
+#define PPC_LHZ_OFFS(r, base, i) do { if ((i) < 32768) PPC_LHZ(r, base, i);   \
+		else {	PPC_ADDIS(r, base, IMM_HA(i));			      \
+			PPC_LHZ(r, r, IMM_L(i)); } } while(0)
+
+#define PPC_CMPWI(a, i)		EMIT(PPC_INST_CMPWI | __PPC_RA(a) | IMM_L(i))
+#define PPC_CMPDI(a, i)		EMIT(PPC_INST_CMPDI | __PPC_RA(a) | IMM_L(i))
+#define PPC_CMPLWI(a, i)	EMIT(PPC_INST_CMPLWI | __PPC_RA(a) | IMM_L(i))
+#define PPC_CMPLW(a, b)		EMIT(PPC_INST_CMPLW | __PPC_RA(a) | __PPC_RB(b))
+
+#define PPC_SUB(d, a, b)	EMIT(PPC_INST_SUB | __PPC_RT(d) |	      \
+				     __PPC_RB(a) | __PPC_RA(b))
+#define PPC_ADD(d, a, b)	EMIT(PPC_INST_ADD | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | __PPC_RB(b))
+#define PPC_MUL(d, a, b)	EMIT(PPC_INST_MULLW | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | __PPC_RB(b))
+#define PPC_MULHWU(d, a, b)	EMIT(PPC_INST_MULHWU | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | __PPC_RB(b))
+#define PPC_MULI(d, a, i)	EMIT(PPC_INST_MULLI | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | IMM_L(i))
+#define PPC_DIVWU(d, a, b)	EMIT(PPC_INST_DIVWU | __PPC_RT(d) |	      \
+				     __PPC_RA(a) | __PPC_RB(b))
+#define PPC_AND(d, a, b)	EMIT(PPC_INST_AND | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_RB(b))
+#define PPC_ANDI(d, a, i)	EMIT(PPC_INST_ANDI | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | IMM_L(i))
+#define PPC_AND_DOT(d, a, b)	EMIT(PPC_INST_ANDDOT | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_RB(b))
+#define PPC_OR(d, a, b)		EMIT(PPC_INST_OR | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_RB(b))
+#define PPC_ORI(d, a, i)	EMIT(PPC_INST_ORI | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | IMM_L(i))
+#define PPC_ORIS(d, a, i)	EMIT(PPC_INST_ORIS | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | IMM_L(i))
+#define PPC_SLW(d, a, s)	EMIT(PPC_INST_SLW | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_RB(s))
+#define PPC_SRW(d, a, s)	EMIT(PPC_INST_SRW | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_RB(s))
+/* slwi = rlwinm Rx, Ry, n, 0, 31-n */
+#define PPC_SLWI(d, a, i)	EMIT(PPC_INST_RLWINM | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_SH(i) |	      \
+				     __PPC_MB(0) | __PPC_ME(31-(i)))
+/* srwi = rlwinm Rx, Ry, 32-n, n, 31 */
+#define PPC_SRWI(d, a, i)	EMIT(PPC_INST_RLWINM | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_SH(32-(i)) |	      \
+				     __PPC_MB(i) | __PPC_ME(31))
+/* sldi = rldicr Rx, Ry, n, 63-n */
+#define PPC_SLDI(d, a, i)	EMIT(PPC_INST_RLDICR | __PPC_RA(d) |	      \
+				     __PPC_RS(a) | __PPC_SH(i) |	      \
+				     __PPC_MB(63-(i)) | (((i) & 0x20) >> 4))
+#define PPC_NEG(d, a)		EMIT(PPC_INST_NEG | __PPC_RT(d) | __PPC_RA(a))
+
+/* Long jump; (unconditional 'branch') */
+#define PPC_JMP(dest)		EMIT(PPC_INST_BRANCH |			      \
+				     (((dest) - (ctx->idx * 4)) & 0x03fffffc))
+/* "cond" here covers BO:BI fields. */
+#define PPC_BCC_SHORT(cond, dest)	EMIT(PPC_INST_BRANCH_COND |	      \
+					     (((cond) & 0x3ff) << 16) |	      \
+					     (((dest) - (ctx->idx * 4)) &     \
+					      0xfffc))
+#define PPC_LI32(d, i)		do { PPC_LI(d, IMM_L(i));		      \
+		if ((u32)(uintptr_t)(i) >= 32768) {			      \
+			PPC_ADDIS(d, d, IMM_HA(i));			      \
+		} } while(0)
+#define PPC_LI64(d, i)		do {					      \
+		if (!((uintptr_t)(i) & 0xffffffff00000000ULL))		      \
+			PPC_LI32(d, i);					      \
+		else {							      \
+			PPC_LIS(d, ((uintptr_t)(i) >> 48));		      \
+			if ((uintptr_t)(i) & 0x0000ffff00000000ULL)	      \
+				PPC_ORI(d, d,				      \
+					((uintptr_t)(i) >> 32) & 0xffff);     \
+			PPC_SLDI(d, d, 32);				      \
+			if ((uintptr_t)(i) & 0x00000000ffff0000ULL)	      \
+				PPC_ORIS(d, d,				      \
+					 ((uintptr_t)(i) >> 16) & 0xffff);    \
+			if ((uintptr_t)(i) & 0x000000000000ffffULL)	      \
+				PPC_ORI(d, d, (uintptr_t)(i) & 0xffff);	      \
+		} } while (0);
+
+static inline bool is_nearbranch(int offset)
+{
+	return (offset < 32768) && (offset >= -32768);
+}
+
+/*
+ * The fly in the ointment of code size changing from pass to pass is
+ * avoided by padding the short branch case with a NOP.	 If code size differs
+ * with different branch reaches we will have the issue of code moving from
+ * one pass to the next and will need a few passes to converge on a stable
+ * state.
+ */
+#define PPC_BCC(cond, dest)	do {					      \
+		if (is_nearbranch((dest) - (ctx->idx * 4))) {		      \
+			PPC_BCC_SHORT(cond, dest);			      \
+			PPC_NOP();					      \
+		} else {						      \
+			/* Flip the 'T or F' bit to invert comparison */      \
+			PPC_BCC_SHORT(cond ^ COND_CMP_TRUE, (ctx->idx+2)*4);  \
+			PPC_JMP(dest);					      \
+		} } while(0)
+
+/* To create a branch condition, select a bit of cr0... */
+#define CR0_LT		0
+#define CR0_GT		1
+#define CR0_EQ		2
+/* ...and modify BO[3] */
+#define COND_CMP_TRUE	0x100
+#define COND_CMP_FALSE	0x000
+/* Together, they make all required comparisons: */
+#define COND_GT		(CR0_GT | COND_CMP_TRUE)
+#define COND_GE		(CR0_LT | COND_CMP_FALSE)
+#define COND_EQ		(CR0_EQ | COND_CMP_TRUE)
+#define COND_NE		(CR0_EQ | COND_CMP_FALSE)
+#define COND_LT		(CR0_LT | COND_CMP_TRUE)
+
+#define SEEN_DATAREF 0x10000 /* might call external helpers */
+#define SEEN_XREG    0x20000 /* X reg is used */
+#define SEEN_MEM     0x40000 /* SEEN_MEM+(1<<n) = use mem[n] for temporary
+			      * storage */
+#define SEEN_MEM_MSK 0x0ffff
+
+struct codegen_context {
+	unsigned int seen;
+	unsigned int idx;
+	int pc_ret0; /* bpf index of first RET #0 instruction (if any) */
+};
+
+#endif
+
+#endif
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
new file mode 100644
index 0000000..2cb2566
--- /dev/null
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -0,0 +1,690 @@
+/* bpf_jit_comp.c: BPF JIT compiler for PPC64
+ *
+ * Copyright 2011 Matt Evans <matt@ozlabs.org>, IBM Corporation
+ *
+ * Based on the x86 BPF compiler, by Eric Dumazet (eric.dumazet@gmail.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#include <linux/moduleloader.h>
+#include <asm/cacheflush.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include "bpf_jit.h"
+
+#ifndef __BIG_ENDIAN
+/* There are endianness assumptions herein. */
+#error "Little-endian PPC not supported in BPF compiler"
+#endif
+
+int bpf_jit_enable __read_mostly;
+
+
+static inline void bpf_flush_icache(void *start, void *end)
+{
+	smp_wmb();
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+}
+
+static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
+				   struct codegen_context *ctx)
+{
+	int i;
+	const struct sock_filter *filter = fp->insns;
+
+	if (ctx->seen & (SEEN_MEM | SEEN_DATAREF)) {
+		/* Make stackframe */
+		if (ctx->seen & SEEN_DATAREF) {
+			/* If we call any helpers (for loads), save LR */
+			EMIT(PPC_INST_MFLR | __PPC_RT(0));
+			PPC_STD(0, 1, 16);
+
+			/* Back up non-volatile regs. */
+			PPC_STD(r_D, 1, -(8*(32-r_D)));
+			PPC_STD(r_HL, 1, -(8*(32-r_HL)));
+		}
+		if (ctx->seen & SEEN_MEM) {
+			/*
+			 * Conditionally save regs r15-r31 as some will be used
+			 * for M[] data.
+			 */
+			for (i = r_M; i < (r_M+16); i++) {
+				if (ctx->seen & (1 << (i-r_M)))
+					PPC_STD(i, 1, -(8*(32-i)));
+			}
+		}
+		EMIT(PPC_INST_STDU | __PPC_RS(1) | __PPC_RA(1) |
+		     (-BPF_PPC_STACKFRAME & 0xfffc));
+	}
+
+	if (ctx->seen & SEEN_DATAREF) {
+		/*
+		 * If this filter needs to access skb data,
+		 * prepare r_D and r_HL:
+		 *  r_HL = skb->len - skb->data_len
+		 *  r_D	 = skb->data
+		 */
+		PPC_LWZ_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
+							 data_len));
+		PPC_LWZ_OFFS(r_HL, r_skb, offsetof(struct sk_buff, len));
+		PPC_SUB(r_HL, r_HL, r_scratch1);
+		PPC_LD_OFFS(r_D, r_skb, offsetof(struct sk_buff, data));
+	}
+
+	if (ctx->seen & SEEN_XREG) {
+		/*
+		 * TODO: Could also detect whether first instr. sets X and
+		 * avoid this (as below, with A).
+		 */
+		PPC_LI(r_X, 0);
+	}
+
+	switch (filter[0].code) {
+	case BPF_S_RET_K:
+	case BPF_S_LD_W_LEN:
+	case BPF_S_ANC_PROTOCOL:
+	case BPF_S_ANC_IFINDEX:
+	case BPF_S_ANC_MARK:
+	case BPF_S_ANC_RXHASH:
+	case BPF_S_ANC_CPU:
+	case BPF_S_ANC_QUEUE:
+	case BPF_S_LD_W_ABS:
+	case BPF_S_LD_H_ABS:
+	case BPF_S_LD_B_ABS:
+		/* first instruction sets A register (or is RET 'constant') */
+		break;
+	default:
+		/* make sure we dont leak kernel information to user */
+		PPC_LI(r_A, 0);
+	}
+}
+
+static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
+{
+	int i;
+
+	if (ctx->seen & (SEEN_MEM | SEEN_DATAREF)) {
+		PPC_ADDI(1, 1, BPF_PPC_STACKFRAME);
+		if (ctx->seen & SEEN_DATAREF) {
+			PPC_LD(0, 1, 16);
+			PPC_MTLR(0);
+			PPC_LD(r_D, 1, -(8*(32-r_D)));
+			PPC_LD(r_HL, 1, -(8*(32-r_HL)));
+		}
+		if (ctx->seen & SEEN_MEM) {
+			/* Restore any saved non-vol registers */
+			for (i = r_M; i < (r_M+16); i++) {
+				if (ctx->seen & (1 << (i-r_M)))
+					PPC_LD(i, 1, -(8*(32-i)));
+			}
+		}
+	}
+	/* The RETs have left a return value in R3. */
+
+	PPC_BLR();
+}
+
+/* Assemble the body code between the prologue & epilogue. */
+static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
+			      struct codegen_context *ctx,
+			      unsigned int *addrs)
+{
+	const struct sock_filter *filter = fp->insns;
+	int flen = fp->len;
+	u8 *func;
+	unsigned int true_cond;
+	int i;
+
+	/* Start of epilogue code */
+	unsigned int exit_addr = addrs[flen];
+
+	for (i = 0; i < flen; i++) {
+		unsigned int K = filter[i].k;
+
+		/*
+		 * addrs[] maps a BPF bytecode address into a real offset from
+		 * the start of the body code.
+		 */
+		addrs[i] = ctx->idx * 4;
+
+		switch (filter[i].code) {
+			/*** ALU ops ***/
+		case BPF_S_ALU_ADD_X: /* A += X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_ADD(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_ADD_K: /* A += K; */
+			if (!K)
+				break;
+			PPC_ADDI(r_A, r_A, IMM_L(K));
+			if (K >= 32768)
+				PPC_ADDIS(r_A, r_A, IMM_HA(K));
+			break;
+		case BPF_S_ALU_SUB_X: /* A -= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_SUB(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_SUB_K: /* A -= K */
+			if (!K)
+				break;
+			PPC_ADDI(r_A, r_A, IMM_L(-K));
+			if (K >= 32768)
+				PPC_ADDIS(r_A, r_A, IMM_HA(-K));
+			break;
+		case BPF_S_ALU_MUL_X: /* A *= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_MUL(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_MUL_K: /* A *= K */
+			if (K < 32768)
+				PPC_MULI(r_A, r_A, K);
+			else {
+				PPC_LI32(r_scratch1, K);
+				PPC_MUL(r_A, r_A, r_scratch1);
+			}
+			break;
+		case BPF_S_ALU_DIV_X: /* A /= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_CMPWI(r_X, 0);
+			if (ctx->pc_ret0 != -1) {
+				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
+			} else {
+				/*
+				 * Exit, returning 0; first pass hits here
+				 * (longer worst-case code size).
+				 */
+				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+			}
+			PPC_DIVWU(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K); */
+			PPC_LI32(r_scratch1, K);
+			/* Top 32 bits of 64bit result -> A */
+			PPC_MULHWU(r_A, r_A, r_scratch1);
+			break;
+		case BPF_S_ALU_AND_X:
+			ctx->seen |= SEEN_XREG;
+			PPC_AND(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_AND_K:
+			if (!IMM_H(K))
+				PPC_ANDI(r_A, r_A, K);
+			else {
+				PPC_LI32(r_scratch1, K);
+				PPC_AND(r_A, r_A, r_scratch1);
+			}
+			break;
+		case BPF_S_ALU_OR_X:
+			ctx->seen |= SEEN_XREG;
+			PPC_OR(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_OR_K:
+			if (IMM_L(K))
+				PPC_ORI(r_A, r_A, IMM_L(K));
+			if (K >= 65536)
+				PPC_ORIS(r_A, r_A, IMM_H(K));
+			break;
+		case BPF_S_ALU_LSH_X: /* A <<= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_SLW(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_LSH_K:
+			if (K == 0)
+				break;
+			else
+				PPC_SLWI(r_A, r_A, K);
+			break;
+		case BPF_S_ALU_RSH_X: /* A >>= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_SRW(r_A, r_A, r_X);
+			break;
+		case BPF_S_ALU_RSH_K: /* A >>= K; */
+			if (K == 0)
+				break;
+			else
+				PPC_SRWI(r_A, r_A, K);
+			break;
+		case BPF_S_ALU_NEG:
+			PPC_NEG(r_A, r_A);
+			break;
+		case BPF_S_RET_K:
+			PPC_LI32(r_ret, K);
+			if (!K) {
+				if (ctx->pc_ret0 == -1)
+					ctx->pc_ret0 = i;
+			}
+			/*
+			 * If this isn't the very last instruction, branch to
+			 * the epilogue if we've stuff to clean up.  Otherwise,
+			 * if there's nothing to tidy, just return.  If we /are/
+			 * the last instruction, we're about to fall through to
+			 * the epilogue to return.
+			 */
+			if (i != flen - 1) {
+				/*
+				 * Note: 'seen' is properly valid only on pass
+				 * #2.	Both parts of this conditional are the
+				 * same instruction size though, meaning the
+				 * first pass will still correctly determine the
+				 * code size/addresses.
+				 */
+				if (ctx->seen)
+					PPC_JMP(exit_addr);
+				else
+					PPC_BLR();
+			}
+			break;
+		case BPF_S_RET_A:
+			PPC_MR(r_ret, r_A);
+			if (i != flen - 1) {
+				if (ctx->seen)
+					PPC_JMP(exit_addr);
+				else
+					PPC_BLR();
+			}
+			break;
+		case BPF_S_MISC_TAX: /* X = A */
+			PPC_MR(r_X, r_A);
+			break;
+		case BPF_S_MISC_TXA: /* A = X */
+			ctx->seen |= SEEN_XREG;
+			PPC_MR(r_A, r_X);
+			break;
+
+			/*** Constant loads/M[] access ***/
+		case BPF_S_LD_IMM: /* A = K */
+			PPC_LI32(r_A, K);
+			break;
+		case BPF_S_LDX_IMM: /* X = K */
+			PPC_LI32(r_X, K);
+			break;
+		case BPF_S_LD_MEM: /* A = mem[K] */
+			PPC_MR(r_A, r_M + (K & 0xf));
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_LDX_MEM: /* X = mem[K] */
+			PPC_MR(r_X, r_M + (K & 0xf));
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_ST: /* mem[K] = A */
+			PPC_MR(r_M + (K & 0xf), r_A);
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_STX: /* mem[K] = X */
+			PPC_MR(r_M + (K & 0xf), r_X);
+			ctx->seen |= SEEN_XREG | SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_LD_W_LEN: /*	A = skb->len; */
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
+			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff, len));
+			break;
+		case BPF_S_LDX_W_LEN: /* X = skb->len; */
+			PPC_LWZ_OFFS(r_X, r_skb, offsetof(struct sk_buff, len));
+			break;
+
+			/*** Ancillary info loads ***/
+
+			/* None of the BPF_S_ANC* codes appear to be passed by
+			 * sk_chk_filter().  The interpreter and the x86 BPF
+			 * compiler implement them so we do too -- they may be
+			 * planted in future.
+			 */
+		case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
+						  protocol) != 2);
+			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  protocol));
+			/* ntohs is a NOP with BE loads. */
+			break;
+		case BPF_S_ANC_IFINDEX:
+			PPC_LD_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
+								dev));
+			PPC_CMPDI(r_scratch1, 0);
+			if (ctx->pc_ret0 != -1) {
+				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
+			} else {
+				/* Exit, returning 0; first pass hits here. */
+				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+			}
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
+						  ifindex) != 4);
+			PPC_LWZ_OFFS(r_A, r_scratch1,
+				     offsetof(struct net_device, ifindex));
+			break;
+		case BPF_S_ANC_MARK:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
+			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  mark));
+			break;
+		case BPF_S_ANC_RXHASH:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
+			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  rxhash));
+			break;
+		case BPF_S_ANC_QUEUE:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
+						  queue_mapping) != 2);
+			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  queue_mapping));
+			break;
+		case BPF_S_ANC_CPU:
+#ifdef CONFIG_SMP
+			/*
+			 * PACA ptr is r13:
+			 * raw_smp_processor_id() = local_paca->paca_index
+			 */
+			PPC_LHZ_OFFS(r_A, 13,
+				     offsetof(struct paca_struct, paca_index));
+#else
+			PPC_LI(r_A, 0);
+#endif
+			break;
+
+			/*** Absolute loads from packet header/data ***/
+		case BPF_S_LD_W_ABS:
+			func = sk_load_word;
+			goto common_load;
+		case BPF_S_LD_H_ABS:
+			func = sk_load_half;
+			goto common_load;
+		case BPF_S_LD_B_ABS:
+			func = sk_load_byte;
+		common_load:
+			/*
+			 * Load from [K].  Reference with the (negative)
+			 * SKF_NET_OFF/SKF_LL_OFF offsets is unsupported.
+			 */
+			ctx->seen |= SEEN_DATAREF;
+			if ((int)K < 0)
+				return -ENOTSUPP;
+			PPC_LI64(r_scratch1, func);
+			PPC_MTLR(r_scratch1);
+			PPC_LI32(r_addr, K);
+			PPC_BLRL();
+			/*
+			 * Helper returns 'lt' condition on error, and an
+			 * appropriate return value in r3
+			 */
+			PPC_BCC(COND_LT, exit_addr);
+			break;
+
+			/*** Indirect loads from packet header/data ***/
+		case BPF_S_LD_W_IND:
+			func = sk_load_word;
+			goto common_load_ind;
+		case BPF_S_LD_H_IND:
+			func = sk_load_half;
+			goto common_load_ind;
+		case BPF_S_LD_B_IND:
+			func = sk_load_byte;
+		common_load_ind:
+			/*
+			 * Load from [X + K].  Negative offsets are tested for
+			 * in the helper functions, and result in a 'ret 0'.
+			 */
+			ctx->seen |= SEEN_DATAREF | SEEN_XREG;
+			PPC_LI64(r_scratch1, func);
+			PPC_MTLR(r_scratch1);
+			PPC_ADDI(r_addr, r_X, IMM_L(K));
+			if (K >= 32768)
+				PPC_ADDIS(r_addr, r_addr, IMM_HA(K));
+			PPC_BLRL();
+			/* If error, cr0.LT set */
+			PPC_BCC(COND_LT, exit_addr);
+			break;
+
+		case BPF_S_LDX_B_MSH:
+			/*
+			 * x86 version drops packet (RET 0) when K<0, whereas
+			 * interpreter does allow K<0 (__load_pointer, special
+			 * ancillary data).
+			 */
+			func = sk_load_byte_msh;
+			goto common_load;
+			break;
+
+			/*** Jump and branches ***/
+		case BPF_S_JMP_JA:
+			if (K != 0)
+				PPC_JMP(addrs[i + 1 + K]);
+			break;
+
+		case BPF_S_JMP_JGT_K:
+		case BPF_S_JMP_JGT_X:
+			true_cond = COND_GT;
+			goto cond_branch;
+		case BPF_S_JMP_JGE_K:
+		case BPF_S_JMP_JGE_X:
+			true_cond = COND_GE;
+			goto cond_branch;
+		case BPF_S_JMP_JEQ_K:
+		case BPF_S_JMP_JEQ_X:
+			true_cond = COND_EQ;
+			goto cond_branch;
+		case BPF_S_JMP_JSET_K:
+		case BPF_S_JMP_JSET_X:
+			true_cond = COND_NE;
+			/* Fall through */
+		cond_branch:
+			/* same targets, can avoid doing the test :) */
+			if (filter[i].jt == filter[i].jf) {
+				if (filter[i].jt > 0)
+					PPC_JMP(addrs[i + 1 + filter[i].jt]);
+				break;
+			}
+
+			switch (filter[i].code) {
+			case BPF_S_JMP_JGT_X:
+			case BPF_S_JMP_JGE_X:
+			case BPF_S_JMP_JEQ_X:
+				ctx->seen |= SEEN_XREG;
+				PPC_CMPLW(r_A, r_X);
+				break;
+			case BPF_S_JMP_JSET_X:
+				ctx->seen |= SEEN_XREG;
+				PPC_AND_DOT(r_scratch1, r_A, r_X);
+				break;
+			case BPF_S_JMP_JEQ_K:
+			case BPF_S_JMP_JGT_K:
+			case BPF_S_JMP_JGE_K:
+				if (K < 32768)
+					PPC_CMPLWI(r_A, K);
+				else {
+					PPC_LI32(r_scratch1, K);
+					PPC_CMPLW(r_A, r_scratch1);
+				}
+				break;
+			case BPF_S_JMP_JSET_K:
+				if (K < 32768)
+					/* PPC_ANDI is /only/ dot-form */
+					PPC_ANDI(r_scratch1, r_A, K);
+				else {
+					PPC_LI32(r_scratch1, K);
+					PPC_AND_DOT(r_scratch1, r_A,
+						    r_scratch1);
+				}
+				break;
+			}
+			/* Sometimes branches are constructed "backward", with
+			 * the false path being the branch and true path being
+			 * a fallthrough to the next instruction.
+			 */
+			if (filter[i].jt == 0)
+				/* Swap the sense of the branch */
+				PPC_BCC(true_cond ^ COND_CMP_TRUE,
+					addrs[i + 1 + filter[i].jf]);
+			else {
+				PPC_BCC(true_cond, addrs[i + 1 + filter[i].jt]);
+				if (filter[i].jf != 0)
+					PPC_JMP(addrs[i + 1 + filter[i].jf]);
+			}
+			break;
+		default:
+			/* The filter contains something cruel & unusual.
+			 * We don't handle it, but also there shouldn't be
+			 * anything missing from our list.
+			 */
+			pr_err("BPF filter opcode %04x (@%d) unsupported\n",
+			       filter[i].code, i);
+			return -ENOTSUPP;
+		}
+
+	}
+	/* Set end-of-body-code address for exit. */
+	addrs[i] = ctx->idx * 4;
+
+	return 0;
+}
+
+void bpf_jit_compile(struct sk_filter *fp)
+{
+	unsigned int proglen;
+	unsigned int alloclen;
+	u32 *image = NULL;
+	u32 *code_base;
+	unsigned int *addrs;
+	struct codegen_context cgctx;
+	int pass;
+	int flen = fp->len;
+
+	if (!bpf_jit_enable)
+		return;
+
+	addrs = kzalloc((flen+1) * sizeof(*addrs), GFP_KERNEL);
+	if (addrs == NULL)
+		return;
+
+	/*
+	 * There are multiple assembly passes as the generated code will change
+	 * size as it settles down, figuring out the max branch offsets/exit
+	 * paths required.
+	 *
+	 * The range of standard conditional branches is +/- 32Kbytes.	Since
+	 * BPF_MAXINSNS = 4096, we can only jump from (worst case) start to
+	 * finish with 8 bytes/instruction.  Not feasible, so long jumps are
+	 * used, distinct from short branches.
+	 *
+	 * Current:
+	 *
+	 * For now, both branch types assemble to 2 words (short branches padded
+	 * with a NOP); this is less efficient, but assembly will always complete
+	 * after exactly 3 passes:
+	 *
+	 * First pass: No code buffer; Program is "faux-generated" -- no code
+	 * emitted but maximum size of output determined (and addrs[] filled
+	 * in).	 Also, we note whether we use M[], whether we use skb data, etc.
+	 * All generation choices assumed to be 'worst-case', e.g. branches all
+	 * far (2 instructions), return path code reduction not available, etc.
+	 *
+	 * Second pass: Code buffer allocated with size determined previously.
+	 * Prologue generated to support features we have seen used.  Exit paths
+	 * determined and addrs[] is filled in again, as code may be slightly
+	 * smaller as a result.
+	 *
+	 * Third pass: Code generated 'for real', and branch destinations
+	 * determined from now-accurate addrs[] map.
+	 *
+	 * Ideal:
+	 *
+	 * If we optimise this, near branches will be shorter.	On the
+	 * first assembly pass, we should err on the side of caution and
+	 * generate the biggest code.  On subsequent passes, branches will be
+	 * generated short or long and code size will reduce.  With smaller
+	 * code, more branches may fall into the short category, and code will
+	 * reduce more.
+	 *
+	 * Finally, if we see one pass generate code the same size as the
+	 * previous pass we have converged and should now generate code for
+	 * real.  Allocating at the end will also save the memory that would
+	 * otherwise be wasted by the (small) current code shrinkage.
+	 * Preferably, we should do a small number of passes (e.g. 5) and if we
+	 * haven't converged by then, get impatient and force code to generate
+	 * as-is, even if the odd branch would be left long.  The chances of a
+	 * long jump are tiny with all but the most enormous of BPF filter
+	 * inputs, so we should usually converge on the third pass.
+	 */
+
+	cgctx.idx = 0;
+	cgctx.seen = 0;
+	cgctx.pc_ret0 = -1;
+	/* Scouting faux-generate pass 0 */
+	if (bpf_jit_build_body(fp, 0, &cgctx, addrs))
+		/* We hit something illegal or unsupported. */
+		goto out;
+
+	/*
+	 * Pretend to build prologue, given the features we've seen.  This will
+	 * update ctgtx.idx as it pretends to output instructions, then we can
+	 * calculate total size from idx.
+	 */
+	bpf_jit_build_prologue(fp, 0, &cgctx);
+	bpf_jit_build_epilogue(0, &cgctx);
+
+	proglen = cgctx.idx * 4;
+	alloclen = proglen + FUNCTION_DESCR_SIZE;
+	image = module_alloc(max_t(unsigned int, alloclen,
+				   sizeof(struct work_struct)));
+	if (!image)
+		goto out;
+
+	code_base = image + (FUNCTION_DESCR_SIZE/4);
+
+	/* Code generation passes 1-2 */
+	for (pass = 1; pass < 3; pass++) {
+		/* Now build the prologue, body code & epilogue for real. */
+		cgctx.idx = 0;
+		bpf_jit_build_prologue(fp, code_base, &cgctx);
+		bpf_jit_build_body(fp, code_base, &cgctx, addrs);
+		bpf_jit_build_epilogue(code_base, &cgctx);
+
+		if (bpf_jit_enable > 1)
+			pr_info("Pass %d: shrink = %d, seen = 0x%x\n", pass,
+				proglen - (cgctx.idx * 4), cgctx.seen);
+	}
+
+	if (bpf_jit_enable > 1)
+		pr_info("flen=%d proglen=%u pass=%d image=%p\n",
+		       flen, proglen, pass, image);
+
+	if (image) {
+		if (bpf_jit_enable > 1)
+			print_hex_dump(KERN_ERR, "JIT code: ",
+				       DUMP_PREFIX_ADDRESS,
+				       16, 1, code_base,
+				       proglen, false);
+
+		bpf_flush_icache(code_base, code_base + (proglen/4));
+		/* Function descriptor nastiness: Address + TOC */
+		((u64 *)image)[0] = (u64)code_base;
+		((u64 *)image)[1] = local_paca->kernel_toc;
+		fp->bpf_func = (void *)image;
+	}
+out:
+	kfree(addrs);
+	return;
+}
+
+static void jit_free_defer(struct work_struct *arg)
+{
+	module_free(NULL, arg);
+}
+
+/* run from softirq, we must use a work_struct to call
+ * module_free() from process context
+ */
+void bpf_jit_free(struct sk_filter *fp)
+{
+	if (fp->bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+
+		INIT_WORK(work, jit_free_defer);
+		schedule_work(work);
+	}
+}
