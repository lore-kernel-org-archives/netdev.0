From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH] net: Fix recvmmsg timeout handling
Date: Mon, 21 Jul 2014 16:21:31 -0300
Message-ID: <20140721192131.GA3212@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gatW/ieO32f1wygP"
Content-Transfer-Encoding: 8bit
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Friesen <chris.friesen@windriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Elie De Brauwer <eliedebrauwer@gmail.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai@seznam.cz>,
	Paul Moore <paul@paul-moore.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>,
	Steven Whitehouse <steve@chygwyn.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:38494 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755206AbaGUTVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 15:21:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi David,

	Trying to get this merged, finally. I has whas has been
discussed so far and agreed wrt the timeout handling.

	There is a separate issues related to possibly delivering errors to
threads that haven't caused them, for that I'll send a separate patch in
a minute.

	Michael et al, if you guys could please take a last look at
this, lets try to get this finally merged :-)

- Arnaldo

--gatW/ieO32f1wygP
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="0001-net-Fix-recvmmsg-timeout-handling.patch"
Content-Transfer-Encoding: 8bit

>From f58e6ca36075f0c0b48933e2e1fe59dec74cf6d7 Mon Sep 17 00:00:00 2001
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 18 Jul 2014 15:23:44 -0300
Subject: [PATCH 1/2] net: Fix recvmmsg timeout handling
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

As reported by Elie de Brauwer the timeout handling in the recvmmsg
syscall had issues that boil down to it not properly passing the
remaining time to each underlying recvmsg() call.

Fix it by adding a timeout pointer to the recvmsg implementations, so
that it can use that using a variation of sock_rcvtimeo, that overrides
the value in SO_RCVTIMEO with the timeout passed, and returns the
remaining time in that pointer, this way each underlying recvmsg call
receives the remaining time.

It ends up in most cases being just a forward of this pointer from
recvmmsg to skb_recv_datagram().

Reported-by: Elie De Brauwer <eliedebrauwer@gmail.com>
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Friesen <chris.friesen@windriver.com>
Cc: David Laight <David.Laight@ACULAB.COM>
Cc: Elie De Brauwer <eliedebrauwer@gmail.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Ondřej Bílka <neleai@seznam.cz>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Rémi Denis-Courmont <remi@remlab.net>
Cc: Steven Whitehouse <steve@chygwyn.com>
Link: http://lkml.kernel.org/n/tip-5tupdoo5hdfci7diirv0ugli@git.kernel.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 crypto/algif_hash.c               |  2 +-
 crypto/algif_skcipher.c           |  2 +-
 drivers/isdn/mISDN/socket.c       |  4 +-
 drivers/net/macvtap.c             |  2 +-
 drivers/net/ppp/pppoe.c           |  4 +-
 drivers/net/tun.c                 |  4 +-
 drivers/vhost/net.c               |  4 +-
 include/linux/net.h               |  7 +++-
 include/linux/skbuff.h            |  4 +-
 include/net/af_vsock.h            |  2 +-
 include/net/bluetooth/bluetooth.h |  4 +-
 include/net/inet_common.h         |  2 +-
 include/net/ping.h                |  2 +-
 include/net/sctp/sctp.h           |  2 +-
 include/net/sock.h                | 11 +++--
 include/net/tcp.h                 |  2 +-
 net/appletalk/ddp.c               |  4 +-
 net/atm/common.c                  |  4 +-
 net/atm/common.h                  |  2 +-
 net/ax25/af_ax25.c                |  4 +-
 net/bluetooth/af_bluetooth.c      | 10 +++--
 net/bluetooth/hci_sock.c          |  4 +-
 net/bluetooth/l2cap_sock.c        |  6 +--
 net/bluetooth/rfcomm/sock.c       |  4 +-
 net/bluetooth/sco.c               |  4 +-
 net/caif/caif_socket.c            | 10 +++--
 net/can/bcm.c                     |  4 +-
 net/can/raw.c                     |  4 +-
 net/core/datagram.c               | 19 ++++++---
 net/core/sock.c                   |  6 +--
 net/dccp/dccp.h                   |  2 +-
 net/dccp/proto.c                  |  6 ++-
 net/decnet/af_decnet.c            |  7 ++--
 net/ieee802154/dgram.c            |  4 +-
 net/ieee802154/raw.c              |  4 +-
 net/ipv4/af_inet.c                |  4 +-
 net/ipv4/ping.c                   |  4 +-
 net/ipv4/raw.c                    |  4 +-
 net/ipv4/tcp.c                    | 16 ++++---
 net/ipv4/udp.c                    |  4 +-
 net/ipv4/udp_impl.h               |  2 +-
 net/ipv6/raw.c                    |  4 +-
 net/ipv6/udp.c                    |  4 +-
 net/ipv6/udp_impl.h               |  2 +-
 net/ipx/af_ipx.c                  |  4 +-
 net/irda/af_irda.c                | 16 ++++---
 net/iucv/af_iucv.c                |  4 +-
 net/key/af_key.c                  |  4 +-
 net/l2tp/l2tp_ip.c                |  4 +-
 net/l2tp/l2tp_ip6.c               |  4 +-
 net/l2tp/l2tp_ppp.c               |  4 +-
 net/llc/af_llc.c                  |  6 ++-
 net/netlink/af_netlink.c          |  4 +-
 net/netrom/af_netrom.c            |  4 +-
 net/nfc/llcp_sock.c               |  4 +-
 net/nfc/rawsock.c                 |  4 +-
 net/packet/af_packet.c            |  4 +-
 net/phonet/datagram.c             |  4 +-
 net/phonet/pep.c                  |  6 +--
 net/rds/rds.h                     |  2 +-
 net/rds/recv.c                    |  6 ++-
 net/rose/af_rose.c                |  4 +-
 net/rxrpc/ar-input.c              |  2 +-
 net/rxrpc/ar-internal.h           |  2 +-
 net/rxrpc/ar-recvmsg.c            | 21 ++++++----
 net/sctp/socket.c                 | 18 ++++----
 net/sctp/ulpevent.c               |  2 +-
 net/socket.c                      | 87 +++++++++++++++++++++++++--------------
 net/sunrpc/svcsock.c              |  2 +-
 net/sunrpc/xprtsock.c             |  4 +-
 net/tipc/socket.c                 |  8 ++--
 net/unix/af_unix.c                | 23 ++++++-----
 net/vmw_vsock/af_vsock.c          | 10 +++--
 net/vmw_vsock/vmci_transport.c    |  4 +-
 net/x25/af_x25.c                  |  4 +-
 75 files changed, 276 insertions(+), 209 deletions(-)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 850246206b12..e5d36f815083 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -151,7 +151,7 @@ unlock:
 }
 
 static int hash_recvmsg(struct kiocb *unused, struct socket *sock,
-			struct msghdr *msg, size_t len, int flags)
+			struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index a19c027b29bd..4bde01591174 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -419,7 +419,7 @@ unlock:
 }
 
 static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
-			    struct msghdr *msg, size_t ignored, int flags)
+			    struct msghdr *msg, size_t ignored, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct alg_sock *ask = alg_sk(sk);
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 1be82284cf9d..254515f71793 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -113,7 +113,7 @@ mISDN_sock_cmsg(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 
 static int
 mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-		   struct msghdr *msg, size_t len, int flags)
+		   struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sk_buff		*skb;
 	struct sock		*sk = sock->sk;
@@ -130,7 +130,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (sk->sk_state == MISDN_CLOSED)
 		return 0;
 
-	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, timeop);
 	if (!skb)
 		return err;
 
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3381c4f91a8c..13d12ef322f2 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1111,7 +1111,7 @@ static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 			   struct msghdr *m, size_t total_len,
-			   int flags)
+			   int flags, long *timeop)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
 	int ret;
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 6c9c16d76935..dc82dee82548 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -963,7 +963,7 @@ static const struct ppp_channel_ops pppoe_chan_ops = {
 };
 
 static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *m, size_t total_len, int flags)
