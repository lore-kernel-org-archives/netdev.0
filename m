From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/28] tipc: Prevent rounding issues when saving connect timeout option
Date: Sat, 17 Sep 2011 23:32:12 -0400
Message-ID: <1316316744-29514-17-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49988 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319Ab1IRDcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:54 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Saves a socket's TIPC_CONN_TIMEOUT socket option value in its original
form (milliseconds), rather than jiffies. This ensures that the exact
value set using setsockopt() is always returned by getsockopt(), without
being subject to rounding issues introduced by a ms->jiffies->ms
conversion sequence.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index adb2eff..fc3c281 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -49,7 +49,7 @@ struct tipc_sock {
 	struct sock sk;
 	struct tipc_port *p;
 	struct tipc_portid peer_name;
-	long conn_timeout;
+	unsigned int conn_timeout;
 };
 
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
@@ -231,7 +231,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	sock_init_data(sock, sk);
 	sk->sk_backlog_rcv = backlog_rcv;
 	tipc_sk(sk)->p = tp_ptr;
-	tipc_sk(sk)->conn_timeout = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
+	tipc_sk(sk)->conn_timeout = CONN_TIMEOUT_DEFAULT;
 
 	spin_unlock_bh(tp_ptr->lock);
 
@@ -1369,7 +1369,7 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	struct msghdr m = {NULL,};
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
-	long timeout;
+	unsigned int timeout;
 	int res;
 
 	lock_sock(sk);
@@ -1434,7 +1434,8 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	res = wait_event_interruptible_timeout(*sk_sleep(sk),
 			(!skb_queue_empty(&sk->sk_receive_queue) ||
 			(sock->state != SS_CONNECTING)),
-			timeout ? timeout : MAX_SCHEDULE_TIMEOUT);
+			timeout ? (long)msecs_to_jiffies(timeout)
+				: MAX_SCHEDULE_TIMEOUT);
 	lock_sock(sk);
 
 	if (res > 0) {
@@ -1696,7 +1697,7 @@ static int setsockopt(struct socket *sock,
 		res = tipc_set_portunreturnable(tport->ref, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		tipc_sk(sk)->conn_timeout = msecs_to_jiffies(value);
+		tipc_sk(sk)->conn_timeout = value;
 		/* no need to set "res", since already 0 at this point */
 		break;
 	default:
@@ -1752,7 +1753,7 @@ static int getsockopt(struct socket *sock,
 		res = tipc_portunreturnable(tport->ref, &value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		value = jiffies_to_msecs(tipc_sk(sk)->conn_timeout);
+		value = tipc_sk(sk)->conn_timeout;
 		/* no need to set "res", since already 0 at this point */
 		break;
 	case TIPC_NODE_RECVQ_DEPTH:
-- 
1.7.4.4
