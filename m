From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 1/5] net: filter: simplify socket charging
Date: Wed, 30 Jul 2014 20:34:12 -0700
Message-ID: <1406777656-27755-2-git-send-email-ast@plumgrid.com>
References: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406777656-27755-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attaching bpf program to a socket involves multiple socket memory arithmetic,
since size of 'sk_filter' is changing when classic BPF is converted to eBPF.
Also common path of program creation has to deal with two ways of freeing
the memory.

Simplify the code by delaying socket charging until program is ready and
its size is known

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h |    2 +-
 net/core/filter.c      |   87 ++++++++++++++++++++----------------------------
 net/core/sock.c        |    9 +++--
 3 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 20dd50ef7271..00640edc166f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -366,7 +366,7 @@ int sk_chk_filter(const struct sock_filter *filter, unsigned int flen);
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
+bool sk_filter_charge(struct sock *sk, struct sk_filter *fp);
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
diff --git a/net/core/filter.c b/net/core/filter.c
index 42c1944b0c63..5a6aeb1d40b8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -872,41 +872,30 @@ static void sk_filter_release(struct sk_filter *fp)
 
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
-	sk_filter_release(fp);
-}
+	u32 filter_size = sk_filter_size(fp->len);
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
-{
-	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	atomic_sub(filter_size, &sk->sk_omem_alloc);
+	sk_filter_release(fp);
 }
 
-static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
-					      struct sock *sk,
-					      unsigned int len)
+/* try to charge the socket memory if there is space available
+ * return true on success
+ */
+bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
-	struct sk_filter *fp_new;
-
-	if (sk == NULL)
-		return krealloc(fp, len, GFP_KERNEL);
-
-	fp_new = sock_kmalloc(sk, len, GFP_KERNEL);
-	if (fp_new) {
-		*fp_new = *fp;
-		/* As we're keeping orig_prog in fp_new along,
-		 * we need to make sure we're not evicting it
-		 * from the old fp.
-		 */
-		fp->orig_prog = NULL;
-		sk_filter_uncharge(sk, fp);
+	u32 filter_size = sk_filter_size(fp->len);
+
+	/* same check as in sock_kmalloc() */
+	if (filter_size <= sysctl_optmem_max &&
+	    atomic_read(&sk->sk_omem_alloc) + filter_size < sysctl_optmem_max) {
+		atomic_inc(&fp->refcnt);
+		atomic_add(filter_size, &sk->sk_omem_alloc);
+		return true;
 	}
-
-	return fp_new;
+	return false;
 }
 
-static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp)
 {
 	struct sock_filter *old_prog;
 	struct sk_filter *old_fp;
@@ -938,7 +927,7 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 
 	/* Expand fp for appending the new filter representation. */
 	old_fp = fp;
-	fp = __sk_migrate_realloc(old_fp, sk, sk_filter_size(new_len));
+	fp = krealloc(old_fp, sk_filter_size(new_len), GFP_KERNEL);
 	if (!fp) {
 		/* The old_fp is still around in case we couldn't
 		 * allocate new memory, so uncharge on that one.
@@ -956,7 +945,7 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 		/* 2nd sk_convert_filter() can fail only if it fails
 		 * to allocate memory, remapping must succeed. Note,
 		 * that at this time old_fp has already been released
-		 * by __sk_migrate_realloc().
+		 * by krealloc().
 		 */
 		goto out_err_free;
 
@@ -968,16 +957,11 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 out_err_free:
 	kfree(old_prog);
 out_err:
-	/* Rollback filter setup. */
-	if (sk != NULL)
-		sk_filter_uncharge(sk, fp);
-	else
-		kfree(fp);
+	__sk_filter_release(fp);
 	return ERR_PTR(err);
 }
 
-static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp)
 {
 	int err;
 
@@ -986,10 +970,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err) {
-		if (sk != NULL)
-			sk_filter_uncharge(sk, fp);
-		else
-			kfree(fp);
+		__sk_filter_release(fp);
 		return ERR_PTR(err);
 	}
 
@@ -1002,7 +983,7 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 	 * internal BPF translation for the optimized interpreter.
 	 */
 	if (!fp->jited)
-		fp = __sk_migrate_filter(fp, sk);
+		fp = __sk_migrate_filter(fp);
 
 	return fp;
 }
@@ -1041,10 +1022,10 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 	 */
 	fp->orig_prog = NULL;
 
-	/* __sk_prepare_filter() already takes care of uncharging
+	/* __sk_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	fp = __sk_prepare_filter(fp, NULL);
+	fp = __sk_prepare_filter(fp);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
@@ -1083,31 +1064,37 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (fprog->filter == NULL)
 		return -EINVAL;
 
-	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
+	fp = kmalloc(sk_fsize, GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
 
 	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
-		sock_kfree_s(sk, fp, sk_fsize);
+		kfree(fp);
 		return -EFAULT;
 	}
 
-	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
 
 	err = sk_store_orig_filter(fp, fprog);
 	if (err) {
-		sk_filter_uncharge(sk, fp);
+		kfree(fp);
 		return -ENOMEM;
 	}
 
-	/* __sk_prepare_filter() already takes care of uncharging
+	/* __sk_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	fp = __sk_prepare_filter(fp, sk);
+	fp = __sk_prepare_filter(fp);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
+	atomic_set(&fp->refcnt, 0);
+
+	if (!sk_filter_charge(sk, fp)) {
+		__sk_filter_release(fp);
+		return -ENOMEM;
+	}
+
 	old_fp = rcu_dereference_protected(sk->sk_filter,
 					   sock_owned_by_user(sk));
 	rcu_assign_pointer(sk->sk_filter, fp);
diff --git a/net/core/sock.c b/net/core/sock.c
index 134291d73fcd..a741163568fa 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1474,6 +1474,7 @@ static void sk_update_clone(const struct sock *sk, struct sock *newsk)
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 {
 	struct sock *newsk;
+	bool is_charged = true;
 
 	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
 	if (newsk != NULL) {
@@ -1518,9 +1519,13 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 		filter = rcu_dereference_protected(newsk->sk_filter, 1);
 		if (filter != NULL)
-			sk_filter_charge(newsk, filter);
+			/* though it's an empty new sock, the charging may fail
+			 * if sysctl_optmem_max was changed between creation of
+			 * original socket and cloning
+			 */
+			is_charged = sk_filter_charge(newsk, filter);
 
-		if (unlikely(xfrm_sk_clone_policy(newsk))) {
+		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk))) {
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */
 			newsk->sk_destruct = NULL;
-- 
1.7.9.5
