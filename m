From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 13:58:16 -0500
Message-ID: <20100210185816.GB3286@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34124 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820Ab0BJTAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:00:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a few more hopefuls for 2.6.33.  Most of them are small and
obvious.  The b43 one appears larger because it adds a comment, but it
makes a significant performance improvement against a long-standing
regression.  The scan.c one mostly moves some code around and will save
us from a lot of WARN_ON noise.  And just for good measure, we add a USB
ID to rtl8187. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 44bfce5c3ec91baf8ffcd075c66711740f29a949:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Benoit Papillault (1):
      mac80211: Fix probe request filtering in IBSS mode

Jelle Martijn Kok (1):
      rtl8187: Add new device ID

Johannes Berg (1):
      mac80211: fix deferred hardware scan requests

Larry Finger (1):
      b43: Fix throughput regression

Michael Buesch (1):
      ssb: Fix CONFIG_SSB_SDIOHOST typo

Roel Kluin (1):
      iwmc3200wifi: Test of wrong pointer after kzalloc in iwm_mlme_update_bss_table()

Sujith (1):
      ath9k: Fix sequence numbers for PAE frames

Wey-Yi Guy (1):
      iwlwifi: Fix to set correct ht configuration

 drivers/net/wireless/ath/ath9k/xmit.c      |    4 ++--
 drivers/net/wireless/b43/b43.h             |    1 +
 drivers/net/wireless/b43/main.c            |   13 ++++++++++---
 drivers/net/wireless/iwlwifi/iwl-core.c    |    1 +
 drivers/net/wireless/iwmc3200wifi/rx.c     |    2 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c |    1 +
 drivers/ssb/main.c                         |    3 +--
 net/mac80211/ibss.c                        |    2 +-
 net/mac80211/scan.c                        |   18 ++++++++++--------
 9 files changed, 28 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index fa12b90..29bf336 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -1615,7 +1615,7 @@ static int ath_tx_setup_buffer(struct ieee80211_hw *hw, struct ath_buf *bf,
 		bf->bf_frmlen -= padsize;
 	}
 
-	if (conf_is_ht(&hw->conf) && !is_pae(skb))
+	if (conf_is_ht(&hw->conf))
 		bf->bf_state.bf_type |= BUF_HT;
 
 	bf->bf_flags = setup_tx_flags(sc, skb, txctl->txq);
@@ -1701,7 +1701,7 @@ static void ath_tx_start_dma(struct ath_softc *sc, struct ath_buf *bf,
 			goto tx_done;
 		}
 
