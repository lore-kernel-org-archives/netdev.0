From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/17] tipc: Un-inline port routine for processing incoming messages
Date: Wed, 29 Feb 2012 18:18:41 -0500
Message-ID: <1330557523-2024-16-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54001 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965423Ab2B2XTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:09 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Converts a non-trivial routine from inline to non-inline form
to avoid bloating the TIPC code base with 6 copies of its body.

This change is essentially cosmetic, and doesn't change existing
TIPC behavior.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 net/tipc/port.h |   42 +-----------------------------------------
 2 files changed, 44 insertions(+), 41 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index b103d76..6adcdf9 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1133,6 +1133,49 @@ int tipc_shutdown(u32 ref)
 	return tipc_disconnect(ref);
 }
 
+/**
+ * tipc_port_recv_msg - receive message from lower layer and deliver to port user
+ */
+
+int tipc_port_recv_msg(struct sk_buff *buf)
+{
+	struct tipc_port *p_ptr;
+	struct tipc_msg *msg = buf_msg(buf);
+	u32 destport = msg_destport(msg);
+	u32 dsz = msg_data_sz(msg);
+	u32 err;
+
+	/* forward unresolved named message */
+	if (unlikely(!destport)) {
+		tipc_net_route_msg(buf);
+		return dsz;
+	}
+
+	/* validate destination & pass to port, otherwise reject message */
+	p_ptr = tipc_port_lock(destport);
+	if (likely(p_ptr)) {
+		if (likely(p_ptr->connected)) {
+			if ((unlikely(msg_origport(msg) !=
+				      tipc_peer_port(p_ptr))) ||
+			    (unlikely(msg_orignode(msg) !=
+				      tipc_peer_node(p_ptr))) ||
+			    (unlikely(!msg_connected(msg)))) {
+				err = TIPC_ERR_NO_PORT;
+				tipc_port_unlock(p_ptr);
+				goto reject;
+			}
+		}
+		err = p_ptr->dispatcher(p_ptr, buf);
+		tipc_port_unlock(p_ptr);
+		if (likely(!err))
+			return dsz;
+	} else {
+		err = TIPC_ERR_NO_PORT;
+	}
+reject:
+	return tipc_reject_msg(buf, err);
+}
+
 /*
  *  tipc_port_recv_sections(): Concatenate and deliver sectioned
  *                        message for this node.
diff --git a/net/tipc/port.h b/net/tipc/port.h
index f751807..9b88531 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -205,6 +205,7 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr);
 /*
  * TIPC messaging routines
  */
+int tipc_port_recv_msg(struct sk_buff *buf);
 int tipc_send(u32 portref, unsigned int num_sect, struct iovec const *msg_sect,
 	      unsigned int total_len);
 
@@ -271,45 +272,4 @@ static inline int tipc_port_congested(struct tipc_port *p_ptr)
 	return (p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2);
 }
 
-/**
- * tipc_port_recv_msg - receive message from lower layer and deliver to port user
- */
-
-static inline int tipc_port_recv_msg(struct sk_buff *buf)
-{
-	struct tipc_port *p_ptr;
-	struct tipc_msg *msg = buf_msg(buf);
-	u32 destport = msg_destport(msg);
-	u32 dsz = msg_data_sz(msg);
-	u32 err;
-
-	/* forward unresolved named message */
-	if (unlikely(!destport)) {
-		tipc_net_route_msg(buf);
-		return dsz;
-	}
-
-	/* validate destination & pass to port, otherwise reject message */
-	p_ptr = tipc_port_lock(destport);
-	if (likely(p_ptr)) {
-		if (likely(p_ptr->connected)) {
-			if ((unlikely(msg_origport(msg) != tipc_peer_port(p_ptr))) ||
-			    (unlikely(msg_orignode(msg) != tipc_peer_node(p_ptr))) ||
-			    (unlikely(!msg_connected(msg)))) {
-				err = TIPC_ERR_NO_PORT;
-				tipc_port_unlock(p_ptr);
-				goto reject;
-			}
-		}
-		err = p_ptr->dispatcher(p_ptr, buf);
-		tipc_port_unlock(p_ptr);
-		if (likely(!err))
-			return dsz;
-	} else {
-		err = TIPC_ERR_NO_PORT;
-	}
-reject:
-	return tipc_reject_msg(buf, err);
-}
-
 #endif
-- 
1.7.9.1
