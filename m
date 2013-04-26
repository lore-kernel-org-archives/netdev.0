From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 3/6] ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W instruction
Date: Fri, 26 Apr 2013 03:51:43 -0400
Message-ID: <1366962706-24204-4-git-send-email-xi.wang@gmail.com>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the seccomp BPF_S_ANC_SECCOMP_LD_W instruction
in ARM JIT.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 arch/arm/net/bpf_jit_32.c | 64 +++++++++++++++++++++++++++++------------------
 1 file changed, 39 insertions(+), 25 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 1a643ee..9bfce464 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -19,6 +19,7 @@
 #include <linux/if_vlan.h>
 #include <asm/cacheflush.h>
 #include <asm/hwcap.h>
+#include <asm/syscall.h>
 
 #include "bpf_jit_32.h"
 
@@ -55,7 +56,8 @@
 #define FLAG_NEED_X_RESET	(1 << 0)
 
 struct jit_ctx {
-	const struct sk_filter *skf;
+	struct sock_filter *insns;
+	unsigned len;
 	unsigned idx;
 	unsigned prologue_bytes;
 	int ret0_fp_idx;
@@ -131,8 +133,8 @@ static u16 saved_regs(struct jit_ctx *ctx)
 {
 	u16 ret = 0;
 
-	if ((ctx->skf->len > 1) ||
-	    (ctx->skf->insns[0].code == BPF_S_RET_A))
+	if ((ctx->len > 1) ||
+	    (ctx->insns[0].code == BPF_S_RET_A))
 		ret |= 1 << r_A;
 
 #ifdef CONFIG_FRAME_POINTER
@@ -181,7 +183,7 @@ static inline bool is_load_to_a(u16 inst)
 static void build_prologue(struct jit_ctx *ctx)
 {
 	u16 reg_set = saved_regs(ctx);
-	u16 first_inst = ctx->skf->insns[0].code;
+	u16 first_inst = ctx->insns[0].code;
 	u16 off;
 
 #ifdef CONFIG_FRAME_POINTER
@@ -279,7 +281,7 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 		ctx->imms[i] = k;
 
 	/* constants go just after the epilogue */
-	offset =  ctx->offsets[ctx->skf->len];
+	offset =  ctx->offsets[ctx->len];
 	offset += ctx->prologue_bytes;
 	offset += ctx->epilogue_bytes;
 	offset += i * 4;
@@ -419,7 +421,7 @@ static inline void emit_err_ret(u8 cond, struct jit_ctx *ctx)
 		emit(ARM_MOV_R(ARM_R0, ARM_R0), ctx);
 	} else {
 		_emit(cond, ARM_MOV_I(ARM_R0, 0), ctx);
-		_emit(cond, ARM_B(b_imm(ctx->skf->len, ctx)), ctx);
+		_emit(cond, ARM_B(b_imm(ctx->len, ctx)), ctx);
 	}
 }
 
@@ -469,14 +471,13 @@ static inline void update_on_xread(struct jit_ctx *ctx)
 static int build_body(struct jit_ctx *ctx)
 {
 	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
-	const struct sk_filter *prog = ctx->skf;
 	const struct sock_filter *inst;
 	unsigned i, load_order, off, condt;
 	int imm12;
 	u32 k;
 
-	for (i = 0; i < prog->len; i++) {
-		inst = &(prog->insns[i]);
+	for (i = 0; i < ctx->len; i++) {
+		inst = &(ctx->insns[i]);
 		/* K as an immediate value operand */
 		k = inst->k;
 
@@ -769,8 +770,8 @@ cmp_x:
 				ctx->ret0_fp_idx = i;
 			emit_mov_i(ARM_R0, k, ctx);
 b_epilogue:
-			if (i != ctx->skf->len - 1)
-				emit(ARM_B(b_imm(prog->len, ctx)), ctx);
+			if (i != ctx->len - 1)
+				emit(ARM_B(b_imm(ctx->len, ctx)), ctx);
 			break;
 		case BPF_S_MISC_TAX:
 			/* X = A */
@@ -845,6 +846,19 @@ b_epilogue:
 			off = offsetof(struct sk_buff, queue_mapping);
 			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
 			break;
+#ifdef CONFIG_SECCOMP_FILTER
+		case BPF_S_ANC_SECCOMP_LD_W:
+			if (k == offsetof(struct seccomp_data, arch)) {
+				emit_mov_i(r_A, AUDIT_ARCH_ARM, ctx);
+				break;
+			}
+			ctx->seen |= SEEN_CALL;
+			emit_mov_i(ARM_R3, (u32)seccomp_bpf_load, ctx);
+			emit_mov_i(ARM_R0, k, ctx);
+			emit_blx_r(ARM_R3, ctx);
+			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
+			break;
+#endif
 		default:
 			return -1;
 		}
@@ -858,22 +872,24 @@ b_epilogue:
 }
 
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	struct jit_ctx ctx;
 	unsigned tmp_idx;
 	unsigned alloc_size;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	memset(&ctx, 0, sizeof(ctx));
-	ctx.skf		= fp;
-	ctx.ret0_fp_idx = -1;
+	ctx.insns	= filter;
+	ctx.len		= flen;
+	ctx.ret0_fp_idx	= -1;
 
-	ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
+	ctx.offsets = kzalloc(4 * (ctx.len + 1), GFP_KERNEL);
 	if (ctx.offsets == NULL)
-		return;
+		return bpf_func;
 
 	/* fake pass to fill in the ctx->seen */
 	if (unlikely(build_body(&ctx)))
@@ -919,12 +935,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 
 	if (bpf_jit_enable > 1)
 		/* there are 2 passes here */
-		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
+		bpf_jit_dump(ctx.len, alloc_size, 2, ctx.target);
 
-	fp->bpf_func = (void *)ctx.target;
+	bpf_func = (void *)ctx.target;
 out:
 	kfree(ctx.offsets);
-	return;
+	return bpf_func;
 }
 
 static void bpf_jit_free_worker(struct work_struct *work)
@@ -932,12 +948,10 @@ static void bpf_jit_free_worker(struct work_struct *work)
 	module_free(NULL, work);
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
-	struct work_struct *work;
-
-	if (fp->bpf_func != sk_run_filter) {
-		work = (struct work_struct *)fp->bpf_func;
+	if (bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, bpf_jit_free_worker);
 		schedule_work(work);
-- 
1.8.1.2
