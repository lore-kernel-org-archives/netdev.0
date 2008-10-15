From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-10-14
Date: Tue, 14 Oct 2008 21:32:05 -0400
Message-ID: <20081015013204.GH3349@tuxdriver.com>
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

Here is a nice little batch of wireless fixes in time for 2.6.28-rc1.
There are also a few USB ID additions as well.  I think this is all
mostly obvious, and hopefully still acceptable at this stage.

Please let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 485013717020cd8961337309e359d6cef43d6022:
  Ron Mercer (1):
        qlge: Fix page size ifdef test.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrey Borzenkov (1):
      orinoco: fix unsafe locking in orinoco_cs_resume

Christian Lamparter (1):
      p54usb: Device ID updates

David Kilroy (1):
      orinoco: fix unsafe locking in spectrum_cs_suspend

Felix Fietkau (1):
      rt2x00: fix regression introduced by "mac80211: free up 2 bytes in skb->cb"

Florent Fourcot (1):
      rtl8187: Add USB ID for Belkin F5D7050 with RTL8187B chip

Johannes Berg (5):
      mac80211: fix debugfs lockup
      mac80211: fix HT information element parsing
      mac80211: fix debugfs netdev rename
      cfg80211: fix debugfs error handling
      ath9k/mac80211: disallow fragmentation in ath9k, report to userspace

John W. Linville (1):
      rtl8187: add device ID 0bda:8198

Jouni Malinen (1):
      mac80211: Fix scan RX processing oops

Larry Finger (1):
      p54: Fix compilation problem on PPC

Manish Katiyar (1):
      libertas : Remove unused variable warning for "old_channel" from cmd.c

Rami Rosen (1):
      iwlwifi: fix compilation warning when CONFIG_IWLWIFI_DEBUG is not set.

Randy Dunlap (1):
      mac80211: fixme for kernel-doc

Tomas Winkler (1):
      iwlwifi: fix ct kill configuration for 5350

 drivers/net/wireless/ath9k/main.c         |    8 +++++++-
 drivers/net/wireless/iwlwifi/iwl-5000.c   |    6 +++---
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    2 +-
 drivers/net/wireless/libertas/cmd.c       |    2 ++
 drivers/net/wireless/orinoco_cs.c         |    5 +++--
 drivers/net/wireless/p54/p54common.c      |    1 -
 drivers/net/wireless/p54/p54usb.c         |    3 ++-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    9 +++++----
 drivers/net/wireless/rtl8187_dev.c        |    3 +++
 drivers/net/wireless/spectrum_cs.c        |    5 +++--
 include/net/mac80211.h                    |    3 ++-
 net/mac80211/debugfs_netdev.c             |    6 +++++-
 net/mac80211/debugfs_sta.c                |   11 +++++++++++
 net/mac80211/ieee80211_i.h                |    6 ++----
 net/mac80211/mlme.c                       |    3 ---
 net/mac80211/scan.c                       |    3 ++-
 net/mac80211/sta_info.c                   |    7 ++++++-
 net/mac80211/sta_info.h                   |    1 +
 net/mac80211/util.c                       |    8 ++++----
 net/mac80211/wext.c                       |    2 +-
 net/wireless/core.c                       |    5 ++++-
 21 files changed, 67 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 7472699..f05f584 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -1640,6 +1640,11 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 	return ret;
 }
 
