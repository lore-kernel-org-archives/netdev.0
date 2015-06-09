From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] s390/bpf: implement bpf_tail_call() helper
Date: Mon,  8 Jun 2015 21:51:06 -0700
Message-ID: <1433825466-18306-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32856 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbbFIEvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 00:51:13 -0400
Received: by qkhg32 with SMTP id g32so3885643qkh.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 21:51:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

bpf_tail_call() arguments:

 - ctx......: Context pointer
 - jmp_table: One of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
 - index....: Index in the jump table

In this implementation s390x JIT does stack unwinding and jumps into the
callee program prologue. Caller and callee use the same stack.

With this patch a tail call generates the following code on s390x:

 if (index >= array->map.max_entries)
         goto out
 000003ff8001c7e4: e31030100016   llgf    %r1,16(%r3)
 000003ff8001c7ea: ec41001fa065   clgrj   %r4,%r1,10,3ff8001c828

 if (tail_call_cnt++ > MAX_TAIL_CALL_CNT)
         goto out;
 000003ff8001c7f0: a7080001       lhi     %r0,1
 000003ff8001c7f4: eb10f25000fa   laal    %r1,%r0,592(%r15)
 000003ff8001c7fa: ec120017207f   clij    %r1,32,2,3ff8001c828

 prog = array->prog[index];
 if (prog == NULL)
         goto out;
 000003ff8001c800: eb140003000d   sllg    %r1,%r4,3
 000003ff8001c806: e31310800004   lg      %r1,128(%r3,%r1)
 000003ff8001c80c: ec18000e007d   clgij   %r1,0,8,3ff8001c828

 Restore registers before calling function
 000003ff8001c812: eb68f2980004   lmg     %r6,%r8,664(%r15)
 000003ff8001c818: ebbff2c00004   lmg     %r11,%r15,704(%r15)

 goto *(prog->bpf_func + tail_call_start);
 000003ff8001c81e: e31100200004   lg      %r1,32(%r1,%r0)
 000003ff8001c824: 47f01006       bc      15,6(%r1)

Reviewed-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/s390/net/bpf_jit.h      |   10 +++-
 arch/s390/net/bpf_jit_comp.c |  106 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 112 insertions(+), 4 deletions(-)

diff --git a/arch/s390/net/bpf_jit.h b/arch/s390/net/bpf_jit.h
index de156ba3bd71..f6498eec9ee1 100644
--- a/arch/s390/net/bpf_jit.h
+++ b/arch/s390/net/bpf_jit.h
@@ -28,6 +28,9 @@ extern u8 sk_load_word[], sk_load_half[], sk_load_byte[];
  *	      | old backchain |     |
  *	      +---------------+     |
  *	      |   r15 - r6    |     |
+ *	      +---------------+     |
+ *	      | 4 byte align  |     |
+ *	      | tail_call_cnt |     |
  * BFP	   -> +===============+     |
  *	      |		      |     |
  *	      |   BPF stack   |     |
@@ -46,14 +49,17 @@ extern u8 sk_load_word[], sk_load_half[], sk_load_byte[];
  * R15	   -> +---------------+     + low
  *
  * We get 160 bytes stack space from calling function, but only use
- * 11 * 8 byte (old backchain + r15 - r6) for storing registers.
+ * 12 * 8 byte for old backchain, r15..r6, and tail_call_cnt.
  */
 #define STK_SPACE	(MAX_BPF_STACK + 8 + 4 + 4 + 160)
-#define STK_160_UNUSED	(160 - 11 * 8)
+#define STK_160_UNUSED	(160 - 12 * 8)
 #define STK_OFF		(STK_SPACE - STK_160_UNUSED)
 #define STK_OFF_TMP	160	/* Offset of tmp buffer on stack */
 #define STK_OFF_HLEN	168	/* Offset of SKB header length on stack */
 
+#define STK_OFF_R6	(160 - 11 * 8)	/* Offset of r6 on stack */
+#define STK_OFF_TCCNT	(160 - 12 * 8)	/* Offset of tail_call_cnt on stack */
+
 /* Offset to skip condition code check */
 #define OFF_OK		4
 
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 55423d8be580..d3766dd67e23 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -21,6 +21,7 @@
 #include <linux/netdevice.h>
 #include <linux/filter.h>
 #include <linux/init.h>
