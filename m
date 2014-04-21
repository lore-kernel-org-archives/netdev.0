From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/11] tipc: decouple the
	relationship between bearer and link
Date: Mon, 21 Apr 2014 10:55:46 +0800
Message-ID: <1398048952-7825-6-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Currently on both paths of message transmission and reception, the
read lock of tipc_net_lock must be held before bearer is accessed,
while the write lock of tipc_net_lock has to be taken before bearer
is configured. Although it can ensure that bearer is always valid on
the two data paths, link and bearer is closely bound together.

So as the part of effort of removing tipc_net_lock, the locking
policy of bearer protection will be adjusted as below: on the two
data paths, RCU is used, and on the configuration path of bearer,
RTNL lock is applied.

Now RCU just covers the path of message reception. To make it possible
to protect the path of message transmission with RCU, link should not
use its stored bearer pointer to access bearer, but it should use the
bearer identity of its attached bearer as index to get bearer instance
from bearer_list array, which can help us decouple the relationship
between bearer and link. As a result, bearer on the path of message
transmission can be safely protected by RCU when we access bearer_list
array within RCU lock protection.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bcast.c    |    8 ++++----
 net/tipc/bearer.c   |   40 ++++++++++++++++++++++++++++++----------
 net/tipc/bearer.h   |    6 +++---
 net/tipc/discover.c |   17 ++++++++++-------
 net/tipc/link.c     |   49 +++++++++++++++++++++++++++++++++----------------
 net/tipc/link.h     |    6 ++++--
 net/tipc/node.c     |    8 ++++----
 7 files changed, 88 insertions(+), 46 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 223a199..51dab96 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -321,7 +321,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 				 : n_ptr->bclink.last_sent);
 
 		spin_lock_bh(&bc_lock);
-		tipc_bearer_send(&bcbearer->bearer, buf, NULL);
+		tipc_bearer_send(MAX_BEARERS, buf, NULL);
 		bcl->stats.sent_nacks++;
 		spin_unlock_bh(&bc_lock);
 		kfree_skb(buf);
@@ -627,13 +627,13 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 
 		if (bp_index == 0) {
 			/* Use original buffer for first bearer */
-			tipc_bearer_send(b, buf, &b->bcast_addr);
+			tipc_bearer_send(b->identity, buf, &b->bcast_addr);
 		} else {
 			/* Avoid concurrent buffer access */
 			tbuf = pskb_copy(buf, GFP_ATOMIC);
 			if (!tbuf)
 				break;
-			tipc_bearer_send(b, tbuf, &b->bcast_addr);
+			tipc_bearer_send(b->identity, tbuf, &b->bcast_addr);
 			kfree_skb(tbuf); /* Bearer keeps a clone */
 		}
 
@@ -786,7 +786,7 @@ void tipc_bclink_init(void)
 	bcl->owner = &bclink->node;
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
-	bcl->b_ptr = &bcbearer->bearer;
+	bcl->bearer_id = MAX_BEARERS;
 	rcu_assign_pointer(bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 65b1763..e0625e9 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -215,18 +215,32 @@ struct sk_buff *tipc_bearer_get_names(void)
 	return buf;
 }
 
-void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest)
+void tipc_bearer_add_dest(u32 bearer_id, u32 dest)
 {
-	tipc_nmap_add(&b_ptr->nodes, dest);
-	tipc_bcbearer_sort();
-	tipc_disc_add_dest(b_ptr->link_req);
+	struct tipc_bearer *b_ptr;
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	if (b_ptr) {
+		tipc_nmap_add(&b_ptr->nodes, dest);
+		tipc_bcbearer_sort();
+		tipc_disc_add_dest(b_ptr->link_req);
+	}
+	rcu_read_unlock();
 }
 
-void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest)
+void tipc_bearer_remove_dest(u32 bearer_id, u32 dest)
 {
-	tipc_nmap_remove(&b_ptr->nodes, dest);
-	tipc_bcbearer_sort();
-	tipc_disc_remove_dest(b_ptr->link_req);
+	struct tipc_bearer *b_ptr;
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	if (b_ptr) {
+		tipc_nmap_remove(&b_ptr->nodes, dest);
+		tipc_bcbearer_sort();
+		tipc_disc_remove_dest(b_ptr->link_req);
+	}
+	rcu_read_unlock();
 }
 
 /**
@@ -507,10 +521,16 @@ int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
  * The media send routine must not alter the buffer being passed in
  * as it may be needed for later retransmission!
  */
