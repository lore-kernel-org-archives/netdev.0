From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-04-23
Date: Wed, 23 Apr 2008 21:55:43 -0400
Message-ID: <20080424015543.GA16453@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2320 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbYDXCaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 22:30:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is a round of fixes for 2.6.26.  The only ones that aren't strictly
fixes are a MAINTAINERS update for mac80211 and a change in the element
ID values used for 802.11s to avoid conflicts with approved portions of
the standard -- those seem worthy of fix status to me. :-)

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d7d313000ba2fc94a5383511a17ff38a39bab928:
  Tomas Winkler (1):
        iwlwifi: Fix built-in compilation of iwlcore

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      mac80211: Fix n-band association problem

Adrian Bunk (1):
      net/mac80211/rx.c: fix off-by-one

Johannes Berg (1):
      mac80211: MAINTAINERS update

Larry Finger (1):
      ssb: Fix all-ones boardflags

Luis Carlos Cobo (1):
      mac80211: update mesh EID values

Michael Buesch (4):
      b43: Workaround invalid bluetooth settings
      b43: Fix HostFlags data types
      b43: Add more btcoexist workarounds
      b43: Workaround DMA quirks

Nick Kossifidis (1):
      ath5k: Fix radio identification on AR5424/2424

Pavel Emelyanov (1):
      mac80211: Fix race between ieee80211_rx_bss_put and lookup routines.

Roel Kluin (2):
      prism54: prism54_get_encode() test below 0 on unsigned index
      wireless: rndis_wlan: modparam_workaround_interval is never below 0.

Roland Dreier (1):
      iwlwifi: Don't unlock priv->mutex if it isn't locked

Ron Rindjunsky (1):
      mac80211: fix use before check of Qdisc length

 MAINTAINERS                                 |    6 +--
 drivers/net/wireless/ath5k/hw.c             |   14 ++++++--
 drivers/net/wireless/b43/dma.c              |   47 ++++++++++++++++++++++----
 drivers/net/wireless/b43/main.c             |   32 ++++++++++++++++--
 drivers/net/wireless/b43/phy.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    1 -
 drivers/net/wireless/prism54/isl_ioctl.c    |    2 +-
 drivers/net/wireless/rndis_wlan.c           |    5 ++-
 drivers/ssb/pci.c                           |    5 +++
 include/linux/ieee80211.h                   |   20 +++++++----
 net/mac80211/mlme.c                         |   28 ++++++++++++++--
 net/mac80211/rx.c                           |    2 +-
 net/mac80211/wme.c                          |    2 +-
 14 files changed, 129 insertions(+), 38 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 45b86ab..36aadf6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2547,12 +2547,10 @@ W:	http://www.tazenda.demon.co.uk/phil/linux-hp
 S:	Maintained
 
 MAC80211
-P:	Michael Wu
-M:	flamingice@sourmilk.net
 P:	Johannes Berg
 M:	johannes@sipsolutions.net
