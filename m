From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-02-01
Date: Tue, 1 Feb 2011 15:40:10 -0500
Message-ID: <20110201204010.GG2560@tuxdriver.com>
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

Here is another batch of fixes intended for 2.6.38.

Included is a firmware upload fix for rtlwifi, a use after free
fix for wl12xx, a memory fix related to PAPRD for ath9k, a couple
of PM-related fixes for ath9k, fixes for race conditions that lead
to crashes in ath9k and ath9k_htc, and a couple of ath5k fixes, one
related to dma error handling and the other an endian fix.  A email
address change in the MAINTAINERS entry for wl12xx tops it all off. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fca540ab5f4718c6133f71f7be1793066008bf89:

  enc28j60: Fix reading of transmit status vector (2011-01-31 20:56:54 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (2):
      ath5k: fix error handling in ath5k_hw_dma_stop
      ath5k: correct endianness of frame duration

Chaoming Li (1):
      rtlwifi: Fix firmware upload errors

Luciano Coelho (1):
      MAINTAINERS: update information for the wl12xx driver

Mathias Krause (1):
      wl12xx: fix use after free

Mohammed Shafi Shajakhan (1):
      ath9k: Fix memory leak due to failed PAPRD frames

Rajkumar Manoharan (2):
      ath9k_hw: Fix system hang when resuming from S3/S4
      ath9k: Fix power save usage count imbalance on deinit

Stanislaw Gruszka (2):
      ath9k: fix race conditions when stop device
      ath9k_htc: fix race conditions when stop device

 MAINTAINERS                                   |    6 ++--
 drivers/net/wireless/ath/ath5k/dma.c          |    4 +-
 drivers/net/wireless/ath/ath5k/pcu.c          |    4 +--
 drivers/net/wireless/ath/ath9k/ar9002_hw.c    |    3 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    3 --
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |   21 +++++++++----
 drivers/net/wireless/ath/ath9k/init.c         |    7 +---
 drivers/net/wireless/ath/ath9k/main.c         |   19 ++++++++++--
 drivers/net/wireless/rtlwifi/efuse.c          |   40 ++++++++++++------------
 drivers/net/wireless/wl12xx/spi.c             |    3 +-
 10 files changed, 61 insertions(+), 49 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c9ec9d8..a5deb42 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6612,12 +6612,12 @@ S:	Maintained
 F:	drivers/net/wireless/wl1251/*
 
 WL1271 WIRELESS DRIVER
-M:	Luciano Coelho <luciano.coelho@nokia.com>
+M:	Luciano Coelho <coelho@ti.com>
 L:	linux-wireless@vger.kernel.org
-W:	http://wireless.kernel.org
+W:	http://wireless.kernel.org/en/users/Drivers/wl12xx
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/luca/wl12xx.git
 S:	Maintained
-F:	drivers/net/wireless/wl12xx/wl1271*
+F:	drivers/net/wireless/wl12xx/
 F:	include/linux/wl12xx.h
 
 WL3501 WIRELESS PCMCIA CARD DRIVER
diff --git a/drivers/net/wireless/ath/ath5k/dma.c b/drivers/net/wireless/ath/ath5k/dma.c
index 0064be7..21091c2 100644
--- a/drivers/net/wireless/ath/ath5k/dma.c
+++ b/drivers/net/wireless/ath/ath5k/dma.c
@@ -838,9 +838,9 @@ int ath5k_hw_dma_stop(struct ath5k_hw *ah)
 	for (i = 0; i < qmax; i++) {
 		err = ath5k_hw_stop_tx_dma(ah, i);
 		/* -EINVAL -> queue inactive */
-		if (err != -EINVAL)
+		if (err && err != -EINVAL)
 			return err;
 	}
 
-	return err;
+	return 0;
 }
