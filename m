From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 20/20] tipc: Optimize creation of connection protocol messages
Date: Fri, 24 Jun 2011 18:07:27 -0400
Message-ID: <1308953247-25266-21-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34429 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab1FXWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:57 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Simplifies the creation of connection protocol messages by eliminating
the passing of information that is no longer required, is constant,
or is contained within the port structure that is issuing the message.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   48 ++++++++++++------------------------------------
 1 files changed, 12 insertions(+), 36 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index ab0a8e9..54d812a 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -327,14 +327,12 @@ int tipc_set_portunreturnable(u32 ref, unsigned int isunrejectable)
 }
 
 /*
- * port_build_proto_msg(): build a port level protocol
- * or a connection abortion message. Called with
- * tipc_port lock on.
+ * port_build_proto_msg(): create connection protocol message for port
+ *
+ * On entry the port must be locked and connected.
  */
-static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
-					    u32 origport, u32 orignode,
-					    u32 usr, u32 type, u32 err,
-					    u32 ack)
+static struct sk_buff *port_build_proto_msg(struct tipc_port *p_ptr,
+					    u32 type, u32 ack)
 {
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
@@ -342,11 +340,10 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
-		tipc_msg_init(msg, usr, type, INT_H_SIZE, destnode);
-		msg_set_errcode(msg, err);
-		msg_set_destport(msg, destport);
-		msg_set_origport(msg, origport);
-		msg_set_orignode(msg, orignode);
+		tipc_msg_init(msg, CONN_MANAGER, type, INT_H_SIZE,
+			      port_peernode(p_ptr));
+		msg_set_destport(msg, port_peerport(p_ptr));
+		msg_set_origport(msg, p_ptr->ref);
 		msg_set_msgcnt(msg, ack);
 	}
 	return buf;
@@ -458,14 +455,7 @@ static void port_timeout(unsigned long ref)
 	if (p_ptr->probing_state == PROBING) {
 		buf = port_build_self_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
 	} else {
-		buf = port_build_proto_msg(port_peerport(p_ptr),
-					   port_peernode(p_ptr),
-					   p_ptr->ref,
-					   tipc_own_addr,
-					   CONN_MANAGER,
-					   CONN_PROBE,
-					   TIPC_OK,
-					   0);
+		buf = port_build_proto_msg(p_ptr, CONN_PROBE, 0);
 		p_ptr->probing_state = PROBING;
 		k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 	}
@@ -567,14 +557,7 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 		}
 		break;
 	case CONN_PROBE:
-		r_buf = port_build_proto_msg(origport,
-					     orignode,
-					     destport,
-					     tipc_own_addr,
-					     CONN_MANAGER,
-					     CONN_PROBE_REPLY,
-					     TIPC_OK,
-					     0);
+		r_buf = port_build_proto_msg(p_ptr, CONN_PROBE_REPLY, 0);
 		break;
 	default:
 		/* CONN_PROBE_REPLY or unrecognized - no action required */
@@ -899,14 +882,7 @@ void tipc_acknowledge(u32 ref, u32 ack)
 		return;
 	if (p_ptr->connected) {
 		p_ptr->conn_unacked -= ack;
-		buf = port_build_proto_msg(port_peerport(p_ptr),
-					   port_peernode(p_ptr),
-					   ref,
-					   tipc_own_addr,
-					   CONN_MANAGER,
-					   CONN_ACK,
-					   TIPC_OK,
-					   ack);
+		buf = port_build_proto_msg(p_ptr, CONN_ACK, ack);
 	}
 	tipc_port_unlock(p_ptr);
 	tipc_net_route_msg(buf);
-- 
1.7.4.4

