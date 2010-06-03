From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-06-03
Date: Thu, 3 Jun 2010 13:38:43 -0400
Message-ID: <20100603173843.GB14597@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

This is a handful of fixes intended for 2.6.35.  The ath5k patch fixes a
problem reported by multiple people as "Commit 6b5d11 breaks association
with WPA enabled APs".  The ones from Johannes fix a locking problem and
and a problem caused by reading the wrong data location.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a1868dc2878e61778b9d6d8c61d5368e51d68a29:
  Jeff Kirsher (1):
        ixgbe: return IXGBE_ERR_RAR_INDEX when out of range

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bruno Randolf (1):
      ath5k: wake queues on reset

Johannes Berg (2):
      mac80211: fix blockack-req processing
      mac80211: fix dialog token allocator

 drivers/net/wireless/ath/ath5k/base.c |   17 +++--------------
 net/mac80211/agg-tx.c                 |    6 ++++--
 net/mac80211/rx.c                     |   13 +++++++++++--
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index cc6d41d..2978359 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -222,7 +222,6 @@ static int ath5k_tx(struct ieee80211_hw *hw, struct sk_buff *skb);
 static int ath5k_tx_queue(struct ieee80211_hw *hw, struct sk_buff *skb,
 		struct ath5k_txq *txq);
 static int ath5k_reset(struct ath5k_softc *sc, struct ieee80211_channel *chan);
-static int ath5k_reset_wake(struct ath5k_softc *sc);
 static int ath5k_start(struct ieee80211_hw *hw);
 static void ath5k_stop(struct ieee80211_hw *hw);
 static int ath5k_add_interface(struct ieee80211_hw *hw,
@@ -2770,7 +2769,7 @@ ath5k_tasklet_reset(unsigned long data)
 {
 	struct ath5k_softc *sc = (void *)data;
 
-	ath5k_reset_wake(sc);
+	ath5k_reset(sc, sc->curchan);
 }
 
 /*
@@ -2941,23 +2940,13 @@ ath5k_reset(struct ath5k_softc *sc, struct ieee80211_channel *chan)
 	ath5k_beacon_config(sc);
 	/* intrs are enabled by ath5k_beacon_config */
 
+	ieee80211_wake_queues(sc->hw);
+
 	return 0;
 err:
 	return ret;
 }
 
-static int
-ath5k_reset_wake(struct ath5k_softc *sc)
-{
-	int ret;
-
-	ret = ath5k_reset(sc, sc->curchan);
-	if (!ret)
-		ieee80211_wake_queues(sc->hw);
-
-	return ret;
-}
-
 static int ath5k_start(struct ieee80211_hw *hw)
 {
 	return ath5k_init(hw->priv);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index c163d0a..98258b7 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -332,14 +332,16 @@ int ieee80211_start_tx_ba_session(struct ieee80211_sta *pubsta, u16 tid)
 		IEEE80211_QUEUE_STOP_REASON_AGGREGATION);
 
 	spin_unlock(&local->ampdu_lock);
-	spin_unlock_bh(&sta->lock);
 
-	/* send an addBA request */
+	/* prepare tid data */
 	sta->ampdu_mlme.dialog_token_allocator++;
 	sta->ampdu_mlme.tid_tx[tid]->dialog_token =
 			sta->ampdu_mlme.dialog_token_allocator;
 	sta->ampdu_mlme.tid_tx[tid]->ssn = start_seq_num;
 
+	spin_unlock_bh(&sta->lock);
+
+	/* send AddBA request */
 	ieee80211_send_addba_request(sdata, pubsta->addr, tid,
 			 sta->ampdu_mlme.tid_tx[tid]->dialog_token,
 			 sta->ampdu_mlme.tid_tx[tid]->ssn,
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 6e2a7bc..5e0b654 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1818,17 +1818,26 @@ ieee80211_rx_h_ctrl(struct ieee80211_rx_data *rx, struct sk_buff_head *frames)
 		return RX_CONTINUE;
 
 	if (ieee80211_is_back_req(bar->frame_control)) {
+		struct {
+			__le16 control, start_seq_num;
+		} __packed bar_data;
+
 		if (!rx->sta)
 			return RX_DROP_MONITOR;
+
+		if (skb_copy_bits(skb, offsetof(struct ieee80211_bar, control),
+				  &bar_data, sizeof(bar_data)))
+			return RX_DROP_MONITOR;
+
 		spin_lock(&rx->sta->lock);
-		tid = le16_to_cpu(bar->control) >> 12;
+		tid = le16_to_cpu(bar_data.control) >> 12;
 		if (!rx->sta->ampdu_mlme.tid_active_rx[tid]) {
 			spin_unlock(&rx->sta->lock);
 			return RX_DROP_MONITOR;
 		}
 		tid_agg_rx = rx->sta->ampdu_mlme.tid_rx[tid];
 
-		start_seq_num = le16_to_cpu(bar->start_seq_num) >> 4;
+		start_seq_num = le16_to_cpu(bar_data.start_seq_num) >> 4;
 
 		/* reset session timer */
 		if (tid_agg_rx->timeout)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
