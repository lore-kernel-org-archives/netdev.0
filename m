From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: don't let ldimm64 leak map addresses on unprivileged
Date: Mon,  8 May 2017 00:04:09 +0200
Message-ID: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, jannh@google.com, kafai@fb.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54704 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdEGWmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:42:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes two things at once:

1) It checks the env->allow_ptr_leaks and only prints the map address to
   the log if we have the privileges to do so, otherwise it just dumps 0
   as we would when kptr_restrict is enabled on %pK. Given the latter is
   off by default and not every distro sets it, I don't want to rely on
   this, hence the 0 by default for unprivileged.

2) Printing of ldimm64 in the verifier log is currently broken in that
   we don't print the full immediate, but only the 32 bit part of the
   first insn part for ldimm64. Thus, fix this up as well; it's okay to
   access, since we verified all ldimm64 earlier already (including just
   constants) through replace_map_fd_with_map_ptr().

Fixes: cbd357008604 ("bpf: verifier (add ability to receive verification log)")
Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c2ff608..5d19a02 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -298,7 +298,8 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 	[BPF_EXIT >> 4] = "exit",
 };
 
-static void print_bpf_insn(struct bpf_insn *insn)
+static void print_bpf_insn(const struct bpf_verifier_env *env,
+			   const struct bpf_insn *insn)
 {
 	u8 class = BPF_CLASS(insn->code);
 
@@ -362,9 +363,19 @@ static void print_bpf_insn(struct bpf_insn *insn)
 				insn->code,
 				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 				insn->src_reg, insn->imm);
-		} else if (BPF_MODE(insn->code) == BPF_IMM) {
-			verbose("(%02x) r%d = 0x%x\n",
-				insn->code, insn->dst_reg, insn->imm);
+		} else if (BPF_MODE(insn->code) == BPF_IMM &&
+			   BPF_SIZE(insn->code) == BPF_DW) {
+			/* At this point, we already made sure that the second
+			 * part of the ldimm64 insn is accessible.
+			 */
+			u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
+			bool map_ptr = insn->src_reg == BPF_PSEUDO_MAP_FD;
+
+			if (map_ptr && !env->allow_ptr_leaks)
+				imm = 0;
+
+			verbose("(%02x) r%d = 0x%llx\n", insn->code,
+				insn->dst_reg, (unsigned long long)imm);
 		} else {
 			verbose("BUG_ld_%02x\n", insn->code);
 			return;
@@ -2853,7 +2864,7 @@ static int do_check(struct bpf_verifier_env *env)
 
 		if (log_level) {
 			verbose("%d: ", insn_idx);
-			print_bpf_insn(insn);
+			print_bpf_insn(env, insn);
 		}
 
 		err = ext_analyzer_insn_hook(env, insn_idx, prev_insn_idx);
-- 
1.9.3
