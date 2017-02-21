From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: fix unlocking of jited image when module ronx not set
Date: Tue, 21 Feb 2017 16:09:34 +0100
Message-ID: <578a70ffeddfb08608dff0d223bfa51ab3b5ac93.1487688093.git.daniel@iogearbox.net>
References: <cover.1487688093.git.daniel@iogearbox.net>
Cc: ast@kernel.org, labbott@redhat.com, eric.dumazet@gmail.com,
        willemb@google.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56272 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbdBUPKE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 10:10:04 -0500
In-Reply-To: <cover.1487688093.git.daniel@iogearbox.net>
In-Reply-To: <cover.1487688093.git.daniel@iogearbox.net>
References: <cover.1487688093.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric and Willem reported that they recently saw random crashes when
JIT was in use and bisected this to 74451e66d516 ("bpf: make jited
programs visible in traces"). Issue was that the consolidation part
added bpf_jit_binary_unlock_ro() that would unlock previously made
read-only memory back to read-write. However, DEBUG_SET_MODULE_RONX
cannot be used for this to test for presence of set_memory_*()
functions. We need to use ARCH_HAS_SET_MEMORY instead to fix this;
also add the corresponding bpf_jit_binary_lock_ro() to filter.h.

Fixes: 74451e66d516 ("bpf: make jited programs visible in traces")
Reported-by: Eric Dumazet <edumazet@google.com>
Reported-by: Willem de Bruijn <willemb@google.com>
Bisected-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit_comp.c |  2 +-
 arch/s390/net/bpf_jit_comp.c  |  2 +-
 arch/x86/net/bpf_jit_comp.c   |  2 +-
 include/linux/filter.h        | 13 +++++++++++--
 4 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 05d1210..a785554 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -898,7 +898,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	bpf_flush_icache(header, ctx.image + ctx.idx);
 
-	set_memory_ro((unsigned long)header, header->pages);
+	bpf_jit_binary_lock_ro(header);
 	prog->bpf_func = (void *)ctx.image;
 	prog->jited = 1;
 
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index f1d0e62..b49c52a 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1327,7 +1327,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 			print_fn_code(jit.prg_buf, jit.size_prg);
 	}
 	if (jit.prg_buf) {
-		set_memory_ro((unsigned long)header, header->pages);
+		bpf_jit_binary_lock_ro(header);
 		fp->bpf_func = (void *) jit.prg_buf;
 		fp->jited = 1;
 	}
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 18a62e2..32322ce 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1165,7 +1165,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 
 	if (image) {
 		bpf_flush_icache(header, image + proglen);
-		set_memory_ro((unsigned long)header, header->pages);
+		bpf_jit_binary_lock_ro(header);
 		prog->bpf_func = (void *)image;
 		prog->jited = 1;
 	} else {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 0c1cc91..0c167fd 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -551,7 +551,7 @@ static inline bool bpf_prog_was_classic(const struct bpf_prog *prog)
 
 #define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))
 
-#ifdef CONFIG_DEBUG_SET_MODULE_RONX
+#ifdef CONFIG_ARCH_HAS_SET_MEMORY
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
 	set_memory_ro((unsigned long)fp, fp->pages);
@@ -562,6 +562,11 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 	set_memory_rw((unsigned long)fp, fp->pages);
 }
 
+static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
+{
+	set_memory_ro((unsigned long)hdr, hdr->pages);
+}
+
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
 {
 	set_memory_rw((unsigned long)hdr, hdr->pages);
@@ -575,10 +580,14 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 {
 }
 
+static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
+{
+}
+
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
 {
 }
-#endif /* CONFIG_DEBUG_SET_MODULE_RONX */
+#endif /* CONFIG_ARCH_HAS_SET_MEMORY */
 
 static inline struct bpf_binary_header *
 bpf_jit_binary_hdr(const struct bpf_prog *fp)
-- 
1.9.3
