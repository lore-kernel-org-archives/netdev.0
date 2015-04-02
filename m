From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: simplify link mtu
	negotiation
Date: Thu,  2 Apr 2015 09:33:02 -0400
Message-ID: <1427981582-30819-4-git-send-email-jon.maloy@ericsson.com>
References: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When a link is being established, the two endpoints advertise their
respective interface MTU in the transmitted RESET and ACTIVATE messages.
If there is any difference, the lower of the two MTUs will be selected
for use by both endpoints.

However, as a remnant of earlier attempts to introduce TIPC level
routing. there also exists an MTU discovery mechanism. If an intermediate
node has a lower MTU than the two endpoints, they will discover this
through a bisectional approach, and finally adopt this MTU for common use.

Since there is no TIPC level routing, and probably never will be,
this mechanism doesn't make any sense, and only serves to make the
link level protocol unecessarily complex.

In this commit, we eliminate the MTU discovery algorithm,and fall back
to the simple MTU advertising approach. This change is fully backwards
compatible.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |   4 +-
 net/tipc/link.c  | 129 ++++++++++++++-----------------------------------------
 net/tipc/link.h  |  12 +++---
 net/tipc/node.c  |   9 ++--
 4 files changed, 43 insertions(+), 111 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index ae558dd..c5cbdcb 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -413,7 +413,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 	 */
 	if (((seqno - tn->own_addr) % TIPC_MIN_LINK_WIN) == 0) {
 		tipc_link_proto_xmit(node->active_links[node->addr & 1],
-				     STATE_MSG, 0, 0, 0, 0, 0);
+				     STATE_MSG, 0, 0, 0, 0);
 		tn->bcl->stats.sent_acks++;
 	}
 }
@@ -899,7 +899,7 @@ int tipc_bclink_init(struct net *net)
 	skb_queue_head_init(&bclink->inputq);
 	bcl->owner = &bclink->node;
 	bcl->owner->net = net;
-	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
+	bcl->mtu = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->bearer_id = MAX_BEARERS;
 	rcu_assign_pointer(tn->bearer_list[MAX_BEARERS], &bcbearer->bearer);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b1e1795..a6b30df 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -136,34 +136,6 @@ static struct tipc_link *tipc_parallel_link(struct tipc_link *l)
 	return l->owner->active_links[1];
 }
 
-static void link_init_max_pkt(struct tipc_link *l_ptr)
-{
-	struct tipc_node *node = l_ptr->owner;
-	struct tipc_net *tn = net_generic(node->net, tipc_net_id);
-	struct tipc_bearer *b_ptr;
-	u32 max_pkt;
-
-	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(tn->bearer_list[l_ptr->bearer_id]);
-	if (!b_ptr) {
-		rcu_read_unlock();
-		return;
-	}
-	max_pkt = (b_ptr->mtu & ~3);
-	rcu_read_unlock();
-
-	if (max_pkt > MAX_MSG_SIZE)
-		max_pkt = MAX_MSG_SIZE;
-
-	l_ptr->max_pkt_target = max_pkt;
-	if (l_ptr->max_pkt_target < MAX_PKT_DEFAULT)
-		l_ptr->max_pkt = l_ptr->max_pkt_target;
-	else
-		l_ptr->max_pkt = MAX_PKT_DEFAULT;
-
-	l_ptr->max_pkt_probes = 0;
-}
-
 /*
  *  Simple non-static link routines (i.e. referenced outside this file)
  */
@@ -304,7 +276,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	msg_set_bearer_id(msg, b_ptr->identity);
 	strcpy((char *)msg_data(msg), if_name);
 	l_ptr->net_plane = b_ptr->net_plane;
-	link_init_max_pkt(l_ptr);
+	l_ptr->advertised_mtu = b_ptr->mtu;
+	l_ptr->mtu = l_ptr->advertised_mtu;
 	l_ptr->priority = b_ptr->priority;
 	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
 	l_ptr->next_out_no = 1;
@@ -465,8 +438,8 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	/* Link is down, accept any session */
 	l_ptr->peer_session = INVALID_SESSION;
 
-	/* Prepare for max packet size negotiation */
-	link_init_max_pkt(l_ptr);
+	/* Prepare for renewed mtu size negotiation */
+	l_ptr->mtu = l_ptr->advertised_mtu;
 
 	l_ptr->state = RESET_UNKNOWN;
 
