From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/17] tcp: md5: constify tcp_md5_do_lookup() socket argument
Date: Fri, 25 Sep 2015 07:39:15 -0700
Message-ID: <1443191964-923-9-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33704 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380AbbIYOkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:10 -0400
Received: by pacex6 with SMTP id ex6so107616667pac.0
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:09 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TCP new listener is done, these functions will be called
without socket lock being held. Make sure they don't change
anything.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   | 10 +++++-----
 net/ipv4/tcp_ipv4.c |  6 +++---
 net/ipv6/tcp_ipv6.c |  4 ++--
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a89ec41fa3d9..70aea203545e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1372,16 +1372,16 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp);
 int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
 		   int family);
-struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
 					 const struct sock *addr_sk);
 
 #ifdef CONFIG_TCP_MD5SIG
-struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family);
 #define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_key)
 #else
-static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+static inline struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family)
 {
@@ -1684,7 +1684,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 /* TCP af-specific functions */
 struct tcp_sock_af_ops {
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*(*md5_lookup) (struct sock *sk,
+	struct tcp_md5sig_key	*(*md5_lookup) (const struct sock *sk,
 						const struct sock *addr_sk);
 	int		(*calc_md5_hash)(char *location,
 					 const struct tcp_md5sig_key *md5,
@@ -1699,7 +1699,7 @@ struct tcp_sock_af_ops {
 struct tcp_request_sock_ops {
 	u16 mss_clamp;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *(*req_md5_lookup)(struct sock *sk,
+	struct tcp_md5sig_key *(*req_md5_lookup)(const struct sock *sk,
 						 const struct sock *addr_sk);
 	int		(*calc_md5_hash) (char *location,
 					  const struct tcp_md5sig_key *md5,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9d968ca7b669..1c1009d783f5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -865,7 +865,7 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
  */
 
 /* Find the Key structure for an address.  */
-struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 					 const union tcp_md5_addr *addr,
 					 int family)
 {
@@ -877,7 +877,7 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 	/* caller either holds rcu_read_lock() or socket lock */
 	md5sig = rcu_dereference_check(tp->md5sig_info,
 				       sock_owned_by_user(sk) ||
-				       lockdep_is_held(&sk->sk_lock.slock));
+				       lockdep_is_held((spinlock_t *)&sk->sk_lock.slock));
 	if (!md5sig)
 		return NULL;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -894,7 +894,7 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 }
 EXPORT_SYMBOL(tcp_md5_do_lookup);
 
-struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
+struct tcp_md5sig_key *tcp_v4_md5_lookup(const struct sock *sk,
 					 const struct sock *addr_sk)
 {
 	const union tcp_md5_addr *addr;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9016797445a2..1071131a6c53 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -476,13 +476,13 @@ static void tcp_v6_reqsk_destructor(struct request_sock *req)
 }
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(const struct sock *sk,
 						   const struct in6_addr *addr)
 {
 	return tcp_md5_do_lookup(sk, (union tcp_md5_addr *)addr, AF_INET6);
 }
 
-static struct tcp_md5sig_key *tcp_v6_md5_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_lookup(const struct sock *sk,
 						const struct sock *addr_sk)
 {
 	return tcp_v6_md5_do_lookup(sk, &addr_sk->sk_v6_daddr);
-- 
2.6.0.rc2.230.g3dd15c0
