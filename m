From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-12-29
Date: Tue, 29 Dec 2009 16:12:23 -0500
Message-ID: <20091229211223.GA6104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752746AbZL2VPi@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a somewhat large batch of fixes intended for 2.6.33.  Most of
them are simple, straightforward, and small.  There is one from Johannes
that removes a lot of code, but the code it removes is unused and the
patch quiets a lot of build SPAM.

This also includes the revert of a b43 patch that is causing some
problems for people.  It does some (apparently unnecessary) alignment
checking that causes some allocations to fail.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 92c6f8d849178582fc527aaf1e51dd37a74767d3:
  Benjamin Herrenschmidt (1):
        ps3_gelic_wireless: Fix build failure due to missing WEXT_PRIV

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrey Borzenkov (1):
      orinoco: fix GFP_KERNEL in orinoco_set_key with interrupts disabled

Bob Copeland (1):
      ath5k: fix SWI calibration interrupt storm

Dan Carpenter (1):
      wl1271_cmd.c: cleanup char => u8

Felix Fietkau (2):
      mac80211: fix ibss join with fixed-bssid
      ath9k: fix missed error codes in the tx status check

Gertjan van Wingerde (1):
      rt2x00: Add USB ID for Linksys WUSB 600N rev 2.

Johannes Berg (3):
      wireless: remove remaining qual code
      cfg80211: fix race between deauth and assoc response
      cfg80211: fix error path in cfg80211_wext_siwscan

John W. Linville (1):
      Revert "b43: Enforce DMA descriptor memory constraints"

Luis R. Rodriguez (4):
      ath9k: wake hardware for interface IBSS/AP/Mesh removal
      ath9k: wake hardware during AMPDU TX actions
      mac80211: fix race with suspend and dynamic_ps_disable_work
      mac80211: fix propagation of failed hardware reconfigurations

Roel Kluin (1):
      wl1251: timeout one too soon in wl1251_boot_run_firmware()

Samuel Ortiz (1):
      libertas: Remove carrier signaling from the scan code

Sujith (1):
      ath9k: fix suspend by waking device prior to stop

Tobias Klauser (2):
      ath9k: Storage class should be before const qualifier
      iwlwifi: Storage class should be before const qualifier

Zhu Yi (1):
      iwmc3200wifi: fix array out-of-boundary access

 drivers/net/wireless/ath/ath5k/base.c       |   18 +--
 drivers/net/wireless/ath/ath9k/mac.h        |    3 +
 drivers/net/wireless/ath/ath9k/main.c       |   14 ++
 drivers/net/wireless/ath/ath9k/pci.c        |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c       |    2 +-
 drivers/net/wireless/b43/dma.c              |  197 ++++++---------------------
 drivers/net/wireless/b43/dma.h              |    7 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   48 +------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   41 ------
 drivers/net/wireless/iwmc3200wifi/iwm.h     |    2 +-
 drivers/net/wireless/libertas/scan.c        |   22 +--
 drivers/net/wireless/libertas_tf/main.c     |    1 -
 drivers/net/wireless/orinoco/wext.c         |    6 +-
 drivers/net/wireless/rt2x00/rt2800usb.c     |    1 +
 drivers/net/wireless/rtl818x/rtl8180_dev.c  |    1 -
 drivers/net/wireless/wl12xx/wl1251_boot.c   |    2 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c    |    4 +-
 drivers/net/wireless/zd1211rw/zd_chip.c     |  140 -------------------
 drivers/net/wireless/zd1211rw/zd_chip.h     |    3 -
 drivers/net/wireless/zd1211rw/zd_mac.c      |    3 -
 include/net/mac80211.h                      |    2 -
 net/mac80211/ibss.c                         |    4 +
 net/mac80211/tx.c                           |    4 +
 net/mac80211/util.c                         |   12 ++
 net/wireless/mlme.c                         |   13 ++-
 net/wireless/scan.c                         |   13 ++-
 29 files changed, 130 insertions(+), 448 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index a4c086f..e63b7c4 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1903,17 +1903,6 @@ accept:
 		rxs->noise = sc->ah->ah_noise_floor;
 		rxs->signal = rxs->noise + rs.rs_rssi;
 
-		/* An rssi of 35 indicates you should be able use
-		 * 54 Mbps reliably. A more elaborate scheme can be used
-		 * here but it requires a map of SNR/throughput for each
-		 * possible mode used */
-		rxs->qual = rs.rs_rssi * 100 / 35;
-
-		/* rssi can be more than 35 though, anything above that
-		 * should be considered at 100% */
-		if (rxs->qual > 100)
-			rxs->qual = 100;
-
 		rxs->antenna = rs.rs_antenna;
 		rxs->rate_idx = ath5k_hw_to_driver_rix(sc, rs.rs_rate);
 		rxs->flag |= ath5k_rx_decrypted(sc, ds, skb, &rs);
@@ -2381,6 +2370,9 @@ ath5k_init(struct ath5k_softc *sc)
 	 */
 	ath5k_stop_locked(sc);
 
+	/* Set PHY calibration interval */
+	ah->ah_cal_intval = ath5k_calinterval;
+
 	/*
 	 * The basic interface to setting the hardware in a good
 	 * state is ``reset''.  On return the hardware is known to
@@ -2408,10 +2400,6 @@ ath5k_init(struct ath5k_softc *sc)
 
 	/* Set ack to be sent at low bit-rates */
 	ath5k_hw_set_ack_bitrate_high(ah, false);
-
-	/* Set PHY calibration inteval */
-	ah->ah_cal_intval = ath5k_calinterval;
-
 	ret = 0;
 done:
 	mmiowb();
