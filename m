From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 11/11] tipc: use generic SKB list
	APIs to manage TIPC outgoing packet chains
Date: Wed, 26 Nov 2014 11:41:55 +0800
Message-ID: <1416973315-6047-12-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use standard SKB list APIs associated with struct sk_buff_head to
manage socket outgoing packet chain and name table outgoing packet
chain, having relevant code simpler and more readable.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c      |   20 ++++----
 net/tipc/bcast.h      |    2 +-
 net/tipc/link.c       |   98 ++++++++++++++++++++++++--------------
 net/tipc/link.h       |    5 +-
 net/tipc/msg.c        |   74 ++++++++++++++--------------
 net/tipc/msg.h        |    6 +--
 net/tipc/name_distr.c |   46 +++++++++---------
 net/tipc/socket.c     |  127 +++++++++++++++++++++++++------------------------
 8 files changed, 203 insertions(+), 175 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7b238b1..f0761c7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -398,20 +398,20 @@ static void bclink_peek_nack(struct tipc_msg *msg)
 
 /* tipc_bclink_xmit - broadcast buffer chain to all nodes in cluster
  *                    and to identified node local sockets
- * @buf: chain of buffers containing message
+ * @list: chain of buffers containing message
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_bclink_xmit(struct sk_buff *buf)
+int tipc_bclink_xmit(struct sk_buff_head *list)
 {
 	int rc = 0;
 	int bc = 0;
-	struct sk_buff *clbuf;
+	struct sk_buff *skb;
 
 	/* Prepare clone of message for local node */
-	clbuf = tipc_msg_reassemble(buf);
-	if (unlikely(!clbuf)) {
-		kfree_skb_list(buf);
+	skb = tipc_msg_reassemble(list);
+	if (unlikely(!skb)) {
+		__skb_queue_purge(list);
 		return -EHOSTUNREACH;
 	}
 
@@ -419,7 +419,7 @@ int tipc_bclink_xmit(struct sk_buff *buf)
 	if (likely(bclink)) {
 		tipc_bclink_lock();
 		if (likely(bclink->bcast_nodes.count)) {
-			rc = __tipc_link_xmit(bcl, buf);
+			rc = __tipc_link_xmit(bcl, list);
 			if (likely(!rc)) {
 				u32 len = skb_queue_len(&bcl->outqueue);
 
@@ -433,13 +433,13 @@ int tipc_bclink_xmit(struct sk_buff *buf)
 	}
 
 	if (unlikely(!bc))
-		kfree_skb_list(buf);
+		__skb_queue_purge(list);
 
 	/* Deliver message clone */
 	if (likely(!rc))
-		tipc_sk_mcast_rcv(clbuf);
+		tipc_sk_mcast_rcv(skb);
 	else
-		kfree_skb(clbuf);
+		kfree_skb(skb);
 
 	return rc;
 }
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 443de08..644d791 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -100,7 +100,7 @@ int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
 void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
-int tipc_bclink_xmit(struct sk_buff *buf);
+int tipc_bclink_xmit(struct sk_buff_head *list);
 void tipc_bclink_wakeup_users(void);
 int tipc_nl_add_bc_link(struct tipc_nl_msg *msg);
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 0e04508..34bf15c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -664,9 +664,10 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
  * - For all other messages we discard the buffer and return -EHOSTUNREACH
  * - For TIPC internal messages we also reset the link
  */
-static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
+static int tipc_link_cong(struct tipc_link *link, struct sk_buff_head *list)
 {
-	struct tipc_msg *msg = buf_msg(buf);
+	struct sk_buff *skb = skb_peek(list);
+	struct tipc_msg *msg = buf_msg(skb);
 	uint imp = tipc_msg_tot_importance(msg);
 	u32 oport = msg_tot_origport(msg);
 
@@ -679,28 +680,29 @@ static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
 		goto drop;
 	if (unlikely(msg_reroute_cnt(msg)))
 		goto drop;
-	if (TIPC_SKB_CB(buf)->wakeup_pending)
+	if (TIPC_SKB_CB(skb)->wakeup_pending)
 		return -ELINKCONG;
-	if (link_schedule_user(link, oport, TIPC_SKB_CB(buf)->chain_sz, imp))
+	if (link_schedule_user(link, oport, skb_queue_len(list), imp))
 		return -ELINKCONG;
 drop:
-	kfree_skb_list(buf);
+	__skb_queue_purge(list);
 	return -EHOSTUNREACH;
 }
 
 /**
  * __tipc_link_xmit(): same as tipc_link_xmit, but destlink is known & locked
  * @link: link to use
- * @skb: chain of buffers containing message
+ * @list: chain of buffers containing message
+ *
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG, -EMSGSIZE (plain socket
  * user data messages) or -EHOSTUNREACH (all other messages/senders)
  * Only the socket functions tipc_send_stream() and tipc_send_packet() need
  * to act on the return value, since they may need to do more send attempts.
  */
-int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *skb)
+int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list)
 {
-	struct tipc_msg *msg = buf_msg(skb);
+	struct tipc_msg *msg = buf_msg(skb_peek(list));
 	uint psz = msg_size(msg);
 	uint sndlim = link->queue_limit[0];
 	uint imp = tipc_msg_tot_importance(msg);
@@ -710,21 +712,21 @@ int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *skb)
 	uint bc_last_in = link->owner->bclink.last_in;
 	struct tipc_media_addr *addr = &link->media_addr;
 	struct sk_buff_head *outqueue = &link->outqueue;
