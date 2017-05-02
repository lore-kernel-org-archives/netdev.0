From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 2/2] tipc: refactor function tipc_sk_recv_stream()
Date: Tue, 2 May 2017 18:16:54 +0200
Message-ID: <1493741814-25899-3-git-send-email-jon.maloy@ericsson.com>
References: <1493741814-25899-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:57528 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdEBQR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:17:58 -0400
In-Reply-To: <1493741814-25899-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We try to make this function more readable by improving variable names
and comments, using more stack variables, and doing some smaller changes
to the logics. We also rename the function to make it consistent with
naming conventions used elsewhere in the code.

Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 155 +++++++++++++++++++++++++-----------------------------
 1 file changed, 71 insertions(+), 84 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 3855bfd..7e45ef9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1375,9 +1375,9 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m,
 }
 
 /**
- * tipc_recv_stream - receive stream-oriented data
+ * tipc_recvstream - receive stream-oriented data
  * @m: descriptor for message info
- * @buf_len: total size of user buffer area
+ * @buflen: total size of user buffer area
  * @flags: receive flags
  *
  * Used for SOCK_STREAM messages only.  If not enough data is available
@@ -1385,111 +1385,98 @@ static int tipc_recvmsg(struct socket *sock, struct msghdr *m,
  *
  * Returns size of returned message data, errno otherwise
  */
-static int tipc_recv_stream(struct socket *sock, struct msghdr *m,
-			    size_t buf_len, int flags)
+static int tipc_recvstream(struct socket *sock, struct msghdr *m,
+			   size_t buflen, int flags)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	long timeo;
-	unsigned int sz;
-	int target;
-	int sz_copied = 0;
-	u32 err;
-	int res = 0, hlen;
+	struct sk_buff *skb;
+	struct tipc_msg *hdr;
+	struct tipc_skb_cb *skb_cb;
+	bool peek = flags & MSG_PEEK;
+	int offset, required, copy, copied = 0;
+	int hlen, dlen, err, rc;
+	long timeout;
 
 	/* Catch invalid receive attempts */
-	if (unlikely(!buf_len))
+	if (unlikely(!buflen))
 		return -EINVAL;
 
 	lock_sock(sk);
 
 	if (unlikely(sk->sk_state == TIPC_OPEN)) {
-		res = -ENOTCONN;
-		goto exit;
-	}
-
-	target = sock_rcvlowat(sk, flags & MSG_WAITALL, buf_len);
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
-
-restart:
-	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, &timeo);
-	if (res)
+		rc = -ENOTCONN;
 		goto exit;
-
-	/* Look at first message in receive queue */
-	buf = skb_peek(&sk->sk_receive_queue);
-	msg = buf_msg(buf);
-	sz = msg_data_sz(msg);
-	hlen = msg_hdr_sz(msg);
-	err = msg_errcode(msg);
-
-	/* Discard an empty non-errored message & try again */
-	if ((!sz) && (!err)) {
-		tsk_advance_rx_queue(sk);
-		goto restart;
 	}
