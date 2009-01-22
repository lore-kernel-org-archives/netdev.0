From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-01-22
Date: Thu, 22 Jan 2009 14:43:21 -0500
Message-ID: <20090122194320.GD3646@tuxdriver.com>
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

Here is this week's round of fixes intended for 2.6.29.  Most of them
are small and obvious.  There are a couple of bigger ones for p54,
one that corrects some frame corruption on monitor interfaces and
another that corrects a potential use-after-free bug.  There is also
an orinoco patch that looks big because it is moving some code around
to avoid a locking issue.  All of them have cooked in wireless-testing
and have had extensive testing.

Please let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 6d317482944250228255bcbe97a95b7e7ad9a538:
  Christian Eggers (1):
        usb/mcs7830: Don't use buffers from stack for USB transfers

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Andrey Borzenkov (1):
      orinoco: move kmalloc(..., GFP_KERNEL) outside spinlock in orinoco_ioctl_set_genie

Brian Cavagnolo (1):
      mac80211: decrement ref count to netdev after launching mesh discovery

Chr (1):
      p54: add missing break in eeprom parser

Christian Lamparter (3):
      mac80211: fix slot time debug message
      p54: more cryptographic accelerator fixes
      p54usb: fix nasty use after free

Hin-Tak Leung (1):
      zd1211rw: adding Sitecom WL-603 (0df6:0036) to the USB id list

Ivo van Doorn (1):
      rt2x00: Fix TX rate short preamble detection

Pavel Roskin (1):
      orinoco: use KERN_DEBUG for link status messages

Reinette Chatre (1):
      iwlwifi: return NETDEV_TX_OK from _tx ops

 drivers/net/wireless/iwlwifi/iwl-agn.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 drivers/net/wireless/orinoco/orinoco.c      |   32 +++++++++++--------------
 drivers/net/wireless/p54/p54common.c        |   24 +++++++++++++++----
 drivers/net/wireless/p54/p54usb.c           |   34 ++++++++++----------------
 drivers/net/wireless/rt2x00/rt2x00queue.c   |    3 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    1 +
 net/mac80211/mlme.c                         |    4 +-
 net/mac80211/tx.c                           |    6 +++-
 9 files changed, 57 insertions(+), 51 deletions(-)