+#include <linux/bpf.h>
 #include <asm/cacheflush.h>
 #include <asm/dis.h>
 #include "bpf_jit.h"
@@ -40,6 +41,8 @@ struct bpf_jit {
 	int base_ip;		/* Base address for literal pool */
 	int ret0_ip;		/* Address of return 0 */
 	int exit_ip;		/* Address of exit */
+	int tail_call_start;	/* Tail call start offset */
+	int labels[1];		/* Labels for local jumps */
 };
 
 #define BPF_SIZE_MAX	4096	/* Max size for program */
@@ -49,6 +52,7 @@ struct bpf_jit {
 #define SEEN_RET0	4	/* ret0_ip points to a valid return 0 */
 #define SEEN_LITERAL	8	/* code uses literals */
 #define SEEN_FUNC	16	/* calls C functions */
+#define SEEN_TAIL_CALL	32	/* code uses tail calls */
 #define SEEN_STACK	(SEEN_FUNC | SEEN_MEM | SEEN_SKB)
 
 /*
@@ -60,6 +64,7 @@ struct bpf_jit {
 #define REG_L		(__MAX_BPF_REG+3)	/* Literal pool register */
 #define REG_15		(__MAX_BPF_REG+4)	/* Register 15 */
 #define REG_0		REG_W0			/* Register 0 */
+#define REG_1		REG_W1			/* Register 1 */
 #define REG_2		BPF_REG_1		/* Register 2 */
 #define REG_14		BPF_REG_0		/* Register 14 */
 
@@ -223,6 +228,24 @@ static inline void reg_set_seen(struct bpf_jit *jit, u32 b1)
 	REG_SET_SEEN(b3);					\
 })
 
