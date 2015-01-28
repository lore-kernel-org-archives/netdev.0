From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] net: remove sock_iocb
Date: Wed, 28 Jan 2015 18:04:53 +0100
Message-ID: <1422464693-7827-1-git-send-email-hch@lst.de>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49388 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933815AbbA1UlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:41:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sock_iocb structure is allocate on stack for each read/write-like
operation on sockets, and contains various fields of which only the
embedded msghdr and sometimes a pointer to the scm_cookie is ever used.
Get rid of the sock_iocb and put a msghdr directly on the stack and pass
the scm_cookie explicitly to netlink_mmap_sendmsg.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/net/sock.h       | 23 ---------------
 net/netlink/af_netlink.c | 28 +++++++------------
 net/socket.c             | 45 +++--------------------------
 net/unix/af_unix.c       | 73 +++++++++++++++++++-----------------------------
 4 files changed, 43 insertions(+), 126 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2210fec..1534149 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1374,29 +1374,6 @@ void sk_prot_clear_portaddr_nulls(struct sock *sk, int size);
 #define SOCK_BINDADDR_LOCK	4
 #define SOCK_BINDPORT_LOCK	8
 
-/* sock_iocb: used to kick off async processing of socket ios */
-struct sock_iocb {
-	struct list_head	list;
-
-	int			flags;
-	int			size;
-	struct socket		*sock;
-	struct sock		*sk;
-	struct scm_cookie	*scm;
-	struct msghdr		*msg, async_msg;
-	struct kiocb		*kiocb;
-};
-
-static inline struct sock_iocb *kiocb_to_siocb(struct kiocb *iocb)
-{
-	return (struct sock_iocb *)iocb->private;
-}
-
-static inline struct kiocb *siocb_to_kiocb(struct sock_iocb *si)
-{
-	return si->kiocb;
-}
-
 struct socket_alloc {
 	struct socket socket;
 	struct inode vfs_inode;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 02fdde2..efae751 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -708,7 +708,7 @@ static void netlink_ring_setup_skb(struct sk_buff *skb, struct sock *sk,
 
 static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 				u32 dst_portid, u32 dst_group,
-				struct sock_iocb *siocb)
+				struct scm_cookie *scm)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct netlink_ring *ring;
@@ -754,7 +754,7 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 
 		NETLINK_CB(skb).portid	  = nlk->portid;
 		NETLINK_CB(skb).dst_group = dst_group;
-		NETLINK_CB(skb).creds	  = siocb->scm->creds;
+		NETLINK_CB(skb).creds	  = scm->creds;
 
 		err = security_netlink_send(sk, skb);
 		if (err) {
@@ -833,7 +833,7 @@ static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
 #define netlink_tx_is_mmaped(sk)	false
 #define netlink_mmap			sock_no_mmap
 #define netlink_poll			datagram_poll
-#define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, siocb)	0
+#define netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group, scm)	0
 #endif /* CONFIG_NETLINK_MMAP */
 
 static void netlink_skb_destructor(struct sk_buff *skb)
@@ -2259,7 +2259,6 @@ static void netlink_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
@@ -2273,10 +2272,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &scm;
-
-	err = scm_send(sock, msg, siocb->scm, true);
+	err = scm_send(sock, msg, &scm, true);
 	if (err < 0)
 		return err;
 
@@ -2305,7 +2301,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (netlink_tx_is_mmaped(sk) &&
 	    msg->msg_iter.iov->iov_base == NULL) {
 		err = netlink_mmap_sendmsg(sk, msg, dst_portid, dst_group,
-					   siocb);
+					   &scm);
 		goto out;
 	}
 
@@ -2319,7 +2315,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 	NETLINK_CB(skb).portid	= nlk->portid;
 	NETLINK_CB(skb).dst_group = dst_group;
-	NETLINK_CB(skb).creds	= siocb->scm->creds;
+	NETLINK_CB(skb).creds	= scm.creds;
 	NETLINK_CB(skb).flags	= netlink_skb_flags;
 
 	err = -EFAULT;
@@ -2341,7 +2337,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
 
 out:
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return err;
 }
 
@@ -2349,7 +2345,6 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, size_t len,
 			   int flags)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -2412,11 +2407,8 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	if (nlk->flags & NETLINK_RECV_PKTINFO)
 		netlink_cmsg_recv_pktinfo(msg, skb);
 
-	if (NULL == siocb->scm) {
-		memset(&scm, 0, sizeof(scm));
-		siocb->scm = &scm;
-	}
-	siocb->scm->creds = *NETLINK_CREDS(skb);
+	memset(&scm, 0, sizeof(scm));
+	scm.creds = *NETLINK_CREDS(skb);
 	if (flags & MSG_TRUNC)
 		copied = data_skb->len;
 
