From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: l2tp: Standardize logging styles
Date: Wed, 16 May 2012 12:55:56 -0700
Message-ID: <1337198156.10019.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:50693 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760587Ab2EPTz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 15:55:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more current logging styles.

Add pr_fmt to prefix output appropriately.
Convert printks to pr_<level>.
Convert PRINTK macros to new l2tp_<level> macros.
Neaten some <foo>_refcount debugging macros.
Use print_hex_dump_bytes instead of hand-coded loops.
Coalesce formats and align arguments.

Some KERN_DEBUG output is not now emitted unless
dynamic_debugging is enabled.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/l2tp/l2tp_core.c    |  216 ++++++++++++++++++++++-------------------------
 net/l2tp/l2tp_core.h    |   35 ++++++--
 net/l2tp/l2tp_debugfs.c |    6 +-
 net/l2tp/l2tp_eth.c     |   15 +--
 net/l2tp/l2tp_ip.c      |   15 +--
 net/l2tp/l2tp_ip6.c     |   15 +--
 net/l2tp/l2tp_netlink.c |    4 +-
 net/l2tp/l2tp_ppp.c     |  128 ++++++++++++++--------------
 8 files changed, 213 insertions(+), 221 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 0d6aedc..32b2155 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -18,6 +18,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/string.h>
 #include <linux/list.h>
@@ -86,12 +88,6 @@
 /* Default trace flags */
 #define L2TP_DEFAULT_DEBUG_FLAGS	0
 
-#define PRINTK(_mask, _type, _lvl, _fmt, args...)			\
-	do {								\
-		if ((_mask) & (_type))					\
-			printk(_lvl "L2TP: " _fmt, ##args);		\
-	} while (0)
-
 /* Private data stored for received packets in the skb.
  */
 struct l2tp_skb_cb {
@@ -141,14 +137,20 @@ static inline void l2tp_tunnel_dec_refcount_1(struct l2tp_tunnel *tunnel)
 		l2tp_tunnel_free(tunnel);
 }
 #ifdef L2TP_REFCNT_DEBUG
-#define l2tp_tunnel_inc_refcount(_t) do { \
-		printk(KERN_DEBUG "l2tp_tunnel_inc_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
-		l2tp_tunnel_inc_refcount_1(_t);				\
-	} while (0)
-#define l2tp_tunnel_dec_refcount(_t) do { \
-		printk(KERN_DEBUG "l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_t)->name, atomic_read(&_t->ref_count)); \
-		l2tp_tunnel_dec_refcount_1(_t);				\
-	} while (0)
+#define l2tp_tunnel_inc_refcount(_t)					\
+do {									\
+	pr_debug("l2tp_tunnel_inc_refcount: %s:%d %s: cnt=%d\n",	\
+		 __func__, __LINE__, (_t)->name,			\
+		 atomic_read(&_t->ref_count));				\
+	l2tp_tunnel_inc_refcount_1(_t);					\
+} while (0)
+#define l2tp_tunnel_dec_refcount(_t)
+do {									\
+	pr_debug("l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n",	\
+		 __func__, __LINE__, (_t)->name,			\
+		 atomic_read(&_t->ref_count));				\
+	l2tp_tunnel_dec_refcount_1(_t);					\
+} while (0)
 #else
 #define l2tp_tunnel_inc_refcount(t) l2tp_tunnel_inc_refcount_1(t)
 #define l2tp_tunnel_dec_refcount(t) l2tp_tunnel_dec_refcount_1(t)
@@ -337,10 +339,10 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (L2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_queue_before(&session->reorder_q, skbp, skb);
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-			       "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
-			       session->name, ns, L2TP_SKB_CB(skbp)->ns,
-			       skb_queue_len(&session->reorder_q));
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
+				 session->name, ns, L2TP_SKB_CB(skbp)->ns,
+				 skb_queue_len(&session->reorder_q));
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_oos_packets++;
 			u64_stats_update_end(&sstats->syncp);
@@ -386,8 +388,8 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 		else
 			session->nr &= 0xffffff;
 
-		PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-		       "%s: updated nr to %hu\n", session->name, session->nr);
+		l2tp_dbg(session, L2TP_MSG_SEQ, "%s: updated nr to %hu\n",
+			 session->name, session->nr);
 	}
 
 	/* call private receive handler */
