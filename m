From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Mon, 3 Sep 2012 11:16:13 +0800
Message-ID: <504420FD.4030908@windriver.com>
References: <503F84CF.208@genband.com> <504085D9.3010907@windriver.com> <5040D3C4.2010308@genband.com> <5040D5D9.4040802@genband.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090507080401030106030600"
Cc: netdev <netdev@vger.kernel.org>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38176 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab2ICDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 23:16:07 -0400
In-Reply-To: <5040D5D9.4040802@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------090507080401030106030600
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit


>>
>> It looks like the case where we come in with "sock->state ==
>> SS_LISTENING" has changed. Previously we would return -EOPNOTSUPP but
>> now it'll be -EINVAL. Is that intentional?
>
> Just noticed something else.  In the SS_CONNECTING case I don't think 
> there's any point in setting "res = -EALREADY" since a bit further 
> down it gets set unconditionally anyway.
>
Yes, you are right. Please check v2 version.

Thanks,
Ying

> Chris
>


--------------090507080401030106030600
Content-Type: text/x-diff;
	name="0001-tipc-correct-return-value-of-connect-when-it-is-inte.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename*0="0001-tipc-correct-return-value-of-connect-when-it-is-inte.pa";
	filename*1="tch"

>From 8c4606c4dbb1cf47f357cc3620ba5b70b433b670 Mon Sep 17 00:00:00 2001
From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 3 Sep 2012 10:29:28 +0800
Subject: [PATCH v2] tipc: correct return value of connect() when it is interrupted by a signal

When connect() is interrupted by a signal, it returns -ERESTARTSYS
error code, meanwhile socket state is also changed to SS_DISCONNECTING
state. If connect() syscall exits from kernel space to userspace,
kernel will deal with the pending signal. Once seeing the -ERESTARTSYS,
it will retry this syscall again. As a result, finally userspace gets
-EISCONN error code from connect() at the moment.

Correct behavior of connect() is that we should not set socket state
SS_DISCONNECTING when signal happens, but it may return a successful
code to userspace after signal is handled.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/tipc_socket.c |  109 +++++++++++++++++++++++++-----------------------
 1 files changed, 57 insertions(+), 52 deletions(-)

diff --git a/net/tipc/tipc_socket.c b/net/tipc/tipc_socket.c
index c135edf..d800087 100644
--- a/net/tipc/tipc_socket.c
+++ b/net/tipc/tipc_socket.c
@@ -1456,21 +1456,6 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 	}
 
-	/* Issue Posix-compliant error code if socket is in the wrong state */
-
-	if (sock->state == SS_LISTENING) {
-		res = -EOPNOTSUPP;
-		goto exit;
-	}
-	if (sock->state == SS_CONNECTING) {
-		res = -EALREADY;
-		goto exit;
-	}
-	if (sock->state != SS_UNCONNECTED) {
-		res = -EISCONN;
-		goto exit;
-	}
-
 	/*
 	 * Reject connection attempt using multicast address
 	 *
@@ -1483,54 +1468,74 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 		goto exit;
 	}
 
-	/* Reject any messages already in receive queue (very unlikely) */
-
-	reject_rx_queue(sk);
+	switch (sock->state) {
+	case SS_UNCONNECTED:
+		/* Reject any messages already in receive queue
+		 * (very unlikely) */
+		reject_rx_queue(sk);
 
-	/* Send a 'SYN-' to destination */
+		/* Send a 'SYN-' to destination */
+		m.msg_name = dest;
+		m.msg_namelen = destlen;
+		res = send_msg(NULL, sock, &m, 0);
+		if (res < 0) {
+			goto exit;
+		}
 
-	m.msg_name = dest;
-	m.msg_namelen = destlen;
-	res = send_msg(NULL, sock, &m, 0);
-	if (res < 0) {
-		goto exit;
+		/*
+		 * Just entered SS_CONNECTING state; the only
+		 * difference is that return value in non-blocking
+		 * case is EINPROGRESS, rather than EALREADY.
+		 */
+		res = -EINPROGRESS;
+		break;
+	case SS_LISTENING:
+		res = -EOPNOTSUPP;
+		break;
+	case SS_CONNECTED:
+		res = -EISCONN;
+		break;
+	default:
+		res = -EINVAL;
+		break;
 	}
 
-	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
-
-	timeout = tipc_sk(sk)->conn_timeout;
-	release_sock(sk);
-	res = wait_event_interruptible_timeout(*sk->sk_sleep,
-			(!skb_queue_empty(&sk->sk_receive_queue) ||
-			(sock->state != SS_CONNECTING)),
-			timeout ? (long)msecs_to_jiffies(timeout)
-				: MAX_SCHEDULE_TIMEOUT);
-	lock_sock(sk);
+	if (sock->state == SS_CONNECTING) {
+		/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
+		timeout = tipc_sk(sk)->conn_timeout;
+		release_sock(sk);
+		res = wait_event_interruptible_timeout(*sk->sk_sleep,
+				(!skb_queue_empty(&sk->sk_receive_queue) ||
+				(sock->state != SS_CONNECTING)),
+				timeout ? (long)msecs_to_jiffies(timeout)
+					: MAX_SCHEDULE_TIMEOUT);
+		lock_sock(sk);
 
-	if (res > 0) {
-		buf = skb_peek(&sk->sk_receive_queue);
-		if (buf != NULL) {
-			msg = buf_msg(buf);
-			res = auto_connect(sock, msg);
-			if (!res) {
-				if (!msg_data_sz(msg))
-					advance_rx_queue(sk);
+		if (res > 0) {
+			buf = skb_peek(&sk->sk_receive_queue);
+			if (buf != NULL) {
+				msg = buf_msg(buf);
+				res = auto_connect(sock, msg);
+				if (!res) {
+					if (!msg_data_sz(msg))
+						advance_rx_queue(sk);
+				}
+			} else {
+				if (sock->state == SS_CONNECTED) {
+					res = -EISCONN;
+				} else {
+					res = -ECONNREFUSED;
+				}
 			}
 		} else {
-			if (sock->state == SS_CONNECTED) {
-				res = -EISCONN;
+			if (res == 0) {
+				sock->state = SS_DISCONNECTING;
+				res = -ETIMEDOUT;
 			} else {
-				res = -ECONNREFUSED;
+				; /* leave "res" unchanged */
 			}
 		}
-	} else {
-		if (res == 0)
-			res = -ETIMEDOUT;
-		else
-			; /* leave "res" unchanged */
-		sock->state = SS_DISCONNECTING;
 	}
-
 exit:
 	release_sock(sk);
 	return res;
-- 
1.7.1


--------------090507080401030106030600--
