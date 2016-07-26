From: Phil Turnbull <phil.turnbull@oracle.com>
Subject: [PATCH net] l2tp: Correctly return -EBADF from pppol2tp_getname.
Date: Tue, 26 Jul 2016 15:14:35 -0400
Message-ID: <20160726191435.31503-1-phil.turnbull@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>,
	Phil Turnbull <phil.turnbull@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24291 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbcGZTQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 15:16:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If 'tunnel' is NULL we should return -EBADF but the 'end_put_sess' path
unconditionally sets 'error' back to zero. Rework the error path so it
more closely matches pppol2tp_sendmsg.

Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>
---
 net/l2tp/l2tp_ppp.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 652c250b9a3b..d9560aa2dba3 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -866,10 +866,8 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	pls = l2tp_session_priv(session);
 	tunnel = l2tp_sock_to_tunnel(pls->tunnel_sock);
-	if (tunnel == NULL) {
-		error = -EBADF;
+	if (tunnel == NULL)
 		goto end_put_sess;
-	}
 
 	inet = inet_sk(tunnel->sock);
 	if ((tunnel->version == 2) && (tunnel->sock->sk_family == AF_INET)) {
@@ -947,12 +945,11 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 	}
 
 	*usockaddr_len = len;
+	error = 0;
 
 	sock_put(pls->tunnel_sock);
 end_put_sess:
 	sock_put(sk);
-	error = 0;
-
 end:
 	return error;
 }
-- 
2.9.0.rc2
