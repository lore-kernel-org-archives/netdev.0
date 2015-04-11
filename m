From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 17/17] new helper: msg_data_left()
Date: Sat, 11 Apr 2015 22:18:28 +0100
Message-ID: <1428787108-13650-17-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37890 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbbDKVSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:32 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

convert open-coded instances

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 crypto/algif_hash.c     |  4 ++--
 crypto/algif_skcipher.c |  4 ++--
 drivers/vhost/net.c     |  4 ++--
 include/linux/socket.h  |  5 +++++
 net/core/datagram.c     |  2 +-
 net/ipv4/tcp.c          |  8 ++++----
 net/rxrpc/ar-output.c   | 19 +++++++++----------
 net/socket.c            |  4 ++--
 8 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
index 0a465e0..1396ad0 100644
--- a/crypto/algif_hash.c
+++ b/crypto/algif_hash.c
@@ -56,8 +56,8 @@ static int hash_sendmsg(struct socket *sock, struct msghdr *msg,
 
 	ctx->more = 0;
 
-	while (iov_iter_count(&msg->msg_iter)) {
-		int len = iov_iter_count(&msg->msg_iter);
+	while (msg_data_left(msg)) {
+		int len = msg_data_left(msg);
 
 		if (len > limit)
 			len = limit;
diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
index 8f903b6..9450752 100644
--- a/crypto/algif_skcipher.c
+++ b/crypto/algif_skcipher.c
@@ -641,7 +641,7 @@ static int skcipher_recvmsg_sync(struct socket *sock, struct msghdr *msg,
 	long copied = 0;
 
 	lock_sock(sk);
-	while (iov_iter_count(&msg->msg_iter)) {
+	while (msg_data_left(msg)) {
 		sgl = list_first_entry(&ctx->tsgl,
 				       struct skcipher_sg_list, list);
 		sg = sgl->sg;
@@ -655,7 +655,7 @@ static int skcipher_recvmsg_sync(struct socket *sock, struct msghdr *msg,
 				goto unlock;
 		}
 
-		used = min_t(unsigned long, ctx->used, iov_iter_count(&msg->msg_iter));
+		used = min_t(unsigned long, ctx->used, msg_data_left(msg));
 
 		used = af_alg_make_sg(&ctx->rsgl, &msg->msg_iter, used);
 		err = used;
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 18f05bf..7d137a4 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -357,13 +357,13 @@ static void handle_tx(struct vhost_net *net)
 		iov_iter_init(&msg.msg_iter, WRITE, vq->iov, out, len);
 		iov_iter_advance(&msg.msg_iter, hdr_size);
 		/* Sanity check */
-		if (!iov_iter_count(&msg.msg_iter)) {
+		if (!msg_data_left(&msg)) {
 			vq_err(vq, "Unexpected header len for TX: "
 			       "%zd expected %zd\n",
 			       len, hdr_size);
 			break;
 		}
-		len = iov_iter_count(&msg.msg_iter);
+		len = msg_data_left(&msg);
 
 		zcopy_used = zcopy && len >= VHOST_GOODCOPY_LEN
 				   && (nvq->upend_idx + 1) % UIO_MAXIOV !=
diff --git a/include/linux/socket.h b/include/linux/socket.h
index c9852ef..5bf59c8 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -139,6 +139,11 @@ static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr
 	return __cmsg_nxthdr(__msg->msg_control, __msg->msg_controllen, __cmsg);
 }
 
+static inline size_t msg_data_left(struct msghdr *msg)
+{
+	return iov_iter_count(&msg->msg_iter);
+}
+
 /* "Socket"-level control message types: */
 
 #define	SCM_RIGHTS	0x01		/* rw: access rights (array of int) */
diff --git a/net/core/datagram.c b/net/core/datagram.c
index df493d6..b80fb91 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -673,7 +673,7 @@ int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
 	if (!chunk)
 		return 0;
 
-	if (iov_iter_count(&msg->msg_iter) < chunk) {
+	if (msg_data_left(msg) < chunk) {
 		if (__skb_checksum_complete(skb))
 			goto csum_error;
 		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 094a682..18e3a12 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1119,7 +1119,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
-	while (iov_iter_count(&msg->msg_iter)) {
+	while (msg_data_left(msg)) {
 		int copy = 0;
 		int max = size_goal;
 
@@ -1163,8 +1163,8 @@ new_segment:
 		}
 
 		/* Try to append data to the end of skb. */
-		if (copy > iov_iter_count(&msg->msg_iter))
-			copy = iov_iter_count(&msg->msg_iter);
+		if (copy > msg_data_left(msg))
+			copy = msg_data_left(msg);
 
 		/* Where to copy to? */
 		if (skb_availroom(skb) > 0) {
@@ -1221,7 +1221,7 @@ new_segment:
 		tcp_skb_pcount_set(skb, 0);
 
 		copied += copy;
-		if (!iov_iter_count(&msg->msg_iter)) {
+		if (!msg_data_left(msg)) {
 			tcp_tx_timestamp(sk, skb);
 			goto out;
 		}
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 7a31a39..c004280 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -564,8 +564,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			max &= ~(call->conn->size_align - 1UL);
 
 			chunk = max;
-			if (chunk > iov_iter_count(&msg->msg_iter) && !more)
-				chunk = iov_iter_count(&msg->msg_iter);
+			if (chunk > msg_data_left(msg) && !more)
+				chunk = msg_data_left(msg);
 
 			space = chunk + call->conn->size_align;
 			space &= ~(call->conn->size_align - 1UL);
@@ -608,11 +608,11 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 		sp = rxrpc_skb(skb);
 
 		/* append next segment of data to the current buffer */
-		if (iov_iter_count(&msg->msg_iter) > 0) {
+		if (msg_data_left(msg) > 0) {
 			int copy = skb_tailroom(skb);
 			ASSERTCMP(copy, >, 0);
-			if (copy > iov_iter_count(&msg->msg_iter))
-				copy = iov_iter_count(&msg->msg_iter);
+			if (copy > msg_data_left(msg))
+				copy = msg_data_left(msg);
 			if (copy > sp->remain)
 				copy = sp->remain;
 
@@ -633,7 +633,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 		/* add the packet to the send queue if it's now full */
 		if (sp->remain <= 0 ||
-		    (iov_iter_count(&msg->msg_iter) == 0 && !more)) {
+		    (msg_data_left(msg) == 0 && !more)) {
 			struct rxrpc_connection *conn = call->conn;
 			uint32_t seq;
 			size_t pad;
@@ -663,7 +663,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			sp->hdr.serviceId = conn->service_id;
 
 			sp->hdr.flags = conn->out_clientflag;
-			if (iov_iter_count(&msg->msg_iter) == 0 && !more)
+			if (msg_data_left(msg) == 0 && !more)
 				sp->hdr.flags |= RXRPC_LAST_PACKET;
 			else if (CIRC_SPACE(call->acks_head, call->acks_tail,
 					    call->acks_winsz) > 1)
@@ -679,11 +679,10 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			memcpy(skb->head, &sp->hdr,
 			       sizeof(struct rxrpc_header));
-			rxrpc_queue_packet(call, skb,
-					   iov_iter_count(&msg->msg_iter) == 0 && !more);
+			rxrpc_queue_packet(call, skb, !msg_data_left(msg) && !more);
 			skb = NULL;
 		}
-	} while (iov_iter_count(&msg->msg_iter) > 0);
+	} while (msg_data_left(msg) > 0);
 
 success:
 	ret = copied;
diff --git a/net/socket.c b/net/socket.c
index 21676e4..5b01262 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -612,7 +612,7 @@ EXPORT_SYMBOL(__sock_tx_timestamp);
 
 static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg)
 {
-	int ret = sock->ops->sendmsg(sock, msg, iov_iter_count(&msg->msg_iter));
+	int ret = sock->ops->sendmsg(sock, msg, msg_data_left(msg));
 	BUG_ON(ret == -EIOCBQUEUED);
 	return ret;
 }
@@ -620,7 +620,7 @@ static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg)
 int sock_sendmsg(struct socket *sock, struct msghdr *msg)
 {
 	int err = security_socket_sendmsg(sock, msg,
-					  iov_iter_count(&msg->msg_iter));
+					  msg_data_left(msg));
 
 	return err ?: sock_sendmsg_nosec(sock, msg);
 }
-- 
2.1.4
