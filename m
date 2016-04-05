From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/3] net: introduce lockdep_is_held and update various places to use it
Date: Tue,  5 Apr 2016 17:10:15 +0200
Message-ID: <1459869016-13896-3-git-send-email-hannes@stressinduktion.org>
References: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Cc: daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:46992 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758776AbcDEPKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:10:24 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id BBA3A21967
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 11:10:23 -0400 (EDT)
In-Reply-To: <1459869016-13896-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The socket is either locked if we hold the slock spin_lock for
lock_sock_fast and unlock_sock_fast or we own the lock (sk_lock.owned
!= 0). Check for this and at the same time improve that the current
thread/cpu is really holding the lock.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h       | 12 ++++++++++--
 net/dccp/ipv4.c          |  2 +-
 net/dccp/ipv6.c          |  2 +-
 net/ipv4/af_inet.c       |  2 +-
 net/ipv4/cipso_ipv4.c    |  3 ++-
 net/ipv4/ip_sockglue.c   |  4 ++--
 net/ipv4/tcp_ipv4.c      |  8 +++-----
 net/ipv6/ipv6_sockglue.c |  6 ++++--
 net/ipv6/tcp_ipv6.c      |  2 +-
 net/socket.c             |  2 +-
 10 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4654ad45e84e7f..57c894ef37bac8 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1356,6 +1356,14 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
+static bool lockdep_sock_is_held(const struct sock *csk)
+{
+	struct sock *sk = (struct sock *)csk;
+
+	return lockdep_is_held(&sk->sk_lock) ||
+	       lockdep_is_held(&sk->sk_lock.slock);
+}
+
 void lock_sock_nested(struct sock *sk, int subclass);
 
 static inline void lock_sock(struct sock *sk)
