From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-03-01
Date: Fri, 1 Mar 2013 14:23:33 -0500
Message-ID: <20130301192332.GE27114@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57798 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab3CATaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 14:30:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This is another flurry of fixes intended for the 3.9 stream...

A mac80211 pull from Johannes:

"Seth fixes a stupid bug I introduced into one of his earlier patches,
Chun-Yeow fixes mesh forwarding and Felix fixes monitor mode. I myself
fixed a small locking issue and, the biggest change here, removed some
nl80211 information with which sometimes the per wiphy information was
getting too large for the typical 4k-minus-overhead. In my -next tree I
have a patch to allow splitting that and add back the information
removed now."

An iwlwifi pull from Johannes:

"I have a fix for a pretty important bug regarding DMA mapping, that
could cause the DMA engine to overwrite data we wanted to send to it, so
that the next time we send it it would be bad. This particularly affects
calibration results. Other than that, three little fixes for the MVM
driver."

But wait, there's more!

Avinash Patil fixes an incorrectly timed delay in mwifiex.

Bing Zhao prevents a crash in SD8688 caused by failing to properly
set a flag before issuing a command.

Felix Fietkau is the big here this time, providing a trio of minor
ath9k fixes and correcting the advertised interface combinations for
rt2x00 when mesh support is disabled.

Finally, Hauke Mehrtens gives us a patch that correctlin initializes
a spin lock in the bcma code.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 32fcafbcd1c9f6c7013016a22a5369b4acb93577:

  net/phy: micrel: Disable asymmetric pause for KSZ9021 (2013-02-28 15:37:30 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 98b7ff9a4977e4f4f451c30288b197ad79e5ab7f:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2013-03-01 13:52:03 -0500)

----------------------------------------------------------------

Avinash Patil (1):
      mwifiex: correct sleep delay counter

Bing Zhao (1):
      libertas: fix crash for SD8688

Chun-Yeow Yeoh (1):
      mac80211: fix the problem of forwarding from DS to DS in Mesh

Dor Shaish (1):
      iwlwifi: mvm: Remove testing of static PIC in PhyDB

Felix Fietkau (6):
      mac80211: fix idle handling in monitor mode
      mac80211: fix monitor mode channel reporting
      ath9k: fix RSSI dummy marker value
      ath9k_htc: fix signal strength handling issues
      ath9k_hw: improve reset reliability after errors
      rt2x00: error in configurations with mesh support disabled

Hauke Mehrtens (1):
      bcma: init spin lock

Johannes Berg (6):
      mac80211: fix tim_lock locking
      nl80211: remove radar information
      nl80211: remove TCP WoWLAN information
      iwlwifi: always copy first 16 bytes of commands
      iwlwifi: mvm: fix AP/GO mode station removal
      iwlwifi: fix wakeup status query and packet reporting

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Seth Forshee (1):
      mac80211: Ensure off-channel frames don't get queued

 drivers/bcma/driver_pci_host.c                |   2 +
 drivers/net/wireless/ath/ath9k/common.h       |   2 +-
 drivers/net/wireless/ath/ath9k/htc.h          |   1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |  18 +++--
 drivers/net/wireless/ath/ath9k/hw.c           |   4 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h   |  10 +--
 drivers/net/wireless/iwlwifi/iwl-phy-db.c     |  16 ----
 drivers/net/wireless/iwlwifi/mvm/d3.c         | 104 +++++++++++++++++++-------
 drivers/net/wireless/iwlwifi/mvm/mac80211.c   |  19 +++--
 drivers/net/wireless/iwlwifi/mvm/mvm.h        |   4 +
 drivers/net/wireless/iwlwifi/pcie/internal.h  |   9 +++
 drivers/net/wireless/iwlwifi/pcie/tx.c        |  75 ++++++++++++++-----
 drivers/net/wireless/libertas/if_sdio.c       |   6 +-
 drivers/net/wireless/mwifiex/pcie.c           |   2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c       |   8 +-
 net/mac80211/cfg.c                            |  12 ++-
 net/mac80211/iface.c                          |   2 +-
 net/mac80211/tx.c                             |  77 ++++++++++++-------
 net/wireless/nl80211.c                        |  61 +--------------
 19 files changed, 258 insertions(+), 174 deletions(-)

diff --git a/drivers/bcma/driver_pci_host.c b/drivers/bcma/driver_pci_host.c
index d3bde6c..30629a3 100644
--- a/drivers/bcma/driver_pci_host.c
+++ b/drivers/bcma/driver_pci_host.c
@@ -404,6 +404,8 @@ void bcma_core_pci_hostmode_init(struct bcma_drv_pci *pc)
 		return;
 	}
 
+	spin_lock_init(&pc_host->cfgspace_lock);
+
 	pc->host_controller = pc_host;
 	pc_host->pci_controller.io_resource = &pc_host->io_resource;
 	pc_host->pci_controller.mem_resource = &pc_host->mem_resource;
diff --git a/drivers/net/wireless/ath/ath9k/common.h b/drivers/net/wireless/ath/ath9k/common.h
index 5f845be..050ca4a 100644
--- a/drivers/net/wireless/ath/ath9k/common.h
+++ b/drivers/net/wireless/ath/ath9k/common.h
@@ -27,7 +27,7 @@
 #define WME_MAX_BA              WME_BA_BMP_SIZE
 #define ATH_TID_MAX_BUFS        (2 * WME_MAX_BA)
 
