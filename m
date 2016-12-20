From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 1/2] sctp: reduce indent level in sctp_copy_local_addr_list
Date: Tue, 20 Dec 2016 13:49:49 +0800
Message-ID: <b4d6428c565955e9e81e3b4623a6458e7567e593.1482212764.git.lucien.xin@gmail.com>
References: <cover.1482212764.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34621 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754745AbcLTFuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 00:50:07 -0500
In-Reply-To: <cover.1482212764.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1482212764.git.lucien.xin@gmail.com>
References: <cover.1482212764.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to reduce indent level by using continue when the addr
is not allowed, and also drop end_copy by using break.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/protocol.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 7b523e3..da5d82b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -205,26 +205,27 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
 	list_for_each_entry_rcu(addr, &net->sctp.local_addr_list, list) {
 		if (!addr->valid)
 			continue;
-		if (sctp_in_scope(net, &addr->a, scope)) {
-			/* Now that the address is in scope, check to see if
-			 * the address type is really supported by the local
-			 * sock as well as the remote peer.
-			 */
-			if ((((AF_INET == addr->a.sa.sa_family) &&
-			      (copy_flags & SCTP_ADDR4_PEERSUPP))) ||
-			    (((AF_INET6 == addr->a.sa.sa_family) &&
-			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
-			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
-				error = sctp_add_bind_addr(bp, &addr->a,
-						    sizeof(addr->a),
-						    SCTP_ADDR_SRC, GFP_ATOMIC);
-				if (error)
-					goto end_copy;
-			}
-		}
+		if (!sctp_in_scope(net, &addr->a, scope))
+			continue;
+
+		/* Now that the address is in scope, check to see if
+		 * the address type is really supported by the local
+		 * sock as well as the remote peer.
+		 */
+		if (addr->a.sa.sa_family == AF_INET &&
+		    !(copy_flags & SCTP_ADDR4_PEERSUPP))
+			continue;
+		if (addr->a.sa.sa_family == AF_INET6 &&
+		    (!(copy_flags & SCTP_ADDR6_ALLOWED) ||
+		     !(copy_flags & SCTP_ADDR6_PEERSUPP)))
+			continue;
+
+		error = sctp_add_bind_addr(bp, &addr->a, sizeof(addr->a),
+					   SCTP_ADDR_SRC, GFP_ATOMIC);
+		if (error)
+			break;
 	}
 
-end_copy:
 	rcu_read_unlock();
 	return error;
 }
-- 
2.1.0
