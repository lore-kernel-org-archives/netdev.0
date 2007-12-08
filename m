From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] Incorrect time conversion in TIPC
Date: Sat, 8 Dec 2007 13:49:57 +0100
Message-ID: <20071208124957.GB4757@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53000 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753626AbXLHMt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2007 07:49:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

the timeouts in tipc/socket.c dont match if HZ is not 1000,
this patch changes it to use the proper conversion functions.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.24-rc3/net/tipc/socket.c.orig	2007-12-07 20:07:11.000000000 +0100
+++ linux-2.6.24-rc3/net/tipc/socket.c	2007-12-07 20:11:15.000000000 +0100
@@ -209,7 +209,7 @@ static int tipc_create(struct net *net, 
 
 	sock_init_data(sock, sk);
 	init_waitqueue_head(sk->sk_sleep);
-	sk->sk_rcvtimeo = 8 * HZ;   /* default connect timeout = 8s */
+	sk->sk_rcvtimeo = msecs_to_jiffies(8000);   /* default connect timeout = 8s */
 
 	tsock = tipc_sk(sk);
 	port = tipc_get_port(ref);
@@ -1535,7 +1535,7 @@ static int setsockopt(struct socket *soc
 		res = tipc_set_portunreturnable(tsock->p->ref, value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		sock->sk->sk_rcvtimeo = (value * HZ / 1000);
+		sock->sk->sk_rcvtimeo = msecs_to_jiffies(value);
 		break;
 	default:
 		res = -EINVAL;
@@ -1588,7 +1588,7 @@ static int getsockopt(struct socket *soc
 		res = tipc_portunreturnable(tsock->p->ref, &value);
 		break;
 	case TIPC_CONN_TIMEOUT:
-		value = (sock->sk->sk_rcvtimeo * 1000) / HZ;
+		value = jiffies_to_msecs(sock->sk->sk_rcvtimeo);
 		break;
 	default:
 		res = -EINVAL;