-P:	Jiri Benc
-M:	jbenc@suse.cz
+P:	Michael Wu
+M:	flamingice@sourmilk.net
 L:	linux-wireless@vger.kernel.org
 W:	http://linuxwireless.org/
 T:	git kernel.org:/pub/scm/linux/kernel/git/linville/wireless-2.6.git
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index 87e7822..5fb1ae6 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -304,14 +304,20 @@ struct ath5k_hw *ath5k_hw_attach(struct ath5k_softc *sc, u8 mac_version)
 		ah->ah_radio = AR5K_RF2413;
 		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
 	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_SC2) {
-
 		ah->ah_radio = AR5K_RF5413;
+		ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
+	} else if (ah->ah_radio_5ghz_revision < AR5K_SREV_RAD_5133) {
 
-		if (ah->ah_mac_srev <= AR5K_SREV_VER_AR5424 &&
-			ah->ah_mac_srev >= AR5K_SREV_VER_AR2424)
+		/* AR5424 */
+		if (srev >= AR5K_SREV_VER_AR5424) {
+			ah->ah_radio = AR5K_RF5413;
 			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5424;
-		else
+		/* AR2424 */
+		} else {
+			ah->ah_radio = AR5K_RF2413; /* For testing */
 			ah->ah_phy_spending = AR5K_PHY_SPENDING_RF5112A;
+		}
+
 	/*
 	 * Register returns 0x4 for radio revision
 	 * so ath5k_hw_radio_revision doesn't parse the value
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 21c886a..6dcbb3c 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -980,6 +980,42 @@ void b43_dma_free(struct b43_wldev *dev)
 	destroy_ring(dma, tx_ring_mcast);
 }
 
+static int b43_dma_set_mask(struct b43_wldev *dev, u64 mask)
+{
+	u64 orig_mask = mask;
+	bool fallback = 0;
+	int err;
+
+	/* Try to set the DMA mask. If it fails, try falling back to a
+	 * lower mask, as we can always also support a lower one. */
+	while (1) {
+		err = ssb_dma_set_mask(dev->dev, mask);
+		if (!err)
+			break;
+		if (mask == DMA_64BIT_MASK) {
+			mask = DMA_32BIT_MASK;
+			fallback = 1;
+			continue;
+		}
+		if (mask == DMA_32BIT_MASK) {
+			mask = DMA_30BIT_MASK;
+			fallback = 1;
+			continue;
+		}
+		b43err(dev->wl, "The machine/kernel does not support "
+		       "the required %u-bit DMA mask\n",
+		       (unsigned int)dma_mask_to_engine_type(orig_mask));
+		return -EOPNOTSUPP;
+	}
+	if (fallback) {
+		b43info(dev->wl, "DMA mask fallback from %u-bit to %u-bit\n",
+			(unsigned int)dma_mask_to_engine_type(orig_mask),
+			(unsigned int)dma_mask_to_engine_type(mask));
+	}
+
+	return 0;
+}
+
 int b43_dma_init(struct b43_wldev *dev)
 {
 	struct b43_dma *dma = &dev->dma;
@@ -989,14 +1025,9 @@ int b43_dma_init(struct b43_wldev *dev)
 
 	dmamask = supported_dma_mask(dev);
 	type = dma_mask_to_engine_type(dmamask);
-	err = ssb_dma_set_mask(dev->dev, dmamask);
-	if (err) {
-		b43err(dev->wl, "The machine/kernel does not support "
-		       "the required DMA mask (0x%08X%08X)\n",
-		       (unsigned int)((dmamask & 0xFFFFFFFF00000000ULL) >> 32),
-		       (unsigned int)(dmamask & 0x00000000FFFFFFFFULL));
-		return -EOPNOTSUPP;
-	}
+	err = b43_dma_set_mask(dev, dmamask);
+	if (err)
+		return err;
 
 	err = -ENOMEM;
 	/* setup TX DMA channels. */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index cf5c046..94a0cde 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -84,6 +84,10 @@ int b43_modparam_qos = 1;
 module_param_named(qos, b43_modparam_qos, int, 0444);
 MODULE_PARM_DESC(qos, "Enable QOS support (default on)");
 
+static int modparam_btcoex = 1;
+module_param_named(btcoex, modparam_btcoex, int, 0444);
+MODULE_PARM_DESC(btcoex, "Enable Bluetooth coexistance (default on)");
+
 
 static const struct ssb_device_id b43_ssb_tbl[] = {
 	SSB_DEVICE(SSB_VENDOR_BROADCOM, SSB_DEV_80211, 5),
@@ -3706,8 +3710,10 @@ static void setup_struct_wldev_for_init(struct b43_wldev *dev)
 static void b43_bluetooth_coext_enable(struct b43_wldev *dev)
 {
 	struct ssb_sprom *sprom = &dev->dev->bus->sprom;
-	u32 hf;
+	u64 hf;
 
+	if (!modparam_btcoex)
+		return;
 	if (!(sprom->boardflags_lo & B43_BFL_BTCOEXIST))
 		return;
 	if (dev->phy.type != B43_PHYTYPE_B && !dev->phy.gmode)
@@ -3719,11 +3725,13 @@ static void b43_bluetooth_coext_enable(struct b43_wldev *dev)
 	else
 		hf |= B43_HF_BTCOEX;
 	b43_hf_write(dev, hf);
-	//TODO
 }
 
 static void b43_bluetooth_coext_disable(struct b43_wldev *dev)
-{				//TODO
+{
+	if (!modparam_btcoex)
+		return;
+	//TODO
 }
 
 static void b43_imcfglo_timeouts_workaround(struct b43_wldev *dev)
@@ -3852,7 +3860,8 @@ static int b43_wireless_core_init(struct b43_wldev *dev)
 	struct ssb_sprom *sprom = &bus->sprom;
 	struct b43_phy *phy = &dev->phy;
 	int err;
-	u32 hf, tmp;
+	u64 hf;
+	u32 tmp;
 
 	B43_WARN_ON(b43_status(dev) != B43_STAT_UNINIT);
 
@@ -4414,8 +4423,16 @@ static int b43_one_core_attach(struct ssb_device *dev, struct b43_wl *wl)
 	return err;
 }
 
+#define IS_PDEV(pdev, _vendor, _device, _subvendor, _subdevice)		( \
+	(pdev->vendor == PCI_VENDOR_ID_##_vendor) &&			\
+	(pdev->device == _device) &&					\
+	(pdev->subsystem_vendor == PCI_VENDOR_ID_##_subvendor) &&	\
+	(pdev->subsystem_device == _subdevice)				)
+
 static void b43_sprom_fixup(struct ssb_bus *bus)
 {
+	struct pci_dev *pdev;
+
 	/* boardflags workarounds */
 	if (bus->boardinfo.vendor == SSB_BOARDVENDOR_DELL &&
 	    bus->chip_id == 0x4301 && bus->boardinfo.rev == 0x74)
@@ -4423,6 +4440,13 @@ static void b43_sprom_fixup(struct ssb_bus *bus)
 	if (bus->boardinfo.vendor == PCI_VENDOR_ID_APPLE &&
 	    bus->boardinfo.type == 0x4E && bus->boardinfo.rev > 0x40)
 		bus->sprom.boardflags_lo |= B43_BFL_PACTRL;
+	if (bus->bustype == SSB_BUSTYPE_PCI) {
+		pdev = bus->host_pci;
+		if (IS_PDEV(pdev, BROADCOM, 0x4318, ASUSTEK, 0x100F) ||
+		    IS_PDEV(pdev, BROADCOM, 0x4320, LINKSYS, 0x0015) ||
+		    IS_PDEV(pdev, BROADCOM, 0x4320, LINKSYS, 0x0013))
+			bus->sprom.boardflags_lo &= ~B43_BFL_BTCOEXIST;
+	}
 }
 
 static void b43_wireless_exit(struct ssb_device *dev, struct b43_wl *wl)
diff --git a/drivers/net/wireless/b43/phy.c b/drivers/net/wireless/b43/phy.c
index 575c543..de024dc 100644
--- a/drivers/net/wireless/b43/phy.c
+++ b/drivers/net/wireless/b43/phy.c
@@ -2043,7 +2043,7 @@ int b43_phy_init(struct b43_wldev *dev)
 void b43_set_rx_antenna(struct b43_wldev *dev, int antenna)
 {
 	struct b43_phy *phy = &dev->phy;
-	u32 hf;
+	u64 hf;
 	u16 tmp;
 	int autodiv = 0;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 1a5678f..a1a0b3c 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6907,7 +6907,6 @@ static int iwl3945_mac_config_interface(struct ieee80211_hw *hw,
 
 	if (priv->vif != vif) {
 		IWL_DEBUG_MAC80211("leave - priv->vif != vif\n");
-		mutex_unlock(&priv->mutex);
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d7e2358..d0bbcaa 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6473,7 +6473,6 @@ static int iwl4965_mac_config_interface(struct ieee80211_hw *hw,
 
 	if (priv->vif != vif) {
 		IWL_DEBUG_MAC80211("leave - priv->vif != vif\n");
-		mutex_unlock(&priv->mutex);
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index e5b3c28..5b375b2 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -1186,7 +1186,7 @@ prism54_get_encode(struct net_device *ndev, struct iw_request_info *info,
 	rvalue |= mgt_get_request(priv, DOT11_OID_DEFKEYID, 0, NULL, &r);
 	devindex = r.u;
 	/* Now get the key, return it */
-	if ((index < 0) || (index > 3))
+	if (index == -1 || index > 3)
 		/* no index provided, use the current one */
 		index = devindex;
 	rvalue |= mgt_get_request(priv, DOT11_OID_DEFKEYX, index, NULL, &r);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 977751f..d0b1fb1 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -2402,7 +2402,6 @@ static int bcm4320_early_init(struct usbnet *dev)
 	priv->param_power_output = modparam_power_output;
 	priv->param_roamtrigger  = modparam_roamtrigger;
 	priv->param_roamdelta    = modparam_roamdelta;
-	priv->param_workaround_interval = modparam_workaround_interval;
 
 	priv->param_country[0] = toupper(priv->param_country[0]);
 	priv->param_country[1] = toupper(priv->param_country[1]);
@@ -2425,8 +2424,10 @@ static int bcm4320_early_init(struct usbnet *dev)
 	else if (priv->param_roamdelta > 2)
 		priv->param_roamdelta = 2;
 
-	if (priv->param_workaround_interval < 0)
+	if (modparam_workaround_interval < 0)
 		priv->param_workaround_interval = 500;
+	else
+		priv->param_workaround_interval = modparam_workaround_interval;
 
 	rndis_set_config_parameter_str(dev, "Country", priv->param_country);
 	rndis_set_config_parameter_str(dev, "FrameBursting",
diff --git a/drivers/ssb/pci.c b/drivers/ssb/pci.c
index 904b1a8..57c4ccf 100644
--- a/drivers/ssb/pci.c
+++ b/drivers/ssb/pci.c
@@ -484,6 +484,11 @@ static int sprom_extract(struct ssb_bus *bus, struct ssb_sprom *out,
 			goto unsupported;
 	}
 
+	if (out->boardflags_lo == 0xFFFF)
+		out->boardflags_lo = 0;  /* per specs */
+	if (out->boardflags_hi == 0xFFFF)
+		out->boardflags_hi = 0;  /* per specs */
+
 	return 0;
 unsupported:
 	ssb_printk(KERN_WARNING PFX "Unsupported SPROM revision %d "
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index f27d11a..529f301 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -465,13 +465,19 @@ enum ieee80211_eid {
 	WLAN_EID_TS_DELAY = 43,
 	WLAN_EID_TCLAS_PROCESSING = 44,
 	WLAN_EID_QOS_CAPA = 46,
-	/* 802.11s */
-	WLAN_EID_MESH_CONFIG = 36,      /* Pending IEEE 802.11 ANA approval */
-	WLAN_EID_MESH_ID = 37,          /* Pending IEEE 802.11 ANA approval */
-	WLAN_EID_PEER_LINK = 40,	/* Pending IEEE 802.11 ANA approval */
-	WLAN_EID_PREQ = 53,		/* Pending IEEE 802.11 ANA approval */
-	WLAN_EID_PREP = 54,		/* Pending IEEE 802.11 ANA approval */
-	WLAN_EID_PERR = 55,		/* Pending IEEE 802.11 ANA approval */
+	/* 802.11s
+	 *
+	 * All mesh EID numbers are pending IEEE 802.11 ANA approval.
+	 * The numbers have been incremented from those suggested in
+	 * 802.11s/D2.0 so that MESH_CONFIG does not conflict with
+	 * EXT_SUPP_RATES.
+	 */
+	WLAN_EID_MESH_CONFIG = 51,
+	WLAN_EID_MESH_ID = 52,
+	WLAN_EID_PEER_LINK = 55,
+	WLAN_EID_PREQ = 68,
+	WLAN_EID_PREP = 69,
+	WLAN_EID_PERR = 70,
 	/* 802.11h */
 	WLAN_EID_PWR_CONSTRAINT = 32,
 	WLAN_EID_PWR_CAPABILITY = 33,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 6b75cb6..a5e5c31 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2248,10 +2248,13 @@ static void ieee80211_rx_bss_put(struct net_device *dev,
 				 struct ieee80211_sta_bss *bss)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	if (!atomic_dec_and_test(&bss->users))
+
+	local_bh_disable();
+	if (!atomic_dec_and_lock(&bss->users, &local->sta_bss_lock)) {
+		local_bh_enable();
 		return;
+	}
 
-	spin_lock_bh(&local->sta_bss_lock);
 	__ieee80211_rx_bss_hash_del(dev, bss);
 	list_del(&bss->list);
 	spin_unlock_bh(&local->sta_bss_lock);
@@ -2709,7 +2712,26 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 			bss->wmm_ie_len = elems.wmm_param_len + 2;
 		} else
 			bss->wmm_ie_len = 0;
-	} else if (!elems.wmm_param && bss->wmm_ie) {
+	} else if (elems.wmm_info &&
+		    (!bss->wmm_ie || bss->wmm_ie_len != elems.wmm_info_len ||
+		     memcmp(bss->wmm_ie, elems.wmm_info, elems.wmm_info_len))) {
+		 /* As for certain AP's Fifth bit is not set in WMM IE in
+		  * beacon frames.So while parsing the beacon frame the
+		  * wmm_info structure is used instead of wmm_param.
+		  * wmm_info structure was never used to set bss->wmm_ie.
+		  * This code fixes this problem by copying the WME
+		  * information from wmm_info to bss->wmm_ie and enabling
+		  * n-band association.
+		  */
+		kfree(bss->wmm_ie);
+		bss->wmm_ie = kmalloc(elems.wmm_info_len + 2, GFP_ATOMIC);
+		if (bss->wmm_ie) {
+			memcpy(bss->wmm_ie, elems.wmm_info - 2,
+			       elems.wmm_info_len + 2);
+			bss->wmm_ie_len = elems.wmm_info_len + 2;
+		} else
+			bss->wmm_ie_len = 0;
+	} else if (!elems.wmm_param && !elems.wmm_info && bss->wmm_ie) {
 		kfree(bss->wmm_ie);
 		bss->wmm_ie = NULL;
 		bss->wmm_ie_len = 0;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 52e4554..02f436a 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2170,7 +2170,7 @@ void __ieee80211_rx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_supported_band *sband;
 
 	if (status->band < 0 ||
-	    status->band > IEEE80211_NUM_BANDS) {
+	    status->band >= IEEE80211_NUM_BANDS) {
 		WARN_ON(1);
 		return;
 	}
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 4e94e40..64faa3d 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -709,7 +709,7 @@ void ieee80211_requeue(struct ieee80211_local *local, int queue)
 	struct ieee80211_sched_data *q = qdisc_priv(root_qd);
 	struct Qdisc *qdisc = q->queues[queue];
 	struct sk_buff *skb = NULL;
-	u32 len = qdisc->q.qlen;
+	u32 len;
 
 	if (!qdisc || !qdisc->dequeue)
 		return;
-- 
John W. Linville
linville@tuxdriver.com
