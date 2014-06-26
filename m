From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 09/13] tipc: connection oriented transport uses new send functions
Date: Wed, 25 Jun 2014 20:41:38 -0500
Message-ID: <1403746902-20408-10-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24169 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757394AbaFZBtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:03 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We move the message sending across established connections
to use the message preparation and send functions introduced
earlier in this series. We now do the message preparation
and call to the link send function directly from the socket,
instead of going via the port layer.

As a consequence of this change, the functions tipc_send(),
tipc_port_iovec_rcv(), tipc_port_iovec_reject() and tipc_reject_msg()
become unreferenced and can be eliminated from port.c. For the same
reason, the functions tipc_link_xmit_fast(), tipc_link_iovec_xmit_long()
and tipc_link_iovec_fast() can be eliminated from link.c.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c   |  249 -----------------------------------------------------
 net/tipc/port.c   |  142 +-----------------------------
 net/tipc/port.h   |   12 ---
 net/tipc/socket.c |  180 +++++++++++++++-----------------------
 4 files changed, 70 insertions(+), 513 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 68d2afb..93a8033 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -82,9 +82,6 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf);
 static int  tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 				 struct sk_buff **buf);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
-static int  tipc_link_iovec_long_xmit(struct tipc_port *sender,
-				      struct iovec const *msg_sect,
-				      unsigned int len, u32 destnode);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
@@ -1071,252 +1068,6 @@ void tipc_link_names_xmit(struct list_head *message_list, u32 dest)
 }
 
 /*
- * tipc_link_xmit_fast: Entry for data messages where the
- * destination link is known and the header is complete,
- * inclusive total message length. Very time critical.
- * Link is locked. Returns user data length.
- */
-static int tipc_link_xmit_fast(struct tipc_link *l_ptr, struct sk_buff *buf,
-			       u32 *used_max_pkt)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	int res = msg_data_sz(msg);
-
-	if (likely(!link_congested(l_ptr))) {
-		if (likely(msg_size(msg) <= l_ptr->max_pkt)) {
-			link_add_to_outqueue(l_ptr, buf, msg);
-			tipc_bearer_send(l_ptr->bearer_id, buf,
-					 &l_ptr->media_addr);
-			l_ptr->unacked_window = 0;
-			return res;
-		}
-		else
-			*used_max_pkt = l_ptr->max_pkt;
-	}
-	return __tipc_link_xmit(l_ptr, buf);  /* All other cases */
-}
-
-/*
- * tipc_link_iovec_xmit_fast: Entry for messages where the
- * destination processor is known and the header is complete,
- * except for total message length.
- * Returns user data length or errno.
- */
-int tipc_link_iovec_xmit_fast(struct tipc_port *sender,
-			      struct iovec const *msg_sect,
-			      unsigned int len, u32 destaddr)
-{
-	struct tipc_msg *hdr = &sender->phdr;
-	struct tipc_link *l_ptr;
-	struct sk_buff *buf;
-	struct tipc_node *node;
-	int res;
-	u32 selector = msg_origport(hdr) & 1;
-
-again:
-	/*
-	 * Try building message using port's max_pkt hint.
-	 * (Must not hold any locks while building message.)
-	 */
-	res = tipc_msg_build(hdr, msg_sect, len, sender->max_pkt, &buf);
-	/* Exit if build request was invalid */
-	if (unlikely(res < 0))
-		return res;
-
-	node = tipc_node_find(destaddr);
-	if (likely(node)) {
-		tipc_node_lock(node);
-		l_ptr = node->active_links[selector];
-		if (likely(l_ptr)) {
-			if (likely(buf)) {
-				res = tipc_link_xmit_fast(l_ptr, buf,
-							  &sender->max_pkt);
-exit:
-				tipc_node_unlock(node);
-				return res;
-			}
-
-			/* Exit if link (or bearer) is congested */
-			if (link_congested(l_ptr)) {
-				res = link_schedule_port(l_ptr,
-							 sender->ref, res);
-				goto exit;
-			}
-
-			/*
-			 * Message size exceeds max_pkt hint; update hint,
-			 * then re-try fast path or fragment the message
-			 */
-			sender->max_pkt = l_ptr->max_pkt;
-			tipc_node_unlock(node);
-
-
-			if ((msg_hdr_sz(hdr) + res) <= sender->max_pkt)
-				goto again;
-
-			return tipc_link_iovec_long_xmit(sender, msg_sect,
-							 len, destaddr);
-		}
-		tipc_node_unlock(node);
-	}
-
-	/* Couldn't find a link to the destination node */
-	kfree_skb(buf);
-	tipc_port_iovec_reject(sender, hdr, msg_sect, len, TIPC_ERR_NO_NODE);
-	return -ENETUNREACH;
-}
-
-/*
- * tipc_link_iovec_long_xmit(): Entry for long messages where the
- * destination node is known and the header is complete,
- * inclusive total message length.
- * Link and bearer congestion status have been checked to be ok,
- * and are ignored if they change.
- *
- * Note that fragments do not use the full link MTU so that they won't have
- * to undergo refragmentation if link changeover causes them to be sent
- * over another link with an additional tunnel header added as prefix.
- * (Refragmentation will still occur if the other link has a smaller MTU.)
- *
- * Returns user data length or errno.
- */
-static int tipc_link_iovec_long_xmit(struct tipc_port *sender,
-				     struct iovec const *msg_sect,
-				     unsigned int len, u32 destaddr)
-{
-	struct tipc_link *l_ptr;
-	struct tipc_node *node;
-	struct tipc_msg *hdr = &sender->phdr;
-	u32 dsz = len;
-	u32 max_pkt, fragm_sz, rest;
-	struct tipc_msg fragm_hdr;
-	struct sk_buff *buf, *buf_chain, *prev;
-	u32 fragm_crs, fragm_rest, hsz, sect_rest;
-	const unchar __user *sect_crs;
-	int curr_sect;
-	u32 fragm_no;
-	int res = 0;
-
-again:
-	fragm_no = 1;
-	max_pkt = sender->max_pkt - INT_H_SIZE;
-		/* leave room for tunnel header in case of link changeover */
-	fragm_sz = max_pkt - INT_H_SIZE;
-		/* leave room for fragmentation header in each fragment */
-	rest = dsz;
-	fragm_crs = 0;
-	fragm_rest = 0;
-	sect_rest = 0;
-	sect_crs = NULL;
-	curr_sect = -1;
-
-	/* Prepare reusable fragment header */
-	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
-		 INT_H_SIZE, msg_destnode(hdr));
-	msg_set_size(&fragm_hdr, max_pkt);
-	msg_set_fragm_no(&fragm_hdr, 1);
-
-	/* Prepare header of first fragment */
-	buf_chain = buf = tipc_buf_acquire(max_pkt);
-	if (!buf)
-		return -ENOMEM;
-	buf->next = NULL;
-	skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
-	hsz = msg_hdr_sz(hdr);
-	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, hdr, hsz);
-
-	/* Chop up message */
-	fragm_crs = INT_H_SIZE + hsz;
-	fragm_rest = fragm_sz - hsz;
-
-	do {		/* For all sections */
-		u32 sz;
-
-		if (!sect_rest) {
-			sect_rest = msg_sect[++curr_sect].iov_len;
-			sect_crs = msg_sect[curr_sect].iov_base;
-		}
-
-		if (sect_rest < fragm_rest)
-			sz = sect_rest;
-		else
-			sz = fragm_rest;
-
-		if (copy_from_user(buf->data + fragm_crs, sect_crs, sz)) {
-			res = -EFAULT;
-error:
-			kfree_skb_list(buf_chain);
-			return res;
-		}
-		sect_crs += sz;
-		sect_rest -= sz;
-		fragm_crs += sz;
-		fragm_rest -= sz;
-		rest -= sz;
-
-		if (!fragm_rest && rest) {
-
-			/* Initiate new fragment: */
-			if (rest <= fragm_sz) {
-				fragm_sz = rest;
-				msg_set_type(&fragm_hdr, LAST_FRAGMENT);
-			} else {
-				msg_set_type(&fragm_hdr, FRAGMENT);
-			}
-			msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
-			msg_set_fragm_no(&fragm_hdr, ++fragm_no);
-			prev = buf;
-			buf = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
-			if (!buf) {
-				res = -ENOMEM;
-				goto error;
-			}
-
-			buf->next = NULL;
-			prev->next = buf;
-			skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
-			fragm_crs = INT_H_SIZE;
-			fragm_rest = fragm_sz;
-		}
-	} while (rest > 0);
-
-	/*
-	 * Now we have a buffer chain. Select a link and check
-	 * that packet size is still OK
-	 */
-	node = tipc_node_find(destaddr);
-	if (likely(node)) {
-		tipc_node_lock(node);
-		l_ptr = node->active_links[sender->ref & 1];
-		if (!l_ptr) {
-			tipc_node_unlock(node);
-			goto reject;
-		}
-		if (l_ptr->max_pkt < max_pkt) {
-			sender->max_pkt = l_ptr->max_pkt;
-			tipc_node_unlock(node);
-			kfree_skb_list(buf_chain);
-			goto again;
-		}
-	} else {
-reject:
-		kfree_skb_list(buf_chain);
-		tipc_port_iovec_reject(sender, hdr, msg_sect, len,
-				       TIPC_ERR_NO_NODE);
-		return -ENETUNREACH;
-	}
-
-	/* Append chain of fragments to send queue & send them */
-	l_ptr->long_msg_seq_no++;
-	link_add_chain_to_outqueue(l_ptr, buf_chain, l_ptr->long_msg_seq_no);
-	l_ptr->stats.sent_fragments += fragm_no;
-	l_ptr->stats.sent_fragmented++;
-	tipc_link_push_queue(l_ptr);
-	tipc_node_unlock(node);
-	return dsz;
-}
-
-/*
  * tipc_link_push_packet: Push one unsent packet to the media
  */
 static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 8350ec9..606ff1a 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -211,6 +211,7 @@ u32 tipc_port_init(struct tipc_port *p_ptr,
 	}
 
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
+	p_ptr->sent = 1;
 	p_ptr->ref = ref;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
