From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-10-29
Date: Fri, 29 Oct 2010 15:14:22 -0400
Message-ID: <20101029191422.GE2399@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are more fixes intended for 2.6.37.  Most are obvious one-liners
(more-or-less).  The series from Luis fixes a bug as documented in the
changelog.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 19449bfc10d163f0024dd5ae5808e28cda32e7b4:

  stmmac: enable/disable rx/tx in the core with a single write. (2010-10-28 11:47:54 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Felix Fietkau (1):
      ath9k: fix tx aggregation flush on AR9003

Jesper Juhl (1):
      mac80211: fix failure to check kmalloc return value in key_key_read

Jones Desougi (1):
      ath5k: Fix double free on hw attach error path

Jouni Malinen (1):
      mac80211: Fix scan_ies_len to include DS Params

Larry Finger (1):
      b43: Fix warning at drivers/mmc/core/core.c:237 in mmc_wait_for_cmd

Luis R. Rodriguez (4):
      ath9k: add locking for stopping RX
      ath9k: add locking for starting the PCU on RX
      ath9k: rename rxflushlock to pcu_lock
      ath9k: lock reset and PCU start/stopping

Mohammed Shafi Shajakhan (1):
      ath9k: Fix incorrect access of rate flags in RC

Paul Fox (1):
      libertas: Fix sd8686 firmware reload

Rajkumar Manoharan (1):
      ath9k_htc: Set proper firmware offset for Netgear WNDA3200

 drivers/net/wireless/ath/ath5k/attach.c  |   17 +++++++--------
 drivers/net/wireless/ath/ath9k/ath9k.h   |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c |   10 +++++++-
 drivers/net/wireless/ath/ath9k/main.c    |   31 +++++++++++++++++++++++++++-
 drivers/net/wireless/ath/ath9k/rc.c      |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c    |   15 ++++++-------
 drivers/net/wireless/ath/ath9k/xmit.c    |   18 ++++++++--------
 drivers/net/wireless/b43/sdio.c          |    2 +
 drivers/net/wireless/libertas/if_sdio.c  |   32 +++++++++++++++++++++++++++--
 net/mac80211/debugfs_key.c               |    6 ++++-
 net/mac80211/main.c                      |    5 ++-
 11 files changed, 102 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/attach.c b/drivers/net/wireless/ath/ath5k/attach.c
index cd0b14a..fbe8aca 100644
--- a/drivers/net/wireless/ath/ath5k/attach.c
+++ b/drivers/net/wireless/ath/ath5k/attach.c
@@ -139,12 +139,12 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	/* Fill the ath5k_hw struct with the needed functions */
 	ret = ath5k_hw_init_desc_functions(ah);
 	if (ret)
-		goto err_free;
+		goto err;
 
 	/* Bring device out of sleep and reset its units */
 	ret = ath5k_hw_nic_wakeup(ah, 0, true);
 	if (ret)
-		goto err_free;
+		goto err;
 
 	/* Get MAC, PHY and RADIO revisions */
 	ah->ah_mac_srev = srev;
@@ -234,7 +234,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 		} else {
 			ATH5K_ERR(sc, "Couldn't identify radio revision.\n");
 			ret = -ENODEV;
-			goto err_free;
+			goto err;
 		}
 	}
 
@@ -244,7 +244,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	(srev < AR5K_SREV_AR2425)) {
 		ATH5K_ERR(sc, "Device not yet supported.\n");
 		ret = -ENODEV;
-		goto err_free;
+		goto err;
 	}
 
 	/*
@@ -252,7 +252,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	 */
 	ret = ath5k_hw_post(ah);
 	if (ret)
-		goto err_free;
+		goto err;
 
 	/* Enable pci core retry fix on Hainan (5213A) and later chips */
 	if (srev >= AR5K_SREV_AR5213A)
@@ -265,7 +265,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	ret = ath5k_eeprom_init(ah);
 	if (ret) {
 		ATH5K_ERR(sc, "unable to init EEPROM\n");
-		goto err_free;
+		goto err;
 	}
 
 	ee = &ah->ah_capabilities.cap_eeprom;
@@ -307,7 +307,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	if (ret) {
 		ATH5K_ERR(sc, "unable to get device capabilities: 0x%04x\n",
 			sc->pdev->device);
-		goto err_free;
+		goto err;
 	}
 
 	/* Crypto settings */
