From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: [RFC] mac80211: introduce netdev queue control for txqs
Date: Wed, 27 Jan 2016 15:39:13 +0100
Message-ID: <1453905553-25566-1-git-send-email-michal.kazior@tieto.com>
References: <1453904917-25458-1-git-send-email-michal.kazior@tieto.com>
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453904917-25458-1-git-send-email-michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Until now all stations (notably in AP mode) would
share 4 AC queues exposed via netdev. This meant
that whenever a single station's AC became full
all other stations' AC were considered full and
stopped as well.

This was suboptimal and could lead to per station
traffic starvation and/or suboptimal Tx
aggregation performance.

The introduced queue control is performed by
mac80211 alone. Additional netdev queues are
created only if driver supports wake_tx_queue()
op.

First 4 netdev queues are used for unclassified
traffic (e.g. when there's no sta_info for given
RA) which is mostly multicast.

All other netdev queues (>=4) are used per
station. Each station gets 4 queues for each AC.
Whenever station's AC-related ieee80211_txqs get
full only that single station's netdev queue is
stopped allowing all other stations (either using
identical AC number or not) to continue submitting
traffic without interruption.

Current implementation supports up to 63
non-overlapping stations. Overlapping stations
will share their per AC netdev queues so whenever
any of overlapping stations' AC queue is stopped
others are stopped as well.

This was designed with MU-MIMO in mind but should
benefit regular Tx aggregation as well because
drivers will now have the ability to avoid
clogging up their internal (be it firmware or
hardware) queues with traffic to slow or
unresponsive stations needlessly.

Note: This can significantly increase memory usage
with, e.g. fq_codel qdisc even up to 20MB per
virtual interface.

Signed-off-by: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
---
Note: It is recommended to have the following
patch applied in order to avoid conflicts:

  https://patchwork.kernel.org/patch/8134481/

I'm re-sending this with netdev in Cc as per
Johannes' suggestion.


 net/mac80211/cfg.c         |  5 +++
 net/mac80211/ieee80211_i.h | 16 +++++++++
 net/mac80211/iface.c       | 21 ++++++++++-
 net/mac80211/sta_info.c    | 86 ++++++++++++++++++++++++++++++++++++++++++++--
 net/mac80211/sta_info.h    | 11 ++++++
 net/mac80211/tx.c          | 74 ++++++++++++++++++++++++++++++++++-----
 net/mac80211/util.c        | 35 ++++++++++++++++---
 net/mac80211/wme.c         |  5 +++
 8 files changed, 238 insertions(+), 15 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 66d22de93c8d..0428c5f68e8c 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1370,6 +1370,11 @@ static int ieee80211_change_station(struct wiphy *wiphy,
 			prev_4addr = true;
 		}
 
+		if (local->ops->wake_tx_queue) {
+			sta_info_ndev_free(sta->sdata, sta);
+			sta_info_ndev_init(vlansdata, sta);
+		}
+
 		sta->sdata = vlansdata;
 		ieee80211_check_fast_xmit(sta);
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index a96f8c0461f6..416bd12f14d2 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -47,6 +47,17 @@ struct ieee80211_local;
  * frame can be up to about 2 kB long. */
 #define TOTAL_MAX_TX_BUFFER 512
 
+/* The number of stations exposed via netdev queues. First 4 netdev queues are
+ * mapped to vif's ACs. Subsequent ones, in groups of 4, are ACs for stations.
+ * NUM_NDEV_STA + 1 station is wrapped around to 1st station. f.e. netdev queue
+ * 5 corresponds to AC1 of STA0, STA63, STA126, ... and queue 8 corresponds
+ * to AC0 of STA1, STA64, STA127, ...
+ *
+ * This is used only when driver implements wake_tx_queues() op.
+ */
+#define IEEE80211_NUM_NDEV_STA 63
+#define IEEE80211_NUM_NDEV_STA_Q (IEEE80211_NUM_NDEV_STA * IEEE80211_NUM_ACS)
+
 /* Required encryption head and tailroom */
 #define IEEE80211_ENCRYPT_HEADROOM 8
 #define IEEE80211_ENCRYPT_TAILROOM 18
