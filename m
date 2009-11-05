From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/5] net/ipx: push down BKL into a ipx_dgram_ops
Date: Thu,  5 Nov 2009 15:37:27 +0100
Message-ID: <1257431850-20874-3-git-send-email-arnd@arndb.de>
References: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Cc: David Miller <davem@davemloft.net>, John Kacur <jkacur@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757476AbZKEOiC@vger.kernel.org>
In-Reply-To: <1257431850-20874-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Making the BKL usage explicit in ipx makes it more
obvious where it is used, reduces code size and helps
getting rid of the BKL in common code.

I did not analyse how to kill lock_kernel from ipx
entirely, this will involve either proving that it's not
needed, or replacing with a proper mutex or spinlock,
after finding out which data structures are protected
by the lock.

Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipx/af_ipx.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 66c7a20..f542c5b 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1298,6 +1298,7 @@ static int ipx_setsockopt(struct socket *sock, int level, int optname,
 	int opt;
 	int rc = -EINVAL;
 
+	lock_kernel();
 	if (optlen != sizeof(int))
 		goto out;
 
@@ -1312,6 +1313,7 @@ static int ipx_setsockopt(struct socket *sock, int level, int optname,
 	ipx_sk(sk)->type = opt;
 	rc = 0;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1323,6 +1325,7 @@ static int ipx_getsockopt(struct socket *sock, int level, int optname,
 	int len;
 	int rc = -ENOPROTOOPT;
 
+	lock_kernel();
 	if (!(level == SOL_IPX && optname == IPX_TYPE))
 		goto out;
 
@@ -1343,6 +1346,7 @@ static int ipx_getsockopt(struct socket *sock, int level, int optname,
 
 	rc = 0;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1390,6 +1394,7 @@ static int ipx_release(struct socket *sock)
 	if (!sk)
 		goto out;
 
+	lock_kernel();
 	if (!sock_flag(sk, SOCK_DEAD))
 		sk->sk_state_change(sk);
 
@@ -1397,6 +1402,7 @@ static int ipx_release(struct socket *sock)
 	sock->sk = NULL;
 	sk_refcnt_debug_release(sk);
 	ipx_destroy_socket(sk);
+	unlock_kernel();
 out:
 	return 0;
 }
@@ -1424,7 +1430,8 @@ static __be16 ipx_first_free_socketnum(struct ipx_interface *intrfc)
 	return htons(socketNum);
 }
 
-static int ipx_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+static int __ipx_bind(struct socket *sock,
+			struct sockaddr *uaddr, int addr_len)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
@@ -1519,6 +1526,17 @@ out:
 	return rc;
 }
 
+static int ipx_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
+{
+	int rc;
+
+	lock_kernel();
+	rc = __ipx_bind(sock, uaddr, addr_len);
+	unlock_kernel();
+
+	return rc;
+}
+
 static int ipx_connect(struct socket *sock, struct sockaddr *uaddr,
 	int addr_len, int flags)
 {
@@ -1531,6 +1549,7 @@ static int ipx_connect(struct socket *sock, struct sockaddr *uaddr,
 	sk->sk_state	= TCP_CLOSE;
 	sock->state 	= SS_UNCONNECTED;
 
+	lock_kernel();
 	if (addr_len != sizeof(*addr))
 		goto out;
 	addr = (struct sockaddr_ipx *)uaddr;
@@ -1550,7 +1569,7 @@ static int ipx_connect(struct socket *sock, struct sockaddr *uaddr,
 			IPX_NODE_LEN);
 #endif	/* CONFIG_IPX_INTERN */
 
-		rc = ipx_bind(sock, (struct sockaddr *)&uaddr,
+		rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
 			      sizeof(struct sockaddr_ipx));
 		if (rc)
 			goto out;
@@ -1577,6 +1596,7 @@ static int ipx_connect(struct socket *sock, struct sockaddr *uaddr,
 		ipxrtr_put(rt);
 	rc = 0;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1592,6 +1612,7 @@ static int ipx_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	*uaddr_len = sizeof(struct sockaddr_ipx);
 
+	lock_kernel();
 	if (peer) {
 		rc = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
@@ -1626,6 +1647,19 @@ static int ipx_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	rc = 0;
 out:
+	unlock_kernel();
+	return rc;
+}
+
+static unsigned int ipx_datagram_poll(struct file *file, struct socket *sock,
+			   poll_table *wait)
+{
+	int rc;
+
+	lock_kernel();
+	rc = datagram_poll(file, sock, wait);
+	unlock_kernel();
+
 	return rc;
 }
 
@@ -1700,6 +1734,7 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 	int rc = -EINVAL;
 	int flags = msg->msg_flags;
 
+	lock_kernel();
 	/* Socket gets bound below anyway */
 /*	if (sk->sk_zapped)
 		return -EIO; */	/* Socket not bound */
@@ -1723,7 +1758,7 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 			memcpy(uaddr.sipx_node, ipxs->intrfc->if_node,
 				IPX_NODE_LEN);
 #endif
-			rc = ipx_bind(sock, (struct sockaddr *)&uaddr,
+			rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
 					sizeof(struct sockaddr_ipx));
 			if (rc)
 				goto out;
@@ -1751,6 +1786,7 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (rc >= 0)
 		rc = len;
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1765,6 +1801,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int copied, rc;
 
+	lock_kernel();
 	/* put the autobinding in */
 	if (!ipxs->port) {
 		struct sockaddr_ipx uaddr;
@@ -1779,7 +1816,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 		memcpy(uaddr.sipx_node, ipxs->intrfc->if_node, IPX_NODE_LEN);
 #endif	/* CONFIG_IPX_INTERN */
 
-		rc = ipx_bind(sock, (struct sockaddr *)&uaddr,
+		rc = __ipx_bind(sock, (struct sockaddr *)&uaddr,
 			      sizeof(struct sockaddr_ipx));
 		if (rc)
 			goto out;
@@ -1823,6 +1860,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 out_free:
 	skb_free_datagram(sk, skb);
 out:
+	unlock_kernel();
 	return rc;
 }
 
@@ -1834,6 +1872,7 @@ static int ipx_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	struct sock *sk = sock->sk;
 	void __user *argp = (void __user *)arg;
 
+	lock_kernel();
 	switch (cmd) {
 	case TIOCOUTQ:
 		amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
@@ -1896,6 +1935,7 @@ static int ipx_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		rc = -ENOIOCTLCMD;
 		break;
 	}
+	unlock_kernel();
 
 	return rc;
 }
@@ -1933,7 +1973,7 @@ static struct net_proto_family ipx_family_ops = {
 	.owner		= THIS_MODULE,
 };
 
-static const struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {
+static const struct proto_ops ipx_dgram_ops = {
 	.family		= PF_IPX,
 	.owner		= THIS_MODULE,
 	.release	= ipx_release,
@@ -1942,7 +1982,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {
 	.socketpair	= sock_no_socketpair,
 	.accept		= sock_no_accept,
 	.getname	= ipx_getname,
-	.poll		= datagram_poll,
+	.poll		= ipx_datagram_poll,
 	.ioctl		= ipx_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ipx_compat_ioctl,
@@ -1957,8 +1997,6 @@ static const struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {
 	.sendpage	= sock_no_sendpage,
 };
 
-SOCKOPS_WRAP(ipx_dgram, PF_IPX);
-
 static struct packet_type ipx_8023_packet_type __read_mostly = {
 	.type		= cpu_to_be16(ETH_P_802_3),
 	.func		= ipx_rcv,
-- 
1.6.3.3
