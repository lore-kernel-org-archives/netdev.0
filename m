From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-08-16
Date: Mon, 16 Aug 2010 16:34:41 -0400
Message-ID: <20100816203440.GG2656@tuxdriver.com>
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

This group of fixes is intended for 2.6.36.  This includes a fix for a
warning backtrace related to pm_qos in ipw2100, a packet injection oops
for ath9k_htc, a connectivity regression for ath9k_htc related to HT
capabilities handling, a scanning regression in wl1251, 
a firmware loading error in ath9k_htc, and a patch to disable L0s for
all ath5k cards (causes misc wierdness).

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3c09e2647b5e1f1f9fd383971468823c2505e1b0:

  ctcm: rename READ/WRITE defines to avoid redefinitions (2010-08-12 16:04:23 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

John W. Linville (1):
      ipw2100: register pm_qos request before registering pci driver

Maxim Levitsky (1):
      ath5k: disable ASPM L0s for all cards

Rajkumar Manoharan (2):
      ath9k_htc: fix panic on packet injection using airbase-ng tool.
      ath9k_htc: load proper firmware for device ID 7015

Vivek Natarajan (1):
      ath9k_htc: Fix disconnect issue in HT40 mode.

Yuri Kululin (1):
      wl1251: fix trigger scan timeout usage

 drivers/net/wireless/ath/ath5k/base.c         |   21 +++++++++++++++++++++
 drivers/net/wireless/ath/ath9k/eeprom.h       |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_9287.c  |    7 ++++++-
 drivers/net/wireless/ath/ath9k/hif_usb.c      |    8 ++------
 drivers/net/wireless/ath/ath9k/htc_drv_init.c |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    3 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |   15 ++++++++++-----
 drivers/net/wireless/ath/ath9k/reg.h          |    1 +
 drivers/net/wireless/ipw2x00/ipw2100.c        |    5 +++--
 drivers/net/wireless/wl12xx/wl1251_cmd.c      |    2 +-
 10 files changed, 48 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 0d5de25..373dcfe 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -48,6 +48,7 @@
 #include <linux/netdevice.h>
 #include <linux/cache.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 #include <linux/ethtool.h>
 #include <linux/uaccess.h>
 #include <linux/slab.h>
@@ -476,6 +477,26 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	int ret;
 	u8 csz;
 
+	/*
+	 * L0s needs to be disabled on all ath5k cards.
+	 *
+	 * For distributions shipping with CONFIG_PCIEASPM (this will be enabled
+	 * by default in the future in 2.6.36) this will also mean both L1 and
+	 * L0s will be disabled when a pre 1.1 PCIe device is detected. We do
+	 * know L1 works correctly even for all ath5k pre 1.1 PCIe devices
+	 * though but cannot currently undue the effect of a blacklist, for
+	 * details you can read pcie_aspm_sanity_check() and see how it adjusts
+	 * the device link capability.
+	 *
+	 * It may be possible in the future to implement some PCI API to allow
+	 * drivers to override blacklists for pre 1.1 PCIe but for now it is
+	 * best to accept that both L0s and L1 will be disabled completely for
+	 * distributions shipping with CONFIG_PCIEASPM rather than having this
+	 * issue present. Motivation for adding this new API will be to help
+	 * with power consumption for some of these devices.
+	 */
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S);
+
 	ret = pci_enable_device(pdev);
 	if (ret) {
 		dev_err(&pdev->dev, "can't enable device\n");
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
index 8750c55..7f48df1 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/eeprom.h
@@ -191,6 +191,7 @@
 #define AR9287_EEP_NO_BACK_VER       AR9287_EEP_MINOR_VER_1
 
 #define AR9287_EEP_START_LOC            128
+#define AR9287_HTC_EEP_START_LOC        256
 #define AR9287_NUM_2G_CAL_PIERS         3
 #define AR9287_NUM_2G_CCK_TARGET_POWERS 3
 #define AR9287_NUM_2G_20_TARGET_POWERS  3
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index 4a52cf0..dff2da7 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -34,9 +34,14 @@ static bool ath9k_hw_ar9287_fill_eeprom(struct ath_hw *ah)
 	struct ar9287_eeprom *eep = &ah->eeprom.map9287;
 	struct ath_common *common = ath9k_hw_common(ah);
 	u16 *eep_data;
-	int addr, eep_start_loc = AR9287_EEP_START_LOC;
+	int addr, eep_start_loc;
 	eep_data = (u16 *)eep;
 
+	if (ah->hw_version.devid == 0x7015)
+		eep_start_loc = AR9287_HTC_EEP_START_LOC;
+	else
+		eep_start_loc = AR9287_EEP_START_LOC;
+
 	if (!ath9k_hw_use_flash(ah)) {
 		ath_print(common, ATH_DBG_EEPROM,
 			  "Reading from EEPROM, not flash\n");
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 61c1bee..17e7a9a 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -799,7 +799,7 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
 	}
 	kfree(buf);
 
-	if (hif_dev->device_id == 0x7010)
+	if ((hif_dev->device_id == 0x7010) || (hif_dev->device_id == 0x7015))
 		firm_offset = AR7010_FIRMWARE_TEXT;
 	else
 		firm_offset = AR9271_FIRMWARE_TEXT;
@@ -901,6 +901,7 @@ static int ath9k_hif_usb_probe(struct usb_interface *interface,
 
 	switch(hif_dev->device_id) {
 	case 0x7010:
+	case 0x7015:
 	case 0x9018:
 		if (le16_to_cpu(udev->descriptor.bcdDevice) == 0x0202)
 			hif_dev->fw_name = FIRMWARE_AR7010_1_1;
@@ -912,11 +913,6 @@ static int ath9k_hif_usb_probe(struct usb_interface *interface,
 		break;
 	}
 
-	if (!hif_dev->fw_name) {
-		dev_err(&udev->dev, "Can't determine firmware !\n");
-		goto err_htc_hw_alloc;
-	}
-
 	ret = ath9k_hif_usb_dev_init(hif_dev);
 	if (ret) {
 		ret = -EINVAL;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 148b433..2d42791 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -245,6 +245,7 @@ static int ath9k_init_htc_services(struct ath9k_htc_priv *priv, u16 devid)
 
 	switch(devid) {
 	case 0x7010:
+	case 0x7015:
 	case 0x9018:
 		priv->htc->credits = 45;
 		break;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index ebed9d1..7d09b4b 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -366,7 +366,8 @@ static void ath9k_htc_setup_rate(struct ath9k_htc_priv *priv,
 		caps = WLAN_RC_HT_FLAG;
 		if (sta->ht_cap.mcs.rx_mask[1])
 			caps |= WLAN_RC_DS_FLAG;
-		if (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40)
+		if ((sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40) &&
+		     (conf_is_ht40(&priv->hw->conf)))
 			caps |= WLAN_RC_40_FLAG;
 		if (conf_is_ht40(&priv->hw->conf) &&
 		    (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40))
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index bd0b4ac..2a6e45a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -78,18 +78,23 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_sta *sta = tx_info->control.sta;
 	struct ath9k_htc_sta *ista;
-	struct ath9k_htc_vif *avp;
 	struct ath9k_htc_tx_ctl tx_ctl;
 	enum htc_endpoint_id epid;
 	u16 qnum;
 	__le16 fc;
 	u8 *tx_fhdr;
-	u8 sta_idx;
+	u8 sta_idx, vif_idx;
 
 	hdr = (struct ieee80211_hdr *) skb->data;
 	fc = hdr->frame_control;
 
-	avp = (struct ath9k_htc_vif *) tx_info->control.vif->drv_priv;
+	if (tx_info->control.vif &&
+			(struct ath9k_htc_vif *) tx_info->control.vif->drv_priv)
+		vif_idx = ((struct ath9k_htc_vif *)
+				tx_info->control.vif->drv_priv)->index;
+	else
+		vif_idx = priv->nvifs;
+
 	if (sta) {
 		ista = (struct ath9k_htc_sta *) sta->drv_priv;
 		sta_idx = ista->index;
@@ -106,7 +111,7 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 		memset(&tx_hdr, 0, sizeof(struct tx_frame_hdr));
 
 		tx_hdr.node_idx = sta_idx;
-		tx_hdr.vif_idx = avp->index;
+		tx_hdr.vif_idx = vif_idx;
 
 		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU) {
 			tx_ctl.type = ATH9K_HTC_AMPDU;
@@ -169,7 +174,7 @@ int ath9k_htc_tx_start(struct ath9k_htc_priv *priv, struct sk_buff *skb)
 		tx_ctl.type = ATH9K_HTC_NORMAL;
 
 		mgmt_hdr.node_idx = sta_idx;
-		mgmt_hdr.vif_idx = avp->index;
+		mgmt_hdr.vif_idx = vif_idx;
 		mgmt_hdr.tidno = 0;
 		mgmt_hdr.flags = 0;
 
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/ath/ath9k/reg.h
index 633e3d9..d01c4ad 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -899,6 +899,7 @@
 
 #define AR_DEVID_7010(_ah) \
 	(((_ah)->hw_version.devid == 0x7010) || \
+	 ((_ah)->hw_version.devid == 0x7015) || \
 	 ((_ah)->hw_version.devid == 0x9018))
 
 #define AR_RADIO_SREV_MAJOR                   0xf0
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 16bbfa3..1189dbb 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6665,12 +6665,13 @@ static int __init ipw2100_init(void)
 	printk(KERN_INFO DRV_NAME ": %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	printk(KERN_INFO DRV_NAME ": %s\n", DRV_COPYRIGHT);
 
+	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+			   PM_QOS_DEFAULT_VALUE);
+
 	ret = pci_register_driver(&ipw2100_pci_driver);
 	if (ret)
 		goto out;
 
-	pm_qos_add_request(&ipw2100_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
-			   PM_QOS_DEFAULT_VALUE);
 #ifdef CONFIG_IPW2100_DEBUG
 	ipw2100_debug_level = debug;
 	ret = driver_create_file(&ipw2100_pci_driver.driver,
diff --git a/drivers/net/wireless/wl12xx/wl1251_cmd.c b/drivers/net/wireless/wl12xx/wl1251_cmd.c
index a37b30c..ce3722f 100644
--- a/drivers/net/wireless/wl12xx/wl1251_cmd.c
+++ b/drivers/net/wireless/wl12xx/wl1251_cmd.c
@@ -484,7 +484,7 @@ int wl1251_cmd_trigger_scan_to(struct wl1251 *wl, u32 timeout)
 
 	cmd->timeout = timeout;
 
-	ret = wl1251_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd));
+	ret = wl1251_cmd_send(wl, CMD_TRIGGER_SCAN_TO, cmd, sizeof(*cmd));
 	if (ret < 0) {
 		wl1251_error("cmd trigger scan to failed: %d", ret);
 		goto out;
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
