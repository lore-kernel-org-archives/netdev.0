From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/14] tipc: Allow connect() to wait indefinitely
Date: Tue, 17 Aug 2010 17:00:15 -0400
Message-ID: <1282078816-11844-14-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57156 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab0HQVA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:29 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Cause a socket whose TIPC_CONN_TIMEOUT option is zero to wait
indefinitely for a response to a connection request using connect().
Previously, specifying a timeout of 0 ms resulted in an immediate
timeout, which was inconsistent with the behavior specified by Posix
for a socket's receive and send timeout.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7b81fdd..f7ac94d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -64,6 +64,7 @@ struct tipc_sock {
 	struct sock sk;
 	struct tipc_port *p;
 	struct tipc_portid peer_name;
+	long conn_timeout;
 };
 
 #define tipc_sk(sk) ((struct tipc_sock *)(sk))
@@ -240,9 +241,9 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 	sock->state = state;
 
 	sock_init_data(sock, sk);
-	sk->sk_rcvtimeo = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
 	sk->sk_backlog_rcv = backlog_rcv;
 	tipc_sk(sk)->p = tp_ptr;
+	tipc_sk(sk)->conn_timeout = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
 
 	spin_unlock_bh(tp_ptr->lock);
 
@@ -1385,6 +1386,7 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 	struct msghdr m = {NULL,};
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
+	long timeout;
 	int res;
 
 	lock_sock(sk);
@@ -1445,11 +1447,12 @@ static int connect(struct socket *sock, struct sockaddr *dest, int destlen,
 
 	/* Wait until an 'ACK' or 'RST' arrives, or a timeout occurs */
 
+	timeout = tipc_sk(sk)->conn_timeout;
 	release_sock(sk);
 	res = wait_event_interruptible_timeout(*sk_sleep(sk),
 			(!skb_queue_empty(&sk->sk_receive_queue) ||
 			(sock->state != SS_CONNECTING)),
-			sk->sk_rcvtimeo);
+			timeout ? timeout : MAX_SCHEDULE_TIMEOUT);
 	lock_sock(sk);
 
 	if (res > 0) {
@@ -1712,7 +1715,7 @@ static int setsockopt(struct socket *sock,
 		res = tipc_set_portunreturnable(tport->ref, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		sk->sk_rcvtimeo = msecs_to_jiffies(value);
+		tipc_sk(sk)->conn_timeout = msecs_to_jiffies(value);
 		/* no need to set "res", since already 0 at this point */
 		break;
 	default:
@@ -1767,7 +1770,7 @@ static int getsockopt(struct socket *sock,
 		res = tipc_portunreturnable(tport->ref, &value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		value = jiffies_to_msecs(sk->sk_rcvtimeo);
+		value = jiffies_to_msecs(tipc_sk(sk)->conn_timeout);
 		/* no need to set "res", since already 0 at this point */
 		break;
 	 case TIPC_NODE_RECVQ_DEPTH:
-- 
1.7.2.1

