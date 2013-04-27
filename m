From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2 net-next 1/3] filter: refactor BPF JIT for seccomp filters
Date: Fri, 26 Apr 2013 22:17:25 -0400
Message-ID: <1367029047-14830-2-git-send-email-xi.wang@gmail.com>
References: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Xi Wang <xi.wang@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:49726 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879Ab3D0CSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 22:18:49 -0400
In-Reply-To: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, bpf_jit_compile() and bpf_jit_free() take an sk_filter,
which seccomp filters cannot reuse.

Change bpf_jit_compile() to take a pointer to BPF instructions and
an instruction length, and to return a JITted function.

Change bpf_jit_free() to take a JITted function.

Add JIT calls for seccomp filters.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Will Drewry <wad@chromium.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: David Laight <david.laight@aculab.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c       | 50 ++++++++++++++++++++---------------------
 arch/powerpc/net/bpf_jit_comp.c | 36 ++++++++++++++---------------
 arch/s390/net/bpf_jit_comp.c    | 31 ++++++++++++-------------
 arch/sparc/net/bpf_jit_comp.c   | 22 +++++++++---------
 arch/x86/net/bpf_jit_comp.c     | 21 +++++++++--------
 include/linux/filter.h          | 16 ++++++++-----
 kernel/seccomp.c                |  6 ++++-
 net/core/filter.c               |  6 ++---
 8 files changed, 97 insertions(+), 91 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 1a643ee..073b085 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -55,7 +55,8 @@
 #define FLAG_NEED_X_RESET	(1 << 0)
 
 struct jit_ctx {
-	const struct sk_filter *skf;
+	struct sock_filter *insns;
+	unsigned len;
 	unsigned idx;
 	unsigned prologue_bytes;
 	int ret0_fp_idx;
@@ -131,8 +132,8 @@ static u16 saved_regs(struct jit_ctx *ctx)
 {
 	u16 ret = 0;
 
-	if ((ctx->skf->len > 1) ||
-	    (ctx->skf->insns[0].code == BPF_S_RET_A))
+	if ((ctx->len > 1) ||
+	    (ctx->insns[0].code == BPF_S_RET_A))
 		ret |= 1 << r_A;
 
 #ifdef CONFIG_FRAME_POINTER
@@ -181,7 +182,7 @@ static inline bool is_load_to_a(u16 inst)
 static void build_prologue(struct jit_ctx *ctx)
 {
 	u16 reg_set = saved_regs(ctx);
-	u16 first_inst = ctx->skf->insns[0].code;
+	u16 first_inst = ctx->insns[0].code;
 	u16 off;
 
 #ifdef CONFIG_FRAME_POINTER
@@ -279,7 +280,7 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 		ctx->imms[i] = k;
 
 	/* constants go just after the epilogue */
-	offset =  ctx->offsets[ctx->skf->len];
+	offset =  ctx->offsets[ctx->len];
 	offset += ctx->prologue_bytes;
 	offset += ctx->epilogue_bytes;
 	offset += i * 4;
@@ -419,7 +420,7 @@ static inline void emit_err_ret(u8 cond, struct jit_ctx *ctx)
 		emit(ARM_MOV_R(ARM_R0, ARM_R0), ctx);
 	} else {
 		_emit(cond, ARM_MOV_I(ARM_R0, 0), ctx);
-		_emit(cond, ARM_B(b_imm(ctx->skf->len, ctx)), ctx);
+		_emit(cond, ARM_B(b_imm(ctx->len, ctx)), ctx);
 	}
 }
 
@@ -469,14 +470,13 @@ static inline void update_on_xread(struct jit_ctx *ctx)
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
 
@@ -769,8 +769,8 @@ cmp_x:
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
@@ -858,22 +858,24 @@ b_epilogue:
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
@@ -919,12 +921,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 
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
@@ -932,12 +934,10 @@ static void bpf_jit_free_worker(struct work_struct *work)
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
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index c427ae3..a82e400 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -31,11 +31,11 @@ static inline void bpf_flush_icache(void *start, void *end)
 	flush_icache_range((unsigned long)start, (unsigned long)end);
 }
 