@@ -1594,8 +1602,8 @@ static inline void sk_rethink_txhash(struct sock *sk)
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
 {
-	return rcu_dereference_check(sk->sk_dst_cache, sock_owned_by_user(sk) ||
-						       lockdep_is_held(&sk->sk_lock.slock));
+	return rcu_dereference_check(sk->sk_dst_cache,
+				     lockdep_sock_is_held(sk));
 }
 
 static inline struct dst_entry *
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 6438c5a7efc411..f6d183f8f33222 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -62,7 +62,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	nexthop = daddr = usin->sin_addr.s_addr;
 
 	inet_opt = rcu_dereference_protected(inet->inet_opt,
-					     sock_owned_by_user(sk));
+					     lockdep_sock_is_held(sk));
 	if (inet_opt != NULL && inet_opt->opt.srr) {
 		if (daddr == 0)
 			return -EINVAL;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 71bf1deba4c5ed..8ceb3cebcad4b6 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -868,7 +868,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl6.fl6_sport = inet->inet_sport;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
-	opt = rcu_dereference_protected(np->opt, sock_owned_by_user(sk));
+	opt = rcu_dereference_protected(np->opt, lockdep_sock_is_held(sk));
 	final_p = fl6_update_dst(&fl6, opt, &final);
 
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9e481992dbaef2..7e37ebb5af396e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1106,7 +1106,7 @@ static int inet_sk_reselect_saddr(struct sock *sk)
 	struct ip_options_rcu *inet_opt;
 
 	inet_opt = rcu_dereference_protected(inet->inet_opt,
-					     sock_owned_by_user(sk));
+					     lockdep_sock_is_held(sk));
 	if (inet_opt && inet_opt->opt.srr)
 		daddr = inet_opt->opt.faddr;
 
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index bdb2a07ec363b7..40d6b87713a132 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -1933,7 +1933,8 @@ int cipso_v4_sock_setattr(struct sock *sk,
 
 	sk_inet = inet_sk(sk);
 
-	old = rcu_dereference_protected(sk_inet->inet_opt, sock_owned_by_user(sk));
+	old = rcu_dereference_protected(sk_inet->inet_opt,
+					lockdep_sock_is_held(sk));
 	if (sk_inet->is_icsk) {
 		sk_conn = inet_csk(sk);
 		if (old)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 1b7c0776c805b5..89b5f3bd669436 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -642,7 +642,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		if (err)
 			break;
 		old = rcu_dereference_protected(inet->inet_opt,
-						sock_owned_by_user(sk));
+						lockdep_sock_is_held(sk));
 		if (inet->is_icsk) {
 			struct inet_connection_sock *icsk = inet_csk(sk);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1302,7 +1302,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		struct ip_options_rcu *inet_opt;
 
 		inet_opt = rcu_dereference_protected(inet->inet_opt,
-						     sock_owned_by_user(sk));
+						     lockdep_sock_is_held(sk));
 		opt->optlen = 0;
 		if (inet_opt)
 			memcpy(optbuf, &inet_opt->opt,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 456ff3d6a13223..f4f2a0a3849d3d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -157,7 +157,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	nexthop = daddr = usin->sin_addr.s_addr;
 	inet_opt = rcu_dereference_protected(inet->inet_opt,
-					     sock_owned_by_user(sk));
+					     lockdep_sock_is_held(sk));
 	if (inet_opt && inet_opt->opt.srr) {
 		if (!daddr)
 			return -EINVAL;
@@ -882,8 +882,7 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 
 	/* caller either holds rcu_read_lock() or socket lock */
 	md5sig = rcu_dereference_check(tp->md5sig_info,
-				       sock_owned_by_user(sk) ||
-				       lockdep_is_held((spinlock_t *)&sk->sk_lock.slock));
+				       lockdep_sock_is_held(sk));
 	if (!md5sig)
 		return NULL;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -928,8 +927,7 @@ int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
 	}
 
 	md5sig = rcu_dereference_protected(tp->md5sig_info,
-					   sock_owned_by_user(sk) ||
-					   lockdep_is_held(&sk->sk_lock.slock));
+					   lockdep_sock_is_held(sk));
 	if (!md5sig) {
 		md5sig = kmalloc(sizeof(*md5sig), gfp);
 		if (!md5sig)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a5557d22f89ea9..4ff4b29894ebfe 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -407,7 +407,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		if (optname != IPV6_RTHDR && !ns_capable(net->user_ns, CAP_NET_RAW))
 			break;
 
-		opt = rcu_dereference_protected(np->opt, sock_owned_by_user(sk));
+		opt = rcu_dereference_protected(np->opt,
+						lockdep_sock_is_held(sk));
 		opt = ipv6_renew_options(sk, opt, optname,
 					 (struct ipv6_opt_hdr __user *)optval,
 					 optlen);
@@ -1124,7 +1125,8 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		struct ipv6_txoptions *opt;
 
 		lock_sock(sk);
-		opt = rcu_dereference_protected(np->opt, sock_owned_by_user(sk));
+		opt = rcu_dereference_protected(np->opt,
+						lockdep_sock_is_held(sk));
 		len = ipv6_getsockopt_sticky(sk, opt, optname, optval, len);
 		release_sock(sk);
 		/* check if ipv6_getsockopt_sticky() returns err code */
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7cde1b6fdda3fc..0e621bc1ae11c8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -234,7 +234,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	fl6.fl6_dport = usin->sin6_port;
 	fl6.fl6_sport = inet->inet_sport;
 
-	opt = rcu_dereference_protected(np->opt, sock_owned_by_user(sk));
+	opt = rcu_dereference_protected(np->opt, lockdep_sock_is_held(sk));
 	final_p = fl6_update_dst(&fl6, opt, &final);
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
diff --git a/net/socket.c b/net/socket.c
index 979d3146b081d7..afa3c347071735 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1046,7 +1046,7 @@ static int sock_fasync(int fd, struct file *filp, int on)
 		return -EINVAL;
 
 	lock_sock(sk);
-	wq = rcu_dereference_protected(sock->wq, sock_owned_by_user(sk));
+	wq = rcu_dereference_protected(sock->wq, lockdep_sock_is_held(sk));
 	fasync_helper(fd, filp, on, &wq->fasync_list);
 
 	if (!wq->fasync_list)
-- 
2.5.5
