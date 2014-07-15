From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/7] tipc: remove unreferenced functions
Date: Tue, 15 Jul 2014 10:49:55 -0400
Message-ID: <1405435797-30116-6-git-send-email-jon.maloy@ericsson.com>
References: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.biz.mail.ne1.yahoo.com ([98.138.207.14]:34060 "HELO
	smtp107.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753296AbaGOOuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 10:50:07 -0400
In-Reply-To: <1405435797-30116-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can now remove a number of functions which have become obsolete
and unreferenced through this commit series. There are no functional
changes in this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c |   26 ------
 net/tipc/bcast.h |    1 -
 net/tipc/link.c  |  247 ------------------------------------------------------
 net/tipc/link.h  |    6 --
 net/tipc/msg.c   |   35 --------
 net/tipc/msg.h   |    3 -
 net/tipc/port.c  |  112 -------------------------
 net/tipc/port.h  |   10 ---
 8 files changed, 440 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index c665c95..2b68173 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -389,32 +389,6 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 	tipc_node_unlock(n_ptr);
 }
 
-/*
- * tipc_bclink_xmit - broadcast a packet to all nodes in cluster
- */
-int tipc_bclink_xmit(struct sk_buff *buf)
-{
-	int res;
-
-	tipc_bclink_lock();
-
-	if (!bclink->bcast_nodes.count) {
-		res = msg_data_sz(buf_msg(buf));
-		kfree_skb(buf);
-		goto exit;
-	}
-
-	res = __tipc_link_xmit(bcl, buf);
-	if (likely(res >= 0)) {
-		bclink_set_last_sent();
-		bcl->stats.queue_sz_counts++;
-		bcl->stats.accu_queue_sz += bcl->out_queue_size;
-	}
-exit:
-	tipc_bclink_unlock();
-	return res;
-}
-
 /* tipc_bclink_xmit2 - broadcast buffer chain to all nodes in cluster
  *                     and to identified node local sockets
  * @buf: chain of buffers containing message
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index d90645f..af6b657 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -89,7 +89,6 @@ void tipc_bclink_add_node(u32 addr);
 void tipc_bclink_remove_node(u32 addr);
 struct tipc_node *tipc_bclink_retransmit_to(void);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
-int  tipc_bclink_xmit(struct sk_buff *buf);
 void tipc_bclink_rcv(struct sk_buff *buf);
 u32  tipc_bclink_get_last_sent(void);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index d1255ba..28730dd 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -85,7 +85,6 @@ static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
-static int tipc_link_frag_xmit(struct tipc_link *l_ptr, struct sk_buff *buf);
 static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
 static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf);
@@ -679,180 +678,6 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 	}
 }
 
-/*
- * link_bundle_buf(): Append contents of a buffer to
- * the tail of an existing one.
- */
-static int link_bundle_buf(struct tipc_link *l_ptr, struct sk_buff *bundler,
-			   struct sk_buff *buf)
-{
-	struct tipc_msg *bundler_msg = buf_msg(bundler);
-	struct tipc_msg *msg = buf_msg(buf);
-	u32 size = msg_size(msg);
-	u32 bundle_size = msg_size(bundler_msg);
-	u32 to_pos = align(bundle_size);
-	u32 pad = to_pos - bundle_size;
-
-	if (msg_user(bundler_msg) != MSG_BUNDLER)
-		return 0;
-	if (msg_type(bundler_msg) != OPEN_MSG)
-		return 0;
-	if (skb_tailroom(bundler) < (pad + size))
-		return 0;
-	if (l_ptr->max_pkt < (to_pos + size))
-		return 0;
-
-	skb_put(bundler, pad + size);
-	skb_copy_to_linear_data_offset(bundler, to_pos, buf->data, size);
-	msg_set_size(bundler_msg, to_pos + size);
-	msg_set_msgcnt(bundler_msg, msg_msgcnt(bundler_msg) + 1);
-	kfree_skb(buf);
-	l_ptr->stats.sent_bundled++;
-	return 1;
-}
-
-static void link_add_to_outqueue(struct tipc_link *l_ptr,
-				 struct sk_buff *buf,
-				 struct tipc_msg *msg)
-{
-	u32 ack = mod(l_ptr->next_in_no - 1);
-	u32 seqno = mod(l_ptr->next_out_no++);
-
-	msg_set_word(msg, 2, ((ack << 16) | seqno));
-	msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-	buf->next = NULL;
-	if (l_ptr->first_out) {
-		l_ptr->last_out->next = buf;
-		l_ptr->last_out = buf;
-	} else
-		l_ptr->first_out = l_ptr->last_out = buf;
-
-	l_ptr->out_queue_size++;
-	if (l_ptr->out_queue_size > l_ptr->stats.max_queue_sz)
-		l_ptr->stats.max_queue_sz = l_ptr->out_queue_size;
-}
-
-static void link_add_chain_to_outqueue(struct tipc_link *l_ptr,
-				       struct sk_buff *buf_chain,
-				       u32 long_msgno)
-{
-	struct sk_buff *buf;
-	struct tipc_msg *msg;
-
-	if (!l_ptr->next_out)
-		l_ptr->next_out = buf_chain;
-	while (buf_chain) {
-		buf = buf_chain;
-		buf_chain = buf_chain->next;
-
-		msg = buf_msg(buf);
-		msg_set_long_msgno(msg, long_msgno);
-		link_add_to_outqueue(l_ptr, buf, msg);
-	}
-}
-
-/*
- * tipc_link_xmit() is the 'full path' for messages, called from
- * inside TIPC when the 'fast path' in tipc_send_xmit
- * has failed, and from link_send()
- */
-int __tipc_link_xmit(struct tipc_link *l_ptr, struct sk_buff *buf)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	u32 size = msg_size(msg);
-	u32 dsz = msg_data_sz(msg);
-	u32 queue_size = l_ptr->out_queue_size;
-	u32 imp = tipc_msg_tot_importance(msg);
-	u32 queue_limit = l_ptr->queue_limit[imp];
-	u32 max_packet = l_ptr->max_pkt;
-
-	/* Match msg importance against queue limits: */
-	if (unlikely(queue_size >= queue_limit)) {
-		if (imp <= TIPC_CRITICAL_IMPORTANCE) {
-			link_schedule_port(l_ptr, msg_origport(msg), size);
-			kfree_skb(buf);
-			return -ELINKCONG;
-		}
-		kfree_skb(buf);
-		if (imp > CONN_MANAGER) {
-			pr_warn("%s<%s>, send queue full", link_rst_msg,
-				l_ptr->name);
-			tipc_link_reset(l_ptr);
-		}
-		return dsz;
-	}
-
-	/* Fragmentation needed ? */
-	if (size > max_packet)
-		return tipc_link_frag_xmit(l_ptr, buf);
-
-	/* Packet can be queued or sent. */
-	if (likely(!link_congested(l_ptr))) {
-		link_add_to_outqueue(l_ptr, buf, msg);
-
-		tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
-		l_ptr->unacked_window = 0;
-		return dsz;
-	}
-	/* Congestion: can message be bundled ? */
-	if ((msg_user(msg) != CHANGEOVER_PROTOCOL) &&
-	    (msg_user(msg) != MSG_FRAGMENTER)) {
-
-		/* Try adding message to an existing bundle */
-		if (l_ptr->next_out &&
-		    link_bundle_buf(l_ptr, l_ptr->last_out, buf))
-			return dsz;
-
-		/* Try creating a new bundle */
-		if (size <= max_packet * 2 / 3) {
-			struct sk_buff *bundler = tipc_buf_acquire(max_packet);
-			struct tipc_msg bundler_hdr;
-
-			if (bundler) {
-				tipc_msg_init(&bundler_hdr, MSG_BUNDLER, OPEN_MSG,
-					 INT_H_SIZE, l_ptr->addr);
-				skb_copy_to_linear_data(bundler, &bundler_hdr,
-							INT_H_SIZE);
-				skb_trim(bundler, INT_H_SIZE);
-				link_bundle_buf(l_ptr, bundler, buf);
-				buf = bundler;
-				msg = buf_msg(buf);
-				l_ptr->stats.sent_bundles++;
-			}
-		}
-	}
-	if (!l_ptr->next_out)
-		l_ptr->next_out = buf;
-	link_add_to_outqueue(l_ptr, buf, msg);
-	return dsz;
-}
-
-/*
- * tipc_link_xmit(): same as __tipc_link_xmit(), but the link to use
- * has not been selected yet, and the the owner node is not locked
- * Called by TIPC internal users, e.g. the name distributor
- */
-int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector)
-{
-	struct tipc_link *l_ptr;
-	struct tipc_node *n_ptr;
-	int res = -ELINKCONG;
-
-	n_ptr = tipc_node_find(dest);
-	if (n_ptr) {
-		tipc_node_lock(n_ptr);
-		l_ptr = n_ptr->active_links[selector & 1];
-		if (l_ptr)
-			res = __tipc_link_xmit(l_ptr, buf);
-		else
-			kfree_skb(buf);
-		tipc_node_unlock(n_ptr);
-	} else {
-		kfree_skb(buf);
-	}
-	return res;
-}
-
 /* tipc_link_cong: determine return value and how to treat the
  * sent buffer during link congestion.
  * - For plain, errorless user data messages we keep the buffer and
@@ -2123,78 +1948,6 @@ void tipc_link_bundle_rcv(struct sk_buff *buf)
 	kfree_skb(buf);
 }
 
-/*
- *  Fragmentation/defragmentation:
- */
-
-/*
- * tipc_link_frag_xmit: Entry for buffers needing fragmentation.
- * The buffer is complete, inclusive total message length.
- * Returns user data length.
- */
-static int tipc_link_frag_xmit(struct tipc_link *l_ptr, struct sk_buff *buf)
-{
-	struct sk_buff *buf_chain = NULL;
-	struct sk_buff *buf_chain_tail = (struct sk_buff *)&buf_chain;
-	struct tipc_msg *inmsg = buf_msg(buf);
-	struct tipc_msg fragm_hdr;
-	u32 insize = msg_size(inmsg);
-	u32 dsz = msg_data_sz(inmsg);
-	unchar *crs = buf->data;
-	u32 rest = insize;
-	u32 pack_sz = l_ptr->max_pkt;
-	u32 fragm_sz = pack_sz - INT_H_SIZE;
-	u32 fragm_no = 0;
-	u32 destaddr;
-
-	if (msg_short(inmsg))
-		destaddr = l_ptr->addr;
-	else
-		destaddr = msg_destnode(inmsg);
-
-	/* Prepare reusable fragment header: */
-	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
-		 INT_H_SIZE, destaddr);
-
-	/* Chop up message: */
-	while (rest > 0) {
-		struct sk_buff *fragm;
-
-		if (rest <= fragm_sz) {
-			fragm_sz = rest;
-			msg_set_type(&fragm_hdr, LAST_FRAGMENT);
-		}
-		fragm = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
-		if (fragm == NULL) {
-			kfree_skb(buf);
-			kfree_skb_list(buf_chain);
-			return -ENOMEM;
-		}
-		msg_set_size(&fragm_hdr, fragm_sz + INT_H_SIZE);
-		fragm_no++;
-		msg_set_fragm_no(&fragm_hdr, fragm_no);
-		skb_copy_to_linear_data(fragm, &fragm_hdr, INT_H_SIZE);
-		skb_copy_to_linear_data_offset(fragm, INT_H_SIZE, crs,
-					       fragm_sz);
-		buf_chain_tail->next = fragm;
-		buf_chain_tail = fragm;
-
-		rest -= fragm_sz;
-		crs += fragm_sz;
-		msg_set_type(&fragm_hdr, FRAGMENT);
-	}
-	kfree_skb(buf);
-
-	/* Append chain of fragments to send queue & send them */
-	l_ptr->long_msg_seq_no++;
-	link_add_chain_to_outqueue(l_ptr, buf_chain, l_ptr->long_msg_seq_no);
-	l_ptr->stats.sent_fragments += fragm_no;
-	l_ptr->stats.sent_fragmented++;
-	tipc_link_push_queue(l_ptr);
-
-	return dsz;
-}
-
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 {
 	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 04a59c5..f0ebeb6 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -226,15 +226,9 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
-int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
 int tipc_link_xmit2(struct sk_buff *buf, u32 dest, u32 selector);
-int __tipc_link_xmit(struct tipc_link *l_ptr, struct sk_buff *buf);
 int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf);