@@ -279,92 +280,6 @@ static struct sk_buff *port_build_proto_msg(struct tipc_port *p_ptr,
 	return buf;
 }
 
-int tipc_reject_msg(struct sk_buff *buf, u32 err)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	struct sk_buff *rbuf;
-	struct tipc_msg *rmsg;
-	int hdr_sz;
-	u32 imp;
-	u32 data_sz = msg_data_sz(msg);
-	u32 src_node;
-	u32 rmsg_sz;
-
-	/* discard rejected message if it shouldn't be returned to sender */
-	if (WARN(!msg_isdata(msg),
-		 "attempt to reject message with user=%u", msg_user(msg))) {
-		dump_stack();
-		goto exit;
-	}
-	if (msg_errcode(msg) || msg_dest_droppable(msg))
-		goto exit;
-
-	/*
-	 * construct returned message by copying rejected message header and
-	 * data (or subset), then updating header fields that need adjusting
-	 */
-	hdr_sz = msg_hdr_sz(msg);
-	rmsg_sz = hdr_sz + min_t(u32, data_sz, MAX_REJECT_SIZE);
-
-	rbuf = tipc_buf_acquire(rmsg_sz);
-	if (rbuf == NULL)
-		goto exit;
-
-	rmsg = buf_msg(rbuf);
-	skb_copy_to_linear_data(rbuf, msg, rmsg_sz);
-
-	if (msg_connected(rmsg)) {
-		imp = msg_importance(rmsg);
-		if (imp < TIPC_CRITICAL_IMPORTANCE)
-			msg_set_importance(rmsg, ++imp);
-	}
-	msg_set_non_seq(rmsg, 0);
-	msg_set_size(rmsg, rmsg_sz);
-	msg_set_errcode(rmsg, err);
-	msg_set_prevnode(rmsg, tipc_own_addr);
-	msg_swap_words(rmsg, 4, 5);
-	if (!msg_short(rmsg))
-		msg_swap_words(rmsg, 6, 7);
-
-	/* send self-abort message when rejecting on a connected port */
-	if (msg_connected(msg)) {
-		struct tipc_port *p_ptr = tipc_port_lock(msg_destport(msg));
-
-		if (p_ptr) {
-			struct sk_buff *abuf = NULL;
-
-			if (p_ptr->connected)
-				abuf = port_build_self_abort_msg(p_ptr, err);
-			tipc_port_unlock(p_ptr);
-			tipc_net_route_msg(abuf);
-		}
-	}
-
-	/* send returned message & dispose of rejected message */
-	src_node = msg_prevnode(msg);
-	if (in_own_node(src_node))
-		tipc_sk_rcv(rbuf);
-	else
-		tipc_link_xmit(rbuf, src_node, msg_link_selector(rmsg));
-exit:
-	kfree_skb(buf);
-	return data_sz;
-}
-
-int tipc_port_iovec_reject(struct tipc_port *p_ptr, struct tipc_msg *hdr,
-			   struct iovec const *msg_sect, unsigned int len,
-			   int err)
-{
-	struct sk_buff *buf;
-	int res;
-
-	res = tipc_msg_build(hdr, msg_sect, len, MAX_MSG_SIZE, &buf);
-	if (!buf)
-		return res;
-
-	return tipc_reject_msg(buf, err);
-}
-
 static void port_timeout(unsigned long ref)
 {
 	struct tipc_port *p_ptr = tipc_port_lock(ref);
@@ -698,7 +613,7 @@ int __tipc_port_connect(u32 ref, struct tipc_port *p_ptr,
 			  (net_ev_handler)port_handle_node_down);
 	res = 0;
 exit:
-	p_ptr->max_pkt = tipc_link_get_max_pkt(peer->node, ref);
+	p_ptr->max_pkt = tipc_node_get_mtu(peer->node, ref);
 	return res;
 }
 
