From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/5] net: filter: get rid of sock_fprog_kern
Date: Wed, 23 Apr 2014 22:56:59 +0200
Message-ID: <1398286621-3591-4-git-send-email-dborkman@redhat.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932651AbaDWU5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 16:57:21 -0400
In-Reply-To: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is actually cleaner to just get rid of sock_fprog_kern structure.
It's not really useful as we can just use sock_fprog structure as
we do elsewhere in the kernel, this could throw some sparse false
positives though, but getting rid of the structure duplication is
probably the better way to go.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h | 13 +++++--------
 net/core/filter.c      | 24 ++++++++++++------------
 net/core/sock_diag.c   |  4 ++--
 3 files changed, 19 insertions(+), 22 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index b042d1d..e58b687 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -67,11 +67,6 @@ struct compat_sock_fprog {
 };
 #endif
 
-struct sock_fprog_kern {
-	u16			len;
-	struct sock_filter	*filter;
-};
-
 struct sk_buff;
 struct sock;
 struct seccomp_data;
@@ -80,7 +75,7 @@ struct sk_filter {
 	atomic_t		refcnt;
 	u32			jited:1,	/* Is our filter JIT'ed? */
 				len:31;		/* Number of filter blocks */
-	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
+	struct sock_fprog	*orig_prog;	/* Original BPF program */
 	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter_int *filter);
@@ -97,8 +92,10 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 		   offsetof(struct sk_filter, insns[proglen]));
 }
 
-#define sk_filter_proglen(fprog)			\
-		(fprog->len * sizeof(fprog->filter[0]))
+static inline unsigned int sk_filter_prog_size(const struct sock_fprog *fprog)
+{
+	return fprog->len * sizeof(fprog->filter[0]);
+}
 
 #define SK_RUN_FILTER(filter, ctx)			\
 		(*filter->bpf_func)(ctx, filter->insnsi)
diff --git a/net/core/filter.c b/net/core/filter.c
index 2fd2293..e5e7717 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1396,17 +1396,17 @@ EXPORT_SYMBOL(sk_chk_filter);
 static int sk_store_orig_filter(struct sk_filter *fp,
 				const struct sock_fprog *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
-	struct sock_fprog_kern *fkprog;
+	unsigned int fsize = sk_filter_prog_size(fprog);
+	struct sock_fprog *op;
 
-	fp->orig_prog = kmalloc(sizeof(*fkprog), GFP_KERNEL);
+	fp->orig_prog = kmalloc(sizeof(*op), GFP_KERNEL);
 	if (!fp->orig_prog)
 		return -ENOMEM;
 
-	fkprog = fp->orig_prog;
-	fkprog->len = fprog->len;
-	fkprog->filter = kmemdup(fp->insns, fsize, GFP_KERNEL);
-	if (!fkprog->filter) {
+	op = fp->orig_prog;
+	op->len = fprog->len;
+	op->filter = kmemdup(fp->insns, fsize, GFP_KERNEL);
+	if (!op->filter) {
 		kfree(fp->orig_prog);
 		return -ENOMEM;
 	}
@@ -1416,7 +1416,7 @@ static int sk_store_orig_filter(struct sk_filter *fp,
 
 static void sk_release_orig_filter(struct sk_filter *fp)
 {
-	struct sock_fprog_kern *fprog = fp->orig_prog;
+	struct sock_fprog *fprog = fp->orig_prog;
 
 	if (fprog) {
 		kfree(fprog->filter);
@@ -1599,7 +1599,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 int sk_unattached_filter_create(struct sk_filter **pfp,
 				struct sock_fprog *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = sk_filter_prog_size(fprog);
 	struct sk_filter *fp;
 
 	/* Make sure new filter is there and in the right amounts. */
@@ -1651,7 +1651,7 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = sk_filter_prog_size(fprog);
 	unsigned int sk_fsize = sk_filter_size(fprog->len);
 	int err;
 
@@ -1799,7 +1799,7 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		  unsigned int len)
 {
-	struct sock_fprog_kern *fprog;
+	struct sock_fprog *fprog;
 	struct sk_filter *filter;
 	int ret = 0;
 
@@ -1824,7 +1824,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		goto out;
 
 	ret = -EFAULT;
-	if (copy_to_user(ubuf, fprog->filter, sk_filter_proglen(fprog)))
+	if (copy_to_user(ubuf, fprog->filter, sk_filter_prog_size(fprog)))
 		goto out;
 
 	/* Instead of bytes, the API requests to return the number
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index d7af188..6669077 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -52,7 +52,7 @@ EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
-	struct sock_fprog_kern *fprog;
+	struct sock_fprog *fprog;
 	struct sk_filter *filter;
 	struct nlattr *attr;
 	unsigned int flen;
@@ -69,7 +69,7 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 		goto out;
 
 	fprog = filter->orig_prog;
-	flen = sk_filter_proglen(fprog);
+	flen = sk_filter_prog_size(fprog);
 
 	attr = nla_reserve(skb, attrtype, flen);
 	if (attr == NULL) {
-- 
1.7.11.7
