From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-12-20
Date: Fri, 20 Dec 2013 16:01:32 -0500
Message-ID: <20131220210132.GB15392@tuxdriver.com>
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

Please consider pulling this batch of fixes for the 3.13 stream...

For the mac80211 bits, Johannes says:

"Here's a fix for another potential radiotap parser buffer overrun thanks
to Evan Huus, and a fix for a cfg80211 warning in a certain corner case
(reconnecting to the same BSS)."

For the bluetooth bits, Gustavo says:

"Two patches in this pull request. An important fix from Marcel in the
permission check for HCI User Channels, there was a extra check for
CAP_NET_RAW, and it was now removed. These channels should only require
CAP_NET_ADMIN. The other patch is a device id addition."

On top of that...

Sujith Manoharan provides a workaround for a hardware problem that
can result in lost interrupts.

Larry Finger fixes an oops when unloading the rtlwifi driver (Red
Hat bug 852761).

Mathy Vanhoef fixes a somewhat minor MAC address privacy issue
(CVE-2013-4579).

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 965cdea825693c821d200e38fac9402cde6dce6a:

  dccp: catch failed request_module call in dccp_probe init (2013-12-19 19:25:50 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to 76ae07df2520d2f26c565747ad40c9e993b16cf7:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2013-12-20 15:40:06 -0500)

----------------------------------------------------------------

Johannes Berg (1):
      radiotap: fix bitmap-end-finding buffer overrun

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Larry Finger (1):
      rtlwifi: pci: Fix oops on driver unload

Marcel Holtmann (1):
      Bluetooth: Fix HCI User Channel permission check in hci_sock_sendmsg

Marco Piazza (1):
      Bluetooth: Add support for Toshiba Bluetooth device [0930:0220]

Mathy Vanhoef (1):
      ath9k_htc: properly set MAC address and BSSID mask

Sujith Manoharan (1):
      ath9k: Fix interrupt handling for the AR9002 family

Ujjal Roy (1):
      cfg80211: fix WARN_ON for re-association to the expired BSS

 drivers/bluetooth/ath3k.c                     |  2 ++
 drivers/bluetooth/btusb.c                     |  1 +
 drivers/net/wireless/ath/ath9k/ar9002_mac.c   | 52 ++++++++++++++++++++++-----
 drivers/net/wireless/ath/ath9k/htc_drv_main.c | 25 ++++++++-----
 drivers/net/wireless/ath/ath9k/main.c         |  5 +--
 drivers/net/wireless/rtlwifi/pci.c            |  4 ++-
 net/bluetooth/hci_sock.c                      | 26 ++++++++------
 net/wireless/radiotap.c                       |  4 +++
 net/wireless/sme.c                            | 22 ++++++------
 9 files changed, 101 insertions(+), 40 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 6bfc1bb318f6..dceb85f8d9a8 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -87,6 +87,7 @@ static const struct usb_device_id ath3k_table[] = {
 	{ USB_DEVICE(0x0CF3, 0xE004) },
 	{ USB_DEVICE(0x0CF3, 0xE005) },
 	{ USB_DEVICE(0x0930, 0x0219) },
+	{ USB_DEVICE(0x0930, 0x0220) },
 	{ USB_DEVICE(0x0489, 0xe057) },
 	{ USB_DEVICE(0x13d3, 0x3393) },
 	{ USB_DEVICE(0x0489, 0xe04e) },
@@ -129,6 +130,7 @@ static const struct usb_device_id ath3k_blist_tbl[] = {
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe005), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0930, 0x0220), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3393), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe04e), .driver_info = BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index c0ff34f2d2df..3980fd18f6ea 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -154,6 +154,7 @@ static const struct usb_device_id blacklist_table[] = {
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe005), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info = BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0930, 0x0220), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3393), .driver_info = BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe04e), .driver_info = BTUSB_ATH3012 },
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_mac.c b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
index 8d78253c26ce..a366d6b4626f 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
@@ -76,9 +76,16 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 				mask2 |= ATH9K_INT_CST;
 			if (isr2 & AR_ISR_S2_TSFOOR)
 				mask2 |= ATH9K_INT_TSFOOR;
