From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH] ARM: net: delegate filter to kernel interpreter when imm_offset() return value can't fit into 12bits.
Date: Thu,  7 May 2015 17:14:21 +0200
Message-ID: <1431011661-10277-1-git-send-email-nschichan@freebox.fr>
To: Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Mircea Gherzan <mgherzan@gmail.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ARM JIT code emits "ldr rX, [pc, #offset]" to access the literal
pool. #offset maximum value is 4095 and if the generated code is too
large, the #offset value can overflow and not point to the expected
slot in the literal pool. Additionally, when overflow occurs, bits of
the overflow can end up changing the destination register of the ldr
instruction.

Fix that by detecting the overflow in imm_offset() and setting a flag
that is checked for each BPF instructions converted in
build_body(). As of now it can only be detected in the second pass. As
a result the second build_body() call can now fail, so add the
corresponding cleanup code in that case.

Using multiple literal pools in the JITed code is going to require
lots of intrusive changes to the JIT code (which would better be done
as a feature instead of fix), just delegating to the kernel BPF
interpreter in that case is a more straight forward, minimal fix and
easy to backport.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/arm/net/bpf_jit_32.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 6bda637..bb8ffcd 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -54,6 +54,7 @@
 #define SEEN_DATA		(1 << (BPF_MEMWORDS + 3))
 
 #define FLAG_NEED_X_RESET	(1 << 0)
+#define FLAG_IMM_OVERFLOW	(1 << 1)
 
 struct jit_ctx {
 	const struct bpf_prog *skf;
@@ -293,6 +294,15 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 	/* PC in ARM mode == address of the instruction + 8 */
 	imm = offset - (8 + ctx->idx * 4);
 
+	if (imm & ~0xfff) {
+		/*
+		 * literal pool is too far, signal it into flags. we
+		 * can only detect it on the second pass unfortunately.
+		 */
+		ctx->flags |= FLAG_IMM_OVERFLOW;
+		return 0;
+	}
+
 	return imm;
 }
 
@@ -876,6 +886,14 @@ b_epilogue:
 		default:
 			return -1;
 		}
+
+		if (ctx->flags & FLAG_IMM_OVERFLOW)
+			/*
+			 * this instruction generated an overflow when
+			 * trying to access the literal pool, so
+			 * delegate this filter to the kernel interpreter.
+			 */
+			return -1;
 	}
 
 	/* compute offsets only during the first pass */
@@ -938,7 +956,14 @@ void bpf_jit_compile(struct bpf_prog *fp)
 	ctx.idx = 0;
 
 	build_prologue(&ctx);
-	build_body(&ctx);
+	if (build_body(&ctx) < 0) {
+#if __LINUX_ARM_ARCH__ < 7
+		if (ctx.imm_count)
+			kfree(ctx.imms);
+#endif
+		bpf_jit_binary_free(header);
+		goto out;
+	}
 	build_epilogue(&ctx);
 
 	flush_icache_range((u32)ctx.target, (u32)(ctx.target + ctx.idx));
-- 
1.9.1