diff --git a/drivers/net/wireless/ath/ath9k/mac.h b/drivers/net/wireless/ath/ath9k/mac.h
index 0c87771..e185479 100644
--- a/drivers/net/wireless/ath/ath9k/mac.h
+++ b/drivers/net/wireless/ath/ath9k/mac.h
@@ -77,6 +77,9 @@
 #define ATH9K_TXERR_XTXOP          0x08
 #define ATH9K_TXERR_TIMER_EXPIRED  0x10
 #define ATH9K_TX_ACKED		   0x20
+#define ATH9K_TXERR_MASK						\
+	(ATH9K_TXERR_XRETRY | ATH9K_TXERR_FILT | ATH9K_TXERR_FIFO |	\
+	 ATH9K_TXERR_XTXOP | ATH9K_TXERR_TIMER_EXPIRED)
 
 #define ATH9K_TX_BA                0x01
 #define ATH9K_TX_PWRMGMT           0x02
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 9e68c1a..996eb90 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2514,6 +2514,9 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 		return; /* another wiphy still in use */
 	}
 
+	/* Ensure HW is awake when we try to shut it down. */
+	ath9k_ps_wakeup(sc);
+
 	if (ah->btcoex_hw.enabled) {
 		ath9k_hw_btcoex_disable(ah);
 		if (ah->btcoex_hw.scheme == ATH_BTCOEX_CFG_3WIRE)
@@ -2534,6 +2537,9 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 	/* disable HAL and put h/w to sleep */
 	ath9k_hw_disable(ah);
 	ath9k_hw_configpcipowersave(ah, 1, 1);
+	ath9k_ps_restore(sc);
+
+	/* Finally, put the chip in FULL SLEEP mode */
 	ath9k_setpower(sc, ATH9K_PM_FULL_SLEEP);
 
 	sc->sc_flags |= SC_OP_INVALID;
@@ -2647,8 +2653,10 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	if ((sc->sc_ah->opmode == NL80211_IFTYPE_AP) ||
 	    (sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC) ||
 	    (sc->sc_ah->opmode == NL80211_IFTYPE_MESH_POINT)) {
+		ath9k_ps_wakeup(sc);
 		ath9k_hw_stoptxdma(sc->sc_ah, sc->beacon.beaconq);
 		ath_beacon_return(sc, avp);
+		ath9k_ps_restore(sc);
 	}
 
 	sc->sc_flags &= ~SC_OP_BEACONS;
@@ -3097,15 +3105,21 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 	case IEEE80211_AMPDU_RX_STOP:
 		break;
 	case IEEE80211_AMPDU_TX_START:
+		ath9k_ps_wakeup(sc);
 		ath_tx_aggr_start(sc, sta, tid, ssn);
 		ieee80211_start_tx_ba_cb_irqsafe(vif, sta->addr, tid);
+		ath9k_ps_restore(sc);
 		break;
 	case IEEE80211_AMPDU_TX_STOP:
+		ath9k_ps_wakeup(sc);
 		ath_tx_aggr_stop(sc, sta, tid);
 		ieee80211_stop_tx_ba_cb_irqsafe(vif, sta->addr, tid);
+		ath9k_ps_restore(sc);
 		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
+		ath9k_ps_wakeup(sc);
 		ath_tx_aggr_resume(sc, sta, tid);
+		ath9k_ps_restore(sc);
 		break;
 	default:
 		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 5321f73..f7af5ea 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -96,7 +96,7 @@ static void ath_pci_bt_coex_prep(struct ath_common *common)
 	pci_write_config_byte(pdev, ATH_PCIE_CAP_LINK_CTRL, aspm);
 }
 
-const static struct ath_bus_ops ath_pci_bus_ops = {
+static const struct ath_bus_ops ath_pci_bus_ops = {
 	.read_cachesize = ath_pci_read_cachesize,
 	.cleanup = ath_pci_cleanup,
 	.eeprom_read = ath_pci_eeprom_read,
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 1e813bb..fa12b90 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2072,7 +2072,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 				&txq->axq_q, lastbf->list.prev);
 
 		txq->axq_depth--;
-		txok = !(ds->ds_txstat.ts_status & ATH9K_TXERR_FILT);
+		txok = !(ds->ds_txstat.ts_status & ATH9K_TXERR_MASK);
 		txq->axq_tx_inprogress = false;
 		spin_unlock_bh(&txq->axq_lock);
 
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 027be27..88d1fd0 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -383,160 +383,44 @@ static inline
 	}
 }
 
