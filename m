From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/15] tipc: Prevent loss of fragmented messages over broadcast link
Date: Mon,  6 Feb 2012 19:52:46 -0500
Message-ID: <1328575968-20643-14-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50215 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532Ab2BGAxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:19 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies broadcast link so that an incoming fragmented message is not
lost if reassembly cannot begin because there currently is no buffer
big enough to hold the entire reassembled message. The broadcast link
now ignores the first fragment completely, which causes the sending node
to retransmit the first fragment so that reassembly can be re-attempted.

Previously, the sender would have had no reason to retransmit the 1st
fragment, so we would never have a chance to re-try the allocation.

To do this cleanly without duplicaton, a new bclink_accept_pkt()
function is introduced.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   64 +++++++++++++++++++++++++++++++++++------------------
 1 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a9b7132..41ecf31 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -389,7 +389,33 @@ exit:
 	return res;
 }
 
-/**
+/*
+ * bclink_accept_pkt - accept an incoming, in-sequence broadcast packet
+ *
+ * Called with both sending node's lock and bc_lock taken.
+ */
+
+static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
+{
+	bclink_update_last_sent(node, seqno);
+	node->bclink.last_in = seqno;
+	node->bclink.oos_state = 0;
+	bcl->stats.recv_info++;
+
+	/*
+	 * Unicast an ACK periodically, ensuring that
+	 * all nodes in the cluster don't ACK at the same time
+	 */
+
+	if (((seqno - tipc_own_addr) % TIPC_MIN_LINK_WIN) == 0) {
+		tipc_link_send_proto_msg(
+			node->active_links[node->addr & 1],
+			STATE_MSG, 0, 0, 0, 0, 0);
+		bcl->stats.sent_acks++;
+	}
+}
+
+/*
  * tipc_bclink_recv_pkt - receive a broadcast packet, and deliver upwards
  *
  * tipc_net_lock is read_locked, no other locks set
@@ -443,29 +469,12 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	next_in = mod(node->bclink.last_in + 1);
 
 	if (likely(seqno == next_in)) {
-		bclink_update_last_sent(node, seqno);
 receive:
-		node->bclink.last_in = seqno;
-		node->bclink.oos_state = 0;
-
-		spin_lock_bh(&bc_lock);
-		bcl->stats.recv_info++;
-
-		/*
-		 * Unicast an ACK periodically, ensuring that
-		 * all nodes in the cluster don't ACK at the same time
-		 */
-
-		if (((seqno - tipc_own_addr) % TIPC_MIN_LINK_WIN) == 0) {
-			tipc_link_send_proto_msg(
-				node->active_links[node->addr & 1],
-				STATE_MSG, 0, 0, 0, 0, 0);
-			bcl->stats.sent_acks++;
-		}
-
 		/* Deliver message to destination */
 
 		if (likely(msg_isdata(msg))) {
+			spin_lock_bh(&bc_lock);
+			bclink_accept_pkt(node, seqno);
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
@@ -473,24 +482,35 @@ receive:
 			else
 				buf_discard(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
+			spin_lock_bh(&bc_lock);
+			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_link_recv_bundle(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
+			int ret = tipc_link_recv_fragment(&node->bclink.defragm,
+						      &buf, &msg);
+			if (ret < 0)
+				goto unlock;
+			spin_lock_bh(&bc_lock);
+			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
-			if (tipc_link_recv_fragment(&node->bclink.defragm,
-						    &buf, &msg))
+			if (ret > 0)
 				bcl->stats.recv_fragmented++;
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_net_route_msg(buf);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
+			spin_lock_bh(&bc_lock);
+			bclink_accept_pkt(node, seqno);
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_named_recv(buf);
 		} else {
+			spin_lock_bh(&bc_lock);
+			bclink_accept_pkt(node, seqno);
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			buf_discard(buf);
-- 
1.7.9
