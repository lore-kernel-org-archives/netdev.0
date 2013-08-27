From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] sfc: Split Falcon-arch-specific and common
 filter state
Date: Tue, 27 Aug 2013 21:45:53 +0100
Message-ID: <1377636353.13272.81.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6051 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406Ab3H0Up5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:45:57 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the common state from struct efx_filter_state into struct efx_nic.
Rename struct efx_filter_state to efx_farch_filter_state and change
the type of efx_nic::filter_state to void *.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/filter.c     | 100 ++++++++++++++++------------------
 drivers/net/ethernet/sfc/net_driver.h |  13 ++++-
 2 files changed, 58 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/sfc/filter.c b/drivers/net/ethernet/sfc/filter.c
index 96f8f2e..29986d3 100644
--- a/drivers/net/ethernet/sfc/filter.c
+++ b/drivers/net/ethernet/sfc/filter.c
@@ -77,13 +77,8 @@ struct efx_farch_filter_table {
 	unsigned	search_depth[EFX_FARCH_FILTER_TYPE_COUNT];
 };
 
-struct efx_filter_state {
-	spinlock_t	lock;
+struct efx_farch_filter_state {
 	struct efx_farch_filter_table table[EFX_FARCH_FILTER_TABLE_COUNT];
-#ifdef CONFIG_RFS_ACCEL
-	u32		*rps_flow_id;
-	unsigned	rps_expire_index;
-#endif
 };
 
 static void
@@ -142,7 +137,7 @@ efx_farch_filter_table_reset_search_depth(struct efx_farch_filter_table *table)
 
 static void efx_farch_filter_push_rx_config(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table;
 	efx_oword_t filter_ctl;
 
@@ -216,7 +211,7 @@ static void efx_farch_filter_push_rx_config(struct efx_nic *efx)
 
 static void efx_farch_filter_push_tx_limits(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table;
 	efx_oword_t tx_cfg;
 
@@ -427,7 +422,7 @@ efx_farch_filter_to_gen_spec(struct efx_filter_spec *gen_spec,
 static void
 efx_farch_filter_reset_rx_def(struct efx_nic *efx, unsigned filter_idx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table =
 		&state->table[EFX_FARCH_FILTER_TABLE_RX_DEF];
 	struct efx_farch_filter_spec *spec = &table->spec[filter_idx];
@@ -585,7 +580,7 @@ static inline unsigned int efx_farch_filter_id_index(u32 id)
 
 u32 efx_filter_get_rx_id_limit(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	unsigned int range = EFX_FARCH_FILTER_MATCH_PRI_COUNT - 1;
 	enum efx_farch_filter_table_id table_id;
 
@@ -621,7 +616,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx,
 			     struct efx_filter_spec *gen_spec,
 			     bool replace_equal)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table;
 	struct efx_farch_filter_spec spec;
 	efx_oword_t filter;
@@ -649,7 +644,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx,
 		rep_index = spec.type - EFX_FARCH_FILTER_UC_DEF;
 		ins_index = rep_index;
 
-		spin_lock_bh(&state->lock);
+		spin_lock_bh(&efx->filter_lock);
 	} else {
 		/* Search concurrently for
 		 * (1) a filter to be replaced (rep_index): any filter
@@ -679,7 +674,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx,
 		ins_index = -1;
 		depth = 1;
 
-		spin_lock_bh(&state->lock);
+		spin_lock_bh(&efx->filter_lock);
 
 		for (;;) {
 			if (!test_bit(i, table->used_bitmap)) {
@@ -762,7 +757,7 @@ s32 efx_filter_insert_filter(struct efx_nic *efx,
 	rc = efx_farch_filter_make_id(&spec, ins_index);
 
 out:
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 	return rc;
 }
 
@@ -800,7 +795,7 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 			      enum efx_filter_priority priority,
 			      u32 filter_id)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	unsigned int filter_idx;
@@ -817,7 +812,7 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 		return -ENOENT;
 	spec = &table->spec[filter_idx];
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&
 	    spec->priority == priority) {
@@ -829,7 +824,7 @@ int efx_filter_remove_id_safe(struct efx_nic *efx,
 		rc = -ENOENT;
 	}
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 
 	return rc;
 }
@@ -848,7 +843,7 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 			       enum efx_filter_priority priority,
 			       u32 filter_id, struct efx_filter_spec *spec_buf)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	struct efx_farch_filter_spec *spec;
@@ -865,7 +860,7 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 		return -ENOENT;
 	spec = &table->spec[filter_idx];
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	if (test_bit(filter_idx, table->used_bitmap) &&
 	    spec->priority == priority) {
@@ -875,7 +870,7 @@ int efx_filter_get_filter_safe(struct efx_nic *efx,
 		rc = -ENOENT;
 	}
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 
 	return rc;
 }
@@ -885,11 +880,11 @@ efx_farch_filter_table_clear(struct efx_nic *efx,
 			     enum efx_farch_filter_table_id table_id,
 			     enum efx_filter_priority priority)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table = &state->table[table_id];
 	unsigned int filter_idx;
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	for (filter_idx = 0; filter_idx < table->size; ++filter_idx)
 		if (table->spec[filter_idx].priority <= priority)
@@ -898,7 +893,7 @@ efx_farch_filter_table_clear(struct efx_nic *efx,
 	if (table->used == 0)
 		efx_farch_filter_table_reset_search_depth(table);
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 }
 
 /**
@@ -917,13 +912,13 @@ void efx_filter_clear_rx(struct efx_nic *efx, enum efx_filter_priority priority)
 u32 efx_filter_count_rx_used(struct efx_nic *efx,
 			     enum efx_filter_priority priority)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	unsigned int filter_idx;
 	u32 count = 0;
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	for (table_id = EFX_FARCH_FILTER_TABLE_RX_IP;
 	     table_id <= EFX_FARCH_FILTER_TABLE_RX_DEF;
@@ -936,7 +931,7 @@ u32 efx_filter_count_rx_used(struct efx_nic *efx,
 		}
 	}
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 
 	return count;
 }
@@ -945,13 +940,13 @@ s32 efx_filter_get_rx_ids(struct efx_nic *efx,
 			  enum efx_filter_priority priority,
 			  u32 *buf, u32 size)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	unsigned int filter_idx;
 	s32 count = 0;
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	for (table_id = EFX_FARCH_FILTER_TABLE_RX_IP;
 	     table_id <= EFX_FARCH_FILTER_TABLE_RX_DEF;
@@ -970,7 +965,7 @@ s32 efx_filter_get_rx_ids(struct efx_nic *efx,
 		}
 	}
 out:
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 
 	return count;
 }
@@ -978,13 +973,13 @@ out:
 /* Restore filter stater after reset */
 void efx_restore_filters(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	efx_oword_t filter;
 	unsigned int filter_idx;
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	for (table_id = 0; table_id < EFX_FARCH_FILTER_TABLE_COUNT; table_id++) {
 		table = &state->table[table_id];
@@ -1005,28 +1000,28 @@ void efx_restore_filters(struct efx_nic *efx)
 	efx_farch_filter_push_rx_config(efx);
 	efx_farch_filter_push_tx_limits(efx);
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 }
 
 int efx_probe_filters(struct efx_nic *efx)
 {
-	struct efx_filter_state *state;
+	struct efx_farch_filter_state *state;
 	struct efx_farch_filter_table *table;
 	unsigned table_id;
 
-	state = kzalloc(sizeof(*efx->filter_state), GFP_KERNEL);
+	state = kzalloc(sizeof(struct efx_farch_filter_state), GFP_KERNEL);
 	if (!state)
 		return -ENOMEM;
 	efx->filter_state = state;
 
-	spin_lock_init(&state->lock);
+	spin_lock_init(&efx->filter_lock);
 
 	if (efx_nic_rev(efx) >= EFX_REV_FALCON_B0) {
 #ifdef CONFIG_RFS_ACCEL
-		state->rps_flow_id = kcalloc(FR_BZ_RX_FILTER_TBL0_ROWS,
-					     sizeof(*state->rps_flow_id),
-					     GFP_KERNEL);
-		if (!state->rps_flow_id)
+		efx->rps_flow_id = kcalloc(FR_BZ_RX_FILTER_TBL0_ROWS,
+					   sizeof(*efx->rps_flow_id),
+					   GFP_KERNEL);
+		if (!efx->rps_flow_id)
 			goto fail;
 #endif
 		table = &state->table[EFX_FARCH_FILTER_TABLE_RX_IP];
@@ -1086,7 +1081,7 @@ fail:
 
 void efx_remove_filters(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 
 	for (table_id = 0; table_id < EFX_FARCH_FILTER_TABLE_COUNT; table_id++) {
@@ -1094,7 +1089,7 @@ void efx_remove_filters(struct efx_nic *efx)
 		vfree(state->table[table_id].spec);
 	}
 #ifdef CONFIG_RFS_ACCEL
-	kfree(state->rps_flow_id);
+	kfree(efx->rps_flow_id);
 #endif
 	kfree(state);
 }
@@ -1102,13 +1097,13 @@ void efx_remove_filters(struct efx_nic *efx)
 /* Update scatter enable flags for filters pointing to our own RX queues */
 void efx_filter_update_rx_scatter(struct efx_nic *efx)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	enum efx_farch_filter_table_id table_id;
 	struct efx_farch_filter_table *table;
 	efx_oword_t filter;
 	unsigned int filter_idx;
 
-	spin_lock_bh(&state->lock);
+	spin_lock_bh(&efx->filter_lock);
 
 	for (table_id = EFX_FARCH_FILTER_TABLE_RX_IP;
 	     table_id <= EFX_FARCH_FILTER_TABLE_RX_DEF;
@@ -1140,7 +1135,7 @@ void efx_filter_update_rx_scatter(struct efx_nic *efx)
 
 	efx_farch_filter_push_rx_config(efx);
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 }
 
 #ifdef CONFIG_RFS_ACCEL
@@ -1150,7 +1145,6 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
-	struct efx_filter_state *state = efx->filter_state;
 	struct efx_filter_spec spec;
 	const struct iphdr *ip;
 	const __be16 *ports;
@@ -1196,7 +1190,7 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 		return rc;
 
 	/* Remember this so we can check whether to expire the filter later */
-	state->rps_flow_id[rc] = flow_id;
+	efx->rps_flow_id[rc] = flow_id;
 	channel = efx_get_channel(efx, skb_get_rx_queue(skb));
 	++channel->rfs_filters_added;
 
@@ -1211,17 +1205,17 @@ int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
 
 bool __efx_filter_rfs_expire(struct efx_nic *efx, unsigned quota)
 {
-	struct efx_filter_state *state = efx->filter_state;
+	struct efx_farch_filter_state *state = efx->filter_state;
 	struct efx_farch_filter_table *table =
 		&state->table[EFX_FARCH_FILTER_TABLE_RX_IP];
 	unsigned mask = table->size - 1;
 	unsigned index;
 	unsigned stop;
 
-	if (!spin_trylock_bh(&state->lock))
+	if (!spin_trylock_bh(&efx->filter_lock))
 		return false;
 
-	index = state->rps_expire_index;
+	index = efx->rps_expire_index;
 	stop = (index + quota) & mask;
 
 	while (index != stop) {
@@ -1229,20 +1223,20 @@ bool __efx_filter_rfs_expire(struct efx_nic *efx, unsigned quota)
 		    table->spec[index].priority == EFX_FILTER_PRI_HINT &&
 		    rps_may_expire_flow(efx->net_dev,
 					table->spec[index].dmaq_id,
-					state->rps_flow_id[index], index)) {
+					efx->rps_flow_id[index], index)) {
 			netif_info(efx, rx_status, efx->net_dev,
 				   "expiring filter %d [flow %u]\n",
-				   index, state->rps_flow_id[index]);
+				   index, efx->rps_flow_id[index]);
 			efx_farch_filter_table_clear_entry(efx, table, index);
 		}
 		index = (index + 1) & mask;
 	}
 
-	state->rps_expire_index = stop;
+	efx->rps_expire_index = stop;
 	if (table->used == 0)
 		efx_farch_filter_table_reset_search_depth(table);
 
-	spin_unlock_bh(&state->lock);
+	spin_unlock_bh(&efx->filter_lock);
 	return true;
 }
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 694c572..5287a3c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -676,7 +676,6 @@ union efx_multicast_hash {
 	efx_oword_t oword[EFX_MCAST_HASH_ENTRIES / sizeof(efx_oword_t) / 8];
 };
 
-struct efx_filter_state;
 struct efx_vf;
 struct vfdi_status;
 
@@ -763,6 +762,11 @@ struct vfdi_status;
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state
+ * @filter_lock: Filter table lock
+ * @filter_state: Architecture-dependent filter table state
+ * @rps_flow_id: Flow IDs of filters allocated for accelerated RFS,
+ *	indexed by filter ID
+ * @rps_expire_index: Next index to check for expiry in @rps_flow_id
  * @drain_pending: Count of RX and TX queues that haven't been flushed and drained.
  * @rxq_flush_pending: Count of number of receive queues that need to be flushed.
  *	Decremented when the efx_flush_rx_queue() is called.
@@ -898,7 +902,12 @@ struct efx_nic {
 
 	void *loopback_selftest;
 
-	struct efx_filter_state *filter_state;
+	spinlock_t filter_lock;
+	void *filter_state;
+#ifdef CONFIG_RFS_ACCEL
+	u32 *rps_flow_id;
+	unsigned int rps_expire_index;
+#endif
 
 	atomic_t drain_pending;
 	atomic_t rxq_flush_pending;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
