From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 07/12] put iov_iter into msghdr
Date: Fri,  5 Dec 2014 05:58:48 +0000
Message-ID: <1417759133-18370-7-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Note that the code _using_ ->msg_iter at that point will be very
unhappy with anything other than unshifted iovec-backed iov_iter.
We still need to convert users to proper primitives.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 crypto/algif_hash.c            |  4 ++--
 crypto/algif_skcipher.c        |  4 ++--
 drivers/net/macvtap.c          |  8 ++------
 drivers/net/tun.c              |  8 ++------
 drivers/vhost/net.c            |  8 +++-----
 fs/afs/rxrpc.c                 | 14 ++++++--------
 include/linux/skbuff.h         | 16 ++++++++++------
 include/linux/socket.h         |  3 +--
 include/net/bluetooth/l2cap.h  |  2 +-
 include/net/udplite.h          |  3 ++-
 net/atm/common.c               |  5 +----
 net/bluetooth/6lowpan.c        |  6 +++---
 net/bluetooth/a2mp.c           |  3 +--
 net/bluetooth/smp.c            |  3 +--
 net/caif/caif_socket.c         |  2 +-
 net/compat.c                   | 10 ++++++----
 net/ipv4/ip_output.c           |  6 ++++--
 net/ipv4/ping.c                |  3 ++-
 net/ipv4/raw.c                 |  3 ++-
 net/ipv4/tcp.c                 |  6 +++---
 net/ipv4/tcp_output.c          |  2 +-
 net/ipv6/ping.c                |  3 ++-
 net/ipv6/raw.c                 |  3 ++-
 net/netlink/af_netlink.c       |  2 +-
 net/packet/af_packet.c         |  7 ++-----
 net/rds/recv.c                 |  7 ++++---
 net/rds/send.c                 |  4 +---
 net/rxrpc/ar-output.c          |  8 +++-----
 net/sctp/socket.c              |  5 +----
 net/socket.c                   | 27 ++++++++++++---------------
 net/tipc/msg.c                 |  4 ++--
 net/tipc/socket.c              |  4 ++--
 net/unix/af_unix.c             | 10 ++--------
 net/vmw_vsock/vmci_transport.c |  3 ++-
 34 files changed, 92 insertions(+), 114 deletions(-)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 35c93ff..83cd2cc 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -42,7 +42,7 @@ static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
 	struct alg_sock *ask = alg_sk(sk);
 	struct hash_ctx *ctx = ask->private;
 	unsigned long iovlen;
-	struct iovec *iov;
+	const struct iovec *iov;
 	long copied = 0;
 	int err;
 
