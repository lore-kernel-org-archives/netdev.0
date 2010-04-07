From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-04-07
Date: Wed, 7 Apr 2010 14:28:32 -0400
Message-ID: <20100407182832.GA2995@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a batch of fixes intended for 2.6.34.  Included is a variable
initialization required for some ath9k hardware to function reliably,
some RCU annotation to avoid some warnings in mac80211, and a fix for
a regression relating to 802.11s mesh networking.  Also included are
several iwlwifi fixes, include the elimination of an order-4 allocation
during resume, avoidance of a the BUG_ON in the rate scaling routines,
and the elimination of a DMA API warning during module removal.
The iwlwifi patches are a little larger than I would like, but the
fixes seem legitimate and worthwhile to me.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fb9e2d887243499b8d28efcf80821c4f6a092395:
  Ken Kawasaki (1):
        smc91c92_cs: fix the problem of "Unable to find hardware address"

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Felix Fietkau (1):
      ath9k: fix double calls to ath_radio_enable

Javier Cardona (1):
      mac80211: Handle mesh action frames in ieee80211_rx_h_action

Johannes Berg (1):
      mac80211: annotate station rcu dereferences

Shanyu Zhao (1):
      iwlwifi: use consistent table for tx data collect

Zhu Yi (2):
      iwlwifi: fix DMA allocation warnings
      iwlwifi: avoid Tx queue memory allocation in interface down

 drivers/net/wireless/ath/ath9k/main.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |   55 +++++++--------
 drivers/net/wireless/iwlwifi/iwl-core.c   |   11 ++-
 drivers/net/wireless/iwlwifi/iwl-core.h   |    5 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c     |  107 +++++++++++++++++++++++++----
 net/mac80211/main.c                       |    4 +-
 net/mac80211/mesh.c                       |    3 -
 net/mac80211/rx.c                         |    5 ++
 net/mac80211/sta_info.c                   |   20 ++++-
 9 files changed, 153 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 67ca4e5..115e1ae 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1532,8 +1532,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 		all_wiphys_idle =  ath9k_all_wiphys_idle(sc);
 		ath9k_set_wiphy_idle(aphy, idle);
 
-		if (!idle && all_wiphys_idle)
-			enable_radio = true;
+		enable_radio = (!idle && all_wiphys_idle);
 
 		/*
 		 * After we unlock here its possible another wiphy
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 8bf7c20..be00cb3 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -345,6 +345,17 @@ static inline int get_num_of_ant_from_rate(u32 rate_n_flags)
 	       !!(rate_n_flags & RATE_MCS_ANT_C_MSK);
 }
 
+/*
+ * Static function to get the expected throughput from an iwl_scale_tbl_info
+ * that wraps a NULL pointer check
+ */
+static s32 get_expected_tpt(struct iwl_scale_tbl_info *tbl, int rs_index)
+{
+	if (tbl->expected_tpt)
+		return tbl->expected_tpt[rs_index];
+	return 0;
+}
+
 /**
  * rs_collect_tx_data - Update the success/failure sliding window
  *
@@ -352,19 +363,21 @@ static inline int get_num_of_ant_from_rate(u32 rate_n_flags)
  * at this rate.  window->data contains the bitmask of successful
  * packets.
  */
