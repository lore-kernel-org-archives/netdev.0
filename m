From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2011-04-14
Date: Thu, 14 Apr 2011 16:08:58 -0400
Message-ID: <20110414200858.GC2652@tuxdriver.com>
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

Another small round of fixes intended for 2.6.39...

Included are a fix for a WARNING from ath9k regarding a DMA failure, a
fix for iwlegacy not initializing its Tx power correctly, and a small
ath9k fix to report the driver name correctly to ethtool.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 38a2f37258f9e2ae3f6e4241e01088be8dfaf4e9:

  usbnet: Fix up 'FLAG_POINTTOPOINT' and 'FLAG_MULTI_PACKET' overlaps. (2011-04-14 00:22:27 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Felix Fietkau (1):
      ath9k_hw: fix stopping rx DMA during resets

Stanislaw Gruszka (1):
      iwlegacy: fix tx_power initialization

Sujith Manoharan (1):
      ath9k_htc: Fix ethtool reporting

 drivers/net/wireless/ath/ath9k/hif_usb.c     |    4 ++--
 drivers/net/wireless/ath/ath9k/hw.c          |    9 ---------
 drivers/net/wireless/ath/ath9k/mac.c         |   25 ++++++++++++++++++++++---
 drivers/net/wireless/ath/ath9k/mac.h         |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c        |    6 +++---
 drivers/net/wireless/iwlegacy/iwl-3945-hw.h  |    2 --
 drivers/net/wireless/iwlegacy/iwl-4965-hw.h  |    3 ---
 drivers/net/wireless/iwlegacy/iwl-core.c     |   17 +++++++++++------
 drivers/net/wireless/iwlegacy/iwl-eeprom.c   |    7 -------
 drivers/net/wireless/iwlegacy/iwl3945-base.c |    4 ----
 drivers/net/wireless/iwlegacy/iwl4965-base.c |    6 ------
 11 files changed, 39 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index f1b8af6..2d10239 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -1040,7 +1040,7 @@ static int ath9k_hif_usb_probe(struct usb_interface *interface,
 	}
 
 	ret = ath9k_htc_hw_init(hif_dev->htc_handle,
-				&hif_dev->udev->dev, hif_dev->device_id,
+				&interface->dev, hif_dev->device_id,
 				hif_dev->udev->product, id->driver_info);
 	if (ret) {
 		ret = -EINVAL;
@@ -1158,7 +1158,7 @@ fail_resume:
 #endif
 
 static struct usb_driver ath9k_hif_usb_driver = {
-	.name = "ath9k_hif_usb",
+	.name = KBUILD_MODNAME,
 	.probe = ath9k_hif_usb_probe,
 	.disconnect = ath9k_hif_usb_disconnect,
 #ifdef CONFIG_PM
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 1ec9bcd..c95bc5c 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1254,15 +1254,6 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	ah->txchainmask = common->tx_chainmask;
 	ah->rxchainmask = common->rx_chainmask;
 
-	if ((common->bus_ops->ath_bus_type != ATH_USB) && !ah->chip_fullsleep) {
-		ath9k_hw_abortpcurecv(ah);
-		if (!ath9k_hw_stopdmarecv(ah)) {
-			ath_dbg(common, ATH_DBG_XMIT,
-				"Failed to stop receive dma\n");
-			bChannelChange = false;
-		}
-	}
-
 	if (!ath9k_hw_setpower(ah, ATH9K_PM_AWAKE))
 		return -EIO;
 
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 562257a..edc1cbb 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -751,28 +751,47 @@ void ath9k_hw_abortpcurecv(struct ath_hw *ah)
 }
 EXPORT_SYMBOL(ath9k_hw_abortpcurecv);
 
-bool ath9k_hw_stopdmarecv(struct ath_hw *ah)
+bool ath9k_hw_stopdmarecv(struct ath_hw *ah, bool *reset)
 {
 #define AH_RX_STOP_DMA_TIMEOUT 10000   /* usec */
 #define AH_RX_TIME_QUANTUM     100     /* usec */
 	struct ath_common *common = ath9k_hw_common(ah);
+	u32 mac_status, last_mac_status = 0;
 	int i;
 
+	/* Enable access to the DMA observation bus */
+	REG_WRITE(ah, AR_MACMISC,
+		  ((AR_MACMISC_DMA_OBS_LINE_8 << AR_MACMISC_DMA_OBS_S) |
+		   (AR_MACMISC_MISC_OBS_BUS_1 <<
+		    AR_MACMISC_MISC_OBS_BUS_MSB_S)));
+
 	REG_WRITE(ah, AR_CR, AR_CR_RXD);
 
 	/* Wait for rx enable bit to go low */
 	for (i = AH_RX_STOP_DMA_TIMEOUT / AH_TIME_QUANTUM; i != 0; i--) {
 		if ((REG_READ(ah, AR_CR) & AR_CR_RXE) == 0)
 			break;
+
+		if (!AR_SREV_9300_20_OR_LATER(ah)) {
+			mac_status = REG_READ(ah, AR_DMADBG_7) & 0x7f0;
+			if (mac_status == 0x1c0 && mac_status == last_mac_status) {
+				*reset = true;
+				break;
+			}
+
+			last_mac_status = mac_status;
+		}
+
 		udelay(AH_TIME_QUANTUM);
 	}
 
 	if (i == 0) {
 		ath_err(common,
-			"DMA failed to stop in %d ms AR_CR=0x%08x AR_DIAG_SW=0x%08x\n",
+			"DMA failed to stop in %d ms AR_CR=0x%08x AR_DIAG_SW=0x%08x DMADBG_7=0x%08x\n",
 			AH_RX_STOP_DMA_TIMEOUT / 1000,
 			REG_READ(ah, AR_CR),
-			REG_READ(ah, AR_DIAG_SW));
+			REG_READ(ah, AR_DIAG_SW),
+			REG_READ(ah, AR_DMADBG_7));
 		return false;
 	} else {
 		return true;
diff --git a/drivers/net/wireless/ath/ath9k/mac.h b/drivers/net/wireless/ath/ath9k/mac.h
index b2b2ff8..c2a5938 100644
--- a/drivers/net/wireless/ath/ath9k/mac.h
+++ b/drivers/net/wireless/ath/ath9k/mac.h
@@ -695,7 +695,7 @@ bool ath9k_hw_setrxabort(struct ath_hw *ah, bool set);
 void ath9k_hw_putrxbuf(struct ath_hw *ah, u32 rxdp);
 void ath9k_hw_startpcureceive(struct ath_hw *ah, bool is_scanning);
 void ath9k_hw_abortpcurecv(struct ath_hw *ah);
-bool ath9k_hw_stopdmarecv(struct ath_hw *ah);
+bool ath9k_hw_stopdmarecv(struct ath_hw *ah, bool *reset);
 int ath9k_hw_beaconq_setup(struct ath_hw *ah);
 
 /* Interrupt Handling */
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index a9c3f46..dcd19bc 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -486,12 +486,12 @@ start_recv:
 bool ath_stoprecv(struct ath_softc *sc)
 {
 	struct ath_hw *ah = sc->sc_ah;
-	bool stopped;
+	bool stopped, reset = false;
 
 	spin_lock_bh(&sc->rx.rxbuflock);
 	ath9k_hw_abortpcurecv(ah);
 	ath9k_hw_setrxfilter(ah, 0);
-	stopped = ath9k_hw_stopdmarecv(ah);
+	stopped = ath9k_hw_stopdmarecv(ah, &reset);
 
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
 		ath_edma_stop_recv(sc);
@@ -506,7 +506,7 @@ bool ath_stoprecv(struct ath_softc *sc)
 			"confusing the DMA engine when we start RX up\n");
 		ATH_DBG_WARN_ON_ONCE(!stopped);
 	}
-	return stopped;
+	return stopped || reset;
 }
 
 void ath_flushrecv(struct ath_softc *sc)
diff --git a/drivers/net/wireless/iwlegacy/iwl-3945-hw.h b/drivers/net/wireless/iwlegacy/iwl-3945-hw.h
index 779d3cb..5c3a68d 100644
--- a/drivers/net/wireless/iwlegacy/iwl-3945-hw.h
+++ b/drivers/net/wireless/iwlegacy/iwl-3945-hw.h
@@ -74,8 +74,6 @@
 /* RSSI to dBm */
 #define IWL39_RSSI_OFFSET	95
 
-#define IWL_DEFAULT_TX_POWER	0x0F
-
 /*
  * EEPROM related constants, enums, and structures.
  */
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-hw.h b/drivers/net/wireless/iwlegacy/iwl-4965-hw.h
index 08b189c..fc6fa28 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-hw.h
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-hw.h
@@ -804,9 +804,6 @@ struct iwl4965_scd_bc_tbl {
 
 #define IWL4965_DEFAULT_TX_RETRY  15
 
-/* Limit range of txpower output target to be between these values */
-#define IWL4965_TX_POWER_TARGET_POWER_MIN	(0)	/* 0 dBm: 1 milliwatt */
-
 /* EEPROM */
 #define IWL4965_FIRST_AMPDU_QUEUE	10
 
diff --git a/drivers/net/wireless/iwlegacy/iwl-core.c b/drivers/net/wireless/iwlegacy/iwl-core.c
index a209a0e..2b08efb 100644
--- a/drivers/net/wireless/iwlegacy/iwl-core.c
+++ b/drivers/net/wireless/iwlegacy/iwl-core.c
@@ -160,6 +160,7 @@ int iwl_legacy_init_geos(struct iwl_priv *priv)
 	struct ieee80211_channel *geo_ch;
 	struct ieee80211_rate *rates;
 	int i = 0;
+	s8 max_tx_power = 0;
 
 	if (priv->bands[IEEE80211_BAND_2GHZ].n_bitrates ||
 	    priv->bands[IEEE80211_BAND_5GHZ].n_bitrates) {
@@ -235,8 +236,8 @@ int iwl_legacy_init_geos(struct iwl_priv *priv)
 
 			geo_ch->flags |= ch->ht40_extension_channel;
 
-			if (ch->max_power_avg > priv->tx_power_device_lmt)
-				priv->tx_power_device_lmt = ch->max_power_avg;
+			if (ch->max_power_avg > max_tx_power)
+				max_tx_power = ch->max_power_avg;
 		} else {
 			geo_ch->flags |= IEEE80211_CHAN_DISABLED;
 		}
@@ -249,6 +250,10 @@ int iwl_legacy_init_geos(struct iwl_priv *priv)
 				 geo_ch->flags);
 	}
 
