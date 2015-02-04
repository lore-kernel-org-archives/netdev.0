From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v3 05/18] rxrpc: switch rxrpc_send_data() to iov_iter primitives
Date: Wed,  4 Feb 2015 06:39:56 +0000
Message-ID: <1423032009-18367-5-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150204063730.GG29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43082 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbbBDGkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 01:40:11 -0500
In-Reply-To: <20150204063730.GG29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Convert skb_add_data() to iov_iter; allows to get rid of the explicit
messing with iovec in its only caller - skb_add_data() will keep advancing
->msg_iter for us, so there's no need to similate that manually.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h | 11 +++++------
 net/rxrpc/ar-output.c  | 43 ++++++++++---------------------------------
 2 files changed, 15 insertions(+), 39 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..9a8bafe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2484,19 +2484,18 @@ static inline int skb_put_padto(struct sk_buff *skb, unsigned int len)
 }
 
 static inline int skb_add_data(struct sk_buff *skb,
-			       char __user *from, int copy)
+			       struct iov_iter *from, int copy)
 {
 	const int off = skb->len;
 
 	if (skb->ip_summed == CHECKSUM_NONE) {
-		int err = 0;
-		__wsum csum = csum_and_copy_from_user(from, skb_put(skb, copy),
-							    copy, 0, &err);
-		if (!err) {
+		__wsum csum = 0;
+		if (csum_and_copy_from_iter(skb_put(skb, copy), copy,
+					    &csum, from) == copy) {
 			skb->csum = csum_block_add(skb->csum, csum, off);
 			return 0;
 		}
-	} else if (!copy_from_user(skb_put(skb, copy), from, copy))
+	} else if (copy_from_iter(skb_put(skb, copy), copy, from) == copy)
 		return 0;
 
 	__skb_trim(skb, off);
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index e1a9373..963a5b9 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -529,13 +529,11 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			   struct msghdr *msg, size_t len)
 {
 	struct rxrpc_skb_priv *sp;
-	unsigned char __user *from;
 	struct sk_buff *skb;
-	const struct iovec *iov;
 	struct sock *sk = &rx->sk;
 	long timeo;
 	bool more;
-	int ret, ioc, segment, copied;
+	int ret, copied;
 
 	timeo = sock_sndtimeo(sk, msg->msg_flags & MSG_DONTWAIT);
 
@@ -545,25 +543,17 @@ static int rxrpc_send_data(struct kiocb *iocb,
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		return -EPIPE;
 
-	iov = msg->msg_iter.iov;
-	ioc = msg->msg_iter.nr_segs - 1;
-	from = iov->iov_base;
-	segment = iov->iov_len;
-	iov++;
 	more = msg->msg_flags & MSG_MORE;
 
 	skb = call->tx_pending;
 	call->tx_pending = NULL;
 
 	copied = 0;
-	do {
+	if (len > iov_iter_count(&msg->msg_iter))
+		len = iov_iter_count(&msg->msg_iter);
+	while (len) {
 		int copy;
 
-		if (segment > len)
-			segment = len;
-
-		_debug("SEGMENT %d @%p", segment, from);
-
 		if (!skb) {
 			size_t size, chunk, max, space;
 
@@ -631,13 +621,13 @@ static int rxrpc_send_data(struct kiocb *iocb,
 		/* append next segment of data to the current buffer */
 		copy = skb_tailroom(skb);
 		ASSERTCMP(copy, >, 0);
-		if (copy > segment)
-			copy = segment;
+		if (copy > len)
+			copy = len;
 		if (copy > sp->remain)
 			copy = sp->remain;
 
 		_debug("add");
-		ret = skb_add_data(skb, from, copy);
+		ret = skb_add_data(skb, &msg->msg_iter, copy);
 		_debug("added");
 		if (ret < 0)
 			goto efault;
@@ -646,18 +636,6 @@ static int rxrpc_send_data(struct kiocb *iocb,
 		copied += copy;
 
 		len -= copy;
-		segment -= copy;
-		from += copy;
-		while (segment == 0 && ioc > 0) {
-			from = iov->iov_base;
-			segment = iov->iov_len;
-			iov++;
-			ioc--;
-		}
-		if (len == 0) {
-			segment = 0;
-			ioc = 0;
-		}
 
 		/* check for the far side aborting the call or a network error
 		 * occurring */
@@ -665,7 +643,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			goto call_aborted;
 
 		/* add the packet to the send queue if it's now full */
-		if (sp->remain <= 0 || (segment == 0 && !more)) {
+		if (sp->remain <= 0 || (!len && !more)) {
 			struct rxrpc_connection *conn = call->conn;
 			uint32_t seq;
 			size_t pad;
@@ -711,11 +689,10 @@ static int rxrpc_send_data(struct kiocb *iocb,
 
 			memcpy(skb->head, &sp->hdr,
 			       sizeof(struct rxrpc_header));
-			rxrpc_queue_packet(call, skb, segment == 0 && !more);
+			rxrpc_queue_packet(call, skb, !iov_iter_count(&msg->msg_iter) && !more);
 			skb = NULL;
 		}
-
-	} while (segment > 0);
+	}
 
 success:
 	ret = copied;
-- 
2.1.4