-static int rs_collect_tx_data(struct iwl_rate_scale_data *windows,
-			      int scale_index, s32 tpt, int attempts,
-			      int successes)
+static int rs_collect_tx_data(struct iwl_scale_tbl_info *tbl,
+			      int scale_index, int attempts, int successes)
 {
 	struct iwl_rate_scale_data *window = NULL;
 	static const u64 mask = (((u64)1) << (IWL_RATE_MAX_WINDOW - 1));
-	s32 fail_count;
+	s32 fail_count, tpt;
 
 	if (scale_index < 0 || scale_index >= IWL_RATE_COUNT)
 		return -EINVAL;
 
 	/* Select window for current tx bit rate */
-	window = &(windows[scale_index]);
+	window = &(tbl->win[scale_index]);
+
+	/* Get expected throughput */
+	tpt = get_expected_tpt(tbl, scale_index);
 
 	/*
 	 * Keep track of only the latest 62 tx frame attempts in this rate's
@@ -738,16 +751,6 @@ static bool table_type_matches(struct iwl_scale_tbl_info *a,
 	return (a->lq_type == b->lq_type) && (a->ant_type == b->ant_type) &&
 		(a->is_SGI == b->is_SGI);
 }
-/*
- * Static function to get the expected throughput from an iwl_scale_tbl_info
- * that wraps a NULL pointer check
- */
-static s32 get_expected_tpt(struct iwl_scale_tbl_info *tbl, int rs_index)
-{
-	if (tbl->expected_tpt)
-		return tbl->expected_tpt[rs_index];
-	return 0;
-}
 
 /*
  * mac80211 sends us Tx status
@@ -764,12 +767,10 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 	struct iwl_priv *priv = (struct iwl_priv *)priv_r;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
-	struct iwl_rate_scale_data *window = NULL;
 	enum mac80211_rate_control_flags mac_flags;
 	u32 tx_rate;
 	struct iwl_scale_tbl_info tbl_type;
-	struct iwl_scale_tbl_info *curr_tbl, *other_tbl;
-	s32 tpt = 0;
+	struct iwl_scale_tbl_info *curr_tbl, *other_tbl, *tmp_tbl;
 
 	IWL_DEBUG_RATE_LIMIT(priv, "get frame ack response, update rate scale window\n");
 
@@ -852,7 +853,6 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 		IWL_DEBUG_RATE(priv, "Neither active nor search matches tx rate\n");
 		return;
 	}
-	window = (struct iwl_rate_scale_data *)&(curr_tbl->win[0]);
 
 	/*
 	 * Updating the frame history depends on whether packets were
@@ -865,8 +865,7 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 		tx_rate = le32_to_cpu(table->rs_table[0].rate_n_flags);
 		rs_get_tbl_info_from_mcs(tx_rate, priv->band, &tbl_type,
 				&rs_index);
-		tpt = get_expected_tpt(curr_tbl, rs_index);
-		rs_collect_tx_data(window, rs_index, tpt,
+		rs_collect_tx_data(curr_tbl, rs_index,
 				   info->status.ampdu_ack_len,
 				   info->status.ampdu_ack_map);
 
@@ -896,19 +895,13 @@ static void rs_tx_status(void *priv_r, struct ieee80211_supported_band *sband,
 			 * table as active/search.
 			 */
 			if (table_type_matches(&tbl_type, curr_tbl))
-				tpt = get_expected_tpt(curr_tbl, rs_index);
+				tmp_tbl = curr_tbl;
 			else if (table_type_matches(&tbl_type, other_tbl))
-				tpt = get_expected_tpt(other_tbl, rs_index);
+				tmp_tbl = other_tbl;
 			else
 				continue;
-
-			/* Constants mean 1 transmission, 0 successes */
-			if (i < retries)
-				rs_collect_tx_data(window, rs_index, tpt, 1,
-						0);
-			else
-				rs_collect_tx_data(window, rs_index, tpt, 1,
-						legacy_success);
+			rs_collect_tx_data(tmp_tbl, rs_index, 1,
+					   i < retries ? 0 : legacy_success);
 		}
 
 		/* Update success/fail counts if not searching for new mode */
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 112149e..894bcb8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -307,10 +307,13 @@ int iwl_hw_nic_init(struct iwl_priv *priv)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	/* Allocate and init all Tx and Command queues */
-	ret = iwl_txq_ctx_reset(priv);
-	if (ret)
-		return ret;
+	/* Allocate or reset and init all Tx and Command queues */
+	if (!priv->txq) {
+		ret = iwl_txq_ctx_alloc(priv);
+		if (ret)
+			return ret;
+	} else
+		iwl_txq_ctx_reset(priv);
 
 	set_bit(STATUS_INIT, &priv->status);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 4ef7739..732590f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -442,7 +442,8 @@ void iwl_rx_csa(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb);
 /*****************************************************
 * TX
 ******************************************************/
