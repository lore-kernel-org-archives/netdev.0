From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] net: introduce support for lazy initialization of secret keys
Date: Wed, 25 Sep 2013 23:34:03 +0200
Message-ID: <20130925213403.GF4904@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fw@strlen.de, edumazet@google.com, davem@davemloft.net,
	ycheng@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51244 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab3IYVeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 17:34:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_get_random_once is a new macro which handles the initialization of
secret keys at use-site. It is possible to call it in the fast path. Only
the initialization depends on the spinlock and is rather slow. Otherwise
it should get used just before the key is used to delay the entropy
extration as late as possible to get better randomness. It returns true
if the key got initialized.

This patch splits the secret key for syncookies between ipv4 and ipv6
and initializes them with net_get_random_once. This change was the reason
I did this patch. I think the initialization of the syncookie_secret is
way to early.

Changed key initialization of tcp_fastopen cookies to net_get_random_once.

Also initialize the secret keys for tcp connection hashing via
net_get_random_once.

Cc: Florian Westphal <fw@strlen.de>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Please review carefully, especially the concurrency bits
(I also did not test the fastopen changes, yet).

I left net_get_random_once non-irq-safe because I hope I can spice up
__net_get_random_once with get_random_bytes_busy_wait_initialized later on as
soon as I get more feedback on that patch.

This patch depends on Eric Dumazet's patch: "net: net_secret should not depend on TCP"
(currently in patchwork)

Also, would it make sense to switch to static_keys in the net_get_random_once
macro?

 include/linux/net.h        | 17 +++++++++++++++++
 include/net/tcp.h          |  3 +--
 net/core/secure_seq.c      | 14 ++------------
 net/core/utils.c           | 16 ++++++++++++++++
 net/ipv4/af_inet.c         | 10 ++--------
 net/ipv4/syncookies.c      | 16 ++++++----------
 net/ipv4/sysctl_net_ipv4.c |  5 +++++
 net/ipv4/tcp_fastopen.c    | 21 ++++++++++-----------
 net/ipv6/syncookies.c      | 10 ++++++++--
 9 files changed, 67 insertions(+), 45 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4f27575..2bfb8ca 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -243,6 +243,23 @@ do {								\
 #define net_random()		prandom_u32()
 #define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
+bool __net_get_random_once(void *buf, int nbytes, bool *done,
+			   spinlock_t *lock);
+
+/* BE CAREFUL: this function is not interrupt safe */
+#define net_get_random_once(buf, nbytes)				\
+	({								\
+		static DEFINE_SPINLOCK(__lock);				\
+		static bool __done = false;				\
+		bool __ret = false;					\
+		if (unlikely(!__done))					\
+			__ret = __net_get_random_once(buf,		\
+						    nbytes,		\
+						    &__done,		\
+						    &__lock);		\
+		__ret;							\
+	})
+
 extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 				    struct kvec *vec, size_t num, size_t len);
 extern int   	     kernel_recvmsg(struct socket *sock, struct msghdr *msg,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index de870ee..2a26100 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -475,7 +475,6 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
-extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
@@ -1323,7 +1322,7 @@ extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
 void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 			     struct tcp_fastopen_cookie *foc);
-
+void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
 /* Fastopen key context */
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3f1ec15..b02fd16 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -7,6 +7,7 @@
 #include <linux/hrtimer.h>
 #include <linux/ktime.h>
 #include <linux/string.h>
+#include <linux/net.h>
 
 #include <net/secure_seq.h>
 
@@ -16,18 +17,7 @@ static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
 
 static void net_secret_init(void)
 {
-	u32 tmp;
-	int i;
-
-	if (likely(net_secret[0]))
-		return;
-
-	for (i = NET_SECRET_SIZE; i > 0;) {
-		do {
-			get_random_bytes(&tmp, sizeof(tmp));
-		} while (!tmp);
-		cmpxchg(&net_secret[--i], 0, tmp);
-	}
+	net_get_random_once(net_secret, sizeof(net_secret));
 }
 
 #ifdef CONFIG_INET
