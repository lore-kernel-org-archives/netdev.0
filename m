From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 25/28] tipc: Add support for SO_SNDTIMEO socket option
Date: Sat, 17 Sep 2011 23:32:21 -0400
Message-ID: <1316316744-29514-26-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50005 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756302Ab1IRDdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:33:01 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Adds support for the SO_SNDTIMEO socket option. (This complements the
existing support for SO_RCVTIMEO that is already present.)

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index fc3c281..2f90beb 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -525,6 +525,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
 	int needs_conn;
+	long timeout_val;
 	int res = -EINVAL;
 
 	if (unlikely(!dest))
@@ -564,6 +565,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 		reject_rx_queue(sk);
 	}
 
+	timeout_val = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
+
 	do {
 		if (dest->addrtype == TIPC_ADDR_NAME) {
 			res = dest_name_check(dest, m);
@@ -600,16 +603,14 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 				sock->state = SS_CONNECTING;
 			break;
 		}
-		if (m->msg_flags & MSG_DONTWAIT) {
-			res = -EWOULDBLOCK;
+		if (timeout_val <= 0L) {
+			res = timeout_val ? timeout_val : -EWOULDBLOCK;
 			break;
 		}
 		release_sock(sk);
-		res = wait_event_interruptible(*sk_sleep(sk),
-					       !tport->congested);
+		timeout_val = wait_event_interruptible_timeout(*sk_sleep(sk),
+					       !tport->congested, timeout_val);
 		lock_sock(sk);
-		if (res)
-			break;
 	} while (1);
 
 exit:
@@ -636,6 +637,7 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct tipc_port *tport = tipc_sk_port(sk);
 	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
+	long timeout_val;
 	int res;
 
 	/* Handle implied connection establishment */
@@ -650,6 +652,8 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 	if (iocb)
 		lock_sock(sk);
 
+	timeout_val = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
+
 	do {
 		if (unlikely(sock->state != SS_CONNECTED)) {
 			if (sock->state == SS_DISCONNECTING)
@@ -663,16 +667,14 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 				total_len);
 		if (likely(res != -ELINKCONG))
 			break;
-		if (m->msg_flags & MSG_DONTWAIT) {
-			res = -EWOULDBLOCK;
+		if (timeout_val <= 0L) {
+			res = timeout_val ? timeout_val : -EWOULDBLOCK;
 			break;
 		}
 		release_sock(sk);
-		res = wait_event_interruptible(*sk_sleep(sk),
-			(!tport->congested || !tport->connected));
+		timeout_val = wait_event_interruptible_timeout(*sk_sleep(sk),
+			(!tport->congested || !tport->connected), timeout_val);
 		lock_sock(sk);
-		if (res)
-			break;
 	} while (1);
 
 	if (iocb)
-- 
1.7.4.4
