From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/20] tipc: remove calls to dbg() and msg_dbg()
Date: Fri, 31 Dec 2010 23:59:25 -0500
Message-ID: <1293857975-30267-11-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53301 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1AAFAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:07 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates obsolete calls to two of TIPC's main debugging macros, as well
as a pair of associated debugging routines that are no longer required.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |    3 -
 net/tipc/bearer.c     |    1 -
 net/tipc/config.c     |    4 +-
 net/tipc/core.h       |    4 --
 net/tipc/discover.c   |    4 --
 net/tipc/link.c       |  119 +-----------------------------------------------
 net/tipc/name_distr.c |   14 ------
 net/tipc/name_table.c |   33 +-------------
 net/tipc/net.c        |   10 ----
 net/tipc/node.c       |    3 -
 net/tipc/port.c       |   10 ----
 net/tipc/port.h       |    1 -
 net/tipc/socket.c     |   39 ++++------------
 net/tipc/subscr.c     |    4 --
 14 files changed, 16 insertions(+), 233 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 110829e..cb817d5 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -436,8 +436,6 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	u32 seqno;
 	struct sk_buff *deferred;
 
-	msg_dbg(msg, "<BC<<<");
-
 	if (unlikely(!node || !tipc_node_is_up(node) || !node->bclink.supported ||
 		     (msg_mc_netid(msg) != tipc_net_id))) {
 		buf_discard(buf);
@@ -445,7 +443,6 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	}
 
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
-		msg_dbg(msg, "<BCNACK<<<");
 		if (msg_destnode(msg) == tipc_own_addr) {
 			tipc_node_lock(node);
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 885da94..24dc6c2 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -164,7 +164,6 @@ int  tipc_register_media(u32 media_type,
 	m_ptr->priority = bearer_priority;
 	m_ptr->tolerance = link_tolerance;
 	m_ptr->window = send_window_limit;
-	dbg("Media <%s> registered\n", name);
 	res = 0;
 exit:
 	write_unlock_bh(&tipc_net_lock);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index afa6e85..a7894ff 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -65,10 +65,8 @@ int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
 	struct tlv_desc *tlv = (struct tlv_desc *)skb_tail_pointer(buf);
 	int new_tlv_space = TLV_SPACE(tlv_data_size);
 
-	if (skb_tailroom(buf) < new_tlv_space) {
-		dbg("tipc_cfg_append_tlv unable to append TLV\n");
+	if (skb_tailroom(buf) < new_tlv_space)
 		return 0;
-	}
 	skb_put(buf, new_tlv_space);
 	tlv->tlv_type = htons(tlv_type);
 	tlv->tlv_len  = htons(TLV_LENGTH(tlv_data_size));
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 17f3670..b4e54f8 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -243,7 +243,6 @@ u32 tipc_k_signal(Handler routine, unsigned long argument);
 static inline void k_init_timer(struct timer_list *timer, Handler routine,
 				unsigned long argument)
 {
-	dbg("initializing timer %p\n", timer);
 	setup_timer(timer, routine, argument);
 }
 
@@ -263,7 +262,6 @@ static inline void k_init_timer(struct timer_list *timer, Handler routine,
 
 static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
 {
-	dbg("starting timer %p for %u\n", timer, msec);
 	mod_timer(timer, jiffies + msecs_to_jiffies(msec) + 1);
 }
 
@@ -280,7 +278,6 @@ static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
 
 static inline void k_cancel_timer(struct timer_list *timer)
 {
-	dbg("cancelling timer %p\n", timer);
 	del_timer_sync(timer);
 }
 
@@ -298,7 +295,6 @@ static inline void k_cancel_timer(struct timer_list *timer)
 
 static inline void k_term_timer(struct timer_list *timer)
 {
-	dbg("terminating timer %p\n", timer);
 }
 
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 80799f6..e722378 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -133,7 +133,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 	u32 type = msg_type(msg);
 
 	msg_get_media_addr(msg,&media_addr);
-	msg_dbg(msg, "RECV:");
 	buf_discard(buf);
 
 	if (net_id != tipc_net_id)
@@ -156,7 +155,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 		struct tipc_node *n_ptr = tipc_node_find(orig);
 		int link_fully_up;
 
-		dbg(" in own cluster\n");
 		if (n_ptr == NULL) {
 			n_ptr = tipc_node_create(orig);
 			if (!n_ptr)
@@ -173,7 +171,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 
 		link = n_ptr->links[b_ptr->identity];
 		if (!link) {
-			dbg("creating link\n");
 			link = tipc_link_create(b_ptr, orig, &media_addr);
 			if (!link) {
 				spin_unlock_bh(&n_ptr->lock);
@@ -198,7 +195,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 			return;
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, 1, orig, b_ptr);
 		if (rbuf != NULL) {
-			msg_dbg(buf_msg(rbuf),"SEND:");
 			b_ptr->media->send_msg(rbuf, &b_ptr->publ, &media_addr);
 			buf_discard(rbuf);
 		}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 671ffd3..cb10d20 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -153,18 +153,6 @@ static void dbg_print_link(struct link *l_ptr, const char *str)
 		link_print(l_ptr, DBG_OUTPUT, str);
 }
 
-static void dbg_print_buf_chain(struct sk_buff *root_buf)
-{
-	if (DBG_OUTPUT != TIPC_NULL) {
-		struct sk_buff *buf = root_buf;
-
-		while (buf) {
-			msg_dbg(buf_msg(buf), "In chain: ");
-			buf = buf->next;
-		}
-	}
-}
-
 /*
  *  Simple link routines
  */
@@ -433,9 +421,6 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 	list_add_tail(&l_ptr->link_list, &b_ptr->links);
 	tipc_k_signal((Handler)link_start, (unsigned long)l_ptr);
 
-	dbg("tipc_link_create(): tolerance = %u,cont intv = %u, abort_limit = %u\n",
-	    l_ptr->tolerance, l_ptr->continuity_interval, l_ptr->abort_limit);
-
 	return l_ptr;
 }
 
@@ -455,8 +440,6 @@ void tipc_link_delete(struct link *l_ptr)
 		return;
 	}
 
-	dbg("tipc_link_delete()\n");
-
 	k_cancel_timer(&l_ptr->timer);
 
 	tipc_node_lock(l_ptr->owner);
@@ -473,7 +456,6 @@ void tipc_link_delete(struct link *l_ptr)
 
 static void link_start(struct link *l_ptr)
 {
-	dbg("link_start %x\n", l_ptr);
 	link_state_event(l_ptr, STARTING_EVT);
 }
 
@@ -926,9 +908,6 @@ static int link_bundle_buf(struct link *l_ptr,
 	skb_copy_to_linear_data_offset(bundler, to_pos, buf->data, size);
 	msg_set_size(bundler_msg, to_pos + size);
 	msg_set_msgcnt(bundler_msg, msg_msgcnt(bundler_msg) + 1);
-	dbg("Packed msg # %u(%u octets) into pos %u in buf(#%u)\n",
-	    msg_msgcnt(bundler_msg), size, to_pos, msg_seqno(bundler_msg));
-	msg_dbg(msg, "PACKD:");
 	buf_discard(buf);
 	l_ptr->stats.sent_bundled++;
 	return 1;
@@ -977,7 +956,6 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 			return link_schedule_port(l_ptr, msg_origport(msg),
 						  size);
 		}
-		msg_dbg(msg, "TIPC: Congestion, throwing away\n");
 		buf_discard(buf);
 		if (imp > CONN_MANAGER) {
 			warn("Resetting link <%s>, send queue full", l_ptr->name);
@@ -1066,17 +1044,12 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector & 1];
 		if (l_ptr) {
-			dbg("tipc_link_send: found link %x for dest %x\n", l_ptr, dest);
 			res = tipc_link_send_buf(l_ptr, buf);
 		} else {
-			dbg("Attempt to send msg to unreachable node:\n");
-			msg_dbg(buf_msg(buf),">>>");
 			buf_discard(buf);
 		}
 		tipc_node_unlock(n_ptr);
 	} else {
-		dbg("Attempt to send msg to unknown node:\n");
-		msg_dbg(buf_msg(buf),">>>");
 		buf_discard(buf);
 	}
 	read_unlock_bh(&tipc_net_lock);
@@ -1103,10 +1076,8 @@ static int link_send_buf_fast(struct link *l_ptr, struct sk_buff *buf,
 				if (likely(tipc_bearer_send(l_ptr->b_ptr, buf,
 							    &l_ptr->media_addr))) {
 					l_ptr->unacked_window = 0;
-					msg_dbg(msg,"SENT_FAST:");
 					return res;
 				}
-				dbg("failed sent fast...\n");
 				tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
 				l_ptr->stats.bearer_congs++;
 				l_ptr->next_out = buf;
@@ -1141,8 +1112,6 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
 	if (likely(n_ptr)) {
 		tipc_node_lock(n_ptr);
 		l_ptr = n_ptr->active_links[selector];
-		dbg("send_fast: buf %x selected %x, destnode = %x\n",
-		    buf, l_ptr, destnode);
 		if (likely(l_ptr)) {
 			res = link_send_buf_fast(l_ptr, buf, &dummy);
 			tipc_node_unlock(n_ptr);
@@ -1292,7 +1261,6 @@ again:
 
 	/* Prepare reusable fragment header: */
 
-	msg_dbg(hdr, ">FRAGMENTING>");
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, msg_destnode(hdr));
 	msg_set_link_selector(&fragm_hdr, sender->publ.ref);
@@ -1308,7 +1276,6 @@ again:
 	skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 	hsz = msg_hdr_sz(hdr);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, hdr, hsz);
-	msg_dbg(buf_msg(buf), ">BUILD>");
 
 	/* Chop up message: */
 
@@ -1367,7 +1334,6 @@ error:
 			skb_copy_to_linear_data(buf, &fragm_hdr, INT_H_SIZE);
 			fragm_crs = INT_H_SIZE;
 			fragm_rest = fragm_sz;
-			msg_dbg(buf_msg(buf),"  >BUILD>");
 		}
 	}
 	while (rest > 0);