@@ -422,12 +424,11 @@ start:
 			sstats->rx_seq_discards++;
 			sstats->rx_errors++;
 			u64_stats_update_end(&sstats->syncp);
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-			       "%s: oos pkt %u len %d discarded (too old), "
-			       "waiting for %u, reorder_q_len=%d\n",
-			       session->name, L2TP_SKB_CB(skb)->ns,
-			       L2TP_SKB_CB(skb)->length, session->nr,
-			       skb_queue_len(&session->reorder_q));
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: oos pkt %u len %d discarded (too old), waiting for %u, reorder_q_len=%d\n",
+				 session->name, L2TP_SKB_CB(skb)->ns,
+				 L2TP_SKB_CB(skb)->length, session->nr,
+				 skb_queue_len(&session->reorder_q));
 			session->reorder_skip = 1;
 			__skb_unlink(skb, &session->reorder_q);
 			kfree_skb(skb);
@@ -438,20 +439,19 @@ start:
 
 		if (L2TP_SKB_CB(skb)->has_seq) {
 			if (session->reorder_skip) {
-				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: advancing nr to next pkt: %u -> %u",
-				       session->name, session->nr,
-				       L2TP_SKB_CB(skb)->ns);
+				l2tp_dbg(session, L2TP_MSG_SEQ,
+					 "%s: advancing nr to next pkt: %u -> %u",
+					 session->name, session->nr,
+					 L2TP_SKB_CB(skb)->ns);
 				session->reorder_skip = 0;
 				session->nr = L2TP_SKB_CB(skb)->ns;
 			}
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
-				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: holding oos pkt %u len %d, "
-				       "waiting for %u, reorder_q_len=%d\n",
-				       session->name, L2TP_SKB_CB(skb)->ns,
-				       L2TP_SKB_CB(skb)->length, session->nr,
-				       skb_queue_len(&session->reorder_q));
+				l2tp_dbg(session, L2TP_MSG_SEQ,
+					 "%s: holding oos pkt %u len %d, waiting for %u, reorder_q_len=%d\n",
+					 session->name, L2TP_SKB_CB(skb)->ns,
+					 L2TP_SKB_CB(skb)->length, session->nr,
+					 skb_queue_len(&session->reorder_q));
 				goto out;
 			}
 		}
@@ -595,9 +595,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	/* Parse and check optional cookie */
 	if (session->peer_cookie_len > 0) {
 		if (memcmp(ptr, &session->peer_cookie[0], session->peer_cookie_len)) {
-			PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-			       "%s: cookie mismatch (%u/%u). Discarding.\n",
-			       tunnel->name, tunnel->tunnel_id, session->session_id);
+			l2tp_info(tunnel, L2TP_MSG_DATA,
+				  "%s: cookie mismatch (%u/%u). Discarding.\n",
+				  tunnel->name, tunnel->tunnel_id,
+				  session->session_id);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_cookie_discards++;
 			u64_stats_update_end(&sstats->syncp);
@@ -626,9 +627,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			L2TP_SKB_CB(skb)->ns = ns;
 			L2TP_SKB_CB(skb)->has_seq = 1;
 
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-			       "%s: recv data ns=%u, nr=%u, session nr=%u\n",
-			       session->name, ns, nr, session->nr);
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: recv data ns=%u, nr=%u, session nr=%u\n",
+				 session->name, ns, nr, session->nr);
 		}
 	} else if (session->l2specific_type == L2TP_L2SPECTYPE_DEFAULT) {
 		u32 l2h = ntohl(*(__be32 *) ptr);
@@ -640,9 +641,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			L2TP_SKB_CB(skb)->ns = ns;
 			L2TP_SKB_CB(skb)->has_seq = 1;
 
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-			       "%s: recv data ns=%u, session nr=%u\n",
-			       session->name, ns, session->nr);
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: recv data ns=%u, session nr=%u\n",
+				 session->name, ns, session->nr);
 		}
 	}
 
@@ -655,9 +656,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 		 * configure it so.
 		 */
 		if ((!session->lns_mode) && (!session->send_seq)) {
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_INFO,
-			       "%s: requested to enable seq numbers by LNS\n",
-			       session->name);
+			l2tp_info(session, L2TP_MSG_SEQ,
+				  "%s: requested to enable seq numbers by LNS\n",
+				  session->name);
 			session->send_seq = -1;
 			l2tp_session_set_header_len(session, tunnel->version);
 		}
@@ -666,9 +667,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 		 * If user has configured mandatory sequence numbers, discard.
 		 */
 		if (session->recv_seq) {
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_WARNING,
-			       "%s: recv data has no seq numbers when required. "
-			       "Discarding\n", session->name);
+			l2tp_warn(session, L2TP_MSG_SEQ,
+				  "%s: recv data has no seq numbers when required. Discarding.\n",
+				  session->name);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_seq_discards++;
 			u64_stats_update_end(&sstats->syncp);
