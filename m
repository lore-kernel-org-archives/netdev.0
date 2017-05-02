From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 1/2] tipc: refactor function tipc_sk_recvmsg()
Date: Tue, 2 May 2017 18:16:53 +0200
Message-ID: <1493741814-25899-2-git-send-email-jon.maloy@ericsson.com>
References: <1493741814-25899-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:48807 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdEBQRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 12:17:42 -0400
In-Reply-To: <1493741814-25899-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We try to make this function more readable by improving variable names
and comments, plus some minor changes to the logics.

Reviewed-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/socket.c | 109 +++++++++++++++++++++++++-----------------------------
 1 file changed, 50 insertions(+), 59 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 8a4e9fe..3855bfd 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -51,6 +51,7 @@
 #define TIPC_FWD_MSG		1
 #define TIPC_MAX_PORT		0xffffffff
 #define TIPC_MIN_PORT		1
+#define TIPC_ACK_RATE		4       /* ACK at 1/4 of of rcv window size */
 
 enum {
 	TIPC_LISTEN = TCP_LISTEN,
@@ -1290,7 +1291,7 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
 /**
  * tipc_recvmsg - receive packet-oriented message
  * @m: descriptor for message info
- * @buf_len: total size of user buffer area
+ * @buflen: length of user buffer area
  * @flags: receive flags
  *
  * Used for SOCK_DGRAM, SOCK_RDM, and SOCK_SEQPACKET messages.
@@ -1298,89 +1299,79 @@ static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
  *
  * Returns size of returned message data, errno otherwise
  */
-static int tipc_recvmsg(struct socket *sock, struct msghdr *m, size_t buf_len,
-			int flags)
+static int tipc_recvmsg(struct socket *sock, struct msghdr *m,
+			size_t buflen,	int flags)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-	bool is_connectionless = tipc_sk_type_connectionless(sk);
-	long timeo;
-	unsigned int sz;
-	u32 err;
-	int res, hlen;
+	struct sk_buff *skb;
+	struct tipc_msg *hdr;
+	bool connected = !tipc_sk_type_connectionless(sk);
+	int rc, err, hlen, dlen, copy;
+	long timeout;
 
 	/* Catch invalid receive requests */
-	if (unlikely(!buf_len))
+	if (unlikely(!buflen))
 		return -EINVAL;
 
 	lock_sock(sk);
-
-	if (!is_connectionless && unlikely(sk->sk_state == TIPC_OPEN)) {
-		res = -ENOTCONN;
+	if (unlikely(connected && sk->sk_state == TIPC_OPEN)) {
+		rc = -ENOTCONN;
 		goto exit;
 	}
+	timeout = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
 
-	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
-restart:
-
-	/* Look for a message in receive queue; wait if necessary */
-	res = tipc_wait_for_rcvmsg(sock, &timeo);
-	if (res)
-		goto exit;
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
+	do {
+		/* Look at first msg in receive queue; wait if necessary */
+		rc = tipc_wait_for_rcvmsg(sock, &timeout);
+		if (unlikely(rc))
+			goto exit;
+		skb = skb_peek(&sk->sk_receive_queue);
+		hdr = buf_msg(skb);
+		dlen = msg_data_sz(hdr);
+		hlen = msg_hdr_sz(hdr);
+		err = msg_errcode(hdr);
+		if (likely(dlen || err))
+			break;
 		tsk_advance_rx_queue(sk);
-		goto restart;
-	}
+	} while (1);
 
-	/* Capture sender's address (optional) */
-	set_orig_addr(m, msg);
-
-	/* Capture ancillary data (optional) */
-	res = tipc_sk_anc_data_recv(m, msg, tsk);
-	if (res)
+	/* Collect msg meta data, including error code and rejected data */
+	set_orig_addr(m, hdr);
+	rc = tipc_sk_anc_data_recv(m, hdr, tsk);
+	if (unlikely(rc))
 		goto exit;
 
-	/* Capture message data (if valid) & compute return value (always) */
-	if (!err) {
-		if (unlikely(buf_len < sz)) {
-			sz = buf_len;
+	/* Capture data if non-error msg, otherwise just set return value */
+	if (likely(!err)) {
+		copy = min_t(int, dlen, buflen);
+		if (unlikely(copy != dlen))
 			m->msg_flags |= MSG_TRUNC;
-		}
-		res = skb_copy_datagram_msg(buf, hlen, m, sz);
-		if (res)
-			goto exit;
-		res = sz;
+		rc = skb_copy_datagram_msg(skb, hlen, m, copy);
 	} else {
-		if (is_connectionless || err == TIPC_CONN_SHUTDOWN ||
-		    m->msg_control)
-			res = 0;
-		else
-			res = -ECONNRESET;
+		copy = 0;
+		rc = 0;
+		if (err != TIPC_CONN_SHUTDOWN && connected && !m->msg_control)
+			rc = -ECONNRESET;
 	}
+	if (unlikely(rc))
+		goto exit;
 
+	/* Caption of data or error code/rejected data was successful */
 	if (unlikely(flags & MSG_PEEK))
 		goto exit;
 
-	if (likely(!is_connectionless)) {
-		tsk->rcv_unacked += tsk_inc(tsk, hlen + sz);
-		if (unlikely(tsk->rcv_unacked >= (tsk->rcv_win / 4)))
-			tipc_sk_send_ack(tsk);
-	}
 	tsk_advance_rx_queue(sk);
+	if (likely(!connected))
+		goto exit;
+
+	/* Send connection flow control ack when applicable */
+	tsk->rcv_unacked += tsk_inc(tsk, hlen + dlen);
+	if (tsk->rcv_unacked >= tsk->rcv_win / TIPC_ACK_RATE)
+		tipc_sk_send_ack(tsk);
 exit:
 	release_sock(sk);
-	return res;
+	return rc ? rc : copy;
 }
 
 /**
-- 
2.1.4
