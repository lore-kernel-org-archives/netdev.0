From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf: remove stubs for cBPF from arch code
Date: Thu, 16 Feb 2017 22:24:49 +0100
Message-ID: <86fd4a6952fe158d887c1a76aea2f924f12e58f9.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40165 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933485AbdBPVZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:25:38 -0500
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the dummy bpf_jit_compile() stubs for eBPF JITs and make
that a single __weak function in the core that can be overridden
similarly to the eBPF one. Also remove stale pr_err() mentions
of bpf_jit_compile.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm64/net/bpf_jit_comp.c     |  5 -----
 arch/powerpc/net/bpf_jit_comp64.c |  2 --
 arch/s390/net/bpf_jit_comp.c      |  8 --------
 arch/x86/net/bpf_jit_comp.c       |  8 ++------
 include/linux/filter.h            |  6 +-----
 kernel/bpf/core.c                 | 12 +++++++++++-
 6 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index b2fc97a..c444408 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -813,11 +813,6 @@ static inline void bpf_flush_icache(void *start, void *end)
 	flush_icache_range((unsigned long)start, (unsigned long)end);
 }
 
-void bpf_jit_compile(struct bpf_prog *prog)
-{
-	/* Nothing to do here. We support Internal BPF. */
-}
-
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_prog *tmp, *orig_prog = prog;
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 73a5cf1..f9ebd02 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -961,8 +961,6 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 	return 0;
 }
 
-void bpf_jit_compile(struct bpf_prog *fp) { }
-
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 {
 	u32 proglen;
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 167b31b..6454efd 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1263,14 +1263,6 @@ static int bpf_jit_prog(struct bpf_jit *jit, struct bpf_prog *fp)
 }
 
 /*
- * Classic BPF function stub. BPF programs will be converted into
- * eBPF and then bpf_int_jit_compile() will be called.
- */
-void bpf_jit_compile(struct bpf_prog *fp)
-{
-}
-
-/*
  * Compile eBPF program "fp"
  */
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index bb660e5..26123d0 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1067,13 +1067,13 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 
 		ilen = prog - temp;
 		if (ilen > BPF_MAX_INSN_SIZE) {
-			pr_err("bpf_jit_compile fatal insn size error\n");
+			pr_err("bpf_jit: fatal insn size error\n");
 			return -EFAULT;
 		}
 
 		if (image) {
 			if (unlikely(proglen + ilen > oldproglen)) {
-				pr_err("bpf_jit_compile fatal error\n");
+				pr_err("bpf_jit: fatal error\n");
 				return -EFAULT;
 			}
 			memcpy(image + proglen, temp, ilen);
@@ -1085,10 +1085,6 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 	return proglen;
 }
 
-void bpf_jit_compile(struct bpf_prog *prog)
-{
-}
-
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_binary_header *header = NULL;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index e4eb254..c7a70e0 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -607,6 +607,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog);
+void bpf_jit_compile(struct bpf_prog *prog);
 bool bpf_helper_changes_pkt_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
@@ -625,7 +626,6 @@ struct bpf_binary_header *
 		     bpf_jit_fill_hole_t bpf_fill_ill_insns);
 void bpf_jit_binary_free(struct bpf_binary_header *hdr);
 
-void bpf_jit_compile(struct bpf_prog *fp);
 void bpf_jit_free(struct bpf_prog *fp);
 
 struct bpf_prog *bpf_jit_blind_constants(struct bpf_prog *fp);
@@ -669,10 +669,6 @@ static inline bool bpf_jit_blinding_enabled(void)
 	return true;
 }
 #else
-static inline void bpf_jit_compile(struct bpf_prog *fp)
-{
-}
-
 static inline void bpf_jit_free(struct bpf_prog *fp)
 {
 	bpf_prog_unlock_free(fp);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index fddd76b..2831ba1 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1154,12 +1154,22 @@ const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 	.arg3_type	= ARG_ANYTHING,
 };
 
-/* For classic BPF JITs that don't implement bpf_int_jit_compile(). */
+/* Stub for JITs that only support cBPF. eBPF programs are interpreted.
+ * It is encouraged to implement bpf_int_jit_compile() instead, so that
+ * eBPF and implicitly also cBPF can get JITed!
+ */
 struct bpf_prog * __weak bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	return prog;
 }
 
+/* Stub for JITs that support eBPF. All cBPF code gets transformed into
+ * eBPF by the kernel and is later compiled by bpf_int_jit_compile().
+ */
+void __weak bpf_jit_compile(struct bpf_prog *prog)
+{
+}
+
 bool __weak bpf_helper_changes_pkt_data(void *func)
 {
 	return false;
-- 
1.9.3
