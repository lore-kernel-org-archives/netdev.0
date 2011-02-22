From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-02-22
Date: Tue, 22 Feb 2011 14:37:57 -0500
Message-ID: <20110222193757.GF12153@tuxdriver.com>
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

Here is the latest round of wireless fixes intended for 2.6.38.
Included are a DMA API fix for p54, an ath5k channel setting fix
for AR2317 hardware, a WARNING fix related to conn_mon_timer, a lock
order fix in cfg80211_wext_siwfreq, a bluetooth locking fix, and a
few simple hardware-enablement patches.

There are a couple of other notables.  There is an ath9k patch that
reverts some earlier patches that cause a regression in power usage.
Also, there is a fairly large ath5k patch to address a regression
related to fast channel switching.  The patch seems bigger than it
really is because it moves some code around.  Both of these cite the
related bugzilla entry.

Please let me know if there are problems!

John

---

The following changes since commit c24f691b56107feeba076616982093ee2d3c8fb5:

  tcp: undo_retrans counter fixes (2011-02-21 11:31:18 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros BT AR5BBU12 fw supported

Christian Lamparter (1):
      p54pci: update receive dma buffers before and after processing

Daniel J Blueman (1):
      fix cfg80211_wext_siwfreq lock ordering...

Gertjan van Wingerde (1):
      rt2x00: Fix WPA TKIP Michael MIC failures.

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6

Mohammed Shafi Shajakhan (1):
      ath9k: Fix ath9k prevents CPU to enter C3 states

Nick Kossifidis (1):
      ath5k: Fix fast channel switching

Nikolay Ledovskikh (1):
      ath5k: Correct channel setting for AR2317 chip

Oliver Neukum (1):
      Bluetooth: fix crash with quirky dongles doing sound

Stanislaw Gruszka (1):
      mac80211: fix conn_mon_timer running after disassociate

Vladislav P (1):
      Bluetooth: Release BTM while sleeping to avoid deadlock

Xose Vazquez Perez (1):
      wireless: rt2x00: rt2800pci.c: add two ids

 drivers/bluetooth/ath3k.c               |    3 +
 drivers/bluetooth/btusb.c               |    7 +-
 drivers/net/wireless/ath/ath5k/phy.c    |  143 +++++++++++++++++++------------
 drivers/net/wireless/ath/ath9k/ath9k.h  |    6 --
 drivers/net/wireless/ath/ath9k/init.c   |    8 --
 drivers/net/wireless/ath/ath9k/main.c   |    8 --
 drivers/net/wireless/p54/p54pci.c       |   14 ++-
 drivers/net/wireless/rt2x00/rt2800pci.c |    8 ++
 drivers/net/wireless/rt2x00/rt2800usb.c |    6 ++
 net/bluetooth/rfcomm/tty.c              |    2 +
 net/mac80211/mlme.c                     |    6 ++
 net/wireless/wext-compat.c              |    4 +-
 12 files changed, 129 insertions(+), 86 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 333c212..6dcd55a 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -41,6 +41,9 @@ static struct usb_device_id ath3k_table[] = {
 
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03F0, 0x311D) },
+
+	/* Atheros AR5BBU12 with sflash firmware */
+	{ USB_DEVICE(0x0489, 0xE02C) },
 	{ }	/* Terminating entry */
 };
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 4cefa91..b7f2f37 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -105,6 +105,9 @@ static struct usb_device_id blacklist_table[] = {
 	/* Atheros AR9285 Malbec with sflash firmware */
 	{ USB_DEVICE(0x03f0, 0x311d), .driver_info = BTUSB_IGNORE },
 
+	/* Atheros AR5BBU12 with sflash firmware */
+	{ USB_DEVICE(0x0489, 0xe02c), .driver_info = BTUSB_IGNORE },
+
 	/* Broadcom BCM2035 */
 	{ USB_DEVICE(0x0a5c, 0x2035), .driver_info = BTUSB_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x0a5c, 0x200a), .driver_info = BTUSB_WRONG_SCO_MTU },