diff --git a/drivers/net/wireless/ath/ath5k/pcu.c b/drivers/net/wireless/ath/ath5k/pcu.c
index e5f2b96..a702817 100644
--- a/drivers/net/wireless/ath/ath5k/pcu.c
+++ b/drivers/net/wireless/ath/ath5k/pcu.c
@@ -86,7 +86,7 @@ int ath5k_hw_get_frame_duration(struct ath5k_hw *ah,
 	if (!ah->ah_bwmode) {
 		dur = ieee80211_generic_frame_duration(sc->hw,
 						NULL, len, rate);
-		return dur;
+		return le16_to_cpu(dur);
 	}
 
 	bitrate = rate->bitrate;
@@ -265,8 +265,6 @@ static inline void ath5k_hw_write_rate_duration(struct ath5k_hw *ah)
 		 * what rate we should choose to TX ACKs. */
 		tx_time = ath5k_hw_get_frame_duration(ah, 10, rate);
 
-		tx_time = le16_to_cpu(tx_time);
-
 		ath5k_hw_reg_write(ah, tx_time, reg);
 
 		if (!(rate->flags & IEEE80211_RATE_SHORT_PREAMBLE))
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index f8a7771..f44c84a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -426,9 +426,8 @@ static void ar9002_hw_configpcipowersave(struct ath_hw *ah,
 		}
 
 		/* WAR for ASPM system hang */
-		if (AR_SREV_9280(ah) || AR_SREV_9285(ah) || AR_SREV_9287(ah)) {
+		if (AR_SREV_9285(ah) || AR_SREV_9287(ah))
 			val |= (AR_WA_BIT6 | AR_WA_BIT7);
-		}
 
 		if (AR_SREV_9285E_20(ah))
 			val |= AR_WA_BIT23;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 38433f9..0352f09 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -142,9 +142,6 @@ static void ath9k_deinit_priv(struct ath9k_htc_priv *priv)
 {
 	ath9k_htc_exit_debug(priv->ah);
 	ath9k_hw_deinit(priv->ah);
-	tasklet_kill(&priv->swba_tasklet);
-	tasklet_kill(&priv->rx_tasklet);
-	tasklet_kill(&priv->tx_tasklet);
 	kfree(priv->ah);
 	priv->ah = NULL;
 }
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index f4d576b..6bb5995 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -1025,12 +1025,6 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 	int ret = 0;
 	u8 cmd_rsp;
 
-	/* Cancel all the running timers/work .. */
-	cancel_work_sync(&priv->fatal_work);
-	cancel_work_sync(&priv->ps_work);
-	cancel_delayed_work_sync(&priv->ath9k_led_blink_work);
-	ath9k_led_stop_brightness(priv);
-
 	mutex_lock(&priv->mutex);
 
 	if (priv->op_flags & OP_INVALID) {
@@ -1044,8 +1038,23 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 	WMI_CMD(WMI_DISABLE_INTR_CMDID);
 	WMI_CMD(WMI_DRAIN_TXQ_ALL_CMDID);
 	WMI_CMD(WMI_STOP_RECV_CMDID);
+
+	tasklet_kill(&priv->swba_tasklet);
+	tasklet_kill(&priv->rx_tasklet);
+	tasklet_kill(&priv->tx_tasklet);
+
 	skb_queue_purge(&priv->tx_queue);
 
+	mutex_unlock(&priv->mutex);
+
+	/* Cancel all the running timers/work .. */
+	cancel_work_sync(&priv->fatal_work);
+	cancel_work_sync(&priv->ps_work);
+	cancel_delayed_work_sync(&priv->ath9k_led_blink_work);
+	ath9k_led_stop_brightness(priv);
+
+	mutex_lock(&priv->mutex);
+
 	/* Remove monitor interface here */
 	if (ah->opmode == NL80211_IFTYPE_MONITOR) {
 		if (ath9k_htc_remove_monitor_interface(priv))
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 767d8b8..087a6a9 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -598,8 +598,6 @@ err_btcoex:
 err_queues:
 	ath9k_hw_deinit(ah);
 err_hw:
-	tasklet_kill(&sc->intr_tq);
-	tasklet_kill(&sc->bcon_tasklet);
 
 	kfree(ah);
 	sc->sc_ah = NULL;
@@ -807,9 +805,6 @@ static void ath9k_deinit_softc(struct ath_softc *sc)
 
 	ath9k_hw_deinit(sc->sc_ah);
 
-	tasklet_kill(&sc->intr_tq);
-	tasklet_kill(&sc->bcon_tasklet);
-
 	kfree(sc->sc_ah);
 	sc->sc_ah = NULL;
 }
@@ -824,6 +819,8 @@ void ath9k_deinit_device(struct ath_softc *sc)
 	wiphy_rfkill_stop_polling(sc->hw->wiphy);
 	ath_deinit_leds(sc);
 
+	ath9k_ps_restore(sc);
+
 	for (i = 0; i < sc->num_sec_wiphy; i++) {
 		struct ath_wiphy *aphy = sc->sec_wiphy[i];
 		if (aphy == NULL)
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index c79c97b..9040c2f 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -325,6 +325,8 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 {
 	struct ieee80211_hw *hw = sc->hw;
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
+	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath_tx_control txctl;
 	int time_left;
 
@@ -342,8 +344,12 @@ static bool ath_paprd_send_frame(struct ath_softc *sc, struct sk_buff *skb, int
 	init_completion(&sc->paprd_complete);
 	sc->paprd_pending = true;
 	txctl.paprd = BIT(chain);
-	if (ath_tx_start(hw, skb, &txctl) != 0)
+
+	if (ath_tx_start(hw, skb, &txctl) != 0) {
+		ath_dbg(common, ATH_DBG_XMIT, "PAPRD TX failed\n");
+		dev_kfree_skb_any(skb);
 		return false;
+	}
 
 	time_left = wait_for_completion_timeout(&sc->paprd_complete,
 			msecs_to_jiffies(ATH_PAPRD_TIMEOUT));
@@ -953,8 +959,6 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	spin_unlock_bh(&sc->sc_pcu_lock);
 	ath9k_ps_restore(sc);
-
-	ath9k_setpower(sc, ATH9K_PM_FULL_SLEEP);
 }
 
 int ath_reset(struct ath_softc *sc, bool retry_tx)
@@ -1309,6 +1313,9 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	spin_lock_bh(&sc->sc_pcu_lock);
 
+	/* prevent tasklets to enable interrupts once we disable them */
+	ah->imask &= ~ATH9K_INT_GLOBAL;
+
 	/* make sure h/w will not generate any interrupt
 	 * before setting the invalid flag. */
 	ath9k_hw_disable_interrupts(ah);
@@ -1326,6 +1333,12 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	spin_unlock_bh(&sc->sc_pcu_lock);
 
+	/* we can now sync irq and kill any running tasklets, since we already
+	 * disabled interrupts and not holding a spin lock */
+	synchronize_irq(sc->irq);
+	tasklet_kill(&sc->intr_tq);
+	tasklet_kill(&sc->bcon_tasklet);
+
 	ath9k_ps_restore(sc);
 
 	sc->ps_idle = true;
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index b8433f3..62876cd 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -726,9 +726,9 @@ static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 }
 
 static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
-				u8 efuse_data, u8 offset, int *bcontinual,
-				u8 *write_state, struct pgpkt_struct target_pkt,
-				int *repeat_times, int *bresult, u8 word_en)
+			u8 efuse_data, u8 offset, int *bcontinual,
+			u8 *write_state, struct pgpkt_struct *target_pkt,
+			int *repeat_times, int *bresult, u8 word_en)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct pgpkt_struct tmp_pkt;
@@ -744,8 +744,8 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 	tmp_pkt.word_en = tmp_header & 0x0F;
 	tmp_word_cnts = efuse_calculate_word_cnts(tmp_pkt.word_en);
 
-	if (tmp_pkt.offset != target_pkt.offset) {
-		efuse_addr = efuse_addr + (tmp_word_cnts * 2) + 1;
+	if (tmp_pkt.offset != target_pkt->offset) {
+		*efuse_addr = *efuse_addr + (tmp_word_cnts * 2) + 1;
 		*write_state = PG_STATE_HEADER;
 	} else {
 		for (tmpindex = 0; tmpindex < (tmp_word_cnts * 2); tmpindex++) {
@@ -756,23 +756,23 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 		}
 
 		if (bdataempty == false) {
-			efuse_addr = efuse_addr + (tmp_word_cnts * 2) + 1;
+			*efuse_addr = *efuse_addr + (tmp_word_cnts * 2) + 1;
 			*write_state = PG_STATE_HEADER;
 		} else {
 			match_word_en = 0x0F;
-			if (!((target_pkt.word_en & BIT(0)) |
+			if (!((target_pkt->word_en & BIT(0)) |
 			     (tmp_pkt.word_en & BIT(0))))
 				match_word_en &= (~BIT(0));
 
-			if (!((target_pkt.word_en & BIT(1)) |
+			if (!((target_pkt->word_en & BIT(1)) |
 			     (tmp_pkt.word_en & BIT(1))))
 				match_word_en &= (~BIT(1));
 
-			if (!((target_pkt.word_en & BIT(2)) |
+			if (!((target_pkt->word_en & BIT(2)) |
 			     (tmp_pkt.word_en & BIT(2))))
 				match_word_en &= (~BIT(2));
 
-			if (!((target_pkt.word_en & BIT(3)) |
+			if (!((target_pkt->word_en & BIT(3)) |
 			     (tmp_pkt.word_en & BIT(3))))
 				match_word_en &= (~BIT(3));
 
@@ -780,7 +780,7 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 				badworden = efuse_word_enable_data_write(
 							    hw, *efuse_addr + 1,
 							    tmp_pkt.word_en,
-							    target_pkt.data);
+							    target_pkt->data);
 
 				if (0x0F != (badworden & 0x0F)) {
 					u8 reorg_offset = offset;
@@ -791,26 +791,26 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 				}
 
 				tmp_word_en = 0x0F;
-				if ((target_pkt.word_en & BIT(0)) ^
+				if ((target_pkt->word_en & BIT(0)) ^
 				    (match_word_en & BIT(0)))
 					tmp_word_en &= (~BIT(0));
 
-				if ((target_pkt.word_en & BIT(1)) ^
+				if ((target_pkt->word_en & BIT(1)) ^
 				    (match_word_en & BIT(1)))
 					tmp_word_en &= (~BIT(1));
 
-				if ((target_pkt.word_en & BIT(2)) ^
+				if ((target_pkt->word_en & BIT(2)) ^
 					(match_word_en & BIT(2)))
 					tmp_word_en &= (~BIT(2));
 
-				if ((target_pkt.word_en & BIT(3)) ^
+				if ((target_pkt->word_en & BIT(3)) ^
 				    (match_word_en & BIT(3)))
 					tmp_word_en &= (~BIT(3));
 
 				if ((tmp_word_en & 0x0F) != 0x0F) {
 					*efuse_addr = efuse_get_current_size(hw);
-					target_pkt.offset = offset;
-					target_pkt.word_en = tmp_word_en;
+					target_pkt->offset = offset;
+					target_pkt->word_en = tmp_word_en;
 				} else
 					*bcontinual = false;
 				*write_state = PG_STATE_HEADER;
@@ -821,8 +821,8 @@ static void efuse_write_data_case1(struct ieee80211_hw *hw, u16 *efuse_addr,
 				}
 			} else {
 				*efuse_addr += (2 * tmp_word_cnts) + 1;
-				target_pkt.offset = offset;
-				target_pkt.word_en = word_en;
+				target_pkt->offset = offset;
+				target_pkt->word_en = word_en;
 				*write_state = PG_STATE_HEADER;
 			}
 		}
@@ -938,7 +938,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 				efuse_write_data_case1(hw, &efuse_addr,
 						       efuse_data, offset,
 						       &bcontinual,
-						       &write_state, target_pkt,
+						       &write_state, &target_pkt,
 						       &repeat_times, &bresult,
 						       word_en);
 			else
diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index 4671491..7145ea5 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -110,9 +110,8 @@ static void wl1271_spi_reset(struct wl1271 *wl)
 	spi_message_add_tail(&t, &m);
 
 	spi_sync(wl_to_spi(wl), &m);
-	kfree(cmd);
-
 	wl1271_dump(DEBUG_SPI, "spi reset -> ", cmd, WSPI_INIT_CMD_LEN);
+	kfree(cmd);
 }
 
 static void wl1271_spi_init(struct wl1271 *wl)
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
