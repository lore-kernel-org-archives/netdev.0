From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/21] tipc: Avoid recomputation of outgoing message length
Date: Tue, 10 May 2011 16:44:32 -0400
Message-ID: <1305060277-15600-17-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52441 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab1EJUpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:12 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Rework TIPC's message sending routines to take advantage of the total
amount of data value passed to it by the kernel socket infrastructure.
This change eliminates the need for TIPC to compute the size of outgoing
messages itself, as well as the check for an oversize message in
tipc_msg_build().  In addition, this change warrants an explanation:

   -     res = send_packet(NULL, sock, &my_msg, 0);
   +     res = send_packet(NULL, sock, &my_msg, bytes_to_send);

Previously, the final argument to send_packet() was ignored (since the
amount of data being sent was recalculated by a lower-level routine)
and we could just pass in a dummy value (0). Now that the
recalculation is being eliminated, the argument value being passed to
send_packet() is significant and we have to supply the actual amount
of data we want to send.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c   |   18 +++++++++++-------
 net/tipc/link.h   |    1 +
 net/tipc/msg.c    |   25 +++----------------------
 net/tipc/msg.h    |    5 ++---
 net/tipc/port.c   |   49 +++++++++++++++++++++++++++----------------------
 net/tipc/port.h   |   14 +++++++++-----
 net/tipc/socket.c |   14 +++++++++-----
 net/tipc/subscr.c |    4 ++--
 8 files changed, 64 insertions(+), 66 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2a9f44a..4bab139 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -92,7 +92,8 @@ static int  link_recv_changeover_msg(struct link **l_ptr, struct sk_buff **buf);
 static void link_set_supervision_props(struct link *l_ptr, u32 tolerance);
 static int  link_send_sections_long(struct tipc_port *sender,
 				    struct iovec const *msg_sect,
-				    u32 num_sect, u32 destnode);
+				    u32 num_sect, unsigned int total_len,
+				    u32 destnode);
 static void link_check_defragm_bufs(struct link *l_ptr);
 static void link_state_event(struct link *l_ptr, u32 event);
 static void link_reset_statistics(struct link *l_ptr);
@@ -1043,6 +1044,7 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
+				 unsigned int total_len,
 				 u32 destaddr)
 {
 	struct tipc_msg *hdr = &sender->phdr;
@@ -1058,8 +1060,8 @@ again:
 	 * (Must not hold any locks while building message.)
 	 */
 
-	res = tipc_msg_build(hdr, msg_sect, num_sect, sender->max_pkt,
-			!sender->user_port, &buf);
+	res = tipc_msg_build(hdr, msg_sect, num_sect, total_len,
+			     sender->max_pkt, !sender->user_port, &buf);
 
 	read_lock_bh(&tipc_net_lock);
 	node = tipc_node_find(destaddr);
@@ -1104,7 +1106,8 @@ exit:
 				goto again;
 
 			return link_send_sections_long(sender, msg_sect,
-						       num_sect, destaddr);
+						       num_sect, total_len,
+						       destaddr);
 		}
 		tipc_node_unlock(node);
 	}
@@ -1116,7 +1119,7 @@ exit:
 		return tipc_reject_msg(buf, TIPC_ERR_NO_NODE);
 	if (res >= 0)
 		return tipc_port_reject_sections(sender, hdr, msg_sect, num_sect,
-						 TIPC_ERR_NO_NODE);
+						 total_len, TIPC_ERR_NO_NODE);
 	return res;
 }
 
