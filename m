From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 6/6] unix: Support peeking offset for stream sockets
Date: Tue, 21 Feb 2012 21:32:06 +0400
Message-ID: <4F43D516.9060102@parallels.com>
References: <4F43D49E.3010401@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2991 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225Ab2BURcQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 12:32:16 -0500
In-Reply-To: <4F43D49E.3010401@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same here -- we can protect the sk_peek_off manipulations with
the unix_sk->readlock mutex.

The peeking of data from a stream socket is done in the datagram style,
i.e. even if there's enough room for more data in the user buffer, only
the head skb's data is copied in there. This feature is preserved when
peeking data from a given offset -- the data is read till the nearest
skb's boundary.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/af_unix.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3d9481d..0be4d24 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -559,6 +559,7 @@ static const struct proto_ops unix_stream_ops = {
 	.recvmsg =	unix_stream_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
+	.set_peek_off =	unix_set_peek_off,
 };
 
 static const struct proto_ops unix_dgram_ops = {
@@ -1904,6 +1905,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int target;
 	int err = 0;
 	long timeo;
+	int skip;
 
 	err = -EINVAL;
 	if (sk->sk_state != TCP_ESTABLISHED)
@@ -1933,12 +1935,15 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		goto out;
 	}
 
+	skip = sk_peek_offset(sk, flags);
+
 	do {
 		int chunk;
 		struct sk_buff *skb;
 
 		unix_state_lock(sk);
 		skb = skb_peek(&sk->sk_receive_queue);
+again:
 		if (skb == NULL) {
 			unix_sk(sk)->recursion_level = 0;
 			if (copied >= target)
@@ -1973,6 +1978,13 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			unix_state_unlock(sk);
 			break;
 		}
+
+		if (skip >= skb->len) {
+			skip -= skb->len;
+			skb = skb_peek_next(skb, &sk->sk_receive_queue);
+			goto again;
+		}
+
 		unix_state_unlock(sk);
 
 		if (check_creds) {
@@ -1992,8 +2004,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			sunaddr = NULL;
 		}
 
-		chunk = min_t(unsigned int, skb->len, size);
-		if (memcpy_toiovec(msg->msg_iov, skb->data, chunk)) {
+		chunk = min_t(unsigned int, skb->len - skip, size);
+		if (memcpy_toiovec(msg->msg_iov, skb->data + skip, chunk)) {
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
@@ -2005,6 +2017,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 		if (!(flags & MSG_PEEK)) {
 			skb_pull(skb, chunk);
 
+			sk_peek_offset_bwd(sk, chunk);
+
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
 
@@ -2022,6 +2036,8 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			if (UNIXCB(skb).fp)
 				siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
 
+			sk_peek_offset_fwd(sk, chunk);
+
 			break;
 		}
 	} while (size);
-- 
1.5.5.6
