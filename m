From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 11/17] tipc: use registry when
	scanning sockets
Date: Fri, 22 Aug 2014 18:09:14 -0400
Message-ID: <1408745360-23560-12-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The functions tipc_port_get_ports() and tipc_port_reinit() scan over
all sockets/ports to access each of them. This is done by using a
dedicated linked list, 'tipc_socks' where all sockets are members. The
list is in turn protected by a spinlock, 'port_list_lock', while each
socket is locked by using port_lock at the moment of access.

In order to reduce complexity and risk of deadlock, we want to get
rid of the linked list and the accompanying spinlock.

This is what we do in this commit. Instead of the linked list, we use
the port registry to scan across the sockets. We also add usage of
bh_lock_sock() inside the scope of port_lock in both functions, as a
preparation for the complete removal of port_lock.

Finally, we move the functions from port.c to socket.c, and rename them
to tipc_sk_sock_show() and tipc_sk_reinit() repectively.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/config.c |    4 +-
 net/tipc/net.c    |    2 +-
 net/tipc/port.c   |   87 ---------------------------------------
 net/tipc/port.h   |    5 ---
 net/tipc/ref.c    |   20 +++++++++
 net/tipc/ref.h    |    1 +
 net/tipc/socket.c |  118 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/tipc/socket.h |    3 +-
 8 files changed, 133 insertions(+), 107 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 2b42403..876f4c6 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -35,7 +35,7 @@
  */
 
 #include "core.h"
-#include "port.h"
+#include "socket.h"
 #include "name_table.h"
 #include "config.h"
 #include "server.h"
@@ -266,7 +266,7 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		rep_tlv_buf = tipc_media_get_names();
 		break;
 	case TIPC_CMD_SHOW_PORTS:
-		rep_tlv_buf = tipc_port_get_ports();
+		rep_tlv_buf = tipc_sk_socks_show();
 		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7fcc949..421dd89 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -111,7 +111,7 @@ int tipc_net_start(u32 addr)
 
 	tipc_own_addr = addr;
 	tipc_named_reinit();
-	tipc_port_reinit();
+	tipc_sk_reinit();
 	res = tipc_bclink_init();
 	if (res)
 		return res;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 1efa298..cea3730 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -63,93 +63,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
 		(!peernode && (orignode == tipc_own_addr));
 }
 
