From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/17] tipc: Eliminate trivial buffer manipulation helper routines
Date: Wed, 29 Feb 2012 18:18:35 -0500
Message-ID: <1330557523-2024-10-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53961 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965326Ab2B2XTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:03 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of two inlined routines that simply call existing sk_buff
manipulation routines, since there is no longer any extra processing
done by the helper routines.

Note that these changes are essentially cosmetic in nature, and have
no impact on the actual operation of TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |   12 ++++----
 net/tipc/core.h       |   24 --------------
 net/tipc/discover.c   |    6 ++--
 net/tipc/link.c       |   80 ++++++++++++++++++++++++------------------------
 net/tipc/msg.c        |    2 +-
 net/tipc/name_distr.c |    4 +-
 net/tipc/net.c        |    4 +-
 net/tipc/node.c       |    4 +-
 net/tipc/port.c       |   14 ++++----
 net/tipc/socket.c     |    8 ++--
 10 files changed, 67 insertions(+), 91 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 41ecf31..e00441a2 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -256,7 +256,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 		if (bcbuf_acks(crs) == 0) {
 			bcl->first_out = next;
 			bcl->out_queue_size--;
-			buf_discard(crs);
+			kfree_skb(crs);
 			released = 1;
 		}
 		crs = next;
@@ -330,7 +330,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 		tipc_bearer_send(&bcbearer->bearer, buf, NULL);
 		bcl->stats.sent_nacks++;
 		spin_unlock_bh(&bc_lock);
-		buf_discard(buf);
+		kfree_skb(buf);
 
 		n_ptr->bclink.oos_state++;
 	}
@@ -374,7 +374,7 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 
 	if (!bclink->bcast_nodes.count) {
 		res = msg_data_sz(buf_msg(buf));
-		buf_discard(buf);
+		kfree_skb(buf);
 		goto exit;
 	}
 
@@ -480,7 +480,7 @@ receive:
 			if (likely(msg_mcast(msg)))
 				tipc_port_recv_mcast(buf, NULL);
 			else
-				buf_discard(buf);
+				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
 			spin_lock_bh(&bc_lock);
 			bclink_accept_pkt(node, seqno);
@@ -513,7 +513,7 @@ receive:
 			bclink_accept_pkt(node, seqno);
 			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
-			buf_discard(buf);
+			kfree_skb(buf);
 		}
 		buf = NULL;
 
@@ -569,7 +569,7 @@ receive:
 unlock:
 	tipc_node_unlock(node);
 exit:
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 1260b05..aefe186 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -269,28 +269,4 @@ static inline struct tipc_msg *buf_msg(struct sk_buff *skb)
 
 extern struct sk_buff *tipc_buf_acquire(u32 size);
 
-/**
- * buf_discard - frees a TIPC message buffer
- * @skb: message buffer
- *
- * Frees a message buffer.  If passed NULL, just returns.
- */
-
-static inline void buf_discard(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-}
-
-/**
- * buf_linearize - convert a TIPC message buffer into a single contiguous piece
- * @skb: message buffer
- *
- * Returns 0 on success.
- */
-
-static inline int buf_linearize(struct sk_buff *skb)
-{
-	return skb_linearize(skb);
-}
-
 #endif
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f5f9bf7..c630a21 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -135,7 +135,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 
 	media_addr.broadcast = 1;
 	b_ptr->media->msg2addr(&media_addr, msg_media_addr(msg));
-	buf_discard(buf);
+	kfree_skb(buf);
 
 	/* Ensure message from node is valid and communication is permitted */
 	if (net_id != tipc_net_id)
@@ -250,7 +250,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
 		if (rbuf) {
 			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
-			buf_discard(rbuf);
+			kfree_skb(rbuf);
 		}
 	}
 
