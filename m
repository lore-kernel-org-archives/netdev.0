From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 10/13] tipc: let port protocol senders use new link send function
Date: Wed, 25 Jun 2014 20:41:39 -0500
Message-ID: <1403746902-20408-11-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24179 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757329AbaFZBtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:05 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several functions in port.c, related to the port protocol and
connection shutdown, need to send messages. We now convert them
to use the new link send function.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.c |   30 +++++++++++++++++++++++-------
 1 file changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 606ff1a..60aede0 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -236,6 +236,8 @@ u32 tipc_port_init(struct tipc_port *p_ptr,
 void tipc_port_destroy(struct tipc_port *p_ptr)
 {
 	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg = NULL;
+	u32 peer;
 
 	tipc_withdraw(p_ptr, 0, NULL);
 
@@ -247,14 +249,15 @@ void tipc_port_destroy(struct tipc_port *p_ptr)
 	if (p_ptr->connected) {
 		buf = port_build_peer_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
 		tipc_nodesub_unsubscribe(&p_ptr->subscription);
+		msg = buf_msg(buf);
+		peer = msg_destnode(msg);
+		tipc_link_xmit2(buf, peer, msg_link_selector(msg));
 	}
-
 	spin_lock_bh(&tipc_port_list_lock);
 	list_del(&p_ptr->port_list);
 	list_del(&p_ptr->wait_list);
 	spin_unlock_bh(&tipc_port_list_lock);
 	k_term_timer(&p_ptr->timer);
-	tipc_net_route_msg(buf);
 }
 
 /*
@@ -276,6 +279,7 @@ static struct sk_buff *port_build_proto_msg(struct tipc_port *p_ptr,
 		msg_set_destport(msg, tipc_port_peerport(p_ptr));
 		msg_set_origport(msg, p_ptr->ref);
 		msg_set_msgcnt(msg, ack);
+		buf->next = NULL;
 	}
 	return buf;
 }
@@ -284,6 +288,7 @@ static void port_timeout(unsigned long ref)
 {
 	struct tipc_port *p_ptr = tipc_port_lock(ref);
 	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg = NULL;
 
 	if (!p_ptr)
 		return;
@@ -302,7 +307,8 @@ static void port_timeout(unsigned long ref)
 		k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 	}
 	tipc_port_unlock(p_ptr);
-	tipc_net_route_msg(buf);
+	msg = buf_msg(buf);
+	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 
@@ -310,12 +316,14 @@ static void port_handle_node_down(unsigned long ref)
 {
 	struct tipc_port *p_ptr = tipc_port_lock(ref);
 	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg = NULL;
 
 	if (!p_ptr)
 		return;
 	buf = port_build_self_abort_msg(p_ptr, TIPC_ERR_NO_NODE);
 	tipc_port_unlock(p_ptr);
-	tipc_net_route_msg(buf);
+	msg = buf_msg(buf);
+	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 
@@ -327,6 +335,7 @@ static struct sk_buff *port_build_self_abort_msg(struct tipc_port *p_ptr, u32 er
 		struct tipc_msg *msg = buf_msg(buf);
 		msg_swap_words(msg, 4, 5);
 		msg_swap_words(msg, 6, 7);
+		buf->next = NULL;
 	}
 	return buf;
 }
@@ -351,6 +360,7 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 er
 		if (imp < TIPC_CRITICAL_IMPORTANCE)
 			msg_set_importance(msg, ++imp);
 		msg_set_errcode(msg, err);
+		buf->next = NULL;
 	}
 	return buf;
 }
@@ -401,7 +411,7 @@ void tipc_port_proto_rcv(struct sk_buff *buf)
 	p_ptr->probing_state = CONFIRMED;
 	tipc_port_unlock(p_ptr);
 exit:
-	tipc_net_route_msg(r_buf);
+	tipc_link_xmit2(r_buf, msg_destnode(msg), msg_link_selector(msg));
 	kfree_skb(buf);
 }
 
@@ -496,6 +506,7 @@ void tipc_acknowledge(u32 ref, u32 ack)
 {
 	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
+	struct tipc_msg *msg;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
@@ -505,7 +516,10 @@ void tipc_acknowledge(u32 ref, u32 ack)
 		buf = port_build_proto_msg(p_ptr, CONN_ACK, ack);
 	}
 	tipc_port_unlock(p_ptr);
-	tipc_net_route_msg(buf);
+	if (!buf)
+		return;
+	msg = buf_msg(buf);
+	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
 int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
@@ -656,6 +670,7 @@ int tipc_port_disconnect(u32 ref)
  */
 int tipc_port_shutdown(u32 ref)
 {
+	struct tipc_msg *msg;
 	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
 
@@ -665,6 +680,7 @@ int tipc_port_shutdown(u32 ref)
 
 	buf = port_build_peer_abort_msg(p_ptr, TIPC_CONN_SHUTDOWN);
 	tipc_port_unlock(p_ptr);
-	tipc_net_route_msg(buf);
+	msg = buf_msg(buf);
+	tipc_link_xmit2(buf, msg_destnode(msg),	msg_link_selector(msg));
 	return tipc_port_disconnect(ref);
 }
-- 
1.7.9.5