@@ -1417,7 +1383,6 @@ reject:
 		l_ptr->stats.sent_fragments++;
 		msg_set_long_msgno(msg, l_ptr->long_msg_seq_no);
 		link_add_to_outqueue(l_ptr, buf, msg);
-		msg_dbg(msg, ">ADD>");
 		buf = next;
 	}
 
@@ -1459,14 +1424,12 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			msg_dbg(buf_msg(buf), ">DEF-RETR>");
 			l_ptr->retransm_queue_head = mod(++r_q_head);
 			l_ptr->retransm_queue_size = --r_q_size;
 			l_ptr->stats.retransmitted++;
 			return 0;
 		} else {
 			l_ptr->stats.bearer_congs++;
-			msg_dbg(buf_msg(buf), "|>DEF-RETR>");
 			return PUSH_FAILED;
 		}
 	}
@@ -1478,13 +1441,11 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf),l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			msg_dbg(buf_msg(buf), ">DEF-PROT>");
 			l_ptr->unacked_window = 0;
 			buf_discard(buf);
 			l_ptr->proto_msg_queue = NULL;
 			return 0;
 		} else {
-			msg_dbg(buf_msg(buf), "|>DEF-PROT>");
 			l_ptr->stats.bearer_congs++;
 			return PUSH_FAILED;
 		}
