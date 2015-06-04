From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 1/6] MIPS: net: BPF: Free up some callee-saved registers
Date: Thu, 4 Jun 2015 11:56:11 +0100
Message-ID: <1433415376-20952-2-git-send-email-markos.chandras@imgtec.com>
References: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
        <linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Move the two scratch registers from s0 and s1 to t4 and t5 in order
to free up some callee-saved registers. We will use these callee-saved
registers to store some permanent data on them in a subsequent patch.

Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 35 +++++++++++++++--------------------
 arch/mips/net/bpf_jit.h |  2 ++
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 5d6139390bf8..850b08ee3fab 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -29,9 +29,6 @@
 
 /* ABI
  *
- * s0	1st scratch register
- * s1	2nd scratch register
- * s2	offset register
  * s3	BPF register A
  * s4	BPF register X
  * s5	*skb
@@ -88,13 +85,13 @@
  * any of the $s0-$s6 registers will only be preserved if
  * they are going to actually be used.
  */
-#define r_s0		MIPS_R_S0 /* scratch reg 1 */
-#define r_s1		MIPS_R_S1 /* scratch reg 2 */
 #define r_off		MIPS_R_S2
 #define r_A		MIPS_R_S3
 #define r_X		MIPS_R_S4
 #define r_skb		MIPS_R_S5
 #define r_M		MIPS_R_S6
+#define r_s0		MIPS_R_T4 /* scratch reg 1 */
+#define r_s1		MIPS_R_T5 /* scratch reg 2 */
 #define r_tmp_imm	MIPS_R_T6 /* No need to preserve this */
 #define r_tmp		MIPS_R_T7 /* No need to preserve this */
 #define r_zero		MIPS_R_ZERO
@@ -108,8 +105,6 @@
 #define SEEN_SREG_SFT		(BPF_MEMWORDS + 1)
 #define SEEN_SREG_BASE		(1 << SEEN_SREG_SFT)
 #define SEEN_SREG(x)		(SEEN_SREG_BASE << (x))
-#define SEEN_S0			SEEN_SREG(0)
-#define SEEN_S1			SEEN_SREG(1)
 #define SEEN_OFF		SEEN_SREG(2)
 #define SEEN_A			SEEN_SREG(3)
 #define SEEN_X			SEEN_SREG(4)
@@ -817,7 +812,7 @@ load_common:
 				   b_imm(prog->len, ctx), ctx);
 			emit_reg_move(r_ret, r_zero, ctx);
 
-			ctx->flags |= SEEN_CALL | SEEN_OFF | SEEN_S0 |
+			ctx->flags |= SEEN_CALL | SEEN_OFF |
 				SEEN_SKB | SEEN_A;
 
 			emit_load_func(r_s0, (ptr)load_func[load_order],
@@ -883,7 +878,7 @@ load_ind:
 				return -ENOTSUPP;
 
 			/* X <- 4 * (P[k:1] & 0xf) */
-			ctx->flags |= SEEN_X | SEEN_CALL | SEEN_S0 | SEEN_SKB;
+			ctx->flags |= SEEN_X | SEEN_CALL | SEEN_SKB;
 			/* Load offset to a1 */
 			emit_load_func(r_s0, (ptr)jit_get_skb_b, ctx);
 			/*
@@ -947,7 +942,7 @@ load_ind:
 		case BPF_ALU | BPF_MUL | BPF_K:
 			/* A *= K */
 			/* Load K to scratch register before MUL */
-			ctx->flags |= SEEN_A | SEEN_S0;
+			ctx->flags |= SEEN_A;
 			emit_load_imm(r_s0, k, ctx);
 			emit_mul(r_A, r_A, r_s0, ctx);
 			break;
@@ -965,7 +960,7 @@ load_ind:
 				emit_srl(r_A, r_A, k, ctx);
 				break;
 			}
-			ctx->flags |= SEEN_A | SEEN_S0;
+			ctx->flags |= SEEN_A;
 			emit_load_imm(r_s0, k, ctx);
 			emit_div(r_A, r_s0, ctx);
 			break;