-	struct sk_buff *next;
+	struct sk_buff *skb, *tmp;
 
 	/* Match queue limits against msg importance: */
 	if (unlikely(skb_queue_len(outqueue) >= link->queue_limit[imp]))
-		return tipc_link_cong(link, skb);
+		return tipc_link_cong(link, list);
 
 	/* Has valid packet limit been used ? */
 	if (unlikely(psz > mtu)) {
-		kfree_skb_list(skb);
+		__skb_queue_purge(list);
 		return -EMSGSIZE;
 	}
 
 	/* Prepare each packet for sending, and add to outqueue: */
-	while (skb) {
-		next = skb->next;
+	skb_queue_walk_safe(list, skb, tmp) {
+		__skb_unlink(skb, list);
 		msg = buf_msg(skb);
 		msg_set_word(msg, 2, ((ack << 16) | mod(seqno)));
 		msg_set_bcast_ack(msg, bc_last_in);
@@ -736,7 +738,6 @@ int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *skb)
 			link->unacked_window = 0;
 		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
 			link->stats.sent_bundled++;
-			skb = next;
 			continue;
 		} else if (tipc_msg_make_bundle(outqueue, skb, mtu,
 						link->addr)) {
@@ -750,22 +751,43 @@ int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *skb)
 				link->next_out = skb;
 		}
 		seqno++;
-		skb = next;
 	}
 	link->next_out_no = seqno;
 	return 0;
 }
 
+static void skb2list(struct sk_buff *skb, struct sk_buff_head *list)
+{
+	__skb_queue_head_init(list);
+	__skb_queue_tail(list, skb);
+}
+
+static int __tipc_link_xmit_skb(struct tipc_link *link, struct sk_buff *skb)
+{
+	struct sk_buff_head head;
+
+	skb2list(skb, &head);
+	return __tipc_link_xmit(link, &head);
+}
+
+int tipc_link_xmit_skb(struct sk_buff *skb, u32 dnode, u32 selector)
+{
+	struct sk_buff_head head;
+
+	skb2list(skb, &head);
+	return tipc_link_xmit(&head, dnode, selector);
+}
+
 /**
  * tipc_link_xmit() is the general link level function for message sending
- * @buf: chain of buffers containing message
+ * @list: chain of buffers containing message
  * @dsz: amount of user data to be sent
  * @dnode: address of destination node
  * @selector: a number used for deterministic link selection
  * Consumes the buffer chain, except when returning -ELINKCONG
  * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
  */
-int tipc_link_xmit(struct sk_buff *buf, u32 dnode, u32 selector)
+int tipc_link_xmit(struct sk_buff_head *list, u32 dnode, u32 selector)
 {
 	struct tipc_link *link = NULL;
 	struct tipc_node *node;
@@ -776,17 +798,22 @@ int tipc_link_xmit(struct sk_buff *buf, u32 dnode, u32 selector)
 		tipc_node_lock(node);
 		link = node->active_links[selector & 1];
 		if (link)
-			rc = __tipc_link_xmit(link, buf);
+			rc = __tipc_link_xmit(link, list);
 		tipc_node_unlock(node);
 	}
 
 	if (link)
 		return rc;
 
-	if (likely(in_own_node(dnode)))
-		return tipc_sk_rcv(buf);
+	if (likely(in_own_node(dnode))) {
+		/* As a node local message chain never contains more than one
+		 * buffer, we just need to dequeue one SKB buffer from the
+		 * head list.
+		 */
+		return tipc_sk_rcv(__skb_dequeue(list));
+	}
+	__skb_queue_purge(list);
 