+		  struct msghdr *m, size_t total_len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -975,7 +975,7 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-				flags & MSG_DONTWAIT, &error);
+				flags & MSG_DONTWAIT, &error, timeop);
 	if (error < 0)
 		goto end;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index acaaf6784179..a84a2a2be9fb 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1343,7 +1343,7 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 
 	/* Read frames from queue */
 	skb = __skb_recv_datagram(tfile->socket.sk, noblock ? MSG_DONTWAIT : 0,
-				  &peeked, &off, &err);
+				  &peeked, &off, &err, NULL);
 	if (skb) {
 		ret = tun_put_user(tun, tfile, skb, iv, len);
 		kfree_skb(skb);
@@ -1452,7 +1452,7 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len,
-		       int flags)
+		       int flags, long *timeop)
 {
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
 	struct tun_struct *tun = __tun_get(tfile);
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8dae2f724a35..6cd829e78ab6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -602,7 +602,7 @@ static void handle_rx(struct vhost_net *net)
 		if (unlikely(headcount > UIO_MAXIOV)) {
 			msg.msg_iovlen = 1;
 			err = sock->ops->recvmsg(NULL, sock, &msg,
-						 1, MSG_DONTWAIT | MSG_TRUNC);
+						 1, MSG_DONTWAIT | MSG_TRUNC, NULL);
 			pr_debug("Discarded rx packet: len %zd\n", sock_len);
 			continue;
 		}
@@ -628,7 +628,7 @@ static void handle_rx(struct vhost_net *net)
 			copy_iovec_hdr(vq->iov, nvq->hdr, sock_hlen, in);
 		msg.msg_iovlen = in;
 		err = sock->ops->recvmsg(NULL, sock, &msg,
-					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
+					 sock_len, MSG_DONTWAIT | MSG_TRUNC, NULL);
 		/* Userspace might have consumed the packet meanwhile:
 		 * it's not supposed to do this usually, but might be hard
 		 * to prevent. Discard data we got (if any) and keep going. */
diff --git a/include/linux/net.h b/include/linux/net.h
index 17d83393afcc..fcbbda434ff4 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -171,10 +171,13 @@ struct proto_ops {
 	 * returning uninitialized memory to user space.  The recvfrom
 	 * handlers can assume that msg.msg_name is either NULL or has
 	 * a minimum size of sizeof(struct sockaddr_storage).
+	 * timeop contains a per call timeout (as opposed as per socket,
+	 * used by recvmmsg, set it to NULL to disable it. It should return
+	 * the remaining time, if not NULL.
 	 */
 	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
 				      struct msghdr *m, size_t total_len,
-				      int flags);
+				      int flags, long *timeop);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
@@ -215,7 +218,7 @@ int sock_create_lite(int family, int type, int proto, struct socket **res);
 void sock_release(struct socket *sock);
 int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len);
 int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
-		 int flags);
+		 int flags, long *timeop);
 struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname);
 struct socket *sockfd_lookup(int fd, int *err);
 struct socket *sock_from_file(struct file *file, int *err);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 369430340ed9..263c71a152cc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2520,9 +2520,9 @@ static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
-				    int *peeked, int *off, int *err);
+				    int *peeked, int *off, int *err, long *timeop);
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
-				  int *err);
+				  int *err, long *timeop);
 unsigned int datagram_poll(struct file *file, struct socket *sock,
 			   struct poll_table_struct *wait);
 int skb_copy_datagram_iovec(const struct sk_buff *from, int offset,
diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 428277869400..6c007bd57f39 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -101,7 +101,7 @@ struct vsock_transport {
 	/* DGRAM. */
 	int (*dgram_bind)(struct vsock_sock *, struct sockaddr_vm *);
 	int (*dgram_dequeue)(struct kiocb *kiocb, struct vsock_sock *vsk,
-			     struct msghdr *msg, size_t len, int flags);
+			     struct msghdr *msg, size_t len, int flags, long *timeop);
 	int (*dgram_enqueue)(struct vsock_sock *, struct sockaddr_vm *,
 			     struct iovec *, size_t len);
 	bool (*dgram_allow)(u32 cid, u32 port);
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
index 373000de610d..45b51c6ec672 100644
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -246,9 +246,9 @@ void bt_sock_unregister(int proto);
 void bt_sock_link(struct bt_sock_list *l, struct sock *s);
 void bt_sock_unlink(struct bt_sock_list *l, struct sock *s);
 int  bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *msg, size_t len, int flags);
+				struct msghdr *msg, size_t len, int flags, long *timeop);
 int  bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t len, int flags);
+			struct msghdr *msg, size_t len, int flags, long *timeop);
 uint bt_sock_poll(struct file *file, struct socket *sock, poll_table *wait);
 int  bt_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int  bt_sock_wait_state(struct sock *sk, int state, unsigned long timeo);
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index fe7994c48b75..f80071949b98 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -26,7 +26,7 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 		      size_t size, int flags);
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags);
+		 size_t size, int flags, long *timeop);
 int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
diff --git a/include/net/ping.h b/include/net/ping.h
index 026479b61a2d..c259ba72c811 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -76,7 +76,7 @@ int  ping_getfrag(void *from, char *to, int offset, int fraglen, int odd,
 		  struct sk_buff *);
 
 int  ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		  size_t len, int noblock, int flags, int *addr_len);
+		  size_t len, int noblock, int flags, int *addr_len, long *timeop);
 int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
 			 void *user_icmph, size_t icmph_len);
 int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 90c1cccd164d..0ac5735b2347 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -109,7 +109,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 		    struct sctp_association *asoc);
 extern struct percpu_counter sctp_sockets_allocated;
 int sctp_asconf_mgmt(struct sctp_sock *, struct sctp_sockaddr_entry *);
-struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *);
+struct sk_buff *sctp_skb_recv_datagram(struct sock *, int, int, int *, long *);
 
 /*
  * sctp/primitive.c
diff --git a/include/net/sock.h b/include/net/sock.h
index 28f734601b50..9c9a8929c102 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -979,7 +979,7 @@ struct proto {
 	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
 					   struct msghdr *msg,
 					   size_t len, int noblock, int flags,
-					   int *addr_len);
+					   int *addr_len, long *timeop);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk,
@@ -1611,7 +1611,7 @@ int sock_no_getsockopt(struct socket *, int , int, char __user *, int __user *);
 int sock_no_setsockopt(struct socket *, int, int, char __user *, unsigned int);
 int sock_no_sendmsg(struct kiocb *, struct socket *, struct msghdr *, size_t);
 int sock_no_recvmsg(struct kiocb *, struct socket *, struct msghdr *, size_t,
-		    int);
+		    int, long *);
 int sock_no_mmap(struct file *file, struct socket *sock,
 		 struct vm_area_struct *vma);
 ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
@@ -1624,7 +1624,7 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
 int sock_common_getsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, int __user *optlen);
 int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags);
+			       struct msghdr *msg, size_t size, int flags, long *timeop);
 int sock_common_setsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, unsigned int optlen);
 int compat_sock_common_getsockopt(struct socket *sock, int level,
@@ -2131,6 +2131,11 @@ static inline long sock_rcvtimeo(const struct sock *sk, bool noblock)
 	return noblock ? 0 : sk->sk_rcvtimeo;
 }
 
+static inline long sock_rcvtimeop(const struct sock *sk, long *timeop, bool noblock)
+{
+	return noblock ? 0 : (timeop ? *timeop : sk->sk_rcvtimeo);
+}
+
 static inline long sock_sndtimeo(const struct sock *sk, bool noblock)
 {
 	return noblock ? 0 : sk->sk_sndtimeo;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0aeb2eb749dc..7ac0bf016263 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -437,7 +437,7 @@ int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 void tcp_set_keepalive(struct sock *sk, int val);
 void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
 int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int nonblock, int flags, int *addr_len);
+		size_t len, int nonblock, int flags, int *addr_len, long *timeop);
 void tcp_parse_options(const struct sk_buff *skb,
 		       struct tcp_options_received *opt_rx,
 		       int estab, struct tcp_fastopen_cookie *foc);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index c00897f65a31..82b05f942d22 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1729,7 +1729,7 @@ out:
 }
 
 static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-			 size_t size, int flags)
+			 size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct ddpehdr *ddp;
@@ -1739,7 +1739,7 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	struct sk_buff *skb;
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-						flags & MSG_DONTWAIT, &err);
+						flags & MSG_DONTWAIT, &err, timeop);
 	lock_sock(sk);
 
 	if (!skb)
diff --git a/net/atm/common.c b/net/atm/common.c
index 7b491006eaf4..8def66eaed87 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -524,7 +524,7 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 }
 
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int flags)
+		size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
@@ -544,7 +544,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	    !test_bit(ATM_VF_READY, &vcc->flags))
 		return 0;
 
-	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &error, timeop);
 	if (!skb)
 		return error;
 
diff --git a/net/atm/common.h b/net/atm/common.h
index cc3c2dae4d79..b370ffd78a39 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -14,7 +14,7 @@ int vcc_create(struct net *net, struct socket *sock, int protocol, int family);
 int vcc_release(struct socket *sock);
 int vcc_connect(struct socket *sock, int itf, short vpi, int vci);
 int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int flags);
+		size_t size, int flags, long *timeop);
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		size_t total_len);
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index c35c3f48fc0f..ee0411920216 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1600,7 +1600,7 @@ out:
 }
 
 static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, size_t size, int flags)
+	struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -1619,7 +1619,7 @@ static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	/* Now we can treat all alike */
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-				flags & MSG_DONTWAIT, &err);
+				flags & MSG_DONTWAIT, &err, timeop);
 	if (skb == NULL)
 		goto out;
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 4dca0299ed96..21a28e5f5c7c 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -209,7 +209,7 @@ struct sock *bt_accept_dequeue(struct sock *parent, struct socket *newsock)
 EXPORT_SYMBOL(bt_accept_dequeue);
 
 int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *msg, size_t len, int flags)
+				struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -222,7 +222,7 @@ int bt_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb) {
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
 			return 0;
@@ -282,7 +282,7 @@ static long bt_sock_data_wait(struct sock *sk, long timeo)
 }
 
 int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+			       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	int err = 0;
@@ -297,7 +297,7 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	lock_sock(sk);
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
-	timeo  = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	timeo  = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 
 	do {
 		struct sk_buff *skb;
@@ -381,6 +381,8 @@ int bt_sock_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	} while (size);
 
 out:
+	if (timeop)
+		*timeop = timeo;
 	release_sock(sk);
 	return copied ? : err;
 }
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index c64728d571ae..b13686691630 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -833,7 +833,7 @@ static void hci_sock_cmsg(struct sock *sk, struct msghdr *msg,
 }
 
 static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len, int flags)
+			    struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -848,7 +848,7 @@ static int hci_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (sk->sk_state == BT_CLOSED)
 		return 0;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		return err;
 
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 9bb4d1b3a483..dfce9a46aff4 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -972,7 +972,7 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 static int l2cap_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t len, int flags)
+			      struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct l2cap_pinfo *pi = l2cap_pi(sk);
@@ -999,9 +999,9 @@ static int l2cap_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	release_sock(sk);
 
 	if (sock->type == SOCK_STREAM)
-		err = bt_sock_stream_recvmsg(iocb, sock, msg, len, flags);
+		err = bt_sock_stream_recvmsg(iocb, sock, msg, len, flags, timeop);
 	else
-		err = bt_sock_recvmsg(iocb, sock, msg, len, flags);
+		err = bt_sock_recvmsg(iocb, sock, msg, len, flags, timeop);
 
 	if (pi->chan->mode != L2CAP_MODE_ERTM)
 		return err;
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index c603a5eb4720..a3cbf8c4daf5 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -617,7 +617,7 @@ done:
 }
 
 static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+			       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct rfcomm_dlc *d = rfcomm_pi(sk)->dlc;
@@ -628,7 +628,7 @@ static int rfcomm_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return 0;
 	}
 
-	len = bt_sock_stream_recvmsg(iocb, sock, msg, size, flags);
+	len = bt_sock_stream_recvmsg(iocb, sock, msg, size, flags, timeop);
 
 	lock_sock(sk);
 	if (!(flags & MSG_PEEK) && len > 0)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index c06dbd3938e8..bfaa16bdc366 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -700,7 +700,7 @@ static void sco_conn_defer_accept(struct hci_conn *conn, u16 setting)
 }
 
 static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *msg, size_t len, int flags)
+			    struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sco_pinfo *pi = sco_pi(sk);
@@ -718,7 +718,7 @@ static int sco_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	release_sock(sk);
 
-	return bt_sock_recvmsg(iocb, sock, msg, len, flags);
+	return bt_sock_recvmsg(iocb, sock, msg, len, flags, timeop);
 }
 
 static int sco_sock_setsockopt(struct socket *sock, int level, int optname, char __user *optval, unsigned int optlen)
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 43f750e88e19..1528e1583f1c 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -272,7 +272,7 @@ static void caif_check_flow_release(struct sock *sk)
  * changed locking, address handling and added MSG_TRUNC.
  */
 static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *m, size_t len, int flags)
+			       struct msghdr *m, size_t len, int flags, long *timeop)
 
 {
 	struct sock *sk = sock->sk;
@@ -284,7 +284,7 @@ static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (m->msg_flags&MSG_OOB)
 		goto read_error;
 
-	skb = skb_recv_datagram(sk, flags, 0 , &ret);
+	skb = skb_recv_datagram(sk, flags, 0 , &ret, timeop);
 	if (!skb)
 		goto read_error;
 	copylen = skb->len;
@@ -345,7 +345,7 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
  */
 static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
-			       int flags)
+			       int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	int copied = 0;
@@ -367,7 +367,7 @@ static int caif_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	caif_read_lock(sk);
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
-	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
+	timeo = sock_rcvtimeop(sk, timeop, flags&MSG_DONTWAIT);
 
 	do {
 		int chunk;
@@ -450,6 +450,8 @@ unlock:
 	caif_read_unlock(sk);
 
 out:
+	if (timeop)
+		*timeop = timeo;
 	return copied ? : err;
 }
 
diff --git a/net/can/bcm.c b/net/can/bcm.c
index dcb75c0e66c1..dc12c80ec5cd 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1541,7 +1541,7 @@ static int bcm_connect(struct socket *sock, struct sockaddr *uaddr, int len,
 }
 
 static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size, int flags)
+		       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -1551,7 +1551,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	noblock =  flags & MSG_DONTWAIT;
 	flags   &= ~MSG_DONTWAIT;
-	skb = skb_recv_datagram(sk, flags, noblock, &error);
+	skb = skb_recv_datagram(sk, flags, noblock, &error, timeop);
 	if (!skb)
 		return error;
 
diff --git a/net/can/raw.c b/net/can/raw.c
index 081e81fd017f..0a4aa9d98e5e 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -731,7 +731,7 @@ send_failed:
 }
 
 static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size, int flags)
+		       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -741,7 +741,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	noblock =  flags & MSG_DONTWAIT;
 	flags   &= ~MSG_DONTWAIT;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		return err;
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 488dd1a825c0..856e18c586c6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -138,6 +138,9 @@ out_noerr:
  *	@off: an offset in bytes to peek skb from. Returns an offset
  *	      within an skb where data actually starts
  *	@err: error code returned
