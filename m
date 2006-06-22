From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 23/32] [TIPC] Optimized argument validation done by connect().
Date: Thu, 22 Jun 2006 15:59:36 +0200
Message-ID: <11509847872073-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:38038 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030661AbWFVN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:52 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/socket.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6d4d2b0..32d7784 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -455,7 +455,8 @@ static int send_msg(struct kiocb *iocb, 
 
 	if (unlikely(!dest))
 		return -EDESTADDRREQ;
-	if (unlikely(dest->family != AF_TIPC))
+	if (unlikely((m->msg_namelen < sizeof(*dest)) ||
+		     (dest->family != AF_TIPC)))
 		return -EINVAL;
 
 	needs_conn = (sock->state != SS_READY);
@@ -1245,7 +1246,8 @@ static int connect(struct socket *sock, 
    if (sock->state == SS_READY)
 	   return -EOPNOTSUPP;
 
-   /* MOVE THE REST OF THIS ERROR CHECKING TO send_msg()? */
+   /* Issue Posix-compliant error code if socket is in the wrong state */
+
    if (sock->state == SS_LISTENING)
 	   return -EOPNOTSUPP;
    if (sock->state == SS_CONNECTING)
@@ -1253,13 +1255,20 @@ static int connect(struct socket *sock, 
    if (sock->state != SS_UNCONNECTED)
            return -EISCONN;
 
-   if ((destlen < sizeof(*dst)) || (dst->family != AF_TIPC) ||
-       ((dst->addrtype != TIPC_ADDR_NAME) && (dst->addrtype != TIPC_ADDR_ID)))
+   /*
+    * Reject connection attempt using multicast address
+    *
+    * Note: send_msg() validates the rest of the address fields,
+    *       so there's no need to do it here
+    */
+
+   if (dst->addrtype == TIPC_ADDR_MCAST)
            return -EINVAL;
 
    /* Send a 'SYN-' to destination */
 
    m.msg_name = dest;
+   m.msg_namelen = destlen;
    if ((res = send_msg(NULL, sock, &m, 0)) < 0) {
 	   sock->state = SS_DISCONNECTING;
 	   return res;
-- 
1.4.0