@@ -341,8 +341,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	ath5k_hw_set_ledstate(ah, AR5K_LED_INIT);
 
 	return 0;
-err_free:
-	kfree(ah);
+err:
 	return ret;
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 973c919..9b8e7e3 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -310,7 +310,7 @@ struct ath_rx {
 	u8 rxotherant;
 	u32 *rxlink;
 	unsigned int rxfilter;
-	spinlock_t rxflushlock;
+	spinlock_t pcu_lock;
 	spinlock_t rxbuflock;
 	struct list_head rxbuf;
 	struct ath_descdma rxdma;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 728d904..6576f68 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -801,10 +801,16 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 	}
 	kfree(buf);
 
-	if ((hif_dev->device_id == 0x7010) || (hif_dev->device_id == 0x7015))
+	switch (hif_dev->device_id) {
+	case 0x7010:
+	case 0x7015:
+	case 0x9018:
 		firm_offset = AR7010_FIRMWARE_TEXT;
-	else
+		break;
+	default:
 		firm_offset = AR9271_FIRMWARE_TEXT;
+		break;
+	}
 
 	/*
 	 * Issue FW download complete command to firmware.
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index c6ec800..b52f1cf 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -241,6 +241,9 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	 */
 	ath9k_hw_set_interrupts(ah, 0);
 	ath_drain_all_txq(sc, false);
+
+	spin_lock_bh(&sc->rx.pcu_lock);
+
 	stopped = ath_stoprecv(sc);
 
 	/* XXX: do not flush receive queue here. We don't want
@@ -268,6 +271,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 			  "reset status %d\n",
 			  channel->center_freq, r);
 		spin_unlock_bh(&sc->sc_resetlock);
+		spin_unlock_bh(&sc->rx.pcu_lock);
 		goto ps_restore;
 	}
 	spin_unlock_bh(&sc->sc_resetlock);
@@ -276,9 +280,12 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to restart recv logic\n");
 		r = -EIO;
+		spin_unlock_bh(&sc->rx.pcu_lock);
 		goto ps_restore;
 	}
 
+	spin_unlock_bh(&sc->rx.pcu_lock);
+
 	ath_update_txpow(sc);
 	ath9k_hw_set_interrupts(ah, ah->imask);
 
@@ -613,7 +620,7 @@ void ath9k_tasklet(unsigned long data)
 		rxmask = (ATH9K_INT_RX | ATH9K_INT_RXEOL | ATH9K_INT_RXORN);
 
 	if (status & rxmask) {
-		spin_lock_bh(&sc->rx.rxflushlock);
+		spin_lock_bh(&sc->rx.pcu_lock);
 
 		/* Check for high priority Rx first */
 		if ((ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) &&
@@ -621,7 +628,7 @@ void ath9k_tasklet(unsigned long data)
 			ath_rx_tasklet(sc, 0, true);
 
 		ath_rx_tasklet(sc, 0, false);
-		spin_unlock_bh(&sc->rx.rxflushlock);
+		spin_unlock_bh(&sc->rx.pcu_lock);
 	}
 
 	if (status & ATH9K_INT_TX) {
@@ -876,6 +883,7 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 	if (!ah->curchan)
 		ah->curchan = ath_get_curchannel(sc, sc->hw);
 
+	spin_lock_bh(&sc->rx.pcu_lock);
 	spin_lock_bh(&sc->sc_resetlock);
 	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
@@ -890,8 +898,10 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 	if (ath_startrecv(sc) != 0) {
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to restart recv logic\n");
+		spin_unlock_bh(&sc->rx.pcu_lock);
 		return;
 	}
+	spin_unlock_bh(&sc->rx.pcu_lock);
 
 	if (sc->sc_flags & SC_OP_BEACONS)
 		ath_beacon_config(sc, NULL);	/* restart beacons */
@@ -930,6 +940,9 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 	ath9k_hw_set_interrupts(ah, 0);
 
 	ath_drain_all_txq(sc, false);	/* clear pending tx frames */
+
+	spin_lock_bh(&sc->rx.pcu_lock);
+
 	ath_stoprecv(sc);		/* turn off frame recv */
 	ath_flushrecv(sc);		/* flush recv queue */
 
@@ -947,6 +960,9 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 	spin_unlock_bh(&sc->sc_resetlock);
 
 	ath9k_hw_phy_disable(ah);
+
+	spin_unlock_bh(&sc->rx.pcu_lock);
+
 	ath9k_hw_configpcipowersave(ah, 1, 1);
 	ath9k_ps_restore(sc);
 	ath9k_setpower(sc, ATH9K_PM_FULL_SLEEP);
@@ -966,6 +982,9 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 
 	ath9k_hw_set_interrupts(ah, 0);
 	ath_drain_all_txq(sc, retry_tx);
+
+	spin_lock_bh(&sc->rx.pcu_lock);
+
 	ath_stoprecv(sc);
 	ath_flushrecv(sc);
 
@@ -980,6 +999,8 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to start recv logic\n");
 
+	spin_unlock_bh(&sc->rx.pcu_lock);
+
 	/*
 	 * We may be doing a reset in response to a request
 	 * that changes the channel so update any state that
@@ -1142,6 +1163,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	 * be followed by initialization of the appropriate bits
 	 * and then setup of the interrupt mask.
 	 */
+	spin_lock_bh(&sc->rx.pcu_lock);
 	spin_lock_bh(&sc->sc_resetlock);
 	r = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (r) {
@@ -1150,6 +1172,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 			  "(freq %u MHz)\n", r,
 			  curchan->center_freq);
 		spin_unlock_bh(&sc->sc_resetlock);
+		spin_unlock_bh(&sc->rx.pcu_lock);
 		goto mutex_unlock;
 	}
 	spin_unlock_bh(&sc->sc_resetlock);
