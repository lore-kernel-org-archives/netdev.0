From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/16] tipc: make tipc broadcast
	link support net namespace
Date: Fri, 9 Jan 2015 15:27:07 +0800
Message-ID: <1420788433-17960-11-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC broadcast link is statically established and its relevant states
are maintained with the global variables: "bcbearer", "bclink" and
"bcl". Allowing different namespace to own different broadcast link
instances, these variables must be moved to tipc_net structure and
broadcast link instances would be allocated and initialized when
namespace is created.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.c       |    2 +-
 net/tipc/addr.h       |    3 +
 net/tipc/bcast.c      |  297 +++++++++++++++++++++++--------------------------
 net/tipc/bcast.h      |   97 +++++++++++-----
 net/tipc/bearer.c     |    7 +-
 net/tipc/bearer.h     |   21 +++-
 net/tipc/core.h       |   10 ++
 net/tipc/link.c       |   17 +--
 net/tipc/msg.h        |    2 +-
 net/tipc/name_table.c |    1 +
 net/tipc/net.c        |    1 +
 net/tipc/node.c       |    6 +-
 12 files changed, 259 insertions(+), 205 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 357b74b..9e6eeb4 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -34,7 +34,7 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include "core.h"
+#include <linux/kernel.h>
 #include "addr.h"
 
 /**
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 3e1f18e..4e364c4 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -37,6 +37,9 @@
 #ifndef _TIPC_ADDR_H
 #define _TIPC_ADDR_H
 
+#include <linux/types.h>
+#include <linux/tipc.h>
+
 #define TIPC_ZONE_MASK		0xff000000u
 #define TIPC_CLUSTER_MASK	0xfffff000u
 
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e7c5383..bc58097 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -35,77 +35,14 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#include "core.h"
-#include "link.h"
 #include "socket.h"
 #include "msg.h"
 #include "bcast.h"
 #include "name_distr.h"
+#include "core.h"
 
 #define	MAX_PKT_DEFAULT_MCAST	1500	/* bcast link max packet size (fixed) */
 #define	BCLINK_WIN_DEFAULT	20	/* bcast link window size (default) */
-#define	BCBEARER		MAX_BEARERS
-
-/**
- * struct tipc_bcbearer_pair - a pair of bearers used by broadcast link
- * @primary: pointer to primary bearer
- * @secondary: pointer to secondary bearer
- *
- * Bearers must have same priority and same set of reachable destinations
- * to be paired.
- */
-
-struct tipc_bcbearer_pair {
-	struct tipc_bearer *primary;
-	struct tipc_bearer *secondary;
-};
-
-/**
- * struct tipc_bcbearer - bearer used by broadcast link
- * @bearer: (non-standard) broadcast bearer structure
- * @media: (non-standard) broadcast media structure
- * @bpairs: array of bearer pairs
- * @bpairs_temp: temporary array of bearer pairs used by tipc_bcbearer_sort()
- * @remains: temporary node map used by tipc_bcbearer_send()
- * @remains_new: temporary node map used tipc_bcbearer_send()
- *
- * Note: The fields labelled "temporary" are incorporated into the bearer
- * to avoid consuming potentially limited stack space through the use of
- * large local variables within multicast routines.  Concurrent access is
- * prevented through use of the spinlock "bclink_lock".
- */
-struct tipc_bcbearer {
-	struct tipc_bearer bearer;
-	struct tipc_media media;
-	struct tipc_bcbearer_pair bpairs[MAX_BEARERS];
-	struct tipc_bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
-	struct tipc_node_map remains;
-	struct tipc_node_map remains_new;
-};
-
-/**
- * struct tipc_bclink - link used for broadcast messages
- * @lock: spinlock governing access to structure
- * @link: (non-standard) broadcast link structure
- * @node: (non-standard) node structure representing b'cast link's peer node
- * @flags: represent bclink states
- * @bcast_nodes: map of broadcast-capable nodes
- * @retransmit_to: node that most recently requested a retransmit
- *
- * Handles sequence numbering, fragmentation, bundling, etc.
- */
-struct tipc_bclink {
-	spinlock_t lock;
-	struct tipc_link link;
-	struct tipc_node node;
-	unsigned int flags;
-	struct tipc_node_map bcast_nodes;
-	struct tipc_node *retransmit_to;
-};
-
-static struct tipc_bcbearer *bcbearer;
-static struct tipc_bclink *bclink;
-static struct tipc_link *bcl;
 
 const char tipc_bclink_name[] = "broadcast-link";
 