@@ -58,7 +58,7 @@ static int hash_sendmsg(struct kiocb *unused, struct socket *sock,
 
 	ctx->more = 0;
 
-	for (iov = msg->msg_iov, iovlen = msg->msg_iovlen; iovlen > 0;
+	for (iov = msg->msg_iter.iov, iovlen = msg->msg_iter.nr_segs; iovlen > 0;
 	     iovlen--, iov++) {
 		unsigned long seglen = iov->iov_len;
 		char __user *from = iov->iov_base;
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index c3b482b..4f45dab 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -429,13 +429,13 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
 	struct skcipher_sg_list *sgl;
 	struct scatterlist *sg;
 	unsigned long iovlen;
-	struct iovec *iov;
+	const struct iovec *iov;
 	int err = -EAGAIN;
 	int used;
 	long copied = 0;
 
 	lock_sock(sk);
-	for (iov = msg->msg_iov, iovlen = msg->msg_iovlen; iovlen > 0;
+	for (iov = msg->msg_iter.iov, iovlen = msg->msg_iter.nr_segs; iovlen > 0;
 	     iovlen--, iov++) {
 		unsigned long seglen = iov->iov_len;
 		char __user *from = iov->iov_base;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 22b4cf2..4fb1222 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1092,9 +1092,7 @@ static int macvtap_sendmsg(struct kiocb *iocb, struct socket *sock,
 			   struct msghdr *m, size_t total_len)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
-	struct iov_iter from;
-	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, total_len);
-	return macvtap_get_user(q, m, &from, m->msg_flags & MSG_DONTWAIT);
+	return macvtap_get_user(q, m, &m->msg_iter, m->msg_flags & MSG_DONTWAIT);
 }
 
 static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
@@ -1102,12 +1100,10 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 			   int flags)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
-	struct iov_iter to;
 	int ret;
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	iov_iter_init(&to, READ, m->msg_iov, m->msg_iovlen, total_len);
-	ret = macvtap_do_read(q, &to, flags & MSG_DONTWAIT);
+	ret = macvtap_do_read(q, &m->msg_iter, flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6d44da1..8d8bede 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1446,13 +1446,11 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 	int ret;
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
 	struct tun_struct *tun = __tun_get(tfile);
-	struct iov_iter from;
 
 	if (!tun)
 		return -EBADFD;
 
-	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, total_len);
-	ret = tun_get_user(tun, tfile, m->msg_control, &from,
+	ret = tun_get_user(tun, tfile, m->msg_control, &m->msg_iter,
 			   m->msg_flags & MSG_DONTWAIT);
 	tun_put(tun);
 	return ret;
@@ -1464,7 +1462,6 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct tun_file *tfile = container_of(sock, struct tun_file, socket);
 	struct tun_struct *tun = __tun_get(tfile);
-	struct iov_iter to;
 	int ret;
 
 	if (!tun)
@@ -1479,8 +1476,7 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 					 SOL_PACKET, TUN_TX_TIMESTAMP);
 		goto out;
 	}
-	iov_iter_init(&to, READ, m->msg_iov, m->msg_iovlen, total_len);
-	ret = tun_do_read(tun, tfile, &to, flags & MSG_DONTWAIT);
+	ret = tun_do_read(tun, tfile, &m->msg_iter, flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8dae2f7..9f06e70 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -342,7 +342,6 @@ static void handle_tx(struct vhost_net *net)
 		.msg_namelen = 0,
 		.msg_control = NULL,
 		.msg_controllen = 0,
-		.msg_iov = vq->iov,
 		.msg_flags = MSG_DONTWAIT,
 	};
 	size_t len, total_len = 0;
@@ -396,8 +395,8 @@ static void handle_tx(struct vhost_net *net)
 		}
 		/* Skip header. TODO: support TSO. */
 		s = move_iovec_hdr(vq->iov, nvq->hdr, hdr_size, out);
-		msg.msg_iovlen = out;
 		len = iov_length(vq->iov, out);