+	required = sock_rcvlowat(sk, flags & MSG_WAITALL, buflen);
+	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
-	/* Optionally capture sender's address & ancillary data of first msg */
-	if (sz_copied == 0) {
-		set_orig_addr(m, msg);
-		res = tipc_sk_anc_data_recv(m, msg, tsk);
-		if (res)
-			goto exit;
-	}
-
-	/* Capture message data (if valid) & compute return value (always) */
-	if (!err) {
-		u32 offset = TIPC_SKB_CB(buf)->bytes_read;
-		u32 needed;
-		int sz_to_copy;
-
-		sz -= offset;
-		needed = (buf_len - sz_copied);
-		sz_to_copy = min(sz, needed);
+	do {
+		/* Look at first msg in receive queue; wait if necessary */
+		rc = tipc_wait_for_rcvmsg(sock, &timeout);
+		if (unlikely(rc))
+			break;
+		skb = skb_peek(&sk->sk_receive_queue);
+		skb_cb = TIPC_SKB_CB(skb);
+		hdr = buf_msg(skb);
+		dlen = msg_data_sz(hdr);
+		hlen = msg_hdr_sz(hdr);
+		err = msg_errcode(hdr);
 
-		res = skb_copy_datagram_msg(buf, hlen + offset, m, sz_to_copy);
-		if (res)
-			goto exit;
+		/* Discard any empty non-errored (SYN-) message */
+		if (unlikely(!dlen && !err)) {
+			tsk_advance_rx_queue(sk);
+			continue;
+		}
 
-		sz_copied += sz_to_copy;
+		/* Collect msg meta data, incl. error code and rejected data */
+		if (!copied) {
+			set_orig_addr(m, hdr);
+			rc = tipc_sk_anc_data_recv(m, hdr, tsk);
+			if (rc)
+				break;
+		}
 
-		if (sz_to_copy < sz) {
-			if (!(flags & MSG_PEEK))
-				TIPC_SKB_CB(buf)->bytes_read =
-					offset + sz_to_copy;
-			goto exit;
+		/* Copy data if msg ok, otherwise return error/partial data */
+		if (likely(!err)) {
+			offset = skb_cb->bytes_read;
+			copy = min_t(int, dlen - offset, buflen - copied);
+			rc = skb_copy_datagram_msg(skb, hlen + offset, m, copy);
+			if (unlikely(rc))
+				break;
+			copied += copy;
+			offset += copy;
+			if (unlikely(offset < dlen)) {
+				if (!peek)
+					skb_cb->bytes_read = offset;
+				break;
+			}
+		} else {
+			rc = 0;
+			if ((err != TIPC_CONN_SHUTDOWN) && !m->msg_control)
+				rc = -ECONNRESET;
+			if (copied || rc)
+				break;
 		}
-	} else {
-		if (sz_copied != 0)
-			goto exit; /* can't add error msg to valid data */
 
-		if ((err == TIPC_CONN_SHUTDOWN) || m->msg_control)
-			res = 0;
-		else
-			res = -ECONNRESET;
-	}
+		if (unlikely(peek))
+			break;
 
-	if (unlikely(flags & MSG_PEEK))
-		goto exit;
+		tsk_advance_rx_queue(sk);
 
-	tsk->rcv_unacked += tsk_inc(tsk, hlen + msg_data_sz(msg));
-	if (unlikely(tsk->rcv_unacked >= (tsk->rcv_win / 4)))
-		tipc_sk_send_ack(tsk);
-	tsk_advance_rx_queue(sk);
+		/* Send connection flow control advertisement when applicable */
+		tsk->rcv_unacked += tsk_inc(tsk, hlen + dlen);
+		if (unlikely(tsk->rcv_unacked >= tsk->rcv_win / TIPC_ACK_RATE))
+			tipc_sk_send_ack(tsk);
 
-	/* Loop around if more data is required */
-	if ((sz_copied < buf_len) &&	/* didn't get all requested data */
-	    (!skb_queue_empty(&sk->sk_receive_queue) ||
-	    (sz_copied < target)) &&	/* and more is ready or required */
-	    (!err))			/* and haven't reached a FIN */
-		goto restart;
+		/* Exit if all requested data or FIN/error received */
+		if (copied == buflen || err)
+			break;
 
+	} while (!skb_queue_empty(&sk->sk_receive_queue) || copied < required);
 exit:
 	release_sock(sk);
-	return sz_copied ? sz_copied : res;
+	return copied ? copied : rc;
 }
 
 /**
@@ -2584,7 +2571,7 @@ static const struct proto_ops stream_ops = {
 	.setsockopt	= tipc_setsockopt,
 	.getsockopt	= tipc_getsockopt,
 	.sendmsg	= tipc_sendstream,
-	.recvmsg	= tipc_recv_stream,
+	.recvmsg	= tipc_recvstream,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage
 };
-- 
2.1.4