@@ -1504,11 +1465,9 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 			if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
 				if (msg_user(msg) == MSG_BUNDLER)
 					msg_set_type(msg, CLOSED_MSG);
-				msg_dbg(msg, ">PUSH-DATA>");
 				l_ptr->next_out = buf->next;
 				return 0;
 			} else {
-				msg_dbg(msg, "|PUSH-DATA|");
 				l_ptr->stats.bearer_congs++;
 				return PUSH_FAILED;
 			}
@@ -1571,7 +1530,6 @@ static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
 	struct tipc_msg *msg = buf_msg(buf);
 
 	warn("Retransmission failure on link <%s>\n", l_ptr->name);
-	tipc_msg_dbg(TIPC_OUTPUT, msg, ">RETR-FAIL>");
 
 	if (l_ptr->addr) {
 
@@ -1621,11 +1579,8 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 
 	msg = buf_msg(buf);
 
-	dbg("Retransmitting %u in link %x\n", retransmits, l_ptr);
-
 	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
 		if (l_ptr->retransm_queue_size == 0) {
-			msg_dbg(msg, ">NO_RETR->BCONG>");
 			dbg_print_link(l_ptr, "   ");
 			l_ptr->retransm_queue_head = msg_seqno(msg);
 			l_ptr->retransm_queue_size = retransmits;
@@ -1653,7 +1608,6 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-			msg_dbg(buf_msg(buf), ">RETR>");
 			buf = buf->next;
 			retransmits--;
 			l_ptr->stats.retransmitted++;
@@ -1939,12 +1893,10 @@ deliver:
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
-		msg_dbg(msg,"NSEQ<REC<");
 		link_state_event(l_ptr, TRAFFIC_MSG_EVT);
 
 		if (link_working_working(l_ptr)) {
 			/* Re-insert in front of queue */
-			msg_dbg(msg,"RECV-REINS:");
 			buf->next = head;
 			head = buf;
 			tipc_node_unlock(n_ptr);
@@ -2026,9 +1978,6 @@ static void link_handle_out_of_seq_msg(struct link *l_ptr,
 		return;
 	}
 
-	dbg("rx OOS msg: seq_no %u, expecting %u (%u)\n",
-	    seq_no, mod(l_ptr->next_in_no), l_ptr->next_in_no);
-
 	/* Record OOS packet arrival (force mismatch on next timeout) */
 
 	l_ptr->checkpoint--;
@@ -2146,8 +2095,6 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 
 	/* Message can be sent */
 
-	msg_dbg(msg, ">>");
-
 	buf = tipc_buf_acquire(msg_size);
 	if (!buf)
 		return;
@@ -2181,8 +2128,6 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 	u32 msg_tol;
 	struct tipc_msg *msg = buf_msg(buf);
 
-	dbg("AT(%u):", jiffies_to_msecs(jiffies));
-	msg_dbg(msg, "<<");
 	if (link_blocked(l_ptr))
 		goto exit;
 
@@ -2201,11 +2146,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 	case RESET_MSG:
 		if (!link_working_unknown(l_ptr) &&
 		    (l_ptr->peer_session != INVALID_SESSION)) {
-			if (msg_session(msg) == l_ptr->peer_session) {
-				dbg("Duplicate RESET: %u<->%u\n",
-				    msg_session(msg), l_ptr->peer_session);
+			if (msg_session(msg) == l_ptr->peer_session)
 				break; /* duplicate: ignore */
-			}
 		}
 		/* fall thru' */
 	case ACTIVATE_MSG:
@@ -2266,8 +2208,6 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 
 		max_pkt_ack = msg_max_pkt(msg);
 		if (max_pkt_ack > l_ptr->max_pkt) {
-			dbg("Link <%s> updated MTU %u -> %u\n",
-			    l_ptr->name, l_ptr->max_pkt, max_pkt_ack);
 			l_ptr->max_pkt = max_pkt_ack;
 			l_ptr->max_pkt_probes = 0;
 		}
@@ -2289,14 +2229,11 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 						 0, rec_gap, 0, 0, max_pkt_ack);
 		}
 		if (msg_seq_gap(msg)) {
-			msg_dbg(msg, "With Gap:");
 			l_ptr->stats.recv_nacks++;
 			tipc_link_retransmit(l_ptr, l_ptr->first_out,
 					     msg_seq_gap(msg));
 		}
 		break;
-	default:
-		msg_dbg(buf_msg(buf), "<DISCARDING UNKNOWN<");
 	}
 exit:
 	buf_discard(buf);