@@ -1137,12 +1140,13 @@ exit:
 static int link_send_sections_long(struct tipc_port *sender,
 				   struct iovec const *msg_sect,
 				   u32 num_sect,
+				   unsigned int total_len,
 				   u32 destaddr)
 {
 	struct link *l_ptr;
 	struct tipc_node *node;
 	struct tipc_msg *hdr = &sender->phdr;
-	u32 dsz = msg_data_sz(hdr);
+	u32 dsz = total_len;
 	u32 max_pkt, fragm_sz, rest;
 	struct tipc_msg fragm_hdr;
 	struct sk_buff *buf, *buf_chain, *prev;
@@ -1269,7 +1273,7 @@ reject:
 			buf_discard(buf_chain);
 		}
 		return tipc_port_reject_sections(sender, hdr, msg_sect, num_sect,
-						 TIPC_ERR_NO_NODE);
+						 total_len, TIPC_ERR_NO_NODE);
 	}
 
 	/* Append whole chain to send queue: */
diff --git a/net/tipc/link.h b/net/tipc/link.h
index e6a30db..74fbeca 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -228,6 +228,7 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
+				 unsigned int total_len,
 				 u32 destnode);
 void tipc_link_recv_bundle(struct sk_buff *buf);
 int  tipc_link_recv_fragment(struct sk_buff **pending,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 6d92d17..03e57bf 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -68,20 +68,6 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 }
 
 /**
- * tipc_msg_calc_data_size - determine total data size for message
- */
-
-int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
-{
-	int dsz = 0;
-	int i;
-
-	for (i = 0; i < num_sect; i++)
-		dsz += msg_sect[i].iov_len;
-	return dsz;
-}
-
-/**
  * tipc_msg_build - create message using specified header and data
  *
  * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
@@ -89,18 +75,13 @@ int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
  * Returns message data size or errno
  */
 
-int tipc_msg_build(struct tipc_msg *hdr,
-			    struct iovec const *msg_sect, u32 num_sect,
+int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
+		   u32 num_sect, unsigned int total_len,
 			    int max_size, int usrmem, struct sk_buff **buf)
 {
 	int dsz, sz, hsz, pos, res, cnt;
 
-	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
-	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
-		*buf = NULL;
-		return -EINVAL;
-	}
-
+	dsz = total_len;
 	pos = hsz = msg_hdr_sz(hdr);
 	sz = hsz + dsz;
 	msg_set_size(hdr, sz);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 005b318..8452454 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -750,9 +750,8 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 u32 tipc_msg_tot_importance(struct tipc_msg *m);
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 			    u32 hsize, u32 destnode);
-int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect);
-int tipc_msg_build(struct tipc_msg *hdr,
-			    struct iovec const *msg_sect, u32 num_sect,
+int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
+		   u32 num_sect, unsigned int total_len,
 			    int max_size, int usrmem, struct sk_buff **buf);
 
 static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 9f2ff12..c68dc95 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -74,7 +74,8 @@ static u32 port_peerport(struct tipc_port *p_ptr)
  */
 
 int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
-		   u32 num_sect, struct iovec const *msg_sect)
+		   u32 num_sect, struct iovec const *msg_sect,
+		   unsigned int total_len)
 {
 	struct tipc_msg *hdr;
 	struct sk_buff *buf;
@@ -98,7 +99,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 	msg_set_namelower(hdr, seq->lower);
 	msg_set_nameupper(hdr, seq->upper);
 	msg_set_hdr_sz(hdr, MCAST_H_SIZE);
-	res = tipc_msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, total_len, MAX_MSG_SIZE,
 			!oport->user_port, &buf);
 	if (unlikely(!buf))
 		return res;