+
+			if (!(pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED)) {
+				REG_WRITE(ah, AR_ISR_S2, isr2);
+				isr &= ~AR_ISR_BCNMISC;
+			}
 		}
 
-		isr = REG_READ(ah, AR_ISR_RAC);
+		if (pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED)
+			isr = REG_READ(ah, AR_ISR_RAC);
+
 		if (isr == 0xffffffff) {
 			*masked = 0;
 			return false;
@@ -97,11 +104,23 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 
 			*masked |= ATH9K_INT_TX;
 
-			s0_s = REG_READ(ah, AR_ISR_S0_S);
+			if (pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED) {
+				s0_s = REG_READ(ah, AR_ISR_S0_S);
+				s1_s = REG_READ(ah, AR_ISR_S1_S);
+			} else {
+				s0_s = REG_READ(ah, AR_ISR_S0);
+				REG_WRITE(ah, AR_ISR_S0, s0_s);
+				s1_s = REG_READ(ah, AR_ISR_S1);
+				REG_WRITE(ah, AR_ISR_S1, s1_s);
+
+				isr &= ~(AR_ISR_TXOK |
+					 AR_ISR_TXDESC |
+					 AR_ISR_TXERR |
+					 AR_ISR_TXEOL);
+			}
+
 			ah->intr_txqs |= MS(s0_s, AR_ISR_S0_QCU_TXOK);
 			ah->intr_txqs |= MS(s0_s, AR_ISR_S0_QCU_TXDESC);
-
-			s1_s = REG_READ(ah, AR_ISR_S1_S);
 			ah->intr_txqs |= MS(s1_s, AR_ISR_S1_QCU_TXERR);
 			ah->intr_txqs |= MS(s1_s, AR_ISR_S1_QCU_TXEOL);
 		}
@@ -114,13 +133,15 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		*masked |= mask2;
 	}
 
