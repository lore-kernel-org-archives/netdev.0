From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-12-10
Date: Fri, 10 Dec 2010 15:29:03 -0500
Message-ID: <20101210202902.GG4296@tuxdriver.com>
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

Here is the latest round of wireless bits intended for 2.6.37...

Included are some orinoco fixes, one to avoid the crash in bug 23932 and
two others that render TKIP countermeasures ineffective (i.e. decreased
security).  Helmut has provided us a fix to avoid a BUG when using
shared skbs.  The ath9k team gives us a fix for failed resumes on
ath9k_htc, a fix for detecting broadcast frames with a MIC failure, a
fix for a null pointer access when generating beacons, and a DMA issue
that can lead to memory corruption.  Matteo Croce pitches-in with a fix
to prevent transmitting with too much power.  Finally,  Javier Cardona
provides a trio of ath5k fixes that restore mesh function on those
devices.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f19872575ff7819a3723154657a497d9bca66b33:

  tcp: protect sysctl_tcp_cookie_size reads (2010-12-08 12:34:09 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

David Kilroy (3):
      orinoco: initialise priv->hw before assigning the interrupt
      orinoco: clear countermeasure setting on commit
      orinoco: fix TKIP countermeasure behaviour

Felix Fietkau (1):
      ath9k: fix a DMA related race condition on reset

Helmut Schaa (1):
      mac80211: Fix BUG in pskb_expand_head when transmitting shared skbs

Javier Cardona (3):
      ath5k: Fix beaconing in mesh mode
      ath5k: Prevent mesh interfaces from being counted as ad-hoc
      ath5k: Put the right tsf value in mesh beacons

Matteo Croce (1):
      ath9k: fix bug in tx power

Rajkumar Manoharan (1):
      ath9k: fix beacon resource related race condition

Senthil Balasubramanian (1):
      ath9k: Fix STA disconnect issue due to received MIC failed bcast frames

Sujith Manoharan (1):
      ath9k_htc: Fix suspend/resume

 drivers/net/wireless/ath/ath5k/base.c         |   13 +++++++----
 drivers/net/wireless/ath/ath9k/ath9k.h        |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c   |   12 +++++++---
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    7 ++++++
 drivers/net/wireless/ath/ath9k/htc.h          |    3 ++
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    6 +++++
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    4 +-
 drivers/net/wireless/ath/ath9k/mac.c          |    3 +-
 drivers/net/wireless/ath/ath9k/main.c         |   26 +++++++++---------------
 drivers/net/wireless/ath/ath9k/recv.c         |    9 +++++++-
 drivers/net/wireless/ath/ath9k/xmit.c         |   22 +++++---------------
 drivers/net/wireless/orinoco/main.c           |    6 +++++
 drivers/net/wireless/orinoco/orinoco_cs.c     |   14 ++++++------
 drivers/net/wireless/orinoco/spectrum_cs.c    |   14 ++++++------
 drivers/net/wireless/orinoco/wext.c           |    4 +-
 net/mac80211/tx.c                             |   21 +++++++++++++++++--
 16 files changed, 100 insertions(+), 66 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 8251946..42ed923 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1917,7 +1917,8 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 		sc->bmisscount = 0;
 	}
 