@@ -418,12 +419,12 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 
 int tipc_port_reject_sections(struct tipc_port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
-			      int err)
+			      unsigned int total_len, int err)
 {
 	struct sk_buff *buf;
 	int res;
 
-	res = tipc_msg_build(hdr, msg_sect, num_sect, MAX_MSG_SIZE,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, total_len, MAX_MSG_SIZE,
 			!p_ptr->user_port, &buf);
 	if (!buf)
 		return res;
@@ -1163,12 +1164,13 @@ int tipc_shutdown(u32 ref)
  */
 
 static int tipc_port_recv_sections(struct tipc_port *sender, unsigned int num_sect,
-				   struct iovec const *msg_sect)
+				   struct iovec const *msg_sect,
+				   unsigned int total_len)
 {
 	struct sk_buff *buf;
 	int res;
 
-	res = tipc_msg_build(&sender->phdr, msg_sect, num_sect,
+	res = tipc_msg_build(&sender->phdr, msg_sect, num_sect, total_len,
 			MAX_MSG_SIZE, !sender->user_port, &buf);
 	if (likely(buf))
 		tipc_port_recv_msg(buf);
@@ -1179,7 +1181,8 @@ static int tipc_port_recv_sections(struct tipc_port *sender, unsigned int num_se
  * tipc_send - send message sections on connection
  */
 
-int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
+int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect,
+	      unsigned int total_len)
 {
 	struct tipc_port *p_ptr;
 	u32 destnode;
@@ -1194,9 +1197,10 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 		destnode = port_peernode(p_ptr);
 		if (likely(destnode != tipc_own_addr))
 			res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
-							   destnode);
+							   total_len, destnode);
 		else
-			res = tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
+			res = tipc_port_recv_sections(p_ptr, num_sect, msg_sect,
+						      total_len);
 
 		if (likely(res != -ELINKCONG)) {
 			p_ptr->congested = 0;
@@ -1207,8 +1211,7 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 	}
 	if (port_unreliable(p_ptr)) {
 		p_ptr->congested = 0;
-		/* Just calculate msg length and return */
-		return tipc_msg_calc_data_size(msg_sect, num_sect);
+		return total_len;
 	}
 	return -ELINKCONG;
 }
@@ -1218,7 +1221,8 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
  */
 
 int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
-	   unsigned int num_sect, struct iovec const *msg_sect)
+		   unsigned int num_sect, struct iovec const *msg_sect,
+		   unsigned int total_len)
 {
 	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
@@ -1245,23 +1249,23 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	if (likely(destport)) {
 		if (likely(destnode == tipc_own_addr))
 			res = tipc_port_recv_sections(p_ptr, num_sect,
-						      msg_sect);
+						      msg_sect, total_len);
 		else
 			res = tipc_link_send_sections_fast(p_ptr, msg_sect,
-							   num_sect, destnode);
+							   num_sect, total_len,
+							   destnode);
 		if (likely(res != -ELINKCONG)) {
 			if (res > 0)
 				p_ptr->sent++;
 			return res;
 		}
 		if (port_unreliable(p_ptr)) {
-			/* Just calculate msg length and return */
-			return tipc_msg_calc_data_size(msg_sect, num_sect);
+			return total_len;
 		}
 		return -ELINKCONG;
 	}
 	return tipc_port_reject_sections(p_ptr, msg, msg_sect, num_sect,
-					 TIPC_ERR_NO_NAME);
+					 total_len, TIPC_ERR_NO_NAME);
 }
 
 /**
@@ -1269,7 +1273,8 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
  */
 
 int tipc_send2port(u32 ref, struct tipc_portid const *dest,
-	   unsigned int num_sect, struct iovec const *msg_sect)
+		   unsigned int num_sect, struct iovec const *msg_sect,
+		   unsigned int total_len)
 {
 	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
@@ -1289,18 +1294,18 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
 
 	if (dest->node == tipc_own_addr)
-		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect);
+		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect,
+					       total_len);
 	else
 		res = tipc_link_send_sections_fast(p_ptr, msg_sect, num_sect,
-						   dest->node);
+						   total_len, dest->node);
 	if (likely(res != -ELINKCONG)) {
 		if (res > 0)
 			p_ptr->sent++;
 		return res;
 	}
 	if (port_unreliable(p_ptr)) {
-		/* Just calculate msg length and return */
-		return tipc_msg_calc_data_size(msg_sect, num_sect);
+		return total_len;
 	}
 	return -ELINKCONG;
 }
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 87b9424..b9aa341 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -205,23 +205,27 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr);
 /*
  * TIPC messaging routines
  */
