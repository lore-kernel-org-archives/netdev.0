From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 09/10] bpf, arm64: add support for constant blinding
Date: Fri, 13 May 2016 19:08:34 +0200
Message-ID: <5d415bdc5feeed2cf3142a5bb3956c7357290158.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41907 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452AbcEMRJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:05 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds recently added constant blinding helpers into the
arm64 eBPF JIT. In the bpf_int_jit_compile() path, requirements are
to utilize bpf_jit_blind_constants()/bpf_jit_prog_release_other()
pair for rewriting the program into a blinded one, and to map the
BPF_REG_AX register to a CPU register. The mapping is on x9.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Zi Shen Lim <zlim.lnx@gmail.com>
Acked-by: Yang Shi <yang.shi@linaro.org>
Tested-by: Yang Shi <yang.shi@linaro.org>
---
 arch/arm64/net/bpf_jit_comp.c | 52 +++++++++++++++++++++++++++++++++----------
 1 file changed, 40 insertions(+), 12 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index b421df7..031ed08 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -31,8 +31,8 @@
 
 int bpf_jit_enable __read_mostly;
 
-#define TMP_REG_1 (MAX_BPF_REG + 0)
-#define TMP_REG_2 (MAX_BPF_REG + 1)
+#define TMP_REG_1 (MAX_BPF_JIT_REG + 0)
+#define TMP_REG_2 (MAX_BPF_JIT_REG + 1)
 
 /* Map BPF registers to A64 registers */
 static const int bpf2a64[] = {
@@ -54,6 +54,8 @@ static const int bpf2a64[] = {
 	/* temporary register for internal BPF JIT */
 	[TMP_REG_1] = A64_R(23),
 	[TMP_REG_2] = A64_R(24),
+	/* temporary register for blinding constants */
+	[BPF_REG_AX] = A64_R(9),
 };
 
 struct jit_ctx {
@@ -763,26 +765,43 @@ void bpf_jit_compile(struct bpf_prog *prog)
 
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
+	struct bpf_prog *tmp, *orig_prog = prog;
 	struct bpf_binary_header *header;
+	bool tmp_blinded = false;
 	struct jit_ctx ctx;
 	int image_size;
 	u8 *image_ptr;
 
 	if (!bpf_jit_enable)
-		return prog;
+		return orig_prog;
+
+	tmp = bpf_jit_blind_constants(prog);
+	/* If blinding was requested and we failed during blinding,
+	 * we must fall back to the interpreter.
+	 */
+	if (IS_ERR(tmp))
+		return orig_prog;
+	if (tmp != prog) {
+		tmp_blinded = true;
+		prog = tmp;
+	}
 
 	memset(&ctx, 0, sizeof(ctx));
 	ctx.prog = prog;
 
 	ctx.offset = kcalloc(prog->len, sizeof(int), GFP_KERNEL);
-	if (ctx.offset == NULL)
-		return prog;
+	if (ctx.offset == NULL) {
+		prog = orig_prog;
+		goto out;
+	}
 
 	/* 1. Initial fake pass to compute ctx->idx. */
 
 	/* Fake pass to fill in ctx->offset and ctx->tmp_used. */
-	if (build_body(&ctx))
-		goto out;
+	if (build_body(&ctx)) {
+		prog = orig_prog;
+		goto out_off;
+	}
 
 	build_prologue(&ctx);
 
@@ -793,8 +812,10 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	image_size = sizeof(u32) * ctx.idx;
 	header = bpf_jit_binary_alloc(image_size, &image_ptr,
 				      sizeof(u32), jit_fill_hole);
-	if (header == NULL)
-		goto out;
+	if (header == NULL) {
+		prog = orig_prog;
+		goto out_off;
+	}
 
 	/* 2. Now, the actual pass. */
 
@@ -805,7 +826,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	if (build_body(&ctx)) {
 		bpf_jit_binary_free(header);
-		goto out;
+		prog = orig_prog;
+		goto out_off;
 	}
 
 	build_epilogue(&ctx);
@@ -813,7 +835,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	/* 3. Extra pass to validate JITed code. */
 	if (validate_code(&ctx)) {
 		bpf_jit_binary_free(header);
-		goto out;
+		prog = orig_prog;
+		goto out_off;
 	}
 
 	/* And we're done. */
@@ -825,8 +848,13 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 	set_memory_ro((unsigned long)header, header->pages);
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
-out:
+
+out_off:
 	kfree(ctx.offset);
+out:
+	if (tmp_blinded)
+		bpf_jit_prog_release_other(prog, prog == orig_prog ?
+					   tmp : orig_prog);
 	return prog;
 }
 
-- 
1.9.3