-	if (sc->opmode == NL80211_IFTYPE_AP && sc->num_ap_vifs > 1) {
+	if ((sc->opmode == NL80211_IFTYPE_AP && sc->num_ap_vifs > 1) ||
+			sc->opmode == NL80211_IFTYPE_MESH_POINT) {
 		u64 tsf = ath5k_hw_get_tsf64(ah);
 		u32 tsftu = TSF_TO_TU(tsf);
 		int slot = ((tsftu % sc->bintval) * ATH_BCBUF) / sc->bintval;
@@ -1949,8 +1950,9 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 		/* NB: hw still stops DMA, so proceed */
 	}
 
-	/* refresh the beacon for AP mode */
-	if (sc->opmode == NL80211_IFTYPE_AP)
+	/* refresh the beacon for AP or MESH mode */
+	if (sc->opmode == NL80211_IFTYPE_AP ||
+			sc->opmode == NL80211_IFTYPE_MESH_POINT)
 		ath5k_beacon_update(sc->hw, vif);
 
 	ath5k_hw_set_txdp(ah, sc->bhalq, bf->daddr);
@@ -2851,7 +2853,8 @@ static int ath5k_add_interface(struct ieee80211_hw *hw,
 
 	/* Assign the vap/adhoc to a beacon xmit slot. */
 	if ((avf->opmode == NL80211_IFTYPE_AP) ||
-	    (avf->opmode == NL80211_IFTYPE_ADHOC)) {
+	    (avf->opmode == NL80211_IFTYPE_ADHOC) ||
+	    (avf->opmode == NL80211_IFTYPE_MESH_POINT)) {
 		int slot;
 
 		WARN_ON(list_empty(&sc->bcbuf));
@@ -2870,7 +2873,7 @@ static int ath5k_add_interface(struct ieee80211_hw *hw,
 		sc->bslot[avf->bslot] = vif;
 		if (avf->opmode == NL80211_IFTYPE_AP)
 			sc->num_ap_vifs++;
-		else
+		else if (avf->opmode == NL80211_IFTYPE_ADHOC)
 			sc->num_adhoc_vifs++;
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 0d0bec3..0963071 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -329,7 +329,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp);
 struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype);
 void ath_tx_cleanupq(struct ath_softc *sc, struct ath_txq *txq);
 int ath_tx_setup(struct ath_softc *sc, int haltype);
-void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx);
+bool ath_drain_all_txq(struct ath_softc *sc, bool retry_tx);
 void ath_draintxq(struct ath_softc *sc,
 		     struct ath_txq *txq, bool retry_tx);
 void ath_tx_node_init(struct ath_softc *sc, struct ath_node *an);
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index 526d7c9..a3ccb1b 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -1063,15 +1063,19 @@ static void ath9k_hw_set_def_power_per_rate_table(struct ath_hw *ah,
 	case 1:
 		break;
 	case 2:
-		scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_TWO_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_TWO_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	case 3:
-		scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		if (scaledPower > REDUCE_SCALED_POWER_BY_THREE_CHAIN)
+			scaledPower -= REDUCE_SCALED_POWER_BY_THREE_CHAIN;
+		else
+			scaledPower = 0;
 		break;
 	}
 
-	scaledPower = max((u16)0, scaledPower);
-
 	if (IS_CHAN_2GHZ(chan)) {
 		numCtlModes = ARRAY_SIZE(ctlModesFor11g) -
 			SUB_NUM_CTL_MODES_AT_2G_40;
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index dfb6560..0de3c3d 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -1024,6 +1024,13 @@ static int ath9k_hif_usb_suspend(struct usb_interface *interface,
 	struct hif_device_usb *hif_dev =
 		(struct hif_device_usb *) usb_get_intfdata(interface);
 
+	/*
+	 * The device has to be set to FULLSLEEP mode in case no
+	 * interface is up.
+	 */
+	if (!(hif_dev->flags & HIF_USB_START))
+		ath9k_htc_suspend(hif_dev->htc_handle);
+
 	ath9k_hif_usb_dealloc_urbs(hif_dev);
 
 	return 0;
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index 75ecf6a..c3b561d 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -455,6 +455,8 @@ u32 ath9k_htc_calcrxfilter(struct ath9k_htc_priv *priv);
 void ath9k_htc_ps_wakeup(struct ath9k_htc_priv *priv);
 void ath9k_htc_ps_restore(struct ath9k_htc_priv *priv);
 void ath9k_ps_work(struct work_struct *work);
+bool ath9k_htc_setpower(struct ath9k_htc_priv *priv,
+			enum ath9k_power_mode mode);
 
 void ath9k_start_rfkill_poll(struct ath9k_htc_priv *priv);
 void ath9k_init_leds(struct ath9k_htc_priv *priv);
@@ -464,6 +466,7 @@ int ath9k_htc_probe_device(struct htc_target *htc_handle, struct device *dev,
 			   u16 devid, char *product);
 void ath9k_htc_disconnect_device(struct htc_target *htc_handle, bool hotunplug);
 #ifdef CONFIG_PM
+void ath9k_htc_suspend(struct htc_target *htc_handle);
 int ath9k_htc_resume(struct htc_target *htc_handle);
 #endif
 #ifdef CONFIG_ATH9K_HTC_DEBUGFS
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 7c8a38d..8776f49 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -891,6 +891,12 @@ void ath9k_htc_disconnect_device(struct htc_target *htc_handle, bool hotunplug)
 }
 
 #ifdef CONFIG_PM
+
+void ath9k_htc_suspend(struct htc_target *htc_handle)
+{
+	ath9k_htc_setpower(htc_handle->drv_priv, ATH9K_PM_FULL_SLEEP);
+}
+
 int ath9k_htc_resume(struct htc_target *htc_handle)
 {
 	int ret;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 9a3be8d..51977ca 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -63,8 +63,8 @@ static enum htc_phymode ath9k_htc_get_curmode(struct ath9k_htc_priv *priv,
 	return mode;
 }
 
-static bool ath9k_htc_setpower(struct ath9k_htc_priv *priv,
-			       enum ath9k_power_mode mode)
+bool ath9k_htc_setpower(struct ath9k_htc_priv *priv,
+			enum ath9k_power_mode mode)
 {
 	bool ret;
 
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index 8c13479..c996963 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -703,8 +703,7 @@ int ath9k_hw_rxprocdesc(struct ath_hw *ah, struct ath_desc *ds,
 			rs->rs_phyerr = phyerr;
 		} else if (ads.ds_rxstatus8 & AR_DecryptCRCErr)
 			rs->rs_status |= ATH9K_RXERR_DECRYPT;
-		else if ((ads.ds_rxstatus8 & AR_MichaelErr) &&
-		         rs->rs_keyix != ATH9K_RXKEYIX_INVALID)
+		else if (ads.ds_rxstatus8 & AR_MichaelErr)
 			rs->rs_status |= ATH9K_RXERR_MIC;
 		else if (ads.ds_rxstatus8 & AR_KeyMiss)
 			rs->rs_status |= ATH9K_RXERR_DECRYPT;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index dace215..c0c3464 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -244,11 +244,12 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	 * the relevant bits of the h/w.
 	 */
 	ath9k_hw_set_interrupts(ah, 0);
-	ath_drain_all_txq(sc, false);
+	stopped = ath_drain_all_txq(sc, false);
 
 	spin_lock_bh(&sc->rx.pcu_lock);
 
-	stopped = ath_stoprecv(sc);
+	if (!ath_stoprecv(sc))
+		stopped = false;
 
 	/* XXX: do not flush receive queue here. We don't want
 	 * to flush data frames already in queue because of
@@ -1519,8 +1520,6 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	struct ath_softc *sc = aphy->sc;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_vif *avp = (void *)vif->drv_priv;
-	bool bs_valid = false;
-	int i;
 
 	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
@@ -1534,26 +1533,21 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	if ((sc->sc_ah->opmode == NL80211_IFTYPE_AP) ||
 	    (sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC) ||
 	    (sc->sc_ah->opmode == NL80211_IFTYPE_MESH_POINT)) {
+		/* Disable SWBA interrupt */
+		sc->sc_ah->imask &= ~ATH9K_INT_SWBA;
 		ath9k_ps_wakeup(sc);
+		ath9k_hw_set_interrupts(sc->sc_ah, sc->sc_ah->imask);
 		ath9k_hw_stoptxdma(sc->sc_ah, sc->beacon.beaconq);
 		ath9k_ps_restore(sc);
+		tasklet_kill(&sc->bcon_tasklet);
 	}
 
 	ath_beacon_return(sc, avp);
 	sc->sc_flags &= ~SC_OP_BEACONS;
 
-	for (i = 0; i < ARRAY_SIZE(sc->beacon.bslot); i++) {
-		if (sc->beacon.bslot[i] == vif) {
-			printk(KERN_DEBUG "%s: vif had allocated beacon "
-			       "slot\n", __func__);
-			sc->beacon.bslot[i] = NULL;
-			sc->beacon.bslot_aphy[i] = NULL;
-		} else if (sc->beacon.bslot[i])
-			bs_valid = true;
-	}
-	if (!bs_valid && (sc->sc_ah->imask & ATH9K_INT_SWBA)) {
-		/* Disable SWBA interrupt */
-		sc->sc_ah->imask &= ~ATH9K_INT_SWBA;
+	if (sc->nbcnvifs) {
+		/* Re-enable SWBA interrupt */
+		sc->sc_ah->imask |= ATH9K_INT_SWBA;
 		ath9k_ps_wakeup(sc);
 		ath9k_hw_set_interrupts(sc->sc_ah, sc->sc_ah->imask);
 		ath9k_ps_restore(sc);
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 1a62e35..fdc2ec5 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -838,6 +838,10 @@ static bool ath9k_rx_accept(struct ath_common *common,
 			    struct ath_rx_status *rx_stats,
 			    bool *decrypt_error)
 {
+#define is_mc_or_valid_tkip_keyix ((is_mc ||			\
+		(rx_stats->rs_keyix != ATH9K_RXKEYIX_INVALID && \
+		test_bit(rx_stats->rs_keyix, common->tkip_keymap))))
+
 	struct ath_hw *ah = common->ah;
 	__le16 fc;
 	u8 rx_status_len = ah->caps.rx_status_len;
@@ -879,15 +883,18 @@ static bool ath9k_rx_accept(struct ath_common *common,
 		if (rx_stats->rs_status & ATH9K_RXERR_DECRYPT) {
 			*decrypt_error = true;
 		} else if (rx_stats->rs_status & ATH9K_RXERR_MIC) {
+			bool is_mc;
 			/*
 			 * The MIC error bit is only valid if the frame
 			 * is not a control frame or fragment, and it was
 			 * decrypted using a valid TKIP key.
 			 */
+			is_mc = !!is_multicast_ether_addr(hdr->addr1);
+
 			if (!ieee80211_is_ctl(fc) &&
 			    !ieee80211_has_morefrags(fc) &&
 			    !(le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) &&
-			    test_bit(rx_stats->rs_keyix, common->tkip_keymap))
+			    is_mc_or_valid_tkip_keyix)
 				rxs->flag |= RX_FLAG_MMIC_ERROR;
 			else
 				rx_stats->rs_status &= ~ATH9K_RXERR_MIC;
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index f2ade24..aff0478 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1120,7 +1120,7 @@ void ath_draintxq(struct ath_softc *sc, struct ath_txq *txq, bool retry_tx)
 	}
 }
 
-void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
+bool ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 {
 	struct ath_hw *ah = sc->sc_ah;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
@@ -1128,7 +1128,7 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 	int i, npend = 0;
 
 	if (sc->sc_flags & SC_OP_INVALID)
-		return;
+		return true;
 
 	/* Stop beacon queue */
 	ath9k_hw_stoptxdma(sc->sc_ah, sc->beacon.beaconq);
@@ -1142,25 +1142,15 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 		}
 	}
 
-	if (npend) {
-		int r;
-
-		ath_print(common, ATH_DBG_FATAL,
-			  "Failed to stop TX DMA. Resetting hardware!\n");
-
-		spin_lock_bh(&sc->sc_resetlock);
-		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
-		if (r)
-			ath_print(common, ATH_DBG_FATAL,
-				  "Unable to reset hardware; reset status %d\n",
-				  r);
-		spin_unlock_bh(&sc->sc_resetlock);
-	}
+	if (npend)
+		ath_print(common, ATH_DBG_FATAL, "Failed to stop TX DMA!\n");
 
 	for (i = 0; i < ATH9K_NUM_TX_QUEUES; i++) {
 		if (ATH_TXQ_SETUP(sc, i))
 			ath_draintxq(sc, &sc->tx.txq[i], retry_tx);
 	}
+
+	return !npend;
 }
 
 void ath_tx_cleanupq(struct ath_softc *sc, struct ath_txq *txq)
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index fa0cf74..f3d396e 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1811,6 +1811,12 @@ static int __orinoco_commit(struct orinoco_private *priv)
 	struct net_device *dev = priv->ndev;
 	int err = 0;
 
+	/* If we've called commit, we are reconfiguring or bringing the
+	 * interface up. Maintaining countermeasures across this would
+	 * be confusing, so note that we've disabled them. The port will
+	 * be enabled later in orinoco_commit or __orinoco_up. */
+	priv->tkip_cm_active = 0;
+
 	err = orinoco_hw_program_rids(priv);
 
 	/* FIXME: what about netif_tx_lock */
diff --git a/drivers/net/wireless/orinoco/orinoco_cs.c b/drivers/net/wireless/orinoco/orinoco_cs.c
index 71b3d68..32954c4 100644
--- a/drivers/net/wireless/orinoco/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco/orinoco_cs.c
@@ -151,20 +151,20 @@ orinoco_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	ret = pcmcia_request_irq(link, orinoco_interrupt);
-	if (ret)
-		goto failed;
-
-	/* We initialize the hermes structure before completing PCMCIA
-	 * configuration just in case the interrupt handler gets
-	 * called. */
 	mem = ioport_map(link->resource[0]->start,
 			resource_size(link->resource[0]));
 	if (!mem)
 		goto failed;
 
+	/* We initialize the hermes structure before completing PCMCIA
+	 * configuration just in case the interrupt handler gets
+	 * called. */
 	hermes_struct_init(hw, mem, HERMES_16BIT_REGSPACING);
 
+	ret = pcmcia_request_irq(link, orinoco_interrupt);
+	if (ret)
+		goto failed;
+
 	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
diff --git a/drivers/net/wireless/orinoco/spectrum_cs.c b/drivers/net/wireless/orinoco/spectrum_cs.c
index fb859a5..db34c28 100644
--- a/drivers/net/wireless/orinoco/spectrum_cs.c
+++ b/drivers/net/wireless/orinoco/spectrum_cs.c
@@ -214,21 +214,21 @@ spectrum_cs_config(struct pcmcia_device *link)
 		goto failed;
 	}
 
