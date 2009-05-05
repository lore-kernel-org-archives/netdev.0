From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-05-05
Date: Tue, 5 May 2009 14:10:09 -0400
Message-ID: <20090505181009.GA2788@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41641 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbZEESQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 14:16:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Yet another round of fixes intended for 2.6.30...

Included is the removal of another unnecessary EXPORT_SYMBOL that seems
to be irritating some versions of GCC, the correction of a WARN_ON check
that generates spurious log noise, a fix for a missing length value that
leads to bad data being passed to userland, the correction of a WARN in
iwl_set_tkip_dynamic_key_info, fixes for a couple of cfg80211 Oopsen, a
one-line comment correction in cfg80211, and a couple of memory
corruption fixes related to mac80211 rate control algorithms.  One of
these last two looks a little big, but it is mostly moving a hunk of
code around.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 379b026ecc20c4657d37e40ead789f7f28f1a1c1:
  Lubomir Rintel (1):
        ne2k-pci: Do not register device until initialized.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andreas Schwab (1):
      iwlwifi: remove EXPORT_SYMBOL for static symbol

Jiri Slaby (2):
      mac80211: minstrel, fix memory corruption
      mac80211: pid, fix memory corruption

Johannes Berg (2):
      mac80211: correct fragmentation threshold check
      cfg80211: fix truncated IEs

Luis R. Rodriguez (3):
      cfg80211: fix race condition with wiphy_apply_custom_regulatory()
      cfg80211: fix bug while trying to process beacon hints on init
      cfg80211: fix comment on regulatory hint processing