@@ -829,7 +832,7 @@ static void btusb_work(struct work_struct *work)
 
 	if (hdev->conn_hash.sco_num > 0) {
 		if (!test_bit(BTUSB_DID_ISO_RESUME, &data->flags)) {
-			err = usb_autopm_get_interface(data->isoc);
+			err = usb_autopm_get_interface(data->isoc ? data->isoc : data->intf);
 			if (err < 0) {
 				clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
 				usb_kill_anchored_urbs(&data->isoc_anchor);
@@ -858,7 +861,7 @@ static void btusb_work(struct work_struct *work)
 
 		__set_isoc_interface(hdev, 0);
 		if (test_and_clear_bit(BTUSB_DID_ISO_RESUME, &data->flags))
-			usb_autopm_put_interface(data->isoc);
+			usb_autopm_put_interface(data->isoc ? data->isoc : data->intf);
 	}
 }
 
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 78c26fd..62ce2f4 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -282,6 +282,34 @@ int ath5k_hw_phy_disable(struct ath5k_hw *ah)
 	return 0;
 }
 
+/*
+ * Wait for synth to settle
+ */
+static void ath5k_hw_wait_for_synth(struct ath5k_hw *ah,
+			struct ieee80211_channel *channel)
+{
+	/*
+	 * On 5211+ read activation -> rx delay
+	 * and use it (100ns steps).
+	 */
+	if (ah->ah_version != AR5K_AR5210) {
+		u32 delay;
+		delay = ath5k_hw_reg_read(ah, AR5K_PHY_RX_DELAY) &
+			AR5K_PHY_RX_DELAY_M;
+		delay = (channel->hw_value & CHANNEL_CCK) ?
+			((delay << 2) / 22) : (delay / 10);
+		if (ah->ah_bwmode == AR5K_BWMODE_10MHZ)
+			delay = delay << 1;
+		if (ah->ah_bwmode == AR5K_BWMODE_5MHZ)
+			delay = delay << 2;
+		/* XXX: /2 on turbo ? Let's be safe
+		 * for now */
+		udelay(100 + delay);
+	} else {
+		mdelay(1);
+	}
+}
+
 
 /**********************\
 * RF Gain optimization *
@@ -1253,6 +1281,7 @@ static int ath5k_hw_channel(struct ath5k_hw *ah,
 	case AR5K_RF5111:
 		ret = ath5k_hw_rf5111_channel(ah, channel);
 		break;
+	case AR5K_RF2317:
 	case AR5K_RF2425:
 		ret = ath5k_hw_rf2425_channel(ah, channel);
 		break;
@@ -3237,6 +3266,13 @@ int ath5k_hw_phy_init(struct ath5k_hw *ah, struct ieee80211_channel *channel,
 		/* Failed */
 		if (i >= 100)
 			return -EIO;
+
+		/* Set channel and wait for synth */
+		ret = ath5k_hw_channel(ah, channel);
+		if (ret)
+			return ret;
+
+		ath5k_hw_wait_for_synth(ah, channel);
 	}
 
 	/*
@@ -3251,13 +3287,53 @@ int ath5k_hw_phy_init(struct ath5k_hw *ah, struct ieee80211_channel *channel,
 	if (ret)
 		return ret;
 
+	/* Write OFDM timings on 5212*/
+	if (ah->ah_version == AR5K_AR5212 &&
+		channel->hw_value & CHANNEL_OFDM) {
+
+		ret = ath5k_hw_write_ofdm_timings(ah, channel);
+		if (ret)
+			return ret;
+
+		/* Spur info is available only from EEPROM versions
+		 * greater than 5.3, but the EEPROM routines will use
+		 * static values for older versions */
+		if (ah->ah_mac_srev >= AR5K_SREV_AR5424)
+			ath5k_hw_set_spur_mitigation_filter(ah,
+							    channel);
+	}
+
+	/* If we used fast channel switching
+	 * we are done, release RF bus and
+	 * fire up NF calibration.
+	 *
+	 * Note: Only NF calibration due to
+	 * channel change, not AGC calibration
+	 * since AGC is still running !
+	 */
+	if (fast) {
+		/*
+		 * Release RF Bus grant
+		 */
+		AR5K_REG_DISABLE_BITS(ah, AR5K_PHY_RFBUS_REQ,
+				    AR5K_PHY_RFBUS_REQ_REQUEST);
+
+		/*
+		 * Start NF calibration
+		 */
+		AR5K_REG_ENABLE_BITS(ah, AR5K_PHY_AGCCTL,
+					AR5K_PHY_AGCCTL_NF);
+
+		return ret;
+	}
+
 	/*
 	 * For 5210 we do all initialization using
 	 * initvals, so we don't have to modify
 	 * any settings (5210 also only supports
 	 * a/aturbo modes)
 	 */
