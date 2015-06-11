From: Firo Yang <firogm@gmail.com>
Subject: [RFC PATCH] net: Add sock_common_listen for TCP and DCCP
Date: Thu, 11 Jun 2015 19:05:03 +0800
Message-ID: <1434020703-7614-1-git-send-email-firogm@gmail.com>
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au,
	ast@plumgrid.com, dborkman@redhat.com, ebiederm@xmission.com,
	dan.carpenter@oracle.com, Julia.Lawall@lip6.fr,
	kernel-janitors@vger.kernel.org, Firo Yang <firogm@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33579 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbbFKLFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 07:05:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code refactoring:
1. Move the common code of inet_listen() and inet_dccp_listen() to
sock_common_listen().
Add new state SOCK_LISTEN and SOCK_CLOSE for sock_common_listen().

2. Modify and rename inet_listen() to tcp_listen().

3. Modify and rename inet_dccp_listen() to dccp_listen().

4. Add new callback pointer listen in struct proto for
tcp_listen() and dccp_listen().

This patch makes codes more modularized and removes redudant codes.

Signed-off-by: Firo Yang <firogm@gmail.com>
---
I test it on my x86 pc.

 include/net/sock.h  | 18 ++++++++++++++++
 include/net/tcp.h   |  1 +
 net/core/sock.c     | 36 +++++++++++++++++++++++++++++++
 net/dccp/dccp.h     |  2 +-
 net/dccp/ipv4.c     |  4 ++--
 net/dccp/ipv6.c     |  3 ++-
 net/dccp/proto.c    | 62 ++++++++++++++++-------------------------------------
 net/ipv4/af_inet.c  | 58 +------------------------------------------------
 net/ipv4/tcp.c      | 35 ++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c |  1 +
 net/ipv6/af_inet6.c |  2 +-
 net/ipv6/tcp_ipv6.c |  1 +
 12 files changed, 118 insertions(+), 105 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 26c1c31..5adc7f4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -934,6 +934,7 @@ struct proto {
 	int			(*connect)(struct sock *sk,
 					struct sockaddr *uaddr,
 					int addr_len);
+	int			(*listen)(struct sock *sk, int backlog);
 	int			(*disconnect)(struct sock *sk, int flags);
 
 	struct sock *		(*accept)(struct sock *sk, int flags, int *err);
@@ -1349,6 +1350,21 @@ void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
 #define SOCK_BINDADDR_LOCK	4
 #define SOCK_BINDPORT_LOCK	8
 
+/*
+ * Sock common state
+ * These values must be enqual to correspondent TCP state
+ * and DCCP state.
+ */
+enum {
+	SOCK_CLOSE	= TCP_CLOSE,
+	SOCK_LISTEN	= TCP_LISTEN
+};
+
+enum {
+	SOCKF_CLOSE	= TCPF_CLOSE,
+	SOCKF_LISTEN	= TCPF_LISTEN,
+};
+
 struct socket_alloc {
 	struct socket socket;
 	struct inode vfs_inode;
@@ -1587,6 +1603,8 @@ int compat_sock_common_setsockopt(struct socket *sock, int level,
 
 void sk_common_release(struct sock *sk);
 
+int sock_common_listen(struct socket *sock, int backlog);
+
 /*
  *	Default socket callbacks and setup code
  */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 978cebe..70d3f64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -434,6 +434,7 @@ int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen);
 void tcp_set_keepalive(struct sock *sk, int val);
 void tcp_syn_ack_timeout(const struct request_sock *req);
+int tcp_listen(struct sock *sk, int backlog);
 int tcp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 		int flags, int *addr_len);
 void tcp_parse_options(const struct sk_buff *skb,
diff --git a/net/core/sock.c b/net/core/sock.c
index e72633c..8016a1e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2559,6 +2559,42 @@ int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 EXPORT_SYMBOL(sock_common_recvmsg);
 
 /*
+ *	Move a socket into listening state.
+ */
+int sock_common_listen(struct socket *sock, int backlog)
+{
+	struct sock *sk = sock->sk;
+	unsigned char old_state;
+	int err;
+
+	lock_sock(sk);
+
+	err = -EINVAL;
+	if (sock->state != SS_UNCONNECTED)
+		goto out;
+
+	old_state = sk->sk_state;
+	if (!((1 << old_state) & (SOCKF_CLOSE | SOCKF_LISTEN)))
+		goto out;
+
+	/* Really, if the socket is already in listen state
+	 * we can only allow the backlog to be adjusted.
+	 */
+	if (old_state != SOCK_LISTEN) {
+		err = sk->sk_prot->listen(sk, backlog);
+		if (err)
+			goto out;
+	}
+	sk->sk_max_ack_backlog = backlog;
+	err = 0;
+
+out:
+	release_sock(sk);
+	return err;
+}
+EXPORT_SYMBOL(sock_common_listen);
+
+/*
  *	Set socket options on an inet socket.
  */
 int sock_common_setsockopt(struct socket *sock, int level, int optname,
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index bebc735..5a5acbb 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -313,7 +313,7 @@ int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 int dccp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int nonblock,
 		 int flags, int *addr_len);
 void dccp_shutdown(struct sock *sk, int how);
-int inet_dccp_listen(struct socket *sock, int backlog);
+int dccp_listen(struct sock *sk, int backlog);
 unsigned int dccp_poll(struct file *file, struct socket *sock,
 		       poll_table *wait);
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ccf4c56..339f253 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -952,6 +952,7 @@ static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
 	.close			= dccp_close,
+	.listen			= dccp_listen,
 	.connect		= dccp_v4_connect,
 	.disconnect		= dccp_disconnect,
 	.ioctl			= dccp_ioctl,
@@ -1000,8 +1001,7 @@ static const struct proto_ops inet_dccp_ops = {
 	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
 	.poll		   = dccp_poll,
 	.ioctl		   = inet_ioctl,
-	/* FIXME: work on inet_listen to rename it to sock_common_listen */
-	.listen		   = inet_dccp_listen,
+	.listen		   = sock_common_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5165571..1a96194 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1011,6 +1011,7 @@ static struct proto dccp_v6_prot = {
 	.name		   = "DCCPv6",
 	.owner		   = THIS_MODULE,
 	.close		   = dccp_close,
+	.listen		   = dccp_listen,
 	.connect	   = dccp_v6_connect,
 	.disconnect	   = dccp_disconnect,
 	.ioctl		   = dccp_ioctl,
@@ -1056,7 +1057,7 @@ static const struct proto_ops inet6_dccp_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = dccp_poll,
 	.ioctl		   = inet6_ioctl,
-	.listen		   = inet_dccp_listen,
+	.listen		   = sock_common_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 52a9401..097edab 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -231,17 +231,31 @@ void dccp_destroy_sock(struct sock *sk)
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);
 
-static inline int dccp_listen_start(struct sock *sk, int backlog)
+int dccp_listen(struct sock *sk, int backlog)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct socket *sock = sk->sk_socket;
+	struct dccp_sock *dp;
+	int err;
 
+	err = -EINVAL;
+	if (sock->type != SOCK_DCCP)
+		goto out;
+
+	dp = dccp_sk(sk);
 	dp->dccps_role = DCCP_ROLE_LISTEN;
 	/* do not start to listen if feature negotiation setup fails */
-	if (dccp_feat_finalise_settings(dp))
-		return -EPROTO;
-	return inet_csk_listen_start(sk, backlog);
+	if (dccp_feat_finalise_settings(dp)) {
+		err = -EPROTO;
+		goto out;
+	}
+	err = inet_csk_listen_start(sk, backlog);
+
+out:
+	return err;
 }
 
+EXPORT_SYMBOL_GPL(dccp_listen);
+
 static inline int dccp_need_reset(int state)
 {
 	return state != DCCP_CLOSED && state != DCCP_LISTEN &&
@@ -913,44 +927,6 @@ out:
 
 EXPORT_SYMBOL_GPL(dccp_recvmsg);
 
-int inet_dccp_listen(struct socket *sock, int backlog)
-{
-	struct sock *sk = sock->sk;
-	unsigned char old_state;
-	int err;
-
-	lock_sock(sk);
-
-	err = -EINVAL;
-	if (sock->state != SS_UNCONNECTED || sock->type != SOCK_DCCP)
-		goto out;
-
-	old_state = sk->sk_state;
-	if (!((1 << old_state) & (DCCPF_CLOSED | DCCPF_LISTEN)))
-		goto out;
-
-	/* Really, if the socket is already in listen state
-	 * we can only allow the backlog to be adjusted.
-	 */
-	if (old_state != DCCP_LISTEN) {
-		/*
-		 * FIXME: here it probably should be sk->sk_prot->listen_start
-		 * see tcp_listen_start
-		 */
-		err = dccp_listen_start(sk, backlog);
-		if (err)
-			goto out;
-	}
-	sk->sk_max_ack_backlog = backlog;
-	err = 0;
-
-out:
-	release_sock(sk);
-	return err;
-}
-
-EXPORT_SYMBOL_GPL(inet_dccp_listen);
-
 static void dccp_terminate_connection(struct sock *sk)
 {
 	u8 next_state = DCCP_CLOSED;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cc858ef..e2e2b19 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -187,62 +187,6 @@ static int inet_autobind(struct sock *sk)
 }
 
 /*
- *	Move a socket into listening state.
- */
-int inet_listen(struct socket *sock, int backlog)
-{
-	struct sock *sk = sock->sk;
-	unsigned char old_state;
-	int err;
-
-	lock_sock(sk);
-
-	err = -EINVAL;
-	if (sock->state != SS_UNCONNECTED || sock->type != SOCK_STREAM)
-		goto out;
-
-	old_state = sk->sk_state;
-	if (!((1 << old_state) & (TCPF_CLOSE | TCPF_LISTEN)))
-		goto out;
-
-	/* Really, if the socket is already in listen state
-	 * we can only allow the backlog to be adjusted.
-	 */
-	if (old_state != TCP_LISTEN) {
-		/* Check special setups for testing purpose to enable TFO w/o
-		 * requiring TCP_FASTOPEN sockopt.
-		 * Note that only TCP sockets (SOCK_STREAM) will reach here.
-		 * Also fastopenq may already been allocated because this
-		 * socket was in TCP_LISTEN state previously but was
-		 * shutdown() (rather than close()).
-		 */
-		if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
-		    !inet_csk(sk)->icsk_accept_queue.fastopenq) {
-			if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) != 0)
-				err = fastopen_init_queue(sk, backlog);
-			else if ((sysctl_tcp_fastopen &
-				  TFO_SERVER_WO_SOCKOPT2) != 0)
-				err = fastopen_init_queue(sk,
-				    ((uint)sysctl_tcp_fastopen) >> 16);
-			else
-				err = 0;
-			if (err)
-				goto out;
-		}
-		err = inet_csk_listen_start(sk, backlog);
-		if (err)
-			goto out;
-	}
-	sk->sk_max_ack_backlog = backlog;
-	err = 0;
-
-out:
-	release_sock(sk);
-	return err;
-}
-EXPORT_SYMBOL(inet_listen);
-
-/*
  *	Create an inet socket.
  */
 
