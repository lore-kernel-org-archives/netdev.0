From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] tipc: cleanup function namespace
Date: Wed, 13 Oct 2010 16:20:35 -0700
Message-ID: <20101013162035.0c2e8123@nehalam>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>, paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab0JMXUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 19:20:41 -0400
In-Reply-To: <20101013.142834.226768662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do some cleanups of TIPC based on make namespacecheck
  1. Don't export unused symbols
  2. Eliminate dead code
  3. Make functions and variables local
  4. Rename buf_acquire to tipc_buf_acquire since it is used in several files

Compile tested only.
This make break out of tree kernel modules that depend on TIPC routines.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/tipc/tipc.h      |   71 -------------
 include/net/tipc/tipc_port.h |    2 
 net/tipc/addr.c              |    5 
 net/tipc/bcast.c             |   10 +
 net/tipc/bcast.h             |    3 
 net/tipc/cluster.c           |   21 ---
 net/tipc/cluster.h           |    2 
 net/tipc/config.c            |    7 +
 net/tipc/config.h            |    6 -
 net/tipc/core.c              |   28 +----
 net/tipc/core.h              |    9 -
 net/tipc/dbg.c               |   13 +-
 net/tipc/dbg.h               |    3 
 net/tipc/discover.c          |   16 --
 net/tipc/discover.h          |    2 
 net/tipc/link.c              |   45 ++++----
 net/tipc/link.h              |    4 
 net/tipc/msg.c               |    2 
 net/tipc/name_distr.c        |    2 
 net/tipc/node.c              |   19 ---
 net/tipc/node.h              |    1 
 net/tipc/port.c              |  234 ++++---------------------------------------
 net/tipc/port.h              |    2 
 net/tipc/ref.c               |   17 ---
 net/tipc/ref.h               |    1 
 net/tipc/subscr.c            |    9 -
 net/tipc/zone.c              |   11 --
 net/tipc/zone.h              |    1 
 28 files changed, 84 insertions(+), 462 deletions(-)

--- a/include/net/tipc/tipc.h	2010-10-13 15:43:50.025580173 -0700
+++ b/include/net/tipc/tipc.h	2010-10-13 16:14:33.731207018 -0700
@@ -50,8 +50,6 @@
  * TIPC operating mode routines
  */
 
-u32 tipc_get_addr(void);
-
 #define TIPC_NOT_RUNNING  0
 #define TIPC_NODE_MODE    1
 #define TIPC_NET_MODE     2
