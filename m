From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf, arm64: fix faulty emission of map access in tail calls
Date: Thu, 11 May 2017 01:53:15 +0200
Message-ID: <0e928e7c351b962a16376a2ab29e2af1c5b4c027.1494459589.git.daniel__1773.07849885455$1494460411$gmane$org@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, illusionist.neo@gmail.com,
        zlim.lnx@gmail.com, catalin.marinas@arm.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33577 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEJXx2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 19:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shubham was recently asking on netdev why in arm64 JIT we don't multiply
the index for accessing the tail call map by 8. That led me into testing
out arm64 JIT wrt tail calls and it turned out I got a NULL pointer
dereference on the tail call.

The buggy access is at:

  prog = array->ptrs[index];
  if (prog == NULL)
      goto out;

  [...]
  00000060:  d2800e0a  mov x10, #0x70 // #112
  00000064:  f86a682a  ldr x10, [x1,x10]
  00000068:  f862694b  ldr x11, [x10,x2]
  0000006c:  b40000ab  cbz x11, 0x00000080
  [...]

The code triggering the crash is f862694b. x1 at the time contains the
address of the bpf array, x10 offsetof(struct bpf_array, ptrs). Meaning,
above we load the pointer to the program at map slot 0 into x10. x10
can then be NULL if the slot is not occupied, which we later on try to
access with a user given offset in x2 that is the map index.

Fix this by emitting the following instead:

  [...]
  00000060:  d2800e0a  mov x10, #0x70 // #112
  00000064:  8b0a002a  add x10, x1, x10
  00000068:  d37df04b  lsl x11, x2, #3
  0000006c:  f86b694b  ldr x11, [x10,x11]
  00000070:  b40000ab  cbz x11, 0x00000084
  [...]

This basically adds the offset to ptrs to the base address of the bpf
array we got and we later on access the map with an index * 8 offset
relative to that. The tail call map itself is basically one large area
with meta data at the head followed by the array of prog pointers.
This makes tail calls working again, tested on Cavium ThunderX ARMv8.

Fixes: ddb55992b04d ("arm64: bpf: implement bpf_tail_call() helper")
Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index c6e5358..71f9305 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -253,8 +253,9 @@ static int emit_bpf_tail_call(struct jit_ctx *ctx)
 	 */
 	off = offsetof(struct bpf_array, ptrs);
 	emit_a64_mov_i64(tmp, off, ctx);
-	emit(A64_LDR64(tmp, r2, tmp), ctx);
-	emit(A64_LDR64(prg, tmp, r3), ctx);
+	emit(A64_ADD(1, tmp, r2, tmp), ctx);
+	emit(A64_LSL(1, prg, r3, 3), ctx);
+	emit(A64_LDR64(prg, tmp, prg), ctx);
 	emit(A64_CBZ(1, prg, jmp_offset), ctx);
 
 	/* goto *(prog->bpf_func + prologue_size); */
-- 
1.9.3
