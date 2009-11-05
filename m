From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/5] net/x25: push BKL usage into x25_proto
Date: Thu,  5 Nov 2009 15:37:29 +0100
Message-ID: <1257431850-20874-5-git-send-email-arnd@arndb.de>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Henner Eisen <eis@baty.hanse.de>, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757627AbZKEOiO@vger.kernel.org>
In-Reply-To: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The x25 driver uses lock_kernel() implicitly through
its proto_ops wrapper. The makes the usage explicit
in order to get rid of that wrapper and to better document
the usage of the BKL.

The next step should be to get rid of the usage of the BKL
in x25 entirely, which requires understanding what data
structures need serialized accesses.

Cc: Henner Eisen <eis@baty.hanse.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-x25@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/x25/af_x25.c |   71 +++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 60 insertions(+), 11 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 7fa9c7a..a7a4bc2 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -415,6 +415,7 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int rc = -ENOPROTOOPT;
 
+	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -429,6 +430,7 @@ static int x25_setsockopt(struct socket *sock, int level, int optname,
 	x25_sk(sk)->qbitincl = !!opt;
 	rc = 0;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -438,6 +440,7 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	struct sock *sk = sock->sk;
 	int val, len, rc = -ENOPROTOOPT;
 
+	lock_kernel();
 	if (level != SOL_X25 || optname != X25_QBITINCL)
 		goto out;
 
@@ -458,6 +461,7 @@ static int x25_getsockopt(struct socket *sock, int level, int optname,
 	val = x25_sk(sk)->qbitincl;
 	rc = copy_to_user(optval, &val, len) ? -EFAULT : 0;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -466,12 +470,14 @@ static int x25_listen(struct socket *sock, int backlog)
 	struct sock *sk = sock->sk;
 	int rc = -EOPNOTSUPP;
 
+	lock_kernel();
 	if (sk->sk_state != TCP_LISTEN) {
 		memset(&x25_sk(sk)->dest_addr, 0, X25_ADDR_LEN);
 		sk->sk_max_ack_backlog = backlog;
 		sk->sk_state           = TCP_LISTEN;
 		rc = 0;
 	}
+	unlock_kernel();
 
 	return rc;
 }
@@ -597,6 +603,7 @@ static int x25_release(struct socket *sock)
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25;
 
+	lock_kernel();
 	if (!sk)
 		goto out;
 
@@ -627,6 +634,7 @@ static int x25_release(struct socket *sock)
 
 	sock_orphan(sk);
 out:
+	unlock_kernel();
 	return 0;
 }
 
@@ -634,18 +642,23 @@ static int x25_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
 	struct sockaddr_x25 *addr = (struct sockaddr_x25 *)uaddr;
+	int rc = 0;
 
+	lock_kernel();
 	if (!sock_flag(sk, SOCK_ZAPPED) ||
 	    addr_len != sizeof(struct sockaddr_x25) ||
-	    addr->sx25_family != AF_X25)
-		return -EINVAL;
+	    addr->sx25_family != AF_X25) {
+		rc = -EINVAL;
+		goto out;
+	}
 
 	x25_sk(sk)->source_addr = addr->sx25_addr;
 	x25_insert_socket(sk);
 	sock_reset_flag(sk, SOCK_ZAPPED);
 	SOCK_DEBUG(sk, "x25_bind: socket is bound\n");
-
-	return 0;
+out:
+	unlock_kernel();
+	return rc;
 }
 
 static int x25_wait_for_connection_establishment(struct sock *sk)
@@ -686,6 +699,7 @@ static int x25_connect(struct socket *sock, struct sockaddr *uaddr,
 	struct x25_route *rt;
 	int rc = 0;
 
+	lock_kernel();
 	lock_sock(sk);
 	if (sk->sk_state == TCP_ESTABLISHED && sock->state == SS_CONNECTING) {
 		sock->state = SS_CONNECTED;
@@ -763,6 +777,7 @@ out_put_route:
 	x25_route_put(rt);
 out:
 	release_sock(sk);
+	unlock_kernel();
 	return rc;
 }
 
@@ -802,6 +817,7 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 	struct sk_buff *skb;
 	int rc = -EINVAL;
 
+	lock_kernel();
 	if (!sk || sk->sk_state != TCP_LISTEN)
 		goto out;
 
@@ -829,6 +845,7 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags)
 out2:
 	release_sock(sk);
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -838,10 +855,14 @@ static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)uaddr;
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25 = x25_sk(sk);
+	int rc = 0;
 
