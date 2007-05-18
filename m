From: Jon Paul Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 3/3] [TIPC]: Optimize stream send routine
	to avoid fragmentation
Date: Thu, 17 May 2007 20:33:49 -0400
Message-ID: <11794484301599-git-send-email-jon.maloy@ericsson.com>
References: <1>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Paul Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch enhances TIPC's stream socket send routine so that
it avoids transmitting data in chunks that require fragmentation
and reassembly, thereby improving performance at both the
sending and receiving ends of the connection.

The "maximum packet size" hint that records MTU info allows
the socket to decide how big a chunk it should send; in the
event that the hint has become stale, fragmentation may still
occur, but the data will be passed correctly and the hint will
be updated in time for the following send.  Note: The 66060 byte
pseudo-MTU used for intra-node connections requires the send
routine to perform an additional check to ensure it does not
exceed TIPC"s limit of 66000 bytes of user data per chunk.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>
---
 include/net/tipc/tipc_port.h |    6 ++++--
 net/tipc/link.c              |   16 ++++++++--------
 net/tipc/port.c              |   10 +++++-----
 net/tipc/port.h              |    6 ++----
 net/tipc/socket.c            |   25 +++++++++++++++++--------
 5 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
index 333bba6..cfc4ba4 100644
--- a/include/net/tipc/tipc_port.h
+++ b/include/net/tipc/tipc_port.h
@@ -1,8 +1,8 @@
 /*
  * include/net/tipc/tipc_port.h: Include file for privileged access to TIPC ports
  * 
- * Copyright (c) 1994-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 1994-2007, Ericsson AB
+ * Copyright (c) 2005-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -55,6 +55,7 @@
  * @conn_unacked: number of unacknowledged messages received from peer port
  * @published: non-zero if port has one or more associated names
  * @congested: non-zero if cannot send because of link or port congestion
+ * @max_pkt: maximum packet size "hint" used when building messages sent by port
  * @ref: unique reference to port in TIPC object registry
  * @phdr: preformatted message header used when sending messages
  */
@@ -68,6 +69,7 @@ struct tipc_port {
 	u32 conn_unacked;
 	int published;
 	u32 congested;
+	u32 max_pkt;
 	u32 ref;
 	struct tipc_msg phdr;
 };
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2124f32..5adfdfd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1,8 +1,8 @@
 /*
  * net/tipc/link.c: TIPC link code
  *
- * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2004-2006, Wind River Systems
+ * Copyright (c) 1996-2007, Ericsson AB
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -1260,7 +1260,7 @@ again:
 	 * (Must not hold any locks while building message.)
 	 */
 
