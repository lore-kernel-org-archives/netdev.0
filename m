From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 03/13] tipc: introduce send functions for chained buffers in link
Date: Wed, 25 Jun 2014 20:41:32 -0500
Message-ID: <1403746902-20408-4-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24128 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757251AbaFZBsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:50 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current link implementation provides several different transmit
functions, depending on the characteristics of the message to be
sent: if it is an iovec or an sk_buff, if it needs fragmentation or
not, if the caller holds the node_lock or not. The permutation of
these options gives us an unwanted amount of unnecessarily complex
code.

As a first step towards simplifying the send path for all messages,
we introduce two new send functions at link level, tipc_link_xmit2()
and __tipc_link_xmit2(). The former looks up a link to the message
destination, and if one is found, it grabs the node lock and calls
the second function, which works exclusively inside the node lock
protection. If no link is found, and the destination is on the same
node, it delivers the message directly to the local destination
socket.

The new functions take a buffer chain where all packet headers are
already prepared, and the correct MTU has been used. These two
functions will later replace all other link-level transmit functions.

The functions are not backwards compatible, so we have added them
as new functions with temporary names. They are tested, but have no
users yet. Those will be added later in this series.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |  140 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/tipc/link.h |    2 +
 net/tipc/msg.c  |   96 +++++++++++++++++++++++++++++++++-----
 net/tipc/msg.h  |   25 +++++++++-
 4 files changed, 250 insertions(+), 13 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index ad2c57f..68d2afb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -850,6 +850,144 @@ int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector)
 	return res;
 }
 
