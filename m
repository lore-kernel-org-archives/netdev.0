From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 11/13] tipc: same receive code path for connection protocol and data messages
Date: Wed, 25 Jun 2014 20:41:40 -0500
Message-ID: <1403746902-20408-12-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24183 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757329AbaFZBtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:09 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a preparation to eliminate port_lock we need to bring reception
of connection protocol messages under proper protection of bh_lock_sock
or socket owner.

We fix this by letting those messages follow the same code path as
incoming data messages.

As a side effect of this change, the last reference to the function
net_route_msg() disappears, and we can eliminate that function.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c   |   18 ++++++++++++------
 net/tipc/net.c    |   40 ----------------------------------------
 net/tipc/net.h    |    2 --
 net/tipc/port.c   |    7 +------
 net/tipc/port.h   |    2 +-
 net/tipc/socket.c |    5 +++++
 6 files changed, 19 insertions(+), 55 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 93a8033..96a8072 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1479,6 +1479,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		case TIPC_MEDIUM_IMPORTANCE:
 		case TIPC_HIGH_IMPORTANCE:
 		case TIPC_CRITICAL_IMPORTANCE:
+		case CONN_MANAGER:
 			tipc_node_unlock(n_ptr);
 			tipc_sk_rcv(buf);
 			continue;
@@ -1493,10 +1494,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			tipc_node_unlock(n_ptr);
 			tipc_named_rcv(buf);
 			continue;
-		case CONN_MANAGER:
-			tipc_node_unlock(n_ptr);
-			tipc_port_proto_rcv(buf);
-			continue;
 		case BCAST_PROTOCOL:
 			tipc_link_sync_rcv(n_ptr, buf);
 			break;
@@ -2106,6 +2103,7 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 	u32 msgcount = msg_msgcnt(buf_msg(buf));
 	u32 pos = INT_H_SIZE;
 	struct sk_buff *obuf;
+	struct tipc_msg *omsg;
 
 	while (msgcount--) {
 		obuf = buf_extract(buf, pos);
@@ -2113,8 +2111,16 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 			pr_warn("Link unable to unbundle message(s)\n");
 			break;
 		}
-		pos += align(msg_size(buf_msg(obuf)));
-		tipc_net_route_msg(obuf);
+		omsg = buf_msg(obuf);
+		pos += align(msg_size(omsg));
+		if (msg_isdata(omsg) || (msg_user(omsg) == CONN_MANAGER)) {
+			tipc_sk_rcv(obuf);
+		} else if (msg_user(omsg) == NAME_DISTRIBUTOR) {
+			tipc_named_rcv(obuf);
+		} else {
+			pr_warn("Illegal bundled msg: %u\n", msg_user(omsg));
+			kfree_skb(obuf);
+		}
 	}
 	kfree_skb(buf);
 }
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 5f7d6ff..7fcc949 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -103,46 +103,6 @@
  *       This is always used within the scope of a tipc_nametbl_lock(read).
  *     - A local spin_lock protecting the queue of subscriber events.
 */
-void tipc_net_route_msg(struct sk_buff *buf)
-{
-	struct tipc_msg *msg;
-	u32 dnode;
-
-	if (!buf)
-		return;
-	msg = buf_msg(buf);
-
-	/* Handle message for this node */
-	dnode = msg_short(msg) ? tipc_own_addr : msg_destnode(msg);
-	if (tipc_in_scope(dnode, tipc_own_addr)) {
-		if (msg_isdata(msg)) {
-			if (msg_mcast(msg))
-				tipc_port_mcast_rcv(buf, NULL);
-			else if (msg_destport(msg)) {
-				tipc_sk_rcv(buf);
-			} else {
-				pr_warn("Cannot route msg; no destination\n");
-				kfree_skb(buf);
-			}
-			return;
-		}
-		switch (msg_user(msg)) {
-		case NAME_DISTRIBUTOR:
-			tipc_named_rcv(buf);
-			break;
-		case CONN_MANAGER:
-			tipc_port_proto_rcv(buf);
-			break;
-		default:
-			kfree_skb(buf);
-		}
-		return;
-	}
-
-	/* Handle message for another node */
-	skb_trim(buf, msg_size(msg));
-	tipc_link_xmit(buf, dnode, msg_link_selector(msg));
-}
 
 int tipc_net_start(u32 addr)
 {
diff --git a/net/tipc/net.h b/net/tipc/net.h
index c6c2b46..59ef338 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -37,8 +37,6 @@
 #ifndef _TIPC_NET_H
 #define _TIPC_NET_H
 
-void tipc_net_route_msg(struct sk_buff *buf);
-
 int tipc_net_start(u32 addr);
 void tipc_net_stop(void);
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 60aede0..dcc6309 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -365,16 +365,14 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 er
 	return buf;
 }
 
-void tipc_port_proto_rcv(struct sk_buff *buf)
+void tipc_port_proto_rcv(struct tipc_port *p_ptr, struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_port *p_ptr;
 	struct sk_buff *r_buf = NULL;
 	u32 destport = msg_destport(msg);
 	int wakeable;
 
 	/* Validate connection */
-	p_ptr = tipc_port_lock(destport);
 	if (!p_ptr || !p_ptr->connected || !tipc_port_peer_msg(p_ptr, msg)) {
 		r_buf = tipc_buf_acquire(BASIC_H_SIZE);
 		if (r_buf) {
@@ -385,8 +383,6 @@ void tipc_port_proto_rcv(struct sk_buff *buf)
 			msg_set_origport(msg, destport);
 			msg_set_destport(msg, msg_origport(msg));
 		}
-		if (p_ptr)
-			tipc_port_unlock(p_ptr);
 		goto exit;
 	}
 
@@ -409,7 +405,6 @@ void tipc_port_proto_rcv(struct sk_buff *buf)
 		break;
 	}
 	p_ptr->probing_state = CONFIRMED;
-	tipc_port_unlock(p_ptr);
 exit:
 	tipc_link_xmit2(r_buf, msg_destnode(msg), msg_link_selector(msg));
 	kfree_skb(buf);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 231d948..3f28fd4 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -140,7 +140,7 @@ int tipc_port_mcast_xmit(struct tipc_port *port,
 			 unsigned int len);
 
 struct sk_buff *tipc_port_get_ports(void);
-void tipc_port_proto_rcv(struct sk_buff *buf);
+void tipc_port_proto_rcv(struct tipc_port *port, struct sk_buff *buf);
 void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp);
 void tipc_port_reinit(void);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index bfe79bb..d838a4b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1416,6 +1416,11 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 	unsigned int limit = rcvbuf_limit(sk, buf);
 	int rc = TIPC_OK;
 
+	if (unlikely(msg_user(msg) == CONN_MANAGER)) {
+		tipc_port_proto_rcv(&tsk->port, buf);
+		return TIPC_OK;
+	}
+
 	/* Reject message if it is wrong sort of message for socket */
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
 		return -TIPC_ERR_NO_PORT;
-- 
1.7.9.5