@@ -681,15 +682,15 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 		 * LAC is broken. Discard the frame.
 		 */
 		if ((!session->lns_mode) && (session->send_seq)) {
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_INFO,
-			       "%s: requested to disable seq numbers by LNS\n",
-			       session->name);
+			l2tp_info(session, L2TP_MSG_SEQ,
+				  "%s: requested to disable seq numbers by LNS\n",
+				  session->name);
 			session->send_seq = 0;
 			l2tp_session_set_header_len(session, tunnel->version);
 		} else if (session->send_seq) {
-			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_WARNING,
-			       "%s: recv data has no seq numbers when required. "
-			       "Discarding\n", session->name);
+			l2tp_warn(session, L2TP_MSG_SEQ,
+				  "%s: recv data has no seq numbers when required. Discarding.\n",
+				  session->name);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_seq_discards++;
 			u64_stats_update_end(&sstats->syncp);
@@ -749,12 +750,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 				u64_stats_update_begin(&sstats->syncp);
 				sstats->rx_seq_discards++;
 				u64_stats_update_end(&sstats->syncp);
-				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: oos pkt %u len %d discarded, "
-				       "waiting for %u, reorder_q_len=%d\n",
-				       session->name, L2TP_SKB_CB(skb)->ns,
-				       L2TP_SKB_CB(skb)->length, session->nr,
-				       skb_queue_len(&session->reorder_q));
+				l2tp_dbg(session, L2TP_MSG_SEQ,
+					 "%s: oos pkt %u len %d discarded, waiting for %u, reorder_q_len=%d\n",
+					 session->name, L2TP_SKB_CB(skb)->ns,
+					 L2TP_SKB_CB(skb)->length, session->nr,
+					 skb_queue_len(&session->reorder_q));
 				goto discard;
 			}
 			skb_queue_tail(&session->reorder_q, skb);
@@ -800,7 +800,6 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	unsigned char *ptr, *optr;
 	u16 hdrflags;
 	u32 tunnel_id, session_id;
-	int offset;
 	u16 version;
 	int length;
 	struct l2tp_stats *tstats;
@@ -813,8 +812,9 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 
 	/* Short packet? */
 	if (!pskb_may_pull(skb, L2TP_HDR_SIZE_SEQ)) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: recv short packet (len=%d)\n", tunnel->name, skb->len);
+		l2tp_info(tunnel, L2TP_MSG_DATA,
+			  "%s: recv short packet (len=%d)\n",
+			  tunnel->name, skb->len);
 		goto error;
 	}
 
@@ -824,14 +824,8 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 		if (!pskb_may_pull(skb, length))
 			goto error;
 
-		printk(KERN_DEBUG "%s: recv: ", tunnel->name);
-
-		offset = 0;
-		do {
-			printk(" %02X", skb->data[offset]);
-		} while (++offset < length);
-
-		printk("\n");
+		pr_debug("%s: recv\n", tunnel->name);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, skb->data, length);
 	}
 
 	/* Point to L2TP header */
@@ -843,9 +837,9 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	/* Check protocol version */
 	version = hdrflags & L2TP_HDR_VER_MASK;
 	if (version != tunnel->version) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: recv protocol version mismatch: got %d expected %d\n",
-		       tunnel->name, version, tunnel->version);
+		l2tp_info(tunnel, L2TP_MSG_DATA,
+			  "%s: recv protocol version mismatch: got %d expected %d\n",
+			  tunnel->name, version, tunnel->version);
 		goto error;
 	}
 
@@ -854,8 +848,9 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 
 	/* If type is control packet, it is handled by userspace. */
 	if (hdrflags & L2TP_HDRFLAG_T) {
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: recv control packet, len=%d\n", tunnel->name, length);
+		l2tp_dbg(tunnel, L2TP_MSG_DATA,
+			 "%s: recv control packet, len=%d\n",
+			 tunnel->name, length);
 		goto error;
 	}
 
@@ -883,9 +878,9 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	session = l2tp_session_find(tunnel->l2tp_net, tunnel, session_id);
 	if (!session || !session->recv_skb) {
 		/* Not found? Pass to userspace to deal with */
-		PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
-		       "%s: no session found (%u/%u). Passing up.\n",
-		       tunnel->name, tunnel_id, session_id);
+		l2tp_info(tunnel, L2TP_MSG_DATA,
+			  "%s: no session found (%u/%u). Passing up.\n",
+			  tunnel->name, tunnel_id, session_id);
 		goto error;
 	}
 
@@ -925,8 +920,8 @@ int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (tunnel == NULL)
 		goto pass_up;
 
-	PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_DEBUG,
-	       "%s: received %d bytes\n", tunnel->name, skb->len);
+	l2tp_dbg(tunnel, L2TP_MSG_DATA, "%s: received %d bytes\n",
+		 tunnel->name, skb->len);
 
 	if (l2tp_udp_recv_core(tunnel, skb, tunnel->recv_payload_hook))
 		goto pass_up_put;
