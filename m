From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/2] inet: Fix get port to handle zero port number with soreuseport set
Date: Wed, 14 Dec 2016 16:54:16 -0800
Message-ID: <20161215005416.1561632-3-tom@herbertland.com>
References: <20161215005416.1561632-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <jbacik@fb.com>, <eric.dumazet@gmail.com>,
        <raigatgoog@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54764 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933120AbcLOAym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:54:42 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uBF0pp2X015701
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:40 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 27bdnkt0d9-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:40 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 0e46a6dac26111e688750002c992ebde-9e9f9a50 for <netdev@vger.kernel.org>;        Wed,
 14 Dec 2016 16:54:39 -0800
In-Reply-To: <20161215005416.1561632-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user may call listen with binding an explicit port with the intent
that the kernel will assign an available port to the socket. In this
case inet_csk_get_port does a port scan. For such sockets, the user may
also set soreuseport with the intent a creating more sockets for the
port that is selected. The problem is that the initial socket being
opened could inadvertently choose an existing and unreleated port
number that was already created with soreuseport.

This patch adds a boolean parameter to inet_bind_conflict that indicates
rather soreuseport is allowed for the check (in addition to
sk->sk_reuseport). In calls to inet_bind_conflict from inet_csk_get_port
the argument is set to true if an explicit port is being looked up (snum
argument is nonzero), and is false if port scan is done.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/inet6_connection_sock.h |  3 ++-
 include/net/inet_connection_sock.h  |  6 ++++--
 net/ipv4/inet_connection_sock.c     | 14 +++++++++-----
 net/ipv6/inet6_connection_sock.c    |  7 ++++---
 4 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 954ad6b..3212b39 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -22,7 +22,8 @@ struct sock;
 struct sockaddr;
 
 int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb, bool relax);
+			    const struct inet_bind_bucket *tb, bool relax,
+			    bool soreuseport_ok);
 
 struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req, u8 proto);
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 146054c..85ee387 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -63,7 +63,8 @@ struct inet_connection_sock_af_ops {
 #endif
 	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
 	int	    (*bind_conflict)(const struct sock *sk,
-				     const struct inet_bind_bucket *tb, bool relax);
+				     const struct inet_bind_bucket *tb,
+				     bool relax, bool soreuseport_ok);
 	void	    (*mtu_reduced)(struct sock *sk);
 };
 
@@ -261,7 +262,8 @@ inet_csk_rto_backoff(const struct inet_connection_sock *icsk,
 struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
 int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb, bool relax);
+			   const struct inet_bind_bucket *tb, bool relax,
+			   bool soreuseport_ok);
 int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
 struct dst_entry *inet_csk_route_req(const struct sock *sk, struct flowi4 *fl4,
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f59838a6..19ea045 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -45,11 +45,12 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
 EXPORT_SYMBOL(inet_get_local_port_range);
 
 int inet_csk_bind_conflict(const struct sock *sk,
-			   const struct inet_bind_bucket *tb, bool relax)
+			   const struct inet_bind_bucket *tb, bool relax,
+			   bool reuseport_ok)
 {
 	struct sock *sk2;
-	int reuse = sk->sk_reuse;
-	int reuseport = sk->sk_reuseport;
+	bool reuse = sk->sk_reuse;
+	bool reuseport = !!sk->sk_reuseport && reuseport_ok;
 	kuid_t uid = sock_i_uid((struct sock *)sk);
 
 	/*
@@ -105,6 +106,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	struct inet_bind_bucket *tb;
 	kuid_t uid = sock_i_uid(sk);
 	u32 remaining, offset;
+	bool reuseport_ok = !!snum;
 
 	if (port) {
 have_port:
@@ -165,7 +167,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 					smallest_size = tb->num_owners;
 					smallest_port = port;
 				}
-				if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false))
+				if (!inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, false,
+									      reuseport_ok))
 					goto tb_found;
 				goto next_port;
 			}
@@ -206,7 +209,8 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		      sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
 		    smallest_size == -1)
 			goto success;
-		if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
+		if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true,
+							     reuseport_ok)) {
 			if ((reuse ||
 			     (tb->fastreuseport > 0 &&
 			      sk->sk_reuseport &&
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 1c86c47..7396e75 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -29,11 +29,12 @@
 #include <net/sock_reuseport.h>
 
 int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb, bool relax)
+			    const struct inet_bind_bucket *tb, bool relax,
+			    bool reuseport_ok)
 {
 	const struct sock *sk2;
-	int reuse = sk->sk_reuse;
-	int reuseport = sk->sk_reuseport;
+	bool reuse = !!sk->sk_reuse;
+	bool reuseport = !!sk->sk_reuseport && reuseport_ok;
 	kuid_t uid = sock_i_uid((struct sock *)sk);
 
 	/* We must walk the whole port owner list in this case. -DaveM */
-- 
2.9.3