+	lock_kernel();
 	if (peer) {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -ENOTCONN;
+		if (sk->sk_state != TCP_ESTABLISHED) {
+			rc = -ENOTCONN;
+			goto out;
+		}
 		sx25->sx25_addr = x25->dest_addr;
 	} else
 		sx25->sx25_addr = x25->source_addr;
@@ -849,7 +870,21 @@ static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
 	sx25->sx25_family = AF_X25;
 	*uaddr_len = sizeof(*sx25);
 
-	return 0;
+out:
+	unlock_kernel();
+	return rc;
+}
+
+static unsigned int x25_datagram_poll(struct file *file, struct socket *sock,
+			   poll_table *wait)
+{
+	int rc;
+
+	lock_kernel();
+	rc = datagram_poll(file, sock, wait);
+	unlock_kernel();
+
+	return rc;
 }
 
 int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
@@ -1002,6 +1037,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	size_t size;
 	int qbit = 0, rc = -EINVAL;
 
+	lock_kernel();
 	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_OOB|MSG_EOR|MSG_CMSG_COMPAT))
 		goto out;
 
@@ -1166,6 +1202,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 	release_sock(sk);
 	rc = len;
 out:
+	unlock_kernel();
 	return rc;
 out_kfree_skb:
 	kfree_skb(skb);
@@ -1186,6 +1223,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 	unsigned char *asmptr;
 	int rc = -ENOTCONN;
 
+	lock_kernel();
 	/*
 	 * This works for seqpacket too. The receiver has ordered the queue for
 	 * us! We do one quick check first though
@@ -1259,6 +1297,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 out_free_dgram:
 	skb_free_datagram(sk, skb);
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1270,6 +1309,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 	int rc;
 
+	lock_kernel();
 	switch (cmd) {
 		case TIOCOUTQ: {
 			int amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
@@ -1472,6 +1512,7 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = -ENOIOCTLCMD;
 			break;
 	}
+	unlock_kernel();
 
 	return rc;
 }
@@ -1542,15 +1583,19 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 		break;
 	case SIOCGSTAMP:
 		rc = -EINVAL;
+		lock_kernel();
 		if (sk)
 			rc = compat_sock_get_timestamp(sk,
 					(struct timeval __user*)argp);
+		unlock_kernel();
 		break;
 	case SIOCGSTAMPNS:
 		rc = -EINVAL;
+		lock_kernel();
 		if (sk)
 			rc = compat_sock_get_timestampns(sk,
 					(struct timespec __user*)argp);
+		unlock_kernel();
 		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
@@ -1569,16 +1614,22 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 		rc = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
+		lock_kernel();
 		rc = x25_route_ioctl(cmd, argp);
+		unlock_kernel();
 		break;
 	case SIOCX25GSUBSCRIP:
+		lock_kernel();
 		rc = compat_x25_subscr_ioctl(cmd, argp);
+		unlock_kernel();
 		break;
 	case SIOCX25SSUBSCRIP:
 		rc = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
+		lock_kernel();
 		rc = compat_x25_subscr_ioctl(cmd, argp);
+		unlock_kernel();
 		break;
 	case SIOCX25GFACILITIES:
 	case SIOCX25SFACILITIES:
@@ -1600,7 +1651,7 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 }
 #endif
 
-static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
+static const struct proto_ops x25_proto_ops = {
 	.family =	AF_X25,
 	.owner =	THIS_MODULE,
 	.release =	x25_release,
@@ -1609,7 +1660,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	x25_accept,
 	.getname =	x25_getname,
-	.poll =		datagram_poll,
+	.poll =		x25_datagram_poll,
 	.ioctl =	x25_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_x25_ioctl,
@@ -1624,8 +1675,6 @@ static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
 	.sendpage =	sock_no_sendpage,
 };
 
-SOCKOPS_WRAP(x25_proto, AF_X25);
-
 static struct packet_type x25_packet_type __read_mostly = {
 	.type =	cpu_to_be16(ETH_P_X25),
 	.func =	x25_lapb_receive_frame,
-- 
1.6.3.3
