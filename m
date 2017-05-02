From: David Miller <davem@davemloft.net>
Subject: [PATCH] sparc64: Fix BPF JIT wrt. branches and ldimm64
 instructions.
Date: Mon, 01 May 2017 23:50:13 -0400 (EDT)
Message-ID: <20170501.235013.431457553660896233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, xi.wang@gmail.com,
        catalin.marinas@arm.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750848AbdEBDuV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:50:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like other JITs, sparc64 maintains an array of instruction offsets but
stores the entries off by one.  This is done because jumps to the exit
block are indexed to one past the last BPF instruction.

So if we size the array by the program length, we need to record the
previous instruction in order to stay within the array bounds.

This is explained in ARM JIT commit 8eee539ddea0 ("arm64: bpf: fix
out-of-bounds read in bpf2a64_offset()").

But this scheme requires a little bit of careful handling when the
instruction before the branch destination is a 64-bit load immediate.
It takes up 2 BPF instruction slots.

Therefore, we have to fill in the array entry for the second half of
the 64-bit load immediate instruction rather than for the one for the
beginning of that instruction.

Fixes: 7a12b5031c6b ("sparc64: Add eBPF JIT.")
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/net/bpf_jit_comp_64.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index ec7d10d..21de774 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -1446,12 +1446,13 @@ static int build_body(struct jit_ctx *ctx)
 		int ret;
 
 		ret = build_insn(insn, ctx);
-		ctx->offset[i] = ctx->idx;
 
 		if (ret > 0) {
 			i++;
+			ctx->offset[i] = ctx->idx;
 			continue;
 		}
+		ctx->offset[i] = ctx->idx;
 		if (ret)
 			return ret;
 	}
-- 
2.1.2.532.g19b5d50
