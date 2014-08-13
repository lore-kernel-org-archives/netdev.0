From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v4 net-next 02/26] net: filter: split filter.h and expose eBPF to user space
Date: Wed, 13 Aug 2014 00:57:13 -0700
Message-ID: <1407916658-8731-3-git-send-email-ast@plumgrid.com>
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

eBPF can be used from user space.

uapi/linux/bpf.h: eBPF instruction set definition

linux/filter.h: the rest

This patch only moves macro definitions, but practically it freezes existing
eBPF instruction set, though new instructions can still be added in the future.

These eBPF definitions cannot go into uapi/linux/filter.h, since the names
may conflict with existing applications.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h    |  305 +------------------------------------------
 include/uapi/linux/Kbuild |    1 +
 include/uapi/linux/bpf.h  |  314 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 316 insertions(+), 304 deletions(-)
 create mode 100644 include/uapi/linux/bpf.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 73a6d505e729..f04793474d16 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -9,315 +9,12 @@
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
 #include <uapi/linux/filter.h>
-
-/* Internally used and optimized filter representation with extended
- * instruction set based on top of classic BPF.
- */
-
-/* instruction classes */
-#define BPF_ALU64	0x07	/* alu mode in double word width */
-
-/* ld/ldx fields */
-#define BPF_DW		0x18	/* double word */
-#define BPF_XADD	0xc0	/* exclusive add */
-
-/* alu/jmp fields */
-#define BPF_MOV		0xb0	/* mov reg to reg */
-#define BPF_ARSH	0xc0	/* sign extending arithmetic shift right */
-
-/* change endianness of a register */
-#define BPF_END		0xd0	/* flags for endianness conversion: */
-#define BPF_TO_LE	0x00	/* convert to little-endian */
-#define BPF_TO_BE	0x08	/* convert to big-endian */
-#define BPF_FROM_LE	BPF_TO_LE
-#define BPF_FROM_BE	BPF_TO_BE
-
-#define BPF_JNE		0x50	/* jump != */
-#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
-#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
-#define BPF_CALL	0x80	/* function call */
-#define BPF_EXIT	0x90	/* function return */
-
-/* Register numbers */
-enum {
-	BPF_REG_0 = 0,
-	BPF_REG_1,
-	BPF_REG_2,
-	BPF_REG_3,
-	BPF_REG_4,
-	BPF_REG_5,
-	BPF_REG_6,
-	BPF_REG_7,
-	BPF_REG_8,
-	BPF_REG_9,
-	BPF_REG_10,
-	__MAX_BPF_REG,
-};
-
-/* BPF has 10 general purpose 64-bit registers and stack frame. */
-#define MAX_BPF_REG	__MAX_BPF_REG
-
-/* ArgX, context and stack frame pointer register positions. Note,
- * Arg1, Arg2, Arg3, etc are used as argument mappings of function
- * calls in BPF_CALL instruction.
- */
-#define BPF_REG_ARG1	BPF_REG_1
-#define BPF_REG_ARG2	BPF_REG_2
-#define BPF_REG_ARG3	BPF_REG_3
-#define BPF_REG_ARG4	BPF_REG_4
-#define BPF_REG_ARG5	BPF_REG_5
-#define BPF_REG_CTX	BPF_REG_6
-#define BPF_REG_FP	BPF_REG_10
-
-/* Additional register mappings for converted user programs. */
-#define BPF_REG_A	BPF_REG_0
-#define BPF_REG_X	BPF_REG_7
-#define BPF_REG_TMP	BPF_REG_8
-
-/* BPF program can access up to 512 bytes of stack space. */
-#define MAX_BPF_STACK	512
-
-/* Helper macros for filter block array initializers. */
-
-/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
-
-#define BPF_ALU64_REG(OP, DST, SRC)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = 0 })
-
-#define BPF_ALU32_REG(OP, DST, SRC)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = 0 })
-
-/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
-
-#define BPF_ALU64_IMM(OP, DST, IMM)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-#define BPF_ALU32_IMM(OP, DST, IMM)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
-
-#define BPF_ENDIAN(TYPE, DST, LEN)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = LEN })
-
-/* Short form of mov, dst_reg = src_reg */
-
-#define BPF_MOV64_REG(DST, SRC)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = 0 })
-
-#define BPF_MOV32_REG(DST, SRC)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = 0 })
-
-/* Short form of mov, dst_reg = imm32 */
-
-#define BPF_MOV64_IMM(DST, IMM)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-#define BPF_MOV32_IMM(DST, IMM)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* use two of BPF_LD_IMM64 to encode single move 64-bit insn
- * first macro to carry lower 32-bits and second for higher 32-bits
- */
-#define BPF_LD_IMM64(DST, IMM)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
-
-#define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU64 | BPF_MOV | BPF_SRC(TYPE),	\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-#define BPF_MOV32_RAW(TYPE, DST, SRC, IMM)			\
-	((struct bpf_insn) {					\
-		.code  = BPF_ALU | BPF_MOV | BPF_SRC(TYPE),	\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
-
-#define BPF_LD_ABS(SIZE, IMM)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
-		.dst_reg = 0,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* Indirect packet access, R0 = *(uint *) (skb->data + src_reg + imm32) */
-
-#define BPF_LD_IND(SIZE, SRC, IMM)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_IND,	\
-		.dst_reg = 0,					\
-		.src_reg = SRC,					\
-		.off   = 0,					\
-		.imm   = IMM })
-
-/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
-
-#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
-	((struct bpf_insn) {					\
-		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = OFF,					\
-		.imm   = 0 })
-
-/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
-
-#define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
-	((struct bpf_insn) {					\
-		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = OFF,					\
-		.imm   = 0 })
-
-/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
-
-#define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = OFF,					\
-		.imm   = IMM })
-
-/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
-
-#define BPF_JMP_REG(OP, DST, SRC, OFF)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = OFF,					\
-		.imm   = 0 })
-
-/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
-
-#define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
-	((struct bpf_insn) {					\
-		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
-		.dst_reg = DST,					\
-		.src_reg = 0,					\
-		.off   = OFF,					\
-		.imm   = IMM })
-
-/* Function call */
-
-#define BPF_EMIT_CALL(FUNC)					\
-	((struct bpf_insn) {					\
-		.code  = BPF_JMP | BPF_CALL,			\
-		.dst_reg = 0,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = ((FUNC) - __bpf_call_base) })
-
-/* Raw code statement block */
-
-#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
-	((struct bpf_insn) {					\
-		.code  = CODE,					\
-		.dst_reg = DST,					\
-		.src_reg = SRC,					\
-		.off   = OFF,					\
-		.imm   = IMM })
-
-/* Program exit */
-
-#define BPF_EXIT_INSN()						\
-	((struct bpf_insn) {					\
-		.code  = BPF_JMP | BPF_EXIT,			\
-		.dst_reg = 0,					\
-		.src_reg = 0,					\
-		.off   = 0,					\
-		.imm   = 0 })
-
-#define bytes_to_bpf_size(bytes)				\
-({								\
-	int bpf_size = -EINVAL;					\
-								\
-	if (bytes == sizeof(u8))				\
-		bpf_size = BPF_B;				\
-	else if (bytes == sizeof(u16))				\
-		bpf_size = BPF_H;				\
-	else if (bytes == sizeof(u32))				\
-		bpf_size = BPF_W;				\
-	else if (bytes == sizeof(u64))				\
-		bpf_size = BPF_DW;				\
-								\
-	bpf_size;						\
-})
+#include <uapi/linux/bpf.h>
 
 /* Macro to invoke filter function. */
 #define SK_RUN_FILTER(filter, ctx) \
 	(*filter->prog->bpf_func)(ctx, filter->prog->insnsi)
 