+static int ath9k_no_fragmentation(struct ieee80211_hw *hw, u32 value)
+{
+	return -EOPNOTSUPP;
+}
+
 static struct ieee80211_ops ath9k_ops = {
 	.tx 		    = ath9k_tx,
 	.start 		    = ath9k_start,
@@ -1664,7 +1669,8 @@ static struct ieee80211_ops ath9k_ops = {
 	.get_tsf 	    = ath9k_get_tsf,
 	.reset_tsf 	    = ath9k_reset_tsf,
 	.tx_last_beacon     = NULL,
-	.ampdu_action       = ath9k_ampdu_action
+	.ampdu_action       = ath9k_ampdu_action,
+	.set_frag_threshold = ath9k_no_fragmentation,
 };
 
 static int ath_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index f6003e7..5155b8a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -833,12 +833,12 @@ static int iwl5000_hw_set_hw_params(struct iwl_priv *priv)
 	switch (priv->hw_rev & CSR_HW_REV_TYPE_MSK) {
 	case CSR_HW_REV_TYPE_5100:
 	case CSR_HW_REV_TYPE_5300:
-		/* 5X00 wants in Celsius */
+	case CSR_HW_REV_TYPE_5350:
+		/* 5X00 and 5350 wants in Celsius */
 		priv->hw_params.ct_kill_threshold = CT_KILL_THRESHOLD;
 		break;
 	case CSR_HW_REV_TYPE_5150:
-	case CSR_HW_REV_TYPE_5350:
-		/* 5X50 wants in Kelvin */
+		/* 5150 wants in Kelvin */
 		priv->hw_params.ct_kill_threshold =
 				CELSIUS_TO_KELVIN(CT_KILL_THRESHOLD);
 		break;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 93944de..e2a58e4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -2422,7 +2422,7 @@ static void rs_free_sta(void *priv_r, struct ieee80211_sta *sta,
 			void *priv_sta)
 {
 	struct iwl_lq_sta *lq_sta = priv_sta;
-	struct iwl_priv *priv = priv_r;
+	struct iwl_priv *priv __maybe_unused = priv_r;
 
 	IWL_DEBUG_RATE("enter\n");
 	kfree(lq_sta);
diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
index a912fb6..297696d 100644
--- a/drivers/net/wireless/libertas/cmd.c
+++ b/drivers/net/wireless/libertas/cmd.c
@@ -823,7 +823,9 @@ int lbs_update_channel(struct lbs_private *priv)
 int lbs_set_channel(struct lbs_private *priv, u8 channel)
 {
 	struct cmd_ds_802_11_rf_channel cmd;
+#ifdef DEBUG
 	u8 old_channel = priv->curbssparams.channel;
+#endif
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_CMD);
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index 9eaa252..65fd054 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -403,6 +403,7 @@ static int orinoco_cs_resume(struct pcmcia_device *link)
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct orinoco_pccard *card = priv->card;
 	int err = 0;
+	unsigned long flags;
 
 	if (! test_bit(0, &card->hard_reset_in_progress)) {
 		err = orinoco_reinit_firmware(dev);
@@ -412,7 +413,7 @@ static int orinoco_cs_resume(struct pcmcia_device *link)
 			return -EIO;
 		}
 
-		spin_lock(&priv->lock);
+		spin_lock_irqsave(&priv->lock, flags);
 
 		netif_device_attach(dev);
 		priv->hw_unavailable--;
@@ -424,7 +425,7 @@ static int orinoco_cs_resume(struct pcmcia_device *link)
 				       dev->name, err);
 		}
 
-		spin_unlock(&priv->lock);
+		spin_unlock_irqrestore(&priv->lock, flags);
 	}
 
 	return err;
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 1994aa1..117c7d3 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -479,7 +479,6 @@ static int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 	printk(KERN_ERR "p54: eeprom parse failed!\n");
 	return err;
 }
-EXPORT_SYMBOL_GPL(p54_parse_eeprom);
 
 static int p54_rssi_to_dbm(struct ieee80211_hw *dev, int rssi)
 {
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 1912f5e..75d749b 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -39,6 +39,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0846, 0x4200)},	/* Netgear WG121 */
 	{USB_DEVICE(0x0846, 0x4210)},	/* Netgear WG121 the second ? */
 	{USB_DEVICE(0x0846, 0x4220)},	/* Netgear WG111 */
+	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
 	{USB_DEVICE(0x0cde, 0x0006)},	/* Medion 40900, Roper Europe */
 	{USB_DEVICE(0x124a, 0x4023)},	/* Shuttle PN15, Airvast WM168g, IOGear GWU513 */
 	{USB_DEVICE(0x1915, 0x2234)},	/* Linksys WUSB54G OEM */
