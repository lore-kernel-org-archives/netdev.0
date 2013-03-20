From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 3/3] net: Remove sock_iocb.scm
Date: Wed, 20 Mar 2013 14:38:40 -0700
Message-ID: <f3daf046acadde091ed1e7a4517f9e9039c6d79b.1363815201.git.luto@amacapital.net>
References: <cover.1363815201.git.luto@amacapital.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	containers@lists.linux-foundation.org,
	Andy Lutomirski <luto@amacapital.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:38588 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755Ab3CTVjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:39:12 -0400
Received: by mail-da0-f46.google.com with SMTP id y19so1225955dan.33
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 14:39:12 -0700 (PDT)
In-Reply-To: <cover.1363815201.git.luto@amacapital.net>
In-Reply-To: <cover.1363815201.git.luto@amacapital.net>
References: <cover.1363815201.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure why this was here.  Any use after sendmsg or recvmsg
returned was bogus anyway.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 include/net/sock.h       |  1 -
 net/netlink/af_netlink.c | 27 +++++++-------------
 net/socket.c             |  2 --
 net/unix/af_unix.c       | 66 ++++++++++++++++++------------------------------
 4 files changed, 33 insertions(+), 63 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 14f6e9d..87b134e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1299,7 +1299,6 @@ struct sock_iocb {
 	int			size;
 	struct socket		*sock;
 	struct sock		*sk;
-	struct scm_cookie	*scm;
 	struct msghdr		*msg, async_msg;
 	struct kiocb		*kiocb;
 };
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8245f61..874bc1f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1359,7 +1359,6 @@ static void netlink_cmsg_recv_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct sockaddr_nl *addr = msg->msg_name;
@@ -1372,11 +1371,8 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &scm;
-
-	scm_creds_from_current(&siocb->scm->creds);
-	err = scm_send(sock, msg, siocb->scm);
+	scm_creds_from_current(&scm.creds);
+	err = scm_send(sock, msg, &scm);
 	if (err < 0)
 		return err;
 
@@ -1413,7 +1409,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).dst_group = dst_group;
 
 	/* This is mandatory. See netlink_recvmsg. */
-	NETLINK_CB(skb).creds = siocb->scm->creds;
+	NETLINK_CB(skb).creds = scm.creds;
 
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
@@ -1434,7 +1430,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	err = netlink_unicast(sk, skb, dst_portid, msg->msg_flags&MSG_DONTWAIT);
 
 out:
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return err;
 }
 
@@ -1442,8 +1438,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 			   struct msghdr *msg, size_t len,
 			   int flags)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
-	struct scm_cookie scm;
+	struct scm_cookie scm = SCM_COOKIE_INIT;
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
@@ -1502,14 +1497,10 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	if (nlk->flags & NETLINK_RECV_PKTINFO)
 		netlink_cmsg_recv_pktinfo(msg, skb);
 
-	if (NULL == siocb->scm) {
-		memset(&scm, 0, sizeof(scm));
-		siocb->scm = &scm;
-	}
 	/* skbs without creds are from the kernel. */
-	siocb->scm->creds = *NETLINK_CREDS(skb);
-	if (!siocb->scm->creds.has_creds)
-		scm_creds_from_kernel(&siocb->scm->creds);
+	scm.creds = *NETLINK_CREDS(skb);
+	if (!scm.creds.has_creds)
+		scm_creds_from_kernel(&scm.creds);
 
 	if (flags & MSG_TRUNC)
 		copied = data_skb->len;
@@ -1524,7 +1515,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 		}
 	}
 
-	scm_recv(sock, msg, siocb->scm, flags);
+	scm_recv(sock, msg, &scm, flags);
 out:
 	netlink_rcv_wake(sk);
 	return err ? : copied;
diff --git a/net/socket.c b/net/socket.c
index 88f759a..26a65b4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -619,7 +619,6 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
-	si->scm = NULL;
 	si->msg = msg;
 	si->size = size;
 
@@ -781,7 +780,6 @@ static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
-	si->scm = NULL;
 	si->msg = msg;
 	si->size = size;
 	si->flags = flags;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0881739..e6541c1 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1422,7 +1422,6 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
 static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			      struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
@@ -1433,14 +1432,12 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	unsigned int hash;
 	struct sk_buff *skb;
 	long timeo;
-	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
+	struct scm_cookie scm = SCM_COOKIE_INIT;
 	int max_level;
 	int data_len = 0;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm);
+	err = scm_send(sock, msg, &scm);
 	if (err < 0)
 		return err;
 
