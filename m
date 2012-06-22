From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-06-22
Date: Fri, 22 Jun 2012 16:17:16 -0400
Message-ID: <20120622201716.GB13918@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4e42200cafe0c7a90fc26b82b2088c4f2bcb007a

Dave,

Another quick round of fixes intended for 3.5...

Some of them are Bluetooth -- quoth Gustavo:

	Five fixed to 3.5. There 2 new usb devices id commits, one
	driver fix and two other fixes for the core, one for L2CAP
	and other in MGMT interface.

The Bluetooth fixes look reasonable to me.

The mwifiex drivers gets a fix from Avinash Patil for a potential
stuck tx queue in AP mode, and a fix from Bing Zhao for a crash from
a bad return type.

Bob Copeland gives us a two-liner for ath5k to avoid a bottom half
double lock.

Dan Carpenter gives us an airo fix to correct some incorrect pointer
usage in a memcpy.

The wl1251 driver gets three fixes that Grazvydas Ignotas rescued from
the Maemo repos.  One corrects a TSF calculation, another ensures
that beacon losses are always reported up the stack, and the third
corrects some memory leaks.

Johannes Berg gives us an iwlwifi fix to avoid a debugfs-releated
crash.

Finally, the ath9k folks were busy!  Felix Fietkau fixes a tx rate
duration calculation and an invalid pointer access, Mohammed Shafi
Shajakhan avoids a potential infinite loop, and Rajkumar Manoharan
ensures that the bssid is configured for ath9k_htc when association
or ibss information changes.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 8633c0846160af0b8cfb983bbccd94ae42922af8:

  ixgbe: Fix memory leak in ixgbe when receiving traffic on DDP enabled rings (2012-06-20 00:53:57 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Andrei Emeltchenko (1):
      Bluetooth: btmrvl: Do not send vendor events to bluetooth stack

Avinash Patil (1):
      mwifiex: fix uAP TX packet timeout issue

Bing Zhao (1):
      mwifiex: fix wrong return values in add_virtual_intf() error cases

Bob Copeland (1):
      ath5k: remove _bh from inner locks

Dan Carpenter (1):
      airo: copying wrong data in airo_get_aplist()

Felix Fietkau (2):
      ath9k: fix a tx rate duration calculation bug
      ath9k: fix invalid pointer access in the tx path

Giancarlo Formicuccia (1):
      Bluetooth: add support for atheros 0930:0219

Grazvydas Ignotas (3):
      wl1251: fix TSF calculation
      wl1251: always report beacon loss to the stack
      wl1251: Fix memory leaks in SPI initialization

Johannes Berg (1):
      iwlwifi: remove log_event debugfs file debugging is disabled

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Marek Vasut (1):
      Bluetooth: Support AR3011 in Acer Iconia Tab W500

Mohammed Shafi Shajakhan (1):
      ath9k_hw: avoid possible infinite loop in ar9003_get_pll_sqsum_dvc

Rajkumar Manoharan (1):
      ath9k_htc: configure bssid on ASSOC/IBSS change

Szymon Janc (1):
      Bluetooth: Fix using uninitialized option in RFCMode

Vishal Agarwal (1):
      Bluetooth: Fix sending HCI_Disconnect only when connected

 drivers/bluetooth/ath3k.c                     |    3 ++
 drivers/bluetooth/btmrvl_drv.h                |    2 +-
 drivers/bluetooth/btmrvl_main.c               |   14 +++++++++-
 drivers/bluetooth/btmrvl_sdio.c               |    8 ++++--
 drivers/bluetooth/btusb.c                     |    2 +
 drivers/net/wireless/airo.c                   |    4 +-
 drivers/net/wireless/ath/ath5k/base.c         |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h        |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    5 +--
 drivers/net/wireless/ath/ath9k/hw.c           |   14 ++++++++++-
 drivers/net/wireless/ath/ath9k/xmit.c         |   31 ++++++++++++++----------
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |    6 +++++
 drivers/net/wireless/mwifiex/cfg80211.c       |   25 +++++++++-----------
 drivers/net/wireless/mwifiex/txrx.c           |   10 ++-----
 drivers/net/wireless/ti/wl1251/acx.c          |    2 +-
 drivers/net/wireless/ti/wl1251/event.c        |    3 +-
 drivers/net/wireless/ti/wl1251/spi.c          |    4 +++
 net/bluetooth/l2cap_core.c                    |   14 ++++++-----
 net/bluetooth/mgmt.c                          |    2 +-
 19 files changed, 96 insertions(+), 58 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index ad591bd..10308cd 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -63,6 +63,7 @@ static struct usb_device_id ath3k_table[] = {
 
 	/* Atheros AR3011 with sflash firmware*/
 	{ USB_DEVICE(0x0CF3, 0x3002) },
+	{ USB_DEVICE(0x0CF3, 0xE019) },
 	{ USB_DEVICE(0x13d3, 0x3304) },
 	{ USB_DEVICE(0x0930, 0x0215) },
 	{ USB_DEVICE(0x0489, 0xE03D) },
@@ -77,6 +78,7 @@ static struct usb_device_id ath3k_table[] = {
 	{ USB_DEVICE(0x04CA, 0x3005) },
 	{ USB_DEVICE(0x13d3, 0x3362) },
 	{ USB_DEVICE(0x0CF3, 0xE004) },
+	{ USB_DEVICE(0x0930, 0x0219) },
 
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -101,6 +103,7 @@ static struct usb_device_id ath3k_blist_tbl[] = {
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
 
 	/* Atheros AR5BBU22 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE03C), .driver_info = BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
index 94f2d65..27068d1 100644
--- a/drivers/bluetooth/btmrvl_drv.h
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -136,7 +136,7 @@ int btmrvl_remove_card(struct btmrvl_private *priv);
 
 void btmrvl_interrupt(struct btmrvl_private *priv);
 
-void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb);
+bool btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb);
 int btmrvl_process_event(struct btmrvl_private *priv, struct sk_buff *skb);
 
 int btmrvl_send_module_cfg_cmd(struct btmrvl_private *priv, int subcmd);
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 681ca9d..dc304de 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -44,23 +44,33 @@ void btmrvl_interrupt(struct btmrvl_private *priv)
 }
 EXPORT_SYMBOL_GPL(btmrvl_interrupt);
 
-void btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
+bool btmrvl_check_evtpkt(struct btmrvl_private *priv, struct sk_buff *skb)
 {
 	struct hci_event_hdr *hdr = (void *) skb->data;
 	struct hci_ev_cmd_complete *ec;
-	u16 opcode, ocf;
+	u16 opcode, ocf, ogf;
 
 	if (hdr->evt == HCI_EV_CMD_COMPLETE) {
 		ec = (void *) (skb->data + HCI_EVENT_HDR_SIZE);
 		opcode = __le16_to_cpu(ec->opcode);
 		ocf = hci_opcode_ocf(opcode);
+		ogf = hci_opcode_ogf(opcode);
+
 		if (ocf == BT_CMD_MODULE_CFG_REQ &&
 					priv->btmrvl_dev.sendcmdflag) {
 			priv->btmrvl_dev.sendcmdflag = false;
 			priv->adapter->cmd_complete = true;
 			wake_up_interruptible(&priv->adapter->cmd_wait_q);
 		}
+
+		if (ogf == OGF) {
+			BT_DBG("vendor event skipped: ogf 0x%4.4x", ogf);
+			kfree_skb(skb);
+			return false;
+		}
 	}
+
+	return true;
 }
 EXPORT_SYMBOL_GPL(btmrvl_check_evtpkt);
 
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index a853244..0cd61d9 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -562,10 +562,12 @@ static int btmrvl_sdio_card_to_host(struct btmrvl_private *priv)
 		skb_put(skb, buf_len);
 		skb_pull(skb, SDIO_HEADER_LEN);
 
-		if (type == HCI_EVENT_PKT)
-			btmrvl_check_evtpkt(priv, skb);
+		if (type == HCI_EVENT_PKT) {
+			if (btmrvl_check_evtpkt(priv, skb))
+				hci_recv_frame(skb);
+		} else
+			hci_recv_frame(skb);
 
-		hci_recv_frame(skb);
 		hdev->stat.byte_rx += buf_len;
 		break;
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index c9463af..83ebb24 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -125,6 +125,7 @@ static struct usb_device_id blacklist_table[] = {
 
 	/* Atheros 3011 with sflash firmware */
 	{ USB_DEVICE(0x0cf3, 0x3002), .driver_info = BTUSB_IGNORE },
+	{ USB_DEVICE(0x0cf3, 0xe019), .driver_info = BTUSB_IGNORE },
 	{ USB_DEVICE(0x13d3, 0x3304), .driver_info = BTUSB_IGNORE },
 	{ USB_DEVICE(0x0930, 0x0215), .driver_info = BTUSB_IGNORE },
 	{ USB_DEVICE(0x0489, 0xe03d), .driver_info = BTUSB_IGNORE },
@@ -139,6 +140,7 @@ static struct usb_device_id blacklist_table[] = {
 	{ USB_DEVICE(0x04ca, 0x3005), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
 
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info = BTUSB_IGNORE },
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 520a4b2..a747c63 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -7233,8 +7233,8 @@ static int airo_get_aplist(struct net_device *dev,
 		}
 	} else {
 		dwrq->flags = 1; /* Should be define'd */
-		memcpy(extra + sizeof(struct sockaddr)*i,
-		       &qual,  sizeof(struct iw_quality)*i);
+		memcpy(extra + sizeof(struct sockaddr) * i, qual,
+		       sizeof(struct iw_quality) * i);
 	}
 	dwrq->length = i;
 
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index fbaa309..44ad6fe 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1045,11 +1045,11 @@ ath5k_drain_tx_buffs(struct ath5k_hw *ah)
 
 				ath5k_txbuf_free_skb(ah, bf);
 
-				spin_lock_bh(&ah->txbuflock);
+				spin_lock(&ah->txbuflock);
 				list_move_tail(&bf->list, &ah->txbuf);
 				ah->txbuf_len++;
 				txq->txq_len--;
-				spin_unlock_bh(&ah->txbuflock);
+				spin_unlock(&ah->txbuflock);
 			}
 			txq->link = NULL;
 			txq->txq_poll_mark = false;
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index a277cf6..4866550 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -214,6 +214,7 @@ struct ath_frame_info {
 	enum ath9k_key_type keytype;
 	u8 keyix;
 	u8 retries;
+	u8 rtscts_rate;
 };
 
 struct ath_buf_state {
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 2b8f61c..abbd6ef 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -1496,6 +1496,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 			priv->num_sta_assoc_vif++ : priv->num_sta_assoc_vif--;
 
 		if (priv->ah->opmode == NL80211_IFTYPE_STATION) {
+			ath9k_htc_choose_set_bssid(priv);
 			if (bss_conf->assoc && (priv->num_sta_assoc_vif == 1))
 				ath9k_htc_start_ani(priv);
 			else if (priv->num_sta_assoc_vif == 0)
@@ -1503,13 +1504,11 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 		}
 	}
 
-	if (changed & BSS_CHANGED_BSSID) {
+	if (changed & BSS_CHANGED_IBSS) {
 		if (priv->ah->opmode == NL80211_IFTYPE_ADHOC) {
 			common->curaid = bss_conf->aid;
 			memcpy(common->curbssid, bss_conf->bssid, ETH_ALEN);
 			ath9k_htc_set_bssid(priv);
-		} else if (priv->ah->opmode == NL80211_IFTYPE_STATION) {
-			ath9k_htc_choose_set_bssid(priv);
 		}
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 7db1890..1c68e56 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -784,13 +784,25 @@ static void ath9k_hw_init_qos(struct ath_hw *ah)
 
 u32 ar9003_get_pll_sqsum_dvc(struct ath_hw *ah)
 {
+	struct ath_common *common = ath9k_hw_common(ah);
+	int i = 0;
+
 	REG_CLR_BIT(ah, PLL3, PLL3_DO_MEAS_MASK);
 	udelay(100);
 	REG_SET_BIT(ah, PLL3, PLL3_DO_MEAS_MASK);
 
-	while ((REG_READ(ah, PLL4) & PLL4_MEAS_DONE) == 0)
+	while ((REG_READ(ah, PLL4) & PLL4_MEAS_DONE) == 0) {
+
 		udelay(100);
 
+		if (WARN_ON_ONCE(i >= 100)) {
+			ath_err(common, "PLL4 meaurement not done\n");
+			break;
+		}
+
+		i++;
+	}
+
 	return (REG_READ(ah, PLL3) & SQSUM_DVC_MASK) >> 3;
 }
 EXPORT_SYMBOL(ar9003_get_pll_sqsum_dvc);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index d59dd01..4d57139 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -938,6 +938,7 @@ static void ath_buf_set_rate(struct ath_softc *sc, struct ath_buf *bf,
 	struct ieee80211_tx_rate *rates;
 	const struct ieee80211_rate *rate;
 	struct ieee80211_hdr *hdr;
+	struct ath_frame_info *fi = get_frame_info(bf->bf_mpdu);
 	int i;
 	u8 rix = 0;
 
@@ -948,18 +949,7 @@ static void ath_buf_set_rate(struct ath_softc *sc, struct ath_buf *bf,
 
 	/* set dur_update_en for l-sig computation except for PS-Poll frames */
 	info->dur_update = !ieee80211_is_pspoll(hdr->frame_control);
-
-	/*
-	 * We check if Short Preamble is needed for the CTS rate by
-	 * checking the BSS's global flag.
-	 * But for the rate series, IEEE80211_TX_RC_USE_SHORT_PREAMBLE is used.
-	 */
-	rate = ieee80211_get_rts_cts_rate(sc->hw, tx_info);
-	info->rtscts_rate = rate->hw_value;
-
-	if (tx_info->control.vif &&
-	    tx_info->control.vif->bss_conf.use_short_preamble)
-		info->rtscts_rate |= rate->hw_value_short;
+	info->rtscts_rate = fi->rtscts_rate;
 
 	for (i = 0; i < 4; i++) {
 		bool is_40, is_sgi, is_sp;
@@ -1001,13 +991,13 @@ static void ath_buf_set_rate(struct ath_softc *sc, struct ath_buf *bf,
 		}
 
 		/* legacy rates */
+		rate = &sc->sbands[tx_info->band].bitrates[rates[i].idx];
 		if ((tx_info->band == IEEE80211_BAND_2GHZ) &&
 		    !(rate->flags & IEEE80211_RATE_ERP_G))
 			phy = WLAN_RC_PHY_CCK;
 		else
 			phy = WLAN_RC_PHY_OFDM;
 
-		rate = &sc->sbands[tx_info->band].bitrates[rates[i].idx];
 		info->rates[i].Rate = rate->hw_value;
 		if (rate->hw_value_short) {
 			if (rates[i].flags & IEEE80211_TX_RC_USE_SHORT_PREAMBLE)
@@ -1776,10 +1766,22 @@ static void setup_frame_info(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_sta *sta = tx_info->control.sta;
 	struct ieee80211_key_conf *hw_key = tx_info->control.hw_key;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	const struct ieee80211_rate *rate;
 	struct ath_frame_info *fi = get_frame_info(skb);
 	struct ath_node *an = NULL;
 	enum ath9k_key_type keytype;
+	bool short_preamble = false;
+
+	/*
+	 * We check if Short Preamble is needed for the CTS rate by
+	 * checking the BSS's global flag.
+	 * But for the rate series, IEEE80211_TX_RC_USE_SHORT_PREAMBLE is used.
+	 */
+	if (tx_info->control.vif &&
+	    tx_info->control.vif->bss_conf.use_short_preamble)
+		short_preamble = true;
 
+	rate = ieee80211_get_rts_cts_rate(hw, tx_info);
 	keytype = ath9k_cmn_get_hw_crypto_keytype(skb);
 
 	if (sta)
@@ -1794,6 +1796,9 @@ static void setup_frame_info(struct ieee80211_hw *hw, struct sk_buff *skb,
 		fi->keyix = ATH9K_TXKEYIX_INVALID;
 	fi->keytype = keytype;
 	fi->framelen = framelen;
+	fi->rtscts_rate = rate->hw_value;
+	if (short_preamble)
+		fi->rtscts_rate |= rate->hw_value_short;
 }
 
 u8 ath_txchainmask_reduction(struct ath_softc *sc, u8 chainmask, u32 rate)
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index e7c157e..7f97dec 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -2239,6 +2239,7 @@ static ssize_t iwl_dbgfs_echo_test_write(struct file *file,
 	return count;
 }
 
+#ifdef CONFIG_IWLWIFI_DEBUG
 static ssize_t iwl_dbgfs_log_event_read(struct file *file,
 					 char __user *user_buf,
 					 size_t count, loff_t *ppos)
@@ -2276,6 +2277,7 @@ static ssize_t iwl_dbgfs_log_event_write(struct file *file,
 
 	return count;
 }
+#endif
 
 static ssize_t iwl_dbgfs_calib_disabled_read(struct file *file,
 					 char __user *user_buf,
@@ -2345,7 +2347,9 @@ DEBUGFS_READ_FILE_OPS(bt_traffic);
 DEBUGFS_READ_WRITE_FILE_OPS(protection_mode);
 DEBUGFS_READ_FILE_OPS(reply_tx_error);
 DEBUGFS_WRITE_FILE_OPS(echo_test);
+#ifdef CONFIG_IWLWIFI_DEBUG
 DEBUGFS_READ_WRITE_FILE_OPS(log_event);
+#endif
 DEBUGFS_READ_WRITE_FILE_OPS(calib_disabled);
 
 /*
@@ -2405,7 +2409,9 @@ int iwl_dbgfs_register(struct iwl_priv *priv, const char *name)
 	DEBUGFS_ADD_FILE(rxon_flags, dir_debug, S_IWUSR);
 	DEBUGFS_ADD_FILE(rxon_filter_flags, dir_debug, S_IWUSR);
 	DEBUGFS_ADD_FILE(echo_test, dir_debug, S_IWUSR);
+#ifdef CONFIG_IWLWIFI_DEBUG
 	DEBUGFS_ADD_FILE(log_event, dir_debug, S_IWUSR | S_IRUSR);
+#endif
 
 	if (iwl_advanced_bt_coexist(priv))
 		DEBUGFS_ADD_FILE(bt_traffic, dir_debug, S_IRUSR);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 015fec3..ce61b6f 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1484,7 +1484,7 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	struct wireless_dev *wdev;
 
 	if (!adapter)
-		return NULL;
+		return ERR_PTR(-EFAULT);
 
 	switch (type) {
 	case NL80211_IFTYPE_UNSPECIFIED:
@@ -1494,12 +1494,12 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 		if (priv->bss_mode) {
 			wiphy_err(wiphy,
 				  "cannot create multiple sta/adhoc ifaces\n");
-			return NULL;
+			return ERR_PTR(-EINVAL);
 		}
 
 		wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
 		if (!wdev)
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 
 		wdev->wiphy = wiphy;
 		priv->wdev = wdev;
@@ -1522,12 +1522,12 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 
 		if (priv->bss_mode) {
 			wiphy_err(wiphy, "Can't create multiple AP interfaces");
-			return NULL;
+			return ERR_PTR(-EINVAL);
 		}
 
 		wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
 		if (!wdev)
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 
 		priv->wdev = wdev;
 		wdev->wiphy = wiphy;
@@ -1544,14 +1544,15 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 		break;
 	default:
 		wiphy_err(wiphy, "type not supported\n");
-		return NULL;
+		return ERR_PTR(-EINVAL);
 	}
 
 	dev = alloc_netdev_mq(sizeof(struct mwifiex_private *), name,
 			      ether_setup, 1);
 	if (!dev) {
 		wiphy_err(wiphy, "no memory available for netdevice\n");
-		goto error;
+		priv->bss_mode = NL80211_IFTYPE_UNSPECIFIED;
+		return ERR_PTR(-ENOMEM);
 	}
 
 	mwifiex_init_priv_params(priv, dev);
@@ -1582,7 +1583,9 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	/* Register network device */
 	if (register_netdevice(dev)) {
 		wiphy_err(wiphy, "cannot register virtual network device\n");
-		goto error;
+		free_netdev(dev);
+		priv->bss_mode = NL80211_IFTYPE_UNSPECIFIED;
+		return ERR_PTR(-EFAULT);
 	}
 
 	sema_init(&priv->async_sem, 1);
@@ -1594,12 +1597,6 @@ struct net_device *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	mwifiex_dev_debugfs_init(priv);
 #endif
 	return dev;
-error:
-	if (dev && (dev->reg_state == NETREG_UNREGISTERED))
-		free_netdev(dev);
-	priv->bss_mode = NL80211_IFTYPE_UNSPECIFIED;
-
-	return NULL;
 }
 EXPORT_SYMBOL_GPL(mwifiex_add_virtual_intf);
 
diff --git a/drivers/net/wireless/mwifiex/txrx.c b/drivers/net/wireless/mwifiex/txrx.c
index e2faec4..cecb272 100644
--- a/drivers/net/wireless/mwifiex/txrx.c
+++ b/drivers/net/wireless/mwifiex/txrx.c
@@ -161,15 +161,11 @@ int mwifiex_write_data_complete(struct mwifiex_adapter *adapter,
 		goto done;
 
 	for (i = 0; i < adapter->priv_num; i++) {
-
 		tpriv = adapter->priv[i];
 
-		if ((GET_BSS_ROLE(tpriv) == MWIFIEX_BSS_ROLE_STA) &&
-		    (tpriv->media_connected)) {
-			if (netif_queue_stopped(tpriv->netdev))
-				mwifiex_wake_up_net_dev_queue(tpriv->netdev,
-							      adapter);
-		}
+		if (tpriv->media_connected &&
+		    netif_queue_stopped(tpriv->netdev))
+			mwifiex_wake_up_net_dev_queue(tpriv->netdev, adapter);
 	}
 done:
 	dev_kfree_skb_any(skb);
diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index ad87a1a..db6430c 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -869,7 +869,7 @@ int wl1251_acx_tsf_info(struct wl1251 *wl, u64 *mactime)
 	}
 
 	*mactime = tsf_info->current_tsf_lsb |
-		(tsf_info->current_tsf_msb << 31);
+		((u64)tsf_info->current_tsf_msb << 32);
 
 out:
 	kfree(tsf_info);
diff --git a/drivers/net/wireless/ti/wl1251/event.c b/drivers/net/wireless/ti/wl1251/event.c
index 9f15cca..5ec50a4 100644
--- a/drivers/net/wireless/ti/wl1251/event.c
+++ b/drivers/net/wireless/ti/wl1251/event.c
@@ -76,8 +76,7 @@ static int wl1251_event_process(struct wl1251 *wl, struct event_mailbox *mbox)
 		}
 	}
 
-	if (vector & SYNCHRONIZATION_TIMEOUT_EVENT_ID &&
-	    wl->station_mode != STATION_ACTIVE_MODE) {
+	if (vector & SYNCHRONIZATION_TIMEOUT_EVENT_ID) {
 		wl1251_debug(DEBUG_EVENT, "SYNCHRONIZATION_TIMEOUT_EVENT");
 
 		/* indicate to the stack, that beacons have been lost */
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 87f6305..567660c 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -73,6 +73,8 @@ static void wl1251_spi_reset(struct wl1251 *wl)
 	spi_sync(wl_to_spi(wl), &m);
 
 	wl1251_dump(DEBUG_SPI, "spi reset -> ", cmd, WSPI_INIT_CMD_LEN);
+
+	kfree(cmd);
 }
 
 static void wl1251_spi_wake(struct wl1251 *wl)
@@ -127,6 +129,8 @@ static void wl1251_spi_wake(struct wl1251 *wl)
 	spi_sync(wl_to_spi(wl), &m);
 
 	wl1251_dump(DEBUG_SPI, "spi init -> ", cmd, WSPI_INIT_CMD_LEN);
+
+	kfree(cmd);
 }
 
 static void wl1251_spi_reset_wake(struct wl1251 *wl)
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 8394e36..4554e80 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2915,12 +2915,14 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *chan, void *rsp, int len)
 	while (len >= L2CAP_CONF_OPT_SIZE) {
 		len -= l2cap_get_conf_opt(&rsp, &type, &olen, &val);
 
-		switch (type) {
-		case L2CAP_CONF_RFC:
-			if (olen == sizeof(rfc))
-				memcpy(&rfc, (void *)val, olen);
-			goto done;
-		}
+		if (type != L2CAP_CONF_RFC)
+			continue;
+
+		if (olen != sizeof(rfc))
+			break;
+
+		memcpy(&rfc, (void *)val, olen);
+		goto done;
 	}
 
 	/* Use sane default values in case a misbehaving remote device
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 991d5b6..3e5e336 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -1598,7 +1598,7 @@ static int disconnect(struct sock *sk, struct hci_dev *hdev, void *data,
 	else
 		conn = hci_conn_hash_lookup_ba(hdev, LE_LINK, &cp->addr.bdaddr);
 
-	if (!conn) {
+	if (!conn || conn->state == BT_OPEN || conn->state == BT_CLOSED) {
 		err = cmd_status(sk, hdev->id, MGMT_OP_DISCONNECT,
 				 MGMT_STATUS_NOT_CONNECTED);
 		goto failed;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