@@ -2331,8 +2268,6 @@ static void tipc_link_tunnel(struct link *l_ptr,
 	}
 	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
 	skb_copy_to_linear_data_offset(buf, INT_H_SIZE, msg, length);
-	dbg("%c->%c:", l_ptr->b_ptr->net_plane, tunnel->b_ptr->net_plane);
-	msg_dbg(buf_msg(buf), ">SEND>");
 	tipc_link_send_buf(tunnel, buf);
 }
 
@@ -2364,7 +2299,6 @@ void tipc_link_changeover(struct link *l_ptr)
 		 ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
-	dbg("Link changeover requires %u tunnel messages\n", msgcount);
 
 	if (!l_ptr->first_out) {
 		struct sk_buff *buf;
@@ -2373,9 +2307,6 @@ void tipc_link_changeover(struct link *l_ptr)
 		if (buf) {
 			skb_copy_to_linear_data(buf, &tunnel_hdr, INT_H_SIZE);
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
-			dbg("%c->%c:", l_ptr->b_ptr->net_plane,
-			    tunnel->b_ptr->net_plane);
-			msg_dbg(&tunnel_hdr, "EMPTY>SEND>");
 			tipc_link_send_buf(tunnel, buf);
 		} else {
 			warn("Link changeover error, "
@@ -2439,9 +2370,6 @@ void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
 		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
 		skb_copy_to_linear_data_offset(outbuf, INT_H_SIZE, iter->data,
 					       length);
-		dbg("%c->%c:", l_ptr->b_ptr->net_plane,
-		    tunnel->b_ptr->net_plane);
-		msg_dbg(buf_msg(outbuf), ">SEND>");
 		tipc_link_send_buf(tunnel, outbuf);
 		if (!tipc_link_is_up(l_ptr))
 			return;
@@ -2488,31 +2416,24 @@ static int link_recv_changeover_msg(struct link **l_ptr,
 	u32 msg_count = msg_msgcnt(tunnel_msg);
 
 	dest_link = (*l_ptr)->owner->links[msg_bearer_id(tunnel_msg)];
-	if (!dest_link) {
-		msg_dbg(tunnel_msg, "NOLINK/<REC<");
+	if (!dest_link)
 		goto exit;
-	}
 	if (dest_link == *l_ptr) {
 		err("Unexpected changeover message on link <%s>\n",
 		    (*l_ptr)->name);
 		goto exit;
 	}
-	dbg("%c<-%c:", dest_link->b_ptr->net_plane,
-	    (*l_ptr)->b_ptr->net_plane);
 	*l_ptr = dest_link;
 	msg = msg_get_wrapped(tunnel_msg);
 
 	if (msg_typ == DUPLICATE_MSG) {
-		if (less(msg_seqno(msg), mod(dest_link->next_in_no))) {
-			msg_dbg(tunnel_msg, "DROP/<REC<");
+		if (less(msg_seqno(msg), mod(dest_link->next_in_no)))
 			goto exit;
-		}
 		*buf = buf_extract(tunnel_buf,INT_H_SIZE);
 		if (*buf == NULL) {
 			warn("Link changeover error, duplicate msg dropped\n");
 			goto exit;
 		}
-		msg_dbg(tunnel_msg, "TNL<REC<");
 		buf_discard(tunnel_buf);
 		return 1;
 	}
@@ -2520,18 +2441,14 @@ static int link_recv_changeover_msg(struct link **l_ptr,
 	/* First original message ?: */
 
 	if (tipc_link_is_up(dest_link)) {
-		msg_dbg(tunnel_msg, "UP/FIRST/<REC<");
 		info("Resetting link <%s>, changeover initiated by peer\n",
 		     dest_link->name);
 		tipc_link_reset(dest_link);
 		dest_link->exp_msg_count = msg_count;
-		dbg("Expecting %u tunnelled messages\n", msg_count);
 		if (!msg_count)
 			goto exit;
 	} else if (dest_link->exp_msg_count == START_CHANGEOVER) {
-		msg_dbg(tunnel_msg, "BLK/FIRST/<REC<");
 		dest_link->exp_msg_count = msg_count;
-		dbg("Expecting %u tunnelled messages\n", msg_count);
 		if (!msg_count)
 			goto exit;
 	}
@@ -2541,18 +2458,15 @@ static int link_recv_changeover_msg(struct link **l_ptr,
 	if (dest_link->exp_msg_count == 0) {
 		warn("Link switchover error, "
 		     "got too many tunnelled messages\n");
-		msg_dbg(tunnel_msg, "OVERDUE/DROP/<REC<");
 		dbg_print_link(dest_link, "LINK:");
 		goto exit;
 	}
 	dest_link->exp_msg_count--;
 	if (less(msg_seqno(msg), dest_link->reset_checkpoint)) {
-		msg_dbg(tunnel_msg, "DROP/DUPL/<REC<");
 		goto exit;
 	} else {
 		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
 		if (*buf != NULL) {
-			msg_dbg(tunnel_msg, "TNL<REC<");
 			buf_discard(tunnel_buf);
 			return 1;
 		} else {
@@ -2574,7 +2488,6 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 	u32 pos = INT_H_SIZE;
 	struct sk_buff *obuf;
 
-	msg_dbg(buf_msg(buf), "<BNDL<: ");
 	while (msgcount--) {
 		obuf = buf_extract(buf, pos);
 		if (obuf == NULL) {
@@ -2582,7 +2495,6 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 			break;
 		}
 		pos += align(msg_size(buf_msg(obuf)));
-		msg_dbg(buf_msg(obuf), "     /");
 		tipc_net_route_msg(obuf);
 	}
 	buf_discard(buf);
@@ -2719,7 +2631,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 	u32 long_msg_seq_no = msg_long_msgno(fragm);
 
 	*fb = NULL;
-	msg_dbg(fragm,"FRG<REC<");
 
 	/* Is there an incomplete message waiting for this fragment? */
 
@@ -2738,7 +2649,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		if (msg_type(imsg) == TIPC_MCAST_MSG)
 			max = TIPC_MAX_USER_MSG_SIZE + MCAST_H_SIZE;
 		if (msg_size(imsg) > max) {
-			msg_dbg(fragm,"<REC<Oversized: ");
 			buf_discard(fbuf);
 			return 0;
 		}
@@ -2782,10 +2692,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		set_expected_frags(pbuf,exp_frags);
 		return 0;
 	}
-	dbg(" Discarding orphan fragment %x\n",fbuf);
-	msg_dbg(fragm,"ORPHAN:");
-	dbg("Pending long buffers:\n");
-	dbg_print_buf_chain(*pending);
 	buf_discard(fbuf);
 	return 0;
 }
@@ -2813,11 +2719,6 @@ static void link_check_defragm_bufs(struct link *l_ptr)
 			incr_timer_cnt(buf);
 			prev = buf;
 		} else {
-			dbg(" Discarding incomplete long buffer\n");
-			msg_dbg(buf_msg(buf), "LONG:");
-			dbg_print_link(l_ptr, "curr:");
-			dbg("Pending long buffers:\n");
-			dbg_print_buf_chain(l_ptr->defragm_buf);
 			if (prev)
 				prev->next = buf->next;
 			else
@@ -3165,19 +3066,6 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 	return res;
 }
 
-static void link_dump_send_queue(struct link *l_ptr)
-{
-	if (l_ptr->next_out) {
-		info("\nContents of unsent queue:\n");
-		dbg_print_buf_chain(l_ptr->next_out);
-	}
-	info("\nContents of send queue:\n");
-	if (l_ptr->first_out) {
-		dbg_print_buf_chain(l_ptr->first_out);
-	}
-	info("Empty send queue\n");
-}
-
 static void link_print(struct link *l_ptr, struct print_buf *buf,
 		       const char *str)
 {
@@ -3203,7 +3091,6 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 			tipc_printf(buf, "first_out= %x ", l_ptr->first_out);
 			tipc_printf(buf, "next_out= %x ", l_ptr->next_out);
 			tipc_printf(buf, "last_out= %x ", l_ptr->last_out);
-			link_dump_send_queue(l_ptr);
 		}
 	} else
 		tipc_printf(buf, "[]");
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c4583fe..0dd648e 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -87,7 +87,6 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 	i->upper = htonl(p->upper);
 	i->ref = htonl(p->ref);
 	i->key = htonl(p->key);
-	dbg("publ_to_item: %u, %u, %u\n", p->type, p->lower, p->upper);
 }
 
 /**
@@ -147,7 +146,6 @@ void tipc_named_publish(struct publication *publ)
 
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
-	dbg("tipc_named_publish: broadcasting publish msg\n");
 	named_cluster_distribute(buf);
 }
 
@@ -171,7 +169,6 @@ void tipc_named_withdraw(struct publication *publ)
 
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
-	dbg("tipc_named_withdraw: broadcasting withdraw msg\n");
 	named_cluster_distribute(buf);
 }
 
@@ -209,9 +206,6 @@ void tipc_named_node_up(unsigned long node)
 		left -= ITEM_SIZE;
 		if (!left) {
 			msg_set_link_selector(buf_msg(buf), node);
-			dbg("tipc_named_node_up: sending publish msg to "
-			    "<%u.%u.%u>\n", tipc_zone(node),
-			    tipc_cluster(node), tipc_node(node));
 			tipc_link_send(buf, node, node);
 			buf = NULL;
 		}
@@ -236,8 +230,6 @@ static void node_is_down(struct publication *publ)
 	struct publication *p;
 
 	write_lock_bh(&tipc_nametbl_lock);
-	dbg("node_is_down: withdrawing %u, %u, %u\n",
-	    publ->type, publ->lower, publ->upper);
 	publ->key += 1222345;
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
@@ -268,9 +260,6 @@ void tipc_named_recv(struct sk_buff *buf)
 	write_lock_bh(&tipc_nametbl_lock);
 	while (count--) {
 		if (msg_type(msg) == PUBLICATION) {
-			dbg("tipc_named_recv: got publication for %u, %u, %u\n",
-			    ntohl(item->type), ntohl(item->lower),
-			    ntohl(item->upper));
 			publ = tipc_nametbl_insert_publ(ntohl(item->type),
 							ntohl(item->lower),
 							ntohl(item->upper),
@@ -285,9 +274,6 @@ void tipc_named_recv(struct sk_buff *buf)
 						       (net_ev_handler)node_is_down);
 			}
 		} else if (msg_type(msg) == WITHDRAWAL) {
-			dbg("tipc_named_recv: got withdrawl for %u, %u, %u\n",
-			    ntohl(item->type), ntohl(item->lower),
-			    ntohl(item->upper));
 			publ = tipc_nametbl_remove_publ(ntohl(item->type),
 							ntohl(item->lower),
 							msg_orignode(msg),
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index d5adb04..ddc2ad4 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -172,8 +172,6 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	spin_lock_init(&nseq->lock);
 	nseq->type = type;
 	nseq->sseqs = sseq;
-	dbg("tipc_nameseq_create(): nseq = %p, type %u, ssseqs %p, ff: %u\n",
-	    nseq, type, nseq->sseqs, nseq->first_free);
 	nseq->alloc = 1;
 	INIT_HLIST_NODE(&nseq->ns_list);
 	INIT_LIST_HEAD(&nseq->subscriptions);
@@ -251,8 +249,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	int created_subseq = 0;
 
 	sseq = nameseq_find_subseq(nseq, lower);
-	dbg("nameseq_ins: for seq %p, {%u,%u}, found sseq %p\n",
-	    nseq, type, lower, sseq);
 	if (sseq) {
 
 		/* Lower end overlaps existing entry => need an exact match */
@@ -289,18 +285,15 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 				     type, lower, upper);
 				return NULL;
 			}
-			dbg("Allocated %u more sseqs\n", nseq->alloc);
 			memcpy(sseqs, nseq->sseqs,
 			       nseq->alloc * sizeof(struct sub_seq));
 			kfree(nseq->sseqs);
 			nseq->sseqs = sseqs;
 			nseq->alloc *= 2;
 		}