@@ -753,56 +668,3 @@ int tipc_port_shutdown(u32 ref)
 	tipc_net_route_msg(buf);
 	return tipc_port_disconnect(ref);
 }
-
-/*
- *  tipc_port_iovec_rcv: Concatenate and deliver sectioned
- *                       message for this node.
- */
-static int tipc_port_iovec_rcv(struct tipc_port *sender,
-			       struct iovec const *msg_sect,
-			       unsigned int len)
-{
-	struct sk_buff *buf;
-	int res;
-
-	res = tipc_msg_build(&sender->phdr, msg_sect, len, MAX_MSG_SIZE, &buf);
-	if (likely(buf))
-		tipc_sk_rcv(buf);
-	return res;
-}
-
-/**
- * tipc_send - send message sections on connection
- */
-int tipc_send(struct tipc_port *p_ptr,
-	      struct iovec const *msg_sect,
-	      unsigned int len)
-{
-	u32 destnode;
-	int res;
-
-	if (!p_ptr->connected)
-		return -EINVAL;
-
-	p_ptr->congested = 1;
-	if (!tipc_port_congested(p_ptr)) {
-		destnode = tipc_port_peernode(p_ptr);
-		if (likely(!in_own_node(destnode)))
-			res = tipc_link_iovec_xmit_fast(p_ptr, msg_sect, len,
-							destnode);
-		else
-			res = tipc_port_iovec_rcv(p_ptr, msg_sect, len);
-
-		if (likely(res != -ELINKCONG)) {
-			p_ptr->congested = 0;
-			if (res > 0)
-				p_ptr->sent++;
-			return res;
-		}
-	}
-	if (tipc_port_unreliable(p_ptr)) {
-		p_ptr->congested = 0;
-		return len;
-	}
-	return -ELINKCONG;
-}
diff --git a/net/tipc/port.h b/net/tipc/port.h
index e566d55..231d948 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -104,8 +104,6 @@ struct tipc_port_list;
 u32 tipc_port_init(struct tipc_port *p_ptr,
 		   const unsigned int importance);
 
