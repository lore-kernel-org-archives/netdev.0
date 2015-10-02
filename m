From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH net-next V2] ARM: net: support BPF_ALU | BPF_MOD instructions in the BPF JIT.
Date: Fri,  2 Oct 2015 17:06:47 +0200
Message-ID: <1443798407-19154-1-git-send-email-nschichan@freebox.fr>
To: Russell King <linux@arm.linux.org.uk>,
	Nicolas Schichan <nschichan@freebox.fr>,
	"David S. Miller" <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ARMv7 with UDIV instruction support, generate an UDIV instruction
followed by an MLS instruction.

For other ARM variants, generate code calling a C wrapper similar to
the jit_udiv() function used for BPF_ALU | BPF_DIV instructions.

Some performance numbers reported by the test_bpf module (the duration
per filter run is reported in nanoseconds, between "jitted:<x>" and
"PASS":

ARMv7 QEMU nojit:	test_bpf: #3 DIV_MOD_KX jited:0 2196 PASS
ARMv7 QEMU jit:		test_bpf: #3 DIV_MOD_KX jited:1 104 PASS
ARMv5 QEMU nojit:	test_bpf: #3 DIV_MOD_KX jited:0 2176 PASS
ARMv5 QEMU jit:		test_bpf: #3 DIV_MOD_KX jited:1 1104 PASS
ARMv5 kirkwood nojit:	test_bpf: #3 DIV_MOD_KX jited:0 1103 PASS
ARMv5 kirkwood jit:	test_bpf: #3 DIV_MOD_KX jited:1 311 PASS

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---

Changes from V1:
- Address spelling in comment, following Russel's remarks.

 arch/arm/net/bpf_jit_32.c | 38 ++++++++++++++++++++++++++++++++------
 arch/arm/net/bpf_jit_32.h |  5 +++++
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 876060b..36edd410 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -125,7 +125,7 @@ static u64 jit_get_skb_w(struct sk_buff *skb, int offset)
 }
 
 /*
- * Wrapper that handles both OABI and EABI and assures Thumb2 interworking
+ * Wrappers which handle both OABI and EABI and assures Thumb2 interworking
  * (where the assembly routines like __aeabi_uidiv could cause problems).
  */
 static u32 jit_udiv(u32 dividend, u32 divisor)
@@ -133,6 +133,11 @@ static u32 jit_udiv(u32 dividend, u32 divisor)
 	return dividend / divisor;
 }
 
+static u32 jit_mod(u32 dividend, u32 divisor)
+{
+	return dividend % divisor;
+}
+
 static inline void _emit(int cond, u32 inst, struct jit_ctx *ctx)
 {
 	inst |= (cond << 28);
@@ -471,11 +476,17 @@ static inline void emit_blx_r(u8 tgt_reg, struct jit_ctx *ctx)
 #endif
 }
 
-static inline void emit_udiv(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx)
+static inline void emit_udivmod(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx,
+				int bpf_op)
 {
 #if __LINUX_ARM_ARCH__ == 7
 	if (elf_hwcap & HWCAP_IDIVA) {
-		emit(ARM_UDIV(rd, rm, rn), ctx);
+		if (bpf_op == BPF_DIV)
+			emit(ARM_UDIV(rd, rm, rn), ctx);
+		else {
+			emit(ARM_UDIV(ARM_R3, rm, rn), ctx);
+			emit(ARM_MLS(rd, rn, ARM_R3, rm), ctx);
+		}
 		return;
 	}
 #endif
@@ -496,7 +507,8 @@ static inline void emit_udiv(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx)
 		emit(ARM_MOV_R(ARM_R0, rm), ctx);
 
 	ctx->seen |= SEEN_CALL;
-	emit_mov_i(ARM_R3, (u32)jit_udiv, ctx);
+	emit_mov_i(ARM_R3, bpf_op == BPF_DIV ? (u32)jit_udiv : (u32)jit_mod,
+		   ctx);
 	emit_blx_r(ARM_R3, ctx);
 
 	if (rd != ARM_R0)
@@ -697,13 +709,27 @@ load_ind:
 			if (k == 1)
 				break;
 			emit_mov_i(r_scratch, k, ctx);
-			emit_udiv(r_A, r_A, r_scratch, ctx);
+			emit_udivmod(r_A, r_A, r_scratch, ctx, BPF_DIV);
 			break;
 		case BPF_ALU | BPF_DIV | BPF_X:
 			update_on_xread(ctx);
 			emit(ARM_CMP_I(r_X, 0), ctx);
 			emit_err_ret(ARM_COND_EQ, ctx);
-			emit_udiv(r_A, r_A, r_X, ctx);
+			emit_udivmod(r_A, r_A, r_X, ctx, BPF_DIV);
+			break;
+		case BPF_ALU | BPF_MOD | BPF_K:
+			if (k == 1) {
+				emit_mov_i(r_A, 0, ctx);
+				break;
+			}
+			emit_mov_i(r_scratch, k, ctx);
+			emit_udivmod(r_A, r_A, r_scratch, ctx, BPF_MOD);
+			break;
+		case BPF_ALU | BPF_MOD | BPF_X:
+			update_on_xread(ctx);
+			emit(ARM_CMP_I(r_X, 0), ctx);
+			emit_err_ret(ARM_COND_EQ, ctx);
+			emit_udivmod(r_A, r_A, r_X, ctx, BPF_MOD);
 			break;
 		case BPF_ALU | BPF_OR | BPF_K:
 			/* A |= K */
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index 4b17d5ab..c46fca2 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -115,6 +115,8 @@
 
 #define ARM_INST_UMULL		0x00800090
 
+#define ARM_INST_MLS		0x00600090
+
 /*
  * Use a suitable undefined instruction to use for ARM/Thumb2 faulting.
  * We need to be careful not to conflict with those used by other modules
@@ -210,4 +212,7 @@
 #define ARM_UMULL(rd_lo, rd_hi, rn, rm)	(ARM_INST_UMULL | (rd_hi) << 16 \
 					 | (rd_lo) << 12 | (rm) << 8 | rn)
 
+#define ARM_MLS(rd, rn, rm, ra)	(ARM_INST_MLS | (rd) << 16 | (rn) | (rm) << 8 \
+				 | (ra) << 12)
+
 #endif /* PFILTER_OPCODES_ARM_H */
-- 
1.9.1