-		dbg("Have %u sseqs for type %u\n", nseq->alloc, type);
 
 		/* Insert new sub-sequence */
 
-		dbg("ins in pos %u, ff = %u\n", inspos, nseq->first_free);
 		sseq = &nseq->sseqs[inspos];
 		freesseq = &nseq->sseqs[nseq->first_free];
 		memmove(sseq + 1, sseq, (freesseq - sseq) * sizeof (*sseq));
@@ -310,17 +303,12 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		sseq->upper = upper;
 		created_subseq = 1;
 	}
-	dbg("inserting {%u,%u,%u} from <0x%x:%u> into sseq %p(%u,%u) of seq %p\n",
-	    type, lower, upper, node, port, sseq,
-	    sseq->lower, sseq->upper, nseq);
 
 	/* Insert a publication: */
 
 	publ = publ_create(type, lower, upper, scope, node, port, key);
 	if (!publ)
 		return NULL;
-	dbg("inserting publ %p, node=0x%x publ->node=0x%x, subscr->node=%p\n",
-	    publ, node, publ->node, publ->subscr.node);
 
 	sseq->zone_list_size++;
 	if (!sseq->zone_list)
@@ -355,7 +343,6 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	 * Any subscriptions waiting for notification?
 	 */
 	list_for_each_entry_safe(s, st, &nseq->subscriptions, nameseq_list) {
-		dbg("calling report_overlap()\n");
 		tipc_subscr_report_overlap(s,
 					   publ->lower,
 					   publ->upper,
@@ -393,9 +380,6 @@ static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 i
 	if (!sseq)
 		return NULL;
 
-	dbg("tipc_nameseq_remove_publ: seq: %p, sseq %p, {%u,%u}, key %u\n",
-	    nseq, sseq, nseq->type, inst, key);
-
 	/* Remove publication from zone scope list */
 
 	prev = sseq->zone_list;
@@ -549,15 +533,10 @@ static struct name_seq *nametbl_find_seq(u32 type)
 	struct hlist_node *seq_node;
 	struct name_seq *ns;
 
-	dbg("find_seq %u,(%u,0x%x) table = %p, hash[type] = %u\n",
-	    type, htonl(type), type, table.types, hash(type));
-
 	seq_head = &table.types[hash(type)];
 	hlist_for_each_entry(ns, seq_node, seq_head, ns_list) {
-		if (ns->type == type) {
-			dbg("found %p\n", ns);
+		if (ns->type == type)
 			return ns;
-		}
 	}
 
 	return NULL;
@@ -568,18 +547,14 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 {
 	struct name_seq *seq = nametbl_find_seq(type);
 
-	dbg("tipc_nametbl_insert_publ: {%u,%u,%u} found %p\n", type, lower, upper, seq);
 	if (lower > upper) {
 		warn("Failed to publish illegal {%u,%u,%u}\n",
 		     type, lower, upper);
 		return NULL;
 	}
 
-	dbg("Publishing {%u,%u,%u} from 0x%x\n", type, lower, upper, node);
-	if (!seq) {
+	if (!seq)
 		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
-		dbg("tipc_nametbl_insert_publ: created %p\n", seq);
-	}
 	if (!seq)
 		return NULL;
 
@@ -596,7 +571,6 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 	if (!seq)
 		return NULL;
 
-	dbg("Withdrawing {%u,%u} from 0x%x\n", type, lower, node);
 	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
 
 	if (!seq->first_free && list_empty(&seq->subscriptions)) {
@@ -792,7 +766,6 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 {
 	struct publication *publ;
 
-	dbg("tipc_nametbl_withdraw: {%u,%u}, key=%u\n", type, lower, key);
 	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
@@ -827,8 +800,6 @@ void tipc_nametbl_subscribe(struct subscription *s)
 	}
 	if (seq){
 		spin_lock_bh(&seq->lock);
-		dbg("tipc_nametbl_subscribe:found %p for {%u,%u,%u}\n",
-		    seq, type, s->seq.lower, s->seq.upper);
 		tipc_nameseq_subscribe(seq, s);
 		spin_unlock_bh(&seq->lock);
 	} else {
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 3baf55e..6290bec 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -138,22 +138,18 @@ static void net_route_named_msg(struct sk_buff *buf)
 	u32 dport;
 
 	if (!msg_named(msg)) {
-		msg_dbg(msg, "tipc_net->drop_nam:");
 		buf_discard(buf);
 		return;
 	}
 
 	dnode = addr_domain(msg_lookup_scope(msg));
 	dport = tipc_nametbl_translate(msg_nametype(msg), msg_nameinst(msg), &dnode);
-	dbg("tipc_net->lookup<%u,%u>-><%u,%x>\n",
-	    msg_nametype(msg), msg_nameinst(msg), dport, dnode);
 	if (dport) {
 		msg_set_destnode(msg, dnode);
 		msg_set_destport(msg, dport);
 		tipc_net_route_msg(buf);
 		return;
 	}
-	msg_dbg(msg, "tipc_net->rej:NO NAME: ");
 	tipc_reject_msg(buf, TIPC_ERR_NO_NAME);
 }
 
@@ -169,18 +165,14 @@ void tipc_net_route_msg(struct sk_buff *buf)
 	msg_incr_reroute_cnt(msg);
 	if (msg_reroute_cnt(msg) > 6) {
 		if (msg_errcode(msg)) {
-			msg_dbg(msg, "NET>DISC>:");
 			buf_discard(buf);
 		} else {
-			msg_dbg(msg, "NET>REJ>:");
 			tipc_reject_msg(buf, msg_destport(msg) ?
 					TIPC_ERR_NO_PORT : TIPC_ERR_NO_NAME);
 		}
 		return;
 	}
 
-	msg_dbg(msg, "tipc_net->rout: ");
-
 	/* Handle message for this node */
 	dnode = msg_short(msg) ? tipc_own_addr : msg_destnode(msg);
 	if (tipc_in_scope(dnode, tipc_own_addr)) {
@@ -201,14 +193,12 @@ void tipc_net_route_msg(struct sk_buff *buf)
 			tipc_port_recv_proto_msg(buf);
 			break;
 		default:
-			msg_dbg(msg,"DROP/NET/<REC<");
 			buf_discard(buf);
 		}
 		return;
 	}
 
 	/* Handle message for another node */
-	msg_dbg(msg, "NET>SEND>: ");
 	skb_trim(buf, msg_size(msg));
 	tipc_link_send(buf, dnode, msg_link_selector(msg));
 }
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 31dcca9..fb54719 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -97,7 +97,6 @@ void tipc_node_delete(struct tipc_node *n_ptr)
 	if (!n_ptr)
 		return;
 
-	dbg("node %x deleted\n", n_ptr->addr);
 	n_num = tipc_node(n_ptr->addr);
 	tipc_net.nodes[n_num] = NULL;
 	kfree(n_ptr);
@@ -124,7 +123,6 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct link *l_ptr)
 	     l_ptr->name, l_ptr->b_ptr->net_plane);
 
 	if (!active[0]) {
-		dbg(" link %x into %x/%x\n", l_ptr, &active[0], &active[1]);
 		active[0] = active[1] = l_ptr;
 		node_established_contact(n_ptr);
 		return;
@@ -302,7 +300,6 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct link *l_ptr)
 
 static void node_established_contact(struct tipc_node *n_ptr)
 {
-	dbg("node_established_contact:-> %x\n", n_ptr->addr);
 	tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
 
 	/* Syncronize broadcast acks */
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 33d0b3b..8bacd57 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -188,7 +188,6 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct port_list *dp)
 
 			if (b == NULL) {
 				warn("Unable to deliver multicast message(s)\n");
-				msg_dbg(msg, "LOST:");
 				goto exit;
 			}
 			if ((index == 0) && (cnt != 0)) {
@@ -280,7 +279,6 @@ int tipc_deleteport(u32 ref)
 	spin_unlock_bh(&tipc_port_list_lock);
 	k_term_timer(&p_ptr->timer);
 	kfree(p_ptr);
-	dbg("Deleted port %u\n", ref);
 	tipc_net_route_msg(buf);
 	return 0;
 }
