From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/3] tipc: introduce starvation free send algorithm
Date: Wed, 25 Mar 2015 12:07:24 -0400
Message-ID: <1427299646-31680-2-git-send-email-jon.maloy@ericsson.com>
References: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:23552 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752616AbbCYQHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 12:07:38 -0400
In-Reply-To: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we only use a single counter; the length of the backlog
queue, to determine whether a message should be accepted to the queue
or not. Each time a message is being sent, the queue length is compared
to a threshold value for the message's importance priority. If the queue
length is beyond this threshold, the message is rejected. This algorithm
implies a risk of starvation of low importance senders during very high
load, because it may take a long time before the backlog queue has
decreased enough to accept a lower level message.

We now eliminate this risk by introducing a counter for each importance
priority. When a message is sent, we check only the queue level for that
particular message's priority. If that is ok, the message can be added
to the backlog, irrespective of the queue level for other priorities.
This way, each level is guaranteed a certain portion of the total
bandwidth, and any risk of starvation is eliminated.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |  2 +-
 net/tipc/link.c  | 58 +++++++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h  |  7 +++++--
 3 files changed, 42 insertions(+), 25 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 5230739..7935553 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -831,7 +831,7 @@ int tipc_nl_add_bc_link(struct net *net, struct tipc_nl_msg *msg)
 	prop = nla_nest_start(msg->skb, TIPC_NLA_LINK_PROP);
 	if (!prop)
 		goto attr_msg_full;
-	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN, bcl->queue_limit[0]))
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN, bcl->window))
 		goto prop_msg_full;
 	nla_nest_end(msg->skb, prop);
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 8c98c4d..b9325a1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -310,7 +310,6 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	link_init_max_pkt(l_ptr);
 	l_ptr->priority = b_ptr->priority;
 	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
-
 	l_ptr->next_out_no = 1;
 	__skb_queue_head_init(&l_ptr->transmq);
 	__skb_queue_head_init(&l_ptr->backlogq);