@@ -1171,8 +1194,10 @@ static int ath9k_start(struct ieee80211_hw *hw)
 		ath_print(common, ATH_DBG_FATAL,
 			  "Unable to start recv logic\n");
 		r = -EIO;
+		spin_unlock_bh(&sc->rx.pcu_lock);
 		goto mutex_unlock;
 	}
+	spin_unlock_bh(&sc->rx.pcu_lock);
 
 	/* Setup our intr mask. */
 	ah->imask = ATH9K_INT_TX | ATH9K_INT_RXEOL |
@@ -1371,12 +1396,14 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 	 * before setting the invalid flag. */
 	ath9k_hw_set_interrupts(ah, 0);
 
+	spin_lock_bh(&sc->rx.pcu_lock);
 	if (!(sc->sc_flags & SC_OP_INVALID)) {
 		ath_drain_all_txq(sc, false);
 		ath_stoprecv(sc);
 		ath9k_hw_phy_disable(ah);
 	} else
 		sc->rx.rxlink = NULL;
+	spin_unlock_bh(&sc->rx.pcu_lock);
 
 	/* disable HAL and put h/w to sleep */
 	ath9k_hw_disable(ah);
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 0cee90c..89978d7 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -527,7 +527,7 @@ static u8 ath_rc_setvalid_rates(struct ath_rate_priv *ath_rc_priv,
 	for (i = 0; i < rateset->rs_nrates; i++) {
 		for (j = 0; j < rate_table->rate_cnt; j++) {
 			u32 phy = rate_table->info[j].phy;
-			u16 rate_flags = rate_table->info[i].rate_flags;
+			u16 rate_flags = rate_table->info[j].rate_flags;
 			u8 rate = rateset->rs_rates[i];
 			u8 dot11rate = rate_table->info[j].dot11rate;
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index fe73fc5..fddb012 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -297,19 +297,17 @@ static void ath_edma_start_recv(struct ath_softc *sc)
 	ath_rx_addbuffer_edma(sc, ATH9K_RX_QUEUE_LP,
 			      sc->rx.rx_edma[ATH9K_RX_QUEUE_LP].rx_fifo_hwsize);
 
-	spin_unlock_bh(&sc->rx.rxbuflock);
-
 	ath_opmode_init(sc);
 
 	ath9k_hw_startpcureceive(sc->sc_ah, (sc->sc_flags & SC_OP_OFFCHANNEL));
+
+	spin_unlock_bh(&sc->rx.rxbuflock);
 }
 
 static void ath_edma_stop_recv(struct ath_softc *sc)
 {
-	spin_lock_bh(&sc->rx.rxbuflock);
 	ath_rx_remove_buffer(sc, ATH9K_RX_QUEUE_HP);
 	ath_rx_remove_buffer(sc, ATH9K_RX_QUEUE_LP);
-	spin_unlock_bh(&sc->rx.rxbuflock);
 }
 
 int ath_rx_init(struct ath_softc *sc, int nbufs)
@@ -319,7 +317,7 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 	struct ath_buf *bf;
 	int error = 0;
 
-	spin_lock_init(&sc->rx.rxflushlock);
+	spin_lock_init(&sc->rx.pcu_lock);
 	sc->sc_flags &= ~SC_OP_RXFLUSH;
 	spin_lock_init(&sc->rx.rxbuflock);
 
@@ -506,10 +504,11 @@ int ath_startrecv(struct ath_softc *sc)
 	ath9k_hw_rxena(ah);
 
 start_recv:
-	spin_unlock_bh(&sc->rx.rxbuflock);
 	ath_opmode_init(sc);
 	ath9k_hw_startpcureceive(ah, (sc->sc_flags & SC_OP_OFFCHANNEL));
 
+	spin_unlock_bh(&sc->rx.rxbuflock);
+
 	return 0;
 }
 
@@ -518,6 +517,7 @@ bool ath_stoprecv(struct ath_softc *sc)
 	struct ath_hw *ah = sc->sc_ah;
 	bool stopped;
 
+	spin_lock_bh(&sc->rx.rxbuflock);
 	ath9k_hw_stoppcurecv(ah);
 	ath9k_hw_setrxfilter(ah, 0);
 	stopped = ath9k_hw_stopdmarecv(ah);
@@ -526,19 +526,18 @@ bool ath_stoprecv(struct ath_softc *sc)
 		ath_edma_stop_recv(sc);
 	else
 		sc->rx.rxlink = NULL;
+	spin_unlock_bh(&sc->rx.rxbuflock);
 
 	return stopped;
 }
 
 void ath_flushrecv(struct ath_softc *sc)
 {
-	spin_lock_bh(&sc->rx.rxflushlock);
 	sc->sc_flags |= SC_OP_RXFLUSH;
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA)
 		ath_rx_tasklet(sc, 1, true);
 	ath_rx_tasklet(sc, 1, false);
 	sc->sc_flags &= ~SC_OP_RXFLUSH;