-int tipc_reject_msg(struct sk_buff *buf, u32 err);
-
 void tipc_acknowledge(u32 port_ref, u32 ack);
 
 void tipc_port_destroy(struct tipc_port *p_ptr);
@@ -136,21 +134,11 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
  * TIPC messaging routines
  */
 
-int tipc_send(struct tipc_port *port,
-	      struct iovec const *msg_sect,
-	      unsigned int len);
-
 int tipc_port_mcast_xmit(struct tipc_port *port,
 			 struct tipc_name_seq const *seq,
 			 struct iovec const *msg,
 			 unsigned int len);
 
-int tipc_port_iovec_reject(struct tipc_port *p_ptr,
-			   struct tipc_msg *hdr,
-			   struct iovec const *msg_sect,
-			   unsigned int len,
-			   int err);
-
 struct sk_buff *tipc_port_get_ports(void);
 void tipc_port_proto_rcv(struct sk_buff *buf);
 void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 5690751..bfe79bb 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -206,6 +206,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	sk->sk_data_ready = tipc_data_ready;
 	sk->sk_write_space = tipc_write_space;
 	tsk->conn_timeout = CONN_TIMEOUT_DEFAULT;
+	tsk->port.sent = 0;
 	atomic_set(&tsk->dupl_rcvcnt, 0);
 	tipc_port_unlock(port);
 