@@ -968,8 +963,8 @@ static int l2tp_build_l2tpv2_header(struct l2tp_session *session, void *buf)
 		*bufp++ = 0;
 		session->ns++;
 		session->ns &= 0xffff;
-		PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-		       "%s: updated ns to %u\n", session->name, session->ns);
+		l2tp_dbg(session, L2TP_MSG_SEQ, "%s: updated ns to %u\n",
+			 session->name, session->ns);
 	}
 
 	return bufp - optr;
@@ -1005,8 +1000,9 @@ static int l2tp_build_l2tpv3_header(struct l2tp_session *session, void *buf)
 				l2h = 0x40000000 | session->ns;
 				session->ns++;
 				session->ns &= 0xffffff;
-				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
-				       "%s: updated ns to %u\n", session->name, session->ns);
+				l2tp_dbg(session, L2TP_MSG_SEQ,
+					 "%s: updated ns to %u\n",
+					 session->name, session->ns);
 			}
 
 			*((__be32 *) bufp) = htonl(l2h);
@@ -1029,27 +1025,19 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	/* Debug */
 	if (session->send_seq)
-		PRINTK(session->debug, L2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: send %Zd bytes, ns=%u\n", session->name,
-		       data_len, session->ns - 1);
+		l2tp_dbg(session, L2TP_MSG_DATA, "%s: send %Zd bytes, ns=%u\n",
+			 session->name, data_len, session->ns - 1);
 	else
-		PRINTK(session->debug, L2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: send %Zd bytes\n", session->name, data_len);
+		l2tp_dbg(session, L2TP_MSG_DATA, "%s: send %Zd bytes\n",
+			 session->name, data_len);
 
 	if (session->debug & L2TP_MSG_DATA) {
-		int i;
 		int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 		unsigned char *datap = skb->data + uhlen;
 
-		printk(KERN_DEBUG "%s: xmit:", session->name);
-		for (i = 0; i < (len - uhlen); i++) {
-			printk(" %02X", *datap++);
-			if (i == 31) {
-				printk(" ...");
-				break;
-			}
-		}
-		printk("\n");
+		pr_debug("%s: xmit\n", session->name);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,
+				     datap, min_t(size_t, 32, len - uhlen));
 	}
 
 	/* Queue the packet to IP for output */
@@ -1248,8 +1236,7 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 	if (tunnel == NULL)
 		goto end;
 
-	PRINTK(tunnel->debug, L2TP_MSG_CONTROL, KERN_INFO,
-	       "%s: closing...\n", tunnel->name);
+	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: closing...\n", tunnel->name);
 
 	/* Close all sessions */
 	l2tp_tunnel_closeall(tunnel);
@@ -1291,8 +1278,8 @@ static void l2tp_tunnel_closeall(struct l2tp_tunnel *tunnel)
 
 	BUG_ON(tunnel == NULL);
 
-	PRINTK(tunnel->debug, L2TP_MSG_CONTROL, KERN_INFO,
-	       "%s: closing all sessions...\n", tunnel->name);
+	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: closing all sessions...\n",
+		  tunnel->name);
 
 	write_lock_bh(&tunnel->hlist_lock);
 	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
@@ -1300,8 +1287,8 @@ again:
 		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
 			session = hlist_entry(walk, struct l2tp_session, hlist);
 
-			PRINTK(session->debug, L2TP_MSG_CONTROL, KERN_INFO,
-			       "%s: closing session\n", session->name);
+			l2tp_info(session, L2TP_MSG_CONTROL,
+				  "%s: closing session\n", session->name);
 
 			hlist_del_init(&session->hlist);
 
@@ -1354,8 +1341,7 @@ static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 	BUG_ON(atomic_read(&tunnel->ref_count) != 0);
 	BUG_ON(tunnel->sock != NULL);
 
-	PRINTK(tunnel->debug, L2TP_MSG_CONTROL, KERN_INFO,
-	       "%s: free...\n", tunnel->name);
+	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: free...\n", tunnel->name);
 
 	/* Remove from tunnel list */
 	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