-	if ((ah->ah_version != AR5K_AR5210) && !fast) {
+	if (ah->ah_version != AR5K_AR5210) {
 
 		/*
 		 * Write initial RF gain settings
@@ -3276,22 +3352,6 @@ int ath5k_hw_phy_init(struct ath5k_hw *ah, struct ieee80211_channel *channel,
 		if (ret)
 			return ret;
 
-		/* Write OFDM timings on 5212*/
-		if (ah->ah_version == AR5K_AR5212 &&
-			channel->hw_value & CHANNEL_OFDM) {
-
-			ret = ath5k_hw_write_ofdm_timings(ah, channel);
-			if (ret)
-				return ret;
-
-			/* Spur info is available only from EEPROM versions
-			 * greater than 5.3, but the EEPROM routines will use
-			 * static values for older versions */
-			if (ah->ah_mac_srev >= AR5K_SREV_AR5424)
-				ath5k_hw_set_spur_mitigation_filter(ah,
-								    channel);
-		}
-
 		/*Enable/disable 802.11b mode on 5111
 		(enable 2111 frequency converter + CCK)*/
 		if (ah->ah_radio == AR5K_RF5111) {
@@ -3322,47 +3382,20 @@ int ath5k_hw_phy_init(struct ath5k_hw *ah, struct ieee80211_channel *channel,
 	 */
 	ath5k_hw_reg_write(ah, AR5K_PHY_ACT_ENABLE, AR5K_PHY_ACT);
 
+	ath5k_hw_wait_for_synth(ah, channel);
+
 	/*
-	 * On 5211+ read activation -> rx delay
-	 * and use it.
+	 * Perform ADC test to see if baseband is ready
+	 * Set tx hold and check adc test register
 	 */
-	if (ah->ah_version != AR5K_AR5210) {
-		u32 delay;
-		delay = ath5k_hw_reg_read(ah, AR5K_PHY_RX_DELAY) &
-			AR5K_PHY_RX_DELAY_M;
-		delay = (channel->hw_value & CHANNEL_CCK) ?
-			((delay << 2) / 22) : (delay / 10);
-		if (ah->ah_bwmode == AR5K_BWMODE_10MHZ)
-			delay = delay << 1;
-		if (ah->ah_bwmode == AR5K_BWMODE_5MHZ)
-			delay = delay << 2;
-		/* XXX: /2 on turbo ? Let's be safe
-		 * for now */
-		udelay(100 + delay);
-	} else {
-		mdelay(1);
-	}
-
-	if (fast)
-		/*
-		 * Release RF Bus grant
-		 */
-		AR5K_REG_DISABLE_BITS(ah, AR5K_PHY_RFBUS_REQ,
-				    AR5K_PHY_RFBUS_REQ_REQUEST);
-	else {
-		/*
-		 * Perform ADC test to see if baseband is ready
-		 * Set tx hold and check adc test register
-		 */
-		phy_tst1 = ath5k_hw_reg_read(ah, AR5K_PHY_TST1);
-		ath5k_hw_reg_write(ah, AR5K_PHY_TST1_TXHOLD, AR5K_PHY_TST1);
-		for (i = 0; i <= 20; i++) {
-			if (!(ath5k_hw_reg_read(ah, AR5K_PHY_ADC_TEST) & 0x10))
-				break;
-			udelay(200);
-		}
-		ath5k_hw_reg_write(ah, phy_tst1, AR5K_PHY_TST1);
+	phy_tst1 = ath5k_hw_reg_read(ah, AR5K_PHY_TST1);
+	ath5k_hw_reg_write(ah, AR5K_PHY_TST1_TXHOLD, AR5K_PHY_TST1);
+	for (i = 0; i <= 20; i++) {
+		if (!(ath5k_hw_reg_read(ah, AR5K_PHY_ADC_TEST) & 0x10))
+			break;
+		udelay(200);
 	}
+	ath5k_hw_reg_write(ah, phy_tst1, AR5K_PHY_TST1);
 
 	/*
 	 * Start automatic gain control calibration
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 23838e3..1a7fa6e 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -21,7 +21,6 @@
 #include <linux/device.h>
 #include <linux/leds.h>
 #include <linux/completion.h>
-#include <linux/pm_qos_params.h>
 
 #include "debug.h"
 #include "common.h"
@@ -57,8 +56,6 @@ struct ath_node;
 
 #define A_MAX(a, b) ((a) > (b) ? (a) : (b))
 
-#define ATH9K_PM_QOS_DEFAULT_VALUE	55
-
 #define TSF_TO_TU(_h,_l) \
 	((((u32)(_h)) << 22) | (((u32)(_l)) >> 10))
 
@@ -633,8 +630,6 @@ struct ath_softc {
 	struct ath_descdma txsdma;
 
 	struct ath_ant_comb ant_comb;
-
-	struct pm_qos_request_list pm_qos_req;
 };
 
 struct ath_wiphy {
@@ -666,7 +661,6 @@ static inline void ath_read_cachesize(struct ath_common *common, int *csz)
 extern struct ieee80211_ops ath9k_ops;
 extern int ath9k_modparam_nohwcrypt;
 extern int led_blink;
-extern int ath9k_pm_qos_value;
 extern bool is_ath9k_unloaded;
 
 irqreturn_t ath_isr(int irq, void *dev);
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 087a6a9..a033d01 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -41,10 +41,6 @@ static int ath9k_btcoex_enable;
 module_param_named(btcoex_enable, ath9k_btcoex_enable, int, 0444);
 MODULE_PARM_DESC(btcoex_enable, "Enable wifi-BT coexistence");
 
-int ath9k_pm_qos_value = ATH9K_PM_QOS_DEFAULT_VALUE;
-module_param_named(pmqos, ath9k_pm_qos_value, int, S_IRUSR | S_IRGRP | S_IROTH);
-MODULE_PARM_DESC(pmqos, "User specified PM-QOS value");
-
 bool is_ath9k_unloaded;
 /* We use the hw_value as an index into our private channel structure */
 
@@ -762,9 +758,6 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc, u16 subsysid,
 	ath_init_leds(sc);
 	ath_start_rfkill_poll(sc);
 
-	pm_qos_add_request(&sc->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
-			   PM_QOS_DEFAULT_VALUE);
-
 	return 0;
 
 error_world:
@@ -831,7 +824,6 @@ void ath9k_deinit_device(struct ath_softc *sc)
 	}
 
 	ieee80211_unregister_hw(hw);
-	pm_qos_remove_request(&sc->pm_qos_req);
 	ath_rx_cleanup(sc);
 	ath_tx_cleanup(sc);
 	ath9k_deinit_softc(sc);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index da5c645..a09d15f 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1173,12 +1173,6 @@ static int ath9k_start(struct ieee80211_hw *hw)
 			ath9k_btcoex_timer_resume(sc);
 	}
 
-	/* User has the option to provide pm-qos value as a module
-	 * parameter rather than using the default value of
-	 * 'ATH9K_PM_QOS_DEFAULT_VALUE'.
-	 */
-	pm_qos_update_request(&sc->pm_qos_req, ath9k_pm_qos_value);
-
 	if (ah->caps.pcie_lcr_extsync_en && common->bus_ops->extn_synch_en)
 		common->bus_ops->extn_synch_en(common);
 
@@ -1345,8 +1339,6 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	sc->sc_flags |= SC_OP_INVALID;
 
-	pm_qos_update_request(&sc->pm_qos_req, PM_QOS_DEFAULT_VALUE);
-
 	mutex_unlock(&sc->mutex);
 
 	ath_dbg(common, ATH_DBG_CONFIG, "Driver halt\n");
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 1eacba4..0494d7b 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -199,6 +199,7 @@ static void p54p_check_rx_ring(struct ieee80211_hw *dev, u32 *index,
 	while (i != idx) {
 		u16 len;
 		struct sk_buff *skb;
+		dma_addr_t dma_addr;
 		desc = &ring[i];
 		len = le16_to_cpu(desc->len);
 		skb = rx_buf[i];
@@ -216,17 +217,20 @@ static void p54p_check_rx_ring(struct ieee80211_hw *dev, u32 *index,
 
 			len = priv->common.rx_mtu;
 		}
+		dma_addr = le32_to_cpu(desc->host_addr);
+		pci_dma_sync_single_for_cpu(priv->pdev, dma_addr,
+			priv->common.rx_mtu + 32, PCI_DMA_FROMDEVICE);
 		skb_put(skb, len);
 
 		if (p54_rx(dev, skb)) {
-			pci_unmap_single(priv->pdev,
-					 le32_to_cpu(desc->host_addr),
-					 priv->common.rx_mtu + 32,
-					 PCI_DMA_FROMDEVICE);
+			pci_unmap_single(priv->pdev, dma_addr,
+				priv->common.rx_mtu + 32, PCI_DMA_FROMDEVICE);
 			rx_buf[i] = NULL;
-			desc->host_addr = 0;
+			desc->host_addr = cpu_to_le32(0);
 		} else {
 			skb_trim(skb, 0);
+			pci_dma_sync_single_for_device(priv->pdev, dma_addr,
+				priv->common.rx_mtu + 32, PCI_DMA_FROMDEVICE);
 			desc->len = cpu_to_le16(priv->common.rx_mtu + 32);
 		}
 
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index aa97971..3b3f1e4 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -652,6 +652,12 @@ static void rt2800pci_fill_rxdone(struct queue_entry *entry,
 		 */
 		rxdesc->flags |= RX_FLAG_IV_STRIPPED;
 
+		/*
+		 * The hardware has already checked the Michael Mic and has
+		 * stripped it from the frame. Signal this to mac80211.
+		 */
+		rxdesc->flags |= RX_FLAG_MMIC_STRIPPED;
+
 		if (rxdesc->cipher_status == RX_CRYPTO_SUCCESS)
 			rxdesc->flags |= RX_FLAG_DECRYPTED;
 		else if (rxdesc->cipher_status == RX_CRYPTO_FAIL_MIC)
@@ -1065,6 +1071,8 @@ static DEFINE_PCI_DEVICE_TABLE(rt2800pci_device_table) = {
 	{ PCI_DEVICE(0x1814, 0x3390), PCI_DEVICE_DATA(&rt2800pci_ops) },
 #endif
 #ifdef CONFIG_RT2800PCI_RT35XX
+	{ PCI_DEVICE(0x1432, 0x7711), PCI_DEVICE_DATA(&rt2800pci_ops) },
+	{ PCI_DEVICE(0x1432, 0x7722), PCI_DEVICE_DATA(&rt2800pci_ops) },
 	{ PCI_DEVICE(0x1814, 0x3060), PCI_DEVICE_DATA(&rt2800pci_ops) },
 	{ PCI_DEVICE(0x1814, 0x3062), PCI_DEVICE_DATA(&rt2800pci_ops) },
 	{ PCI_DEVICE(0x1814, 0x3562), PCI_DEVICE_DATA(&rt2800pci_ops) },
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index b97a4a5..197a36c 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -486,6 +486,12 @@ static void rt2800usb_fill_rxdone(struct queue_entry *entry,
 		 */
 		rxdesc->flags |= RX_FLAG_IV_STRIPPED;
 
+		/*
+		 * The hardware has already checked the Michael Mic and has
+		 * stripped it from the frame. Signal this to mac80211.
+		 */
+		rxdesc->flags |= RX_FLAG_MMIC_STRIPPED;
+
 		if (rxdesc->cipher_status == RX_CRYPTO_SUCCESS)
 			rxdesc->flags |= RX_FLAG_DECRYPTED;
 		else if (rxdesc->cipher_status == RX_CRYPTO_FAIL_MIC)
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 2575c2d..d7b9af4 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -727,7 +727,9 @@ static int rfcomm_tty_open(struct tty_struct *tty, struct file *filp)
 			break;
 		}
 
+		tty_unlock();
 		schedule();
+		tty_lock();
 	}
 	set_current_state(TASK_RUNNING);
 	remove_wait_queue(&dev->wait, &wait);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 45fbb9e..c9ceb4d 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1033,6 +1033,12 @@ void ieee80211_sta_rx_notify(struct ieee80211_sub_if_data *sdata,
 	if (is_multicast_ether_addr(hdr->addr1))
 		return;
 
+	/*
+	 * In case we receive frames after disassociation.
+	 */
+	if (!sdata->u.mgd.associated)
+		return;
+
 	ieee80211_sta_reset_conn_monitor(sdata);
 }
 
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 3e5dbd4..d112f03 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -802,11 +802,11 @@ int cfg80211_wext_siwfreq(struct net_device *dev,
 			return freq;
 		if (freq == 0)
 			return -EINVAL;
-		wdev_lock(wdev);
 		mutex_lock(&rdev->devlist_mtx);
+		wdev_lock(wdev);
 		err = cfg80211_set_freq(rdev, wdev, freq, NL80211_CHAN_NO_HT);
-		mutex_unlock(&rdev->devlist_mtx);
 		wdev_unlock(wdev);
+		mutex_unlock(&rdev->devlist_mtx);
 		return err;
 	default:
 		return -EOPNOTSUPP;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
