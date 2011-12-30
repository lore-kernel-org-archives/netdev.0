From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 7/8] tipc: rename struct link* to struct tipc_link*
Date: Thu, 29 Dec 2011 22:48:56 -0500
Message-ID: <1325216937-5856-8-git-send-email-paul.gortmaker@windriver.com>
References: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63631 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab1L3DtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 22:49:17 -0500
In-Reply-To: <1325216937-5856-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the following:

	struct link		->	struct tipc_link
	struct link_req		->	struct tipc_link_req
	struct link_name	->	struct tipc_link_name

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |    6 +-
 net/tipc/bearer.c     |   20 ++++---
 net/tipc/bearer.h     |   11 ++--
 net/tipc/discover.c   |   20 +++---
 net/tipc/discover.h   |    8 +-
 net/tipc/link.c       |  153 +++++++++++++++++++++++++------------------------
 net/tipc/link.h       |   52 +++++++++--------
 net/tipc/name_distr.c |    2 +-
 net/tipc/node.c       |   18 +++---
 net/tipc/node.h       |   12 ++--
 10 files changed, 156 insertions(+), 146 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index c24690f..8eb87b1 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -94,7 +94,7 @@ struct tipc_bcbearer {
  */
 
 struct tipc_bclink {
-	struct link link;
+	struct tipc_link link;
 	struct tipc_node node;
 	struct tipc_node_map bcast_nodes;
 	struct tipc_node *retransmit_to;
@@ -105,7 +105,7 @@ static struct tipc_bclink bcast_link;
 
 static struct tipc_bcbearer *bcbearer = &bcast_bearer;
 static struct tipc_bclink *bclink = &bcast_link;
-static struct link *bcl = &bcast_link.link;
+static struct tipc_link *bcl = &bcast_link.link;
 
 static DEFINE_SPINLOCK(bc_lock);
 
@@ -308,7 +308,7 @@ exit:
 
 static void bclink_send_ack(struct tipc_node *n_ptr)
 {
-	struct link *l_ptr = n_ptr->active_links[n_ptr->addr & 1];
+	struct tipc_link *l_ptr = n_ptr->active_links[n_ptr->addr & 1];
 
 	if (l_ptr != NULL)
 		tipc_link_send_proto_msg(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index cddec3d..eab4201 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -318,7 +318,7 @@ void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest)
 static int bearer_push(struct tipc_bearer *b_ptr)
 {
 	u32 res = 0;
-	struct link *ln, *tln;
+	struct tipc_link *ln, *tln;
 
 	if (b_ptr->blocked)
 		return 0;
@@ -364,7 +364,8 @@ void tipc_continue(struct tipc_bearer *b_ptr)
  * bearer.lock is busy
  */
 
-static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr, struct link *l_ptr)
+static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr,
+						struct tipc_link *l_ptr)
 {
 	list_move_tail(&l_ptr->link_list, &b_ptr->cong_links);
 }
@@ -377,7 +378,7 @@ static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr, struct link
  * bearer.lock is free
  */
 
-void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr)
+void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
 {
 	spin_lock_bh(&b_ptr->lock);
 	tipc_bearer_schedule_unlocked(b_ptr, l_ptr);
@@ -390,7 +391,8 @@ void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr)
  * and if there is, try to resolve it before returning.
  * 'tipc_net_lock' is read_locked when this function is called
  */
-int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr)
+int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr,
+					struct tipc_link *l_ptr)
 {
 	int res = 1;
 
@@ -409,7 +411,7 @@ int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr
  * tipc_bearer_congested - determines if bearer is currently congested
  */
 
-int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr)
+int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
 {
 	if (unlikely(b_ptr->blocked))
 		return 1;
@@ -544,8 +546,8 @@ exit:
 int tipc_block_bearer(const char *name)
 {
 	struct tipc_bearer *b_ptr = NULL;
-	struct link *l_ptr;
-	struct link *temp_l_ptr;
+	struct tipc_link *l_ptr;
+	struct tipc_link *temp_l_ptr;
 
 	read_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
@@ -579,8 +581,8 @@ int tipc_block_bearer(const char *name)
 
 static void bearer_disable(struct tipc_bearer *b_ptr)
 {
-	struct link *l_ptr;
-	struct link *temp_l_ptr;
+	struct tipc_link *l_ptr;
+	struct tipc_link *temp_l_ptr;
 
 	info("Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index af01ca2..3480654 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -144,7 +144,7 @@ struct tipc_bearer {
 	u32 window;
 	u32 tolerance;
 	u32 identity;
-	struct link_req *link_req;
+	struct tipc_link_req *link_req;
 	struct list_head links;
 	struct list_head cong_links;
 	int active;
@@ -157,7 +157,7 @@ struct bearer_name {
 	char if_name[TIPC_MAX_IF_NAME];
 };
 
-struct link;
+struct tipc_link;
 
 extern struct tipc_bearer tipc_bearers[];
 
@@ -188,12 +188,13 @@ struct sk_buff *tipc_media_get_names(void);
 struct sk_buff *tipc_bearer_get_names(void);
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
-void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct link *l_ptr);
+void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr);
 struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
 struct tipc_media *tipc_media_find(const char *name);
-int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr, struct link *l_ptr);
-int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr);
+int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr,
+				   struct tipc_link *l_ptr);
+int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr);
 void tipc_bearer_stop(void);
 void tipc_bearer_lock_push(struct tipc_bearer *b_ptr);
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 420e032..a00e5f8 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -45,7 +45,7 @@
 
 
 /**
- * struct link_req - information about an ongoing link setup request
+ * struct tipc_link_req - information about an ongoing link setup request
  * @bearer: bearer issuing requests
  * @dest: destination address for request messages
  * @domain: network domain to which links can be established
@@ -54,7 +54,7 @@
  * @timer: timer governing period between requests
  * @timer_intv: current interval between requests (in ms)
  */
