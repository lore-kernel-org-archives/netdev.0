From: David Miller <davem@davemloft.net>
Subject: Re: mmotm 2014-05-09-16-17 uploaded (ptrace-ab.hi vs.
 net/core/filter.c)
Date: Tue, 13 May 2014 13:14:08 -0400 (EDT)
Message-ID: <20140513.131408.1239450870035635955.davem@davemloft.net>
References: <20140509231825.22D005A4123@corp2gmr1-2.hot.corp.google.com>
	<536E5EB9.5060101@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	richard@nod.at
To: rdunlap@infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <536E5EB9.5060101@infradead.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 10 May 2014 10:15:37 -0700

> On 05/09/2014 04:18 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2014-05-09-16-17 has been uploaded to
>> 
>>    http://www.ozlabs.org/~akpm/mmotm/
>> 
> 
> 
> uml defconfig on x86_64: (also happens in linux-next)
> 
> net/core/filter.c:57:0: warning: "R8" redefined [enabled by default]
> arch/x86/include/uapi/asm/ptrace-abi.h:38:0: note: this is the location of the previous definition
> 
> Same warnings for R9 and R10.

I'm going to commit the following to net-next to fix this,
thanks Randy.

====================
[PATCH] net: filter: Fix redefinition warnings on x86-64.

Do not collide with the x86-64 PTRACE user API namespace.

net/core/filter.c:57:0: warning: "R8" redefined [enabled by default]
arch/x86/include/uapi/asm/ptrace-abi.h:38:0: note: this is the location of the previous definition

Fix by adding a BPF_ prefix to the register macros.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/filter.c | 71 +++++++++++++++++++++++++++++--------------------------
 1 file changed, 37 insertions(+), 34 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 9aaa05a..c442a0d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -46,17 +46,17 @@
 #include <linux/if_vlan.h>
 
 /* Registers */
-#define R0	regs[BPF_REG_0]
-#define R1	regs[BPF_REG_1]
-#define R2	regs[BPF_REG_2]
-#define R3	regs[BPF_REG_3]
-#define R4	regs[BPF_REG_4]
-#define R5	regs[BPF_REG_5]
-#define R6	regs[BPF_REG_6]
-#define R7	regs[BPF_REG_7]
-#define R8	regs[BPF_REG_8]
-#define R9	regs[BPF_REG_9]
-#define R10	regs[BPF_REG_10]
+#define BPF_R0	regs[BPF_REG_0]
+#define BPF_R1	regs[BPF_REG_1]
+#define BPF_R2	regs[BPF_REG_2]
+#define BPF_R3	regs[BPF_REG_3]
+#define BPF_R4	regs[BPF_REG_4]
+#define BPF_R5	regs[BPF_REG_5]
+#define BPF_R6	regs[BPF_REG_6]
+#define BPF_R7	regs[BPF_REG_7]
+#define BPF_R8	regs[BPF_REG_8]
+#define BPF_R9	regs[BPF_REG_9]
+#define BPF_R10	regs[BPF_REG_10]
 
 /* Named registers */
 #define A	regs[insn->a_reg]
@@ -383,10 +383,12 @@ select_insn:
 
 	/* CALL */
 	JMP_CALL_0:
-		/* Function call scratches R1-R5 registers, preserves R6-R9,
-		 * and stores return value into R0.
+		/* Function call scratches BPF_R1-BPF_R5 registers,
+		 * preserves BPF_R6-BPF_R9, and stores return value
+		 * into BPF_R0.
 		 */
-		R0 = (__bpf_call_base + insn->imm)(R1, R2, R3, R4, R5);
+		BPF_R0 = (__bpf_call_base + insn->imm)(BPF_R1, BPF_R2, BPF_R3,
+						       BPF_R4, BPF_R5);
 		CONT;
 
 	/* JMP */
@@ -478,7 +480,7 @@ select_insn:
 		}
 		CONT;
 	JMP_EXIT_0:
-		return R0;
+		return BPF_R0;
 
 	/* STX and ST and LDX*/
 #define LDST(SIZEOP, SIZE)					\
