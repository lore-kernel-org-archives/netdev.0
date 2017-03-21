From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH net-next] net: convert sk_filter.refcnt from atomic_t to refcount_t
Date: Tue, 21 Mar 2017 13:59:19 +0200
Message-ID: <1490097559-16259-1-git-send-email-elena.reshetova@intel.com>
Cc: ast@fb.com, linux-kernel@vger.kernel.org, peterz@infradead.org,
        netdev@vger.kernel.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        David Windsor <dwindsor@gmail.com>
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h |  3 ++-
 net/core/filter.c      | 17 ++++++++++++-----
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8053c38..20247e7 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -7,6 +7,7 @@
 #include <stdarg.h>
 
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 #include <linux/compat.h>
 #include <linux/skbuff.h>
 #include <linux/linkage.h>
@@ -431,7 +432,7 @@ struct bpf_prog {
 };
 
 struct sk_filter {
-	atomic_t	refcnt;
+	refcount_t	refcnt;
 	struct rcu_head	rcu;
 	struct bpf_prog	*prog;
 };
diff --git a/net/core/filter.c b/net/core/filter.c
index ebaeaf2..c7f0ccd 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -928,7 +928,7 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
  */
 static void sk_filter_release(struct sk_filter *fp)
 {
-	if (atomic_dec_and_test(&fp->refcnt))
+	if (refcount_dec_and_test(&fp->refcnt))
 		call_rcu(&fp->rcu, sk_filter_release_rcu);
 }
 
@@ -943,20 +943,27 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 /* try to charge the socket memory if there is space available
  * return true on success
  */
-bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
+static bool __sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
 	u32 filter_size = bpf_prog_size(fp->prog->len);
 
 	/* same check as in sock_kmalloc() */
 	if (filter_size <= sysctl_optmem_max &&
 	    atomic_read(&sk->sk_omem_alloc) + filter_size < sysctl_optmem_max) {
-		atomic_inc(&fp->refcnt);
 		atomic_add(filter_size, &sk->sk_omem_alloc);
 		return true;
 	}
 	return false;
 }
 
+bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
+{
+	bool ret = __sk_filter_charge(sk, fp);
+	if (ret)
+		refcount_inc(&fp->refcnt);
+	return ret;
+}
+
 static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
 {
 	struct sock_filter *old_prog;
@@ -1179,12 +1186,12 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 		return -ENOMEM;
 
 	fp->prog = prog;
-	atomic_set(&fp->refcnt, 0);
 
-	if (!sk_filter_charge(sk, fp)) {
+	if (!__sk_filter_charge(sk, fp)) {
 		kfree(fp);
 		return -ENOMEM;
 	}
+	refcount_set(&fp->refcnt, 1);
 
 	old_fp = rcu_dereference_protected(sk->sk_filter,
 					   lockdep_sock_is_held(sk));
-- 
2.7.4
