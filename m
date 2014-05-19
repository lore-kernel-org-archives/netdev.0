From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: filter: cleanup invocation of internal BPF
Date: Mon, 19 May 2014 14:56:14 -0700
Message-ID: <1400536574-4485-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:58894 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaESV4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 17:56:21 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so6325431pad.2
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 14:56:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel API for classic BPF socket filters is:

sk_unattached_filter_create() - validate classic BPF, convert, JIT
SK_RUN_FILTER() - run it
sk_unattached_filter_destroy() - destroy socket filter

Cleanup internal BPF kernel API as following:

sk_filter_select_runtime() - final step of internal BPF creation.
  Try to JIT internal BPF program, if JIT is not available select interpreter
SK_RUN_FILTER() - run it
sk_filter_free() - free internal BPF program

Disallow direct calls to BPF interpreter. Execution of the BPF program should
be done with SK_RUN_FILTER() macro.

Example of internal BPF create, run, destroy:

  struct sk_filter *fp;

  fp = kzalloc(sk_filter_size(prog_len), GFP_KERNEL);
  memcpy(fp->insni, prog, prog_len * sizeof(fp->insni[0]));
  fp->len = prog_len;

  sk_filter_select_runtime(fp);

  SK_RUN_FILTER(fp, ctx);

  sk_filter_free(fp);

Sockets, seccomp, testsuite, tracing are using different ways to populate
sk_filter, so first steps of program creation are not common.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

This patch blurs the line between BPF program running in interpeter and JITed
program. The 'jited' flag in 'struct sk_filter' indicates to the caller whether
program was JITed or not, but that shouldn't matter to the caller. JITed program
must be equivalent.
Another alternative is to export bpf_int_jit_compile()/bpf_jit_free() and let
the users decide whether to use interpreter or JIT, but that seems ugly.
We already have net.core.bpf_jit_enable for that.

 include/linux/filter.h |    6 ++----
 kernel/seccomp.c       |    6 ++----
 lib/test_bpf.c         |    4 ++--
 net/core/filter.c      |   44 ++++++++++++++++++++++++++++----------------
 4 files changed, 34 insertions(+), 26 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9d5ae0a2c954..7977b3958e25 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -184,10 +184,8 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
-u32 sk_run_filter_int_seccomp(const struct seccomp_data *ctx,
-			      const struct sock_filter_int *insni);
-u32 sk_run_filter_int_skb(const struct sk_buff *ctx,
-			  const struct sock_filter_int *insni);
+void sk_filter_select_runtime(struct sk_filter *fp);
+void sk_filter_free(struct sk_filter *fp);
 
 int sk_convert_filter(struct sock_filter *prog, int len,
 		      struct sock_filter_int *new_prog, int *new_len);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 7e02d624cc50..1036b6f2fded 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -273,10 +273,8 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 
 	atomic_set(&filter->usage, 1);
 	filter->prog->len = new_len;
-	filter->prog->bpf_func = (void *)sk_run_filter_int_seccomp;
 
-	/* JIT internal BPF into native HW instructions */
-	bpf_int_jit_compile(filter->prog);
+	sk_filter_select_runtime(filter->prog);
 
 	/*
 	 * If there is an existing filter, make it the prev and don't drop its
@@ -340,7 +338,7 @@ void put_seccomp_filter(struct task_struct *tsk)
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
 		orig = orig->prev;
-		bpf_jit_free(freeme->prog);
+		sk_filter_free(freeme->prog);
 		kfree(freeme);
 	}
 }
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 3603ebcd5d65..e160934430eb 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1489,7 +1489,7 @@ static __init int test_bpf(void)
 			memcpy(fp_ext->insns, tests[i].insns_int,
 			       fprog.len * 8);
 			fp->len = fprog.len;
-			fp->bpf_func = sk_run_filter_int_skb;
+			sk_filter_select_runtime(fp);
 		} else {
 			err = sk_unattached_filter_create(&fp, &fprog);
 			if (tests[i].data_type == EXPECTED_FAIL) {
@@ -1516,7 +1516,7 @@ static __init int test_bpf(void)
 		if (tests[i].data_type != SKB_INT)
 			sk_unattached_filter_destroy(fp);
 		else
-			kfree(fp);
+			sk_filter_free(fp);
 
 		if (err) {
 			pr_cont("FAIL %d\n", err);
diff --git a/net/core/filter.c b/net/core/filter.c
index 32c5b44c537e..7067cb240d3e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -153,7 +153,7 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
  * keep, 0 for none. @ctx is the data we are operating on, @insn is the
  * array of filter instructions.
  */
-unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
+static unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
 {
 	u64 stack[MAX_BPF_STACK / sizeof(u64)];
 	u64 regs[MAX_BPF_REG], tmp;
@@ -571,15 +571,6 @@ load_byte:
 		return 0;
 }
 
-u32 sk_run_filter_int_seccomp(const struct seccomp_data *ctx,
-			      const struct sock_filter_int *insni)
-    __attribute__ ((alias ("__sk_run_filter")));
-
-u32 sk_run_filter_int_skb(const struct sk_buff *ctx,
-			  const struct sock_filter_int *insni)
-    __attribute__ ((alias ("__sk_run_filter")));
-EXPORT_SYMBOL_GPL(sk_run_filter_int_skb);
-
 /* Helper to find the offset of pkt_type in sk_buff structure. We want
  * to make sure its still a 3bit field starting at a byte boundary;
  * taken from arch/x86/net/bpf_jit_comp.c.
@@ -1397,7 +1388,7 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
 	sk_release_orig_filter(fp);
-	bpf_jit_free(fp);
+	sk_filter_free(fp);
 }
 
 /**
@@ -1497,7 +1488,6 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 		goto out_err_free;
 	}
 
-	fp->bpf_func = sk_run_filter_int_skb;
 	fp->len = new_len;
 
 	/* 2nd pass: remap sock_filter insns into sock_filter_int insns. */
@@ -1510,6 +1500,8 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 		 */
 		goto out_err_free;
 
+	sk_filter_select_runtime(fp);
+
 	kfree(old_prog);
 	return fp;
 
@@ -1528,6 +1520,29 @@ void __weak bpf_int_jit_compile(struct sk_filter *prog)
 {
 }
 
+/**
+ *	sk_filter_select_runtime - select execution runtime for BPF program
+ *	@fp: sk_filter populated with internal BPF program
+ *
+ * try to JIT internal BPF program, if JIT is not available select interpreter
+ * BPF program will be executed via SK_RUN_FILTER() macro
+ */
+void sk_filter_select_runtime(struct sk_filter *fp)
+{
+	fp->bpf_func = (void *) __sk_run_filter;
+
+	/* Probe if internal BPF can be JITed */
+	bpf_int_jit_compile(fp);
+}
+EXPORT_SYMBOL_GPL(sk_filter_select_runtime);
+
+/* free internal BPF program */
+void sk_filter_free(struct sk_filter *fp)
+{
+	bpf_jit_free(fp);
+}
+EXPORT_SYMBOL_GPL(sk_filter_free);
+
 static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 					     struct sock *sk)
 {
@@ -1548,12 +1563,9 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 	/* JIT compiler couldn't process this filter, so do the
 	 * internal BPF translation for the optimized interpreter.
 	 */
-	if (!fp->jited) {
+	if (!fp->jited)
 		fp = __sk_migrate_filter(fp, sk);
 
-		/* Probe if internal BPF can be jit-ed */
-		bpf_int_jit_compile(fp);
-	}
 	return fp;
 }
 
-- 
1.7.9.5
