From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 13:00:57 +0100
Message-ID: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
Cc: David.Laight@ACULAB.COM, Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:57263 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605Ab2F0MBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 08:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a race condition in l2tp when updating tunnel and
session statistics.  Previously it was possible for multiple threads
to concurrently call u64_stats_update*(), which lead to statistics
readers blocking forever.

This race was discovered on an AMD64 SMP machine running a 32bit
kernel.  Running "ip l2tp" while sending data over an Ethernet
pseudowire resulted in an occasional soft lockup in
u64_stats_fetch_begin() called from l2tp_nl_session_send().

For safe lockless update of l2tp stats, data is now stored in per-cpu
variables.  These per-cpu datasets are then summed at read time via.
an extra helper function l2tp_stats_copy() which has been added to
l2tp_core.c.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c    |  286 ++++++++++++++++++++++++++++-------------------
 net/l2tp/l2tp_core.h    |   44 ++++++--
 net/l2tp/l2tp_debugfs.c |   42 ++++---
 net/l2tp/l2tp_netlink.c |   64 ++++-------
 net/l2tp/l2tp_ppp.c     |   75 ++++++++-----
 5 files changed, 301 insertions(+), 210 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 32b2155..ab2ffc0 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -320,6 +320,43 @@ struct l2tp_tunnel *l2tp_tunnel_find_nth(struct net *net, int nth)
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_find_nth);
 