-	kfree_skb_list(buf);
 	return rc;
 }
 
@@ -800,17 +827,17 @@ int tipc_link_xmit(struct sk_buff *buf, u32 dnode, u32 selector)
  */
 static void tipc_link_sync_xmit(struct tipc_link *link)
 {
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 	struct tipc_msg *msg;
 
-	buf = tipc_buf_acquire(INT_H_SIZE);
-	if (!buf)
+	skb = tipc_buf_acquire(INT_H_SIZE);
+	if (!skb)
 		return;
 
-	msg = buf_msg(buf);
+	msg = buf_msg(skb);
 	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, link->addr);
 	msg_set_last_bcast(msg, link->owner->bclink.acked);
-	__tipc_link_xmit(link, buf);
+	__tipc_link_xmit_skb(link, skb);
 }
 
 /*
@@ -1053,8 +1080,7 @@ void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 	u32 ackd;
 	u32 released;
 
-	__skb_queue_head_init(&head);
-	__skb_queue_tail(&head, skb);
+	skb2list(skb, &head);
 
 	while ((skb = __skb_dequeue(&head))) {
 		/* Ensure message is well-formed */
@@ -1573,7 +1599,7 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
 				  u32 selector)
 {
 	struct tipc_link *tunnel;
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 	u32 length = msg_size(msg);
 
 	tunnel = l_ptr->owner->active_links[selector & 1];
@@ -1582,14 +1608,14 @@ static void tipc_link_tunnel_xmit(struct tipc_link *l_ptr,
 		return;
 	}
 	msg_set_size(tunnel_hdr, length + INT_H_SIZE);
-	buf = tipc_buf_acquire(length + INT_H_SIZE);
-	if (!buf) {
+	skb = tipc_buf_acquire(length + INT_H_SIZE);
+	if (!skb) {
 		pr_warn("%sunable to send tunnel msg\n", link_co_err);
 		return;
 	}
-	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
-	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, msg, length);
-	__tipc_link_xmit(tunnel, buf);
+	skb_copy_to_linear_data(skb, tunnel_hdr, INT_H_SIZE);
+	skb_copy_to_linear_data_offset(skb, INT_H_SIZE, msg, length);
+	__tipc_link_xmit_skb(tunnel, skb);
 }
 
 
@@ -1620,7 +1646,7 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 		if (skb) {
 			skb_copy_to_linear_data(skb, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
-			__tipc_link_xmit(tunnel, skb);
+			__tipc_link_xmit_skb(tunnel, skb);
 		} else {
 			pr_warn("%sunable to send changeover msg\n",
 				link_co_err);
@@ -1691,7 +1717,7 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 		skb_copy_to_linear_data(outskb, &tunnel_hdr, INT_H_SIZE);
 		skb_copy_to_linear_data_offset(outskb, INT_H_SIZE, skb->data,
 					       length);
-		__tipc_link_xmit(tunnel, outskb);
+		__tipc_link_xmit_skb(tunnel, outskb);
 		if (!tipc_link_is_up(l_ptr))
 			return;
 	}
diff --git a/net/tipc/link.h b/net/tipc/link.h
index de7b883..55812e8 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -213,8 +213,9 @@ struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
-int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
-int __tipc_link_xmit(struct tipc_link *link, struct sk_buff *buf);
+int tipc_link_xmit_skb(struct sk_buff *skb, u32 dest, u32 selector);
+int tipc_link_xmit(struct sk_buff_head *list, u32 dest, u32 selector);
+int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ce7514a..5b06597 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -166,11 +166,12 @@ err:
  * @offset: Posision in iov to start copying from
  * @dsz: Total length of user data
  * @pktmax: Max packet size that can be used
- * @chain: Buffer or chain of buffers to be returned to caller
+ * @list: Buffer or chain of buffers to be returned to caller
+ *
  * Returns message data size or errno: -ENOMEM, -EFAULT
  */
-int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
-		   int offset, int dsz, int pktmax , struct sk_buff **chain)
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
+		   int dsz, int pktmax, struct sk_buff_head *list)
 {
 	int mhsz = msg_hdr_sz(mhdr);
 	int msz = mhsz + dsz;
@@ -179,22 +180,22 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 	int pktrem = pktmax;
 	int drem = dsz;
 	struct tipc_msg pkthdr;
-	struct sk_buff *buf, *prev;
+	struct sk_buff *skb;
 	char *pktpos;
 	int rc;
-	uint chain_sz = 0;
+
 	msg_set_size(mhdr, msz);
 
 	/* No fragmentation needed? */
 	if (likely(msz <= pktmax)) {
-		buf = tipc_buf_acquire(msz);
-		*chain = buf;
-		if (unlikely(!buf))
+		skb = tipc_buf_acquire(msz);
+		if (unlikely(!skb))
 			return -ENOMEM;
-		skb_copy_to_linear_data(buf, mhdr, mhsz);
-		pktpos = buf->data + mhsz;
-		TIPC_SKB_CB(buf)->chain_sz = 1;
-		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iov, offset, dsz))
+		__skb_queue_tail(list, skb);
+		skb_copy_to_linear_data(skb, mhdr, mhsz);
+		pktpos = skb->data + mhsz;
+		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iov, offset,
+						 dsz))
 			return dsz;
 		rc = -EFAULT;
 		goto error;
