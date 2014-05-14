From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 3/3] seccomp: JIT compile seccomp filter
Date: Tue, 13 May 2014 19:50:47 -0700
Message-ID: <1400035847-7730-4-git-send-email-ast@plumgrid.com>
References: <1400035847-7730-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Chema Gonzalez <chema@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:46914 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbaENCvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 22:51:04 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so1040607pab.6
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:51:04 -0700 (PDT)
In-Reply-To: <1400035847-7730-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take advantage of internal BPF JIT

05-sim-long_jumps.c of libseccomp was used as micro-benchmark:

 seccomp_rule_add_exact(ctx,...
 seccomp_rule_add_exact(ctx,...

 rc = seccomp_load(ctx);

 for (i = 0; i < 10000000; i++)
    syscall(...);

$ sudo sysctl net.core.bpf_jit_enable=1
$ time ./bench
real	0m2.769s
user	0m1.136s
sys	0m1.624s

$ sudo sysctl net.core.bpf_jit_enable=0
$ time ./bench
real	0m5.825s
user	0m1.268s
sys	0m4.548s

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/seccomp.c |   29 ++++++++++++++++++++---------
 1 file changed, 20 insertions(+), 9 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index b35c21503a36..7e02d624cc50 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -54,8 +54,7 @@
 struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
-	unsigned short len;  /* Instruction count */
-	struct sock_filter_int insnsi[];
+	struct sk_filter *prog;
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
@@ -189,7 +188,8 @@ static u32 seccomp_run_filters(int syscall)
 	 * value always takes priority (ignoring the DATA).
 	 */
 	for (f = current->seccomp.filter; f; f = f->prev) {
-		u32 cur_ret = sk_run_filter_int_seccomp(&sd, f->insnsi);
+		u32 cur_ret = SK_RUN_FILTER(f->prog, (void *)&sd);
+
 		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
 	}
@@ -215,7 +215,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 		return -EINVAL;
 
 	for (filter = current->seccomp.filter; filter; filter = filter->prev)
-		total_insns += filter->len + 4;  /* include a 4 instr penalty */
+		total_insns += filter->prog->len + 4;  /* include a 4 instr penalty */
 	if (total_insns > MAX_INSNS_PER_PATH)
 		return -ENOMEM;
 
@@ -256,19 +256,27 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 
 	/* Allocate a new seccomp_filter */
 	ret = -ENOMEM;
-	filter = kzalloc(sizeof(struct seccomp_filter) +
-			 sizeof(struct sock_filter_int) * new_len,
+	filter = kzalloc(sizeof(struct seccomp_filter),
 			 GFP_KERNEL|__GFP_NOWARN);
 	if (!filter)
 		goto free_prog;
 
-	ret = sk_convert_filter(fp, fprog->len, filter->insnsi, &new_len);
-	if (ret)
+	filter->prog = kzalloc(sk_filter_size(new_len),
+			       GFP_KERNEL|__GFP_NOWARN);
+	if (!filter->prog)
 		goto free_filter;
+
+	ret = sk_convert_filter(fp, fprog->len, filter->prog->insnsi, &new_len);
+	if (ret)
+		goto free_filter_prog;
 	kfree(fp);
 
 	atomic_set(&filter->usage, 1);
-	filter->len = new_len;
+	filter->prog->len = new_len;
+	filter->prog->bpf_func = (void *)sk_run_filter_int_seccomp;
+
+	/* JIT internal BPF into native HW instructions */
+	bpf_int_jit_compile(filter->prog);
 
 	/*
 	 * If there is an existing filter, make it the prev and don't drop its
@@ -278,6 +286,8 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	current->seccomp.filter = filter;
 	return 0;
 
+free_filter_prog:
+	kfree(filter->prog);
 free_filter:
 	kfree(filter);
 free_prog:
@@ -330,6 +340,7 @@ void put_seccomp_filter(struct task_struct *tsk)
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
 		orig = orig->prev;
+		bpf_jit_free(freeme->prog);
 		kfree(freeme);
 	}
 }
-- 
1.7.9.5