+ *	@timeop: per call timeout (as opposed as per socket via SO_RCVTIMEO),
+ *		 will return the remaining time, used in recvmmsg, ignored
+ *		 if set to NULL.
  *
  *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
  *	and possible races. This replaces identical code in packet, raw and
@@ -162,7 +165,7 @@ out_noerr:
  *	the standard around please.
  */
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
-				    int *peeked, int *off, int *err)
+				    int *peeked, int *off, int *err, long *timeop)
 {
 	struct sk_buff *skb, *last;
 	long timeo;
@@ -174,7 +177,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 	if (error)
 		goto no_packet;
 
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	timeo = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 
 	do {
 		/* Again only user level code calls this function, so nothing
@@ -205,6 +208,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 
 			spin_unlock_irqrestore(&queue->lock, cpu_flags);
 			*off = _off;
+			if (timeop)
+				*timeop = timeo;
 			return skb;
 		}
 		spin_unlock_irqrestore(&queue->lock, cpu_flags);
@@ -219,22 +224,24 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 			goto no_packet;
 
 	} while (!wait_for_more_packets(sk, err, &timeo, last));
-
+out:
+	if (timeop)
+		*timeop = timeo;
 	return NULL;
 
 no_packet:
 	*err = error;
-	return NULL;
+	goto out;
 }
 EXPORT_SYMBOL(__skb_recv_datagram);
 
 struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned int flags,
-				  int noblock, int *err)
+				  int noblock, int *err, long *timeop)
 {
 	int peeked, off = 0;
 
 	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				   &peeked, &off, err);
+				   &peeked, &off, err, timeop);
 }
 EXPORT_SYMBOL(skb_recv_datagram);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 026e01f70274..b462e38785af 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2191,7 +2191,7 @@ int sock_no_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 EXPORT_SYMBOL(sock_no_sendmsg);
 
 int sock_no_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		    size_t len, int flags)
+		    size_t len, int flags, long *timeop)
 {
 	return -EOPNOTSUPP;
 }
@@ -2577,14 +2577,14 @@ EXPORT_SYMBOL(compat_sock_common_getsockopt);
 #endif
 
 int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size, int flags)
+			struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
 	int err;
 
 	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
-				   flags & ~MSG_DONTWAIT, &addr_len);
+				   flags & ~MSG_DONTWAIT, &addr_len, timeop);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index c67816647cce..fbf4cc113ffe 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -314,7 +314,7 @@ int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 size_t size);
 int dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
 		 struct msghdr *msg, size_t len, int nonblock, int flags,
-		 int *addr_len);
+		 int *addr_len, long *timeop);
 void dccp_shutdown(struct sock *sk, int how);
 int inet_dccp_listen(struct socket *sock, int backlog);
 unsigned int dccp_poll(struct file *file, struct socket *sock,
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index de2c1e719305..92ae3d37c7f0 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -808,7 +808,7 @@ out_discard:
 EXPORT_SYMBOL_GPL(dccp_sendmsg);
 
 int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len, int nonblock, int flags, int *addr_len)
+		 size_t len, int nonblock, int flags, int *addr_len, long *timeop)
 {
 	const struct dccp_hdr *dh;
 	long timeo;
@@ -820,7 +820,7 @@ int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out;
 	}
 
-	timeo = sock_rcvtimeo(sk, nonblock);
+	timeo = sock_rcvtimeop(sk, timeop, nonblock);
 
 	do {
 		struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
@@ -910,6 +910,8 @@ verify_sock_status:
 	} while (1);
 out:
 	release_sock(sk);
+	if (timeop)
+		*timeop = timeo;
 	return len;
 }
 
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index ae011b46c071..86dfcbe505de 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1669,7 +1669,7 @@ static int dn_data_ready(struct sock *sk, struct sk_buff_head *q, int flags, int
 
 
 static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
-	struct msghdr *msg, size_t size, int flags)
+	struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
@@ -1680,7 +1680,7 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb, *n;
 	struct dn_skb_cb *cb = NULL;
 	unsigned char eor = 0;
-	long timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	long timeo = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 
 	lock_sock(sk);
 
@@ -1814,7 +1814,8 @@ out:
 	}
 
 	release_sock(sk);
-
+	if (timeop)
+		*timeop = timeo;
 	return rv;
 }
 
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index ef2ad8aaef13..f875df985a39 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -306,14 +306,14 @@ out:
 
 static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t len, int noblock,
-			 int flags, int *addr_len)
+			 int flags, int *addr_len, long *timeop)
 {
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sk_buff *skb;
 	DECLARE_SOCKADDR(struct sockaddr_ieee802154 *, saddr, msg->msg_name);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 9d1f64806f02..8ae39c7849c3 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -179,13 +179,13 @@ out:
 }
 
 static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len, int noblock, int flags, int *addr_len)
+		       size_t len, int noblock, int flags, int *addr_len, long *timeop)
 {
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sk_buff *skb;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d5e6836cf772..2dd513c6c643 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -757,7 +757,7 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 EXPORT_SYMBOL(inet_sendpage);
 
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags)
+		 size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	int addr_len = 0;
@@ -766,7 +766,7 @@ int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	sock_rps_record_flow(sk);
 
 	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
-				   flags & ~MSG_DONTWAIT, &addr_len);
+				   flags & ~MSG_DONTWAIT, &addr_len, timeop);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
 	return err;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 044a0ddf6a79..791be60b38f1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -840,7 +840,7 @@ do_confirm:
 }
 
 int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len, int noblock, int flags, int *addr_len)
+		 size_t len, int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct inet_sock *isk = inet_sk(sk);
 	int family = sk->sk_family;
@@ -864,7 +864,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		}
 	}
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2054d7136c62..6921b016513a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -689,7 +689,7 @@ out:	return ret;
  */
 
 static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len, int noblock, int flags, int *addr_len)
+		       size_t len, int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
@@ -705,7 +705,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out;
 	}
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d2118e5fbc7..0572060f83aa 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1602,7 +1602,7 @@ EXPORT_SYMBOL(tcp_read_sock);
  */
 
 int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int nonblock, int flags, int *addr_len)
+		size_t len, int nonblock, int flags, int *addr_len, long *timeop)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int copied = 0;
@@ -1627,7 +1627,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (sk->sk_state == TCP_LISTEN)
 		goto out;
 
-	timeo = sock_rcvtimeo(sk, nonblock);
+	timeo = sock_rcvtimeop(sk, timeop, nonblock);
 
 	/* Urgent data needs to be handled specially. */
 	if (flags & MSG_OOB)
@@ -1994,20 +1994,18 @@ skip_copy:
 
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
-
-	release_sock(sk);
-	return copied;
-
 out:
 	release_sock(sk);
-	return err;
+	if (timeop)
+		*timeop = timeo;
+	return copied;
 
 recv_urg:
-	err = tcp_recv_urg(sk, msg, len, flags);
+	copied = tcp_recv_urg(sk, msg, len, flags);
 	goto out;
 
 recv_sndq:
-	err = tcp_peek_sndq(sk, msg, len);
+	copied = tcp_peek_sndq(sk, msg, len);
 	goto out;
 }
 EXPORT_SYMBOL(tcp_recvmsg);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f31053b90ee0..5e88e79e7d6f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1241,7 +1241,7 @@ EXPORT_SYMBOL(udp_ioctl);
  */
 
 int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len)
+		size_t len, int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
@@ -1257,7 +1257,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+				  &peeked, &off, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index f3c27899f62b..a39aa9996b72 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -22,7 +22,7 @@ int compat_udp_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen);
 #endif
 int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len);
+		size_t len, int noblock, int flags, int *addr_len, long *timeop);
 int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
 int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dee80fb1aa86..0d209b336d34 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -458,7 +458,7 @@ int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 
 static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		  struct msghdr *msg, size_t len,