@@ -115,25 +52,28 @@ static void tipc_nmap_diff(struct tipc_node_map *nm_a,
 static void tipc_nmap_add(struct tipc_node_map *nm_ptr, u32 node);
 static void tipc_nmap_remove(struct tipc_node_map *nm_ptr, u32 node);
 
-static void tipc_bclink_lock(void)
+static void tipc_bclink_lock(struct net *net)
 {
-	spin_lock_bh(&bclink->lock);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	spin_lock_bh(&tn->bclink->lock);
 }
 
-static void tipc_bclink_unlock(void)
+static void tipc_bclink_unlock(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node = NULL;
 
-	if (likely(!bclink->flags)) {
-		spin_unlock_bh(&bclink->lock);
+	if (likely(!tn->bclink->flags)) {
+		spin_unlock_bh(&tn->bclink->lock);
 		return;
 	}
 
-	if (bclink->flags & TIPC_BCLINK_RESET) {
-		bclink->flags &= ~TIPC_BCLINK_RESET;
-		node = tipc_bclink_retransmit_to();
+	if (tn->bclink->flags & TIPC_BCLINK_RESET) {
+		tn->bclink->flags &= ~TIPC_BCLINK_RESET;
+		node = tipc_bclink_retransmit_to(net);
 	}
-	spin_unlock_bh(&bclink->lock);
+	spin_unlock_bh(&tn->bclink->lock);
 
 	if (node)
 		tipc_link_reset_all(node);
@@ -144,9 +84,11 @@ uint  tipc_bclink_get_mtu(void)
 	return MAX_PKT_DEFAULT_MCAST;
 }
 
-void tipc_bclink_set_flags(unsigned int flags)
+void tipc_bclink_set_flags(struct net *net, unsigned int flags)
 {
-	bclink->flags |= flags;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	tn->bclink->flags |= flags;
 }
 
 static u32 bcbuf_acks(struct sk_buff *buf)
@@ -164,31 +106,40 @@ static void bcbuf_decr_acks(struct sk_buff *buf)
 	bcbuf_set_acks(buf, bcbuf_acks(buf) - 1);
 }
 
-void tipc_bclink_add_node(u32 addr)
+void tipc_bclink_add_node(struct net *net, u32 addr)
 {
-	tipc_bclink_lock();
-	tipc_nmap_add(&bclink->bcast_nodes, addr);
-	tipc_bclink_unlock();
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	tipc_bclink_lock(net);
+	tipc_nmap_add(&tn->bclink->bcast_nodes, addr);
+	tipc_bclink_unlock(net);
 }
 
-void tipc_bclink_remove_node(u32 addr)
+void tipc_bclink_remove_node(struct net *net, u32 addr)
 {
-	tipc_bclink_lock();
-	tipc_nmap_remove(&bclink->bcast_nodes, addr);
-	tipc_bclink_unlock();
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	tipc_bclink_lock(net);
+	tipc_nmap_remove(&tn->bclink->bcast_nodes, addr);
+	tipc_bclink_unlock(net);
 }
 
-static void bclink_set_last_sent(void)
+static void bclink_set_last_sent(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
+
 	if (bcl->next_out)
 		bcl->fsm_msg_cnt = mod(buf_seqno(bcl->next_out) - 1);
 	else
 		bcl->fsm_msg_cnt = mod(bcl->next_out_no - 1);
 }
 
-u32 tipc_bclink_get_last_sent(void)
+u32 tipc_bclink_get_last_sent(struct net *net)
 {
-	return bcl->fsm_msg_cnt;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	return tn->bcl->fsm_msg_cnt;
 }
 
 static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
@@ -203,9 +154,11 @@ static void bclink_update_last_sent(struct tipc_node *node, u32 seqno)
  *
  * Called with bclink_lock locked
  */
-struct tipc_node *tipc_bclink_retransmit_to(void)
+struct tipc_node *tipc_bclink_retransmit_to(struct net *net)
 {
-	return bclink->retransmit_to;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	return tn->bclink->retransmit_to;
 }
 
 /**
@@ -215,9 +168,10 @@ struct tipc_node *tipc_bclink_retransmit_to(void)
  *
  * Called with bclink_lock locked
  */
-static void bclink_retransmit_pkt(u32 after, u32 to)
+static void bclink_retransmit_pkt(struct tipc_net *tn, u32 after, u32 to)
 {
 	struct sk_buff *skb;
+	struct tipc_link *bcl = tn->bcl;
 
 	skb_queue_walk(&bcl->outqueue, skb) {
 		if (more(buf_seqno(skb), after)) {
@@ -234,9 +188,10 @@ static void bclink_retransmit_pkt(u32 after, u32 to)
  */
 void tipc_bclink_wakeup_users(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&bclink->link.waiting_sks)))
+	while ((skb = skb_dequeue(&tn->bclink->link.waiting_sks)))
 		tipc_sk_rcv(net, skb);
 }
 
@@ -252,10 +207,12 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	struct sk_buff *skb, *tmp;
 	struct sk_buff *next;
 	unsigned int released = 0;
+	struct net *net = n_ptr->net;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 	/* Bail out if tx queue is empty (no clean up is required) */
-	skb = skb_peek(&bcl->outqueue);
+	skb = skb_peek(&tn->bcl->outqueue);
 	if (!skb)
 		goto exit;
 
@@ -266,43 +223,43 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		 * acknowledge sent messages only (if other nodes still exist)
 		 * or both sent and unsent messages (otherwise)
 		 */
-		if (bclink->bcast_nodes.count)
-			acked = bcl->fsm_msg_cnt;
+		if (tn->bclink->bcast_nodes.count)
+			acked = tn->bcl->fsm_msg_cnt;
 		else
-			acked = bcl->next_out_no;
+			acked = tn->bcl->next_out_no;
 	} else {
 		/*
 		 * Bail out if specified sequence number does not correspond
 		 * to a message that has been sent and not yet acknowledged
 		 */
 		if (less(acked, buf_seqno(skb)) ||
-		    less(bcl->fsm_msg_cnt, acked) ||
+		    less(tn->bcl->fsm_msg_cnt, acked) ||
 		    less_eq(acked, n_ptr->bclink.acked))
 			goto exit;
 	}
 
 	/* Skip over packets that node has previously acknowledged */
-	skb_queue_walk(&bcl->outqueue, skb) {
+	skb_queue_walk(&tn->bcl->outqueue, skb) {
 		if (more(buf_seqno(skb), n_ptr->bclink.acked))
 			break;
 	}
 
 	/* Update packets that node is now acknowledging */
-	skb_queue_walk_from_safe(&bcl->outqueue, skb, tmp) {
+	skb_queue_walk_from_safe(&tn->bcl->outqueue, skb, tmp) {
 		if (more(buf_seqno(skb), acked))
 			break;
 
-		next = tipc_skb_queue_next(&bcl->outqueue, skb);
-		if (skb != bcl->next_out) {
+		next = tipc_skb_queue_next(&tn->bcl->outqueue, skb);
+		if (skb != tn->bcl->next_out) {
 			bcbuf_decr_acks(skb);
 		} else {
 			bcbuf_set_acks(skb, 0);
-			bcl->next_out = next;
-			bclink_set_last_sent();
+			tn->bcl->next_out = next;
+			bclink_set_last_sent(net);
 		}
 
 		if (bcbuf_acks(skb) == 0) {
-			__skb_unlink(skb, &bcl->outqueue);
+			__skb_unlink(skb, &tn->bcl->outqueue);
 			kfree_skb(skb);
 			released = 1;
 		}
@@ -310,15 +267,15 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	n_ptr->bclink.acked = acked;
 
 	/* Try resolving broadcast link congestion, if necessary */
-	if (unlikely(bcl->next_out)) {
-		tipc_link_push_packets(bcl);
-		bclink_set_last_sent();
+	if (unlikely(tn->bcl->next_out)) {
+		tipc_link_push_packets(tn->bcl);
+		bclink_set_last_sent(net);
 	}
-	if (unlikely(released && !skb_queue_empty(&bcl->waiting_sks)))
+	if (unlikely(released && !skb_queue_empty(&tn->bcl->waiting_sks)))
 		n_ptr->action_flags |= TIPC_WAKEUP_BCAST_USERS;
 
 exit:
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 }
 
 /**
@@ -368,10 +325,10 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 		msg_set_bcgap_after(msg, n_ptr->bclink.last_in);
 		msg_set_bcgap_to(msg, to);
 
-		tipc_bclink_lock();
+		tipc_bclink_lock(net);
 		tipc_bearer_send(net, MAX_BEARERS, buf, NULL);
-		bcl->stats.sent_nacks++;
-		tipc_bclink_unlock();
+		tn->bcl->stats.sent_nacks++;
+		tipc_bclink_unlock(net);
 		kfree_skb(buf);
 
 		n_ptr->bclink.oos_state++;
@@ -410,6 +367,9 @@ static void bclink_peek_nack(struct net *net, struct tipc_msg *msg)
  */
 int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
+	struct tipc_bclink *bclink = tn->bclink;
 	int rc = 0;
 	int bc = 0;
 	struct sk_buff *skb;
@@ -423,19 +383,19 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 
 	/* Broadcast to all other nodes */
 	if (likely(bclink)) {
-		tipc_bclink_lock();
+		tipc_bclink_lock(net);
 		if (likely(bclink->bcast_nodes.count)) {
 			rc = __tipc_link_xmit(net, bcl, list);
 			if (likely(!rc)) {
 				u32 len = skb_queue_len(&bcl->outqueue);
 
-				bclink_set_last_sent();
+				bclink_set_last_sent(net);
 				bcl->stats.queue_sz_counts++;
 				bcl->stats.accu_queue_sz += len;
 			}
 			bc = 1;
 		}
-		tipc_bclink_unlock();
+		tipc_bclink_unlock(net);
 	}
 
 	if (unlikely(!bc))
@@ -457,10 +417,12 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
  */
 static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 {
+	struct tipc_net *tn = net_generic(node->net, tipc_net_id);
+
 	bclink_update_last_sent(node, seqno);
 	node->bclink.last_in = seqno;
 	node->bclink.oos_state = 0;
-	bcl->stats.recv_info++;
+	tn->bcl->stats.recv_info++;
 
 	/*
 	 * Unicast an ACK periodically, ensuring that
@@ -469,7 +431,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 	if (((seqno - tipc_own_addr) % TIPC_MIN_LINK_WIN) == 0) {
 		tipc_link_proto_xmit(node->active_links[node->addr & 1],
 				     STATE_MSG, 0, 0, 0, 0, 0);
-		bcl->stats.sent_acks++;
+		tn->bcl->stats.sent_acks++;
 	}
 }
 
@@ -481,6 +443,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_node *node;
 	u32 next_in;
@@ -506,12 +469,12 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 		if (msg_destnode(msg) == tipc_own_addr) {
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bcl->stats.recv_nacks++;
-			bclink->retransmit_to = node;
-			bclink_retransmit_pkt(msg_bcgap_after(msg),
+			tn->bclink->retransmit_to = node;
+			bclink_retransmit_pkt(tn, msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 		} else {
 			tipc_node_unlock(node);
 			bclink_peek_nack(net, msg);
@@ -527,47 +490,47 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 receive:
 		/* Deliver message to destination */
 		if (likely(msg_isdata(msg))) {
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
 				tipc_sk_mcast_rcv(net, buf);
 			else
 				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 			tipc_link_bundle_rcv(net, buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
 			tipc_buf_append(&node->bclink.reasm_buf, &buf);
 			if (unlikely(!buf && !node->bclink.reasm_buf))
 				goto unlock;
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
 			if (buf) {
 				bcl->stats.recv_fragmented++;
 				msg = buf_msg(buf);
-				tipc_bclink_unlock();
+				tipc_bclink_unlock(net);
 				goto receive;
 			}
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 			tipc_named_rcv(net, buf);
 		} else {
-			tipc_bclink_lock();
+			tipc_bclink_lock(net);
 			bclink_accept_pkt(node, seqno);
-			tipc_bclink_unlock();
+			tipc_bclink_unlock(net);
 			tipc_node_unlock(node);
 			kfree_skb(buf);
 		}
@@ -605,14 +568,14 @@ receive:
 		buf = NULL;
 	}
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 
 	if (deferred)
 		bcl->stats.deferred_recv++;
 	else
 		bcl->stats.duplicates++;
 
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 
 unlock:
 	tipc_node_unlock(node);
@@ -623,7 +586,7 @@ exit:
 u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
 {
 	return (n_ptr->bclink.recv_permitted &&
-		(tipc_bclink_get_last_sent() != n_ptr->bclink.acked));
+		(tipc_bclink_get_last_sent(n_ptr->net) != n_ptr->bclink.acked));
 }
 
 
@@ -636,13 +599,15 @@ u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
  * Returns 0 (packet sent successfully) under all circumstances,
  * since the broadcast link's pseudo-bearer never blocks
  */
-static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
+static int tipc_bcbearer_send(struct net *net, struct sk_buff *buf,
+			      struct tipc_bearer *unused1,
 			      struct tipc_media_addr *unused2)
 {
 	int bp_index;
 	struct tipc_msg *msg = buf_msg(buf);
-	struct net *net = sock_net(buf->sk);
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_bcbearer *bcbearer = tn->bcbearer;
+	struct tipc_bclink *bclink = tn->bclink;
 
 	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
@@ -653,7 +618,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 		bcbuf_set_acks(buf, bclink->bcast_nodes.count);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tn->net_id);
-		bcl->stats.sent_info++;
+		tn->bcl->stats.sent_info++;
 
 		if (WARN_ON(!bclink->bcast_nodes.count)) {
 			dump_stack();
@@ -708,13 +673,14 @@ void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
 			u32 node, bool action)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_bcbearer *bcbearer = tn->bcbearer;
 	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
 	struct tipc_bcbearer_pair *bp_curr;
 	struct tipc_bearer *b;
 	int b_index;
 	int pri;
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 
 	if (action)
 		tipc_nmap_add(nm_ptr, node);
@@ -761,7 +727,7 @@ void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
 		bp_curr++;
 	}
 
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 }
 
 static int __tipc_nl_add_bc_link_stat(struct sk_buff *skb,
@@ -815,17 +781,19 @@ msg_full:
 	return -EMSGSIZE;
 }
 
-int tipc_nl_add_bc_link(struct tipc_nl_msg *msg)
+int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg)
 {
 	int err;
 	void *hdr;
 	struct nlattr *attrs;
 	struct nlattr *prop;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
 
 	if (!bcl)
 		return 0;
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
 			  NLM_F_MULTI, TIPC_NL_LINK_GET);
@@ -860,7 +828,7 @@ int tipc_nl_add_bc_link(struct tipc_nl_msg *msg)
 	if (err)
 		goto attr_msg_full;
 
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 	nla_nest_end(msg->skb, attrs);
 	genlmsg_end(msg->skb, hdr);
 
@@ -871,21 +839,23 @@ prop_msg_full:
 attr_msg_full:
 	nla_nest_cancel(msg->skb, attrs);
 msg_full:
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 	genlmsg_cancel(msg->skb, hdr);
 
 	return -EMSGSIZE;
 }
 
-int tipc_bclink_stats(char *buf, const u32 buf_size)
+int tipc_bclink_stats(struct net *net, char *buf, const u32 buf_size)
 {
 	int ret;
 	struct tipc_stats *s;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
 
 	if (!bcl)
 		return 0;
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 
 	s = &bcl->stats;
 
@@ -914,37 +884,46 @@ int tipc_bclink_stats(char *buf, const u32 buf_size)
 			     s->queue_sz_counts ?
 			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 	return ret;
 }
 
-int tipc_bclink_reset_stats(void)
+int tipc_bclink_reset_stats(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
+
 	if (!bcl)
 		return -ENOPROTOOPT;
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 	memset(&bcl->stats, 0, sizeof(bcl->stats));
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 	return 0;
 }
 
-int tipc_bclink_set_queue_limits(u32 limit)
+int tipc_bclink_set_queue_limits(struct net *net, u32 limit)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_link *bcl = tn->bcl;
+
 	if (!bcl)
 		return -ENOPROTOOPT;
 	if ((limit < TIPC_MIN_LINK_WIN) || (limit > TIPC_MAX_LINK_WIN))
 		return -EINVAL;
 
-	tipc_bclink_lock();
+	tipc_bclink_lock(net);
 	tipc_link_set_queue_limits(bcl, limit);
-	tipc_bclink_unlock();
+	tipc_bclink_unlock(net);
 	return 0;
 }
 
 int tipc_bclink_init(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_bcbearer *bcbearer;
+	struct tipc_bclink *bclink;
+	struct tipc_link *bcl;
 
 	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
 	if (!bcbearer)
@@ -969,12 +948,16 @@ int tipc_bclink_init(struct net *net)
 	spin_lock_init(&bclink->node.lock);
 	__skb_queue_head_init(&bclink->node.waiting_sks);
 	bcl->owner = &bclink->node;
+	bcl->owner->net = net;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->bearer_id = MAX_BEARERS;
 	rcu_assign_pointer(tn->bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
+	tn->bcbearer = bcbearer;
+	tn->bclink = bclink;
+	tn->bcl = bcl;
 	return 0;
 }
 
@@ -982,14 +965,14 @@ void tipc_bclink_stop(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	tipc_bclink_lock();
-	tipc_link_purge_queues(bcl);
-	tipc_bclink_unlock();
+	tipc_bclink_lock(net);
+	tipc_link_purge_queues(tn->bcl);
+	tipc_bclink_unlock(net);
 
 	RCU_INIT_POINTER(tn->bearer_list[BCBEARER], NULL);
 	synchronize_net();
-	kfree(bcbearer);
-	kfree(bclink);
+	kfree(tn->bcbearer);
+	kfree(tn->bclink);
 }
 
 /**
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 692efb6..a4583a1 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -37,23 +37,13 @@
 #ifndef _TIPC_BCAST_H
 #define _TIPC_BCAST_H
 
-#include "netlink.h"
+#include <linux/tipc_config.h>
+#include "link.h"
+#include "node.h"
 
-#define MAX_NODES 4096
-#define WSIZE 32
-#define TIPC_BCLINK_RESET 1
-
-/**
- * struct tipc_node_map - set of node identifiers
- * @count: # of nodes in set
- * @map: bitmap of node identifiers that are in the set
- */
-struct tipc_node_map {
-	u32 count;
-	u32 map[MAX_NODES / WSIZE];
-};
-
-#define PLSIZE 32
+#define TIPC_BCLINK_RESET	1
+#define PLSIZE			32
+#define	BCBEARER		MAX_BEARERS
 
 /**
  * struct tipc_port_list - set of node local destination ports
@@ -67,9 +57,64 @@ struct tipc_port_list {
 	u32 ports[PLSIZE];
 };
 
+/**
+ * struct tipc_bcbearer_pair - a pair of bearers used by broadcast link
+ * @primary: pointer to primary bearer
+ * @secondary: pointer to secondary bearer
+ *
+ * Bearers must have same priority and same set of reachable destinations
+ * to be paired.
+ */
 
-struct tipc_node;
+struct tipc_bcbearer_pair {
+	struct tipc_bearer *primary;
+	struct tipc_bearer *secondary;
+};
 
+/**
+ * struct tipc_bcbearer - bearer used by broadcast link
+ * @bearer: (non-standard) broadcast bearer structure
+ * @media: (non-standard) broadcast media structure
+ * @bpairs: array of bearer pairs
+ * @bpairs_temp: temporary array of bearer pairs used by tipc_bcbearer_sort()
+ * @remains: temporary node map used by tipc_bcbearer_send()
+ * @remains_new: temporary node map used tipc_bcbearer_send()
+ *
+ * Note: The fields labelled "temporary" are incorporated into the bearer
+ * to avoid consuming potentially limited stack space through the use of
+ * large local variables within multicast routines.  Concurrent access is
+ * prevented through use of the spinlock "bclink_lock".
+ */
+struct tipc_bcbearer {
+	struct tipc_bearer bearer;
+	struct tipc_media media;
+	struct tipc_bcbearer_pair bpairs[MAX_BEARERS];
+	struct tipc_bcbearer_pair bpairs_temp[TIPC_MAX_LINK_PRI + 1];
+	struct tipc_node_map remains;
+	struct tipc_node_map remains_new;
+};
+
+/**
+ * struct tipc_bclink - link used for broadcast messages
+ * @lock: spinlock governing access to structure
+ * @link: (non-standard) broadcast link structure
+ * @node: (non-standard) node structure representing b'cast link's peer node
+ * @flags: represent bclink states
+ * @bcast_nodes: map of broadcast-capable nodes
+ * @retransmit_to: node that most recently requested a retransmit
+ *
+ * Handles sequence numbering, fragmentation, bundling, etc.
+ */
+struct tipc_bclink {
+	spinlock_t lock;
+	struct tipc_link link;
+	struct tipc_node node;
+	unsigned int flags;
+	struct tipc_node_map bcast_nodes;
+	struct tipc_node *retransmit_to;
+};
+
+struct tipc_node;
 extern const char tipc_bclink_name[];
 
 /**
@@ -86,24 +131,24 @@ void tipc_port_list_free(struct tipc_port_list *pl_ptr);
 
 int tipc_bclink_init(struct net *net);
 void tipc_bclink_stop(struct net *net);
-void tipc_bclink_set_flags(unsigned int flags);
-void tipc_bclink_add_node(u32 addr);
-void tipc_bclink_remove_node(u32 addr);
-struct tipc_node *tipc_bclink_retransmit_to(void);
+void tipc_bclink_set_flags(struct net *tn, unsigned int flags);
+void tipc_bclink_add_node(struct net *net, u32 addr);
+void tipc_bclink_remove_node(struct net *net, u32 addr);
+struct tipc_node *tipc_bclink_retransmit_to(struct net *tn);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
 void tipc_bclink_rcv(struct net *net, struct sk_buff *buf);
-u32  tipc_bclink_get_last_sent(void);
+u32  tipc_bclink_get_last_sent(struct net *net);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
 void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 				   u32 last_sent);
-int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
-int  tipc_bclink_reset_stats(void);
-int  tipc_bclink_set_queue_limits(u32 limit);
+int  tipc_bclink_stats(struct net *net, char *stats_buf, const u32 buf_size);
+int  tipc_bclink_reset_stats(struct net *net);
+int  tipc_bclink_set_queue_limits(struct net *net, u32 limit);
 void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
 			u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
 int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list);
 void tipc_bclink_wakeup_users(struct net *net);
-int tipc_nl_add_bc_link(struct tipc_nl_msg *msg);
+int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg);
 
 #endif
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 2fe9dcb..9a0d6ed 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -40,6 +40,7 @@
 #include "bearer.h"
 #include "link.h"
 #include "discover.h"
+#include "bcast.h"
 
 #define MAX_ADDR_STR 60
 
@@ -482,8 +483,8 @@ void tipc_disable_l2_media(struct tipc_bearer *b)
  * @b_ptr: the bearer through which the packet is to be sent
  * @dest: peer destination address
  */
-int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
-		     struct tipc_media_addr *dest)
+int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
+		     struct tipc_bearer *b, struct tipc_media_addr *dest)
 {
 	struct sk_buff *clone;
 	struct net_device *dev;
@@ -528,7 +529,7 @@ void tipc_bearer_send(struct net *net, u32 bearer_id, struct sk_buff *buf,
 	rcu_read_lock();
 	b_ptr = rcu_dereference_rtnl(tn->bearer_list[bearer_id]);
 	if (likely(b_ptr))
-		b_ptr->media->send_msg(buf, b_ptr, dest);
+		b_ptr->media->send_msg(net, buf, b_ptr, dest);
 	rcu_read_unlock();
 }
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 01722d6..c035e3e 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -37,12 +37,13 @@
 #ifndef _TIPC_BEARER_H
 #define _TIPC_BEARER_H
 
-#include "bcast.h"
 #include "netlink.h"
 #include <net/genetlink.h>
 
 #define MAX_BEARERS	2
 #define MAX_MEDIA	2
+#define MAX_NODES	4096
+#define WSIZE		32
 
 /* Identifiers associated with TIPC message header media address info
  * - address info field is 32 bytes long
@@ -59,6 +60,16 @@
 #define TIPC_MEDIA_TYPE_IB	2
 
 /**
+ * struct tipc_node_map - set of node identifiers
+ * @count: # of nodes in set
+ * @map: bitmap of node identifiers that are in the set
+ */
+struct tipc_node_map {
+	u32 count;
+	u32 map[MAX_NODES / WSIZE];
+};
+
+/**
  * struct tipc_media_addr - destination address used by TIPC bearers
  * @value: address info (format defined by media)
  * @media_id: TIPC media type identifier
@@ -89,7 +100,7 @@ struct tipc_bearer;
  * @name: media name
  */
 struct tipc_media {
-	int (*send_msg)(struct sk_buff *buf,
+	int (*send_msg)(struct net *net, struct sk_buff *buf,
 			struct tipc_bearer *b_ptr,
 			struct tipc_media_addr *dest);
 	int (*enable_media)(struct net *net, struct tipc_bearer *b_ptr);
@@ -157,8 +168,6 @@ struct tipc_bearer_names {
 	char if_name[TIPC_MAX_IF_NAME];
 };
 
-struct tipc_link;
-
 /*
  * TIPC routines available to supported media types
  */
@@ -193,8 +202,8 @@ void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
 int tipc_enable_l2_media(struct net *net, struct tipc_bearer *b);
 void tipc_disable_l2_media(struct tipc_bearer *b);
-int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
-		     struct tipc_media_addr *dest);
+int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
+		     struct tipc_bearer *b, struct tipc_media_addr *dest);
 
 struct sk_buff *tipc_bearer_get_names(struct net *net);
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 75a332b..3f6f9e0 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -61,6 +61,11 @@
 
 #include "node.h"
 #include "bearer.h"
+#include "bcast.h"
+#include "netlink.h"
+#include "link.h"
+#include "node.h"
+#include "msg.h"
 
 #define TIPC_MOD_VER "2.0.0"
 
@@ -91,6 +96,11 @@ struct tipc_net {
 
 	/* Bearer list */
 	struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
+
+	/* Broadcast link */
+	struct tipc_bcbearer *bcbearer;
+	struct tipc_bclink *bclink;
+	struct tipc_link *bcl;
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/link.c b/net/tipc/link.c
index be21e6a..a84d5c6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -941,6 +941,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 				    struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
+	struct net *net = l_ptr->owner->net;
 
 	pr_warn("Retransmission failure on link <%s>\n", l_ptr->name);
 
@@ -958,7 +959,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 		pr_cont("Outstanding acks: %lu\n",
 			(unsigned long) TIPC_SKB_CB(buf)->handle);
 
-		n_ptr = tipc_bclink_retransmit_to();
+		n_ptr = tipc_bclink_retransmit_to(net);
 		tipc_node_lock(n_ptr);
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
@@ -973,7 +974,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 
 		tipc_node_unlock(n_ptr);
 
-		tipc_bclink_set_flags(TIPC_BCLINK_RESET);
+		tipc_bclink_set_flags(net, TIPC_BCLINK_RESET);
 		l_ptr->stale_count = 0;
 	}
 }
