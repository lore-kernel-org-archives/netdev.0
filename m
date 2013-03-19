From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 11/12] l2tp: avoid deadlock in l2tp stats update
Date: Tue, 19 Mar 2013 16:11:22 +0000
Message-ID: <1363709483-24021-12-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36145 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932842Ab3CSQLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:33 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp's u64_stats writers were incorrectly synchronised, making it possible to
deadlock a 64bit machine running a 32bit kernel simply by sending the l2tp
code netlink commands while passing data through l2tp sessions.

Previous discussion on netdev determined that alternative solutions such as
spinlock writer synchronisation or per-cpu data would bring unjustified
overhead, given that most users interested in high volume traffic will likely
be running 64bit kernels on 64bit hardware.

As such, this patch replaces l2tp's use of u64_stats with atomic_long_t,
thereby avoiding the deadlock.

Ref:
http://marc.info/?l=linux-netdev&m=134029167910731&w=2
http://marc.info/?l=linux-netdev&m=134079868111131&w=2

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c    |   75 ++++++++++++-----------------------------------
 net/l2tp/l2tp_core.h    |   19 ++++++------
 net/l2tp/l2tp_debugfs.c |   28 +++++++++---------
 net/l2tp/l2tp_netlink.c |   72 ++++++++++++++++++---------------------------
 net/l2tp/l2tp_ppp.c     |   46 ++++++++++++++---------------
 5 files changed, 93 insertions(+), 147 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index c00f31b..97d30ac 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -374,10 +374,8 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 	struct sk_buff *skbp;
 	struct sk_buff *tmp;
 	u32 ns = L2TP_SKB_CB(skb)->ns;
-	struct l2tp_stats *sstats;
 
 	spin_lock_bh(&session->reorder_q.lock);
-	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (L2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_queue_before(&session->reorder_q, skbp, skb);
@@ -385,9 +383,7 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 				 "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 				 session->name, ns, L2TP_SKB_CB(skbp)->ns,
 				 skb_queue_len(&session->reorder_q));
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_oos_packets++;
-			u64_stats_update_end(&sstats->syncp);
+			atomic_long_inc(&session->stats.rx_oos_packets);
 			goto out;
 		}
 	}
@@ -404,23 +400,16 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int length = L2TP_SKB_CB(skb)->length;
-	struct l2tp_stats *tstats, *sstats;
 
 	/* We're about to requeue the skb, so return resources
 	 * to its current owner (a socket receive buffer).
 	 */
 	skb_orphan(skb);
 