-		  int noblock, int flags, int *addr_len)
+		  int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
@@ -475,7 +475,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (np->rxpmtu && np->rxopt.bits.rxpmtu)
 		return ipv6_recv_rxpmtu(sk, msg, len, addr_len);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f9d8800bb72f..78c1fab2b469 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -379,7 +379,7 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
 int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		  struct msghdr *msg, size_t len,
-		  int noblock, int flags, int *addr_len)
+		  int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
@@ -399,7 +399,7 @@ int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 try_again:
 	skb = __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
-				  &peeked, &off, &err);
+				  &peeked, &off, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index c779c3c90b9d..cd414d719977 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -26,7 +26,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		  size_t len);
 int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		  size_t len, int noblock, int flags, int *addr_len);
+		  size_t len, int noblock, int flags, int *addr_len, long *timeop);
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 void udpv6_destroy_sock(struct sock *sk);
 
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 91729b807c7d..4964c1e0ab03 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1756,7 +1756,7 @@ out:
 
 
 static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
-		struct msghdr *msg, size_t size, int flags)
+		struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
@@ -1791,7 +1791,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-				flags & MSG_DONTWAIT, &rc);
+				flags & MSG_DONTWAIT, &rc, timeop);
 	if (!skb) {
 		if (rc == -EAGAIN && (sk->sk_shutdown & RCV_SHUTDOWN))
 			rc = 0;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 92fafd485deb..23406cde0f1c 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1372,7 +1372,7 @@ out:
  *    after being read, regardless of how much the user actually read
  */
 static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
-			      struct msghdr *msg, size_t size, int flags)
+			      struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1383,7 +1383,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-				flags & MSG_DONTWAIT, &err);
+				flags & MSG_DONTWAIT, &err, timeop);
 	if (!skb)
 		return err;
 
@@ -1421,7 +1421,7 @@ static int irda_recvmsg_dgram(struct kiocb *iocb, struct socket *sock,
  * Function irda_recvmsg_stream (iocb, sock, msg, size, flags)
  */
 static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
-			       struct msghdr *msg, size_t size, int flags)
+			       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct irda_sock *self = irda_sk(sk);
@@ -1444,7 +1444,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 	err = 0;
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
-	timeo = sock_rcvtimeo(sk, noblock);
+	timeo = sock_rcvtimeop(sk, timeop, noblock);
 
 	do {
 		int chunk;
@@ -1479,8 +1479,10 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 
 			finish_wait(sk_sleep(sk), &wait);
 
-			if (err)
-				return err;
+			if (err) {
+				copied = err;
+				break;
+			}
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 
@@ -1533,6 +1535,8 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 		}
 	}
 
+	if (timeop)
+		*timeop = timeo;
 	return copied;
 }
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index d79f5fb695b8..256c4945a854 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1320,7 +1320,7 @@ static void iucv_process_message_q(struct sock *sk)
 }
 
 static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len, int flags)
+			     struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -1341,7 +1341,7 @@ static int iucv_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	/* receive/dequeue next skb:
 	 * the function understands MSG_PEEK and, thus, does not dequeue skb */
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb) {
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
 			return 0;
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1847ec4e3930..1c0374034c35 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3632,7 +3632,7 @@ out:
 
 static int pfkey_recvmsg(struct kiocb *kiocb,
 			 struct socket *sock, struct msghdr *msg, size_t len,
-			 int flags)
+			 int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct pfkey_sock *pfk = pfkey_sk(sk);
@@ -3643,7 +3643,7 @@ static int pfkey_recvmsg(struct kiocb *kiocb,
 	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
 		goto out;
 
-	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, timeop);
 	if (skb == NULL)
 		goto out;
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 369a9822488c..4347233855cb 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -507,7 +507,7 @@ no_route:
 }
 
 static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-			   size_t len, int noblock, int flags, int *addr_len)
+			   size_t len, int noblock, int flags, int *addr_len, long *timeop)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
@@ -518,7 +518,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	if (flags & MSG_OOB)
 		goto out;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index f3f98a156cee..6c839ba9d299 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -645,7 +645,7 @@ do_confirm:
 
 static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len, int noblock,
-			    int flags, int *addr_len)
+			    int flags, int *addr_len, long *timeop)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
@@ -662,7 +662,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	if (flags & MSG_ERRQUEUE)
 		return ipv6_recv_error(sk, msg, len, addr_len);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 13752d96275e..88558464319b 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -187,7 +187,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
  */
 static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock,
 			    struct msghdr *msg, size_t len,
-			    int flags)
+			    int flags, long *timeop)
 {
 	int err;
 	struct sk_buff *skb;
@@ -199,7 +199,7 @@ static int pppol2tp_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	err = 0;
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-				flags & MSG_DONTWAIT, &err);
+				flags & MSG_DONTWAIT, &err, timeop);
 	if (!skb)
 		goto end;
 
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 0080d2b0a8ae..b5edf838f9fa 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -705,7 +705,7 @@ out:
  *	Returns non-negative upon success, negative otherwise.
  */
 static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, size_t len, int flags)
+			  struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	DECLARE_SOCKADDR(struct sockaddr_llc *, uaddr, msg->msg_name);
 	const int nonblock = flags & MSG_DONTWAIT;
@@ -725,7 +725,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (unlikely(sk->sk_type == SOCK_STREAM && sk->sk_state == TCP_LISTEN))
 		goto out;
 
-	timeo = sock_rcvtimeo(sk, nonblock);
+	timeo = sock_rcvtimeop(sk, timeop, nonblock);
 
 	seq = &llc->copied_seq;
 	if (flags & MSG_PEEK) {
@@ -851,6 +851,8 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 out:
 	release_sock(sk);
+	if (timeop)
+		*timeop = timeo;
 	return copied;
 copy_uaddr:
 	if (uaddr != NULL && skb != NULL) {
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1b38f7fe12f1..c7272c505a94 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2399,7 +2399,7 @@ out:
 
 static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, size_t len,
-			   int flags)
+			   int flags, long *timeop)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct scm_cookie scm;
@@ -2415,7 +2415,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 
 	copied = 0;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (skb == NULL)
 		goto out;
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 71cf1bffea06..fda7cb949290 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1134,7 +1134,7 @@ out:
 }
 
 static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
-		      struct msghdr *msg, size_t size, int flags)
+		      struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	DECLARE_SOCKADDR(struct sockaddr_ax25 *, sax, msg->msg_name);
@@ -1154,7 +1154,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	/* Now we can treat all alike */
-	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er)) == NULL) {
+	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er, timeop)) == NULL) {
 		release_sock(sk);
 		return er;
 	}
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 51f077a92fa9..0b233d1f1a57 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -794,7 +794,7 @@ static int llcp_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			     struct msghdr *msg, size_t len, int flags)
+			     struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -817,7 +817,7 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb) {
 		pr_err("Recv datagram failed state %d %d %d",
 		       sk->sk_state, err, sock_error(sk));
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index 11c3544ea546..ab84d8740fe4 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -249,7 +249,7 @@ static int rawsock_sendmsg(struct kiocb *iocb, struct socket *sock,
 }
 
 static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
-			   struct msghdr *msg, size_t len, int flags)
+			   struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
@@ -259,7 +259,7 @@ static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	pr_debug("sock=%p sk=%p len=%zu flags=%d\n", sock, sk, len, flags);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &rc);
+	skb = skb_recv_datagram(sk, flags, noblock, &rc, timeop);
 	if (!skb)
 		return rc;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 614ca91f785a..9728bce0326b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2852,7 +2852,7 @@ out:
  */
 
 static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			  struct msghdr *msg, size_t len, int flags)
+			  struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
@@ -2884,7 +2884,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	but then it will block.
 	 */
 