diff --git a/arch/arm/mach-integrator/clock.h b/arch/arm/mach-integrator/clock.h
deleted file mode 100644
index e69de29..0000000
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 5da6b35..0dc8eed 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -2482,7 +2482,7 @@ static int iwl_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 		dev_kfree_skb_any(skb);
 
 	IWL_DEBUG_MACDUMP("leave\n");
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int iwl_mac_add_interface(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 15f5655..95d0198 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6538,7 +6538,7 @@ static int iwl3945_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 		dev_kfree_skb_any(skb);
 
 	IWL_DEBUG_MAC80211("leave\n");
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int iwl3945_mac_add_interface(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/orinoco/orinoco.c b/drivers/net/wireless/orinoco/orinoco.c
index c3bb85e..45a04fa 100644
--- a/drivers/net/wireless/orinoco/orinoco.c
+++ b/drivers/net/wireless/orinoco/orinoco.c
@@ -1673,7 +1673,7 @@ static void print_linkstatus(struct net_device *dev, u16 status)
 		s = "UNKNOWN";
 	}
 	
-	printk(KERN_INFO "%s: New link status: %s (%04x)\n",
+	printk(KERN_DEBUG "%s: New link status: %s (%04x)\n",
 	       dev->name, s, status);
 }
 
@@ -5068,33 +5068,30 @@ static int orinoco_ioctl_set_genie(struct net_device *dev,
 	struct orinoco_private *priv = netdev_priv(dev);
 	u8 *buf;
 	unsigned long flags;
-	int err = 0;
 
 	/* cut off at IEEE80211_MAX_DATA_LEN */
 	if ((wrqu->data.length > IEEE80211_MAX_DATA_LEN) ||
 	    (wrqu->data.length && (extra == NULL)))
 		return -EINVAL;
 
-	if (orinoco_lock(priv, &flags) != 0)
-		return -EBUSY;
-
 	if (wrqu->data.length) {
 		buf = kmalloc(wrqu->data.length, GFP_KERNEL);
-		if (buf == NULL) {
-			err = -ENOMEM;
-			goto out;
-		}
+		if (buf == NULL)
+			return -ENOMEM;
 
 		memcpy(buf, extra, wrqu->data.length);
-		kfree(priv->wpa_ie);
-		priv->wpa_ie = buf;
-		priv->wpa_ie_len = wrqu->data.length;
-	} else {
-		kfree(priv->wpa_ie);
-		priv->wpa_ie = NULL;
-		priv->wpa_ie_len = 0;
+	} else
+		buf = NULL;
+
+	if (orinoco_lock(priv, &flags) != 0) {
+		kfree(buf);
+		return -EBUSY;
 	}
 
+	kfree(priv->wpa_ie);
+	priv->wpa_ie = buf;
+	priv->wpa_ie_len = wrqu->data.length;
+
 	if (priv->wpa_ie) {
 		/* Looks like wl_lkm wants to check the auth alg, and
 		 * somehow pass it to the firmware.
@@ -5103,9 +5100,8 @@ static int orinoco_ioctl_set_genie(struct net_device *dev,
 		 */
 	}
 
-out:
 	orinoco_unlock(priv, &flags);
-	return err;
+	return 0;
 }
 
 static int orinoco_ioctl_get_genie(struct net_device *dev,
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 12d0717..34561e6 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -451,8 +451,8 @@ static int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 			}
 			if (err)
 				goto err;
-
-		}
+			}
+			break;
 		case PDR_PRISM_ZIF_TX_IQ_CALIBRATION:
 			priv->iq_autocal = kmalloc(data_len, GFP_KERNEL);
 			if (!priv->iq_autocal) {
@@ -745,7 +745,7 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 		struct ieee80211_tx_info *info = IEEE80211_SKB_CB(entry);
 		struct p54_hdr *entry_hdr;
 		struct p54_tx_data *entry_data;
-		int pad = 0;
+		unsigned int pad = 0, frame_len;
 
 		range = (void *)info->rate_driver_data;
 		if (range->start_addr != addr) {
@@ -768,6 +768,7 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 		__skb_unlink(entry, &priv->tx_queue);
 		spin_unlock_irqrestore(&priv->tx_queue.lock, flags);
 
+		frame_len = entry->len;
 		entry_hdr = (struct p54_hdr *) entry->data;
 		entry_data = (struct p54_tx_data *) entry_hdr->data;
 		priv->tx_stats[entry_data->hw_queue].len--;
@@ -814,15 +815,28 @@ static void p54_rx_frame_sent(struct ieee80211_hw *dev, struct sk_buff *skb)
 		info->status.ack_signal = p54_rssi_to_dbm(dev,
 				(int)payload->ack_rssi);
 
-		if (entry_data->key_type == P54_CRYPTO_TKIPMICHAEL) {
+		/* Undo all changes to the frame. */
+		switch (entry_data->key_type) {
+		case P54_CRYPTO_TKIPMICHAEL: {
 			u8 *iv = (u8 *)(entry_data->align + pad +
-				        entry_data->crypt_offset);
+					entry_data->crypt_offset);
 
 			/* Restore the original TKIP IV. */
 			iv[2] = iv[0];
 			iv[0] = iv[1];
 			iv[1] = (iv[0] | 0x20) & 0x7f;	/* WEPSeed - 8.3.2.2 */
+
+			frame_len -= 12; /* remove TKIP_MMIC + TKIP_ICV */
+			break;
+			}
+		case P54_CRYPTO_AESCCMP:
+			frame_len -= 8; /* remove CCMP_MIC */
+			break;
+		case P54_CRYPTO_WEP:
+			frame_len -= 4; /* remove WEP_ICV */
+			break;
 		}
+		skb_trim(entry, frame_len);
 		skb_pull(entry, sizeof(*hdr) + pad + sizeof(*entry_data));
 		ieee80211_tx_status_irqsafe(dev, entry);
 		goto out;
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 6a6a72f..4487cc5 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -144,11 +144,8 @@ static void p54u_tx_cb(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct ieee80211_hw *dev = (struct ieee80211_hw *)
 		usb_get_intfdata(usb_ifnum_to_if(urb->dev, 0));
-	struct p54u_priv *priv = dev->priv;
 
-	skb_pull(skb, priv->common.tx_hdr_len);
-	if (FREE_AFTER_TX(skb))
-		p54_free_skb(dev, skb);
+	p54_free_skb(dev, skb);
 }
 
 static void p54u_tx_dummy_cb(struct urb *urb) { }
@@ -230,7 +227,8 @@ static void p54u_tx_3887(struct ieee80211_hw *dev, struct sk_buff *skb)
 			  p54u_tx_dummy_cb, dev);
 	usb_fill_bulk_urb(data_urb, priv->udev,
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
-			  skb->data, skb->len, p54u_tx_cb, skb);
+			  skb->data, skb->len, FREE_AFTER_TX(skb) ?
+			  p54u_tx_cb : p54u_tx_dummy_cb, skb);
 
 	usb_anchor_urb(addr_urb, &priv->submitted);
 	err = usb_submit_urb(addr_urb, GFP_ATOMIC);