@@ -852,7 +863,12 @@ struct ieee80211_sub_if_data {
 	bool control_port_no_encrypt;
 	int encrypt_headroom;
 
+	spinlock_t ndev_lock; /* protects access to ndev_sta_idr */
+	DECLARE_BITMAP(ndev_sta_q_stopped, IEEE80211_NUM_NDEV_STA_Q);
+	atomic_t ndev_sta_q_refs[IEEE80211_NUM_NDEV_STA_Q];
+	struct idr ndev_sta_idr;
 	atomic_t txqs_len[IEEE80211_NUM_ACS];
+
 	struct ieee80211_tx_queue_params tx_conf[IEEE80211_NUM_ACS];
 	struct mac80211_qos_map __rcu *qos_map;
 
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 453b4e741780..d3dae1ae5652 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1094,6 +1094,8 @@ static void ieee80211_teardown_sdata(struct ieee80211_sub_if_data *sdata)
 
 	if (ieee80211_vif_is_mesh(&sdata->vif))
 		mesh_rmc_free(sdata);
+
+	idr_destroy(&sdata->ndev_sta_idr);
 }
 
 static void ieee80211_uninit(struct net_device *dev)
@@ -1373,6 +1375,7 @@ static void ieee80211_setup_sdata(struct ieee80211_sub_if_data *sdata,
 {
 	static const u8 bssid_wildcard[ETH_ALEN] = {0xff, 0xff, 0xff,
 						    0xff, 0xff, 0xff};
+	int i;
 
 	/* clear type-dependent union */
 	memset(&sdata->u, 0, sizeof(sdata->u));
@@ -1401,6 +1404,15 @@ static void ieee80211_setup_sdata(struct ieee80211_sub_if_data *sdata,
 	INIT_WORK(&sdata->csa_finalize_work, ieee80211_csa_finalize_work);
 	INIT_LIST_HEAD(&sdata->assigned_chanctx_list);
 	INIT_LIST_HEAD(&sdata->reserved_chanctx_list);
+	idr_init(&sdata->ndev_sta_idr);
+	memset(sdata->ndev_sta_q_stopped, 0,
+	       sizeof(sdata->ndev_sta_q_stopped));
+
+	for (i = 0; i < IEEE80211_NUM_NDEV_STA_Q; i++)
+		atomic_set(&sdata->ndev_sta_q_refs[i], 0);
+
+	for (i = 0; i < IEEE80211_NUM_ACS; i++)
+		atomic_set(&sdata->txqs_len[i], 0);
 
 	switch (type) {
 	case NL80211_IFTYPE_P2P_GO:
@@ -1734,9 +1746,14 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 			txq_size += sizeof(struct txq_info) +
 				    local->hw.txq_data_size;
 
-		if (local->hw.queues >= IEEE80211_NUM_ACS)
+		if (local->hw.queues >= IEEE80211_NUM_ACS) {
 			txqs = IEEE80211_NUM_ACS;
 
+			if (local->ops->wake_tx_queue)
+				txqs += IEEE80211_NUM_NDEV_STA *
+					IEEE80211_NUM_ACS;
+		}
+
 		ndev = alloc_netdev_mqs(size + txq_size,
 					name, name_assign_type,
 					ieee80211_if_setup, txqs, 1);
@@ -1831,6 +1848,8 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
 
 	sdata->encrypt_headroom = IEEE80211_ENCRYPT_HEADROOM;
 
+	spin_lock_init(&sdata->ndev_lock);
+
 	/* setup type-dependent data */
 	ieee80211_setup_sdata(sdata, type);
 
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index e1d9ccc5d197..d9ff1b65e1ab 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -112,10 +112,9 @@ static void __cleanup_single_sta(struct sta_info *sta)
 	if (sta->sta.txq[0]) {
 		for (i = 0; i < ARRAY_SIZE(sta->sta.txq); i++) {
 			struct txq_info *txqi = to_txq_info(sta->sta.txq[i]);
-			int n = skb_queue_len(&txqi->queue);
 
 			ieee80211_purge_tx_queue(&local->hw, &txqi->queue);
-			atomic_sub(n, &sdata->txqs_len[txqi->txq.ac]);
+			atomic_set(&sta->txqs_len[txqi->txq.ac], 0);
 			txqi->byte_cnt = 0;
 		}
 	}
@@ -230,6 +229,79 @@ struct sta_info *sta_info_get_by_idx(struct ieee80211_sub_if_data *sdata,
 	return NULL;
 }
 
+void sta_info_ndev_init(struct ieee80211_sub_if_data *sdata,
+			struct sta_info *sta)
+{
+	struct ieee80211_local *local = sdata->local;
+	int i;
+	int q;
+
+	spin_lock_bh(&sdata->ndev_lock);
+	i = idr_alloc(&sdata->ndev_sta_idr, sta, 0,
+		      BIT(sizeof(sta->sta_id) * 8) - 1,
+		      GFP_ATOMIC);
+	spin_unlock_bh(&sdata->ndev_lock);
+
+	if (i < 0) {
+		sta_dbg(sta->sdata, "failed to allocate STA %pM id: %d\n",
+			sta->sta.addr, i);
+		return;
+	}
+
+	sta->sta_id_set = true;
+	sta->sta_id = i;
+	sta->sta_id_off = (sta->sta_id % IEEE80211_NUM_NDEV_STA) *
+			  IEEE80211_NUM_ACS;
+
+	for (i = 0; i < IEEE80211_NUM_ACS; i++) {
+		q = sta->sta_id_off + IEEE80211_NUM_ACS + i;
+
+		atomic_set(&sta->txqs_len[i], 0);
+
+		if ((atomic_read(&sdata->txqs_len[i]) >=
+		     local->hw.txq_ac_max_pending) ||
+		    (sdata->vif.cab_queue != IEEE80211_INVAL_HW_QUEUE &&
+		     local->queue_stop_reasons[sdata->vif.cab_queue]) ||
+		    (sdata->vif.hw_queue[i] != IEEE80211_INVAL_HW_QUEUE &&
+		     local->queue_stop_reasons[sdata->vif.hw_queue[i]]))
+			netif_stop_subqueue(sdata->dev, q);
+		else
+			netif_wake_subqueue(sdata->dev, q);
+	}
+}
+
+void sta_info_ndev_free(struct ieee80211_sub_if_data *sdata,
+		        struct sta_info *sta)
+{
+	struct ieee80211_local *local = sdata->local;
+	int ac;
+	int nq;
+	int sq;
+	int q;
+
+	if (!sta->sta_id_set)
+		return;
+
+	for (ac = 0; ac < IEEE80211_NUM_ACS; ac++) {
+		q = sdata->vif.hw_queue[ac];
+		sq = ac + sta->sta_id_off;
+		nq = sq + IEEE80211_NUM_ACS;
+
+		if (test_and_clear_bit(ac, sta->txqs_stopped) &&
+		    atomic_dec_return(&sdata->ndev_sta_q_refs[sq]) == 0)
+			clear_bit(sq, sdata->ndev_sta_q_stopped);
+
+		if (__netif_subqueue_stopped(sdata->dev, nq))
+			ieee80211_propagate_queue_wake(local, q);
+	}
+
+	spin_lock_bh(&sdata->ndev_lock);
+	idr_remove(&sdata->ndev_sta_idr, sta->sta_id);
+	spin_unlock_bh(&sdata->ndev_lock);
+
+	sta->sta_id_set = false;
+}
+
 /**
  * sta_info_free - free STA
  *
@@ -243,6 +315,8 @@ struct sta_info *sta_info_get_by_idx(struct ieee80211_sub_if_data *sdata,
  */
 void sta_info_free(struct ieee80211_local *local, struct sta_info *sta)
 {
+	struct ieee80211_sub_if_data *sdata = sta->sdata;
+
 	if (sta->rate_ctrl)
 		rate_control_free_sta(sta);
 
@@ -254,6 +328,10 @@ void sta_info_free(struct ieee80211_local *local, struct sta_info *sta)
 #ifdef CONFIG_MAC80211_MESH
 	kfree(sta->mesh);
 #endif
+
+	if (local->ops->wake_tx_queue)
+		sta_info_ndev_free(sdata, sta);
+
 	kfree(sta);
 }
 
@@ -359,6 +437,8 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 
 			ieee80211_init_tx_queue(sdata, sta, txq, i);
 		}
+
+		sta_info_ndev_init(sdata, sta);
 	}
 
 	if (sta_prepare_rate_control(local, sta, gfp))
@@ -413,6 +493,8 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 free_txq:
 	if (sta->sta.txq[0])
 		kfree(to_txq_info(sta->sta.txq[0]));
+	if (local->ops->wake_tx_queue)
+		sta_info_ndev_free(sdata, sta);
 free:
 #ifdef CONFIG_MAC80211_MESH
 	kfree(sta->mesh);
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index f4d38994ecee..c897823caef3 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -407,6 +407,12 @@ struct sta_info {
 
 	struct ieee80211_fast_tx __rcu *fast_tx;
 
+	DECLARE_BITMAP(txqs_stopped, IEEE80211_NUM_ACS);
+	atomic_t txqs_len[IEEE80211_NUM_ACS];
+	u16 sta_id;
+	u16 sta_id_off;
+	bool sta_id_set;
+
 #ifdef CONFIG_MAC80211_MESH
 	struct mesh_sta *mesh;
 #endif
@@ -624,6 +630,11 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 
 void sta_info_free(struct ieee80211_local *local, struct sta_info *sta);
 
+void sta_info_ndev_init(struct ieee80211_sub_if_data *sdata,
+			struct sta_info *sta);
+void sta_info_ndev_free(struct ieee80211_sub_if_data *sdata,
+		        struct sta_info *sta);
+
 /*
  * Insert STA info into hash table/list, returns zero or a
  * -EEXIST if (if the same MAC address is already present).
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index af584f7cdd63..121752ad9f76 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1239,8 +1239,14 @@ static void ieee80211_drv_tx(struct ieee80211_local *local,
 	struct ieee80211_tx_control control = {
 		.sta = pubsta,
 	};
+	struct sta_info *sta = container_of(pubsta, struct sta_info, sta);
 	struct ieee80211_txq *txq = NULL;
 	struct txq_info *txqi;
+	int pending;
+	int q_max;
+	int q;
+	int sq;
+	int nq;
 	u8 ac;
 
 	if (info->control.flags & IEEE80211_TX_CTRL_PS_RESPONSE)
@@ -1262,12 +1268,34 @@ static void ieee80211_drv_tx(struct ieee80211_local *local,
 
 	ac = txq->ac;
 	txqi = to_txq_info(txq);
-	atomic_inc(&sdata->txqs_len[ac]);
-	if (atomic_read(&sdata->txqs_len[ac]) >= local->hw.txq_ac_max_pending)
-		netif_stop_subqueue(sdata->dev, ac);
 
 	spin_lock_bh(&txqi->queue.lock);
 	txqi->byte_cnt += skb->len;
+
+	if (pubsta)
+		pending = atomic_add_return(1, &sta->txqs_len[ac]);
+	else
+		pending = atomic_add_return(1, &sdata->txqs_len[ac]);
+
+	if (pending >= local->hw.txq_ac_max_pending) {
+		if (pubsta) {
+			sq = ac + sta->sta_id_off;
+			nq = sq + IEEE80211_NUM_ACS;
+
+			set_bit(sq, sdata->ndev_sta_q_stopped);
+			if (!test_and_set_bit(ac, sta->txqs_stopped))
+				atomic_inc(&sdata->ndev_sta_q_refs[sq]);
+
+			netif_stop_subqueue(sdata->dev, nq);
+		} else {
+			q_max = (1 + IEEE80211_NUM_NDEV_STA) *
+				IEEE80211_NUM_ACS;
+
+			for (q = ac; q < q_max; q += IEEE80211_NUM_ACS)
+				netif_stop_subqueue(sdata->dev, q);
+		}
+	}
+
 	__skb_queue_tail(&txqi->queue, skb);
 	spin_unlock_bh(&txqi->queue.lock);
 
@@ -1285,9 +1313,14 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata = vif_to_sdata(txq->vif);
 	struct txq_info *txqi = container_of(txq, struct txq_info, txq);
+	struct sta_info *sta = container_of(txq->sta, struct sta_info, sta);
 	struct ieee80211_hdr *hdr;
 	struct sk_buff *skb = NULL;
 	u8 ac = txq->ac;
+	int q = sdata->vif.hw_queue[ac];
+	int pending;
+	int nq;
+	int sq;
 
 	spin_lock_bh(&txqi->queue.lock);
 
@@ -1300,14 +1333,25 @@ struct sk_buff *ieee80211_tx_dequeue(struct ieee80211_hw *hw,
 
 	txqi->byte_cnt -= skb->len;
 
-	atomic_dec(&sdata->txqs_len[ac]);
-	if (__netif_subqueue_stopped(sdata->dev, ac))
-		ieee80211_propagate_queue_wake(local, sdata->vif.hw_queue[ac]);
+	if (txq->sta) {
+		pending = atomic_sub_return(1, &sta->txqs_len[ac]);
+		sq = ac + sta->sta_id_off;
+		nq = sq + IEEE80211_NUM_ACS;
+
+		if (pending < local->hw.txq_ac_max_pending &&
+		    test_and_clear_bit(ac, sta->txqs_stopped) &&
+		    atomic_dec_return(&sdata->ndev_sta_q_refs[sq]) == 0)
+			clear_bit(sq, sdata->ndev_sta_q_stopped);
+	} else {
+		pending = atomic_sub_return(1, &sdata->txqs_len[ac]);
+		nq = ac;
+	}
+
+	if (__netif_subqueue_stopped(sdata->dev, nq))
+		ieee80211_propagate_queue_wake(local, q);
 
 	hdr = (struct ieee80211_hdr *)skb->data;
 	if (txq->sta && ieee80211_is_data_qos(hdr->frame_control)) {
-		struct sta_info *sta = container_of(txq->sta, struct sta_info,
-						    sta);
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 
 		hdr->seq_ctrl = ieee80211_tx_next_seq(sta, txq->tid);
@@ -2941,7 +2985,21 @@ void __ieee80211_subif_start_xmit(struct sk_buff *skb,
 netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 				       struct net_device *dev)
 {
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = sdata->local;
+	u16 ac;
+
+	if (local->ops->wake_tx_queue) {
+		/* ndo_select_queue() can alter the queue mapping for per-station
+		 * stop/wake queue control purposes. Undo it to prevent confusing
+		 * underlying mac80211 drivers.
+		 */
+		ac = skb_get_queue_mapping(skb) % IEEE80211_NUM_ACS;
+		skb_set_queue_mapping(skb, ac);
+	}
+
 	__ieee80211_subif_start_xmit(skb, dev, 0);
+
 	return NETDEV_TX_OK;
 }
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 091f3dd62ad1..fafc036c278f 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -239,6 +239,22 @@ __le16 ieee80211_ctstoself_duration(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(ieee80211_ctstoself_duration);
 
+static void
+ieee80211_propagate_sta_queue_wake(struct ieee80211_sub_if_data *sdata,
+				   int ac)
+{
+	struct ieee80211_local *local = sdata->local;
+	int q_max = IEEE80211_NUM_NDEV_STA_Q;
+	int q;
+
+	if (!local->ops->wake_tx_queue)
+		return;
+
+	for (q = ac; q < q_max; q += IEEE80211_NUM_ACS)
+		if (!test_bit(q, sdata->ndev_sta_q_stopped))
+			netif_wake_subqueue(sdata->dev, q + IEEE80211_NUM_ACS);
+}
+
 void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 {
 	struct ieee80211_sub_if_data *sdata;
@@ -261,15 +277,17 @@ void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 			int ac_queue = sdata->vif.hw_queue[ac];
 
 			if (local->ops->wake_tx_queue &&
-			    (atomic_read(&sdata->txqs_len[ac]) >
+			    (atomic_read(&sdata->txqs_len[ac]) >=
 			     local->hw.txq_ac_max_pending))
 				continue;
 
 			if (ac_queue == queue ||
 			    (sdata->vif.cab_queue == queue &&
 			     local->queue_stop_reasons[ac_queue] == 0 &&
-			     skb_queue_empty(&local->pending[ac_queue])))
+			     skb_queue_empty(&local->pending[ac_queue]))) {
 				netif_wake_subqueue(sdata->dev, ac);
+				ieee80211_propagate_sta_queue_wake(sdata, ac);
+			}
 		}
 	}
 }