-void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
+void tipc_bearer_send(u32 bearer_id, struct sk_buff *buf,
 		      struct tipc_media_addr *dest)
 {
-	b->media->send_msg(buf, b, dest);
+	struct tipc_bearer *b_ptr;
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	if (likely(b_ptr))
+		b_ptr->media->send_msg(buf, b_ptr, dest);
+	rcu_read_unlock();
 }
 
 /**
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index b67b7ea..2fa86bd 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -183,14 +183,14 @@ int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
 		     struct tipc_media_addr *dest);
 
 struct sk_buff *tipc_bearer_get_names(void);
-void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
-void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
+void tipc_bearer_add_dest(u32 bearer_id, u32 dest);
+void tipc_bearer_remove_dest(u32 bearer_id, u32 dest);
 struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
 void tipc_bearer_stop(void);
-void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
+void tipc_bearer_send(u32 bearer_id, struct sk_buff *buf,
 		      struct tipc_media_addr *dest);
 
 #endif	/* _TIPC_BEARER_H */
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 542fe34..3a8f211 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -46,8 +46,9 @@
 
 /**
  * struct tipc_link_req - information about an ongoing link setup request
- * @bearer: bearer issuing requests
+ * @bearer_id: identity of bearer issuing requests
  * @dest: destination address for request messages
+ * @domain: network domain to which links can be established
  * @num_nodes: number of nodes currently discovered (i.e. with an active link)
  * @lock: spinlock for controlling access to requests
  * @buf: request message to be (repeatedly) sent
@@ -55,8 +56,9 @@
  * @timer_intv: current interval between requests (in ms)
  */
 struct tipc_link_req {
-	struct tipc_bearer *bearer;
+	u32 bearer_id;
 	struct tipc_media_addr dest;
+	u32 domain;
 	int num_nodes;
 	spinlock_t lock;
 	struct sk_buff *buf;
@@ -241,7 +243,7 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	if ((type == DSC_REQ_MSG) && !link_fully_up) {
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, b_ptr);
 		if (rbuf) {
-			tipc_bearer_send(b_ptr, rbuf, &media_addr);
+			tipc_bearer_send(b_ptr->identity, rbuf, &media_addr);
 			kfree_skb(rbuf);
 		}
 	}
@@ -303,7 +305,7 @@ static void disc_timeout(struct tipc_link_req *req)
 	spin_lock_bh(&req->lock);
 
 	/* Stop searching if only desired node has been found */
-	if (tipc_node(req->bearer->domain) && req->num_nodes) {
+	if (tipc_node(req->domain) && req->num_nodes) {
 		req->timer_intv = TIPC_LINK_REQ_INACTIVE;
 		goto exit;
 	}
@@ -315,7 +317,7 @@ static void disc_timeout(struct tipc_link_req *req)
 	 * hold at fast polling rate if don't have any associated nodes,
 	 * otherwise hold at slow polling rate
 	 */
-	tipc_bearer_send(req->bearer, req->buf, &req->dest);
+	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
 
 
 	req->timer_intv *= 2;
@@ -354,14 +356,15 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 	}
 
 	memcpy(&req->dest, dest, sizeof(*dest));
-	req->bearer = b_ptr;
+	req->bearer_id = b_ptr->identity;
+	req->domain = b_ptr->domain;
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	spin_lock_init(&req->lock);
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
 	b_ptr->link_req = req;