-	if (AR_SREV_9100(ah))
-		return true;
-
-	if (isr & AR_ISR_GENTMR) {
+	if (!AR_SREV_9100(ah) && (isr & AR_ISR_GENTMR)) {
 		u32 s5_s;
 
-		s5_s = REG_READ(ah, AR_ISR_S5_S);
+		if (pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED) {
+			s5_s = REG_READ(ah, AR_ISR_S5_S);
+		} else {
+			s5_s = REG_READ(ah, AR_ISR_S5);
+		}
+
 		ah->intr_gen_timer_trigger =
 				MS(s5_s, AR_ISR_S5_GENTIMER_TRIG);
 
@@ -133,8 +154,21 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		if ((s5_s & AR_ISR_S5_TIM_TIMER) &&
 		    !(pCap->hw_caps & ATH9K_HW_CAP_AUTOSLEEP))
 			*masked |= ATH9K_INT_TIM_TIMER;
+
+		if (!(pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED)) {
+			REG_WRITE(ah, AR_ISR_S5, s5_s);
+			isr &= ~AR_ISR_GENTMR;
+		}
 	}
 
+	if (!(pCap->hw_caps & ATH9K_HW_CAP_RAC_SUPPORTED)) {
+		REG_WRITE(ah, AR_ISR, isr);
+		REG_READ(ah, AR_ISR);
+	}
+
+	if (AR_SREV_9100(ah))
+		return true;
+
 	if (sync_cause) {
 		ath9k_debug_sync_cause(common, sync_cause);
 		fatal_int =
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 9a2657fdd9cc..608d739d1378 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -127,21 +127,26 @@ static void ath9k_htc_bssid_iter(void *data, u8 *mac, struct ieee80211_vif *vif)
 	struct ath9k_vif_iter_data *iter_data = data;
 	int i;
 
-	for (i = 0; i < ETH_ALEN; i++)
-		iter_data->mask[i] &= ~(iter_data->hw_macaddr[i] ^ mac[i]);
+	if (iter_data->hw_macaddr != NULL) {
+		for (i = 0; i < ETH_ALEN; i++)
+			iter_data->mask[i] &= ~(iter_data->hw_macaddr[i] ^ mac[i]);
+	} else {
+		iter_data->hw_macaddr = mac;
+	}
 }
 
-static void ath9k_htc_set_bssid_mask(struct ath9k_htc_priv *priv,
+static void ath9k_htc_set_mac_bssid_mask(struct ath9k_htc_priv *priv,
 				     struct ieee80211_vif *vif)
 {
 	struct ath_common *common = ath9k_hw_common(priv->ah);
 	struct ath9k_vif_iter_data iter_data;
 
 	/*
-	 * Use the hardware MAC address as reference, the hardware uses it
-	 * together with the BSSID mask when matching addresses.
+	 * Pick the MAC address of the first interface as the new hardware
+	 * MAC address. The hardware will use it together with the BSSID mask
+	 * when matching addresses.
 	 */
-	iter_data.hw_macaddr = common->macaddr;
+	iter_data.hw_macaddr = NULL;
 	memset(&iter_data.mask, 0xff, ETH_ALEN);
 
 	if (vif)
@@ -153,6 +158,10 @@ static void ath9k_htc_set_bssid_mask(struct ath9k_htc_priv *priv,
 		ath9k_htc_bssid_iter, &iter_data);
 
 	memcpy(common->bssidmask, iter_data.mask, ETH_ALEN);
+
+	if (iter_data.hw_macaddr)
+		memcpy(common->macaddr, iter_data.hw_macaddr, ETH_ALEN);
+
 	ath_hw_setbssidmask(common);
 }
 
@@ -1063,7 +1072,7 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 		goto out;
 	}
 
-	ath9k_htc_set_bssid_mask(priv, vif);
+	ath9k_htc_set_mac_bssid_mask(priv, vif);
 
 	priv->vif_slot |= (1 << avp->index);
 	priv->nvifs++;
@@ -1128,7 +1137,7 @@ static void ath9k_htc_remove_interface(struct ieee80211_hw *hw,
 
 	ath9k_htc_set_opmode(priv);
 
-	ath9k_htc_set_bssid_mask(priv, vif);
+	ath9k_htc_set_mac_bssid_mask(priv, vif);
 
 	/*
 	 * Stop ANI only if there are no associated station interfaces.
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 74f452c7b166..21aa09e0e825 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -965,8 +965,9 @@ void ath9k_calculate_iter_data(struct ieee80211_hw *hw,
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	/*
-	 * Use the hardware MAC address as reference, the hardware uses it
-	 * together with the BSSID mask when matching addresses.
+	 * Pick the MAC address of the first interface as the new hardware
+	 * MAC address. The hardware will use it together with the BSSID mask
+	 * when matching addresses.
 	 */
 	memset(iter_data, 0, sizeof(*iter_data));
 	memset(&iter_data->mask, 0xff, ETH_ALEN);
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 0f494444bcd1..5a53195d016b 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -740,6 +740,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 	};
 	int index = rtlpci->rx_ring[rx_queue_idx].idx;
 
+	if (rtlpci->driver_is_goingto_unload)
+		return;
 	/*RX NORMAL PKT */
 	while (count--) {
 		/*rx descriptor */
@@ -1636,6 +1638,7 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	 */
 	set_hal_stop(rtlhal);
 
+	rtlpci->driver_is_goingto_unload = true;
 	rtlpriv->cfg->ops->disable_interrupt(hw);
 	cancel_work_sync(&rtlpriv->works.lps_change_work);
 
@@ -1653,7 +1656,6 @@ static void rtl_pci_stop(struct ieee80211_hw *hw)
 	ppsc->rfchange_inprogress = true;
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_ps_lock, flags);
 
-	rtlpci->driver_is_goingto_unload = true;
 	rtlpriv->cfg->ops->hw_disable(hw);
 	/* some things are not needed if firmware not available */
 	if (!rtlpriv->max_fw_size)
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 6a6c8bb4fd72..7552f9e3089c 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -940,8 +940,22 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	bt_cb(skb)->pkt_type = *((unsigned char *) skb->data);
 	skb_pull(skb, 1);
 
-	if (hci_pi(sk)->channel == HCI_CHANNEL_RAW &&
-	    bt_cb(skb)->pkt_type == HCI_COMMAND_PKT) {
+	if (hci_pi(sk)->channel == HCI_CHANNEL_USER) {
+		/* No permission check is needed for user channel
+		 * since that gets enforced when binding the socket.
+		 *
+		 * However check that the packet type is valid.
+		 */
+		if (bt_cb(skb)->pkt_type != HCI_COMMAND_PKT &&
+		    bt_cb(skb)->pkt_type != HCI_ACLDATA_PKT &&
+		    bt_cb(skb)->pkt_type != HCI_SCODATA_PKT) {
+			err = -EINVAL;
+			goto drop;
+		}
+
+		skb_queue_tail(&hdev->raw_q, skb);
+		queue_work(hdev->workqueue, &hdev->tx_work);
+	} else if (bt_cb(skb)->pkt_type == HCI_COMMAND_PKT) {
 		u16 opcode = get_unaligned_le16(skb->data);
 		u16 ogf = hci_opcode_ogf(opcode);
 		u16 ocf = hci_opcode_ocf(opcode);
@@ -972,14 +986,6 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 			goto drop;
 		}
 
-		if (hci_pi(sk)->channel == HCI_CHANNEL_USER &&
-		    bt_cb(skb)->pkt_type != HCI_COMMAND_PKT &&
-		    bt_cb(skb)->pkt_type != HCI_ACLDATA_PKT &&
-		    bt_cb(skb)->pkt_type != HCI_SCODATA_PKT) {
-			err = -EINVAL;
-			goto drop;
-		}
-
 		skb_queue_tail(&hdev->raw_q, skb);
 		queue_work(hdev->workqueue, &hdev->tx_work);
 	}
diff --git a/net/wireless/radiotap.c b/net/wireless/radiotap.c
index a271c27fac77..722da616438c 100644
--- a/net/wireless/radiotap.c
+++ b/net/wireless/radiotap.c
@@ -124,6 +124,10 @@ int ieee80211_radiotap_iterator_init(
 	/* find payload start allowing for extended bitmap(s) */
 
 	if (iterator->_bitmap_shifter & (1<<IEEE80211_RADIOTAP_EXT)) {
+		if ((unsigned long)iterator->_arg -
+		    (unsigned long)iterator->_rtheader + sizeof(uint32_t) >
+		    (unsigned long)iterator->_max_length)
+			return -EINVAL;
 		while (get_unaligned_le32(iterator->_arg) &
 					(1 << IEEE80211_RADIOTAP_EXT)) {
 			iterator->_arg += sizeof(uint32_t);
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 65f800890d70..d3c5bd7c6b51 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -632,6 +632,16 @@ void __cfg80211_connect_result(struct net_device *dev, const u8 *bssid,
 	}
 #endif
 
+	if (!bss && (status == WLAN_STATUS_SUCCESS)) {
+		WARN_ON_ONCE(!wiphy_to_dev(wdev->wiphy)->ops->connect);
+		bss = cfg80211_get_bss(wdev->wiphy, NULL, bssid,
+				       wdev->ssid, wdev->ssid_len,
+				       WLAN_CAPABILITY_ESS,
+				       WLAN_CAPABILITY_ESS);
+		if (bss)
+			cfg80211_hold_bss(bss_from_pub(bss));
+	}
+
 	if (wdev->current_bss) {
 		cfg80211_unhold_bss(wdev->current_bss);
 		cfg80211_put_bss(wdev->wiphy, &wdev->current_bss->pub);
@@ -649,16 +659,8 @@ void __cfg80211_connect_result(struct net_device *dev, const u8 *bssid,
 		return;
 	}
 
-	if (!bss) {
-		WARN_ON_ONCE(!wiphy_to_dev(wdev->wiphy)->ops->connect);
-		bss = cfg80211_get_bss(wdev->wiphy, NULL, bssid,
-				       wdev->ssid, wdev->ssid_len,
-				       WLAN_CAPABILITY_ESS,
-				       WLAN_CAPABILITY_ESS);
-		if (WARN_ON(!bss))
-			return;
-		cfg80211_hold_bss(bss_from_pub(bss));
-	}
+	if (WARN_ON(!bss))
+		return;
 
 	wdev->current_bss = bss_from_pub(bss);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
