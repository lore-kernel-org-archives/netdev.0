From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2011-08-11
Date: Thu, 11 Aug 2011 14:20:19 -0400
Message-ID: <20110811182018.GF2566@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

This is a little batch of patches intended for 3.1.

Included is a fix for a typo that incorrectly calibrated an ath9k phy,
a fix for an skb leak in ath5k, a fix for a bus error on some Broadcom
SoC using b43, a fix for a memory leak in wl1251, and another pair
of calibration fixes for ath9k. A handful of device ID updates are
included as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit aa02bc7084501d2edecb0e5b9de56da070db19aa:

  PCnet: Fix section mismatch (2011-08-11 07:42:45 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Alex Hacker (1):
      ath9k: fix a misprint which leads to incorrect calibration

Anthony Bourguignon (1):
      rt2x00: Add rt2870 device id for Dvico usb key

Bob Copeland (1):
      ath5k: fix error handling in ath5k_beacon_send

Hauke Mehrtens (1):
      b43: read correct register on bcma bus.

Ivo van Doorn (1):
      rt2x00: Add new rt73 buffalo USB id

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Julia Lawall (1):
      drivers/net/wireless/wl1251: add missing kfree

Larry Finger (1):
      rtlwifi: rtl892cu: New USB IDs

Rajkumar Manoharan (2):
      ath9k_hw: Fix incorrect Tx control power in AR9003 template
      ath9k_hw: update PMU to improve ripple issue for AR9485

 drivers/net/wireless/ath/ath5k/base.c          |   23 ++++++++++++++---------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |    8 ++++----
 drivers/net/wireless/ath/ath9k/ar9003_phy.h    |    2 +-
 drivers/net/wireless/b43/dma.c                 |   20 +++++++++++++++++---
 drivers/net/wireless/rt2x00/rt2800usb.c        |    2 ++
 drivers/net/wireless/rt2x00/rt73usb.c          |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c    |   11 ++++++++---
 drivers/net/wireless/wl1251/acx.c              |    6 +-----
 drivers/net/wireless/wl1251/cmd.c              |    2 +-
 9 files changed, 49 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index f54dff4..c3119a6 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1735,6 +1735,8 @@ ath5k_beacon_setup(struct ath5k_hw *ah, struct ath5k_buf *bf)
 
 	if (dma_mapping_error(ah->dev, bf->skbaddr)) {
 		ATH5K_ERR(ah, "beacon DMA mapping failed\n");
+		dev_kfree_skb_any(skb);
+		bf->skb = NULL;
 		return -EIO;
 	}
 
@@ -1819,8 +1821,6 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 	ath5k_txbuf_free_skb(ah, avf->bbuf);
 	avf->bbuf->skb = skb;
 	ret = ath5k_beacon_setup(ah, avf->bbuf);
-	if (ret)
-		avf->bbuf->skb = NULL;
 out:
 	return ret;
 }
@@ -1840,6 +1840,7 @@ ath5k_beacon_send(struct ath5k_hw *ah)
 	struct ath5k_vif *avf;
 	struct ath5k_buf *bf;
 	struct sk_buff *skb;
+	int err;
 
 	ATH5K_DBG_UNLIMIT(ah, ATH5K_DEBUG_BEACON, "in beacon_send\n");
 
@@ -1888,11 +1889,6 @@ ath5k_beacon_send(struct ath5k_hw *ah)
 
 	avf = (void *)vif->drv_priv;
 	bf = avf->bbuf;
-	if (unlikely(bf->skb == NULL || ah->opmode == NL80211_IFTYPE_STATION ||
-		     ah->opmode == NL80211_IFTYPE_MONITOR)) {
-		ATH5K_WARN(ah, "bf=%p bf_skb=%p\n", bf, bf ? bf->skb : NULL);
-		return;
-	}
 
 	/*
 	 * Stop any current dma and put the new frame on the queue.
@@ -1906,8 +1902,17 @@ ath5k_beacon_send(struct ath5k_hw *ah)
 
 	/* refresh the beacon for AP or MESH mode */
 	if (ah->opmode == NL80211_IFTYPE_AP ||
-	    ah->opmode == NL80211_IFTYPE_MESH_POINT)
-		ath5k_beacon_update(ah->hw, vif);
+	    ah->opmode == NL80211_IFTYPE_MESH_POINT) {
+		err = ath5k_beacon_update(ah->hw, vif);
+		if (err)
+			return;
+	}
+
+	if (unlikely(bf->skb == NULL || ah->opmode == NL80211_IFTYPE_STATION ||
+		     ah->opmode == NL80211_IFTYPE_MONITOR)) {
+		ATH5K_WARN(ah, "bf=%p bf_skb=%p\n", bf, bf->skb);
+		return;
+	}
 
 	trace_ath5k_tx(ah, bf->skb, &ah->txqs[ah->bhalq]);
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index d109c25..c34bef1 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -307,7 +307,7 @@ static const struct ar9300_eeprom ar9300_default = {
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 1) } },
 