@@ -338,6 +356,8 @@ static void __ieee80211_stop_queue(struct ieee80211_hw *hw, int queue,
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata;
 	int n_acs = IEEE80211_NUM_ACS;
+	int q_max;
+	int q;
 
 	trace_stop_queue(local, queue, reason);
 
@@ -355,6 +375,11 @@ static void __ieee80211_stop_queue(struct ieee80211_hw *hw, int queue,
 	if (local->hw.queues < IEEE80211_NUM_ACS)
 		n_acs = 1;
 
+	if (local->ops->wake_tx_queue)
+		q_max = IEEE80211_NUM_ACS * (IEEE80211_NUM_NDEV_STA + 1);
+	else
+		q_max = IEEE80211_NUM_ACS;
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
 		int ac;
@@ -364,8 +389,10 @@ static void __ieee80211_stop_queue(struct ieee80211_hw *hw, int queue,
 
 		for (ac = 0; ac < n_acs; ac++) {
 			if (sdata->vif.hw_queue[ac] == queue ||
-			    sdata->vif.cab_queue == queue)
-				netif_stop_subqueue(sdata->dev, ac);
+			    sdata->vif.cab_queue == queue) {
+				for (q = ac; q < q_max; q += IEEE80211_NUM_ACS)
+					netif_stop_subqueue(sdata->dev, q);
+			}
 		}
 	}
 	rcu_read_unlock();
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 9eb0aee9105b..0950f8383e3d 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -221,6 +221,11 @@ u16 ieee80211_select_queue(struct ieee80211_sub_if_data *sdata,
  downgrade:
 	ret = ieee80211_downgrade_queue(sdata, sta, skb);
  out:
+	if (local->ops->wake_tx_queue && sta) {
+		ret += IEEE80211_NUM_ACS;
+		ret += sta->sta_id_off;
+	}
+
 	rcu_read_unlock();
 	return ret;
 }
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