Reinette Chatre (1):
      iwlwifi: update key flags at time key is set

 drivers/net/wireless/iwlwifi/iwl-sta.c      |   21 ++++----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
 net/mac80211/rc80211_minstrel.c             |    2 +-
 net/mac80211/rc80211_pid_algo.c             |   73 ++++++++++++++------------
 net/mac80211/tx.c                           |    2 +-
 net/wireless/reg.c                          |   17 ++++++-
 net/wireless/scan.c                         |    1 +
 7 files changed, 68 insertions(+), 49 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index 5798fe4..44ab03a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -719,6 +719,14 @@ static int iwl_set_tkip_dynamic_key_info(struct iwl_priv *priv,
 {
 	unsigned long flags;
 	int ret = 0;
+	__le16 key_flags = 0;
+
+	key_flags |= (STA_KEY_FLG_TKIP | STA_KEY_FLG_MAP_KEY_MSK);
+	key_flags |= cpu_to_le16(keyconf->keyidx << STA_KEY_FLG_KEYID_POS);
+	key_flags &= ~STA_KEY_FLG_INVALID;
+
+	if (sta_id == priv->hw_params.bcast_sta_id)
+		key_flags |= STA_KEY_MULTICAST_MSK;
 
 	keyconf->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
 	keyconf->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
@@ -738,6 +746,9 @@ static int iwl_set_tkip_dynamic_key_info(struct iwl_priv *priv,
 	WARN(priv->stations[sta_id].sta.key.key_offset == WEP_INVALID_OFFSET,
 		"no space for a new key");
 
+	priv->stations[sta_id].sta.key.key_flags = key_flags;
+
+
 	/* This copy is acutally not needed: we get the key with each TX */
 	memcpy(priv->stations[sta_id].keyinfo.key, keyconf->key, 16);
 
@@ -754,9 +765,7 @@ void iwl_update_tkip_key(struct iwl_priv *priv,
 {
 	u8 sta_id = IWL_INVALID_STATION;
 	unsigned long flags;
-	__le16 key_flags = 0;
 	int i;
-	DECLARE_MAC_BUF(mac);
 
 	sta_id = iwl_find_station(priv, addr);
 	if (sta_id == IWL_INVALID_STATION) {
@@ -771,16 +780,8 @@ void iwl_update_tkip_key(struct iwl_priv *priv,
 		return;
 	}
 
-	key_flags |= (STA_KEY_FLG_TKIP | STA_KEY_FLG_MAP_KEY_MSK);
-	key_flags |= cpu_to_le16(keyconf->keyidx << STA_KEY_FLG_KEYID_POS);
-	key_flags &= ~STA_KEY_FLG_INVALID;
-
-	if (sta_id == priv->hw_params.bcast_sta_id)
-		key_flags |= STA_KEY_MULTICAST_MSK;
-
 	spin_lock_irqsave(&priv->sta_lock, flags);
 
-	priv->stations[sta_id].sta.key.key_flags = key_flags;
 	priv->stations[sta_id].sta.key.tkip_rx_tsc_byte2 = (u8) iv32;
 
 	for (i = 0; i < 5; i++)
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 70a00c8..4cce661 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1744,7 +1744,6 @@ static void iwl3945_rx_queue_free(struct iwl_priv *priv, struct iwl_rx_queue *rx
 	rxq->bd = NULL;
 	rxq->rb_stts  = NULL;
 }
-EXPORT_SYMBOL(iwl3945_rx_queue_free);
 
 
 /* Convert linear signal-to-noise ratio into dB */
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 3824990..70df3dc 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -476,7 +476,7 @@ minstrel_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
 		return NULL;
 
 	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
-		sband = hw->wiphy->bands[hw->conf.channel->band];
+		sband = hw->wiphy->bands[i];
 		if (sband->n_bitrates > max_rates)
 			max_rates = sband->n_bitrates;
 	}
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index b16801c..01d59a8 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -317,13 +317,44 @@ rate_control_pid_rate_init(void *priv, struct ieee80211_supported_band *sband,
 			   struct ieee80211_sta *sta, void *priv_sta)
 {
 	struct rc_pid_sta_info *spinfo = priv_sta;
+	struct rc_pid_info *pinfo = priv;
+	struct rc_pid_rateinfo *rinfo = pinfo->rinfo;
 	struct sta_info *si;
+	int i, j, tmp;
+	bool s;
 
 	/* TODO: This routine should consider using RSSI from previous packets
 	 * as we need to have IEEE 802.1X auth succeed immediately after assoc..
 	 * Until that method is implemented, we will use the lowest supported
 	 * rate as a workaround. */
 
+	/* Sort the rates. This is optimized for the most common case (i.e.
+	 * almost-sorted CCK+OFDM rates). Kind of bubble-sort with reversed
+	 * mapping too. */
+	for (i = 0; i < sband->n_bitrates; i++) {
+		rinfo[i].index = i;
+		rinfo[i].rev_index = i;
+		if (RC_PID_FAST_START)
+			rinfo[i].diff = 0;
+		else
+			rinfo[i].diff = i * pinfo->norm_offset;
+	}
+	for (i = 1; i < sband->n_bitrates; i++) {
+		s = 0;
+		for (j = 0; j < sband->n_bitrates - i; j++)
+			if (unlikely(sband->bitrates[rinfo[j].index].bitrate >
+				     sband->bitrates[rinfo[j + 1].index].bitrate)) {
+				tmp = rinfo[j].index;
+				rinfo[j].index = rinfo[j + 1].index;
+				rinfo[j + 1].index = tmp;
+				rinfo[rinfo[j].index].rev_index = j;
+				rinfo[rinfo[j + 1].index].rev_index = j + 1;
+				s = 1;
+			}
+		if (!s)
+			break;
+	}
+
 	spinfo->txrate_idx = rate_lowest_index(sband, sta);
 	/* HACK */
 	si = container_of(sta, struct sta_info, sta);
@@ -336,21 +367,22 @@ static void *rate_control_pid_alloc(struct ieee80211_hw *hw,
 	struct rc_pid_info *pinfo;
 	struct rc_pid_rateinfo *rinfo;
 	struct ieee80211_supported_band *sband;
-	int i, j, tmp;
-	bool s;
+	int i, max_rates = 0;
 #ifdef CONFIG_MAC80211_DEBUGFS
 	struct rc_pid_debugfs_entries *de;
 #endif
 
-	sband = hw->wiphy->bands[hw->conf.channel->band];
-
 	pinfo = kmalloc(sizeof(*pinfo), GFP_ATOMIC);
 	if (!pinfo)
 		return NULL;
 
-	/* We can safely assume that sband won't change unless we get
-	 * reinitialized. */
-	rinfo = kmalloc(sizeof(*rinfo) * sband->n_bitrates, GFP_ATOMIC);
+	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
+		sband = hw->wiphy->bands[i];
+		if (sband->n_bitrates > max_rates)
+			max_rates = sband->n_bitrates;
+	}
+
+	rinfo = kmalloc(sizeof(*rinfo) * max_rates, GFP_ATOMIC);
 	if (!rinfo) {
 		kfree(pinfo);
 		return NULL;
@@ -368,33 +400,6 @@ static void *rate_control_pid_alloc(struct ieee80211_hw *hw,
 	pinfo->rinfo = rinfo;
 	pinfo->oldrate = 0;
 
-	/* Sort the rates. This is optimized for the most common case (i.e.
-	 * almost-sorted CCK+OFDM rates). Kind of bubble-sort with reversed
-	 * mapping too. */
-	for (i = 0; i < sband->n_bitrates; i++) {
-		rinfo[i].index = i;
-		rinfo[i].rev_index = i;
-		if (RC_PID_FAST_START)
-			rinfo[i].diff = 0;
-		else
-			rinfo[i].diff = i * pinfo->norm_offset;
-	}
-	for (i = 1; i < sband->n_bitrates; i++) {
-		s = 0;
-		for (j = 0; j < sband->n_bitrates - i; j++)
-			if (unlikely(sband->bitrates[rinfo[j].index].bitrate >
-				     sband->bitrates[rinfo[j + 1].index].bitrate)) {
-				tmp = rinfo[j].index;
-				rinfo[j].index = rinfo[j + 1].index;
-				rinfo[j + 1].index = tmp;
-				rinfo[rinfo[j].index].rev_index = j;
-				rinfo[rinfo[j + 1].index].rev_index = j + 1;
-				s = 1;
-			}
-		if (!s)
-			break;
-	}
-
 #ifdef CONFIG_MAC80211_DEBUGFS
 	de = &pinfo->dentries;
 	de->target = debugfs_create_u32("target_pf", S_IRUSR | S_IWUSR,
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3fb04a8..6365626 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -772,7 +772,7 @@ ieee80211_tx_h_fragment(struct ieee80211_tx_data *tx)
 	hdrlen = ieee80211_hdrlen(hdr->frame_control);
 
 	/* internal error, why is TX_FRAGMENTED set? */
-	if (WARN_ON(skb->len <= frag_threshold))
+	if (WARN_ON(skb->len + FCS_LEN <= frag_threshold))
 		return TX_DROP;
 
 	/*
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 6c1993d..08265ca 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -907,6 +907,7 @@ EXPORT_SYMBOL(freq_reg_info);
 int freq_reg_info(struct wiphy *wiphy, u32 center_freq, u32 *bandwidth,
 			 const struct ieee80211_reg_rule **reg_rule)
 {
+	assert_cfg80211_lock();
 	return freq_reg_info_regd(wiphy, center_freq,
 		bandwidth, reg_rule, NULL);
 }
@@ -1133,7 +1134,8 @@ static bool reg_is_world_roaming(struct wiphy *wiphy)
 	if (is_world_regdom(cfg80211_regdomain->alpha2) ||
 	    (wiphy->regd && is_world_regdom(wiphy->regd->alpha2)))
 		return true;
-	if (last_request->initiator != NL80211_REGDOM_SET_BY_COUNTRY_IE &&
+	if (last_request &&
+	    last_request->initiator != NL80211_REGDOM_SET_BY_COUNTRY_IE &&
 	    wiphy->custom_regulatory)
 		return true;
 	return false;
@@ -1142,6 +1144,12 @@ static bool reg_is_world_roaming(struct wiphy *wiphy)
 /* Reap the advantages of previously found beacons */
 static void reg_process_beacons(struct wiphy *wiphy)
 {
+	/*
+	 * Means we are just firing up cfg80211, so no beacons would
+	 * have been processed yet.
+	 */
+	if (!last_request)
+		return;
 	if (!reg_is_world_roaming(wiphy))
 		return;
 	wiphy_update_beacon_reg(wiphy);
@@ -1176,6 +1184,8 @@ static void handle_channel_custom(struct wiphy *wiphy,
 	struct ieee80211_supported_band *sband;
 	struct ieee80211_channel *chan;
 
+	assert_cfg80211_lock();
+
 	sband = wiphy->bands[band];
 	BUG_ON(chan_idx >= sband->n_channels);
 	chan = &sband->channels[chan_idx];
@@ -1214,10 +1224,13 @@ void wiphy_apply_custom_regulatory(struct wiphy *wiphy,
 				   const struct ieee80211_regdomain *regd)
 {
 	enum ieee80211_band band;
+
+	mutex_lock(&cfg80211_mutex);
 	for (band = 0; band < IEEE80211_NUM_BANDS; band++) {
 		if (wiphy->bands[band])
 			handle_band_custom(wiphy, band, regd);
 	}
+	mutex_unlock(&cfg80211_mutex);
 }
 EXPORT_SYMBOL(wiphy_apply_custom_regulatory);
 
@@ -1423,7 +1436,7 @@ new_request:
 	return call_crda(last_request->alpha2);
 }
 
-/* This currently only processes user and driver regulatory hints */
+/* This processes *all* regulatory hints */
 static void reg_process_hint(struct regulatory_request *reg_request)
 {
 	int r = 0;
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 2ae65b3..1f260c4 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -395,6 +395,7 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 					memcpy(ies, res->pub.information_elements, ielen);
 					found->ies_allocated = true;
 					found->pub.information_elements = ies;
+					found->pub.len_information_elements = ielen;
 				}
 			}
 		}
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