-	res = msg_build(hdr, msg_sect, num_sect, sender->max_pkt,
+	res = msg_build(hdr, msg_sect, num_sect, sender->publ.max_pkt,
 			!sender->user_port, &buf);
 
 	read_lock_bh(&tipc_net_lock);
@@ -1271,7 +1271,7 @@ again:
 		if (likely(l_ptr)) {
 			if (likely(buf)) {
 				res = link_send_buf_fast(l_ptr, buf,
-							 &sender->max_pkt);
+							 &sender->publ.max_pkt);
 				if (unlikely(res < 0))
 					buf_discard(buf);
 exit:
@@ -1299,12 +1299,12 @@ exit:
 			 * then re-try fast path or fragment the message
 			 */
 
-			sender->max_pkt = link_max_pkt(l_ptr);
+			sender->publ.max_pkt = link_max_pkt(l_ptr);
 			tipc_node_unlock(node);
 			read_unlock_bh(&tipc_net_lock);
 
 
-			if ((msg_hdr_sz(hdr) + res) <= sender->max_pkt)
+			if ((msg_hdr_sz(hdr) + res) <= sender->publ.max_pkt)
 				goto again;
 
 			return link_send_sections_long(sender, msg_sect,
@@ -1357,7 +1357,7 @@ static int link_send_sections_long(struct port *sender,
 
 again:
 	fragm_no = 1;
-	max_pkt = sender->max_pkt - INT_H_SIZE;
+	max_pkt = sender->publ.max_pkt - INT_H_SIZE;
 		/* leave room for tunnel header in case of link changeover */
 	fragm_sz = max_pkt - INT_H_SIZE;
 		/* leave room for fragmentation header in each fragment */
@@ -1463,7 +1463,7 @@ error:
 			goto reject;
 		}
 		if (link_max_pkt(l_ptr) < max_pkt) {
-			sender->max_pkt = link_max_pkt(l_ptr);
+			sender->publ.max_pkt = link_max_pkt(l_ptr);
 			tipc_node_unlock(node);
 			for (; buf_chain; buf_chain = buf) {
 				buf = buf_chain->next;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index bcd5da0..5d2b9ce 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1,8 +1,8 @@
 /*
  * net/tipc/port.c: TIPC port code
  *
- * Copyright (c) 1992-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 1992-2007, Ericsson AB
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -239,6 +239,8 @@ u32 tipc_createport_raw(void *usr_handle,
 	}
 
 	tipc_port_lock(ref);
+	p_ptr->publ.usr_handle = usr_handle;
+	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
 	msg = &p_ptr->publ.phdr;
 	msg_init(msg, DATA_LOW, TIPC_NAMED_MSG, TIPC_OK, LONG_H_SIZE, 0);
@@ -248,11 +250,9 @@ u32 tipc_createport_raw(void *usr_handle,
 	msg_set_importance(msg,importance);
 	p_ptr->last_in_seqno = 41;
 	p_ptr->sent = 1;
-	p_ptr->publ.usr_handle = usr_handle;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
 	p_ptr->congested_link = NULL;
-	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->dispatcher = dispatcher;
 	p_ptr->wakeup = wakeup;
 	p_ptr->user_port = NULL;
@@ -1243,7 +1243,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	res = TIPC_OK;
 exit:
 	tipc_port_unlock(p_ptr);
-	p_ptr->max_pkt = tipc_link_get_max_pkt(peer->node, ref);
+	p_ptr->publ.max_pkt = tipc_link_get_max_pkt(peer->node, ref);
 	return res;
 }
 
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 7ef4d64..e5f8c16 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -1,8 +1,8 @@
 /*
  * net/tipc/port.h: Include file for TIPC port code
  *
- * Copyright (c) 1994-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 1994-2007, Ericsson AB
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -81,7 +81,6 @@ struct user_port {
  * @acked:
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
- * @max_pkt: maximum packet size "hint" used when building messages sent by port
  * @probing_state:
  * @probing_interval:
  * @last_in_seqno:
@@ -102,7 +101,6 @@ struct port {
 	u32 acked;
 	struct list_head publications;
 	u32 pub_count;
-	u32 max_pkt;
 	u32 probing_state;
 	u32 probing_interval;
 	u32 last_in_seqno;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index ac7f2aa..4a8f37f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -607,23 +607,24 @@ exit:
 static int send_stream(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len)
 {
+	struct tipc_port *tport;
 	struct msghdr my_msg;
 	struct iovec my_iov;
 	struct iovec *curr_iov;
 	int curr_iovlen;
 	char __user *curr_start;
+	u32 hdr_size;
 	int curr_left;
 	int bytes_to_send;
 	int bytes_sent;
 	int res;
 
-	if (likely(total_len <= TIPC_MAX_USER_MSG_SIZE))
-		return send_packet(iocb, sock, m, total_len);
-
-	/* Can only send large data streams if already connected */
+	/* Handle special cases where there is no connection */
 
 	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_DISCONNECTING)
+		if (sock->state == SS_UNCONNECTED)
+			return send_packet(iocb, sock, m, total_len);
+		else if (sock->state == SS_DISCONNECTING)
 			return -EPIPE;
 		else
 			return -ENOTCONN;
@@ -648,17 +649,25 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 	my_msg.msg_name = NULL;
 	bytes_sent = 0;
 
+	tport = tipc_sk(sock->sk)->p;
+	hdr_size = msg_hdr_sz(&tport->phdr);
+
 	while (curr_iovlen--) {
 		curr_start = curr_iov->iov_base;
 		curr_left = curr_iov->iov_len;
 
 		while (curr_left) {
-			bytes_to_send = (curr_left < TIPC_MAX_USER_MSG_SIZE)
-				? curr_left : TIPC_MAX_USER_MSG_SIZE;
+			bytes_to_send = tport->max_pkt - hdr_size;
+			if (bytes_to_send > TIPC_MAX_USER_MSG_SIZE)
+				bytes_to_send = TIPC_MAX_USER_MSG_SIZE;
+			if (curr_left < bytes_to_send)
+				bytes_to_send = curr_left;
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
 			if ((res = send_packet(iocb, sock, &my_msg, 0)) < 0) {
-				return bytes_sent ? bytes_sent : res;
+				if (bytes_sent != 0)
+					res = bytes_sent;
+				return res;
 			}
 			curr_left -= bytes_to_send;
 			curr_start += bytes_to_send;
-- 
1.5.0.5


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