-	tstats = &tunnel->stats;
-	u64_stats_update_begin(&tstats->syncp);
-	sstats = &session->stats;
-	u64_stats_update_begin(&sstats->syncp);
-	tstats->rx_packets++;
-	tstats->rx_bytes += length;
-	sstats->rx_packets++;
-	sstats->rx_bytes += length;
-	u64_stats_update_end(&tstats->syncp);
-	u64_stats_update_end(&sstats->syncp);
+	atomic_long_inc(&tunnel->stats.rx_packets);
+	atomic_long_add(length, &tunnel->stats.rx_bytes);
+	atomic_long_inc(&session->stats.rx_packets);
+	atomic_long_add(length, &session->stats.rx_bytes);
 
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Bump our Nr */
@@ -451,7 +440,6 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 {
 	struct sk_buff *skb;
 	struct sk_buff *tmp;
-	struct l2tp_stats *sstats;
 
 	/* If the pkt at the head of the queue has the nr that we
 	 * expect to send up next, dequeue it and any other
@@ -459,13 +447,10 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 	 */
 start:
 	spin_lock_bh(&session->reorder_q.lock);
-	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, L2TP_SKB_CB(skb)->expires)) {
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_seq_discards++;
-			sstats->rx_errors++;
-			u64_stats_update_end(&sstats->syncp);
+			atomic_long_inc(&session->stats.rx_seq_discards);
+			atomic_long_inc(&session->stats.rx_errors);
 			l2tp_dbg(session, L2TP_MSG_SEQ,
 				 "%s: oos pkt %u len %d discarded (too old), waiting for %u, reorder_q_len=%d\n",
 				 session->name, L2TP_SKB_CB(skb)->ns,
@@ -624,7 +609,6 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int offset;
 	u32 ns, nr;
-	struct l2tp_stats *sstats = &session->stats;
 
 	/* The ref count is increased since we now hold a pointer to
 	 * the session. Take care to decrement the refcnt when exiting
@@ -641,9 +625,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 				  "%s: cookie mismatch (%u/%u). Discarding.\n",
 				  tunnel->name, tunnel->tunnel_id,
 				  session->session_id);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_cookie_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			atomic_long_inc(&session->stats.rx_cookie_discards);
 			goto discard;
 		}
 		ptr += session->peer_cookie_len;
@@ -712,9 +694,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_seq_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			atomic_long_inc(&session->stats.rx_seq_discards);
 			goto discard;
 		}
 
@@ -733,9 +713,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_seq_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			atomic_long_inc(&session->stats.rx_seq_discards);
 			goto discard;
 		}
 	}
@@ -789,9 +767,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			 * packets
 			 */
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
-				u64_stats_update_begin(&sstats->syncp);
-				sstats->rx_seq_discards++;
-				u64_stats_update_end(&sstats->syncp);
+				atomic_long_inc(&session->stats.rx_seq_discards);
 				l2tp_dbg(session, L2TP_MSG_SEQ,
 					 "%s: oos pkt %u len %d discarded, waiting for %u, reorder_q_len=%d\n",
 					 session->name, L2TP_SKB_CB(skb)->ns,
@@ -817,9 +793,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	return;
 
 discard:
-	u64_stats_update_begin(&sstats->syncp);
-	sstats->rx_errors++;
-	u64_stats_update_end(&sstats->syncp);
+	atomic_long_inc(&session->stats.rx_errors);
 	kfree_skb(skb);
 
 	if (session->deref)
@@ -861,7 +835,6 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	u32 tunnel_id, session_id;
 	u16 version;
 	int length;
-	struct l2tp_stats *tstats;
 
 	if (tunnel->sock && l2tp_verify_udp_checksum(tunnel->sock, skb))
 		goto discard_bad_csum;
@@ -950,10 +923,7 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 discard_bad_csum:
 	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
 	UDP_INC_STATS_USER(tunnel->l2tp_net, UDP_MIB_INERRORS, 0);
-	tstats = &tunnel->stats;
-	u64_stats_update_begin(&tstats->syncp);
-	tstats->rx_errors++;
-	u64_stats_update_end(&tstats->syncp);
+	atomic_long_inc(&tunnel->stats.rx_errors);
 	kfree_skb(skb);
 
 	return 0;
@@ -1080,7 +1050,6 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	unsigned int len = skb->len;
 	int error;
-	struct l2tp_stats *tstats, *sstats;
 
 	/* Debug */
 	if (session->send_seq)
@@ -1109,21 +1078,15 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 		error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
-	tstats = &tunnel->stats;
-	u64_stats_update_begin(&tstats->syncp);
-	sstats = &session->stats;
-	u64_stats_update_begin(&sstats->syncp);
 	if (error >= 0) {
-		tstats->tx_packets++;
-		tstats->tx_bytes += len;
-		sstats->tx_packets++;
-		sstats->tx_bytes += len;
+		atomic_long_inc(&tunnel->stats.tx_packets);
+		atomic_long_add(len, &tunnel->stats.tx_bytes);
+		atomic_long_inc(&session->stats.tx_packets);
+		atomic_long_add(len, &session->stats.tx_bytes);
 	} else {
-		tstats->tx_errors++;
-		sstats->tx_errors++;
+		atomic_long_inc(&tunnel->stats.tx_errors);
+		atomic_long_inc(&session->stats.tx_errors);
 	}
-	u64_stats_update_end(&tstats->syncp);
-	u64_stats_update_end(&sstats->syncp);
 
 	return 0;
 }
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index d40713d..519b013 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -36,16 +36,15 @@ enum {
 struct sk_buff;
 
 struct l2tp_stats {
-	u64			tx_packets;
-	u64			tx_bytes;
-	u64			tx_errors;
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			rx_seq_discards;
-	u64			rx_oos_packets;
-	u64			rx_errors;
-	u64			rx_cookie_discards;
-	struct u64_stats_sync	syncp;
+	atomic_long_t		tx_packets;
+	atomic_long_t		tx_bytes;
+	atomic_long_t		tx_errors;
+	atomic_long_t		rx_packets;
+	atomic_long_t		rx_bytes;
+	atomic_long_t		rx_seq_discards;
+	atomic_long_t		rx_oos_packets;
+	atomic_long_t		rx_errors;
+	atomic_long_t		rx_cookie_discards;
 };
 
 struct l2tp_tunnel;
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index c3813bc..072d720 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -146,14 +146,14 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 		   tunnel->sock ? atomic_read(&tunnel->sock->sk_refcnt) : 0,
 		   atomic_read(&tunnel->ref_count));
 
-	seq_printf(m, " %08x rx %llu/%llu/%llu rx %llu/%llu/%llu\n",
+	seq_printf(m, " %08x rx %ld/%ld/%ld rx %ld/%ld/%ld\n",
 		   tunnel->debug,
-		   (unsigned long long)tunnel->stats.tx_packets,
-		   (unsigned long long)tunnel->stats.tx_bytes,
-		   (unsigned long long)tunnel->stats.tx_errors,
-		   (unsigned long long)tunnel->stats.rx_packets,
-		   (unsigned long long)tunnel->stats.rx_bytes,
-		   (unsigned long long)tunnel->stats.rx_errors);
+		   atomic_long_read(&tunnel->stats.tx_packets),
+		   atomic_long_read(&tunnel->stats.tx_bytes),
+		   atomic_long_read(&tunnel->stats.tx_errors),
+		   atomic_long_read(&tunnel->stats.rx_packets),
+		   atomic_long_read(&tunnel->stats.rx_bytes),
+		   atomic_long_read(&tunnel->stats.rx_errors));
 
 	if (tunnel->show != NULL)
 		tunnel->show(m, tunnel);
@@ -203,14 +203,14 @@ static void l2tp_dfs_seq_session_show(struct seq_file *m, void *v)
 		seq_printf(m, "\n");
 	}
 
-	seq_printf(m, "   %hu/%hu tx %llu/%llu/%llu rx %llu/%llu/%llu\n",
+	seq_printf(m, "   %hu/%hu tx %ld/%ld/%ld rx %ld/%ld/%ld\n",
 		   session->nr, session->ns,
-		   (unsigned long long)session->stats.tx_packets,
-		   (unsigned long long)session->stats.tx_bytes,
-		   (unsigned long long)session->stats.tx_errors,
-		   (unsigned long long)session->stats.rx_packets,
-		   (unsigned long long)session->stats.rx_bytes,
-		   (unsigned long long)session->stats.rx_errors);
+		   atomic_long_read(&session->stats.tx_packets),
+		   atomic_long_read(&session->stats.tx_bytes),
+		   atomic_long_read(&session->stats.tx_errors),
+		   atomic_long_read(&session->stats.rx_packets),
+		   atomic_long_read(&session->stats.rx_bytes),
+		   atomic_long_read(&session->stats.rx_errors));
 
 	if (session->show != NULL)
 		session->show(m, session);
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index c1bab22..0825ff2 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -246,8 +246,6 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 #if IS_ENABLED(CONFIG_IPV6)
 	struct ipv6_pinfo *np = NULL;
 #endif
-	struct l2tp_stats stats;
-	unsigned int start;
 
 	hdr = genlmsg_put(skb, portid, seq, &l2tp_nl_family, flags,
 			  L2TP_CMD_TUNNEL_GET);
@@ -265,28 +263,22 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	do {
-		start = u64_stats_fetch_begin(&tunnel->stats.syncp);
-		stats.tx_packets = tunnel->stats.tx_packets;
-		stats.tx_bytes = tunnel->stats.tx_bytes;
-		stats.tx_errors = tunnel->stats.tx_errors;
-		stats.rx_packets = tunnel->stats.rx_packets;
-		stats.rx_bytes = tunnel->stats.rx_bytes;
-		stats.rx_errors = tunnel->stats.rx_errors;
-		stats.rx_seq_discards = tunnel->stats.rx_seq_discards;
-		stats.rx_oos_packets = tunnel->stats.rx_oos_packets;
-	} while (u64_stats_fetch_retry(&tunnel->stats.syncp, start));
-
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx_bytes) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx_errors) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx_bytes) ||
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS,
+		    atomic_long_read(&tunnel->stats.tx_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES,
+		    atomic_long_read(&tunnel->stats.tx_bytes)) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS,
+		    atomic_long_read(&tunnel->stats.tx_errors)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS,
+		    atomic_long_read(&tunnel->stats.rx_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES,
+		    atomic_long_read(&tunnel->stats.rx_bytes)) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			stats.rx_seq_discards) ||
+		    atomic_long_read(&tunnel->stats.rx_seq_discards)) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
+		    atomic_long_read(&tunnel->stats.rx_oos_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS,
+		    atomic_long_read(&tunnel->stats.rx_errors)))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
@@ -612,8 +604,6 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int fl
 	struct nlattr *nest;
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct sock *sk = NULL;
-	struct l2tp_stats stats;
-	unsigned int start;
 
 	sk = tunnel->sock;
 
