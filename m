From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 15/18] tipc: guarantee that group broadcast doesn't bypass group unicast
Date: Thu, 12 Oct 2017 16:02:36 +0200
Message-ID: <1507816959-31787-16-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48659 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751717AbdJLOCy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:54 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need a mechanism guaranteeing that group unicasts sent out from a
socket are not bypassed by later sent broadcasts from the same socket.
We do this as follows:

- Each time a unicast is sent, we set a the broadcast method for the
  socket to "replicast" and "mandatory". This forces the first
  subsequent broadcast message to follow the same network and data path
  as the preceding unicast to a destination, hence preventing it from
  overtaking the latter.

- In order to make the 'same data path' statement above true, we let
  group unicasts pass through the multicast link input queue, instead
  of as previously through the unicast link input queue.

- In the first broadcast following a unicast, we set a new header flag,
  requiring all recipients to immediately acknowledge its reception.

- During the period before all the expected acknowledges are received,
  the socket refuses to accept any more broadcast attempts, i.e., by
  blocking or returning EAGAIN. This period should typically not be
  longer than a few microseconds.

- When all acknowledges have been received, the sending socket will
  open up for subsequent broadcasts, this time giving the link layer
  freedom to itself select the best transmission method.

- The forced and/or abrupt transmission method changes described above
  may lead to broadcasts arriving out of order to the recipients. We
  remedy this by introducing code that checks and if necessary
  re-orders such messages at the receiving end.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/group.c  | 47 +++++++++++++++++++++++++++++++++++++++++------
 net/tipc/group.h  |  4 +---
 net/tipc/link.c   |  5 ++---
 net/tipc/msg.h    | 21 +++++++++++++++++++++
 net/tipc/socket.c | 34 +++++++++++++++++++++++++++++-----
 5 files changed, 94 insertions(+), 17 deletions(-)

diff --git a/net/tipc/group.c b/net/tipc/group.c
index 5edceb6..1203929 100644
--- a/net/tipc/group.c
+++ b/net/tipc/group.c
@@ -71,6 +71,7 @@ struct tipc_member {
 	u16 advertised;
 	u16 window;
 	u16 bc_rcv_nxt;
+	u16 bc_acked;
 	bool usr_pending;
 };
 
@@ -87,6 +88,7 @@ struct tipc_group {
 	u32 portid;
 	u16 member_cnt;
 	u16 bc_snd_nxt;
+	u16 bc_ackers;
 	bool loopback;
 	bool events;
 };