-/* Check if a DMA region fits the device constraints.
- * Returns true, if the region is OK for usage with this device. */
-static inline bool b43_dma_address_ok(struct b43_dmaring *ring,
-				      dma_addr_t addr, size_t size)
-{
-	switch (ring->type) {
-	case B43_DMA_30BIT:
-		if ((u64)addr + size > (1ULL << 30))
-			return 0;
-		break;
-	case B43_DMA_32BIT:
-		if ((u64)addr + size > (1ULL << 32))
-			return 0;
-		break;
-	case B43_DMA_64BIT:
-		/* Currently we can't have addresses beyond
-		 * 64bit in the kernel. */
-		break;
-	}
-	return 1;
-}
-
-#define is_4k_aligned(addr)	(((u64)(addr) & 0x0FFFull) == 0)
-#define is_8k_aligned(addr)	(((u64)(addr) & 0x1FFFull) == 0)
-
-static void b43_unmap_and_free_ringmem(struct b43_dmaring *ring, void *base,
-				       dma_addr_t dmaaddr, size_t size)
-{
-	ssb_dma_unmap_single(ring->dev->dev, dmaaddr, size, DMA_TO_DEVICE);
-	free_pages((unsigned long)base, get_order(size));
-}
-
-static void * __b43_get_and_map_ringmem(struct b43_dmaring *ring,
-					dma_addr_t *dmaaddr, size_t size,
-					gfp_t gfp_flags)
-{
-	void *base;
-
-	base = (void *)__get_free_pages(gfp_flags, get_order(size));
-	if (!base)
-		return NULL;
-	memset(base, 0, size);
-	*dmaaddr = ssb_dma_map_single(ring->dev->dev, base, size,
-				      DMA_TO_DEVICE);
-	if (ssb_dma_mapping_error(ring->dev->dev, *dmaaddr)) {
-		free_pages((unsigned long)base, get_order(size));
-		return NULL;
-	}
-
-	return base;
-}
-
-static void * b43_get_and_map_ringmem(struct b43_dmaring *ring,
-				      dma_addr_t *dmaaddr, size_t size)
-{
-	void *base;
-
-	base = __b43_get_and_map_ringmem(ring, dmaaddr, size,
-					 GFP_KERNEL);
-	if (!base) {
-		b43err(ring->dev->wl, "Failed to allocate or map pages "
-		       "for DMA ringmemory\n");
-		return NULL;
-	}
-	if (!b43_dma_address_ok(ring, *dmaaddr, size)) {
-		/* The memory does not fit our device constraints.
-		 * Retry with GFP_DMA set to get lower memory. */
-		b43_unmap_and_free_ringmem(ring, base, *dmaaddr, size);
-		base = __b43_get_and_map_ringmem(ring, dmaaddr, size,
-						 GFP_KERNEL | GFP_DMA);
-		if (!base) {
-			b43err(ring->dev->wl, "Failed to allocate or map pages "
-			       "in the GFP_DMA region for DMA ringmemory\n");
-			return NULL;
-		}
-		if (!b43_dma_address_ok(ring, *dmaaddr, size)) {
-			b43_unmap_and_free_ringmem(ring, base, *dmaaddr, size);
-			b43err(ring->dev->wl, "Failed to allocate DMA "
-			       "ringmemory that fits device constraints\n");
-			return NULL;
-		}
-	}
-	/* We expect the memory to be 4k aligned, at least. */
-	if (B43_WARN_ON(!is_4k_aligned(*dmaaddr))) {
-		b43_unmap_and_free_ringmem(ring, base, *dmaaddr, size);
-		return NULL;
-	}
-
-	return base;
-}
-
 static int alloc_ringmemory(struct b43_dmaring *ring)
 {
-	unsigned int required;
-	void *base;
-	dma_addr_t dmaaddr;
-
-	/* There are several requirements to the descriptor ring memory:
-	 * - The memory region needs to fit the address constraints for the
-	 *   device (same as for frame buffers).
-	 * - For 30/32bit DMA devices, the descriptor ring must be 4k aligned.
-	 * - For 64bit DMA devices, the descriptor ring must be 8k aligned.
+	gfp_t flags = GFP_KERNEL;
+
+	/* The specs call for 4K buffers for 30- and 32-bit DMA with 4K
+	 * alignment and 8K buffers for 64-bit DMA with 8K alignment. Testing
+	 * has shown that 4K is sufficient for the latter as long as the buffer
+	 * does not cross an 8K boundary.
+	 *
+	 * For unknown reasons - possibly a hardware error - the BCM4311 rev
+	 * 02, which uses 64-bit DMA, needs the ring buffer in very low memory,
+	 * which accounts for the GFP_DMA flag below.
+	 *
+	 * The flags here must match the flags in free_ringmemory below!
 	 */
-
 	if (ring->type == B43_DMA_64BIT)
-		required = ring->nr_slots * sizeof(struct b43_dmadesc64);
-	else
-		required = ring->nr_slots * sizeof(struct b43_dmadesc32);
-	if (B43_WARN_ON(required > 0x1000))
+		flags |= GFP_DMA;
+	ring->descbase = ssb_dma_alloc_consistent(ring->dev->dev,
+						  B43_DMA_RINGMEMSIZE,
+						  &(ring->dmabase), flags);
+	if (!ring->descbase) {
+		b43err(ring->dev->wl, "DMA ringmemory allocation failed\n");
 		return -ENOMEM;
-
-	ring->alloc_descsize = 0x1000;
-	base = b43_get_and_map_ringmem(ring, &dmaaddr, ring->alloc_descsize);
-	if (!base)
-		return -ENOMEM;
-	ring->alloc_descbase = base;
-	ring->alloc_dmabase = dmaaddr;
-
-	if ((ring->type != B43_DMA_64BIT) || is_8k_aligned(dmaaddr)) {
-		/* We're on <=32bit DMA, or we already got 8k aligned memory.
-		 * That's all we need, so we're fine. */
-		ring->descbase = base;
-		ring->dmabase = dmaaddr;
-		return 0;
-	}
-	b43_unmap_and_free_ringmem(ring, base, dmaaddr, ring->alloc_descsize);
-
-	/* Ok, we failed at the 8k alignment requirement.
-	 * Try to force-align the memory region now. */
-	ring->alloc_descsize = 0x2000;
-	base = b43_get_and_map_ringmem(ring, &dmaaddr, ring->alloc_descsize);
-	if (!base)
-		return -ENOMEM;
-	ring->alloc_descbase = base;
-	ring->alloc_dmabase = dmaaddr;
-
-	if (is_8k_aligned(dmaaddr)) {
-		/* We're already 8k aligned. That Ok, too. */
-		ring->descbase = base;
-		ring->dmabase = dmaaddr;
-		return 0;
 	}
-	/* Force-align it to 8k */
-	ring->descbase = (void *)((u8 *)base + 0x1000);
-	ring->dmabase = dmaaddr + 0x1000;
-	B43_WARN_ON(!is_8k_aligned(ring->dmabase));
+	memset(ring->descbase, 0, B43_DMA_RINGMEMSIZE);
 
 	return 0;
 }
 
 static void free_ringmemory(struct b43_dmaring *ring)
 {
-	b43_unmap_and_free_ringmem(ring, ring->alloc_descbase,
-				   ring->alloc_dmabase, ring->alloc_descsize);
+	gfp_t flags = GFP_KERNEL;
+
+	if (ring->type == B43_DMA_64BIT)
+		flags |= GFP_DMA;
+
+	ssb_dma_free_consistent(ring->dev->dev, B43_DMA_RINGMEMSIZE,
+				ring->descbase, ring->dmabase, flags);
 }
 
 /* Reset the RX DMA channel */
@@ -646,14 +530,29 @@ static bool b43_dma_mapping_error(struct b43_dmaring *ring,
 	if (unlikely(ssb_dma_mapping_error(ring->dev->dev, addr)))
 		return 1;
 
-	if (!b43_dma_address_ok(ring, addr, buffersize)) {
-		/* We can't support this address. Unmap it again. */
-		unmap_descbuffer(ring, addr, buffersize, dma_to_device);
-		return 1;
+	switch (ring->type) {
+	case B43_DMA_30BIT:
+		if ((u64)addr + buffersize > (1ULL << 30))
+			goto address_error;
+		break;
+	case B43_DMA_32BIT:
+		if ((u64)addr + buffersize > (1ULL << 32))
+			goto address_error;
+		break;
+	case B43_DMA_64BIT:
+		/* Currently we can't have addresses beyond
+		 * 64bit in the kernel. */
+		break;
 	}
 
 	/* The address is OK. */
 	return 0;
+
+address_error:
+	/* We can't support this address. Unmap it again. */
+	unmap_descbuffer(ring, addr, buffersize, dma_to_device);
+
+	return 1;
 }
 
 static bool b43_rx_buffer_is_poisoned(struct b43_dmaring *ring, struct sk_buff *skb)
@@ -715,9 +614,6 @@ static int setup_rx_descbuffer(struct b43_dmaring *ring,
 	meta->dmaaddr = dmaaddr;
 	ring->ops->fill_descriptor(ring, desc, dmaaddr,
 				   ring->rx_buffersize, 0, 0, 0);
-	ssb_dma_sync_single_for_device(ring->dev->dev,
-				       ring->alloc_dmabase,
-				       ring->alloc_descsize, DMA_TO_DEVICE);
 
 	return 0;
 }
@@ -1354,9 +1250,6 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 	}
 	/* Now transfer the whole frame. */
 	wmb();
-	ssb_dma_sync_single_for_device(ring->dev->dev,
-				       ring->alloc_dmabase,
-				       ring->alloc_descsize, DMA_TO_DEVICE);
 	ops->poke_tx(ring, next_slot(ring, slot));
 	return 0;
 
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index e607b39..f7ab37c 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -157,6 +157,7 @@ struct b43_dmadesc_generic {
 } __attribute__ ((__packed__));
 
 /* Misc DMA constants */
+#define B43_DMA_RINGMEMSIZE		PAGE_SIZE
 #define B43_DMA0_RX_FRAMEOFFSET		30
 
 /* DMA engine tuning knobs */
@@ -246,12 +247,6 @@ struct b43_dmaring {
 	/* The QOS priority assigned to this ring. Only used for TX rings.
 	 * This is the mac80211 "queue" value. */
 	u8 queue_prio;
-	/* Pointers and size of the originally allocated and mapped memory
-	 * region for the descriptor ring. */
-	void *alloc_descbase;
-	dma_addr_t alloc_dmabase;
-	unsigned int alloc_descsize;
-	/* Pointer to our wireless device. */
 	struct b43_wldev *dev;
 #ifdef CONFIG_B43_DEBUG
 	/* Maximum number of used slots. */
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index e413bd3..234891d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -681,19 +681,13 @@ static void iwl3945_rx_reply_rx(struct iwl_priv *priv,
 		snr = rx_stats_sig_avg / rx_stats_noise_diff;
 		rx_status.noise = rx_status.signal -
 					iwl3945_calc_db_from_ratio(snr);
-		rx_status.qual = iwl3945_calc_sig_qual(rx_status.signal,
-							 rx_status.noise);
-
-	/* If noise info not available, calculate signal quality indicator (%)
-	 *   using just the dBm signal level. */
 	} else {
 		rx_status.noise = priv->last_rx_noise;
-		rx_status.qual = iwl3945_calc_sig_qual(rx_status.signal, 0);
 	}
 
 
-	IWL_DEBUG_STATS(priv, "Rssi %d noise %d qual %d sig_avg %d noise_diff %d\n",
-			rx_status.signal, rx_status.noise, rx_status.qual,
+	IWL_DEBUG_STATS(priv, "Rssi %d noise %d sig_avg %d noise_diff %d\n",
+			rx_status.signal, rx_status.noise,
 			rx_stats_sig_avg, rx_stats_noise_diff);
 
 	header = (struct ieee80211_hdr *)IWL_RX_DATA(pkt);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index ecc23ec..531fa12 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -222,7 +222,6 @@ struct iwl3945_ibss_seq {
  *
  *****************************************************************************/
 extern int iwl3945_calc_db_from_ratio(int sig_ratio);
-extern int iwl3945_calc_sig_qual(int rssi_dbm, int noise_dbm);
 extern void iwl3945_rx_replenish(void *data);
 extern void iwl3945_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq);
 extern unsigned int iwl3945_fill_beacon_frame(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index fe511cb..b93e491 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -150,7 +150,7 @@ static s32 expected_tpt_mimo3_40MHz[4][IWL_RATE_COUNT] = {
 };
 
 /* mbps, mcs */
-const static struct iwl_rate_mcs_info iwl_rate_mcs[IWL_RATE_COUNT] = {
+static const struct iwl_rate_mcs_info iwl_rate_mcs[IWL_RATE_COUNT] = {
 	{  "1", "BPSK DSSS"},
 	{  "2", "QPSK DSSS"},
 	{"5.5", "BPSK CCK"},
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index f5c87e7..6f36b6e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -650,47 +650,6 @@ void iwl_reply_statistics(struct iwl_priv *priv,
 }
 EXPORT_SYMBOL(iwl_reply_statistics);
 
-#define PERFECT_RSSI (-20) /* dBm */
-#define WORST_RSSI (-95)   /* dBm */
-#define RSSI_RANGE (PERFECT_RSSI - WORST_RSSI)
-
-/* Calculate an indication of rx signal quality (a percentage, not dBm!).
- * See http://www.ces.clemson.edu/linux/signal_quality.shtml for info
- *   about formulas used below. */
-static int iwl_calc_sig_qual(int rssi_dbm, int noise_dbm)
-{
-	int sig_qual;
-	int degradation = PERFECT_RSSI - rssi_dbm;
-
-	/* If we get a noise measurement, use signal-to-noise ratio (SNR)
-	 * as indicator; formula is (signal dbm - noise dbm).
-	 * SNR at or above 40 is a great signal (100%).
-	 * Below that, scale to fit SNR of 0 - 40 dB within 0 - 100% indicator.
-	 * Weakest usable signal is usually 10 - 15 dB SNR. */
-	if (noise_dbm) {
-		if (rssi_dbm - noise_dbm >= 40)
-			return 100;
-		else if (rssi_dbm < noise_dbm)
-			return 0;
-		sig_qual = ((rssi_dbm - noise_dbm) * 5) / 2;
-
-	/* Else use just the signal level.
-	 * This formula is a least squares fit of data points collected and
-	 *   compared with a reference system that had a percentage (%) display
-	 *   for signal quality. */
-	} else
-		sig_qual = (100 * (RSSI_RANGE * RSSI_RANGE) - degradation *
-			    (15 * RSSI_RANGE + 62 * degradation)) /
-			   (RSSI_RANGE * RSSI_RANGE);
-
-	if (sig_qual > 100)
-		sig_qual = 100;
-	else if (sig_qual < 1)
-		sig_qual = 0;
-
-	return sig_qual;
-}
-
 /* Calc max signal level (dBm) among 3 possible receivers */
 static inline int iwl_calc_rssi(struct iwl_priv *priv,
 				struct iwl_rx_phy_res *rx_resp)
@@ -1101,11 +1060,8 @@ void iwl_rx_reply_rx(struct iwl_priv *priv,
 	if (iwl_is_associated(priv) &&
 	    !test_bit(STATUS_SCANNING, &priv->status)) {
 		rx_status.noise = priv->last_rx_noise;
-		rx_status.qual = iwl_calc_sig_qual(rx_status.signal,
-							 rx_status.noise);
 	} else {
 		rx_status.noise = IWL_NOISE_MEAS_NOT_AVAILABLE;
-		rx_status.qual = iwl_calc_sig_qual(rx_status.signal, 0);
 	}
 
 	/* Reset beacon noise level if not associated. */
@@ -1118,8 +1074,8 @@ void iwl_rx_reply_rx(struct iwl_priv *priv,
 		iwl_dbg_report_frame(priv, phy_res, len, header, 1);
 #endif
 	iwl_dbg_log_rx_data_frame(priv, len, header);
-	IWL_DEBUG_STATS_LIMIT(priv, "Rssi %d, noise %d, qual %d, TSF %llu\n",
-		rx_status.signal, rx_status.noise, rx_status.qual,
+	IWL_DEBUG_STATS_LIMIT(priv, "Rssi %d, noise %d, TSF %llu\n",
+		rx_status.signal, rx_status.noise,
 		(unsigned long long)rx_status.mactime);
 
 	/*
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index e5d8fa3..f8e4e4b 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1299,47 +1299,6 @@ int iwl3945_calc_db_from_ratio(int sig_ratio)
 	return (int)ratio2dB[sig_ratio];
 }
 
-#define PERFECT_RSSI (-20) /* dBm */
-#define WORST_RSSI (-95)   /* dBm */
-#define RSSI_RANGE (PERFECT_RSSI - WORST_RSSI)
-
-/* Calculate an indication of rx signal quality (a percentage, not dBm!).
- * See http://www.ces.clemson.edu/linux/signal_quality.shtml for info
- *   about formulas used below. */
-int iwl3945_calc_sig_qual(int rssi_dbm, int noise_dbm)
-{
-	int sig_qual;
-	int degradation = PERFECT_RSSI - rssi_dbm;
-
-	/* If we get a noise measurement, use signal-to-noise ratio (SNR)
-	 * as indicator; formula is (signal dbm - noise dbm).
-	 * SNR at or above 40 is a great signal (100%).
-	 * Below that, scale to fit SNR of 0 - 40 dB within 0 - 100% indicator.
-	 * Weakest usable signal is usually 10 - 15 dB SNR. */
-	if (noise_dbm) {
-		if (rssi_dbm - noise_dbm >= 40)
-			return 100;
-		else if (rssi_dbm < noise_dbm)
-			return 0;
-		sig_qual = ((rssi_dbm - noise_dbm) * 5) / 2;
-
-	/* Else use just the signal level.
-	 * This formula is a least squares fit of data points collected and
-	 *   compared with a reference system that had a percentage (%) display
-	 *   for signal quality. */
-	} else
-		sig_qual = (100 * (RSSI_RANGE * RSSI_RANGE) - degradation *
-			    (15 * RSSI_RANGE + 62 * degradation)) /
-			   (RSSI_RANGE * RSSI_RANGE);
-
-	if (sig_qual > 100)
-		sig_qual = 100;
-	else if (sig_qual < 1)
-		sig_qual = 0;
-
-	return sig_qual;
-}
-
 /**
  * iwl3945_rx_handle - Main entry function for receiving responses from uCode
  *
diff --git a/drivers/net/wireless/iwmc3200wifi/iwm.h b/drivers/net/wireless/iwmc3200wifi/iwm.h
index 79ffa3b..8428111 100644
--- a/drivers/net/wireless/iwmc3200wifi/iwm.h
+++ b/drivers/net/wireless/iwmc3200wifi/iwm.h
@@ -268,7 +268,7 @@ struct iwm_priv {
 
 	struct sk_buff_head rx_list;
 	struct list_head rx_tickets;
-	struct list_head rx_packets[IWM_RX_ID_HASH];
+	struct list_head rx_packets[IWM_RX_ID_HASH + 1];
 	struct workqueue_struct *rx_wq;
 	struct work_struct rx_worker;
 
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index c6a6c04..b0b1c78 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -567,11 +567,8 @@ int lbs_scan_networks(struct lbs_private *priv, int full_scan)
 	chan_count = lbs_scan_create_channel_list(priv, chan_list);
 
 	netif_stop_queue(priv->dev);
-	netif_carrier_off(priv->dev);
-	if (priv->mesh_dev) {
+	if (priv->mesh_dev)
 		netif_stop_queue(priv->mesh_dev);
-		netif_carrier_off(priv->mesh_dev);
-	}
 
 	/* Prepare to continue an interrupted scan */
 	lbs_deb_scan("chan_count %d, scan_channel %d\n",
@@ -635,16 +632,13 @@ out2:
 	priv->scan_channel = 0;
 
 out:
-	if (priv->connect_status == LBS_CONNECTED) {
-		netif_carrier_on(priv->dev);
-		if (!priv->tx_pending_len)
-			netif_wake_queue(priv->dev);
-	}
-	if (priv->mesh_dev && (priv->mesh_connect_status == LBS_CONNECTED)) {
-		netif_carrier_on(priv->mesh_dev);
-		if (!priv->tx_pending_len)
-			netif_wake_queue(priv->mesh_dev);
-	}
+	if (priv->connect_status == LBS_CONNECTED && !priv->tx_pending_len)
+		netif_wake_queue(priv->dev);
+
+	if (priv->mesh_dev && (priv->mesh_connect_status == LBS_CONNECTED) &&
+	    !priv->tx_pending_len)
+		netif_wake_queue(priv->mesh_dev);
+
 	kfree(chan_list);
 
 	lbs_deb_leave_args(LBS_DEB_SCAN, "ret %d", ret);
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 019431d..26a1abd 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -495,7 +495,6 @@ int lbtf_rx(struct lbtf_private *priv, struct sk_buff *skb)
 	stats.band = IEEE80211_BAND_2GHZ;
 	stats.signal = prxpd->snr;
 	stats.noise = prxpd->nf;
-	stats.qual = prxpd->snr - prxpd->nf;
 	/* Marvell rate index has a hole at value 4 */
 	if (prxpd->rx_rate > 4)
 		--prxpd->rx_rate;
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 7698fdd..31ca241 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -23,7 +23,7 @@
 #define MAX_RID_LEN 1024
 
 /* Helper routine to record keys
- * Do not call from interrupt context */
+ * It is called under orinoco_lock so it may not sleep */
 static int orinoco_set_key(struct orinoco_private *priv, int index,
 			   enum orinoco_alg alg, const u8 *key, int key_len,
 			   const u8 *seq, int seq_len)
@@ -32,14 +32,14 @@ static int orinoco_set_key(struct orinoco_private *priv, int index,
 	kzfree(priv->keys[index].seq);
 
 	if (key_len) {
-		priv->keys[index].key = kzalloc(key_len, GFP_KERNEL);
+		priv->keys[index].key = kzalloc(key_len, GFP_ATOMIC);
 		if (!priv->keys[index].key)
 			goto nomem;
 	} else
 		priv->keys[index].key = NULL;
 
 	if (seq_len) {
-		priv->keys[index].seq = kzalloc(seq_len, GFP_KERNEL);
+		priv->keys[index].seq = kzalloc(seq_len, GFP_ATOMIC);
 		if (!priv->keys[index].seq)
 			goto free_key;
 	} else
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index af85d18..ab95346 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -922,6 +922,7 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	{ USB_DEVICE(0x1737, 0x0070), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x1737, 0x0071), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x1737, 0x0077), USB_DEVICE_DATA(&rt2800usb_ops) },
+	{ USB_DEVICE(0x1737, 0x0079), USB_DEVICE_DATA(&rt2800usb_ops) },
 	/* Logitec */
 	{ USB_DEVICE(0x0789, 0x0162), USB_DEVICE_DATA(&rt2800usb_ops) },
 	{ USB_DEVICE(0x0789, 0x0163), USB_DEVICE_DATA(&rt2800usb_ops) },
diff --git a/drivers/net/wireless/rtl818x/rtl8180_dev.c b/drivers/net/wireless/rtl818x/rtl8180_dev.c
index a1a3dd1..8a40a14 100644
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -132,7 +132,6 @@ static void rtl8180_handle_rx(struct ieee80211_hw *dev)
 
 			rx_status.antenna = (flags2 >> 15) & 1;
 			/* TODO: improve signal/rssi reporting */
-			rx_status.qual = flags2 & 0xFF;
 			rx_status.signal = (flags2 >> 8) & 0x7F;
 			/* XXX: is this correct? */
 			rx_status.rate_idx = (flags >> 20) & 0xF;
diff --git a/drivers/net/wireless/wl12xx/wl1251_boot.c b/drivers/net/wireless/wl12xx/wl1251_boot.c
index 2e733e7..28a8086 100644
--- a/drivers/net/wireless/wl12xx/wl1251_boot.c
+++ b/drivers/net/wireless/wl12xx/wl1251_boot.c
@@ -256,7 +256,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 		}
 	}
 
-	if (loop >= INIT_LOOP) {
+	if (loop > INIT_LOOP) {
 		wl1251_error("timeout waiting for the hardware to "
 			     "complete initialization");
 		return -EIO;
diff --git a/drivers/net/wireless/wl12xx/wl1271_cmd.c b/drivers/net/wireless/wl12xx/wl1271_cmd.c
index 886a9bc..c3385b3 100644
--- a/drivers/net/wireless/wl12xx/wl1271_cmd.c
+++ b/drivers/net/wireless/wl12xx/wl1271_cmd.c
@@ -777,7 +777,7 @@ out:
 	return ret;
 }
 
-static int wl1271_build_basic_rates(char *rates, u8 band)
+static int wl1271_build_basic_rates(u8 *rates, u8 band)
 {
 	u8 index = 0;
 
@@ -804,7 +804,7 @@ static int wl1271_build_basic_rates(char *rates, u8 band)
 	return index;
 }
 
-static int wl1271_build_extended_rates(char *rates, u8 band)
+static int wl1271_build_extended_rates(u8 *rates, u8 band)
 {
 	u8 index = 0;
 
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index dfa1b9b..7ca95c4 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1325,151 +1325,11 @@ int zd_chip_set_basic_rates(struct zd_chip *chip, u16 cr_rates)
 	return r;
 }
 
-static int ofdm_qual_db(u8 status_quality, u8 zd_rate, unsigned int size)
-{
-	static const u16 constants[] = {
-		715, 655, 585, 540, 470, 410, 360, 315,
-		270, 235, 205, 175, 150, 125, 105,  85,
-		 65,  50,  40,  25,  15
-	};
-
-	int i;
-	u32 x;
-
-	/* It seems that their quality parameter is somehow per signal
-	 * and is now transferred per bit.
-	 */
-	switch (zd_rate) {
-	case ZD_OFDM_RATE_6M:
-	case ZD_OFDM_RATE_12M:
-	case ZD_OFDM_RATE_24M:
-		size *= 2;
-		break;
-	case ZD_OFDM_RATE_9M:
-	case ZD_OFDM_RATE_18M:
-	case ZD_OFDM_RATE_36M:
-	case ZD_OFDM_RATE_54M:
-		size *= 4;
-		size /= 3;
-		break;
-	case ZD_OFDM_RATE_48M:
-		size *= 3;
-		size /= 2;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	x = (10000 * status_quality)/size;
-	for (i = 0; i < ARRAY_SIZE(constants); i++) {
-		if (x > constants[i])
-			break;
-	}
-
-	switch (zd_rate) {
-	case ZD_OFDM_RATE_6M:
-	case ZD_OFDM_RATE_9M:
-		i += 3;
-		break;
-	case ZD_OFDM_RATE_12M:
-	case ZD_OFDM_RATE_18M:
-		i += 5;
-		break;
-	case ZD_OFDM_RATE_24M:
-	case ZD_OFDM_RATE_36M:
-		i += 9;
-		break;
-	case ZD_OFDM_RATE_48M:
-	case ZD_OFDM_RATE_54M:
-		i += 15;
-		break;
-	default:
-		return -EINVAL;
-	}
-
-	return i;
-}
-
-static int ofdm_qual_percent(u8 status_quality, u8 zd_rate, unsigned int size)
-{
-	int r;
-
-	r = ofdm_qual_db(status_quality, zd_rate, size);
-	ZD_ASSERT(r >= 0);
-	if (r < 0)
-		r = 0;
-
-	r = (r * 100)/29;
-	return r <= 100 ? r : 100;
-}
-
-static unsigned int log10times100(unsigned int x)
-{
-	static const u8 log10[] = {
-		  0,
-		  0,   30,   47,   60,   69,   77,   84,   90,   95,  100,
-		104,  107,  111,  114,  117,  120,  123,  125,  127,  130,
-		132,  134,  136,  138,  139,  141,  143,  144,  146,  147,
-		149,  150,  151,  153,  154,  155,  156,  157,  159,  160,
-		161,  162,  163,  164,  165,  166,  167,  168,  169,  169,
-		170,  171,  172,  173,  174,  174,  175,  176,  177,  177,
-		178,  179,  179,  180,  181,  181,  182,  183,  183,  184,
-		185,  185,  186,  186,  187,  188,  188,  189,  189,  190,
-		190,  191,  191,  192,  192,  193,  193,  194,  194,  195,
-		195,  196,  196,  197,  197,  198,  198,  199,  199,  200,
-		200,  200,  201,  201,  202,  202,  202,  203,  203,  204,
-		204,  204,  205,  205,  206,  206,  206,  207,  207,  207,
-		208,  208,  208,  209,  209,  210,  210,  210,  211,  211,
-		211,  212,  212,  212,  213,  213,  213,  213,  214,  214,
-		214,  215,  215,  215,  216,  216,  216,  217,  217,  217,
-		217,  218,  218,  218,  219,  219,  219,  219,  220,  220,
-		220,  220,  221,  221,  221,  222,  222,  222,  222,  223,
-		223,  223,  223,  224,  224,  224,  224,
-	};
-
-	return x < ARRAY_SIZE(log10) ? log10[x] : 225;
-}
-
-enum {
-	MAX_CCK_EVM_DB = 45,
-};
-
-static int cck_evm_db(u8 status_quality)
-{
-	return (20 * log10times100(status_quality)) / 100;
-}
-
-static int cck_snr_db(u8 status_quality)
-{
-	int r = MAX_CCK_EVM_DB - cck_evm_db(status_quality);
-	ZD_ASSERT(r >= 0);
-	return r;
-}
-
-static int cck_qual_percent(u8 status_quality)
-{
-	int r;
-
-	r = cck_snr_db(status_quality);
-	r = (100*r)/17;
-	return r <= 100 ? r : 100;
-}
-
 static inline u8 zd_rate_from_ofdm_plcp_header(const void *rx_frame)
 {
 	return ZD_OFDM | zd_ofdm_plcp_header_rate(rx_frame);
 }
 
-u8 zd_rx_qual_percent(const void *rx_frame, unsigned int size,
-	              const struct rx_status *status)
-{
-	return (status->frame_status&ZD_RX_OFDM) ?
-		ofdm_qual_percent(status->signal_quality_ofdm,
-				  zd_rate_from_ofdm_plcp_header(rx_frame),
-			          size) :
-		cck_qual_percent(status->signal_quality_cck);
-}
-
 /**
  * zd_rx_rate - report zd-rate
  * @rx_frame - received frame
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 9fd8f35..f8bbf7d 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -929,9 +929,6 @@ static inline int zd_get_beacon_interval(struct zd_chip *chip, u32 *interval)
 
 struct rx_status;
 
-u8 zd_rx_qual_percent(const void *rx_frame, unsigned int size,
-	               const struct rx_status *status);
-
 u8 zd_rx_rate(const void *rx_frame, const struct rx_status *status);
 
 struct zd_mc_hash {
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 8a24373..cc648ef 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -828,9 +828,6 @@ int zd_mac_rx(struct ieee80211_hw *hw, const u8 *buffer, unsigned int length)
 	stats.freq = zd_channels[_zd_chip_get_channel(&mac->chip) - 1].center_freq;
 	stats.band = IEEE80211_BAND_2GHZ;
 	stats.signal = status->signal_strength;
-	stats.qual = zd_rx_qual_percent(buffer,
-		                          length - sizeof(struct rx_status),
-		                          status);
 
 	rate = zd_rx_rate(buffer, status);
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 538d6b7..0bf3697 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -547,7 +547,6 @@ enum mac80211_rx_flags {
  *	unspecified depending on the hardware capabilities flags
  *	@IEEE80211_HW_SIGNAL_*
  * @noise: noise when receiving this frame, in dBm.
- * @qual: overall signal quality indication, in percent (0-100).
  * @antenna: antenna used
  * @rate_idx: index of data rate into band's supported rates or MCS index if
  *	HT rates are use (RX_FLAG_HT)
@@ -559,7 +558,6 @@ struct ieee80211_rx_status {
 	int freq;
 	int signal;
 	int noise;
-	int __deprecated qual;
 	int antenna;
 	int rate_idx;
 	int flag;
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 10d1385..1f2db64 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -382,6 +382,7 @@ static void ieee80211_rx_bss_info(struct ieee80211_sub_if_data *sdata,
 struct sta_info *ieee80211_ibss_add_sta(struct ieee80211_sub_if_data *sdata,
 					u8 *bssid,u8 *addr, u32 supp_rates)
 {
+	struct ieee80211_if_ibss *ifibss = &sdata->u.ibss;
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 	int band = local->hw.conf.channel->band;
@@ -397,6 +398,9 @@ struct sta_info *ieee80211_ibss_add_sta(struct ieee80211_sub_if_data *sdata,
 		return NULL;
 	}
 
+	if (ifibss->state == IEEE80211_IBSS_MLME_SEARCH)
+		return NULL;
+
 	if (compare_ether_addr(bssid, sdata->u.ibss.bssid))
 		return NULL;
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 8834cc9..27ceaef 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1419,6 +1419,10 @@ static bool need_dynamic_ps(struct ieee80211_local *local)
 	if (!local->ps_sdata)
 		return false;
 
+	/* No point if we're going to suspend */
+	if (local->quiescing)
+		return false;
+
 	return true;
 }
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 78a6e92..dc76267 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1039,7 +1039,19 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 
 	/* restart hardware */
 	if (local->open_count) {
+		/*
+		 * Upon resume hardware can sometimes be goofy due to
+		 * various platform / driver / bus issues, so restarting
+		 * the device may at times not work immediately. Propagate
+		 * the error.
+		 */
 		res = drv_start(local);
+		if (res) {
+			WARN(local->suspended, "Harware became unavailable "
+			     "upon resume. This is could be a software issue"
+			     "prior to suspend or a harware issue\n");
+			return res;
+		}
 
 		ieee80211_led_radio(local, true);
 	}
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index 1001db4..82e6002 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -93,7 +93,18 @@ void cfg80211_send_rx_assoc(struct net_device *dev, const u8 *buf, size_t len)
 			}
 		}
 
-		WARN_ON(!bss);
+		/*
+		 * We might be coming here because the driver reported
+		 * a successful association at the same time as the
+		 * user requested a deauth. In that case, we will have
+		 * removed the BSS from the auth_bsses list due to the
+		 * deauth request when the assoc response makes it. If
+		 * the two code paths acquire the lock the other way
+		 * around, that's just the standard situation of a
+		 * deauth being requested while connected.
+		 */
+		if (!bss)
+			goto out;
 	} else if (wdev->conn) {
 		cfg80211_sme_failed_assoc(wdev);
 		/*
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 12dfa62..0c2cbbe 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -601,7 +601,7 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 	struct cfg80211_registered_device *rdev;
 	struct wiphy *wiphy;
 	struct iw_scan_req *wreq = NULL;
-	struct cfg80211_scan_request *creq;
+	struct cfg80211_scan_request *creq = NULL;
 	int i, err, n_channels = 0;
 	enum ieee80211_band band;
 
@@ -694,8 +694,10 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 	/* translate "Scan for SSID" request */
 	if (wreq) {
 		if (wrqu->data.flags & IW_SCAN_THIS_ESSID) {
-			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN)
-				return -EINVAL;
+			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN) {
+				err = -EINVAL;
+				goto out;
+			}
 			memcpy(creq->ssids[0].ssid, wreq->essid, wreq->essid_len);
 			creq->ssids[0].ssid_len = wreq->essid_len;
 		}
@@ -707,12 +709,15 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 	err = rdev->ops->scan(wiphy, dev, creq);
 	if (err) {
 		rdev->scan_req = NULL;
-		kfree(creq);
+		/* creq will be freed below */
 	} else {
 		nl80211_send_scan_start(rdev, dev);
+		/* creq now owned by driver */
+		creq = NULL;
 		dev_hold(dev);
 	}
  out:
+	kfree(creq);
 	cfg80211_unlock_rdev(rdev);
 	return err;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
