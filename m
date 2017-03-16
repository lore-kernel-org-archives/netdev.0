From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/17] net: convert sk_filter.refcnt from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:28:58 +0200
Message-ID: <1489678147-21404-9-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
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
---
 include/linux/filter.h | 3 ++-
 net/core/filter.c      | 7 ++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

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
index ebaeaf2..62267e2 100644
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
 
@@ -950,7 +950,7 @@ bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 	/* same check as in sock_kmalloc() */
 	if (filter_size <= sysctl_optmem_max &&
 	    atomic_read(&sk->sk_omem_alloc) + filter_size < sysctl_optmem_max) {
-		atomic_inc(&fp->refcnt);
+		refcount_inc(&fp->refcnt);
 		atomic_add(filter_size, &sk->sk_omem_alloc);
 		return true;
 	}
@@ -1179,12 +1179,13 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 		return -ENOMEM;
 
 	fp->prog = prog;
-	atomic_set(&fp->refcnt, 0);
+	refcount_set(&fp->refcnt, 1);
 
 	if (!sk_filter_charge(sk, fp)) {
 		kfree(fp);
 		return -ENOMEM;
 	}
+	refcount_set(&fp->refcnt, 1);
 
 	old_fp = rcu_dereference_protected(sk->sk_filter,
 					   lockdep_sock_is_held(sk));
-- 
2.7.4