@@ -2431,7 +2423,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 		}
 	}
 
-	scm_recv(sock, msg, siocb->scm, flags);
+	scm_recv(sock, msg, &scm, flags);
 out:
 	netlink_rcv_wake(sk);
 	return err ? : copied;
diff --git a/net/socket.c b/net/socket.c
index 418795c..748a8f5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -613,13 +613,6 @@ EXPORT_SYMBOL(__sock_tx_timestamp);
 static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size)
 {
-	struct sock_iocb *si = kiocb_to_siocb(iocb);
-
-	si->sock = sock;
-	si->scm = NULL;
-	si->msg = msg;
-	si->size = size;
-
 	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
@@ -635,11 +628,9 @@ static int do_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 			   size_t size, bool nosec)
 {
 	struct kiocb iocb;
-	struct sock_iocb siocb;
 	int ret;
 
 	init_sync_kiocb(&iocb, NULL);
-	iocb.private = &siocb;
 	ret = nosec ? __sock_sendmsg_nosec(&iocb, sock, msg, size) :
 		      __sock_sendmsg(&iocb, sock, msg, size);
 	if (-EIOCBQUEUED == ret)
@@ -756,14 +747,6 @@ EXPORT_SYMBOL_GPL(__sock_recv_ts_and_drops);
 static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 				       struct msghdr *msg, size_t size, int flags)
 {
-	struct sock_iocb *si = kiocb_to_siocb(iocb);
-
-	si->sock = sock;
-	si->scm = NULL;
-	si->msg = msg;
-	si->size = size;
-	si->flags = flags;
-
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
@@ -779,11 +762,9 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
 	struct kiocb iocb;
-	struct sock_iocb siocb;
 	int ret;
 
 	init_sync_kiocb(&iocb, NULL);
-	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
@@ -795,11 +776,9 @@ static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 			      size_t size, int flags)
 {
 	struct kiocb iocb;
-	struct sock_iocb siocb;
 	int ret;
 
 	init_sync_kiocb(&iocb, NULL);
-	iocb.private = &siocb;
 	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
@@ -866,14 +845,6 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
-static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
-					 struct sock_iocb *siocb)
-{
-	siocb->kiocb = iocb;
-	iocb->private = siocb;
-	return siocb;
-}
-
 static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 		struct file *file, const struct iovec *iov,
 		unsigned long nr_segs)
@@ -898,7 +869,7 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
-	struct sock_iocb siocb, *x;
+	struct msghdr msg;
 
 	if (pos != 0)
 		return -ESPIPE;
@@ -906,11 +877,7 @@ static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
 		return 0;
 
-
-	x = alloc_sock_iocb(iocb, &siocb);
-	if (!x)
-		return -ENOMEM;
-	return do_sock_read(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+	return do_sock_read(&msg, iocb, iocb->ki_filp, iov, nr_segs);
 }
 
 static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
