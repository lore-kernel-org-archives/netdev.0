From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/17] tipc: Fix port counter handling to correct congestion control
Date: Wed, 23 Feb 2011 20:26:41 -0500
Message-ID: <1298510805-20630-14-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34529 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab1BXB1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:15 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Modifies TIPC's congestion control between a connected port and its
peer so that it works as documented. The following changes have been
made:

1) The counter of the number of messages sent by a port now starts
   at zero, rather than one. This prevents the port from reporting port
   congestion one message earlier than it was supposed to.

2) The counter of the number of messages sent by a port is now
   incremented only if a non-empty message is sent successfully.
   This prevents the port from becoming permanently congested if
   too many send attempts are unsuccessful because of congestion
   (or other reasons). It also removes the risk that empty hand-
   shaking messages used during connection setup might cause the
   port to report congestion earlier than it was supposed to.

3) The counter of the number of unacknowledged messages received by
   a port controlled by an internal TIPC service is now incremented
   only if the message is non-empty, in order to be consistent with
   the aforementioned changes.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |   53 ++++++++++++++++++++++++++++++++++-------------------
 net/tipc/port.h |    4 ++--
 2 files changed, 36 insertions(+), 21 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index aff5dc0..3e5122c 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -234,7 +234,6 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_origport(msg, ref);
 	p_ptr->last_in_seqno = 41;
-	p_ptr->sent = 1;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
 	p_ptr->dispatcher = dispatcher;
@@ -732,6 +731,7 @@ static void port_dispatcher_sigh(void *dummy)
 				tipc_conn_msg_event cb = up_ptr->conn_msg_cb;
 				u32 peer_port = port_peerport(p_ptr);
 				u32 peer_node = port_peernode(p_ptr);
+				u32 dsz;
 
 				tipc_port_unlock(p_ptr);
 				if (unlikely(!cb))
@@ -742,13 +742,14 @@ static void port_dispatcher_sigh(void *dummy)
 				} else if ((msg_origport(msg) != peer_port) ||
 					   (msg_orignode(msg) != peer_node))
 					goto reject;
-				if (unlikely(++p_ptr->conn_unacked >=
-					     TIPC_FLOW_CONTROL_WIN))
+				dsz = msg_data_sz(msg);
+				if (unlikely(dsz &&
+					     (++p_ptr->conn_unacked >=
+					      TIPC_FLOW_CONTROL_WIN)))
 					tipc_acknowledge(dref,
 							 p_ptr->conn_unacked);
 				skb_pull(buf, msg_hdr_sz(msg));
-				cb(usr_handle, dref, &buf, msg_data(msg),
-				   msg_data_sz(msg));
+				cb(usr_handle, dref, &buf, msg_data(msg), dsz);
 				break;
 			}
 		case TIPC_DIRECT_MSG:{
@@ -1221,7 +1222,8 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 		if (likely(res != -ELINKCONG)) {
 			port_incr_out_seqno(p_ptr);
 			p_ptr->congested = 0;
-			p_ptr->sent++;
+			if (res > 0)
+				p_ptr->sent++;
 			return res;
 		}
 	}
@@ -1263,13 +1265,17 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	msg_set_destport(msg, destport);
 
 	if (likely(destport)) {
-		p_ptr->sent++;
 		if (likely(destnode == tipc_own_addr))
-			return tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
-		res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
-						   destnode);
-		if (likely(res != -ELINKCONG))
+			res = tipc_port_recv_sections(p_ptr, num_sect,
+						      msg_sect);
+		else
+			res = tipc_link_send_sections_fast(p_ptr, msg_sect,
+							   num_sect, destnode);
+		if (likely(res != -ELINKCONG)) {
+			if (res > 0)
+				p_ptr->sent++;
 			return res;
+		}
 		if (port_unreliable(p_ptr)) {
 			/* Just calculate msg length and return */
 			return tipc_msg_calc_data_size(msg_sect, num_sect);
@@ -1302,12 +1308,17 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
 	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
-	p_ptr->sent++;
+
 	if (dest->node == tipc_own_addr)
-		return tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
-	res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect, dest->node);
-	if (likely(res != -ELINKCONG))
+		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
+	else
+		res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
+						   dest->node);
+	if (likely(res != -ELINKCONG)) {
+		if (res > 0)
+			p_ptr->sent++;
 		return res;
+	}
 	if (port_unreliable(p_ptr)) {
 		/* Just calculate msg length and return */
 		return tipc_msg_calc_data_size(msg_sect, num_sect);
@@ -1343,12 +1354,16 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 
 	skb_push(buf, DIR_MSG_H_SIZE);
 	skb_copy_to_linear_data(buf, msg, DIR_MSG_H_SIZE);
-	p_ptr->sent++;
+
 	if (dest->node == tipc_own_addr)
-		return tipc_port_recv_msg(buf);
-	res = tipc_send_buf_fast(buf, dest->node);
-	if (likely(res != -ELINKCONG))
+		res = tipc_port_recv_msg(buf);
+	else
+		res = tipc_send_buf_fast(buf, dest->node);
+	if (likely(res != -ELINKCONG)) {
+		if (res > 0)
+			p_ptr->sent++;
 		return res;
+	}
 	if (port_unreliable(p_ptr))
 		return dsz;
 	return -ELINKCONG;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index f8722af..34ccb7c 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -113,8 +113,8 @@ struct user_port {
  * @user_port: ptr to user port associated with port (if any)
  * @wait_list: adjacent ports in list of ports waiting on link congestion
  * @waiting_pkts:
- * @sent:
- * @acked:
+ * @sent: # of non-empty messages sent by port
+ * @acked: # of non-empty message acknowledgements from connected port's peer
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
-- 
1.7.3.3

