From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 5/5] tipc: clean out all instances of #if 0'd unused code
Date: Tue, 12 Oct 2010 20:25:58 -0400
Message-ID: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61692 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab0JMA0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 20:26:03 -0400
In-Reply-To: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove all instances of legacy, or as yet to be implemented code
that is currently living within an #if 0 ... #endif block.
In the rare instance that some of it be needed in the future,
it can still be dragged out of history, but there is no need
for it to sit in mainline.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c     |  141 -------------------------------------------------
 net/tipc/discover.c   |   20 -------
 net/tipc/discover.h   |    3 -
 net/tipc/link.c       |  112 +--------------------------------------
 net/tipc/link.h       |    4 --
 net/tipc/name_table.c |   17 ------
 net/tipc/net.c        |    9 ---
 net/tipc/node.c       |   26 ---------
 net/tipc/port.c       |   44 ---------------
 9 files changed, 1 insertions(+), 375 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index a43450c..1e2fd41 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -120,139 +120,6 @@ struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 	return buf;
 }
 
-
-#if 0
-
-/* Now obsolete code for handling commands not yet implemented the new way */
-
-/*
- * Some of this code assumed that the manager structure contains two added
- * fields:
- *	u32 link_subscriptions;
- *	struct list_head link_subscribers;
- * which are currently not present.  These fields may need to be re-introduced
- * if and when support for link subscriptions is added.
- */
-
-void tipc_cfg_link_event(u32 addr, char *name, int up)
-{
-	/* TIPC DOESN'T HANDLE LINK EVENT SUBSCRIPTIONS AT THE MOMENT */
-}
-
-int tipc_cfg_cmd(const struct tipc_cmd_msg * msg,
-		 char *data,
-		 u32 sz,
-		 u32 *ret_size,
-		 struct tipc_portid *orig)
-{
-	int rv = -EINVAL;
-	u32 cmd = msg->cmd;
-
-	*ret_size = 0;
-	switch (cmd) {
-	case TIPC_REMOVE_LINK:
-	case TIPC_CMD_BLOCK_LINK:
-	case TIPC_CMD_UNBLOCK_LINK:
-		if (!cfg_check_connection(orig))
-			rv = link_control(msg->argv.link_name, msg->cmd, 0);
-		break;
-	case TIPC_ESTABLISH:
-		{
-			int connected;
-
-			tipc_isconnected(mng.conn_port_ref, &connected);
-			if (connected || !orig) {
-				rv = TIPC_FAILURE;
-				break;
-			}
-			rv = tipc_connect2port(mng.conn_port_ref, orig);
-			if (rv == TIPC_OK)
-				orig = 0;
-			break;
-		}
-	case TIPC_GET_PEER_ADDRESS:
-		*ret_size = link_peer_addr(msg->argv.link_name, data, sz);
-		break;
-	case TIPC_GET_ROUTES:
-		rv = TIPC_OK;
-		break;
-	default: {}
-	}
-	if (*ret_size)
-		rv = TIPC_OK;
-	return rv;
-}
-
-static void cfg_cmd_event(struct tipc_cmd_msg *msg,
-			  char *data,
-			  u32 sz,
-			  struct tipc_portid const *orig)
-{
-	int rv = -EINVAL;
-	struct tipc_cmd_result_msg rmsg;
-	struct iovec msg_sect[2];
-	int *arg;
-
-	msg->cmd = ntohl(msg->cmd);
-
-	cfg_prepare_res_msg(msg->cmd, msg->usr_handle, rv, &rmsg, msg_sect,
-			    data, 0);
-	if (ntohl(msg->magic) != TIPC_MAGIC)
-		goto exit;
-
-	switch (msg->cmd) {
-	case TIPC_CREATE_LINK:
-		if (!cfg_check_connection(orig))
-			rv = disc_create_link(&msg->argv.create_link);
-		break;
-	case TIPC_LINK_SUBSCRIBE:
-		{
-			struct subscr_data *sub;
-
-			if (mng.link_subscriptions > 64)
-				break;
-			sub = kmalloc(sizeof(*sub),
-							    GFP_ATOMIC);
-			if (sub == NULL) {
-				warn("Memory squeeze; dropped remote link subscription\n");
-				break;
-			}
-			INIT_LIST_HEAD(&sub->subd_list);
-			tipc_createport(mng.user_ref,
-					(void *)sub,
-					TIPC_HIGH_IMPORTANCE,
-					0,
-					0,
-					(tipc_conn_shutdown_event)cfg_linksubscr_cancel,
-					0,
-					0,
-					(tipc_conn_msg_event)cfg_linksubscr_cancel,
-					0,
-					&sub->port_ref);
-			if (!sub->port_ref) {
-				kfree(sub);
-				break;
-			}
-			memcpy(sub->usr_handle,msg->usr_handle,
-			       sizeof(sub->usr_handle));
-			sub->domain = msg->argv.domain;
-			list_add_tail(&sub->subd_list, &mng.link_subscribers);
-			tipc_connect2port(sub->port_ref, orig);
-			rmsg.retval = TIPC_OK;
-			tipc_send(sub->port_ref, 2u, msg_sect);
-			mng.link_subscriptions++;
-			return;
-		}
-	default:
-		rv = tipc_cfg_cmd(msg, data, sz, (u32 *)&msg_sect[1].iov_len, orig);
-	}
-exit:
-	rmsg.result_len = htonl(msg_sect[1].iov_len);
-	rmsg.retval = htonl(rv);
-	tipc_cfg_respond(msg_sect, 2u, orig);
-}
-#endif
-
 #define MAX_STATS_INFO 2000
 
 static struct sk_buff *tipc_show_stats(void)