-int iwl_txq_ctx_reset(struct iwl_priv *priv);
+int iwl_txq_ctx_alloc(struct iwl_priv *priv);
+void iwl_txq_ctx_reset(struct iwl_priv *priv);
 void iwl_hw_txq_free_tfd(struct iwl_priv *priv, struct iwl_tx_queue *txq);
 int iwl_hw_txq_attach_buf_to_tfd(struct iwl_priv *priv,
 				 struct iwl_tx_queue *txq,
@@ -456,6 +457,8 @@ void iwl_free_tfds_in_queue(struct iwl_priv *priv,
 void iwl_txq_update_write_ptr(struct iwl_priv *priv, struct iwl_tx_queue *txq);
 int iwl_tx_queue_init(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 		      int slots_num, u32 txq_id);
+void iwl_tx_queue_reset(struct iwl_priv *priv, struct iwl_tx_queue *txq,
+			int slots_num, u32 txq_id);
 void iwl_tx_queue_free(struct iwl_priv *priv, int txq_id);
 int iwl_tx_agg_start(struct iwl_priv *priv, const u8 *ra, u16 tid, u16 *ssn);
 int iwl_tx_agg_stop(struct iwl_priv *priv , const u8 *ra, u16 tid);
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 8c12311..343d81a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -193,10 +193,34 @@ void iwl_cmd_queue_free(struct iwl_priv *priv)
 	struct iwl_queue *q = &txq->q;
 	struct device *dev = &priv->pci_dev->dev;
 	int i;
+	bool huge = false;
 
 	if (q->n_bd == 0)
 		return;
 
+	for (; q->read_ptr != q->write_ptr;
+	     q->read_ptr = iwl_queue_inc_wrap(q->read_ptr, q->n_bd)) {
+		/* we have no way to tell if it is a huge cmd ATM */
+		i = get_cmd_index(q, q->read_ptr, 0);
+
+		if (txq->meta[i].flags & CMD_SIZE_HUGE) {
+			huge = true;
+			continue;
+		}
+
+		pci_unmap_single(priv->pci_dev,
+				 pci_unmap_addr(&txq->meta[i], mapping),
+				 pci_unmap_len(&txq->meta[i], len),
+				 PCI_DMA_BIDIRECTIONAL);
+	}
+	if (huge) {
+		i = q->n_window;
+		pci_unmap_single(priv->pci_dev,
+				 pci_unmap_addr(&txq->meta[i], mapping),
+				 pci_unmap_len(&txq->meta[i], len),
+				 PCI_DMA_BIDIRECTIONAL);
+	}
+
 	/* De-alloc array of command/tx buffers */
 	for (i = 0; i <= TFD_CMD_SLOTS; i++)
 		kfree(txq->cmd[i]);
@@ -409,6 +433,26 @@ out_free_arrays:
 }
 EXPORT_SYMBOL(iwl_tx_queue_init);
 
+void iwl_tx_queue_reset(struct iwl_priv *priv, struct iwl_tx_queue *txq,
+			int slots_num, u32 txq_id)
+{
+	int actual_slots = slots_num;
+
+	if (txq_id == IWL_CMD_QUEUE_NUM)
+		actual_slots++;
+
+	memset(txq->meta, 0, sizeof(struct iwl_cmd_meta) * actual_slots);
+
+	txq->need_update = 0;
+
+	/* Initialize queue's high/low-water marks, and head/tail indexes */
+	iwl_queue_init(priv, &txq->q, TFD_QUEUE_SIZE_MAX, slots_num, txq_id);
+
+	/* Tell device where to find queue */
+	priv->cfg->ops->lib->txq_init(priv, txq);
+}
+EXPORT_SYMBOL(iwl_tx_queue_reset);
+
 /**
  * iwl_hw_txq_ctx_free - Free TXQ Context
  *
@@ -420,8 +464,7 @@ void iwl_hw_txq_ctx_free(struct iwl_priv *priv)
 
 	/* Tx queues */
 	if (priv->txq) {
-		for (txq_id = 0; txq_id < priv->hw_params.max_txq_num;
-		     txq_id++)
+		for (txq_id = 0; txq_id < priv->hw_params.max_txq_num; txq_id++)
 			if (txq_id == IWL_CMD_QUEUE_NUM)
 				iwl_cmd_queue_free(priv);
 			else
@@ -437,15 +480,15 @@ void iwl_hw_txq_ctx_free(struct iwl_priv *priv)
 EXPORT_SYMBOL(iwl_hw_txq_ctx_free);
 
 /**
- * iwl_txq_ctx_reset - Reset TX queue context
- * Destroys all DMA structures and initialize them again
+ * iwl_txq_ctx_alloc - allocate TX queue context
+ * Allocate all Tx DMA structures and initialize them
  *
  * @param priv
  * @return error code
  */
-int iwl_txq_ctx_reset(struct iwl_priv *priv)
+int iwl_txq_ctx_alloc(struct iwl_priv *priv)
 {
-	int ret = 0;
+	int ret;
 	int txq_id, slots_num;
 	unsigned long flags;
 
@@ -503,8 +546,31 @@ int iwl_txq_ctx_reset(struct iwl_priv *priv)
 	return ret;
 }
 
+void iwl_txq_ctx_reset(struct iwl_priv *priv)
+{
+	int txq_id, slots_num;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	/* Turn off all Tx DMA fifos */
+	priv->cfg->ops->lib->txq_set_sched(priv, 0);
+
+	/* Tell NIC where to find the "keep warm" buffer */
+	iwl_write_direct32(priv, FH_KW_MEM_ADDR_REG, priv->kw.dma >> 4);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	/* Alloc and init all Tx queues, including the command queue (#4) */
+	for (txq_id = 0; txq_id < priv->hw_params.max_txq_num; txq_id++) {
+		slots_num = txq_id == IWL_CMD_QUEUE_NUM ?
+			    TFD_CMD_SLOTS : TFD_TX_CMD_SLOTS;
+		iwl_tx_queue_reset(priv, &priv->txq[txq_id], slots_num, txq_id);
+	}
+}
+
 /**
- * iwl_txq_ctx_stop - Stop all Tx DMA channels, free Tx queue memory
+ * iwl_txq_ctx_stop - Stop all Tx DMA channels
  */
 void iwl_txq_ctx_stop(struct iwl_priv *priv)
 {
@@ -524,9 +590,6 @@ void iwl_txq_ctx_stop(struct iwl_priv *priv)
 				    1000);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
-
-	/* Deallocate memory for all Tx queues */
-	iwl_hw_txq_ctx_free(priv);
 }
 EXPORT_SYMBOL(iwl_txq_ctx_stop);
 
@@ -1049,6 +1112,14 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 
 	spin_lock_irqsave(&priv->hcmd_lock, flags);
 
+	/* If this is a huge cmd, mark the huge flag also on the meta.flags
+	 * of the _original_ cmd. This is used for DMA mapping clean up.
+	 */
+	if (cmd->flags & CMD_SIZE_HUGE) {
+		idx = get_cmd_index(q, q->write_ptr, 0);
+		txq->meta[idx].flags = CMD_SIZE_HUGE;
+	}
+
 	idx = get_cmd_index(q, q->write_ptr, cmd->flags & CMD_SIZE_HUGE);
 	out_cmd = txq->cmd[idx];
 	out_meta = &txq->meta[idx];
@@ -1226,6 +1297,7 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	bool huge = !!(pkt->hdr.sequence & SEQ_HUGE_FRAME);
 	struct iwl_device_cmd *cmd;
 	struct iwl_cmd_meta *meta;
+	struct iwl_tx_queue *txq = &priv->txq[IWL_CMD_QUEUE_NUM];
 
 	/* If a Tx command is being handled and it isn't in the actual
 	 * command queue then there a command routing bug has been introduced
@@ -1239,9 +1311,17 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 		return;
 	}
 
-	cmd_index = get_cmd_index(&priv->txq[IWL_CMD_QUEUE_NUM].q, index, huge);
-	cmd = priv->txq[IWL_CMD_QUEUE_NUM].cmd[cmd_index];
-	meta = &priv->txq[IWL_CMD_QUEUE_NUM].meta[cmd_index];
+	/* If this is a huge cmd, clear the huge flag on the meta.flags
+	 * of the _original_ cmd. So that iwl_cmd_queue_free won't unmap
+	 * the DMA buffer for the scan (huge) command.
+	 */
+	if (huge) {
+		cmd_index = get_cmd_index(&txq->q, index, 0);
+		txq->meta[cmd_index].flags = 0;
+	}
+	cmd_index = get_cmd_index(&txq->q, index, huge);
+	cmd = txq->cmd[cmd_index];
+	meta = &txq->meta[cmd_index];
 
 	pci_unmap_single(priv->pci_dev,
 			 pci_unmap_addr(meta, mapping),
@@ -1263,6 +1343,7 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 			       get_cmd_string(cmd->hdr.cmd));
 		wake_up_interruptible(&priv->wait_command_queue);
 	}
