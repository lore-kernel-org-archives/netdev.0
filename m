From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-02-08
Date: Tue, 8 Feb 2011 14:55:30 -0500
Message-ID: <20110208195530.GB6244@tuxdriver.com>
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

Here is the latest round of wireless fixes intended for 2.6.38.
Included is a carl9170 fix (described as a typo) for receiving buffered
broadcasts, an iwlagn fix to properly monitor the rfkill switch when
the interface is down, a mac80211 fix to correctly check for cloned
skbs when resizing, a null pointer fix for wl1251 if it fails to get
a beacon, a mac80211 fix related to off-channel tx, an ssb fix for
using the wrong pointer for getting invariance for pcmcia devices,
an ath9k double-free fix, and a one-line iwlagn fix to correctly
describe an antenna configuration.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 429a01a70f301baf0c8fc780f891a18c296d5e24:

  Merge branch 'batman-adv/merge' of git://git.open-mesh.org/ecsv/linux-merge (2011-02-07 19:54:14 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      carl9170: fix typo in PS code

Don Fry (1):
      iwlagn: Re-enable RF_KILL interrupt when down

Felix Fietkau (1):
      mac80211: fix the skb cloned check in the tx path

Jesper Juhl (1):
      wireless, wl1251: Fix potential NULL pointer dereference in wl1251_op_bss_info_changed()

Johannes Berg (1):
      mac80211: fix TX status cookie in HW offload case

Michael Buesch (1):
      ssb-pcmcia: Fix parsing of invariants tuples

Mohammed Shafi Shajakhan (1):
      ath9k: Fix possible double free of PAPRD skb's

