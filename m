From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-05-12
Date: Tue, 12 May 2009 10:54:24 -0400
Message-ID: <20090512145423.GA3773@tuxdriver.com>
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

Another round of fixes intended for 2.6.30.  In particular, "mac80211:
avoid NULL ptr deref when finding max_rates in PID and minstrel" fixes a
bug that is a by-product of a fix that has already gone to Linus...oops!
As for the others, the iwlwifi patch adds PCI IDs and corrects antenna
configurations for a couple of devices, the rtl8187 corrects a problem
some people were hitting relating to using non-DMA buffers for USB
messages, the airo fix corrects an possible buffer overflow, and the
ath5k fix documents the oops it is correcting.

Please let me know if there are problems!

Thanks,

John

P.S.  I probably should have gotten this out sooner, but due to a burp
at my mailserver I was a bit unaware... :-(

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit e1cc1c578055d20d36e084e324001fb5e0355a71:
  David S. Miller (1):
        Merge branch 'net-fixes' of git://git.kernel.org/.../chris/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: update channel in sw state after stopping RX and TX

Jay Sternberg (1):
      iwlwifi: fix device id registration for 6000 series 2x2 devices

John W. Linville (3):
      airo: airo_get_encode{,ext} potential buffer overflow
      mac80211: avoid NULL ptr deref when finding max_rates in PID and minstrel
      rtl8187: use DMA-aware buffers with usb_control_msg

 drivers/net/wireless/airo.c                    |   10 +++-
 drivers/net/wireless/ath5k/base.c              |   22 +++++----
 drivers/net/wireless/iwlwifi/iwl-6000.c        |    8 ++--
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    2 +
 drivers/net/wireless/rtl818x/rtl8187.h         |   57 ++++++++++++++++++------
 drivers/net/wireless/rtl818x/rtl8187_dev.c     |   13 +++++-
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |    8 +++-
 net/mac80211/rc80211_minstrel.c                |    2 +-
 net/mac80211/rc80211_pid_algo.c                |    2 +-
 9 files changed, 91 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index c36d3a3..d734757 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6501,7 +6501,10 @@ static int airo_get_encode(struct net_device *dev,
 
 	/* Copy the key to the user buffer */
 	dwrq->length = get_wep_key(local, index, &buf[0], sizeof(buf));
-	memcpy(extra, buf, dwrq->length);
+	if (dwrq->length != -1)
+		memcpy(extra, buf, dwrq->length);
+	else
+		dwrq->length = 0;
 
 	return 0;
 }
@@ -6659,7 +6662,10 @@ static int airo_get_encodeext(struct net_device *dev,
 	
 	/* Copy the key to the user buffer */
 	ext->key_len = get_wep_key(local, idx, &buf[0], sizeof(buf));
-	memcpy(extra, buf, ext->key_len);
+	if (ext->key_len != -1)
+		memcpy(extra, buf, ext->key_len);
+	else
+		ext->key_len = 0;
 
 	return 0;
 }
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index a08bc8a..32df27a 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -214,7 +214,7 @@ static struct pci_driver ath5k_pci_driver = {
  * Prototypes - MAC 802.11 stack related functions
  */
 static int ath5k_tx(struct ieee80211_hw *hw, struct sk_buff *skb);
-static int ath5k_reset(struct ath5k_softc *sc, bool stop, bool change_channel);
+static int ath5k_reset(struct ath5k_softc *sc, struct ieee80211_channel *chan);
 static int ath5k_reset_wake(struct ath5k_softc *sc);
 static int ath5k_start(struct ieee80211_hw *hw);
 static void ath5k_stop(struct ieee80211_hw *hw);
@@ -1038,16 +1038,13 @@ ath5k_chan_set(struct ath5k_softc *sc, struct ieee80211_channel *chan)
 	if (chan->center_freq != sc->curchan->center_freq ||
 		chan->hw_value != sc->curchan->hw_value) {
 
-		sc->curchan = chan;
-		sc->curband = &sc->sbands[chan->band];
-
 		/*
 		 * To switch channels clear any pending DMA operations;
 		 * wait long enough for the RX fifo to drain, reset the
 		 * hardware at the new frequency, and then re-enable
 		 * the relevant bits of the h/w.
 		 */
-		return ath5k_reset(sc, true, true);
+		return ath5k_reset(sc, chan);
 	}
 
 	return 0;
@@ -2314,7 +2311,7 @@ ath5k_init(struct ath5k_softc *sc)
 	sc->imask = AR5K_INT_RXOK | AR5K_INT_RXERR | AR5K_INT_RXEOL |
 		AR5K_INT_RXORN | AR5K_INT_TXDESC | AR5K_INT_TXEOL |
 		AR5K_INT_FATAL | AR5K_INT_GLOBAL;
-	ret = ath5k_reset(sc, false, false);
+	ret = ath5k_reset(sc, NULL);
 	if (ret)
 		goto done;
 
@@ -2599,18 +2596,25 @@ drop_packet:
 	return NETDEV_TX_OK;
 }
 
+/*
+ * Reset the hardware.  If chan is not NULL, then also pause rx/tx
+ * and change to the given channel.
+ */
 static int
-ath5k_reset(struct ath5k_softc *sc, bool stop, bool change_channel)
+ath5k_reset(struct ath5k_softc *sc, struct ieee80211_channel *chan)
 {
 	struct ath5k_hw *ah = sc->ah;
 	int ret;
 
 	ATH5K_DBG(sc, ATH5K_DEBUG_RESET, "resetting\n");
 
-	if (stop) {
+	if (chan) {
 		ath5k_hw_set_imr(ah, 0);
 		ath5k_txq_cleanup(sc);
 		ath5k_rx_stop(sc);
+
+		sc->curchan = chan;
+		sc->curband = &sc->sbands[chan->band];
 	}
 	ret = ath5k_hw_reset(ah, sc->opmode, sc->curchan, true);
 	if (ret) {
@@ -2648,7 +2652,7 @@ ath5k_reset_wake(struct ath5k_softc *sc)
 {
 	int ret;
 
-	ret = ath5k_reset(sc, true, true);
+	ret = ath5k_reset(sc, sc->curchan);
 	if (!ret)
 		ieee80211_wake_queues(sc->hw);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index edfa5e1..bd438d8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -101,8 +101,8 @@ struct iwl_cfg iwl6000_2agn_cfg = {
 	.eeprom_ver = EEPROM_5000_EEPROM_VERSION,
 	.eeprom_calib_ver = EEPROM_5000_TX_POWER_VERSION,
 	.mod_params = &iwl50_mod_params,
-	.valid_tx_ant = ANT_BC,
-	.valid_rx_ant = ANT_BC,
+	.valid_tx_ant = ANT_AB,
+	.valid_rx_ant = ANT_AB,
 	.need_pll_cfg = false,
 };
 
@@ -117,8 +117,8 @@ struct iwl_cfg iwl6050_2agn_cfg = {
 	.eeprom_ver = EEPROM_5000_EEPROM_VERSION,
 	.eeprom_calib_ver = EEPROM_5000_TX_POWER_VERSION,
 	.mod_params = &iwl50_mod_params,
-	.valid_tx_ant = ANT_BC,
-	.valid_rx_ant = ANT_BC,
+	.valid_tx_ant = ANT_AB,
+	.valid_rx_ant = ANT_AB,
 	.need_pll_cfg = false,
 };
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 1ef4192..3bb28db 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3636,7 +3636,9 @@ static struct pci_device_id iwl_hw_card_ids[] = {
 	{IWL_PCI_DEVICE(0x0085, 0x1112, iwl6000_2ag_cfg)},
 	{IWL_PCI_DEVICE(0x0082, 0x1122, iwl6000_2ag_cfg)},
 	{IWL_PCI_DEVICE(0x422B, PCI_ANY_ID, iwl6000_3agn_cfg)},
+	{IWL_PCI_DEVICE(0x422C, PCI_ANY_ID, iwl6000_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x4238, PCI_ANY_ID, iwl6000_3agn_cfg)},
+	{IWL_PCI_DEVICE(0x4239, PCI_ANY_ID, iwl6000_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0082, PCI_ANY_ID, iwl6000_2agn_cfg)},
 	{IWL_PCI_DEVICE(0x0085, PCI_ANY_ID, iwl6000_3agn_cfg)},
 	{IWL_PCI_DEVICE(0x0086, PCI_ANY_ID, iwl6050_3agn_cfg)},
diff --git a/drivers/net/wireless/rtl818x/rtl8187.h b/drivers/net/wireless/rtl818x/rtl8187.h
index 9718f61..edeff82 100644
--- a/drivers/net/wireless/rtl818x/rtl8187.h
+++ b/drivers/net/wireless/rtl818x/rtl8187.h
@@ -120,6 +120,12 @@ struct rtl8187_priv {
 		__le64 buf;
 		struct sk_buff_head queue;
 	} b_tx_status; /* This queue is used by both -b and non-b devices */
+	struct mutex io_mutex;
+	union {
+		u8 bits8;
+		__le16 bits16;
+		__le32 bits32;
+	} *io_dmabuf;
 };
 
 void rtl8187_write_phy(struct ieee80211_hw *dev, u8 addr, u32 data);
@@ -129,10 +135,14 @@ static inline u8 rtl818x_ioread8_idx(struct rtl8187_priv *priv,
 {
 	u8 val;
 
+	mutex_lock(&priv->io_mutex);
 	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
 			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
-			(unsigned long)addr, idx & 0x03, &val,
-			sizeof(val), HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits8, sizeof(val), HZ / 2);
+
+	val = priv->io_dmabuf->bits8;
+	mutex_unlock(&priv->io_mutex);
 
 	return val;
 }
@@ -147,10 +157,14 @@ static inline u16 rtl818x_ioread16_idx(struct rtl8187_priv *priv,
 {
 	__le16 val;
 
+	mutex_lock(&priv->io_mutex);
 	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
 			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
-			(unsigned long)addr, idx & 0x03, &val,
-			sizeof(val), HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits16, sizeof(val), HZ / 2);
+
+	val = priv->io_dmabuf->bits16;
+	mutex_unlock(&priv->io_mutex);
 
 	return le16_to_cpu(val);
 }
@@ -165,10 +179,14 @@ static inline u32 rtl818x_ioread32_idx(struct rtl8187_priv *priv,
 {
 	__le32 val;
 
+	mutex_lock(&priv->io_mutex);
 	usb_control_msg(priv->udev, usb_rcvctrlpipe(priv->udev, 0),
 			RTL8187_REQ_GET_REG, RTL8187_REQT_READ,
-			(unsigned long)addr, idx & 0x03, &val,
-			sizeof(val), HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits32, sizeof(val), HZ / 2);
+
+	val = priv->io_dmabuf->bits32;
+	mutex_unlock(&priv->io_mutex);
 
 	return le32_to_cpu(val);
 }
@@ -181,10 +199,15 @@ static inline u32 rtl818x_ioread32(struct rtl8187_priv *priv, __le32 *addr)
 static inline void rtl818x_iowrite8_idx(struct rtl8187_priv *priv,
 					u8 *addr, u8 val, u8 idx)
 {
+	mutex_lock(&priv->io_mutex);
+
+	priv->io_dmabuf->bits8 = val;
 	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
-			(unsigned long)addr, idx & 0x03, &val,
-			sizeof(val), HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits8, sizeof(val), HZ / 2);
+
+	mutex_unlock(&priv->io_mutex);
 }
 
 static inline void rtl818x_iowrite8(struct rtl8187_priv *priv, u8 *addr, u8 val)
@@ -195,12 +218,15 @@ static inline void rtl818x_iowrite8(struct rtl8187_priv *priv, u8 *addr, u8 val)
 static inline void rtl818x_iowrite16_idx(struct rtl8187_priv *priv,
 					 __le16 *addr, u16 val, u8 idx)
 {
-	__le16 buf = cpu_to_le16(val);
+	mutex_lock(&priv->io_mutex);
 
+	priv->io_dmabuf->bits16 = cpu_to_le16(val);
 	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
-			(unsigned long)addr, idx & 0x03, &buf, sizeof(buf),
-			HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits16, sizeof(val), HZ / 2);
+
+	mutex_unlock(&priv->io_mutex);
 }
 
 static inline void rtl818x_iowrite16(struct rtl8187_priv *priv, __le16 *addr,
@@ -212,12 +238,15 @@ static inline void rtl818x_iowrite16(struct rtl8187_priv *priv, __le16 *addr,
 static inline void rtl818x_iowrite32_idx(struct rtl8187_priv *priv,
 					 __le32 *addr, u32 val, u8 idx)
 {
-	__le32 buf = cpu_to_le32(val);
+	mutex_lock(&priv->io_mutex);
 
+	priv->io_dmabuf->bits32 = cpu_to_le32(val);
 	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
-			(unsigned long)addr, idx & 0x03, &buf, sizeof(buf),
-			HZ / 2);
+			(unsigned long)addr, idx & 0x03,
+			&priv->io_dmabuf->bits32, sizeof(val), HZ / 2);
+
+	mutex_unlock(&priv->io_mutex);
 }
 
 static inline void rtl818x_iowrite32(struct rtl8187_priv *priv, __le32 *addr,
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index fd81884..bac6cfb 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -1329,6 +1329,14 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	priv = dev->priv;
 	priv->is_rtl8187b = (id->driver_info == DEVICE_RTL8187B);
 
+	/* allocate "DMA aware" buffer for register accesses */
+	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf), GFP_KERNEL);
+	if (!priv->io_dmabuf) {
+		err = -ENOMEM;
+		goto err_free_dev;
+	}
+	mutex_init(&priv->io_mutex);
+
 	SET_IEEE80211_DEV(dev, &intf->dev);
 	usb_set_intfdata(intf, dev);
 	priv->udev = udev;
@@ -1495,7 +1503,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	err = ieee80211_register_hw(dev);
 	if (err) {
 		printk(KERN_ERR "rtl8187: Cannot register device\n");
-		goto err_free_dev;
+		goto err_free_dmabuf;
 	}
 	mutex_init(&priv->conf_mutex);
 	skb_queue_head_init(&priv->b_tx_status.queue);
@@ -1506,6 +1514,8 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 
 	return 0;
 
+ err_free_dmabuf:
+	kfree(priv->io_dmabuf);
  err_free_dev:
 	ieee80211_free_hw(dev);
 	usb_set_intfdata(intf, NULL);
@@ -1526,6 +1536,7 @@ static void __devexit rtl8187_disconnect(struct usb_interface *intf)
 	priv = dev->priv;
 	usb_reset_device(priv->udev);
 	usb_put_dev(interface_to_usbdev(intf));
+	kfree(priv->io_dmabuf);
 	ieee80211_free_hw(dev);
 }
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
index 78df281..a098193 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rtl8225.c
@@ -88,9 +88,15 @@ static void rtl8225_write_8051(struct ieee80211_hw *dev, u8 addr, __le16 data)
 	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80);
 	udelay(10);
 
+	mutex_lock(&priv->io_mutex);
+
+	priv->io_dmabuf->bits16 = data;
 	usb_control_msg(priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			RTL8187_REQ_SET_REG, RTL8187_REQT_WRITE,
-			addr, 0x8225, &data, sizeof(data), HZ / 2);
+			addr, 0x8225, &priv->io_dmabuf->bits16, sizeof(data),
+			HZ / 2);
+
+	mutex_unlock(&priv->io_mutex);
 
 	rtl818x_iowrite16(priv, &priv->map->RFPinsOutput, reg80 | (1 << 2));
 	udelay(10);
diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 70df3dc..d9233ec 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -477,7 +477,7 @@ minstrel_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp)
 
 	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
 		sband = hw->wiphy->bands[i];
-		if (sband->n_bitrates > max_rates)
+		if (sband && sband->n_bitrates > max_rates)
 			max_rates = sband->n_bitrates;
 	}
 
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 01d59a8..8bef9a1 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -378,7 +378,7 @@ static void *rate_control_pid_alloc(struct ieee80211_hw *hw,
 
 	for (i = 0; i < IEEE80211_NUM_BANDS; i++) {
 		sband = hw->wiphy->bands[i];
-		if (sband->n_bitrates > max_rates)
+		if (sband && sband->n_bitrates > max_rates)
 			max_rates = sband->n_bitrates;
 	}
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
