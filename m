From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/20] tipc: Reject connection protocol message sent to unconnected port
Date: Fri, 24 Jun 2011 18:07:25 -0400
Message-ID: <1308953247-25266-19-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34420 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945Ab1FXWHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:54 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Restructures the logic used in tipc_port_recv_proto_msg() to ensure
that incoming connection protocol messages are handled properly. The
routine now uses a two-stage process that first ensures the message
applies on an existing connection and then processes the request.
This corrects a loophole that allowed a connection probe request to
be processed if it was sent to an unconnected port that had no names
bound to it.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   79 ++++++++++++++++++++++++++++---------------------------
 1 files changed, 40 insertions(+), 39 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 8be68e0..1b20b96 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -526,62 +526,63 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 er
 void tipc_port_recv_proto_msg(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_port *p_ptr = tipc_port_lock(msg_destport(msg));
-	u32 err = TIPC_OK;
+	struct tipc_port *p_ptr;
 	struct sk_buff *r_buf = NULL;
-	struct sk_buff *abort_buf = NULL;
-
-	if (!p_ptr) {
-		err = TIPC_ERR_NO_PORT;
-	} else if (p_ptr->connected) {
-		if ((port_peernode(p_ptr) != msg_orignode(msg)) ||
-		    (port_peerport(p_ptr) != msg_origport(msg))) {
-			err = TIPC_ERR_NO_PORT;
-		} else if (msg_type(msg) == CONN_ACK) {
-			int wakeup = tipc_port_congested(p_ptr) &&
-				     p_ptr->congested &&
-				     p_ptr->wakeup;
-			p_ptr->acked += msg_msgcnt(msg);
-			if (tipc_port_congested(p_ptr))
-				goto exit;
-			p_ptr->congested = 0;
-			if (!wakeup)
-				goto exit;
-			p_ptr->wakeup(p_ptr);
-			goto exit;
-		}
-	} else if (p_ptr->published) {
-		err = TIPC_ERR_NO_PORT;
-	}
-	if (err) {
-		r_buf = port_build_proto_msg(msg_origport(msg),
-					     msg_orignode(msg),
-					     msg_destport(msg),
+	u32 orignode = msg_orignode(msg);
+	u32 origport = msg_origport(msg);
+	u32 destport = msg_destport(msg);
+	int wakeable;
+
+	/* Validate connection */
+
+	p_ptr = tipc_port_lock(destport);
+	if (!p_ptr || !p_ptr->connected ||
+	    (port_peernode(p_ptr) != orignode) ||
+	    (port_peerport(p_ptr) != origport)) {
+		r_buf = port_build_proto_msg(origport,
+					     orignode,
+					     destport,
 					     tipc_own_addr,
 					     TIPC_HIGH_IMPORTANCE,
 					     TIPC_CONN_MSG,
-					     err,
+					     TIPC_ERR_NO_PORT,
 					     0);
+		if (p_ptr)
+			tipc_port_unlock(p_ptr);
 		goto exit;
 	}
 
-	/* All is fine */
-	if (msg_type(msg) == CONN_PROBE) {
-		r_buf = port_build_proto_msg(msg_origport(msg),
-					     msg_orignode(msg),
-					     msg_destport(msg),
+	/* Process protocol message sent by peer */
+
+	switch (msg_type(msg)) {
+	case CONN_ACK:
+		wakeable = tipc_port_congested(p_ptr) && p_ptr->congested &&
+			p_ptr->wakeup;
+		p_ptr->acked += msg_msgcnt(msg);
+		if (!tipc_port_congested(p_ptr)) {
+			p_ptr->congested = 0;
+			if (wakeable)
+				p_ptr->wakeup(p_ptr);
+		}
+		break;
+	case CONN_PROBE:
+		r_buf = port_build_proto_msg(origport,
+					     orignode,
+					     destport,
 					     tipc_own_addr,
 					     CONN_MANAGER,
 					     CONN_PROBE_REPLY,
 					     TIPC_OK,
 					     0);
+		break;
+	default:
+		/* CONN_PROBE_REPLY or unrecognized - no action required */
+		break;
 	}
 	p_ptr->probing_state = CONFIRMED;
+	tipc_port_unlock(p_ptr);
 exit:
-	if (p_ptr)
-		tipc_port_unlock(p_ptr);
 	tipc_net_route_msg(r_buf);
-	tipc_net_route_msg(abort_buf);
 	buf_discard(buf);
 }
 
-- 
1.7.4.4