-	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err);
+	skb = skb_recv_datagram(sk, flags, flags & MSG_DONTWAIT, &err, timeop);
 
 	/*
 	 *	An error occurred so return it. Because skb_recv_datagram()
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 290352c0e6b4..77eff48eeb83 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -127,7 +127,7 @@ static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+			int flags, int *addr_len, long *timeop)
 {
 	struct sk_buff *skb = NULL;
 	struct sockaddr_pn sa;
@@ -138,7 +138,7 @@ static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
 			MSG_CMSG_COMPAT))
 		goto out_nofree;
 
-	skb = skb_recv_datagram(sk, flags, noblock, &rval);
+	skb = skb_recv_datagram(sk, flags, noblock, &rval, timeop);
 	if (skb == NULL)
 		goto out_nofree;
 
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 70a547ea5177..c5832e1958f8 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -783,7 +783,7 @@ static struct sock *pep_sock_accept(struct sock *sk, int flags, int *errp)
 	u8 pipe_handle, enabled, n_sb;
 	u8 aligned = 0;
 
-	skb = skb_recv_datagram(sk, 0, flags & O_NONBLOCK, errp);
+	skb = skb_recv_datagram(sk, 0, flags & O_NONBLOCK, errp, NULL);
 	if (!skb)
 		return NULL;
 
@@ -1248,7 +1248,7 @@ struct sk_buff *pep_read(struct sock *sk)
 
 static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+			int flags, int *addr_len, long *timeop)
 {
 	struct sk_buff *skb;
 	int err;
@@ -1277,7 +1277,7 @@ static int pep_recvmsg(struct kiocb *iocb, struct sock *sk,
 			return -EINVAL;
 	}
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skb = skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	lock_sock(sk);
 	if (skb == NULL) {
 		if (err == -ENOTCONN && sk->sk_state == TCP_CLOSE_WAIT)
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 48f8ffc60f8f..e511e569bbc9 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -706,7 +706,7 @@ void rds_inc_put(struct rds_incoming *inc);
 void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		       struct rds_incoming *inc, gfp_t gfp);
 int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int msg_flags);
+		size_t size, int msg_flags, long *timeop);
 void rds_clear_recv_queue(struct rds_sock *rs);
 int rds_notify_queue_get(struct rds_sock *rs, struct msghdr *msg);
 void rds_inc_info_copy(struct rds_incoming *inc,
diff --git a/net/rds/recv.c b/net/rds/recv.c
index bd82522534fc..6223a4b0fded 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -396,7 +396,7 @@ static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg)
 }
 
 int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
-		size_t size, int msg_flags)
+		size_t size, int msg_flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct rds_sock *rs = rds_sk_to_rs(sk);
@@ -406,7 +406,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct rds_incoming *inc = NULL;
 
 	/* udp_recvmsg()->sock_recvtimeo() gets away without locking too.. */
-	timeo = sock_rcvtimeo(sk, nonblock);
+	timeo = sock_rcvtimeop(sk, timeop, nonblock);
 
 	rdsdebug("size %zu flags 0x%x timeo %ld\n", size, msg_flags, timeo);
 
@@ -493,6 +493,8 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		rds_inc_put(inc);
 
 out:
+	if (timeop)
+		*timeop = timeo;
 	return ret;
 }
 
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index a85c1a086ae4..76ef9fd187b3 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1212,7 +1212,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 
 static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size, int flags)
+			struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct rose_sock *rose = rose_sk(sk);
@@ -1229,7 +1229,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return -ENOTCONN;
 
 	/* Now we can treat all alike */
-	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er)) == NULL)
+	if ((skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT, flags & MSG_DONTWAIT, &er, timeop)) == NULL)
 		return er;
 
 	qbit = (skb->data[0] & ROSE_Q_BIT) == ROSE_Q_BIT;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 63b21e580de9..2319fae4b1f6 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -655,7 +655,7 @@ void rxrpc_data_ready(struct sock *sk)
 		return;
 	}
 
-	skb = skb_recv_datagram(sk, 0, 1, &ret);
+	skb = skb_recv_datagram(sk, 0, 1, &ret, NULL);
 	if (!skb) {
 		rxrpc_put_local(local);
 		if (ret == -EAGAIN)
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index ba9fd36d3f15..a21e51937e27 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -573,7 +573,7 @@ extern const struct file_operations rxrpc_connection_seq_fops;
  */
 void rxrpc_remove_user_ID(struct rxrpc_sock *, struct rxrpc_call *);
 int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *, size_t,
-		  int);
+		  int, long *);
 
 /*
  * ar-security.c
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index e9aaa65c0778..e9082ed598cd 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -44,7 +44,7 @@ void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
  *   simultaneously
  */
 int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
-		  struct msghdr *msg, size_t len, int flags)
+		  struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_call *call = NULL, *continue_call = NULL;
@@ -63,7 +63,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	ullen = msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned long);
 
-	timeo = sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
+	timeo = sock_rcvtimeop(&rx->sk, timeop, flags & MSG_DONTWAIT);
 	msg->msg_flags |= MSG_MORE;
 
 	lock_sock(&rx->sk);
@@ -78,7 +78,8 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				release_sock(&rx->sk);
 				if (continue_call)
 					rxrpc_put_call(continue_call);
-				return -ENODATA;
+				copied = -ENODATA;
+				goto out_copied;
 			}
 		}
 
@@ -135,7 +136,7 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 				release_sock(&rx->sk);
 				rxrpc_put_call(continue_call);
 				_leave(" = %d [noncont]", copied);
-				return copied;
+				goto out_copied;
 			}
 		}
 
@@ -252,6 +253,9 @@ out:
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	_leave(" = %d [data]", copied);
+out_copied:
+	if (timeop)
+		*timeop = timeo;
 	return copied;
 
 	/* handle non-DATA messages such as aborts, incoming connections and
@@ -328,7 +332,8 @@ terminal_message:
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	_leave(" = %d", ret);
-	return ret;
+	copied = ret;
+	goto out_copied;
 
 copy_error:
 	_debug("copy error");
@@ -337,7 +342,8 @@ copy_error:
 	if (continue_call)
 		rxrpc_put_call(continue_call);
 	_leave(" = %d", ret);
-	return ret;
+	copied = ret;
+	goto out_copied;
 
 wait_interrupted:
 	ret = sock_intr_errno(timeo);
@@ -348,8 +354,7 @@ wait_error:
 	if (copied)
 		copied = ret;
 	_leave(" = %d [waitfail %d]", copied, ret);
-	return copied;
-
+	goto out_copied;
 }
 
 /**
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 743308f40544..90924fb819ee 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2062,7 +2062,7 @@ static int sctp_skb_pull(struct sk_buff *skb, int len)
  */
 static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len, int noblock,
-			int flags, int *addr_len)
+			int flags, int *addr_len, long *timeop)
 {
 	struct sctp_ulpevent *event = NULL;
 	struct sctp_sock *sp = sctp_sk(sk);
@@ -2082,7 +2082,7 @@ static int sctp_recvmsg(struct kiocb *iocb, struct sock *sk,
 		goto out;
 	}
 
-	skb = sctp_skb_recv_datagram(sk, flags, noblock, &err);
+	skb = sctp_skb_recv_datagram(sk, flags, noblock, &err, timeop);
 	if (!skb)
 		goto out;
 
@@ -6741,13 +6741,13 @@ out:
  * with a few changes to make lksctp work.
  */
 struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
-				       int noblock, int *err)
+				       int noblock, int *err, long *timeop)
 {
 	int error;
 	struct sk_buff *skb;
 	long timeo;
 
-	timeo = sock_rcvtimeo(sk, noblock);
+	timeo = sock_rcvtimeop(sk, timeop, noblock);
 
 	pr_debug("%s: timeo:%ld, max:%ld\n", __func__, timeo,
 		 MAX_SCHEDULE_TIMEOUT);
@@ -6771,7 +6771,7 @@ struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 		}
 
 		if (skb)
