From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/6] unix: Support peeking offset for datagram and seqpacket
 sockets
Date: Tue, 21 Feb 2012 21:31:51 +0400
Message-ID: <4F43D507.9010905@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4785 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826Ab2BURb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:31:59 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sk_peek_off manipulations are protected with the unix_sk->readlock mutex.
This mutex is enough since all we need is to syncronize setting the offset
vs reading the queue head. The latter is fully covered with the mentioned lock.

The recently added __skb_recv_datagram's offset is used to pick the skb to
read the data from.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/af_unix.c |   30 +++++++++++++++++++++++++-----
 1 files changed, 25 insertions(+), 5 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 85d3bb7..3d9481d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -530,6 +530,16 @@ static int unix_seqpacket_sendmsg(struct kiocb *, struct socket *,
 static int unix_seqpacket_recvmsg(struct kiocb *, struct socket *,
 				  struct msghdr *, size_t, int);
 
+static void unix_set_peek_off(struct sock *sk, int val)
+{
+	struct unix_sock *u = unix_sk(sk);
+
+	mutex_lock(&u->readlock);
+	sk->sk_peek_off = val;
+	mutex_unlock(&u->readlock);
+}
+
+
 static const struct proto_ops unix_stream_ops = {
 	.family =	PF_UNIX,
 	.owner =	THIS_MODULE,
@@ -570,6 +580,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.recvmsg =	unix_dgram_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.set_peek_off =	unix_set_peek_off,
 };
 
 static const struct proto_ops unix_seqpacket_ops = {
@@ -591,6 +602,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.recvmsg =	unix_seqpacket_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.set_peek_off =	unix_set_peek_off,
 };
 
 static struct proto unix_proto = {
@@ -1756,6 +1768,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
 	int err;
+	int peeked, skip;
 
 	err = -EOPNOTSUPP;
 	if (flags&MSG_OOB)
@@ -1769,7 +1782,9 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	skip = sk_peek_offset(sk, flags);
+
+	skb = __skb_recv_datagram(sk, flags, &peeked, &skip, &err);
 	if (!skb) {
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
@@ -1786,12 +1801,12 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);
 
-	if (size > skb->len)
-		size = skb->len;
-	else if (size < skb->len)
+	if (size > skb->len - skip)
+		size = skb->len - skip;
+	else if (size < skb->len - skip)
 		msg->msg_flags |= MSG_TRUNC;
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, size);
+	err = skb_copy_datagram_iovec(skb, skip, msg->msg_iov, size);
 	if (err)
 		goto out_free;
 
@@ -1808,6 +1823,8 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (!(flags & MSG_PEEK)) {
 		if (UNIXCB(skb).fp)
 			unix_detach_fds(siocb->scm, skb);
+
+		sk_peek_offset_bwd(sk, skb->len);
 	} else {
 		/* It is questionable: on PEEK we could:
 		   - do not return fds - good, but too simple 8)
@@ -1821,6 +1838,9 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		   clearly however!
 
 		*/
+
+		sk_peek_offset_fwd(sk, size);
+
 		if (UNIXCB(skb).fp)
 			siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
 	}
-- 
1.5.5.6
