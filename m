From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v4 3/9] net: filter: move filter accounting to filter core
Date: Fri, 28 Mar 2014 18:58:20 +0100
Message-ID: <1396029506-16776-4-git-send-email-dborkman@redhat.com>
References: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@parallels.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754076AbaC1R6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 13:58:46 -0400
In-Reply-To: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch basically does two things, i) removes the extern keyword
from the include/linux/filter.h file to be more consistent with the
rest of Joe's changes, and ii) moves filter accounting into the filter
core framework.

Filter accounting mainly done through sk_filter_{un,}charge() take
care of the case when sockets are being cloned through sk_clone_lock()
so that removal of the filter on one socket won't result in eviction
as it's still referenced by the other.

These functions actually belong to net/core/filter.c and not
include/net/sock.h as we want to keep all that in a central place.
It's also not in fast-path so uninlining them is fine and even allows
us to get rd of sk_filter_release_rcu()'s EXPORT_SYMBOL and a forward
declaration.

Joint work with Alexei Starovoitov.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
---
 include/linux/filter.h | 30 +++++++++++++++++-------------
 include/net/sock.h     | 27 ---------------------------
 net/core/filter.c      | 27 +++++++++++++++++++++++++--
 3 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 93a9792..9bde3ed 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -50,28 +50,32 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 #define sk_filter_proglen(fprog)			\
 		(fprog->len * sizeof(fprog->filter[0]))
 
-extern int sk_filter(struct sock *sk, struct sk_buff *skb);
-extern unsigned int sk_run_filter(const struct sk_buff *skb,
-				  const struct sock_filter *filter);
+int sk_filter(struct sock *sk, struct sk_buff *skb);
+unsigned int sk_run_filter(const struct sk_buff *skb,
+			   const struct sock_filter *filter);
 
-extern int sk_unattached_filter_create(struct sk_filter **pfp,
-				       struct sock_fprog *fprog);
-extern void sk_unattached_filter_destroy(struct sk_filter *fp);
+int sk_unattached_filter_create(struct sk_filter **pfp,
+				struct sock_fprog *fprog);
+void sk_unattached_filter_destroy(struct sk_filter *fp);
 
-extern int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
-extern int sk_detach_filter(struct sock *sk);
+int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+int sk_detach_filter(struct sock *sk);
 
-extern int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
-extern int sk_get_filter(struct sock *sk, struct sock_filter __user *filter, unsigned len);
-extern void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
+int sk_chk_filter(struct sock_filter *filter, unsigned int flen);
+int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
+		  unsigned int len);
+void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to);
+
+void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
+void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
 #include <linux/printk.h>
 
-extern void bpf_jit_compile(struct sk_filter *fp);
-extern void bpf_jit_free(struct sk_filter *fp);
+void bpf_jit_compile(struct sk_filter *fp);
+void bpf_jit_free(struct sk_filter *fp);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
diff --git a/include/net/sock.h b/include/net/sock.h
index 8d7c431..06a5668 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1621,33 +1621,6 @@ void sk_common_release(struct sock *sk);
 /* Initialise core socket variables */
 void sock_init_data(struct socket *sock, struct sock *sk);
 
-void sk_filter_release_rcu(struct rcu_head *rcu);
-
-/**
- *	sk_filter_release - release a socket filter
- *	@fp: filter to remove
- *
- *	Remove a filter from a socket and release its resources.
- */
-
-static inline void sk_filter_release(struct sk_filter *fp)
-{
-	if (atomic_dec_and_test(&fp->refcnt))
-		call_rcu(&fp->rcu, sk_filter_release_rcu);
-}
-
-static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
-{
-	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
-	sk_filter_release(fp);
-}
-
-static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
-{
-	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
-}
-
 /*
  * Socket reference counting postulates.
  *
diff --git a/net/core/filter.c b/net/core/filter.c
index 9730e7f..5b3427a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -664,14 +664,37 @@ static void sk_release_orig_filter(struct sk_filter *fp)
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
  */
-void sk_filter_release_rcu(struct rcu_head *rcu)
+static void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
 	sk_release_orig_filter(fp);
 	bpf_jit_free(fp);
 }
-EXPORT_SYMBOL(sk_filter_release_rcu);
+
+/**
+ *	sk_filter_release - release a socket filter
+ *	@fp: filter to remove
+ *
+ *	Remove a filter from a socket and release its resources.
+ */
+static void sk_filter_release(struct sk_filter *fp)
+{
+	if (atomic_dec_and_test(&fp->refcnt))
+		call_rcu(&fp->rcu, sk_filter_release_rcu);
+}
+
+void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
+{
+	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	sk_filter_release(fp);
+}
+
+void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
+{
+	atomic_inc(&fp->refcnt);
+	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+}
 
 static int __sk_prepare_filter(struct sk_filter *fp)
 {
-- 
1.7.11.7
