From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with
 fragmented memory
Date: Thu, 08 Aug 2013 14:37:32 -0700
Message-ID: <1375997852.4004.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:39407 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966702Ab3HHVhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 17:37:35 -0400
Received: by mail-oa0-f52.google.com with SMTP id n12so1427210oag.11
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 14:37:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

unix_stream_sendmsg() currently uses order-2 allocations,
and we had numerous reports this can fail.

The __GFP_REPEAT flag present in sock_alloc_send_pskb() is
not helping.

This patch extends the work done in commit eb6a24816b247c
("af_unix: reduce high order page allocations) for
datagram sockets.

This opens the possibility of zero copy IO (splice() and
friends)

The trick is to not use skb_pull() anymore in recvmsg() path,
and instead add a @consumed field in UNIXCB() to track amount
of already read payload in the skb.

There is a performance regression for large sends
because of extra page allocations that will be addressed
in a follow-up patch, allowing sock_alloc_send_pskb()
to attempt high order page allocations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Rientjes <rientjes@google.com>
---
Google-Bug-Id: 9198684

 include/net/af_unix.h |    1 
 net/unix/af_unix.c    |   65 ++++++++++++++++++----------------------
 2 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 05442df..a175ba4 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -35,6 +35,7 @@ struct unix_skb_parms {
 #ifdef CONFIG_SECURITY_NETWORK
 	u32			secid;		/* Security ID		*/
 #endif
+	u32			consumed;
 };
 
 #define UNIXCB(skb) 	(*(struct unix_skb_parms *)&((skb)->cb))
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c4ce243..99dc760 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1596,6 +1596,10 @@ out:
 	return err;
 }
 
+/* We use paged skbs for stream sockets, and limit occupancy to 32768
+ * bytes, and a minimun of a full page.
+ */
+#define UNIX_SKB_FRAGS_SZ (PAGE_SIZE << get_order(32768))
 
 static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
@@ -1609,6 +1613,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	bool fds_sent = false;
 	int max_level;
+	int data_len;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1635,40 +1640,21 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		goto pipe_err;
 
 	while (sent < len) {
-		/*
-		 *	Optimisation for the fact that under 0.01% of X
-		 *	messages typically need breaking up.
-		 */
-
-		size = len-sent;
+		size = len - sent;
 
 		/* Keep two messages in the pipe so it schedules better */
-		if (size > ((sk->sk_sndbuf >> 1) - 64))
-			size = (sk->sk_sndbuf >> 1) - 64;
+		size = min_t(int, size, (sk->sk_sndbuf >> 1) - 64);
 
-		if (size > SKB_MAX_ALLOC)
-			size = SKB_MAX_ALLOC;
-
-		/*
-		 *	Grab a buffer
-		 */
+		/* allow fallback to order-0 allocations */
+		size = min_t(int, size, SKB_MAX_HEAD(0) + UNIX_SKB_FRAGS_SZ);
 
-		skb = sock_alloc_send_skb(sk, size, msg->msg_flags&MSG_DONTWAIT,
-					  &err);
+		data_len = max_t(int, 0, size - SKB_MAX_HEAD(0));
 
-		if (skb == NULL)
+		skb = sock_alloc_send_pskb(sk, size - data_len, data_len,
+					   msg->msg_flags & MSG_DONTWAIT, &err);
+		if (!skb)
 			goto out_err;
 
-		/*
-		 *	If you pass two values to the sock_alloc_send_skb
-		 *	it tries to grab the large buffer with GFP_NOFS
-		 *	(which can fail easily), and if it fails grab the
-		 *	fallback size buffer which is under a page and will
-		 *	succeed. [Alan]
-		 */
-		size = min_t(int, size, skb_tailroom(skb));
-
-
 		/* Only send the fds in the first buffer */
 		err = unix_scm_to_skb(siocb->scm, skb, !fds_sent);
 		if (err < 0) {
@@ -1678,7 +1664,10 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		max_level = err + 1;
 		fds_sent = true;
 
-		err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+		skb_put(skb, size - data_len);
+		skb->data_len = data_len;
+		skb->len = size;
+		err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, size);
 		if (err) {
 			kfree_skb(skb);
 			goto out_err;
@@ -1890,6 +1879,11 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 	return timeo;
 }
 
+static unsigned int unix_skb_len(const struct sk_buff *skb)
+{
+	return skb->len - UNIXCB(skb).consumed;
+}
+
 static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size,
 			       int flags)
@@ -1977,8 +1971,8 @@ again:
 		}
 
 		skip = sk_peek_offset(sk, flags);
-		while (skip >= skb->len) {
-			skip -= skb->len;
+		while (skip >= unix_skb_len(skb)) {
+			skip -= unix_skb_len(skb);
 			last = skb;
 			skb = skb_peek_next(skb, &sk->sk_receive_queue);
 			if (!skb)
@@ -2005,8 +1999,9 @@ again:
 			sunaddr = NULL;
 		}
 
-		chunk = min_t(unsigned int, skb->len - skip, size);
-		if (memcpy_toiovec(msg->msg_iov, skb->data + skip, chunk)) {
+		chunk = min_t(unsigned int, unix_skb_len(skb) - skip, size);
+		if (skb_copy_datagram_iovec(skb, UNIXCB(skb).consumed + skip,
+					    msg->msg_iov, chunk)) {
 			if (copied == 0)
 				copied = -EFAULT;
 			break;
@@ -2016,14 +2011,14 @@ again:
 
 		/* Mark read part of skb as used */
 		if (!(flags & MSG_PEEK)) {
-			skb_pull(skb, chunk);
+			UNIXCB(skb).consumed += chunk;
 
 			sk_peek_offset_bwd(sk, chunk);
 
 			if (UNIXCB(skb).fp)
 				unix_detach_fds(siocb->scm, skb);
 
-			if (skb->len)
+			if (unix_skb_len(skb))
 				break;
 
 			skb_unlink(skb, &sk->sk_receive_queue);
@@ -2107,7 +2102,7 @@ long unix_inq_len(struct sock *sk)
 	if (sk->sk_type == SOCK_STREAM ||
 	    sk->sk_type == SOCK_SEQPACKET) {
 		skb_queue_walk(&sk->sk_receive_queue, skb)
-			amount += skb->len;
+			amount += unix_skb_len(skb);
 	} else {
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb)
