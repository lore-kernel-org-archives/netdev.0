From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 02/18] tipc: improve address sanity check in tipc_connect()
Date: Thu, 12 Oct 2017 16:02:23 +0200
Message-ID: <1507816959-31787-3-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:46423 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdJLOCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:50 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The address given to tipc_connect() is not completely sanity checked,
under the assumption that this will be done later in the function
__tipc_sendmsg() when the address is used there.

However, the latter functon will in the next commits serve as caller
to several other send functions, so we want to move the corresponding
sanity check there to the beginning of that function, before we possibly
need to grab the address stored by tipc_connect(). We must therefore
be able to trust that this address already has been thoroughly checked.

We do this in this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9a7e7b5c..7659e79 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1911,28 +1911,27 @@ static int tipc_connect(struct socket *sock, struct sockaddr *dest,
 	int previous;
 	int res = 0;
 
+	if (destlen != sizeof(struct sockaddr_tipc))
+		return -EINVAL;
+
 	lock_sock(sk);
 
-	/* DGRAM/RDM connect(), just save the destaddr */
-	if (tipc_sk_type_connectionless(sk)) {
-		if (dst->family == AF_UNSPEC) {
-			memset(&tsk->peer, 0, sizeof(struct sockaddr_tipc));
-		} else if (destlen != sizeof(struct sockaddr_tipc)) {
+	if (dst->family == AF_UNSPEC) {
+		memset(&tsk->peer, 0, sizeof(struct sockaddr_tipc));
+		if (!tipc_sk_type_connectionless(sk))
 			res = -EINVAL;
-		} else {
-			memcpy(&tsk->peer, dest, destlen);
-		}
 		goto exit;
+	} else if (dst->family != AF_TIPC) {
+		res = -EINVAL;
 	}
-
-	/*
-	 * Reject connection attempt using multicast address
-	 *
-	 * Note: send_msg() validates the rest of the address fields,
-	 *       so there's no need to do it here
-	 */
-	if (dst->addrtype == TIPC_ADDR_MCAST) {
+	if (dst->addrtype != TIPC_ADDR_ID && dst->addrtype != TIPC_ADDR_NAME)
 		res = -EINVAL;
+	if (res)
+		goto exit;
+
+	/* DGRAM/RDM connect(), just save the destaddr */
+	if (tipc_sk_type_connectionless(sk)) {
+		memcpy(&tsk->peer, dest, destlen);
 		goto exit;
 	}
 
-- 
2.1.4
