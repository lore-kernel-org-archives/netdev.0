From: David Daney <david.daney@cavium.com>
Subject: [PATCH 1/3] MIPS,bpf: Fix using smp_processor_id() in preemptible splat.
Date: Fri, 18 Aug 2017 16:40:31 -0700
Message-ID: <20170818234033.5990-2-david.daney@cavium.com>
References: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818234033.5990-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the kernel is configured with preemption enabled we were getting
warning stack traces for use of current_cpu_type().

Fix by moving the test between preempt_disable()/preempt_enable() and
caching the results of the CPU type tests for use during code
generation.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/ebpf_jit.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/mips/net/ebpf_jit.c b/arch/mips/net/ebpf_jit.c
index 3f87b96..721216b 100644
--- a/arch/mips/net/ebpf_jit.c
+++ b/arch/mips/net/ebpf_jit.c
@@ -113,6 +113,7 @@ struct jit_ctx {
 	u64 *reg_val_types;
 	unsigned int long_b_conversion:1;
 	unsigned int gen_b_offsets:1;
+	unsigned int use_bbit_insns:1;
 };
 
 static void set_reg_val_type(u64 *rvt, int reg, enum reg_val_type type)
@@ -655,19 +656,6 @@ static int emit_bpf_tail_call(struct jit_ctx *ctx, int this_idx)
 	return build_int_epilogue(ctx, MIPS_R_T9);
 }
 
-static bool use_bbit_insns(void)
-{
-	switch (current_cpu_type()) {
-	case CPU_CAVIUM_OCTEON:
-	case CPU_CAVIUM_OCTEON_PLUS:
-	case CPU_CAVIUM_OCTEON2:
-	case CPU_CAVIUM_OCTEON3:
-		return true;
-	default:
-		return false;
-	}
-}
-
 static bool is_bad_offset(int b_off)
 {
 	return b_off > 0x1ffff || b_off < -0x20000;
@@ -1198,7 +1186,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		if (dst < 0)
 			return dst;
 
-		if (use_bbit_insns() && hweight32((u32)insn->imm) == 1) {
+		if (ctx->use_bbit_insns && hweight32((u32)insn->imm) == 1) {
 			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
 				b_off = b_imm(exit_idx, ctx);
 				if (is_bad_offset(b_off))
@@ -1853,6 +1841,18 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	memset(&ctx, 0, sizeof(ctx));
 
+	preempt_disable();
+	switch (current_cpu_type()) {
+	case CPU_CAVIUM_OCTEON:
+	case CPU_CAVIUM_OCTEON_PLUS:
+	case CPU_CAVIUM_OCTEON2:
+	case CPU_CAVIUM_OCTEON3:
+		ctx.use_bbit_insns = 1;
+	default:
+		ctx.use_bbit_insns = 0;
+	}
+	preempt_enable();
+
 	ctx.offsets = kcalloc(prog->len + 1, sizeof(*ctx.offsets), GFP_KERNEL);
 	if (ctx.offsets == NULL)
 		goto out_err;
-- 
2.9.5