+#define EMIT6_PCREL_LABEL(op1, op2, b1, b2, label, mask)	\
+({								\
+	int rel = (jit->labels[label] - jit->prg) >> 1;		\
+	_EMIT6(op1 | reg(b1, b2) << 16 | (rel & 0xffff),	\
+	       op2 | mask << 12);				\
+	REG_SET_SEEN(b1);					\
+	REG_SET_SEEN(b2);					\
+})
+
+#define EMIT6_PCREL_IMM_LABEL(op1, op2, b1, imm, label, mask)	\
+({								\
+	int rel = (jit->labels[label] - jit->prg) >> 1;		\
+	_EMIT6(op1 | (reg_high(b1) | mask) << 16 |		\
+		(rel & 0xffff), op2 | (imm & 0xff) << 8);	\
+	REG_SET_SEEN(b1);					\
+	BUILD_BUG_ON(((unsigned long) imm) > 0xff);		\
+})
+
 #define EMIT6_PCREL(op1, op2, b1, b2, i, off, mask)		\
 ({								\
 	/* Branch instruction needs 6 bytes */			\
@@ -286,7 +309,7 @@ static void jit_fill_hole(void *area, unsigned int size)
  */
 static void save_regs(struct bpf_jit *jit, u32 rs, u32 re)
 {
-	u32 off = 72 + (rs - 6) * 8;
+	u32 off = STK_OFF_R6 + (rs - 6) * 8;
 
 	if (rs == re)
 		/* stg %rs,off(%r15) */
@@ -301,7 +324,7 @@ static void save_regs(struct bpf_jit *jit, u32 rs, u32 re)
  */
 static void restore_regs(struct bpf_jit *jit, u32 rs, u32 re)
 {
-	u32 off = 72 + (rs - 6) * 8;
+	u32 off = STK_OFF_R6 + (rs - 6) * 8;
 
 	if (jit->seen & SEEN_STACK)
 		off += STK_OFF;
@@ -374,6 +397,16 @@ static void save_restore_regs(struct bpf_jit *jit, int op)
  */
 static void bpf_jit_prologue(struct bpf_jit *jit)
 {
+	if (jit->seen & SEEN_TAIL_CALL) {
+		/* xc STK_OFF_TCCNT(4,%r15),STK_OFF_TCCNT(%r15) */
+		_EMIT6(0xd703f000 | STK_OFF_TCCNT, 0xf000 | STK_OFF_TCCNT);
+	} else {
+		/* j tail_call_start: NOP if no tail calls are used */
+		EMIT4_PCREL(0xa7f40000, 6);
+		_EMIT2(0);
+	}
+	/* Tail calls have to skip above initialization */
+	jit->tail_call_start = jit->prg;
 	/* Save registers */
 	save_restore_regs(jit, REGS_SAVE);
 	/* Setup literal pool */
@@ -951,6 +984,75 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		EMIT4(0xb9040000, BPF_REG_0, REG_2);
 		break;
 	}
+	case BPF_JMP | BPF_CALL | BPF_X:
+		/*
+		 * Implicit input:
+		 *  B1: pointer to ctx
+		 *  B2: pointer to bpf_array
+		 *  B3: index in bpf_array
+		 */
+		jit->seen |= SEEN_TAIL_CALL;
+
+		/*
+		 * if (index >= array->map.max_entries)
+		 *         goto out;
+		 */
+
+		/* llgf %w1,map.max_entries(%b2) */
+		EMIT6_DISP_LH(0xe3000000, 0x0016, REG_W1, REG_0, BPF_REG_2,
+			      offsetof(struct bpf_array, map.max_entries));
+		/* clgrj %b3,%w1,0xa,label0: if %b3 >= %w1 goto out */
+		EMIT6_PCREL_LABEL(0xec000000, 0x0065, BPF_REG_3,
+				  REG_W1, 0, 0xa);
+
+		/*
+		 * if (tail_call_cnt++ > MAX_TAIL_CALL_CNT)
+		 *         goto out;
+		 */
+
+		if (jit->seen & SEEN_STACK)
+			off = STK_OFF_TCCNT + STK_OFF;
+		else
+			off = STK_OFF_TCCNT;
+		/* lhi %w0,1 */
+		EMIT4_IMM(0xa7080000, REG_W0, 1);
+		/* laal %w1,%w0,off(%r15) */
+		EMIT6_DISP_LH(0xeb000000, 0x00fa, REG_W1, REG_W0, REG_15, off);
+		/* clij %w1,MAX_TAIL_CALL_CNT,0x2,label0 */
+		EMIT6_PCREL_IMM_LABEL(0xec000000, 0x007f, REG_W1,
+				      MAX_TAIL_CALL_CNT, 0, 0x2);
+
+		/*
+		 * prog = array->prog[index];
+		 * if (prog == NULL)
+		 *         goto out;
+		 */
+
+		/* sllg %r1,%b3,3: %r1 = index * 8 */
+		EMIT6_DISP_LH(0xeb000000, 0x000d, REG_1, BPF_REG_3, REG_0, 3);
+		/* lg %r1,prog(%b2,%r1) */
+		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_1, BPF_REG_2,
+			      REG_1, offsetof(struct bpf_array, prog));
+		/* clgij %r1,0,0x8,label0 */
+		EMIT6_PCREL_IMM_LABEL(0xec000000, 0x007d, REG_1, 0, 0, 0x8);
+
+		/*
+		 * Restore registers before calling function
+		 */
+		save_restore_regs(jit, REGS_RESTORE);
+
+		/*
+		 * goto *(prog->bpf_func + tail_call_start);
+		 */
+
+		/* lg %r1,bpf_func(%r1) */
+		EMIT6_DISP_LH(0xe3000000, 0x0004, REG_1, REG_1, REG_0,
+			      offsetof(struct bpf_prog, bpf_func));
+		/* bc 0xf,tail_call_start(%r1) */
+		_EMIT4(0x47f01000 + jit->tail_call_start);
+		/* out: */
+		jit->labels[0] = jit->prg;
+		break;
 	case BPF_JMP | BPF_EXIT: /* return b0 */
 		last = (i == fp->len - 1) ? 1 : 0;
 		if (last && !(jit->seen & SEEN_RET0))
-- 
1.7.9.5