@@ -1536,7 +1522,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		err = -EBADF;
 		sock = sockfd_lookup(fd, &err);
 		if (!sock) {
-			printk(KERN_ERR "tunl %hu: sockfd_lookup(fd=%d) returned %d\n",
+			pr_err("tunl %hu: sockfd_lookup(fd=%d) returned %d\n",
 			       tunnel_id, fd, err);
 			goto err;
 		}
@@ -1552,7 +1538,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	case L2TP_ENCAPTYPE_UDP:
 		err = -EPROTONOSUPPORT;
 		if (sk->sk_protocol != IPPROTO_UDP) {
-			printk(KERN_ERR "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
 			       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
 			goto err;
 		}
@@ -1560,7 +1546,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	case L2TP_ENCAPTYPE_IP:
 		err = -EPROTONOSUPPORT;
 		if (sk->sk_protocol != IPPROTO_L2TP) {
-			printk(KERN_ERR "tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
 			       tunnel_id, fd, sk->sk_protocol, IPPROTO_L2TP);
 			goto err;
 		}
@@ -1868,7 +1854,7 @@ static int __init l2tp_init(void)
 	if (rc)
 		goto out;
 
-	printk(KERN_INFO "L2TP core driver, %s\n", L2TP_DRV_VERSION);
+	pr_info("L2TP core driver, %s\n", L2TP_DRV_VERSION);
 
 out:
 	return rc;
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 9002634..a38ec6c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -261,17 +261,36 @@ static inline void l2tp_session_dec_refcount_1(struct l2tp_session *session)
 }
 
 #ifdef L2TP_REFCNT_DEBUG
-#define l2tp_session_inc_refcount(_s) do { \
-		printk(KERN_DEBUG "l2tp_session_inc_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_s)->name, atomic_read(&_s->ref_count)); \
-		l2tp_session_inc_refcount_1(_s);				\
-	} while (0)
-#define l2tp_session_dec_refcount(_s) do { \
-		printk(KERN_DEBUG "l2tp_session_dec_refcount: %s:%d %s: cnt=%d\n", __func__, __LINE__, (_s)->name, atomic_read(&_s->ref_count)); \
-		l2tp_session_dec_refcount_1(_s);				\
-	} while (0)
+#define l2tp_session_inc_refcount(_s)					\
+do {									\
+	pr_debug("l2tp_session_inc_refcount: %s:%d %s: cnt=%d\n",	\
+		 __func__, __LINE__, (_s)->name,			\
+		 atomic_read(&_s->ref_count));				\
+	l2tp_session_inc_refcount_1(_s);				\
+} while (0)
+#define l2tp_session_dec_refcount(_s)					\
+do {									\
+	pr_debug("l2tp_session_dec_refcount: %s:%d %s: cnt=%d\n",	\
+		 __func__, __LINE__, (_s)->name,			\
+		 atomic_read(&_s->ref_count));				\
+	l2tp_session_dec_refcount_1(_s);				\
+} while (0)
 #else
 #define l2tp_session_inc_refcount(s) l2tp_session_inc_refcount_1(s)
 #define l2tp_session_dec_refcount(s) l2tp_session_dec_refcount_1(s)
 #endif
 
+#define l2tp_printk(ptr, type, func, fmt, ...)				\
+do {									\
+	if (((ptr)->debug) & (type))					\
+		func(fmt, ##__VA_ARGS__);				\
+} while (0)
+
+#define l2tp_warn(ptr, type, fmt, ...)					\
+	l2tp_printk(ptr, type, pr_warn, fmt, ##__VA_ARGS__)
+#define l2tp_info(ptr, type, fmt, ...)					\
+	l2tp_printk(ptr, type, pr_info, fmt, ##__VA_ARGS__)
+#define l2tp_dbg(ptr, type, fmt, ...)					\
+	l2tp_printk(ptr, type, pr_debug, fmt, ##__VA_ARGS__)
+
 #endif /* _L2TP_CORE_H_ */
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index c0d57ba..c3813bc 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -9,6 +9,8 @@
  *	2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
@@ -325,11 +327,11 @@ static int __init l2tp_debugfs_init(void)
 	if (tunnels == NULL)
 		rc = -EIO;
 
-	printk(KERN_INFO "L2TP debugfs support\n");
+	pr_info("L2TP debugfs support\n");
 
 out:
 	if (rc)
-		printk(KERN_WARNING "l2tp debugfs: unable to init\n");
+		pr_warn("unable to init\n");
 
 	return rc;
 }
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 63fe5f3..443591d 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -9,6 +9,8 @@
  *	2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
@@ -115,21 +117,14 @@ static void l2tp_eth_dev_recv(struct l2tp_session *session, struct sk_buff *skb,
 
 	if (session->debug & L2TP_MSG_DATA) {
 		unsigned int length;
-		int offset;
 		u8 *ptr = skb->data;
 
 		length = min(32u, skb->len);
 		if (!pskb_may_pull(skb, length))
 			goto error;
 
-		printk(KERN_DEBUG "%s: eth recv: ", session->name);
-
-		offset = 0;
-		do {
-			printk(" %02X", ptr[offset]);
-		} while (++offset < length);
-
-		printk("\n");
+		pr_debug("%s: eth recv\n", session->name);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, ptr, length);
 	}
 
 	if (!pskb_may_pull(skb, sizeof(ETH_HLEN)))
@@ -308,7 +303,7 @@ static int __init l2tp_eth_init(void)
 	if (err)
 		goto out_unreg;
 
-	printk(KERN_INFO "L2TP ethernet pseudowire support (L2TPv3)\n");
+	pr_info("L2TP ethernet pseudowire support (L2TPv3)\n");
 
 	return 0;
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index c89a32f..889f5d1 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -9,6 +9,8 @@
  *	2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/icmp.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -120,7 +122,6 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel = NULL;
 	int length;
-	int offset;
 
 	/* Point to L2TP header */
 	optr = ptr = skb->data;
@@ -155,14 +156,8 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, length))
 			goto discard;
 
-		printk(KERN_DEBUG "%s: ip recv: ", tunnel->name);
-
-		offset = 0;
-		do {
-			printk(" %02X", ptr[offset]);
-		} while (++offset < length);
-
-		printk("\n");
+		pr_debug("%s: ip recv\n", tunnel->name);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, ptr, length);
 	}
 
 	l2tp_recv_common(session, skb, ptr, optr, 0, skb->len, tunnel->recv_payload_hook);