@@ -269,28 +267,24 @@ static void p54u_tx_lm87(struct ieee80211_hw *dev, struct sk_buff *skb)
 {
 	struct p54u_priv *priv = dev->priv;
 	struct urb *data_urb;
-	struct lm87_tx_hdr *hdr;
-	__le32 checksum;
-	__le32 addr = ((struct p54_hdr *)skb->data)->req_id;
+	struct lm87_tx_hdr *hdr = (void *)skb->data - sizeof(*hdr);
 
 	data_urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!data_urb)
 		return;
 
-	checksum = p54u_lm87_chksum((__le32 *)skb->data, skb->len);
-	hdr = (struct lm87_tx_hdr *)skb_push(skb, sizeof(*hdr));
-	hdr->chksum = checksum;
-	hdr->device_addr = addr;
+	hdr->chksum = p54u_lm87_chksum((__le32 *)skb->data, skb->len);
+	hdr->device_addr = ((struct p54_hdr *)skb->data)->req_id;
 
 	usb_fill_bulk_urb(data_urb, priv->udev,
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
-			  skb->data, skb->len, p54u_tx_cb, skb);
+			  hdr, skb->len + sizeof(*hdr),  FREE_AFTER_TX(skb) ?
+			  p54u_tx_cb : p54u_tx_dummy_cb, skb);
 	data_urb->transfer_flags |= URB_ZERO_PACKET;
 
 	usb_anchor_urb(data_urb, &priv->submitted);
 	if (usb_submit_urb(data_urb, GFP_ATOMIC)) {
 		usb_unanchor_urb(data_urb);
-		skb_pull(skb, sizeof(*hdr));
 		p54_free_skb(dev, skb);
 	}
 	usb_free_urb(data_urb);
