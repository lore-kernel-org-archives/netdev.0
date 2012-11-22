From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/9] tipc: remove the bearer congestion mechanism
Date: Thu, 22 Nov 2012 15:59:49 -0500
Message-ID: <1353617994-3962-5-git-send-email-paul.gortmaker@windriver.com>
References: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59982 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757583Ab2KVVAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:08 -0500
In-Reply-To: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Currently at the TIPC bearer layer there is the following congestion
mechanism:

Once sending packets has failed via that bearer, the bearer will be
flagged as being in congested state at once. During bearer congestion,
all packets arriving at link will be queued on the link's outgoing
buffer.  When we detect that the state of bearer congestion has
relaxed (e.g. some packets are received from the bearer) we will try
our best to push all packets in the link's outgoing buffer until the
buffer is empty, or until the bearer is congested again.

However, in fact the TIPC bearer never receives any feedback from the
device layer whether a send was successful or not, so it must always
assume it was successful. Therefore, the bearer congestion mechanism
as it exists currently is of no value.

But the bearer blocking state is still useful for us. For example,
when the physical media goes down/up, we need to change the state of
the links bound to the bearer.  So the code maintaing the state
information is not removed.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c    |  21 ++++------
 net/tipc/bearer.c   | 110 +++++-------------------------------------------
 net/tipc/bearer.h   |  24 ++---------
 net/tipc/discover.c |   2 +-
 net/tipc/link.c     | 117 +++++++++++++++++-----------------------------------
 net/tipc/link.h     |   4 --
 6 files changed, 61 insertions(+), 217 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e4e6d8c..40da098 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -619,16 +619,14 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		if (bcbearer->remains_new.count == bcbearer->remains.count)
 			continue;	/* bearer pair doesn't add anything */
 
-		if (p->blocked ||
-		    p->media->send_msg(buf, p, &p->media->bcast_addr)) {
+		if (!tipc_bearer_blocked(p))
+			tipc_bearer_send(p, buf, &p->media->bcast_addr);
+		else if (s && !tipc_bearer_blocked(s))
 			/* unable to send on primary bearer */
-			if (!s || s->blocked ||
-			    s->media->send_msg(buf, s,
-					       &s->media->bcast_addr)) {
-				/* unable to send on either bearer */
-				continue;
-			}
-		}
+			tipc_bearer_send(s, buf, &s->media->bcast_addr);
+		else
+			/* unable to send on either bearer */
+			continue;
 
 		if (s) {
 			bcbearer->bpairs[bp_index].primary = s;
@@ -731,8 +729,8 @@ int tipc_bclink_stats(char *buf, const u32 buf_size)
 			     "  TX naks:%u acks:%u dups:%u\n",
 			     s->sent_nacks, s->sent_acks, s->retransmitted);
 	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion bearer:%u link:%u  Send queue max:%u avg:%u\n",
-			     s->bearer_congs, s->link_congs, s->max_queue_sz,
+			     "  Congestion link:%u  Send queue max:%u avg:%u\n",
+			     s->link_congs, s->max_queue_sz,
 			     s->queue_sz_counts ?
 			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