-			return skb;
+			break;
 
 		/* Caller is allowed not to check sk->sk_err before calling. */
 		error = sock_error(sk);
@@ -6791,11 +6791,15 @@ struct sk_buff *sctp_skb_recv_datagram(struct sock *sk, int flags,
 			goto no_packet;
 	} while (sctp_wait_for_packet(sk, err, &timeo) == 0);
 
-	return NULL;
+out:
+	if (timeop)
+		*timeop = timeo;
+
+	return skb;
 
 no_packet:
 	*err = error;
-	return NULL;
+	goto out;
 }
 
 /* If sndbuf has changed, wake up per association sndbuf waiters.  */
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index e049298ecfa0..e555d5d02c73 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -940,7 +940,7 @@ void sctp_ulpevent_read_nxtinfo(const struct sctp_ulpevent *event,
 	struct sk_buff *skb;
 	int err;
 
-	skb = sctp_skb_recv_datagram(sk, MSG_PEEK, 1, &err);
+	skb = sctp_skb_recv_datagram(sk, MSG_PEEK, 1, &err, NULL);
 	if (skb != NULL) {
 		__sctp_ulpevent_read_nxtinfo(sctp_skb2event(skb),
 					     msghdr, skb);
diff --git a/net/socket.c b/net/socket.c
index abf56b2a14f9..310a50971769 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -772,7 +772,7 @@ void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 
 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
-				       struct msghdr *msg, size_t size, int flags)
+				       struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
@@ -782,19 +782,19 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 	si->size = size;
 	si->flags = flags;
 
-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	return sock->ops->recvmsg(iocb, sock, msg, size, flags, timeop);
 }
 
 static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size, int flags)
+				 struct msghdr *msg, size_t size, int flags, long *timeop)
 {
 	int err = security_socket_recvmsg(sock, msg, size, flags);
 
-	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
+	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags, timeop);
 }
 
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
-		 size_t size, int flags)
+		 size_t size, int flags, long *timeop)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -802,7 +802,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
-	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
+	ret = __sock_recvmsg(&iocb, sock, msg, size, flags, timeop);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
@@ -810,7 +810,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 EXPORT_SYMBOL(sock_recvmsg);
 
 static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
-			      size_t size, int flags)
+			      size_t size, int flags, long *timeop)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;
@@ -818,7 +818,7 @@ static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
-	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags, timeop);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
 	return ret;
@@ -851,7 +851,7 @@ int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
 	msg->msg_iov = (struct iovec *)vec, msg->msg_iovlen = num;
-	result = sock_recvmsg(sock, msg, size, flags);
+	result = sock_recvmsg(sock, msg, size, flags, NULL);
 	set_fs(oldfs);
 	return result;
 }
@@ -914,7 +914,7 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_iovlen = nr_segs;
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
-	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
+	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags, NULL);
 }
 
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -1862,7 +1862,7 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	msg.msg_namelen = 0;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err = sock_recvmsg(sock, &msg, size, flags);
+	err = sock_recvmsg(sock, &msg, size, flags, NULL);
 
 	if (err >= 0 && addr != NULL) {
 		err2 = move_addr_to_user(&address,
@@ -2207,7 +2207,7 @@ SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
 }
 
 static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned int flags, int nosec)
+			 struct msghdr *msg_sys, unsigned int flags, int nosec, long *timeop)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -2265,7 +2265,7 @@ static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	err = (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
-							  total_len, flags);
+							  total_len, flags, timeop);
 	if (err < 0)
 		goto out_freeiov;
 	len = err;
@@ -2312,7 +2312,7 @@ long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags)
 	if (!sock)
 		goto out;
 
-	err = ___sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+	err = ___sys_recvmsg(sock, msg, &msg_sys, flags, 0, NULL);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2327,6 +2327,30 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	return __sys_recvmsg(fd, msg, flags);
 }
 
+static int sock_set_timeout_ts(long *timeo_p, struct timespec *ts)
+{
+	if (ts->tv_nsec < 0 || ts->tv_nsec >= NSEC_PER_SEC)
+		return -EDOM;
+
+	if (ts->tv_sec < 0) {
+		static int warned __read_mostly;
+
+		*timeo_p = 0;
+		if (warned < 10 && net_ratelimit()) {
+			warned++;
+			pr_info("%s: `%s' (pid %d) tries to set negative timeout\n",
+				__func__, current->comm, task_pid_nr(current));
+		}
+		return 0;
+	}
+	*timeo_p = MAX_SCHEDULE_TIMEOUT;
+	if (ts->tv_sec == 0 && ts->tv_nsec == 0)
+		return 0;
+	if (ts->tv_sec < (MAX_SCHEDULE_TIMEOUT / HZ - 1))
+		*timeo_p = ts->tv_sec * HZ + (ts->tv_nsec + (NSEC_PER_SEC / HZ - 1)) / (NSEC_PER_SEC / HZ);
+	return 0;
+}
+
 /*
  *     Linux recvmmsg interface
  */
@@ -2339,12 +2363,14 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct mmsghdr __user *entry;
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
-	struct timespec end_time;
+	long timeout_hz, *timeop = NULL;
 
-	if (timeout &&
-	    poll_select_set_timeout(&end_time, timeout->tv_sec,
-				    timeout->tv_nsec))
-		return -EINVAL;
+	if (timeout) {
+		err = sock_set_timeout_ts(&timeout_hz, timeout);
+		if (err)
+			return err;
+		timeop = &timeout_hz;
+	}
 
 	datagrams = 0;
 
@@ -2366,7 +2392,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		if (MSG_CMSG_COMPAT & flags) {
 			err = ___sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
 					     &msg_sys, flags & ~MSG_WAITFORONE,
-					     datagrams);
+					     datagrams, timeop);
 			if (err < 0)
 				break;
 			err = __put_user(err, &compat_entry->msg_len);
@@ -2375,7 +2401,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 			err = ___sys_recvmsg(sock,
 					     (struct msghdr __user *)entry,
 					     &msg_sys, flags & ~MSG_WAITFORONE,
-					     datagrams);
+					     datagrams, timeop);
 			if (err < 0)
 				break;
 			err = put_user(err, &entry->msg_len);
@@ -2390,17 +2416,11 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		if (flags & MSG_WAITFORONE)
 			flags |= MSG_DONTWAIT;
 
-		if (timeout) {
-			ktime_get_ts(timeout);
-			*timeout = timespec_sub(end_time, *timeout);
-			if (timeout->tv_sec < 0) {
-				timeout->tv_sec = timeout->tv_nsec = 0;
-				break;
-			}
-
+		if (timeout && timeout_hz == 0) {
 			/* Timeout, return less than vlen datagrams */
-			if (timeout->tv_nsec == 0 && timeout->tv_sec == 0)
-				break;
+			timeout->tv_sec = timeout->tv_nsec = 0;
+			timeop = NULL;
+			break;
 		}
 
 		/* Out of band data, return right away */
@@ -2411,6 +2431,11 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 out_put:
 	fput_light(sock->file, fput_needed);
 
+	if (timeop) {
+		timeout->tv_sec	 = timeout_hz / HZ;
+		timeout->tv_nsec = (timeout_hz % HZ) * (NSEC_PER_SEC / HZ);
+	}
+
 	if (err == 0)
 		return datagrams;
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b507cd327d9b..92417723f9dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -551,7 +551,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 			     0, 0, MSG_PEEK | MSG_DONTWAIT);
 	if (err >= 0)
