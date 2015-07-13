From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: remove self-assignment in interpreter's tail call
Date: Mon, 13 Jul 2015 20:49:32 +0200
Message-ID: <6586042063b52e17a355fce15460ee16c1ee95bf.1436812762.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34622 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbGMSth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 14:49:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ARG1 = BPF_R1 as it stands, evaluates to regs[BPF_REG_1] = regs[BPF_REG_1]
and thus has no effect. Add a comment instead, explaining what happens and
why it's okay to just remove it. Since from user space side, a tail call is
invoked as a pseudo helper function via bpf_tail_call_proto, the verifier
checks the arguments just like with any other helper function and makes
sure that the first argument (regs[BPF_REG_1])'s type is ARG_PTR_TO_CTX.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/core.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index c5bedc8..bf38f5e 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -453,7 +453,11 @@ select_insn:
 		if (unlikely(!prog))
 			goto out;
 
-		ARG1 = BPF_R1;
+		/* ARG1 at this point is guaranteed to point to CTX from
+		 * the verifier side due to the fact that the tail call is
+		 * handeled like a helper, that is, bpf_tail_call_proto,
+		 * where arg1_type is ARG_PTR_TO_CTX.
+		 */
 		insn = prog->insnsi;
 		goto select_insn;
 out:
-- 
1.9.3
