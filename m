From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 06/10] bpf: prepare bpf_int_jit_compile/bpf_prog_select_runtime apis
Date: Fri, 13 May 2016 19:08:31 +0200
Message-ID: <c046b6e29e85dede05b1127b846b366dc25f6b28.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41879 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbcEMRJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:09:03 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the blinding is strictly only called from inside eBPF JITs,
we need to change signatures for bpf_int_jit_compile() and
bpf_prog_select_runtime() first in order to prepare that the
eBPF program we're dealing with can change underneath. Hence,
for call sites, we need to return the latest prog. No functional
change in this patch.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/arm64/net/bpf_jit_comp.c |  7 ++++---
 arch/s390/net/bpf_jit_comp.c  |  8 +++++---
 arch/x86/net/bpf_jit_comp.c   |  7 ++++---
 include/linux/filter.h        |  5 +++--
 kernel/bpf/core.c             | 18 ++++++++++++++----
 kernel/bpf/syscall.c          |  2 +-
 lib/test_bpf.c                |  5 ++++-
 net/core/filter.c             |  6 +++++-
 8 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index a7fb209..b421df7 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -761,7 +761,7 @@ void bpf_jit_compile(struct bpf_prog *prog)
 	/* Nothing to do here. We support Internal BPF. */
 }
 
-void bpf_int_jit_compile(struct bpf_prog *prog)
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_binary_header *header;
 	struct jit_ctx ctx;
@@ -769,14 +769,14 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	u8 *image_ptr;
 
 	if (!bpf_jit_enable)
-		return;
+		return prog;
 
 	memset(&ctx, 0, sizeof(ctx));
 	ctx.prog = prog;
 
 	ctx.offset = kcalloc(prog->len, sizeof(int), GFP_KERNEL);
 	if (ctx.offset == NULL)
-		return;
+		return prog;
 
 	/* 1. Initial fake pass to compute ctx->idx. */
 
@@ -827,6 +827,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	prog->jited = 1;
 out:
 	kfree(ctx.offset);
+	return prog;
 }
 
 void bpf_jit_free(struct bpf_prog *prog)
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 3c0bfc1..fcf301a 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1262,18 +1262,19 @@ void bpf_jit_compile(struct bpf_prog *fp)
 /*
  * Compile eBPF program "fp"
  */
