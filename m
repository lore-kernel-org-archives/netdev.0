From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 17/18] tipc: guarantee delivery of last broadcast before DOWN event
Date: Thu, 12 Oct 2017 16:02:38 +0200
Message-ID: <1507816959-31787-18-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48659 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdJLOC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:58 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following scenario is possible:
- A user sends a broadcast message, and thereafter immediately leaves
  the group.
- The LEAVE message, following a different path than the broadcast,
  arrives ahead of the broadcast, and the sending member is removed
  from the receiver's list.
- The broadcast message arrives, but is dropped because the sender
  now is unknown to the receipient.

We fix this by sequence numbering membership events, just like ordinary
unicast messages. Currently, when a JOIN is sent to a peer, it contains
a synchronization point, - the sequence number of the next sent
broadcast, in order to give the receiver a start synchronization point.
We now let even LEAVE messages contain such an "end synchronization"
point, so that the recipient can delay the removal of the sending member
until it knows that all messages have been received.

The received synchronization points are added as sequence numbers to the
generated membership events, making it possible to handle them almost
the same way as regular unicasts in the receiving filter function. In
particular, a DOWN event with a too high sequence number will be kept
in the reordering queue until the missing broadcast(s) arrive and have
been delivered.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/group.c | 45 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/net/tipc/group.c b/net/tipc/group.c
index 1203929..0a405f2 100644
--- a/net/tipc/group.c
+++ b/net/tipc/group.c
@@ -71,6 +71,7 @@ struct tipc_member {
 	u16 advertised;
 	u16 window;
 	u16 bc_rcv_nxt;
+	u16 bc_syncpt;
 	u16 bc_acked;
 	bool usr_pending;
 };
@@ -413,7 +414,7 @@ static void tipc_group_sort_msg(struct sk_buff *skb, struct sk_buff_head *defq)
 	u16 bc_seqno = msg_grp_bc_seqno(hdr);
 	int mtyp = msg_type(hdr);
 
-	/* Bcast may be bypassed by unicast or other bcast, - sort it in */
+	/* Bcast/mcast may be bypassed by ucast or other bcast, - sort it in */
 	if (mtyp == TIPC_GRP_BCAST_MSG || mtyp == TIPC_GRP_MCAST_MSG) {
 		skb_queue_walk_safe(defq, _skb, tmp) {
 			_hdr = buf_msg(_skb);
@@ -437,7 +438,7 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 	struct sk_buff_head *defq;
 	struct tipc_member *m;
 	struct tipc_msg *hdr;
-	bool ack, deliver, update;
+	bool ack, deliver, update, leave = false;
 	u32 node, port;
 	int mtyp, blks;
 
@@ -451,13 +452,6 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 	if (!msg_in_group(hdr))
 		goto drop;
 
-	if (msg_is_grp_evt(hdr)) {
-		if (!grp->events)
-			goto drop;
-		__skb_queue_tail(inputq, skb);
-		return;
-	}
-
 	m = tipc_group_find_member(grp, node, port);
 	if (!tipc_group_is_receiver(m))
 		goto drop;
@@ -493,6 +487,12 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 			break;
 		case TIPC_GRP_UCAST_MSG:
 			break;
+		case TIPC_GRP_MEMBER_EVT:
+			if (m->state == MBR_LEAVING)
+				leave = true;
+			if (!grp->events)
+				deliver = false;
+			break;
 		default:
 			break;
 		}
@@ -507,6 +507,11 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 		if (ack)
 			tipc_group_proto_xmit(grp, m, GRP_ACK_MSG, xmitq);
 
+		if (leave) {
+			tipc_group_delete_member(grp, m);
+			__skb_queue_purge(defq);
+			break;
+		}
 		if (!update)
 			continue;
 
@@ -564,6 +569,8 @@ static void tipc_group_proto_xmit(struct tipc_group *grp, struct tipc_member *m,
 		msg_set_grp_bc_syncpt(hdr, grp->bc_snd_nxt);
 		msg_set_adv_win(hdr, adv);
 		m->advertised += adv;
+	} else if (mtyp == GRP_LEAVE_MSG) {
+		msg_set_grp_bc_syncpt(hdr, grp->bc_snd_nxt);
 	} else if (mtyp == GRP_ADV_MSG) {
 		msg_set_adv_win(hdr, adv);
 		m->advertised += adv;
@@ -578,6 +585,7 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 			  struct sk_buff_head *xmitq)
 {
 	struct tipc_member *m;
+	struct tipc_msg *ehdr;
 	u32 node = msg_orignode(hdr);
 	u32 port = msg_origport(hdr);
 
@@ -593,7 +601,8 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 						     MBR_QUARANTINED);
 		if (!m)
 			return;
-		m->bc_rcv_nxt = msg_grp_bc_syncpt(hdr);
+		m->bc_syncpt = msg_grp_bc_syncpt(hdr);
+		m->bc_rcv_nxt = m->bc_syncpt;
 		m->window += msg_adv_win(hdr);
 
 		/* Wait until PUBLISH event is received */
@@ -604,6 +613,8 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 			*usr_wakeup = true;
 			m->usr_pending = false;
 			tipc_group_proto_xmit(grp, m, GRP_ADV_MSG, xmitq);
+			ehdr = buf_msg(m->event_msg);
+			msg_set_grp_bc_seqno(ehdr, m->bc_syncpt);
 			__skb_queue_tail(inputq, m->event_msg);
 		}
 		if (m->window < ADV_IDLE)