-		 { { CTL(60, 1), CTL(60, 0), CTL(0, 0), CTL(0, 0) } },
+		 { { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 
@@ -884,7 +884,7 @@ static const struct ar9300_eeprom ar9300_x113 = {
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 1) } },
 
-		 { { CTL(60, 1), CTL(60, 0), CTL(0, 0), CTL(0, 0) } },
+		 { { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 
@@ -2040,7 +2040,7 @@ static const struct ar9300_eeprom ar9300_x112 = {
 		{ { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		{ { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 1) } },
 
-		{ { CTL(60, 1), CTL(60, 0), CTL(0, 0), CTL(0, 0) } },
+		{ { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 0) } },
 		{ { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 		{ { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 
@@ -3734,7 +3734,7 @@ static void ar9003_hw_internal_regulator_apply(struct ath_hw *ah)
 				}
 			} else {
 				reg_pmu_set = (5 << 1) | (7 << 4) |
-					      (1 << 8) | (2 << 14) |
+					      (2 << 8) | (2 << 14) |
 					      (6 << 17) | (1 << 20) |
 					      (3 << 24) | (1 << 28);
 			}
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.h b/drivers/net/wireless/ath/ath9k/ar9003_phy.h
index 6de3f0b..5c59042 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.h
@@ -850,7 +850,7 @@
 #define AR_PHY_TPC_11_B1         (AR_SM1_BASE + 0x220)
 #define AR_PHY_PDADC_TAB_1       (AR_SM1_BASE + 0x240)
 #define AR_PHY_TX_IQCAL_STATUS_B1   (AR_SM1_BASE + 0x48c)
-#define AR_PHY_TX_IQCAL_CORR_COEFF_B1(_i)    (AR_SM_BASE + 0x450 + ((_i) << 2))
+#define AR_PHY_TX_IQCAL_CORR_COEFF_B1(_i)    (AR_SM1_BASE + 0x450 + ((_i) << 2))
 
 /*
  * Channel 2 Register Map
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 83cba22..481e534 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -795,9 +795,23 @@ static u64 supported_dma_mask(struct b43_wldev *dev)
 	u32 tmp;
 	u16 mmio_base;
 
-	tmp = b43_read32(dev, SSB_TMSHIGH);
-	if (tmp & SSB_TMSHIGH_DMA64)
-		return DMA_BIT_MASK(64);
+	switch (dev->dev->bus_type) {
+#ifdef CONFIG_B43_BCMA
+	case B43_BUS_BCMA:
+		tmp = bcma_aread32(dev->dev->bdev, BCMA_IOST);
+		if (tmp & BCMA_IOST_DMA64)
+			return DMA_BIT_MASK(64);
+		break;
+#endif
+#ifdef CONFIG_B43_SSB
+	case B43_BUS_SSB:
+		tmp = ssb_read32(dev->dev->sdev, SSB_TMSHIGH);
+		if (tmp & SSB_TMSHIGH_DMA64)
+			return DMA_BIT_MASK(64);
+		break;
+#endif
+	}
+
 	mmio_base = b43_dmacontroller_base(0, 0);
 	b43_write32(dev, mmio_base + B43_DMA32_TXCTL, B43_DMA32_TXADDREXT_MASK);
 	tmp = b43_read32(dev, mmio_base + B43_DMA32_TXCTL);
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 5075593..9395631 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -921,6 +921,8 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	{ USB_DEVICE(0x07d1, 0x3c16) },
 	/* Draytek */
 	{ USB_DEVICE(0x07fa, 0x7712) },
+	/* DVICO */
+	{ USB_DEVICE(0x0fe9, 0xb307) },
 	/* Edimax */
 	{ USB_DEVICE(0x7392, 0x7711) },
 	{ USB_DEVICE(0x7392, 0x7717) },
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 6a93939..0baeb89 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2420,6 +2420,7 @@ static struct usb_device_id rt73usb_device_table[] = {
 	/* Buffalo */
 	{ USB_DEVICE(0x0411, 0x00d8) },
 	{ USB_DEVICE(0x0411, 0x00d9) },
+	{ USB_DEVICE(0x0411, 0x00e6) },
 	{ USB_DEVICE(0x0411, 0x00f4) },
 	{ USB_DEVICE(0x0411, 0x0116) },
 	{ USB_DEVICE(0x0411, 0x0119) },
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 942f7a3..ef63c0d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -281,6 +281,8 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x817d, rtl92cu_hal_cfg)},
 	/* 8188CE-VAU USB minCard (b/g mode only) */
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x817e, rtl92cu_hal_cfg)},
+	/* 8188RU in Alfa AWUS036NHR */
+	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x817f, rtl92cu_hal_cfg)},
 	/* 8188 Combo for BC4 */
 	{RTL_USB_DEVICE(USB_VENDER_ID_REALTEK, 0x8754, rtl92cu_hal_cfg)},
 
