From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 01/10 net-next] l2tp: fix locking of 64-bit counters for smp
Date: Mon, 30 Apr 2012 08:48:46 +0100
Message-ID: <1335772135-27910-2-git-send-email-jchapman@katalix.com>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53472 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab2D3Hs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:48:58 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 6BBEFA620CB
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 08:48:56 +0100 (BST)
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP uses 64-bit counters but since these are not updated atomically,
we need to make them safe for smp. This patch addresses that.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c    |   75 +++++++++++++++++++++++++++++++++++------------
 net/l2tp/l2tp_core.h    |    1 +
 net/l2tp/l2tp_netlink.c |   62 ++++++++++++++++++++++++++++----------
 3 files changed, 103 insertions(+), 35 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 8cd5f4b..5e27c05 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -329,8 +329,10 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 	struct sk_buff *skbp;
 	struct sk_buff *tmp;
 	u32 ns = L2TP_SKB_CB(skb)->ns;
+	struct l2tp_stats *sstats;
 
 	spin_lock_bh(&session->reorder_q.lock);
+	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (L2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_queue_before(&session->reorder_q, skbp, skb);
@@ -338,7 +340,9 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 			       "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 			       session->name, ns, L2TP_SKB_CB(skbp)->ns,
 			       skb_queue_len(&session->reorder_q));
-			session->stats.rx_oos_packets++;
+			u64_stats_update_begin(&sstats->syncp);
+			sstats->rx_oos_packets++;
+			u64_stats_update_end(&sstats->syncp);
 			goto out;
 		}
 	}
@@ -355,16 +359,23 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 {
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int length = L2TP_SKB_CB(skb)->length;
+	struct l2tp_stats *tstats, *sstats;
 
 	/* We're about to requeue the skb, so return resources
 	 * to its current owner (a socket receive buffer).
 	 */
 	skb_orphan(skb);
 
-	tunnel->stats.rx_packets++;
-	tunnel->stats.rx_bytes += length;
-	session->stats.rx_packets++;
-	session->stats.rx_bytes += length;
+	tstats = &tunnel->stats;
+	u64_stats_update_begin(&tstats->syncp);
+	sstats = &session->stats;
+	u64_stats_update_begin(&sstats->syncp);
+	tstats->rx_packets++;
+	tstats->rx_bytes += length;
+	sstats->rx_packets++;
+	sstats->rx_bytes += length;
+	u64_stats_update_end(&tstats->syncp);
+	u64_stats_update_end(&sstats->syncp);
 
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Bump our Nr */
@@ -395,6 +406,7 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 {
 	struct sk_buff *skb;
 	struct sk_buff *tmp;
+	struct l2tp_stats *sstats;
 
 	/* If the pkt at the head of the queue has the nr that we
 	 * expect to send up next, dequeue it and any other
@@ -402,10 +414,13 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
 	 */
 start:
 	spin_lock_bh(&session->reorder_q.lock);
+	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, L2TP_SKB_CB(skb)->expires)) {
-			session->stats.rx_seq_discards++;
-			session->stats.rx_errors++;
+			u64_stats_update_begin(&sstats->syncp);
+			sstats->rx_seq_discards++;
+			sstats->rx_errors++;
+			u64_stats_update_end(&sstats->syncp);
 			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
 			       "%s: oos pkt %u len %d discarded (too old), "
 			       "waiting for %u, reorder_q_len=%d\n",
@@ -557,6 +572,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int offset;
 	u32 ns, nr;
+	struct l2tp_stats *sstats = &session->stats;
 
 	/* The ref count is increased since we now hold a pointer to
 	 * the session. Take care to decrement the refcnt when exiting
@@ -572,7 +588,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			PRINTK(tunnel->debug, L2TP_MSG_DATA, KERN_INFO,
 			       "%s: cookie mismatch (%u/%u). Discarding.\n",
 			       tunnel->name, tunnel->tunnel_id, session->session_id);
-			session->stats.rx_cookie_discards++;
+			u64_stats_update_begin(&sstats->syncp);
+			sstats->rx_cookie_discards++;
+			u64_stats_update_end(&sstats->syncp);
 			goto discard;
 		}
 		ptr += session->peer_cookie_len;
@@ -641,7 +659,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_WARNING,
 			       "%s: recv data has no seq numbers when required. "
 			       "Discarding\n", session->name);
-			session->stats.rx_seq_discards++;
+			u64_stats_update_begin(&sstats->syncp);
+			sstats->rx_seq_discards++;
+			u64_stats_update_end(&sstats->syncp);
 			goto discard;
 		}
 
@@ -660,7 +680,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			PRINTK(session->debug, L2TP_MSG_SEQ, KERN_WARNING,
 			       "%s: recv data has no seq numbers when required. "
 			       "Discarding\n", session->name);
-			session->stats.rx_seq_discards++;
+			u64_stats_update_begin(&sstats->syncp);
+			sstats->rx_seq_discards++;
+			u64_stats_update_end(&sstats->syncp);
 			goto discard;
 		}
 	}
@@ -714,7 +736,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			 * packets
 			 */
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
-				session->stats.rx_seq_discards++;
+				u64_stats_update_begin(&sstats->syncp);
+				sstats->rx_seq_discards++;
+				u64_stats_update_end(&sstats->syncp);
 				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
 				       "%s: oos pkt %u len %d discarded, "
 				       "waiting for %u, reorder_q_len=%d\n",
@@ -741,7 +765,9 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	return;
 
 discard:
-	session->stats.rx_errors++;
+	u64_stats_update_begin(&sstats->syncp);
+	sstats->rx_errors++;
+	u64_stats_update_end(&sstats->syncp);
 	kfree_skb(skb);
 
 	if (session->deref)
@@ -767,6 +793,7 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	int offset;
 	u16 version;
 	int length;
+	struct l2tp_stats *tstats;
 
 	if (tunnel->sock && l2tp_verify_udp_checksum(tunnel->sock, skb))
 		goto discard_bad_csum;
@@ -859,7 +886,10 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 discard_bad_csum:
 	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
 	UDP_INC_STATS_USER(tunnel->l2tp_net, UDP_MIB_INERRORS, 0);
-	tunnel->stats.rx_errors++;
+	tstats = &tunnel->stats;
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->rx_errors++;
+	u64_stats_update_end(&tstats->syncp);
 	kfree_skb(skb);
 
 	return 0;
@@ -985,6 +1015,7 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	unsigned int len = skb->len;
 	int error;
+	struct l2tp_stats *tstats, *sstats;
 
 	/* Debug */
 	if (session->send_seq)
@@ -1021,15 +1052,21 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 		error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
+	tstats = &tunnel->stats;
+	u64_stats_update_begin(&tstats->syncp);
+	sstats = &session->stats;
+	u64_stats_update_begin(&sstats->syncp);
 	if (error >= 0) {
-		tunnel->stats.tx_packets++;
-		tunnel->stats.tx_bytes += len;
-		session->stats.tx_packets++;
-		session->stats.tx_bytes += len;
+		tstats->tx_packets++;
+		tstats->tx_bytes += len;
+		sstats->tx_packets++;
+		sstats->tx_bytes += len;
 	} else {
-		tunnel->stats.tx_errors++;
-		session->stats.tx_errors++;
+		tstats->tx_errors++;
+		sstats->tx_errors++;
 	}
+	u64_stats_update_end(&tstats->syncp);
+	u64_stats_update_end(&sstats->syncp);
 
 	return 0;
 }
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 09e4a38..a8c943b 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -45,6 +45,7 @@ struct l2tp_stats {
 	u64			rx_oos_packets;
 	u64			rx_errors;
 	u64			rx_cookie_discards;
+	struct u64_stats_sync	syncp;
 };
 
 struct l2tp_tunnel;
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index bc8c334..1dbb977 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -225,6 +225,8 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	struct nlattr *nest;
 	struct sock *sk = NULL;
 	struct inet_sock *inet;
