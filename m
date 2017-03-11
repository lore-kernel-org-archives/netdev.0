From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: improve read-only handling
Date: Sat, 11 Mar 2017 16:55:49 +0100
Message-ID: <19a5c15f39cec7e0e8eeba8e2add5db859a6d34a.1489246970.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44839 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753890AbdCKP4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 10:56:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve bpf_{prog,jit_binary}_{un,}lock_ro() by throwing a
one-time warning in case of an error when the image couldn't
be set read-only, and also mark struct bpf_prog as locked when
bpf_prog_lock_ro() was called.

Reason for the latter is that bpf_prog_unlock_ro() is called from
various places including error paths, and we shouldn't mess with
page attributes when really not needed.

For bpf_jit_binary_unlock_ro() this is not needed as jited flag
implicitly indicates this, thus for archs with ARCH_HAS_SET_MEMORY
we're guaranteed to have a previously locked image. Overall, this
should also help us to identify any further potential issues with
set_memory_*() helpers.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 ( My preference is on -net, so we can potentially find and fix
   any remaining unexpected issue with set_memory_*(). Thanks! )

 include/linux/filter.h | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 0c167fd..fbf7b39 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -409,6 +409,7 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	kmemcheck_bitfield_begin(meta);
 	u16			jited:1,	/* Is our filter JIT'ed? */
+				locked:1,	/* Program image locked? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -554,22 +555,29 @@ static inline bool bpf_prog_was_classic(const struct bpf_prog *prog)
 #ifdef CONFIG_ARCH_HAS_SET_MEMORY
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	set_memory_ro((unsigned long)fp, fp->pages);
+	fp->locked = 1;
+	WARN_ON_ONCE(set_memory_ro((unsigned long)fp, fp->pages));
 }
 
 static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 {
-	set_memory_rw((unsigned long)fp, fp->pages);
+	if (fp->locked) {
+		WARN_ON_ONCE(set_memory_rw((unsigned long)fp, fp->pages));
+		/* In case set_memory_rw() fails, we want to be the first
+		 * to crash here instead of some random place later on.
+		 */
+		fp->locked = 0;
+	}
 }
 
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
-	set_memory_ro((unsigned long)hdr, hdr->pages);
+	WARN_ON_ONCE(set_memory_ro((unsigned long)hdr, hdr->pages));
 }
 
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
 {
-	set_memory_rw((unsigned long)hdr, hdr->pages);
+	WARN_ON_ONCE(set_memory_rw((unsigned long)hdr, hdr->pages));
 }
 #else
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
-- 
1.9.3