@@ -656,28 +646,22 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 portid, u32 seq, int fl
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	do {
-		start = u64_stats_fetch_begin(&session->stats.syncp);
-		stats.tx_packets = session->stats.tx_packets;
-		stats.tx_bytes = session->stats.tx_bytes;
-		stats.tx_errors = session->stats.tx_errors;
-		stats.rx_packets = session->stats.rx_packets;
-		stats.rx_bytes = session->stats.rx_bytes;
-		stats.rx_errors = session->stats.rx_errors;
-		stats.rx_seq_discards = session->stats.rx_seq_discards;
-		stats.rx_oos_packets = session->stats.rx_oos_packets;
-	} while (u64_stats_fetch_retry(&session->stats.syncp, start));
-
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx_bytes) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx_errors) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx_bytes) ||
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS,
+		atomic_long_read(&session->stats.tx_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES,
+		atomic_long_read(&session->stats.tx_bytes)) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS,
+		atomic_long_read(&session->stats.tx_errors)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS,
+		atomic_long_read(&session->stats.rx_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES,
+		atomic_long_read(&session->stats.rx_bytes)) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			stats.rx_seq_discards) ||
+		atomic_long_read(&session->stats.rx_seq_discards)) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
+		atomic_long_read(&session->stats.rx_oos_packets)) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS,
+		atomic_long_read(&session->stats.rx_errors)))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 7e3e16a..9d0eb8c 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -260,7 +260,7 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 			  session->name);
 
 		/* Not bound. Nothing we can do, so discard. */
