From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-06-30
Date: Wed, 30 Jun 2010 14:53:20 -0400
Message-ID: <20100630185319.GA2618@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Here are a few more fixes intended for 2.6.35.  Included are a couple of
small regression fixes for iwlwifi, one that causes connection stalls with
802.11n on some devices and another which could disable multicast traffic.
Also included is an ath9k fix which avoids a null pointer dereference
resulting from a timer leak.

Please let me know if there are problems!

John

---

The following changes since commit d3ead2413cb99d3e6265577b12537434e229d8c2:
  Guillaume Gaudonville (1):
        ixgbe: skip non IPv4 packets in ATR filter

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      iwlwifi: fix multicast

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in starting ani

Wey-Yi Guy (1):
      iwlwifi: set TX_CMD_FLAG_PROT_REQUIRE_MSK in tx_flag

 drivers/net/wireless/ath/ath9k/ath9k.h      |    1 +
 drivers/net/wireless/ath/ath9k/main.c       |   11 ++++++++++-
 drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c |    6 +-----
 drivers/net/wireless/iwlwifi/iwl-core.c     |    7 ++++++-
 4 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index fbb7dec..5ea8773 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -445,6 +445,7 @@ void ath_deinit_leds(struct ath_softc *sc);
 #define SC_OP_TSF_RESET              BIT(11)
 #define SC_OP_BT_PRIORITY_DETECTED   BIT(12)
 #define SC_OP_BT_SCAN		     BIT(13)
+#define SC_OP_ANI_RUN		     BIT(14)
 
 /* Powersave flags */
 #define PS_WAIT_FOR_BEACON        BIT(0)
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index abfa049..1e2a68e 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -336,6 +336,10 @@ set_timer:
 static void ath_start_ani(struct ath_common *common)
 {
 	unsigned long timestamp = jiffies_to_msecs(jiffies);
+	struct ath_softc *sc = (struct ath_softc *) common->priv;
+
+	if (!(sc->sc_flags & SC_OP_ANI_RUN))
+		return;
 
 	common->ani.longcal_timer = timestamp;
 	common->ani.shortcal_timer = timestamp;
@@ -872,11 +876,13 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 		/* Reset rssi stats */
 		sc->sc_ah->stats.avgbrssi = ATH_RSSI_DUMMY_MARKER;
 
+		sc->sc_flags |= SC_OP_ANI_RUN;
 		ath_start_ani(common);
 	} else {
 		ath_print(common, ATH_DBG_CONFIG, "Bss Info DISASSOC\n");
 		common->curaid = 0;
 		/* Stop ANI */
+		sc->sc_flags &= ~SC_OP_ANI_RUN;
 		del_timer_sync(&common->ani.timer);
 	}
 }
@@ -1478,8 +1484,10 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 
 	if (vif->type == NL80211_IFTYPE_AP    ||
 	    vif->type == NL80211_IFTYPE_ADHOC ||
-	    vif->type == NL80211_IFTYPE_MONITOR)
+	    vif->type == NL80211_IFTYPE_MONITOR) {
+		sc->sc_flags |= SC_OP_ANI_RUN;
 		ath_start_ani(common);
+	}
 
 out:
 	mutex_unlock(&sc->mutex);
@@ -1500,6 +1508,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	mutex_lock(&sc->mutex);
 
 	/* Stop ANI */
+	sc->sc_flags &= ~SC_OP_ANI_RUN;
 	del_timer_sync(&common->ani.timer);
 
 	/* Reclaim beacon resources */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
index 44ef5d9..01658cf 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-hcmd.c
@@ -212,11 +212,7 @@ static void iwlagn_chain_noise_reset(struct iwl_priv *priv)
 static void iwlagn_rts_tx_cmd_flag(struct ieee80211_tx_info *info,
 			__le32 *tx_flags)
 {
-	if ((info->control.rates[0].flags & IEEE80211_TX_RC_USE_RTS_CTS) ||
-	    (info->control.rates[0].flags & IEEE80211_TX_RC_USE_CTS_PROTECT))
-		*tx_flags |= TX_CMD_FLG_RTS_CTS_MSK;
-	else
-		*tx_flags &= ~TX_CMD_FLG_RTS_CTS_MSK;
+	*tx_flags |= TX_CMD_FLG_RTS_CTS_MSK;
 }
 
 /* Calc max signal level (dBm) among 3 possible receivers */
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 426e955..5bbc529 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1314,7 +1314,6 @@ void iwl_configure_filter(struct ieee80211_hw *hw,
 			changed_flags, *total_flags);
 
 	CHK(FIF_OTHER_BSS | FIF_PROMISC_IN_BSS, RXON_FILTER_PROMISC_MSK);
-	CHK(FIF_ALLMULTI, RXON_FILTER_ACCEPT_GRP_MSK);
 	CHK(FIF_CONTROL, RXON_FILTER_CTL2HOST_MSK);
 	CHK(FIF_BCN_PRBRESP_PROMISC, RXON_FILTER_BCON_AWARE_MSK);
 
@@ -1329,6 +1328,12 @@ void iwl_configure_filter(struct ieee80211_hw *hw,
 
 	mutex_unlock(&priv->mutex);
 
+	/*
+	 * Receiving all multicast frames is always enabled by the
+	 * default flags setup in iwl_connection_init_rx_config()
+	 * since we currently do not support programming multicast
+	 * filters into the device.
+	 */
 	*total_flags &= FIF_OTHER_BSS | FIF_ALLMULTI | FIF_PROMISC_IN_BSS |
 			FIF_BCN_PRBRESP_PROMISC | FIF_CONTROL;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