@@ -614,6 +625,7 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 	case GRP_LEAVE_MSG:
 		if (!m)
 			return;
+		m->bc_syncpt = msg_grp_bc_syncpt(hdr);
 
 		/* Wait until WITHDRAW event is received */
 		if (m->state != MBR_LEAVING) {
@@ -621,9 +633,10 @@ void tipc_group_proto_rcv(struct tipc_group *grp, bool *usr_wakeup,
 			return;
 		}
 		/* Otherwise deliver already received WITHDRAW event */
+		ehdr = buf_msg(m->event_msg);
+		msg_set_grp_bc_seqno(ehdr, m->bc_syncpt);
 		__skb_queue_tail(inputq, m->event_msg);
 		*usr_wakeup = true;
-		tipc_group_delete_member(grp, m);
 		list_del_init(&m->congested);
 		return;
 	case GRP_ADV_MSG:
@@ -666,6 +679,7 @@ void tipc_group_member_evt(struct tipc_group *grp,
 	u32 port = evt->port.ref;
 	u32 node = evt->port.node;
 	u32 self;
+	bool node_up;
 
 	if (!grp)
 		goto drop;
@@ -698,6 +712,7 @@ void tipc_group_member_evt(struct tipc_group *grp,
 			m->event_msg = skb;
 			m->state = MBR_PUBLISHED;
 		} else {
+			msg_set_grp_bc_seqno(hdr, m->bc_syncpt);
 			__skb_queue_tail(inputq, skb);
 			m->state = MBR_JOINED;
 			*usr_wakeup = true;
@@ -718,14 +733,18 @@ void tipc_group_member_evt(struct tipc_group *grp,
 
 		*usr_wakeup = true;
 		m->usr_pending = false;
+		node_up = tipc_node_is_up(net, node);
 
 		/* Hold back event if more messages might be expected */
-		if (m->state != MBR_LEAVING && tipc_node_is_up(net, node)) {
+		if (m->state != MBR_LEAVING && node_up) {
 			m->event_msg = skb;
 			m->state = MBR_LEAVING;
 		} else {
+			if (node_up)
+				msg_set_grp_bc_seqno(hdr, m->bc_syncpt);
+			else
+				msg_set_grp_bc_seqno(hdr, m->bc_rcv_nxt);
 			__skb_queue_tail(inputq, skb);
-			tipc_group_delete_member(grp, m);
 		}
 		list_del_init(&m->congested);
 	}
-- 
2.1.4