@@ -396,7 +396,7 @@ void tipc_disc_delete(struct tipc_link_req *req)
 {
 	k_cancel_timer(&req->timer);
 	k_term_timer(&req->timer);
-	buf_discard(req->buf);
+	kfree_skb(req->buf);
 	kfree(req);
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 6cc78a9..f16e65d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -484,7 +484,7 @@ static void link_release_outqueue(struct tipc_link *l_ptr)
 
 	while (buf) {
 		next = buf->next;
-		buf_discard(buf);
+		kfree_skb(buf);
 		buf = next;
 	}
 	l_ptr->first_out = NULL;
@@ -503,7 +503,7 @@ void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 
 	while (buf) {
 		next = buf->next;
-		buf_discard(buf);
+		kfree_skb(buf);
 		buf = next;
 	}
 	l_ptr->defragm_buf = NULL;
@@ -522,20 +522,20 @@ void tipc_link_stop(struct tipc_link *l_ptr)
 	buf = l_ptr->oldest_deferred_in;
 	while (buf) {
 		next = buf->next;
-		buf_discard(buf);
+		kfree_skb(buf);
 		buf = next;
 	}
 
 	buf = l_ptr->first_out;
 	while (buf) {
 		next = buf->next;
-		buf_discard(buf);
+		kfree_skb(buf);
 		buf = next;
 	}
 
 	tipc_link_reset_fragments(l_ptr);
 
-	buf_discard(l_ptr->proto_msg_queue);
+	kfree_skb(l_ptr->proto_msg_queue);
 	l_ptr->proto_msg_queue = NULL;
 }
 
@@ -571,12 +571,12 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 	/* Clean up all queues: */
 
 	link_release_outqueue(l_ptr);
-	buf_discard(l_ptr->proto_msg_queue);
+	kfree_skb(l_ptr->proto_msg_queue);
 	l_ptr->proto_msg_queue = NULL;
 	buf = l_ptr->oldest_deferred_in;
 	while (buf) {
 		struct sk_buff *next = buf->next;
-		buf_discard(buf);
+		kfree_skb(buf);
 		buf = next;
 	}
 	if (!list_empty(&l_ptr->waiting_ports))
@@ -810,7 +810,7 @@ static int link_bundle_buf(struct tipc_link *l_ptr,
 	skb_copy_to_linear_data_offset(bundler, to_pos, buf->data, size);
 	msg_set_size(bundler_msg, to_pos + size);
 	msg_set_msgcnt(bundler_msg, msg_msgcnt(bundler_msg) + 1);
-	buf_discard(buf);
+	kfree_skb(buf);
 	l_ptr->stats.sent_bundled++;
 	return 1;
 }
@@ -878,10 +878,10 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 	if (unlikely(queue_size >= queue_limit)) {
 		if (imp <= TIPC_CRITICAL_IMPORTANCE) {
 			link_schedule_port(l_ptr, msg_origport(msg), size);
-			buf_discard(buf);
+			kfree_skb(buf);
 			return -ELINKCONG;
 		}
-		buf_discard(buf);
+		kfree_skb(buf);
 		if (imp > CONN_MANAGER) {
 			warn("Resetting link <%s>, send queue full", l_ptr->name);
 			tipc_link_reset(l_ptr);
@@ -968,10 +968,10 @@ int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector)
 		if (l_ptr)
 			res = tipc_link_send_buf(l_ptr, buf);
 		else
-			buf_discard(buf);
+			kfree_skb(buf);
 		tipc_node_unlock(n_ptr);
 	} else {
-		buf_discard(buf);
+		kfree_skb(buf);
 	}
 	read_unlock_bh(&tipc_net_lock);
 	return res;
@@ -1018,7 +1018,7 @@ void tipc_link_send_names(struct list_head *message_list, u32 dest)
 
 	list_for_each_safe(buf, temp_buf, ((struct sk_buff *)message_list)) {
 		list_del((struct list_head *)buf);
-		buf_discard(buf);
+		kfree_skb(buf);
 	}
 }
 
@@ -1262,7 +1262,7 @@ again:
 error:
 				for (; buf_chain; buf_chain = buf) {
 					buf = buf_chain->next;
-					buf_discard(buf_chain);
+					kfree_skb(buf_chain);
 				}
 				return -EFAULT;
 			}