-static int port_print(struct tipc_port *p_ptr, char *buf, int len, int full_id)
-{
-	struct publication *publ;
-	int ret;
-
-	if (full_id)
-		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
-				    tipc_zone(tipc_own_addr),
-				    tipc_cluster(tipc_own_addr),
-				    tipc_node(tipc_own_addr), p_ptr->ref);
-	else
-		ret = tipc_snprintf(buf, len, "%-10u:", p_ptr->ref);
-
-	if (p_ptr->connected) {
-		u32 dport = tipc_port_peerport(p_ptr);
-		u32 destnode = tipc_port_peernode(p_ptr);
-
-		ret += tipc_snprintf(buf + ret, len - ret,
-				     " connected to <%u.%u.%u:%u>",
-				     tipc_zone(destnode),
-				     tipc_cluster(destnode),
-				     tipc_node(destnode), dport);
-		if (p_ptr->conn_type != 0)
-			ret += tipc_snprintf(buf + ret, len - ret,
-					     " via {%u,%u}", p_ptr->conn_type,
-					     p_ptr->conn_instance);
-	} else if (p_ptr->published) {
-		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
-		list_for_each_entry(publ, &p_ptr->publications, pport_list) {
-			if (publ->lower == publ->upper)
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u}", publ->type,
-						     publ->lower);
-			else
-				ret += tipc_snprintf(buf + ret, len - ret,
-						     " {%u,%u,%u}", publ->type,
-						     publ->lower, publ->upper);
-		}
-	}
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-struct sk_buff *tipc_port_get_ports(void)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	struct tipc_port *p_ptr;
-	int str_len = 0;
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-
-	spin_lock_bh(&tipc_port_list_lock);
-	list_for_each_entry(p_ptr, &tipc_socks, port_list) {
-		spin_lock_bh(p_ptr->lock);
-		str_len += port_print(p_ptr, pb, pb_len, 0);
-		spin_unlock_bh(p_ptr->lock);
-	}
-	spin_unlock_bh(&tipc_port_list_lock);
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
-void tipc_port_reinit(void)
-{
-	struct tipc_port *p_ptr;
-	struct tipc_msg *msg;
-
-	spin_lock_bh(&tipc_port_list_lock);
-	list_for_each_entry(p_ptr, &tipc_socks, port_list) {
-		msg = &p_ptr->phdr;
-		msg_set_prevnode(msg, tipc_own_addr);
-		msg_set_orignode(msg, tipc_own_addr);
-	}
-	spin_unlock_bh(&tipc_port_list_lock);
-}
-
 int tipc_publish(struct tipc_port *p_ptr, unsigned int scope,
 		 struct tipc_name_seq const *seq)
 {
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 4c6cfdd..4a3c54e 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -73,7 +73,6 @@ struct tipc_port {
 	u32 max_pkt;
 	u32 ref;
 	struct tipc_msg phdr;
-	struct list_head port_list;
 	struct list_head publications;
 	u32 pub_count;
 	u32 probing_state;
@@ -81,9 +80,6 @@ struct tipc_port {
 	struct timer_list timer;
 };
 
-extern struct list_head tipc_socks;
-extern spinlock_t tipc_port_list_lock;
-
 /*
  * TIPC port manipulation routines
  */
@@ -100,7 +96,6 @@ int tipc_withdraw(struct tipc_port *p_ptr, unsigned int scope,
 
 int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 
-struct sk_buff *tipc_port_get_ports(void);
 void tipc_port_reinit(void);
 
 /**
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 3d4ecd7..7fc2740 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -264,3 +264,23 @@ void *tipc_ref_lock(u32 ref)
 	}
 	return NULL;
 }
+
+/* tipc_ref_lock_next - lock & return next object after referenced one
+*/
+void *tipc_ref_lock_next(u32 *ref)
+{
+	struct reference *entry;
+	uint index = *ref & tipc_ref_table.index_mask;
+
+	while (++index < tipc_ref_table.capacity) {
+		entry = &tipc_ref_table.entries[index];
+		if (!entry->object)
+			continue;
+		spin_lock_bh(&entry->lock);
+		*ref = entry->ref;
+		if (entry->object)
+			return entry->object;
+		spin_unlock_bh(&entry->lock);
+	}
+	return NULL;
+}
diff --git a/net/tipc/ref.h b/net/tipc/ref.h
index d01aa1d..e236fa5 100644
--- a/net/tipc/ref.h
+++ b/net/tipc/ref.h
@@ -44,5 +44,6 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock);
 void tipc_ref_discard(u32 ref);
 
 void *tipc_ref_lock(u32 ref);
+void *tipc_ref_lock_next(u32 *ref);
 
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index f2be4c2..ddc2f8c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -40,6 +40,7 @@
 #include "node.h"
 #include "link.h"
 #include <linux/export.h>
+#include "config.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
@@ -63,9 +64,6 @@ static const struct proto_ops msg_ops;
 static struct proto tipc_proto;
 static struct proto tipc_proto_kern;
 
-DEFINE_SPINLOCK(tipc_port_list_lock);
-LIST_HEAD(tipc_socks);
-
 /*
  * Revised TIPC socket locking policy:
  *
@@ -113,6 +111,17 @@ LIST_HEAD(tipc_socks);
 
 #include "socket.h"
 
+/* tipc_sk_lock_next: find & lock next socket in registry from given port number
+*/
+static struct tipc_sock *tipc_sk_lock_next(u32 *ref)
+{
+	struct tipc_port *port = (struct tipc_port *)tipc_ref_lock_next(ref);
+
+	if (!port)
+		return NULL;
+	return tipc_port_to_sock(port);
+}
+
 /**
  * advance_rx_queue - discard first buffer in socket receive queue
  *
@@ -203,16 +212,11 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	port->max_pkt = MAX_PKT_DEFAULT;
 	port->ref = ref;
 	INIT_LIST_HEAD(&port->publications);
-	INIT_LIST_HEAD(&port->port_list);
 
-	/* Guard against race during node address update */
-	spin_lock_bh(&tipc_port_list_lock);
 	msg = &port->phdr;
 	tipc_msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
 		      NAMED_H_SIZE, 0);
 	msg_set_origport(msg, ref);
-	list_add_tail(&port->port_list, &tipc_socks);
-	spin_unlock_bh(&tipc_port_list_lock);
 
 	/* Finish initializing socket data structures */
 	sock->ops = ops;
@@ -377,9 +381,6 @@ static int tipc_release(struct socket *sock)
 			tipc_link_xmit(buf, dnode, port->ref);
 		tipc_node_remove_conn(dnode, port->ref);
 	}