+		iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
 		/* Sanity check */
 		if (!len) {
 			vq_err(vq, "Unexpected header len for TX: "
@@ -562,7 +561,6 @@ static void handle_rx(struct vhost_net *net)
 		.msg_namelen = 0,
 		.msg_control = NULL, /* FIXME: get and handle RX aux data. */
 		.msg_controllen = 0,
-		.msg_iov = vq->iov,
 		.msg_flags = MSG_DONTWAIT,
 	};
 	struct virtio_net_hdr_mrg_rxbuf hdr = {
@@ -600,7 +598,7 @@ static void handle_rx(struct vhost_net *net)
 			break;
 		/* On overrun, truncate and discard */
 		if (unlikely(headcount > UIO_MAXIOV)) {
-			msg.msg_iovlen = 1;
+			iov_iter_init(&msg.msg_iter, READ, vq->iov, 1, 1);
 			err = sock->ops->recvmsg(NULL, sock, &msg,
 						 1, MSG_DONTWAIT | MSG_TRUNC);
 			pr_debug("Discarded rx packet: len %zd\n", sock_len);
@@ -626,7 +624,7 @@ static void handle_rx(struct vhost_net *net)
 			/* Copy the header for use in VIRTIO_NET_F_MRG_RXBUF:
 			 * needed because recvmsg can modify msg_iov. */
 			copy_iovec_hdr(vq->iov, nvq->hdr, sock_hlen, in);
-		msg.msg_iovlen = in;
+		iov_iter_init(&msg.msg_iter, READ, vq->iov, in, sock_len);
 		err = sock->ops->recvmsg(NULL, sock, &msg,
 					 sock_len, MSG_DONTWAIT | MSG_TRUNC);
 		/* Userspace might have consumed the packet meanwhile:
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 03a3beb..06e14bf 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -306,8 +306,8 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg,
 
 			_debug("- range %u-%u%s",
 			       offset, to, msg->msg_flags ? " [more]" : "");
-			msg->msg_iov = (struct iovec *) iov;
-			msg->msg_iovlen = 1;
+			iov_iter_init(&msg->msg_iter, WRITE,
+				      (struct iovec *) iov, 1, to - offset);
 
 			/* have to change the state *before* sending the last
 			 * packet as RxRPC might give us the reply before it
@@ -384,8 +384,8 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	msg.msg_iov		= (struct iovec *) iov;
-	msg.msg_iovlen		= 1;
+	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)iov, 1,
+		      call->request_size);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= (call->send_pages ? MSG_MORE : 0);
@@ -778,8 +778,7 @@ void afs_send_empty_reply(struct afs_call *call)
 	iov[0].iov_len		= 0;
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	msg.msg_iov		= iov;
-	msg.msg_iovlen		= 0;
+	iov_iter_init(&msg.msg_iter, WRITE, iov, 0, 0);	/* WTF? */
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= 0;
@@ -815,8 +814,7 @@ void afs_send_simple_reply(struct afs_call *call, const void *buf, size_t len)
 	iov[0].iov_len		= len;
 	msg.msg_name		= NULL;
 	msg.msg_namelen		= 0;
-	msg.msg_iov		= iov;
-	msg.msg_iovlen		= 1;
+	iov_iter_init(&msg.msg_iter, WRITE, iov, 1, len);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
 	msg.msg_flags		= 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7691ad5..4199dfa 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2644,22 +2644,24 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 			   struct poll_table_struct *wait);
 int skb_copy_datagram_iovec(const struct sk_buff *from, int offset,
 			    struct iovec *to, int size);
+int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
+			   struct iov_iter *to, int size);
 static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
 					struct msghdr *msg, int size)
 {
-	return skb_copy_datagram_iovec(from, offset, msg->msg_iov, size);
+	/* XXX: stripping const */
+	return skb_copy_datagram_iovec(from, offset, (struct iovec *)msg->msg_iter.iov, size);
 }
 int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb, int hlen,
 				     struct iovec *iov);
 static inline int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
 			    struct msghdr *msg)
 {
-	return skb_copy_and_csum_datagram_iovec(skb, hlen, msg->msg_iov);
+	/* XXX: stripping const */
+	return skb_copy_and_csum_datagram_iovec(skb, hlen, (struct iovec *)msg->msg_iter.iov);
 }
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from, int len);
-int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
-			   struct iov_iter *to, int size);
 int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *frm);
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
@@ -2687,12 +2689,14 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
-	return memcpy_fromiovec(data, msg->msg_iov, len);
+	/* XXX: stripping const */
+	return memcpy_fromiovec(data, (struct iovec *)msg->msg_iter.iov, len);
 }
 
 static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
 {
-	return memcpy_toiovec(msg->msg_iov, data, len);
+	/* XXX: stripping const */
+	return memcpy_toiovec((struct iovec *)msg->msg_iter.iov, data, len);
 }
 
 struct skb_checksum_ops {
diff --git a/include/linux/socket.h b/include/linux/socket.h
index de52228..048d6d6 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -47,8 +47,7 @@ struct linger {
 struct msghdr {
 	void		*msg_name;	/* ptr to socket address structure */
 	int		msg_namelen;	/* size of socket address structure */
-	struct iovec	*msg_iov;	/* scatter/gather array */
-	__kernel_size_t	msg_iovlen;	/* # elements in msg_iov */
+	struct iov_iter	msg_iter;	/* data */
 	void		*msg_control;	/* ancillary data */
 	__kernel_size_t	msg_controllen;	/* ancillary data buffer length */
 	unsigned int	msg_flags;	/* flags on received message */
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 4e23674..bca6fc0 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -911,7 +911,7 @@ static inline int l2cap_chan_no_memcpy_fromiovec(struct l2cap_chan *chan,
 	/* Following is safe since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	struct kvec *vec = (struct kvec *)msg->msg_iov;
+	struct kvec *vec = (struct kvec *)msg->msg_iter.iov;
 
 	while (len > 0) {
 		if (vec->iov_len) {
diff --git a/include/net/udplite.h b/include/net/udplite.h
index d5baaba..ae7c8d1 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -20,7 +20,8 @@ static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
 				      int len, int odd, struct sk_buff *skb)
 {
 	struct msghdr *msg = from;
-	return memcpy_fromiovecend(to, msg->msg_iov, offset, len);
+	/* XXX: stripping const */
+	return memcpy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len);
 }
 
 /* Designate sk as UDP-Lite socket */
diff --git a/net/atm/common.c b/net/atm/common.c
index f591129..b84057e 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -577,9 +577,6 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
 	int eff, error;
-	struct iov_iter from;
-
-	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, size);
 
 	lock_sock(sk);
 	if (sock->state != SS_CONNECTED) {
@@ -634,7 +631,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
-	if (copy_from_iter(skb_put(skb, size), size, &from) != size) {
+	if (copy_from_iter(skb_put(skb, size), size, &m->msg_iter) != size) {
 		kfree_skb(skb);
 		error = -EFAULT;
 		goto out;
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index bdcaefd..d8c67a5 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -537,12 +537,12 @@ static int send_pkt(struct l2cap_chan *chan, struct sk_buff *skb,
 	 */
 	chan->data = skb;
 
-	memset(&msg, 0, sizeof(msg));
-	msg.msg_iov = (struct iovec *) &iv;
-	msg.msg_iovlen = 1;
 	iv.iov_base = skb->data;
 	iv.iov_len = skb->len;
 
+	memset(&msg, 0, sizeof(msg));
+	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *) &iv, 1, skb->len);
+
 	err = l2cap_chan_send(chan, &msg, skb->len);
 	if (err > 0) {
 		netdev->stats.tx_bytes += err;
diff --git a/net/bluetooth/a2mp.c b/net/bluetooth/a2mp.c
index 5dcade5..716d2a3 100644
--- a/net/bluetooth/a2mp.c
+++ b/net/bluetooth/a2mp.c
@@ -60,8 +60,7 @@ void a2mp_send(struct amp_mgr *mgr, u8 code, u8 ident, u16 len, void *data)
 
 	memset(&msg, 0, sizeof(msg));
 
-	msg.msg_iov = (struct iovec *) &iv;
-	msg.msg_iovlen = 1;
+	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)&iv, 1, total_len);
 
 	l2cap_chan_send(chan, &msg, total_len);
 
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 069b76e..21f555b 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -268,8 +268,7 @@ static void smp_send_cmd(struct l2cap_conn *conn, u8 code, u16 len, void *data)
 
 	memset(&msg, 0, sizeof(msg));
 
-	msg.msg_iov = (struct iovec *) &iv;
-	msg.msg_iovlen = 2;
+	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)iv, 2, 1 + len);
 
 	l2cap_chan_send(chan, &msg, 1 + len);
 
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index ac618b0..769b185 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -535,7 +535,7 @@ static int caif_seqpkt_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto err;
 
 	ret = -EINVAL;