Wey-Yi Guy (1):
      iwlagn: overwrite EEPROM chain setting for 6250 devices

 drivers/net/wireless/ath/ath9k/ath9k.h  |    2 +-
 drivers/net/wireless/ath/ath9k/main.c   |    2 --
 drivers/net/wireless/ath/ath9k/xmit.c   |    7 ++++++-
 drivers/net/wireless/ath/carl9170/rx.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c |    2 ++
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    6 ++++++
 drivers/net/wireless/wl1251/main.c      |    3 +++
 drivers/ssb/pcmcia.c                    |    2 +-
 net/mac80211/cfg.c                      |    2 ++
 net/mac80211/ieee80211_i.h              |    2 +-
 net/mac80211/status.c                   |    7 ++++++-
 net/mac80211/tx.c                       |    2 +-
 12 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 3681caf5..23838e3 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -218,6 +218,7 @@ struct ath_frame_info {
 struct ath_buf_state {
 	u8 bf_type;
 	u8 bfs_paprd;
+	unsigned long bfs_paprd_timestamp;
 	enum ath9k_internal_frame_type bfs_ftype;
 };
 
@@ -593,7 +594,6 @@ struct ath_softc {
 	struct work_struct paprd_work;
 	struct work_struct hw_check_work;
 	struct completion paprd_complete;
-	bool paprd_pending;
 
 	u32 intrstatus;
 	u32 sc_flags; /* SC_OP_* */
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 9040c2f..da5c645 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -342,7 +342,6 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 	tx_info->control.rates[1].idx = -1;
 
 	init_completion(&sc->paprd_complete);
-	sc->paprd_pending = true;
 	txctl.paprd = BIT(chain);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
@@ -353,7 +352,6 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 
 	time_left = wait_for_completion_timeout(&sc->paprd_complete,
 			msecs_to_jiffies(ATH_PAPRD_TIMEOUT));
-	sc->paprd_pending = false;
 
 	if (!time_left)
 		ath_dbg(ath9k_hw_common(sc->sc_ah), ATH_DBG_CALIBRATE,
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 33a37ed..07b7804 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1725,6 +1725,9 @@ static void ath_tx_start_dma(struct ath_softc *sc, struct ath_buf *bf,
 			ar9003_hw_set_paprd_txdesc(sc->sc_ah, bf->bf_desc,
 						   bf->bf_state.bfs_paprd);
 
+		if (txctl->paprd)
+			bf->bf_state.bfs_paprd_timestamp = jiffies;
+
 		ath_tx_send_normal(sc, txctl->txq, tid, &bf_head);
 	}
 
@@ -1886,7 +1889,9 @@ static void ath_tx_complete_buf(struct ath_softc *sc, struct ath_buf *bf,
 	bf->bf_buf_addr = 0;
 
 	if (bf->bf_state.bfs_paprd) {
-		if (!sc->paprd_pending)
+		if (time_after(jiffies,
+				bf->bf_state.bfs_paprd_timestamp +
+				msecs_to_jiffies(ATH_PAPRD_TIMEOUT)))
 			dev_kfree_skb_any(skb);
 		else
 			complete(&sc->paprd_complete);
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index 939a0e9..84866a4 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -564,7 +564,7 @@ static void carl9170_ps_beacon(struct ar9170 *ar, void *data, unsigned int len)
 	cam = ieee80211_check_tim(tim_ie, tim_len, ar->common.curaid);
 
 	/* 2. Maybe the AP wants to send multicast/broadcast data? */
-	cam = !!(tim_ie->bitmap_ctrl & 0x01);
+	cam |= !!(tim_ie->bitmap_ctrl & 0x01);
 
 	if (!cam) {
 		/* back to low-power land. */
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index af505bc..ef36aff 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -681,6 +681,8 @@ struct iwl_cfg iwl6000i_2bg_cfg = {
 	.fw_name_pre = IWL6050_FW_PRE,				\
 	.ucode_api_max = IWL6050_UCODE_API_MAX,			\
 	.ucode_api_min = IWL6050_UCODE_API_MIN,			\
+	.valid_tx_ant = ANT_AB,		/* .cfg overwrite */	\
+	.valid_rx_ant = ANT_AB,		/* .cfg overwrite */	\
 	.ops = &iwl6050_ops,					\
 	.eeprom_ver = EEPROM_6050_EEPROM_VERSION,		\
 	.eeprom_calib_ver = EEPROM_6050_TX_POWER_VERSION,	\
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index f13a83a..a236b8b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1157,6 +1157,9 @@ static void iwl_irq_tasklet_legacy(struct iwl_priv *priv)
 	/* only Re-enable if diabled by irq */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status))
 		iwl_enable_interrupts(priv);
+	/* Re-enable RF_KILL if it occurred */
+	else if (handled & CSR_INT_BIT_RF_KILL)
+		iwl_enable_rfkill_int(priv);
 
 #ifdef CONFIG_IWLWIFI_DEBUG
 	if (iwl_get_debug_level(priv) & (IWL_DL_ISR)) {
@@ -1371,6 +1374,9 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 	/* only Re-enable if diabled by irq */
 	if (test_bit(STATUS_INT_ENABLED, &priv->status))
 		iwl_enable_interrupts(priv);
+	/* Re-enable RF_KILL if it occurred */
+	else if (handled & CSR_INT_BIT_RF_KILL)
+		iwl_enable_rfkill_int(priv);
 }
 
 /* the threshold ratio of actual_ack_cnt to expected_ack_cnt in percent */
diff --git a/drivers/net/wireless/wl1251/main.c b/drivers/net/wireless/wl1251/main.c
index 012e1a4..40372ba 100644
--- a/drivers/net/wireless/wl1251/main.c
+++ b/drivers/net/wireless/wl1251/main.c
@@ -1039,6 +1039,9 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 
 	if (changed & BSS_CHANGED_BEACON) {
 		beacon = ieee80211_beacon_get(hw, vif);
+		if (!beacon)
+			goto out_sleep;
+
 		ret = wl1251_cmd_template_set(wl, CMD_BEACON, beacon->data,
 					      beacon->len);
 
diff --git a/drivers/ssb/pcmcia.c b/drivers/ssb/pcmcia.c
index c7345db..f853379 100644
--- a/drivers/ssb/pcmcia.c
+++ b/drivers/ssb/pcmcia.c
@@ -733,7 +733,7 @@ int ssb_pcmcia_get_invariants(struct ssb_bus *bus,
 
 	/* Fetch the vendor specific tuples. */
 	res = pcmcia_loop_tuple(bus->host_pcmcia, SSB_PCMCIA_CIS,
-				ssb_pcmcia_do_get_invariants, sprom);
+				ssb_pcmcia_do_get_invariants, iv);
 	if ((res == 0) || (res == -ENOSPC))
 		return 0;
 
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 4bc8a92..9cd73b1 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1822,6 +1822,7 @@ static int ieee80211_mgmt_tx(struct wiphy *wiphy, struct net_device *dev,
 		*cookie ^= 2;
 		IEEE80211_SKB_CB(skb)->flags |= IEEE80211_TX_CTL_TX_OFFCHAN;
 		local->hw_roc_skb = skb;
+		local->hw_roc_skb_for_status = skb;
 		mutex_unlock(&local->mtx);
 
 		return 0;
@@ -1875,6 +1876,7 @@ static int ieee80211_mgmt_tx_cancel_wait(struct wiphy *wiphy,
 		if (ret == 0) {
 			kfree_skb(local->hw_roc_skb);
 			local->hw_roc_skb = NULL;
+			local->hw_roc_skb_for_status = NULL;
 		}
 
 		mutex_unlock(&local->mtx);
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index c47d7c0..533fd32 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -953,7 +953,7 @@ struct ieee80211_local {
 
 	struct ieee80211_channel *hw_roc_channel;
 	struct net_device *hw_roc_dev;
-	struct sk_buff *hw_roc_skb;
+	struct sk_buff *hw_roc_skb, *hw_roc_skb_for_status;
 	struct work_struct hw_roc_start, hw_roc_done;
 	enum nl80211_channel_type hw_roc_channel_type;
 	unsigned int hw_roc_duration;
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 38a7972..071ac95 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -323,6 +323,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 
 	if (info->flags & IEEE80211_TX_INTFL_NL80211_FRAME_TX) {
 		struct ieee80211_work *wk;
+		u64 cookie = (unsigned long)skb;
 
 		rcu_read_lock();
 		list_for_each_entry_rcu(wk, &local->work_list, list) {
@@ -334,8 +335,12 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 			break;
 		}
 		rcu_read_unlock();
+		if (local->hw_roc_skb_for_status == skb) {
+			cookie = local->hw_roc_cookie ^ 2;
+			local->hw_roc_skb_for_status = NULL;
+		}
 		cfg80211_mgmt_tx_status(
-			skb->dev, (unsigned long) skb, skb->data, skb->len,
+			skb->dev, cookie, skb->data, skb->len,
 			!!(info->flags & IEEE80211_TX_STAT_ACK), GFP_ATOMIC);
 	}
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index b64b42b..b0beaa5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1547,7 +1547,7 @@ static int ieee80211_skb_resize(struct ieee80211_local *local,
 		skb_orphan(skb);
 	}
 
-	if (skb_header_cloned(skb))
+	if (skb_cloned(skb))
 		I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
 	else if (head_need || tail_need)
 		I802_DEBUG_INC(local->tx_expand_skb_head);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
