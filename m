From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 1/6] filter: refactor BPF JIT for seccomp filters
Date: Fri, 26 Apr 2013 03:51:41 -0400
Message-ID: <1366962706-24204-2-git-send-email-xi.wang@gmail.com>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, bpf_jit_compile() and bpf_jit_free() takes an sk_filter,
which seccomp filters cannot reuse.

Change bpf_jit_compile() to take a pointer to BPF instructions and
the length, and to return a JITted function.

Change bpf_jit_free() to take a JITted function.

Add JIT calls for seccomp filters.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 include/linux/filter.h | 16 ++++++++++------
 kernel/seccomp.c       |  6 +++++-
 net/core/filter.c      |  6 ++----
 3 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d1248f4..8743093 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -21,12 +21,14 @@ struct compat_sock_fprog {
 struct sk_buff;
 struct sock;
 
+typedef unsigned int (*bpf_func_t)(const struct sk_buff *skb,
+				   const struct sock_filter *filter);
+
 struct sk_filter
 {
 	atomic_t		refcnt;
 	unsigned int         	len;	/* Number of filter blocks */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct sock_filter *filter);
+	bpf_func_t		bpf_func;
 	struct rcu_head		rcu;
 	struct sock_filter     	insns[0];
 };
@@ -48,11 +50,12 @@ extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
 extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
 
 #ifdef CONFIG_BPF_JIT
+#include <stdarg.h>
 #include <linux/linkage.h>
 #include <linux/printk.h>
 
-extern void bpf_jit_compile(struct sk_filter *fp);
-extern void bpf_jit_free(struct sk_filter *fp);
+extern bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen);
+extern void bpf_jit_free(bpf_func_t bpf_func);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
@@ -65,10 +68,11 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 }
 #define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER->insns)
 #else
-static inline void bpf_jit_compile(struct sk_filter *fp)
+static inline bpf_func_t bpf_jit_compile(struct sock_filter *filter, unsigned int flen)
 {
+	return sk_run_filter;
 }
-static inline void bpf_jit_free(struct sk_filter *fp)
+static inline void bpf_jit_free(bpf_func_t bpf_func)
 {
 }
 #define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insns)
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5af44b5..f784feb 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -55,6 +55,7 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	unsigned short len;  /* Instruction count */
+	bpf_func_t bpf_func;
 	struct sock_filter insns[];
 };
 
@@ -211,7 +212,7 @@ static u32 seccomp_run_filters(int syscall)
 	 * value always takes priority (ignoring the DATA).
 	 */
 	for (f = current->seccomp.filter; f; f = f->prev) {
-		u32 cur_ret = sk_run_filter(NULL, f->insns);
+		u32 cur_ret = SK_RUN_FILTER(f, NULL);
 		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
 	}
@@ -273,6 +274,8 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	if (ret)
 		goto fail;
 
+	filter->bpf_func = bpf_jit_compile(filter->insns, filter->len);
+
 	/*
 	 * If there is an existing filter, make it the prev and don't drop its
 	 * task reference.
@@ -330,6 +333,7 @@ void put_seccomp_filter(struct task_struct *tsk)
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
 		orig = orig->prev;
+		bpf_jit_free(freeme->bpf_func);
 		kfree(freeme);
 	}
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index dad2a17..0a7900b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -643,7 +643,7 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
-	bpf_jit_free(fp);
+	bpf_jit_free(fp->bpf_func);
 	kfree(fp);
 }
 EXPORT_SYMBOL(sk_filter_release_rcu);
@@ -652,13 +652,11 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 {
 	int err;
 
-	fp->bpf_func = sk_run_filter;
-
 	err = sk_chk_filter(fp->insns, fp->len);
 	if (err)
 		return err;
 
-	bpf_jit_compile(fp);
+	fp->bpf_func = bpf_jit_compile(fp->insns, fp->len);
 	return 0;
 }
 
-- 
1.8.1.2
