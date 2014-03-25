From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 2/9] net: filter: keep original BPF program around
Date: Tue, 25 Mar 2014 13:10:50 +0100
Message-ID: <1395749457-16178-3-git-send-email-dborkman@redhat.com>
References: <1395749457-16178-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbaCYMLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 08:11:19 -0400
In-Reply-To: <1395749457-16178-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to open up the possibility to internally transform a BPF program
into an alternative and possibly non-trivial reversible representation, we
need to keep the original BPF program around, so that it can be passed back
to user space w/o the need of a complex decoder.

The reason for that use case resides in commit a8fc92778080 ("sk-filter:
Add ability to get socket filter program (v2)"), that is, the ability
to retrieve the currently attached BPF filter from a given socket used
mainly by the checkpoint-restore project, for example.

Therefore, we add two helpers sk_{store,release}_orig_filter for taking
care of that. In the sk_unattached_filter_create() case, there's no such
possibility/requirement to retrieve a loaded BPF program. Therefore, we
can spare us the work in that case.

This approach will simplify and slightly speed up both, sk_get_filter()
and sock_diag_put_filterinfo() handlers as we won't need to successively
decode filters anymore through sk_decode_filter(). As we still need
sk_decode_filter() later on, we're keeping it around.

Joint work with Alexei Starovoitov.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/filter.h | 15 +++++++--
 net/core/filter.c      | 86 ++++++++++++++++++++++++++++++++++++++++----------
 net/core/sock_diag.c   | 23 ++++++--------
 3 files changed, 93 insertions(+), 31 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index e65e230..93a9792 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -19,14 +19,19 @@ struct compat_sock_fprog {
 };
 #endif
 
+struct sock_fprog_kern {
+	u16			len;
+	struct sock_filter	*filter;
+};
+
 struct sk_buff;
 struct sock;
 
-struct sk_filter
-{
+struct sk_filter {
 	atomic_t		refcnt;
 	u32			jited:1,	/* Is our filter JIT'ed? */
 				len:31;		/* Number of filter blocks */
+	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct sock_filter *filter);
@@ -42,14 +47,20 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 		   offsetof(struct sk_filter, insns[proglen]));
 }
 
+#define sk_filter_proglen(fprog)			\
+		(fprog->len * sizeof(fprog->filter[0]))
+
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
 extern unsigned int sk_run_filter(const struct sk_buff *skb,
 				  const struct sock_filter *filter);
+
 extern int sk_unattached_filter_create(struct sk_filter **pfp,
 				       struct sock_fprog *fprog);
 extern void sk_unattached_filter_destroy(struct sk_filter *fp);
+
 extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 extern int sk_detach_filter(struct sock *sk);
+
 extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
diff --git a/net/core/filter.c b/net/core/filter.c
index 2874cc8..f19c078 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -629,6 +629,37 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 }
 EXPORT_SYMBOL(sk_chk_filter);
 