@@ -975,7 +970,7 @@ load_ind:
 				ctx->flags |= SEEN_A;
 				emit_jit_reg_move(r_A, r_zero, ctx);
 			} else {
-				ctx->flags |= SEEN_A | SEEN_S0;
+				ctx->flags |= SEEN_A;
 				emit_load_imm(r_s0, k, ctx);
 				emit_mod(r_A, r_s0, ctx);
 			}
@@ -1089,10 +1084,10 @@ jmp_cmp:
 			if ((condt & MIPS_COND_GE) ||
 			    (condt & MIPS_COND_GT)) {
 				if (condt & MIPS_COND_K) { /* K */
-					ctx->flags |= SEEN_S0 | SEEN_A;
+					ctx->flags |= SEEN_A;
 					emit_sltiu(r_s0, r_A, k, ctx);
 				} else { /* X */
-					ctx->flags |= SEEN_S0 | SEEN_A |
+					ctx->flags |= SEEN_A |
 						SEEN_X;
 					emit_sltu(r_s0, r_A, r_X, ctx);
 				}
@@ -1104,7 +1099,7 @@ jmp_cmp:
 				/* A > (K|X) ? scratch = 0 */
 				if (condt & MIPS_COND_GT) {
 					/* Checking for equality */
-					ctx->flags |= SEEN_S0 | SEEN_A | SEEN_X;
+					ctx->flags |= SEEN_A | SEEN_X;
 					if (condt & MIPS_COND_K)
 						emit_load_imm(r_s0, k, ctx);
 					else
@@ -1127,7 +1122,7 @@ jmp_cmp:
 			} else {
 				/* A == K|X */
 				if (condt & MIPS_COND_K) { /* K */
-					ctx->flags |= SEEN_S0 | SEEN_A;
+					ctx->flags |= SEEN_A;
 					emit_load_imm(r_s0, k, ctx);
 					/* jump true */
 					b_off = b_imm(i + inst->jt + 1, ctx);
@@ -1157,7 +1152,7 @@ jmp_cmp:
 			}
 			break;
 		case BPF_JMP | BPF_JSET | BPF_K:
-			ctx->flags |= SEEN_S0 | SEEN_S1 | SEEN_A;
+			ctx->flags |= SEEN_A;
 			/* pc += (A & K) ? pc -> jt : pc -> jf */
 			emit_load_imm(r_s1, k, ctx);
 			emit_and(r_s0, r_A, r_s1, ctx);
@@ -1171,7 +1166,7 @@ jmp_cmp:
 			emit_nop(ctx);
 			break;
 		case BPF_JMP | BPF_JSET | BPF_X:
-			ctx->flags |= SEEN_S0 | SEEN_X | SEEN_A;
+			ctx->flags |= SEEN_X | SEEN_A;
 			/* pc += (A & X) ? pc -> jt : pc -> jf */
 			emit_and(r_s0, r_A, r_X, ctx);
 			/* jump true */
@@ -1255,7 +1250,7 @@ jmp_cmp:
 			break;
 		case BPF_ANC | SKF_AD_IFINDEX:
 			/* A = skb->dev->ifindex */
-			ctx->flags |= SEEN_SKB | SEEN_A | SEEN_S0;
+			ctx->flags |= SEEN_SKB | SEEN_A;
 			off = offsetof(struct sk_buff, dev);
 			/* Load *dev pointer */
 			emit_load_ptr(r_s0, r_skb, off, ctx);
@@ -1282,7 +1277,7 @@ jmp_cmp:
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG:
 		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
-			ctx->flags |= SEEN_SKB | SEEN_S0 | SEEN_A;
+			ctx->flags |= SEEN_SKB | SEEN_A;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
diff --git a/arch/mips/net/bpf_jit.h b/arch/mips/net/bpf_jit.h
index 3a5751b4335a..f9b5a4d3dbf4 100644
--- a/arch/mips/net/bpf_jit.h
+++ b/arch/mips/net/bpf_jit.h
@@ -18,6 +18,8 @@
 #define MIPS_R_V1	3
 #define MIPS_R_A0	4
 #define MIPS_R_A1	5
+#define MIPS_R_T4	12
+#define MIPS_R_T5	13
 #define MIPS_R_T6	14
 #define MIPS_R_T7	15
 #define MIPS_R_S0	16
-- 
2.4.2