@@ -505,18 +507,19 @@ select_insn:
 		atomic64_add((u64) X, (atomic64_t *)(unsigned long)
 			     (A + insn->off));
 		CONT;
-	LD_ABS_W: /* R0 = ntohl(*(u32 *) (skb->data + K)) */
+	LD_ABS_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + K)) */
 		off = K;
 load_word:
-		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are only
-		 * appearing in the programs where ctx == skb. All programs
-		 * keep 'ctx' in regs[BPF_REG_CTX] == R6, sk_convert_filter()
-		 * saves it in R6, internal BPF verifier will check that
-		 * R6 == ctx.
+		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are
+		 * only appearing in the programs where ctx ==
+		 * skb. All programs keep 'ctx' in regs[BPF_REG_CTX]
+		 * == BPF_R6, sk_convert_filter() saves it in BPF_R6,
+		 * internal BPF verifier will check that BPF_R6 ==
+		 * ctx.
 		 *
-		 * BPF_ABS and BPF_IND are wrappers of function calls, so
-		 * they scratch R1-R5 registers, preserve R6-R9, and store
-		 * return value into R0.
+		 * BPF_ABS and BPF_IND are wrappers of function calls,
+		 * so they scratch BPF_R1-BPF_R5 registers, preserve
+		 * BPF_R6-BPF_R9, and store return value into BPF_R0.
 		 *
 		 * Implicit input:
 		 *   ctx
@@ -526,39 +529,39 @@ load_word:
 		 *   K == 32-bit immediate
 		 *
 		 * Output:
-		 *   R0 - 8/16/32-bit skb data converted to cpu endianness
+		 *   BPF_R0 - 8/16/32-bit skb data converted to cpu endianness
 		 */
 		ptr = load_pointer((struct sk_buff *) ctx, off, 4, &tmp);
 		if (likely(ptr != NULL)) {
-			R0 = get_unaligned_be32(ptr);
+			BPF_R0 = get_unaligned_be32(ptr);
 			CONT;
 		}
 		return 0;
-	LD_ABS_H: /* R0 = ntohs(*(u16 *) (skb->data + K)) */
+	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + K)) */
 		off = K;
 load_half:
 		ptr = load_pointer((struct sk_buff *) ctx, off, 2, &tmp);
 		if (likely(ptr != NULL)) {
-			R0 = get_unaligned_be16(ptr);
+			BPF_R0 = get_unaligned_be16(ptr);
 			CONT;
 		}
 		return 0;
-	LD_ABS_B: /* R0 = *(u8 *) (ctx + K) */
+	LD_ABS_B: /* BPF_R0 = *(u8 *) (ctx + K) */
 		off = K;
 load_byte:
 		ptr = load_pointer((struct sk_buff *) ctx, off, 1, &tmp);
 		if (likely(ptr != NULL)) {
-			R0 = *(u8 *)ptr;
+			BPF_R0 = *(u8 *)ptr;
 			CONT;
 		}
 		return 0;
-	LD_IND_W: /* R0 = ntohl(*(u32 *) (skb->data + X + K)) */
+	LD_IND_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + X + K)) */
 		off = K + X;
 		goto load_word;
-	LD_IND_H: /* R0 = ntohs(*(u16 *) (skb->data + X + K)) */
+	LD_IND_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + X + K)) */
 		off = K + X;
 		goto load_half;
-	LD_IND_B: /* R0 = *(u8 *) (skb->data + X + K) */
+	LD_IND_B: /* BPF_R0 = *(u8 *) (skb->data + X + K) */
 		off = K + X;
 		goto load_byte;
 
@@ -1001,7 +1004,7 @@ do_pass:
 			*insn = BPF_ALU64_REG(BPF_MOV, BPF_REG_TMP, BPF_REG_A);
 			insn++;
 
-			/* A = R0 = *(u8 *) (skb->data + K) */
+			/* A = BPF_R0 = *(u8 *) (skb->data + K) */
 			*insn = BPF_LD_ABS(BPF_B, fp->k);
 			insn++;
 
-- 
1.9.0
