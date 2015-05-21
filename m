From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 2/4] net: af_unix: implement stream sendpage support
Date: Thu, 21 May 2015 11:39:14 +0200
Message-ID: <b41cc15175028ef651f0a603fd53f037efc2b6fb.1432200344.git.hannes@stressinduktion.org>
References: <cover.1432200343.git.hannes@stressinduktion.org>
Cc: edumazet@google.com, cwang@twopensource.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:34988 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753894AbbEUJjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 05:39:24 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id C75902064D
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 05:39:23 -0400 (EDT)
In-Reply-To: <cover.1432200343.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1432200343.git.hannes@stressinduktion.org>
References: <cover.1432200343.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements sendpage support for AF_UNIX SOCK_STREAM
sockets. This is also required for a complete splice implementation.

The implementation is a bit tricky because we append to already existing
skbs and so have to hold unix_sk->readlock to protect the reading side
from either advancing UNIXCB.consumed or freeing the skb at the socket
receive tail.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2:
* replaced skb_queue_tail with the unlocked version, __skb_queue_tail (thanks, Eric!)
* folded variable declaration and initialization (thanks, Cong!)

 net/unix/af_unix.c | 99 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 98 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 941b3d2..7762c0b 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -518,6 +518,8 @@ static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
 static int unix_stream_sendmsg(struct socket *, struct msghdr *, size_t);
 static int unix_stream_recvmsg(struct socket *, struct msghdr *, size_t, int);
+static ssize_t unix_stream_sendpage(struct socket *, struct page *, int offset,
+				    size_t size, int flags);
 static int unix_dgram_sendmsg(struct socket *, struct msghdr *, size_t);
 static int unix_dgram_recvmsg(struct socket *, struct msghdr *, size_t, int);
 static int unix_dgram_connect(struct socket *, struct sockaddr *,
@@ -558,7 +560,7 @@ static const struct proto_ops unix_stream_ops = {
 	.sendmsg =	unix_stream_sendmsg,
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
-	.sendpage =	sock_no_sendpage,
+	.sendpage =	unix_stream_sendpage,
 	.set_peek_off =	unix_set_peek_off,
 };
 
@@ -1720,6 +1722,101 @@ out_err:
 	return sent ? : err;
 }
 
+static ssize_t unix_stream_sendpage(struct socket *socket, struct page *page,
+				    int offset, size_t size, int flags)
+{
+	int err = 0;
+	bool send_sigpipe = true;
+	struct sock *other, *sk = socket->sk;
+	struct sk_buff *skb, *newskb = NULL, *tail = NULL;
+
+	if (flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	other = unix_peer(sk);
+	if (!other || sk->sk_state != TCP_ESTABLISHED)
+		return -ENOTCONN;
+
+	if (false) {
+alloc_skb:
+		unix_state_unlock(other);
+		mutex_unlock(&unix_sk(other)->readlock);
+		newskb = sock_alloc_send_pskb(sk, 0, 0, flags & MSG_DONTWAIT,
+					      &err, 0);
+		if (!newskb)
+			return err;
+	}
+
+	/* we must acquire readlock as we modify already present
+	 * skbs in the sk_receive_queue and mess with skb->len
+	 */
+	err = mutex_lock_interruptible(&unix_sk(other)->readlock);
+	if (err) {
+		err = flags & MSG_DONTWAIT ? -EAGAIN : -ERESTARTSYS;
+		send_sigpipe = false;
+		goto err;
+	}
+
+	if (sk->sk_shutdown & SEND_SHUTDOWN) {
+		err = -EPIPE;
+		goto err_unlock;
+	}
+
+	unix_state_lock(other);
+
+	if (sock_flag(other, SOCK_DEAD) ||
+	    other->sk_shutdown & RCV_SHUTDOWN) {
+		err = -EPIPE;
+		goto err_state_unlock;
+	}
+
+	skb = skb_peek_tail(&other->sk_receive_queue);
+	if (tail && tail == skb) {
+		skb = newskb;
+	} else if (!skb) {
+		if (newskb)
+			skb = newskb;
+		else
+			goto alloc_skb;
+	} else if (newskb) {
+		/* this is fast path, we don't necessarily need to
+		 * call to kfree_skb even though with newskb == NULL
+		 * this - does no harm
+		 */
+		consume_skb(newskb);
+	}
+
+	if (skb_append_pagefrags(skb, page, offset, size)) {
+		tail = skb;
+		goto alloc_skb;
+	}
+
+	skb->len += size;
+	skb->data_len += size;
+	skb->truesize += size;
+	atomic_add(size, &sk->sk_wmem_alloc);
+
+	if (newskb)
+		__skb_queue_tail(&other->sk_receive_queue, newskb);
+
+	unix_state_unlock(other);
+	mutex_unlock(&unix_sk(other)->readlock);
+
+	other->sk_data_ready(other);
+
+	return size;
+
+err_state_unlock:
+	unix_state_unlock(other);
+err_unlock:
+	mutex_unlock(&unix_sk(other)->readlock);
+err:
+	kfree_skb(newskb);
+	if (send_sigpipe && !(flags & MSG_NOSIGNAL))
+		send_sig(SIGPIPE, current, 0);
+	return err;
+}
+
 static int unix_seqpacket_sendmsg(struct socket *sock, struct msghdr *msg,
 				  size_t len)
 {
-- 
2.1.0