@@ -766,7 +764,6 @@ int tipc_bclink_set_queue_limits(u32 limit)
 
 void tipc_bclink_init(void)
 {
-	INIT_LIST_HEAD(&bcbearer->bearer.cong_links);
 	bcbearer->bearer.media = &bcbearer->media;
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-broadcast");
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 4ec5c80..aa62f93 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -279,116 +279,31 @@ void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest)
 }
 
 /*
- * bearer_push(): Resolve bearer congestion. Force the waiting
- * links to push out their unsent packets, one packet per link
- * per iteration, until all packets are gone or congestion reoccurs.
- * 'tipc_net_lock' is read_locked when this function is called
- * bearer.lock must be taken before calling
- * Returns binary true(1) ore false(0)
- */
-static int bearer_push(struct tipc_bearer *b_ptr)
-{
-	u32 res = 0;
-	struct tipc_link *ln, *tln;
-
-	if (b_ptr->blocked)
-		return 0;
-
-	while (!list_empty(&b_ptr->cong_links) && (res != PUSH_FAILED)) {
-		list_for_each_entry_safe(ln, tln, &b_ptr->cong_links, link_list) {
-			res = tipc_link_push_packet(ln);
-			if (res == PUSH_FAILED)
-				break;
-			if (res == PUSH_FINISHED)
-				list_move_tail(&ln->link_list, &b_ptr->links);
-		}
-	}
-	return list_empty(&b_ptr->cong_links);
-}
-
-void tipc_bearer_lock_push(struct tipc_bearer *b_ptr)
-{
-	spin_lock_bh(&b_ptr->lock);
-	bearer_push(b_ptr);
-	spin_unlock_bh(&b_ptr->lock);
-}
-
-
-/*
- * Interrupt enabling new requests after bearer congestion or blocking:
+ * Interrupt enabling new requests after bearer blocking:
  * See bearer_send().
  */
-void tipc_continue(struct tipc_bearer *b_ptr)
+void tipc_continue(struct tipc_bearer *b)
 {
-	spin_lock_bh(&b_ptr->lock);
-	if (!list_empty(&b_ptr->cong_links))
-		tipc_k_signal((Handler)tipc_bearer_lock_push, (unsigned long)b_ptr);
-	b_ptr->blocked = 0;
-	spin_unlock_bh(&b_ptr->lock);
+	spin_lock_bh(&b->lock);
+	b->blocked = 0;
+	spin_unlock_bh(&b->lock);
 }
 
 /*
- * Schedule link for sending of messages after the bearer
- * has been deblocked by 'continue()'. This method is called
- * when somebody tries to send a message via this link while
- * the bearer is congested. 'tipc_net_lock' is in read_lock here
- * bearer.lock is busy
+ * tipc_bearer_blocked - determines if bearer is currently blocked
  */
-static void tipc_bearer_schedule_unlocked(struct tipc_bearer *b_ptr,
-						struct tipc_link *l_ptr)
+int tipc_bearer_blocked(struct tipc_bearer *b)
 {
-	list_move_tail(&l_ptr->link_list, &b_ptr->cong_links);
-}
-
-/*
- * Schedule link for sending of messages after the bearer
- * has been deblocked by 'continue()'. This method is called
- * when somebody tries to send a message via this link while
- * the bearer is congested. 'tipc_net_lock' is in read_lock here,
- * bearer.lock is free
- */
-void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
-{
-	spin_lock_bh(&b_ptr->lock);
-	tipc_bearer_schedule_unlocked(b_ptr, l_ptr);
-	spin_unlock_bh(&b_ptr->lock);
-}
-
+	int res;
 
-/*
- * tipc_bearer_resolve_congestion(): Check if there is bearer congestion,
- * and if there is, try to resolve it before returning.
- * 'tipc_net_lock' is read_locked when this function is called
- */
-int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr,
-					struct tipc_link *l_ptr)
-{
-	int res = 1;
+	spin_lock_bh(&b->lock);
+	res = b->blocked;
+	spin_unlock_bh(&b->lock);
 
-	if (list_empty(&b_ptr->cong_links))
-		return 1;
-	spin_lock_bh(&b_ptr->lock);
-	if (!bearer_push(b_ptr)) {
-		tipc_bearer_schedule_unlocked(b_ptr, l_ptr);
-		res = 0;
-	}
-	spin_unlock_bh(&b_ptr->lock);
 	return res;
 }
 
 /**
- * tipc_bearer_congested - determines if bearer is currently congested
- */
-int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr)
-{
-	if (unlikely(b_ptr->blocked))
-		return 1;
-	if (likely(list_empty(&b_ptr->cong_links)))
-		return 0;
-	return !tipc_bearer_resolve_congestion(b_ptr, l_ptr);
-}
-
-/**
  * tipc_enable_bearer - enable bearer with the given name
  */
 int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
@@ -489,7 +404,6 @@ restart:
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->active = 1;
 	b_ptr->priority = priority;
