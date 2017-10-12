From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 14/18] tipc: guarantee group unicast doesn't bypass group broadcast
Date: Thu, 12 Oct 2017 16:02:35 +0200
Message-ID: <1507816959-31787-15-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:46423 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752295AbdJLOC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:58 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Group unicast messages don't follow the same path as broadcast messages,
and there is a high risk that unicasts sent from a socket might bypass
previously sent broadcasts from the same socket.

We fix this by letting all unicast messages carry the sequence number of
the next sent broadcast from the same node, but without updating this
number at the receiver. This way, a receiver can check and if necessary
re-order such messages before they are added to the socket receive buffer.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/group.c  | 87 +++++++++++++++++++++++++++++++++++++++++++++----------
 net/tipc/socket.c |  2 ++
 2 files changed, 74 insertions(+), 15 deletions(-)

diff --git a/net/tipc/group.c b/net/tipc/group.c
index 2fa49cc7..5edceb6 100644
--- a/net/tipc/group.c
+++ b/net/tipc/group.c
@@ -62,6 +62,7 @@ struct tipc_member {
 	struct list_head list;
 	struct list_head congested;
 	struct sk_buff *event_msg;
+	struct sk_buff_head deferredq;
 	struct tipc_group *group;
 	u32 node;
 	u32 port;
@@ -253,6 +254,7 @@ static struct tipc_member *tipc_group_create_member(struct tipc_group *grp,
 		return NULL;
 	INIT_LIST_HEAD(&m->list);
 	INIT_LIST_HEAD(&m->congested);
+	__skb_queue_head_init(&m->deferredq);
 	m->group = grp;
 	m->node = node;
 	m->port = port;
@@ -383,29 +385,54 @@ bool tipc_group_bc_cong(struct tipc_group *grp, int len)
 	return tipc_group_cong(grp, m->node, m->port, len, &m);
 }
 
+/* tipc_group_sort_msg() - sort msg into queue by bcast sequence number
+ */
+static void tipc_group_sort_msg(struct sk_buff *skb, struct sk_buff_head *defq)
+{
+	struct sk_buff *_skb, *tmp;
+	struct tipc_msg *_hdr, *hdr = buf_msg(skb);
+	u16 bc_seqno = msg_grp_bc_seqno(hdr);
+	int mtyp = msg_type(hdr);
+
+	/* Bcast may be bypassed by unicast, - sort it in */
+	if (mtyp == TIPC_GRP_BCAST_MSG || mtyp == TIPC_GRP_MCAST_MSG) {
+		skb_queue_walk_safe(defq, _skb, tmp) {
+			_hdr = buf_msg(_skb);
+			if (!less(bc_seqno, msg_grp_bc_seqno(_hdr)))
+				continue;
+			__skb_queue_before(defq, _skb, skb);
+			return;
+		}
+		/* Bcast was not bypassed, - add to tail */
+	}
+	/* Unicasts are never bypassed, - always add to tail */
+	__skb_queue_tail(defq, skb);
+}
+
 /* tipc_group_filter_msg() - determine if we should accept arriving message
  */
 void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 			   struct sk_buff_head *xmitq)
 {
 	struct sk_buff *skb = __skb_dequeue(inputq);
+	struct sk_buff_head *defq;
 	struct tipc_member *m;
 	struct tipc_msg *hdr;
+	bool deliver, update;
 	u32 node, port;
-	int mtyp;
+	int mtyp, blks;
 
 	if (!skb)
 		return;
 
 	hdr = buf_msg(skb);
-	mtyp = msg_type(hdr);
 	node =  msg_orignode(hdr);
 	port = msg_origport(hdr);
 
 	if (!msg_in_group(hdr))
 		goto drop;
 
-	if (mtyp == TIPC_GRP_MEMBER_EVT) {
+	if (msg_is_grp_evt(hdr)) {
 		if (!grp->events)
 			goto drop;
 		__skb_queue_tail(inputq, skb);
@@ -416,22 +443,52 @@ void tipc_group_filter_msg(struct tipc_group *grp, struct sk_buff_head *inputq,
 	if (!tipc_group_is_receiver(m))
 		goto drop;
 
-	m->bc_rcv_nxt = msg_grp_bc_seqno(hdr) + 1;
+	if (less(msg_grp_bc_seqno(hdr), m->bc_rcv_nxt))
+		goto drop;
 
-	/* Drop multicast here if not for this member */
-	if (mtyp == TIPC_GRP_MCAST_MSG) {
-		if (msg_nameinst(hdr) != grp->instance) {
-			m->bc_rcv_nxt = msg_grp_bc_seqno(hdr) + 1;
-			tipc_group_update_rcv_win(grp, msg_blocks(hdr),
-						  node, port, xmitq);
-			kfree_skb(skb);
-			return;
+	TIPC_SKB_CB(skb)->orig_member = m->instance;
+	defq = &m->deferredq;
+	tipc_group_sort_msg(skb, defq);
+
+	while ((skb = skb_peek(defq))) {
+		hdr = buf_msg(skb);
+		mtyp = msg_type(hdr);
+		deliver = true;
+		update = false;
+
+		if (more(msg_grp_bc_seqno(hdr), m->bc_rcv_nxt))
+			break;
+
+		/* Decide what to do with message */
+		switch (mtyp) {
+		case TIPC_GRP_MCAST_MSG:
+			if (msg_nameinst(hdr) != grp->instance) {
+				update = true;
+				deliver = false;
+			}
+			/* Fall thru */
+		case TIPC_GRP_BCAST_MSG:
+			m->bc_rcv_nxt++;
+			break;
+		case TIPC_GRP_UCAST_MSG:
+			break;
+		default:
+			break;
 		}
-	}
 
-	TIPC_SKB_CB(skb)->orig_member = m->instance;
-	__skb_queue_tail(inputq, skb);
+		/* Execute decisions */
+		__skb_dequeue(defq);
+		if (deliver)
+			__skb_queue_tail(inputq, skb);
+		else
+			kfree_skb(skb);
+
+		if (!update)
+			continue;
 
+		blks = msg_blocks(hdr);
+		tipc_group_update_rcv_win(grp, blks, node, port, xmitq);
+	}
 	return;
 drop:
 	kfree_skb(skb);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ad41f64..015cdd9 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -827,6 +827,7 @@ static int tipc_send_group_msg(struct net *net, struct tipc_sock *tsk,
 {
 	struct tipc_msg *hdr = &tsk->phdr;
 	struct sk_buff_head pkts;
+	u16 bc_snd_nxt = tipc_group_bc_snd_nxt(tsk->group);
 	int blks = tsk_blocks(GROUP_H_SIZE + dlen);
 	int mtu, rc;
 
@@ -835,6 +836,7 @@ static int tipc_send_group_msg(struct net *net, struct tipc_sock *tsk,
 	msg_set_hdr_sz(hdr, GROUP_H_SIZE);
 	msg_set_destport(hdr, dport);
 	msg_set_destnode(hdr, dnode);
+	msg_set_grp_bc_seqno(hdr, bc_snd_nxt);
 
 	/* Build message as chain of buffers */
 	skb_queue_head_init(&pkts);
-- 
2.1.4