@@ -258,6 +260,7 @@ static struct tipc_member *tipc_group_create_member(struct tipc_group *grp,
 	m->group = grp;
 	m->node = node;
 	m->port = port;
+	m->bc_acked = grp->bc_snd_nxt - 1;
 	grp->member_cnt++;
 	tipc_group_add_to_tree(grp, m);
 	tipc_nlist_add(&grp->dests, m->node);
@@ -275,6 +278,11 @@ static void tipc_group_delete_member(struct tipc_group *grp,
 {
 	rb_erase(&m->tree_node, &grp->members);
 	grp->member_cnt--;
+
+	/* Check if we were waiting for replicast ack from this member */
+	if (grp->bc_ackers && less(m->bc_acked, grp->bc_snd_nxt - 1))
+		grp->bc_ackers--;
+
 	list_del_init(&m->list);
 	list_del_init(&m->congested);
 
@@ -325,16 +333,23 @@ void tipc_group_update_member(struct tipc_member *m, int len)
 	list_add_tail(&m->congested, &grp->congested);
 }
 
-void tipc_group_update_bc_members(struct tipc_group *grp, int len)
+void tipc_group_update_bc_members(struct tipc_group *grp, int len, bool ack)
 {
 	struct tipc_member *m;
 	struct rb_node *n;
+	u16 prev = grp->bc_snd_nxt - 1;
 
 	for (n = rb_first(&grp->members); n; n = rb_next(n)) {
 		m = container_of(n, struct tipc_member, tree_node);
-		if (tipc_group_is_enabled(m))
+		if (tipc_group_is_enabled(m)) {
 			tipc_group_update_member(m, len);
+			m->bc_acked = prev;
+		}
 	}
+
+	/* Mark number of acknowledges to expect, if any */
+	if (ack)
+		grp->bc_ackers = grp->member_cnt;
 	grp->bc_snd_nxt++;
 }
 
@@ -375,6 +390,10 @@ bool tipc_group_bc_cong(struct tipc_group *grp, int len)
 {
 	struct tipc_member *m = NULL;
 
+	/* If prev bcast was replicast, reject until all receivers have acked */
+	if (grp->bc_ackers)
+		return true;
+
 	if (list_empty(&grp->congested))
 		return false;
 
@@ -394,7 +413,7 @@ static void tipc_group_sort_msg(struct sk_buff *skb, struct sk_buff_head *defq)
 	u16 bc_seqno = msg_grp_bc_seqno(hdr);
 	int mtyp = msg_type(hdr);
 
-	/* Bcast may be bypassed by unicast, - sort it in */
+	/* Bcast may be bypassed by unicast or other bcast, - sort it in */
 	if (mtyp == TIPC_GRP_BCAST_MSG || mtyp == TIPC_GRP_MCAST_MSG) {
 		skb_queue_walk_safe(defq, _skb, tmp) {
 			_hdr = buf_msg(_skb);
@@ -418,7 +437,7 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 	struct sk_buff_head *defq;
 	struct tipc_member *m;
 	struct tipc_msg *hdr;
-	bool deliver, update;
+	bool ack, deliver, update;
 	u32 node, port;
 	int mtyp, blks;
 
@@ -454,6 +473,7 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 		hdr = buf_msg(skb);
 		mtyp = msg_type(hdr);
 		deliver = true;
+		ack = false;
 		update = false;
 
 		if (more(msg_grp_bc_seqno(hdr), m->bc_rcv_nxt))
@@ -469,6 +489,7 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 			/* Fall thru */
 		case TIPC_GRP_BCAST_MSG:
 			m->bc_rcv_nxt++;
+			ack = msg_grp_bc_ack_req(hdr);
 			break;
 		case TIPC_GRP_UCAST_MSG:
 			break;
@@ -483,6 +504,9 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 		else
 			kfree_skb(skb);
 
+		if (ack)
+			tipc_group_proto_xmit(grp, m, GRP_ACK_MSG, xmitq);
+
 		if (!update)
 			continue;
 
@@ -543,6 +567,8 @@ static void tipc_group_proto_xmit(struct tipc_group *grp, struct tipc_member *m,
 	} else if (mtyp == GRP_ADV_MSG) {
 		msg_set_adv_win(hdr, adv);
 		m->advertised += adv;
+	} else if (mtyp == GRP_ACK_MSG) {
+		msg_set_grp_bc_acked(hdr, m->bc_rcv_nxt);
 	}
 	__skb_queue_tail(xmitq, skb);
 }
@@ -596,7 +622,7 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 		}
 		/* Otherwise deliver already received WITHDRAW event */
 		__skb_queue_tail(inputq, m->event_msg);
-		*usr_wakeup = m->usr_pending;
+		*usr_wakeup = true;
 		tipc_group_delete_member(grp, m);
 		list_del_init(&m->congested);
 		return;
@@ -608,6 +634,15 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 		m->usr_pending = false;
 		list_del_init(&m->congested);
 		return;
+	case GRP_ACK_MSG:
+		if (!m)
+			return;
+		m->bc_acked = msg_grp_bc_acked(hdr);
+		if (--grp->bc_ackers)
+			break;
+		*usr_wakeup = true;
+		m->usr_pending = false;
+		return;
 	default:
 		pr_warn("Received unknown GROUP_PROTO message\n");
 	}
@@ -681,7 +716,7 @@ void tipc_group_member_evt(struct tipc_group *grp,
 
 		TIPC_SKB_CB(skb)->orig_member = m->instance;
 
-		*usr_wakeup = m->usr_pending;
+		*usr_wakeup = true;
 		m->usr_pending = false;
 
 		/* Hold back event if more messages might be expected */
diff --git a/net/tipc/group.h b/net/tipc/group.h
index e432066..d525e1c 100644
--- a/net/tipc/group.h
+++ b/net/tipc/group.h
@@ -61,7 +61,7 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *wakeup,
 			  struct tipc_msg *hdr,
 			  struct sk_buff_head *inputq,
 			  struct sk_buff_head *xmitq);
-void tipc_group_update_bc_members(struct tipc_group *grp, int len);
+void tipc_group_update_bc_members(struct tipc_group *grp, int len, bool ack);
 bool tipc_group_cong(struct tipc_group *grp, u32 dnode, u32 dport,
 		     int len, struct tipc_member **m);
 bool tipc_group_bc_cong(struct tipc_group *grp, int len);
@@ -69,7 +69,5 @@ void tipc_group_update_rcv_win(struct tipc_group *grp, int blks, u32 node,
 			       u32 port, struct sk_buff_head *xmitq);
 u16 tipc_group_bc_snd_nxt(struct tipc_group *grp);
 void tipc_group_update_member(struct tipc_member *m, int len);
-struct tipc_member *tipc_group_find_sender(struct tipc_group *grp,
-					   u32 node, u32 port);
 int tipc_group_size(struct tipc_group *grp);
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index bd25bff..70a2149 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1046,13 +1046,12 @@ static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb,
 	case TIPC_MEDIUM_IMPORTANCE:
 	case TIPC_HIGH_IMPORTANCE:
 	case TIPC_CRITICAL_IMPORTANCE:
-		if (unlikely(msg_mcast(hdr))) {
+		if (unlikely(msg_in_group(hdr) || msg_mcast(hdr))) {
 			skb_queue_tail(l->bc_rcvlink->inputq, skb);
 			return true;
 		}
-	case CONN_MANAGER:
 	case GROUP_PROTOCOL:
-		skb_queue_tail(inputq, skb);
+	case CONN_MANAGER:
 		return true;
 	case NAME_DISTRIBUTOR:
 		l->bc_rcvlink->state = LINK_ESTABLISHED;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index b40a050..1c088a1 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -547,6 +547,7 @@ static inline void msg_set_nameupper(struct tipc_msg *m, u32 n)
 #define GRP_JOIN_MSG         0
 #define GRP_LEAVE_MSG        1
 #define GRP_ADV_MSG          2
+#define GRP_ACK_MSG          3
 
 /*
  * Word 1
@@ -839,6 +840,16 @@ static inline void msg_set_grp_bc_syncpt(struct tipc_msg *m, u16 n)
 	msg_set_bits(m, 9, 16, 0xffff, n);
 }
 
+static inline u16 msg_grp_bc_acked(struct tipc_msg *m)
+{
+	return msg_bits(m, 9, 16, 0xffff);
+}
+
+static inline void msg_set_grp_bc_acked(struct tipc_msg *m, u16 n)
+{
+	msg_set_bits(m, 9, 16, 0xffff, n);
+}
+
 /* Word 10
  */
 static inline u16 msg_grp_evt(struct tipc_msg *m)
@@ -851,6 +862,16 @@ static inline void msg_set_grp_evt(struct tipc_msg *m, int n)
 	msg_set_bits(m, 10, 0, 0x3, n);
 }
 
+static inline u16 msg_grp_bc_ack_req(struct tipc_msg *m)
+{
+	return msg_bits(m, 10, 0, 0x1);
+}
+
+static inline void msg_set_grp_bc_ack_req(struct tipc_msg *m, bool n)
+{
+	msg_set_bits(m, 10, 0, 0x1, n);
+}
+
 static inline u16 msg_grp_bc_seqno(struct tipc_msg *m)
 {
 	return msg_bits(m, 10, 16, 0xffff);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 015cdd9..379c5b9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -825,6 +825,7 @@ static int tipc_send_group_msg(struct net *net, struct tipc_sock *tsk,
 			       struct msghdr *m, struct tipc_member *mb,
 			       u32 dnode, u32 dport, int dlen)
 {
+	struct tipc_mc_method *method = &tsk->mc_method;
 	struct tipc_msg *hdr = &tsk->phdr;
 	struct sk_buff_head pkts;
 	u16 bc_snd_nxt = tipc_group_bc_snd_nxt(tsk->group);
@@ -852,9 +853,12 @@ static int tipc_send_group_msg(struct net *net, struct tipc_sock *tsk,
 		tsk->cong_link_cnt++;
 	}
 
-	/* Update send window and sequence number */
+	/* Update send window */
 	tipc_group_update_member(mb, blks);
 
+	/* A broadcast sent within next EXPIRE period must follow same path */
+	method->rcast = true;
+	method->mandatory = true;
 	return dlen;
 }
 
@@ -1005,6 +1009,7 @@ static int tipc_send_group_bcast(struct socket *sock, struct msghdr *m,
 	struct tipc_nlist *dsts = tipc_group_dests(grp);
 	struct tipc_mc_method *method = &tsk->mc_method;
 	struct sk_buff_head pkts;
+	bool ack = method->mandatory && method->rcast;
 	int blks = tsk_blocks(MCAST_H_SIZE + dlen);
 	int mtu = tipc_bcast_get_mtu(net);
 	int rc = -EHOSTUNREACH;
@@ -1031,6 +1036,9 @@ static int tipc_send_group_bcast(struct socket *sock, struct msghdr *m,
 	msg_set_destnode(hdr, 0);
 	msg_set_grp_bc_seqno(hdr, tipc_group_bc_snd_nxt(grp));
 
+	/* Avoid getting stuck with repeated forced replicasts */
+	msg_set_grp_bc_ack_req(hdr, ack);
+
 	/* Build message as chain of buffers */
 	skb_queue_head_init(&pkts);
 	rc = tipc_msg_build(hdr, m, 0, dlen, mtu, &pkts);
@@ -1038,13 +1046,17 @@ static int tipc_send_group_bcast(struct socket *sock, struct msghdr *m,
 		return rc;
 
 	/* Send message */
-	rc = tipc_mcast_xmit(net, &pkts, method, dsts,
-			     &tsk->cong_link_cnt);
+	rc = tipc_mcast_xmit(net, &pkts, method, dsts, &tsk->cong_link_cnt);
 	if (unlikely(rc))
 		return rc;
 
 	/* Update broadcast sequence number and send windows */
-	tipc_group_update_bc_members(tsk->group, blks);
+	tipc_group_update_bc_members(tsk->group, blks, ack);
+
+	/* Broadcast link is now free to choose method for next broadcast */
+	method->mandatory = false;
+	method->expires = jiffies;
+
 	return dlen;
 }
 
@@ -1106,9 +1118,9 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
 	u32 self = tipc_own_addr(net);
 	u32 scope = TIPC_CLUSTER_SCOPE;
 	struct sk_buff_head tmpq;
-	uint hsz;
 	struct sk_buff *skb, *_skb;
 	u32 lower = 0, upper = ~0;
+	int user, mtyp, hsz;
 
 	__skb_queue_head_init(&tmpq);
 	INIT_LIST_HEAD(&dports);
@@ -1116,6 +1128,18 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff_head *arrvq,
 	skb = tipc_skb_peek(arrvq, &inputq->lock);
 	for (; skb; skb = tipc_skb_peek(arrvq, &inputq->lock)) {
 		msg = buf_msg(skb);
+		user = msg_user(msg);
+		mtyp = msg_type(msg);
+		if (mtyp == TIPC_GRP_UCAST_MSG || user == GROUP_PROTOCOL) {
+			spin_lock_bh(&inputq->lock);
+			if (skb_peek(arrvq) == skb) {
+				__skb_dequeue(arrvq);
+				__skb_queue_tail(inputq, skb);
+			}
+			refcount_dec(&skb->users);
+			spin_unlock_bh(&inputq->lock);
+			continue;
+		}
 		hsz = skb_headroom(skb) + msg_hdr_sz(msg);
 		oport = msg_origport(msg);
 		onode = msg_orignode(msg);
-- 
2.1.4