-int tipc_send(u32 portref, unsigned int num_sect, struct iovec const *msg_sect);
+int tipc_send(u32 portref, unsigned int num_sect, struct iovec const *msg_sect,
+	      unsigned int total_len);
 
 int tipc_send2name(u32 portref, struct tipc_name const *name, u32 domain,
-		unsigned int num_sect, struct iovec const *msg_sect);
+		   unsigned int num_sect, struct iovec const *msg_sect,
+		   unsigned int total_len);
 
 int tipc_send2port(u32 portref, struct tipc_portid const *dest,
-		unsigned int num_sect, struct iovec const *msg_sect);
+		   unsigned int num_sect, struct iovec const *msg_sect,
+		   unsigned int total_len);
 
 int tipc_send_buf2port(u32 portref, struct tipc_portid const *dest,
 		struct sk_buff *buf, unsigned int dsz);
 
 int tipc_multicast(u32 portref, struct tipc_name_seq const *seq,
-		unsigned int section_count, struct iovec const *msg);
+		   unsigned int section_count, struct iovec const *msg,
+		   unsigned int total_len);
 
 int tipc_port_reject_sections(struct tipc_port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
-			      int err);
+			      unsigned int total_len, int err);
 struct sk_buff *tipc_port_get_ports(void);
 void tipc_port_recv_proto_msg(struct sk_buff *buf);
 void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index e1c7917..3388373 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -576,12 +576,14 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 					     &dest->addr.name.name,
 					     dest->addr.name.domain,
 					     m->msg_iovlen,
-					     m->msg_iov);
+					     m->msg_iov,
+					     total_len);
 		} else if (dest->addrtype == TIPC_ADDR_ID) {
 			res = tipc_send2port(tport->ref,
 					     &dest->addr.id,
 					     m->msg_iovlen,
-					     m->msg_iov);
+					     m->msg_iov,
+					     total_len);
 		} else if (dest->addrtype == TIPC_ADDR_MCAST) {
 			if (needs_conn) {
 				res = -EOPNOTSUPP;
@@ -593,7 +595,8 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 			res = tipc_multicast(tport->ref,
 					     &dest->addr.nameseq,
 					     m->msg_iovlen,
-					     m->msg_iov);
+					     m->msg_iov,
+					     total_len);
 		}
 		if (likely(res != -ELINKCONG)) {
 			if (needs_conn && (res >= 0))
@@ -659,7 +662,8 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 			break;
 		}
 
-		res = tipc_send(tport->ref, m->msg_iovlen, m->msg_iov);
+		res = tipc_send(tport->ref, m->msg_iovlen, m->msg_iov,
+				total_len);
 		if (likely(res != -ELINKCONG))
 			break;
 		if (m->msg_flags & MSG_DONTWAIT) {
@@ -766,7 +770,7 @@ static int send_stream(struct kiocb *iocb, struct socket *sock,
 				bytes_to_send = curr_left;
 			my_iov.iov_base = curr_start;
 			my_iov.iov_len = bytes_to_send;
-			res = send_packet(NULL, sock, &my_msg, 0);
+			res = send_packet(NULL, sock, &my_msg, bytes_to_send);
 			if (res < 0) {
 				if (bytes_sent)
 					res = bytes_sent;
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index aae9eae..6cf7268 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -109,7 +109,7 @@ static void subscr_send_event(struct subscription *sub,
 	sub->evt.found_upper = htohl(found_upper, sub->swap);
 	sub->evt.port.ref = htohl(port_ref, sub->swap);
 	sub->evt.port.node = htohl(node, sub->swap);
-	tipc_send(sub->server_ref, 1, &msg_sect);
+	tipc_send(sub->server_ref, 1, &msg_sect, msg_sect.iov_len);
 }
 
 /**
@@ -521,7 +521,7 @@ static void subscr_named_msg_event(void *usr_handle,
 
 	/* Send an ACK- to complete connection handshaking */
 
-	tipc_send(server_port_ref, 0, NULL);
+	tipc_send(server_port_ref, 0, NULL, 0);
 
 	/* Handle optional subscription request */
 
-- 
1.7.4.4