diff --git a/net/core/utils.c b/net/core/utils.c
index aa88e23..f2fa223 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -338,3 +338,19 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 				  csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
+
+bool __net_get_random_once(void *buf, int nbytes, bool *done,
+			    spinlock_t *lock)
+{
+	spin_lock_bh(lock);
+	if (*done) {
+		spin_unlock_bh(lock);
+		return false;
+	}
+
+	get_random_bytes(buf, nbytes);
+	*done = true;
+	spin_unlock_bh(lock);
+	return true;
+}
+EXPORT_SYMBOL(__net_get_random_once);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cfeb85c..1abd8c8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -257,14 +257,8 @@ EXPORT_SYMBOL(ipv6_hash_secret);
  */
 void build_ehash_secret(void)
 {
-	u32 rnd;
-
-	do {
-		get_random_bytes(&rnd, sizeof(rnd));
-	} while (rnd == 0);
-
-	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
-		get_random_bytes(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
+	net_get_random_once(&inet_ehash_secret, sizeof(inet_ehash_secret));
+	net_get_random_once(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 15e0241..af79b84 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -25,15 +25,7 @@
 
 extern int sysctl_tcp_syncookies;
 
-__u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
-EXPORT_SYMBOL(syncookie_secret);
-
-static __init int init_syncookies(void)
-{
-	get_random_bytes(syncookie_secret, sizeof(syncookie_secret));
-	return 0;
-}
-__initcall(init_syncookies);
+static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
@@ -44,7 +36,11 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
+	__u32 *tmp;
+
+	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));
+
+	tmp = __get_cpu_var(ipv4_cookie_scratch);
 
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 540279f..d2b5140 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -267,6 +267,11 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
+		/* Generate a dummy secret but don't publish it. This
+		 * is needed so we don't regenerate a new key on the
+		 * first invocation of tcp_fastopen_cookie_gen
+		 */
+		tcp_fastopen_init_key_once(false);
 		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index ab7bd35..2240103 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -14,6 +14,14 @@ struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
 
+void tcp_fastopen_init_key_once(bool publish)
+{
+	static __u8 key[TCP_FASTOPEN_KEY_LENGTH];
+
+	if (net_get_random_once(key, sizeof(key)) && publish)
+		tcp_fastopen_reset_cipher(key, sizeof(key));
+}
+
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
 {
 	struct tcp_fastopen_context *ctx =
@@ -70,6 +78,8 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	__be32 path[4] = { src, dst, 0, 0 };
 	struct tcp_fastopen_context *ctx;
 
+	tcp_fastopen_init_key_once(true);
+
 	rcu_read_lock();
 	ctx = rcu_dereference(tcp_fastopen_ctx);
 	if (ctx) {
@@ -78,14 +88,3 @@ void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
 	}
 	rcu_read_unlock();
 }
-
-static int __init tcp_fastopen_init(void)
-{
-	__u8 key[TCP_FASTOPEN_KEY_LENGTH];
-
-	get_random_bytes(key, sizeof(key));
-	tcp_fastopen_reset_cipher(key, sizeof(key));
-	return 0;
-}
-
-late_initcall(tcp_fastopen_init);
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index d703218..a454cef 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -21,6 +21,8 @@
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
+static u32 syncookie6_secret[2][16-4+SHA_DIGEST_WORDS];
+
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
@@ -61,14 +63,18 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
+	__u32 *tmp;
+
+	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));
+
+	tmp = __get_cpu_var(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
 	 * 192 bits required for sha_transform, from the syncookie_secret
 	 * and overwrite the digest with the secret
 	 */
-	memcpy(tmp + 10, syncookie_secret[c], 44);
+	memcpy(tmp + 10, syncookie6_secret[c], 44);
 	memcpy(tmp, saddr, 16);
 	memcpy(tmp + 4, daddr, 16);
 	tmp[8] = ((__force u32)sport << 16) + (__force u32)dport;
-- 
1.8.3.1