@@ -398,19 +397,22 @@ static bool link_schedule_user(struct tipc_link *link, u32 oport,
  * Move a number of waiting users, as permitted by available space in
  * the send queue, from link wait queue to node wait queue for wakeup
  */
-void link_prepare_wakeup(struct tipc_link *link)
+void link_prepare_wakeup(struct tipc_link *l)
 {
-	uint pend_qsz = skb_queue_len(&link->backlogq);
+	int pnd[TIPC_SYSTEM_IMPORTANCE + 1] = {0,};
+	int imp, lim;
 	struct sk_buff *skb, *tmp;
 
-	skb_queue_walk_safe(&link->wakeupq, skb, tmp) {
-		if (pend_qsz >= link->queue_limit[TIPC_SKB_CB(skb)->chain_imp])
+	skb_queue_walk_safe(&l->wakeupq, skb, tmp) {
+		imp = TIPC_SKB_CB(skb)->chain_imp;
+		lim = l->window + l->backlog[imp].limit;
+		pnd[imp] += TIPC_SKB_CB(skb)->chain_sz;
+		if ((pnd[imp] + l->backlog[imp].len) >= lim)
 			break;
-		pend_qsz += TIPC_SKB_CB(skb)->chain_sz;
-		skb_unlink(skb, &link->wakeupq);
-		skb_queue_tail(&link->inputq, skb);
-		link->owner->inputq = &link->inputq;
-		link->owner->action_flags |= TIPC_MSG_EVT;
+		skb_unlink(skb, &l->wakeupq);
+		skb_queue_tail(&l->inputq, skb);
+		l->owner->inputq = &l->inputq;
+		l->owner->action_flags |= TIPC_MSG_EVT;
 	}
 }
 
@@ -424,6 +426,16 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 	l_ptr->reasm_buf = NULL;
 }
 
+static void tipc_link_purge_backlog(struct tipc_link *l)
+{
+	__skb_queue_purge(&l->backlogq);
+	l->backlog[TIPC_LOW_IMPORTANCE].len = 0;
+	l->backlog[TIPC_MEDIUM_IMPORTANCE].len = 0;
+	l->backlog[TIPC_HIGH_IMPORTANCE].len = 0;
+	l->backlog[TIPC_CRITICAL_IMPORTANCE].len = 0;
+	l->backlog[TIPC_SYSTEM_IMPORTANCE].len = 0;
+}
+
 /**
  * tipc_link_purge_queues - purge all pkt queues associated with link
  * @l_ptr: pointer to link
@@ -432,7 +444,7 @@ void tipc_link_purge_queues(struct tipc_link *l_ptr)
 {
 	__skb_queue_purge(&l_ptr->deferdq);
 	__skb_queue_purge(&l_ptr->transmq);
-	__skb_queue_purge(&l_ptr->backlogq);
+	tipc_link_purge_backlog(l_ptr);
 	tipc_link_reset_fragments(l_ptr);
 }
 
@@ -466,13 +478,13 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 
 	/* Clean up all queues, except inputq: */
 	__skb_queue_purge(&l_ptr->transmq);
-	__skb_queue_purge(&l_ptr->backlogq);
 	__skb_queue_purge(&l_ptr->deferdq);
 	if (!owner->inputq)
 		owner->inputq = &l_ptr->inputq;
 	skb_queue_splice_init(&l_ptr->wakeupq, owner->inputq);
 	if (!skb_queue_empty(owner->inputq))
 		owner->action_flags |= TIPC_MSG_EVT;
+	tipc_link_purge_backlog(l_ptr);
 	l_ptr->rcv_unacked = 0;
 	l_ptr->checkpoint = 1;
 	l_ptr->next_out_no = 1;
@@ -754,16 +766,14 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 	struct sk_buff_head *backlogq = &link->backlogq;
 	struct sk_buff *skb, *tmp;
 
-	/* Match queue limit against msg importance: */
-	if (unlikely(skb_queue_len(backlogq) >= link->queue_limit[imp]))
+	/* Match backlog limit against msg importance: */
+	if (unlikely(link->backlog[imp].len >= link->backlog[imp].limit))
 		return tipc_link_cong(link, list);
 
-	/* Has valid packet limit been used ? */
 	if (unlikely(msg_size(msg) > mtu)) {
 		__skb_queue_purge(list);
 		return -EMSGSIZE;
 	}
-
 	/* Prepare each packet for sending, and add to relevant queue: */
 	skb_queue_walk_safe(list, skb, tmp) {
 		__skb_unlink(skb, list);
@@ -786,8 +796,10 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		if (tipc_msg_make_bundle(&skb, mtu, link->addr)) {
 			link->stats.sent_bundled++;
 			link->stats.sent_bundles++;
+			imp = msg_importance(buf_msg(skb));
 		}
 		__skb_queue_tail(backlogq, skb);
+		link->backlog[imp].len++;
 		seqno++;
 	}
 	link->next_out_no = seqno;
@@ -914,6 +926,7 @@ void tipc_link_push_packets(struct tipc_link *link)
 		if (!skb)
 			break;
 		msg = buf_msg(skb);
+		link->backlog[msg_importance(msg)].len--;
 		msg_set_ack(msg, ack);
 		msg_set_bcast_ack(msg, link->owner->bclink.last_in);
 		link->rcv_unacked = 0;
@@ -1610,6 +1623,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
 		      ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	skb_queue_splice_tail_init(&l_ptr->backlogq, &l_ptr->transmq);
+	tipc_link_purge_backlog(l_ptr);
 	msgcount = skb_queue_len(&l_ptr->transmq);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
@@ -1817,11 +1831,11 @@ void tipc_link_set_queue_limits(struct tipc_link *l, u32 win)
 	int max_bulk = TIPC_MAX_PUBLICATIONS / (l->max_pkt / ITEM_SIZE);
 
 	l->window = win;
-	l->queue_limit[TIPC_LOW_IMPORTANCE]      = win / 2;
-	l->queue_limit[TIPC_MEDIUM_IMPORTANCE]   = win;
-	l->queue_limit[TIPC_HIGH_IMPORTANCE]     = win / 2 * 3;
-	l->queue_limit[TIPC_CRITICAL_IMPORTANCE] = win * 2;
-	l->queue_limit[TIPC_SYSTEM_IMPORTANCE]   = max_bulk;
+	l->backlog[TIPC_LOW_IMPORTANCE].limit      = win / 2;
+	l->backlog[TIPC_MEDIUM_IMPORTANCE].limit   = win;
+	l->backlog[TIPC_HIGH_IMPORTANCE].limit     = win / 2 * 3;
+	l->backlog[TIPC_CRITICAL_IMPORTANCE].limit = win * 2;
+	l->backlog[TIPC_SYSTEM_IMPORTANCE].limit   = max_bulk;
 }
 
 /* tipc_link_find_owner - locate owner node of link by link's name
@@ -2120,7 +2134,7 @@ static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
 	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_TOL, link->tolerance))
 		goto prop_msg_full;
 	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN,
-			link->queue_limit[TIPC_LOW_IMPORTANCE]))
+			link->window))
 		goto prop_msg_full;
 	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_PRIO, link->priority))
 		goto prop_msg_full;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index eec3ecf..99543a4 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -118,7 +118,7 @@ struct tipc_stats {
  * @pmsg: convenience pointer to "proto_msg" field
  * @priority: current link priority
  * @net_plane: current link network plane ('A' through 'H')
- * @queue_limit: outbound message queue congestion thresholds (indexed by user)
+ * @backlog_limit: backlog queue congestion thresholds (indexed by importance)
  * @exp_msg_count: # of tunnelled messages expected during link changeover
  * @reset_checkpoint: seq # of last acknowledged message at time of link reset
  * @max_pkt: current maximum packet size for this link
@@ -166,7 +166,6 @@ struct tipc_link {
 	struct tipc_msg *pmsg;
 	u32 priority;
 	char net_plane;
-	u32 queue_limit[15];	/* queue_limit[0]==window limit */
 
 	/* Changeover */
 	u32 exp_msg_count;
@@ -180,6 +179,10 @@ struct tipc_link {
 	/* Sending */
 	struct sk_buff_head transmq;
 	struct sk_buff_head backlogq;
+	struct {
+		u16 len;
+		u16 limit;
+	} backlog[5];
 	u32 next_out_no;
 	u32 window;
 	u32 last_retransmitted;
-- 
1.9.1