-		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU) {
+		if ((tx_info->flags & IEEE80211_TX_CTL_AMPDU) && !is_pae(skb)) {
 			/*
 			 * Try aggregation if it's a unicast data frame
 			 * and the destination is HT capable.
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index fe3bf94..c484cc2 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -115,6 +115,7 @@
 #define B43_MMIO_TSF_2			0x636	/* core rev < 3 only */
 #define B43_MMIO_TSF_3			0x638	/* core rev < 3 only */
 #define B43_MMIO_RNG			0x65A
+#define B43_MMIO_IFSSLOT		0x684	/* Interframe slot time */
 #define B43_MMIO_IFSCTL			0x688 /* Interframe space control */
 #define  B43_MMIO_IFSCTL_USE_EDCF	0x0004
 #define B43_MMIO_POWERUP_DELAY		0x6A8
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 19b4eae..fcbf0e2 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -628,10 +628,17 @@ static void b43_upload_card_macaddress(struct b43_wldev *dev)
 static void b43_set_slot_time(struct b43_wldev *dev, u16 slot_time)
 {
 	/* slot_time is in usec. */
-	if (dev->phy.type != B43_PHYTYPE_G)
+	/* This test used to exit for all but a G PHY. */
+	if (b43_current_band(dev->wl) == IEEE80211_BAND_5GHZ)
 		return;
-	b43_write16(dev, 0x684, 510 + slot_time);
-	b43_shm_write16(dev, B43_SHM_SHARED, 0x0010, slot_time);
+	b43_write16(dev, B43_MMIO_IFSSLOT, 510 + slot_time);
+	/* Shared memory location 0x0010 is the slot time and should be
+	 * set to slot_time; however, this register is initially 0 and changing
+	 * the value adversely affects the transmit rate for BCM4311
+	 * devices. Until this behavior is unterstood, delete this step
+	 *
+	 * b43_shm_write16(dev, B43_SHM_SHARED, 0x0010, slot_time);
+	 */
 }
 
 static void b43_short_slot_timing_enable(struct b43_wldev *dev)
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 5461f10..d10bea6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2744,6 +2744,7 @@ int iwl_mac_config(struct ieee80211_hw *hw, u32 changed)
 		if ((le16_to_cpu(priv->staging_rxon.channel) != ch))
 			priv->staging_rxon.flags = 0;
 
+		iwl_set_rxon_ht(priv, ht_conf);
 		iwl_set_rxon_channel(priv, conf->channel);
 
 		iwl_set_flags_for_band(priv, conf->channel->band);
diff --git a/drivers/net/wireless/iwmc3200wifi/rx.c b/drivers/net/wireless/iwmc3200wifi/rx.c
index 3db3d8b..64d16fe 100644
--- a/drivers/net/wireless/iwmc3200wifi/rx.c
+++ b/drivers/net/wireless/iwmc3200wifi/rx.c
@@ -794,7 +794,7 @@ static int iwm_mlme_update_bss_table(struct iwm_priv *iwm, u8 *buf,
 	}
 
 	bss->bss = kzalloc(bss_len, GFP_KERNEL);
-	if (!bss) {
+	if (!bss->bss) {
 		kfree(bss);
 		IWM_ERR(iwm, "Couldn't allocate bss\n");
 		return -ENOMEM;
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index bc5726d..7ba3052 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -65,6 +65,7 @@ static struct usb_device_id rtl8187_table[] __devinitdata = {
 	/* Sitecom */
 	{USB_DEVICE(0x0df6, 0x000d), .driver_info = DEVICE_RTL8187},
 	{USB_DEVICE(0x0df6, 0x0028), .driver_info = DEVICE_RTL8187B},
+	{USB_DEVICE(0x0df6, 0x0029), .driver_info = DEVICE_RTL8187B},
 	/* Sphairon Access Systems GmbH */
 	{USB_DEVICE(0x114B, 0x0150), .driver_info = DEVICE_RTL8187},
 	/* Dick Smith Electronics */
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 5681ebe..03dfd27 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -494,8 +494,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 #endif
 			break;
 		case SSB_BUSTYPE_SDIO:
-#ifdef CONFIG_SSB_SDIO
-			sdev->irq = bus->host_sdio->dev.irq;
+#ifdef CONFIG_SSB_SDIOHOST
 			dev->parent = &bus->host_sdio->dev;
 #endif
 			break;
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 1f2db64..22f0c2a 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -647,7 +647,7 @@ static void ieee80211_rx_mgmt_probe_req(struct ieee80211_sub_if_data *sdata,
 	}
 	if (pos[1] != 0 &&
 	    (pos[1] != ifibss->ssid_len ||
-	     !memcmp(pos + 2, ifibss->ssid, ifibss->ssid_len))) {
+	     memcmp(pos + 2, ifibss->ssid, ifibss->ssid_len))) {
 		/* Ignore ProbeReq for foreign SSID */
 		return;
 	}
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index f934c96..bc17cf7 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -439,6 +439,16 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 	if (local->scan_req)
 		return -EBUSY;
 
+	if (req != local->int_scan_req &&
+	    sdata->vif.type == NL80211_IFTYPE_STATION &&
+	    !list_empty(&ifmgd->work_list)) {
+		/* actually wait for the work it's doing to finish/time out */
+		set_bit(IEEE80211_STA_REQ_SCAN, &ifmgd->request);
+		local->scan_req = req;
+		local->scan_sdata = sdata;
+		return 0;
+	}
+
 	if (local->ops->hw_scan) {
 		u8 *ies;
 
@@ -463,14 +473,6 @@ static int __ieee80211_start_scan(struct ieee80211_sub_if_data *sdata,
 	local->scan_req = req;
 	local->scan_sdata = sdata;
 
-	if (req != local->int_scan_req &&
-	    sdata->vif.type == NL80211_IFTYPE_STATION &&
-	    !list_empty(&ifmgd->work_list)) {
-		/* actually wait for the work it's doing to finish/time out */
-		set_bit(IEEE80211_STA_REQ_SCAN, &ifmgd->request);
-		return 0;
-	}
-
 	if (local->ops->hw_scan)
 		__set_bit(SCAN_HW_SCANNING, &local->scanning);
 	else
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
