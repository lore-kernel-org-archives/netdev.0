From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 02/16] tipc: wakeup sleeping users at disconnect
Date: Tue, 1 Nov 2016 14:02:35 +0100
Message-ID: <1478005369-17239-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:64166 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424264AbcKANDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:03:07 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, in filter_connect() when we terminate a connection due to
an error message from peer, we set the socket state to DISCONNECTING.

The socket is notified about this broken connection using EPIPE when
a user tries to send a message. However if a socket was waiting on a
poll() while the connection is being terminated, we fail to wakeup
that socket.

In this commit, we wakeup sleeping sockets at connection termination.

Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index adf3e6ecf61e..cd01deb1da9c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1599,6 +1599,7 @@ static bool filter_connect(struct tipc_sock *tsk, struct sk_buff *skb)
 			/* Let timer expire on it's own */
 			tipc_node_remove_conn(net, tsk_peer_node(tsk),
 					      tsk->portid);
+			sk->sk_state_change(sk);
 		}
 		return true;
 
-- 
2.1.4