+static int sk_store_orig_filter(struct sk_filter *fp,
+				const struct sock_fprog *fprog)
+{
+	unsigned int fsize = sk_filter_proglen(fprog);
+	struct sock_fprog_kern *fkprog;
+
+	fp->orig_prog = kmalloc(sizeof(*fkprog), GFP_KERNEL);
+	if (!fp->orig_prog)
+		return -ENOMEM;
+
+	fkprog = fp->orig_prog;
+	fkprog->len = fprog->len;
+	fkprog->filter = kmemdup(fp->insns, fsize, GFP_KERNEL);
+	if (!fkprog->filter) {
+		kfree(fp->orig_prog);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void sk_release_orig_filter(struct sk_filter *fp)
+{
+	struct sock_fprog_kern *fprog = fp->orig_prog;
+
+	if (fprog) {
+		kfree(fprog->filter);
+		kfree(fprog);
+	}
+}
+
 /**
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
@@ -637,6 +668,7 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
+	sk_release_orig_filter(fp);
 	bpf_jit_free(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
@@ -669,8 +701,8 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 int sk_unattached_filter_create(struct sk_filter **pfp,
 				struct sock_fprog *fprog)
 {
+	unsigned int fsize = sk_filter_proglen(fprog);
 	struct sk_filter *fp;
-	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
 	int err;
 
 	/* Make sure new filter is there and in the right amounts. */
@@ -680,10 +712,16 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 	fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
+
 	memcpy(fp->insns, fprog->filter, fsize);
 
 	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
+	/* Since unattached filters are not copied back to user
+	 * space through sk_get_filter(), we do not need to hold
+	 * a copy here, and can spare us the work.
+	 */
+	fp->orig_prog = NULL;
 
 	err = __sk_prepare_filter(fp);
 	if (err)
@@ -716,7 +754,7 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
-	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
+	unsigned int fsize = sk_filter_proglen(fprog);
 	unsigned int sk_fsize = sk_filter_size(fprog->len);
 	int err;
 
@@ -730,6 +768,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
+
 	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
 		sock_kfree_s(sk, fp, sk_fsize);
 		return -EFAULT;
@@ -738,6 +777,12 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
 
+	err = sk_store_orig_filter(fp, fprog);
+	if (err) {
+		sk_filter_uncharge(sk, fp);
+		return -ENOMEM;
+	}
+
 	err = __sk_prepare_filter(fp);
 	if (err) {
 		sk_filter_uncharge(sk, fp);
@@ -750,6 +795,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 	if (old_fp)
 		sk_filter_uncharge(sk, old_fp);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
@@ -769,6 +815,7 @@ int sk_detach_filter(struct sock *sk)
 		sk_filter_uncharge(sk, filter);
 		ret = 0;
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
@@ -851,34 +898,41 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 	to->k = filt->k;
 }
 
-int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf, unsigned int len)
+int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
+		  unsigned int len)
 {
+	struct sock_fprog_kern *fprog;
 	struct sk_filter *filter;
-	int i, ret;
+	int ret = 0;
 
 	lock_sock(sk);
 	filter = rcu_dereference_protected(sk->sk_filter,
-			sock_owned_by_user(sk));
-	ret = 0;
+					   sock_owned_by_user(sk));
 	if (!filter)
 		goto out;
-	ret = filter->len;
+
+	/* We're copying the filter that has been originally attached,
+	 * so no conversion/decode needed anymore.
+	 */
+	fprog = filter->orig_prog;
+
+	ret = fprog->len;
 	if (!len)
+		/* User space only enquires number of filter blocks. */
 		goto out;
+
 	ret = -EINVAL;
-	if (len < filter->len)
+	if (len < fprog->len)
 		goto out;
 
 	ret = -EFAULT;
-	for (i = 0; i < filter->len; i++) {
-		struct sock_filter fb;
-
-		sk_decode_filter(&filter->insns[i], &fb);
-		if (copy_to_user(&ubuf[i], &fb, sizeof(fb)))
-			goto out;
-	}
+	if (copy_to_user(ubuf, fprog->filter, sk_filter_proglen(fprog)))
+		goto out;
 
-	ret = filter->len;
+	/* Instead of bytes, the API requests to return the number
+	 * of filter blocks.
+	 */
+	ret = fprog->len;
 out:
 	release_sock(sk);
 	return ret;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a0e9cf6..d7af188 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -52,9 +52,10 @@ EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
-	struct nlattr *attr;
+	struct sock_fprog_kern *fprog;
 	struct sk_filter *filter;
-	unsigned int len;
+	struct nlattr *attr;
+	unsigned int flen;
 	int err = 0;
 
 	if (!ns_capable(user_ns, CAP_NET_ADMIN)) {
@@ -63,24 +64,20 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 	}
 
 	rcu_read_lock();
-
 	filter = rcu_dereference(sk->sk_filter);
-	len = filter ? filter->len * sizeof(struct sock_filter) : 0;
+	if (!filter)
+		goto out;
 
-	attr = nla_reserve(skb, attrtype, len);
+	fprog = filter->orig_prog;
+	flen = sk_filter_proglen(fprog);
+
+	attr = nla_reserve(skb, attrtype, flen);
 	if (attr == NULL) {
 		err = -EMSGSIZE;
 		goto out;
 	}
 
-	if (filter) {
-		struct sock_filter *fb = (struct sock_filter *)nla_data(attr);
-		int i;
-
-		for (i = 0; i < filter->len; i++, fb++)
-			sk_decode_filter(&filter->insns[i], fb);
-	}
-
+	memcpy(nla_data(attr), fprog->filter, flen);
 out:
 	rcu_read_unlock();
 	return err;
-- 
1.7.11.7