@@ -563,11 +536,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->checkpoint = l_ptr->next_in_no;
 				if (tipc_bclink_acks_missing(l_ptr->owner)) {
 					tipc_link_proto_xmit(l_ptr, STATE_MSG,
-							     0, 0, 0, 0, 0);
-					l_ptr->fsm_msg_cnt++;
-				} else if (l_ptr->max_pkt < l_ptr->max_pkt_target) {
-					tipc_link_proto_xmit(l_ptr, STATE_MSG,
-							     1, 0, 0, 0, 0);
+							     0, 0, 0, 0);
 					l_ptr->fsm_msg_cnt++;
 				}
 				link_set_timer(l_ptr, cont_intv);
@@ -575,7 +544,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			}
 			l_ptr->state = WORKING_UNKNOWN;
 			l_ptr->fsm_msg_cnt = 0;
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv / 4);
 			break;
@@ -586,7 +555,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
 			tipc_link_proto_xmit(l_ptr, ACTIVATE_MSG,
-					     0, 0, 0, 0, 0);
+					     0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
 			break;
@@ -609,7 +578,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
 			tipc_link_proto_xmit(l_ptr, ACTIVATE_MSG,
-					     0, 0, 0, 0, 0);
+					     0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
 			break;
@@ -620,13 +589,13 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->checkpoint = l_ptr->next_in_no;
 				if (tipc_bclink_acks_missing(l_ptr->owner)) {
 					tipc_link_proto_xmit(l_ptr, STATE_MSG,
-							     0, 0, 0, 0, 0);
+							     0, 0, 0, 0);
 					l_ptr->fsm_msg_cnt++;
 				}
 				link_set_timer(l_ptr, cont_intv);
 			} else if (l_ptr->fsm_msg_cnt < l_ptr->abort_limit) {
 				tipc_link_proto_xmit(l_ptr, STATE_MSG,
-						     1, 0, 0, 0, 0);
+						     1, 0, 0, 0);
 				l_ptr->fsm_msg_cnt++;
 				link_set_timer(l_ptr, cont_intv / 4);
 			} else {	/* Link has failed */
@@ -636,7 +605,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->state = RESET_UNKNOWN;
 				l_ptr->fsm_msg_cnt = 0;
 				tipc_link_proto_xmit(l_ptr, RESET_MSG,
-						     0, 0, 0, 0, 0);
+						     0, 0, 0, 0);
 				l_ptr->fsm_msg_cnt++;
 				link_set_timer(l_ptr, cont_intv);
 			}
@@ -656,7 +625,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->state = WORKING_WORKING;
 			l_ptr->fsm_msg_cnt = 0;
 			link_activate(l_ptr);
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			if (l_ptr->owner->working_links == 1)
 				tipc_link_sync_xmit(l_ptr);
@@ -666,7 +635,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
 			tipc_link_proto_xmit(l_ptr, ACTIVATE_MSG,
-					     1, 0, 0, 0, 0);
+					     1, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
 			break;
@@ -676,7 +645,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case TIMEOUT_EVT:
-			tipc_link_proto_xmit(l_ptr, RESET_MSG, 0, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, RESET_MSG, 0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
 			break;
@@ -694,7 +663,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			l_ptr->state = WORKING_WORKING;
 			l_ptr->fsm_msg_cnt = 0;
 			link_activate(l_ptr);
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 1, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			if (l_ptr->owner->working_links == 1)
 				tipc_link_sync_xmit(l_ptr);
@@ -704,7 +673,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			break;
 		case TIMEOUT_EVT:
 			tipc_link_proto_xmit(l_ptr, ACTIVATE_MSG,
-					     0, 0, 0, 0, 0);
+					     0, 0, 0, 0);
 			l_ptr->fsm_msg_cnt++;
 			link_set_timer(l_ptr, cont_intv);
 			break;
@@ -733,7 +702,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 	struct tipc_msg *msg = buf_msg(skb_peek(list));
 	unsigned int maxwin = link->window;
 	unsigned int imp = msg_importance(msg);
-	uint mtu = link->max_pkt;
+	uint mtu = link->mtu;
 	uint ack = mod(link->next_in_no - 1);
 	uint seqno = link->next_out_no;
 	uint bc_last_in = link->owner->bclink.last_in;
@@ -1187,7 +1156,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			link_retrieve_defq(l_ptr, &head);
 		if (unlikely(++l_ptr->rcv_unacked >= TIPC_MIN_LINK_WIN)) {
 			l_ptr->stats.sent_acks++;
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0);
 		}
 		tipc_link_input(l_ptr, skb);
 		skb = NULL;
