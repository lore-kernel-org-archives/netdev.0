From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [BUG]  TIPC handling of -ERESTARTSYS in connect()
Date: Fri, 31 Aug 2012 17:37:29 +0800
Message-ID: <504085D9.3010907@windriver.com>
References: <503F84CF.208@genband.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------030602070603030001000505"
Cc: netdev <netdev@vger.kernel.org>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:36385 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab2HaJhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 05:37:31 -0400
In-Reply-To: <503F84CF.208@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------030602070603030001000505
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hi Chris,

Although this is a known issue, still thanks for your report.

Regardless of 1.7.7 or mainline, the issue really exists.
Can you please check and verify the attached patch?

PS: the patch is based on 1.7.7 rather than mainline.

Thanks,
Ying

Chris Friesen wrote:
> Hi,
>
> I'm seeing some behaviour that looks unintentional in the TIPC connect() call.
> I'm running TIPC 1.7.7.  My userspace code (stripped of error handling) looks
> like this:
>
> 	int sd = socket (AF_TIPC, SOCK_SEQPACKET,0);
> 	connect(sd,(struct sockaddr*)&topsrv,sizeof(topsrv));
>
> where topsrv is the address of the TIPC topology server.  The thing that's weird
> is that intermittently we get a EISCONN error on the connect call.
>
> Looking at the TIPC connect() code, I think what is happening is that
> wait_event_interruptible_timeout() is being interrupted by a signal and returns
> -ERESTARTSYS.  This sets sock->state to SS_DISCONNECTING and exits.  Userspace
> sees the ERESTARTSYS and retries the syscall, then we hit the
> "sock->state != SS_UNCONNECTED" check and exit with -EISCONN.
>
> I think current mainline is susceptible to this as well.
>
> I'm not sure what the proper fix would be--can we detect coming back in that we were
> waiting for a message and just skip down to the wait_event_interruptible_timeout()
> call?
>
> Chris
>
>
>   


--------------030602070603030001000505
Content-Type: text/x-diff;
	name="0001-tipc-correctly-handle-ERESTARTSYS-return-value-of-co.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename*0="0001-tipc-correctly-handle-ERESTARTSYS-return-value-of-co.pa";
	filename*1="tch"

>From d1f38c0016bf9e1c24aa9c41efca857b6a302b4e Mon Sep 17 00:00:00 2001
From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 31 Aug 2012 17:26:13 +0800
Subject: [PATCH] tipc: correctly handle -ERESTARTSYS return value of connect()

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/tipc_socket.c |  109 +++++++++++++++++++++++++-----------------------
 1 files changed, 57 insertions(+), 52 deletions(-)

diff --git a/net/tipc/tipc_socket.c b/net/tipc/tipc_socket.c
index c135edf..aa5d57f 100644
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
+	case SS_CONNECTING:
+		res = -EALREADY;
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


--------------030602070603030001000505--