-	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
 	spin_lock_init(&b_ptr->lock);
 
@@ -528,7 +442,6 @@ int tipc_block_bearer(const char *name)
 	pr_info("Blocking bearer <%s>\n", name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
-	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		struct tipc_node *n_ptr = l_ptr->owner;
 
@@ -555,7 +468,6 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
-	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		tipc_link_delete(l_ptr);
 	}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index dd4c2ab..39f1192 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -120,7 +120,6 @@ struct tipc_media {
  * @identity: array index of this bearer within TIPC bearer array
  * @link_req: ptr to (optional) structure making periodic link setup requests
  * @links: list of non-congested links associated with bearer
- * @cong_links: list of congested links associated with bearer
  * @active: non-zero if bearer structure is represents a bearer
  * @net_plane: network plane ('A' through 'H') currently associated with bearer
  * @nodes: indicates which nodes in cluster can be reached through bearer
@@ -143,7 +142,6 @@ struct tipc_bearer {
 	u32 identity;
 	struct tipc_link_req *link_req;
 	struct list_head links;
-	struct list_head cong_links;
 	int active;
 	char net_plane;
 	struct tipc_node_map nodes;
@@ -185,39 +183,23 @@ struct sk_buff *tipc_media_get_names(void);
 struct sk_buff *tipc_bearer_get_names(void);
 void tipc_bearer_add_dest(struct tipc_bearer *b_ptr, u32 dest);
 void tipc_bearer_remove_dest(struct tipc_bearer *b_ptr, u32 dest);
-void tipc_bearer_schedule(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr);
 struct tipc_bearer *tipc_bearer_find(const char *name);
 struct tipc_bearer *tipc_bearer_find_interface(const char *if_name);
 struct tipc_media *tipc_media_find(const char *name);
-int tipc_bearer_resolve_congestion(struct tipc_bearer *b_ptr,
-				   struct tipc_link *l_ptr);
-int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct tipc_link *l_ptr);
+int tipc_bearer_blocked(struct tipc_bearer *b_ptr);
 void tipc_bearer_stop(void);
-void tipc_bearer_lock_push(struct tipc_bearer *b_ptr);
-
 
 /**
  * tipc_bearer_send- sends buffer to destination over bearer
  *
- * Returns true (1) if successful, or false (0) if unable to send
- *
  * IMPORTANT:
  * The media send routine must not alter the buffer being passed in
  * as it may be needed for later retransmission!
- *
- * If the media send routine returns a non-zero value (indicating that
- * it was unable to send the buffer), it must:
- *   1) mark the bearer as blocked,
- *   2) call tipc_continue() once the bearer is able to send again.
- * Media types that are unable to meet these two critera must ensure their
- * send routine always returns success -- even if the buffer was not sent --
- * and let TIPC's link code deal with the undelivered message.
  */
-static inline int tipc_bearer_send(struct tipc_bearer *b_ptr,
-				   struct sk_buff *buf,
+static inline void tipc_bearer_send(struct tipc_bearer *b, struct sk_buff *buf,
 				   struct tipc_media_addr *dest)
 {
-	return !b_ptr->media->send_msg(buf, b_ptr, dest);
+	b->media->send_msg(buf, b, dest);
 }
 
 #endif	/* _TIPC_BEARER_H */
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 50eaa40..1074b95 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -243,7 +243,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	if ((type == DSC_REQ_MSG) && !link_fully_up && !b_ptr->blocked) {
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
 		if (rbuf) {
-			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
+			tipc_bearer_send(b_ptr, rbuf, &media_addr);
 			kfree_skb(rbuf);
 		}
 	}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a79c755..0cc6480 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -872,17 +872,12 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		return link_send_long_buf(l_ptr, buf);
 
 	/* Packet can be queued or sent. */
-	if (likely(!tipc_bearer_congested(l_ptr->b_ptr, l_ptr) &&
+	if (likely(!tipc_bearer_blocked(l_ptr->b_ptr) &&
 		   !link_congested(l_ptr))) {
 		link_add_to_outqueue(l_ptr, buf, msg);
 
-		if (likely(tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr))) {
-			l_ptr->unacked_window = 0;
-		} else {
-			tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
-			l_ptr->stats.bearer_congs++;
-			l_ptr->next_out = buf;
-		}
+		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		l_ptr->unacked_window = 0;
 		return dsz;
 	}
 	/* Congestion: can message be bundled ? */
@@ -891,10 +886,8 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 
 		/* Try adding message to an existing bundle */
 		if (l_ptr->next_out &&
-		    link_bundle_buf(l_ptr, l_ptr->last_out, buf)) {
-			tipc_bearer_resolve_congestion(l_ptr->b_ptr, l_ptr);
+		    link_bundle_buf(l_ptr, l_ptr->last_out, buf))
 			return dsz;
-		}
 
 		/* Try creating a new bundle */
 		if (size <= max_packet * 2 / 3) {
@@ -917,7 +910,6 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	if (!l_ptr->next_out)
 		l_ptr->next_out = buf;
 	link_add_to_outqueue(l_ptr, buf, msg);
-	tipc_bearer_resolve_congestion(l_ptr->b_ptr, l_ptr);
 	return dsz;
 }
 
@@ -1006,16 +998,11 @@ static int link_send_buf_fast(struct tipc_link *l_ptr, struct sk_buff *buf,
 
 	if (likely(!link_congested(l_ptr))) {
 		if (likely(msg_size(msg) <= l_ptr->max_pkt)) {
-			if (likely(list_empty(&l_ptr->b_ptr->cong_links))) {
+			if (likely(!tipc_bearer_blocked(l_ptr->b_ptr))) {
 				link_add_to_outqueue(l_ptr, buf, msg);
-				if (likely(tipc_bearer_send(l_ptr->b_ptr, buf,
-							    &l_ptr->media_addr))) {
-					l_ptr->unacked_window = 0;
-					return res;
-				}
-				tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
-				l_ptr->stats.bearer_congs++;
-				l_ptr->next_out = buf;
+				tipc_bearer_send(l_ptr->b_ptr, buf,
+						 &l_ptr->media_addr);
+				l_ptr->unacked_window = 0;
 				return res;
 			}
 		} else
@@ -1106,7 +1093,7 @@ exit:
 
 			/* Exit if link (or bearer) is congested */
 			if (link_congested(l_ptr) ||
-			    !list_empty(&l_ptr->b_ptr->cong_links)) {
+			    tipc_bearer_blocked(l_ptr->b_ptr)) {
 				res = link_schedule_port(l_ptr,
 							 sender->ref, res);
 				goto exit;
@@ -1329,15 +1316,11 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	if (r_q_size && buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			l_ptr->retransm_queue_head = mod(++r_q_head);
-			l_ptr->retransm_queue_size = --r_q_size;
-			l_ptr->stats.retransmitted++;
-			return 0;
-		} else {
-			l_ptr->stats.bearer_congs++;
-			return PUSH_FAILED;
-		}
+		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		l_ptr->retransm_queue_head = mod(++r_q_head);
+		l_ptr->retransm_queue_size = --r_q_size;
+		l_ptr->stats.retransmitted++;
+		return 0;
 	}
 
 	/* Send deferred protocol message, if any: */
@@ -1345,15 +1328,11 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 	if (buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
-		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			l_ptr->unacked_window = 0;
-			kfree_skb(buf);
-			l_ptr->proto_msg_queue = NULL;
-			return 0;
-		} else {
-			l_ptr->stats.bearer_congs++;
-			return PUSH_FAILED;
-		}
+		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		l_ptr->unacked_window = 0;
+		kfree_skb(buf);
+		l_ptr->proto_msg_queue = NULL;
+		return 0;
 	}
 
 	/* Send one deferred data message, if send window not full: */
@@ -1366,18 +1345,14 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 		if (mod(next - first) < l_ptr->queue_limit[0]) {
 			msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-			if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-				if (msg_user(msg) == MSG_BUNDLER)
-					msg_set_type(msg, CLOSED_MSG);
-				l_ptr->next_out = buf->next;
-				return 0;
-			} else {
-				l_ptr->stats.bearer_congs++;
-				return PUSH_FAILED;
-			}
+			tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+			if (msg_user(msg) == MSG_BUNDLER)
+				msg_set_type(msg, CLOSED_MSG);
+			l_ptr->next_out = buf->next;
+			return 0;
 		}
 	}
-	return PUSH_FINISHED;
+	return 1;
 }
 
 /*
@@ -1388,15 +1363,12 @@ void tipc_link_push_queue(struct tipc_link *l_ptr)
 {
 	u32 res;
 
-	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr))
+	if (tipc_bearer_blocked(l_ptr->b_ptr))
 		return;
 
 	do {
 		res = tipc_link_push_packet(l_ptr);
 	} while (!res);
-
-	if (res == PUSH_FAILED)
-		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
 }
 
 static void link_reset_all(unsigned long addr)
@@ -1481,7 +1453,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 
 	msg = buf_msg(buf);
 
-	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
+	if (tipc_bearer_blocked(l_ptr->b_ptr)) {
 		if (l_ptr->retransm_queue_size == 0) {
 			l_ptr->retransm_queue_head = msg_seqno(msg);
 			l_ptr->retransm_queue_size = retransmits;
@@ -1491,7 +1463,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		}
 		return;
 	} else {
-		/* Detect repeated retransmit failures on uncongested bearer */
+		/* Detect repeated retransmit failures on unblocked bearer */
 		if (l_ptr->last_retransmitted == msg_seqno(msg)) {
 			if (++l_ptr->stale_count > 100) {
 				link_retransmit_failure(l_ptr, buf);
@@ -1507,17 +1479,10 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 		msg = buf_msg(buf);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			buf = buf->next;
-			retransmits--;
-			l_ptr->stats.retransmitted++;
-		} else {
-			tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
-			l_ptr->stats.bearer_congs++;
-			l_ptr->retransm_queue_head = buf_seqno(buf);
-			l_ptr->retransm_queue_size = retransmits;
-			return;
-		}
+		tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
+		buf = buf->next;
+		retransmits--;
+		l_ptr->stats.retransmitted++;
 	}
 
 	l_ptr->retransm_queue_head = l_ptr->retransm_queue_size = 0;
@@ -1972,21 +1937,13 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 
-	/* Defer message if bearer is already congested */
-	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
-		l_ptr->proto_msg_queue = buf;
-		return;
-	}
-
-	/* Defer message if attempting to send results in bearer congestion */
-	if (!tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
+	/* Defer message if bearer is already blocked */
+	if (tipc_bearer_blocked(l_ptr->b_ptr)) {
 		l_ptr->proto_msg_queue = buf;
-		l_ptr->stats.bearer_congs++;
 		return;
 	}
 
-	/* Discard message if it was sent successfully */
+	tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr);
 	l_ptr->unacked_window = 0;
 	kfree_skb(buf);
 }
@@ -2937,8 +2894,8 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 			     s->sent_nacks, s->sent_acks, s->retransmitted);
 
 	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion bearer:%u link:%u  Send queue"
-			     " max:%u avg:%u\n", s->bearer_congs, s->link_congs,
+			     "  Congestion link:%u  Send queue"
+			     " max:%u avg:%u\n", s->link_congs,
 			     s->max_queue_sz, s->queue_sz_counts ?
 			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 6e92112..c048ed1 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -40,9 +40,6 @@
 #include "msg.h"
 #include "node.h"
 
-#define PUSH_FAILED   1
-#define PUSH_FINISHED 2
-
 /*
  * Out-of-range value for link sequence numbers
  */
@@ -82,7 +79,6 @@ struct tipc_stats {
 	u32 recv_fragmented;
 	u32 recv_fragments;
 	u32 link_congs;		/* # port sends blocked by congestion */
-	u32 bearer_congs;
 	u32 deferred_recv;
 	u32 duplicates;
 	u32 max_queue_sz;	/* send queue size high water mark */
-- 
1.7.12.1
