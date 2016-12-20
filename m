From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 1/5 net-next] inet: replace ->bind_conflict with ->rcv_saddr_equal
Date: Tue, 20 Dec 2016 15:07:00 -0500
Message-ID: <1482264424-15439-2-git-send-email-jbacik@fb.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50301 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754529AbcLTUHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 15:07:39 -0500
In-Reply-To: <1482264424-15439-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only difference between inet6_csk_bind_conflict and inet_csk_bind_conflict
is how they check the rcv_saddr.  Since we want to be able to check the saddr in
other places just drop the protocol specific ->bind_conflict and replace it with
->rcv_saddr_equal, then make inet_csk_bind_conflict the one true bind conflict
function.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/inet6_connection_sock.h |  5 -----
 include/net/inet_connection_sock.h  |  9 +++------
 net/dccp/ipv4.c                     |  3 ++-
 net/dccp/ipv6.c                     |  2 +-
 net/ipv4/inet_connection_sock.c     | 22 +++++++-------------
 net/ipv4/tcp_ipv4.c                 |  3 ++-
 net/ipv4/udp.c                      |  1 +
 net/ipv6/inet6_connection_sock.c    | 40 -------------------------------------
 net/ipv6/tcp_ipv6.c                 |  4 ++--
 9 files changed, 18 insertions(+), 71 deletions(-)

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
index ec0479a..9cd43c5 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -62,9 +62,9 @@ struct inet_connection_sock_af_ops {
 				char __user *optval, int __user *optlen);
 #endif
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
-	int	    (*bind_conflict)(const struct sock *sk,
-				     const struct inet_bind_bucket *tb,
-				     bool relax, bool soreuseport_ok);
+	int         (*rcv_saddr_equal)(const struct sock *sk1,
+				       const struct sock *sk2,
+				       bool match_wildcard);
 	void	    (*mtu_reduced)(struct sock *sk);
 };
 
@@ -261,9 +261,6 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
-int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb, bool relax,
-			   bool soreuseport_ok);
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 struct dst_entry *inet_csk_route_req(const struct sock *sk, struct flowi4 *fl4,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 9c67a96..1931324 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/random.h>
 
+#include <net/addrconf.h>
 #include <net/icmp.h>
 #include <net/inet_common.h>
 #include <net/inet_hashtables.h>
@@ -901,7 +902,7 @@ static const struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
 	.getsockopt	   = ip_getsockopt,
 	.addr2sockaddr	   = inet_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
-	.bind_conflict	   = inet_csk_bind_conflict,
+	.rcv_saddr_equal   = ipv4_rcv_saddr_equal,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ip_setsockopt,
 	.compat_getsockopt = compat_ip_getsockopt,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4663a01..45242b8 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -926,7 +926,7 @@ static const struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
+	.rcv_saddr_equal   = ipv6_rcv_saddr_equal,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5f44fa1..74f6a57 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -44,9 +44,9 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
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
@@ -62,7 +62,6 @@ int inet_csk_bind_conflict(const struct sock *sk,
 
 	sk_for_each_bound(sk2, &tb->owners) {
 		if (sk != sk2 &&
-		    !inet_v6_ipv6only(sk2) &&
 		    (!sk->sk_bound_dev_if ||
 		     !sk2->sk_bound_dev_if ||
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
@@ -72,23 +71,18 @@ int inet_csk_bind_conflict(const struct sock *sk,
 			     rcu_access_pointer(sk->sk_reuseport_cb) ||
 			     (sk2->sk_state != TCP_TIME_WAIT &&
 			     !uid_eq(uid, sock_i_uid(sk2))))) {
-
-				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
-				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
+				if (inet_csk(sk)->icsk_af_ops->rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 			if (!relax && reuse && sk2->sk_reuse &&
 			    sk2->sk_state != TCP_LISTEN) {
-
-				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
-				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
+				if (inet_csk(sk)->icsk_af_ops->rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 		}
 	}
 	return sk2 != NULL;
 }
-EXPORT_SYMBOL_GPL(inet_csk_bind_conflict);
 
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
@@ -167,8 +161,7 @@ other_parity_scan:
 					smallest_size = tb->num_owners;
 					smallest_port = port;
 				}
-				if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false,
-									      reuseport_ok))
+				if (!inet_csk_bind_conflict(sk, tb, false, reuseport_ok))
 					goto tb_found;
 				goto next_port;
 			}
@@ -209,8 +202,7 @@ tb_found:
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
index 029708f..7608012 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -63,6 +63,7 @@
 #include <linux/times.h>
 #include <linux/slab.h>
 
+#include <net/addrconf.h>
 #include <net/net_namespace.h>
 #include <net/icmp.h>
 #include <net/inet_hashtables.h>
@@ -1781,7 +1782,7 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.getsockopt	   = ip_getsockopt,
 	.addr2sockaddr	   = inet_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in),
-	.bind_conflict	   = inet_csk_bind_conflict,
+	.rcv_saddr_equal   = ipv4_rcv_saddr_equal,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ip_setsockopt,
 	.compat_getsockopt = compat_ip_getsockopt,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2a70c05..6089ea8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -374,6 +374,7 @@ int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ipv4_rcv_saddr_equal);
 
 static u32 udp4_portaddr_hash(const struct net *net, __be32 saddr,
 			      unsigned int port)
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 71939a2..7538715 100644
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
-				if (ipv6_rcv_saddr_equal(sk, sk2, true))
-					break;
-			}
-			if (!relax && reuse && sk2->sk_reuse &&
-			    sk2->sk_state != TCP_LISTEN &&
-			    ipv6_rcv_saddr_equal(sk, sk2, true))
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
index bee59a6..2f40b98 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1603,7 +1603,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
+	.rcv_saddr_equal   = ipv6_rcv_saddr_equal,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
@@ -1634,7 +1634,7 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
-	.bind_conflict	   = inet6_csk_bind_conflict,
+	.rcv_saddr_equal   = ipv6_rcv_saddr_equal,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
-- 
2.9.3
