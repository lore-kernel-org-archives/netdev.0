From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 5/8] bpf: Avoid copying the entire BPF program when hashing it
Date: Tue, 10 Jan 2017 15:24:43 -0800
Message-ID: <7d95d2483eb648960a9f33e38a01fcc678da545e.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50686 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756882AbdAJXZB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 18:25:01 -0500
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sha256 helpers can consume a message incrementally, so there's no need
to allocate a buffer to store the whole blob to be hashed.

This may be a slight slowdown for very long messages because gcc can't
inline the sha256_update() calls.  For reasonably-sized programs,
however, this should be a considerable speedup as vmalloc() is quite
slow.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 kernel/bpf/core.c | 33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 668b92f6ab58..106162a1bc54 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -149,44 +149,37 @@ void __bpf_prog_free(struct bpf_prog *fp)
 int bpf_prog_calc_digest(struct bpf_prog *fp)
 {
 	struct sha256_state sha;
-	u32 i, psize;
-	struct bpf_insn *dst;
+	u32 i;
 	bool was_ld_map;
-	u8 *raw;
-
-	psize = bpf_prog_insn_size(fp);
-	raw = vmalloc(psize);
-	if (!raw)
-		return -ENOMEM;
 
 	sha256_init_direct(&sha);
 
 	/* We need to take out the map fd for the digest calculation
 	 * since they are unstable from user space side.
 	 */
-	dst = (void *)raw;
 	for (i = 0, was_ld_map = false; i < fp->len; i++) {
-		dst[i] = fp->insnsi[i];
+		struct bpf_insn insn = fp->insnsi[i];
+
 		if (!was_ld_map &&
-		    dst[i].code == (BPF_LD | BPF_IMM | BPF_DW) &&
-		    dst[i].src_reg == BPF_PSEUDO_MAP_FD) {
+		    insn.code == (BPF_LD | BPF_IMM | BPF_DW) &&
+		    insn.src_reg == BPF_PSEUDO_MAP_FD) {
 			was_ld_map = true;
-			dst[i].imm = 0;
+			insn.imm = 0;
 		} else if (was_ld_map &&
-			   dst[i].code == 0 &&
-			   dst[i].dst_reg == 0 &&
-			   dst[i].src_reg == 0 &&
-			   dst[i].off == 0) {
+			   insn.code == 0 &&
+			   insn.dst_reg == 0 &&
+			   insn.src_reg == 0 &&
+			   insn.off == 0) {
 			was_ld_map = false;
-			dst[i].imm = 0;
+			insn.imm = 0;
 		} else {
 			was_ld_map = false;
 		}
+
+		sha256_update_direct(&sha, (const u8 *)&insn, sizeof(insn));
 	}
 
-	sha256_update_direct(&sha, raw, psize);
 	sha256_final_direct(&sha, fp->digest);
-	vfree(raw);
 	return 0;
 }
 
-- 
2.9.3