-int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
-int tipc_link_iovec_xmit_fast(struct tipc_port *sender,
-			      struct iovec const *msg_sect,
-			      unsigned int len, u32 destnode);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 4662b16..04e5cad 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -60,41 +60,6 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 	msg_set_destnode(m, destnode);
 }
 
-/**
- * tipc_msg_build - create message using specified header and data
- *
- * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
- *
- * Returns message data size or errno
- */
-int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
-		   unsigned int len, int max_size, struct sk_buff **buf)
-{
-	int dsz, sz, hsz;
-	unsigned char *to;
-
-	dsz = len;
-	hsz = msg_hdr_sz(hdr);
-	sz = hsz + dsz;
-	msg_set_size(hdr, sz);
-	if (unlikely(sz > max_size)) {
-		*buf = NULL;
-		return dsz;
-	}
-
-	*buf = tipc_buf_acquire(sz);
-	if (!(*buf))
-		return -ENOMEM;
-	skb_copy_to_linear_data(*buf, hdr, hsz);
-	to = (*buf)->data + hsz;
-	if (len && memcpy_fromiovecend(to, msg_sect, 0, dsz)) {
-		kfree_skb(*buf);
-		*buf = NULL;
-		return -EFAULT;
-	}
-	return dsz;
-}
-
 /* tipc_buf_append(): Append a buffer to the fragment list of another buffer
  * Let first buffer become head buffer
  * Returns 1 and sets *buf to headbuf if chain is complete, otherwise 0
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index a15d596..868fe22 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -732,9 +732,6 @@ int tipc_msg_eval(struct sk_buff *buf, u32 *dnode);
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 
-int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
-		   unsigned int len, int max_size, struct sk_buff **buf);
-
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 
 bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 0d09dcb..835dca1 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -74,118 +74,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg)
 		(!peernode && (orignode == tipc_own_addr));
 }
 
-/**
- * tipc_port_mcast_xmit - send a multicast message to local and remote
- * destinations
- */
-int tipc_port_mcast_xmit(struct tipc_port *oport,
-			 struct tipc_name_seq const *seq,
-			 struct iovec const *msg_sect,
-			 unsigned int len)
-{
-	struct tipc_msg *hdr;
-	struct sk_buff *buf;
-	struct sk_buff *ibuf = NULL;
-	struct tipc_port_list dports = {0, NULL, };
-	int ext_targets;
-	int res;
-
-	/* Create multicast message */
-	hdr = &oport->phdr;
-	msg_set_type(hdr, TIPC_MCAST_MSG);
-	msg_set_lookup_scope(hdr, TIPC_CLUSTER_SCOPE);
-	msg_set_destport(hdr, 0);
-	msg_set_destnode(hdr, 0);
-	msg_set_nametype(hdr, seq->type);
-	msg_set_namelower(hdr, seq->lower);
-	msg_set_nameupper(hdr, seq->upper);
-	msg_set_hdr_sz(hdr, MCAST_H_SIZE);
-	res = tipc_msg_build(hdr, msg_sect, len, MAX_MSG_SIZE, &buf);
-	if (unlikely(!buf))
-		return res;
-
-	/* Figure out where to send multicast message */
-	ext_targets = tipc_nametbl_mc_translate(seq->type, seq->lower, seq->upper,
-						TIPC_NODE_SCOPE, &dports);
-
-	/* Send message to destinations (duplicate it only if necessary) */
-	if (ext_targets) {
-		if (dports.count != 0) {
-			ibuf = skb_copy(buf, GFP_ATOMIC);
-			if (ibuf == NULL) {
-				tipc_port_list_free(&dports);
-				kfree_skb(buf);
-				return -ENOMEM;
-			}
-		}
-		res = tipc_bclink_xmit(buf);
-		if ((res < 0) && (dports.count != 0))
-			kfree_skb(ibuf);
-	} else {
-		ibuf = buf;
-	}
-
-	if (res >= 0) {
-		if (ibuf)
-			tipc_port_mcast_rcv(ibuf, &dports);
-	} else {
-		tipc_port_list_free(&dports);
-	}
-	return res;
-}
-
-/**
- * tipc_port_mcast_rcv - deliver multicast message to all destination ports
- *
- * If there is no port list, perform a lookup to create one
- */
-void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp)
-{
-	struct tipc_msg *msg;
-	struct tipc_port_list dports = {0, NULL, };
-	struct tipc_port_list *item = dp;
-	int cnt = 0;
-
-	msg = buf_msg(buf);
-
-	/* Create destination port list, if one wasn't supplied */
-	if (dp == NULL) {
-		tipc_nametbl_mc_translate(msg_nametype(msg),
-				     msg_namelower(msg),
-				     msg_nameupper(msg),
-				     TIPC_CLUSTER_SCOPE,
-				     &dports);
-		item = dp = &dports;
-	}
-
-	/* Deliver a copy of message to each destination port */
-	if (dp->count != 0) {
-		msg_set_destnode(msg, tipc_own_addr);
-		if (dp->count == 1) {
-			msg_set_destport(msg, dp->ports[0]);
-			tipc_sk_rcv(buf);
-			tipc_port_list_free(dp);
-			return;
-		}
-		for (; cnt < dp->count; cnt++) {
-			int index = cnt % PLSIZE;
-			struct sk_buff *b = skb_clone(buf, GFP_ATOMIC);
-
-			if (b == NULL) {
-				pr_warn("Unable to deliver multicast message(s)\n");
-				goto exit;
-			}
-			if ((index == 0) && (cnt != 0))
-				item = item->next;
-			msg_set_destport(buf_msg(b), item->ports[index]);
-			tipc_sk_rcv(b);
-		}
-	}
-exit:
-	kfree_skb(buf);
-	tipc_port_list_free(dp);
-}
-
 /* tipc_port_init - intiate TIPC port and lock it
  *
  * Returns obtained reference if initialization is successful, zero otherwise
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 0e47052..3f93454 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -120,17 +120,7 @@ int __tipc_port_connect(u32 ref, struct tipc_port *p_ptr,
 		   struct tipc_portid const *peer);
 int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 
-/*
- * TIPC messaging routines
- */
-
-int tipc_port_mcast_xmit(struct tipc_port *port,
-			 struct tipc_name_seq const *seq,
-			 struct iovec const *msg,
-			 unsigned int len);
-
 struct sk_buff *tipc_port_get_ports(void);
-void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp);
 void tipc_port_reinit(void);
 
 /**
-- 
1.7.9.5
