From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] seccomp, filter: add and use bpf_prog_create_from_user from seccomp
Date: Wed,  6 May 2015 16:12:30 +0200
Message-ID: <1ff9bc3432f272308ae6bb8945994df3f8ceadbb.1430908146.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59830 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbEFOMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:12:38 -0400
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seccomp has always been a special candidate when it comes to preparation
of its filters in seccomp_prepare_filter(). Due to the extra checks and
filter rewrite it partially duplicates code and has BPF internals exposed.

This patch adds a generic API inside the BPF code code that seccomp can use
and thus keep it's filter preparation code minimal and better maintainable.
The other side-effect is that now classic JITs can add seccomp support as
well by only providing a BPF_LDX | BPF_W | BPF_ABS translation.

Tested with seccomp and BPF test suites.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Nicolas Schichan <nschichan@freebox.fr>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Kees Cook <keescook@chromium.org>
---
 include/linux/filter.h | 12 +++++-------
 kernel/seccomp.c       | 42 ++++++++++++-----------------------------
 net/core/filter.c      | 51 ++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 66 insertions(+), 39 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 0dcb44b..3c03a60 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -374,19 +374,17 @@ static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 	__bpf_prog_free(fp);
 }
 
+typedef int (*bpf_aux_classic_check_t)(struct sock_filter *filter,
+				       unsigned int flen);
+
 int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
+int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
+			      bpf_aux_classic_check_t trans);
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
-
-typedef int (*bpf_aux_classic_check_t)(struct sock_filter *filter,
-				       unsigned int flen);
-
-struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
-				    bpf_aux_classic_check_t trans);
-
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 93d40f7..245df6b 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -346,15 +346,13 @@ static inline void seccomp_sync_threads(void)
  */
 static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 {
-	struct seccomp_filter *filter;
-	struct bpf_prog *prog;
-	unsigned long fsize;
+	struct seccomp_filter *sfilter;
+	int ret;
 
 	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
 		return ERR_PTR(-EINVAL);
 
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
-	fsize = bpf_classic_proglen(fprog);
 
 	/*
 	 * Installing a seccomp filter requires that the task has
@@ -367,37 +365,21 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 				     CAP_SYS_ADMIN) != 0)
 		return ERR_PTR(-EACCES);
 
-	prog = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
-	if (!prog)
-		return ERR_PTR(-ENOMEM);
-
-	/* Copy the instructions from fprog. */
-	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
-		__bpf_prog_free(prog);
-		return ERR_PTR(-EFAULT);
-	}
-
-	prog->len = fprog->len;
-
-	/* bpf_prepare_filter() already takes care of freeing
-	 * memory in case something goes wrong.
-	 */
-	prog = bpf_prepare_filter(prog, seccomp_check_filter);
-	if (IS_ERR(prog))
-		return ERR_CAST(prog);
-
 	/* Allocate a new seccomp_filter */
-	filter = kzalloc(sizeof(struct seccomp_filter),
-			 GFP_KERNEL|__GFP_NOWARN);
-	if (!filter) {
-		bpf_prog_destroy(prog);
+	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
+	if (!sfilter)
 		return ERR_PTR(-ENOMEM);
+
+	ret = bpf_prog_create_from_user(&sfilter->prog, fprog,
+					seccomp_check_filter);
+	if (ret < 0) {
+		kfree(sfilter);
+		return ERR_PTR(ret);
 	}
 
-	filter->prog = prog;
-	atomic_set(&filter->usage, 1);
+	atomic_set(&sfilter->usage, 1);
 
-	return filter;
+	return sfilter;
 }
 
 /**
diff --git a/net/core/filter.c b/net/core/filter.c
index 45c015d..a831f19 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -991,8 +991,8 @@ out_err:
 	return ERR_PTR(err);
 }
 
-struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
-				    bpf_aux_classic_check_t trans)
+static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
+					   bpf_aux_classic_check_t trans)
 {
 	int err;
 
@@ -1074,6 +1074,53 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_create);
 
+/**
+ *	bpf_prog_create_from_user - create an unattached filter from user buffer
+ *	@pfp: the unattached filter that is created
+ *	@fprog: the filter program
+ *	@trans: post-classic verifier transformation handler
+ *
+ * This function effectively does the same as bpf_prog_create(), only
+ * that it builds up its insns buffer from user space provided buffer.
+ * It also allows for passing a bpf_aux_classic_check_t handler.
+ */
+int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
+			      bpf_aux_classic_check_t trans)
+{
+	unsigned int fsize = bpf_classic_proglen(fprog);
+	struct bpf_prog *fp;
+
+	/* Make sure new filter is there and in the right amounts. */
+	if (fprog->filter == NULL)
+		return -EINVAL;
+
+	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
+	if (!fp)
+		return -ENOMEM;
+
+	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
+		__bpf_prog_free(fp);
+		return -EFAULT;
+	}
+
+	fp->len = fprog->len;
+	/* Since unattached filters are not copied back to user
+	 * space through sk_get_filter(), we do not need to hold
+	 * a copy here, and can spare us the work.
+	 */
+	fp->orig_prog = NULL;
+
+	/* bpf_prepare_filter() already takes care of freeing
+	 * memory in case something goes wrong.
+	 */
+	fp = bpf_prepare_filter(fp, trans);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	*pfp = fp;
+	return 0;
+}
+
 void bpf_prog_destroy(struct bpf_prog *fp)
 {
 	__bpf_prog_release(fp);
-- 
1.9.3