+	meta->flags = 0;
 }
 EXPORT_SYMBOL(iwl_tx_cmd_complete);
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 06c33b6..b887e48 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -225,11 +225,11 @@ void ieee80211_bss_info_change_notify(struct ieee80211_sub_if_data *sdata,
 			switch (sdata->vif.type) {
 			case NL80211_IFTYPE_AP:
 				sdata->vif.bss_conf.enable_beacon =
-					!!rcu_dereference(sdata->u.ap.beacon);
+					!!sdata->u.ap.beacon;
 				break;
 			case NL80211_IFTYPE_ADHOC:
 				sdata->vif.bss_conf.enable_beacon =
-					!!rcu_dereference(sdata->u.ibss.presp);
+					!!sdata->u.ibss.presp;
 				break;
 			case NL80211_IFTYPE_MESH_POINT:
 				sdata->vif.bss_conf.enable_beacon = true;
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 61080c5..7a6bebc 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -749,9 +749,6 @@ ieee80211_mesh_rx_mgmt(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb)
 
 	switch (fc & IEEE80211_FCTL_STYPE) {
 	case IEEE80211_STYPE_ACTION:
-		if (skb->len < IEEE80211_MIN_ACTION_SIZE)
-			return RX_DROP_MONITOR;
-		/* fall through */
 	case IEEE80211_STYPE_PROBE_RESP:
 	case IEEE80211_STYPE_BEACON:
 		skb_queue_tail(&ifmsh->skb_queue, skb);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index b5c48de..13fcd2d 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1973,6 +1973,11 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 			goto handled;
 		}
 		break;
+	case MESH_PLINK_CATEGORY:
+	case MESH_PATH_SEL_CATEGORY:
+		if (ieee80211_vif_is_mesh(&sdata->vif))
+			return ieee80211_mesh_rx_mgmt(sdata, rx->skb);
+		break;
 	}
 
 	/*
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 56422d8..fb12cec 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -93,12 +93,18 @@ struct sta_info *sta_info_get(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 
-	sta = rcu_dereference(local->sta_hash[STA_HASH(addr)]);
+	sta = rcu_dereference_check(local->sta_hash[STA_HASH(addr)],
+				    rcu_read_lock_held() ||
+				    lockdep_is_held(&local->sta_lock) ||
+				    lockdep_is_held(&local->sta_mtx));
 	while (sta) {
 		if (sta->sdata == sdata &&
 		    memcmp(sta->sta.addr, addr, ETH_ALEN) == 0)
 			break;
-		sta = rcu_dereference(sta->hnext);
+		sta = rcu_dereference_check(sta->hnext,
+					    rcu_read_lock_held() ||
+					    lockdep_is_held(&local->sta_lock) ||
+					    lockdep_is_held(&local->sta_mtx));
 	}
 	return sta;
 }
@@ -113,13 +119,19 @@ struct sta_info *sta_info_get_bss(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 
-	sta = rcu_dereference(local->sta_hash[STA_HASH(addr)]);
+	sta = rcu_dereference_check(local->sta_hash[STA_HASH(addr)],
+				    rcu_read_lock_held() ||
+				    lockdep_is_held(&local->sta_lock) ||
+				    lockdep_is_held(&local->sta_mtx));
 	while (sta) {
 		if ((sta->sdata == sdata ||
 		     sta->sdata->bss == sdata->bss) &&
 		    memcmp(sta->sta.addr, addr, ETH_ALEN) == 0)
 			break;
-		sta = rcu_dereference(sta->hnext);
+		sta = rcu_dereference_check(sta->hnext,
+					    rcu_read_lock_held() ||
+					    lockdep_is_held(&local->sta_lock) ||
+					    lockdep_is_held(&local->sta_mtx));
 	}
 	return sta;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
