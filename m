From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-06-28
Date: Thu, 28 Jun 2012 14:40:12 -0400
Message-ID: <20120628184011.GC2115@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit de03309bd209b6fb025e9359266e0cbb441f7441

Dave,

These fixes are intended for 3.5...

Amitkumar Karwar gives us two mwifiex fixes: one fixes some skb
manipulations when handling some event messages; and another that
does some similar fixing on an error path.

Avinash Patil gives us a fix for for a memory leak in mwifiex.

Dan Rosenberg offers an NFC NCI fix to enforce some message length
limits to prevent buffer overflows.

Eliad Peller provides a mac80211 fix to prevent some frames from
being built with an invalid BSSID.

Eric Dumazet sends an NFC fix to prevent a BUG caused by a NULL
pointer dereference.

Felix Fietkau has an ath9k fix for a regression causing
LEAP-authenticated connection failures.

Johannes Berg provides an iwlwifi fix that eliminates some log SPAM
after an authentication/association timeout.  He also provides a
mac80211 fix to prevent incorrectly addressing certain action frames
(and in so doing, to comply with the 802.11 specs).

Larry Finger provides a few USB IDs for the rtl8192cu driver --
should be harmless.

Panayiotis Karabassis provices a one-liner to fix kernel bug 42903
(a system freeze).

Randy Dunlap provides a one-line Kconfig change to prevent build
failures with some configurations.

Stone Piao provides an mwifiex sequence numbering fix and a fix
to prevent mwifiex from attempting to include eapol frames in an
aggregation frame.

Finally, Tom Hughes provides an ath9k fix for a NULL pointer
dereference.

Please let me know if there are problems!

John

---

The following changes since commit a969dd139cc2f2bccdcb11894f0695517cf84d4d:

  Merge branch 'for-davem' of git://gitorious.org/linux-can/linux-can (2012-06-27 15:27:24 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

for you to fetch changes up to de03309bd209b6fb025e9359266e0cbb441f7441:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless into for-davem (2012-06-28 13:47:53 -0400)

----------------------------------------------------------------

Amitkumar Karwar (2):
      mwifiex: fix bugs in event handling code
      mwifiex: improve error path handling in usb.c

Avinash Patil (1):
      mwifiex: fix memory leak associated with IE manamgement

Dan Rosenberg (1):
      NFC: Prevent multiple buffer overflows in NCI

Eliad Peller (1):
      mac80211: clear ifmgd->bssid only after building DELBA

Eric Dumazet (1):
      NFC: Return from rawsock_release when sk is NULL

Felix Fietkau (1):
      ath9k: fix dynamic WEP related regression

Johannes Berg (2):
      iwlwifi: fix activating inactive stations
      mac80211: correct behaviour on unrecognised action frames

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-wireless' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: New USB IDs

Panayiotis Karabassis (1):
      ath9k: enable serialize_regmode for non-PCIE AR9287

Randy Dunlap (1):
      wlcore: drop INET dependency

Stone Piao (2):
      mwifiex: fix 11n rx packet drop issue
      mwifiex: fix WPS eapol handshake failure