-	spin_unlock_bh(&sc->rx.rxflushlock);
 }
 
 static bool ath_beacon_dtim_pending_cab(struct sk_buff *skb)
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 30ef2df..f2ade24 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1089,15 +1089,6 @@ void ath_draintxq(struct ath_softc *sc, struct ath_txq *txq, bool retry_tx)
 	txq->axq_tx_inprogress = false;
 	spin_unlock_bh(&txq->axq_lock);
 
-	/* flush any pending frames if aggregation is enabled */
-	if (sc->sc_flags & SC_OP_TXAGGR) {
-		if (!retry_tx) {
-			spin_lock_bh(&txq->axq_lock);
-			ath_txq_drain_pending_buffers(sc, txq);
-			spin_unlock_bh(&txq->axq_lock);
-		}
-	}
-
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
 		spin_lock_bh(&txq->axq_lock);
 		while (!list_empty(&txq->txq_fifo_pending)) {
@@ -1118,6 +1109,15 @@ void ath_draintxq(struct ath_softc *sc, struct ath_txq *txq, bool retry_tx)
 		}
 		spin_unlock_bh(&txq->axq_lock);
 	}
+
+	/* flush any pending frames if aggregation is enabled */
+	if (sc->sc_flags & SC_OP_TXAGGR) {
+		if (!retry_tx) {
+			spin_lock_bh(&txq->axq_lock);
+			ath_txq_drain_pending_buffers(sc, txq);
+			spin_unlock_bh(&txq->axq_lock);
+		}
+	}
 }
 
 void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
diff --git a/drivers/net/wireless/b43/sdio.c b/drivers/net/wireless/b43/sdio.c
index 45933cf..9a55338 100644
--- a/drivers/net/wireless/b43/sdio.c
+++ b/drivers/net/wireless/b43/sdio.c
@@ -175,7 +175,9 @@ static void b43_sdio_remove(struct sdio_func *func)
 	struct b43_sdio *sdio = sdio_get_drvdata(func);
 
 	ssb_bus_unregister(&sdio->ssb);
+	sdio_claim_host(func);
 	sdio_disable_func(func);
+	sdio_release_host(func);
 	kfree(sdio);
 	sdio_set_drvdata(func, NULL);
 }
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index 296fd00..e5685dc 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -684,18 +684,40 @@ static int if_sdio_prog_firmware(struct if_sdio_card *card)
 
 	lbs_deb_enter(LBS_DEB_SDIO);
 