+/* tipc_link_cong: determine return value and how to treat the
+ * sent buffer during link congestion.
+ * - For plain, errorless user data messages we keep the buffer and
+ *   return -ELINKONG.
+ * - For all other messages we discard the buffer and return -EHOSTUNREACH
+ * - For TIPC internal messages we also reset the link
+ */
+static int tipc_link_cong(struct tipc_link *link, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	uint psz = msg_size(msg);
+	uint imp = tipc_msg_tot_importance(msg);
+	u32 oport = msg_tot_origport(msg);
+
+	if (likely(imp <= TIPC_CRITICAL_IMPORTANCE)) {
+		if (!msg_errcode(msg) && !msg_reroute_cnt(msg)) {
+			link_schedule_port(link, oport, psz);
+			return -ELINKCONG;
+		}
+	} else {
+		pr_warn("%s<%s>, send queue full", link_rst_msg, link->name);
+		tipc_link_reset(link);
+	}
+	kfree_skb_list(buf);
+	return -EHOSTUNREACH;
+}
+
+/**
+ * __tipc_link_xmit2(): same as tipc_link_xmit2, but destlink is known & locked
+ * @link: link to use
+ * @buf: chain of buffers containing message
+ * Consumes the buffer chain, except when returning -ELINKCONG
+ * Returns 0 if success, otherwise errno: -ELINKCONG, -EMSGSIZE (plain socket
+ * user data messages) or -EHOSTUNREACH (all other messages/senders)
+ * Only the socket functions tipc_send_stream() and tipc_send_packet() need
+ * to act on the return value, since they may need to do more send attempts.
+ */
+int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	uint psz = msg_size(msg);
+	uint qsz = link->out_queue_size;
+	uint sndlim = link->queue_limit[0];
+	uint imp = tipc_msg_tot_importance(msg);
+	uint mtu = link->max_pkt;
+	uint ack = mod(link->next_in_no - 1);
+	uint seqno = link->next_out_no;
+	uint bc_last_in = link->owner->bclink.last_in;
+	struct tipc_media_addr *addr = &link->media_addr;
+	struct sk_buff *next = buf->next;
+
+	/* Match queue limits against msg importance: */
+	if (unlikely(qsz >= link->queue_limit[imp]))
+		return tipc_link_cong(link, buf);
+
+	/* Has valid packet limit been used ? */
+	if (unlikely(psz > mtu)) {
+		kfree_skb_list(buf);
+		return -EMSGSIZE;
+	}
+
+	/* Prepare each packet for sending, and add to outqueue: */
+	while (buf) {
+		next = buf->next;
+		msg = buf_msg(buf);
+		msg_set_word(msg, 2, ((ack << 16) | mod(seqno)));
+		msg_set_bcast_ack(msg, bc_last_in);
+
+		if (!link->first_out) {
+			link->first_out = buf;
+		} else if (qsz < sndlim) {
+			link->last_out->next = buf;
+		} else if (tipc_msg_bundle(link->last_out, buf, mtu)) {
+			link->stats.sent_bundled++;
+			buf = next;
+			next = buf->next;
+			continue;
+		} else if (tipc_msg_make_bundle(&buf, mtu, link->addr)) {
+			link->stats.sent_bundled++;
+			link->stats.sent_bundles++;
+			link->last_out->next = buf;
+			if (!link->next_out)
+				link->next_out = buf;
+		} else {
+			link->last_out->next = buf;
+			if (!link->next_out)
+				link->next_out = buf;
+		}
+
+		/* Send packet if possible: */
+		if (likely(++qsz <= sndlim)) {
+			tipc_bearer_send(link->bearer_id, buf, addr);
+			link->next_out = next;
+			link->unacked_window = 0;
+		}
+		seqno++;
+		link->last_out = buf;
+		buf = next;
+	}
+	link->next_out_no = seqno;
+	link->out_queue_size = qsz;
+	return 0;
+}
+
+/**
+ * tipc_link_xmit2() is the general link level function for message sending
+ * @buf: chain of buffers containing message
+ * @dsz: amount of user data to be sent
+ * @dnode: address of destination node
+ * @selector: a number used for deterministic link selection
+ * Consumes the buffer chain, except when returning -ELINKCONG
+ * Returns 0 if success, otherwise errno: -ELINKCONG,-EHOSTUNREACH,-EMSGSIZE
+ */
+int tipc_link_xmit2(struct sk_buff *buf, u32 dnode, u32 selector)
+{
+	struct tipc_link *link = NULL;
+	struct tipc_node *node;
+	int rc = -EHOSTUNREACH;
+
+	node = tipc_node_find(dnode);
+	if (node) {
+		tipc_node_lock(node);
+		link = node->active_links[selector & 1];
+		if (link)
+			rc = __tipc_link_xmit2(link, buf);
+		tipc_node_unlock(node);
+	}
+
+	if (link)
+		return rc;
+
+	if (likely(in_own_node(dnode)))
+		return tipc_sk_rcv(buf);
+
+	kfree_skb_list(buf);
+	return rc;
+}
+
 /*
  * tipc_link_sync_xmit - synchronize broadcast link endpoints.
  *
@@ -1238,7 +1376,7 @@ static u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 			tipc_bearer_send(l_ptr->bearer_id, buf,
 					 &l_ptr->media_addr);
 			if (msg_user(msg) == MSG_BUNDLER)
-				msg_set_type(msg, CLOSED_MSG);
+				msg_set_type(msg, BUNDLE_CLOSED);
 			l_ptr->next_out = buf->next;
 			return 0;
 		}
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 200d518..227ff81 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -227,8 +227,10 @@ void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
+int tipc_link_xmit2(struct sk_buff *buf, u32 dest, u32 selector);
 void tipc_link_names_xmit(struct list_head *message_list, u32 dest);
 int __tipc_link_xmit(struct tipc_link *l_ptr, struct sk_buff *buf);
+int __tipc_link_xmit2(struct tipc_link *link, struct sk_buff *buf);
 int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
 int tipc_link_iovec_xmit_fast(struct tipc_port *sender,
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 8be6e94..e02afc9 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -37,20 +37,11 @@
 #include "core.h"
 #include "msg.h"
 
-u32 tipc_msg_tot_importance(struct tipc_msg *m)
+static unsigned int align(unsigned int i)
 {
-	if (likely(msg_isdata(m))) {
-		if (likely(msg_orignode(m) == tipc_own_addr))
-			return msg_importance(m);
-		return msg_importance(m) + 4;
-	}
-	if ((msg_user(m) == MSG_FRAGMENTER)  &&
-	    (msg_type(m) == FIRST_FRAGMENT))
-		return msg_importance(msg_get_wrapped(m));
-	return msg_importance(m);
+	return (i + 3) & ~3u;
 }
 
-
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode)
 {
@@ -152,3 +143,86 @@ out_free:
 	kfree_skb(*buf);
 	return 0;
 }
+
+/**
+ * tipc_msg_bundle(): Append contents of a buffer to tail of an existing one
+ * @bbuf: the existing buffer ("bundle")
+ * @buf:  buffer to be appended
+ * @mtu:  max allowable size for the bundle buffer
+ * Consumes buffer if successful
+ * Returns true if bundling could be performed, otherwise false
+ */
+bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu)
+{
+	struct tipc_msg *bmsg = buf_msg(bbuf);
+	struct tipc_msg *msg = buf_msg(buf);
+	unsigned int bsz = msg_size(bmsg);
+	unsigned int msz = msg_size(msg);
+	u32 start = align(bsz);
+	u32 max = mtu - INT_H_SIZE;
+	u32 pad = start - bsz;
+
+	if (likely(msg_user(msg) == MSG_FRAGMENTER))
+		return false;
+	if (unlikely(msg_user(msg) == CHANGEOVER_PROTOCOL))
+		return false;
+	if (unlikely(msg_user(msg) == BCAST_PROTOCOL))
+		return false;
+	if (likely(msg_user(bmsg) != MSG_BUNDLER))
+		return false;
+	if (likely(msg_type(bmsg) != BUNDLE_OPEN))
+		return false;
+	if (unlikely(skb_tailroom(bbuf) < (pad + msz)))
+		return false;
+	if (unlikely(max < (start + msz)))
+		return false;
+
+	skb_put(bbuf, pad + msz);
+	skb_copy_to_linear_data_offset(bbuf, start, buf->data, msz);
+	msg_set_size(bmsg, start + msz);
+	msg_set_msgcnt(bmsg, msg_msgcnt(bmsg) + 1);
+	bbuf->next = buf->next;
+	kfree_skb(buf);
+	return true;
+}
+
+/**
+ * tipc_msg_make_bundle(): Create bundle buf and append message to its tail
+ * @buf:  buffer to be appended and replaced
+ * @mtu:  max allowable size for the bundle buffer, inclusive header
+ * @dnode: destination node for message. (Not always present in header)
+ * Replaces buffer if successful
+ * Returns true if sucess, otherwise false
+ */
+bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
+{
+	struct sk_buff *bbuf;
+	struct tipc_msg *bmsg;
+	struct tipc_msg *msg = buf_msg(*buf);
+	u32 msz = msg_size(msg);
+	u32 max = mtu - INT_H_SIZE;
+
+	if (msg_user(msg) == MSG_FRAGMENTER)
+		return false;
+	if (msg_user(msg) == CHANGEOVER_PROTOCOL)
+		return false;
+	if (msg_user(msg) == BCAST_PROTOCOL)
+		return false;
+	if (msz > (max / 2))
+		return false;
+
+	bbuf = tipc_buf_acquire(max);
+	if (!bbuf)
+		return false;
+
+	skb_trim(bbuf, INT_H_SIZE);
+	bmsg = buf_msg(bbuf);
+	tipc_msg_init(bmsg, MSG_BUNDLER, BUNDLE_OPEN, INT_H_SIZE, dnode);
+	msg_set_seqno(bmsg, msg_seqno(msg));
+	msg_set_ack(bmsg, msg_ack(msg));
+	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
+	bbuf->next = (*buf)->next;
+	tipc_msg_bundle(bbuf, *buf, mtu);
+	*buf = bbuf;
+	return true;
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5035119..41a05fa 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -463,6 +463,11 @@ static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
 #define FRAGMENT		1
 #define LAST_FRAGMENT		2
 
+/* Bundling protocol message types
+ */
+#define BUNDLE_OPEN             0
+#define BUNDLE_CLOSED           1
+
 /*
  * Link management protocol message types
  */
@@ -706,12 +711,30 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 9, 0, 0xffff, n);
 }
 
-u32 tipc_msg_tot_importance(struct tipc_msg *m);
+static inline u32 tipc_msg_tot_importance(struct tipc_msg *m)
+{
+	if ((msg_user(m) == MSG_FRAGMENTER) && (msg_type(m) == FIRST_FRAGMENT))
+		return msg_importance(msg_get_wrapped(m));
+	return msg_importance(m);
+}
+
+static inline u32 msg_tot_origport(struct tipc_msg *m)
+{
+	if ((msg_user(m) == MSG_FRAGMENTER) && (msg_type(m) == FIRST_FRAGMENT))
+		return msg_origport(msg_get_wrapped(m));
+	return msg_origport(m);
+}
+
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
+
 int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   unsigned int len, int max_size, struct sk_buff **buf);
 
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 
+bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
+
+bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
+
 #endif
-- 
1.7.9.5
