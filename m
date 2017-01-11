From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 2/6 net-next] inet: drop ->bind_conflict
Date: Wed, 11 Jan 2017 15:22:40 -0500
Message-ID: <1484166164-21250-1-git-send-email-jbacik@fb.com>
References: <1484165171-19210-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55128 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934259AbdAKUXA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:23:00 -0500
In-Reply-To: <1484165171-19210-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only difference between inet6_csk_bind_conflict and inet_csk_bind_conflict
is how they check the rcv_saddr, so delete this call back and simply
change inet_csk_bind_conflict to call inet_rcv_saddr_equal.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/inet6_connection_sock.h |  5 -----
 include/net/inet_connection_sock.h  |  6 ------
 net/dccp/ipv4.c                     |  2 +-
 net/dccp/ipv6.c                     |  2 --
 net/ipv4/inet_connection_sock.c     | 22 +++++++-------------
 net/ipv4/tcp_ipv4.c                 |  2 +-
 net/ipv6/inet6_connection_sock.c    | 40 -------------------------------------
 net/ipv6/tcp_ipv6.c                 |  2 --
 8 files changed, 9 insertions(+), 72 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 3212b39..8ec87b6 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -15,16 +15,11 @@
 
 #include <linux/types.h>
 
-struct inet_bind_bucket;
 struct request_sock;
 struct sk_buff;
 struct sock;
 struct sockaddr;
 
-int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb, bool relax,
-			    bool soreuseport_ok);
-
 struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req, u8 proto);
 
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 85ee387..add75c7 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -62,9 +62,6 @@ struct inet_connection_sock_af_ops {
 				char __user *optval, int __user *optlen);
 #endif
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
-	int	    (*bind_conflict)(const struct sock *sk,
-				     const struct inet_bind_bucket *tb,
-				     bool relax, bool soreuseport_ok);
 	void	    (*mtu_reduced)(struct sock *sk);
 };
 
@@ -261,9 +258,6 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
-int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb, bool relax,
-			   bool soreuseport_ok);
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 struct dst_entry *inet_csk_route_req(const struct sock *sk, struct flowi4 *fl4,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d859a5c..ed6f99b 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/random.h>
 
+#include <net/addrconf.h>
 #include <net/icmp.h>
 #include <net/inet_common.h>
 #include <net/inet_hashtables.h>
@@ -904,7 +905,6 @@ static const struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
 	.getsockopt	   = ip_getsockopt,
 	.addr2sockaddr	   = inet_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
-	.bind_conflict	   = inet_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ip_setsockopt,
 	.compat_getsockopt = compat_ip_getsockopt,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index adfc790..08bcdc3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -937,7 +937,6 @@ static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
@@ -958,7 +957,6 @@ static const struct inet_connection_sock_af_ops dccp_ipv6_mapped = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ba597cb..a1c9055 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -116,9 +116,9 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
-int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb, bool relax,
-			   bool reuseport_ok)
+static int inet_csk_bind_conflict(const struct sock *sk,
+				  const struct inet_bind_bucket *tb,
+				  bool relax, bool reuseport_ok)
 {
 	struct sock *sk2;
 	bool reuse = sk->sk_reuse;
@@ -134,7 +134,6 @@ int inet_csk_bind_conflict(const struct sock *sk,
 
 	sk_for_each_bound(sk2, &tb->owners) {
 		if (sk != sk2 &&
-		    !inet_v6_ipv6only(sk2) &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
@@ -144,23 +143,18 @@ int inet_csk_bind_conflict(const struct sock *sk,
 			     rcu_access_pointer(sk->sk_reuseport_cb) ||
 			     (sk2->sk_state != TCP_TIME_WAIT &&
 			     !uid_eq(uid, sock_i_uid(sk2))))) {
-
-				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
-				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
+				if (inet_rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 			if (!relax && reuse && sk2->sk_reuse &&
 			    sk2->sk_state != TCP_LISTEN) {
-
-				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
-				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
+				if (inet_rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 		}
 	}
 	return sk2 != NULL;
 }
-EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
@@ -239,8 +233,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 					smallest_size = tb->num_owners;
 					smallest_port = port;
 				}
-				if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false,
-									      reuseport_ok))
+				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
 					goto tb_found;
 				goto next_port;
 			}
@@ -281,8 +274,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
 		    smallest_size == -1)
 			goto success;
-		if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true,
-							     reuseport_ok)) {
+		if (inet_csk_bind_conflict(sk, tb, true, reuseport_ok)) {
 			if ((reuse ||
 			     (tb->fastreuseport > 0 &&
 			      sk->sk_reuseport &&
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 56d756e..dc07734 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -63,6 +63,7 @@
 #include <linux/times.h>
 #include <linux/slab.h>
 
+#include <net/addrconf.h>
 #include <net/net_namespace.h>
 #include <net/icmp.h>
 #include <net/inet_hashtables.h>
@@ -1817,7 +1818,6 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.getsockopt	   = ip_getsockopt,
 	.addr2sockaddr	   = inet_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
-	.bind_conflict	   = inet_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ip_setsockopt,
 	.compat_getsockopt = compat_ip_getsockopt,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 55ee2ea..97074c4 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -28,46 +28,6 @@
 #include <net/inet6_connection_sock.h>
 #include <net/sock_reuseport.h>
 
-int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb, bool relax,
-			    bool reuseport_ok)
-{
-	const struct sock *sk2;
-	bool reuse = !!sk->sk_reuse;
-	bool reuseport = !!sk->sk_reuseport && reuseport_ok;
-	kuid_t uid = sock_i_uid((struct sock *)sk);
-
-	/* We must walk the whole port owner list in this case. -DaveM */
-	/*
-	 * See comment in inet_csk_bind_conflict about sock lookup
-	 * vs net namespaces issues.
-	 */
-	sk_for_each_bound(sk2, &tb->owners) {
-		if (sk != sk2 &&
-		    (!sk->sk_bound_dev_if ||
-		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
-			if ((!reuse || !sk2->sk_reuse ||
-			     sk2->sk_state == TCP_LISTEN) &&
-			    (!reuseport || !sk2->sk_reuseport ||
-			     rcu_access_pointer(sk->sk_reuseport_cb) ||
-			     (sk2->sk_state != TCP_TIME_WAIT &&
-			      !uid_eq(uid,
-				      sock_i_uid((struct sock *)sk2))))) {
-				if (inet_rcv_saddr_equal(sk, sk2, true))
-					break;
-			}
-			if (!relax && reuse && sk2->sk_reuse &&
-			    sk2->sk_state != TCP_LISTEN &&
-			    inet_rcv_saddr_equal(sk, sk2, true))
-				break;
-		}
-	}
-
-	return sk2 != NULL;
-}
-EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
-
 struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 				      struct flowi6 *fl6,
 				      const struct request_sock *req,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 228965d..13ba53a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1621,7 +1621,6 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
@@ -1652,7 +1651,6 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
-- 
2.5.5