@@ -62,8 +60,6 @@ int tipc_attach(unsigned int *userref, t
 
 void tipc_detach(unsigned int userref);
 
-int tipc_get_mode(void);
-
 /*
  * TIPC port manipulation routines
  */
@@ -153,12 +149,6 @@ int tipc_disconnect(u32 portref);
 
 int tipc_shutdown(u32 ref);
 
-int tipc_isconnected(u32 portref, int *isconnected);
-
-int tipc_peer(u32 portref, struct tipc_portid *peer);
-
-int tipc_ref_valid(u32 portref); 
-
 /*
  * TIPC messaging routines
  */
@@ -170,38 +160,12 @@ int tipc_send(u32 portref,
 	      unsigned int num_sect,
 	      struct iovec const *msg_sect);
 
-int tipc_send_buf(u32 portref,
-		  struct sk_buff *buf,
-		  unsigned int dsz);
-
 int tipc_send2name(u32 portref, 
 		   struct tipc_name const *name, 
 		   u32 domain,
 		   unsigned int num_sect,
 		   struct iovec const *msg_sect);
 
-int tipc_send_buf2name(u32 portref,
-		       struct tipc_name const *name,
-		       u32 domain,
-		       struct sk_buff *buf,
-		       unsigned int dsz);
-
-int tipc_forward2name(u32 portref, 
-		      struct tipc_name const *name, 
-		      u32 domain,
-		      unsigned int section_count,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *origin,
-		      unsigned int importance);
-
-int tipc_forward_buf2name(u32 portref,
-			  struct tipc_name const *name,
-			  u32 domain,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance);
-
 int tipc_send2port(u32 portref,
 		   struct tipc_portid const *dest,
 		   unsigned int num_sect,
@@ -212,46 +176,11 @@ int tipc_send_buf2port(u32 portref,
 		       struct sk_buff *buf,
 		       unsigned int dsz);
 
-int tipc_forward2port(u32 portref,
-		      struct tipc_portid const *dest,
-		      unsigned int num_sect,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *origin,
-		      unsigned int importance);
-
-int tipc_forward_buf2port(u32 portref,
-			  struct tipc_portid const *dest,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance);
-
 int tipc_multicast(u32 portref, 
 		   struct tipc_name_seq const *seq, 
 		   u32 domain,	/* currently unused */
 		   unsigned int section_count,
 		   struct iovec const *msg);
-
-#if 0
-int tipc_multicast_buf(u32 portref, 
-		       struct tipc_name_seq const *seq, 
-		       u32 domain,
-		       void *buf,
-		       unsigned int size);
-#endif
-
-/*
- * TIPC subscription routines
- */
-
-int tipc_ispublished(struct tipc_name const *name);
-
-/*
- * Get number of available nodes within specified domain (excluding own node)
- */
-
-unsigned int tipc_available_nodes(const u32 domain);
-
 #endif
 
 #endif
--- a/net/tipc/bcast.c	2010-10-13 15:34:09.359325773 -0700
+++ b/net/tipc/bcast.c	2010-10-13 15:58:43.362005611 -0700
@@ -121,6 +121,9 @@ static DEFINE_SPINLOCK(bc_lock);
 
 const char tipc_bclink_name[] = "broadcast-link";
 
+static void tipc_nmap_diff(struct tipc_node_map *nm_a,
+			   struct tipc_node_map *nm_b,
+			   struct tipc_node_map *nm_diff);
 
 static u32 buf_seqno(struct sk_buff *buf)
 {
@@ -287,7 +290,7 @@ static void bclink_send_nack(struct tipc
 	if (!less(n_ptr->bclink.gap_after, n_ptr->bclink.gap_to))
 		return;
 
-	buf = buf_acquire(INT_H_SIZE);
+	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
 		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
@@ -871,8 +874,9 @@ void tipc_nmap_remove(struct tipc_node_m
  * @nm_diff: output node map A-B (i.e. nodes of A that are not in B)
  */
 
-void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
-				  struct tipc_node_map *nm_diff)
+static void tipc_nmap_diff(struct tipc_node_map *nm_a,
+			   struct tipc_node_map *nm_b,
+			   struct tipc_node_map *nm_diff)
 {
 	int stop = ARRAY_SIZE(nm_a->map);
 	int w;
--- a/net/tipc/bcast.h	2010-10-13 15:34:39.167747046 -0700
+++ b/net/tipc/bcast.h	2010-10-13 15:42:10.321560582 -0700
@@ -84,9 +84,6 @@ static inline int tipc_nmap_equal(struct
 	return !memcmp(nm_a, nm_b, sizeof(*nm_a));
 }
 
-void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
-				  struct tipc_node_map *nm_diff);
-
 void tipc_port_list_add(struct port_list *pl_ptr, u32 port);
 void tipc_port_list_free(struct port_list *pl_ptr);
 
--- a/net/tipc/cluster.c	2010-10-13 15:44:43.583143953 -0700
+++ b/net/tipc/cluster.c	2010-10-13 16:03:22.148331782 -0700
@@ -113,25 +113,6 @@ void tipc_cltr_delete(struct cluster *c_
 	kfree(c_ptr);
 }
 
-u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr)
-{
-	struct tipc_node *n_ptr;
-	u32 n_num = tipc_node(addr) + 1;
-
-	if (!c_ptr)
-		return addr;
-	for (; n_num <= c_ptr->highest_node; n_num++) {
-		n_ptr = c_ptr->nodes[n_num];
-		if (n_ptr && tipc_node_has_active_links(n_ptr))
-			return n_ptr->addr;
-	}
-	for (n_num = 1; n_num < tipc_node(addr); n_num++) {
-		n_ptr = c_ptr->nodes[n_num];
-		if (n_ptr && tipc_node_has_active_links(n_ptr))
-			return n_ptr->addr;
-	}
-	return 0;
-}
 
 void tipc_cltr_attach_node(struct cluster *c_ptr, struct tipc_node *n_ptr)
 {
@@ -232,7 +213,7 @@ struct tipc_node *tipc_cltr_select_node(
 static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest)
 {
 	u32 size = INT_H_SIZE + data_size;
-	struct sk_buff *buf = buf_acquire(size);
+	struct sk_buff *buf = tipc_buf_acquire(size);
 	struct tipc_msg *msg;
 
 	if (buf) {
--- a/net/tipc/config.c	2010-10-13 15:35:16.359281659 -0700
+++ b/net/tipc/config.c	2010-10-13 16:07:20.471544155 -0700
@@ -95,7 +95,7 @@ int tipc_cfg_append_tlv(struct sk_buff *
 	return 1;
 }
 
-struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
+static struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
 {
 	struct sk_buff *buf;
 	__be32 value_net;
@@ -109,6 +109,11 @@ struct sk_buff *tipc_cfg_reply_unsigned_
 	return buf;
 }
 
+static struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
+{
+	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
+}
+
 struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 {
 	struct sk_buff *buf;
--- a/net/tipc/config.h	2010-10-13 15:43:36.031261839 -0700
+++ b/net/tipc/config.h	2010-10-13 15:49:35.868009966 -0700
@@ -45,7 +45,6 @@
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
 int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
 			void *tlv_data, int tlv_data_size);
-struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value);
 struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string);
 
 static inline struct sk_buff *tipc_cfg_reply_none(void)
@@ -53,11 +52,6 @@ static inline struct sk_buff *tipc_cfg_r
 	return tipc_cfg_reply_alloc(0);
 }
 
-static inline struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
-{
-	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
-}
-
 static inline struct sk_buff *tipc_cfg_reply_error_string(char *string)
 {
 	return tipc_cfg_reply_string_type(TIPC_TLV_ERROR_STRING, string);
--- a/net/tipc/core.c	2010-10-13 15:32:35.750562985 -0700
+++ b/net/tipc/core.c	2010-10-13 16:00:58.197719377 -0700
@@ -96,13 +96,13 @@ int tipc_net_id;
 int tipc_remote_management;
 
 
-int tipc_get_mode(void)
+static int tipc_get_mode(void)
 {
 	return tipc_mode;
 }
 
 /**
- * buf_acquire - creates a TIPC message buffer
+ * tipc_buf_acquire - creates a TIPC message buffer
  * @size: message size (including TIPC header)
  *
  * Returns a new buffer with data pointers set to the specified size.
@@ -111,7 +111,7 @@ int tipc_get_mode(void)
  *       There may also be unrequested tailroom present at the buffer's end.
  */
 
-struct sk_buff *buf_acquire(u32 size)
+struct sk_buff *tipc_buf_acquire(u32 size)
 {
 	struct sk_buff *skb;
 	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
@@ -129,7 +129,7 @@ struct sk_buff *buf_acquire(u32 size)
  * tipc_core_stop_net - shut down TIPC networking sub-systems
  */
 
-void tipc_core_stop_net(void)
+static void tipc_core_stop_net(void)
 {
 	tipc_eth_media_stop();
 	tipc_net_stop();
@@ -154,7 +154,7 @@ int tipc_core_start_net(unsigned long ad
  * tipc_core_stop - switch TIPC from SINGLE NODE to NOT RUNNING mode
  */
 
-void tipc_core_stop(void)
+static void tipc_core_stop(void)
 {
 	if (tipc_mode != TIPC_NODE_MODE)
 		return;
@@ -176,7 +176,7 @@ void tipc_core_stop(void)
  * tipc_core_start - switch TIPC from NOT RUNNING to SINGLE NODE mode
  */
 
-int tipc_core_start(void)
+static int tipc_core_start(void)
 {
 	int res;
 
@@ -246,7 +246,6 @@ MODULE_VERSION(TIPC_MOD_VER);
 
 EXPORT_SYMBOL(tipc_attach);
 EXPORT_SYMBOL(tipc_detach);
-EXPORT_SYMBOL(tipc_get_addr);
 EXPORT_SYMBOL(tipc_get_mode);
 EXPORT_SYMBOL(tipc_createport);
 EXPORT_SYMBOL(tipc_deleteport);
@@ -262,23 +261,10 @@ EXPORT_SYMBOL(tipc_withdraw);
 EXPORT_SYMBOL(tipc_connect2port);
 EXPORT_SYMBOL(tipc_disconnect);
 EXPORT_SYMBOL(tipc_shutdown);
-EXPORT_SYMBOL(tipc_isconnected);
-EXPORT_SYMBOL(tipc_peer);
-EXPORT_SYMBOL(tipc_ref_valid);
 EXPORT_SYMBOL(tipc_send);
-EXPORT_SYMBOL(tipc_send_buf);
 EXPORT_SYMBOL(tipc_send2name);
-EXPORT_SYMBOL(tipc_forward2name);
-EXPORT_SYMBOL(tipc_send_buf2name);
-EXPORT_SYMBOL(tipc_forward_buf2name);
 EXPORT_SYMBOL(tipc_send2port);
-EXPORT_SYMBOL(tipc_forward2port);
-EXPORT_SYMBOL(tipc_send_buf2port);
-EXPORT_SYMBOL(tipc_forward_buf2port);
 EXPORT_SYMBOL(tipc_multicast);
-/* EXPORT_SYMBOL(tipc_multicast_buf); not available yet */
-EXPORT_SYMBOL(tipc_ispublished);
-EXPORT_SYMBOL(tipc_available_nodes);
 
 /* TIPC API for external bearers (see tipc_bearer.h) */
 
@@ -295,6 +281,4 @@ EXPORT_SYMBOL(tipc_createport_raw);
 EXPORT_SYMBOL(tipc_reject_msg);
 EXPORT_SYMBOL(tipc_send_buf_fast);
 EXPORT_SYMBOL(tipc_acknowledge);
-EXPORT_SYMBOL(tipc_get_port);
-EXPORT_SYMBOL(tipc_get_handle);
 
--- a/net/tipc/core.h	2010-10-13 15:36:36.237690119 -0700
+++ b/net/tipc/core.h	2010-10-13 16:07:56.727164658 -0700
@@ -83,9 +83,7 @@
  * Note: TIPC_LOG is configured to echo its output to the system console;
  *       user-defined buffers can be configured to do the same thing.
  */
-
 extern struct print_buf *const TIPC_NULL;
-extern struct print_buf *const TIPC_CONS;
 extern struct print_buf *const TIPC_LOG;
 
 void tipc_printf(struct print_buf *, const char *fmt, ...);
@@ -204,10 +202,7 @@ extern atomic_t tipc_user_count;
  * Routines available to privileged subsystems
  */
 
-extern int  tipc_core_start(void);
-extern void tipc_core_stop(void);
-extern int  tipc_core_start_net(unsigned long addr);
-extern void tipc_core_stop_net(void);
+extern int tipc_core_start_net(unsigned long);
 extern int  tipc_handler_start(void);
 extern void tipc_handler_stop(void);
 extern int  tipc_netlink_start(void);
@@ -328,7 +323,7 @@ static inline struct tipc_msg *buf_msg(s
 	return (struct tipc_msg *)skb->data;
 }
 
-extern struct sk_buff *buf_acquire(u32 size);
+extern struct sk_buff *tipc_buf_acquire(u32 size);
 
 /**
  * buf_discard - frees a TIPC message buffer
--- a/net/tipc/dbg.c	2010-10-13 15:35:34.049157629 -0700
+++ b/net/tipc/dbg.c	2010-10-13 15:58:43.362005611 -0700
@@ -52,7 +52,7 @@ static struct print_buf null_buf = { NUL
 struct print_buf *const TIPC_NULL = &null_buf;
 
 static struct print_buf cons_buf = { NULL, 0, NULL, 1 };
-struct print_buf *const TIPC_CONS = &cons_buf;
+static struct print_buf *const TIPC_CONS = &cons_buf;
 
 static struct print_buf log_buf = { NULL, 0, NULL, 1 };
 struct print_buf *const TIPC_LOG = &log_buf;
@@ -76,6 +76,10 @@ struct print_buf *const TIPC_LOG = &log_
 static char print_string[TIPC_PB_MAX_STR];
 static DEFINE_SPINLOCK(print_lock);
 
+static void tipc_printbuf_reset(struct print_buf *pb);
+static int  tipc_printbuf_empty(struct print_buf *pb);
+static void tipc_printbuf_move(struct print_buf *pb_to,
+			       struct print_buf *pb_from);
 
 #define FORMAT(PTR,LEN,FMT) \
 {\
@@ -116,7 +120,7 @@ void tipc_printbuf_init(struct print_buf
  * @pb: pointer to print buffer structure
  */
 
-void tipc_printbuf_reset(struct print_buf *pb)
+static void tipc_printbuf_reset(struct print_buf *pb)
 {
 	if (pb->buf) {
 		pb->crs = pb->buf;
@@ -132,7 +136,7 @@ void tipc_printbuf_reset(struct print_bu
  * Returns non-zero if print buffer is empty.
  */
 
-int tipc_printbuf_empty(struct print_buf *pb)
+static int tipc_printbuf_empty(struct print_buf *pb)
 {
 	return !pb->buf || (pb->crs == pb->buf);
 }
@@ -181,7 +185,8 @@ int tipc_printbuf_validate(struct print_
  * Source print buffer becomes empty if a successful move occurs.
  */
 
-void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from)
+static void tipc_printbuf_move(struct print_buf *pb_to,
+			       struct print_buf *pb_from)
 {
 	int len;
 
--- a/net/tipc/dbg.h	2010-10-13 15:37:37.134376966 -0700
+++ b/net/tipc/dbg.h	2010-10-13 15:42:09.489660536 -0700
@@ -56,10 +56,7 @@ struct print_buf {
 #define TIPC_PB_MAX_STR 512	/* max printable string (with trailing NUL) */
 
 void tipc_printbuf_init(struct print_buf *pb, char *buf, u32 size);
-void tipc_printbuf_reset(struct print_buf *pb);
-int  tipc_printbuf_empty(struct print_buf *pb);
 int  tipc_printbuf_validate(struct print_buf *pb);
-void tipc_printbuf_move(struct print_buf *pb_to, struct print_buf *pb_from);
 
 int tipc_log_resize(int log_size);
 
--- a/net/tipc/discover.c	2010-10-13 15:38:16.357666201 -0700
+++ b/net/tipc/discover.c	2010-10-13 15:52:14.740906596 -0700
@@ -68,20 +68,6 @@ struct link_req {
 	unsigned int timer_intv;
 };
 
-
-/*
- * disc_lost_link(): A link has lost contact
- */
-
-void tipc_disc_link_event(u32 addr, char *name, int up)
-{
-	if (in_own_cluster(addr))
-		return;
-	/*
-	 * Code for inter cluster link setup here
-	 */
-}
-
 /**
  * tipc_disc_init_msg - initialize a link setup message
  * @type: message type (request or response)
@@ -95,7 +81,7 @@ static struct sk_buff *tipc_disc_init_ms
 					  u32 dest_domain,
 					  struct bearer *b_ptr)
 {
-	struct sk_buff *buf = buf_acquire(DSC_H_SIZE);
+	struct sk_buff *buf = tipc_buf_acquire(DSC_H_SIZE);
 	struct tipc_msg *msg;
 
 	if (buf) {
--- a/net/tipc/discover.h	2010-10-13 15:47:41.609746110 -0700
+++ b/net/tipc/discover.h	2010-10-13 15:47:50.604664821 -0700
@@ -50,6 +50,4 @@ void tipc_disc_stop_link_req(struct link
 
 void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr);
 
-void tipc_disc_link_event(u32 addr, char *name, int up);
-
 #endif
--- a/net/tipc/link.c	2010-10-13 15:38:30.243998362 -0700
+++ b/net/tipc/link.c	2010-10-13 15:53:47.961684397 -0700
@@ -112,6 +112,9 @@ static void link_state_event(struct link
 static void link_reset_statistics(struct link *l_ptr);
 static void link_print(struct link *l_ptr, struct print_buf *buf,
 		       const char *str);
+static void link_start(struct link *l_ptr);
+static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf);
+
 
 /*
  * Debugging code used by link routines only
@@ -442,7 +445,7 @@ struct link *tipc_link_create(struct bea
 
 	k_init_timer(&l_ptr->timer, (Handler)link_timeout, (unsigned long)l_ptr);
 	list_add_tail(&l_ptr->link_list, &b_ptr->links);
-	tipc_k_signal((Handler)tipc_link_start, (unsigned long)l_ptr);
+	tipc_k_signal((Handler)link_start, (unsigned long)l_ptr);
 
 	dbg("tipc_link_create(): tolerance = %u,cont intv = %u, abort_limit = %u\n",
 	    l_ptr->tolerance, l_ptr->continuity_interval, l_ptr->abort_limit);
@@ -482,9 +485,9 @@ void tipc_link_delete(struct link *l_ptr
 	kfree(l_ptr);
 }
 
-void tipc_link_start(struct link *l_ptr)
+static void link_start(struct link *l_ptr)
 {
-	dbg("tipc_link_start %x\n", l_ptr);
+	dbg("link_start %x\n", l_ptr);
 	link_state_event(l_ptr, STARTING_EVT);
 }
 
@@ -1000,7 +1003,7 @@ int tipc_link_send_buf(struct link *l_pt
 	/* Fragmentation needed ? */
 
 	if (size > max_packet)
-		return tipc_link_send_long_buf(l_ptr, buf);
+		return link_send_long_buf(l_ptr, buf);
 
 	/* Packet can be queued or sent: */
 
@@ -1036,7 +1039,7 @@ int tipc_link_send_buf(struct link *l_pt
 		/* Try creating a new bundle */
 
 		if (size <= max_packet * 2 / 3) {
-			struct sk_buff *bundler = buf_acquire(max_packet);
+			struct sk_buff *bundler = tipc_buf_acquire(max_packet);
 			struct tipc_msg bundler_hdr;
 
 			if (bundler) {
@@ -1312,7 +1315,7 @@ again:
 
 	/* Prepare header of first fragment: */
 
-	buf_chain = buf = buf_acquire(max_pkt);
+	buf_chain = buf = tipc_buf_acquire(max_pkt);
 	if (!buf)
 		return -ENOMEM;
 	buf->next = NULL;
@@ -1369,7 +1372,7 @@ error:
 			msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
 			msg_set_fragm_no(&fragm_hdr, ++fragm_no);
 			prev = buf;
-			buf = buf_acquire(fragm_sz + INT_H_SIZE);
+			buf = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
 			if (!buf)
 				goto error;
 
@@ -2145,7 +2148,7 @@ void tipc_link_send_proto_msg(struct lin
 	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
 		if (!l_ptr->proto_msg_queue) {
 			l_ptr->proto_msg_queue =
-				buf_acquire(sizeof(l_ptr->proto_msg));
+				tipc_buf_acquire(sizeof(l_ptr->proto_msg));
 		}
 		buf = l_ptr->proto_msg_queue;
 		if (!buf)
@@ -2159,7 +2162,7 @@ void tipc_link_send_proto_msg(struct lin
 
 	msg_dbg(msg, ">>");
 
-	buf = buf_acquire(msg_size);
+	buf = tipc_buf_acquire(msg_size);
 	if (!buf)
 		return;
 
@@ -2318,10 +2321,10 @@ exit:
  * tipc_link_tunnel(): Send one message via a link belonging to
  * another bearer. Owner node is locked.
  */
-void tipc_link_tunnel(struct link *l_ptr,
-		      struct tipc_msg *tunnel_hdr,
-		      struct tipc_msg  *msg,
-		      u32 selector)
+static void tipc_link_tunnel(struct link *l_ptr,
+			     struct tipc_msg *tunnel_hdr,
+			     struct tipc_msg  *msg,
+			     u32 selector)
 {
 	struct link *tunnel;
 	struct sk_buff *buf;
@@ -2334,7 +2337,7 @@ void tipc_link_tunnel(struct link *l_ptr
 		return;
 	}
 	msg_set_size(tunnel_hdr, length + INT_H_SIZE);
-	buf = buf_acquire(length + INT_H_SIZE);
+	buf = tipc_buf_acquire(length + INT_H_SIZE);
 	if (!buf) {
 		warn("Link changeover error, "
 		     "unable to send tunnel msg\n");
@@ -2380,7 +2383,7 @@ void tipc_link_changeover(struct link *l
 	if (!l_ptr->first_out) {
 		struct sk_buff *buf;
 
-		buf = buf_acquire(INT_H_SIZE);
+		buf = tipc_buf_acquire(INT_H_SIZE);
 		if (buf) {
 			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
@@ -2441,7 +2444,7 @@ void tipc_link_send_duplicate(struct lin
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));	/* Update */
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 		msg_set_size(&tunnel_hdr, length + INT_H_SIZE);
-		outbuf = buf_acquire(length + INT_H_SIZE);
+		outbuf = tipc_buf_acquire(length + INT_H_SIZE);
 		if (outbuf == NULL) {
 			warn("Link changeover error, "
 			     "unable to send duplicate msg\n");
@@ -2477,7 +2480,7 @@ static struct sk_buff *buf_extract(struc
 	u32 size = msg_size(msg);
 	struct sk_buff *eb;
 
-	eb = buf_acquire(size);
+	eb = tipc_buf_acquire(size);
 	if (eb)
 		skb_copy_to_linear_data(eb, msg, size);
 	return eb;
@@ -2605,11 +2608,11 @@ void tipc_link_recv_bundle(struct sk_buf
 
 
 /*
- * tipc_link_send_long_buf: Entry for buffers needing fragmentation.
+ * link_send_long_buf: Entry for buffers needing fragmentation.
  * The buffer is complete, inclusive total message length.
  * Returns user data length.
  */
-int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
+static int link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 {
 	struct tipc_msg *inmsg = buf_msg(buf);
 	struct tipc_msg fragm_hdr;
@@ -2648,7 +2651,7 @@ int tipc_link_send_long_buf(struct link 
 			fragm_sz = rest;
 			msg_set_type(&fragm_hdr, LAST_FRAGMENT);
 		}
-		fragm = buf_acquire(fragm_sz + INT_H_SIZE);
+		fragm = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
 		if (fragm == NULL) {
 			warn("Link unable to fragment message\n");
 			dsz = -ENOMEM;
@@ -2753,7 +2756,7 @@ int tipc_link_recv_fragment(struct sk_bu
 			buf_discard(fbuf);
 			return 0;
 		}
-		pbuf = buf_acquire(msg_size(imsg));
+		pbuf = tipc_buf_acquire(msg_size(imsg));
 		if (pbuf != NULL) {
 			pbuf->next = *pending;
 			*pending = pbuf;
--- a/net/tipc/link.h	2010-10-13 15:51:49.403953468 -0700
+++ b/net/tipc/link.h	2010-10-13 15:52:06.877852172 -0700
@@ -225,7 +225,6 @@ void tipc_link_send_duplicate(struct lin
 void tipc_link_reset_fragments(struct link *l_ptr);
 int tipc_link_is_up(struct link *l_ptr);
 int tipc_link_is_active(struct link *l_ptr);
-void tipc_link_start(struct link *l_ptr);
 u32 tipc_link_push_packet(struct link *l_ptr);
 void tipc_link_stop(struct link *l_ptr);
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space, u16 cmd);
@@ -239,9 +238,6 @@ int tipc_link_send_sections_fast(struct 
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
 				 u32 destnode);
-int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf);
-void tipc_link_tunnel(struct link *l_ptr, struct tipc_msg *tnl_hdr,
-		      struct tipc_msg *msg, u32 selector);
 void tipc_link_recv_bundle(struct sk_buff *buf);
 int  tipc_link_recv_fragment(struct sk_buff **pending,
 			     struct sk_buff **fb,
--- a/net/tipc/msg.c	2010-10-13 15:45:42.760031835 -0700
+++ b/net/tipc/msg.c	2010-10-13 15:45:52.410871897 -0700
@@ -112,7 +112,7 @@ int tipc_msg_build(struct tipc_msg *hdr,
 		return dsz;
 	}
 
-	*buf = buf_acquire(sz);
+	*buf = tipc_buf_acquire(sz);
 	if (!(*buf))
 		return -ENOMEM;
 	skb_copy_to_linear_data(*buf, hdr, hsz);
--- a/net/tipc/name_distr.c	2010-10-13 15:45:56.098428684 -0700
+++ b/net/tipc/name_distr.c	2010-10-13 15:46:05.505298048 -0700
@@ -98,7 +98,7 @@ static void publ_to_item(struct distr_it
 
 static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 {
-	struct sk_buff *buf = buf_acquire(LONG_H_SIZE + size);
+	struct sk_buff *buf = tipc_buf_acquire(LONG_H_SIZE + size);
 	struct tipc_msg *msg;
 
 	if (buf != NULL) {
--- a/net/tipc/node.c	2010-10-13 15:39:25.165401568 -0700
+++ b/net/tipc/node.c	2010-10-13 16:03:21.564402314 -0700
@@ -50,7 +50,8 @@ void node_print(struct print_buf *buf, s
 static void node_lost_contact(struct tipc_node *n_ptr);
 static void node_established_contact(struct tipc_node *n_ptr);
 
-struct tipc_node *tipc_nodes = NULL;	/* sorted list of nodes within cluster */
+/* sorted list of nodes within cluster */
+static struct tipc_node *tipc_nodes = NULL;
 
 static DEFINE_SPINLOCK(node_create_lock);
 
@@ -587,22 +588,6 @@ void tipc_node_remove_router(struct tipc
 		node_lost_contact(n_ptr);
 }
 
-u32 tipc_available_nodes(const u32 domain)
-{
-	struct tipc_node *n_ptr;
-	u32 cnt = 0;
-
-	read_lock_bh(&tipc_net_lock);
-	for (n_ptr = tipc_nodes; n_ptr; n_ptr = n_ptr->next) {
-		if (!tipc_in_scope(domain, n_ptr->addr))
-			continue;
-		if (tipc_node_is_up(n_ptr))
-			cnt++;
-	}
-	read_unlock_bh(&tipc_net_lock);
-	return cnt;
-}
-
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
 {
 	u32 domain;
--- a/net/tipc/node.h	2010-10-13 15:54:01.616035253 -0700
+++ b/net/tipc/node.h	2010-10-13 15:54:11.830801530 -0700
@@ -96,7 +96,6 @@ struct tipc_node {
 	} bclink;
 };
 
-extern struct tipc_node *tipc_nodes;
 extern u32 tipc_own_tag;
 
 struct tipc_node *tipc_node_create(u32 addr);
--- a/net/tipc/port.c	2010-10-13 15:40:52.362926772 -0700
+++ b/net/tipc/port.c	2010-10-13 16:16:41.435779874 -0700
@@ -293,34 +293,6 @@ int tipc_deleteport(u32 ref)
 	return 0;
 }
 
-/**
- * tipc_get_port() - return port associated with 'ref'
- *
- * Note: Port is not locked.
- */
-
-struct tipc_port *tipc_get_port(const u32 ref)
-{
-	return (struct tipc_port *)tipc_ref_deref(ref);
-}
-
-/**
- * tipc_get_handle - return user handle associated to port 'ref'
- */
-
-void *tipc_get_handle(const u32 ref)
-{
-	struct port *p_ptr;
-	void * handle;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return NULL;
-	handle = p_ptr->publ.usr_handle;
-	tipc_port_unlock(p_ptr);
-	return handle;
-}
-
 static int port_unreliable(struct port *p_ptr)
 {
 	return msg_src_droppable(&p_ptr->publ.phdr);
@@ -392,7 +364,7 @@ static struct sk_buff *port_build_proto_
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 
-	buf = buf_acquire(LONG_H_SIZE);
+	buf = tipc_buf_acquire(LONG_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
 		tipc_msg_init(msg, usr, type, LONG_H_SIZE, destnode);
@@ -433,7 +405,7 @@ int tipc_reject_msg(struct sk_buff *buf,
 		hdr_sz = MCAST_H_SIZE;
 	else
 		hdr_sz = LONG_H_SIZE;
-	rbuf = buf_acquire(data_sz + hdr_sz);
+	rbuf = tipc_buf_acquire(data_sz + hdr_sz);
 	if (rbuf == NULL) {
 		buf_discard(buf);
 		return data_sz;
@@ -1242,50 +1214,13 @@ int tipc_shutdown(u32 ref)
 	return tipc_disconnect(ref);
 }
 
-int tipc_isconnected(u32 ref, int *isconnected)
-{
-	struct port *p_ptr;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return -EINVAL;
-	*isconnected = p_ptr->publ.connected;
-	tipc_port_unlock(p_ptr);
-	return 0;
-}
-
-int tipc_peer(u32 ref, struct tipc_portid *peer)
-{
-	struct port *p_ptr;
-	int res;
-
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr)
-		return -EINVAL;
-	if (p_ptr->publ.connected) {
-		peer->ref = port_peerport(p_ptr);
-		peer->node = port_peernode(p_ptr);
-		res = 0;
-	} else
-		res = -ENOTCONN;
-	tipc_port_unlock(p_ptr);
-	return res;
-}
-
-int tipc_ref_valid(u32 ref)
-{
-	/* Works irrespective of type */
-	return !!tipc_ref_deref(ref);
-}
-
-
 /*
  *  tipc_port_recv_sections(): Concatenate and deliver sectioned
  *                        message for this node.
  */
 
-int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
-		       struct iovec const *msg_sect)
+static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
+				   struct iovec const *msg_sect)
 {
 	struct sk_buff *buf;
 	int res;
@@ -1336,65 +1271,16 @@ int tipc_send(u32 ref, unsigned int num_
 }
 
 /**
- * tipc_send_buf - send message buffer on connection
- */
-
-int tipc_send_buf(u32 ref, struct sk_buff *buf, unsigned int dsz)
-{
-	struct port *p_ptr;
-	struct tipc_msg *msg;
-	u32 destnode;
-	u32 hsz;
-	u32 sz;
-	u32 res;
-
-	p_ptr = tipc_port_deref(ref);
-	if (!p_ptr || !p_ptr->publ.connected)
-		return -EINVAL;
-
-	msg = &p_ptr->publ.phdr;
-	hsz = msg_hdr_sz(msg);
-	sz = hsz + dsz;
-	msg_set_size(msg, sz);
-	if (skb_cow(buf, hsz))
-		return -ENOMEM;
-
-	skb_push(buf, hsz);
-	skb_copy_to_linear_data(buf, msg, hsz);
-	destnode = msg_destnode(msg);
-	p_ptr->publ.congested = 1;
-	if (!tipc_port_congested(p_ptr)) {
-		if (likely(destnode != tipc_own_addr))
-			res = tipc_send_buf_fast(buf, destnode);
-		else {
-			tipc_port_recv_msg(buf);
-			res = sz;
-		}
-		if (likely(res != -ELINKCONG)) {
-			port_incr_out_seqno(p_ptr);
-			p_ptr->sent++;
-			p_ptr->publ.congested = 0;
-			return res;
-		}
-	}
-	if (port_unreliable(p_ptr)) {
-		p_ptr->publ.congested = 0;
-		return dsz;
-	}
-	return -ELINKCONG;
-}
-
-/**
  * tipc_forward2name - forward message sections to port name
  */
 
-int tipc_forward2name(u32 ref,
-		      struct tipc_name const *name,
-		      u32 domain,
-		      u32 num_sect,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *orig,
-		      unsigned int importance)
+static int tipc_forward2name(u32 ref,
+			     struct tipc_name const *name,
+			     u32 domain,
+			     u32 num_sect,
+			     struct iovec const *msg_sect,
+			     struct tipc_portid const *orig,
+			     unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1457,89 +1343,15 @@ int tipc_send2name(u32 ref,
 }
 
 /**
- * tipc_forward_buf2name - forward message buffer to port name
- */
-
-int tipc_forward_buf2name(u32 ref,
-			  struct tipc_name const *name,
-			  u32 domain,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance)
-{
-	struct port *p_ptr;
-	struct tipc_msg *msg;
-	u32 destnode = domain;
-	u32 destport;
-	int res;
-
-	p_ptr = (struct port *)tipc_ref_deref(ref);
-	if (!p_ptr || p_ptr->publ.connected)
-		return -EINVAL;
-
-	msg = &p_ptr->publ.phdr;
-	if (importance <= TIPC_CRITICAL_IMPORTANCE)
-		msg_set_importance(msg, importance);
-	msg_set_type(msg, TIPC_NAMED_MSG);
-	msg_set_orignode(msg, orig->node);
-	msg_set_origport(msg, orig->ref);
-	msg_set_nametype(msg, name->type);
-	msg_set_nameinst(msg, name->instance);
-	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
-	msg_set_hdr_sz(msg, LONG_H_SIZE);
-	msg_set_size(msg, LONG_H_SIZE + dsz);
-	destport = tipc_nametbl_translate(name->type, name->instance, &destnode);
-	msg_set_destnode(msg, destnode);
-	msg_set_destport(msg, destport);
-	msg_dbg(msg, "forw2name ==> ");
-	if (skb_cow(buf, LONG_H_SIZE))
-		return -ENOMEM;
-	skb_push(buf, LONG_H_SIZE);
-	skb_copy_to_linear_data(buf, msg, LONG_H_SIZE);
-	msg_dbg(buf_msg(buf),"PREP:");
-	if (likely(destport)) {
-		p_ptr->sent++;
-		if (destnode == tipc_own_addr)
-			return tipc_port_recv_msg(buf);
-		res = tipc_send_buf_fast(buf, destnode);
-		if (likely(res != -ELINKCONG))
-			return res;
-		if (port_unreliable(p_ptr))
-			return dsz;
-		return -ELINKCONG;
-	}
-	return tipc_reject_msg(buf, TIPC_ERR_NO_NAME);
-}
-
-/**
- * tipc_send_buf2name - send message buffer to port name
- */
-
-int tipc_send_buf2name(u32 ref,
-		       struct tipc_name const *dest,
-		       u32 domain,
-		       struct sk_buff *buf,
-		       unsigned int dsz)
-{
-	struct tipc_portid orig;
-
-	orig.ref = ref;
-	orig.node = tipc_own_addr;
-	return tipc_forward_buf2name(ref, dest, domain, buf, dsz, &orig,
-				     TIPC_PORT_IMPORTANCE);
-}
-
-/**
  * tipc_forward2port - forward message sections to port identity
  */
 
-int tipc_forward2port(u32 ref,
-		      struct tipc_portid const *dest,
-		      unsigned int num_sect,
-		      struct iovec const *msg_sect,
-		      struct tipc_portid const *orig,
-		      unsigned int importance)
+static int tipc_forward2port(u32 ref,
+			     struct tipc_portid const *dest,
+			     unsigned int num_sect,
+			     struct iovec const *msg_sect,
+			     struct tipc_portid const *orig,
+			     unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -1591,12 +1403,12 @@ int tipc_send2port(u32 ref,
 /**
  * tipc_forward_buf2port - forward message buffer to port identity
  */
-int tipc_forward_buf2port(u32 ref,
-			  struct tipc_portid const *dest,
-			  struct sk_buff *buf,
-			  unsigned int dsz,
-			  struct tipc_portid const *orig,
-			  unsigned int importance)
+static int tipc_forward_buf2port(u32 ref,
+				 struct tipc_portid const *dest,
+				 struct sk_buff *buf,
+				 unsigned int dsz,
+				 struct tipc_portid const *orig,
+				 unsigned int importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
--- a/net/tipc/port.h	2010-10-13 15:48:09.502393058 -0700
+++ b/net/tipc/port.h	2010-10-13 16:14:00.819182858 -0700
@@ -109,8 +109,6 @@ struct port {
 extern spinlock_t tipc_port_list_lock;
 struct port_list;
 
-int tipc_port_recv_sections(struct port *p_ptr, u32 num_sect,
-			    struct iovec const *msg_sect);
 int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err);
--- a/net/tipc/ref.c	2010-10-13 15:41:13.468391212 -0700
+++ b/net/tipc/ref.c	2010-10-13 16:03:20.908481542 -0700
@@ -282,23 +282,6 @@ void *tipc_ref_lock(u32 ref)
 	return NULL;
 }
 
-/**
- * tipc_ref_unlock - unlock referenced object
- */
-
-void tipc_ref_unlock(u32 ref)
-{
-	if (likely(tipc_ref_table.entries)) {
-		struct reference *entry;
-
-		entry = &tipc_ref_table.entries[ref &
-						tipc_ref_table.index_mask];
-		if (likely((entry->ref == ref) && (entry->object)))
-			spin_unlock_bh(&entry->lock);
-		else
-			err("Attempt to unlock non-existent reference\n");
-	}
-}
 
 /**
  * tipc_ref_deref - return pointer referenced object (without locking it)
--- a/net/tipc/ref.h	2010-10-13 15:47:56.028012866 -0700
+++ b/net/tipc/ref.h	2010-10-13 15:48:04.642977233 -0700
@@ -44,7 +44,6 @@ u32 tipc_ref_acquire(void *object, spinl
 void tipc_ref_discard(u32 ref);
 
 void *tipc_ref_lock(u32 ref);
-void tipc_ref_unlock(u32 ref);
 void *tipc_ref_deref(u32 ref);
 
 #endif
--- a/net/tipc/zone.c	2010-10-13 15:41:49.324083397 -0700
+++ b/net/tipc/zone.c	2010-10-13 15:54:26.329050453 -0700
@@ -160,14 +160,3 @@ u32 tipc_zone_select_router(struct _zone
 	}
 	return 0;
 }
-
-
-u32 tipc_zone_next_node(u32 addr)
-{
-	struct cluster *c_ptr = tipc_cltr_find(addr);
-
-	if (c_ptr)
-		return tipc_cltr_next_node(c_ptr, addr);
-	return 0;
-}
-
--- a/net/tipc/zone.h	2010-10-13 15:48:24.460594837 -0700
+++ b/net/tipc/zone.h	2010-10-13 15:48:33.715482229 -0700
@@ -61,7 +61,6 @@ void tipc_zone_send_external_routes(stru
 struct _zone *tipc_zone_create(u32 addr);
 void tipc_zone_delete(struct _zone *z_ptr);
 void tipc_zone_attach_cluster(struct _zone *z_ptr, struct cluster *c_ptr);
-u32 tipc_zone_next_node(u32 addr);
 
 static inline struct _zone *tipc_zone_find(u32 addr)
 {
--- a/net/tipc/addr.c	2010-10-13 15:33:41.742641197 -0700
+++ b/net/tipc/addr.c	2010-10-13 16:02:50.348172914 -0700
@@ -41,11 +41,6 @@
 #include "cluster.h"
 #include "net.h"
 
-u32 tipc_get_addr(void)
-{
-	return tipc_own_addr;
-}
-
 /**
  * tipc_addr_domain_valid - validates a network domain address
  *
--- a/net/tipc/cluster.h	2010-10-13 16:01:44.276153671 -0700
+++ b/net/tipc/cluster.h	2010-10-13 16:01:56.218711152 -0700
@@ -75,7 +75,7 @@ void tipc_cltr_attach_node(struct cluste
 void tipc_cltr_send_slave_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_broadcast(struct sk_buff *buf);
 int tipc_cltr_init(void);
-u32 tipc_cltr_next_node(struct cluster *c_ptr, u32 addr);
+
 void tipc_cltr_bcast_new_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
 void tipc_cltr_send_local_routes(struct cluster *c_ptr, u32 dest);
 void tipc_cltr_bcast_lost_route(struct cluster *c_ptr, u32 dest, u32 lo, u32 hi);
--- a/net/tipc/subscr.c	2010-10-13 16:01:08.020532905 -0700
+++ b/net/tipc/subscr.c	2010-10-13 16:03:03.330604772 -0700
@@ -598,12 +598,3 @@ void tipc_subscr_stop(void)
 		topsrv.user_ref = 0;
 	}
 }
-
-
-int tipc_ispublished(struct tipc_name const *name)
-{
-	u32 domain = 0;
-
-	return tipc_nametbl_translate(name->type, name->instance, &domain) != 0;
-}
-
--- a/include/net/tipc/tipc_port.h	2010-10-13 16:05:35.080274751 -0700
+++ b/include/net/tipc/tipc_port.h	2010-10-13 16:06:14.247543618 -0700
@@ -88,8 +88,6 @@ void tipc_acknowledge(u32 port_ref,u32 a
 
 struct tipc_port *tipc_get_port(const u32 ref);
 
-void *tipc_get_handle(const u32 ref);
-
 /*
  * The following routines require that the port be locked on entry
  */