@@ -903,7 +847,7 @@ const struct proto_ops inet_stream_ops = {
 	.getname	   = inet_getname,
 	.poll		   = tcp_poll,
 	.ioctl		   = inet_ioctl,
-	.listen		   = inet_listen,
+	.listen		   = sock_common_listen,
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 65f791f..3aa185b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1301,6 +1301,41 @@ out_err:
 }
 EXPORT_SYMBOL(tcp_sendmsg);
 
+int tcp_listen(struct sock *sk, int backlog)
+{
+	struct socket *sock = sk->sk_socket;
+	int err;
+
+	err = -EINVAL;
+	if (sock->type != SOCK_STREAM)
+		goto out;
+	/* Check special setups for testing purpose to enable TFO w/o
+	 * requiring TCP_FASTOPEN sockopt.
+	 * Note that only TCP sockets (SOCK_STREAM) will reach here.
+	 * Also fastopenq may already been allocated because this
+	 * socket was in TCP_LISTEN state previously but was
+	 * shutdown() (rather than close()).
+	 */
+	if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
+	    !inet_csk(sk)->icsk_accept_queue.fastopenq) {
+		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) != 0)
+			err = fastopen_init_queue(sk, backlog);
+		else if ((sysctl_tcp_fastopen &
+			  TFO_SERVER_WO_SOCKOPT2) != 0)
+			err = fastopen_init_queue(sk,
+			    ((uint)sysctl_tcp_fastopen) >> 16);
+		else
+			err = 0;
+		if (err)
+			goto out;
+	}
+	err = inet_csk_listen_start(sk, backlog);
+
+out:
+	return err;
+}
+EXPORT_SYMBOL(tcp_listen);
+
 /*
  *	Handle reading urgent data. BSD has very simple semantics for
  *	this, no blocking and very strange errors 8)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d7d4c2b..0dff9dc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2337,6 +2337,7 @@ struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
 	.close			= tcp_close,
+	.listen			= tcp_listen,
 	.connect		= tcp_v4_connect,
 	.disconnect		= tcp_disconnect,
 	.accept			= inet_csk_accept,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7de52b6..8fd9c77 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -516,7 +516,7 @@ const struct proto_ops inet6_stream_ops = {
 	.getname	   = inet6_getname,
 	.poll		   = tcp_poll,			/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
-	.listen		   = inet_listen,		/* ok		*/
+	.listen		   = sock_common_listen,	/* ok		*/
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 45a7176..80cecc6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1822,6 +1822,7 @@ struct proto tcpv6_prot = {
 	.name			= "TCPv6",
 	.owner			= THIS_MODULE,
 	.close			= tcp_close,
+	.listen			= tcp_listen,
 	.connect		= tcp_v6_connect,
 	.disconnect		= tcp_disconnect,
 	.accept			= inet_csk_accept,
-- 
2.4.3