@@ -1362,7 +1331,7 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 	if (tipc_link_defer_pkt(&l_ptr->deferdq, buf)) {
 		l_ptr->stats.deferred_recv++;
 		if ((skb_queue_len(&l_ptr->deferdq) % TIPC_MIN_LINK_WIN) == 1)
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0);
 	} else {
 		l_ptr->stats.duplicates++;
 	}
@@ -1372,7 +1341,7 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
  * Send protocol message to the other endpoint.
  */
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
-			  u32 gap, u32 tolerance, u32 priority, u32 ack_mtu)
+			  u32 gap, u32 tolerance, u32 priority)
 {
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg = l_ptr->pmsg;
@@ -1410,26 +1379,11 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 			l_ptr->stats.sent_nacks++;
 		msg_set_link_tolerance(msg, tolerance);
 		msg_set_linkprio(msg, priority);
-		msg_set_max_pkt(msg, ack_mtu);
+		msg_set_max_pkt(msg, l_ptr->mtu);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_probe(msg, probe_msg != 0);
-		if (probe_msg) {
-			u32 mtu = l_ptr->max_pkt;
-
-			if ((mtu < l_ptr->max_pkt_target) &&
-			    link_working_working(l_ptr) &&
-			    l_ptr->fsm_msg_cnt) {
-				msg_size = (mtu + (l_ptr->max_pkt_target - mtu)/2 + 2) & ~3;
-				if (l_ptr->max_pkt_probes == 10) {
-					l_ptr->max_pkt_target = (msg_size - 4);
-					l_ptr->max_pkt_probes = 0;
-					msg_size = (mtu + (l_ptr->max_pkt_target - mtu)/2 + 2) & ~3;
-				}
-				l_ptr->max_pkt_probes++;
-			}
-
+		if (probe_msg)
 			l_ptr->stats.sent_probes++;
-		}
 		l_ptr->stats.sent_states++;
 	} else {		/* RESET_MSG or ACTIVATE_MSG */
 		msg_set_ack(msg, mod(l_ptr->failover_checkpt - 1));
@@ -1438,7 +1392,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 		msg_set_probe(msg, 0);
 		msg_set_link_tolerance(msg, l_ptr->tolerance);
 		msg_set_linkprio(msg, l_ptr->priority);
-		msg_set_max_pkt(msg, l_ptr->max_pkt_target);
+		msg_set_max_pkt(msg, l_ptr->advertised_mtu);
 	}
 
 	r_flag = (l_ptr->owner->working_links > tipc_link_is_up(l_ptr));
@@ -1469,8 +1423,6 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 				struct sk_buff *buf)
 {
 	u32 rec_gap = 0;
-	u32 max_pkt_info;
-	u32 max_pkt_ack;
 	u32 msg_tol;
 	struct tipc_msg *msg = buf_msg(buf);
 
@@ -1513,15 +1465,8 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 		if (msg_linkprio(msg) > l_ptr->priority)
 			l_ptr->priority = msg_linkprio(msg);
 
-		max_pkt_info = msg_max_pkt(msg);
-		if (max_pkt_info) {
-			if (max_pkt_info < l_ptr->max_pkt_target)
-				l_ptr->max_pkt_target = max_pkt_info;
-			if (l_ptr->max_pkt > l_ptr->max_pkt_target)
-				l_ptr->max_pkt = l_ptr->max_pkt_target;
-		} else {
-			l_ptr->max_pkt = l_ptr->max_pkt_target;
-		}
+		if (l_ptr->mtu > msg_max_pkt(msg))
+			l_ptr->mtu = msg_max_pkt(msg);
 
 		/* Synchronize broadcast link info, if not done previously */
 		if (!tipc_node_is_up(l_ptr->owner)) {
@@ -1566,18 +1511,8 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 				      mod(l_ptr->next_in_no));
 		}
 
-		max_pkt_ack = msg_max_pkt(msg);
-		if (max_pkt_ack > l_ptr->max_pkt) {
-			l_ptr->max_pkt = max_pkt_ack;
-			l_ptr->max_pkt_probes = 0;
-		}
-
-		max_pkt_ack = 0;
-		if (msg_probe(msg)) {
+		if (msg_probe(msg))
 			l_ptr->stats.recv_probes++;
-			if (msg_size(msg) > sizeof(l_ptr->proto_msg))
-				max_pkt_ack = msg_size(msg);
-		}
 
 		/* Protocol message before retransmits, reduce loss risk */
 		if (l_ptr->owner->bclink.recv_permitted)