@@ -300,11 +294,9 @@ static void p54u_tx_net2280(struct ieee80211_hw *dev, struct sk_buff *skb)
 {
 	struct p54u_priv *priv = dev->priv;
 	struct urb *int_urb, *data_urb;
-	struct net2280_tx_hdr *hdr;
+	struct net2280_tx_hdr *hdr = (void *)skb->data - sizeof(*hdr);
 	struct net2280_reg_write *reg;
 	int err = 0;
-	__le32 addr = ((struct p54_hdr *) skb->data)->req_id;
-	__le16 len = cpu_to_le16(skb->len);
 
 	reg = kmalloc(sizeof(*reg), GFP_ATOMIC);
 	if (!reg)
@@ -327,10 +319,9 @@ static void p54u_tx_net2280(struct ieee80211_hw *dev, struct sk_buff *skb)
 	reg->addr = cpu_to_le32(P54U_DEV_BASE);
 	reg->val = cpu_to_le32(ISL38XX_DEV_INT_DATA);
 
-	hdr = (void *)skb_push(skb, sizeof(*hdr));
 	memset(hdr, 0, sizeof(*hdr));
-	hdr->len = len;
-	hdr->device_addr = addr;
+	hdr->len = cpu_to_le16(skb->len);
+	hdr->device_addr = ((struct p54_hdr *) skb->data)->req_id;
 
 	usb_fill_bulk_urb(int_urb, priv->udev,
 		usb_sndbulkpipe(priv->udev, P54U_PIPE_DEV), reg, sizeof(*reg),
@@ -345,7 +336,8 @@ static void p54u_tx_net2280(struct ieee80211_hw *dev, struct sk_buff *skb)
 
 	usb_fill_bulk_urb(data_urb, priv->udev,
 			  usb_sndbulkpipe(priv->udev, P54U_PIPE_DATA),
-			  skb->data, skb->len, p54u_tx_cb, skb);
+			  hdr, skb->len + sizeof(*hdr), FREE_AFTER_TX(skb) ?
+			  p54u_tx_cb : p54u_tx_dummy_cb, skb);
 
 	usb_anchor_urb(int_urb, &priv->submitted);
 	err = usb_submit_urb(int_urb, GFP_ATOMIC);
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 746a8f3..0709dec 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -154,6 +154,7 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 	struct rt2x00_dev *rt2x00dev = entry->queue->rt2x00dev;
 	struct ieee80211_tx_info *tx_info = IEEE80211_SKB_CB(entry->skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)entry->skb->data;
+	struct ieee80211_tx_rate *txrate = &tx_info->control.rates[0];
 	struct ieee80211_rate *rate =
 	    ieee80211_get_tx_rate(rt2x00dev->hw, tx_info);
 	const struct rt2x00_rate *hwrate;
@@ -313,7 +314,7 @@ static void rt2x00queue_create_tx_descriptor(struct queue_entry *entry,
 		 * When preamble is enabled we should set the
 		 * preamble bit for the signal.
 		 */
-		if (rate->flags & IEEE80211_TX_RC_USE_SHORT_PREAMBLE)
+		if (txrate->flags & IEEE80211_TX_RC_USE_SHORT_PREAMBLE)
 			txdesc->signal |= 0x08;
 	}
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index b5db57d..17527f7 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -84,6 +84,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x340a), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1237), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x07fa, 0x1196), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0df6, 0x0036), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 5ba721b..2b890af 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -620,8 +620,8 @@ static u32 ieee80211_handle_bss_capability(struct ieee80211_sub_if_data *sdata,
 	if (use_short_slot != bss_conf->use_short_slot) {
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: switched to %s slot"
-			       " (BSSID=%s)\n",
+			printk(KERN_DEBUG "%s: switched to %s slot time"
+			       " (BSSID=%pM)\n",
 			       sdata->dev->name,
 			       use_short_slot ? "short" : "long",
 			       ifsta->bssid);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index a4af3a1..4278e54 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1307,8 +1307,10 @@ int ieee80211_master_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (is_multicast_ether_addr(hdr->addr3))
 			memcpy(hdr->addr1, hdr->addr3, ETH_ALEN);
 		else
-			if (mesh_nexthop_lookup(skb, osdata))
-				return  0;
+			if (mesh_nexthop_lookup(skb, osdata)) {
+				dev_put(odev);
+				return 0;
+			}
 		if (memcmp(odev->dev_addr, hdr->addr4, ETH_ALEN) != 0)
 			IEEE80211_IFSTA_MESH_CTR_INC(&osdata->u.mesh,
 							    fwded_frames);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
