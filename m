From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/5] bpf, x86_64/arm64: remove old ldimm64 artifacts from jits
Date: Thu, 27 Apr 2017 01:39:31 +0200
Message-ID: <6bf6e315622d8aff4e7e0cb3d0267c9bc414dcbd.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57401 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754553AbdDZXk4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:56 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For both cases, the verifier is already rejecting such invalid
formed instructions. Thus, remove these artifacts from old times
and align it with ppc64, sparc64 and s390x JITs that don't have
them in the first place.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm64/net/bpf_jit_comp.c | 9 ---------
 arch/x86/net/bpf_jit_comp.c   | 7 -------
 2 files changed, 16 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a785554..3047368 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -604,15 +604,6 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		const struct bpf_insn insn1 = insn[1];
 		u64 imm64;
 
-		if (insn1.code != 0 || insn1.src_reg != 0 ||
-		    insn1.dst_reg != 0 || insn1.off != 0) {
-			/* Note: verifier in BPF core must catch invalid
-			 * instructions.
-			 */
-			pr_err_once("Invalid BPF_LD_IMM64 instruction\n");
-			return -EINVAL;
-		}
-
 		imm64 = (u64)insn1.imm << 32 | (u32)imm;
 		emit_a64_mov_i64(dst, imm64, ctx);
 
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 32322ce..14f840d 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -490,13 +490,6 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			break;
 
 		case BPF_LD | BPF_IMM | BPF_DW:
-			if (insn[1].code != 0 || insn[1].src_reg != 0 ||
-			    insn[1].dst_reg != 0 || insn[1].off != 0) {
-				/* verifier must catch invalid insns */
-				pr_err("invalid BPF_LD_IMM64 insn\n");
-				return -EINVAL;
-			}
-
 			/* optimization: if imm64 is zero, use 'xor <dst>,<dst>'
 			 * to save 7 bytes.
 			 */
-- 
1.9.3