-	if (unlikely(msg->msg_iov->iov_base == NULL))
+	if (unlikely(msg->msg_iter.iov->iov_base == NULL))
 		goto err;
 	noblock = msg->msg_flags & MSG_DONTWAIT;
 
diff --git a/net/compat.c b/net/compat.c
index 062f157..3236b41 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -37,13 +37,14 @@ ssize_t get_compat_msghdr(struct msghdr *kmsg,
 			  struct iovec **iov)
 {
 	compat_uptr_t uaddr, uiov, tmp3;
+	compat_size_t nr_segs;
 	ssize_t err;
 
 	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
 	    __get_user(uaddr, &umsg->msg_name) ||
 	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
 	    __get_user(uiov, &umsg->msg_iov) ||
-	    __get_user(kmsg->msg_iovlen, &umsg->msg_iovlen) ||
+	    __get_user(nr_segs, &umsg->msg_iovlen) ||
 	    __get_user(tmp3, &umsg->msg_control) ||
 	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
 	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
@@ -68,14 +69,15 @@ ssize_t get_compat_msghdr(struct msghdr *kmsg,
 		kmsg->msg_namelen = 0;
 	}
 
-	if (kmsg->msg_iovlen > UIO_MAXIOV)
+	if (nr_segs > UIO_MAXIOV)
 		return -EMSGSIZE;
 
 	err = compat_rw_copy_check_uvector(save_addr ? READ : WRITE,
-					   compat_ptr(uiov), kmsg->msg_iovlen,
+					   compat_ptr(uiov), nr_segs,
 					   UIO_FASTIOV, *iov, iov);
 	if (err >= 0)
-		kmsg->msg_iov = *iov;
+		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
+			      *iov, nr_segs, err);
 	return err;
 }
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cdedcf1..b50861b2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -755,11 +755,13 @@ ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk
 	struct msghdr *msg = from;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (memcpy_fromiovecend(to, msg->msg_iov, offset, len) < 0)