@@ -63,8 +64,8 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0cde, 0x0006)},   /* Medion MD40900 */
 	{USB_DEVICE(0x0cde, 0x0008)},	/* Sagem XG703A */
 	{USB_DEVICE(0x0d8e, 0x3762)},	/* DLink DWL-G120 Cohiba */
-	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
 	{USB_DEVICE(0x124a, 0x4025)},	/* IOGear GWU513 (GW3887IK chip) */
+	{USB_DEVICE(0x1260, 0xee22)},	/* SMC 2862W-G version 2 */
 	{USB_DEVICE(0x13b1, 0x000a)},	/* Linksys WUSB54G ver 2 */
 	{USB_DEVICE(0x13B1, 0x000C)},	/* Linksys WUSB54AG */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 1676ac4..451d410 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -374,7 +374,7 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb)
 	struct queue_entry *entry = rt2x00queue_get_entry(queue, Q_INDEX);
 	struct txentry_desc txdesc;
 	struct skb_frame_desc *skbdesc;
-	unsigned int iv_len;
+	unsigned int iv_len = 0;
 
 	if (unlikely(rt2x00queue_full(queue)))
 		return -EINVAL;
@@ -395,6 +395,9 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb)
 	entry->skb = skb;
 	rt2x00queue_create_tx_descriptor(entry, &txdesc);
 