Tom Hughes (1):
      ath9k: fix panic caused by returning a descriptor we have queued for reuse

 drivers/net/wireless/ath/ath.h               |    1 +
 drivers/net/wireless/ath/ath9k/hw.c          |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c        |    7 ++++---
 drivers/net/wireless/ath/key.c               |    4 ++++
 drivers/net/wireless/iwlwifi/iwl-mac80211.c  |   12 +++++++++++
 drivers/net/wireless/mwifiex/11n_rxreorder.c |    5 +++--
 drivers/net/wireless/mwifiex/11n_rxreorder.h |    7 +++++++
 drivers/net/wireless/mwifiex/ie.c            |    1 +
 drivers/net/wireless/mwifiex/sdio.c          |    6 +++---
 drivers/net/wireless/mwifiex/sta_event.c     |    9 ++++-----
 drivers/net/wireless/mwifiex/usb.c           |   28 ++++++++++++++++++--------
 drivers/net/wireless/mwifiex/wmm.c           |    3 +++
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c  |    3 +++
 drivers/net/wireless/ti/wlcore/Kconfig       |    1 -
 net/mac80211/mlme.c                          |   13 ++++++------
 net/mac80211/rx.c                            |    5 ++++-
 net/nfc/nci/ntf.c                            |   10 ++++-----
 net/nfc/rawsock.c                            |    5 ++++-
 18 files changed, 85 insertions(+), 37 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index c54b7d37..420d69b 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -143,6 +143,7 @@ struct ath_common {
 	u32 keymax;
 	DECLARE_BITMAP(keymap, ATH_KEYMAX);
 	DECLARE_BITMAP(tkip_keymap, ATH_KEYMAX);
+	DECLARE_BITMAP(ccmp_keymap, ATH_KEYMAX);
 	enum ath_crypt_caps crypt_caps;
 
 	unsigned int clockrate;
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 1c68e56..995ca8e 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -622,7 +622,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 
 	if (NR_CPUS > 1 && ah->config.serialize_regmode == SER_REG_MODE_AUTO) {
 		if (ah->hw_version.macVersion == AR_SREV_VERSION_5416_PCI ||
-		    ((AR_SREV_9160(ah) || AR_SREV_9280(ah)) &&
+		    ((AR_SREV_9160(ah) || AR_SREV_9280(ah) || AR_SREV_9287(ah)) &&
 		     !ah->is_pciexpress)) {
 			ah->config.serialize_regmode =
 				SER_REG_MODE_ON;
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index e1fcc68..0735aeb 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -695,9 +695,9 @@ static bool ath_edma_get_buffers(struct ath_softc *sc,
 			__skb_unlink(skb, &rx_edma->rx_fifo);
 			list_add_tail(&bf->list, &sc->rx.rxbuf);
 			ath_rx_edma_buf_link(sc, qtype);
-		} else {
-			bf = NULL;
 		}
+
+		bf = NULL;
 	}
 
 	*dest = bf;
@@ -822,7 +822,8 @@ static bool ath9k_rx_accept(struct ath_common *common,
 	 * descriptor does contain a valid key index. This has been observed
 	 * mostly with CCMP encryption.
 	 */
-	if (rx_stats->rs_keyix == ATH9K_RXKEYIX_INVALID)
+	if (rx_stats->rs_keyix == ATH9K_RXKEYIX_INVALID ||
+	    !test_bit(rx_stats->rs_keyix, common->ccmp_keymap))
 		rx_stats->rs_status &= ~ATH9K_RXERR_KEYMISS;
 
 	if (!rx_stats->rs_datalen) {
diff --git a/drivers/net/wireless/ath/key.c b/drivers/net/wireless/ath/key.c
index 0e81904..5c54aa4 100644
--- a/drivers/net/wireless/ath/key.c
+++ b/drivers/net/wireless/ath/key.c
@@ -556,6 +556,9 @@ int ath_key_config(struct ath_common *common,
 		return -EIO;
 
 	set_bit(idx, common->keymap);
+	if (key->cipher == WLAN_CIPHER_SUITE_CCMP)
+		set_bit(idx, common->ccmp_keymap);
+
 	if (key->cipher == WLAN_CIPHER_SUITE_TKIP) {
 		set_bit(idx + 64, common->keymap);
 		set_bit(idx, common->tkip_keymap);
@@ -582,6 +585,7 @@ void ath_key_delete(struct ath_common *common, struct ieee80211_key_conf *key)
 		return;
 
 	clear_bit(key->hw_key_idx, common->keymap);
+	clear_bit(key->hw_key_idx, common->ccmp_keymap);
 	if (key->cipher != WLAN_CIPHER_SUITE_TKIP)
 		return;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-mac80211.c b/drivers/net/wireless/iwlwifi/iwl-mac80211.c
index 3ee23134..0136803 100644
--- a/drivers/net/wireless/iwlwifi/iwl-mac80211.c
+++ b/drivers/net/wireless/iwlwifi/iwl-mac80211.c
@@ -796,6 +796,18 @@ int iwlagn_mac_sta_state(struct ieee80211_hw *hw,
 	switch (op) {
 	case ADD:
 		ret = iwlagn_mac_sta_add(hw, vif, sta);
+		if (ret)
+			break;
+		/*
+		 * Clear the in-progress flag, the AP station entry was added
+		 * but we'll initialize LQ only when we've associated (which
+		 * would also clear the in-progress flag). This is necessary
+		 * in case we never initialize LQ because association fails.
+		 */
+		spin_lock_bh(&priv->sta_lock);
+		priv->stations[iwl_sta_id(sta)].used &=
+			~IWL_STA_UCODE_INPROGRESS;
+		spin_unlock_bh(&priv->sta_lock);
 		break;
 	case REMOVE:
 		ret = iwlagn_mac_sta_remove(hw, vif, sta);
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index 9c44088..900ee12 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -256,7 +256,8 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
 	else
 		last_seq = priv->rx_seq[tid];
 
-	if (last_seq >= new_node->start_win)
+	if (last_seq != MWIFIEX_DEF_11N_RX_SEQ_NUM &&
+	    last_seq >= new_node->start_win)
 		new_node->start_win = last_seq + 1;
 
 	new_node->win_size = win_size;
@@ -596,5 +597,5 @@ void mwifiex_11n_cleanup_reorder_tbl(struct mwifiex_private *priv)
 	spin_unlock_irqrestore(&priv->rx_reorder_tbl_lock, flags);
 
 	INIT_LIST_HEAD(&priv->rx_reorder_tbl_ptr);
-	memset(priv->rx_seq, 0, sizeof(priv->rx_seq));
+	mwifiex_reset_11n_rx_seq_num(priv);
 }
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.h b/drivers/net/wireless/mwifiex/11n_rxreorder.h
index f1bffeb..6c9815a 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.h
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.h
@@ -37,6 +37,13 @@
 
 #define ADDBA_RSP_STATUS_ACCEPT 0
 
+#define MWIFIEX_DEF_11N_RX_SEQ_NUM	0xffff
+
+static inline void mwifiex_reset_11n_rx_seq_num(struct mwifiex_private *priv)
+{
+	memset(priv->rx_seq, 0xff, sizeof(priv->rx_seq));
+}
+
 int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private *,
 			       u16 seqNum,
 			       u16 tid, u8 *ta,
diff --git a/drivers/net/wireless/mwifiex/ie.c b/drivers/net/wireless/mwifiex/ie.c
index ceb82cd..383820a 100644
--- a/drivers/net/wireless/mwifiex/ie.c
+++ b/drivers/net/wireless/mwifiex/ie.c
@@ -213,6 +213,7 @@ mwifiex_update_uap_custom_ie(struct mwifiex_private *priv,
 		/* save assoc resp ie index after auto-indexing */
 		*assoc_idx = *((u16 *)pos);
 
+	kfree(ap_custom_ie);
 	return ret;
 }
 
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index e037747..fc8a9bf 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -978,10 +978,10 @@ static int mwifiex_decode_rx_packet(struct mwifiex_adapter *adapter,
 		dev_dbg(adapter->dev, "info: --- Rx: Event ---\n");
 		adapter->event_cause = *(u32 *) skb->data;
 
-		skb_pull(skb, MWIFIEX_EVENT_HEADER_LEN);
-
 		if ((skb->len > 0) && (skb->len  < MAX_EVENT_SIZE))
-			memcpy(adapter->event_body, skb->data, skb->len);
+			memcpy(adapter->event_body,
+			       skb->data + MWIFIEX_EVENT_HEADER_LEN,
+			       skb->len);
 
 		/* event cause has been saved to adapter->event_cause */
 		adapter->event_received = true;
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireless/mwifiex/sta_event.c
index 4ace5a3..11e731f 100644
--- a/drivers/net/wireless/mwifiex/sta_event.c
+++ b/drivers/net/wireless/mwifiex/sta_event.c
@@ -406,9 +406,9 @@ int mwifiex_process_sta_event(struct mwifiex_private *priv)
 		break;
 
 	case EVENT_UAP_STA_ASSOC:
-		skb_pull(adapter->event_skb, MWIFIEX_UAP_EVENT_EXTRA_HEADER);
 		memset(&sinfo, 0, sizeof(sinfo));
-		event = (struct mwifiex_assoc_event *)adapter->event_skb->data;
+		event = (struct mwifiex_assoc_event *)
+			(adapter->event_body + MWIFIEX_UAP_EVENT_EXTRA_HEADER);
 		if (le16_to_cpu(event->type) == TLV_TYPE_UAP_MGMT_FRAME) {
 			len = -1;
 
@@ -433,9 +433,8 @@ int mwifiex_process_sta_event(struct mwifiex_private *priv)
 				 GFP_KERNEL);
 		break;
 	case EVENT_UAP_STA_DEAUTH:
-		skb_pull(adapter->event_skb, MWIFIEX_UAP_EVENT_EXTRA_HEADER);
-		cfg80211_del_sta(priv->netdev, adapter->event_skb->data,
-				 GFP_KERNEL);
+		cfg80211_del_sta(priv->netdev, adapter->event_body +
+				 MWIFIEX_UAP_EVENT_EXTRA_HEADER, GFP_KERNEL);
 		break;
 	case EVENT_UAP_BSS_IDLE:
 		priv->media_connected = false;
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
index 49ebf20..22a5916 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -49,6 +49,7 @@ static int mwifiex_usb_recv(struct mwifiex_adapter *adapter,
 	struct device *dev = adapter->dev;
 	u32 recv_type;
 	__le32 tmp;
+	int ret;
 
 	if (adapter->hs_activated)
 		mwifiex_process_hs_config(adapter);
@@ -69,16 +70,19 @@ static int mwifiex_usb_recv(struct mwifiex_adapter *adapter,
 		case MWIFIEX_USB_TYPE_CMD:
 			if (skb->len > MWIFIEX_SIZE_OF_CMD_BUFFER) {
 				dev_err(dev, "CMD: skb->len too large\n");
-				return -1;
+				ret = -1;
+				goto exit_restore_skb;
 			} else if (!adapter->curr_cmd) {
 				dev_dbg(dev, "CMD: no curr_cmd\n");
 				if (adapter->ps_state == PS_STATE_SLEEP_CFM) {
 					mwifiex_process_sleep_confirm_resp(
 							adapter, skb->data,
 							skb->len);
-					return 0;
+					ret = 0;
+					goto exit_restore_skb;
 				}
-				return -1;
+				ret = -1;
+				goto exit_restore_skb;
 			}
 
 			adapter->curr_cmd->resp_skb = skb;
@@ -87,20 +91,22 @@ static int mwifiex_usb_recv(struct mwifiex_adapter *adapter,
 		case MWIFIEX_USB_TYPE_EVENT:
 			if (skb->len < sizeof(u32)) {
 				dev_err(dev, "EVENT: skb->len too small\n");
-				return -1;
+				ret = -1;
+				goto exit_restore_skb;
 			}
 			skb_copy_from_linear_data(skb, &tmp, sizeof(u32));
 			adapter->event_cause = le32_to_cpu(tmp);
-			skb_pull(skb, sizeof(u32));
 			dev_dbg(dev, "event_cause %#x\n", adapter->event_cause);
 
 			if (skb->len > MAX_EVENT_SIZE) {
 				dev_err(dev, "EVENT: event body too large\n");
-				return -1;
+				ret = -1;
+				goto exit_restore_skb;
 			}
 
-			skb_copy_from_linear_data(skb, adapter->event_body,
-						  skb->len);
+			memcpy(adapter->event_body, skb->data +
+			       MWIFIEX_EVENT_HEADER_LEN, skb->len);
+
 			adapter->event_received = true;
 			adapter->event_skb = skb;
 			break;
@@ -124,6 +130,12 @@ static int mwifiex_usb_recv(struct mwifiex_adapter *adapter,
 	}
 
 	return -EINPROGRESS;
+
+exit_restore_skb:
+	/* The buffer will be reused for further cmds/events */
+	skb_push(skb, INTF_HEADER_LEN);
+
+	return ret;
 }
 
 static void mwifiex_usb_rx_complete(struct urb *urb)
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwifiex/wmm.c
index f3fc655..3fa4d41 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -404,6 +404,8 @@ mwifiex_wmm_init(struct mwifiex_adapter *adapter)
 		priv->add_ba_param.tx_win_size = MWIFIEX_AMPDU_DEF_TXWINSIZE;
 		priv->add_ba_param.rx_win_size = MWIFIEX_AMPDU_DEF_RXWINSIZE;
 
+		mwifiex_reset_11n_rx_seq_num(priv);
+
 		atomic_set(&priv->wmm.tx_pkts_queued, 0);
 		atomic_set(&priv->wmm.highest_queued_prio, HIGH_PRIO_TID);
 	}
@@ -1221,6 +1223,7 @@ mwifiex_dequeue_tx_packet(struct mwifiex_adapter *adapter)
 
 	if (!ptr->is_11n_enabled ||
 	    mwifiex_is_ba_stream_setup(priv, ptr, tid) ||
+	    priv->wps.session_enable ||
 	    ((priv->sec_info.wpa_enabled ||
 	      priv->sec_info.wpa2_enabled) &&
 	     !priv->wpa_is_gtk_set)) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index d228358..9970c2b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -301,9 +301,11 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(0x07b8, 0x8188, rtl92cu_hal_cfg)}, /*Abocom - Abocom*/
 	{RTL_USB_DEVICE(0x07b8, 0x8189, rtl92cu_hal_cfg)}, /*Funai - Abocom*/
 	{RTL_USB_DEVICE(0x0846, 0x9041, rtl92cu_hal_cfg)}, /*NetGear WNA1000M*/
+	{RTL_USB_DEVICE(0x0bda, 0x5088, rtl92cu_hal_cfg)}, /*Thinkware-CC&C*/
 	{RTL_USB_DEVICE(0x0df6, 0x0052, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
 	{RTL_USB_DEVICE(0x0df6, 0x005c, rtl92cu_hal_cfg)}, /*Sitecom - Edimax*/
 	{RTL_USB_DEVICE(0x0eb0, 0x9071, rtl92cu_hal_cfg)}, /*NO Brand - Etop*/
+	{RTL_USB_DEVICE(0x4856, 0x0091, rtl92cu_hal_cfg)}, /*NetweeN - Feixun*/
 	/* HP - Lite-On ,8188CUS Slim Combo */
 	{RTL_USB_DEVICE(0x103c, 0x1629, rtl92cu_hal_cfg)},
 	{RTL_USB_DEVICE(0x13d3, 0x3357, rtl92cu_hal_cfg)}, /* AzureWave */
@@ -346,6 +348,7 @@ static struct usb_device_id rtl8192c_usb_ids[] = {
 	{RTL_USB_DEVICE(0x07b8, 0x8178, rtl92cu_hal_cfg)}, /*Funai -Abocom*/
 	{RTL_USB_DEVICE(0x0846, 0x9021, rtl92cu_hal_cfg)}, /*Netgear-Sercomm*/
 	{RTL_USB_DEVICE(0x0b05, 0x17ab, rtl92cu_hal_cfg)}, /*ASUS-Edimax*/
+	{RTL_USB_DEVICE(0x0bda, 0x8186, rtl92cu_hal_cfg)}, /*Realtek 92CE-VAU*/
 	{RTL_USB_DEVICE(0x0df6, 0x0061, rtl92cu_hal_cfg)}, /*Sitecom-Edimax*/
 	{RTL_USB_DEVICE(0x0e66, 0x0019, rtl92cu_hal_cfg)}, /*Hawking-Edimax*/
 	{RTL_USB_DEVICE(0x2001, 0x3307, rtl92cu_hal_cfg)}, /*D-Link-Cameo*/
diff --git a/drivers/net/wireless/ti/wlcore/Kconfig b/drivers/net/wireless/ti/wlcore/Kconfig
index 54156b0..d7b907e 100644
--- a/drivers/net/wireless/ti/wlcore/Kconfig
+++ b/drivers/net/wireless/ti/wlcore/Kconfig
@@ -1,7 +1,6 @@
 config WLCORE
 	tristate "TI wlcore support"
 	depends on WL_TI && GENERIC_HARDIRQS && MAC80211
-	depends on INET
 	select FW_LOADER
 	---help---
 	  This module contains the main code for TI WLAN chips.  It abstracts
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 66e4fcd..a4bb856 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1342,7 +1342,6 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 	u32 changed = 0;
-	u8 bssid[ETH_ALEN];
 
 	ASSERT_MGD_MTX(ifmgd);
 
@@ -1354,10 +1353,7 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 
 	ieee80211_stop_poll(sdata);
 
-	memcpy(bssid, ifmgd->associated->bssid, ETH_ALEN);
-
 	ifmgd->associated = NULL;
-	memset(ifmgd->bssid, 0, ETH_ALEN);
 
 	/*
 	 * we need to commit the associated = NULL change because the
@@ -1377,7 +1373,7 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 	netif_carrier_off(sdata->dev);
 
 	mutex_lock(&local->sta_mtx);
-	sta = sta_info_get(sdata, bssid);
+	sta = sta_info_get(sdata, ifmgd->bssid);
 	if (sta) {
 		set_sta_flag(sta, WLAN_STA_BLOCK_BA);
 		ieee80211_sta_tear_down_BA_sessions(sta, tx);
@@ -1386,13 +1382,16 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 
 	/* deauthenticate/disassociate now */
 	if (tx || frame_buf)
-		ieee80211_send_deauth_disassoc(sdata, bssid, stype, reason,
-					       tx, frame_buf);
+		ieee80211_send_deauth_disassoc(sdata, ifmgd->bssid, stype,
+					       reason, tx, frame_buf);
 
 	/* flush out frame */
 	if (tx)
 		drv_flush(local, false);
 
+	/* clear bssid only after building the needed mgmt frames */
+	memset(ifmgd->bssid, 0, ETH_ALEN);
+
 	/* remove AP and TDLS peers */
 	sta_info_flush(local, sdata);
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 7bcecf7..965e6ec 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2455,7 +2455,7 @@ ieee80211_rx_h_action_return(struct ieee80211_rx_data *rx)
 	 * frames that we didn't handle, including returning unknown
 	 * ones. For all other modes we will return them to the sender,
 	 * setting the 0x80 bit in the action category, as required by
-	 * 802.11-2007 7.3.1.11.
+	 * 802.11-2012 9.24.4.
 	 * Newer versions of hostapd shall also use the management frame
 	 * registration mechanisms, but older ones still use cooked
 	 * monitor interfaces so push all frames there.
@@ -2465,6 +2465,9 @@ ieee80211_rx_h_action_return(struct ieee80211_rx_data *rx)
 	     sdata->vif.type == NL80211_IFTYPE_AP_VLAN))
 		return RX_DROP_MONITOR;
 
+	if (is_multicast_ether_addr(mgmt->da))
+		return RX_DROP_MONITOR;
+
 	/* do not return rejected action frames */
 	if (mgmt->u.action.category & 0x80)
 		return RX_DROP_UNUSABLE;
diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index cb26461..2ab196a 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -106,7 +106,7 @@ static __u8 *nci_extract_rf_params_nfca_passive_poll(struct nci_dev *ndev,
 	nfca_poll->sens_res = __le16_to_cpu(*((__u16 *)data));
 	data += 2;
 
-	nfca_poll->nfcid1_len = *data++;
+	nfca_poll->nfcid1_len = min_t(__u8, *data++, NFC_NFCID1_MAXSIZE);
 
 	pr_debug("sens_res 0x%x, nfcid1_len %d\n",
 		 nfca_poll->sens_res, nfca_poll->nfcid1_len);
@@ -130,7 +130,7 @@ static __u8 *nci_extract_rf_params_nfcb_passive_poll(struct nci_dev *ndev,
 			struct rf_tech_specific_params_nfcb_poll *nfcb_poll,
 						     __u8 *data)
 {
-	nfcb_poll->sensb_res_len = *data++;
+	nfcb_poll->sensb_res_len = min_t(__u8, *data++, NFC_SENSB_RES_MAXSIZE);
 
 	pr_debug("sensb_res_len %d\n", nfcb_poll->sensb_res_len);
 
@@ -145,7 +145,7 @@ static __u8 *nci_extract_rf_params_nfcf_passive_poll(struct nci_dev *ndev,
 						     __u8 *data)
 {
 	nfcf_poll->bit_rate = *data++;
-	nfcf_poll->sensf_res_len = *data++;
+	nfcf_poll->sensf_res_len = min_t(__u8, *data++, NFC_SENSF_RES_MAXSIZE);
 
 	pr_debug("bit_rate %d, sensf_res_len %d\n",
 		 nfcf_poll->bit_rate, nfcf_poll->sensf_res_len);
@@ -331,7 +331,7 @@ static int nci_extract_activation_params_iso_dep(struct nci_dev *ndev,
 	switch (ntf->activation_rf_tech_and_mode) {
 	case NCI_NFC_A_PASSIVE_POLL_MODE:
 		nfca_poll = &ntf->activation_params.nfca_poll_iso_dep;
-		nfca_poll->rats_res_len = *data++;
+		nfca_poll->rats_res_len = min_t(__u8, *data++, 20);
 		pr_debug("rats_res_len %d\n", nfca_poll->rats_res_len);
 		if (nfca_poll->rats_res_len > 0) {
 			memcpy(nfca_poll->rats_res,
@@ -341,7 +341,7 @@ static int nci_extract_activation_params_iso_dep(struct nci_dev *ndev,
 
 	case NCI_NFC_B_PASSIVE_POLL_MODE:
 		nfcb_poll = &ntf->activation_params.nfcb_poll_iso_dep;
-		nfcb_poll->attrib_res_len = *data++;
+		nfcb_poll->attrib_res_len = min_t(__u8, *data++, 50);
 		pr_debug("attrib_res_len %d\n", nfcb_poll->attrib_res_len);
 		if (nfcb_poll->attrib_res_len > 0) {
 			memcpy(nfcb_poll->attrib_res,
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index ec1134c..8b8a6a2 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -54,7 +54,10 @@ static int rawsock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	pr_debug("sock=%p\n", sock);
+	pr_debug("sock=%p sk=%p\n", sock, sk);
+
+	if (!sk)
+		return 0;
 
 	sock_orphan(sk);
 	sock_put(sk);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
