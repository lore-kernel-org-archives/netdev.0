From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, arm64: fix jit branch offset related to ldimm64
Date: Tue,  2 May 2017 20:34:54 +0200
Message-ID: <5f7d105a1830ed789f1b416dc17b02fce0bd070e.1493749880.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org, xi.wang@gmail.com,
        catalin.marinas@arm.com, zlim.lnx@gmail.com,
        linux-arm-kernel@lists.infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37544 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdEBSfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 14:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the instruction right before the branch destination is
a 64 bit load immediate, we currently calculate the wrong
jump offset in the ctx->offset[] array as we only account
one instruction slot for the 64 bit load immediate although
it uses two BPF instructions. Fix it up by setting the offset
into the right slot after we incremented the index.

Before (ldimm64 test 1):

  [...]
  00000020:  52800007  mov w7, #0x0 // #0
  00000024:  d2800060  mov x0, #0x3 // #3
  00000028:  d2800041  mov x1, #0x2 // #2
  0000002c:  eb01001f  cmp x0, x1
  00000030:  54ffff82  b.cs 0x00000020
  00000034:  d29fffe7  mov x7, #0xffff // #65535
  00000038:  f2bfffe7  movk x7, #0xffff, lsl #16
  0000003c:  f2dfffe7  movk x7, #0xffff, lsl #32
  00000040:  f2ffffe7  movk x7, #0xffff, lsl #48
  00000044:  d29dddc7  mov x7, #0xeeee // #61166
  00000048:  f2bdddc7  movk x7, #0xeeee, lsl #16
  0000004c:  f2ddddc7  movk x7, #0xeeee, lsl #32
  00000050:  f2fdddc7  movk x7, #0xeeee, lsl #48
  [...]

After (ldimm64 test 1):

  [...]
  00000020:  52800007  mov w7, #0x0 // #0
  00000024:  d2800060  mov x0, #0x3 // #3
  00000028:  d2800041  mov x1, #0x2 // #2
  0000002c:  eb01001f  cmp x0, x1
  00000030:  540000a2  b.cs 0x00000044
  00000034:  d29fffe7  mov x7, #0xffff // #65535
  00000038:  f2bfffe7  movk x7, #0xffff, lsl #16
  0000003c:  f2dfffe7  movk x7, #0xffff, lsl #32
  00000040:  f2ffffe7  movk x7, #0xffff, lsl #48
  00000044:  d29dddc7  mov x7, #0xeeee // #61166
  00000048:  f2bdddc7  movk x7, #0xeeee, lsl #16
  0000004c:  f2ddddc7  movk x7, #0xeeee, lsl #32
  00000050:  f2fdddc7  movk x7, #0xeeee, lsl #48
  [...]

Also, add a couple of test cases to make sure JITs pass
this test. Tested on Cavium ThunderX ARMv8. The added
test cases all pass after the fix.

Fixes: 8eee539ddea0 ("arm64: bpf: fix out-of-bounds read in bpf2a64_offset()")
Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Xi Wang <xi.wang@gmail.com>
---
 ( Based against net-next where BPF related patches are usually
   routed, if something else is preferred please let me know. )

 arch/arm64/net/bpf_jit_comp.c |  8 ++++----
 lib/test_bpf.c                | 45 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a785554..ce8ab04 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -779,14 +779,14 @@ static int build_body(struct jit_ctx *ctx)
 		int ret;
 
 		ret = build_insn(insn, ctx);
-
-		if (ctx->image == NULL)
-			ctx->offset[i] = ctx->idx;
-
 		if (ret > 0) {
 			i++;
+			if (ctx->image == NULL)
+				ctx->offset[i] = ctx->idx;
 			continue;
 		}
+		if (ctx->image == NULL)
+			ctx->offset[i] = ctx->idx;
 		if (ret)
 			return ret;
 	}
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 0362da0..2e38502 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4656,6 +4656,51 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 		{ },
 		{ { 0, 1 } },
 	},
+	{
+		/* Mainly testing JIT + imm64 here. */
+		"JMP_JGE_X: ldimm64 test 1",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JGE, R1, R2, 2),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeUL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xeeeeeeeeU } },
+	},
+	{
+		"JMP_JGE_X: ldimm64 test 2",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JGE, R1, R2, 0),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xffffffffU } },
+	},
+	{
+		"JMP_JGE_X: ldimm64 test 3",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_LD_IMM64(R1, 3),
+			BPF_LD_IMM64(R2, 2),
+			BPF_JMP_REG(BPF_JGE, R1, R2, 4),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeUL),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_JMP | BPF_JNE | BPF_X */
 	{
 		"JMP_JNE_X: if (3 != 2) return 1",
-- 
1.9.3