+		/* XXX: stripping const */
+		if (memcpy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len) < 0)
 			return -EFAULT;
 	} else {
 		__wsum csum = 0;
-		if (csum_partial_copy_fromiovecend(to, msg->msg_iov, offset, len, &csum) < 0)
+		/* XXX: stripping const */
+		if (csum_partial_copy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len, &csum) < 0)
 			return -EFAULT;
 		skb->csum = csum_block_add(skb->csum, csum, odd);
 	}
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8dd4ae0..c0d82f7 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -811,7 +811,8 @@ back_from_confirm:
 	pfh.icmph.checksum = 0;
 	pfh.icmph.un.echo.id = inet->inet_sport;
 	pfh.icmph.un.echo.sequence = user_icmph.un.echo.sequence;
-	pfh.iov = msg->msg_iov;
+	/* XXX: stripping const */
+	pfh.iov = (struct iovec *)msg->msg_iter.iov;
 	pfh.wcheck = 0;
 	pfh.family = AF_INET;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 5d83bd2..0bb68df 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -625,7 +625,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 back_from_confirm:
 
 	if (inet->hdrincl)
-		err = raw_send_hdrinc(sk, &fl4, msg->msg_iov, len,
+		/* XXX: stripping const */
+		err = raw_send_hdrinc(sk, &fl4, (struct iovec *)msg->msg_iter.iov, len,
 				      &rt, msg->msg_flags);
 
 	 else {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4a96f37..54ba620 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1085,7 +1085,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
-	struct iovec *iov;
+	const struct iovec *iov;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int iovlen, flags, err, copied = 0;
@@ -1136,8 +1136,8 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	mss_now = tcp_send_mss(sk, &size_goal, flags);
 
 	/* Ok commence sending. */
-	iovlen = msg->msg_iovlen;
-	iov = msg->msg_iov;
+	iovlen = msg->msg_iter.nr_segs;
+	iov = msg->msg_iter.iov;
 	copied = 0;
 
 	err = -EPIPE;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f5bd4bd..3e225b0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -3050,7 +3050,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	syn_data->ip_summed = CHECKSUM_PARTIAL;
 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
 	if (unlikely(memcpy_fromiovecend(skb_put(syn_data, space),
-					 fo->data->msg_iov, 0, space))) {
+					 fo->data->msg_iter.iov, 0, space))) {
 		kfree_skb(syn_data);
 		goto fallback;
 	}
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 5b7a1ed..2d31483 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -163,7 +163,8 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.icmph.checksum = 0;
 	pfh.icmph.un.echo.id = inet->inet_sport;
 	pfh.icmph.un.echo.sequence = user_icmph.icmp6_sequence;
