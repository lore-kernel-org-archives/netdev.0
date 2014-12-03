From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH] bpf: arm64: lift restriction on last instruction
Date: Wed,  3 Dec 2014 00:38:01 -0800
Message-ID: <1417595881-32218-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Earlier implementation assumed last instruction is BPF_EXIT.
Since this is no longer a restriction in eBPF, we remove this
limitation.

Per Alexei Starovoitov [1]:
> classic BPF has a restriction that last insn is always BPF_RET.
> eBPF doesn't have BPF_RET instruction and this restriction.
> It has BPF_EXIT insn which can appear anywhere in the program
> one or more times and it doesn't have to be last insn.

[1] https://lkml.org/lkml/2014/11/27/2

Fixes: e54bcde3d69d ("arm64: eBPF JIT compiler")
Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/net/bpf_jit_comp.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 41f1e3e..edba042 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -60,7 +60,7 @@ struct jit_ctx {
 	const struct bpf_prog *prog;
 	int idx;
 	int tmp_used;
-	int body_offset;
+	int epilogue_offset;
 	int *offset;
 	u32 *image;
 };
@@ -130,8 +130,8 @@ static void jit_fill_hole(void *area, unsigned int size)
 
 static inline int epilogue_offset(const struct jit_ctx *ctx)
 {
-	int to = ctx->offset[ctx->prog->len - 1];
-	int from = ctx->idx - ctx->body_offset;
+	int to = ctx->epilogue_offset;
+	int from = ctx->idx;
 
 	return to - from;
 }
@@ -463,6 +463,8 @@ emit_cond_jmp:
 	}
 	/* function return */
 	case BPF_JMP | BPF_EXIT:
+		/* Optimization: when last instruction is EXIT,
+		   simply fallthrough to epilogue. */
 		if (i == ctx->prog->len - 1)
 			break;
 		jmp_offset = epilogue_offset(ctx);
@@ -685,11 +687,13 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 
 	/* 1. Initial fake pass to compute ctx->idx. */
 
-	/* Fake pass to fill in ctx->offset. */
+	/* Fake pass to fill in ctx->offset and ctx->tmp_used. */
 	if (build_body(&ctx))
 		goto out;
 
 	build_prologue(&ctx);
+
+	ctx.epilogue_offset = ctx.idx;
 	build_epilogue(&ctx);
 
 	/* Now we know the actual image size. */
@@ -706,7 +710,6 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 
 	build_prologue(&ctx);
 
-	ctx.body_offset = ctx.idx;
 	if (build_body(&ctx)) {
 		bpf_jit_binary_free(header);
 		goto out;
-- 
1.9.1