-		session->stats.rx_errors++;
+		atomic_long_inc(&session->stats.rx_errors);
 		kfree_skb(skb);
 	}
 
@@ -992,14 +992,14 @@ end:
 static void pppol2tp_copy_stats(struct pppol2tp_ioc_stats *dest,
 				struct l2tp_stats *stats)
 {
-	dest->tx_packets = stats->tx_packets;
-	dest->tx_bytes = stats->tx_bytes;
-	dest->tx_errors = stats->tx_errors;
-	dest->rx_packets = stats->rx_packets;
-	dest->rx_bytes = stats->rx_bytes;
-	dest->rx_seq_discards = stats->rx_seq_discards;
-	dest->rx_oos_packets = stats->rx_oos_packets;
-	dest->rx_errors = stats->rx_errors;
+	dest->tx_packets = atomic_long_read(&stats->tx_packets);
+	dest->tx_bytes = atomic_long_read(&stats->tx_bytes);
+	dest->tx_errors = atomic_long_read(&stats->tx_errors);
+	dest->rx_packets = atomic_long_read(&stats->rx_packets);
+	dest->rx_bytes = atomic_long_read(&stats->rx_bytes);
+	dest->rx_seq_discards = atomic_long_read(&stats->rx_seq_discards);
+	dest->rx_oos_packets = atomic_long_read(&stats->rx_oos_packets);
+	dest->rx_errors = atomic_long_read(&stats->rx_errors);
 }
 
 /* Session ioctl helper.
@@ -1633,14 +1633,14 @@ static void pppol2tp_seq_tunnel_show(struct seq_file *m, void *v)
 		   tunnel->name,
 		   (tunnel == tunnel->sock->sk_user_data) ? 'Y' : 'N',
 		   atomic_read(&tunnel->ref_count) - 1);
-	seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
+	seq_printf(m, " %08x %ld/%ld/%ld %ld/%ld/%ld\n",
 		   tunnel->debug,
-		   (unsigned long long)tunnel->stats.tx_packets,
-		   (unsigned long long)tunnel->stats.tx_bytes,
-		   (unsigned long long)tunnel->stats.tx_errors,
-		   (unsigned long long)tunnel->stats.rx_packets,
-		   (unsigned long long)tunnel->stats.rx_bytes,
-		   (unsigned long long)tunnel->stats.rx_errors);
+		   atomic_long_read(&tunnel->stats.tx_packets),
+		   atomic_long_read(&tunnel->stats.tx_bytes),
+		   atomic_long_read(&tunnel->stats.tx_errors),
+		   atomic_long_read(&tunnel->stats.rx_packets),
+		   atomic_long_read(&tunnel->stats.rx_bytes),
+		   atomic_long_read(&tunnel->stats.rx_errors));
 }
 
 static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
@@ -1675,14 +1675,14 @@ static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
 		   session->lns_mode ? "LNS" : "LAC",
 		   session->debug,
 		   jiffies_to_msecs(session->reorder_timeout));
-	seq_printf(m, "   %hu/%hu %llu/%llu/%llu %llu/%llu/%llu\n",
+	seq_printf(m, "   %hu/%hu %ld/%ld/%ld %ld/%ld/%ld\n",
 		   session->nr, session->ns,
-		   (unsigned long long)session->stats.tx_packets,
-		   (unsigned long long)session->stats.tx_bytes,
-		   (unsigned long long)session->stats.tx_errors,
-		   (unsigned long long)session->stats.rx_packets,
-		   (unsigned long long)session->stats.rx_bytes,
-		   (unsigned long long)session->stats.rx_errors);
+		   atomic_long_read(&session->stats.tx_packets),
+		   atomic_long_read(&session->stats.tx_bytes),
+		   atomic_long_read(&session->stats.tx_errors),
+		   atomic_long_read(&session->stats.rx_packets),
+		   atomic_long_read(&session->stats.rx_bytes),
+		   atomic_long_read(&session->stats.rx_errors));
 
 	if (po)
 		seq_printf(m, "   interface %s\n", ppp_dev_name(&po->chan));
-- 
1.7.9.5