-	tipc_bearer_send(req->bearer, req->buf, &req->dest);
+	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
 	return 0;
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index c5190ab..229d478 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -101,9 +101,18 @@ static unsigned int align(unsigned int i)
 
 static void link_init_max_pkt(struct tipc_link *l_ptr)
 {
+	struct tipc_bearer *b_ptr;
 	u32 max_pkt;
 
-	max_pkt = (l_ptr->b_ptr->mtu & ~3);
+	rcu_read_lock();
+	b_ptr = rcu_dereference_rtnl(bearer_list[l_ptr->bearer_id]);
+	if (!b_ptr) {
+		rcu_read_unlock();
+		return;
+	}
+	max_pkt = (b_ptr->mtu & ~3);
+	rcu_read_unlock();
+
 	if (max_pkt > MAX_MSG_SIZE)
 		max_pkt = MAX_MSG_SIZE;
 
@@ -248,7 +257,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->owner = n_ptr;
 	l_ptr->checkpoint = 1;
 	l_ptr->peer_session = INVALID_SESSION;
-	l_ptr->b_ptr = b_ptr;
+	l_ptr->bearer_id = b_ptr->identity;
 	link_set_supervision_props(l_ptr, b_ptr->tolerance);
 	l_ptr->state = RESET_UNKNOWN;
 
@@ -263,6 +272,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->priority = b_ptr->priority;
 	tipc_link_set_queue_limits(l_ptr, b_ptr->window);
 
+	l_ptr->net_plane = b_ptr->net_plane;
 	link_init_max_pkt(l_ptr);
 
 	l_ptr->next_out_no = 1;
@@ -426,7 +436,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 		return;
 
 	tipc_node_link_down(l_ptr->owner, l_ptr);
-	tipc_bearer_remove_dest(l_ptr->b_ptr, l_ptr->addr);
+	tipc_bearer_remove_dest(l_ptr->bearer_id, l_ptr->addr);
 
 	if (was_active_link && tipc_node_active_links(l_ptr->owner)) {
 		l_ptr->reset_checkpoint = checkpoint;
@@ -477,7 +487,7 @@ static void link_activate(struct tipc_link *l_ptr)
 {
 	l_ptr->next_in_no = l_ptr->stats.recv_info = 1;
 	tipc_node_link_up(l_ptr->owner, l_ptr);
-	tipc_bearer_add_dest(l_ptr->b_ptr, l_ptr->addr);
+	tipc_bearer_add_dest(l_ptr->bearer_id, l_ptr->addr);
 }
 
 /**
@@ -777,7 +787,7 @@ int __tipc_link_xmit(struct tipc_link *l_ptr, struct sk_buff *buf)
 	if (likely(!link_congested(l_ptr))) {
 		link_add_to_outqueue(l_ptr, buf, msg);
 
-		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
 		l_ptr->unacked_window = 0;
 		return dsz;
 	}
@@ -941,7 +951,7 @@ static int tipc_link_xmit_fast(struct tipc_link *l_ptr, struct sk_buff *buf,
 	if (likely(!link_congested(l_ptr))) {
 		if (likely(msg_size(msg) <= l_ptr->max_pkt)) {
 			link_add_to_outqueue(l_ptr, buf, msg);
-			tipc_bearer_send(l_ptr->b_ptr, buf,
+			tipc_bearer_send(l_ptr->bearer_id, buf,
 					 &l_ptr->media_addr);
 			l_ptr->unacked_window = 0;
 			return res;
@@ -1204,7 +1214,7 @@ static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	if (r_q_size && buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
 		l_ptr->retransm_queue_head = mod(++r_q_head);
 		l_ptr->retransm_queue_size = --r_q_size;
 		l_ptr->stats.retransmitted++;
@@ -1216,7 +1226,7 @@ static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	if (buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
 		l_ptr->unacked_window = 0;
 		kfree_skb(buf);
 		l_ptr->proto_msg_queue = NULL;
@@ -1233,7 +1243,8 @@ static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 		if (mod(next - first) < l_ptr->queue_limit[0]) {
 			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-			tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+			tipc_bearer_send(l_ptr->bearer_id, buf,
+					 &l_ptr->media_addr);
 			if (msg_user(msg) == MSG_BUNDLER)
 				msg_set_type(msg, CLOSED_MSG);
 			l_ptr->next_out = buf->next;
@@ -1352,7 +1363,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		msg = buf_msg(buf);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
 		buf = buf->next;
 		retransmits--;
 		l_ptr->stats.retransmitted++;
@@ -1440,7 +1451,7 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 /**
  * tipc_rcv - process TIPC packets/messages arriving from off-node
  * @head: pointer to message buffer chain
- * @tb_ptr: pointer to bearer message arrived on
+ * @b_ptr: pointer to bearer message arrived on
  *
  * Invoked with no locks held.  Bearer pointer must point to a valid bearer
  * structure (i.e. cannot be NULL), but bearer can be inactive.
@@ -1752,7 +1763,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 
 	/* Create protocol message with "out-of-sequence" sequence number */
 	msg_set_type(msg, msg_typ);
-	msg_set_net_plane(msg, l_ptr->b_ptr->net_plane);
+	msg_set_net_plane(msg, l_ptr->net_plane);
 	msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 	msg_set_last_bcast(msg, tipc_bclink_get_last_sent());
 
@@ -1818,7 +1829,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 	buf->priority = TC_PRIO_CONTROL;
 
-	tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+	tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
 	l_ptr->unacked_window = 0;
 	kfree_skb(buf);
 }
@@ -1843,9 +1854,9 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 	/* record unnumbered packet arrival (force mismatch on next timeout) */
 	l_ptr->checkpoint--;
 
-	if (l_ptr->b_ptr->net_plane != msg_net_plane(msg))
+	if (l_ptr->net_plane != msg_net_plane(msg))
 		if (tipc_own_addr > msg_prevnode(msg))
-			l_ptr->b_ptr->net_plane = msg_net_plane(msg);
+			l_ptr->net_plane = msg_net_plane(msg);
 
 	switch (msg_type(msg)) {
 
@@ -2793,7 +2804,13 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
-	pr_info("%s Link %x<%s>:", str, l_ptr->addr, l_ptr->b_ptr->name);
+	struct tipc_bearer *b_ptr;
+
+	rcu_read_lock();
+	b_ptr = rcu_dereference_rtnl(bearer_list[l_ptr->bearer_id]);
+	if (b_ptr)
+		pr_info("%s Link %x<%s>:", str, l_ptr->addr, b_ptr->name);
+	rcu_read_unlock();
 
 	if (link_working_unknown(l_ptr))
 		pr_cont(":WU\n");
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 8c0b49b..4b556c1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -107,7 +107,7 @@ struct tipc_stats {
  * @checkpoint: reference point for triggering link continuity checking
  * @peer_session: link session # being used by peer end of link
  * @peer_bearer_id: bearer id used by link's peer endpoint
- * @b_ptr: pointer to bearer used by link
+ * @bearer_id: local bearer id used by link
  * @tolerance: minimum link continuity loss needed to reset link [in ms]
  * @continuity_interval: link continuity testing interval [in ms]
  * @abort_limit: # of unacknowledged continuity probes needed to reset link
@@ -116,6 +116,7 @@ struct tipc_stats {
  * @proto_msg: template for control messages generated by link
  * @pmsg: convenience pointer to "proto_msg" field
  * @priority: current link priority
+ * @net_plane: current link network plane ('A' through 'H')
  * @queue_limit: outbound message queue congestion thresholds (indexed by user)
  * @exp_msg_count: # of tunnelled messages expected during link changeover
  * @reset_checkpoint: seq # of last acknowledged message at time of link reset
@@ -155,7 +156,7 @@ struct tipc_link {
 	u32 checkpoint;
 	u32 peer_session;
 	u32 peer_bearer_id;
-	struct tipc_bearer *b_ptr;
+	u32 bearer_id;
 	u32 tolerance;
 	u32 continuity_interval;
 	u32 abort_limit;
@@ -167,6 +168,7 @@ struct tipc_link {
 	} proto_msg;
 	struct tipc_msg *pmsg;
 	u32 priority;
+	char net_plane;
 	u32 queue_limit[15];	/* queue_limit[0]==window limit */
 
 	/* Changeover */
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1d3a499..fa6823f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -148,7 +148,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->working_links++;
 
 	pr_info("Established link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->b_ptr->net_plane);
+		l_ptr->name, l_ptr->net_plane);
 
 	if (!active[0]) {
 		active[0] = active[1] = l_ptr;
@@ -208,11 +208,11 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 	if (!tipc_link_is_active(l_ptr)) {
 		pr_info("Lost standby link <%s> on network plane %c\n",
-			l_ptr->name, l_ptr->b_ptr->net_plane);
+			l_ptr->name, l_ptr->net_plane);
 		return;
 	}
 	pr_info("Lost link <%s> on network plane %c\n",
-		l_ptr->name, l_ptr->b_ptr->net_plane);
+		l_ptr->name, l_ptr->net_plane);
 
 	active = &n_ptr->active_links[0];
 	if (active[0] == l_ptr)
@@ -239,7 +239,7 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 
 void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	n_ptr->links[l_ptr->b_ptr->identity] = l_ptr;
+	n_ptr->links[l_ptr->bearer_id] = l_ptr;
 	spin_lock_bh(&node_list_lock);
 	tipc_num_links++;
 	spin_unlock_bh(&node_list_lock);
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
