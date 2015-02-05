From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/9] tipc: reduce usage of context info in socket and link
Date: Thu,  5 Feb 2015 08:36:36 -0500
Message-ID: <1423143404-23322-2-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.bf1.yahoo.com ([98.139.221.62]:46164 "EHLO
	smtp103.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbbBENhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:37:22 -0500
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The most common usage of namespace information is when we fetch the
own node addess from the net structure. This leads to a lot of
passing around of a parameter of type 'struct net *' between
functions just to make them able to obtain this address.

However, in many cases this is unnecessary. The own node address
is readily available as a member of both struct tipc_sock and
tipc_link, and can be fetched from there instead.
The fact that the vast majority of functions in socket.c and link.c
anyway are maintaining a pointer to their respective base structures
makes this option even more compelling.

In this commit, we introduce the inline functions tsk_own_node()
and link_own_node() to make it easy for functions to fetch the node
address from those structs instead of having to pass along and
dereference the namespace struct.

In particular, we make calls to the msg_xx() functions in msg.{h,c}
context independent by directly passing them the own node address
as parameter when needed. Those functions should be regarded as
leaves in the code dependency tree, and it is hence desirable to
keep them namspace unaware.

Apart from a potential positive effect on cache behavior, these
changes make it easier to introduce the changes that will follow
later in this series.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c      |  7 ++++--
 net/tipc/bcast.h      |  2 +-
 net/tipc/discover.c   |  3 ++-
 net/tipc/link.c       | 56 ++++++++++++++++++++----------------------
 net/tipc/link.h       |  4 +++
 net/tipc/msg.c        | 33 ++++++++++++-------------
 net/tipc/msg.h        | 10 ++++----
 net/tipc/name_distr.c |  5 ++--
 net/tipc/node.c       |  2 +-
 net/tipc/socket.c     | 67 +++++++++++++++++++++++++++------------------------
 10 files changed, 98 insertions(+), 91 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 53f8bf0..3b886eb 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -283,10 +283,11 @@ exit:
  *
  * RCU and node lock set
  */
-void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
+void tipc_bclink_update_link_state(struct tipc_node *n_ptr,
 				   u32 last_sent)
 {
 	struct sk_buff *buf;
+	struct net *net = n_ptr->net;
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	/* Ignore "stale" link state info */
@@ -317,7 +318,7 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 		struct sk_buff *skb = skb_peek(&n_ptr->bclink.deferred_queue);
 		u32 to = skb ? buf_seqno(skb) - 1 : n_ptr->bclink.last_sent;
 
-		tipc_msg_init(net, msg, BCAST_PROTOCOL, STATE_MSG,
+		tipc_msg_init(tn->own_addr, msg, BCAST_PROTOCOL, STATE_MSG,
 			      INT_H_SIZE, n_ptr->addr);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tn->net_id);
@@ -954,6 +955,8 @@ int tipc_bclink_init(struct net *net)
 	bcl->bearer_id = MAX_BEARERS;
 	rcu_assign_pointer(tn->bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
+	bcl->pmsg = (struct tipc_msg *)&bcl->proto_msg;
+	msg_set_prevnode(bcl->pmsg, tn->own_addr);
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tn->bcbearer = bcbearer;
 	tn->bclink = bclink;
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index a4583a1..6ea190d 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -139,7 +139,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
 void tipc_bclink_rcv(struct net *net, struct sk_buff *buf);
 u32  tipc_bclink_get_last_sent(struct net *net);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
-void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
+void tipc_bclink_update_link_state(struct tipc_node *node,
 				   u32 last_sent);
 int  tipc_bclink_stats(struct net *net, char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(struct net *net);
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index a580a40..feef375 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -85,7 +85,8 @@ static void tipc_disc_init_msg(struct net *net, struct sk_buff *buf, u32 type,
 	u32 dest_domain = b_ptr->domain;
 
 	msg = buf_msg(buf);
-	tipc_msg_init(net, msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
+	tipc_msg_init(tn->own_addr, msg, LINK_CONFIG, type,
+		      INT_H_SIZE, dest_domain);
 	msg_set_non_seq(msg, 1);
 	msg_set_node_sig(msg, tn->random);
 	msg_set_dest_domain(msg, dest_domain);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 77c7ccd..41cb09a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -101,13 +101,12 @@ static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
  */
 #define START_CHANGEOVER 100000u
 
-static void link_handle_out_of_seq_msg(struct net *net,
-				       struct tipc_link *l_ptr,
-				       struct sk_buff *buf);
-static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
-				struct sk_buff *buf);
-static int  tipc_link_tunnel_rcv(struct net *net, struct tipc_node *n_ptr,
-				 struct sk_buff **buf);
+static void link_handle_out_of_seq_msg(struct tipc_link *link,
+				       struct sk_buff *skb);
+static void tipc_link_proto_rcv(struct tipc_link *link,
+				struct sk_buff *skb);
+static int  tipc_link_tunnel_rcv(struct tipc_node *node,
+				 struct sk_buff **skb);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
@@ -303,7 +302,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
 	msg = l_ptr->pmsg;
-	tipc_msg_init(n_ptr->net, msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE,
+	tipc_msg_init(tn->own_addr, msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE,
 		      l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
 	msg_set_session(msg, (tn->random & 0xffff));
@@ -379,12 +378,11 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 static bool link_schedule_user(struct tipc_link *link, u32 oport,
 			       uint chain_sz, uint imp)
 {
-	struct net *net = link->owner->net;
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *buf;
 
-	buf = tipc_msg_create(net, SOCK_WAKEUP, 0, INT_H_SIZE, 0, tn->own_addr,
-			      tn->own_addr, oport, 0, 0);
+	buf = tipc_msg_create(SOCK_WAKEUP, 0, INT_H_SIZE, 0,
+			      link_own_addr(link), link_own_addr(link),
+			      oport, 0, 0);
 	if (!buf)
 		return false;
 	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
@@ -778,7 +776,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
 			link->stats.sent_bundled++;
 			continue;
-		} else if (tipc_msg_make_bundle(net, outqueue, skb, mtu,
+		} else if (tipc_msg_make_bundle(outqueue, skb, mtu,
 						link->addr)) {
 			link->stats.sent_bundled++;
 			link->stats.sent_bundles++;
@@ -877,7 +875,7 @@ static void tipc_link_sync_xmit(struct tipc_link *link)
 		return;
 
 	msg = buf_msg(skb);
-	tipc_msg_init(link->owner->net, msg, BCAST_PROTOCOL, STATE_MSG,
+	tipc_msg_init(link_own_addr(link), msg, BCAST_PROTOCOL, STATE_MSG,
 		      INT_H_SIZE, link->addr);
 	msg_set_last_bcast(msg, link->owner->bclink.acked);
 	__tipc_link_xmit_skb(link, skb);
@@ -1207,7 +1205,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
-				tipc_link_proto_rcv(net, l_ptr, skb);
+				tipc_link_proto_rcv(l_ptr, skb);
 				link_retrieve_defq(l_ptr, &head);
 				tipc_node_unlock(n_ptr);
 				continue;
@@ -1227,7 +1225,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 
 		/* Link is now in state WORKING_WORKING */
 		if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
-			link_handle_out_of_seq_msg(net, l_ptr, skb);
+			link_handle_out_of_seq_msg(l_ptr, skb);
 			link_retrieve_defq(l_ptr, &head);
 			tipc_node_unlock(n_ptr);
 			continue;
@@ -1275,7 +1273,7 @@ static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
 	msg = buf_msg(*buf);
 	switch (msg_user(msg)) {
 	case CHANGEOVER_PROTOCOL:
-		if (tipc_link_tunnel_rcv(net, n, buf))
+		if (tipc_link_tunnel_rcv(n, buf))
 			res = 0;
 		break;
 	case MSG_FRAGMENTER:
@@ -1375,14 +1373,13 @@ u32 tipc_link_defer_pkt(struct sk_buff_head *list, struct sk_buff *skb)
 /*
  * link_handle_out_of_seq_msg - handle arrival of out-of-sequence packet
  */
-static void link_handle_out_of_seq_msg(struct net *net,
-				       struct tipc_link *l_ptr,
+static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf)
 {
 	u32 seq_no = buf_seqno(buf);
 
 	if (likely(msg_user(buf_msg(buf)) == LINK_PROTOCOL)) {
-		tipc_link_proto_rcv(net, l_ptr, buf);
+		tipc_link_proto_rcv(l_ptr, buf);
 		return;
 	}
 
@@ -1507,10 +1504,9 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
  * Note that network plane id propagates through the network, and may
  * change at any time. The node with lowest address rules
  */
-static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
+static void tipc_link_proto_rcv(struct tipc_link *l_ptr,
 				struct sk_buff *buf)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 rec_gap = 0;
 	u32 max_pkt_info;
 	u32 max_pkt_ack;
@@ -1522,7 +1518,7 @@ static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 		goto exit;
 
 	if (l_ptr->net_plane != msg_net_plane(msg))
-		if (tn->own_addr > msg_prevnode(msg))
+		if (link_own_addr(l_ptr) > msg_prevnode(msg))
 			l_ptr->net_plane = msg_net_plane(msg);
 
 	switch (msg_type(msg)) {
@@ -1625,7 +1621,7 @@ static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 
 		/* Protocol message before retransmits, reduce loss risk */
 		if (l_ptr->owner->bclink.recv_permitted)
-			tipc_bclink_update_link_state(net, l_ptr->owner,
+			tipc_bclink_update_link_state(l_ptr->owner,
 						      msg_last_bcast(msg));
 
 		if (rec_gap || (msg_probe(msg))) {
@@ -1690,7 +1686,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	if (!tunnel)
 		return;
 
-	tipc_msg_init(l_ptr->owner->net, &tunnel_hdr, CHANGEOVER_PROTOCOL,
+	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
 		      ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
@@ -1748,7 +1744,7 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 	struct sk_buff *skb;
 	struct tipc_msg tunnel_hdr;
 
-	tipc_msg_init(l_ptr->owner->net, &tunnel_hdr, CHANGEOVER_PROTOCOL,
+	tipc_msg_init(link_own_addr(l_ptr), &tunnel_hdr, CHANGEOVER_PROTOCOL,
 		      DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_msgcnt(&tunnel_hdr, skb_queue_len(&l_ptr->outqueue));
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
@@ -1802,7 +1798,7 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 /* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
  * Owner node is locked.
  */
-static void tipc_link_dup_rcv(struct net *net, struct tipc_link *l_ptr,
+static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
 			      struct sk_buff *t_buf)
 {
 	struct sk_buff *buf;
@@ -1817,7 +1813,7 @@ static void tipc_link_dup_rcv(struct net *net, struct tipc_link *l_ptr,
 	}
 
 	/* Add buffer to deferred queue, if applicable: */
-	link_handle_out_of_seq_msg(net, l_ptr, buf);
+	link_handle_out_of_seq_msg(l_ptr, buf);
 }
 
 /*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
@@ -1869,7 +1865,7 @@ exit:
  *  returned to the active link for delivery upwards.
  *  Owner node is locked.
  */
-static int tipc_link_tunnel_rcv(struct net *net, struct tipc_node *n_ptr,
+static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				struct sk_buff **buf)
 {
 	struct sk_buff *t_buf = *buf;
@@ -1887,7 +1883,7 @@ static int tipc_link_tunnel_rcv(struct net *net, struct tipc_node *n_ptr,
 		goto exit;
 
 	if (msg_type(t_msg) == DUPLICATE_MSG)
-		tipc_link_dup_rcv(net, l_ptr, t_buf);
+		tipc_link_dup_rcv(l_ptr, t_buf);
 	else if (msg_type(t_msg) == ORIGINAL_MSG)
 		*buf = tipc_link_failover_rcv(l_ptr, t_buf);
 	else
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 3e3432b..5b9a17f 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -278,6 +278,10 @@ static inline u32 lesser(u32 left, u32 right)
 	return less_eq(left, right) ? left : right;
 }
 
+static inline u32 link_own_addr(struct tipc_link *l)
+{
+	return msg_prevnode(l->pmsg);
+}
 
 /*
  * Link status checking routines
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index da67c8d..940d741 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -70,25 +70,23 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 	return skb;
 }
 
-void tipc_msg_init(struct net *net, struct tipc_msg *m, u32 user, u32 type,
-		   u32 hsize, u32 destnode)
+void tipc_msg_init(u32 own_node, struct tipc_msg *m, u32 user, u32 type,
+		   u32 hsize, u32 dnode)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-
 	memset(m, 0, hsize);
 	msg_set_version(m);
 	msg_set_user(m, user);
 	msg_set_hdr_sz(m, hsize);
 	msg_set_size(m, hsize);
-	msg_set_prevnode(m, tn->own_addr);
+	msg_set_prevnode(m, own_node);
 	msg_set_type(m, type);
 	if (hsize > SHORT_H_SIZE) {
-		msg_set_orignode(m, tn->own_addr);
-		msg_set_destnode(m, destnode);
+		msg_set_orignode(m, own_node);
+		msg_set_destnode(m, dnode);
 	}
 }
 
-struct sk_buff *tipc_msg_create(struct net *net, uint user, uint type,
+struct sk_buff *tipc_msg_create(uint user, uint type,
 				uint hdr_sz, uint data_sz, u32 dnode,
 				u32 onode, u32 dport, u32 oport, int errcode)
 {
@@ -100,9 +98,8 @@ struct sk_buff *tipc_msg_create(struct net *net, uint user, uint type,
 		return NULL;
 
 	msg = buf_msg(buf);
-	tipc_msg_init(net, msg, user, type, hdr_sz, dnode);
+	tipc_msg_init(onode, msg, user, type, hdr_sz, dnode);
 	msg_set_size(msg, hdr_sz + data_sz);
-	msg_set_prevnode(msg, onode);
 	msg_set_origport(msg, oport);
 	msg_set_destport(msg, dport);
 	msg_set_errcode(msg, errcode);
@@ -195,7 +192,7 @@ err:
  *
  * Returns message data size or errno: -ENOMEM, -EFAULT
  */
-int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int pktmax, struct sk_buff_head *list)
 {
 	int mhsz = msg_hdr_sz(mhdr);
@@ -227,8 +224,8 @@ int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
 	}
 
 	/* Prepare reusable fragment header */
-	tipc_msg_init(net, &pkthdr, MSG_FRAGMENTER, FIRST_FRAGMENT, INT_H_SIZE,
-		      msg_destnode(mhdr));
+	tipc_msg_init(msg_prevnode(mhdr), &pkthdr, MSG_FRAGMENTER,
+		      FIRST_FRAGMENT, INT_H_SIZE, msg_destnode(mhdr));
 	msg_set_size(&pkthdr, pktmax);
 	msg_set_fragm_no(&pkthdr, pktno);
 
@@ -338,7 +335,7 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
  * Replaces buffer if successful
  * Returns true if success, otherwise false
  */
-bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
+bool tipc_msg_make_bundle(struct sk_buff_head *list,
 			  struct sk_buff *skb, u32 mtu, u32 dnode)
 {
 	struct sk_buff *bskb;
@@ -362,7 +359,8 @@ bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
 
 	skb_trim(bskb, INT_H_SIZE);
 	bmsg = buf_msg(bskb);
-	tipc_msg_init(net, bmsg, MSG_BUNDLER, 0, INT_H_SIZE, dnode);
+	tipc_msg_init(msg_prevnode(msg), bmsg, MSG_BUNDLER, 0,
+		      INT_H_SIZE, dnode);
 	msg_set_seqno(bmsg, msg_seqno(msg));
 	msg_set_ack(bmsg, msg_ack(msg));
 	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
@@ -379,10 +377,9 @@ bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
  * Consumes buffer if failure
  * Returns true if success, otherwise false
  */
-bool tipc_msg_reverse(struct net *net, struct sk_buff *buf, u32 *dnode,
+bool tipc_msg_reverse(u32 own_addr,  struct sk_buff *buf, u32 *dnode,
 		      int err)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_msg *msg = buf_msg(buf);
 	uint imp = msg_importance(msg);
 	struct tipc_msg ohdr;
@@ -402,7 +399,7 @@ bool tipc_msg_reverse(struct net *net, struct sk_buff *buf, u32 *dnode,
 	msg_set_errcode(msg, err);
 	msg_set_origport(msg, msg_destport(&ohdr));
 	msg_set_destport(msg, msg_origport(&ohdr));
-	msg_set_prevnode(msg, tn->own_addr);
+	msg_set_prevnode(msg, own_addr);
 	if (!msg_short(msg)) {
 		msg_set_orignode(msg, msg_destnode(&ohdr));
 		msg_set_destnode(msg, msg_orignode(&ohdr));
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 526ef34..f7ea954 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -748,19 +748,19 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 }
 
 struct sk_buff *tipc_buf_acquire(u32 size);
-bool tipc_msg_reverse(struct net *net, struct sk_buff *buf, u32 *dnode,
+bool tipc_msg_reverse(u32 own_addr, struct sk_buff *buf, u32 *dnode,
 		      int err);
 int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode);
-void tipc_msg_init(struct net *net, struct tipc_msg *m, u32 user, u32 type,
+void tipc_msg_init(u32 own_addr, struct tipc_msg *m, u32 user, u32 type,
 		   u32 hsize, u32 destnode);
-struct sk_buff *tipc_msg_create(struct net *net, uint user, uint type,
+struct sk_buff *tipc_msg_create(uint user, uint type,
 				uint hdr_sz, uint data_sz, u32 dnode,
 				u32 onode, u32 dport, u32 oport, int errcode);
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
-bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
+bool tipc_msg_make_bundle(struct sk_buff_head *list,
 			  struct sk_buff *skb, u32 mtu, u32 dnode);
-int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu, struct sk_buff_head *list);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 7f31cd4..dd8564c 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -71,13 +71,14 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 static struct sk_buff *named_prepare_buf(struct net *net, u32 type, u32 size,
 					 u32 dest)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size);
 	struct tipc_msg *msg;
 
 	if (buf != NULL) {
 		msg = buf_msg(buf);
-		tipc_msg_init(net, msg, NAME_DISTRIBUTOR, type, INT_H_SIZE,
-			      dest);
+		tipc_msg_init(tn->own_addr, msg, NAME_DISTRIBUTOR, type,
+			      INT_H_SIZE, dest);
 		msg_set_size(msg, INT_H_SIZE + size);
 	}
 	return buf;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 842bd7a..1c409c4 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -204,7 +204,7 @@ void tipc_node_abort_sock_conns(struct net *net, struct list_head *conns)
 	struct sk_buff *buf;
 
 	list_for_each_entry_safe(conn, safe, conns, list) {
-		buf = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
 				      tn->own_addr, conn->peer_node,
 				      conn->port, conn->peer_port,
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index caa4d66..b384e65 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -177,6 +177,11 @@ static const struct nla_policy tipc_nl_sock_policy[TIPC_NLA_SOCK_MAX + 1] = {
  *   - port reference
  */
 
+static u32 tsk_own_node(struct tipc_sock *tsk)
+{
+	return msg_prevnode(&tsk->phdr);
+}
+
 static u32 tsk_peer_node(struct tipc_sock *tsk)
 {
 	return msg_destnode(&tsk->phdr);
@@ -249,11 +254,11 @@ static void tsk_rej_rx_queue(struct sock *sk)
 {
 	struct sk_buff *skb;
 	u32 dnode;
-	struct net *net = sock_net(sk);
+	u32 own_node = tsk_own_node(tipc_sk(sk));
 
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue))) {
-		if (tipc_msg_reverse(net, skb, &dnode, TIPC_ERR_NO_PORT))
-			tipc_link_xmit_skb(net, skb, dnode, 0);
+		if (tipc_msg_reverse(own_node, skb, &dnode, TIPC_ERR_NO_PORT))
+			tipc_link_xmit_skb(sock_net(sk), skb, dnode, 0);
 	}
 }
 
@@ -305,6 +310,7 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 static int tipc_sk_create(struct net *net, struct socket *sock,
 			  int protocol, int kern)
 {
+	struct tipc_net *tn;
 	const struct proto_ops *ops;
 	socket_state state;
 	struct sock *sk;
@@ -346,7 +352,8 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	tsk->max_pkt = MAX_PKT_DEFAULT;
 	INIT_LIST_HEAD(&tsk->publications);
 	msg = &tsk->phdr;
-	tipc_msg_init(net, msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
+	tn = net_generic(sock_net(sk), tipc_net_id);
+	tipc_msg_init(tn->own_addr, msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
 		      NAMED_H_SIZE, 0);
 
 	/* Finish initializing socket data structures */
@@ -471,7 +478,6 @@ static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct net *net;
-	struct tipc_net *tn;
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
 	u32 dnode, probing_state;
@@ -484,8 +490,6 @@ static int tipc_release(struct socket *sock)
 		return 0;
 
 	net = sock_net(sk);
-	tn = net_generic(net, tipc_net_id);
-
 	tsk = tipc_sk(sk);
 	lock_sock(sk);
 
@@ -507,7 +511,7 @@ static int tipc_release(struct socket *sock)
 				tsk->connected = 0;
 				tipc_node_remove_conn(net, dnode, tsk->portid);
 			}
-			if (tipc_msg_reverse(net, skb, &dnode,
+			if (tipc_msg_reverse(tsk_own_node(tsk), skb, &dnode,
 					     TIPC_ERR_NO_PORT))
 				tipc_link_xmit_skb(net, skb, dnode, 0);
 		}
@@ -520,9 +524,9 @@ static int tipc_release(struct socket *sock)
 		sock_put(sk);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
-		skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 				      TIPC_CONN_MSG, SHORT_H_SIZE, 0, dnode,
-				      tn->own_addr, tsk_peer_port(tsk),
+				      tsk_own_node(tsk), tsk_peer_port(tsk),
 				      tsk->portid, TIPC_ERR_NO_PORT);
 		if (skb)
 			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
@@ -730,8 +734,9 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 			  struct msghdr *msg, size_t dsz, long timeo)
 {
 	struct sock *sk = sock->sk;
+	struct tipc_sock *tsk = tipc_sk(sk);
 	struct net *net = sock_net(sk);
-	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
+	struct tipc_msg *mhdr = &tsk->phdr;
 	struct sk_buff_head head;
 	struct iov_iter save = msg->msg_iter;
 	uint mtu;
@@ -749,7 +754,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(net, mhdr, msg, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &head);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -836,7 +841,7 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 		if (conn_cong)
 			tsk->sk.sk_write_space(&tsk->sk);
 	} else if (msg_type(msg) == CONN_PROBE) {
-		if (!tipc_msg_reverse(sock_net(&tsk->sk), buf, dnode, TIPC_OK))
+		if (!tipc_msg_reverse(tsk_own_node(tsk), buf, dnode, TIPC_OK))
 			return TIPC_OK;
 		msg_set_type(msg, CONN_PROBE_REPLY);
 		return TIPC_FWD_MSG;
@@ -971,7 +976,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(net, mhdr, m, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &head);
 	if (rc < 0)
 		goto exit;
 
@@ -1090,7 +1095,7 @@ next:
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(net, mhdr, m, sent, send, mtu, &head);
+	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &head);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
@@ -1263,7 +1268,6 @@ static int tipc_sk_anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 {
 	struct net *net = sock_net(&tsk->sk);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *skb = NULL;
 	struct tipc_msg *msg;
 	u32 peer_port = tsk_peer_port(tsk);
@@ -1271,9 +1275,9 @@ static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 
 	if (!tsk->connected)
 		return;
-	skb = tipc_msg_create(net, CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0,
-			      dnode, tn->own_addr, peer_port, tsk->portid,
-			      TIPC_OK);
+	skb = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0,
+			      dnode, tsk_own_node(tsk), peer_port,
+			      tsk->portid, TIPC_OK);
 	if (!skb)
 		return;
 	msg = buf_msg(skb);
@@ -1756,7 +1760,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if ((rc < 0) && !tipc_msg_reverse(net, skb, &onode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(tsk_own_node(tsk), skb, &onode, -rc))
 		return 0;
 
 	tipc_link_xmit_skb(net, skb, onode, 0);
@@ -1773,6 +1777,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 {
 	struct tipc_sock *tsk;
+	struct tipc_net *tn;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(skb));
 	int rc = TIPC_OK;
@@ -1804,7 +1809,8 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	if (likely(!rc))
 		return 0;
 exit:
-	if ((rc < 0) && !tipc_msg_reverse(net, skb, &dnode, -rc))
+	tn = net_generic(net, tipc_net_id);
+	if ((rc < 0) && !tipc_msg_reverse(tn->own_addr, skb, &dnode, -rc))
 		return -EHOSTUNREACH;
 
 	tipc_link_xmit_skb(net, skb, dnode, 0);
@@ -2065,7 +2071,6 @@ static int tipc_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct sk_buff *skb;
 	u32 dnode;
@@ -2088,16 +2093,17 @@ restart:
 				kfree_skb(skb);
 				goto restart;
 			}
-			if (tipc_msg_reverse(net, skb, &dnode,
+			if (tipc_msg_reverse(tsk_own_node(tsk), skb, &dnode,
 					     TIPC_CONN_SHUTDOWN))
 				tipc_link_xmit_skb(net, skb, dnode,
 						   tsk->portid);
 			tipc_node_remove_conn(net, dnode, tsk->portid);
 		} else {
 			dnode = tsk_peer_node(tsk);
-			skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+
+			skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 					      TIPC_CONN_MSG, SHORT_H_SIZE,
-					      0, dnode, tn->own_addr,
+					      0, dnode, tsk_own_node(tsk),
 					      tsk_peer_port(tsk),
 					      tsk->portid, TIPC_CONN_SHUTDOWN);
 			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
@@ -2129,10 +2135,9 @@ static void tipc_sk_timeout(unsigned long data)
 {
 	struct tipc_sock *tsk = (struct tipc_sock *)data;
 	struct sock *sk = &tsk->sk;
-	struct net *net = sock_net(sk);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *skb = NULL;
 	u32 peer_port, peer_node;
+	u32 own_node = tsk_own_node(tsk);
 
 	bh_lock_sock(sk);
 	if (!tsk->connected) {
@@ -2144,13 +2149,13 @@ static void tipc_sk_timeout(unsigned long data)
 
 	if (tsk->probing_state == TIPC_CONN_PROBING) {
 		/* Previous probe not answered -> self abort */
-		skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
-				      tn->own_addr, peer_node, tsk->portid,
+				      own_node, peer_node, tsk->portid,
 				      peer_port, TIPC_ERR_NO_PORT);
 	} else {
-		skb = tipc_msg_create(net, CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
-				      0, peer_node, tn->own_addr,
+		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
+				      INT_H_SIZE, 0, peer_node, own_node,
 				      peer_port, tsk->portid, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
 		sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
-- 
1.9.1