+/*
+ * Sum tunnel/session statistics across all CPUs
+ */
+int l2tp_stats_copy(struct l2tp_stats *cpustats, struct l2tp_stats *dest)
+{
+	int i;
+	unsigned int start;
+
+	if (!cpustats || !dest)
+		return 1;
+
+	memset(dest, 0, sizeof(struct l2tp_stats));
+
+	for_each_possible_cpu(i) {
+		struct l2tp_stats *stats = per_cpu_ptr(cpustats, i);
+
+		do {
+			start = u64_stats_fetch_begin(&stats->tx.syncp);
+			dest->tx.packets += stats->tx.packets;
+			dest->tx.bytes += stats->tx.bytes;
+			dest->tx.errors += stats->tx.errors;
+		} while (u64_stats_fetch_retry(&stats->tx.syncp, start));
+
+		do {
+			start = u64_stats_fetch_begin(&stats->rx.syncp);
+			dest->rx.packets += stats->rx.packets;
+			dest->rx.bytes += stats->rx.bytes;
+			dest->rx.errors += stats->rx.errors;
+			dest->rx.seq_discards += stats->rx.seq_discards;
+			dest->rx.oos_packets += stats->rx.oos_packets;
+		} while (u64_stats_fetch_retry(&stats->rx.syncp, start));
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(l2tp_stats_copy);
+
 /*****************************************************************************
  * Receive data handling
  *****************************************************************************/
@@ -335,7 +372,6 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 	struct l2tp_stats *sstats;
 
 	spin_lock_bh(&session->reorder_q.lock);
-	sstats = &session->stats;
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (L2TP_SKB_CB(skbp)->ns > ns) {
 			__skb_queue_before(&session->reorder_q, skbp, skb);
@@ -343,9 +379,10 @@ static void l2tp_recv_queue_skb(struct l2tp_session *session, struct sk_buff *sk
 				 "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 				 session->name, ns, L2TP_SKB_CB(skbp)->ns,
 				 skb_queue_len(&session->reorder_q));
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_oos_packets++;
-			u64_stats_update_end(&sstats->syncp);
+			sstats = this_cpu_ptr(session->cpustats);
+			u64_stats_update_begin(&sstats->rx.syncp);
+			sstats->rx.oos_packets++;
+			u64_stats_update_end(&sstats->rx.syncp);
 			goto out;
 		}
 	}
@@ -369,16 +406,17 @@ static void l2tp_recv_dequeue_skb(struct l2tp_session *session, struct sk_buff *
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
+	tstats = this_cpu_ptr(tunnel->cpustats);
+	u64_stats_update_begin(&tstats->rx.syncp);
+	tstats->rx.packets++;
+	tstats->rx.bytes += length;
+	u64_stats_update_end(&tstats->rx.syncp);
+
+	sstats = this_cpu_ptr(session->cpustats);
+	u64_stats_update_begin(&sstats->rx.syncp);
+	sstats->rx.packets++;
+	sstats->rx.bytes += length;
+	u64_stats_update_end(&sstats->rx.syncp);
 
 	if (L2TP_SKB_CB(skb)->has_seq) {
 		/* Bump our Nr */
@@ -417,13 +455,13 @@ static void l2tp_recv_dequeue(struct l2tp_session *session)
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
+			sstats = this_cpu_ptr(session->cpustats);
+			u64_stats_update_begin(&sstats->rx.syncp);
+			sstats->rx.seq_discards++;
+			sstats->rx.errors++;
+			u64_stats_update_end(&sstats->rx.syncp);
 			l2tp_dbg(session, L2TP_MSG_SEQ,
 				 "%s: oos pkt %u len %d discarded (too old), waiting for %u, reorder_q_len=%d\n",
 				 session->name, L2TP_SKB_CB(skb)->ns,
@@ -582,7 +620,7 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	int offset;
 	u32 ns, nr;
-	struct l2tp_stats *sstats = &session->stats;
+	struct l2tp_stats *sstats;
 
 	/* The ref count is increased since we now hold a pointer to
 	 * the session. Take care to decrement the refcnt when exiting
@@ -599,9 +637,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 				  "%s: cookie mismatch (%u/%u). Discarding.\n",
 				  tunnel->name, tunnel->tunnel_id,
 				  session->session_id);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_cookie_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			sstats = this_cpu_ptr(session->cpustats);
+			u64_stats_update_begin(&sstats->rx.syncp);
+			sstats->rx.cookie_discards++;
+			u64_stats_update_end(&sstats->rx.syncp);
 			goto discard;
 		}
 		ptr += session->peer_cookie_len;
@@ -670,9 +709,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_seq_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			sstats = this_cpu_ptr(session->cpustats);
+			u64_stats_update_begin(&sstats->rx.syncp);
+			sstats->rx.seq_discards++;
+			u64_stats_update_end(&sstats->rx.syncp);
 			goto discard;
 		}
 
@@ -691,9 +731,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			l2tp_warn(session, L2TP_MSG_SEQ,
 				  "%s: recv data has no seq numbers when required. Discarding.\n",
 				  session->name);
-			u64_stats_update_begin(&sstats->syncp);
-			sstats->rx_seq_discards++;
-			u64_stats_update_end(&sstats->syncp);
+			sstats = this_cpu_ptr(session->cpustats);
+			u64_stats_update_begin(&sstats->rx.syncp);
+			sstats->rx.seq_discards++;
+			u64_stats_update_end(&sstats->rx.syncp);
 			goto discard;
 		}
 	}
@@ -747,9 +788,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 			 * packets
 			 */
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
-				u64_stats_update_begin(&sstats->syncp);
-				sstats->rx_seq_discards++;
-				u64_stats_update_end(&sstats->syncp);
+				sstats = this_cpu_ptr(session->cpustats);
+				u64_stats_update_begin(&sstats->rx.syncp);
+				sstats->rx.seq_discards++;
+				u64_stats_update_end(&sstats->rx.syncp);
 				l2tp_dbg(session, L2TP_MSG_SEQ,
 					 "%s: oos pkt %u len %d discarded, waiting for %u, reorder_q_len=%d\n",
 					 session->name, L2TP_SKB_CB(skb)->ns,
@@ -775,9 +817,10 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	return;
 
 discard:
-	u64_stats_update_begin(&sstats->syncp);
-	sstats->rx_errors++;
-	u64_stats_update_end(&sstats->syncp);
+	sstats = this_cpu_ptr(session->cpustats);
+	u64_stats_update_begin(&sstats->rx.syncp);
+	sstats->rx.errors++;
+	u64_stats_update_end(&sstats->rx.syncp);
 	kfree_skb(skb);
 
 	if (session->deref)
@@ -891,10 +934,10 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 discard_bad_csum:
 	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
 	UDP_INC_STATS_USER(tunnel->l2tp_net, UDP_MIB_INERRORS, 0);
-	tstats = &tunnel->stats;
-	u64_stats_update_begin(&tstats->syncp);
-	tstats->rx_errors++;
-	u64_stats_update_end(&tstats->syncp);
+	tstats = this_cpu_ptr(tunnel->cpustats);
+	u64_stats_update_begin(&tstats->rx.syncp);
+	tstats->rx.errors++;
+	u64_stats_update_end(&tstats->rx.syncp);
 	kfree_skb(skb);
 
 	return 0;
@@ -1050,21 +1093,21 @@ static int l2tp_xmit_core(struct l2tp_session *session, struct sk_buff *skb,
 		error = ip_queue_xmit(skb, fl);
 
 	/* Update stats */
-	tstats = &tunnel->stats;
-	u64_stats_update_begin(&tstats->syncp);
-	sstats = &session->stats;
-	u64_stats_update_begin(&sstats->syncp);
+	tstats = this_cpu_ptr(tunnel->cpustats);
+	sstats = this_cpu_ptr(session->cpustats);
+	u64_stats_update_begin(&tstats->tx.syncp);
+	u64_stats_update_begin(&sstats->tx.syncp);
 	if (error >= 0) {
-		tstats->tx_packets++;
-		tstats->tx_bytes += len;
-		sstats->tx_packets++;
-		sstats->tx_bytes += len;
+		tstats->tx.packets++;
+		tstats->tx.bytes += len;
+		sstats->tx.packets++;
+		sstats->tx.bytes += len;
 	} else {
-		tstats->tx_errors++;
-		sstats->tx_errors++;
+		tstats->tx.errors++;
+		sstats->tx.errors++;
 	}
-	u64_stats_update_end(&tstats->syncp);
-	u64_stats_update_end(&sstats->syncp);
+	u64_stats_update_end(&tstats->tx.syncp);
+	u64_stats_update_end(&sstats->tx.syncp);
 
 	return 0;
 }
@@ -1256,6 +1299,8 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 	sk->sk_destruct = tunnel->old_sk_destruct;
 	sk->sk_user_data = NULL;
 
+	free_percpu(tunnel->cpustats);
+
 	/* Call the original destructor */
 	if (sk->sk_destruct)
 		(*sk->sk_destruct)(sk);
@@ -1567,6 +1612,13 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		goto err;
 	}
 
+	tunnel->cpustats = alloc_percpu(struct l2tp_stats);
+	if (tunnel->cpustats == NULL) {
+		kfree(tunnel);
+		err = -ENOMEM;
+		goto err;
+	}
+
 	tunnel->version = version;
 	tunnel->tunnel_id = tunnel_id;
 	tunnel->peer_tunnel_id = peer_tunnel_id;
@@ -1692,6 +1744,8 @@ void l2tp_session_free(struct l2tp_session *session)
 
 		sock_put(tunnel->sock);
 
+		free_percpu(session->cpustats);
+
 		/* This will delete the tunnel context if this
 		 * is the last session on the tunnel.
 		 */
@@ -1742,80 +1796,88 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 	struct l2tp_session *session;
 
 	session = kzalloc(sizeof(struct l2tp_session) + priv_size, GFP_KERNEL);
-	if (session != NULL) {
-		session->magic = L2TP_SESSION_MAGIC;
-		session->tunnel = tunnel;
+	if (session == NULL)
+		goto err;
 
-		session->session_id = session_id;
-		session->peer_session_id = peer_session_id;
-		session->nr = 0;
+	session->cpustats = alloc_percpu(struct l2tp_stats);
+	if (session->cpustats == NULL) {
+		kfree(session);
+		goto err;
+	}
 
-		sprintf(&session->name[0], "sess %u/%u",
-			tunnel->tunnel_id, session->session_id);
+	session->magic = L2TP_SESSION_MAGIC;
+	session->tunnel = tunnel;
 
-		skb_queue_head_init(&session->reorder_q);
-
-		INIT_HLIST_NODE(&session->hlist);
-		INIT_HLIST_NODE(&session->global_hlist);
-
-		/* Inherit debug options from tunnel */
-		session->debug = tunnel->debug;
-
-		if (cfg) {
-			session->pwtype = cfg->pw_type;
-			session->debug = cfg->debug;
-			session->mtu = cfg->mtu;
-			session->mru = cfg->mru;
-			session->send_seq = cfg->send_seq;
-			session->recv_seq = cfg->recv_seq;
-			session->lns_mode = cfg->lns_mode;
-			session->reorder_timeout = cfg->reorder_timeout;
-			session->offset = cfg->offset;
-			session->l2specific_type = cfg->l2specific_type;
-			session->l2specific_len = cfg->l2specific_len;
-			session->cookie_len = cfg->cookie_len;
-			memcpy(&session->cookie[0], &cfg->cookie[0], cfg->cookie_len);
-			session->peer_cookie_len = cfg->peer_cookie_len;
-			memcpy(&session->peer_cookie[0], &cfg->peer_cookie[0], cfg->peer_cookie_len);
-		}
+	session->session_id = session_id;
+	session->peer_session_id = peer_session_id;
+	session->nr = 0;
 
-		if (tunnel->version == L2TP_HDR_VER_2)
-			session->build_header = l2tp_build_l2tpv2_header;
-		else
-			session->build_header = l2tp_build_l2tpv3_header;
+	sprintf(&session->name[0], "sess %u/%u",
+			tunnel->tunnel_id, session->session_id);
 
-		l2tp_session_set_header_len(session, tunnel->version);
+	skb_queue_head_init(&session->reorder_q);
+
+	INIT_HLIST_NODE(&session->hlist);
+	INIT_HLIST_NODE(&session->global_hlist);
+
+	/* Inherit debug options from tunnel */
+	session->debug = tunnel->debug;
+
+	if (cfg) {
+		session->pwtype = cfg->pw_type;
+		session->debug = cfg->debug;
+		session->mtu = cfg->mtu;
+		session->mru = cfg->mru;
+		session->send_seq = cfg->send_seq;
+		session->recv_seq = cfg->recv_seq;
+		session->lns_mode = cfg->lns_mode;
+		session->reorder_timeout = cfg->reorder_timeout;
+		session->offset = cfg->offset;
+		session->l2specific_type = cfg->l2specific_type;
+		session->l2specific_len = cfg->l2specific_len;
+		session->cookie_len = cfg->cookie_len;
+		memcpy(&session->cookie[0], &cfg->cookie[0], cfg->cookie_len);
+		session->peer_cookie_len = cfg->peer_cookie_len;
+		memcpy(&session->peer_cookie[0], &cfg->peer_cookie[0], cfg->peer_cookie_len);
+	}
 
-		/* Bump the reference count. The session context is deleted
-		 * only when this drops to zero.
-		 */
-		l2tp_session_inc_refcount(session);
-		l2tp_tunnel_inc_refcount(tunnel);
+	if (tunnel->version == L2TP_HDR_VER_2)
+		session->build_header = l2tp_build_l2tpv2_header;
+	else
+		session->build_header = l2tp_build_l2tpv3_header;
 
-		/* Ensure tunnel socket isn't deleted */
-		sock_hold(tunnel->sock);
+	l2tp_session_set_header_len(session, tunnel->version);
 
-		/* Add session to the tunnel's hash list */
-		write_lock_bh(&tunnel->hlist_lock);
-		hlist_add_head(&session->hlist,
-			       l2tp_session_id_hash(tunnel, session_id));
-		write_unlock_bh(&tunnel->hlist_lock);
+	/* Bump the reference count. The session context is deleted
+	 * only when this drops to zero.
+	 */
+	l2tp_session_inc_refcount(session);
+	l2tp_tunnel_inc_refcount(tunnel);
 
-		/* And to the global session list if L2TPv3 */
-		if (tunnel->version != L2TP_HDR_VER_2) {
-			struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
+	/* Ensure tunnel socket isn't deleted */
+	sock_hold(tunnel->sock);
 
-			spin_lock_bh(&pn->l2tp_session_hlist_lock);
-			hlist_add_head_rcu(&session->global_hlist,
-					   l2tp_session_id_hash_2(pn, session_id));
-			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
-		}
+	/* Add session to the tunnel's hash list */
+	write_lock_bh(&tunnel->hlist_lock);
+	hlist_add_head(&session->hlist,
+			l2tp_session_id_hash(tunnel, session_id));
+	write_unlock_bh(&tunnel->hlist_lock);
 
-		/* Ignore management session in session count value */
-		if (session->session_id != 0)
-			atomic_inc(&l2tp_session_count);
+	/* And to the global session list if L2TPv3 */
+	if (tunnel->version != L2TP_HDR_VER_2) {
+		struct l2tp_net *pn = l2tp_pernet(tunnel->l2tp_net);
+
+		spin_lock_bh(&pn->l2tp_session_hlist_lock);
+		hlist_add_head_rcu(&session->global_hlist,
+				l2tp_session_id_hash_2(pn, session_id));
+		spin_unlock_bh(&pn->l2tp_session_hlist_lock);
 	}
 
+	/* Ignore management session in session count value */
+	if (session->session_id != 0)
+		atomic_inc(&l2tp_session_count);
+
+err:
 	return session;
 }
 EXPORT_SYMBOL_GPL(l2tp_session_create);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index a38ec6c..29bb34c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -35,19 +35,34 @@ enum {
 
 struct sk_buff;
 
-struct l2tp_stats {
-	u64			tx_packets;
-	u64			tx_bytes;
-	u64			tx_errors;
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			rx_seq_discards;
-	u64			rx_oos_packets;
-	u64			rx_errors;
-	u64			rx_cookie_discards;
+/* Stats are synchronised via a synchronisation point for safe
+ * reader/writer access on 64 and 32 bit kernels.  Stats are
+ * stored on a per-cpu basis for safe lockless updating, and
+ * summed at read time.  This allows the statistics update in
+ * the data path to be fast at some small cost when reading.
+ */
+struct l2tp_rx_stats {
+	u64			packets;
+	u64			bytes;
+	u64			errors;
+	u64			seq_discards;
+	u64			cookie_discards;
+	u64			oos_packets;
+	struct u64_stats_sync	syncp;
+};
+
+struct l2tp_tx_stats {
+	u64			packets;
+	u64			bytes;
+	u64			errors;
 	struct u64_stats_sync	syncp;
 };
 
+struct l2tp_stats {
+	struct l2tp_rx_stats	rx;
+	struct l2tp_tx_stats	tx;
+};
+
 struct l2tp_tunnel;
 
 /* Describes a session. Contains information to determine incoming
@@ -127,7 +142,9 @@ struct l2tp_session {
 	int			mtu;
 	int			mru;
 	enum l2tp_pwtype	pwtype;
-	struct l2tp_stats	stats;
+
+	struct l2tp_stats	*cpustats;	/* per-cpu counters */
+
 	struct hlist_node	global_hlist;	/* Global hash list node */
 
 	int (*build_header)(struct l2tp_session *session, void *buf);
@@ -175,7 +192,8 @@ struct l2tp_tunnel {
 	int			debug;		/* bitmask of debug message
 						 * categories */
 	enum l2tp_encap_type	encap;
-	struct l2tp_stats	stats;
+
+	struct l2tp_stats	*cpustats;	/* per-cpu counters */
 
 	struct list_head	list;		/* Keep a list of all tunnels */
 	struct net		*l2tp_net;	/* the net we belong to */
@@ -246,6 +264,8 @@ extern int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int
 extern int l2tp_nl_register_ops(enum l2tp_pwtype pw_type, const struct l2tp_nl_cmd_ops *ops);
 extern void l2tp_nl_unregister_ops(enum l2tp_pwtype pw_type);
 
+extern int l2tp_stats_copy(struct l2tp_stats *cpustats, struct l2tp_stats *dest);
+
 /* Session reference counts. Incremented when code obtains a reference
  * to a session.
  */
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index c3813bc..5ec4732 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -106,6 +106,7 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 	int hash;
 	struct hlist_node *walk;
 	struct hlist_node *tmp;
+	struct l2tp_stats stats;
 
 	read_lock_bh(&tunnel->hlist_lock);
 	for (hash = 0; hash < L2TP_HASH_SIZE; hash++) {
@@ -146,14 +147,18 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 		   tunnel->sock ? atomic_read(&tunnel->sock->sk_refcnt) : 0,
 		   atomic_read(&tunnel->ref_count));
 
-	seq_printf(m, " %08x rx %llu/%llu/%llu rx %llu/%llu/%llu\n",
-		   tunnel->debug,
-		   (unsigned long long)tunnel->stats.tx_packets,
-		   (unsigned long long)tunnel->stats.tx_bytes,
-		   (unsigned long long)tunnel->stats.tx_errors,
-		   (unsigned long long)tunnel->stats.rx_packets,
-		   (unsigned long long)tunnel->stats.rx_bytes,
-		   (unsigned long long)tunnel->stats.rx_errors);
+	if (!l2tp_stats_copy(tunnel->cpustats, &stats)) {
+		seq_printf(m, " %08x tx %llu/%llu/%llu rx %llu/%llu/%llu\n",
+				tunnel->debug,
+				(unsigned long long)stats.tx.packets,
+				(unsigned long long)stats.tx.bytes,
+				(unsigned long long)stats.tx.errors,
+				(unsigned long long)stats.rx.packets,
+				(unsigned long long)stats.rx.bytes,
+				(unsigned long long)stats.rx.errors);
+	} else {
+		seq_printf(m, " stats lookup failure\n");
+	}
 
 	if (tunnel->show != NULL)
 		tunnel->show(m, tunnel);
@@ -162,6 +167,7 @@ static void l2tp_dfs_seq_tunnel_show(struct seq_file *m, void *v)
 static void l2tp_dfs_seq_session_show(struct seq_file *m, void *v)
 {
 	struct l2tp_session *session = v;
+	struct l2tp_stats stats;
 
 	seq_printf(m, "  SESSION %u, peer %u, %s\n", session->session_id,
 		   session->peer_session_id,
@@ -203,14 +209,18 @@ static void l2tp_dfs_seq_session_show(struct seq_file *m, void *v)
 		seq_printf(m, "\n");
 	}
 
-	seq_printf(m, "   %hu/%hu tx %llu/%llu/%llu rx %llu/%llu/%llu\n",
-		   session->nr, session->ns,
-		   (unsigned long long)session->stats.tx_packets,
-		   (unsigned long long)session->stats.tx_bytes,
-		   (unsigned long long)session->stats.tx_errors,
-		   (unsigned long long)session->stats.rx_packets,
-		   (unsigned long long)session->stats.rx_bytes,
-		   (unsigned long long)session->stats.rx_errors);
+	if (!l2tp_stats_copy(session->cpustats, &stats)) {
+		seq_printf(m, "   %hu/%hu tx %llu/%llu/%llu rx %llu/%llu/%llu\n",
+				session->nr, session->ns,
+				(unsigned long long)stats.tx.packets,
+				(unsigned long long)stats.tx.bytes,
+				(unsigned long long)stats.tx.errors,
+				(unsigned long long)stats.rx.packets,
+				(unsigned long long)stats.rx.bytes,
+				(unsigned long long)stats.rx.errors);
+	} else {
+		seq_printf(m, " stats lookup failure\n");
+	}
 
 	if (session->show != NULL)
 		session->show(m, session);
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index ddc553e..09fd33d 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -246,7 +246,6 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 	struct ipv6_pinfo *np = NULL;
 #endif
 	struct l2tp_stats stats;
-	unsigned int start;
 
 	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
 			  L2TP_CMD_TUNNEL_GET);
@@ -264,28 +263,19 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
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
+	if (0 != l2tp_stats_copy(tunnel->cpustats, &stats))
+		goto nla_put_failure;
+
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx.packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx.bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx.errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx.packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx.bytes) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			stats.rx_seq_discards) ||
+			stats.rx.seq_discards) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
+			stats.rx.oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx.errors))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
@@ -612,7 +602,6 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct sock *sk = NULL;
 	struct l2tp_stats stats;
-	unsigned int start;
 
 	sk = tunnel->sock;
 
@@ -655,28 +644,19 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
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
+	if (0 != l2tp_stats_copy(session->cpustats, &stats))
+		goto nla_put_failure;
+
+	if (nla_put_u64(skb, L2TP_ATTR_TX_PACKETS, stats.tx.packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_BYTES, stats.tx.bytes) ||
+	    nla_put_u64(skb, L2TP_ATTR_TX_ERRORS, stats.tx.errors) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_PACKETS, stats.rx.packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_BYTES, stats.rx.bytes) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_SEQ_DISCARDS,
-			stats.rx_seq_discards) ||
+			stats.rx.seq_discards) ||
 	    nla_put_u64(skb, L2TP_ATTR_RX_OOS_PACKETS,
-			stats.rx_oos_packets) ||
-	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx_errors))
+			stats.rx.oos_packets) ||
+	    nla_put_u64(skb, L2TP_ATTR_RX_ERRORS, stats.rx.errors))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 286366e..054c069 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -222,6 +222,7 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 {
 	struct pppol2tp_session *ps = l2tp_session_priv(session);
 	struct sock *sk = NULL;
+	struct l2tp_stats *sstats = NULL;
 
 	/* If the socket is bound, send it in to PPP's input queue. Otherwise
 	 * queue it on the session socket.
@@ -259,7 +260,10 @@ static void pppol2tp_recv(struct l2tp_session *session, struct sk_buff *skb, int
 			  session->name);
 
 		/* Not bound. Nothing we can do, so discard. */
-		session->stats.rx_errors++;
+		sstats = this_cpu_ptr(session->cpustats);
+		u64_stats_update_begin(&sstats->rx.syncp);
+		sstats->rx.errors++;
+		u64_stats_update_end(&sstats->rx.syncp);
 		kfree_skb(skb);
 	}
 