@@ -207,15 +208,15 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 	msg_set_fragm_no(&pkthdr, pktno);
 
 	/* Prepare first fragment */
-	*chain = buf = tipc_buf_acquire(pktmax);
-	if (!buf)
+	skb = tipc_buf_acquire(pktmax);
+	if (!skb)
 		return -ENOMEM;
-	chain_sz = 1;
-	pktpos = buf->data;
-	skb_copy_to_linear_data(buf, &pkthdr, INT_H_SIZE);
+	__skb_queue_tail(list, skb);
+	pktpos = skb->data;
+	skb_copy_to_linear_data(skb, &pkthdr, INT_H_SIZE);
 	pktpos += INT_H_SIZE;
 	pktrem -= INT_H_SIZE;
-	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, mhdr, mhsz);
+	skb_copy_to_linear_data_offset(skb, INT_H_SIZE, mhdr, mhsz);
 	pktpos += mhsz;
 	pktrem -= mhsz;
 
@@ -238,28 +239,25 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 			pktsz = drem + INT_H_SIZE;
 		else
 			pktsz = pktmax;
-		prev = buf;
-		buf = tipc_buf_acquire(pktsz);
-		if (!buf) {
+		skb = tipc_buf_acquire(pktsz);
+		if (!skb) {
 			rc = -ENOMEM;
 			goto error;
 		}
-		chain_sz++;
-		prev->next = buf;
+		__skb_queue_tail(list, skb);
 		msg_set_type(&pkthdr, FRAGMENT);
 		msg_set_size(&pkthdr, pktsz);
 		msg_set_fragm_no(&pkthdr, ++pktno);
-		skb_copy_to_linear_data(buf, &pkthdr, INT_H_SIZE);
-		pktpos = buf->data + INT_H_SIZE;
+		skb_copy_to_linear_data(skb, &pkthdr, INT_H_SIZE);
+		pktpos = skb->data + INT_H_SIZE;
 		pktrem = pktsz - INT_H_SIZE;
 
 	} while (1);
-	TIPC_SKB_CB(*chain)->chain_sz = chain_sz;
-	msg_set_type(buf_msg(buf), LAST_FRAGMENT);
+	msg_set_type(buf_msg(skb), LAST_FRAGMENT);
 	return dsz;
 error:
-	kfree_skb_list(*chain);
-	*chain = NULL;
+	__skb_queue_purge(list);
+	__skb_queue_head_init(list);
 	return rc;
 }
 
@@ -430,22 +428,23 @@ int tipc_msg_eval(struct sk_buff *buf, u32 *dnode)
 /* tipc_msg_reassemble() - clone a buffer chain of fragments and
  *                         reassemble the clones into one message
  */
-struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain)
+struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list)
 {
-	struct sk_buff *buf = chain;
-	struct sk_buff *frag = buf;
+	struct sk_buff *skb;
+	struct sk_buff *frag = NULL;
 	struct sk_buff *head = NULL;
 	int hdr_sz;
 
 	/* Copy header if single buffer */
-	if (!buf->next) {
-		hdr_sz = skb_headroom(buf) + msg_hdr_sz(buf_msg(buf));
-		return __pskb_copy(buf, hdr_sz, GFP_ATOMIC);
+	if (skb_queue_len(list) == 1) {
+		skb = skb_peek(list);
+		hdr_sz = skb_headroom(skb) + msg_hdr_sz(buf_msg(skb));
+		return __pskb_copy(skb, hdr_sz, GFP_ATOMIC);
 	}
 
 	/* Clone all fragments and reassemble */
-	while (buf) {
-		frag = skb_clone(buf, GFP_ATOMIC);
+	skb_queue_walk(list, skb) {
+		frag = skb_clone(skb, GFP_ATOMIC);
 		if (!frag)
 			goto error;
 		frag->next = NULL;
@@ -453,7 +452,6 @@ struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain)
 			break;
 		if (!head)
 			goto error;
-		buf = buf->next;
 	}
 	return frag;
 error:
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 53e425f..d5c83d7 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -739,9 +739,9 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
 bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
 			  u32 mtu, u32 dnode);
 
-int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
-		   int offset, int dsz, int mtu , struct sk_buff **chain);
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
+		   int dsz, int mtu, struct sk_buff_head *list);
 
-struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain);
+struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
 #endif
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 6c2638d..56248db 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -114,9 +114,9 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 	return buf;
 }
 
-void named_cluster_distribute(struct sk_buff *buf)
+void named_cluster_distribute(struct sk_buff *skb)
 {
-	struct sk_buff *obuf;
+	struct sk_buff *oskb;
 	struct tipc_node *node;
 	u32 dnode;
 
@@ -127,15 +127,15 @@ void named_cluster_distribute(struct sk_buff *buf)
 			continue;
 		if (!tipc_node_active_links(node))
 			continue;
-		obuf = skb_copy(buf, GFP_ATOMIC);
-		if (!obuf)
+		oskb = skb_copy(skb, GFP_ATOMIC);
+		if (!oskb)
 			break;
-		msg_set_destnode(buf_msg(obuf), dnode);
-		tipc_link_xmit(obuf, dnode, dnode);
+		msg_set_destnode(buf_msg(oskb), dnode);
+		tipc_link_xmit_skb(oskb, dnode, dnode);
 	}
 	rcu_read_unlock();
 
-	kfree_skb(buf);
+	kfree_skb(skb);
 }
 
 /**
@@ -190,15 +190,15 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
 
 /**
  * named_distribute - prepare name info for bulk distribution to another node
- * @msg_list: list of messages (buffers) to be returned from this function
+ * @list: list of messages (buffers) to be returned from this function
  * @dnode: node to be updated
  * @pls: linked list of publication items to be packed into buffer chain
  */