@@ -593,7 +588,7 @@ static int __init l2tp_ip_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "L2TP IP encapsulation support (L2TPv3)\n");
+	pr_info("L2TP IP encapsulation support (L2TPv3)\n");
 
 	err = proto_register(&l2tp_ip_prot, 1);
 	if (err != 0)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 88f0abe..0291d8d 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -9,6 +9,8 @@
  *	2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/icmp.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -133,7 +135,6 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel = NULL;
 	int length;
-	int offset;
 
 	/* Point to L2TP header */
 	optr = ptr = skb->data;
@@ -168,14 +169,8 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 		if (!pskb_may_pull(skb, length))
 			goto discard;
 
-		printk(KERN_DEBUG "%s: ip recv: ", tunnel->name);
-
-		offset = 0;
-		do {
-			printk(" %02X", ptr[offset]);
-		} while (++offset < length);
-
-		printk("\n");
+		pr_debug("%s: ip recv\n", tunnel->name);
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, ptr, length);
 	}
 
 	l2tp_recv_common(session, skb, ptr, optr, 0, skb->len,
@@ -752,7 +747,7 @@ static int __init l2tp_ip6_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "L2TP IP encapsulation support for IPv6 (L2TPv3)\n");
+	pr_info("L2TP IP encapsulation support for IPv6 (L2TPv3)\n");
 
 	err = proto_register(&l2tp_ip6_prot, 1);
 	if (err != 0)
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 24edad0..8577264 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -14,6 +14,8 @@
  * published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/sock.h>
 #include <net/genetlink.h>
 #include <net/udp.h>
@@ -902,7 +904,7 @@ static int l2tp_nl_init(void)
 {
 	int err;
 
-	printk(KERN_INFO "L2TP netlink interface\n");
+	pr_info("L2TP netlink interface\n");
 	err = genl_register_family_with_ops(&l2tp_nl_family, l2tp_nl_ops,
 					    ARRAY_SIZE(l2tp_nl_ops));
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 9f2c421..8ef6b94 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -57,6 +57,8 @@
  * http://openl2tp.sourceforge.net.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/string.h>
 #include <linux/list.h>
@@ -106,12 +108,6 @@
 /* Space for UDP, L2TP and PPP headers */
 #define PPPOL2TP_HEADER_OVERHEAD	40
 
-#define PRINTK(_mask, _type, _lvl, _fmt, args...)			\
-	do {								\
-		if ((_mask) & (_type))					\
-			printk(_lvl "PPPOL2TP: " _fmt, ##args);		\
-	} while (0)
-
 /* Number of bytes to build transmit L2TP headers.
  * Unfortunately the size is different depending on whether sequence numbers
  * are enabled.
@@ -236,9 +232,9 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		struct pppox_sock *po;
-		PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_DEBUG,
-		       "%s: recv %d byte data frame, passing to ppp\n",
-		       session->name, data_len);
+		l2tp_dbg(session, PPPOL2TP_MSG_DATA,
+			 "%s: recv %d byte data frame, passing to ppp\n",
+			 session->name, data_len);
 
 		/* We need to forget all info related to the L2TP packet
 		 * gathered in the skb as we are going to reuse the same
@@ -259,8 +255,8 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 		po = pppox_sk(sk);
 		ppp_input(&po->chan, skb);
 	} else {
-		PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_INFO,
-		       "%s: socket not bound\n", session->name);
+		l2tp_info(session, PPPOL2TP_MSG_DATA, "%s: socket not bound\n",
+			  session->name);
 
 		/* Not bound. Nothing we can do, so discard. */
 		session->stats.rx_errors++;
@@ -270,8 +266,7 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 	return;
 
 no_sock:
-	PRINTK(session->debug, PPPOL2TP_MSG_DATA, KERN_INFO,
-	       "%s: no socket\n", session->name);
+	l2tp_info(session, PPPOL2TP_MSG_DATA, "%s: no socket\n", session->name);
 	kfree_skb(skb);
 }
 
@@ -827,8 +822,8 @@ out_no_ppp:
 	/* This is how we get the session context from the socket. */
 	sk->sk_user_data = session;
 	sk->sk_state = PPPOX_CONNECTED;
-	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-	       "%s: created\n", session->name);
+	l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: created\n",
+		  session->name);
 
 end:
 	release_sock(sk);