-		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
+		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err, NULL);
 
 	if (skb == NULL) {
 		if (err != -EAGAIN) {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index be8bbd5d65ec..1afb8ece3eb6 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -965,7 +965,7 @@ static void xs_local_data_ready(struct sock *sk)
 	if (xprt == NULL)
 		goto out;
 
-	skb = skb_recv_datagram(sk, 0, 1, &err);
+	skb = skb_recv_datagram(sk, 0, 1, &err, NULL);
 	if (skb == NULL)
 		goto out;
 
@@ -1027,7 +1027,7 @@ static void xs_udp_data_ready(struct sock *sk)
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 
-	if ((skb = skb_recv_datagram(sk, 0, 1, &err)) == NULL)
+	if ((skb = skb_recv_datagram(sk, 0, 1, &err, NULL)) == NULL)
 		goto out;
 
 	repsize = skb->len - sizeof(struct udphdr);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8477d08a6aa0..68f58e7579dc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1150,7 +1150,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
  * Returns size of returned message data, errno otherwise
  */
 static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *m, size_t buf_len, int flags)
+			struct msghdr *m, size_t buf_len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
@@ -1173,7 +1173,7 @@ static int tipc_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto exit;
 	}
 
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+	timeo = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 restart:
 
 	/* Look for a message in receive queue; wait if necessary */
@@ -1230,6 +1230,8 @@ restart:
 		advance_rx_queue(sk);
 	}
 exit:
+	if (timeop)
+		*timeop = timeo;
 	release_sock(sk);
 	return res;
 }
@@ -1247,7 +1249,7 @@ exit:
  * Returns size of returned message data, errno otherwise
  */
 static int tipc_recv_stream(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t buf_len, int flags)
+			    struct msghdr *m, size_t buf_len, int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e96884380732..dcca71ed08c6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -519,17 +519,17 @@ static int unix_shutdown(struct socket *, int);
 static int unix_stream_sendmsg(struct kiocb *, struct socket *,
 			       struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct kiocb *, struct socket *,
-			       struct msghdr *, size_t, int);
+			       struct msghdr *, size_t, int, long *);
 static int unix_dgram_sendmsg(struct kiocb *, struct socket *,
 			      struct msghdr *, size_t);
 static int unix_dgram_recvmsg(struct kiocb *, struct socket *,
-			      struct msghdr *, size_t, int);
+			      struct msghdr *, size_t, int, long *);
 static int unix_dgram_connect(struct socket *, struct sockaddr *,
 			      int, int);
 static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
 				  struct msghdr *, size_t);
 static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
-				  struct msghdr *, size_t, int);
+				  struct msghdr *, size_t, int, long *);
 
 static int unix_set_peek_off(struct sock *sk, int val)
 {
@@ -1283,7 +1283,7 @@ static int unix_accept(struct socket *sock, struct socket *newsock, int flags)
 	 * so that no locks are necessary.
 	 */
 
-	skb = skb_recv_datagram(sk, 0, flags&O_NONBLOCK, &err);
+	skb = skb_recv_datagram(sk, 0, flags&O_NONBLOCK, &err, NULL);
 	if (!skb) {
 		/* This means receive shutdown. */
 		if (err == 0)
@@ -1755,14 +1755,14 @@ static int unix_seqpacket_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 static int unix_seqpacket_recvmsg(struct kiocb *iocb, struct socket *sock,
 			      struct msghdr *msg, size_t size,
-			      int flags)
+			      int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 
 	if (sk->sk_state != TCP_ESTABLISHED)
 		return -ENOTCONN;
 
-	return unix_dgram_recvmsg(iocb, sock, msg, size, flags);
+	return unix_dgram_recvmsg(iocb, sock, msg, size, flags, timeop);
 }
 
 static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
@@ -1777,7 +1777,7 @@ static void unix_copy_addr(struct msghdr *msg, struct sock *sk)
 
 static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 			      struct msghdr *msg, size_t size,
-			      int flags)
+			      int flags, long *timeop)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
 	struct scm_cookie tmp_scm;
@@ -1803,7 +1803,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	skip = sk_peek_offset(sk, flags);
 
-	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
+	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err, timeop);
 	if (!skb) {
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
@@ -1914,7 +1914,7 @@ static unsigned int unix_skb_len(const struct sk_buff *skb)
 
 static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
-			       int flags)
+			       int flags, long *timeop)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
 	struct scm_cookie tmp_scm;
@@ -1926,7 +1926,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int check_creds = 0;
 	int target;
 	int err = 0;
-	long timeo;
+	long timeo = sock_rcvtimeop(sk, timeop, noblock);
 	int skip;
 
 	err = -EINVAL;
@@ -1938,7 +1938,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
-	timeo = sock_rcvtimeo(sk, noblock);
 
 	/* Lock the socket to prevent queue disordering
 	 * while sleeps in memcpy_tomsg
@@ -2071,6 +2070,8 @@ again:
 	mutex_unlock(&u->readlock);
 	scm_recv(sock, msg, siocb->scm, flags);
 out:
+	if (timeop)
+		*timeop = timeo;
 	return copied ? : err;
 }
 
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 85d232bed87d..10568565f57d 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -1063,10 +1063,10 @@ out:
 }
 
 static int vsock_dgram_recvmsg(struct kiocb *kiocb, struct socket *sock,
-			       struct msghdr *msg, size_t len, int flags)
+			       struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	return transport->dgram_dequeue(kiocb, vsock_sk(sock->sk), msg, len,
-					flags);
+					flags, timeop);
 }
 
 static const struct proto_ops vsock_dgram_ops = {
@@ -1646,7 +1646,7 @@ out:
 static int
 vsock_stream_recvmsg(struct kiocb *kiocb,
 		     struct socket *sock,
-		     struct msghdr *msg, size_t len, int flags)
+		     struct msghdr *msg, size_t len, int flags, long *timeop)
 {
 	struct sock *sk;
 	struct vsock_sock *vsk;
@@ -1661,6 +1661,7 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 	sk = sock->sk;
 	vsk = vsock_sk(sk);
 	err = 0;
+	timeout = sock_rcvtimeop(sk, timeop, flags & MSG_DONTWAIT);
 
 	lock_sock(sk);
 
@@ -1711,7 +1712,6 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 		err = -ENOMEM;
 		goto out;
 	}
-	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 	copied = 0;
 
 	err = transport->notify_recv_init(vsk, target, &recv_data);
@@ -1821,6 +1821,8 @@ vsock_stream_recvmsg(struct kiocb *kiocb,
 out_wait:
 	finish_wait(sk_sleep(sk), &wait);
 out:
+	if (timeop)
+		*timeop = timeout;
 	release_sock(sk);
 	return err;
 }
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 9bb63ffec4f2..9c9e43c17b34 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1733,7 +1733,7 @@ static int vmci_transport_dgram_enqueue(
 static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 					struct vsock_sock *vsk,
 					struct msghdr *msg, size_t len,
-					int flags)
+					int flags, long *timeop)
 {
 	int err;
 	int noblock;
@@ -1748,7 +1748,7 @@ static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 
 	/* Retrieve the head sk_buff from the socket's receive queue. */
 	err = 0;
-	skb = skb_recv_datagram(&vsk->sk, flags, noblock, &err);
+	skb = skb_recv_datagram(&vsk->sk, flags, noblock, &err, timeop);
 	if (err)
 		return err;
 
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5ad4418ef093..da22c042469a 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1254,7 +1254,7 @@ out_kfree_skb:
 
 static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *msg, size_t size,
-		       int flags)
+		       int flags, long *timeop)
 {
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25 = x25_sk(sk);
@@ -1306,7 +1306,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		/* Now we can treat all alike */
 		release_sock(sk);
 		skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
-					flags & MSG_DONTWAIT, &rc);
+					flags & MSG_DONTWAIT, &rc, timeop);
 		lock_sock(sk);
 		if (!skb)
 			goto out;
-- 
1.9.3


--gatW/ieO32f1wygP--