-static void named_distribute(struct list_head *msg_list, u32 dnode,
+static void named_distribute(struct sk_buff_head *list, u32 dnode,
 			     struct publ_list *pls)
 {
 	struct publication *publ;
-	struct sk_buff *buf = NULL;
+	struct sk_buff *skb = NULL;
 	struct distr_item *item = NULL;
 	uint dsz = pls->size * ITEM_SIZE;
 	uint msg_dsz = (tipc_node_get_mtu(dnode, 0) / ITEM_SIZE) * ITEM_SIZE;
@@ -207,15 +207,15 @@ static void named_distribute(struct list_head *msg_list, u32 dnode,
 
 	list_for_each_entry(publ, &pls->list, local_list) {
 		/* Prepare next buffer: */
-		if (!buf) {
+		if (!skb) {
 			msg_rem = min_t(uint, rem, msg_dsz);
 			rem -= msg_rem;
-			buf = named_prepare_buf(PUBLICATION, msg_rem, dnode);
-			if (!buf) {
+			skb = named_prepare_buf(PUBLICATION, msg_rem, dnode);
+			if (!skb) {
 				pr_warn("Bulk publication failure\n");
 				return;
 			}
-			item = (struct distr_item *)msg_data(buf_msg(buf));
+			item = (struct distr_item *)msg_data(buf_msg(skb));
 		}
 
 		/* Pack publication into message: */
@@ -225,8 +225,8 @@ static void named_distribute(struct list_head *msg_list, u32 dnode,
 
 		/* Append full buffer to list: */
 		if (!msg_rem) {
-			list_add_tail((struct list_head *)buf, msg_list);
-			buf = NULL;
+			__skb_queue_tail(list, skb);
+			skb = NULL;
 		}
 	}
 }
@@ -236,18 +236,16 @@ static void named_distribute(struct list_head *msg_list, u32 dnode,
  */
 void tipc_named_node_up(u32 dnode)
 {
-	LIST_HEAD(msg_list);
-	struct sk_buff *buf_chain;
+	struct sk_buff_head head;
+
+	__skb_queue_head_init(&head);
 
 	read_lock_bh(&tipc_nametbl_lock);
-	named_distribute(&msg_list, dnode, &publ_cluster);
-	named_distribute(&msg_list, dnode, &publ_zone);
+	named_distribute(&head, dnode, &publ_cluster);
+	named_distribute(&head, dnode, &publ_zone);
 	read_unlock_bh(&tipc_nametbl_lock);
 
-	/* Convert circular list to linear list and send: */
-	buf_chain = (struct sk_buff *)msg_list.next;
-	((struct sk_buff *)msg_list.prev)->next = NULL;
-	tipc_link_xmit(buf_chain, dnode, dnode);
+	tipc_link_xmit(&head, dnode, dnode);
 }
 
 static void tipc_publ_subscribe(struct publication *publ, u32 addr)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 341fbd1..9658d9b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -244,12 +244,12 @@ static void tsk_advance_rx_queue(struct sock *sk)
  */
 static void tsk_rej_rx_queue(struct sock *sk)
 {
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 	u32 dnode;
 
-	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
-		if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
-			tipc_link_xmit(buf, dnode, 0);
+	while ((skb = __skb_dequeue(&sk->sk_receive_queue))) {
+		if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
+			tipc_link_xmit_skb(skb, dnode, 0);
 	}
 }
 
@@ -462,7 +462,7 @@ static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk;
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 	u32 dnode;
 
 	/*
@@ -481,11 +481,11 @@ static int tipc_release(struct socket *sock)
 	 */
 	dnode = tsk_peer_node(tsk);
 	while (sock->state != SS_DISCONNECTING) {
-		buf = __skb_dequeue(&sk->sk_receive_queue);
-		if (buf == NULL)
+		skb = __skb_dequeue(&sk->sk_receive_queue);
+		if (skb == NULL)
 			break;
-		if (TIPC_SKB_CB(buf)->handle != NULL)
-			kfree_skb(buf);
+		if (TIPC_SKB_CB(skb)->handle != NULL)
+			kfree_skb(skb);
 		else {
 			if ((sock->state == SS_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
@@ -493,8 +493,8 @@ static int tipc_release(struct socket *sock)
 				tsk->connected = 0;
 				tipc_node_remove_conn(dnode, tsk->ref);
 			}
-			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
-				tipc_link_xmit(buf, dnode, 0);
+			if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
+				tipc_link_xmit_skb(skb, dnode, 0);
 		}
 	}
 
@@ -502,12 +502,12 @@ static int tipc_release(struct socket *sock)
 	tipc_sk_ref_discard(tsk->ref);
 	k_cancel_timer(&tsk->timer);
 	if (tsk->connected) {
-		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, dnode, tipc_own_addr,
 				      tsk_peer_port(tsk),
 				      tsk->ref, TIPC_ERR_NO_PORT);
-		if (buf)
-			tipc_link_xmit(buf, dnode, tsk->ref);
+		if (skb)
+			tipc_link_xmit_skb(skb, dnode, tsk->ref);
 		tipc_node_remove_conn(dnode, tsk->ref);
 	}
 	k_term_timer(&tsk->timer);
@@ -712,7 +712,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_msg *mhdr = &tipc_sk(sk)->phdr;
-	struct sk_buff *buf;
+	struct sk_buff_head head;
 	uint mtu;
 	int rc;
 
@@ -727,12 +727,13 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &buf);
+	__skb_queue_head_init(&head);
+	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &head);
 	if (unlikely(rc < 0))
 		return rc;
 
 	do {
-		rc = tipc_bclink_xmit(buf);
+		rc = tipc_bclink_xmit(&head);
 		if (likely(rc >= 0)) {
 			rc = dsz;
 			break;
@@ -744,7 +745,7 @@ new_mtu:
 		tipc_sk(sk)->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
-			kfree_skb_list(buf);
+			__skb_queue_purge(&head);
 	} while (!rc);
 	return rc;
 }
@@ -906,7 +907,8 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
 	u32 dnode, dport;
-	struct sk_buff *buf;
+	struct sk_buff_head head;
+	struct sk_buff *skb;
 	struct tipc_name_seq *seq = &dest->addr.nameseq;
 	u32 mtu;
 	long timeo;
@@ -981,13 +983,15 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 new_mtu:
 	mtu = tipc_node_get_mtu(dnode, tsk->ref);
-	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &buf);
+	__skb_queue_head_init(&head);
+	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &head);
 	if (rc < 0)
 		goto exit;
 
 	do {
-		TIPC_SKB_CB(buf)->wakeup_pending = tsk->link_cong;
-		rc = tipc_link_xmit(buf, dnode, tsk->ref);
+		skb = skb_peek(&head);
+		TIPC_SKB_CB(skb)->wakeup_pending = tsk->link_cong;
+		rc = tipc_link_xmit(&head, dnode, tsk->ref);
 		if (likely(rc >= 0)) {
 			if (sock->state != SS_READY)
 				sock->state = SS_CONNECTING;
@@ -1001,7 +1005,7 @@ new_mtu:
 		tsk->link_cong = 1;
 		rc = tipc_wait_for_sndmsg(sock, &timeo);
 		if (rc)
-			kfree_skb_list(buf);
+			__skb_queue_purge(&head);
 	} while (!rc);
 exit:
 	if (iocb)
@@ -1058,7 +1062,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
-	struct sk_buff *buf;
+	struct sk_buff_head head;
 	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	u32 ref = tsk->ref;
 	int rc = -EINVAL;
@@ -1093,12 +1097,13 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 next:
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
-	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &buf);
+	__skb_queue_head_init(&head);
+	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &head);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
 		if (likely(!tsk_conn_cong(tsk))) {
-			rc = tipc_link_xmit(buf, dnode, ref);
+			rc = tipc_link_xmit(&head, dnode, ref);
 			if (likely(!rc)) {
 				tsk->sent_unacked++;
 				sent += send;
@@ -1116,7 +1121,7 @@ next:
 		}
 		rc = tipc_wait_for_sndpkt(sock, &timeo);
 		if (rc)
-			kfree_skb_list(buf);
+			__skb_queue_purge(&head);
 	} while (!rc);
 exit:
 	if (iocb)
@@ -1261,20 +1266,20 @@ static int tipc_sk_anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 
 static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 {
-	struct sk_buff *buf = NULL;
+	struct sk_buff *skb = NULL;
 	struct tipc_msg *msg;
 	u32 peer_port = tsk_peer_port(tsk);
 	u32 dnode = tsk_peer_node(tsk);
 
 	if (!tsk->connected)
 		return;
-	buf = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0, dnode,
+	skb = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0, dnode,
 			      tipc_own_addr, peer_port, tsk->ref, TIPC_OK);
-	if (!buf)
+	if (!skb)
 		return;
-	msg = buf_msg(buf);
+	msg = buf_msg(skb);
 	msg_set_msgcnt(msg, ack);
-	tipc_link_xmit(buf, dnode, msg_link_selector(msg));
+	tipc_link_xmit_skb(skb, dnode, msg_link_selector(msg));
 }
 
 static int tipc_wait_for_rcvmsg(struct socket *sock, long *timeop)