@@ -881,8 +876,8 @@ static int pppol2tp_session_create(struct net *net, u32 tunnel_id, u32 session_i
 	ps = l2tp_session_priv(session);
 	ps->tunnel_sock = tunnel->sock;
 
-	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-	       "%s: created\n", session->name);
+	l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: created\n",
+		  session->name);
 
 	error = 0;
 
@@ -1058,9 +1053,9 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct pppol2tp_ioc_stats stats;
 
-	PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_DEBUG,
-	       "%s: pppol2tp_session_ioctl(cmd=%#x, arg=%#lx)\n",
-	       session->name, cmd, arg);
+	l2tp_dbg(session, PPPOL2TP_MSG_CONTROL,
+		 "%s: pppol2tp_session_ioctl(cmd=%#x, arg=%#lx)\n",
+		 session->name, cmd, arg);
 
 	sk = ps->sock;
 	sock_hold(sk);
@@ -1078,8 +1073,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		if (copy_to_user((void __user *) arg, &ifr, sizeof(struct ifreq)))
 			break;
 
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get mtu=%d\n", session->name, session->mtu);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: get mtu=%d\n",
+			  session->name, session->mtu);
 		err = 0;
 		break;
 
@@ -1094,8 +1089,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 
 		session->mtu = ifr.ifr_mtu;
 
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set mtu=%d\n", session->name, session->mtu);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: set mtu=%d\n",
+			  session->name, session->mtu);
 		err = 0;
 		break;
 
@@ -1108,8 +1103,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		if (put_user(session->mru, (int __user *) arg))
 			break;
 
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get mru=%d\n", session->name, session->mru);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: get mru=%d\n",
+			  session->name, session->mru);
 		err = 0;
 		break;
 
@@ -1123,8 +1118,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 			break;
 
 		session->mru = val;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set mru=%d\n", session->name, session->mru);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: set mru=%d\n",
+			  session->name, session->mru);
 		err = 0;
 		break;
 
@@ -1133,8 +1128,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		if (put_user(ps->flags, (int __user *) arg))
 			break;
 
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get flags=%d\n", session->name, ps->flags);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: get flags=%d\n",
+			  session->name, ps->flags);
 		err = 0;
 		break;
 
@@ -1143,8 +1138,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		if (get_user(val, (int __user *) arg))
 			break;
 		ps->flags = val;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set flags=%d\n", session->name, ps->flags);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: set flags=%d\n",
+			  session->name, ps->flags);
 		err = 0;
 		break;
 
@@ -1160,8 +1155,8 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		if (copy_to_user((void __user *) arg, &stats,
 				 sizeof(stats)))
 			break;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get L2TP stats\n", session->name);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: get L2TP stats\n",
+			  session->name);
 		err = 0;
 		break;
 
@@ -1188,9 +1183,9 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 	struct sock *sk;
 	struct pppol2tp_ioc_stats stats;
 
-	PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_DEBUG,
-	       "%s: pppol2tp_tunnel_ioctl(cmd=%#x, arg=%#lx)\n",
-	       tunnel->name, cmd, arg);
+	l2tp_dbg(tunnel, PPPOL2TP_MSG_CONTROL,
+		 "%s: pppol2tp_tunnel_ioctl(cmd=%#x, arg=%#lx)\n",
+		 tunnel->name, cmd, arg);
 
 	sk = tunnel->sock;
 	sock_hold(sk);
@@ -1224,8 +1219,8 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 			err = -EFAULT;
 			break;
 		}
-		PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get L2TP stats\n", tunnel->name);
+		l2tp_info(tunnel, PPPOL2TP_MSG_CONTROL, "%s: get L2TP stats\n",
+			  tunnel->name);
 		err = 0;
 		break;
 