@@ -784,30 +785,40 @@ static int tipc_wait_for_sndpkt(struct socket *sock, long *timeo_p)
 }
 
 /**
- * tipc_send_packet - send a connection-oriented message
- * @iocb: if NULL, indicates that socket lock is already held
+ * tipc_send_stream - send stream-oriented data
+ * @iocb: (unused)
  * @sock: socket structure
- * @m: message to send
- * @total_len: length of message
+ * @m: data to send
+ * @dsz: total length of data to be transmitted
  *
- * Used for SOCK_SEQPACKET messages and SOCK_STREAM data.
+ * Used for SOCK_STREAM data.
  *
- * Returns the number of bytes sent on success, or errno otherwise
+ * Returns the number of bytes sent on success (or partial success),
+ * or errno if no data sent
  */
-static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t total_len)
+static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *m, size_t dsz)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
+	struct tipc_port *port = &tsk->port;
+	struct tipc_msg *mhdr = &port->phdr;
+	struct sk_buff *buf;
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
-	int res = -EINVAL;
+	u32 ref = port->ref;
+	int rc = -EINVAL;
 	long timeo;
+	u32 dnode;
+	uint mtu, send, sent = 0;
 
 	/* Handle implied connection establishment */
-	if (unlikely(dest))
-		return tipc_sendmsg(iocb, sock, m, total_len);
-
-	if (total_len > TIPC_MAX_USER_MSG_SIZE)
+	if (unlikely(dest)) {
+		rc = tipc_sendmsg(iocb, sock, m, dsz);
+		if (dsz && (dsz == rc))
+			tsk->port.sent = 1;
+		return rc;
+	}
+	if (dsz > (uint)INT_MAX)
 		return -EMSGSIZE;
 
 	if (iocb)
@@ -815,123 +826,68 @@ static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
 
 	if (unlikely(sock->state != SS_CONNECTED)) {
 		if (sock->state == SS_DISCONNECTING)
-			res = -EPIPE;
+			rc = -EPIPE;
 		else
-			res = -ENOTCONN;
+			rc = -ENOTCONN;
 		goto exit;
 	}
 
 	timeo = sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
+	dnode = tipc_port_peernode(port);
+	port->congested = 1;
+
+next:
+	mtu = port->max_pkt;
+	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
+	rc = tipc_msg_build2(mhdr, m->msg_iov, sent, send, mtu, &buf);
+	if (unlikely(rc < 0))
+		goto exit;
 	do {
-		res = tipc_send(&tsk->port, m->msg_iov, total_len);
-		if (likely(res != -ELINKCONG))
-			break;
-		res = tipc_wait_for_sndpkt(sock, &timeo);
-		if (res)
-			break;
-	} while (1);
+		port->congested = 1;
+		if (likely(!tipc_port_congested(port))) {
+			rc = tipc_link_xmit2(buf, dnode, ref);
+			if (likely(!rc)) {
+				port->sent++;
+				sent += send;
+				if (sent == dsz)
+					break;
+				goto next;
+			}
+			if (rc == -EMSGSIZE) {
+				port->max_pkt = tipc_node_get_mtu(dnode, ref);
+				goto next;
+			}
+			if (rc != -ELINKCONG)
+				break;
+		}
+		rc = tipc_wait_for_sndpkt(sock, &timeo);
+	} while (!rc);
+
+	port->congested = 0;
 exit:
 	if (iocb)
 		release_sock(sk);