@@ -546,14 +413,6 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SHOW_PORTS:
 		rep_tlv_buf = tipc_port_get_ports();
 		break;
-#if 0
-	case TIPC_CMD_SHOW_PORT_STATS:
-		rep_tlv_buf = port_show_stats(req_tlv_area, req_tlv_space);
-		break;
-	case TIPC_CMD_RESET_PORT_STATS:
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED);
-		break;
-#endif
 	case TIPC_CMD_SET_LOG_SIZE:
 		rep_tlv_buf = tipc_log_resize_cmd(req_tlv_area, req_tlv_space);
 		break;
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f28d1ae..dbd79c6 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -46,16 +46,6 @@
 #define TIPC_LINK_REQ_FAST	2000	/* normal delay if bearer has no links */
 #define TIPC_LINK_REQ_SLOW	600000	/* normal delay if bearer has links */
 
-#if 0
-#define  GET_NODE_INFO         300
-#define  GET_NODE_INFO_RESULT  301
-#define  FORWARD_LINK_PROBE    302
-#define  LINK_REQUEST_REJECTED 303
-#define  LINK_REQUEST_ACCEPTED 304
-#define  DROP_LINK_REQUEST     305
-#define  CHECK_LINK_COUNT      306
-#endif
-
 /*
  * TODO: Most of the inter-cluster setup stuff should be
  * rewritten, and be made conformant with specification.
@@ -79,16 +69,6 @@ struct link_req {
 };
 
 
-#if 0
-int disc_create_link(const struct tipc_link_create *argv)
-{
-	/*
-	 * Code for inter cluster link setup here
-	 */
-	return TIPC_OK;
-}
-#endif
-
 /*
  * disc_lost_link(): A link has lost contact
  */
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index c36eaeb..9d064c3 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -51,8 +51,5 @@ void tipc_disc_stop_link_req(struct link_req *req);
 void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr);
 
 void tipc_disc_link_event(u32 addr, char *name, int up);
-#if 0
-int  disc_create_link(const struct tipc_link_create *argv);
-#endif
 
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 13bc0b6..4284351 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -99,23 +99,6 @@ struct link_name {
 	char if_peer[TIPC_MAX_IF_NAME];
 };
 
-#if 0
-
-/* LINK EVENT CODE IS NOT SUPPORTED AT PRESENT */
-
-/**
- * struct link_event - link up/down event notification
- */
-
-struct link_event {
-	u32 addr;
-	int up;
-	void (*fcn)(u32, char *, int);
-	char name[TIPC_MAX_LINK_NAME];
-};
-
-#endif
-
 static void link_handle_out_of_seq_msg(struct link *l_ptr,
 				       struct sk_buff *buf);
 static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf);
@@ -634,39 +617,9 @@ void tipc_link_stop(struct link *l_ptr)
 	l_ptr->proto_msg_queue = NULL;
 }
 