@@ -1314,8 +1309,8 @@ static int pppol2tp_tunnel_setsockopt(struct sock *sk,
 	switch (optname) {
 	case PPPOL2TP_SO_DEBUG:
 		tunnel->debug = val;
-		PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set debug=%x\n", tunnel->name, tunnel->debug);
+		l2tp_info(tunnel, PPPOL2TP_MSG_CONTROL, "%s: set debug=%x\n",
+			  tunnel->name, tunnel->debug);
 		break;
 
 	default:
@@ -1342,8 +1337,9 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			break;
 		}
 		session->recv_seq = val ? -1 : 0;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set recv_seq=%d\n", session->name, session->recv_seq);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: set recv_seq=%d\n",
+			  session->name, session->recv_seq);
 		break;
 
 	case PPPOL2TP_SO_SENDSEQ:
@@ -1358,8 +1354,9 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			po->chan.hdrlen = val ? PPPOL2TP_L2TP_HDR_SIZE_SEQ :
 				PPPOL2TP_L2TP_HDR_SIZE_NOSEQ;
 		}
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set send_seq=%d\n", session->name, session->send_seq);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: set send_seq=%d\n",
+			  session->name, session->send_seq);
 		break;
 
 	case PPPOL2TP_SO_LNSMODE:
@@ -1368,20 +1365,22 @@ static int pppol2tp_session_setsockopt(struct sock *sk,
 			break;
 		}
 		session->lns_mode = val ? -1 : 0;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set lns_mode=%d\n", session->name, session->lns_mode);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: set lns_mode=%d\n",
+			  session->name, session->lns_mode);
 		break;
 
 	case PPPOL2TP_SO_DEBUG:
 		session->debug = val;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set debug=%x\n", session->name, session->debug);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: set debug=%x\n",
+			  session->name, session->debug);
 		break;
 
 	case PPPOL2TP_SO_REORDERTO:
 		session->reorder_timeout = msecs_to_jiffies(val);
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: set reorder_timeout=%d\n", session->name, session->reorder_timeout);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: set reorder_timeout=%d\n",
+			  session->name, session->reorder_timeout);
 		break;
 
 	default:
@@ -1460,8 +1459,8 @@ static int pppol2tp_tunnel_getsockopt(struct sock *sk,
 	switch (optname) {
 	case PPPOL2TP_SO_DEBUG:
 		*val = tunnel->debug;
-		PRINTK(tunnel->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get debug=%x\n", tunnel->name, tunnel->debug);
+		l2tp_info(tunnel, PPPOL2TP_MSG_CONTROL, "%s: get debug=%x\n",
+			  tunnel->name, tunnel->debug);
 		break;
 
 	default:
@@ -1483,32 +1482,32 @@ static int pppol2tp_session_getsockopt(struct sock *sk,
 	switch (optname) {
 	case PPPOL2TP_SO_RECVSEQ:
 		*val = session->recv_seq;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get recv_seq=%d\n", session->name, *val);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: get recv_seq=%d\n", session->name, *val);
 		break;
 
 	case PPPOL2TP_SO_SENDSEQ:
 		*val = session->send_seq;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get send_seq=%d\n", session->name, *val);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: get send_seq=%d\n", session->name, *val);
 		break;
 
 	case PPPOL2TP_SO_LNSMODE:
 		*val = session->lns_mode;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get lns_mode=%d\n", session->name, *val);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: get lns_mode=%d\n", session->name, *val);
 		break;
 
 	case PPPOL2TP_SO_DEBUG:
 		*val = session->debug;
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get debug=%d\n", session->name, *val);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL, "%s: get debug=%d\n",
+			  session->name, *val);
 		break;
 
 	case PPPOL2TP_SO_REORDERTO:
 		*val = (int) jiffies_to_msecs(session->reorder_timeout);
-		PRINTK(session->debug, PPPOL2TP_MSG_CONTROL, KERN_INFO,
-		       "%s: get reorder_timeout=%d\n", session->name, *val);
+		l2tp_info(session, PPPOL2TP_MSG_CONTROL,
+			  "%s: get reorder_timeout=%d\n", session->name, *val);
 		break;
 
 	default:
@@ -1871,8 +1870,7 @@ static int __init pppol2tp_init(void)
 		goto out_unregister_pppox;
 #endif
 
-	printk(KERN_INFO "PPPoL2TP kernel driver, %s\n",
-	       PPPOL2TP_DRV_VERSION);
+	pr_info("PPPoL2TP kernel driver, %s\n", PPPOL2TP_DRV_VERSION);
 
 out:
 	return err;