@@ -366,7 +364,6 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 		msg_set_orignode(msg, orignode);
 		msg_set_transp_seqno(msg, seqno);
 		msg_set_msgcnt(msg, ack);
-		msg_dbg(msg, "PORT>SEND>:");
 	}
 	return buf;
 }
@@ -384,7 +381,6 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		data_sz = MAX_REJECT_SIZE;
 	if (msg_connected(msg) && (imp < TIPC_CRITICAL_IMPORTANCE))
 		imp++;
-	msg_dbg(msg, "port->rej: ");
 
 	/* discard rejected message if it shouldn't be returned to sender */
 	if (msg_errcode(msg) || msg_dest_droppable(msg)) {
@@ -547,8 +543,6 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	struct sk_buff *r_buf = NULL;
 	struct sk_buff *abort_buf = NULL;
 
-	msg_dbg(msg, "PORT<RECV<:");
-
 	if (!p_ptr) {
 		err = TIPC_ERR_NO_PORT;
 	} else if (p_ptr->publ.connected) {
@@ -1015,9 +1009,6 @@ int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 	if (!p_ptr)
 		return -EINVAL;
 
-	dbg("tipc_publ %u, p_ptr = %x, conn = %x, scope = %x, "
-	    "lower = %u, upper = %u\n",
-	    ref, p_ptr, p_ptr->publ.connected, scope, seq->lower, seq->upper);
 	if (p_ptr->publ.connected)
 		goto exit;
 	if (seq->lower > seq->upper)
@@ -1357,7 +1348,6 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 
 	skb_push(buf, DIR_MSG_H_SIZE);
 	skb_copy_to_linear_data(buf, msg, DIR_MSG_H_SIZE);
-	msg_dbg(msg, "buf2port: ");
 	p_ptr->sent++;
 	if (dest->node == tipc_own_addr)
 		return tipc_port_recv_msg(buf);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index da607a8..a9c5287 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -316,7 +316,6 @@ static inline int tipc_port_recv_msg(struct sk_buff *buf)
 		err = TIPC_ERR_NO_PORT;
 	}
 reject:
-	dbg("port->rejecting, err = %x..\n",err);
 	return tipc_reject_msg(buf, err);
 }
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index cd0bb77..7a21a5e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1226,42 +1226,25 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 	 */
 
 	if (sock->state == SS_READY) {
-		if (msg_connected(msg)) {
-			msg_dbg(msg, "dispatch filter 1\n");
+		if (msg_connected(msg))
 			return TIPC_ERR_NO_PORT;
-		}
 	} else {
-		if (msg_mcast(msg)) {
-			msg_dbg(msg, "dispatch filter 2\n");
+		if (msg_mcast(msg))
 			return TIPC_ERR_NO_PORT;
-		}
 		if (sock->state == SS_CONNECTED) {
-			if (!msg_connected(msg)) {
-				msg_dbg(msg, "dispatch filter 3\n");
+			if (!msg_connected(msg))
 				return TIPC_ERR_NO_PORT;
-			}
-		}
-		else if (sock->state == SS_CONNECTING) {
-			if (!msg_connected(msg) && (msg_errcode(msg) == 0)) {
-				msg_dbg(msg, "dispatch filter 4\n");
+		} else if (sock->state == SS_CONNECTING) {
+			if (!msg_connected(msg) && (msg_errcode(msg) == 0))
 				return TIPC_ERR_NO_PORT;
-			}
-		}
-		else if (sock->state == SS_LISTENING) {
-			if (msg_connected(msg) || msg_errcode(msg)) {
-				msg_dbg(msg, "dispatch filter 5\n");
+		} else if (sock->state == SS_LISTENING) {
+			if (msg_connected(msg) || msg_errcode(msg))
 				return TIPC_ERR_NO_PORT;
-			}
-		}
-		else if (sock->state == SS_DISCONNECTING) {
-			msg_dbg(msg, "dispatch filter 6\n");
+		} else if (sock->state == SS_DISCONNECTING) {
 			return TIPC_ERR_NO_PORT;
-		}
-		else /* (sock->state == SS_UNCONNECTED) */ {
-			if (msg_connected(msg) || msg_errcode(msg)) {
-				msg_dbg(msg, "dispatch filter 7\n");
+		} else /* (sock->state == SS_UNCONNECTED) */ {
+			if (msg_connected(msg) || msg_errcode(msg))
 				return TIPC_ERR_NO_PORT;
-			}
 		}
 	}
 