+	priv->tx_power_device_lmt = max_tx_power;
+	priv->tx_power_user_lmt = max_tx_power;
+	priv->tx_power_next = max_tx_power;
+
 	if ((priv->bands[IEEE80211_BAND_5GHZ].n_channels == 0) &&
 	     priv->cfg->sku & IWL_SKU_A) {
 		IWL_INFO(priv, "Incorrectly detected BG card as ABG. "
@@ -1124,11 +1129,11 @@ int iwl_legacy_set_tx_power(struct iwl_priv *priv, s8 tx_power, bool force)
 	if (!priv->cfg->ops->lib->send_tx_power)
 		return -EOPNOTSUPP;
 
-	if (tx_power < IWL4965_TX_POWER_TARGET_POWER_MIN) {
+	/* 0 dBm mean 1 milliwatt */
+	if (tx_power < 0) {
 		IWL_WARN(priv,
-			 "Requested user TXPOWER %d below lower limit %d.\n",
-			 tx_power,
-			 IWL4965_TX_POWER_TARGET_POWER_MIN);
+			 "Requested user TXPOWER %d below 1 mW.\n",
+			 tx_power);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/iwlegacy/iwl-eeprom.c b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
index 04c5648..cb346d1 100644
--- a/drivers/net/wireless/iwlegacy/iwl-eeprom.c
+++ b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
@@ -471,13 +471,6 @@ int iwl_legacy_init_channel_map(struct iwl_priv *priv)
 					     flags & EEPROM_CHANNEL_RADAR))
 				       ? "" : "not ");
 