-	pfh.iov = msg->msg_iov;
+	/* XXX: stripping const */
+	pfh.iov = (struct iovec *)msg->msg_iter.iov;
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 11a9283..ee25631 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -886,7 +886,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 back_from_confirm:
 	if (inet->hdrincl)
-		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl6, &dst, msg->msg_flags);
+		/* XXX: stripping const */
+		err = rawv6_send_hdrinc(sk, (struct iovec *)msg->msg_iter.iov, len, &fl6, &dst, msg->msg_flags);
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, raw6_getfrag, &rfv,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 63aa5c8..cc9bcf0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2305,7 +2305,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	}
 
 	if (netlink_tx_is_mmaped(sk) &&
-	    msg->msg_iov->iov_base == NULL) {
+	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
 					   siocb);
 		goto out;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index efa8445..ed2e620 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2408,11 +2408,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	unsigned short gso_type = 0;
 	int hlen, tlen;
 	int extra_len = 0;
-	struct iov_iter from;
 	ssize_t n;
 
-	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
-
 	/*
 	 *	Get and verify the address.
 	 */
@@ -2451,7 +2448,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 		len -= vnet_hdr_len;
 
 		err = -EFAULT;
-		n = copy_from_iter(&vnet_hdr, vnet_hdr_len, &from);
+		n = copy_from_iter(&vnet_hdr, vnet_hdr_len, &msg->msg_iter);
 		if (n != vnet_hdr_len)
 			goto out_unlock;
 
@@ -2522,7 +2519,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	}
 
 	/* Returns -EFAULT on error */
-	err = skb_copy_datagram_from_iter(skb, offset, &from, len);
+	err = skb_copy_datagram_from_iter(skb, offset, &msg->msg_iter, len);
 	if (err)
 		goto out_free;
 
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 47d7b10..f9ec1ac 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -404,7 +404,6 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int ret = 0, nonblock = msg_flags & MSG_DONTWAIT;
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct rds_incoming *inc = NULL;
-	struct iov_iter to;
 
 	/* udp_recvmsg()->sock_recvtimeo() gets away without locking too.. */
 	timeo = sock_rcvtimeo(sk, nonblock);
@@ -415,6 +414,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		goto out;
 
 	while (1) {
+		struct iov_iter save;
 		/* If there are pending notifications, do those - and nothing else */
 		if (!list_empty(&rs->rs_notify_queue)) {
 			ret = rds_notify_queue_get(rs, msg);
@@ -450,8 +450,8 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		rdsdebug("copying inc %p from %pI4:%u to user\n", inc,
 			 &inc->i_conn->c_faddr,
 			 ntohs(inc->i_hdr.h_sport));
-		iov_iter_init(&to, READ, msg->msg_iov, msg->msg_iovlen, size);
-		ret = inc->i_conn->c_trans->inc_copy_to_user(inc, &to);
+		save = msg->msg_iter;
+		ret = inc->i_conn->c_trans->inc_copy_to_user(inc, &msg->msg_iter);
 		if (ret < 0)
 			break;
 
@@ -464,6 +464,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 			rds_inc_put(inc);
 			inc = NULL;
 			rds_stats_inc(s_recv_deliver_raced);
+			msg->msg_iter = save;
 			continue;
 		}
 
diff --git a/net/rds/send.c b/net/rds/send.c
index 4de62ea..40a5629a 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -934,9 +934,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	int queued = 0, allocated_mr = 0;
 	int nonblock = msg->msg_flags & MSG_DONTWAIT;
 	long timeo = sock_sndtimeo(sk, nonblock);
-	struct iov_iter from;
 
-	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, payload_len);
 	/* Mirror Linux UDP mirror of BSD error message compatibility */
 	/* XXX: Perhaps MSG_MORE someday */
 	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_CMSG_COMPAT)) {
@@ -984,7 +982,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 			ret = -ENOMEM;
 			goto out;
 		}
-		ret = rds_message_copy_from_user(rm, &from);
+		ret = rds_message_copy_from_user(rm, &msg->msg_iter);
 		if (ret)
 			goto out;
 	}
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 0b4b9a7..86e0f10 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -531,14 +531,12 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	struct rxrpc_skb_priv *sp;
 	unsigned char __user *from;
 	struct sk_buff *skb;
