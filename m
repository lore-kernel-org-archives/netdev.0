From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH] l2tp: synchronise u64 stats writer callsites
Date: Thu, 21 Jun 2012 16:04:14 +0100
Message-ID: <1340291054-16077-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48119 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759268Ab2FUPLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 11:11:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix statistics update race in l2tp_core.  As described in
include/linux/u64_stats_sync.h, it is necessary for the writers of
u64 statistics to ensure mutual exclusion to the seqcount for
statistics synchronisation.  Failure to do so may result in a
missed seqcount update, leaving readers blocking forever.

This race was discovered on an AMD64 SMP machine running a 32bit
kernel.  Running "ip l2tp" while sending data over an Ethernet
pseudowire resulted in an occasional soft lockup in
u64_stats_fetch_begin() called from l2tp_nl_session_send().

Statistics writers are now serialized via. a spinlock in the stats
structure, preventing the seqcount update race.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   34 +++++++++++++++++++++++++++++++---
 net/l2tp/l2tp_core.h |    5 +++++
 2 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 32b2155..e9e7cb0 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -343,9 +343,11 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 				 "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 				 session->name, ns, L2TP_SKB_CB(skbp)->ns,
 				 skb_queue_len(&session->reorder_q));
+			spin_lock_bh(&sstats->writelock);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_oos_packets++;
 			u64_stats_update_end(&sstats->syncp);
+			spin_unlock_bh(&sstats->writelock);
 			goto out;
 		}
 	}
@@ -370,15 +372,20 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
 	skb_orphan(skb);
 
 	tstats = &tunnel->stats;
+	spin_lock_bh(&tstats->writelock);
 	u64_stats_update_begin(&tstats->syncp);
-	sstats = &session->stats;
-	u64_stats_update_begin(&sstats->syncp);
 	tstats->rx_packets++;
 	tstats->rx_bytes += length;
+	u64_stats_update_end(&tstats->syncp);
+	spin_unlock_bh(&tstats->writelock);
+
+	sstats = &session->stats;
+	spin_lock_bh(&sstats->writelock);
+	u64_stats_update_begin(&sstats->syncp);
 	sstats->rx_packets++;
 	sstats->rx_bytes += length;
-	u64_stats_update_end(&tstats->syncp);
 	u64_stats_update_end(&sstats->syncp);
+	spin_unlock_bh(&sstats->writelock);
 
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Bump our Nr */
@@ -420,10 +427,12 @@ start:
 	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, L2TP_SKB_CB(skb)->expires)) {
+			spin_lock_bh(&sstats->writelock);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_seq_discards++;
 			sstats->rx_errors++;
 			u64_stats_update_end(&sstats->syncp);
+			spin_unlock_bh(&sstats->writelock);
 			l2tp_dbg(session, L2TP_MSG_SEQ,
 				 "%s: oos pkt %u len %d discarded (too old), waiting for %u, reorder_q_len=%d\n",
 				 session->name, L2TP_SKB_CB(skb)->ns,
@@ -599,9 +608,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 				  "%s: cookie mismatch (%u/%u). Discarding.\n",
 				  tunnel->name, tunnel->tunnel_id,
 				  session->session_id);
+			spin_lock_bh(&sstats->writelock);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_cookie_discards++;
 			u64_stats_update_end(&sstats->syncp);
+			spin_unlock_bh(&sstats->writelock);
 			goto discard;
 		}
 		ptr += session->peer_cookie_len;
@@ -670,9 +681,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
+			spin_lock_bh(&sstats->writelock);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_seq_discards++;
 			u64_stats_update_end(&sstats->syncp);
+			spin_unlock_bh(&sstats->writelock);
 			goto discard;
 		}
 
@@ -691,9 +704,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
+			spin_lock_bh(&sstats->writelock);
 			u64_stats_update_begin(&sstats->syncp);
 			sstats->rx_seq_discards++;
 			u64_stats_update_end(&sstats->syncp);
+			spin_unlock_bh(&sstats->writelock);
 			goto discard;
 		}
 	}
@@ -747,9 +762,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			 * packets
 			 */
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
+				spin_lock_bh(&sstats->writelock);
 				u64_stats_update_begin(&sstats->syncp);
 				sstats->rx_seq_discards++;
 				u64_stats_update_end(&sstats->syncp);
+				spin_unlock_bh(&sstats->writelock);
 				l2tp_dbg(session, L2TP_MSG_SEQ,
 					 "%s: oos pkt %u len %d discarded, waiting for %u, reorder_q_len=%d\n",
 					 session->name, L2TP_SKB_CB(skb)->ns,
@@ -775,9 +792,11 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	return;
 
 discard:
+	spin_lock_bh(&sstats->writelock);
 	u64_stats_update_begin(&sstats->syncp);
 	sstats->rx_errors++;
 	u64_stats_update_end(&sstats->syncp);
+	spin_unlock_bh(&sstats->writelock);
 	kfree_skb(skb);
 
 	if (session->deref)
@@ -892,9 +911,11 @@ discard_bad_csum:
 	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
 	UDP_INC_STATS_USER(tunnel->l2tp_net, UDP_MIB_INERRORS, 0);
 	tstats = &tunnel->stats;
+	spin_lock_bh(&tstats->writelock);
 	u64_stats_update_begin(&tstats->syncp);
 	tstats->rx_errors++;
 	u64_stats_update_end(&tstats->syncp);
+	spin_unlock_bh(&tstats->writelock);
 	kfree_skb(skb);
 
 	return 0;
@@ -1051,8 +1072,10 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 
 	/* Update stats */
 	tstats = &tunnel->stats;
+	spin_lock_bh(&tstats->writelock);
 	u64_stats_update_begin(&tstats->syncp);
 	sstats = &session->stats;
+	spin_lock_bh(&sstats->writelock);
 	u64_stats_update_begin(&sstats->syncp);
 	if (error >= 0) {
 		tstats->tx_packets++;
@@ -1064,7 +1087,9 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 		sstats->tx_errors++;
 	}
 	u64_stats_update_end(&tstats->syncp);
+	spin_unlock_bh(&tstats->writelock);
 	u64_stats_update_end(&sstats->syncp);
+	spin_unlock_bh(&sstats->writelock);
 
 	return 0;
 }
@@ -1575,6 +1600,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	tunnel->magic = L2TP_TUNNEL_MAGIC;
 	sprintf(&tunnel->name[0], "tunl %u", tunnel_id);
 	rwlock_init(&tunnel->hlist_lock);
+	spin_lock_init(&tunnel->stats.writelock);
 
 	/* The net we belong to */
 	tunnel->l2tp_net = net;
@@ -1758,6 +1784,8 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		INIT_HLIST_NODE(&session->hlist);
 		INIT_HLIST_NODE(&session->global_hlist);
 
+		spin_lock_init(&session->stats.writelock);
+
 		/* Inherit debug options from tunnel */
 		session->debug = tunnel->debug;
 
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a38ec6c..80c4475 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -35,6 +35,10 @@ enum {
 
 struct sk_buff;
 
+/* Stats are synchronised via a synchronisation point for safe
+ * reader/writer access on 64 and 32 bit kernels.  Multi-threaded
+ * stats writers are serialized through a spinlock.
+ */
 struct l2tp_stats {
 	u64			tx_packets;
 	u64			tx_bytes;
@@ -46,6 +50,7 @@ struct l2tp_stats {
 	u64			rx_errors;
 	u64			rx_cookie_discards;
 	struct u64_stats_sync	syncp;
+	spinlock_t		writelock;
 };
 
 struct l2tp_tunnel;
-- 
1.7.9.5