-#if 0
-
 /* LINK EVENT CODE IS NOT SUPPORTED AT PRESENT */
-
-static void link_recv_event(struct link_event *ev)
-{
-	ev->fcn(ev->addr, ev->name, ev->up);
-	kfree(ev);
-}
-
-static void link_send_event(void (*fcn)(u32 a, char *n, int up),
-			    struct link *l_ptr, int up)
-{
-	struct link_event *ev;
-
-	ev = kmalloc(sizeof(*ev), GFP_ATOMIC);
-	if (!ev) {
-		warn("Link event allocation failure\n");
-		return;
-	}
-	ev->addr = l_ptr->addr;
-	ev->up = up;
-	ev->fcn = fcn;
-	memcpy(ev->name, l_ptr->name, TIPC_MAX_LINK_NAME);
-	tipc_k_signal((Handler)link_recv_event, (unsigned long)ev);
-}
-
-#else
-
 #define link_send_event(fcn, l_ptr, up) do { } while (0)
 
-#endif
-
 void tipc_link_reset(struct link *l_ptr)
 {
 	struct sk_buff *buf;
@@ -690,10 +643,7 @@ void tipc_link_reset(struct link *l_ptr)
 
 	tipc_node_link_down(l_ptr->owner, l_ptr);
 	tipc_bearer_remove_dest(l_ptr->b_ptr, l_ptr->addr);
-#if 0
-	tipc_printf(TIPC_CONS, "\nReset link <%s>\n", l_ptr->name);
-	dbg_link_dump();
-#endif
+
 	if (was_active_link && tipc_node_has_active_links(l_ptr->owner) &&
 	    l_ptr->owner->permit_changeover) {
 		l_ptr->reset_checkpoint = checkpoint;
@@ -3198,44 +3148,6 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 	return buf;
 }
 
-#if 0
-int link_control(const char *name, u32 op, u32 val)
-{
-	int res = -EINVAL;
-	struct link *l_ptr;
-	u32 bearer_id;
-	struct tipc_node * node;
-	u32 a;
-
-	a = link_name2addr(name, &bearer_id);
-	read_lock_bh(&tipc_net_lock);
-	node = tipc_node_find(a);
-	if (node) {
-		tipc_node_lock(node);
-		l_ptr = node->links[bearer_id];
-		if (l_ptr) {
-			if (op == TIPC_REMOVE_LINK) {
-				struct bearer *b_ptr = l_ptr->b_ptr;
-				spin_lock_bh(&b_ptr->publ.lock);
-				tipc_link_delete(l_ptr);
-				spin_unlock_bh(&b_ptr->publ.lock);
-			}
-			if (op == TIPC_CMD_BLOCK_LINK) {
-				tipc_link_reset(l_ptr);
-				l_ptr->blocked = 1;
-			}
-			if (op == TIPC_CMD_UNBLOCK_LINK) {
-				l_ptr->blocked = 0;
-			}
-			res = 0;
-		}
-		tipc_node_unlock(node);
-	}
-	read_unlock_bh(&tipc_net_lock);
-	return res;
-}
-#endif
-
 /**
  * tipc_link_get_max_pkt - get maximum packet size to use when sending to destination
  * @dest: network address of destination node
@@ -3266,28 +3178,6 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 	return res;
 }
 
-#if 0
-static void link_dump_rec_queue(struct link *l_ptr)
-{
-	struct sk_buff *crs;
-
-	if (!l_ptr->oldest_deferred_in) {
-		info("Reception queue empty\n");
-		return;
-	}
-	info("Contents of Reception queue:\n");
-	crs = l_ptr->oldest_deferred_in;
-	while (crs) {
-		if (crs->data == (void *)0x0000a3a3) {
-			info("buffer %x invalid\n", crs);
-			return;
-		}
-		msg_dbg(buf_msg(crs), "In rec queue:\n");
-		crs = crs->next;
-	}
-}
-#endif
-
 static void link_dump_send_queue(struct link *l_ptr)
 {
 	if (l_ptr->next_out) {
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 26151d3..4e944ef 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -210,10 +210,6 @@ struct link {
 		u32 msg_length_counts;
 		u32 msg_lengths_total;
 		u32 msg_length_profile[7];
-#if 0
-		u32 sent_tunneled;
-		u32 recv_tunneled;
-#endif
 	} stats;
 
 	struct print_buf print_buf;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 9ca4b06..3a8de43 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1009,16 +1009,6 @@ static void nametbl_list(struct print_buf *buf, u32 depth_info,
 	}
 }
 
-#if 0
-void tipc_nametbl_print(struct print_buf *buf, const char *str)
-{
-	tipc_printf(buf, str);
-	read_lock_bh(&tipc_nametbl_lock);
-	nametbl_list(buf, 0, 0, 0, 0);
-	read_unlock_bh(&tipc_nametbl_lock);
-}
-#endif
-
 #define MAX_NAME_TBL_QUERY 32768
 
 struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
@@ -1051,13 +1041,6 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 	return buf;
 }
 
-#if 0
-void tipc_nametbl_dump(void)
-{
-	nametbl_list(TIPC_CONS, 0, 0, 0, 0);
-}
-#endif
-
 int tipc_nametbl_init(void)
 {
 	table.types = kcalloc(tipc_nametbl_size, sizeof(struct hlist_head),
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7e05af4..1a621cf 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -129,15 +129,6 @@ u32 tipc_net_select_router(u32 addr, u32 ref)
 	return tipc_zone_select_router(tipc_net.zones[tipc_zone(addr)], addr, ref);
 }
 
-#if 0
-u32 tipc_net_next_node(u32 a)
-{
-	if (tipc_net.zones[tipc_zone(a)])
-		return tipc_zone_next_node(a);
-	return 0;
-}
-#endif
-
 void tipc_net_remove_as_router(u32 router)
 {
 	u32 z_num;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 944b480..fab80b4 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -121,16 +121,6 @@ void tipc_node_delete(struct tipc_node *n_ptr)
 	if (!n_ptr)
 		return;
 
-#if 0
-	/* Not needed because links are already deleted via tipc_bearer_stop() */
-
-	u32 l_num;
-
-	for (l_num = 0; l_num < MAX_BEARERS; l_num++) {
-		link_delete(n_ptr->links[l_num]);
-	}
-#endif
-
 	dbg("node %x deleted\n", n_ptr->addr);
 	node_count--;
 	list_del(&n_ptr->node_list);
@@ -597,22 +587,6 @@ void tipc_node_remove_router(struct tipc_node *n_ptr, u32 router)
 		node_lost_contact(n_ptr);
 }
 