@@ -1479,11 +1476,11 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
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
@@ -1578,7 +1575,7 @@ restart:
 	unix_state_unlock(other);
 	other->sk_data_ready(other, len);
 	sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return len;
 
 out_unlock:
@@ -1588,7 +1585,7 @@ out_free:
 out:
 	if (other)
 		sock_put(other);
-	scm_destroy(siocb->scm);
+	scm_destroy(&scm);
 	return err;
 }
 
@@ -1596,20 +1593,17 @@ out:
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
 	int err, size;
 	struct sk_buff *skb;
 	int sent = 0;
-	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
+	struct scm_cookie scm = SCM_COOKIE_INIT;
 	bool fds_sent = false;
 	int max_level;
 
-	if (NULL == siocb->scm)
-		siocb->scm = &tmp_scm;
 	wait_for_unix_gc();
-	err = scm_send(sock, msg, siocb->scm);
+	err = scm_send(sock, msg, &scm);
 	if (err < 0)
 		return err;
 
@@ -1666,7 +1660,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 
 
 		/* Only send the fds in the first buffer */
-		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
+		err = unix_scm_to_skb(&scm, skb, !fds_sent);
 		if (err < 0) {
 			kfree_skb(skb);
 			goto out_err;
@@ -1695,8 +1689,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		sent += size;
 	}
 
-	scm_destroy(siocb->scm);
-	siocb->scm = NULL;
+	scm_destroy(&scm);
 
 	return sent;
 
@@ -1708,8 +1701,7 @@ pipe_err:
 		send_sig(SIGPIPE, current, 0);
 	err = -EPIPE;
 out_err:
-	scm_destroy(siocb->scm);
-	siocb->scm = NULL;
+	scm_destroy(&scm);
 	return sent ? : err;
 }
 
@@ -1760,7 +1752,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 			      int flags)
 {
 	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
-	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
+	struct scm_cookie scm = SCM_COOKIE_INIT;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
@@ -1811,16 +1803,12 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (sock_flag(sk, SOCK_RCVTSTAMP))
 		__sock_recv_timestamp(msg, sk, skb);
 
-	if (!siocb->scm) {
-		siocb->scm = &tmp_scm;
-		memset(&tmp_scm, 0, sizeof(tmp_scm));
-	}
-	siocb->scm->creds = UNIXCB(skb).creds;
-	unix_set_secdata(siocb->scm, skb);
+	scm.creds = UNIXCB(skb).creds;
+	unix_set_secdata(&scm, skb);
 
 	if (!(flags & MSG_PEEK)) {
 		if (UNIXCB(skb).fp)
-			unix_detach_fds(siocb->scm, skb);
+			unix_detach_fds(&scm, skb);
 
 		sk_peek_offset_bwd(sk, skb->len);
 	} else {
@@ -1840,11 +1828,11 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
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
@@ -1892,8 +1880,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
 			       int flags)
 {
-	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
-	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
+	struct scm_cookie scm = SCM_COOKIE_INIT;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = msg->msg_name;
@@ -1921,11 +1908,6 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 * while sleeps in memcpy_tomsg
 	 */
 
-	if (!siocb->scm) {
-		siocb->scm = &tmp_scm;
-		memset(&tmp_scm, 0, sizeof(tmp_scm));
-	}
-
 	err = mutex_lock_interruptible(&u->readlock);
 	if (err) {
 		err = sock_intr_errno(timeo);
@@ -1987,11 +1969,11 @@ again:
 		if (check_creds) {
 			/* Never glue messages from different writers */
 			if (!scm_creds_equal(&UNIXCB(skb).creds,
-			                     &siocb->scm->creds));
+			                     &scm.creds));
 				break;
 		} else {
 			/* Copy credentials */
-			siocb->scm->creds = UNIXCB(skb).creds;
+			scm.creds = UNIXCB(skb).creds;
 			check_creds = 1;
 		}
 
@@ -2017,7 +1999,7 @@ again:
 			sk_peek_offset_bwd(sk, chunk);
 
 			if (UNIXCB(skb).fp)
-				unix_detach_fds(siocb->scm, skb);
+				unix_detach_fds(&scm, skb);
 
 			if (skb->len)
 				break;
@@ -2025,13 +2007,13 @@ again:
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
 
@@ -2040,7 +2022,7 @@ again:
 	} while (size);
 
 	mutex_unlock(&u->readlock);
-	scm_recv(sock, msg, siocb->scm, flags);
+	scm_recv(sock, msg, &scm, flags);
 out:
 	return copied ? : err;
 }
-- 
1.8.1.4