@@ -1316,7 +1316,7 @@ error:
 			tipc_node_unlock(node);
 			for (; buf_chain; buf_chain = buf) {
 				buf = buf_chain->next;
-				buf_discard(buf_chain);
+				kfree_skb(buf_chain);
 			}
 			goto again;
 		}
@@ -1324,7 +1324,7 @@ error:
 reject:
 		for (; buf_chain; buf_chain = buf) {
 			buf = buf_chain->next;
-			buf_discard(buf_chain);
+			kfree_skb(buf_chain);
 		}
 		return tipc_port_reject_sections(sender, hdr, msg_sect, num_sect,
 						 total_len, TIPC_ERR_NO_NODE);
@@ -1390,7 +1390,7 @@ u32 tipc_link_push_packet(struct tipc_link *l_ptr)
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
 			l_ptr->unacked_window = 0;
-			buf_discard(buf);
+			kfree_skb(buf);
 			l_ptr->proto_msg_queue = NULL;
 			return 0;
 		} else {
@@ -1679,7 +1679,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Ensure message data is a single contiguous unit */
 
-		if (unlikely(buf_linearize(buf)))
+		if (unlikely(skb_linearize(buf)))
 			goto cont;
 
 		/* Handle arrival of a non-unicast link message */
@@ -1744,7 +1744,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		       less_eq(buf_seqno(crs), ackd)) {
 			struct sk_buff *next = crs->next;
 
-			buf_discard(crs);
+			kfree_skb(crs);
 			crs = next;
 			released++;
 		}
@@ -1820,7 +1820,7 @@ deliver:
 					}
 					break;
 				default:
-					buf_discard(buf);
+					kfree_skb(buf);
 					buf = NULL;
 					break;
 				}
@@ -1851,7 +1851,7 @@ deliver:
 		}
 		tipc_node_unlock(n_ptr);
 cont:
-		buf_discard(buf);
+		kfree_skb(buf);
 	}
 	read_unlock_bh(&tipc_net_lock);
 }
