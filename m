From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 7/9] tipc: introduce message to synchronize broadcast link
Date: Thu, 22 Nov 2012 15:59:52 -0500
Message-ID: <1353617994-3962-8-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43267 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932624Ab2KVVAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:17 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>

Upon establishing a first link between two nodes, there is
currently a risk that the two endpoints will disagree on exactly
which sequence number reception and acknowleding of broadcast
packets should start.

The following scenarios may happen:

1: Node A sends an ACTIVATE message to B, telling it to start acking
   packets from sequence number N.
2: Node A sends out broadcast N, but does not expect an acknowledge
   from B, since B is not yet in its broadcast receiver's list.
3: Node A receives ACK for N from all nodes except B, and releases
   packet N.
4: Node B receives the ACTIVATE, activates its link endpoint, and
   stores the value N as sequence number of first expected packet.
5: Node B sends a NAME_DISTR message to A.
6: Node A receives the NAME_DISTR message, and activates its endpoint.
   At this moment B is added to A's broadcast receiver's set.
   Node A also sets sequence number 0 as the first broadcast packet
   to be received from B.
7: Node A sends broadcast N+1.
8: B receives N+1, determines there is a gap in the sequence, since
   it is expecting N, and sends a NACK for N back to A.
9: Node A has already released N, so no retransmission is possible.
   The broadcast link in direction A->B is stale.

In addition to, or instead of, 7-9 above, the following may happen:

10: Node B sends broadcast M > 0 to A.
11: Node A receives M, falsely decides there must be a gap, since
    it is expecting packet 0, and asks for retransmission of packets
    [0,M-1].
12: Node B has already released these packets, so the broadcast
    link is stale in direction B->A.

We solve this problem by introducing a new unicast message type,
BCAST_PROTOCOL/STATE, to convey the sequence number of the next
sent broadcast packet to the other endpoint, at exactly the moment
that endpoint is added to the own node's broadcast receivers list,
and before any other unicast messages are permitted to be sent.

Furthermore, we don't allow any node to start receiving and
processing broadcast packets until this new synchronization
message has been received.

To maintain backwards compatibility, we still open up for
broadcast reception if we receive a NAME_DISTR message without
any preceding broadcast sync message. In this case, we must
assume that the other end has an older code version, and will
never send out the new synchronization message. Hence, for mixed
old and new nodes, the issue arising in 7-12 of the above may
happen with the same probability as before.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 net/tipc/node.c |  5 ++---
 2 files changed, 60 insertions(+), 6 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 20f128f..87bf5aa 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/link.c: TIPC link code
  *
- * Copyright (c) 1996-2007, Ericsson AB
+ * Copyright (c) 1996-2007, 2012, Ericsson AB
  * Copyright (c) 2004-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -103,6 +103,8 @@ static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
 static void link_start(struct tipc_link *l_ptr);
 static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
+static void tipc_link_send_sync(struct tipc_link *l);
+static void tipc_link_recv_sync(struct tipc_node *n, struct sk_buff *buf);
 
 /*
  *  Simple link routines
@@ -712,6 +714,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_activate(l_ptr);
 			tipc_link_send_proto_msg(l_ptr, STATE_MSG, 1, 0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
+			if (l_ptr->owner->working_links == 1)
+				tipc_link_send_sync(l_ptr);
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
@@ -745,6 +749,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_activate(l_ptr);
 			tipc_link_send_proto_msg(l_ptr, STATE_MSG, 1, 0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
+			if (l_ptr->owner->working_links == 1)
+				tipc_link_send_sync(l_ptr);
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
@@ -941,7 +947,48 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 	return res;
 }
 
-/**
+/*
+ * tipc_link_send_sync - synchronize broadcast link endpoints.
+ *
+ * Give a newly added peer node the sequence number where it should
+ * start receiving and acking broadcast packets.
+ *
+ * Called with node locked
+ */
+static void tipc_link_send_sync(struct tipc_link *l)
+{
+	struct sk_buff *buf;
+	struct tipc_msg *msg;
+
+	buf = tipc_buf_acquire(INT_H_SIZE);
+	if (!buf)
+		return;
+
+	msg = buf_msg(buf);
+	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, l->addr);
+	msg_set_last_bcast(msg, l->owner->bclink.acked);
+	link_add_chain_to_outqueue(l, buf, 0);
+	tipc_link_push_queue(l);
+}
+
+/*
+ * tipc_link_recv_sync - synchronize broadcast link endpoints.
+ * Receive the sequence number where we should start receiving and
+ * acking broadcast packets from a newly added peer node, and open
+ * up for reception of such packets.
+ *
+ * Called with node locked
+ */
+static void tipc_link_recv_sync(struct tipc_node *n, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+
+	n->bclink.last_sent = n->bclink.last_in = msg_last_bcast(msg);
+	n->bclink.recv_permitted = true;
+	kfree_skb(buf);
+}
+
+/*
  * tipc_link_send_names - send name table entries to new neighbor
  *
  * Send routine for bulk delivery of name table messages when contact
@@ -1691,9 +1738,14 @@ deliver:
 					tipc_link_recv_bundle(buf);
 					continue;
 				case NAME_DISTRIBUTOR:
+					n_ptr->bclink.recv_permitted = true;
 					tipc_node_unlock(n_ptr);
 					tipc_named_recv(buf);
 					continue;
+				case BCAST_PROTOCOL:
+					tipc_link_recv_sync(n_ptr, buf);
+					tipc_node_unlock(n_ptr);
+					continue;
 				case CONN_MANAGER:
 					tipc_node_unlock(n_ptr);
 					tipc_port_recv_proto_msg(buf);
@@ -1736,16 +1788,19 @@ deliver:
 			continue;
 		}
 
+		/* Link is not in state WORKING_WORKING */
 		if (msg_user(msg) == LINK_PROTOCOL) {
 			link_recv_proto_msg(l_ptr, buf);
 			head = link_insert_deferred_queue(l_ptr, head);
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
+
+		/* Traffic message. Conditionally activate link */
 		link_state_event(l_ptr, TRAFFIC_MSG_EVT);
 
 		if (link_working_working(l_ptr)) {
-			/* Re-insert in front of queue */
+			/* Re-insert buffer in front of queue */
 			buf->next = head;
 			head = buf;
 			tipc_node_unlock(n_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 283a59f..48f39dd 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/node.c: TIPC node management routines
  *
- * Copyright (c) 2000-2006, Ericsson AB
+ * Copyright (c) 2000-2006, 2012 Ericsson AB
  * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -263,10 +263,9 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 static void node_established_contact(struct tipc_node *n_ptr)
 {
 	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
-
+	n_ptr->bclink.oos_state = 0;
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 	tipc_bclink_add_node(n_ptr->addr);
-	n_ptr->bclink.recv_permitted = true;
 }
 
 static void node_name_purge_complete(unsigned long node_addr)
-- 
1.7.12.1