-	struct iovec *iov;
+	const struct iovec *iov;
 	struct sock *sk = &rx->sk;
 	long timeo;
 	bool more;
 	int ret, ioc, segment, copied;
 
-	_enter(",,,{%zu},%zu", msg->msg_iovlen, len);
-
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 
 	/* this should be in poll */
@@ -547,8 +545,8 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		return -EPIPE;
 
-	iov = msg->msg_iov;
-	ioc = msg->msg_iovlen - 1;
+	iov = msg->msg_iter.iov;
+	ioc = msg->msg_iter.nr_segs - 1;
 	from = iov->iov_base;
 	segment = iov->iov_len;
 	iov++;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 0397ac9..c92f96cd 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1609,9 +1609,6 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	__u16 sinfo_flags = 0;
 	long timeo;
 	int err;
-	struct iov_iter from;
-
-	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, msg_len);
 
 	err = 0;
 	sp = sctp_sk(sk);
@@ -1950,7 +1947,7 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	}
 
 	/* Break the message into multiple chunks of maximum size. */
-	datamsg = sctp_datamsg_from_user(asoc, sinfo, &from);
+	datamsg = sctp_datamsg_from_user(asoc, sinfo, &msg->msg_iter);
 	if (IS_ERR(datamsg)) {
 		err = PTR_ERR(datamsg);
 		goto out_free;
diff --git a/net/socket.c b/net/socket.c
index ee3ee39..46571ee 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -691,8 +691,7 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 	 * the following is safe, since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	msg->msg_iov = (struct iovec *)vec;
-	msg->msg_iovlen = num;
+	iov_iter_init(&msg->msg_iter, WRITE, (struct iovec *)vec, num, size);
 	result = sock_sendmsg(sock, msg, size);
 	set_fs(oldfs);
 	return result;
@@ -855,7 +854,7 @@ int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 	 * the following is safe, since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	msg->msg_iov = (struct iovec *)vec, msg->msg_iovlen = num;
+	iov_iter_init(&msg->msg_iter, READ, (struct iovec *)vec, num, size);
 	result = sock_recvmsg(sock, msg, size, flags);
 	set_fs(oldfs);
 	return result;
@@ -915,8 +914,7 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *)iov;
-	msg->msg_iovlen = nr_segs;
+	iov_iter_init(&msg->msg_iter, READ, iov, nr_segs, size);
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
 	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
@@ -955,8 +953,7 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	msg->msg_iov = (struct iovec *)iov;
-	msg->msg_iovlen = nr_segs;
+	iov_iter_init(&msg->msg_iter, WRITE, iov, nr_segs, size);
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 	if (sock->type == SOCK_SEQPACKET)
 		msg->msg_flags |= MSG_EOR;
@@ -1800,8 +1797,7 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
 	iov.iov_base = buff;
 	iov.iov_len = len;
 	msg.msg_name = NULL;
-	msg.msg_iov = &iov;
-	msg.msg_iovlen = 1;
+	iov_iter_init(&msg.msg_iter, WRITE, &iov, 1, len);
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_namelen = 0;
@@ -1858,10 +1854,9 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
-	msg.msg_iovlen = 1;
-	msg.msg_iov = &iov;
 	iov.iov_len = size;
 	iov.iov_base = ubuf;
+	iov_iter_init(&msg.msg_iter, READ, &iov, 1, size);
 	/* Save some cycles and don't copy the address if not needed */
 	msg.msg_name = addr ? (struct sockaddr *)&address : NULL;
 	/* We assume all kernel code knows the size of sockaddr_storage */
