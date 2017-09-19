From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix ri->map prog pointer on bpf_prog_realloc
Date: Tue, 19 Sep 2017 03:16:44 +0200
Message-ID: <b797841607c3327007a787af3418cb0a60b868c0.1505783562.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46125 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdISBQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 21:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 109980b894e9 ("bpf: don't select potentially stale
ri->map from buggy xdp progs") passed the pointer to the prog
itself to be loaded into r4 prior on bpf_redirect_map() helper
call, so that we can store the owner into ri->map_owner out of
the helper.

Issue with that is that the actual address of the prog is still
subject to change when subsequent rewrites occur, e.g. through
patching other helper functions or constant blinding. Thus, we
really need to take prog->aux as the address we're holding, and
then during runtime fetch the actual pointer via aux->prog. This
also works with prog clones as they share the same aux and fixup
pointer to self after blinding finished.

Fixes: 109980b894e9 ("bpf: don't select potentially stale ri->map from buggy xdp progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 799b245..243c09f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -4205,9 +4205,17 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 		}
 
 		if (insn->imm == BPF_FUNC_redirect_map) {
-			u64 addr = (unsigned long)prog;
+			/* Note, we cannot use prog directly as imm as subsequent
+			 * rewrites would still change the prog pointer. The only
+			 * stable address we can use is aux, which also works with
+			 * prog clones during blinding.
+			 */
+			u64 addr = (unsigned long)prog->aux;
+			const int r4 = BPF_REG_4;
 			struct bpf_insn r4_ld[] = {
-				BPF_LD_IMM64(BPF_REG_4, addr),
+				BPF_LD_IMM64(r4, addr),
+				BPF_LDX_MEM(BPF_DW, r4, r4,
+					    offsetof(struct bpf_prog_aux, prog)),
 				*insn,
 			};
 			cnt = ARRAY_SIZE(r4_ld);
-- 
1.9.3