@@ -1891,7 +1891,7 @@ u32 tipc_link_defer_pkt(struct sk_buff **head, struct sk_buff **tail,
 		u32 curr_seqno = buf_seqno(queue_buf);
 
 		if (seq_no == curr_seqno) {
-			buf_discard(buf);
+			kfree_skb(buf);
 			return 0;
 		}
 
@@ -1932,7 +1932,7 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 
 	if (less(seq_no, mod(l_ptr->next_in_no))) {
 		l_ptr->stats.duplicates++;
-		buf_discard(buf);
+		kfree_skb(buf);
 		return;
 	}
 
@@ -1961,7 +1961,7 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	/* Discard any previous message that was deferred due to congestion */
 
 	if (l_ptr->proto_msg_queue) {
-		buf_discard(l_ptr->proto_msg_queue);
+		kfree_skb(l_ptr->proto_msg_queue);
 		l_ptr->proto_msg_queue = NULL;
 	}
 
@@ -2060,7 +2060,7 @@ void tipc_link_send_proto_msg(struct tipc_link *l_ptr, u32 msg_typ,
 	/* Discard message if it was sent successfully */
 
 	l_ptr->unacked_window = 0;
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 /*
@@ -2204,7 +2204,7 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 		break;
 	}
 exit:
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 
@@ -2402,7 +2402,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 			warn("Link changeover error, duplicate msg dropped\n");
 			goto exit;
 		}
-		buf_discard(tunnel_buf);
+		kfree_skb(tunnel_buf);
 		return 1;
 	}
 
@@ -2434,7 +2434,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	} else {
 		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
 		if (*buf != NULL) {
-			buf_discard(tunnel_buf);
+			kfree_skb(tunnel_buf);
 			return 1;
 		} else {
 			warn("Link changeover error, original msg dropped\n");
@@ -2442,7 +2442,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	}
 exit:
 	*buf = NULL;
-	buf_discard(tunnel_buf);
+	kfree_skb(tunnel_buf);
 	return 0;
 }
 
@@ -2464,7 +2464,7 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 		pos += align(msg_size(buf_msg(obuf)));
 		tipc_net_route_msg(obuf);
 	}
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 /*
@@ -2513,11 +2513,11 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 		fragm = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
 		if (fragm == NULL) {
-			buf_discard(buf);
+			kfree_skb(buf);
 			while (buf_chain) {
 				buf = buf_chain;
 				buf_chain = buf_chain->next;
-				buf_discard(buf);
+				kfree_skb(buf);
 			}
 			return -ENOMEM;
 		}
@@ -2534,7 +2534,7 @@ static int link_send_long_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		crs += fragm_sz;
 		msg_set_type(&fragm_hdr, FRAGMENT);
 	}
-	buf_discard(buf);
+	kfree_skb(buf);
 
 	/* Append chain of fragments to send queue & send them */
 
@@ -2621,7 +2621,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		if (msg_type(imsg) == TIPC_MCAST_MSG)
 			max = TIPC_MAX_USER_MSG_SIZE + MCAST_H_SIZE;
 		if (msg_size(imsg) > max) {
-			buf_discard(fbuf);
+			kfree_skb(fbuf);
 			return 0;
 		}
 		pbuf = tipc_buf_acquire(msg_size(imsg));
@@ -2637,10 +2637,10 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			set_expected_frags(pbuf, exp_fragm_cnt - 1);
 		} else {
 			dbg("Link unable to reassemble fragmented message\n");
-			buf_discard(fbuf);
+			kfree_skb(fbuf);
 			return -1;
 		}
-		buf_discard(fbuf);
+		kfree_skb(fbuf);
 		return 0;
 	} else if (pbuf && (msg_type(fragm) != FIRST_FRAGMENT)) {
 		u32 dsz = msg_data_sz(fragm);
@@ -2649,7 +2649,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		u32 exp_frags = get_expected_frags(pbuf) - 1;
 		skb_copy_to_linear_data_offset(pbuf, crs,
 					       msg_data(fragm), dsz);
-		buf_discard(fbuf);
+		kfree_skb(fbuf);
 
 		/* Is message complete? */
 
@@ -2666,7 +2666,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		set_expected_frags(pbuf, exp_frags);
 		return 0;
 	}
-	buf_discard(fbuf);
+	kfree_skb(fbuf);
 	return 0;
 }
 
@@ -2697,7 +2697,7 @@ static void link_check_defragm_bufs(struct tipc_link *l_ptr)
 				prev->next = buf->next;
 			else
 				l_ptr->defragm_buf = buf->next;
-			buf_discard(buf);
+			kfree_skb(buf);
 		}
 		buf = next;
 	}
@@ -3072,7 +3072,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_s
 	str_len = tipc_link_stats((char *)TLV_DATA(req_tlv_area),
 				  (char *)TLV_DATA(rep_tlv), MAX_LINK_STATS_INFO);
 	if (!str_len) {
-		buf_discard(buf);
+		kfree_skb(buf);
 		return tipc_cfg_reply_error_string("link not found");
 	}
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 3e4d3e2..e3afe16 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -106,7 +106,7 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 	if (likely(res))
 		return dsz;
 