@@ -1404,7 +1405,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 	msg_set_type(msg, msg_typ);
 	msg_set_net_plane(msg, l_ptr->net_plane);
 	msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-	msg_set_last_bcast(msg, tipc_bclink_get_last_sent());
+	msg_set_last_bcast(msg, tipc_bclink_get_last_sent(l_ptr->owner->net));
 
 	if (msg_typ == STATE_MSG) {
 		u32 next_sent = mod(l_ptr->next_out_no);
@@ -2105,7 +2106,7 @@ struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
 
 	if (!strcmp(args->name, tipc_bclink_name)) {
 		if ((cmd == TIPC_CMD_SET_LINK_WINDOW) &&
-		    (tipc_bclink_set_queue_limits(new_value) == 0))
+		    (tipc_bclink_set_queue_limits(net, new_value) == 0))
 			return tipc_cfg_reply_none();
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change setting on broadcast link)");
@@ -2143,7 +2144,7 @@ struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
 
 	link_name = (char *)TLV_DATA(req_tlv_area);
 	if (!strcmp(link_name, tipc_bclink_name)) {
-		if (tipc_bclink_reset_stats())
+		if (tipc_bclink_reset_stats(net))
 			return tipc_cfg_reply_error_string("link not found");
 		return tipc_cfg_reply_none();
 	}
