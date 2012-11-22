From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 6/9] tipc: rename supported flag to recv_permitted
Date: Thu, 22 Nov 2012 15:59:51 -0500
Message-ID: <1353617994-3962-7-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60006 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617Ab2KVVAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:17 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Rename the "supported" flag in bclink structure to "recv_permitted"
to better reflect what it is used for. When this flag is set for a
given node, we are permitted to receive and acknowledge broadcast
messages from that node.  Convert it to a bool at the same time,
since it is not used to store any numerical values.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c | 6 +++---
 net/tipc/link.c  | 8 ++++----
 net/tipc/node.c  | 6 +++---
 net/tipc/node.h  | 4 ++--
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 40da098..54f89f9 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -347,7 +347,7 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 
 	tipc_node_lock(n_ptr);
 
-	if (n_ptr->bclink.supported &&
+	if (n_ptr->bclink.recv_permitted &&
 	    (n_ptr->bclink.last_in != n_ptr->bclink.last_sent) &&
 	    (n_ptr->bclink.last_in == msg_bcgap_after(msg)))
 		n_ptr->bclink.oos_state = 2;
@@ -429,7 +429,7 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 		goto exit;
 
 	tipc_node_lock(node);
-	if (unlikely(!node->bclink.supported))
+	if (unlikely(!node->bclink.recv_permitted))
 		goto unlock;
 
 	/* Handle broadcast protocol message */
@@ -564,7 +564,7 @@ exit:
 
 u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
 {
-	return (n_ptr->bclink.supported &&
+	return (n_ptr->bclink.recv_permitted &&
 		(tipc_bclink_get_last_sent() != n_ptr->bclink.acked));
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index f3a078f..20f128f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1426,8 +1426,8 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
 		pr_info("Broadcast link info for %s\n", addr_string);
-		pr_info("Supported: %d,  Acked: %u\n",
-			n_ptr->bclink.supported,
+		pr_info("Reception permitted: %d,  Acked: %u\n",
+			n_ptr->bclink.recv_permitted,
 			n_ptr->bclink.acked);
 		pr_info("Last in: %u,  Oos state: %u,  Last sent: %u\n",
 			n_ptr->bclink.last_in,
@@ -1640,7 +1640,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		ackd = msg_ack(msg);
 
 		/* Release acked messages */
-		if (n_ptr->bclink.supported)
+		if (n_ptr->bclink.recv_permitted)
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		crs = l_ptr->first_out;
@@ -2067,7 +2067,7 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 
 		/* Protocol message before retransmits, reduce loss risk */
-		if (l_ptr->owner->bclink.supported)
+		if (l_ptr->owner->bclink.recv_permitted)
 			tipc_bclink_update_link_state(l_ptr->owner,
 						      msg_last_bcast(msg));
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6f3e9b3..283a59f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -266,7 +266,7 @@ static void node_established_contact(struct tipc_node *n_ptr)
 
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 	tipc_bclink_add_node(n_ptr->addr);
-	n_ptr->bclink.supported = 1;
+	n_ptr->bclink.recv_permitted = true;
 }
 
 static void node_name_purge_complete(unsigned long node_addr)
@@ -292,7 +292,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
-	if (n_ptr->bclink.supported) {
+	if (n_ptr->bclink.recv_permitted) {
 		while (n_ptr->bclink.deferred_head) {
 			struct sk_buff *buf = n_ptr->bclink.deferred_head;
 			n_ptr->bclink.deferred_head = buf->next;
@@ -308,7 +308,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		tipc_bclink_remove_node(n_ptr->addr);
 		tipc_bclink_acknowledge(n_ptr, INVALID_LINK_SEQ);
 
-		n_ptr->bclink.supported = 0;
+		n_ptr->bclink.recv_permitted = false;
 	}
 
 	/* Abort link changeover */
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 3ac905f..3c189b3 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -67,7 +67,6 @@
  * @permit_changeover: non-zero if node has redundant links to this system
  * @signature: node instance identifier
  * @bclink: broadcast-related info
- *    @supported: non-zero if node supports TIPC b'cast capability
  *    @acked: sequence # of last outbound b'cast message acknowledged by node
  *    @last_in: sequence # of last in-sequence b'cast message received from node
  *    @last_sent: sequence # of last b'cast message sent by node
@@ -76,6 +75,7 @@
  *    @deferred_head: oldest OOS b'cast message received from node
  *    @deferred_tail: newest OOS b'cast message received from node
  *    @defragm: list of partially reassembled b'cast message fragments from node
+ *    @recv_permitted: true if node is allowed to receive b'cast messages
  */
 struct tipc_node {
 	u32 addr;
@@ -91,7 +91,6 @@ struct tipc_node {
 	int permit_changeover;
 	u32 signature;
 	struct {
-		u8 supported;
 		u32 acked;
 		u32 last_in;
 		u32 last_sent;
@@ -100,6 +99,7 @@ struct tipc_node {
 		struct sk_buff *deferred_head;
 		struct sk_buff *deferred_tail;
 		struct sk_buff *defragm;
+		bool recv_permitted;
 	} bclink;
 };
 
-- 
1.7.12.1
