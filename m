From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: remove one indirection level in
 tcp_md5sig_pool
Date: Tue, 13 Sep 2011 08:28:37 +0200
Message-ID: <1315895317.2556.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55652 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559Ab1IMG2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 02:28:44 -0400
Received: by wyh22 with SMTP id 22so192197wyh.19
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2011 23:28:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_md5sig_pool is currently an 'array' (a percpu object) of pointers to
struct tcp_md5sig_pool. Only the pointers are NUMA aware, but objects
themselves are all allocated on a single node.

Remove this extra indirection to get proper percpu memory (NUMA aware)
and make code simpler.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Note: crypto_alloc_hash() is still not NUMA aware...

 include/net/tcp.h |    2 +-
 net/ipv4/tcp.c    |   41 +++++++++++++++++------------------------
 2 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..d6ca000 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1180,7 +1180,7 @@ extern int tcp_v4_md5_do_del(struct sock *sk, __be32 addr);
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
 
-extern struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct sock *);
+extern struct tcp_md5sig_pool __percpu *tcp_alloc_md5sig_pool(struct sock *);
 extern void tcp_free_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 46febca..6508115 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2857,26 +2857,25 @@ EXPORT_SYMBOL(tcp_gro_complete);
 
 #ifdef CONFIG_TCP_MD5SIG
 static unsigned long tcp_md5sig_users;
-static struct tcp_md5sig_pool * __percpu *tcp_md5sig_pool;
+static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool;
 static DEFINE_SPINLOCK(tcp_md5sig_pool_lock);
 
-static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool * __percpu *pool)
+static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
 {
 	int cpu;
+
 	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p = *per_cpu_ptr(pool, cpu);
-		if (p) {
-			if (p->md5_desc.tfm)
-				crypto_free_hash(p->md5_desc.tfm);
-			kfree(p);
-		}
+		struct tcp_md5sig_pool *p = per_cpu_ptr(pool, cpu);
+
+		if (p->md5_desc.tfm)
+			crypto_free_hash(p->md5_desc.tfm);
 	}
 	free_percpu(pool);
 }
 
 void tcp_free_md5sig_pool(void)
 {
-	struct tcp_md5sig_pool * __percpu *pool = NULL;
+	struct tcp_md5sig_pool __percpu *pool = NULL;
 
 	spin_lock_bh(&tcp_md5sig_pool_lock);
 	if (--tcp_md5sig_users == 0) {
@@ -2889,30 +2888,24 @@ void tcp_free_md5sig_pool(void)
 }
 EXPORT_SYMBOL(tcp_free_md5sig_pool);
 
-static struct tcp_md5sig_pool * __percpu *
+static struct tcp_md5sig_pool __percpu *
 __tcp_alloc_md5sig_pool(struct sock *sk)
 {
 	int cpu;
-	struct tcp_md5sig_pool * __percpu *pool;
+	struct tcp_md5sig_pool __percpu *pool;
 
-	pool = alloc_percpu(struct tcp_md5sig_pool *);
+	pool = alloc_percpu(struct tcp_md5sig_pool);
 	if (!pool)
 		return NULL;
 
 	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p;
 		struct crypto_hash *hash;
 
-		p = kzalloc(sizeof(*p), sk->sk_allocation);
-		if (!p)
-			goto out_free;
-		*per_cpu_ptr(pool, cpu) = p;
-
 		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
 		if (!hash || IS_ERR(hash))
 			goto out_free;
 
-		p->md5_desc.tfm = hash;
+		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
 	}
 	return pool;
 out_free:
@@ -2920,9 +2913,9 @@ out_free:
 	return NULL;
 }
 
-struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct sock *sk)
+struct tcp_md5sig_pool __percpu *tcp_alloc_md5sig_pool(struct sock *sk)
 {
-	struct tcp_md5sig_pool * __percpu *pool;
+	struct tcp_md5sig_pool __percpu *pool;
 	int alloc = 0;
 
 retry:
@@ -2941,7 +2934,7 @@ retry:
 
 	if (alloc) {
 		/* we cannot hold spinlock here because this may sleep. */
-		struct tcp_md5sig_pool * __percpu *p;
+		struct tcp_md5sig_pool __percpu *p;
 
 		p = __tcp_alloc_md5sig_pool(sk);
 		spin_lock_bh(&tcp_md5sig_pool_lock);
@@ -2974,7 +2967,7 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
  */
 struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 {
-	struct tcp_md5sig_pool * __percpu *p;
+	struct tcp_md5sig_pool __percpu *p;
 
 	local_bh_disable();
 
@@ -2985,7 +2978,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 	spin_unlock(&tcp_md5sig_pool_lock);
 
 	if (p)
-		return *this_cpu_ptr(p);
+		return this_cpu_ptr(p);
 
 	local_bh_enable();
 	return NULL;