-	return res;
+	return sent ? sent : rc;
 }
 
 /**
- * tipc_send_stream - send stream-oriented data
- * @iocb: (unused)
+ * tipc_send_packet - send a connection-oriented message
+ * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
- * @m: data to send
- * @total_len: total length of data to be sent
+ * @m: message to send
+ * @dsz: length of data to be transmitted
  *
- * Used for SOCK_STREAM data.
+ * Used for SOCK_SEQPACKET messages.
  *
- * Returns the number of bytes sent on success (or partial success),
- * or errno if no data sent
+ * Returns the number of bytes sent on success, or errno otherwise
  */
-static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
-			    struct msghdr *m, size_t total_len)
+static int tipc_send_packet(struct kiocb *iocb, struct socket *sock,
+			    struct msghdr *m, size_t dsz)
 {
-	struct sock *sk = sock->sk;
-	struct tipc_sock *tsk = tipc_sk(sk);
-	struct msghdr my_msg;
-	struct iovec my_iov;
-	struct iovec *curr_iov;
-	int curr_iovlen;
-	char __user *curr_start;
-	u32 hdr_size;
-	int curr_left;
-	int bytes_to_send;
-	int bytes_sent;
-	int res;
-
-	lock_sock(sk);
-
-	/* Handle special cases where there is no connection */
-	if (unlikely(sock->state != SS_CONNECTED)) {
-		if (sock->state == SS_UNCONNECTED)
-			res = tipc_send_packet(NULL, sock, m, total_len);
-		else
-			res = sock->state == SS_DISCONNECTING ? -EPIPE : -ENOTCONN;
-		goto exit;
-	}
-
-	if (unlikely(m->msg_name)) {
-		res = -EISCONN;
-		goto exit;
-	}
-
-	if (total_len > (unsigned int)INT_MAX) {
-		res = -EMSGSIZE;
-		goto exit;
-	}
-
-	/*
-	 * Send each iovec entry using one or more messages
-	 *
-	 * Note: This algorithm is good for the most likely case
-	 * (i.e. one large iovec entry), but could be improved to pass sets
-	 * of small iovec entries into send_packet().
-	 */
-	curr_iov = m->msg_iov;
-	curr_iovlen = m->msg_iovlen;
-	my_msg.msg_iov = &my_iov;
-	my_msg.msg_iovlen = 1;
-	my_msg.msg_flags = m->msg_flags;
-	my_msg.msg_name = NULL;
-	bytes_sent = 0;
-
-	hdr_size = msg_hdr_sz(&tsk->port.phdr);
-
-	while (curr_iovlen--) {
-		curr_start = curr_iov->iov_base;
-		curr_left = curr_iov->iov_len;
-
-		while (curr_left) {
-			bytes_to_send = tsk->port.max_pkt - hdr_size;
-			if (bytes_to_send > TIPC_MAX_USER_MSG_SIZE)
-				bytes_to_send = TIPC_MAX_USER_MSG_SIZE;
-			if (curr_left < bytes_to_send)
-				bytes_to_send = curr_left;
-			my_iov.iov_base = curr_start;
-			my_iov.iov_len = bytes_to_send;
-			res = tipc_send_packet(NULL, sock, &my_msg,
-					       bytes_to_send);
-			if (res < 0) {
-				if (bytes_sent)
-					res = bytes_sent;
-				goto exit;
-			}
-			curr_left -= bytes_to_send;
-			curr_start += bytes_to_send;
-			bytes_sent += bytes_to_send;
-		}
+	if (dsz > TIPC_MAX_USER_MSG_SIZE)
+		return -EMSGSIZE;
 
-		curr_iov++;
-	}
-	res = bytes_sent;
-exit:
-	release_sock(sk);
-	return res;
+	return tipc_send_stream(iocb, sock, m, dsz);
 }
 
 /**
-- 
1.7.9.5