-#if 0
-void node_print(struct print_buf *buf, struct tipc_node *n_ptr, char *str)
-{
-	u32 i;
-
-	tipc_printf(buf, "\n\n%s", str);
-	for (i = 0; i < MAX_BEARERS; i++) {
-		if (!n_ptr->links[i])
-			continue;
-		tipc_printf(buf, "Links[%u]: %x, ", i, n_ptr->links[i]);
-	}
-	tipc_printf(buf, "Active links: [%x,%x]\n",
-		    n_ptr->active_links[0], n_ptr->active_links[1]);
-}
-#endif
-
 u32 tipc_available_nodes(const u32 domain)
 {
 	struct tipc_node *n_ptr;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index d760336..5c4285b 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -710,50 +710,6 @@ struct sk_buff *tipc_port_get_ports(void)
 	return buf;
 }
 
-#if 0
-
-#define MAX_PORT_STATS 2000
-
-struct sk_buff *port_show_stats(const void *req_tlv_area, int req_tlv_space)
-{
-	u32 ref;
-	struct port *p_ptr;
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	struct print_buf pb;
-	int str_len;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_PORT_REF))
-		return cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	ref = *(u32 *)TLV_DATA(req_tlv_area);
-	ref = ntohl(ref);
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return cfg_reply_error_string("port not found");
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_PORT_STATS));
-	if (!buf) {
-		tipc_port_unlock(p_ptr);
-		return NULL;
-	}
-	rep_tlv = (struct tlv_desc *)buf->data;
-
-	tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), MAX_PORT_STATS);
-	port_print(p_ptr, &pb, 1);
-	/* NEED TO FILL IN ADDITIONAL PORT STATISTICS HERE */
-	tipc_port_unlock(p_ptr);
-	str_len = tipc_printbuf_validate(&pb);
-
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
-#endif
-
 void tipc_port_reinit(void)
 {
 	struct port *p_ptr;
-- 
1.7.0.4