@@ -1028,16 +1032,21 @@ end:
  ****************************************************************************/
 
 static void pppol2tp_copy_stats(struct pppol2tp_ioc_stats *dest,
-				struct l2tp_stats *stats)
+				struct l2tp_stats *cpustats)
 {
-	dest->tx_packets = stats->tx_packets;
-	dest->tx_bytes = stats->tx_bytes;
-	dest->tx_errors = stats->tx_errors;
-	dest->rx_packets = stats->rx_packets;
-	dest->rx_bytes = stats->rx_bytes;
-	dest->rx_seq_discards = stats->rx_seq_discards;
-	dest->rx_oos_packets = stats->rx_oos_packets;
-	dest->rx_errors = stats->rx_errors;
+	struct l2tp_stats tmp;
+
+	if (0 != l2tp_stats_copy(cpustats, &tmp))
+		return;
+
+	dest->tx_packets = tmp.tx.packets;
+	dest->tx_bytes = tmp.tx.bytes;
+	dest->tx_errors = tmp.tx.errors;
+	dest->rx_packets = tmp.rx.packets;
+	dest->rx_bytes = tmp.rx.bytes;
+	dest->rx_seq_discards = tmp.rx.seq_discards;
+	dest->rx_oos_packets = tmp.rx.oos_packets;
+	dest->rx_errors = tmp.rx.errors;
 }
 
 /* Session ioctl helper.
@@ -1151,7 +1160,7 @@ static int pppol2tp_session_ioctl(struct l2tp_session *session,
 		memset(&stats, 0, sizeof(stats));
 		stats.tunnel_id = tunnel->tunnel_id;
 		stats.session_id = session->session_id;
-		pppol2tp_copy_stats(&stats, &session->stats);
+		pppol2tp_copy_stats(&stats, session->cpustats);
 		if (copy_to_user((void __user *) arg, &stats,
 				 sizeof(stats)))
 			break;
@@ -1214,7 +1223,7 @@ static int pppol2tp_tunnel_ioctl(struct l2tp_tunnel *tunnel,
 #ifdef CONFIG_XFRM
 		stats.using_ipsec = (sk->sk_policy[0] || sk->sk_policy[1]) ? 1 : 0;
 #endif
-		pppol2tp_copy_stats(&stats, &tunnel->stats);
+		pppol2tp_copy_stats(&stats, tunnel->cpustats);
 		if (copy_to_user((void __user *) arg, &stats, sizeof(stats))) {
 			err = -EFAULT;
 			break;
@@ -1666,19 +1675,24 @@ static void pppol2tp_seq_stop(struct seq_file *p, void *v)
 static void pppol2tp_seq_tunnel_show(struct seq_file *m, void *v)
 {
 	struct l2tp_tunnel *tunnel = v;
+	struct l2tp_stats tmp;
 
 	seq_printf(m, "\nTUNNEL '%s', %c %d\n",
 		   tunnel->name,
 		   (tunnel == tunnel->sock->sk_user_data) ? 'Y' : 'N',
 		   atomic_read(&tunnel->ref_count) - 1);
-	seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
-		   tunnel->debug,
-		   (unsigned long long)tunnel->stats.tx_packets,
-		   (unsigned long long)tunnel->stats.tx_bytes,
-		   (unsigned long long)tunnel->stats.tx_errors,
-		   (unsigned long long)tunnel->stats.rx_packets,
-		   (unsigned long long)tunnel->stats.rx_bytes,
-		   (unsigned long long)tunnel->stats.rx_errors);
+	if (!l2tp_stats_copy(tunnel->cpustats, &tmp)) {
+		seq_printf(m, " %08x %llu/%llu/%llu %llu/%llu/%llu\n",
+				tunnel->debug,
+				(unsigned long long)tmp.tx.packets,
+				(unsigned long long)tmp.tx.bytes,
+				(unsigned long long)tmp.tx.errors,
+				(unsigned long long)tmp.rx.packets,
+				(unsigned long long)tmp.rx.bytes,
+				(unsigned long long)tmp.rx.errors);
+	} else {
+		seq_printf(m, " stats lookup failure\n");
+	}
 }
 
 static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
@@ -1687,6 +1701,7 @@ static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
 	struct l2tp_tunnel *tunnel = session->tunnel;
 	struct pppol2tp_session *ps = l2tp_session_priv(session);
 	struct pppox_sock *po = pppox_sk(ps->sock);
+	struct l2tp_stats tmp;
 	u32 ip = 0;
 	u16 port = 0;
 
@@ -1713,14 +1728,18 @@ static void pppol2tp_seq_session_show(struct seq_file *m, void *v)
 		   session->lns_mode ? "LNS" : "LAC",
 		   session->debug,
 		   jiffies_to_msecs(session->reorder_timeout));
-	seq_printf(m, "   %hu/%hu %llu/%llu/%llu %llu/%llu/%llu\n",
-		   session->nr, session->ns,
-		   (unsigned long long)session->stats.tx_packets,
-		   (unsigned long long)session->stats.tx_bytes,
-		   (unsigned long long)session->stats.tx_errors,
-		   (unsigned long long)session->stats.rx_packets,
-		   (unsigned long long)session->stats.rx_bytes,
-		   (unsigned long long)session->stats.rx_errors);
+	if (!l2tp_stats_copy(session->cpustats, &tmp)) {
+		seq_printf(m, "   %hu/%hu %llu/%llu/%llu %llu/%llu/%llu\n",
+			   session->nr, session->ns,
+			   (unsigned long long)tmp.tx.packets,
+			   (unsigned long long)tmp.tx.bytes,
+			   (unsigned long long)tmp.tx.errors,
+			   (unsigned long long)tmp.rx.packets,
+			   (unsigned long long)tmp.rx.bytes,
+			   (unsigned long long)tmp.rx.errors);
+	} else {
+		seq_printf(m, " stats lookup failure\n");
+	}
 
 	if (po)
 		seq_printf(m, "   interface %s\n", ppp_dev_name(&po->chan));
-- 
1.7.9.5
