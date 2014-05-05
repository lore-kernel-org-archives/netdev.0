From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 07/10] tipc: define new functions to operate bc_lock
Date: Mon, 5 May 2014 08:56:15 +0800
Message-ID: <1399251378-23842-8-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40133 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbaEEA4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:49 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we are going to do more jobs when bc_lock is released, the two
operations of holding/releasing the lock should be encapsulated with
functions. In addition, we move bc_lock spin lock into tipc_bclink
structure avoiding to define the global variable.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |   96 ++++++++++++++++++++++++++++++------------------------
 1 file changed, 53 insertions(+), 43 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 119a59b..9eceaa7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -71,7 +71,7 @@ struct tipc_bcbearer_pair {
  * Note: The fields labelled "temporary" are incorporated into the bearer
  * to avoid consuming potentially limited stack space through the use of
  * large local variables within multicast routines.  Concurrent access is
- * prevented through use of the spinlock "bc_lock".
+ * prevented through use of the spinlock "bclink_lock".
  */
 struct tipc_bcbearer {
 	struct tipc_bearer bearer;
@@ -84,6 +84,7 @@ struct tipc_bcbearer {
 
 /**
  * struct tipc_bclink - link used for broadcast messages
+ * @lock: spinlock governing access to structure
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
  * @bcast_nodes: map of broadcast-capable nodes
@@ -92,6 +93,7 @@ struct tipc_bcbearer {
  * Handles sequence numbering, fragmentation, bundling, etc.
  */
 struct tipc_bclink {
+	spinlock_t lock;
 	struct tipc_link link;
 	struct tipc_node node;
 	struct tipc_node_map bcast_nodes;
@@ -105,8 +107,6 @@ static struct tipc_bcbearer *bcbearer = &bcast_bearer;
 static struct tipc_bclink *bclink = &bcast_link;
 static struct tipc_link *bcl = &bcast_link.link;
 
-static DEFINE_SPINLOCK(bc_lock);
-
 const char tipc_bclink_name[] = "broadcast-link";
 
 static void tipc_nmap_diff(struct tipc_node_map *nm_a,
@@ -115,6 +115,16 @@ static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 static void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
 static void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 
+static void tipc_bclink_lock(void)
+{
+	spin_lock_bh(&bclink->lock);
+}
+
+static void tipc_bclink_unlock(void)
+{
+	spin_unlock_bh(&bclink->lock);
+}
+
 static u32 bcbuf_acks(struct sk_buff *buf)
 {
 	return (u32)(unsigned long)TIPC_SKB_CB(buf)->handle;
@@ -132,16 +142,16 @@ static void bcbuf_decr_acks(struct sk_buff *buf)
 
 void tipc_bclink_add_node(u32 addr)
 {
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 	tipc_nmap_add(&bclink->bcast_nodes, addr);
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 }
 
 void tipc_bclink_remove_node(u32 addr)
 {
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 	tipc_nmap_remove(&bclink->bcast_nodes, addr);
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 }
 
 static void bclink_set_last_sent(void)
@@ -167,7 +177,7 @@ static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
 /**
  * tipc_bclink_retransmit_to - get most recent node to request retransmission
  *
- * Called with bc_lock locked
+ * Called with bclink_lock locked
  */
 struct tipc_node *tipc_bclink_retransmit_to(void)
 {
@@ -179,7 +189,7 @@ struct tipc_node *tipc_bclink_retransmit_to(void)
  * @after: sequence number of last packet to *not* retransmit
  * @to: sequence number of last packet to retransmit
  *
- * Called with bc_lock locked
+ * Called with bclink_lock locked
  */
 static void bclink_retransmit_pkt(u32 after, u32 to)
 {
@@ -196,7 +206,7 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  * @n_ptr: node that sent acknowledgement info
  * @acked: broadcast sequence # that has been acknowledged
  *
- * Node is locked, bc_lock unlocked.
+ * Node is locked, bclink_lock unlocked.
  */
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 {
@@ -204,8 +214,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	struct sk_buff *next;
 	unsigned int released = 0;
 
-	spin_lock_bh(&bc_lock);
-
+	tipc_bclink_lock();
 	/* Bail out if tx queue is empty (no clean up is required) */
 	crs = bcl->first_out;
 	if (!crs)
@@ -269,7 +278,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	if (unlikely(released && !list_empty(&bcl->waiting_ports)))
 		tipc_link_wakeup_ports(bcl, 0);
 exit:
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 }
 
 /**
@@ -322,10 +331,10 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 				 ? buf_seqno(n_ptr->bclink.deferred_head) - 1
 				 : n_ptr->bclink.last_sent);
 
-		spin_lock_bh(&bc_lock);
+		tipc_bclink_lock();
 		tipc_bearer_send(MAX_BEARERS, buf, NULL);
 		bcl->stats.sent_nacks++;
-		spin_unlock_bh(&bc_lock);
+		tipc_bclink_unlock();
 		kfree_skb(buf);
 
 		n_ptr->bclink.oos_state++;
@@ -362,7 +371,7 @@ int tipc_bclink_xmit(struct sk_buff *buf)
 {
 	int res;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 
 	if (!bclink->bcast_nodes.count) {
 		res = msg_data_sz(buf_msg(buf));
@@ -377,14 +386,14 @@ int tipc_bclink_xmit(struct sk_buff *buf)
 		bcl->stats.accu_queue_sz += bcl->out_queue_size;
 	}
 exit:
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 	return res;
 }
 
 /**
  * bclink_accept_pkt - accept an incoming, in-sequence broadcast packet
  *
- * Called with both sending node's lock and bc_lock taken.
+ * Called with both sending node's lock and bclink_lock taken.
  */
 static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 {
@@ -439,12 +448,12 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 		if (msg_destnode(msg) == tipc_own_addr) {
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bcl->stats.recv_nacks++;
 			bclink->retransmit_to = node;
 			bclink_retransmit_pkt(msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 		} else {
 			tipc_node_unlock(node);
 			bclink_peek_nack(msg);
@@ -462,20 +471,20 @@ receive:
 		/* Deliver message to destination */
 
 		if (likely(msg_isdata(msg))) {
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
 				tipc_port_mcast_rcv(buf, NULL);
 			else
 				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			tipc_link_bundle_rcv(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
@@ -485,28 +494,28 @@ receive:
 						 &buf);
 			if (ret == LINK_REASM_ERROR)
 				goto unlock;
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
 			if (ret == LINK_REASM_COMPLETE) {
 				bcl->stats.recv_fragmented++;
 				/* Point msg to inner header */
 				msg = buf_msg(buf);
-				spin_unlock_bh(&bc_lock);
+				tipc_bclink_unlock();
 				goto receive;
 			}
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			tipc_named_rcv(buf);
 		} else {
-			spin_lock_bh(&bc_lock);
+			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
-			spin_unlock_bh(&bc_lock);
+			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			kfree_skb(buf);
 		}
@@ -552,14 +561,14 @@ receive:
 	} else
 		deferred = 0;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 
 	if (deferred)
 		bcl->stats.deferred_recv++;
 	else
 		bcl->stats.duplicates++;
 
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 
 unlock:
 	tipc_node_unlock(node);
@@ -663,7 +672,7 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 	int b_index;
 	int pri;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 
 	if (action)
 		tipc_nmap_add(nm_ptr, node);
@@ -710,7 +719,7 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 		bp_curr++;
 	}
 
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 }
 
 
@@ -722,7 +731,7 @@ int tipc_bclink_stats(char *buf, const u32 buf_size)
 	if (!bcl)
 		return 0;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 
 	s = &bcl->stats;
 
@@ -751,7 +760,7 @@ int tipc_bclink_stats(char *buf, const u32 buf_size)
 			     s->queue_sz_counts ?
 			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 	return ret;
 }
 
@@ -760,9 +769,9 @@ int tipc_bclink_reset_stats(void)
 	if (!bcl)
 		return -ENOPROTOOPT;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 	memset(&bcl->stats, 0, sizeof(bcl->stats));
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 	return 0;
 }
 
@@ -773,9 +782,9 @@ int tipc_bclink_set_queue_limits(u32 limit)
 	if ((limit < TIPC_MIN_LINK_WIN) || (limit > TIPC_MAX_LINK_WIN))
 		return -EINVAL;
 
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 	tipc_link_set_queue_limits(bcl, limit);
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 	return 0;
 }
 
@@ -785,6 +794,7 @@ void tipc_bclink_init(void)
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
+	spin_lock_init(&bclink->lock);
 	INIT_LIST_HEAD(&bcl->waiting_ports);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
@@ -799,9 +809,9 @@ void tipc_bclink_init(void)
 
 void tipc_bclink_stop(void)
 {
-	spin_lock_bh(&bc_lock);
+	tipc_bclink_lock();
 	tipc_link_purge_queues(bcl);
-	spin_unlock_bh(&bc_lock);
+	tipc_bclink_unlock();
 
 	RCU_INIT_POINTER(bearer_list[BCBEARER], NULL);
 	memset(bclink, 0, sizeof(*bclink));
-- 
1.7.9.5