@@ -1995,13 +1990,14 @@ static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
 {
 	struct sockaddr __user *uaddr;
 	struct iovec __user *uiov;
+	size_t nr_segs;
 	ssize_t err;
 
 	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
 	    __get_user(uaddr, &umsg->msg_name) ||
 	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
 	    __get_user(uiov, &umsg->msg_iov) ||
-	    __get_user(kmsg->msg_iovlen, &umsg->msg_iovlen) ||
+	    __get_user(nr_segs, &umsg->msg_iovlen) ||
 	    __get_user(kmsg->msg_control, &umsg->msg_control) ||
 	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
 	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
@@ -2031,14 +2027,15 @@ static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
 		kmsg->msg_namelen = 0;
 	}
 
-	if (kmsg->msg_iovlen > UIO_MAXIOV)
+	if (nr_segs > UIO_MAXIOV)
 		return -EMSGSIZE;
 
 	err = rw_copy_check_uvector(save_addr ? READ : WRITE,
-				    uiov, kmsg->msg_iovlen,
+				    uiov, nr_segs,
 				    UIO_FASTIOV, *iov, iov);
 	if (err >= 0)
-		kmsg->msg_iov = *iov;
+		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
+			      *iov, nr_segs, err);
 	return err;
 }
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 5b06597..a687b30 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -194,7 +194,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 		__skb_queue_tail(list, skb);
 		skb_copy_to_linear_data(skb, mhdr, mhsz);
 		pktpos = skb->data + mhsz;
-		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iov, offset,
+		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iter.iov, offset,
 						 dsz))
 			return dsz;
 		rc = -EFAULT;
@@ -224,7 +224,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 		if (drem < pktrem)
 			pktrem = drem;
 
-		if (memcpy_fromiovecend(pktpos, m->msg_iov, offset, pktrem)) {
+		if (memcpy_fromiovecend(pktpos, m->msg_iter.iov, offset, pktrem)) {
 			rc = -EFAULT;
 			goto error;
 		}
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9658d9b..4e78a7d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -850,9 +850,9 @@ static int dest_name_check(struct sockaddr_tipc *dest, struct msghdr *m)
 	if (likely(dest->addr.name.name.type != TIPC_CFG_SRV))
 		return -EACCES;
 
-	if (!m->msg_iovlen || (m->msg_iov[0].iov_len < sizeof(hdr)))
+	if (!m->msg_iter.nr_segs || (m->msg_iter.iov[0].iov_len < sizeof(hdr)))
 		return -EMSGSIZE;
-	if (copy_from_user(&hdr, m->msg_iov[0].iov_base, sizeof(hdr)))
+	if (copy_from_user(&hdr, m->msg_iter.iov[0].iov_base, sizeof(hdr)))
 		return -EFAULT;
 	if ((ntohs(hdr.tcm_type) & 0xC000) && (!capable(CAP_NET_ADMIN)))
 		return -EACCES;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 4450d62..8e1b102 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1459,9 +1459,6 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	int max_level;
 	int data_len = 0;
-	struct iov_iter from;
-
-	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1519,7 +1516,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	skb_put(skb, len - data_len);
 	skb->data_len = data_len;
 	skb->len = len;
-	err = skb_copy_datagram_from_iter(skb, 0, &from, len);
+	err = skb_copy_datagram_from_iter(skb, 0, &msg->msg_iter, len);
 	if (err)
 		goto out_free;
 
@@ -1641,9 +1638,6 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	bool fds_sent = false;
 	int max_level;
 	int data_len;
-	struct iov_iter from;
-
-	iov_iter_init(&from, WRITE, msg->msg_iov, msg->msg_iovlen, len);
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1700,7 +1694,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		skb_put(skb, size - data_len);
 		skb->data_len = data_len;
 		skb->len = size;
-		err = skb_copy_datagram_from_iter(skb, 0, &from, size);
+		err = skb_copy_datagram_from_iter(skb, 0, &msg->msg_iter, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 20a0ba3..02d2e52 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1850,7 +1850,8 @@ static ssize_t vmci_transport_stream_enqueue(
 	struct msghdr *msg,
 	size_t len)
 {
-	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
+	/* XXX: stripping const */
+	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, (struct iovec *)msg->msg_iter.iov, len, 0);
 }
 
 static s64 vmci_transport_stream_has_data(struct vsock_sock *vsk)
-- 
2.1.3
