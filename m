From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/20] tipc: Optimize creation of FIN messages
Date: Fri, 24 Jun 2011 18:07:24 -0400
Message-ID: <1308953247-25266-18-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34417 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757560Ab1FXWHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:54 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Speeds up the creation of the FIN message that terminates a TIPC
connection. The typical peer termination message is now created by
duplicating the terminating port's standard payload message header
and adjusting the message size, importance, and error code fields,
rather than building all fields of the message from scratch. A FIN
message that is directed to the port itself is created the same way.
but also requires swapping the origin and destination address fields.

In addition to reducing the work required to create FIN messages,
these changes eliminate several instances of duplicated code,

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   61 +++++++++++++++++++++---------------------------------
 1 files changed, 24 insertions(+), 37 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 70e9de5..8be68e0 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -489,39 +489,38 @@ static void port_handle_node_down(unsigned long ref)
 
 static struct sk_buff *port_build_self_abort_msg(struct tipc_port *p_ptr, u32 err)
 {
-	u32 imp = msg_importance(&p_ptr->phdr);
+	struct sk_buff *buf = port_build_peer_abort_msg(p_ptr, err);
 
-	if (!p_ptr->connected)
-		return NULL;
-	if (imp < TIPC_CRITICAL_IMPORTANCE)
-		imp++;
-	return port_build_proto_msg(p_ptr->ref,
-				    tipc_own_addr,
-				    port_peerport(p_ptr),
-				    port_peernode(p_ptr),
-				    imp,
-				    TIPC_CONN_MSG,
-				    err,
-				    0);
+	if (buf) {
+		struct tipc_msg *msg = buf_msg(buf);
+		msg_swap_words(msg, 4, 5);
+		msg_swap_words(msg, 6, 7);
+	}
+	return buf;
 }
 
 
 static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 err)
 {
-	u32 imp = msg_importance(&p_ptr->phdr);
+	struct sk_buff *buf;
+	struct tipc_msg *msg;
+	u32 imp;
 
 	if (!p_ptr->connected)
 		return NULL;
-	if (imp < TIPC_CRITICAL_IMPORTANCE)
-		imp++;
-	return port_build_proto_msg(port_peerport(p_ptr),
-				    port_peernode(p_ptr),
-				    p_ptr->ref,
-				    tipc_own_addr,
-				    imp,
-				    TIPC_CONN_MSG,
-				    err,
-				    0);
+
+	buf = tipc_buf_acquire(BASIC_H_SIZE);
+	if (buf) {
+		msg = buf_msg(buf);
+		memcpy(msg, &p_ptr->phdr, BASIC_H_SIZE);
+		msg_set_hdr_sz(msg, BASIC_H_SIZE);
+		msg_set_size(msg, BASIC_H_SIZE);
+		imp = msg_importance(msg);
+		if (imp < TIPC_CRITICAL_IMPORTANCE)
+			msg_set_importance(msg, ++imp);
+		msg_set_errcode(msg, err);
+	}
+	return buf;
 }
 
 void tipc_port_recv_proto_msg(struct sk_buff *buf)
@@ -1149,19 +1148,7 @@ int tipc_shutdown(u32 ref)
 	if (!p_ptr)
 		return -EINVAL;
 
-	if (p_ptr->connected) {
-		u32 imp = msg_importance(&p_ptr->phdr);
-		if (imp < TIPC_CRITICAL_IMPORTANCE)
-			imp++;
-		buf = port_build_proto_msg(port_peerport(p_ptr),
-					   port_peernode(p_ptr),
-					   ref,
-					   tipc_own_addr,
-					   imp,
-					   TIPC_CONN_MSG,
-					   TIPC_CONN_SHUTDOWN,
-					   0);
-	}
+	buf = port_build_peer_abort_msg(p_ptr, TIPC_CONN_SHUTDOWN);
 	tipc_port_unlock(p_ptr);
 	tipc_net_route_msg(buf);
 	return tipc_disconnect(ref);
-- 
1.7.4.4