-	ret = pcmcia_request_irq(link, orinoco_interrupt);
-	if (ret)
-		goto failed;
-
-	/* We initialize the hermes structure before completing PCMCIA
-	 * configuration just in case the interrupt handler gets
-	 * called. */
 	mem = ioport_map(link->resource[0]->start,
 			resource_size(link->resource[0]));
 	if (!mem)
 		goto failed;
 
+	/* We initialize the hermes structure before completing PCMCIA
+	 * configuration just in case the interrupt handler gets
+	 * called. */
 	hermes_struct_init(hw, mem, HERMES_16BIT_REGSPACING);
 	hw->eeprom_pda = true;
 
+	ret = pcmcia_request_irq(link, orinoco_interrupt);
+	if (ret)
+		goto failed;
+
 	ret = pcmcia_enable_device(link);
 	if (ret)
 		goto failed;
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 93505f9..e5afabe 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -911,10 +911,10 @@ static int orinoco_ioctl_set_auth(struct net_device *dev,
 		 */
 		if (param->value) {
 			priv->tkip_cm_active = 1;
-			ret = hermes_enable_port(hw, 0);
+			ret = hermes_disable_port(hw, 0);
 		} else {
 			priv->tkip_cm_active = 0;
-			ret = hermes_disable_port(hw, 0);
+			ret = hermes_enable_port(hw, 0);
 		}
 		break;
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index df6aac5..7a637b8 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1737,15 +1737,13 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	int nh_pos, h_pos;
 	struct sta_info *sta = NULL;
 	u32 sta_flags = 0;
+	struct sk_buff *tmp_skb;
 
 	if (unlikely(skb->len < ETH_HLEN)) {
 		ret = NETDEV_TX_OK;
 		goto fail;
 	}
 
-	nh_pos = skb_network_header(skb) - skb->data;
-	h_pos = skb_transport_header(skb) - skb->data;
-
 	/* convert Ethernet header to proper 802.11 header (based on
 	 * operation mode) */
 	ethertype = (skb->data[12] << 8) | skb->data[13];
@@ -1918,6 +1916,20 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		goto fail;
 	}
 
+	/*
+	 * If the skb is shared we need to obtain our own copy.
+	 */
+	if (skb_shared(skb)) {
+		tmp_skb = skb;
+		skb = skb_copy(skb, GFP_ATOMIC);
+		kfree_skb(tmp_skb);
+
+		if (!skb) {
+			ret = NETDEV_TX_OK;
+			goto fail;
+		}
+	}
+
 	hdr.frame_control = fc;
 	hdr.duration_id = 0;
 	hdr.seq_ctrl = 0;
@@ -1936,6 +1948,9 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 		encaps_len = 0;
 	}
 
+	nh_pos = skb_network_header(skb) - skb->data;
+	h_pos = skb_transport_header(skb) - skb->data;
+
 	skb_pull(skb, skip_header_bytes);
 	nh_pos -= skip_header_bytes;
 	h_pos -= skip_header_bytes;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
