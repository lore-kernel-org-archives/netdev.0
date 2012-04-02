From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: [PATCH V1 1/1] NET: add a bpf jit for Alpha
Date: Mon, 2 Apr 2012 21:51:25 +0200
Message-ID: <4F7A033D.4040901@googlemail.com>
References: <4F75CA89.4010709@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Matt Evans <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arch@vger.kernel.org>, <linux-alpha@vger.kernel.org>,
	<rth@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhura.skim.hs-owl.de ([193.174.118.81]:56695 "EHLO
	uhura.skim.hs-owl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab2DBTvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 15:51:45 -0400
In-Reply-To: <4F75CA89.4010709@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The weekend was cold and windy, so i wrote a bpf jit for the Alpha architecture.

Signed-off-by: Jan Seiffert <kaffeemonster@googlemail.com>

---

Patch is against net-next and needs Patch 1 of my "Fix negative offsets" Series
(to get bpf_internal_load_pointer_neg_helper)

The Problem is: i don't have any Alpha machine nor do i really have any clue about
the arch.
So this is only compile tested.
I could really need some Alpha asm guru to give some advice and review this.
Are the calls done right, are the asm load helper ok, all the conditional and
sign handling is a little brittle in my mind, etc.

The whole thing is C&P based on the PPC64 jit, so some of the signedness problems
may lurk there too.

A user space mock-up turns this:
struct bpf_insn udp_filter[] = {
	/*   0 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(12)),
	/*   1 */ BPF_STMT(BPF_LD|BPF_B|BPF_ABS, -1048576+(0)),
	/*   2 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xf0),
	/*   3 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x40, 23 - 4, 0),
	/*   4 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x60, 5 - 5, 41 - 5),
	/*   5 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(8)),
	/*   6 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 13 - 7, 0),
	/*   7 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010DB8, 41 - 8, 0),
	/*   8 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010002, 19 - 9, 0),
	/*   9 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xfffffff0),
	/*  10 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x20010010, 41 - 11, 0),
	/*  11 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xff000000),
	/*  12 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xff000000, 41 - 13, 39 - 13),
	/*  13 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(12)),
	/*  14 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 0, 39 - 15),
	/*  15 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(16)),
	/*  16 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xffff, 22 - 17, 0),
	/*  17 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0x0064FF9B, 22 - 18, 0),
	/*  18 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 19, 39 - 19),
	/*  19 */ BPF_STMT(BPF_LD|BPF_W|BPF_ABS, -1048576+(12)),
	/*  20 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xffff0000),
	/*  21 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 22, 39 - 22),
	/*  22 */ BPF_STMT(BPF_LDX|BPF_W|BPF_IMM, -1048576+(20)),
	/*  23 */ BPF_STMT(BPF_LD|BPF_W|BPF_IND, 0),
	/*  24 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xffffffff, 41 - 25, 0),
	/*  25 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xffffff00),
	/*  26 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0000000, 41 - 27, 0),
	/*  27 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0000200, 41 - 28, 0),
	/*  28 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC6336400, 41 - 29, 0),
	/*  29 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xCB007100, 41 - 30, 0),
	/*  30 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC0586300, 41 - 31, 0),
	/*  31 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xfffe0000),
	/*  32 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xC6120000, 41 - 33, 0),
	/*  33 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xff000000),
	/*  34 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0, 41 - 35, 0),
	/*  35 */ BPF_STMT(BPF_ALU|BPF_AND|BPF_K, 0xf0000000),
	/*  36 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xE0000000, 41 - 37, 0),
	/*  37 */ BPF_JUMP(BPF_JMP|BPF_JEQ|BPF_K, 0xF0000000, 41 - 38, 0),
	/*  38 */ BPF_JUMP(BPF_JMP|BPF_JA, 39 - 39, 0, 0),
	/*  39 */ BPF_STMT(BPF_LD|BPF_W|BPF_LEN, 0),
	/*  40 */ BPF_STMT(BPF_RET|BPF_A, 0),
	/*  41 */ BPF_STMT(BPF_RET|BPF_K, 0),
};

into this instruction sequence for Alpha:

   0:   64 00 50 a0     ldl     t1,100(a0)
   4:   60 00 90 a0     ldl     t3,96(a0)
   8:   22 f6 41 48     zapnot  t1,0xf,t1
   c:   24 f6 81 48     zapnot  t3,0xf,t3
  10:   c8 00 70 a4     ldq     t2,200(a0)
  14:   24 01 82 40     subl    t3,t1,t3
  18:   01 04 ff 47     clr     t0
  1c:   00 04 ff 47     clr     v0
  20:   f0 ff 3f 24     ldah    t0,-16
  24:   01 90 21 40     addl    t0,0xc,t0
  28:   f0 ff 1f 27     ldah    t10,-16
  2c:   f7 fe 5b 24     ldah    t1,-265(t12)
  30:   e0 7f 42 20     lda     t1,32736(t1)
  34:   00 40 e2 6a     jsr     t9,(t1),0x38
  38:   72 00 80 f7     bne     at,0x204
  3c:   00 10 1e 44     and     v0,0xf0,v0
  40:   22 11 08 40     subl    v0,0x40,t1
  44:   02 00 e2 43     sextl   t1,t1
  48:   3e 00 40 e4     beq     t1,0x144
  4c:   22 11 0c 40     subl    v0,0x60,t1
  50:   02 00 e2 43     sextl   t1,t1
  54:   6a 00 40 f4     bne     t1,0x200
  58:   f0 ff 1f 27     ldah    t10,-16
  5c:   18 10 01 43     addl    t10,0x8,t10
  60:   f7 fe 5b 24     ldah    t1,-265(t12)
  64:   c8 7f 42 20     lda     t1,32712(t1)
  68:   00 40 e2 6a     jsr     t9,(t1),0x6c
  6c:   65 00 80 f7     bne     at,0x204
  70:   12 00 00 e4     beq     v0,0xbc
  74:   ff df 40 24     ldah    t1,-8193(v0)
  78:   48 f2 42 20     lda     t1,-3512(t1)
  7c:   02 00 e2 43     sextl   t1,t1
  80:   5f 00 40 e4     beq     t1,0x200
  84:   ff df 40 24     ldah    t1,-8193(v0)
  88:   22 51 40 40     subl    t1,0x2,t1
  8c:   02 00 e2 43     sextl   t1,t1
  90:   21 00 40 e4     beq     t1,0x118
  94:   00 f1 01 44     andnot  v0,0xf,v0
  98:   ff df 40 24     ldah    t1,-8193(v0)
  9c:   22 11 42 40     subl    t1,0x10,t1
  a0:   02 00 e2 43     sextl   t1,t1
  a4:   56 00 40 e4     beq     t1,0x200
  a8:   20 16 01 48     zapnot  v0,0x8,v0
  ac:   00 01 40 24     ldah    t1,256(v0)
  b0:   02 00 e2 43     sextl   t1,t1
  b4:   52 00 40 e4     beq     t1,0x200
  b8:   4e 00 e0 c3     br      0x1f4
  bc:   f0 ff 1f 27     ldah    t10,-16
  c0:   18 90 01 43     addl    t10,0xc,t10
  c4:   f7 fe 5b 24     ldah    t1,-265(t12)
  c8:   c8 7f 42 20     lda     t1,32712(t1)
  cc:   00 40 e2 6a     jsr     t9,(t1),0xd0
  d0:   4c 00 80 f7     bne     at,0x204
  d4:   47 00 00 f4     bne     v0,0x1f4
  d8:   f0 ff 1f 27     ldah    t10,-16
  dc:   18 10 02 43     addl    t10,0x10,t10
  e0:   f7 fe 5b 24     ldah    t1,-265(t12)
  e4:   c8 7f 42 20     lda     t1,32712(t1)
  e8:   00 40 e2 6a     jsr     t9,(t1),0xec
  ec:   45 00 80 f7     bne     at,0x204
  f0:   ff ff 40 24     ldah    t1,-1(v0)
  f4:   02 30 40 40     addl    t1,0x1,t1
  f8:   02 00 e2 43     sextl   t1,t1
  fc:   0f 00 40 e4     beq     t1,0x13c
 100:   9b ff 40 24     ldah    t1,-101(v0)
 104:   02 b0 4c 40     addl    t1,0x65,t1
 108:   02 00 e2 43     sextl   t1,t1
 10c:   0b 00 40 e4     beq     t1,0x13c
 110:   3b 00 00 e4     beq     v0,0x200
 114:   37 00 e0 c3     br      0x1f4
 118:   f0 ff 1f 27     ldah    t10,-16
 11c:   18 90 01 43     addl    t10,0xc,t10
 120:   f7 fe 5b 24     ldah    t1,-265(t12)
 124:   c8 7f 42 20     lda     t1,32712(t1)
 128:   00 40 e2 6a     jsr     t9,(t1),0x12c
 12c:   35 00 80 f7     bne     at,0x204
 130:   20 96 01 48     zapnot  v0,0xc,v0
 134:   32 00 00 e4     beq     v0,0x200
 138:   2e 00 e0 c3     br      0x1f4
 13c:   f0 ff 3f 24     ldah    t0,-16
 140:   01 90 22 40     addl    t0,0x14,t0
 144:   18 04 e1 47     mov     t0,t10
 148:   18 00 f8 43     sextl   t10,t10
 14c:   f7 fe 5b 24     ldah    t1,-265(t12)
 150:   c0 7f 42 20     lda     t1,32704(t1)
 154:   00 40 e2 6a     jsr     t9,(t1),0x158
 158:   2a 00 80 f7     bne     at,0x204
 15c:   02 30 00 40     addl    v0,0x1,t1
 160:   02 00 e2 43     sextl   t1,t1
 164:   26 00 40 e4     beq     t1,0x200
 168:   20 d6 01 48     zapnot  v0,0xe,v0
 16c:   00 40 40 24     ldah    t1,16384(v0)
 170:   02 00 e2 43     sextl   t1,t1
 174:   22 00 40 e4     beq     t1,0x200
 178:   00 40 40 24     ldah    t1,16384(v0)
 17c:   00 fe 42 20     lda     t1,-512(t1)
 180:   02 00 e2 43     sextl   t1,t1
 184:   1e 00 40 e4     beq     t1,0x200
 188:   cd 39 40 24     ldah    t1,14797(v0)
 18c:   00 9c 42 20     lda     t1,-25600(t1)
 190:   02 00 e2 43     sextl   t1,t1
 194:   1a 00 40 e4     beq     t1,0x200
 198:   00 35 40 24     ldah    t1,13568(v0)
 19c:   00 8f 42 20     lda     t1,-28928(t1)
 1a0:   02 00 e2 43     sextl   t1,t1
 1a4:   16 00 40 e4     beq     t1,0x200
 1a8:   a8 3f 40 24     ldah    t1,16296(v0)
 1ac:   00 9d 42 20     lda     t1,-25344(t1)
 1b0:   02 00 e2 43     sextl   t1,t1
 1b4:   12 00 40 e4     beq     t1,0x200
 1b8:   fe ff 5f 24     ldah    t1,-2
 1bc:   00 00 02 44     and     v0,t1,v0
 1c0:   ee 39 40 24     ldah    t1,14830(v0)
 1c4:   02 00 e2 43     sextl   t1,t1
 1c8:   0d 00 40 e4     beq     t1,0x200
 1cc:   20 16 01 48     zapnot  v0,0x8,v0
 1d0:   0b 00 00 e4     beq     v0,0x200
 1d4:   00 f0 5f 24     ldah    t1,-4096
 1d8:   00 00 02 44     and     v0,t1,v0
 1dc:   00 20 40 24     ldah    t1,8192(v0)
 1e0:   02 00 e2 43     sextl   t1,t1
 1e4:   06 00 40 e4     beq     t1,0x200
 1e8:   00 10 40 24     ldah    t1,4096(v0)
 1ec:   02 00 e2 43     sextl   t1,t1
 1f0:   03 00 40 e4     beq     t1,0x200
 1f4:   60 00 10 a0     ldl     v0,96(a0)
 1f8:   20 f6 01 48     zapnot  v0,0xf,v0
 1fc:   01 80 fa 6b     ret
 200:   00 04 ff 47     clr     v0
 204:   01 80 fa 6b     ret

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 56a4df9..eede373 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -15,6 +15,7 @@ config ALPHA
 	select GENERIC_IRQ_SHOW
 	select ARCH_WANT_OPTIONAL_GPIOLIB
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
+	select HAVE_BPF_JIT if (NET)
 	help
 	  The Alpha is a 64-bit general-purpose processor designed and
 	  marketed by the Digital Equipment Corporation of blessed memory,
diff --git a/arch/alpha/Makefile b/arch/alpha/Makefile
index 4759fe7..e634f0c 100644
--- a/arch/alpha/Makefile
+++ b/arch/alpha/Makefile
@@ -38,7 +38,9 @@ KBUILD_CFLAGS += $(cflags-y) -Wa,-mev6
 
 head-y := arch/alpha/kernel/head.o
 
-core-y				+= arch/alpha/kernel/ arch/alpha/mm/
+core-y				+= arch/alpha/kernel/ \
+				   arch/alpha/mm/ \
+				   arch/alpha/net/
 core-$(CONFIG_MATHEMU)		+= arch/alpha/math-emu/
 drivers-$(CONFIG_OPROFILE)	+= arch/alpha/oprofile/
 libs-y				+= arch/alpha/lib/
diff --git a/arch/alpha/net/Makefile b/arch/alpha/net/Makefile
new file mode 100644
index 0000000..4a6ae5b
--- /dev/null
+++ b/arch/alpha/net/Makefile
@@ -0,0 +1,4 @@
+#
+# Arch-specific network modules
+#
+obj-$(CONFIG_BPF_JIT) += bpf_jit_helper.o bpf_jit_comp.o
diff --git a/arch/alpha/net/bpf_jit.h b/arch/alpha/net/bpf_jit.h
new file mode 100644
index 0000000..6513820
--- /dev/null
+++ b/arch/alpha/net/bpf_jit.h
@@ -0,0 +1,108 @@
+/* bpf_jit.h: BPF JIT compiler for Alpha
+ *
+ * Copyright 2012 Jan Seiffert <kaffeemonster@googlemail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+#ifndef _BPF_JIT_H
+#define _BPF_JIT_H
+
+#define BPF_ALPHA_STACKFRAME	(64)
+#define BPF_HELPER_STACKFRAME	(64+32)
+
+#ifdef __ASSEMBLY__
+# define REG_NAME(x) $##x
+#else
+# define REG_NAME(x) (x)
+#endif
+
+/*
+ * Generated code register usage:
+ *
+ * mostly like the C ABI? (e.g. $30=sp, $26=ra, no fp), with:
+ *
+ * skb			a0	(Entry parameter)
+ * socket_filter isns	a1	(Entry parameter)
+ * A register		v0	(result register)
+ * X register		t0
+ * scratch register	t1
+ * skb->data		t2
+ * skb headlen		t3	(skb->len - skb->data_len)
+ *
+ * asm helper are called with a more asm ABI, they have to
+ * save regs are make things neat if they want to call out
+ * again.
+ * helper link register	t9
+ * addr			t10
+ */
+/* fixed register */
+#define r_ret		REG_NAME(0)
+/* temp 1 - 8 */
+#define r_A		REG_NAME(0)
+#define r_X		REG_NAME(1)
+#define r_scratch1	REG_NAME(2)
+#define r_D		REG_NAME(3)
+#define r_HL		REG_NAME(4)
+#define r_curthread	REG_NAME(8)
+/* saved 9 - 14 */
+#define r_fp		REG_NAME(15) /* y */
+/* args 16 - 21 */
+#define r_skb		REG_NAME(16)
+#define r_sf		REG_NAME(17)
+/* temp 22 - 25 */
+/* div helper link register */
+#define r_div_link	REG_NAME(23)
+/* div helper uses 24 & 25 as parameter */
+#define r_addr		REG_NAME(24)
+#define r_ra		REG_NAME(26) /* y */
+/* div helper returns result in 27, may clobber 28 */
+#define r_pv		REG_NAME(27) /* n */
+#define r_at		REG_NAME(28) /* n */
+#define r_gp		REG_NAME(29) /* n */
+#define r_sp		REG_NAME(30) /* y */
+#define r_zero		REG_NAME(31)
+
+#define SEEN_DATAREF 0x10000 /* might call external helpers */
+#define SEEN_XREG    0x20000 /* X reg is used */
+#define SEEN_MEM     0x40000 /* SEEN_MEM+(1<<n) = mem[n] used */
+#define SEEN_DIV     0x80000 /* we need to call the div instruction helper */
+#define SEEN_MEM_MSK 0x0ffff
+
+#ifndef __ASSEMBLY__
+
+# define COND_MSK 0x7
+enum cond {
+	COND_EQ = 0x0,
+	COND_GE = 0x1,
+	COND_GT = 0x3,
+	COND_LE = 0x4,
+	COND_LT = 0x6,
+	COND_NE = 0x7
+};
+
+struct codegen_context {
+	unsigned int seen;
+	unsigned int idx;
+	int pc_ret0; /* bpf index of first RET #0 instruction (if any) */
+};
+
+/*
+ * Assembly helpers from arch/alpha/net/bpf_jit.S:
+ */
+extern u32 sk_load_word[1], sk_load_half[1], sk_load_byte[1], sk_load_byte_msh[1];
+extern u32 sk_load_word_positive_offset[1], sk_load_half_positive_offset[1];
+extern u32 sk_load_byte_positive_offset[1], sk_load_byte_msh_positive_offset[1];
+extern u32 sk_load_word_negative_offset[1], sk_load_half_negative_offset[1];
+extern u32 sk_load_byte_negative_offset[1], sk_load_byte_msh_negative_offset[1];
+extern u32 sk_load_word_bwx[1], sk_load_half_bwx[1];
+extern u32 sk_load_byte_bwx[1], sk_load_byte_msh_bwx[1];
+extern u32 sk_load_word_positive_offset_bwx[1], sk_load_half_positive_offset_bwx[1];
+extern u32 sk_load_byte_positive_offset_bwx[1], sk_load_byte_msh_positive_offset_bwx[1];
+extern u32 sk_load_word_negative_offset_bwx[1], sk_load_half_negative_offset_bwx[1];
+extern u32 sk_load_byte_negative_offset_bwx[1], sk_load_byte_msh_negative_offset_bwx[1];
+#endif /* __ASSEMBLY__ */
+
+#endif
diff --git a/arch/alpha/net/bpf_jit_comp.c b/arch/alpha/net/bpf_jit_comp.c
new file mode 100644
index 0000000..5ee67c5
--- /dev/null
+++ b/arch/alpha/net/bpf_jit_comp.c
@@ -0,0 +1,1148 @@
+/* bpf_jit_comp.c: BPF JIT compiler for Alpha
+ *
+ * Copyright 2012 Jan Seiffert <kaffeemonster@googlemail.com>
+ *
+ * Based on the PPC64 BPF compiler, Matt Evans <matt@ozlabs.org>,
+ * IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <linux/moduleloader.h>
+#include <asm/cacheflush.h>
+#include <linux/netdevice.h>
+#include <linux/filter.h>
+#include "bpf_jit.h"
+
+/*
+ * Instruction generation macros
+ */
+#define PLANT_INSTR(d, idx, instr)					      \
+	do { if (d) { (d)[idx] = instr; } idx++; } while (0)
+#define EMIT(instr)		PLANT_INSTR(image, ctx->idx, instr)
+
+#define ALPHA_INST_MEM(op, ra, rb, disp) \
+	((((u32)op)<<26)|(((u32)ra)<<21)|(((u32)rb)<<16)|((disp)&0xffff))
+#define ALPHA_INST_JMP(op, ra, disp) \
+	((((u32)op)<<26)|(((u32)ra)<<21)|((disp)&0x1FFFFF))
+#define ALPHA_INST_OPR(op, ra, rb, func, rc) \
+	((((u32)op)<<26)|(((u32)ra)<<21)|(((u32)rb)<<16)|(((u32)func)<<5)|(rc))
+#define ALPHA_INST_OPI(op, ra, imm, func, rc) \
+	((((u32)op)<<26)|(((u32)ra)<<21)|(((((u32)(imm)&0xff)<<1)|1)<<12)|(((u32)func)<<5)|(rc))
+
+/* ld/st */
+#define ALPHA_LDA(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x08, ra, rb, imm16))
+#define ALPHA_LDAH(rb, imm16, ra)   EMIT(ALPHA_INST_MEM(0x09, ra, rb, imm16))
+#define ALPHA_LDQ_U(rb, imm16, ra)  EMIT(ALPHA_INST_MEM(0x0b, ra, rb, imm16))
+#define ALPHA_LDQ(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x29, ra, rb, imm16))
+#define ALPHA_LDL(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x28, ra, rb, imm16))
+#define ALPHA_LDWU(rb, imm16, ra)   EMIT(ALPHA_INST_MEM(0x0c, ra, rb, imm16))
+#define ALPHA_LDBU(rb, imm16, ra)   EMIT(ALPHA_INST_MEM(0x0A, ra, rb, imm16))
+#define ALPHA_STQ(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x2d, ra, rb, imm16))
+#define ALPHA_STL(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x2c, ra, rb, imm16))
+#define ALPHA_STW(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x0d, ra, rb, imm16))
+#define ALPHA_STB(rb, imm16, ra)    EMIT(ALPHA_INST_MEM(0x0e, ra, rb, imm16))
+/* control */
+#define ALPHA_BR(disp)              EMIT(ALPHA_INST_JMP(0x30, r_zero, disp/4))
+#define ALPHA_BSR(ra, disp)         EMIT(ALPHA_INST_JMP(0x34, ra, disp/4))
+#define ALPHA_BEQ(ra, disp)         EMIT(ALPHA_INST_JMP(0x39, ra, disp/4))
+#define ALPHA_BNE(ra, disp)         EMIT(ALPHA_INST_JMP(0x3d, ra, disp/4))
+#define ALPHA_BGE(ra, disp)         EMIT(ALPHA_INST_JMP(0x3e, ra, disp/4))
+#define ALPHA_BGT(ra, disp)         EMIT(ALPHA_INST_JMP(0x3f, ra, disp/4))
+#define ALPHA_BLE(ra, disp)         EMIT(ALPHA_INST_JMP(0x3b, ra, disp/4))
+#define ALPHA_BLT(ra, disp)         EMIT(ALPHA_INST_JMP(0x3a, ra, disp/4))
+#define ALPHA_JMP(ra, rb)           EMIT(ALPHA_INST_MEM(0x1A, ra, rb, 0 << 14))
+#define ALPHA_JSR(ra, rb)           EMIT(ALPHA_INST_MEM(0x1A, ra, rb, 1 << 14))
+#define ALPHA_JSR_COR(ra, rb)       EMIT(ALPHA_INST_MEM(0x1A, ra, rb, 3 << 14))
+#define ALPHA_RET(ra, rb)           EMIT(ALPHA_INST_MEM(0x1A, ra, rb, (2 << 14)|1))
+/* arith */
+#define ALPHA_ADDL(ra, rb, rc)      EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x00, rc))
+#define ALPHA_ADDLI(ra, imm8, rc)   EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x00, rc))
+#define ALPHA_SUBL(ra, rb, rc)      EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x09, rc))
+#define ALPHA_SUBLI(ra, imm8, rc)   EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x09, rc))
+#define ALPHA_MULL(ra, rb, rc)      EMIT(ALPHA_INST_OPR(0x13, ra, rb,   0x00, rc))
+#define ALPHA_MULLI(ra, imm8, rc)   EMIT(ALPHA_INST_OPI(0x13, ra, imm8, 0x00, rc))
+#define ALPHA_MULQ(ra, rb, rc)      EMIT(ALPHA_INST_OPR(0x13, ra, rb,   0x20, rc))
+#define ALPHA_MULQI(ra, imm8, rc)   EMIT(ALPHA_INST_OPI(0x13, ra, imm8, 0x20, rc))
+#define ALPHA_S4ADDL(ra, rb, rc)    EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x02, rc))
+#define ALPHA_S4ADDLI(ra, imm8, rc) EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x02, rc))
+#define ALPHA_S8ADDL(ra, rb, rc)    EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x12, rc))
+#define ALPHA_S8ADDLI(ra, imm8, rc) EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x12, rc))
+#define ALPHA_S4SUBL(ra, rb, rc)    EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x0B, rc))
+#define ALPHA_S4SUBLI(ra, imm8, rc) EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x0B, rc))
+#define ALPHA_S8SUBL(ra, rb, rc)    EMIT(ALPHA_INST_OPR(0x10, ra, rb,   0x1B, rc))
+#define ALPHA_S8SUBLI(ra, imm8, rc) EMIT(ALPHA_INST_OPI(0x10, ra, imm8, 0x1B, rc))
+/* logic */
+#define ALPHA_AND(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x11, ra, rb,   0x00, rc))
+#define ALPHA_ANDI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x11, ra, imm8, 0x00, rc))
+#define ALPHA_BIC(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x11, ra, rb,   0x08, rc))
+#define ALPHA_BICI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x11, ra, imm8, 0x08, rc))
+#define ALPHA_BIS(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x11, ra, rb,   0x20, rc))
+#define ALPHA_BISI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x11, ra, imm8, 0x20, rc))
+#define ALPHA_ORNOT(ra, rb, rc)     EMIT(ALPHA_INST_OPR(0x11, ra, rb,   0x28, rc))
+#define ALPHA_ORNOTI(ra, imm8, rc)  EMIT(ALPHA_INST_OPI(0x11, ra, imm8, 0x28, rc))
+/* shift log */
+#define ALPHA_SRL(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x34, rc))
+#define ALPHA_SRLI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x34, rc))
+#define ALPHA_SLL(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x39, rc))
+#define ALPHA_SLLI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x39, rc))
+/* shift arith */
+#define ALPHA_SRA(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x3c, rc))
+#define ALPHA_SRAI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x3c, rc))
+/* manipulator */
+#define ALPHA_ZAP(ra, rb, rc)       EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x30, rc))
+#define ALPHA_ZAPI(ra, imm8, rc)    EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x30, rc))
+#define ALPHA_ZAPNOT(ra, rb, rc)    EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x31, rc))
+#define ALPHA_ZAPNOTI(ra, imm8, rc) EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x31, rc))
+#define ALPHA_INSBL(ra, rb, rc)     EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x0b, rc))
+#define ALPHA_INSBLI(ra, imm8, rc)  EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x0b, rc))
+#define ALPHA_EXTBL(ra, rb, rc)     EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x06, rc))
+#define ALPHA_EXTBLI(ra, imm8, rc)  EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x06, rc))
+#define ALPHA_EXTWL(ra, rb, rc)     EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x16, rc))
+#define ALPHA_EXTWLI(ra, imm8, rc)  EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x16, rc))
+#define ALPHA_EXTWH(ra, rb, rc)     EMIT(ALPHA_INST_OPR(0x12, ra, rb,   0x5a, rc))
+#define ALPHA_EXTWHI(ra, imm8, rc)  EMIT(ALPHA_INST_OPI(0x12, ra, imm8, 0x5a, rc))
+
+/* pseudo instr */
+#define ALPHA_NEGL(ra, rb)     ALPHA_SUBL(r_zero, ra, rb)
+#define ALPHA_NEGLI(imm8, rb)  ALPHA_SUBLI(r_zero, imm8, rb)
+#define ALPHA_ZEXTL(ra, rb)    ALPHA_ZAPNOTI(ra, 15, rb)
+#define ALPHA_ZEXTW(ra, rb)    ALPHA_ZAPNOTI(ra, 3, rb)
+#define ALPHA_ZEXTB(ra, rb)    ALPHA_ZAPNOTI(ra, 1, rb)
+#define ALPHA_SEXTL(ra, rb)    ALPHA_ADDL(r_zero, ra, rb)
+#define ALPHA_SEXTLI(imm8, rb) ALPHA_ADDLI(r_zero, imm8, rb)
+#define ALPHA_MOV(ra, rb)      ALPHA_BIS(r_zero, ra, rb)
+#define ALPHA_CLR(ra)          ALPHA_BIS(r_zero, r_zero, ra)
+#define ALPHA_UNOP()           ALPHA_LDQ_U(r_zero, 0, 0)
+/* shorthands */
+#define CLEAR_A() ALPHA_CLR(r_A)
+#define CLEAR_X() ALPHA_CLR(r_X)
+
+
+/*
+ * Vars
+ */
+int bpf_jit_enable __read_mostly;
+int optimize_size __read_mostly;
+
+/* Pseudo symbol to call out to div helper */
+extern u32 __divlu[1];
+
+/*
+ * Helper
+ */
+static inline bool is_imm8(unsigned int K)
+{
+	return K <= 255;
+}
+
+static inline bool is_imm16(int K)
+{
+	return K >= -32768 && K <= 32767;
+}
+
+#define is_imm_jdisp(k) _is_imm_jdisp(k, ctx->idx)
+
+static bool _is_imm_jdisp(int K, unsigned int idx)
+{
+	if ((K % 4) != 0)
+		pr_info("JIT: jump displacement of %i on idx %u is not evenly dividable by 4!\n", K, idx);
+	K /= 4;
+	return K >= (-0x1FFFFF) && K <= 0xfffff;
+}
+
+static void emit_single_c(u32 *image, struct codegen_context *ctx,
+			  int K, int r_s, int r_t)
+{
+	if (K == 0) {
+		if (r_s != r_t)
+			ALPHA_MOV(r_s, r_t);
+	} else if (is_imm8(K))
+		ALPHA_ADDLI(r_s, K, r_t);
+	else if (is_imm8(-K))
+		ALPHA_SUBLI(r_s, -K, r_t);
+	else if (is_imm16(K))
+		ALPHA_LDA(r_s, K, r_t);
+	else if ((K & 0xffff) == 0)
+		ALPHA_LDAH(r_s, K>>16, r_t);
+	else {
+		pr_err("JIT: unexpected load constant");
+		BUG();
+	}
+}
+
+static void constant_breakdown(int K, int *low, int *extra, int *high)
+{
+	int diff;
+
+	*extra = 0;
+	/*
+	 * typical RISC, constant handling is a PITA.
+	 * taking a peak into GCC 3.3.6 how to break down a constant load.
+	 */
+	*low  = ((K & 0xffff) ^ 0x8000) - 0x8000;
+	diff = K - *low;
+	*high = (((diff >> 16) & 0xffff) ^ 0x8000) - 0x8000;
+
+	if ((*high & 0x8000) != 0 && K >= 0) {
+		*extra = 0x4000;
+		diff -= 0x40000000;
+		*high  = ((diff >> 16) & 0xffff) - 2 * ((diff >> 16) & 0x8000);
+	}
+}
+
+static unsigned int constant_needs(int K)
+{
+	int low, extra, high;
+
+	constant_breakdown(K, &low, &extra, &high);
+	if (K == low || (low == 0 && extra == 0))
+		return 1;
+	if (extra)
+		return 3;
+	return 2;
+}
+
+static void add_constant(u32 *image, struct codegen_context *ctx,
+			 int K, int r_s, int r_t)
+{
+	int low, extra, high;
+
+	constant_breakdown(K, &low, &extra, &high);
+
+	if (K == low || (low == 0 && extra == 0)) {
+		emit_single_c(image, ctx, K, r_s, r_t);
+		return;
+	}
+
+	emit_single_c(image, ctx, high << 16, r_s, r_t);
+	if (extra)
+		emit_single_c(image, ctx, extra << 16, r_t, r_t);
+	emit_single_c(image, ctx, low, r_t, r_t);
+}
+
+static void load_complex_constant(u32 *image, struct codegen_context *ctx,
+				  unsigned int i, int K, int r)
+
+{
+	if (K == 0) {
+		ALPHA_CLR(r);
+		return;
+	}
+	if (optimize_size == 0 || constant_needs(K) < 2 ||
+	    i > (0x7fff/sizeof(struct sock_filter))) {
+		add_constant(image, ctx, K, r_zero, r);
+	} else {
+		/* load the constant from the filter program */
+		ALPHA_LDL(r_sf, (i * sizeof(struct sock_filter)) +
+			  offsetof(struct sock_filter, k), r);
+	}
+}
+
+static void optimize_add(u32 *image, struct codegen_context *ctx,
+			 unsigned int i, unsigned int K, int r_t)
+{
+	if (K == 0)
+		return;
+
+	if (optimize_size == 0 || constant_needs(K) < 2 ||
+	    i > (0x7fff/sizeof(struct sock_filter))) {
+		add_constant(image, ctx, K, r_A, r_t);
+		ALPHA_SEXTL(r_t, r_t);
+	} else {
+		/* load the constant from the filter program */
+		ALPHA_LDL(r_sf, (i * sizeof(struct sock_filter)) +
+			  offsetof(struct sock_filter, k), r_scratch1);
+		ALPHA_ADDL(r_A, r_scratch1, r_t);
+	}
+}
+
+static void optimize_sub(u32 *image, struct codegen_context *ctx,
+			unsigned int i, unsigned int K, int r_t)
+{
+	if (K == 0)
+		return;
+
+	if (optimize_size == 0 || constant_needs(K) < 2 ||
+	    i > (0x7fff/sizeof(struct sock_filter))) {
+		optimize_add(image, ctx, i, -K, r_t);
+	} else {
+		/* load the constant from the filter program */
+		ALPHA_LDL(r_sf, (i * sizeof(struct sock_filter)) +
+			  offsetof(struct sock_filter, k), r_scratch1);
+		ALPHA_SUBL(r_A, r_scratch1, r_t);
+	}
+}
+
+static void optimize_mull(u32 *image, struct codegen_context *ctx,
+			  unsigned int i, unsigned int K)
+{
+	switch (K) {
+	case  0:
+		CLEAR_A(); /* fallthrough */
+	case  1:
+		return;
+	case  2:
+		ALPHA_ADDL(r_A, r_A, r_A);
+		return;
+	case  3:
+		ALPHA_S4SUBL(r_A, r_A, r_A);
+		return;
+	case  4:
+		ALPHA_S4ADDL(r_A, r_zero, r_A);
+		return;
+	case  5:
+		ALPHA_S4ADDL(r_A, r_A, r_A);
+		return;
+	case  6:
+		ALPHA_S4ADDL(r_A, r_A, r_scratch1);
+		ALPHA_ADDL(r_A, r_scratch1, r_A);
+		return;
+	case  7:
+		ALPHA_S8SUBL(r_A, r_A, r_A);
+		return;
+	case  8:
+		ALPHA_S8ADDL(r_A, r_zero, r_A);
+		return;
+	case  9:
+		ALPHA_S8ADDL(r_A, r_A, r_A);
+		return;
+	case 10:
+		ALPHA_S8ADDL(r_A, r_A, r_scratch1);
+		ALPHA_ADDL(r_A, r_scratch1, r_A);
+		return;
+	case 11:
+		ALPHA_S8SUBL(r_A, r_A, r_scratch1);
+		ALPHA_S4ADDL(r_A, r_scratch1, r_A);
+	case 12:
+		ALPHA_S8ADDL(r_A, r_zero, r_scratch1);
+		ALPHA_S4ADDL(r_A, r_scratch1, r_A);
+		return;
+	case 13:
+		ALPHA_S8ADDL(r_A, r_A, r_scratch1);
+		ALPHA_S4ADDL(r_A, r_scratch1, r_A);
+/* TODO: test for more fun with s4add/s8add and shifts */
+	default:
+		break;
+	}
+
+	if (is_imm8(K)) {
+		ALPHA_MULLI(r_A, r_A, K);
+	} else {
+		load_complex_constant(image, ctx, i, K, r_scratch1);
+		ALPHA_MULL(r_A, r_scratch1, r_A);
+	}
+}
+
+static void optimize_and(u32 *image, struct codegen_context *ctx,
+			 unsigned int i, unsigned int K, int r_t)
+{
+	unsigned int j, mask;
+	u8 bit;
+
+	if (K == 0xffffffff)
+		return;
+
+	if (K == 0) {
+		ALPHA_CLR(r_t);
+		return;
+	}
+	mask = 0xff; bit = 1;
+	for (j = 0; j < 4; j++, mask <<= 8, bit <<= 1) {
+		if (K == mask) {
+			ALPHA_ZAPNOTI(r_A,  bit, r_t);
+			return;
+		}
+	}
+	mask = 0xff00ff; bit = 5;
+	for (j = 0; j < 2; j++, mask <<= 8, bit <<= 1) {
+		if (K == mask) {
+			ALPHA_ZAPNOTI(r_A,  bit, r_t);
+			return;
+		}
+	}
+	mask = 0xffffff; bit = 7;
+	for (j = 0; j < 4; j++, mask = rol32(mask, 8), bit = rol8(bit, 1)) {
+		if (K == mask) {
+			ALPHA_ZAPNOTI(r_A,  bit, r_t);
+			return;
+		}
+	}
+	mask = 0xffff; bit = 3;
+	for (j = 0; j < 4; j++, mask = rol32(mask, 8), bit = rol8(bit, 1)) {
+		if (K == mask) {
+			ALPHA_ZAPNOTI(r_A,  bit, r_t);
+			return;
+		}
+	}
+
+/* TODO: test for more fun with zap/zapnot */
+
+	if (is_imm8(K)) {
+		ALPHA_ANDI(r_A, K, r_t);
+	} else if (is_imm8(~K)) {
+		ALPHA_BICI(r_A, ~K, r_t);
+	} else if ((constant_needs(K) != 1 && constant_needs(~K) == 1 &&
+		    i <= (0x7fff/sizeof(struct sock_filter))) ||
+		   (constant_needs(K) > constant_needs(~K) &&
+		    (i > (0x7fff/sizeof(struct sock_filter)) ||
+		     optimize_size == 0))) {
+		load_complex_constant(image, ctx, i, ~K, r_scratch1);
+		ALPHA_BIC(r_A, r_scratch1, r_t);
+	} else {
+		load_complex_constant(image, ctx, i, K, r_scratch1);
+		ALPHA_AND(r_A, r_scratch1, r_t);
+	}
+}
+
+static void optimize_or(u32 *image, struct codegen_context *ctx,
+			unsigned int i, unsigned int K)
+{
+	if (K == 0xffffffff) {
+		ALPHA_SUBLI(r_zero, 1, r_A);
+		ALPHA_ZEXTL(r_A, r_A);
+		return;
+	}
+
+	if (K == 0)
+		return;
+
+	if (is_imm8(K)) {
+		ALPHA_BISI(r_A, K, r_A);
+	} else if (is_imm8(~K)) {
+		ALPHA_ORNOTI(r_A, ~K, r_A);
+	} else if ((constant_needs(K) != 1 && constant_needs(~K) == 1 &&
+		    i <= (0x7fff/sizeof(struct sock_filter))) ||
+		   (constant_needs(K) > constant_needs(~K) &&
+		    (i > (0x7fff/sizeof(struct sock_filter)) ||
+		     optimize_size == 0))) {
+		load_complex_constant(image, ctx, i, ~K, r_scratch1);
+		ALPHA_ORNOT(r_A, r_scratch1, r_A);
+	} else {
+		load_complex_constant(image, ctx, i, K, r_scratch1);
+		ALPHA_BIS(r_A, r_scratch1, r_A);
+	}
+}
+
+static void emit_ldwu(u32 *image, struct codegen_context *ctx,
+		      unsigned int off, int r_p, int r)
+{
+	if (amask(AMASK_BWX)) {
+		ALPHA_LDWU(r_p, off, r);
+	} else if ((off & -4) != 3) {
+		ALPHA_LDL(r_p, off & -4, r);
+		off &= 4-1;
+		if (off == 0)
+			ALPHA_ZEXTW(r, r);
+		else
+			ALPHA_EXTWLI(r, off, r);
+	} else if ((off & -8) != 7) {
+		ALPHA_LDQ(r_p, off & -8, r);
+		off &= 8-1;
+		ALPHA_EXTWLI(r, off, r);
+	} else {
+		ALPHA_LDQ(r_p, off & -8, r_scratch1);
+		ALPHA_LDQ(r_p, (off & -8)+8, r);
+		off &= 8-1;
+		ALPHA_EXTWLI(r_scratch1, off, r_scratch1);
+		ALPHA_EXTWHI(r, off, r);
+		ALPHA_BIS(r, r_scratch1, r);
+	}
+}
+
+static void emit_jmp(u32 *image, struct codegen_context *ctx, unsigned int dest)
+{
+	long long ldisp = (long long)dest - ((ctx->idx + 1) * 4);
+	int disp;
+
+	if (ldisp == 0)
+		return;
+
+	if (ldisp < -2147483648 || ldisp > 2147483647) {
+		pr_err("JIT: 64 bit jump displacement: %lld 0x%16.16llx\n", ldisp, ldisp);
+		BUG();
+	}
+	disp = ldisp;
+	if (!is_imm_jdisp(disp)) {
+		add_constant(image, ctx, dest, r_pv, r_scratch1);
+		ALPHA_JMP(r_zero, r_scratch1);
+		return;
+	}
+	ALPHA_BR(disp);
+}
+
+static void emit_cjmp(u32 *image, struct codegen_context *ctx,
+		      unsigned int dest, enum cond c, int r)
+{
+	long long ldisp = (long long)dest - ((ctx->idx + 1) * 4);
+	int disp;
+
+	if (ldisp < -2147483648 || ldisp > 2147483647) {
+		pr_err("JIT: 64 bit cjump displacement: %lld 0x%16.16llx\n", ldisp, ldisp);
+		BUG();
+	}
+	disp = ldisp;
+	if (!is_imm_jdisp(disp)) {
+		unsigned int cn = constant_needs(dest) + 1;
+		emit_cjmp(image, ctx, (ctx->idx + 1 + cn) * 4, c ^ COND_MSK, r);
+		add_constant(image, ctx, dest, r_pv, r_scratch1);
+		ALPHA_JMP(r_zero, r_scratch1);
+		return;
+	}
+
+	switch (c) {
+	case COND_EQ:
+		ALPHA_BEQ(r, disp);
+		break;
+	case COND_NE:
+		ALPHA_BNE(r, disp);
+		break;
+	case COND_GE:
+		ALPHA_BGE(r, disp);
+		break;
+	case COND_GT:
+		ALPHA_BGT(r, disp);
+		break;
+	case COND_LE:
+		ALPHA_BLE(r, disp);
+		break;
+	case COND_LT:
+		ALPHA_BLT(r, disp);
+		break;
+	}
+}
+
+static void emit_call(u32 *image, struct codegen_context *ctx,
+		      void *func, int r)
+{
+	ptrdiff_t disp = (char *)func - (char *)&image[ctx->idx + 1];
+	if (disp >= -2147483648 && disp <= 2147483647) {
+		if (is_imm_jdisp(disp)) {
+			ALPHA_BSR(r, disp);
+			return;
+		}
+
+		disp = (char *)func - (char *)image;
+		if (disp >= -2147483648 && disp <= 2147483647) {
+			add_constant(image, ctx, disp, r_pv, r_scratch1);
+			ALPHA_JSR(r, r_scratch1);
+			return;
+		}
+	}
+
+	if (image != NULL) {
+		pr_err("JIT: 64 Bit call displacement: %td 0x%16.16tx\n", disp, disp);
+		BUG();
+	} else {
+		ctx->idx += 4;
+	}
+}
+
+/*
+ * Main functions
+ */
+#define need_epilogue(ctx) ((ctx->seen & (SEEN_MEM)) != 0)
+static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
+				   struct codegen_context *ctx)
+{
+	const struct sock_filter *filter = fp->insns;
+
+	if (ctx->seen & (SEEN_MEM)) /* Make stackframe */
+		ALPHA_LDA(r_sp, -BPF_ALPHA_STACKFRAME, r_sp);
+
+	if (ctx->seen & SEEN_DATAREF) {
+		/*
+		 * If this filter needs to access skb data,
+		 * prepare r_D and r_HL:
+		 *  r_HL = skb->len - skb->data_len
+		 *  r_D	 = skb->data
+		 */
+		ALPHA_LDL(r_skb, offsetof(struct sk_buff, data_len), r_scratch1);
+		ALPHA_LDL(r_skb, offsetof(struct sk_buff, len), r_HL);
+		ALPHA_ZEXTL(r_scratch1, r_scratch1);
+		ALPHA_ZEXTL(r_HL, r_HL);
+		ALPHA_LDQ(r_skb, offsetof(struct sk_buff, data), r_D);
+		ALPHA_SUBL(r_HL, r_scratch1, r_HL);
+	}
+
+	if (ctx->seen & SEEN_XREG) {
+		/*
+		 * TODO: Could also detect whether first instr. sets X and
+		 * avoid this (as below, with A).
+		 */
+		CLEAR_X();
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
+		CLEAR_A();
+	}
+}
+
+static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
+{
+	if (ctx->seen & (SEEN_MEM))
+		ALPHA_LDA(r_sp, BPF_ALPHA_STACKFRAME, r_sp);
+	/* Our pristine return pointer should be in r26. */
+	ALPHA_RET(r_zero, r_ra);
+}
+
+#define CHOOSE_LOAD_FUNC(K, func) \
+	(amask(AMASK_BWX) ? \
+	 ((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset_bwx : func##_bwx) : func##_positive_offset_bwx) :\
+	 ((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset))
+
+/* Assemble the body code between the prologue & epilogue. */
+static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
+			      struct codegen_context *ctx,
+			      unsigned int *addrs)
+{
+	const struct sock_filter *filter = fp->insns;
+	u32 *func;
+	int flen = fp->len;
+	unsigned int off;
+	enum cond true_cond;
+	int i, r;
+
+	/* Start of epilogue code */
+	unsigned int exit_addr = addrs[flen];
+
+	for (i = 0; i < flen; i++) {
+		unsigned int K = filter[i].k;
+
+		/*
+		 * addrs[] maps a BPF bytecode address into a real offset
+		 * from the start of the body code.
+		 */
+		addrs[i] = ctx->idx * 4;
+
+		switch (filter[i].code) {
+			/*** ALU ops ***/
+		case BPF_S_ALU_ADD_X: /* A += X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_ADDL(r_A, r_X, r_A);
+			break;
+		case BPF_S_ALU_ADD_K: /* A += K; */
+			optimize_add(image, ctx, i, K, r_A);
+			break;
+		case BPF_S_ALU_SUB_X: /* A -= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_SUBL(r_A, r_X, r_A);
+			break;
+		case BPF_S_ALU_SUB_K: /* A -= K */
+			optimize_sub(image, ctx, i, K, r_A);
+			break;
+		case BPF_S_ALU_MUL_X: /* A *= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_MULL(r_A, r_X, r_A);
+			break;
+		case BPF_S_ALU_MUL_K: /* A *= K */
+			optimize_mull(image, ctx, i, K);
+			break;
+		case BPF_S_ALU_DIV_X: /* A /= X; */
+			ctx->seen |= SEEN_XREG|SEEN_DIV;
+			if (ctx->pc_ret0 != -1) {
+				emit_cjmp(image, ctx, addrs[ctx->pc_ret0],
+					  COND_EQ, r_X);
+			} else {
+				/* Exit, returning 0 */
+				emit_cjmp(image, ctx, (ctx->idx*4)+8,
+					  COND_NE, r_X);
+				ctx->pc_ret0 = i;
+				ALPHA_CLR(r_ret);
+				emit_jmp(image, ctx, exit_addr);
+			}
+			ALPHA_MOV(r_pv, r_scratch1);
+			ALPHA_MOV(r_A, 24);
+			ALPHA_MOV(r_X, 25);
+			emit_call(image, ctx, __divlu, r_div_link);
+			ALPHA_MOV(27, r_A);
+			ALPHA_MOV(r_scratch1, r_pv);
+			break;
+		case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K); */
+			load_complex_constant(image, ctx, i, K, r_scratch1);
+			/* Top 32 bits of 64bit result -> A */
+			ALPHA_MULQ(r_A, r_scratch1, r_A);
+			ALPHA_SRLI(r_A, 32, r_A);
+			break;
+		case BPF_S_ALU_AND_X: /* A &= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_AND(r_A, r_X, r_A);
+			break;
+		case BPF_S_ALU_AND_K: /* A &= K; */
+			optimize_and(image, ctx, i, K, r_A);
+			break;
+		case BPF_S_ALU_OR_X: /* A |= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_BIS(r_A, r_X, r_A);
+			break;
+		case BPF_S_ALU_OR_K: /* A |= K; */
+			optimize_or(image, ctx, i, K);
+			break;
+		case BPF_S_ALU_LSH_X: /* A <<= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_SLL(r_A, r_X, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_ALU_LSH_K: /* A <<= K; */
+			if (K != 0) {
+				ALPHA_SLLI(r_A, K & 0x3f, r_A);
+				ALPHA_ZEXTL(r_A, r_A);
+			}
+			break;
+		case BPF_S_ALU_RSH_X: /* A >>= X; */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_SRL(r_A, r_X, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_ALU_RSH_K: /* A >>= K; */
+			if (K != 0) {
+				ALPHA_SRLI(r_A, K & 0x3f, r_A);
+				ALPHA_ZEXTL(r_A, r_A);
+			}
+			break;
+		case BPF_S_ALU_NEG:
+			ALPHA_NEGL(r_A, r_A);
+			break;
+		case BPF_S_RET_K:
+			load_complex_constant(image, ctx, i, K, r_ret);
+			if (K == 0)
+				ctx->pc_ret0 = i;
+			/*
+			 * If this isn't the very last instruction, branch to
+			 * the epilogue if we've stuff to clean up. Otherwise,
+			 * if there's nothing to tidy, just return. If we
+			 * /are/ the last instruction, we're about to fall
+			 * through to the epilogue to return.
+			 */
+			if (i != flen - 1) {
+				if (!image || need_epilogue(ctx))
+					emit_jmp(image, ctx, exit_addr);
+				else
+					ALPHA_RET(r_zero, r_ra);
+			}
+			break;
+		case BPF_S_RET_A:
+			/* r_A and r_ret are the same reg */
+			/* ALPHA_MOV(r_A, r_ret); */
+			if (i != flen - 1) {
+				if (!image || need_epilogue(ctx))
+					emit_jmp(image, ctx, exit_addr);
+				else
+					ALPHA_RET(r_zero, r_ra);
+			}
+			break;
+		case BPF_S_MISC_TAX: /* X = A */
+			ALPHA_MOV(r_A, r_X);
+			break;
+		case BPF_S_MISC_TXA: /* A = X */
+			ctx->seen |= SEEN_XREG;
+			ALPHA_MOV(r_X, r_A);
+			break;
+
+			/*** Constant loads/M[] access ***/
+		case BPF_S_LD_IMM: /* A = K */
+			load_complex_constant(image, ctx, i, K, r_A);
+			break;
+		case BPF_S_LDX_IMM: /* X = K */
+			load_complex_constant(image, ctx, i, K, r_X);
+			break;
+		case BPF_S_LD_MEM: /* A = mem[K] */
+			ALPHA_LDL(r_sp, (K & 0xf) * 4, r_A);
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_LDX_MEM: /* X = mem[K] */
+			ALPHA_LDL(r_sp, (K & 0xf) * 4, r_X);
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_ST: /* mem[K] = A */
+			ALPHA_STL(r_sp, (K & 0xf) * 4, r_A);
+			ctx->seen |= SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_STX: /* mem[K] = X */
+			ALPHA_STL(r_sp, (K & 0xf) * 4, r_X);
+			ctx->seen |= SEEN_XREG | SEEN_MEM | (1<<(K & 0xf));
+			break;
+		case BPF_S_LD_W_LEN: /*	A = skb->len; */
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
+			off = offsetof(struct sk_buff, len);
+			ALPHA_LDL(r_skb, off, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_LDX_W_LEN: /* X = skb->len; */
+			off = offsetof(struct sk_buff, len);
+			ALPHA_LDL(r_skb, off, r_X);
+			ALPHA_ZEXTL(r_X, r_X);
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
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
+			off = offsetof(struct sk_buff, protocol);
+			emit_ldwu(image, ctx, off, r_skb, r_A);
+			ALPHA_SRLI(r_A, 8, r_scratch1);
+			ALPHA_INSBLI(r_A, 1, r_A);
+			ALPHA_BIS(r_scratch1, r_A, r_A);
+			break;
+		case BPF_S_ANC_IFINDEX:
+			off = offsetof(struct sk_buff, dev);
+			ALPHA_LDQ(r_skb, off, r_scratch1);
+			if (ctx->pc_ret0 != -1) {
+				emit_cjmp(image, ctx, addrs[ctx->pc_ret0],
+					  COND_EQ, r_scratch1);
+			} else {
+				/* Exit, returning 0; first pass hits here. */
+				emit_cjmp(image, ctx, (ctx->idx*4)+8,
+					  COND_NE, r_scratch1);
+				ctx->pc_ret0 = i;
+				ALPHA_CLR(r_ret);
+				emit_jmp(image, ctx, exit_addr);
+			}
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
+			off = offsetof(struct net_device, ifindex);
+			ALPHA_LDL(r_scratch1, off, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_ANC_MARK:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
+			off = offsetof(struct sk_buff, mark);
+			ALPHA_LDL(r_skb, off, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_ANC_RXHASH:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
+			off = offsetof(struct sk_buff, rxhash);
+			ALPHA_LDL(r_skb, off, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+			break;
+		case BPF_S_ANC_QUEUE:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
+			off = offsetof(struct sk_buff, queue_mapping);
+			emit_ldwu(image, ctx, off, r_skb, r_A);
+			break;
+		case BPF_S_ANC_CPU:
+#ifdef CONFIG_SMP
+			/*
+			 * current_thread_info is in r8
+			 * raw_smp_processor_id() = current_thread_info()->cpu
+			 */
+			BUILD_BUG_ON(FIELD_SIZEOF(struct thread_info, cpu) != 4);
+			off = offsetof(struct thread_info, cpu);
+			ALPHA_LDL(r_curthread, off, r_A);
+			ALPHA_ZEXTL(r_A, r_A);
+#else
+			CLEAR_A();
+#endif
+			break;
+
+			/*** Absolute loads from packet header/data ***/
+		case BPF_S_LD_W_ABS:
+			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
+			goto common_load;
+		case BPF_S_LD_H_ABS:
+			func = CHOOSE_LOAD_FUNC(K, sk_load_half);
+			goto common_load;
+		case BPF_S_LD_B_ABS:
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
+common_load:
+			/* Load from [K]. */
+			ctx->seen |= SEEN_DATAREF;
+			load_complex_constant(image, ctx, i, K, r_addr);
+			emit_call(image, ctx, func, r_div_link);
+			/*
+			 * Helper returns != 0 in r28 on error, and an
+			 * appropriate return value in r0
+			 */
+			emit_cjmp(image, ctx, exit_addr, COND_NE, r_at);
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
+common_load_ind:
+			/*
+			 * Load from [X + K].  Negative offsets are tested for
+			 * in the helper functions.
+			 */
+			ctx->seen |= SEEN_DATAREF | SEEN_XREG;
+			add_constant(image, ctx, K, r_X, r_addr);
+			ALPHA_SEXTL(r_addr, r_addr);
+			emit_call(image, ctx, func, r_div_link);
+			/* If error, r28 set */
+			emit_cjmp(image, ctx, exit_addr, COND_NE, r_at);
+			break;
+
+		case BPF_S_LDX_B_MSH:
+			func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
+			goto common_load;
+			break;
+
+			/*** Jump and branches ***/
+		case BPF_S_JMP_JA:
+			if (K != 0)
+				emit_jmp(image, ctx, addrs[i + 1 + K]);
+			break;
+
+		case BPF_S_JMP_JGT_K:
+		case BPF_S_JMP_JGT_X:
+			true_cond  = COND_GT;
+			goto cond_branch;
+		case BPF_S_JMP_JGE_K:
+		case BPF_S_JMP_JGE_X:
+			true_cond  = COND_GE;
+			goto cond_branch;
+		case BPF_S_JMP_JEQ_K:
+		case BPF_S_JMP_JEQ_X:
+			true_cond  = COND_EQ;
+			goto cond_branch;
+		case BPF_S_JMP_JSET_K:
+		case BPF_S_JMP_JSET_X:
+			true_cond  = COND_NE;
+			/* Fall through */
+cond_branch:
+			/* same targets, can avoid doing the test :) */
+			if (filter[i].jt == filter[i].jf) {
+				if (filter[i].jt > 0)
+					emit_jmp(image, ctx,
+						 addrs[i + 1 + filter[i].jt]);
+				break;
+			}
+
+			r = r_scratch1;
+			switch (filter[i].code) {
+			case BPF_S_JMP_JGT_X:
+			case BPF_S_JMP_JGE_X:
+			case BPF_S_JMP_JEQ_X:
+				ctx->seen |= SEEN_XREG;
+				ALPHA_SUBL(r_A, r_X, r_scratch1);
+				break;
+			case BPF_S_JMP_JSET_X:
+				ctx->seen |= SEEN_XREG;
+				ALPHA_AND(r_A, r_X, r_scratch1);
+				break;
+			case BPF_S_JMP_JEQ_K:
+			case BPF_S_JMP_JGT_K:
+			case BPF_S_JMP_JGE_K:
+				if (K != 0)
+					optimize_sub(image, ctx, i, K, r_scratch1);
+				else
+					r = r_A;
+				break;
+			case BPF_S_JMP_JSET_K:
+				if (K != 0xffffffff && K != 0)
+					optimize_and(image, ctx, i, K, r_scratch1);
+				else if (K == 0)
+					goto cond_emit_fbr;
+				else
+					r = r_A;
+				break;
+			}
+			/* Sometimes branches are constructed "backward", with
+			 * the false path being the branch and true path being
+			 * a fallthrough to the next instruction.
+			 */
+			if (filter[i].jt == 0) {
+				/* Swap the sense of the branch */
+				emit_cjmp(image, ctx, addrs[i + 1 + filter[i].jf],
+					  true_cond ^ COND_MSK, r);
+			} else {
+				emit_cjmp(image, ctx, addrs[i + 1 + filter[i].jt],
+					  true_cond, r);
+cond_emit_fbr:
+				if (filter[i].jf != 0)
+					emit_jmp(image, ctx, addrs[i + 1 + filter[i].jf]);
+			}
+			break;
+		default:
+			/* The filter contains something cruel & unusual.
+			 * We don't handle it, but also there shouldn't be
+			 * anything missing from our list.
+			 */
+			if (printk_ratelimit())
+				pr_err("BPF filter opcode %04x (@%d) unsupported\n",
+				       filter[i].code, i);
+			return -ENOTSUPP;
+		}
+	}
+	/* Set end-of-body-code address for exit. */
+	addrs[i] = ctx->idx * 4;
+
+	return 0;
+}
+
+static inline void bpf_flush_icache(void *start, void *end)
+{
+	mb();
+/*
+ * TODO: alpha is so loosly ordered, do we need to give it more
+ * whacks over the head?
+ */
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+}
+
+void bpf_jit_compile(struct sk_filter *fp)
+{
+	unsigned int proglen, lastlen;
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
+	 * The range of standard conditional branches is 21 bit, which is good
+	 * for +/- 1M instructions. This should be enough for
+	 * BPF_MAXINSNS = 4096.
+	 *
+	 * Current:
+	 *
+	 * First pass: No code buffer; Program is "faux-generated" -- no code
+	 * emitted but maximum size of output determined (and addrs[] filled
+	 * in). Also, we note whether we use M[], whether we use skb data, etc.
+	 * All generation choices assumed to be 'worst-case', return path code
+	 * reduction not available, etc.
+	 *
+	 * Second pass: Again no code buffer; addrs[] is filled and jumps
+	 * should settle, since the exit points are set. This should get
+	 * it mostly stable so no suprise growth happens. addrs[] is set agian.
+	 *
+	 * Other passes: Code buffer allocated with size determined previously.
+	 * Prologue generated to support features we have seen used. addrs[]
+	 * is filled in again, as code may be slightly smaller as a result.
+	 *
+	 */
+
+	cgctx.seen = 0;
+	cgctx.pc_ret0 = -1;
+	/* Scouting faux-generate pass 0 */
+	if (bpf_jit_build_body(fp, 0, &cgctx, addrs))
+		/* We hit something illegal or unsupported. */
+		goto out;
+	lastlen =  cgctx.idx * 4;
+
+	/* reset */
+	cgctx.idx = 0;
+	/*
+	 * Pretend to build an prologue, given the features we've seen.
+	 * This may influence some offsets
+	 */
+	bpf_jit_build_prologue(fp, 0, &cgctx);
+	proglen =  cgctx.idx;
+	/* Let a second faux-generate pass run to settle some jumps */
+	if (bpf_jit_build_body(fp, 0, &cgctx, addrs))
+		/* We hit something illegal or unsupported. */
+		goto out;
+
+	if (bpf_jit_enable > 1)
+		pr_info("Pass 2: shrink = %d, seen = 0x%x\n",
+			lastlen - ((cgctx.idx - proglen) * 4), cgctx.seen);
+
+	/* Pretend to build epilogue, given the features we've seen. */
+	bpf_jit_build_epilogue(0, &cgctx);
+	/*
+	 * Now ctgtx.idx is updated as we pretended to output instructions,
+	 * the total size aproximation can now be calculated from idx.
+	 */
+
+	lastlen = proglen = cgctx.idx * 4;
+	/* now allocate mem, to get the final mem addr */
+	image = module_alloc(max_t(unsigned int, proglen,
+				   sizeof(struct work_struct)));
+	if (!image)
+		goto out;
+
+	code_base = image;
+
+	/* Code generation passes 3-n */
+	for (pass = 3; pass < 6; pass++, lastlen = cgctx.idx * 4) {
+		/* Now build the prologue, body code & epilogue for real. */
+		cgctx.idx = 0;
+		bpf_jit_build_prologue(fp, code_base, &cgctx);
+		bpf_jit_build_body(fp, code_base, &cgctx, addrs);
+		bpf_jit_build_epilogue(code_base, &cgctx);
+
+		if (bpf_jit_enable > 1)
+			pr_info("Pass %d: shrink = %d, seen = 0x%x\n", pass,
+				lastlen - (cgctx.idx * 4), cgctx.seen);
+		/* has size settled? */
+		if ((lastlen - (cgctx.idx * 4)) == 0)
+			break;
+	}
+
+	if (bpf_jit_enable > 1)
+		pr_info("flen=%d proglen=%u pass=%d image=%p\n",
+		       flen, lastlen, pass, image);
+
+	if (image) {
+		if (bpf_jit_enable > 1)
+			print_hex_dump(KERN_ERR, "JIT code: ",
+				       DUMP_PREFIX_ADDRESS,
+				       32, 4, code_base,
+				       lastlen, false);
+
+		bpf_flush_icache(code_base, code_base + (proglen/4));
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
diff --git a/arch/alpha/net/bpf_jit_helper.S b/arch/alpha/net/bpf_jit_helper.S
new file mode 100644
index 0000000..1288c76
--- /dev/null
+++ b/arch/alpha/net/bpf_jit_helper.S
@@ -0,0 +1,469 @@
+/* bpf_jit_helper.S: Packet/header access helper functions
+ * for Alpha BPF compiler.
+ *
+ * Copyright 2012 Jan Seiffert <kaffeemonster@googlemail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <asm/regdef.h>
+#include "bpf_jit.h"
+
+#define FUNC_ALIGN 4
+#define SKF_MAX_OFF(ra, rc)	ldah	rc, -32(ra)
+
+	.align	4
+	.arch	ev6
+	.set	noat
+/*
+ * All of these routines are called directly from generated code,
+ * whose register usage is:
+ *
+ * r_skb	skb
+ * r_A,r_X	A,X
+ * r_ret	filter return value
+ * r_addr	*** address parameter to helper ***
+ * r_scratch1	scratch
+ * r_D		skb->data
+ * r_HL		skb headlen
+ * r_div_link	return address
+ */
+
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_word
+	.ent	sk_load_word
+	.prologue 0
+sk_load_word:
+	.globl	sk_load_word_bwx
+sk_load_word_bwx:
+	blt	r_addr, bpf_slow_path_word_neg
+	.globl	sk_load_word_positive_offset
+sk_load_word_positive_offset:
+	.globl	sk_load_word_positive_offset_bwx
+sk_load_word_positive_offset_bwx:
+	/* Are we accessing past headlen? */
+	subl	r_HL, 4, r_scratch1
+	subl	r_scratch1, r_addr, r_scratch1
+	blt	r_scratch1, bpf_slow_path_word
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+bpf_restart_word:
+	and	r_addr, 3, r_A
+	bne	r_A, bpf_load_word_unaligned
+	ldl	r_A, 0(r_addr)
+	zapnot	r_A, 15, r_A
+	br	bpf_load_word_out
+	/* full mumbo jumbo needed? */
+bpf_load_word_unaligned:
+	ldq_u	r_scratch1, 0(r_addr)
+	subq	r_addr, r_scratch1, r_A
+	cmpult	r_A, 5, r_A
+	beq	r_A, bpf_load_half_complex
+	/* load simple */
+	ldq	r_A, 0(r_scratch1)
+	extll	r_A, r_addr, r_A
+	br	bpf_load_word_out
+bpf_load_word_complex:
+	/* full mumbo jumbo */
+	ldq	r_A, 0(r_scratch1)
+	ldq	r_at, 8(r_scratch1)
+	extll	r_A, r_addr, r_A
+	extlh	r_at, r_addr, r_at
+	or	r_at, r_A, r_A
+bpf_load_word_out:
+	/* byteswap. */
+	inslh	r_A, 0x07, r_scratch1
+	inswl	r_A, 0x03, r_A
+	or	r_scratch1, r_A, r_A
+	srl	r_A, 16, r_scratch1
+	zapnot	r_A, 0x0a, r_A
+	zapnot	r_scratch1, 0x05, r_scratch1
+	or	r_A, r_scratch1, r_A
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_word
+
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_half
+	.ent	sk_load_half
+	.prologue 0
+sk_load_half:
+	blt	r_addr, bpf_slow_path_half_neg
+	.globl	sk_load_half_positive_offset
+sk_load_half_positive_offset:
+	/* Are we accessing past headlen? */
+	subl	r_HL, 2, r_scratch1
+	subl	r_scratch1, r_addr, r_scratch1
+	blt	r_scratch1, bpf_slow_path_half
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+	/* full mumbo jumbo needed? */
+bpf_restart_half:
+bpf_load_half_unaligned:
+	ldq_u	r_scratch1, 0(r_addr)
+	subq	r_addr, r_scratch1, r_A
+	cmpult	r_A, 7, r_A
+	beq	r_A, bpf_load_half_complex
+	/* load simple */
+	ldq	r_A, 0(r_scratch1)
+	extwl	r_A, r_addr, r_A
+	br	bpf_load_half_out
+bpf_load_half_complex:
+	/* full mumbo jumbo */
+	ldq	r_A, 0(r_scratch1)
+	ldq	r_at, 8(r_scratch1)
+	extwl	r_A, r_addr, r_A
+	extwh	r_at, r_addr, r_at
+	or	r_at, r_A, r_A
+bpf_load_half_out:
+	/* byteswap. */
+	srl	r_A, 8, r_scratch1
+	insbl	r_A, 1, r_A
+	or	r_scratch1, r_A, r_A
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_half
+
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_byte
+	.ent	sk_load_byte
+	.prologue 0
+sk_load_byte:
+	blt	r_addr, bpf_slow_path_byte_neg
+	.globl	sk_load_byte_positive_offset
+sk_load_byte_positive_offset:
+	/* Are we accessing past headlen? */
+	subl	r_HL, r_addr, r_scratch1
+	ble	r_scratch1, bpf_slow_path_byte
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+	/* load it */
+bpf_restart_byte:
+	ldq_u	r_scratch1, 0(r_addr)
+	ldq	r_A, 0(r_scratch1)
+	extbl	r_A, r_addr, r_A
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_byte
+
+/*
+ * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * r_addr is the offset value
+ */
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_byte_msh
+	.ent	sk_load_byte_msh
+	.prologue 0
+sk_load_byte_msh:
+	blt	r_addr, bpf_slow_path_byte_msh_neg
+	.globl	sk_load_byte_msh_positive_offset
+sk_load_byte_msh_positive_offset:
+	/* Are we accessing past headlen? */
+	subl	r_HL, r_addr, r_scratch1
+	ble	r_scratch1, bpf_slow_path_byte_msh
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+	/* load it */
+bpf_restart_byte_msh:
+	ldq_u	r_scratch1, 0(r_addr)
+	ldq	r_X, 0(r_scratch1)
+	extbl	r_X, r_addr, r_X
+	/* munge */
+bpf_load_byte_msh_out:
+	and	r_X, 0xf, r_X
+	sll	r_X, 2, r_X
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_byte_msh
+
+/*
+ * BWX helper
+ */
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_half_bwx
+	.ent	sk_load_half_bwx
+	.prologue 0
+sk_load_half_bwx:
+	blt	r_addr, bpf_slow_path_half_neg_bwx
+	.globl	sk_load_half_positive_offset_bwx
+sk_load_half_positive_offset_bwx:
+	/* Are we accessing past headlen? */
+	subl	r_HL, 2, r_scratch1
+	subl	r_scratch1, r_addr, r_scratch1
+	blt	r_scratch1, bpf_slow_path_half_bwx
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+	/* test alignment */
+bpf_restart_half_bwx:
+	and	r_addr, 1, r_A
+	bne	r_A, bpf_load_half_unaligned
+	ldwu	r_A, 0(r_addr)
+	/* byteswap. */
+	srl	r_A, 8, r_scratch1
+	insbl	r_A, 1, r_A
+	or	r_scratch1, r_A, r_A
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_half_bwx
+
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_byte_bwx
+	.ent	sk_load_byte_bwx
+	.prologue 0
+sk_load_byte_bwx:
+	blt	r_addr, bpf_slow_path_byte_neg_bwx
+	.globl	sk_load_byte_positive_offset_bwx
+sk_load_byte_positive_offset_bwx:
+	/* Are we accessing past headlen? */
+	subl	r_HL, r_addr, r_scratch1
+	ble	r_scratch1, bpf_slow_path_byte_bwx
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+bpf_restart_byte_bwx:
+	ldbu	r_A, 0(r_addr)
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_byte_bwx
+
+/*
+ * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * r_addr is the offset value
+ */
+	.p2align	FUNC_ALIGN
+	.globl	sk_load_byte_msh_bwx
+	.ent	sk_load_byte_msh_bwx
+	.prologue 0
+sk_load_byte_msh_bwx:
+	blt	r_addr, bpf_slow_path_byte_msh_neg_bwx
+	.globl	sk_load_byte_msh_positive_offset_bwx
+sk_load_byte_msh_positive_offset_bwx:
+	/* Are we accessing past headlen? */
+	subl	r_HL, r_addr, r_scratch1
+	ble	r_scratch1, bpf_slow_path_byte_msh_bwx
+	/* Nope, just hitting the header. */
+	addq	r_D, r_addr, r_addr
+bpf_restart_byte_msh_bwx:
+	ldbu	r_X, 0(r_addr)
+	/* munge */
+	and	r_X, 0xf, r_X
+	sll	r_X, 2, r_X
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+	.end	sk_load_byte_msh_bwx
+
+
+/* Call out to skb_copy_bits:
+ * We'll need to back up our volatile regs first;
+ * Allocate a new stack frame here
+ */
+#define bpf_slow_path_common(SIZE, SAVE_REG, RES_REG)		\
+	lda	r_sp, -BPF_HELPER_STACKFRAME(r_sp);		\
+	stq	SAVE_REG,	 0(r_sp);			\
+	stq	r_D,		 8(r_sp);			\
+	stq	r_HL,		16(r_sp);			\
+	stq	r_skb,		24(r_sp);			\
+	stq	r_sf,		32(r_sp);			\
+	stq	r_div_link,	40(r_sp);			\
+	stq	r_ra,		48(r_sp);			\
+	stq	r_pv,		56(r_sp);			\
+	br	pv, 1f;						\
+1:	ldgp	gp, 0(pv);					\
+	/* a0 = r_skb, as passed */				\
+	mov	r_addr, a1;					\
+	lda	a2, 64(r_sp);					\
+	lda	a3, SIZE(zero);					\
+	jsr	ra, skb_copy_bits;				\
+	/* v0 < 0 on error */					\
+	ldq	r_div_link,	40(r_sp);			\
+	ldq	r_ra,		48(r_sp);			\
+	ldq	r_pv,		56(r_sp);			\
+	blt	v0, bpf_error_slow;				\
+	ldq	SAVE_REG,	 0(r_sp);			\
+	ldq	r_D,		 8(r_sp);			\
+	ldq	r_HL,		16(r_sp);			\
+	ldq	r_skb,		24(r_sp);			\
+	ldq	r_sf,		32(r_sp);			\
+	ldq	RES_REG,	64(r_sp);			\
+	lda	r_sp, BPF_HELPER_STACKFRAME(r_sp);
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_word:
+	bpf_slow_path_common(4, r_X, r_A)
+	zapnot	r_A, 15, r_A
+	br	bpf_load_word_out
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_half_bwx:
+bpf_slow_path_half:
+	bpf_slow_path_common(2, r_X, r_A)
+	zapnot	r_A, 3, r_A
+	br	bpf_load_half_out
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_bwx:
+bpf_slow_path_byte:
+	bpf_slow_path_common(1, r_X, r_A)
+	zapnot	r_A, 1, r_A
+	/* Return success, at == 0 */
+	clr	r_at
+	ret	r_zero, (r_div_link),1
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_msh_bwx:
+bpf_slow_path_byte_msh:
+	bpf_slow_path_common(1, r_A, r_X)
+	br	bpf_load_byte_msh_out
+
+/*
+ * Error outs, in the middle for positive and negative offsets
+ */
+	.p2align	FUNC_ALIGN
+bpf_error_slow:
+	lda	r_sp, BPF_HELPER_STACKFRAME(r_sp)
+bpf_error:
+	/* set the filter return value  */
+	clr	r_ret
+	/* set error condition */
+	subl	r_zero, 1, r_at
+	ret	r_zero, (r_div_link),1
+
+/* Call out to bpf_internal_load_pointer_neg_helper:
+ * We'll need to back up our volatile regs first;
+ * Allocate a new stack frame here.
+ */
+#define bpf_slow_path_neg_common(SIZE, SAVE_REG)		\
+	lda	r_sp, -BPF_HELPER_STACKFRAME(r_sp);		\
+	stq	SAVE_REG,	 0(r_sp);			\
+	stq	r_D,		 8(r_sp);			\
+	stq	r_HL,		16(r_sp);			\
+	stq	r_skb,		24(r_sp);			\
+	stq	r_sf,		32(r_sp);			\
+	stq	r_div_link,	40(r_sp);			\
+	stq	r_ra,		48(r_sp);			\
+	stq	r_pv,		56(r_sp);			\
+	br	pv, 1f;						\
+1:	ldgp	gp,0(pv);					\
+	/* a0 = r_skb, as passed */				\
+	mov	r_addr, a1;					\
+	lda	a2, SIZE(r_zero);				\
+	jsr	ra, bpf_internal_load_pointer_neg_helper;	\
+	/* v0 != 0 on success */				\
+	ldq	r_div_link,	40(r_sp);			\
+	ldq	r_ra,		48(r_sp);			\
+	ldq	r_pv,		56(r_sp);			\
+	beq	v0, bpf_error_slow;				\
+	mov	v0, r_addr;					\
+	ldq	SAVE_REG,	 0(r_sp);			\
+	ldq	r_D,		 8(r_sp);			\
+	ldq	r_HL,		16(r_sp);			\
+	ldq	r_skb,		24(r_sp);			\
+	ldq	r_sf,		32(r_sp);			\
+	lda	r_sp, BPF_HELPER_STACKFRAME(r_sp);
+
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_word_neg:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_word_negative_offset
+	.ent	sk_load_word_negative_offset
+	.prologue 0
+sk_load_word_negative_offset:
+	.globl	sk_load_word_negative_offset_bwx
+sk_load_word_negative_offset_bwx:
+	bpf_slow_path_neg_common(4, r_A)
+	br	bpf_restart_word
+	.end	sk_load_word_negative_offset
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_half_neg:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_half_negative_offset
+	.ent	sk_load_half_negative_offset
+	.prologue 0
+sk_load_half_negative_offset:
+	bpf_slow_path_neg_common(2, r_A)
+	br	bpf_restart_half
+	.end	sk_load_half_negative_offset
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_neg:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_byte_negative_offset
+	.ent	sk_load_byte_negative_offset
+	.prologue 0
+sk_load_byte_negative_offset:
+	bpf_slow_path_neg_common(1, r_A)
+	br	bpf_restart_byte
+	.end	sk_load_byte_negative_offset
+
+/*
+ * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * r_addr is the offset value
+ */
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_msh_neg:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_byte_msh_negative_offset
+	.ent	sk_load_byte_msh_negative_offset
+	.prologue 0
+sk_load_byte_msh_negative_offset:
+	bpf_slow_path_neg_common(1, r_X)
+	br	bpf_restart_byte_msh
+	.end	sk_load_byte_msh_negative_offset
+
+/*
+ * BWX helper
+ */
+	.p2align	FUNC_ALIGN
+bpf_slow_path_half_neg_bwx:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_half_negative_offset_bwx
+	.ent	sk_load_half_negative_offset_bwx
+	.prologue 0
+sk_load_half_negative_offset_bwx:
+	bpf_slow_path_neg_common(2, r_A)
+	br	bpf_restart_half_bwx
+	.end	sk_load_half_negative_offset_bwx
+
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_neg_bwx:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_byte_negative_offset_bwx
+	.ent	sk_load_byte_negative_offset_bwx
+	.prologue 0
+sk_load_byte_negative_offset_bwx:
+	bpf_slow_path_neg_common(1, r_A)
+	br	bpf_restart_byte_bwx
+	.end	sk_load_byte_negative_offset_bwx
+
+/*
+ * BPF_S_LDX_B_MSH: ldxb  4*([offset]&0xf)
+ * r_addr is the offset value
+ */
+	.p2align	FUNC_ALIGN
+bpf_slow_path_byte_msh_neg_bwx:
+	SKF_MAX_OFF(r_addr, r_scratch1)
+	blt	r_scratch1, bpf_error
+	.globl	sk_load_byte_msh_negative_offset_bwx
+	.ent	sk_load_byte_msh_negative_offset_bwx
+	.prologue 0
+sk_load_byte_msh_negative_offset_bwx:
+	bpf_slow_path_neg_common(1, r_X)
+	br	bpf_restart_byte_msh_bwx
+	.end	sk_load_byte_msh_negative_offset_bwx
