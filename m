From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/4] tipc: rename functions
	related to link failover and improve comments
Date: Tue,  7 Jan 2014 17:02:41 -0500
Message-ID: <1389132164-32451-2-git-send-email-jon.maloy@ericsson.com>
References: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1389132164-32451-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The functionality related to link addition and failover is unnecessarily
hard to understand and maintain. We try to improve this by renaming
some of the functions, at the same time adding or improving the
explanatory comments around them. Names such as "tipc_rcv()" etc. also
align better with what is used in other networking components.

The changes in this commit are purely cosmetic, no functional changes
are made.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    2 +-
 net/tipc/bearer.h |    3 +--
 net/tipc/link.c   |   70 ++++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h   |   15 ++++++++----
 net/tipc/node.c   |    4 +--
 5 files changed, 56 insertions(+), 38 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 07ed5cc..2d456ab 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -541,7 +541,7 @@ static int tipc_l2_rcv_msg(struct sk_buff *buf, struct net_device *dev,
 	if (likely(b_ptr)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
-			tipc_recv_msg(buf, b_ptr);
+			tipc_rcv(buf, b_ptr);
 			rcu_read_unlock();
 			return NET_RX_SUCCESS;
 		}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 410efb1..4f5db9a 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -161,8 +161,7 @@ extern struct tipc_bearer tipc_bearers[];
  * TIPC routines available to supported media types
  */
 
-void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
-
+void tipc_rcv(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
 int tipc_disable_bearer(const char *name);
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 131a32a..bb48b96 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/link.c: TIPC link code
  *
- * Copyright (c) 1996-2007, 2012, Ericsson AB
+ * Copyright (c) 1996-2007, 2012-2014, Ericsson AB
  * Copyright (c) 2004-2007, 2010-2013, Wind River Systems
  * All rights reserved.
  *
@@ -78,8 +78,8 @@ static const char *link_unk_evt = "Unknown link event ";
 static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf);
 static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf);
-static int  link_recv_changeover_msg(struct tipc_link **l_ptr,
-				     struct sk_buff **buf);
+static int  tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
+				 struct sk_buff **buf);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
 static int  link_send_sections_long(struct tipc_port *sender,
 				    struct iovec const *msg_sect,
@@ -278,7 +278,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	tipc_node_attach_link(n_ptr, l_ptr);
 
-	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
+	k_init_timer(&l_ptr->timer, (Handler)link_timeout,
+		     (unsigned long)l_ptr);
 	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	tipc_k_signal((Handler)link_start, (unsigned long)l_ptr);
 
@@ -1422,14 +1423,14 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 }
 
 /**
- * tipc_recv_msg - process TIPC messages arriving from off-node
+ * tipc_rcv - process TIPC packets/messages arriving from off-node
  * @head: pointer to message buffer chain
  * @tb_ptr: pointer to bearer message arrived on
  *
  * Invoked with no locks held.  Bearer pointer must point to a valid bearer
  * structure (i.e. cannot be NULL), but bearer can be inactive.
  */
-void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
+void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
 	while (head) {
@@ -1603,7 +1604,7 @@ deliver:
 			continue;
 		case CHANGEOVER_PROTOCOL:
 			type = msg_type(msg);
-			if (link_recv_changeover_msg(&l_ptr, &buf)) {
+			if (tipc_link_tunnel_rcv(&l_ptr, &buf)) {
 				msg = buf_msg(buf);
 				seq_no = msg_seqno(msg);
 				if (type == ORIGINAL_MSG)
@@ -1954,13 +1955,13 @@ exit:
 }
 
 
-/*
- * tipc_link_tunnel(): Send one message via a link belonging to
- * another bearer. Owner node is locked.
+/* tipc_link_tunnel_xmit(): Tunnel one packet via a link belonging to
+ * a different bearer. Owner node is locked.
  */
-static void tipc_link_tunnel(struct tipc_link *l_ptr,
-			     struct tipc_msg *tunnel_hdr, struct tipc_msg *msg,
-			     u32 selector)
+static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
+				  struct tipc_msg *tunnel_hdr,
+				  struct tipc_msg *msg,
+				  u32 selector)
 {
 	struct tipc_link *tunnel;
 	struct sk_buff *buf;
@@ -1983,12 +1984,13 @@ static void tipc_link_tunnel(struct tipc_link *l_ptr,
 }
 
 
-
-/*
- * changeover(): Send whole message queue via the remaining link
- *               Owner node is locked.
+/* tipc_link_failover_send_queue(): A link has gone down, but a second
+ * link is still active. We can do failover. Tunnel the failing link's
+ * whole send queue via the remaining link. This way, we don't lose
+ * any packets, and sequence order is preserved for subsequent traffic
+ * sent over the remaining link. Owner node is locked.
  */
-void tipc_link_changeover(struct tipc_link *l_ptr)
+void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 {
 	u32 msgcount = l_ptr->out_queue_size;
 	struct sk_buff *crs = l_ptr->first_out;
@@ -2037,20 +2039,30 @@ void tipc_link_changeover(struct tipc_link *l_ptr)
 			msgcount = msg_msgcnt(msg);
 			while (msgcount--) {
 				msg_set_seqno(m, msg_seqno(msg));
-				tipc_link_tunnel(l_ptr, &tunnel_hdr, m,
-						 msg_link_selector(m));
+				tipc_link_tunnel_xmit(l_ptr, &tunnel_hdr, m,
+						      msg_link_selector(m));
 				pos += align(msg_size(m));
 				m = (struct tipc_msg *)pos;
 			}
 		} else {
-			tipc_link_tunnel(l_ptr, &tunnel_hdr, msg,
-					 msg_link_selector(msg));
+			tipc_link_tunnel_xmit(l_ptr, &tunnel_hdr, msg,
+					      msg_link_selector(msg));
 		}
 		crs = crs->next;
 	}
 }
 
