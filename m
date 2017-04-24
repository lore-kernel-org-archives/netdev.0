From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: make bpf_xdp_adjust_head support mandatory
Date: Mon, 24 Apr 2017 22:14:35 +0200
Message-ID: <6e25ef44c5de02d1feb8b4cc8a2cf60adb4a596e.1493064530.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59773 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1174102AbdDXUOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 16:14:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that also the last in-tree user of the xdp_adjust_head bit has
been removed, we can remove the flag from struct bpf_prog altogether.

This, at the same time, also makes sure that any future driver for
XDP comes with bpf_xdp_adjust_head() support right away.

A rejection based on this flag would also mean that tail calls
couldn't be used with such driver as per c2002f983767 ("bpf: fix
checking xdp_adjust_head on tail calls") fix, thus lets not allow
for it in the first place.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/filter.h | 3 +--
 kernel/bpf/verifier.c  | 3 ---
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 511fe91..9a7786d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -413,8 +413,7 @@ struct bpf_prog {
 				locked:1,	/* Program image locked? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
-				dst_needed:1,	/* Do we need dst entry? */
-				xdp_adjust_head:1; /* Adjusting pkt head? */
+				dst_needed:1;	/* Do we need dst entry? */
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ca15cf2..6f8b6ed 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3346,8 +3346,6 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			prog->dst_needed = 1;
 		if (insn->imm == BPF_FUNC_get_prandom_u32)
 			bpf_user_rnd_init_once();
-		if (insn->imm == BPF_FUNC_xdp_adjust_head)
-			prog->xdp_adjust_head = 1;
 		if (insn->imm == BPF_FUNC_tail_call) {
 			/* If we tail call into other programs, we
 			 * cannot make any assumptions since they can
@@ -3355,7 +3353,6 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			 * the program array.
 			 */
 			prog->cb_access = 1;
-			prog->xdp_adjust_head = 1;
 
 			/* mark bpf_tail_call as different opcode to avoid
 			 * conditional branch in the interpeter for every normal
-- 
1.9.3