-	buf_discard(*buf);
+	kfree_skb(*buf);
 	*buf = NULL;
 	return -EFAULT;
 }
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index acecfda..d57da61 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -120,7 +120,7 @@ static void named_cluster_distribute(struct sk_buff *buf)
 		}
 	}
 
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 /**
@@ -312,7 +312,7 @@ void tipc_named_recv(struct sk_buff *buf)
 		item++;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 /**
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 61afee7..2abd4be 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -117,7 +117,7 @@ static void net_route_named_msg(struct sk_buff *buf)
 	u32 dport;
 
 	if (!msg_named(msg)) {
-		buf_discard(buf);
+		kfree_skb(buf);
 		return;
 	}
 
@@ -161,7 +161,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 			tipc_port_recv_proto_msg(buf);
 			break;
 		default:
-			buf_discard(buf);
+			kfree_skb(buf);
 		}
 		return;
 	}
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1790f50..24c42f7 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -353,12 +353,12 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		while (n_ptr->bclink.deferred_head) {
 			struct sk_buff *buf = n_ptr->bclink.deferred_head;
 			n_ptr->bclink.deferred_head = buf->next;
-			buf_discard(buf);
+			kfree_skb(buf);
 		}
 		n_ptr->bclink.deferred_size = 0;
 
 		if (n_ptr->bclink.defragm) {
-			buf_discard(n_ptr->bclink.defragm);
+			kfree_skb(n_ptr->bclink.defragm);
 			n_ptr->bclink.defragm = NULL;
 		}
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index ba3268b..c4b5a34 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -116,13 +116,13 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 			ibuf = skb_copy(buf, GFP_ATOMIC);
 			if (ibuf == NULL) {
 				tipc_port_list_free(&dports);
-				buf_discard(buf);
+				kfree_skb(buf);
 				return -ENOMEM;
 			}
 		}
 		res = tipc_bclink_send_msg(buf);
 		if ((res < 0) && (dports.count != 0))
-			buf_discard(ibuf);
+			kfree_skb(ibuf);
 	} else {
 		ibuf = buf;
 	}
@@ -187,7 +187,7 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 		}
 	}
 exit:
-	buf_discard(buf);
+	kfree_skb(buf);
 	tipc_port_list_free(dp);
 }
 
@@ -420,7 +420,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	else
 		tipc_link_send(rbuf, src_node, msg_link_selector(rmsg));
 exit:
-	buf_discard(buf);
+	kfree_skb(buf);
 	return data_sz;
 }
 
@@ -568,7 +568,7 @@ void tipc_port_recv_proto_msg(struct sk_buff *buf)
 	tipc_port_unlock(p_ptr);
 exit:
 	tipc_net_route_msg(r_buf);
-	buf_discard(buf);
+	kfree_skb(buf);
 }
 
 static void port_print(struct tipc_port *p_ptr, struct print_buf *buf, int full_id)
@@ -759,7 +759,7 @@ static void port_dispatcher_sigh(void *dummy)
 			}
 		}
 		if (buf)
-			buf_discard(buf);
+			kfree_skb(buf);
 		buf = next;
 		continue;
 err:
@@ -813,7 +813,7 @@ err:
 			}
 		}
 		if (buf)
-			buf_discard(buf);
+			kfree_skb(buf);
 		buf = next;
 		continue;
 reject:
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d3227f2..29e957f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -126,7 +126,7 @@ static atomic_t tipc_queue_size = ATOMIC_INIT(0);
 
 static void advance_rx_queue(struct sock *sk)
 {
-	buf_discard(__skb_dequeue(&sk->sk_receive_queue));
+	kfree_skb(__skb_dequeue(&sk->sk_receive_queue));
 	atomic_dec(&tipc_queue_size);
 }
 
@@ -142,7 +142,7 @@ static void discard_rx_queue(struct sock *sk)
 
 	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
 		atomic_dec(&tipc_queue_size);
-		buf_discard(buf);
+		kfree_skb(buf);
 	}
 }
 
@@ -288,7 +288,7 @@ static int release(struct socket *sock)
 			break;
 		atomic_dec(&tipc_queue_size);
 		if (TIPC_SKB_CB(buf)->handle != 0)
-			buf_discard(buf);
+			kfree_skb(buf);
 		else {
 			if ((sock->state == SS_CONNECTING) ||
 			    (sock->state == SS_CONNECTED)) {
@@ -1615,7 +1615,7 @@ restart:
 		if (buf) {
 			atomic_dec(&tipc_queue_size);
 			if (TIPC_SKB_CB(buf)->handle != 0) {
-				buf_discard(buf);
+				kfree_skb(buf);
 				goto restart;
 			}
 			tipc_disconnect(tport->ref);
-- 
1.7.9.1