@@ -1585,8 +1520,8 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 						      msg_last_bcast(msg));
 
 		if (rec_gap || (msg_probe(msg))) {
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, rec_gap, 0,
-					     0, max_pkt_ack);
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0,
+					     rec_gap, 0, 0);
 		}
 		if (msg_seq_gap(msg)) {
 			l_ptr->stats.recv_nacks++;
@@ -1816,7 +1751,7 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
 
 void tipc_link_set_queue_limits(struct tipc_link *l, u32 win)
 {
-	int max_bulk = TIPC_MAX_PUBLICATIONS / (l->max_pkt / ITEM_SIZE);
+	int max_bulk = TIPC_MAX_PUBLICATIONS / (l->mtu / ITEM_SIZE);
 
 	l->window = win;
 	l->backlog[TIPC_LOW_IMPORTANCE].limit      = win / 2;
@@ -1988,14 +1923,14 @@ int tipc_nl_link_set(struct sk_buff *skb, struct genl_info *info)
 
 			tol = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
 			link_set_supervision_props(link, tol);
-			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, tol, 0, 0);
+			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, tol, 0);
 		}
 		if (props[TIPC_NLA_PROP_PRIO]) {
 			u32 prio;
 
 			prio = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
 			link->priority = prio;
-			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, 0, prio, 0);
+			tipc_link_proto_xmit(link, STATE_MSG, 0, 0, 0, prio);
 		}
 		if (props[TIPC_NLA_PROP_WIN]) {
 			u32 win;
@@ -2100,7 +2035,7 @@ static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
 	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_DEST,
 			tipc_cluster_mask(tn->own_addr)))
 		goto attr_msg_full;
-	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_MTU, link->max_pkt))
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_MTU, link->mtu))
 		goto attr_msg_full;
 	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_RX, link->next_in_no))
 		goto attr_msg_full;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 6e28f03..b5b4e35 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -123,9 +123,8 @@ struct tipc_stats {
  * @backlog_limit: backlog queue congestion thresholds (indexed by importance)
  * @exp_msg_count: # of tunnelled messages expected during link changeover
  * @reset_checkpoint: seq # of last acknowledged message at time of link reset
- * @max_pkt: current maximum packet size for this link
- * @max_pkt_target: desired maximum packet size for this link
- * @max_pkt_probes: # of probes based on current (max_pkt, max_pkt_target)
+ * @mtu: current maximum packet size for this link
+ * @advertised_mtu: advertised own mtu when link is being established
  * @transmitq: queue for sent, non-acked messages
  * @backlogq: queue for messages waiting to be sent
  * @next_out_no: next sequence number to use for outbound messages
@@ -176,9 +175,8 @@ struct tipc_link {
 	struct sk_buff *failover_skb;
 
 	/* Max packet negotiation */
-	u32 max_pkt;
-	u32 max_pkt_target;
-	u32 max_pkt_probes;
+	u16 mtu;
+	u16 advertised_mtu;
 
 	/* Sending */
 	struct sk_buff_head transmq;
@@ -233,7 +231,7 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dest,
 int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		     struct sk_buff_head *list);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
-			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
+			  u32 gap, u32 tolerance, u32 priority);
 void tipc_link_push_packets(struct tipc_link *l_ptr);
 u32 tipc_link_defer_pkt(struct sk_buff_head *list, struct sk_buff *buf);
 void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index f3d522c..22c059a 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -254,8 +254,8 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	active[0] = active[1] = l_ptr;
 exit:
 	/* Leave room for changeover header when returning 'mtu' to users: */
-	n_ptr->act_mtus[0] = active[0]->max_pkt - INT_H_SIZE;
-	n_ptr->act_mtus[1] = active[1]->max_pkt - INT_H_SIZE;
+	n_ptr->act_mtus[0] = active[0]->mtu - INT_H_SIZE;
+	n_ptr->act_mtus[1] = active[1]->mtu - INT_H_SIZE;
 }
 
 /**
@@ -319,11 +319,10 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 	/* Leave room for changeover header when returning 'mtu' to users: */
 	if (active[0]) {
-		n_ptr->act_mtus[0] = active[0]->max_pkt - INT_H_SIZE;
-		n_ptr->act_mtus[1] = active[1]->max_pkt - INT_H_SIZE;
+		n_ptr->act_mtus[0] = active[0]->mtu - INT_H_SIZE;
+		n_ptr->act_mtus[1] = active[1]->mtu - INT_H_SIZE;
 		return;
 	}
-
 	/* Loopback link went down? No fragmentation needed from now on. */
 	if (n_ptr->addr == tn->own_addr) {
 		n_ptr->act_mtus[0] = MAX_MSG_SIZE;
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