-#define ATH_RSSI_DUMMY_MARKER   0x127
+#define ATH_RSSI_DUMMY_MARKER   127
 #define ATH_RSSI_LPF_LEN 		10
 #define RSSI_LPF_THRESHOLD		-20
 #define ATH_RSSI_EP_MULTIPLIER     (1<<7)
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 96bfb18..d3b099d 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -22,6 +22,7 @@
 #include <linux/firmware.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/leds.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 3ad1fd0..bd8251c 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1067,15 +1067,19 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 
 	last_rssi = priv->rx.last_rssi;
 
-	if (likely(last_rssi != ATH_RSSI_DUMMY_MARKER))
-		rxbuf->rxstatus.rs_rssi = ATH_EP_RND(last_rssi,
-						     ATH_RSSI_EP_MULTIPLIER);
+	if (ieee80211_is_beacon(hdr->frame_control) &&
+	    !is_zero_ether_addr(common->curbssid) &&
+	    ether_addr_equal(hdr->addr3, common->curbssid)) {
+		s8 rssi = rxbuf->rxstatus.rs_rssi;
 
-	if (rxbuf->rxstatus.rs_rssi < 0)
-		rxbuf->rxstatus.rs_rssi = 0;
+		if (likely(last_rssi != ATH_RSSI_DUMMY_MARKER))
+			rssi = ATH_EP_RND(last_rssi, ATH_RSSI_EP_MULTIPLIER);
 
-	if (ieee80211_is_beacon(fc))
-		priv->ah->stats.avgbrssi = rxbuf->rxstatus.rs_rssi;
+		if (rssi < 0)
+			rssi = 0;
+
+		priv->ah->stats.avgbrssi = rssi;
+	}
 
 	rx_status->mactime = be64_to_cpu(rxbuf->rxstatus.rs_tstamp);
 	rx_status->band = hw->conf.channel->band;
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 2a2ae40..07e2526 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1463,7 +1463,9 @@ static bool ath9k_hw_chip_reset(struct ath_hw *ah,
 			reset_type = ATH9K_RESET_POWER_ON;
 		else
 			reset_type = ATH9K_RESET_COLD;
-	}
+	} else if (ah->chip_fullsleep || REG_READ(ah, AR_Q_TXE) ||
+		   (REG_READ(ah, AR_CR) & AR_CR_RXE))
+		reset_type = ATH9K_RESET_COLD;
 
 	if (!ath9k_hw_set_reset_reg(ah, reset_type))
 		return false;
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.h b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
index 9a0f45e..10f0179 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
@@ -349,25 +349,23 @@ TRACE_EVENT(iwlwifi_dev_rx_data,
 TRACE_EVENT(iwlwifi_dev_hcmd,
 	TP_PROTO(const struct device *dev,
 		 struct iwl_host_cmd *cmd, u16 total_size,
-		 const void *hdr, size_t hdr_len),
-	TP_ARGS(dev, cmd, total_size, hdr, hdr_len),
+		 struct iwl_cmd_header *hdr),
+	TP_ARGS(dev, cmd, total_size, hdr),
 	TP_STRUCT__entry(
 		DEV_ENTRY
 		__dynamic_array(u8, hcmd, total_size)
 		__field(u32, flags)
 	),
 	TP_fast_assign(
-		int i, offset = hdr_len;
+		int i, offset = sizeof(*hdr);
 
 		DEV_ASSIGN;
 		__entry->flags = cmd->flags;
-		memcpy(__get_dynamic_array(hcmd), hdr, hdr_len);
+		memcpy(__get_dynamic_array(hcmd), hdr, sizeof(*hdr));
 
 		for (i = 0; i < IWL_MAX_CMD_TFDS; i++) {
 			if (!cmd->len[i])
 				continue;
-			if (!(cmd->dataflags[i] & IWL_HCMD_DFL_NOCOPY))
-				continue;
 			memcpy((u8 *)__get_dynamic_array(hcmd) + offset,
 			       cmd->data[i], cmd->len[i]);
 			offset += cmd->len[i];
diff --git a/drivers/net/wireless/iwlwifi/iwl-phy-db.c b/drivers/net/wireless/iwlwifi/iwl-phy-db.c
index 14fc8d3..3392011 100644
--- a/drivers/net/wireless/iwlwifi/iwl-phy-db.c
+++ b/drivers/net/wireless/iwlwifi/iwl-phy-db.c
@@ -136,12 +136,6 @@ struct iwl_calib_res_notif_phy_db {
 	u8 data[];
 } __packed;
 
-#define IWL_PHY_DB_STATIC_PIC cpu_to_le32(0x21436587)
-static inline void iwl_phy_db_test_pic(__le32 pic)
-{
-	WARN_ON(IWL_PHY_DB_STATIC_PIC != pic);
-}
-
 struct iwl_phy_db *iwl_phy_db_init(struct iwl_trans *trans)
 {
 	struct iwl_phy_db *phy_db = kzalloc(sizeof(struct iwl_phy_db),
@@ -260,11 +254,6 @@ int iwl_phy_db_set_section(struct iwl_phy_db *phy_db, struct iwl_rx_packet *pkt,
 			(size - CHANNEL_NUM_SIZE) / phy_db->channel_num;
 	}
 
-	/* Test PIC */
-	if (type != IWL_PHY_DB_CFG)
-		iwl_phy_db_test_pic(*(((__le32 *)phy_db_notif->data) +
-				      (size / sizeof(__le32)) - 1));
-
 	IWL_DEBUG_INFO(phy_db->trans,
 		       "%s(%d): [PHYDB]SET: Type %d , Size: %d\n",
 		       __func__, __LINE__, type, size);
@@ -372,11 +361,6 @@ int iwl_phy_db_get_section_data(struct iwl_phy_db *phy_db,
 		*size = entry->size;
 	}
 
-	/* Test PIC */
-	if (type != IWL_PHY_DB_CFG)
-		iwl_phy_db_test_pic(*(((__le32 *)*data) +
-				      (*size / sizeof(__le32)) - 1));
-
 	IWL_DEBUG_INFO(phy_db->trans,
 		       "%s(%d): [PHYDB] GET: Type %d , Size: %d\n",
 		       __func__, __LINE__, type, *size);
diff --git a/drivers/net/wireless/iwlwifi/mvm/d3.c b/drivers/net/wireless/iwlwifi/mvm/d3.c
index c64d864..994c8c2 100644
--- a/drivers/net/wireless/iwlwifi/mvm/d3.c
+++ b/drivers/net/wireless/iwlwifi/mvm/d3.c
@@ -61,6 +61,7 @@
  *
  *****************************************************************************/
 
+#include <linux/etherdevice.h>
 #include <net/cfg80211.h>
 #include <net/ipv6.h>
 #include "iwl-modparams.h"
@@ -192,6 +193,11 @@ static void iwl_mvm_wowlan_program_keys(struct ieee80211_hw *hw,
 					   sizeof(wkc), &wkc);
 		data->error = ret != 0;
 
+		mvm->ptk_ivlen = key->iv_len;
+		mvm->ptk_icvlen = key->icv_len;
+		mvm->gtk_ivlen = key->iv_len;
+		mvm->gtk_icvlen = key->icv_len;
+
 		/* don't upload key again */
 		goto out_unlock;
 	}
@@ -304,9 +310,13 @@ static void iwl_mvm_wowlan_program_keys(struct ieee80211_hw *hw,
 	 */
 	if (key->flags & IEEE80211_KEY_FLAG_PAIRWISE) {
 		key->hw_key_idx = 0;
+		mvm->ptk_ivlen = key->iv_len;
+		mvm->ptk_icvlen = key->icv_len;
 	} else {
 		data->gtk_key_idx++;
 		key->hw_key_idx = data->gtk_key_idx;
+		mvm->gtk_ivlen = key->iv_len;
+		mvm->gtk_icvlen = key->icv_len;
 	}
 
 	ret = iwl_mvm_set_sta_key(mvm, vif, sta, key, true);
@@ -649,6 +659,11 @@ int iwl_mvm_suspend(struct ieee80211_hw *hw, struct cfg80211_wowlan *wowlan)
 	/* We reprogram keys and shouldn't allocate new key indices */
 	memset(mvm->fw_key_table, 0, sizeof(mvm->fw_key_table));
 
+	mvm->ptk_ivlen = 0;
+	mvm->ptk_icvlen = 0;
+	mvm->ptk_ivlen = 0;
+	mvm->ptk_icvlen = 0;
+
 	/*
 	 * The D3 firmware still hardcodes the AP station ID for the
 	 * BSS we're associated with as 0. As a result, we have to move
@@ -783,7 +798,6 @@ static void iwl_mvm_query_wakeup_reasons(struct iwl_mvm *mvm,
 	struct iwl_wowlan_status *status;
 	u32 reasons;
 	int ret, len;
-	bool pkt8023 = false;
 	struct sk_buff *pkt = NULL;
 
 	iwl_trans_read_mem_bytes(mvm->trans, base,
@@ -824,7 +838,8 @@ static void iwl_mvm_query_wakeup_reasons(struct iwl_mvm *mvm,
 	status = (void *)cmd.resp_pkt->data;
 
 	if (len - sizeof(struct iwl_cmd_header) !=
-	    sizeof(*status) + le32_to_cpu(status->wake_packet_bufsize)) {
+	    sizeof(*status) +
+	    ALIGN(le32_to_cpu(status->wake_packet_bufsize), 4)) {
 		IWL_ERR(mvm, "Invalid WoWLAN status response!\n");
 		goto out;
 	}
@@ -836,61 +851,96 @@ static void iwl_mvm_query_wakeup_reasons(struct iwl_mvm *mvm,
 		goto report;
 	}
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_MAGIC_PACKET) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_MAGIC_PACKET)
 		wakeup.magic_pkt = true;
-		pkt8023 = true;
-	}
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_PATTERN) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_PATTERN)
 		wakeup.pattern_idx =
 			le16_to_cpu(status->pattern_number);
-		pkt8023 = true;
-	}
 
 	if (reasons & (IWL_WOWLAN_WAKEUP_BY_DISCONNECTION_ON_MISSED_BEACON |
 		       IWL_WOWLAN_WAKEUP_BY_DISCONNECTION_ON_DEAUTH))
 		wakeup.disconnect = true;
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_GTK_REKEY_FAILURE) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_GTK_REKEY_FAILURE)
 		wakeup.gtk_rekey_failure = true;
-		pkt8023 = true;
-	}
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_RFKILL_DEASSERTED) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_RFKILL_DEASSERTED)
 		wakeup.rfkill_release = true;
-		pkt8023 = true;
-	}
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_EAPOL_REQUEST) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_EAPOL_REQUEST)
 		wakeup.eap_identity_req = true;
-		pkt8023 = true;
-	}
 
-	if (reasons & IWL_WOWLAN_WAKEUP_BY_FOUR_WAY_HANDSHAKE) {
+	if (reasons & IWL_WOWLAN_WAKEUP_BY_FOUR_WAY_HANDSHAKE)
 		wakeup.four_way_handshake = true;
-		pkt8023 = true;
-	}
 
 	if (status->wake_packet_bufsize) {
-		u32 pktsize = le32_to_cpu(status->wake_packet_bufsize);
-		u32 pktlen = le32_to_cpu(status->wake_packet_length);
+		int pktsize = le32_to_cpu(status->wake_packet_bufsize);
+		int pktlen = le32_to_cpu(status->wake_packet_length);
+		const u8 *pktdata = status->wake_packet;
+		struct ieee80211_hdr *hdr = (void *)pktdata;
+		int truncated = pktlen - pktsize;
+
+		/* this would be a firmware bug */
+		if (WARN_ON_ONCE(truncated < 0))
+			truncated = 0;
+
+		if (ieee80211_is_data(hdr->frame_control)) {
+			int hdrlen = ieee80211_hdrlen(hdr->frame_control);
+			int ivlen = 0, icvlen = 4; /* also FCS */
 
-		if (pkt8023) {
 			pkt = alloc_skb(pktsize, GFP_KERNEL);
 			if (!pkt)
 				goto report;
-			memcpy(skb_put(pkt, pktsize), status->wake_packet,
-			       pktsize);
+
+			memcpy(skb_put(pkt, hdrlen), pktdata, hdrlen);
+			pktdata += hdrlen;
+			pktsize -= hdrlen;
+
+			if (ieee80211_has_protected(hdr->frame_control)) {
+				if (is_multicast_ether_addr(hdr->addr1)) {
+					ivlen = mvm->gtk_ivlen;
+					icvlen += mvm->gtk_icvlen;
+				} else {
+					ivlen = mvm->ptk_ivlen;
+					icvlen += mvm->ptk_icvlen;
+				}
+			}
+
+			/* if truncated, FCS/ICV is (partially) gone */
+			if (truncated >= icvlen) {
+				icvlen = 0;
+				truncated -= icvlen;
+			} else {
+				icvlen -= truncated;
+				truncated = 0;
+			}
+
+			pktsize -= ivlen + icvlen;
+			pktdata += ivlen;
+
+			memcpy(skb_put(pkt, pktsize), pktdata, pktsize);
+
 			if (ieee80211_data_to_8023(pkt, vif->addr, vif->type))
 				goto report;
 			wakeup.packet = pkt->data;
 			wakeup.packet_present_len = pkt->len;
-			wakeup.packet_len = pkt->len - (pktlen - pktsize);
+			wakeup.packet_len = pkt->len - truncated;
 			wakeup.packet_80211 = false;
 		} else {
+			int fcslen = 4;
+
+			if (truncated >= 4) {
+				truncated -= 4;
+				fcslen = 0;
+			} else {
+				fcslen -= truncated;
+				truncated = 0;
+			}
+			pktsize -= fcslen;
 			wakeup.packet = status->wake_packet;
 			wakeup.packet_present_len = pktsize;
-			wakeup.packet_len = pktlen;
+			wakeup.packet_len = pktlen - truncated;
 			wakeup.packet_80211 = true;
 		}
 	}
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
index e8264e1..7e169b0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -557,11 +557,9 @@ static int iwl_mvm_mac_add_interface(struct ieee80211_hw *hw,
 	return ret;
 }
 
-static void iwl_mvm_mac_remove_interface(struct ieee80211_hw *hw,
-					 struct ieee80211_vif *vif)
+static void iwl_mvm_prepare_mac_removal(struct iwl_mvm *mvm,
+					struct ieee80211_vif *vif)
 {
-	struct iwl_mvm *mvm = IWL_MAC80211_GET_MVM(hw);
-	struct iwl_mvm_vif *mvmvif = iwl_mvm_vif_from_mac80211(vif);
 	u32 tfd_msk = 0, ac;
 
 	for (ac = 0; ac < IEEE80211_NUM_ACS; ac++)
@@ -594,12 +592,21 @@ static void iwl_mvm_mac_remove_interface(struct ieee80211_hw *hw,
 		 */
 		flush_work(&mvm->sta_drained_wk);
 	}
+}
+
+static void iwl_mvm_mac_remove_interface(struct ieee80211_hw *hw,
+					 struct ieee80211_vif *vif)
+{
+	struct iwl_mvm *mvm = IWL_MAC80211_GET_MVM(hw);
+	struct iwl_mvm_vif *mvmvif = iwl_mvm_vif_from_mac80211(vif);
+
+	iwl_mvm_prepare_mac_removal(mvm, vif);
 
 	mutex_lock(&mvm->mutex);
 
 	/*
 	 * For AP/GO interface, the tear down of the resources allocated to the
-	 * interface should be handled as part of the bss_info_changed flow.
+	 * interface is be handled as part of the stop_ap flow.
 	 */
 	if (vif->type == NL80211_IFTYPE_AP) {
 		iwl_mvm_dealloc_int_sta(mvm, &mvmvif->bcast_sta);
@@ -763,6 +770,8 @@ static void iwl_mvm_stop_ap(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 	struct iwl_mvm *mvm = IWL_MAC80211_GET_MVM(hw);
 	struct iwl_mvm_vif *mvmvif = iwl_mvm_vif_from_mac80211(vif);
 
+	iwl_mvm_prepare_mac_removal(mvm, vif);
+
 	mutex_lock(&mvm->mutex);
 
 	mvmvif->ap_active = false;
diff --git a/drivers/net/wireless/iwlwifi/mvm/mvm.h b/drivers/net/wireless/iwlwifi/mvm/mvm.h
index 4e339cc..537711b 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mvm.h
+++ b/drivers/net/wireless/iwlwifi/mvm/mvm.h
@@ -327,6 +327,10 @@ struct iwl_mvm {
 	struct led_classdev led;
 
 	struct ieee80211_vif *p2p_device_vif;
+
+#ifdef CONFIG_PM_SLEEP
+	int gtk_ivlen, gtk_icvlen, ptk_ivlen, ptk_icvlen;
+#endif
 };
 
 /* Extract MVM priv from op_mode and _hw */
diff --git a/drivers/net/wireless/iwlwifi/pcie/internal.h b/drivers/net/wireless/iwlwifi/pcie/internal.h
index aa2a39a..3d62e80 100644
--- a/drivers/net/wireless/iwlwifi/pcie/internal.h
+++ b/drivers/net/wireless/iwlwifi/pcie/internal.h
@@ -182,6 +182,15 @@ struct iwl_queue {
 #define TFD_TX_CMD_SLOTS 256
 #define TFD_CMD_SLOTS 32
 
+/*
+ * The FH will write back to the first TB only, so we need
+ * to copy some data into the buffer regardless of whether
+ * it should be mapped or not. This indicates how much to
+ * copy, even for HCMDs it must be big enough to fit the
+ * DRAM scratch from the TX cmd, at least 16 bytes.
+ */
+#define IWL_HCMD_MIN_COPY_SIZE	16
+
 struct iwl_pcie_txq_entry {
 	struct iwl_device_cmd *cmd;
 	struct iwl_device_cmd *copy_cmd;
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/iwlwifi/pcie/tx.c
index 8e9e321..8b625a7 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -1152,10 +1152,12 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 	void *dup_buf = NULL;
 	dma_addr_t phys_addr;
 	int idx;
-	u16 copy_size, cmd_size;
+	u16 copy_size, cmd_size, dma_size;
 	bool had_nocopy = false;
 	int i;
 	u32 cmd_pos;
+	const u8 *cmddata[IWL_MAX_CMD_TFDS];
+	u16 cmdlen[IWL_MAX_CMD_TFDS];
 
 	copy_size = sizeof(out_cmd->hdr);
 	cmd_size = sizeof(out_cmd->hdr);
@@ -1164,8 +1166,23 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 	BUILD_BUG_ON(IWL_MAX_CMD_TFDS > IWL_NUM_OF_TBS - 1);
 
 	for (i = 0; i < IWL_MAX_CMD_TFDS; i++) {
+		cmddata[i] = cmd->data[i];
+		cmdlen[i] = cmd->len[i];
+
 		if (!cmd->len[i])
 			continue;
+
+		/* need at least IWL_HCMD_MIN_COPY_SIZE copied */
+		if (copy_size < IWL_HCMD_MIN_COPY_SIZE) {
+			int copy = IWL_HCMD_MIN_COPY_SIZE - copy_size;
+
+			if (copy > cmdlen[i])
+				copy = cmdlen[i];
+			cmdlen[i] -= copy;
+			cmddata[i] += copy;
+			copy_size += copy;
+		}
+
 		if (cmd->dataflags[i] & IWL_HCMD_DFL_NOCOPY) {
 			had_nocopy = true;
 			if (WARN_ON(cmd->dataflags[i] & IWL_HCMD_DFL_DUP)) {
@@ -1185,7 +1202,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 				goto free_dup_buf;
 			}
 
-			dup_buf = kmemdup(cmd->data[i], cmd->len[i],
+			dup_buf = kmemdup(cmddata[i], cmdlen[i],
 					  GFP_ATOMIC);
 			if (!dup_buf)
 				return -ENOMEM;
@@ -1195,7 +1212,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 				idx = -EINVAL;
 				goto free_dup_buf;
 			}
-			copy_size += cmd->len[i];
+			copy_size += cmdlen[i];
 		}
 		cmd_size += cmd->len[i];
 	}
@@ -1242,14 +1259,31 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 
 	/* and copy the data that needs to be copied */
 	cmd_pos = offsetof(struct iwl_device_cmd, payload);
+	copy_size = sizeof(out_cmd->hdr);
 	for (i = 0; i < IWL_MAX_CMD_TFDS; i++) {
-		if (!cmd->len[i])
+		int copy = 0;
+
+		if (!cmd->len)
 			continue;
-		if (cmd->dataflags[i] & (IWL_HCMD_DFL_NOCOPY |
-					 IWL_HCMD_DFL_DUP))
-			break;
-		memcpy((u8 *)out_cmd + cmd_pos, cmd->data[i], cmd->len[i]);
-		cmd_pos += cmd->len[i];
+
+		/* need at least IWL_HCMD_MIN_COPY_SIZE copied */
+		if (copy_size < IWL_HCMD_MIN_COPY_SIZE) {
+			copy = IWL_HCMD_MIN_COPY_SIZE - copy_size;
+
+			if (copy > cmd->len[i])
+				copy = cmd->len[i];
+		}
+
+		/* copy everything if not nocopy/dup */
+		if (!(cmd->dataflags[i] & (IWL_HCMD_DFL_NOCOPY |
+					   IWL_HCMD_DFL_DUP)))
+			copy = cmd->len[i];
+
+		if (copy) {
+			memcpy((u8 *)out_cmd + cmd_pos, cmd->data[i], copy);
+			cmd_pos += copy;
+			copy_size += copy;
+		}
 	}
 
 	WARN_ON_ONCE(txq->entries[idx].copy_cmd);
@@ -1275,7 +1309,14 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 		     out_cmd->hdr.cmd, le16_to_cpu(out_cmd->hdr.sequence),
 		     cmd_size, q->write_ptr, idx, trans_pcie->cmd_queue);
 
-	phys_addr = dma_map_single(trans->dev, &out_cmd->hdr, copy_size,
+	/*
+	 * If the entire command is smaller than IWL_HCMD_MIN_COPY_SIZE, we must
+	 * still map at least that many bytes for the hardware to write back to.
+	 * We have enough space, so that's not a problem.
+	 */
+	dma_size = max_t(u16, copy_size, IWL_HCMD_MIN_COPY_SIZE);
+
+	phys_addr = dma_map_single(trans->dev, &out_cmd->hdr, dma_size,
 				   DMA_BIDIRECTIONAL);
 	if (unlikely(dma_mapping_error(trans->dev, phys_addr))) {
 		idx = -ENOMEM;
@@ -1283,14 +1324,15 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 	}
 
 	dma_unmap_addr_set(out_meta, mapping, phys_addr);
-	dma_unmap_len_set(out_meta, len, copy_size);
+	dma_unmap_len_set(out_meta, len, dma_size);
 
 	iwl_pcie_txq_build_tfd(trans, txq, phys_addr, copy_size, 1);
 
+	/* map the remaining (adjusted) nocopy/dup fragments */
 	for (i = 0; i < IWL_MAX_CMD_TFDS; i++) {
-		const void *data = cmd->data[i];
+		const void *data = cmddata[i];
 
-		if (!cmd->len[i])
+		if (!cmdlen[i])
 			continue;
 		if (!(cmd->dataflags[i] & (IWL_HCMD_DFL_NOCOPY |
 					   IWL_HCMD_DFL_DUP)))
@@ -1298,7 +1340,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 		if (cmd->dataflags[i] & IWL_HCMD_DFL_DUP)
 			data = dup_buf;
 		phys_addr = dma_map_single(trans->dev, (void *)data,
-					   cmd->len[i], DMA_BIDIRECTIONAL);
+					   cmdlen[i], DMA_BIDIRECTIONAL);
 		if (dma_mapping_error(trans->dev, phys_addr)) {
 			iwl_pcie_tfd_unmap(trans, out_meta,
 					   &txq->tfds[q->write_ptr],
@@ -1307,7 +1349,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 			goto out;
 		}
 
-		iwl_pcie_txq_build_tfd(trans, txq, phys_addr, cmd->len[i], 0);
+		iwl_pcie_txq_build_tfd(trans, txq, phys_addr, cmdlen[i], 0);
 	}
 
 	out_meta->flags = cmd->flags;
@@ -1317,8 +1359,7 @@ static int iwl_pcie_enqueue_hcmd(struct iwl_trans *trans,
 
 	txq->need_update = 1;
 
-	trace_iwlwifi_dev_hcmd(trans->dev, cmd, cmd_size,
-			       &out_cmd->hdr, copy_size);
+	trace_iwlwifi_dev_hcmd(trans->dev, cmd, cmd_size, &out_cmd->hdr);
 
 	/* start timer if queue currently empty */
 	if (q->read_ptr == q->write_ptr && trans_pcie->wd_timeout)
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index 739309e..4557833 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -825,6 +825,11 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
 
 	sdio_release_host(func);
 
+	/* Set fw_ready before queuing any commands so that
+	 * lbs_thread won't block from sending them to firmware.
+	 */
+	priv->fw_ready = 1;
+
 	/*
 	 * FUNC_INIT is required for SD8688 WLAN/BT multiple functions
 	 */
@@ -839,7 +844,6 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
 			netdev_alert(priv->dev, "CMD_FUNC_INIT cmd failed\n");
 	}
 
-	priv->fw_ready = 1;
 	wake_up(&card->pwron_waitq);
 
 	if (!card->started) {
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 35c7972..5c395e2 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -302,7 +302,7 @@ static int mwifiex_pm_wakeup_card(struct mwifiex_adapter *adapter)
 		i++;
 		usleep_range(10, 20);
 		/* 50ms max wait */
-		if (i == 50000)
+		if (i == 5000)
 			break;
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 1031db6..189744d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1236,8 +1236,10 @@ static inline void rt2x00lib_set_if_combinations(struct rt2x00_dev *rt2x00dev)
 	 */
 	if_limit = &rt2x00dev->if_limits_ap;
 	if_limit->max = rt2x00dev->ops->max_ap_intf;
-	if_limit->types = BIT(NL80211_IFTYPE_AP) |
-			BIT(NL80211_IFTYPE_MESH_POINT);
+	if_limit->types = BIT(NL80211_IFTYPE_AP);
+#ifdef CONFIG_MAC80211_MESH
+	if_limit->types |= BIT(NL80211_IFTYPE_MESH_POINT);
+#endif
 
 	/*
 	 * Build up AP interface combinations structure.
@@ -1309,7 +1311,9 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 		rt2x00dev->hw->wiphy->interface_modes |=
 		    BIT(NL80211_IFTYPE_ADHOC) |
 		    BIT(NL80211_IFTYPE_AP) |
+#ifdef CONFIG_MAC80211_MESH
 		    BIT(NL80211_IFTYPE_MESH_POINT) |
+#endif
 		    BIT(NL80211_IFTYPE_WDS);
 
 	rt2x00dev->hw->wiphy->flags |= WIPHY_FLAG_IBSS_RSN;
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 09d96a8..808f5fc 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3285,13 +3285,19 @@ static int ieee80211_cfg_get_channel(struct wiphy *wiphy,
 				     struct cfg80211_chan_def *chandef)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_WDEV_TO_SUB_IF(wdev);
+	struct ieee80211_local *local = wiphy_priv(wiphy);
 	struct ieee80211_chanctx_conf *chanctx_conf;
 	int ret = -ENODATA;
 
 	rcu_read_lock();
-	chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
-	if (chanctx_conf) {
-		*chandef = chanctx_conf->def;
+	if (local->use_chanctx) {
+		chanctx_conf = rcu_dereference(sdata->vif.chanctx_conf);
+		if (chanctx_conf) {
+			*chandef = chanctx_conf->def;
+			ret = 0;
+		}
+	} else if (local->open_count == local->monitors) {
+		*chandef = local->monitor_chandef;
 		ret = 0;
 	}
 	rcu_read_unlock();
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 2c059e5..640afab 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -107,7 +107,7 @@ void ieee80211_recalc_idle(struct ieee80211_local *local)
 
 	lockdep_assert_held(&local->mtx);
 
-	active = !list_empty(&local->chanctx_list);
+	active = !list_empty(&local->chanctx_list) || local->monitors;
 
 	if (!local->ops->remain_on_channel) {
 		list_for_each_entry(roc, &local->roc_list, list) {
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 5b9602b..c592a41 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1231,34 +1231,40 @@ static bool ieee80211_tx_frags(struct ieee80211_local *local,
 		if (local->queue_stop_reasons[q] ||
 		    (!txpending && !skb_queue_empty(&local->pending[q]))) {
 			if (unlikely(info->flags &
-					IEEE80211_TX_INTFL_OFFCHAN_TX_OK &&
-				     local->queue_stop_reasons[q] &
-					~BIT(IEEE80211_QUEUE_STOP_REASON_OFFCHANNEL))) {
+				     IEEE80211_TX_INTFL_OFFCHAN_TX_OK)) {
+				if (local->queue_stop_reasons[q] &
+				    ~BIT(IEEE80211_QUEUE_STOP_REASON_OFFCHANNEL)) {
+					/*
+					 * Drop off-channel frames if queues
+					 * are stopped for any reason other
+					 * than off-channel operation. Never
+					 * queue them.
+					 */
+					spin_unlock_irqrestore(
+						&local->queue_stop_reason_lock,
+						flags);
+					ieee80211_purge_tx_queue(&local->hw,
+								 skbs);
+					return true;
+				}
+			} else {
+
 				/*
-				 * Drop off-channel frames if queues are stopped
-				 * for any reason other than off-channel
-				 * operation. Never queue them.
+				 * Since queue is stopped, queue up frames for
+				 * later transmission from the tx-pending
+				 * tasklet when the queue is woken again.
 				 */
-				spin_unlock_irqrestore(
-					&local->queue_stop_reason_lock, flags);
-				ieee80211_purge_tx_queue(&local->hw, skbs);
-				return true;
+				if (txpending)
+					skb_queue_splice_init(skbs,
+							      &local->pending[q]);
+				else
+					skb_queue_splice_tail_init(skbs,
+								   &local->pending[q]);
+
+				spin_unlock_irqrestore(&local->queue_stop_reason_lock,
+						       flags);
+				return false;
 			}
-
-			/*
-			 * Since queue is stopped, queue up frames for later
-			 * transmission from the tx-pending tasklet when the
-			 * queue is woken again.
-			 */
-			if (txpending)
-				skb_queue_splice_init(skbs, &local->pending[q]);
-			else
-				skb_queue_splice_tail_init(skbs,
-							   &local->pending[q]);
-
-			spin_unlock_irqrestore(&local->queue_stop_reason_lock,
-					       flags);
-			return false;
 		}
 		spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
 
@@ -1844,9 +1850,24 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		}
 
 		if (!is_multicast_ether_addr(skb->data)) {
+			struct sta_info *next_hop;
+			bool mpp_lookup = true;
+
 			mpath = mesh_path_lookup(sdata, skb->data);
-			if (!mpath)
+			if (mpath) {
+				mpp_lookup = false;
+				next_hop = rcu_dereference(mpath->next_hop);
+				if (!next_hop ||
+				    !(mpath->flags & (MESH_PATH_ACTIVE |
+						      MESH_PATH_RESOLVING)))
+					mpp_lookup = true;
+			}
+
+			if (mpp_lookup)
 				mppath = mpp_path_lookup(sdata, skb->data);
+
+			if (mppath && mpath)
+				mesh_path_del(mpath->sdata, mpath->dst);
 		}
 
 		/*
@@ -2360,9 +2381,9 @@ static int ieee80211_beacon_add_tim(struct ieee80211_sub_if_data *sdata,
 	if (local->tim_in_locked_section) {
 		__ieee80211_beacon_add_tim(sdata, ps, skb);
 	} else {
-		spin_lock(&local->tim_lock);
+		spin_lock_bh(&local->tim_lock);
 		__ieee80211_beacon_add_tim(sdata, ps, skb);
-		spin_unlock(&local->tim_lock);
+		spin_unlock_bh(&local->tim_lock);
 	}
 
 	return 0;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 35545cc..e652d05 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -554,16 +554,9 @@ static int nl80211_msg_put_channel(struct sk_buff *msg,
 	if ((chan->flags & IEEE80211_CHAN_NO_IBSS) &&
 	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_IBSS))
 		goto nla_put_failure;
-	if (chan->flags & IEEE80211_CHAN_RADAR) {
-		u32 time = elapsed_jiffies_msecs(chan->dfs_state_entered);
-		if (nla_put_flag(msg, NL80211_FREQUENCY_ATTR_RADAR))
-			goto nla_put_failure;
-		if (nla_put_u32(msg, NL80211_FREQUENCY_ATTR_DFS_STATE,
-				chan->dfs_state))
-			goto nla_put_failure;
-		if (nla_put_u32(msg, NL80211_FREQUENCY_ATTR_DFS_TIME, time))
-			goto nla_put_failure;
-	}
+	if ((chan->flags & IEEE80211_CHAN_RADAR) &&
+	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_RADAR))
+		goto nla_put_failure;
 	if ((chan->flags & IEEE80211_CHAN_NO_HT40MINUS) &&
 	    nla_put_flag(msg, NL80211_FREQUENCY_ATTR_NO_HT40_MINUS))
 		goto nla_put_failure;
@@ -900,9 +893,6 @@ static int nl80211_put_iface_combinations(struct wiphy *wiphy,
 		    nla_put_u32(msg, NL80211_IFACE_COMB_MAXNUM,
 				c->max_interfaces))
 			goto nla_put_failure;
-		if (nla_put_u32(msg, NL80211_IFACE_COMB_RADAR_DETECT_WIDTHS,
-				c->radar_detect_widths))
-			goto nla_put_failure;
 
 		nla_nest_end(msg, nl_combi);
 	}
@@ -914,48 +904,6 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
-#ifdef CONFIG_PM
-static int nl80211_send_wowlan_tcp_caps(struct cfg80211_registered_device *rdev,
-					struct sk_buff *msg)
-{
-	const struct wiphy_wowlan_tcp_support *tcp = rdev->wiphy.wowlan.tcp;
-	struct nlattr *nl_tcp;
-
-	if (!tcp)
-		return 0;
-
-	nl_tcp = nla_nest_start(msg, NL80211_WOWLAN_TRIG_TCP_CONNECTION);
-	if (!nl_tcp)
-		return -ENOBUFS;
-
-	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD,
-			tcp->data_payload_max))
-		return -ENOBUFS;
-
-	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD,
-			tcp->data_payload_max))
-		return -ENOBUFS;
-
-	if (tcp->seq && nla_put_flag(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ))
-		return -ENOBUFS;
-
-	if (tcp->tok && nla_put(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN,
-				sizeof(*tcp->tok), tcp->tok))
-		return -ENOBUFS;
-
-	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_INTERVAL,
-			tcp->data_interval_max))
-		return -ENOBUFS;
-
-	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_WAKE_PAYLOAD,
-			tcp->wake_payload_max))
-		return -ENOBUFS;
-
-	nla_nest_end(msg, nl_tcp);
-	return 0;
-}
-#endif
-
 static int nl80211_send_wiphy(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *dev)
 {
@@ -1330,9 +1278,6 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u32 portid, u32 seq, int flag
 				goto nla_put_failure;
 		}
 
-		if (nl80211_send_wowlan_tcp_caps(dev, msg))
-			goto nla_put_failure;
-
 		nla_nest_end(msg, nl_wowlan);
 	}
 #endif
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