-	spin_lock_bh(&tipc_port_list_lock);
-	list_del(&port->port_list);
-	spin_unlock_bh(&tipc_port_list_lock);
 	k_term_timer(&port->timer);
 
 	/* Discard any remaining (connection-based) messages in receive queue */
@@ -2043,6 +2044,101 @@ static void tipc_sk_timeout(unsigned long ref)
 	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
 }
 
+static int tipc_sk_show(struct tipc_port *port, char *buf,
+			int len, int full_id)
+{
+	struct publication *publ;
+	int ret;
+
+	if (full_id)
+		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
+				    tipc_zone(tipc_own_addr),
+				    tipc_cluster(tipc_own_addr),
+				    tipc_node(tipc_own_addr), port->ref);
+	else
+		ret = tipc_snprintf(buf, len, "%-10u:", port->ref);
+
+	if (port->connected) {
+		u32 dport = tipc_port_peerport(port);
+		u32 destnode = tipc_port_peernode(port);
+
+		ret += tipc_snprintf(buf + ret, len - ret,
+				     " connected to <%u.%u.%u:%u>",
+				     tipc_zone(destnode),
+				     tipc_cluster(destnode),
+				     tipc_node(destnode), dport);
+		if (port->conn_type != 0)
+			ret += tipc_snprintf(buf + ret, len - ret,
+					     " via {%u,%u}", port->conn_type,
+					     port->conn_instance);
+	} else if (port->published) {
+		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
+		list_for_each_entry(publ, &port->publications, pport_list) {
+			if (publ->lower == publ->upper)
+				ret += tipc_snprintf(buf + ret, len - ret,
+						     " {%u,%u}", publ->type,
+						     publ->lower);
+			else
+				ret += tipc_snprintf(buf + ret, len - ret,
+						     " {%u,%u,%u}", publ->type,
+						     publ->lower, publ->upper);
+		}
+	}
+	ret += tipc_snprintf(buf + ret, len - ret, "\n");
+	return ret;
+}
+
+struct sk_buff *tipc_sk_socks_show(void)
+{
+	struct sk_buff *buf;
+	struct tlv_desc *rep_tlv;
+	char *pb;
+	int pb_len;
+	struct tipc_sock *tsk;
+	int str_len = 0;
+	u32 ref = 0;
+
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
+	if (!buf)
+		return NULL;
+	rep_tlv = (struct tlv_desc *)buf->data;
+	pb = TLV_DATA(rep_tlv);
+	pb_len = ULTRA_STRING_MAX_LEN;
+
+	tsk = tipc_sk_lock_next(&ref);
+	for (; tsk; tsk = tipc_sk_lock_next(&ref)) {
+		bh_lock_sock(&tsk->sk);
+		str_len += tipc_sk_show(&tsk->port, pb + str_len,
+					pb_len - str_len, 0);
+		bh_unlock_sock(&tsk->sk);
+		tipc_port_unlock(&tsk->port);
+	}
+	str_len += 1;	/* for "\0" */
+	skb_put(buf, TLV_SPACE(str_len));
+	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
+
+	return buf;
+}
+
+/* tipc_sk_reinit: set non-zero address in all existing sockets
+ *                 when we go from standalone to network mode.
+ */
+void tipc_sk_reinit(void)
+{
+	struct tipc_msg *msg;
+	u32 ref = 0;
+	struct tipc_sock *tsk = tipc_sk_lock_next(&ref);
+
+	for (; tsk; tsk = tipc_sk_lock_next(&ref)) {
+		bh_lock_sock(&tsk->sk);
+		msg = &tsk->port.phdr;
+		msg_set_prevnode(msg, tipc_own_addr);
+		msg_set_orignode(msg, tipc_own_addr);
+		bh_unlock_sock(&tsk->sk);
+		tipc_port_unlock(&tsk->port);
+	}
+}
+
 /**
  * tipc_setsockopt - set socket option
  * @sock: socket structure
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 1405633..5d515be 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -79,7 +79,8 @@ static inline int tipc_sk_conn_cong(struct tipc_sock *tsk)
 }
 
 int tipc_sk_rcv(struct sk_buff *buf);
-
+struct sk_buff *tipc_sk_socks_show(void);
 void tipc_sk_mcast_rcv(struct sk_buff *buf);
+void tipc_sk_reinit(void);
 
 #endif
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
