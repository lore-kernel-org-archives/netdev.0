From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 4/6] PPC: net: bpf_jit_comp: refactor the BPF JIT interface
Date: Fri, 26 Apr 2013 03:51:44 -0400
Message-ID: <1366962706-24204-5-git-send-email-xi.wang@gmail.com>
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

Implement the refactored bpf_jit_compile() and bpf_jit_free().

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 arch/powerpc/net/bpf_jit_comp.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

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
-- 
1.8.1.2