@@ -1280,7 +1263,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 
 	/* Enqueue message (finally!) */
 
-	msg_dbg(msg, "<DISP<: ");
 	TIPC_SKB_CB(buf)->handle = msg_data(msg);
 	atomic_inc(&tipc_queue_size);
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
@@ -1588,7 +1570,6 @@ static int accept(struct socket *sock, struct socket *new_sock, int flags)
 		 * Respond to 'SYN+' by queuing it on new socket.
 		 */
 
-		msg_dbg(msg,"<ACC<: ");
 		if (!msg_data_sz(msg)) {
 			struct msghdr m = {NULL,};
 
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index c5ba323..5102711 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -249,8 +249,6 @@ static void subscr_terminate(struct subscriber *subscriber)
 			k_cancel_timer(&sub->timer);
 			k_term_timer(&sub->timer);
 		}
-		dbg("Term: Removing sub %u,%u,%u from subscriber %x list\n",
-		    sub->seq.type, sub->seq.lower, sub->seq.upper, subscriber);
 		subscr_del(sub);
 	}
 
@@ -307,8 +305,6 @@ static void subscr_cancel(struct tipc_subscr *s,
 		k_term_timer(&sub->timer);
 		spin_lock_bh(subscriber->lock);
 	}
-	dbg("Cancel: removing sub %u,%u,%u from subscriber %x list\n",
-	    sub->seq.type, sub->seq.lower, sub->seq.upper, subscriber);
 	subscr_del(sub);
 }
 
-- 
1.7.3.3