@@ -2191,7 +2192,7 @@ static int tipc_link_stats(struct net *net, const char *name, char *buf,
 	int ret;
 
 	if (!strcmp(name, tipc_bclink_name))
-		return tipc_bclink_stats(buf, buf_size);
+		return tipc_bclink_stats(net, buf, buf_size);
 
 	node = tipc_link_find_owner(net, name, &bearer_id);
 	if (!node)
@@ -2640,7 +2641,7 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			prev_node = node->addr;
 		}
 	} else {
-		err = tipc_nl_add_bc_link(&msg);
+		err = tipc_nl_add_bc_link(net, &msg);
 		if (err)
 			goto out;
 
@@ -2739,7 +2740,7 @@ int tipc_nl_link_reset_stats(struct sk_buff *skb, struct genl_info *info)
 	link_name = nla_data(attrs[TIPC_NLA_LINK_NAME]);
 
 	if (strcmp(link_name, tipc_bclink_name) == 0) {
-		err = tipc_bclink_reset_stats();
+		err = tipc_bclink_reset_stats(net);
 		if (err)
 			return err;
 		return 0;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 0065a2e..75f3242 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -37,7 +37,7 @@
 #ifndef _TIPC_MSG_H
 #define _TIPC_MSG_H
 
-#include "bearer.h"
+#include <linux/tipc.h>
 
 /*
  * Constants and routines used to read and write TIPC payload message headers
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index cf17790..beed5fd 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -39,6 +39,7 @@
 #include "name_table.h"
 #include "name_distr.h"
 #include "subscr.h"
+#include "bcast.h"
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 38633e5..7548ba8 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -41,6 +41,7 @@
 #include "socket.h"
 #include "node.h"
 #include "config.h"
+#include "bcast.h"
 
 static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
 	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
diff --git a/net/tipc/node.c b/net/tipc/node.c
index a0ca1ac..3db5012 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -368,8 +368,8 @@ static void node_established_contact(struct tipc_node *n_ptr)
 {
 	n_ptr->action_flags |= TIPC_NOTIFY_NODE_UP;
 	n_ptr->bclink.oos_state = 0;
-	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
-	tipc_bclink_add_node(n_ptr->addr);
+	n_ptr->bclink.acked = tipc_bclink_get_last_sent(n_ptr->net);
+	tipc_bclink_add_node(n_ptr->net, n_ptr->addr);
 }
 
 static void node_lost_contact(struct tipc_node *n_ptr)
@@ -389,7 +389,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 			n_ptr->bclink.reasm_buf = NULL;
 		}
 
-		tipc_bclink_remove_node(n_ptr->addr);
+		tipc_bclink_remove_node(n_ptr->net, n_ptr->addr);
 		tipc_bclink_acknowledge(n_ptr, INVALID_LINK_SEQ);
 
 		n_ptr->bclink.recv_permitted = false;
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