@@ -303,20 +305,23 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(0x0eb0, 0x9071, rtl92cu_hal_cfg)}, /*NO Brand - Etop*/
 	/* HP - Lite-On ,8188CUS Slim Combo */
 	{RTL_USB_DEVICE(0x103c, 0x1629, rtl92cu_hal_cfg)},
+	{RTL_USB_DEVICE(0x13d3, 0x3357, rtl92cu_hal_cfg)}, /* AzureWave */
 	{RTL_USB_DEVICE(0x2001, 0x3308, rtl92cu_hal_cfg)}, /*D-Link - Alpha*/
 	{RTL_USB_DEVICE(0x2019, 0xab2a, rtl92cu_hal_cfg)}, /*Planex - Abocom*/
 	{RTL_USB_DEVICE(0x2019, 0xed17, rtl92cu_hal_cfg)}, /*PCI - Edimax*/
 	{RTL_USB_DEVICE(0x20f4, 0x648b, rtl92cu_hal_cfg)}, /*TRENDnet - Cameo*/
 	{RTL_USB_DEVICE(0x7392, 0x7811, rtl92cu_hal_cfg)}, /*Edimax - Edimax*/
-	{RTL_USB_DEVICE(0x3358, 0x13d3, rtl92cu_hal_cfg)}, /*Azwave 8188CE-VAU*/
+	{RTL_USB_DEVICE(0x13d3, 0x3358, rtl92cu_hal_cfg)}, /*Azwave 8188CE-VAU*/
 	/* Russian customer -Azwave (8188CE-VAU  b/g mode only) */
-	{RTL_USB_DEVICE(0x3359, 0x13d3, rtl92cu_hal_cfg)},
+	{RTL_USB_DEVICE(0x13d3, 0x3359, rtl92cu_hal_cfg)},
+	{RTL_USB_DEVICE(0x4855, 0x0090, rtl92cu_hal_cfg)}, /* Feixun */
+	{RTL_USB_DEVICE(0x4855, 0x0091, rtl92cu_hal_cfg)}, /* NetweeN-Feixun */
+	{RTL_USB_DEVICE(0x9846, 0x9041, rtl92cu_hal_cfg)}, /* Netgear Cameo */
 
 	/****** 8192CU ********/
 	{RTL_USB_DEVICE(0x0586, 0x341f, rtl92cu_hal_cfg)}, /*Zyxel -Abocom*/
 	{RTL_USB_DEVICE(0x07aa, 0x0056, rtl92cu_hal_cfg)}, /*ATKK-Gemtek*/
 	{RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai -Abocom*/
-	{RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Abocom -Abocom*/
 	{RTL_USB_DEVICE(0x2001, 0x3307, rtl92cu_hal_cfg)}, /*D-Link-Cameo*/
 	{RTL_USB_DEVICE(0x2001, 0x3309, rtl92cu_hal_cfg)}, /*D-Link-Alpha*/
 	{RTL_USB_DEVICE(0x2001, 0x330a, rtl92cu_hal_cfg)}, /*D-Link-Alpha*/
diff --git a/drivers/net/wireless/wl1251/acx.c b/drivers/net/wireless/wl1251/acx.c
index ef8370e..ad87a1a 100644
--- a/drivers/net/wireless/wl1251/acx.c
+++ b/drivers/net/wireless/wl1251/acx.c
@@ -140,8 +140,6 @@ int wl1251_acx_sleep_auth(struct wl1251 *wl, u8 sleep_auth)
 	auth->sleep_auth = sleep_auth;
 
 	ret = wl1251_cmd_configure(wl, ACX_SLEEP_AUTH, auth, sizeof(*auth));
-	if (ret < 0)
-		return ret;
 
 out:
 	kfree(auth);
@@ -681,10 +679,8 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
-	if (ret < 0) {
+	if (ret < 0)
 		wl1251_warning("failed to set cca threshold: %d", ret);
-		return ret;
-	}
 
 out:
 	kfree(detection);
diff --git a/drivers/net/wireless/wl1251/cmd.c b/drivers/net/wireless/wl1251/cmd.c
index 81f164b..d14d69d 100644
--- a/drivers/net/wireless/wl1251/cmd.c
+++ b/drivers/net/wireless/wl1251/cmd.c
@@ -241,7 +241,7 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 	if (ret < 0) {
 		wl1251_error("tx %s cmd for channel %d failed",
 			     enable ? "start" : "stop", channel);
-		return ret;
+		goto out;
 	}
 
 	wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
