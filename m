From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 2/2] tipc: allow rdm/dgram socketpairs
Date: Wed, 29 Mar 2017 11:22:17 +0200
Message-ID: <1490779337-6392-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1490779337-6392-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
        Erik Hugne <erik.hugne@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:43961 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754724AbdC2JWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 05:22:33 -0400
In-Reply-To: <1490779337-6392-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@gmail.com>

for socketpairs using connectionless transport, we cache
the respective node local TIPC portid to use in subsequent
calls to send() in the socket's private data.

Signed-off-by: Erik Hugne <erik.hugne@gmail.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1198dddf72e8..15f6ce7bf868 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2515,9 +2515,21 @@ static int tipc_socketpair(struct socket *sock1, struct socket *sock2)
 {
 	struct tipc_sock *tsk2 = tipc_sk(sock2->sk);
 	struct tipc_sock *tsk1 = tipc_sk(sock1->sk);
-
-	tipc_sk_finish_conn(tsk1, tsk2->portid, 0);
-	tipc_sk_finish_conn(tsk2, tsk1->portid, 0);
+	u32 onode = tipc_own_addr(sock_net(sock1->sk));
+
+	tsk1->peer.family = AF_TIPC;
+	tsk1->peer.addrtype = TIPC_ADDR_ID;
+	tsk1->peer.scope = TIPC_NODE_SCOPE;
+	tsk1->peer.addr.id.ref = tsk2->portid;
+	tsk1->peer.addr.id.node = onode;
+	tsk2->peer.family = AF_TIPC;
+	tsk2->peer.addrtype = TIPC_ADDR_ID;
+	tsk2->peer.scope = TIPC_NODE_SCOPE;
+	tsk2->peer.addr.id.ref = tsk1->portid;
+	tsk2->peer.addr.id.node = onode;
+
+	tipc_sk_finish_conn(tsk1, tsk2->portid, onode);
+	tipc_sk_finish_conn(tsk2, tsk1->portid, onode);
 	return 0;
 }
 
@@ -2529,7 +2541,7 @@ static const struct proto_ops msg_ops = {
 	.release	= tipc_release,
 	.bind		= tipc_bind,
 	.connect	= tipc_connect,
-	.socketpair	= sock_no_socketpair,
+	.socketpair	= tipc_socketpair,
 	.accept		= sock_no_accept,
 	.getname	= tipc_getname,
 	.poll		= tipc_poll,
-- 
2.1.4