+	if (IEEE80211_SKB_CB(skb)->control.hw_key != NULL)
+		iv_len = IEEE80211_SKB_CB(skb)->control.hw_key->iv_len;
+
 	/*
 	 * All information is retreived from the skb->cb array,
 	 * now we should claim ownership of the driver part of that
@@ -410,9 +413,7 @@ int rt2x00queue_write_tx_frame(struct data_queue *queue, struct sk_buff *skb)
 	 * the frame so we can provide it to the driver seperately.
 	 */
 	if (test_bit(ENTRY_TXD_ENCRYPT, &txdesc.flags) &&
-	    !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc.flags) &&
-		(IEEE80211_SKB_CB(skb)->control.hw_key != NULL)) {
-		iv_len = IEEE80211_SKB_CB(skb)->control.hw_key->iv_len;
+	    !test_bit(ENTRY_TXD_ENCRYPT_IV, &txdesc.flags)) {
 		rt2x00crypto_tx_remove_iv(skb, iv_len);
 	}
 
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index e990261..431e3c7 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -33,10 +33,13 @@ MODULE_LICENSE("GPL");
 static struct usb_device_id rtl8187_table[] __devinitdata = {
 	/* Asus */
 	{USB_DEVICE(0x0b05, 0x171d), .driver_info = DEVICE_RTL8187},
+	/* Belkin */
+	{USB_DEVICE(0x050d, 0x705e), .driver_info = DEVICE_RTL8187B},
 	/* Realtek */
 	{USB_DEVICE(0x0bda, 0x8187), .driver_info = DEVICE_RTL8187},
 	{USB_DEVICE(0x0bda, 0x8189), .driver_info = DEVICE_RTL8187B},
 	{USB_DEVICE(0x0bda, 0x8197), .driver_info = DEVICE_RTL8187B},
+	{USB_DEVICE(0x0bda, 0x8198), .driver_info = DEVICE_RTL8187B},
 	/* Netgear */
 	{USB_DEVICE(0x0846, 0x6100), .driver_info = DEVICE_RTL8187},
 	{USB_DEVICE(0x0846, 0x6a00), .driver_info = DEVICE_RTL8187},
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index 67b26d3..f5513cd 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -450,10 +450,11 @@ spectrum_cs_suspend(struct pcmcia_device *link)
 {
 	struct net_device *dev = link->priv;
 	struct orinoco_private *priv = netdev_priv(dev);
+	unsigned long flags;
 	int err = 0;
 
 	/* Mark the device as stopped, to block IO until later */
-	spin_lock(&priv->lock);
+	spin_lock_irqsave(&priv->lock, flags);
 
 	err = __orinoco_down(dev);
 	if (err)
@@ -463,7 +464,7 @@ spectrum_cs_suspend(struct pcmcia_device *link)
 	netif_device_detach(dev);
 	priv->hw_unavailable++;
 
-	spin_unlock(&priv->lock);
+	spin_unlock_irqrestore(&priv->lock, flags);
 
 	return err;
 }
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 5617a16..d861197 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -645,7 +645,8 @@ enum ieee80211_key_flags {
  * 	- Temporal Encryption Key (128 bits)
  * 	- Temporal Authenticator Tx MIC Key (64 bits)
  * 	- Temporal Authenticator Rx MIC Key (64 bits)
- *
+ * @icv_len: FIXME
+ * @iv_len: FIXME
  */
 struct ieee80211_key_conf {
 	enum ieee80211_key_alg alg;
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 2a45156..2ad504f 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -545,8 +545,12 @@ static int netdev_notify(struct notifier_block *nb,
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
-	sprintf(buf, "netdev:%s", dev->name);
 	dir = sdata->debugfsdir;
+
+	if (!dir)
+		return 0;
+
+	sprintf(buf, "netdev:%s", dev->name);
 	if (!debugfs_rename(dir->d_parent, dir, dir->d_parent, buf))
 		printk(KERN_ERR "mac80211: debugfs: failed to rename debugfs "
 		       "dir to %s\n", buf);
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
index b9902e4..189d0ba 100644
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@ -249,11 +249,22 @@ void ieee80211_sta_debugfs_add(struct sta_info *sta)
 	DECLARE_MAC_BUF(mbuf);
 	u8 *mac;
 
+	sta->debugfs.add_has_run = true;
+
 	if (!stations_dir)
 		return;
 
 	mac = print_mac(mbuf, sta->sta.addr);
 
+	/*
+	 * This might fail due to a race condition:
+	 * When mac80211 unlinks a station, the debugfs entries
+	 * remain, but it is already possible to link a new
+	 * station with the same address which triggers adding
+	 * it to debugfs; therefore, if the old station isn't
+	 * destroyed quickly enough the old station's debugfs
+	 * dir might still be around.
+	 */
 	sta->debugfs.dir = debugfs_create_dir(mac, stations_dir);
 	if (!sta->debugfs.dir)
 		return;
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8025b29..156e42a 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -816,8 +816,8 @@ struct ieee802_11_elems {
 	u8 *ext_supp_rates;
 	u8 *wmm_info;
 	u8 *wmm_param;
-	u8 *ht_cap_elem;
-	u8 *ht_info_elem;
+	struct ieee80211_ht_cap *ht_cap_elem;
+	struct ieee80211_ht_addt_info *ht_info_elem;
 	u8 *mesh_config;
 	u8 *mesh_id;
 	u8 *peer_link;
@@ -844,8 +844,6 @@ struct ieee802_11_elems {
 	u8 ext_supp_rates_len;
 	u8 wmm_info_len;
 	u8 wmm_param_len;
-	u8 ht_cap_elem_len;
-	u8 ht_info_elem_len;
 	u8 mesh_config_len;
 	u8 mesh_id_len;
 	u8 peer_link_len;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 49f86fa..87665d7 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1348,10 +1348,8 @@ static void ieee80211_rx_mgmt_assoc_resp(struct ieee80211_sub_if_data *sdata,
 	    (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
 		struct ieee80211_ht_bss_info bss_info;
 		ieee80211_ht_cap_ie_to_ht_info(
-				(struct ieee80211_ht_cap *)
 				elems.ht_cap_elem, &sta->sta.ht_info);
 		ieee80211_ht_addt_info_ie_to_ht_bss_info(
-				(struct ieee80211_ht_addt_info *)
 				elems.ht_info_elem, &bss_info);
 		ieee80211_handle_ht(local, 1, &sta->sta.ht_info, &bss_info);
 	}
@@ -1709,7 +1707,6 @@ static void ieee80211_rx_mgmt_beacon(struct ieee80211_sub_if_data *sdata,
 		struct ieee80211_ht_bss_info bss_info;
 
 		ieee80211_ht_addt_info_ie_to_ht_bss_info(
-				(struct ieee80211_ht_addt_info *)
 				elems.ht_info_elem, &bss_info);
 		changed |= ieee80211_handle_ht(local, 1, &conf->ht_conf,
 					       &bss_info);
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 8e6685e..416bb41 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -388,7 +388,8 @@ ieee80211_scan_rx(struct ieee80211_sub_if_data *sdata, struct sk_buff *skb,
 	bss = ieee80211_bss_info_update(sdata->local, rx_status,
 					mgmt, skb->len, &elems,
 					freq, beacon);
-	ieee80211_rx_bss_put(sdata->local, bss);
+	if (bss)
+		ieee80211_rx_bss_put(sdata->local, bss);
 
 	dev_kfree_skb(skb);
 	return RX_QUEUED;
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 9b72d15..7fef8ea 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -635,7 +635,12 @@ static void sta_info_debugfs_add_work(struct work_struct *work)
 
 		spin_lock_irqsave(&local->sta_lock, flags);
 		list_for_each_entry(tmp, &local->sta_list, list) {
-			if (!tmp->debugfs.dir) {
+			/*
+			 * debugfs.add_has_run will be set by
+			 * ieee80211_sta_debugfs_add regardless
+			 * of what else it does.
+			 */
+			if (!tmp->debugfs.add_has_run) {
 				sta = tmp;
 				__sta_info_pin(sta);
 				break;
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index a6b5186..168a39a 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -300,6 +300,7 @@ struct sta_info {
 		struct dentry *inactive_ms;
 		struct dentry *last_seq_ctrl;
 		struct dentry *agg_status;
+		bool add_has_run;
 	} debugfs;
 #endif
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index f32561e..cee4884 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -529,12 +529,12 @@ void ieee802_11_parse_elems(u8 *start, size_t len,
 			elems->ext_supp_rates_len = elen;
 			break;
 		case WLAN_EID_HT_CAPABILITY:
-			elems->ht_cap_elem = pos;
-			elems->ht_cap_elem_len = elen;
+			if (elen >= sizeof(struct ieee80211_ht_cap))
+				elems->ht_cap_elem = (void *)pos;
 			break;
 		case WLAN_EID_HT_EXTRA_INFO:
-			elems->ht_info_elem = pos;
-			elems->ht_info_elem_len = elen;
+			if (elen >= sizeof(struct ieee80211_ht_addt_info))
+				elems->ht_info_elem = (void *)pos;
 			break;
 		case WLAN_EID_MESH_ID:
 			elems->mesh_id = pos;
diff --git a/net/mac80211/wext.c b/net/mac80211/wext.c
index 7e0d53a..742f811 100644
--- a/net/mac80211/wext.c
+++ b/net/mac80211/wext.c
@@ -775,7 +775,7 @@ static int ieee80211_ioctl_siwfrag(struct net_device *dev,
 	 * configure it here */
 
 	if (local->ops->set_frag_threshold)
-		local->ops->set_frag_threshold(
+		return local->ops->set_frag_threshold(
 			local_to_hw(local),
 			local->fragmentation_threshold);
 
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 24fdd4c..5031db7 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -184,7 +184,8 @@ int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
 	if (result)
 		goto out_unlock;
 
-	if (!debugfs_rename(rdev->wiphy.debugfsdir->d_parent,
+	if (rdev->wiphy.debugfsdir &&
+	    !debugfs_rename(rdev->wiphy.debugfsdir->d_parent,
 			    rdev->wiphy.debugfsdir,
 			    rdev->wiphy.debugfsdir->d_parent,
 			    newname))
@@ -317,6 +318,8 @@ int wiphy_register(struct wiphy *wiphy)
 	drv->wiphy.debugfsdir =
 		debugfs_create_dir(wiphy_name(&drv->wiphy),
 				   ieee80211_debugfs_dir);
+	if (IS_ERR(drv->wiphy.debugfsdir))
+		drv->wiphy.debugfsdir = NULL;
 
 	res = 0;
 out_unlock:
-- 
John W. Linville		Linux should be at the core
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			of your literate lifestyle.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
