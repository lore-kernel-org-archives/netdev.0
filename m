From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Fri, 22 May 2015 15:42:55 -0700
Message-ID: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36031 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422679AbbEVWnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 18:43:03 -0400
Received: by paza2 with SMTP id a2so20691747paz.3
        for <netdev@vger.kernel.org>; Fri, 22 May 2015 15:43:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

x86 has variable length encoding. x86 JIT compiler is trying
to pick the shortest encoding for given bpf instruction.
While doing so the jump targets are changing, so JIT is doing
multiple passes over the program. Typical program needs 3 passes.
Some very short programs converge with 2 passes. Large programs
may need 4 or 5. But specially crafted bpf programs may hit the
pass limit and if the program converges on the last iteration
the JIT compiler will be producing an image full of 'int 3' insns.
Fix this corner case by doing final iteration over bpf program.

Fixes: 0a14842f5a3c ("net: filter: Just In Time compiler for x86-64")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Daniel wrote the 'Edge hopping nuthouse' test case with 4k jump
instructions that managed to trigger this bug.
The test case is nuts and the bug is real.
It's an old bug, but I think worth backporting all the way.
Though this fix will apply cleanly only till commit:
f3c2af7ba17a ("net: filter: x86: split bpf_jit_compile()")
The older kernels should be similar. They have
'for (pass = 0; pass < 10; pass++) {' at the line 153 or so.
and all have similar problem as far as I can see.

 arch/x86/net/bpf_jit_comp.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 99f76103c6b7..ddeff4844a10 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -966,7 +966,12 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	}
 	ctx.cleanup_addr = proglen;
 
-	for (pass = 0; pass < 10; pass++) {
+	/* JITed image shrinks with every pass and the loop iterates
+	 * until the image stops shrinking. Very large bpf programs
+	 * may converge on the last pass. In such case do one more
+	 * pass to emit the final image
+	 */
+	for (pass = 0; pass < 10 || image; pass++) {
 		proglen = do_jit(prog, addrs, image, oldproglen, &ctx);
 		if (proglen <= 0) {
 			image = NULL;
-- 
1.7.9.5
