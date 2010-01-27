From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-01-27
Date: Wed, 27 Jan 2010 16:35:12 -0500
Message-ID: <20100127213511.GK2962@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756123Ab0A0Vph@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another small collections of fixes intended for 2.6.33.
Included are a NULL pointer dereference fix, a buffer leak fix,
a warning fix, and a correction of an ath9k initialization change
that was improperly limited to only dual-band hardware.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c92b544bd5d8e7ed7d81c77bbecab6df2a95aa53:
  Shan Wei (1):
        ipv6: conntrack: Add member of user to nf_ct_frag6_queue structure

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Felix Fietkau (2):
      ath9k: fix beacon slot/buffer leak
      ath9k: fix eeprom INI values override for 2GHz-only cards

Johannes Berg (1):
      iwlwifi: fix pointer signedness warning

Zhu Yi (1):
      mac80211: fix NULL pointer dereference when ftrace is enabled

 drivers/net/wireless/ath/ath9k/hw.c    |    7 +++----
 drivers/net/wireless/ath/ath9k/main.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c |    4 ++--
 net/mac80211/driver-trace.h            |    2 +-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 2ec61f0..ae37144 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -855,12 +855,11 @@ static void ath9k_hw_init_mode_gain_regs(struct ath_hw *ah)
 	}
 }
 
-static void ath9k_hw_init_11a_eeprom_fix(struct ath_hw *ah)
+static void ath9k_hw_init_eeprom_fix(struct ath_hw *ah)
 {
 	u32 i, j;
 
-	if ((ah->hw_version.devid == AR9280_DEVID_PCI) &&
-	    test_bit(ATH9K_MODE_11A, ah->caps.wireless_modes)) {
+	if (ah->hw_version.devid == AR9280_DEVID_PCI) {
 
 		/* EEPROM Fixup */
 		for (i = 0; i < ah->iniModes.ia_rows; i++) {
@@ -980,7 +979,7 @@ int ath9k_hw_init(struct ath_hw *ah)
 	if (r)
 		return r;
 
-	ath9k_hw_init_11a_eeprom_fix(ah);
+	ath9k_hw_init_eeprom_fix(ah);
 
 	r = ath9k_hw_init_macaddr(ah);
 	if (r) {
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 996eb90..643bea3 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2655,10 +2655,10 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	    (sc->sc_ah->opmode == NL80211_IFTYPE_MESH_POINT)) {
 		ath9k_ps_wakeup(sc);
 		ath9k_hw_stoptxdma(sc->sc_ah, sc->beacon.beaconq);
-		ath_beacon_return(sc, avp);
 		ath9k_ps_restore(sc);
 	}
 
+	ath_beacon_return(sc, avp);
 	sc->sc_flags &= ~SC_OP_BEACONS;
 
 	for (i = 0; i < ARRAY_SIZE(sc->beacon.bslot); i++) {
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index cde09a8..90fbdb2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -297,7 +297,7 @@ u8 iwl_add_station(struct iwl_priv *priv, const u8 *addr, bool is_ap, u8 flags,
 }
 EXPORT_SYMBOL(iwl_add_station);
 
-static void iwl_sta_ucode_deactivate(struct iwl_priv *priv, const char *addr)
+static void iwl_sta_ucode_deactivate(struct iwl_priv *priv, const u8 *addr)
 {
 	unsigned long flags;
 	u8 sta_id = iwl_find_station(priv, addr);
@@ -324,7 +324,7 @@ static void iwl_remove_sta_callback(struct iwl_priv *priv,
 {
 	struct iwl_rem_sta_cmd *rm_sta =
 			(struct iwl_rem_sta_cmd *)cmd->cmd.payload;
-	const char *addr = rm_sta->addr;
+	const u8 *addr = rm_sta->addr;
 
 	if (pkt->hdr.flags & IWL_CMD_FAILED_MSK) {
 		IWL_ERR(priv, "Bad return from REPLY_REMOVE_STA (0x%08X)\n",
diff --git a/net/mac80211/driver-trace.h b/net/mac80211/driver-trace.h
index ee94ea0..da8497e 100644
--- a/net/mac80211/driver-trace.h
+++ b/net/mac80211/driver-trace.h
@@ -680,7 +680,7 @@ TRACE_EVENT(drv_ampdu_action,
 		__entry->ret = ret;
 		__entry->action = action;
 		__entry->tid = tid;
-		__entry->ssn = *ssn;
+		__entry->ssn = ssn ? *ssn : 0;
 	),
 
 	TP_printk(
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