@@ -939,16 +906,12 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos)
 {
-	struct sock_iocb siocb, *x;
+	struct msghdr msg;
 
 	if (pos != 0)
 		return -ESPIPE;
 
-	x = alloc_sock_iocb(iocb, &siocb);
-	if (!x)
-		return -ENOMEM;
-
-	return do_sock_write(&x->async_msg, iocb, iocb->ki_filp, iov, nr_segs);
+	return do_sock_write(&msg, iocb, iocb->ki_filp, iov, nr_segs);
 }
 
 /*
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 8e1b102..526b6ed 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1445,7 +1445,6 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			      struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
@@ -1456,14 +1455,12 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	unsigned int hash;
 	struct sk_buff *skb;
 	long timeo;
-	struct scm_cookie tmp_scm;
+	struct scm_cookie scm;
 	int max_level;
 	int data_len = 0;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm, false);
+	err = scm_send(sock, msg, &scm, false);
 	if (err < 0)
 		return err;
 
@@ -1507,11 +1504,11 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (skb == NULL)
 		goto out;
 
-	err = unix_scm_to_skb(siocb->scm, skb, true);
+	err = unix_scm_to_skb(&scm, skb, true);
 	if (err < 0)
 		goto out_free;
 	max_level = err + 1;
-	unix_get_secdata(siocb->scm, skb);
+	unix_get_secdata(&scm, skb);
 
 	skb_put(skb, len - data_len);
 	skb->data_len = data_len;
@@ -1606,7 +1603,7 @@ restart:
 	unix_state_unlock(other);
 	other->sk_data_ready(other);
 	sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return len;
 
 out_unlock:
@@ -1616,7 +1613,7 @@ out_free:
 out:
 	if (other)
 		sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return err;
 }
 
@@ -1628,21 +1625,18 @@ out:
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	int err, size;
 	struct sk_buff *skb;
 	int sent = 0;
-	struct scm_cookie tmp_scm;
+	struct scm_cookie scm;
 	bool fds_sent = false;
 	int max_level;
 	int data_len;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm, false);
+	err = scm_send(sock, msg, &scm, false);
 	if (err < 0)
 		return err;
 
@@ -1683,7 +1677,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out_err;
 
 		/* Only send the fds in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
+		err = unix_scm_to_skb(&scm, skb, !fds_sent);
 		if (err < 0) {
 			kfree_skb(skb);
 			goto out_err;
@@ -1715,8 +1709,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	scm_destroy(siocb->scm);
-	siocb->scm = NULL;
+	scm_destroy(&scm);
 
 	return sent;
 
@@ -1728,8 +1721,7 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
-	scm_destroy(siocb->scm);
-	siocb->scm = NULL;
+	scm_destroy(&scm);
 	return sent ? : err;
 }
 
@@ -1778,8 +1770,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 			      struct msghdr *msg, size_t size,
 			      int flags)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
-	struct scm_cookie tmp_scm;
+	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
@@ -1831,16 +1822,14 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (sock_flag(sk, SOCK_RCVTSTAMP))
 		__sock_recv_timestamp(msg, sk, skb);
 
-	if (!siocb->scm) {
-		siocb->scm = &tmp_scm;
-		memset(&tmp_scm, 0, sizeof(tmp_scm));
-	}
-	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
-	unix_set_secdata(siocb->scm, skb);
+	memset(&scm, 0, sizeof(scm));
+
+	scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+	unix_set_secdata(&scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
 		if (UNIXCB(skb).fp)
-			unix_detach_fds(siocb->scm, skb);
+			unix_detach_fds(&scm, skb);
 
 		sk_peek_offset_bwd(sk, skb->len);
 	} else {
@@ -1860,11 +1849,11 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		sk_peek_offset_fwd(sk, size);
 
 		if (UNIXCB(skb).fp)
-			siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+			scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 	}
 	err = (flags & MSG_TRUNC) ? skb->len - skip : size;
 
-	scm_recv(sock, msg, siocb->scm, flags);
+	scm_recv(sock, msg, &scm, flags);
 
 out_free:
 	skb_free_datagram(sk, skb);
@@ -1915,8 +1904,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
 			       int flags)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
-	struct scm_cookie tmp_scm;
+	struct scm_cookie scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
@@ -1943,10 +1931,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 * while sleeps in memcpy_tomsg
 	 */
 
-	if (!siocb->scm) {
-		siocb->scm = &tmp_scm;
-		memset(&tmp_scm, 0, sizeof(tmp_scm));
-	}
+	memset(&scm, 0, sizeof(scm));
 
 	err = mutex_lock_interruptible(&u->readlock);
 	if (unlikely(err)) {
@@ -2012,13 +1997,13 @@ again:
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
-			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
-			    !uid_eq(UNIXCB(skb).uid, siocb->scm->creds.uid) ||
-			    !gid_eq(UNIXCB(skb).gid, siocb->scm->creds.gid))
+			if ((UNIXCB(skb).pid  != scm.pid) ||
+			    !uid_eq(UNIXCB(skb).uid, scm.creds.uid) ||
+			    !gid_eq(UNIXCB(skb).gid, scm.creds.gid))
 				break;
 		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
 			/* Copy credentials */
-			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
+			scm_set_cred(&scm, UNIXCB(skb).pid, UNIXCB(skb).uid, UNIXCB(skb).gid);
 			check_creds = 1;
 		}
 
@@ -2045,7 +2030,7 @@ again:
 			sk_peek_offset_bwd(sk, chunk);
 
 			if (UNIXCB(skb).fp)
-				unix_detach_fds(siocb->scm, skb);
+				unix_detach_fds(&scm, skb);
 
 			if (unix_skb_len(skb))
 				break;
@@ -2053,13 +2038,13 @@ again:
 			skb_unlink(skb, &sk->sk_receive_queue);
 			consume_skb(skb);
 
-			if (siocb->scm->fp)
+			if (scm.fp)
 				break;
 		} else {
 			/* It is questionable, see note in unix_dgram_recvmsg.
 			 */
 			if (UNIXCB(skb).fp)
-				siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+				scm.fp = scm_fp_dup(UNIXCB(skb).fp);
 
 			sk_peek_offset_fwd(sk, chunk);
 
@@ -2068,7 +2053,7 @@ again:
 	} while (size);
 
 	mutex_unlock(&u->readlock);
-	scm_recv(sock, msg, siocb->scm, flags);
+	scm_recv(sock, msg, &scm, flags);
 out:
 	return copied ? : err;
 }
-- 
1.9.1
