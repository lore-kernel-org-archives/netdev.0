From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] seccomp: simplify seccomp_prepare_filter and reuse bpf_prepare_filter
Date: Wed,  6 May 2015 16:12:28 +0200
Message-ID: <7c2f7da437c992f239d7e3883983dc25500b77b2.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59821 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbEFOMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:12:38 -0400
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Schichan <nschichan@freebox.fr>

Remove the calls to bpf_check_classic(), bpf_convert_filter() and
bpf_migrate_runtime() and let bpf_prepare_filter() take care of that
instead.

seccomp_check_filter() is passed to bpf_prepare_filter() so that it
gets called from there, after bpf_check_classic().

We can now remove exposure of two internal classic BPF functions
previously used by seccomp. The export of bpf_check_classic() symbol,
previously known as sk_chk_filter(), was there since pre git times,
and no in-tree module was using it, therefore remove it.

Joint work with Daniel Borkmann.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Kees Cook <keescook@chromium.org>
---
 include/linux/filter.h |  4 ---
 kernel/seccomp.c       | 68 ++++++++++++++++----------------------------------
 net/core/filter.c      |  8 +++---
 3 files changed, 26 insertions(+), 54 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 9199624..0dcb44b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -363,9 +363,6 @@ int sk_filter(struct sock *sk, struct sk_buff *skb);
 void bpf_prog_select_runtime(struct bpf_prog *fp);
 void bpf_prog_free(struct bpf_prog *fp);
 
-int bpf_convert_filter(struct sock_filter *prog, int len,
-		       struct bpf_insn *new_prog, int *new_len);
-
 struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags);
 struct bpf_prog *bpf_prog_realloc(struct bpf_prog *fp_old, unsigned int size,
 				  gfp_t gfp_extra_flags);
@@ -387,7 +384,6 @@ int sk_detach_filter(struct sock *sk);
 typedef int (*bpf_aux_classic_check_t)(struct sock_filter *filter,
 				       unsigned int flen);
 
-int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
 struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
 				    bpf_aux_classic_check_t trans);
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 4f44028..93d40f7 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -347,15 +347,14 @@ static inline void seccomp_sync_threads(void)
 static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
 	struct seccomp_filter *filter;
-	unsigned long fp_size;
-	struct sock_filter *fp;
-	int new_len;
-	long ret;
+	struct bpf_prog *prog;
+	unsigned long fsize;
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
+
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
-	fp_size = fprog->len * sizeof(struct sock_filter);
+	fsize = bpf_classic_proglen(fprog);
 
 	/*
 	 * Installing a seccomp filter requires that the task has
@@ -368,60 +367,37 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 				     CAP_SYS_ADMIN) != 0)
 		return ERR_PTR(-EACCES);
 
-	fp = kzalloc(fp_size, GFP_KERNEL|__GFP_NOWARN);
-	if (!fp)
+	prog = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
+	if (!prog)
 		return ERR_PTR(-ENOMEM);
 
 	/* Copy the instructions from fprog. */
-	ret = -EFAULT;
-	if (copy_from_user(fp, fprog->filter, fp_size))
-		goto free_prog;
-
-	/* Check and rewrite the fprog via the skb checker */
-	ret = bpf_check_classic(fp, fprog->len);
-	if (ret)
-		goto free_prog;
+	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
+		__bpf_prog_free(prog);
+		return ERR_PTR(-EFAULT);
+	}
 
-	/* Check and rewrite the fprog for seccomp use */
-	ret = seccomp_check_filter(fp, fprog->len);
-	if (ret)
-		goto free_prog;
+	prog->len = fprog->len;
 
-	/* Convert 'sock_filter' insns to 'bpf_insn' insns */
-	ret = bpf_convert_filter(fp, fprog->len, NULL, &new_len);
-	if (ret)
-		goto free_prog;
+	/* bpf_prepare_filter() already takes care of freeing
+	 * memory in case something goes wrong.
+	 */
+	prog = bpf_prepare_filter(prog, seccomp_check_filter);
+	if (IS_ERR(prog))
+		return ERR_CAST(prog);
 
 	/* Allocate a new seccomp_filter */
-	ret = -ENOMEM;
 	filter = kzalloc(sizeof(struct seccomp_filter),
 			 GFP_KERNEL|__GFP_NOWARN);
-	if (!filter)
-		goto free_prog;
-
-	filter->prog = bpf_prog_alloc(bpf_prog_size(new_len), __GFP_NOWARN);
-	if (!filter->prog)
-		goto free_filter;
-
-	ret = bpf_convert_filter(fp, fprog->len, filter->prog->insnsi, &new_len);
-	if (ret)
-		goto free_filter_prog;
+	if (!filter) {
+		bpf_prog_destroy(prog);
+		return ERR_PTR(-ENOMEM);
+	}
 
-	kfree(fp);
+	filter->prog = prog;
 	atomic_set(&filter->usage, 1);
-	filter->prog->len = new_len;
-
-	bpf_prog_select_runtime(filter->prog);
 
 	return filter;
-
-free_filter_prog:
-	__bpf_prog_free(filter->prog);
-free_filter:
-	kfree(filter);
-free_prog:
-	kfree(fp);
-	return ERR_PTR(ret);
 }
 
 /**
diff --git a/net/core/filter.c b/net/core/filter.c
index e670494..f887084 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -355,8 +355,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  * for socket filters: ctx == 'struct sk_buff *', for seccomp:
  * ctx == 'struct seccomp_data *'.
  */
-int bpf_convert_filter(struct sock_filter *prog, int len,
-		       struct bpf_insn *new_prog, int *new_len)
+static int bpf_convert_filter(struct sock_filter *prog, int len,
+			      struct bpf_insn *new_prog, int *new_len)
 {
 	int new_flen = 0, pass = 0, target, i;
 	struct bpf_insn *new_insn;
@@ -751,7 +751,8 @@ static bool chk_code_allowed(u16 code_to_probe)
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int bpf_check_classic(const struct sock_filter *filter, unsigned int flen)
+static int bpf_check_classic(const struct sock_filter *filter,
+			     unsigned int flen)
 {
 	bool anc_found;
 	int pc;
@@ -825,7 +826,6 @@ int bpf_check_classic(const struct sock_filter *filter, unsigned int flen)
 
 	return -EINVAL;
 }
-EXPORT_SYMBOL(bpf_check_classic);
 
 static int bpf_prog_store_orig_filter(struct bpf_prog *fp,
 				      const struct sock_fprog *fprog)
-- 
1.9.3
