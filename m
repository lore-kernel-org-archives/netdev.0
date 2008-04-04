From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-2.6.26] [TIPC]: Improve socket time conversions
Date: Fri,  4 Apr 2008 16:59:47 -0400
Message-ID: <1207342787-12422-3-git-send-email-allan.stephens@windriver.com>
References: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48292 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbYDDVAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 17:00:34 -0400
In-Reply-To: <1207342787-12422-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies TIPC's socket code to use standard kernel
routines to handle time conversions between jiffies and ms.
This ensures proper operation even when HZ isn't 1000.

Acknowledgements to Eric Sesterhenn <snakebyte@gmx.de> for
identifying this issue and proposing a solution.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/socket.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 64be71a..3223107 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -58,7 +58,8 @@
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
-#define OVERLOAD_LIMIT_BASE    5000
+#define OVERLOAD_LIMIT_BASE	5000
+#define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 
 #define sock_port(sk) ((struct tipc_port *)(sk)->sk_user_data)
 
@@ -170,7 +171,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	}
 
 	sock_init_data(sock, sk);
-	sk->sk_rcvtimeo = 8 * HZ;   /* default connect timeout = 8s */
+	sk->sk_rcvtimeo = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
 
 	tsock = tipc_sk(sk);
 
@@ -1546,7 +1547,7 @@ static int setsockopt(struct socket *sock,
 		res = tipc_set_portunreturnable(tport->ref, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		sock->sk->sk_rcvtimeo = (value * HZ / 1000);
+		sock->sk->sk_rcvtimeo = msecs_to_jiffies(value);
 		break;
 	default:
 		res = -EINVAL;
@@ -1601,7 +1602,7 @@ static int getsockopt(struct socket *sock,
 		res = tipc_portunreturnable(tport->ref, &value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		value = (sock->sk->sk_rcvtimeo * 1000) / HZ;
+		value = jiffies_to_msecs(sock->sk->sk_rcvtimeo);
 		break;
 	default:
 		res = -EINVAL;
-- 
1.5.3.2