+	/*
+	 * Disable interrupts
+	 */
+	sdio_claim_host(card->func);
+	sdio_writeb(card->func, 0x00, IF_SDIO_H_INT_MASK, &ret);
+	sdio_release_host(card->func);
+
 	sdio_claim_host(card->func);
 	scratch = if_sdio_read_scratch(card, &ret);
 	sdio_release_host(card->func);
 
+	lbs_deb_sdio("firmware status = %#x\n", scratch);
+	lbs_deb_sdio("scratch ret = %d\n", ret);
+
 	if (ret)
 		goto out;
 
-	lbs_deb_sdio("firmware status = %#x\n", scratch);
 
+	/*
+	 * The manual clearly describes that FEDC is the right code to use
+	 * to detect firmware presence, but for SD8686 it is not that simple.
+	 * Scratch is also used to store the RX packet length, so we lose
+	 * the FEDC value early on. So we use a non-zero check in order
+	 * to validate firmware presence.
+	 * Additionally, the SD8686 in the Gumstix always has the high scratch
+	 * bit set, even when the firmware is not loaded. So we have to
+	 * exclude that from the test.
+	 */
 	if (scratch == IF_SDIO_FIRMWARE_OK) {
 		lbs_deb_sdio("firmware already loaded\n");
 		goto success;
+	} else if ((card->model == MODEL_8686) && (scratch & 0x7fff)) {
+		lbs_deb_sdio("firmware may be running\n");
+		goto success;
 	}
 
 	ret = lbs_get_firmware(&card->func->dev, lbs_helper_name, lbs_fw_name,
@@ -709,10 +731,14 @@ static int if_sdio_prog_firmware(struct if_sdio_card *card)
 	if (ret)
 		goto out;
 
+	lbs_deb_sdio("Helper firmware loaded\n");
+
 	ret = if_sdio_prog_real(card, mainfw);
 	if (ret)
 		goto out;
 
+	lbs_deb_sdio("Firmware loaded\n");
+
 success:
 	sdio_claim_host(card->func);
 	sdio_set_block_size(card->func, IF_SDIO_BLOCK_SIZE);
@@ -1042,8 +1068,6 @@ static int if_sdio_probe(struct sdio_func *func,
 	priv->exit_deep_sleep = if_sdio_exit_deep_sleep;
 	priv->reset_deep_sleep_wakeup = if_sdio_reset_deep_sleep_wakeup;
 
-	priv->fw_ready = 1;
-
 	sdio_claim_host(func);
 
 	/*
@@ -1064,6 +1088,8 @@ static int if_sdio_probe(struct sdio_func *func,
 	if (ret)
 		goto reclaim;
 
+	priv->fw_ready = 1;
+
 	/*
 	 * FUNC_INIT is required for SD8688 WLAN/BT multiple functions
 	 */
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 4aa47d0..1243d1d 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -203,9 +203,13 @@ static ssize_t key_key_read(struct file *file, char __user *userbuf,
 			    size_t count, loff_t *ppos)
 {
 	struct ieee80211_key *key = file->private_data;
-	int i, res, bufsize = 2 * key->conf.keylen + 2;
+	int i, bufsize = 2 * key->conf.keylen + 2;
 	char *buf = kmalloc(bufsize, GFP_KERNEL);
 	char *p = buf;
+	ssize_t res;
+
+	if (!buf)
+		return -ENOMEM;
 
 	for (i = 0; i < key->conf.keylen; i++)
 		p += scnprintf(p, bufsize + buf - p, "%02x", key->conf.key[i]);
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 6b322fa..107a0cb 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -677,10 +677,11 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	/*
 	 * Calculate scan IE length -- we need this to alloc
 	 * memory and to subtract from the driver limit. It
-	 * includes the (extended) supported rates and HT
+	 * includes the DS Params, (extended) supported rates, and HT
 	 * information -- SSID is the driver's responsibility.
 	 */
-	local->scan_ies_len = 4 + max_bitrates; /* (ext) supp rates */
+	local->scan_ies_len = 4 + max_bitrates /* (ext) supp rates */ +
+		3 /* DS Params */;
 	if (supp_ht)
 		local->scan_ies_len += 2 + sizeof(struct ieee80211_ht_cap);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