-void bpf_int_jit_compile(struct bpf_prog *fp)
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 {
 	struct bpf_binary_header *header;
 	struct bpf_jit jit;
 	int pass;
 
 	if (!bpf_jit_enable)
-		return;
+		return fp;
+
 	memset(&jit, 0, sizeof(jit));
 	jit.addrs = kcalloc(fp->len + 1, sizeof(*jit.addrs), GFP_KERNEL);
 	if (jit.addrs == NULL)
-		return;
+		return fp;
 	/*
 	 * Three initial passes:
 	 *   - 1/2: Determine clobbered registers
@@ -1305,6 +1306,7 @@ void bpf_int_jit_compile(struct bpf_prog *fp)
 	}
 free_addrs:
 	kfree(jit.addrs);
+	return fp;
 }
 
 /*
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index f5bfd4f..6b2d23e 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1073,7 +1073,7 @@ void bpf_jit_compile(struct bpf_prog *prog)
 {
 }
 
-void bpf_int_jit_compile(struct bpf_prog *prog)
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_binary_header *header = NULL;
 	int proglen, oldproglen = 0;
@@ -1084,11 +1084,11 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	int i;
 
 	if (!bpf_jit_enable)
-		return;
+		return prog;
 
 	addrs = kmalloc(prog->len * sizeof(*addrs), GFP_KERNEL);
 	if (!addrs)
-		return;
+		return prog;
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -1140,6 +1140,7 @@ void bpf_int_jit_compile(struct bpf_prog *prog)
 	}
 out:
 	kfree(addrs);
+	return prog;
 }
 
 void bpf_jit_free(struct bpf_prog *fp)
diff --git a/include/linux/filter.h b/include/linux/filter.h
index c4aae49..891852c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -458,7 +458,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
-int bpf_prog_select_runtime(struct bpf_prog *fp);
+struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err);
 void bpf_prog_free(struct bpf_prog *fp);
 
 struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags);
@@ -492,7 +492,8 @@ bool sk_filter_charge(struct sock *sk, struct sk_filter *fp);
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
-void bpf_int_jit_compile(struct bpf_prog *fp);
+
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog);
 bool bpf_helper_changes_skb_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 49b5538..70f0821 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -761,15 +761,22 @@ static int bpf_check_tail_call(const struct bpf_prog *fp)
 /**
  *	bpf_prog_select_runtime - select exec runtime for BPF program
  *	@fp: bpf_prog populated with internal BPF program
+ *	@err: pointer to error variable
  *
  * Try to JIT eBPF program, if JIT is not available, use interpreter.
  * The BPF program will be executed via BPF_PROG_RUN() macro.
  */
-int bpf_prog_select_runtime(struct bpf_prog *fp)
+struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err)
 {
 	fp->bpf_func = (void *) __bpf_prog_run;
 
-	bpf_int_jit_compile(fp);
+	/* eBPF JITs can rewrite the program in case constant
+	 * blinding is active. However, in case of error during
+	 * blinding, bpf_int_jit_compile() must always return a
+	 * valid program, which in this case would simply not
+	 * be JITed, but falls back to the interpreter.
+	 */
+	fp = bpf_int_jit_compile(fp);
 	bpf_prog_lock_ro(fp);
 
 	/* The tail call compatibility check can only be done at
@@ -777,7 +784,9 @@ int bpf_prog_select_runtime(struct bpf_prog *fp)
 	 * with JITed or non JITed program concatenations and not
 	 * all eBPF JITs might immediately support all features.
 	 */
-	return bpf_check_tail_call(fp);
+	*err = bpf_check_tail_call(fp);
+
+	return fp;
 }
 EXPORT_SYMBOL_GPL(bpf_prog_select_runtime);
 
@@ -859,8 +868,9 @@ const struct bpf_func_proto bpf_tail_call_proto = {
 };
 
 /* For classic BPF JITs that don't implement bpf_int_jit_compile(). */
-void __weak bpf_int_jit_compile(struct bpf_prog *prog)
+struct bpf_prog * __weak bpf_int_jit_compile(struct bpf_prog *prog)
 {
+	return prog;
 }
 
 bool __weak bpf_helper_changes_skb_data(void *func)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index cf5e9f7..46ecce4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -762,7 +762,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	fixup_bpf_calls(prog);
 
 	/* eBPF program is ready to be JITed */
-	err = bpf_prog_select_runtime(prog);
+	prog = bpf_prog_select_runtime(prog, &err);
 	if (err < 0)
 		goto free_used_maps;
 
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 8f22fbe..93f4501 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -5621,7 +5621,10 @@ static struct bpf_prog *generate_filter(int which, int *err)
 		fp->type = BPF_PROG_TYPE_SOCKET_FILTER;
 		memcpy(fp->insnsi, fptr, fp->len * sizeof(struct bpf_insn));
 
-		bpf_prog_select_runtime(fp);
+		/* We cannot error here as we don't need type compatibility
+		 * checks.
+		 */
+		fp = bpf_prog_select_runtime(fp, err);
 		break;
 	}
 
diff --git a/net/core/filter.c b/net/core/filter.c
index ea51b47..68adb5f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -994,7 +994,11 @@ static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
 		 */
 		goto out_err_free;
 
-	bpf_prog_select_runtime(fp);
+	/* We are guaranteed to never error here with cBPF to eBPF
+	 * transitions, since there's no issue with type compatibility
+	 * checks on program arrays.
+	 */
+	fp = bpf_prog_select_runtime(fp, &err);
 
 	kfree(old_prog);
 	return fp;
-- 
1.9.3