+	struct l2tp_stats stats;
+	unsigned int start;
 
 	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
 			  L2TP_CMD_TUNNEL_GET);
@@ -242,16 +244,28 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	if (nest == NULL)
 		goto nla_put_failure;
 
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, tunnel->stats.tx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, tunnel->stats.tx_bytes) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, tunnel->stats.tx_errors) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, tunnel->stats.rx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, tunnel->stats.rx_bytes) ||
+	do {
+		start = u64_stats_fetch_begin(&tunnel->stats.syncp);
+		stats.tx_packets = tunnel->stats.tx_packets;
+		stats.tx_bytes = tunnel->stats.tx_bytes;
+		stats.tx_errors = tunnel->stats.tx_errors;
+		stats.rx_packets = tunnel->stats.rx_packets;
+		stats.rx_bytes = tunnel->stats.rx_bytes;
+		stats.rx_errors = tunnel->stats.rx_errors;
+		stats.rx_seq_discards = tunnel->stats.rx_seq_discards;
+		stats.rx_oos_packets = tunnel->stats.rx_oos_packets;
+	} while (u64_stats_fetch_retry(&tunnel->stats.syncp, start));
+
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx_errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx_bytes) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			tunnel->stats.rx_seq_discards) ||
+			stats.rx_seq_discards) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			tunnel->stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, tunnel->stats.rx_errors))
+			stats.rx_oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
@@ -563,6 +577,8 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 	struct nlattr *nest;
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct sock *sk = NULL;
+	struct l2tp_stats stats;
+	unsigned int start;
 
 	sk = tunnel->sock;
 
@@ -600,19 +616,33 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 	    (session->reorder_timeout &&
 	     nla_put_msecs(skb, L2TP_ATTR_RECV_TIMEOUT, session->reorder_timeout)))
 		goto nla_put_failure;
+
 	nest = nla_nest_start(skb, L2TP_ATTR_STATS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, session->stats.tx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, session->stats.tx_bytes) ||
-	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, session->stats.tx_errors) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, session->stats.rx_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, session->stats.rx_bytes) ||
+
+	do {
+		start = u64_stats_fetch_begin(&session->stats.syncp);
+		stats.tx_packets = session->stats.tx_packets;
+		stats.tx_bytes = session->stats.tx_bytes;
+		stats.tx_errors = session->stats.tx_errors;
+		stats.rx_packets = session->stats.rx_packets;
+		stats.rx_bytes = session->stats.rx_bytes;
+		stats.rx_errors = session->stats.rx_errors;
+		stats.rx_seq_discards = session->stats.rx_seq_discards;
+		stats.rx_oos_packets = session->stats.rx_oos_packets;
+	} while (u64_stats_fetch_retry(&session->stats.syncp, start));
+
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx_bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx_errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx_bytes) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			session->stats.rx_seq_discards) ||
+			stats.rx_seq_discards) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			session->stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, session->stats.rx_errors))
+			stats.rx_oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
-- 
1.7.0.4