-struct bpf_insn {
-	__u8	code;		/* opcode */
-	__u8	dst_reg:4;	/* dest register */
-	__u8	src_reg:4;	/* source register */
-	__s16	off;		/* signed offset */
-	__s32	imm;		/* signed immediate constant */
-};
-
 #ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 24e9033f8b3f..fb3f7b675229 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -67,6 +67,7 @@ header-y += bfs_fs.h
 header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
+header-y += bpf.h
 header-y += bpqether.h
 header-y += bsg.h
 header-y += btrfs.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
new file mode 100644
index 000000000000..6f6e10875e95
--- /dev/null
+++ b/include/uapi/linux/bpf.h
@@ -0,0 +1,314 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _UAPI__LINUX_BPF_H__
+#define _UAPI__LINUX_BPF_H__
+
+#include <linux/types.h>
+
+/* Extended instruction set based on top of classic BPF */
+
+/* instruction classes */
+#define BPF_ALU64	0x07	/* alu mode in double word width */
+
+/* ld/ldx fields */
+#define BPF_DW		0x18	/* double word */
+#define BPF_XADD	0xc0	/* exclusive add */
+
+/* alu/jmp fields */
+#define BPF_MOV		0xb0	/* mov reg to reg */
+#define BPF_ARSH	0xc0	/* sign extending arithmetic shift right */
+
+/* change endianness of a register */
+#define BPF_END		0xd0	/* flags for endianness conversion: */
+#define BPF_TO_LE	0x00	/* convert to little-endian */
+#define BPF_TO_BE	0x08	/* convert to big-endian */
+#define BPF_FROM_LE	BPF_TO_LE
+#define BPF_FROM_BE	BPF_TO_BE
+
+#define BPF_JNE		0x50	/* jump != */
+#define BPF_JSGT	0x60	/* SGT is signed '>', GT in x86 */
+#define BPF_JSGE	0x70	/* SGE is signed '>=', GE in x86 */
+#define BPF_CALL	0x80	/* function call */
+#define BPF_EXIT	0x90	/* function return */
+
+/* Register numbers */
+enum {
+	BPF_REG_0 = 0,
+	BPF_REG_1,
+	BPF_REG_2,
+	BPF_REG_3,
+	BPF_REG_4,
+	BPF_REG_5,
+	BPF_REG_6,
+	BPF_REG_7,
+	BPF_REG_8,
+	BPF_REG_9,
+	BPF_REG_10,
+	__MAX_BPF_REG,
+};
+
+/* BPF has 10 general purpose 64-bit registers and stack frame. */
+#define MAX_BPF_REG	__MAX_BPF_REG
+
+/* ArgX, context and stack frame pointer register positions. Note,
+ * Arg1, Arg2, Arg3, etc are used as argument mappings of function
+ * calls in BPF_CALL instruction.
+ */
+#define BPF_REG_ARG1	BPF_REG_1
+#define BPF_REG_ARG2	BPF_REG_2
+#define BPF_REG_ARG3	BPF_REG_3
+#define BPF_REG_ARG4	BPF_REG_4
+#define BPF_REG_ARG5	BPF_REG_5
+#define BPF_REG_CTX	BPF_REG_6
+#define BPF_REG_FP	BPF_REG_10
+
+/* Additional register mappings for converted user programs. */
+#define BPF_REG_A	BPF_REG_0
+#define BPF_REG_X	BPF_REG_7
+#define BPF_REG_TMP	BPF_REG_8
+
+/* BPF program can access up to 512 bytes of stack space. */
+#define MAX_BPF_STACK	512
+
+/* Helper macros for filter block array initializers. */
+
+/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
+
+#define BPF_ALU64_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_ALU32_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
+
+#define BPF_ALU64_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_ALU32_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
+
+#define BPF_ENDIAN(TYPE, DST, LEN)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = LEN })
+
+/* Short form of mov, dst_reg = src_reg */
+
+#define BPF_MOV64_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_MOV32_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* Short form of mov, dst_reg = imm32 */
+
+#define BPF_MOV64_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
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
+/* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
+
+#define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_SRC(TYPE),	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_RAW(TYPE, DST, SRC, IMM)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_SRC(TYPE),	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
+
+#define BPF_LD_ABS(SIZE, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Indirect packet access, R0 = *(uint *) (skb->data + src_reg + imm32) */
+
+#define BPF_LD_IND(SIZE, SRC, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_IND,	\
+		.dst_reg = 0,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
+
+#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
+
+#define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
+
+#define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
+
+#define BPF_JMP_REG(OP, DST, SRC, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
+
+#define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Function call */
+
+#define BPF_EMIT_CALL(FUNC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_CALL,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((FUNC) - __bpf_call_base) })
+
+/* Raw code statement block */
+
+#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
+	((struct bpf_insn) {					\
+		.code  = CODE,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Program exit */
+
+#define BPF_EXIT_INSN()						\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_EXIT,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define bytes_to_bpf_size(bytes)				\
+({								\
+	int bpf_size = -EINVAL;					\
+								\
+	if (bytes == sizeof(u8))				\
+		bpf_size = BPF_B;				\
+	else if (bytes == sizeof(u16))				\
+		bpf_size = BPF_H;				\
+	else if (bytes == sizeof(u32))				\
+		bpf_size = BPF_W;				\
+	else if (bytes == sizeof(u64))				\
+		bpf_size = BPF_DW;				\
+								\
+	bpf_size;						\
+})
+
+struct bpf_insn {
+	__u8	code;		/* opcode */
+	__u8	dst_reg:4;	/* dest register */
+	__u8	src_reg:4;	/* source register */
+	__s16	off;		/* signed offset */
+	__s32	imm;		/* signed immediate constant */
+};
+
+#endif /* _UAPI__LINUX_BPF_H__ */
-- 
1.7.9.5