@@ -1729,20 +1734,20 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 /**
  * tipc_backlog_rcv - handle incoming message from backlog queue
  * @sk: socket
- * @buf: message
+ * @skb: message
  *
  * Caller must hold socket lock, but not port lock.
  *
  * Returns 0
  */
-static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
+static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 	u32 onode;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	uint truesize = buf->truesize;
+	uint truesize = skb->truesize;
 
-	rc = filter_rcv(sk, buf);
+	rc = filter_rcv(sk, skb);
 
 	if (likely(!rc)) {
 		if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
@@ -1750,25 +1755,25 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 		return 0;
 	}
 
-	if ((rc < 0) && !tipc_msg_reverse(buf, &onode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(skb, &onode, -rc))
 		return 0;
 
-	tipc_link_xmit(buf, onode, 0);
+	tipc_link_xmit_skb(skb, onode, 0);
 
 	return 0;
 }
 
 /**
  * tipc_sk_rcv - handle incoming message
- * @buf: buffer containing arriving message
+ * @skb: buffer containing arriving message
  * Consumes buffer
  * Returns 0 if success, or errno: -EHOSTUNREACH
  */
-int tipc_sk_rcv(struct sk_buff *buf)
+int tipc_sk_rcv(struct sk_buff *skb)
 {
 	struct tipc_sock *tsk;
 	struct sock *sk;
-	u32 dport = msg_destport(buf_msg(buf));
+	u32 dport = msg_destport(buf_msg(skb));
 	int rc = TIPC_OK;
 	uint limit;
 	u32 dnode;
@@ -1776,7 +1781,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	/* Validate destination and message */
 	tsk = tipc_sk_get(dport);
 	if (unlikely(!tsk)) {
-		rc = tipc_msg_eval(buf, &dnode);
+		rc = tipc_msg_eval(skb, &dnode);
 		goto exit;
 	}
 	sk = &tsk->sk;
@@ -1785,12 +1790,12 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	spin_lock_bh(&sk->sk_lock.slock);
 
 	if (!sock_owned_by_user(sk)) {
-		rc = filter_rcv(sk, buf);
+		rc = filter_rcv(sk, skb);
 	} else {
 		if (sk->sk_backlog.len == 0)
 			atomic_set(&tsk->dupl_rcvcnt, 0);
-		limit = rcvbuf_limit(sk, buf) + atomic_read(&tsk->dupl_rcvcnt);
-		if (sk_add_backlog(sk, buf, limit))
+		limit = rcvbuf_limit(sk, skb) + atomic_read(&tsk->dupl_rcvcnt);
+		if (sk_add_backlog(sk, skb, limit))
 			rc = -TIPC_ERR_OVERLOAD;
 	}
 	spin_unlock_bh(&sk->sk_lock.slock);
@@ -1798,10 +1803,10 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	if (likely(!rc))
 		return 0;
 exit:
-	if ((rc < 0) && !tipc_msg_reverse(buf, &dnode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(skb, &dnode, -rc))
 		return -EHOSTUNREACH;
 
-	tipc_link_xmit(buf, dnode, 0);
+	tipc_link_xmit_skb(skb, dnode, 0);
 	return (rc < 0) ? -EHOSTUNREACH : 0;
 }
 
@@ -2059,7 +2064,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
-	struct sk_buff *buf;
+	struct sk_buff *skb;
 	u32 dnode;
 	int res;
 
@@ -2074,23 +2079,23 @@ static int tipc_shutdown(struct socket *sock, int how)
 
 restart:
 		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
-		buf = __skb_dequeue(&sk->sk_receive_queue);
-		if (buf) {
-			if (TIPC_SKB_CB(buf)->handle != NULL) {
-				kfree_skb(buf);
+		skb = __skb_dequeue(&sk->sk_receive_queue);
+		if (skb) {
+			if (TIPC_SKB_CB(skb)->handle != NULL) {
+				kfree_skb(skb);
 				goto restart;
 			}
-			if (tipc_msg_reverse(buf, &dnode, TIPC_CONN_SHUTDOWN))
-				tipc_link_xmit(buf, dnode, tsk->ref);
+			if (tipc_msg_reverse(skb, &dnode, TIPC_CONN_SHUTDOWN))
+				tipc_link_xmit_skb(skb, dnode, tsk->ref);
 			tipc_node_remove_conn(dnode, tsk->ref);
 		} else {
 			dnode = tsk_peer_node(tsk);
-			buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
+			skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
 					      TIPC_CONN_MSG, SHORT_H_SIZE,
 					      0, dnode, tipc_own_addr,
 					      tsk_peer_port(tsk),
 					      tsk->ref, TIPC_CONN_SHUTDOWN);
-			tipc_link_xmit(buf, dnode, tsk->ref);
+			tipc_link_xmit_skb(skb, dnode, tsk->ref);
 		}
 		tsk->connected = 0;
 		sock->state = SS_DISCONNECTING;
@@ -2119,7 +2124,7 @@ static void tipc_sk_timeout(unsigned long ref)
 {
 	struct tipc_sock *tsk;
 	struct sock *sk;
-	struct sk_buff *buf = NULL;
+	struct sk_buff *skb = NULL;
 	u32 peer_port, peer_node;
 
 	tsk = tipc_sk_get(ref);
@@ -2137,20 +2142,20 @@ static void tipc_sk_timeout(unsigned long ref)
 
 	if (tsk->probing_state == TIPC_CONN_PROBING) {
 		/* Previous probe not answered -> self abort */
-		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
 				      SHORT_H_SIZE, 0, tipc_own_addr,
 				      peer_node, ref, peer_port,
 				      TIPC_ERR_NO_PORT);
 	} else {
-		buf = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
+		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
 				      0, peer_node, tipc_own_addr,
 				      peer_port, ref, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
 		k_start_timer(&tsk->timer, tsk->probing_interval);
 	}
 	bh_unlock_sock(sk);
-	if (buf)
-		tipc_link_xmit(buf, peer_node, ref);
+	if (skb)
+		tipc_link_xmit_skb(skb, peer_node, ref);
 exit:
 	tipc_sk_put(tsk);
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
