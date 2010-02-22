From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-02-22
Date: Mon, 22 Feb 2010 13:26:53 -0500
Message-ID: <20100222182653.GB2988@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

I have a handful of late-breakers for iwlwifi.  The one from Dan
Halperin moves a single line of code and is a fix for an 802.11n
regression introduced in the 2.6.33 cycle.  The other two combine
to address a problem that causes the wireless LAN connection to
die without any error message.  It has been developed and tested in
combination between the Intel wireless team and a contributor from
Red Hat.  I hope you will consider including these for 2.6.33 if at
all possible.

Please let me know if there are problems!

Thanks,

John

P.S.  The wireless-2.6 tree should be safe/clean for Linus to pull if
time is too short for a round-trip through net-2.6... :-)

---

The following changes since commit 242cc0547f3bcecc0b02ca6f3e9512760185727e:
  Ben Hutchings (1):
        sfc: SFE4002/SFN4112F: Widen temperature and voltage tolerances

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Dan Halperin (1):
      iwlwifi: set HT flags after channel in rxon

Stanislaw Gruszka (1):
      iwlwifi: sanity check before counting number of tfds can be free

Wey-Yi Guy (1):
      iwlwifi: error checking for number of tfds in queue

 drivers/net/wireless/iwlwifi/iwl-4965.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c |    8 +++-----
 drivers/net/wireless/iwlwifi/iwl-core.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h |    2 ++
 drivers/net/wireless/iwlwifi/iwl-tx.c   |   22 ++++++++++++++++++++--
 5 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 9b4b8b5..3146281 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -2008,7 +2008,7 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 			IWL_DEBUG_TX_REPLY(priv, "Retry scheduler reclaim scd_ssn "
 					   "%d index %d\n", scd_ssn , index);
 			freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 			if (priv->mac80211_registered &&
 			    (iwl_queue_space(&txq->q) > txq->q.low_mark) &&
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index de45f30..cffaae7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -1125,7 +1125,7 @@ static void iwl5000_rx_reply_tx(struct iwl_priv *priv,
 					scd_ssn , index, txq_id, txq->swq_id);
 
 			freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+			iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 			if (priv->mac80211_registered &&
 			    (iwl_queue_space(&txq->q) > txq->q.low_mark) &&
@@ -1153,16 +1153,14 @@ static void iwl5000_rx_reply_tx(struct iwl_priv *priv,
 				   tx_resp->failure_frame);
 
 		freed = iwl_tx_queue_reclaim(priv, txq_id, index);
-		if (ieee80211_is_data_qos(tx_resp->frame_ctrl))
-			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 		if (priv->mac80211_registered &&
 		    (iwl_queue_space(&txq->q) > txq->q.low_mark))
 			iwl_wake_queue(priv, txq_id);
 	}
 
-	if (ieee80211_is_data_qos(tx_resp->frame_ctrl))
-		iwl_txq_check_empty(priv, sta_id, tid, txq_id);
+	iwl_txq_check_empty(priv, sta_id, tid, txq_id);
 
 	if (iwl_check_bits(status, TX_ABORT_REQUIRED_MSK))
 		IWL_ERR(priv, "TODO:  Implement Tx ABORT REQUIRED!!!\n");
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index d10bea6..f36f804 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2744,8 +2744,8 @@ int iwl_mac_config(struct ieee80211_hw *hw, u32 changed)
 		if ((le16_to_cpu(priv->staging_rxon.channel) != ch))
 			priv->staging_rxon.flags = 0;
 
-		iwl_set_rxon_ht(priv, ht_conf);
 		iwl_set_rxon_channel(priv, conf->channel);
+		iwl_set_rxon_ht(priv, ht_conf);
 
 		iwl_set_flags_for_band(priv, conf->channel->band);
 		spin_unlock_irqrestore(&priv->lock, flags);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 675b7df..fe37d6a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -446,6 +446,8 @@ void iwl_hw_txq_ctx_free(struct iwl_priv *priv);
 int iwl_hw_tx_queue_init(struct iwl_priv *priv,
 			 struct iwl_tx_queue *txq);
 int iwl_txq_update_write_ptr(struct iwl_priv *priv, struct iwl_tx_queue *txq);
+void iwl_free_tfds_in_queue(struct iwl_priv *priv,
+			    int sta_id, int tid, int freed);
 int iwl_tx_queue_init(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 		      int slots_num, u32 txq_id);
 void iwl_tx_queue_free(struct iwl_priv *priv, int txq_id);
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 87ce2bd..8f40715 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -120,6 +120,20 @@ int iwl_txq_update_write_ptr(struct iwl_priv *priv, struct iwl_tx_queue *txq)
 EXPORT_SYMBOL(iwl_txq_update_write_ptr);
 
 
+void iwl_free_tfds_in_queue(struct iwl_priv *priv,
+			    int sta_id, int tid, int freed)
+{
+	if (priv->stations[sta_id].tid[tid].tfds_in_queue >= freed)
+		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+	else {
+		IWL_ERR(priv, "free more than tfds_in_queue (%u:%d)\n",
+			priv->stations[sta_id].tid[tid].tfds_in_queue,
+			freed);
+		priv->stations[sta_id].tid[tid].tfds_in_queue = 0;
+	}
+}
+EXPORT_SYMBOL(iwl_free_tfds_in_queue);
+
 /**
  * iwl_tx_queue_free - Deallocate DMA queue.
  * @txq: Transmit queue to deallocate.
@@ -1131,6 +1145,7 @@ int iwl_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 	struct iwl_queue *q = &txq->q;
 	struct iwl_tx_info *tx_info;
 	int nfreed = 0;
+	struct ieee80211_hdr *hdr;
 
 	if ((index >= q->n_bd) || (iwl_queue_used(q, index) == 0)) {
 		IWL_ERR(priv, "Read index for DMA queue txq id (%d), index %d, "
@@ -1145,13 +1160,16 @@ int iwl_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 
 		tx_info = &txq->txb[txq->q.read_ptr];
 		iwl_tx_status(priv, tx_info->skb[0]);
+
+		hdr = (struct ieee80211_hdr *)tx_info->skb[0]->data;
+		if (hdr && ieee80211_is_data_qos(hdr->frame_control))
+			nfreed++;
 		tx_info->skb[0] = NULL;
 
 		if (priv->cfg->ops->lib->txq_inval_byte_cnt_tbl)
 			priv->cfg->ops->lib->txq_inval_byte_cnt_tbl(priv, txq);
 
 		priv->cfg->ops->lib->txq_free_tfd(priv, txq);
-		nfreed++;
 	}
 	return nfreed;
 }
@@ -1559,7 +1577,7 @@ void iwl_rx_reply_compressed_ba(struct iwl_priv *priv,
 	if (txq->q.read_ptr != (ba_resp_scd_ssn & 0xff)) {
 		/* calculate mac80211 ampdu sw queue to wake */
 		int freed = iwl_tx_queue_reclaim(priv, scd_flow, index);
-		priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
+		iwl_free_tfds_in_queue(priv, sta_id, tid, freed);
 
 		if ((iwl_queue_space(&txq->q) > txq->q.low_mark) &&
 		    priv->mac80211_registered &&
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
