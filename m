From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 13:04:02 -0400
Message-ID: <20100525170401.GE31753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52613 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903Ab0EYRPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 13:15:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a number of fixes intended for 2.6.35.  Included are some
warning fixes from Randy, some smatch-identified fixes from Dan, some
fixes for using ath9k and IBSS mode, the removal of a PCI ID that was
optimistically added to ath9k, and a smattering of other driver fixes.
This also includes a revert of "ath9k: Group Key fix for VAPs" which
was reported to cause regressions due to a mac80211 change inside it
that snuck past us... :-(

Anyway, these are mostly small(ish) and obvious.  Please let me know
if there are problems!

Thanks,

John

---

The following changes since commit acfbe96a3035639619a6533e04d88ed4ef9ccb61:
  Randy Dunlap (1):
        sock.h: fix kernel-doc warning

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bruno Randolf (1):
      ath5k: consistently use rx_bufsize for RX DMA

Dan Carpenter (3):
      ath9k_htc: dereferencing before check in hif_usb_tx_cb()
      ath9k_htc: rare leak in ath9k_hif_usb_alloc_tx_urbs()
      iwlwifi: testing the wrong variable in iwl_add_bssid_station()

Felix Fietkau (3):
      cfg80211: fix crash in cfg80211_set_freq()
      ath9k: change beacon allocation to prefer the first beacon slot
      ath9k: remove VEOL support for ad-hoc

Gertjan van Wingerde (2):
      rt2x00: Fix failed SLEEP->AWAKE and AWAKE->SLEEP transitions.
      rt2x00: Fix rt2800usb TX descriptor writing.

Helmut Schaa (1):
      rt2x00: don't use to_pci_dev in rt2x00pci_uninitialize

Johannes Berg (1):
      cfg80211: add missing braces

John W. Linville (1):
      Revert "ath9k: Group Key fix for VAPs"

Jussi Kivilinna (1):
      rndis_wlan: replace wireless_send_event with cfg80211_disconnected

Juuso Oikarinen (1):
      wl1271: Fix RX data path frame lengths

Luis R. Rodriguez (1):
      ath9k: remove AR9003 from PCI IDs for now

Randy Dunlap (2):
      wireless: fix mac80211.h kernel-doc warnings
      wireless: fix sta_info.h kernel-doc warnings

Reinette Chatre (1):
      iwlwifi: fix internal scan race

Sujith (1):
      cfg80211: Fix signal_type comparison

Tejun Heo (1):
      wireless: update gfp/slab.h includes

Vasanthakumar Thiagarajan (1):
      ath9k: Fix rx of mcast/bcast frames in PS mode with auto sleep

 drivers/net/wireless/ath/ath5k/base.c      |    7 ++-
 drivers/net/wireless/ath/ath9k/beacon.c    |   75 +++++-----------------------
 drivers/net/wireless/ath/ath9k/hif_usb.c   |   10 +++-
 drivers/net/wireless/ath/ath9k/htc.h       |    1 +
 drivers/net/wireless/ath/ath9k/main.c      |   28 +---------
 drivers/net/wireless/ath/ath9k/pci.c       |    1 -
 drivers/net/wireless/ath/ath9k/recv.c      |   17 +++++--
 drivers/net/wireless/iwlwifi/iwl-agn-ict.c |    1 +
 drivers/net/wireless/iwlwifi/iwl-scan.c    |   21 +++++++-
 drivers/net/wireless/iwlwifi/iwl-sta.c     |    2 +-
 drivers/net/wireless/rndis_wlan.c          |   16 ++++--
 drivers/net/wireless/rt2x00/rt2400pci.c    |    9 ++--
 drivers/net/wireless/rt2x00/rt2500pci.c    |    9 ++--
 drivers/net/wireless/rt2x00/rt2800usb.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c    |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |    7 ++-
 drivers/net/wireless/rt2x00/rt73usb.c      |    7 ++-
 drivers/net/wireless/wl12xx/wl1271_rx.c    |    2 +
 include/net/mac80211.h                     |    4 +-
 net/mac80211/key.c                         |    1 -
 net/mac80211/sta_info.h                    |    2 +-
 net/wireless/chan.c                        |    2 +-
 net/wireless/nl80211.c                     |    6 ++-
 net/wireless/scan.c                        |    4 +-
 24 files changed, 104 insertions(+), 132 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 5f04cf3..cc6d41d 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1214,6 +1214,7 @@ ath5k_rxbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 	struct ath5k_hw *ah = sc->ah;
 	struct sk_buff *skb = bf->skb;
 	struct ath5k_desc *ds;
+	int ret;
 
 	if (!skb) {
 		skb = ath5k_rx_skb_alloc(sc, &bf->skbaddr);
@@ -1240,9 +1241,9 @@ ath5k_rxbuf_setup(struct ath5k_softc *sc, struct ath5k_buf *bf)
 	ds = bf->desc;
 	ds->ds_link = bf->daddr;	/* link to self */
 	ds->ds_data = bf->skbaddr;
-	ah->ah_setup_rx_desc(ah, ds,
-		skb_tailroom(skb),	/* buffer size */
-		0);
+	ret = ah->ah_setup_rx_desc(ah, ds, ah->common.rx_bufsize, 0);
+	if (ret)
+		return ret;
 
 	if (sc->rxlink != NULL)
 		*sc->rxlink = bf->daddr;
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index c8a4558..f43d85a 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -76,22 +76,13 @@ static void ath_beacon_setup(struct ath_softc *sc, struct ath_vif *avp,
 	ds = bf->bf_desc;
 	flags = ATH9K_TXDESC_NOACK;
 
-	if (((sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC) ||
-	     (sc->sc_ah->opmode == NL80211_IFTYPE_MESH_POINT)) &&
-	    (ah->caps.hw_caps & ATH9K_HW_CAP_VEOL)) {
-		ds->ds_link = bf->bf_daddr; /* self-linked */
-		flags |= ATH9K_TXDESC_VEOL;
-		/* Let hardware handle antenna switching. */
-		antenna = 0;
-	} else {
-		ds->ds_link = 0;
-		/*
-		 * Switch antenna every beacon.
-		 * Should only switch every beacon period, not for every SWBA
-		 * XXX assumes two antennae
-		 */
-		antenna = ((sc->beacon.ast_be_xmit / sc->nbcnvifs) & 1 ? 2 : 1);
-	}
+	ds->ds_link = 0;
+	/*
+	 * Switch antenna every beacon.
+	 * Should only switch every beacon period, not for every SWBA
+	 * XXX assumes two antennae
+	 */
+	antenna = ((sc->beacon.ast_be_xmit / sc->nbcnvifs) & 1 ? 2 : 1);
 
 	sband = &sc->sbands[common->hw->conf.channel->band];
 	rate = sband->bitrates[rateidx].hw_value;
@@ -215,36 +206,6 @@ static struct ath_buf *ath_beacon_generate(struct ieee80211_hw *hw,
 	return bf;
 }
 
-/*
- * Startup beacon transmission for adhoc mode when they are sent entirely
- * by the hardware using the self-linked descriptor + veol trick.
-*/
-static void ath_beacon_start_adhoc(struct ath_softc *sc,
-				   struct ieee80211_vif *vif)
-{
-	struct ath_hw *ah = sc->sc_ah;
-	struct ath_common *common = ath9k_hw_common(ah);
-	struct ath_buf *bf;
-	struct ath_vif *avp;
-	struct sk_buff *skb;
-
-	avp = (void *)vif->drv_priv;
-
-	if (avp->av_bcbuf == NULL)
-		return;
-
-	bf = avp->av_bcbuf;
-	skb = bf->bf_mpdu;
-
-	ath_beacon_setup(sc, avp, bf, 0);
-
-	/* NB: caller is known to have already stopped tx dma */
-	ath9k_hw_puttxbuf(ah, sc->beacon.beaconq, bf->bf_daddr);
-	ath9k_hw_txstart(ah, sc->beacon.beaconq);
-	ath_print(common, ATH_DBG_BEACON, "TXDP%u = %llx (%p)\n",
-		  sc->beacon.beaconq, ito64(bf->bf_daddr), bf->bf_desc);
-}
-
 int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 {
 	struct ath_softc *sc = aphy->sc;
@@ -265,7 +226,8 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 		list_del(&avp->av_bcbuf->list);
 
 		if (sc->sc_ah->opmode == NL80211_IFTYPE_AP ||
-		    !(sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_VEOL)) {
+		    sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC ||
+		    sc->sc_ah->opmode == NL80211_IFTYPE_MESH_POINT) {
 			int slot;
 			/*
 			 * Assign the vif to a beacon xmit slot. As
@@ -274,17 +236,11 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 			avp->av_bslot = 0;
 			for (slot = 0; slot < ATH_BCBUF; slot++)
 				if (sc->beacon.bslot[slot] == NULL) {
-					/*
-					 * XXX hack, space out slots to better
-					 * deal with misses
-					 */
-					if (slot+1 < ATH_BCBUF &&
-					    sc->beacon.bslot[slot+1] == NULL) {
-						avp->av_bslot = slot+1;
-						break;
-					}
 					avp->av_bslot = slot;
+
 					/* NB: keep looking for a double slot */
+					if (slot == 0 || !sc->beacon.bslot[slot-1])
+						break;
 				}
 			BUG_ON(sc->beacon.bslot[avp->av_bslot] != NULL);
 			sc->beacon.bslot[avp->av_bslot] = vif;
@@ -721,8 +677,7 @@ static void ath_beacon_config_adhoc(struct ath_softc *sc,
 	 * self-linked tx descriptor and let the hardware deal with things.
 	 */
 	intval |= ATH9K_BEACON_ENA;
-	if (!(ah->caps.hw_caps & ATH9K_HW_CAP_VEOL))
-		ah->imask |= ATH9K_INT_SWBA;
+	ah->imask |= ATH9K_INT_SWBA;
 
 	ath_beaconq_config(sc);
 
@@ -732,10 +687,6 @@ static void ath_beacon_config_adhoc(struct ath_softc *sc,
 	ath9k_beacon_init(sc, nexttbtt, intval);
 	sc->beacon.bmisscnt = 0;
 	ath9k_hw_set_interrupts(ah, ah->imask);
-
-	/* FIXME: Handle properly when vif is NULL */
-	if (vif && ah->caps.hw_caps & ATH9K_HW_CAP_VEOL)
-		ath_beacon_start_adhoc(sc, vif);
 }
 
 void ath_beacon_config(struct ath_softc *sc, struct ieee80211_vif *vif)
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 46dc41a..77b3591 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -107,12 +107,14 @@ static inline void ath9k_skb_queue_purge(struct hif_device_usb *hif_dev,
 static void hif_usb_tx_cb(struct urb *urb)
 {
 	struct tx_buf *tx_buf = (struct tx_buf *) urb->context;
-	struct hif_device_usb *hif_dev = tx_buf->hif_dev;
+	struct hif_device_usb *hif_dev;
 	struct sk_buff *skb;
 
-	if (!hif_dev || !tx_buf)
+	if (!tx_buf || !tx_buf->hif_dev)
 		return;
 
+	hif_dev = tx_buf->hif_dev;
+
 	switch (urb->status) {
 	case 0:
 		break;
@@ -607,6 +609,10 @@ static int ath9k_hif_usb_alloc_tx_urbs(struct hif_device_usb *hif_dev)
 
 	return 0;
 err:
+	if (tx_buf) {
+		kfree(tx_buf->buf);
+		kfree(tx_buf);
+	}
 	ath9k_hif_usb_dealloc_tx_urbs(hif_dev);
 	return -ENOMEM;
 }
diff --git a/drivers/net/wireless/ath/ath9k/htc.h b/drivers/net/wireless/ath/ath9k/htc.h
index ad556aa..c251603 100644
--- a/drivers/net/wireless/ath/ath9k/htc.h
+++ b/drivers/net/wireless/ath/ath9k/htc.h
@@ -23,6 +23,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/leds.h>
+#include <linux/slab.h>
 #include <net/mac80211.h>
 
 #include "common.h"
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 893b552..abfa049 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -752,7 +752,6 @@ static int ath_key_config(struct ath_common *common,
 	struct ath_hw *ah = common->ah;
 	struct ath9k_keyval hk;
 	const u8 *mac = NULL;
-	u8 gmac[ETH_ALEN];
 	int ret = 0;
 	int idx;
 
@@ -776,30 +775,9 @@ static int ath_key_config(struct ath_common *common,
 	memcpy(hk.kv_val, key->key, key->keylen);
 
 	if (!(key->flags & IEEE80211_KEY_FLAG_PAIRWISE)) {
-
-		if (key->ap_addr) {
-			/*
-			 * Group keys on hardware that supports multicast frame
-			 * key search use a mac that is the sender's address with
-			 * the high bit set instead of the app-specified address.
-			 */
-			memcpy(gmac, key->ap_addr, ETH_ALEN);
-			gmac[0] |= 0x80;
-			mac = gmac;
-
-			if (key->alg == ALG_TKIP)
-				idx = ath_reserve_key_cache_slot_tkip(common);
-			else
-				idx = ath_reserve_key_cache_slot(common);
-			if (idx < 0)
-				mac = NULL; /* no free key cache entries */
-		}
-
-		if (!mac) {
-			/* For now, use the default keys for broadcast keys. This may
-			 * need to change with virtual interfaces. */
-			idx = key->keyidx;
-		}
+		/* For now, use the default keys for broadcast keys. This may
+		 * need to change with virtual interfaces. */
+		idx = key->keyidx;
 	} else if (key->keyidx) {
 		if (WARN_ON(!sta))
 			return -EOPNOTSUPP;
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 257b10b..1ec836c 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -28,7 +28,6 @@ static DEFINE_PCI_DEVICE_TABLE(ath_pci_id_table) = {
 	{ PCI_VDEVICE(ATHEROS, 0x002C) }, /* PCI-E 802.11n bonded out */
 	{ PCI_VDEVICE(ATHEROS, 0x002D) }, /* PCI   */
 	{ PCI_VDEVICE(ATHEROS, 0x002E) }, /* PCI-E */
-	{ PCI_VDEVICE(ATHEROS, 0x0030) }, /* PCI-E  AR9300 */
 	{ 0 }
 };
 
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index ba13913..ca6065b 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -19,6 +19,12 @@
 
 #define SKB_CB_ATHBUF(__skb)	(*((struct ath_buf **)__skb->cb))
 
+static inline bool ath9k_check_auto_sleep(struct ath_softc *sc)
+{
+	return sc->ps_enabled &&
+	       (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_AUTOSLEEP);
+}
+
 static struct ieee80211_hw * ath_get_virt_hw(struct ath_softc *sc,
 					     struct ieee80211_hdr *hdr)
 {
@@ -616,8 +622,8 @@ static void ath_rx_ps(struct ath_softc *sc, struct sk_buff *skb)
 	hdr = (struct ieee80211_hdr *)skb->data;
 
 	/* Process Beacon and CAB receive in PS state */
-	if ((sc->ps_flags & PS_WAIT_FOR_BEACON) &&
-	    ieee80211_is_beacon(hdr->frame_control))
+	if (((sc->ps_flags & PS_WAIT_FOR_BEACON) || ath9k_check_auto_sleep(sc))
+	    && ieee80211_is_beacon(hdr->frame_control))
 		ath_rx_ps_beacon(sc, skb);
 	else if ((sc->ps_flags & PS_WAIT_FOR_CAB) &&
 		 (ieee80211_is_data(hdr->frame_control) ||
@@ -932,9 +938,10 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 			sc->rx.rxotherant = 0;
 		}
 
-		if (unlikely(sc->ps_flags & (PS_WAIT_FOR_BEACON |
-					     PS_WAIT_FOR_CAB |
-					     PS_WAIT_FOR_PSPOLL_DATA)))
+		if (unlikely(ath9k_check_auto_sleep(sc) ||
+			     (sc->ps_flags & (PS_WAIT_FOR_BEACON |
+					      PS_WAIT_FOR_CAB |
+					      PS_WAIT_FOR_PSPOLL_DATA))))
 			ath_rx_ps(sc, skb);
 
 		ath_rx_send_to_mac80211(hw, sc, skb, rxs);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c b/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
index a273e37..c92b2c0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-ict.c
@@ -30,6 +30,7 @@
 #include <linux/module.h>
 #include <linux/etherdevice.h>
 #include <linux/sched.h>
+#include <linux/gfp.h>
 #include <net/mac80211.h>
 
 #include "iwl-dev.h"
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 107e173..5d3f51f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -376,6 +376,11 @@ void iwl_bg_start_internal_scan(struct work_struct *work)
 
 	mutex_lock(&priv->mutex);
 
+	if (priv->is_internal_short_scan == true) {
+		IWL_DEBUG_SCAN(priv, "Internal scan already in progress\n");
+		goto unlock;
+	}
+
 	if (!iwl_is_ready_rf(priv)) {
 		IWL_DEBUG_SCAN(priv, "not ready or exit pending\n");
 		goto unlock;
@@ -497,17 +502,27 @@ void iwl_bg_scan_completed(struct work_struct *work)
 {
 	struct iwl_priv *priv =
 	    container_of(work, struct iwl_priv, scan_completed);
+	bool internal = false;
 
 	IWL_DEBUG_SCAN(priv, "SCAN complete scan\n");
 
 	cancel_delayed_work(&priv->scan_check);
 
-	if (!priv->is_internal_short_scan)
-		ieee80211_scan_completed(priv->hw, false);
-	else {
+	mutex_lock(&priv->mutex);
+	if (priv->is_internal_short_scan) {
 		priv->is_internal_short_scan = false;
 		IWL_DEBUG_SCAN(priv, "internal short scan completed\n");
+		internal = true;
 	}
+	mutex_unlock(&priv->mutex);
+
+	/*
+	 * Do not hold mutex here since this will cause mac80211 to call
+	 * into driver again into functions that will attempt to take
+	 * mutex.
+	 */
+	if (!internal)
+		ieee80211_scan_completed(priv->hw, false);
 
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index 85ed235..83a2636 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -431,7 +431,7 @@ int iwl_add_bssid_station(struct iwl_priv *priv, const u8 *addr, bool init_rs,
 	struct iwl_link_quality_cmd *link_cmd;
 	unsigned long flags;
 
-	if (*sta_id_r)
+	if (sta_id_r)
 		*sta_id_r = IWL_INVALID_STATION;
 
 	ret = iwl_add_station_common(priv, addr, 0, NULL, &sta_id);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 2d28908..4bd61ee 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2572,14 +2572,18 @@ static void rndis_wlan_do_link_up_work(struct usbnet *usbdev)
 
 static void rndis_wlan_do_link_down_work(struct usbnet *usbdev)
 {
-	union iwreq_data evt;
+	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 
-	netif_carrier_off(usbdev->net);
+	if (priv->connected) {
+		priv->connected = false;
+		memset(priv->bssid, 0, ETH_ALEN);
+
+		deauthenticate(usbdev);
 
-	evt.data.flags = 0;
-	evt.data.length = 0;
-	memset(evt.ap_addr.sa_data, 0, ETH_ALEN);
-	wireless_send_event(usbdev->net, SIOCGIWAP, &evt, NULL);
+		cfg80211_disconnected(usbdev->net, 0, NULL, 0, GFP_KERNEL);
+	}
+
+	netif_carrier_off(usbdev->net);
 }
 
 static void rndis_wlan_worker(struct work_struct *work)
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 4ba7b03..ad2c98a 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -926,7 +926,7 @@ static void rt2400pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 static int rt2400pci_set_state(struct rt2x00_dev *rt2x00dev,
 			       enum dev_state state)
 {
-	u32 reg;
+	u32 reg, reg2;
 	unsigned int i;
 	char put_to_sleep;
 	char bbp_state;
@@ -947,11 +947,12 @@ static int rt2400pci_set_state(struct rt2x00_dev *rt2x00dev,
 	 * device has entered the correct state.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00pci_register_read(rt2x00dev, PWRCSR1, &reg);
-		bbp_state = rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE);
-		rf_state = rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE);
+		rt2x00pci_register_read(rt2x00dev, PWRCSR1, &reg2);
+		bbp_state = rt2x00_get_field32(reg2, PWRCSR1_BBP_CURR_STATE);
+		rf_state = rt2x00_get_field32(reg2, PWRCSR1_RF_CURR_STATE);
 		if (bbp_state == state && rf_state == state)
 			return 0;
+		rt2x00pci_register_write(rt2x00dev, PWRCSR1, reg);
 		msleep(10);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 89d132d..41da3d2 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1084,7 +1084,7 @@ static void rt2500pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 static int rt2500pci_set_state(struct rt2x00_dev *rt2x00dev,
 			       enum dev_state state)
 {
-	u32 reg;
+	u32 reg, reg2;
 	unsigned int i;
 	char put_to_sleep;
 	char bbp_state;
@@ -1105,11 +1105,12 @@ static int rt2500pci_set_state(struct rt2x00_dev *rt2x00dev,
 	 * device has entered the correct state.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00pci_register_read(rt2x00dev, PWRCSR1, &reg);
-		bbp_state = rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE);
-		rf_state = rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE);
+		rt2x00pci_register_read(rt2x00dev, PWRCSR1, &reg2);
+		bbp_state = rt2x00_get_field32(reg2, PWRCSR1_BBP_CURR_STATE);
+		rf_state = rt2x00_get_field32(reg2, PWRCSR1_RF_CURR_STATE);
 		if (bbp_state == state && rf_state == state)
 			return 0;
+		rt2x00pci_register_write(rt2x00dev, PWRCSR1, reg);
 		msleep(10);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 0f8b84b..6991613 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -413,7 +413,7 @@ static void rt2800usb_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 	 */
 	rt2x00_desc_read(txi, 0, &word);
 	rt2x00_set_field32(&word, TXINFO_W0_USB_DMA_TX_PKT_LEN,
-			   skb->len + TXWI_DESC_SIZE);
+			   skb->len - TXINFO_DESC_SIZE);
 	rt2x00_set_field32(&word, TXINFO_W0_WIV,
 			   !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc->flags));
 	rt2x00_set_field32(&word, TXINFO_W0_QSEL, 2);
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index a016f7c..f71eee6 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -206,7 +206,7 @@ void rt2x00pci_uninitialize(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Free irq line.
 	 */
-	free_irq(to_pci_dev(rt2x00dev->dev)->irq, rt2x00dev);
+	free_irq(rt2x00dev->irq, rt2x00dev);
 
 	/*
 	 * Free DMA
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 2e3076f..6a74baf 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1689,7 +1689,7 @@ static void rt61pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 
 static int rt61pci_set_state(struct rt2x00_dev *rt2x00dev, enum dev_state state)
 {
-	u32 reg;
+	u32 reg, reg2;
 	unsigned int i;
 	char put_to_sleep;
 
@@ -1706,10 +1706,11 @@ static int rt61pci_set_state(struct rt2x00_dev *rt2x00dev, enum dev_state state)
 	 * device has entered the correct state.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00pci_register_read(rt2x00dev, MAC_CSR12, &reg);
-		state = rt2x00_get_field32(reg, MAC_CSR12_BBP_CURRENT_STATE);
+		rt2x00pci_register_read(rt2x00dev, MAC_CSR12, &reg2);
+		state = rt2x00_get_field32(reg2, MAC_CSR12_BBP_CURRENT_STATE);
 		if (state == !put_to_sleep)
 			return 0;
+		rt2x00pci_register_write(rt2x00dev, MAC_CSR12, reg);
 		msleep(10);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index e35bd19..6e0d82e 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1366,7 +1366,7 @@ static void rt73usb_disable_radio(struct rt2x00_dev *rt2x00dev)
 
 static int rt73usb_set_state(struct rt2x00_dev *rt2x00dev, enum dev_state state)
 {
-	u32 reg;
+	u32 reg, reg2;
 	unsigned int i;
 	char put_to_sleep;
 
@@ -1383,10 +1383,11 @@ static int rt73usb_set_state(struct rt2x00_dev *rt2x00dev, enum dev_state state)
 	 * device has entered the correct state.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00usb_register_read(rt2x00dev, MAC_CSR12, &reg);
-		state = rt2x00_get_field32(reg, MAC_CSR12_BBP_CURRENT_STATE);
+		rt2x00usb_register_read(rt2x00dev, MAC_CSR12, &reg2);
+		state = rt2x00_get_field32(reg2, MAC_CSR12_BBP_CURRENT_STATE);
 		if (state == !put_to_sleep)
 			return 0;
+		rt2x00usb_register_write(rt2x00dev, MAC_CSR12, reg);
 		msleep(10);
 	}
 
diff --git a/drivers/net/wireless/wl12xx/wl1271_rx.c b/drivers/net/wireless/wl12xx/wl1271_rx.c
index 57f4bfd..b98fb64 100644
--- a/drivers/net/wireless/wl12xx/wl1271_rx.c
+++ b/drivers/net/wireless/wl12xx/wl1271_rx.c
@@ -113,6 +113,8 @@ static void wl1271_rx_handle_data(struct wl1271 *wl, u32 length)
 	wl1271_debug(DEBUG_RX, "rx skb 0x%p: %d B %s", skb, skb->len,
 		     beacon ? "beacon" : "");
 
+	skb_trim(skb, skb->len - desc->pad_len);
+
 	memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 	ieee80211_rx_ni(wl->hw, skb);
 }
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5be900d..de22cbf 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -815,6 +815,7 @@ enum ieee80211_key_flags {
  *	encrypted in hardware.
  * @alg: The key algorithm.
  * @flags: key flags, see &enum ieee80211_key_flags.
+ * @ap_addr: AP's MAC address
  * @keyidx: the key index (0-3)
  * @keylen: key material length
  * @key: key material. For ALG_TKIP the key is encoded as a 256-bit (32 byte)
@@ -831,7 +832,6 @@ struct ieee80211_key_conf {
 	u8 iv_len;
 	u8 hw_key_idx;
 	u8 flags;
-	u8 *ap_addr;
 	s8 keyidx;
 	u8 keylen;
 	u8 key[0];
@@ -1638,6 +1638,8 @@ enum ieee80211_ampdu_mlme_action {
  *	Returns a negative error code on failure.
  *	The callback must be atomic.
  *
+ * @get_survey: Return per-channel survey information
+ *
  * @rfkill_poll: Poll rfkill hardware state. If you need this, you also
  *	need to set wiphy->rfkill_poll to %true before registration,
  *	and need to call wiphy_rfkill_set_hw_state() in the callback.
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 8d4b417..e8f6e3b 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -140,7 +140,6 @@ static void ieee80211_key_enable_hw_accel(struct ieee80211_key *key)
 				     struct ieee80211_sub_if_data,
 				     u.ap);
 
-	key->conf.ap_addr = sdata->dev->dev_addr;
 	ret = drv_set_key(key->local, SET_KEY, sdata, sta, &key->conf);
 
 	if (!ret) {
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 48a5e80..df9d455 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -145,7 +145,7 @@ enum plink_state {
 /**
  * struct sta_ampdu_mlme - STA aggregation information.
  *
- * @tid_state_rx: TID's state in Rx session state machine.
+ * @tid_active_rx: TID's state in Rx session state machine.
  * @tid_rx: aggregation info for Rx per TID
  * @tid_state_tx: TID's state in Tx session state machine.
  * @tid_tx: aggregation info for Tx per TID
diff --git a/net/wireless/chan.c b/net/wireless/chan.c
index d92d088..b01a6f6 100644
--- a/net/wireless/chan.c
+++ b/net/wireless/chan.c
@@ -50,7 +50,7 @@ int cfg80211_set_freq(struct cfg80211_registered_device *rdev,
 	struct ieee80211_channel *chan;
 	int result;
 
-	if (wdev->iftype == NL80211_IFTYPE_MONITOR)
+	if (wdev && wdev->iftype == NL80211_IFTYPE_MONITOR)
 		wdev = NULL;
 
 	if (wdev) {
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index aaa1aad..db71150 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -4443,9 +4443,10 @@ static int nl80211_remain_on_channel(struct sk_buff *skb,
 		if (channel_type != NL80211_CHAN_NO_HT &&
 		    channel_type != NL80211_CHAN_HT20 &&
 		    channel_type != NL80211_CHAN_HT40PLUS &&
-		    channel_type != NL80211_CHAN_HT40MINUS)
+		    channel_type != NL80211_CHAN_HT40MINUS) {
 			err = -EINVAL;
 			goto out;
+		}
 	}
 
 	freq = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]);
@@ -4717,9 +4718,10 @@ static int nl80211_action(struct sk_buff *skb, struct genl_info *info)
 		if (channel_type != NL80211_CHAN_NO_HT &&
 		    channel_type != NL80211_CHAN_HT20 &&
 		    channel_type != NL80211_CHAN_HT40PLUS &&
-		    channel_type != NL80211_CHAN_HT40MINUS)
+		    channel_type != NL80211_CHAN_HT40MINUS) {
 			err = -EINVAL;
 			goto out;
+		}
 	}
 
 	freq = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]);
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index a026c6d..58401d2 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -515,7 +515,7 @@ cfg80211_inform_bss(struct wiphy *wiphy,
 
 	privsz = wiphy->bss_priv_size;
 
-	if (WARN_ON(wiphy->signal_type == NL80211_BSS_SIGNAL_UNSPEC &&
+	if (WARN_ON(wiphy->signal_type == CFG80211_SIGNAL_TYPE_UNSPEC &&
 			(signal < 0 || signal > 100)))
 		return NULL;
 
@@ -571,7 +571,7 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
 				      u.probe_resp.variable);
 	size_t privsz = wiphy->bss_priv_size;
 
-	if (WARN_ON(wiphy->signal_type == NL80211_BSS_SIGNAL_UNSPEC &&
+	if (WARN_ON(wiphy->signal_type == CFG80211_SIGNAL_TYPE_UNSPEC &&
 	            (signal < 0 || signal > 100)))
 		return NULL;
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