-			/* Set the tx_power_user_lmt to the highest power
-			 * supported by any channel */
-			if (eeprom_ch_info[ch].max_power_avg >
-						priv->tx_power_user_lmt)
-				priv->tx_power_user_lmt =
-				    eeprom_ch_info[ch].max_power_avg;
-
 			ch_info++;
 		}
 	}
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net/wireless/iwlegacy/iwl3945-base.c
index 28eb3d8..cc7ebce 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -3825,10 +3825,6 @@ static int iwl3945_init_drv(struct iwl_priv *priv)
 	priv->force_reset[IWL_FW_RESET].reset_duration =
 		IWL_DELAY_NEXT_FORCE_FW_RELOAD;
 
-
-	priv->tx_power_user_lmt = IWL_DEFAULT_TX_POWER;
-	priv->tx_power_next = IWL_DEFAULT_TX_POWER;
-
 	if (eeprom->version < EEPROM_3945_EEPROM_VERSION) {
 		IWL_WARN(priv, "Unsupported EEPROM version: 0x%04X\n",
 			 eeprom->version);
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index 91b3d8b..d484c36 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -3140,12 +3140,6 @@ static int iwl4965_init_drv(struct iwl_priv *priv)
 
 	iwl_legacy_init_scan_params(priv);
 
-	/* Set the tx_power_user_lmt to the lowest power level
-	 * this value will get overwritten by channel max power avg
-	 * from eeprom */
-	priv->tx_power_user_lmt = IWL4965_TX_POWER_TARGET_POWER_MIN;
-	priv->tx_power_next = IWL4965_TX_POWER_TARGET_POWER_MIN;