-struct link_req {
+struct tipc_link_req {
 	struct tipc_bearer *bearer;
 	struct tipc_media_addr dest;
 	u32 domain;
@@ -120,7 +120,7 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 {
 	struct tipc_node *n_ptr;
-	struct link *link;
+	struct tipc_link *link;
 	struct tipc_media_addr media_addr, *addr;
 	struct sk_buff *rbuf;
 	struct tipc_msg *msg = buf_msg(buf);
@@ -218,7 +218,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
  * and is either not currently searching or is searching at a slow rate
  */
 
-static void disc_update(struct link_req *req)
+static void disc_update(struct tipc_link_req *req)
 {
 	if (!req->num_nodes) {
 		if ((req->timer_intv == TIPC_LINK_REQ_INACTIVE) ||
@@ -234,7 +234,7 @@ static void disc_update(struct link_req *req)
  * @req: ptr to link request structure
  */
 
-void tipc_disc_add_dest(struct link_req *req)
+void tipc_disc_add_dest(struct tipc_link_req *req)
 {
 	req->num_nodes++;
 }
@@ -244,7 +244,7 @@ void tipc_disc_add_dest(struct link_req *req)
  * @req: ptr to link request structure
  */
 
-void tipc_disc_remove_dest(struct link_req *req)
+void tipc_disc_remove_dest(struct tipc_link_req *req)
 {
 	req->num_nodes--;
 	disc_update(req);
@@ -255,7 +255,7 @@ void tipc_disc_remove_dest(struct link_req *req)
  * @req: ptr to link request structure
  */
 
-static void disc_send_msg(struct link_req *req)
+static void disc_send_msg(struct tipc_link_req *req)
 {
 	if (!req->bearer->blocked)
 		tipc_bearer_send(req->bearer, req->buf, &req->dest);
@@ -268,7 +268,7 @@ static void disc_send_msg(struct link_req *req)
  * Called whenever a link setup request timer associated with a bearer expires.
  */
 
-static void disc_timeout(struct link_req *req)
+static void disc_timeout(struct tipc_link_req *req)
 {
 	int max_delay;
 
@@ -316,7 +316,7 @@ exit:
 int tipc_disc_create(struct tipc_bearer *b_ptr,
 		     struct tipc_media_addr *dest, u32 dest_domain)
 {
-	struct link_req *req;
+	struct tipc_link_req *req;
 
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req)
@@ -345,7 +345,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr,
  * @req: ptr to link request structure
  */
 
-void tipc_disc_delete(struct link_req *req)
+void tipc_disc_delete(struct tipc_link_req *req)
 {
 	k_cancel_timer(&req->timer);
 	k_term_timer(&req->timer);
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index a3af595..75b67c4 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -37,13 +37,13 @@
 #ifndef _TIPC_DISCOVER_H
 #define _TIPC_DISCOVER_H
 
-struct link_req;
+struct tipc_link_req;
 
 int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest,
 		     u32 dest_domain);
-void tipc_disc_delete(struct link_req *req);
-void tipc_disc_add_dest(struct link_req *req);
-void tipc_disc_remove_dest(struct link_req *req);
+void tipc_disc_delete(struct tipc_link_req *req);
+void tipc_disc_add_dest(struct tipc_link_req *req);
+void tipc_disc_remove_dest(struct tipc_link_req *req);
 void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr);
 
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 515dfe4..ac1832a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -71,35 +71,36 @@
 #define START_CHANGEOVER 100000u
 
 /**
- * struct link_name - deconstructed link name
+ * struct tipc_link_name - deconstructed link name
  * @addr_local: network address of node at this end
  * @if_local: name of interface at this end
  * @addr_peer: network address of node at far end
  * @if_peer: name of interface at far end
  */
 
-struct link_name {
+struct tipc_link_name {
 	u32 addr_local;
 	char if_local[TIPC_MAX_IF_NAME];
 	u32 addr_peer;
 	char if_peer[TIPC_MAX_IF_NAME];
 };
 
-static void link_handle_out_of_seq_msg(struct link *l_ptr,
+static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf);
-static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf);
-static int  link_recv_changeover_msg(struct link **l_ptr, struct sk_buff **buf);
-static void link_set_supervision_props(struct link *l_ptr, u32 tolerance);
+static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf);
+static int  link_recv_changeover_msg(struct tipc_link **l_ptr,
+				     struct sk_buff **buf);
+static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
 static int  link_send_sections_long(struct tipc_port *sender,
 				    struct iovec const *msg_sect,
 				    u32 num_sect, unsigned int total_len,
 				    u32 destnode);
-static void link_check_defragm_bufs(struct link *l_ptr);
-static void link_state_event(struct link *l_ptr, u32 event);
-static void link_reset_statistics(struct link *l_ptr);
-static void link_print(struct link *l_ptr, const char *str);
-static void link_start(struct link *l_ptr);
-static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf);
+static void link_check_defragm_bufs(struct tipc_link *l_ptr);
+static void link_state_event(struct tipc_link *l_ptr, u32 event);
+static void link_reset_statistics(struct tipc_link *l_ptr);
+static void link_print(struct tipc_link *l_ptr, const char *str);
+static void link_start(struct tipc_link *l_ptr);
+static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
 
 /*
  *  Simple link routines
@@ -110,7 +111,7 @@ static unsigned int align(unsigned int i)
 	return (i + 3) & ~3u;
 }
 
-static void link_init_max_pkt(struct link *l_ptr)
+static void link_init_max_pkt(struct tipc_link *l_ptr)
 {
 	u32 max_pkt;
 
@@ -127,14 +128,14 @@ static void link_init_max_pkt(struct link *l_ptr)
 	l_ptr->max_pkt_probes = 0;
 }
 
-static u32 link_next_sent(struct link *l_ptr)
+static u32 link_next_sent(struct tipc_link *l_ptr)
 {
 	if (l_ptr->next_out)
 		return buf_seqno(l_ptr->next_out);
 	return mod(l_ptr->next_out_no);
 }
 
-static u32 link_last_sent(struct link *l_ptr)
+static u32 link_last_sent(struct tipc_link *l_ptr)
 {
 	return mod(link_next_sent(l_ptr) - 1);
 }
@@ -143,28 +144,29 @@ static u32 link_last_sent(struct link *l_ptr)
  *  Simple non-static link routines (i.e. referenced outside this file)
  */
 
-int tipc_link_is_up(struct link *l_ptr)
+int tipc_link_is_up(struct tipc_link *l_ptr)
 {
 	if (!l_ptr)
 		return 0;
 	return link_working_working(l_ptr) || link_working_unknown(l_ptr);
 }
 
-int tipc_link_is_active(struct link *l_ptr)
+int tipc_link_is_active(struct tipc_link *l_ptr)
 {
 	return	(l_ptr->owner->active_links[0] == l_ptr) ||
 		(l_ptr->owner->active_links[1] == l_ptr);
 }
 
 /**
- * link_name_validate - validate & (optionally) deconstruct link name
+ * link_name_validate - validate & (optionally) deconstruct tipc_link name
  * @name - ptr to link name string
  * @name_parts - ptr to area for link name components (or NULL if not needed)
  *
  * Returns 1 if link name is valid, otherwise 0.
  */
 
-static int link_name_validate(const char *name, struct link_name *name_parts)
+static int link_name_validate(const char *name,
+				struct tipc_link_name *name_parts)
 {
 	char name_copy[TIPC_MAX_LINK_NAME];
 	char *addr_local;
@@ -238,7 +240,7 @@ static int link_name_validate(const char *name, struct link_name *name_parts)
  * tipc_node_delete() is called.)
  */
 
-static void link_timeout(struct link *l_ptr)
+static void link_timeout(struct tipc_link *l_ptr)
 {
 	tipc_node_lock(l_ptr->owner);
 
@@ -287,7 +289,7 @@ static void link_timeout(struct link *l_ptr)
 	tipc_node_unlock(l_ptr->owner);
 }
 
-static void link_set_timer(struct link *l_ptr, u32 time)
+static void link_set_timer(struct tipc_link *l_ptr, u32 time)
 {
 	k_start_timer(&l_ptr->timer, time);
 }
@@ -301,11 +303,11 @@ static void link_set_timer(struct link *l_ptr, u32 time)
  * Returns pointer to link.
  */
 
-struct link *tipc_link_create(struct tipc_node *n_ptr,
+struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr)
 {
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_msg *msg;
 	char *if_name;
 	char addr_string[16];
@@ -382,7 +384,7 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
  * to avoid a potential deadlock situation.
  */
 
-void tipc_link_delete(struct link *l_ptr)
+void tipc_link_delete(struct tipc_link *l_ptr)
 {
 	if (!l_ptr) {
 		err("Attempt to delete non-existent link\n");
@@ -401,7 +403,7 @@ void tipc_link_delete(struct link *l_ptr)
 	kfree(l_ptr);
 }
 
-static void link_start(struct link *l_ptr)
+static void link_start(struct tipc_link *l_ptr)
 {
 	tipc_node_lock(l_ptr->owner);
 	link_state_event(l_ptr, STARTING_EVT);
@@ -418,7 +420,7 @@ static void link_start(struct link *l_ptr)
  * has abated.
  */
 
-static int link_schedule_port(struct link *l_ptr, u32 origport, u32 sz)
+static int link_schedule_port(struct tipc_link *l_ptr, u32 origport, u32 sz)
 {
 	struct tipc_port *p_ptr;
 
@@ -440,7 +442,7 @@ exit:
 	return -ELINKCONG;
 }
 
-void tipc_link_wakeup_ports(struct link *l_ptr, int all)
+void tipc_link_wakeup_ports(struct tipc_link *l_ptr, int all)
 {
 	struct tipc_port *p_ptr;
 	struct tipc_port *temp_p_ptr;
@@ -475,7 +477,7 @@ exit:
  * @l_ptr: pointer to link
  */
 
-static void link_release_outqueue(struct link *l_ptr)
+static void link_release_outqueue(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->first_out;
 	struct sk_buff *next;
@@ -494,7 +496,7 @@ static void link_release_outqueue(struct link *l_ptr)
  * @l_ptr: pointer to link
  */
 
-void tipc_link_reset_fragments(struct link *l_ptr)
+void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->defragm_buf;
 	struct sk_buff *next;
@@ -512,7 +514,7 @@ void tipc_link_reset_fragments(struct link *l_ptr)
  * @l_ptr: pointer to link
  */
 
-void tipc_link_stop(struct link *l_ptr)
+void tipc_link_stop(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf;
 	struct sk_buff *next;
@@ -537,7 +539,7 @@ void tipc_link_stop(struct link *l_ptr)
 	l_ptr->proto_msg_queue = NULL;
 }
 
-void tipc_link_reset(struct link *l_ptr)
+void tipc_link_reset(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf;
 	u32 prev_state = l_ptr->state;
@@ -597,7 +599,7 @@ void tipc_link_reset(struct link *l_ptr)
 }
 
 
-static void link_activate(struct link *l_ptr)
+static void link_activate(struct tipc_link *l_ptr)
 {
 	l_ptr->next_in_no = l_ptr->stats.recv_info = 1;
 	tipc_node_link_up(l_ptr->owner, l_ptr);
@@ -610,9 +612,9 @@ static void link_activate(struct link *l_ptr)
  * @event: state machine event to process
  */
 
-static void link_state_event(struct link *l_ptr, unsigned event)
+static void link_state_event(struct tipc_link *l_ptr, unsigned event)
 {
-	struct link *other;
+	struct tipc_link *other;
 	u32 cont_intv = l_ptr->continuity_interval;
 
 	if (!l_ptr->started && (event != STARTING_EVT))
@@ -784,7 +786,7 @@ static void link_state_event(struct link *l_ptr, unsigned event)
  * the tail of an existing one.
  */
 
-static int link_bundle_buf(struct link *l_ptr,
+static int link_bundle_buf(struct tipc_link *l_ptr,
 			   struct sk_buff *bundler,
 			   struct sk_buff *buf)
 {
@@ -813,7 +815,7 @@ static int link_bundle_buf(struct link *l_ptr,
 	return 1;
 }
 
-static void link_add_to_outqueue(struct link *l_ptr,
+static void link_add_to_outqueue(struct tipc_link *l_ptr,
 				 struct sk_buff *buf,
 				 struct tipc_msg *msg)
 {
@@ -834,7 +836,7 @@ static void link_add_to_outqueue(struct link *l_ptr,
 		l_ptr->stats.max_queue_sz = l_ptr->out_queue_size;
 }
 
-static void link_add_chain_to_outqueue(struct link *l_ptr,
+static void link_add_chain_to_outqueue(struct tipc_link *l_ptr,
 				       struct sk_buff *buf_chain,
 				       u32 long_msgno)
 {
@@ -859,7 +861,7 @@ static void link_add_chain_to_outqueue(struct link *l_ptr,
  * has failed, and from link_send()
  */
 
-int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
+int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	u32 size = msg_size(msg);
@@ -954,7 +956,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 {
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 	int res = -ELINKCONG;
 
@@ -988,7 +990,7 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 void tipc_link_send_names(struct list_head *message_list, u32 dest)
 {
 	struct tipc_node *n_ptr;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct sk_buff *buf;
 	struct sk_buff *temp_buf;
 
@@ -1027,7 +1029,7 @@ void tipc_link_send_names(struct list_head *message_list, u32 dest)
  * Link is locked. Returns user data length.
  */
 
-static int link_send_buf_fast(struct link *l_ptr, struct sk_buff *buf,
+static int link_send_buf_fast(struct tipc_link *l_ptr, struct sk_buff *buf,
 			      u32 *used_max_pkt)
 {
 	struct tipc_msg *msg = buf_msg(buf);
@@ -1061,7 +1063,7 @@ static int link_send_buf_fast(struct link *l_ptr, struct sk_buff *buf,
  */
 int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 {
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_node *n_ptr;
 	int res;
 	u32 selector = msg_origport(buf_msg(buf)) & 1;
@@ -1100,7 +1102,7 @@ int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 u32 destaddr)
 {
 	struct tipc_msg *hdr = &sender->phdr;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct sk_buff *buf;
 	struct tipc_node *node;
 	int res;
@@ -1195,7 +1197,7 @@ static int link_send_sections_long(struct tipc_port *sender,
 				   unsigned int total_len,
 				   u32 destaddr)
 {
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_node *node;
 	struct tipc_msg *hdr = &sender->phdr;
 	u32 dsz = total_len;
@@ -1342,7 +1344,7 @@ reject:
 /*
  * tipc_link_push_packet: Push one unsent packet to the media
  */
-u32 tipc_link_push_packet(struct link *l_ptr)
+u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 {
 	struct sk_buff *buf = l_ptr->first_out;
 	u32 r_q_size = l_ptr->retransm_queue_size;
@@ -1426,7 +1428,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
  * push_queue(): push out the unsent messages of a link where
  *               congestion has abated. Node is locked
  */
-void tipc_link_push_queue(struct link *l_ptr)
+void tipc_link_push_queue(struct tipc_link *l_ptr)
 {
 	u32 res;
 
@@ -1470,7 +1472,8 @@ static void link_reset_all(unsigned long addr)
 	read_unlock_bh(&tipc_net_lock);
 }
 
-static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
+static void link_retransmit_failure(struct tipc_link *l_ptr,
+					struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 
@@ -1514,7 +1517,7 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 	}
 }
 
-void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
+void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 			  u32 retransmits)
 {
 	struct tipc_msg *msg;
@@ -1571,7 +1574,7 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
  * link_insert_deferred_queue - insert deferred messages back into receive chain
  */
 
-static struct sk_buff *link_insert_deferred_queue(struct link *l_ptr,
+static struct sk_buff *link_insert_deferred_queue(struct tipc_link *l_ptr,
 						  struct sk_buff *buf)
 {
 	u32 seq_no;
@@ -1653,7 +1656,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 	read_lock_bh(&tipc_net_lock);
 	while (head) {
 		struct tipc_node *n_ptr;
-		struct link *l_ptr;
+		struct tipc_link *l_ptr;
 		struct sk_buff *crs;
 		struct sk_buff *buf = head;
 		struct tipc_msg *msg;
@@ -1906,7 +1909,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head,
  * link_handle_out_of_seq_msg - handle arrival of out-of-sequence packet
  */
 
-static void link_handle_out_of_seq_msg(struct link *l_ptr,
+static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf)
 {
 	u32 seq_no = buf_seqno(buf);
@@ -1944,8 +1947,9 @@ static void link_handle_out_of_seq_msg(struct link *l_ptr,
 /*
  * Send protocol message to the other endpoint.
  */
-void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
-			      u32 gap, u32 tolerance, u32 priority, u32 ack_mtu)
+void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
+				int probe_msg, u32 gap, u32 tolerance,
+				u32 priority, u32 ack_mtu)
 {
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg = l_ptr->pmsg;
@@ -2062,7 +2066,7 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
  * change at any time. The node with lowest address rules
  */
 
-static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
+static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 {
 	u32 rec_gap = 0;
 	u32 max_pkt_info;
@@ -2195,12 +2199,12 @@ exit:
  * tipc_link_tunnel(): Send one message via a link belonging to
  * another bearer. Owner node is locked.
  */
-static void tipc_link_tunnel(struct link *l_ptr,
+static void tipc_link_tunnel(struct tipc_link *l_ptr,
 			     struct tipc_msg *tunnel_hdr,
 			     struct tipc_msg  *msg,
 			     u32 selector)
 {
-	struct link *tunnel;
+	struct tipc_link *tunnel;
 	struct sk_buff *buf;
 	u32 length = msg_size(msg);
 
@@ -2229,11 +2233,11 @@ static void tipc_link_tunnel(struct link *l_ptr,
  *               Owner node is locked.
  */
 
-void tipc_link_changeover(struct link *l_ptr)
+void tipc_link_changeover(struct tipc_link *l_ptr)
 {
 	u32 msgcount = l_ptr->out_queue_size;
 	struct sk_buff *crs = l_ptr->first_out;
-	struct link *tunnel = l_ptr->owner->active_links[0];
+	struct tipc_link *tunnel = l_ptr->owner->active_links[0];
 	struct tipc_msg tunnel_hdr;
 	int split_bundles;
 
@@ -2292,7 +2296,7 @@ void tipc_link_changeover(struct link *l_ptr)
 	}
 }
 
-void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
+void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *tunnel)
 {
 	struct sk_buff *iter;
 	struct tipc_msg tunnel_hdr;
@@ -2356,11 +2360,11 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
  *  via other link. Node is locked. Return extracted buffer.
  */
 
-static int link_recv_changeover_msg(struct link **l_ptr,
+static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 				    struct sk_buff **buf)
 {
 	struct sk_buff *tunnel_buf = *buf;
-	struct link *dest_link;
+	struct tipc_link *dest_link;
 	struct tipc_msg *msg;
 	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
 	u32 msg_typ = msg_type(tunnel_msg);
@@ -2460,7 +2464,7 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
  * The buffer is complete, inclusive total message length.
  * Returns user data length.
  */
-static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
+static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 {
 	struct sk_buff *buf_chain = NULL;
 	struct sk_buff *buf_chain_tail = (struct sk_buff *)&buf_chain;
@@ -2656,7 +2660,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
  * @l_ptr: pointer to link
  */
 
-static void link_check_defragm_bufs(struct link *l_ptr)
+static void link_check_defragm_bufs(struct tipc_link *l_ptr)
 {
 	struct sk_buff *prev = NULL;
 	struct sk_buff *next = NULL;
@@ -2686,7 +2690,7 @@ static void link_check_defragm_bufs(struct link *l_ptr)
 
 
 
-static void link_set_supervision_props(struct link *l_ptr, u32 tolerance)
+static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 {
 	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
 		return;
@@ -2698,7 +2702,7 @@ static void link_set_supervision_props(struct link *l_ptr, u32 tolerance)
 }
 
 
-void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
+void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 {
 	/* Data messages from this node, inclusive FIRST_FRAGM */
 	l_ptr->queue_limit[TIPC_LOW_IMPORTANCE] = window;
@@ -2728,11 +2732,12 @@ void tipc_link_set_queue_limits(struct link *l_ptr, u32 window)
  * Returns pointer to link (or 0 if invalid link name).
  */
 
-static struct link *link_find_link(const char *name, struct tipc_node **node)
+static struct tipc_link *link_find_link(const char *name,
+					struct tipc_node **node)
 {
-	struct link_name link_name_parts;
+	struct tipc_link_name link_name_parts;
 	struct tipc_bearer *b_ptr;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 
 	if (!link_name_validate(name, &link_name_parts))
 		return NULL;
@@ -2791,7 +2796,7 @@ static int link_value_is_valid(u16 cmd, u32 new_value)
 static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 {
 	struct tipc_node *node;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
 
@@ -2893,7 +2898,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
  * @l_ptr: pointer to link
  */
 
-static void link_reset_statistics(struct link *l_ptr)
+static void link_reset_statistics(struct tipc_link *l_ptr)
 {
 	memset(&l_ptr->stats, 0, sizeof(l_ptr->stats));
 	l_ptr->stats.sent_info = l_ptr->next_out_no;
@@ -2903,7 +2908,7 @@ static void link_reset_statistics(struct link *l_ptr)
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space)
 {
 	char *link_name;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_node *node;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
@@ -2951,7 +2956,7 @@ static u32 percent(u32 count, u32 total)
 static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 {
 	struct print_buf pb;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct tipc_node *node;
 	char *status;
 	u32 profile_total = 0;
@@ -3073,7 +3078,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 {
 	struct tipc_node *n_ptr;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	u32 res = MAX_PKT_DEFAULT;
 
 	if (dest == tipc_own_addr)
@@ -3092,7 +3097,7 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 	return res;
 }
 
-static void link_print(struct link *l_ptr, const char *str)
+static void link_print(struct tipc_link *l_ptr, const char *str)
 {
 	char print_area[256];
 	struct print_buf pb;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index d35b0f3..73c18c1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -67,7 +67,7 @@
 #define MAX_PKT_DEFAULT 1500
 
 /**
- * struct link - TIPC link data structure
+ * struct tipc_link - TIPC link data structure
  * @addr: network address of link's peer node
  * @name: link name character string
  * @media_addr: media address to use when sending messages over link
@@ -115,7 +115,7 @@
  * @stats: collects statistics regarding link activity
  */
 
-struct link {
+struct tipc_link {
 	u32 addr;
 	char name[TIPC_MAX_LINK_NAME];
 	struct tipc_media_addr media_addr;
@@ -213,24 +213,24 @@ struct link {
 
 struct tipc_port;
 
-struct link *tipc_link_create(struct tipc_node *n_ptr,
+struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 			      struct tipc_bearer *b_ptr,
 			      const struct tipc_media_addr *media_addr);
-void tipc_link_delete(struct link *l_ptr);
-void tipc_link_changeover(struct link *l_ptr);
-void tipc_link_send_duplicate(struct link *l_ptr, struct link *dest);
-void tipc_link_reset_fragments(struct link *l_ptr);
-int tipc_link_is_up(struct link *l_ptr);
-int tipc_link_is_active(struct link *l_ptr);
-u32 tipc_link_push_packet(struct link *l_ptr);
-void tipc_link_stop(struct link *l_ptr);
+void tipc_link_delete(struct tipc_link *l_ptr);
+void tipc_link_changeover(struct tipc_link *l_ptr);
+void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *dest);
+void tipc_link_reset_fragments(struct tipc_link *l_ptr);
+int tipc_link_is_up(struct tipc_link *l_ptr);
+int tipc_link_is_active(struct tipc_link *l_ptr);
+u32 tipc_link_push_packet(struct tipc_link *l_ptr);
+void tipc_link_stop(struct tipc_link *l_ptr);
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space, u16 cmd);
 struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space);
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area, int req_tlv_space);
-void tipc_link_reset(struct link *l_ptr);
+void tipc_link_reset(struct tipc_link *l_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 void tipc_link_send_names(struct list_head *message_list, u32 dest);
-int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf);
+int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
@@ -241,14 +241,16 @@ void tipc_link_recv_bundle(struct sk_buff *buf);
 int  tipc_link_recv_fragment(struct sk_buff **pending,
 			     struct sk_buff **fb,
 			     struct tipc_msg **msg);
-void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int prob, u32 gap,
-			      u32 tolerance, u32 priority, u32 acked_mtu);
-void tipc_link_push_queue(struct link *l_ptr);
+void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ, int prob,
+			      u32 gap, u32 tolerance, u32 priority,
+			      u32 acked_mtu);
+void tipc_link_push_queue(struct tipc_link *l_ptr);
 u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 		   struct sk_buff *buf);
-void tipc_link_wakeup_ports(struct link *l_ptr, int all);
-void tipc_link_set_queue_limits(struct link *l_ptr, u32 window);
-void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *start, u32 retransmits);
+void tipc_link_wakeup_ports(struct tipc_link *l_ptr, int all);
+void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
+void tipc_link_retransmit(struct tipc_link *l_ptr,
+			  struct sk_buff *start, u32 retransmits);
 
 /*
  * Link sequence number manipulation routines (uses modulo 2**16 arithmetic)
@@ -293,32 +295,32 @@ static inline u32 lesser(u32 left, u32 right)
  * Link status checking routines
  */
 
-static inline int link_working_working(struct link *l_ptr)
+static inline int link_working_working(struct tipc_link *l_ptr)
 {
 	return l_ptr->state == WORKING_WORKING;
 }
 
-static inline int link_working_unknown(struct link *l_ptr)
+static inline int link_working_unknown(struct tipc_link *l_ptr)
 {
 	return l_ptr->state == WORKING_UNKNOWN;
 }
 
-static inline int link_reset_unknown(struct link *l_ptr)
+static inline int link_reset_unknown(struct tipc_link *l_ptr)
 {
 	return l_ptr->state == RESET_UNKNOWN;
 }
 
-static inline int link_reset_reset(struct link *l_ptr)
+static inline int link_reset_reset(struct tipc_link *l_ptr)
 {
 	return l_ptr->state == RESET_RESET;
 }
 
-static inline int link_blocked(struct link *l_ptr)
+static inline int link_blocked(struct tipc_link *l_ptr)
 {
 	return l_ptr->exp_msg_count || l_ptr->blocked;
 }
 
-static inline int link_congested(struct link *l_ptr)
+static inline int link_congested(struct tipc_link *l_ptr)
 {
 	return l_ptr->out_queue_size >= l_ptr->queue_limit[0];
 }
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index be8306f..98ebb37 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -176,7 +176,7 @@ void tipc_named_withdraw(struct publication *publ)
 void tipc_named_node_up(unsigned long nodearg)
 {
 	struct tipc_node *n_ptr;
-	struct link *l_ptr;
+	struct tipc_link *l_ptr;
 	struct publication *publ;
 	struct distr_item *item = NULL;
 	struct sk_buff *buf = NULL;
diff --git a/net/tipc/node.c b/net/tipc/node.c
index e530de2..6b226fa 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -136,9 +136,9 @@ void tipc_node_delete(struct tipc_node *n_ptr)
  * Link becomes active (alone or shared) or standby, depending on its priority.
  */
 
-void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr)
+void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	struct link **active = &n_ptr->active_links[0];
+	struct tipc_link **active = &n_ptr->active_links[0];
 
 	n_ptr->working_links++;
 
@@ -171,14 +171,14 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr)
 
 static void node_select_active_links(struct tipc_node *n_ptr)
 {
-	struct link **active = &n_ptr->active_links[0];
+	struct tipc_link **active = &n_ptr->active_links[0];
 	u32 i;
 	u32 highest_prio = 0;
 
 	active[0] = active[1] = NULL;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		struct link *l_ptr = n_ptr->links[i];
+		struct tipc_link *l_ptr = n_ptr->links[i];
 
 		if (!l_ptr || !tipc_link_is_up(l_ptr) ||
 		    (l_ptr->priority < highest_prio))
@@ -197,9 +197,9 @@ static void node_select_active_links(struct tipc_node *n_ptr)
  * tipc_node_link_down - handle loss of link
  */
 
-void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr)
+void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
-	struct link **active;
+	struct tipc_link **active;
 
 	n_ptr->working_links--;
 
@@ -239,14 +239,14 @@ int tipc_node_is_up(struct tipc_node *n_ptr)
 	return tipc_node_active_links(n_ptr);
 }
 
-void tipc_node_attach_link(struct tipc_node *n_ptr, struct link *l_ptr)
+void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = l_ptr;
 	atomic_inc(&tipc_num_links);
 	n_ptr->link_cnt++;
 }
 
-void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
+void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
 	n_ptr->links[l_ptr->b_ptr->identity] = NULL;
 	atomic_dec(&tipc_num_links);
@@ -360,7 +360,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 
 	/* Abort link changeover */
 	for (i = 0; i < MAX_BEARERS; i++) {
-		struct link *l_ptr = n_ptr->links[i];
+		struct tipc_link *l_ptr = n_ptr->links[i];
 		if (!l_ptr)
 			continue;
 		l_ptr->reset_checkpoint = l_ptr->next_in_no;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 4f15cb4..0b1c5f8 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -79,8 +79,8 @@ struct tipc_node {
 	struct hlist_node hash;
 	struct list_head list;
 	struct list_head nsub;
-	struct link *active_links[2];
-	struct link *links[MAX_BEARERS];
+	struct tipc_link *active_links[2];
+	struct tipc_link *links[MAX_BEARERS];
 	int link_cnt;
 	int working_links;
 	int block_setup;
@@ -117,10 +117,10 @@ extern u32 tipc_own_tag;
 struct tipc_node *tipc_node_find(u32 addr);
 struct tipc_node *tipc_node_create(u32 addr);
 void tipc_node_delete(struct tipc_node *n_ptr);
-void tipc_node_attach_link(struct tipc_node *n_ptr, struct link *l_ptr);
-void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr);
-void tipc_node_link_down(struct tipc_node *n_ptr, struct link *l_ptr);
-void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr);
+void tipc_node_attach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
+void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
+void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
+void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr);
 int tipc_node_active_links(struct tipc_node *n_ptr);
 int tipc_node_redundant_links(struct tipc_node *n_ptr);
 int tipc_node_is_up(struct tipc_node *n_ptr);
-- 
1.7.4.4