-static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
+static void bpf_jit_build_prologue(struct sock_filter *filter,
+				   u32 *image,
 				   struct codegen_context *ctx)
 {
 	int i;
-	const struct sock_filter *filter = fp->insns;
 
 	if (ctx->seen & (SEEN_MEM | SEEN_DATAREF)) {
 		/* Make stackframe */
@@ -135,12 +135,12 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
 /* Assemble the body code between the prologue & epilogue. */
-static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
+static int bpf_jit_build_body(struct sock_filter *filter,
+			      unsigned int flen,
+			      u32 *image,
 			      struct codegen_context *ctx,
 			      unsigned int *addrs)
 {
-	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
 	u8 *func;
 	unsigned int true_cond;
 	int i;
@@ -564,7 +564,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 	return 0;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	unsigned int proglen;
 	unsigned int alloclen;
@@ -573,14 +573,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 	unsigned int *addrs;
 	struct codegen_context cgctx;
 	int pass;
-	int flen = fp->len;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	addrs = kzalloc((flen+1) * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return bpf_func;
 
 	/*
 	 * There are multiple assembly passes as the generated code will change
@@ -636,7 +636,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	cgctx.seen = 0;
 	cgctx.pc_ret0 = -1;
 	/* Scouting faux-generate pass 0 */
-	if (bpf_jit_build_body(fp, 0, &cgctx, addrs))
+	if (bpf_jit_build_body(filter, flen, 0, &cgctx, addrs))
 		/* We hit something illegal or unsupported. */
 		goto out;
 
@@ -645,7 +645,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	 * update ctgtx.idx as it pretends to output instructions, then we can
 	 * calculate total size from idx.
 	 */
-	bpf_jit_build_prologue(fp, 0, &cgctx);
+	bpf_jit_build_prologue(filter, 0, &cgctx);
 	bpf_jit_build_epilogue(0, &cgctx);
 
 	proglen = cgctx.idx * 4;
@@ -661,8 +661,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 	for (pass = 1; pass < 3; pass++) {
 		/* Now build the prologue, body code & epilogue for real. */
 		cgctx.idx = 0;
-		bpf_jit_build_prologue(fp, code_base, &cgctx);
-		bpf_jit_build_body(fp, code_base, &cgctx, addrs);
+		bpf_jit_build_prologue(filter, code_base, &cgctx);
+		bpf_jit_build_body(filter, flen, code_base, &cgctx, addrs);
 		bpf_jit_build_epilogue(code_base, &cgctx);
 
 		if (bpf_jit_enable > 1)
@@ -681,11 +681,11 @@ void bpf_jit_compile(struct sk_filter *fp)
 		/* Function descriptor nastiness: Address + TOC */
 		((u64 *)image)[0] = (u64)code_base;
 		((u64 *)image)[1] = local_paca->kernel_toc;
-		fp->bpf_func = (void *)image;
+		bpf_func = (void *)image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -696,10 +696,10 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+	if (bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, jit_free_defer);
 		schedule_work(work);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 0972e91..7966e0c 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -738,19 +738,19 @@ out:
 	return -1;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	unsigned long size, prg_len, lit_len;
 	struct bpf_jit jit, cjit;
 	unsigned int *addrs;
 	int pass, i;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
-	addrs = kmalloc(fp->len * sizeof(*addrs), GFP_KERNEL);
+		return bpf_func;
+	addrs = kzalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
-	memset(addrs, 0, fp->len * sizeof(*addrs));
+		return bpf_func;
 	memset(&jit, 0, sizeof(cjit));
 	memset(&cjit, 0, sizeof(cjit));
 
@@ -759,10 +759,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 		jit.lit = jit.mid;
 
 		bpf_jit_prologue(&jit);
-		bpf_jit_noleaks(&jit, fp->insns);
-		for (i = 0; i < fp->len; i++) {
-			if (bpf_jit_insn(&jit, fp->insns + i, addrs, i,
-					 i == fp->len - 1))
+		bpf_jit_noleaks(&jit, filter);
+		for (i = 0; i < flen; i++) {
+			if (bpf_jit_insn(&jit, filter + i, addrs, i,
+					 i == flen - 1))
 				goto out;
 		}
 		bpf_jit_epilogue(&jit);
@@ -789,8 +789,8 @@ void bpf_jit_compile(struct sk_filter *fp)
 		cjit = jit;
 	}
 	if (bpf_jit_enable > 1) {
-		pr_err("flen=%d proglen=%lu pass=%d image=%p\n",
-		       fp->len, jit.end - jit.start, pass, jit.start);
+		pr_err("flen=%u proglen=%lu pass=%d image=%p\n",
+		       flen, jit.end - jit.start, pass, jit.start);
 		if (jit.start) {
 			printk(KERN_ERR "JIT code:\n");
 			print_fn_code(jit.start, jit.mid - jit.start);
@@ -800,9 +800,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 		}
 	}
 	if (jit.start)
-		fp->bpf_func = (void *) jit.start;
+		bpf_func = (void *) jit.start;
 out:
 	kfree(addrs);
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -813,13 +814,13 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
 	struct work_struct *work;
 
-	if (fp->bpf_func == sk_run_filter)
+	if (bpf_func == sk_run_filter)
 		return;
-	work = (struct work_struct *)fp->bpf_func;
+	work = (struct work_struct *)bpf_func;
 	INIT_WORK(work, jit_free_defer);
 	schedule_work(work);
 }
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index d36a85e..15e6513 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -354,21 +354,21 @@ do {	*prog++ = BR_OPC | WDISP22(OFF);		\
  * emit_jump() calls with adjusted offsets.
  */
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	unsigned int cleanup_addr, proglen, oldproglen = 0;
 	u32 temp[8], *prog, *func, seen = 0, pass;
-	const struct sock_filter *filter = fp->insns;
-	int i, flen = fp->len, pc_ret0 = -1;
+	int i, pc_ret0 = -1;
 	unsigned int *addrs;
 	void *image;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return bpf_func;
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -763,7 +763,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return bpf_func;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -799,11 +799,11 @@ cond_branch:			f_offset = addrs[i + filter[i].jf];
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
+		bpf_func = (void *)image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -814,10 +814,10 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+	if (bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, jit_free_defer);
 		schedule_work(work);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f66b540..8898680 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -144,7 +144,7 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
 	u8 temp[64];
 	u8 *prog;
@@ -157,15 +157,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 	int pc_ret0 = -1; /* bpf index of first RET #0 instruction (if any) */
 	unsigned int cleanup_addr; /* epilogue code offset */
 	unsigned int *addrs;
-	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
+	bpf_func_t bpf_func = sk_run_filter;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return bpf_func;
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -694,7 +693,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return bpf_func;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -731,11 +730,11 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
+		bpf_func = (void *)image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -746,10 +745,10 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(bpf_func_t bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+	if (bpf_func != sk_run_filter) {
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, jit_free_defer);
 		schedule_work(work);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index d1248f4..8743093 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -21,12 +21,14 @@ struct compat_sock_fprog {
 struct sk_buff;
 struct sock;
 
+typedef unsigned int (*bpf_func_t)(const struct sk_buff *skb,
+				   const struct sock_filter *filter);
+
 struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct sock_filter *filter);
+	bpf_func_t		bpf_func;
 	struct rcu_head		rcu;
 	struct sock_filter     	insns[0];
 };
@@ -48,11 +50,12 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 
 #ifdef CONFIG_BPF_JIT
+#include <stdarg.h>
 #include <linux/linkage.h>
 #include <linux/printk.h>
 
-extern void bpf_jit_compile(struct sk_filter *fp);
-extern void bpf_jit_free(struct sk_filter *fp);
+extern bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen);
+extern void bpf_jit_free(bpf_func_t bpf_func);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
@@ -65,10 +68,11 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 }
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #else
-static inline void bpf_jit_compile(struct sk_filter *fp)
+static inline bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
+	return sk_run_filter;
 }
-static inline void bpf_jit_free(struct sk_filter *fp)
+static inline void bpf_jit_free(bpf_func_t bpf_func)
 {
 }
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5af44b5..f784feb 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -55,6 +55,7 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	unsigned short len;  /* Instruction count */
+	bpf_func_t bpf_func;
 	struct sock_filter insns[];
 };
 
@@ -211,7 +212,7 @@ static u32 seccomp_run_filters(int syscall)
 	 * value always takes priority (ignoring the DATA).
 	 */
 	for (f = current->seccomp.filter; f; f = f->prev) {
-		u32 cur_ret = sk_run_filter(NULL, f->insns);
+		u32 cur_ret = SK_RUN_FILTER(f, NULL);
 		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
 	}
@@ -273,6 +274,8 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	if (ret)
 		goto fail;
 
+	filter->bpf_func = bpf_jit_compile(filter->insns, filter->len);
+
 	/*
 	 * If there is an existing filter, make it the prev and don't drop its
 	 * task reference.
@@ -330,6 +333,7 @@ void put_seccomp_filter(struct task_struct *tsk)
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
 		orig = orig->prev;
+		bpf_jit_free(freeme->bpf_func);
 		kfree(freeme);
 	}
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index dad2a17..0a7900b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -643,7 +643,7 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
-	bpf_jit_free(fp);
+	bpf_jit_free(fp->bpf_func);
 	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
@@ -652,13 +652,11 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 {
 	int err;
 
-	fp->bpf_func = sk_run_filter;
-
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err)
 		return err;
 
-	bpf_jit_compile(fp);
+	fp->bpf_func = bpf_jit_compile(fp->insns, fp->len);
 	return 0;
 }
 
-- 
1.8.1.2