-void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *tunnel)
+/* tipc_link_dup_send_queue(): A second link has become active. Tunnel a
+ * duplicate of the first link's send queue via the new link. This way, we
+ * are guaranteed that currently queued packets from a socket are delivered
+ * before future traffic from the same socket, even if this is using the
+ * new link. The last arriving copy of each duplicate packet is dropped at
+ * the receiving end by the regular protocol check, so packet cardinality
+ * and sequence order is preserved per sender/receiver socket pair.
+ * Owner node is locked.
+ */
+void tipc_link_dup_send_queue(struct tipc_link *l_ptr,
+			      struct tipc_link *tunnel)
 {
 	struct sk_buff *iter;
 	struct tipc_msg tunnel_hdr;
@@ -2106,12 +2118,14 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 	return eb;
 }
 
-/*
- *  link_recv_changeover_msg(): Receive tunneled packet sent
- *  via other link. Node is locked. Return extracted buffer.
+/*  tipc_link_tunnel_rcv(): Receive a tunneled packet, sent
+ *  via other link as result of a failover (ORIGINAL_MSG) or
+ *  a new active link (DUPLICATE_MSG). Failover packets are
+ *  returned to the active link for delivery upwards.
+ *  Owner node is locked.
  */
-static int link_recv_changeover_msg(struct tipc_link **l_ptr,
-				    struct sk_buff **buf)
+static int tipc_link_tunnel_rcv(struct tipc_link **l_ptr,
+				struct sk_buff **buf)
 {
 	struct sk_buff *tunnel_buf = *buf;
 	struct tipc_link *dest_link;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 0636ca9..89ab89b 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -216,15 +216,20 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
 void tipc_link_delete(struct tipc_link *l_ptr);
-void tipc_link_changeover(struct tipc_link *l_ptr);
-void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *dest);
+void tipc_link_failover_send_queue(struct tipc_link *l_ptr);
+void tipc_link_dup_send_queue(struct tipc_link *l_ptr,
+			      struct tipc_link *dest);
 void tipc_link_reset_fragments(struct tipc_link *l_ptr);
 int tipc_link_is_up(struct tipc_link *l_ptr);
 int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_stop(struct tipc_link *l_ptr);
-struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space, u16 cmd);
-struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space);
-struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space);
+struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area,
+				     int req_tlv_space,
+				     u16 cmd);
+struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
+					 int req_tlv_space);
+struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
+					  int req_tlv_space);
 void tipc_link_reset(struct tipc_link *l_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 void tipc_link_send_names(struct list_head *message_list, u32 dest);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index e167d26..efe4d41 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -162,7 +162,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		pr_info("New link <%s> becomes standby\n", l_ptr->name);
 		return;
 	}
-	tipc_link_send_duplicate(active[0], l_ptr);
+	tipc_link_dup_send_queue(active[0], l_ptr);
 	if (l_ptr->priority == active[0]->priority) {
 		active[0] = l_ptr;
 		return;
@@ -225,7 +225,7 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	if (active[0] == l_ptr)
 		node_select_active_links(n_ptr);
 	if (tipc_node_is_up(n_ptr))
-		tipc_link_changeover(l_ptr);
+		tipc_link_failover_send_queue(l_ptr);
 	else
 		node_lost_contact(n_ptr);
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
