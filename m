From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFC 2/2] net: Allow protocols to provide an unlocked_recvmsg
	sk_prot method
Date: Wed, 20 May 2009 20:06:59 -0300
Message-ID: <20090520230659.GC5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34766 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755398AbZETXHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 19:07:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So that the socket layer kwows which protocol uses locking and can ask
for an unlocked recvmsg call inside recvmmsg, that takes the lock for a
batch of packets.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/socket.h |    3 ++
 include/net/sock.h     |    5 ++++
 net/core/sock.c        |   11 +++++++--
 net/ipv4/udp.c         |   52 ++++++++++++++++++++++++++++++++++++++++-------
 net/socket.c           |   39 ++++++++++++++++++++++++-----------
 5 files changed, 87 insertions(+), 23 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 50c6c44..7ef30a3 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -265,6 +265,9 @@ struct ucred {
 #define MSG_ERRQUEUE	0x2000	/* Fetch message from error queue */
 #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
 #define MSG_MORE	0x8000	/* Sender will send more */
+#ifdef __KERNEL__
+#define MSG_UNLOCKED	0x10000	/* Don't lock the sock */
+#endif
 
 #define MSG_EOF         MSG_FIN
 
diff --git a/include/net/sock.h b/include/net/sock.h
index da2ea5f..43c231c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -637,6 +637,11 @@ struct proto {
 					   struct msghdr *msg,
 					size_t len, int noblock, int flags, 
 					int *addr_len);
+	int			(*unlocked_recvmsg)(struct kiocb *iocb,
+						    struct sock *sk,
+						    struct msghdr *msg,
+						    size_t len, int noblock,
+						    int flags, int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
diff --git a/net/core/sock.c b/net/core/sock.c
index 9730820..2640ab7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1918,11 +1918,16 @@ int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	int addr_len = 0;
 	int err;
+	int addr_len = 0;
+
+	BUG_ON((flags & MSG_UNLOCKED) &&
+	       sk->sk_prot->unlocked_recvmsg == NULL);
 
-	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
-				   flags & ~MSG_DONTWAIT, &addr_len);
+	err = ((flags & MSG_UNLOCKED) ?
+	       sk->sk_prot->unlocked_recvmsg :
+	       sk->sk_prot->recvmsg)(iocb, sk, msg, size, flags & MSG_DONTWAIT,
+				     flags & ~MSG_DONTWAIT, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7a1d1ce..4c6e994 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -871,13 +871,35 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	return 0;
 }
 
+static void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
+{
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
+}
+
+static int skb_kill_datagram_locked(struct sock *sk, struct sk_buff *skb,
+				    unsigned int flags)
+{
+	int ret;
+	lock_sock(sk);
+	ret = skb_kill_datagram(sk, skb, flags);
+	release_sock(sk);
+	return ret;
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
 
-int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len)
+static int __udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len,
+			 void (*free_datagram)(struct sock *,
+					       struct sk_buff *),
+			 int  (*kill_datagram)(struct sock *,
+					       struct sk_buff *, unsigned int))
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
@@ -955,23 +977,36 @@ try_again:
 		err = ulen;
 
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	free_datagram(sk, skb);
 out:
 	return err;
 
 csum_copy_err:
-	lock_sock(sk);
-	if (!skb_kill_datagram(sk, skb, flags))
+	if (!kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	release_sock(sk);
 
 	if (noblock)
 		return -EAGAIN;
 	goto try_again;
 }
 
+int udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+		struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram_locked,
+			     skb_kill_datagram_locked);
+}
+
+int udp_unlocked_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram, skb_kill_datagram);
+}
+
 
 int udp_disconnect(struct sock *sk, int flags)
 {
@@ -1564,6 +1599,7 @@ struct proto udp_prot = {
 	.getsockopt	   = udp_getsockopt,
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
+	.unlocked_recvmsg  = udp_unlocked_recvmsg,
 	.sendpage	   = udp_sendpage,
 	.backlog_rcv	   = __udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
diff --git a/net/socket.c b/net/socket.c
index f0249cb..3ab1520 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2084,29 +2084,23 @@ out:
  *	Linux recvmmsg interface
  */
 
-SYSCALL_DEFINE4(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
-		unsigned int, vlen, unsigned int, flags)
+static int __sys_recvmmsg(struct socket *sock, struct mmsghdr __user *mmsg,
+			  unsigned vlen, unsigned flags)
 {
-	int fput_needed, err, datagrams = 0;
-	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	int err, datagrams = 0;
 	struct mmsghdr __user *entry = mmsg;
 
-	if (!sock)
-		goto out;
-
 	while (datagrams < vlen) {
 		err = __sys_recvmsg(sock, (struct msghdr __user *)entry, flags);
 		if (err < 0)
-			goto out_put;
+			break;
 		err = __put_user(err, &entry->msg_len);
 		if (err)
-			goto out_put;
+			break;
 		++entry;
 		++datagrams;
 	}
-out_put:
-	fput_light(sock->file, fput_needed);
-out:
+
 	/*
 	 * We may return less entries than requested (vlen) if the
 	 * sock is non block and there aren't enough datagrams.
@@ -2116,6 +2110,27 @@ out:
 	return err;
 }
 
+SYSCALL_DEFINE4(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags)
+{
+	int fput_needed, err;
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	if (sock->sk->sk_prot->unlocked_recvmsg) {
+		lock_sock(sock->sk);
+		err = __sys_recvmmsg(sock, mmsg, vlen, flags | MSG_UNLOCKED);
+		release_sock(sock->sk);
+	} else
+		err = __sys_recvmmsg(sock, mmsg, vlen, flags);
+	
+	fput_light(sock->file, fput_needed);
+out:
+	return err;
+}
+
 #ifdef __ARCH_WANT_SYS_SOCKETCALL
 
 /* Argument list sizes for sys_socketcall */
-- 
1.6.0.6


