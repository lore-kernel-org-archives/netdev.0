From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-05-01
Date: Thu, 1 May 2008 18:18:22 -0400
Message-ID: <20080501221822.GA13489@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2374 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761545AbYEAW7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 18:59:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another quick round of wireless fixes for 2.6.26...let me know if there
are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit c2a3b233450d5bc426c063ea2d8a74351db29ea4:
  David S. Miller (1):
        Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bill Moss (1):
      iwlwifi: fix debug messages during scanning

Guy Cohen (1):
      iwlwifi: fix current channel is not scanned

Ivo van Doorn (2):
      rt2x00: Don't enable short preamble for 1MBs
      rt2x00: Fix quality/activity led handling

Kirill A. Shutemov (1):
      Make linux/wireless.h be able to compile

Michael Buesch (1):
      b43: Fix some TX/RX locking issues

 drivers/net/wireless/b43/b43.h              |    4 ++
 drivers/net/wireless/b43/main.c             |   43 ++++++++++++++++++---------
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   29 +++++-------------
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   26 ++++------------
 drivers/net/wireless/rt2x00/rt2400pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    2 +
 drivers/net/wireless/rt2x00/rt2x00leds.c    |   15 +++++++++
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    6 ++++
 drivers/net/wireless/rt2x00/rt61pci.c       |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +-
 include/linux/wireless.h                    |    7 +----
 15 files changed, 78 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index eff2a15..37783cd 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -691,6 +691,10 @@ struct b43_wl {
 
 	struct mutex mutex;
 	spinlock_t irq_lock;
+	/* R/W lock for data transmission.
+	 * Transmissions on 2+ queues can run concurrently, but somebody else
+	 * might sync with TX by write_lock_irqsave()'ing. */
+	rwlock_t tx_lock;
 	/* Lock for LEDs access. */
 	spinlock_t leds_lock;
 	/* Lock for SHM access. */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 6c7db9a..8fdba94 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -729,6 +729,7 @@ static void b43_synchronize_irq(struct b43_wldev *dev)
  */
 void b43_dummy_transmission(struct b43_wldev *dev)
 {
+	struct b43_wl *wl = dev->wl;
 	struct b43_phy *phy = &dev->phy;
 	unsigned int i, max_loop;
 	u16 value;
@@ -755,6 +756,9 @@ void b43_dummy_transmission(struct b43_wldev *dev)
 		return;
 	}
 
+	spin_lock_irq(&wl->irq_lock);
+	write_lock(&wl->tx_lock);
+
 	for (i = 0; i < 5; i++)
 		b43_ram_write(dev, i * 4, buffer[i]);
 
@@ -795,6 +799,9 @@ void b43_dummy_transmission(struct b43_wldev *dev)
 	}
 	if (phy->radio_ver == 0x2050 && phy->radio_rev <= 0x5)
 		b43_radio_write16(dev, 0x0051, 0x0037);
+
+	write_unlock(&wl->tx_lock);
+	spin_unlock_irq(&wl->irq_lock);
 }
 
 static void key_write(struct b43_wldev *dev,
@@ -2840,24 +2847,31 @@ static int b43_op_tx(struct ieee80211_hw *hw,
 {
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
-	int err = -ENODEV;
+	unsigned long flags;
+	int err;
 
 	if (unlikely(skb->len < 2 + 2 + 6)) {
 		/* Too short, this can't be a valid frame. */
-		return -EINVAL;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 	B43_WARN_ON(skb_shinfo(skb)->nr_frags);
-
 	if (unlikely(!dev))
-		goto out;
-	if (unlikely(b43_status(dev) < B43_STAT_STARTED))
-		goto out;
-	/* TX is done without a global lock. */
-	if (b43_using_pio_transfers(dev))
-		err = b43_pio_tx(dev, skb, ctl);
-	else
-		err = b43_dma_tx(dev, skb, ctl);
-out:
+		return NETDEV_TX_BUSY;
+
+	/* Transmissions on seperate queues can run concurrently. */
+	read_lock_irqsave(&wl->tx_lock, flags);
+
+	err = -ENODEV;
+	if (likely(b43_status(dev) >= B43_STAT_STARTED)) {
+		if (b43_using_pio_transfers(dev))
+			err = b43_pio_tx(dev, skb, ctl);
+		else
+			err = b43_dma_tx(dev, skb, ctl);
+	}
+
+	read_unlock_irqrestore(&wl->tx_lock, flags);
+
 	if (unlikely(err))
 		return NETDEV_TX_BUSY;
 	return NETDEV_TX_OK;
@@ -3476,7 +3490,9 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 	spin_unlock_irqrestore(&wl->irq_lock, flags);
 	b43_synchronize_irq(dev);
 
+	write_lock_irqsave(&wl->tx_lock, flags);
 	b43_set_status(dev, B43_STAT_INITIALIZED);
+	write_unlock_irqrestore(&wl->tx_lock, flags);
 
 	b43_pio_stop(dev);
 	mutex_unlock(&wl->mutex);
@@ -3485,8 +3501,6 @@ static void b43_wireless_core_stop(struct b43_wldev *dev)
 	cancel_delayed_work_sync(&dev->periodic_work);
 	mutex_lock(&wl->mutex);
 
-	ieee80211_stop_queues(wl->hw);	//FIXME this could cause a deadlock, as mac80211 seems buggy.
-
 	b43_mac_suspend(dev);
 	free_irq(dev->dev->irq, dev);
 	b43dbg(wl, "Wireless interface stopped\n");
@@ -4498,6 +4512,7 @@ static int b43_wireless_init(struct ssb_device *dev)
 	memset(wl, 0, sizeof(*wl));
 	wl->hw = hw;
 	spin_lock_init(&wl->irq_lock);
+	rwlock_init(&wl->tx_lock);
 	spin_lock_init(&wl->leds_lock);
 	spin_lock_init(&wl->shm_lock);
 	mutex_init(&wl->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index 45c1c55..c7695a2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -742,7 +742,6 @@ struct iwl3945_priv {
 	u8 direct_ssid_len;
 	u8 direct_ssid[IW_ESSID_MAX_SIZE];
 	struct iwl3945_scan_cmd *scan;
-	u8 only_active_channel;
 
 	/* spinlock */
 	spinlock_t lock;	/* protect general shared data */
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.h b/drivers/net/wireless/iwlwifi/iwl-4965.h
index 9ed13cb..581b985 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.h
@@ -996,7 +996,6 @@ struct iwl_priv {
 	u8 direct_ssid_len;
 	u8 direct_ssid[IW_ESSID_MAX_SIZE];
 	struct iwl4965_scan_cmd *scan;
-	u8 only_active_channel;
 
 	/* spinlock */
 	spinlock_t lock;	/* protect general shared data */
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index a1a0b3c..13925b6 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -4968,17 +4968,6 @@ static int iwl3945_get_channels_for_scan(struct iwl3945_priv *priv,
 		if (channels[i].flags & IEEE80211_CHAN_DISABLED)
 			continue;
 
-		if (channels[i].hw_value ==
-		    le16_to_cpu(priv->active_rxon.channel)) {
-			if (iwl3945_is_associated(priv)) {
-				IWL_DEBUG_SCAN
-				    ("Skipping current channel %d\n",
-				     le16_to_cpu(priv->active_rxon.channel));
-				continue;
-			}
-		} else if (priv->only_active_channel)
-			continue;
-
 		scan_ch->channel = channels[i].hw_value;
 
 		ch_info = iwl3945_get_channel_info(priv, band, scan_ch->channel);
@@ -6303,12 +6292,17 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
 	} else if (!iwl3945_is_associated(priv) && priv->essid_len) {
+		IWL_DEBUG_SCAN
+		  ("Kicking off one direct scan for '%s' when not associated\n",
+		   iwl3945_escape_essid(priv->essid, priv->essid_len));
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
 		direct_mask = 1;
-	} else
+	} else {
+		IWL_DEBUG_SCAN("Kicking off one indirect scan.\n");
 		direct_mask = 0;
+	}
 
 	/* We don't build a direct scan probe request; the uCode will do
 	 * that based on the direct_mask added to each channel entry */
@@ -6346,23 +6340,18 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR)
 		scan->filter_flags = RXON_FILTER_PROMISC_MSK;
 
-	if (direct_mask) {
-		IWL_DEBUG_SCAN
-		    ("Initiating direct scan for %s.\n",
-		     iwl3945_escape_essid(priv->essid, priv->essid_len));
+	if (direct_mask)
 		scan->channel_count =
 			iwl3945_get_channels_for_scan(
 				priv, band, 1, /* active */
 				direct_mask,
 				(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)]);
-	} else {
-		IWL_DEBUG_SCAN("Initiating indirect scan.\n");
+	else
 		scan->channel_count =
 			iwl3945_get_channels_for_scan(
 				priv, band, 0, /* passive */
 				direct_mask,
 				(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)]);
-	}
 
 	cmd.len += le16_to_cpu(scan->tx_cmd.len) +
 	    scan->channel_count * sizeof(struct iwl3945_scan_channel);
@@ -7314,8 +7303,6 @@ static void iwl3945_mac_reset_tsf(struct ieee80211_hw *hw)
 		return;
 	}
 
-	priv->only_active_channel = 0;
-
 	iwl3945_set_rate(priv);
 
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index d0bbcaa..883b42f 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -4633,17 +4633,6 @@ static int iwl4965_get_channels_for_scan(struct iwl_priv *priv,
 		if (channels[i].flags & IEEE80211_CHAN_DISABLED)
 			continue;
 
-		if (ieee80211_frequency_to_channel(channels[i].center_freq) ==
-		    le16_to_cpu(priv->active_rxon.channel)) {
-			if (iwl_is_associated(priv)) {
-				IWL_DEBUG_SCAN
-				    ("Skipping current channel %d\n",
-				     le16_to_cpu(priv->active_rxon.channel));
-				continue;
-			}
-		} else if (priv->only_active_channel)
-			continue;
-
 		scan_ch->channel = ieee80211_frequency_to_channel(channels[i].center_freq);
 
 		ch_info = iwl_get_channel_info(priv, band,
@@ -5824,11 +5813,15 @@ static void iwl4965_bg_request_scan(struct work_struct *data)
 		       priv->direct_ssid, priv->direct_ssid_len);
 		direct_mask = 1;
 	} else if (!iwl_is_associated(priv) && priv->essid_len) {
+		IWL_DEBUG_SCAN
+		  ("Kicking off one direct scan for '%s' when not associated\n",
+		   iwl4965_escape_essid(priv->essid, priv->essid_len));
 		scan->direct_scan[0].id = WLAN_EID_SSID;
 		scan->direct_scan[0].len = priv->essid_len;
 		memcpy(scan->direct_scan[0].ssid, priv->essid, priv->essid_len);
 		direct_mask = 1;
 	} else {
+		IWL_DEBUG_SCAN("Kicking off one indirect scan.\n");
 		direct_mask = 0;
 	}
 
@@ -5881,23 +5874,18 @@ static void iwl4965_bg_request_scan(struct work_struct *data)
 	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR)
 		scan->filter_flags = RXON_FILTER_PROMISC_MSK;
 
-	if (direct_mask) {
-		IWL_DEBUG_SCAN
-		    ("Initiating direct scan for %s.\n",
-		     iwl4965_escape_essid(priv->essid, priv->essid_len));
+	if (direct_mask)
 		scan->channel_count =
 			iwl4965_get_channels_for_scan(
 				priv, band, 1, /* active */
 				direct_mask,
 				(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)]);
-	} else {
-		IWL_DEBUG_SCAN("Initiating indirect scan.\n");
+	else
 		scan->channel_count =
 			iwl4965_get_channels_for_scan(
 				priv, band, 0, /* passive */
 				direct_mask,
 				(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)]);
-	}
 
 	cmd.len += le16_to_cpu(scan->tx_cmd.len) +
 	    scan->channel_count * sizeof(struct iwl4965_scan_channel);
@@ -7061,8 +7049,6 @@ static void iwl4965_mac_reset_tsf(struct ieee80211_hw *hw)
 		return;
 	}
 
-	priv->only_active_channel = 0;
-
 	iwl4965_set_rate(priv);
 
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index b41187a..560b9c7 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -363,7 +363,7 @@ static void rt2400pci_config_erp(struct rt2x00_dev *rt2x00dev,
 	rt2x00pci_register_write(rt2x00dev, TXCSR1, reg);
 
 	rt2x00pci_register_read(rt2x00dev, ARCSR2, &reg);
-	rt2x00_set_field32(&reg, ARCSR2_SIGNAL, 0x00 | preamble_mask);
+	rt2x00_set_field32(&reg, ARCSR2_SIGNAL, 0x00);
 	rt2x00_set_field32(&reg, ARCSR2_SERVICE, 0x04);
 	rt2x00_set_field32(&reg, ARCSR2_LENGTH, get_duration(ACK_SIZE, 10));
 	rt2x00pci_register_write(rt2x00dev, ARCSR2, reg);
@@ -1308,7 +1308,7 @@ static int rt2400pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 
 	if (value == LED_MODE_TXRX_ACTIVITY) {
 		rt2x00dev->led_qual.rt2x00dev = rt2x00dev;
-		rt2x00dev->led_radio.type = LED_TYPE_ACTIVITY;
+		rt2x00dev->led_qual.type = LED_TYPE_ACTIVITY;
 		rt2x00dev->led_qual.led_dev.brightness_set =
 		    rt2400pci_brightness_set;
 		rt2x00dev->led_qual.led_dev.blink_set =
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 5ade097..a5ed54b 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -370,7 +370,7 @@ static void rt2500pci_config_erp(struct rt2x00_dev *rt2x00dev,
 	rt2x00pci_register_write(rt2x00dev, TXCSR1, reg);
 
 	rt2x00pci_register_read(rt2x00dev, ARCSR2, &reg);
-	rt2x00_set_field32(&reg, ARCSR2_SIGNAL, 0x00 | preamble_mask);
+	rt2x00_set_field32(&reg, ARCSR2_SIGNAL, 0x00);
 	rt2x00_set_field32(&reg, ARCSR2_SERVICE, 0x04);
 	rt2x00_set_field32(&reg, ARCSR2_LENGTH, get_duration(ACK_SIZE, 10));
 	rt2x00pci_register_write(rt2x00dev, ARCSR2, reg);
@@ -1485,7 +1485,7 @@ static int rt2500pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 
 	if (value == LED_MODE_TXRX_ACTIVITY) {
 		rt2x00dev->led_qual.rt2x00dev = rt2x00dev;
-		rt2x00dev->led_radio.type = LED_TYPE_ACTIVITY;
+		rt2x00dev->led_qual.type = LED_TYPE_ACTIVITY;
 		rt2x00dev->led_qual.led_dev.brightness_set =
 		    rt2500pci_brightness_set;
 		rt2x00dev->led_qual.led_dev.blink_set =
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 6bb07b3..fdbd0ef 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1394,7 +1394,7 @@ static int rt2500usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 
 	if (value == LED_MODE_TXRX_ACTIVITY) {
 		rt2x00dev->led_qual.rt2x00dev = rt2x00dev;
-		rt2x00dev->led_radio.type = LED_TYPE_ACTIVITY;
+		rt2x00dev->led_qual.type = LED_TYPE_ACTIVITY;
 		rt2x00dev->led_qual.led_dev.brightness_set =
 		    rt2500usb_brightness_set;
 		rt2x00dev->led_qual.led_dev.blink_set =
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index f8fe7a1..8d8657f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -114,6 +114,7 @@ int rt2x00lib_enable_radio(struct rt2x00_dev *rt2x00dev)
 		return status;
 
 	rt2x00leds_led_radio(rt2x00dev, true);
+	rt2x00led_led_activity(rt2x00dev, true);
 
 	__set_bit(DEVICE_ENABLED_RADIO, &rt2x00dev->flags);
 
@@ -157,6 +158,7 @@ void rt2x00lib_disable_radio(struct rt2x00_dev *rt2x00dev)
 	 * Disable radio.
 	 */
 	rt2x00dev->ops->lib->set_device_state(rt2x00dev, STATE_RADIO_OFF);
+	rt2x00led_led_activity(rt2x00dev, false);
 	rt2x00leds_led_radio(rt2x00dev, false);
 }
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00leds.c b/drivers/net/wireless/rt2x00/rt2x00leds.c
index 40c1f5c..b362a1c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00leds.c
+++ b/drivers/net/wireless/rt2x00/rt2x00leds.c
@@ -72,6 +72,21 @@ void rt2x00leds_led_quality(struct rt2x00_dev *rt2x00dev, int rssi)
 	}
 }
 
+void rt2x00led_led_activity(struct rt2x00_dev *rt2x00dev, bool enabled)
+{
+	struct rt2x00_led *led = &rt2x00dev->led_qual;
+	unsigned int brightness;
+
+	if ((led->type != LED_TYPE_ACTIVITY) || !(led->flags & LED_REGISTERED))
+		return;
+
+	brightness = enabled ? LED_FULL : LED_OFF;
+	if (brightness != led->led_dev.brightness) {
+		led->led_dev.brightness_set(&led->led_dev, brightness);
+		led->led_dev.brightness = brightness;
+	}
+}
+
 void rt2x00leds_led_assoc(struct rt2x00_dev *rt2x00dev, bool enabled)
 {
 	struct rt2x00_led *led = &rt2x00dev->led_assoc;
diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 5be32ff..41ee02c 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -185,6 +185,7 @@ static inline void rt2x00rfkill_resume(struct rt2x00_dev *rt2x00dev)
  */
 #ifdef CONFIG_RT2X00_LIB_LEDS
 void rt2x00leds_led_quality(struct rt2x00_dev *rt2x00dev, int rssi);
+void rt2x00led_led_activity(struct rt2x00_dev *rt2x00dev, bool enabled);
 void rt2x00leds_led_assoc(struct rt2x00_dev *rt2x00dev, bool enabled);
 void rt2x00leds_led_radio(struct rt2x00_dev *rt2x00dev, bool enabled);
 void rt2x00leds_register(struct rt2x00_dev *rt2x00dev);
@@ -197,6 +198,11 @@ static inline void rt2x00leds_led_quality(struct rt2x00_dev *rt2x00dev,
 {
 }
 
+static inline void rt2x00led_led_activity(struct rt2x00_dev *rt2x00dev,
+					  bool enabled)
+{
+}
+
 static inline void rt2x00leds_led_assoc(struct rt2x00_dev *rt2x00dev,
 					bool enabled)
 {
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 468a31c..ae12dcd 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2087,7 +2087,7 @@ static int rt61pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 
 	if (value == LED_MODE_SIGNAL_STRENGTH) {
 		rt2x00dev->led_qual.rt2x00dev = rt2x00dev;
-		rt2x00dev->led_radio.type = LED_TYPE_QUALITY;
+		rt2x00dev->led_qual.type = LED_TYPE_QUALITY;
 		rt2x00dev->led_qual.led_dev.brightness_set =
 		    rt61pci_brightness_set;
 		rt2x00dev->led_qual.led_dev.blink_set =
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index a9efe25..da19a3a 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1647,7 +1647,7 @@ static int rt73usb_init_eeprom(struct rt2x00_dev *rt2x00dev)
 
 	if (value == LED_MODE_SIGNAL_STRENGTH) {
 		rt2x00dev->led_qual.rt2x00dev = rt2x00dev;
-		rt2x00dev->led_radio.type = LED_TYPE_QUALITY;
+		rt2x00dev->led_qual.type = LED_TYPE_QUALITY;
 		rt2x00dev->led_qual.led_dev.brightness_set =
 		    rt73usb_brightness_set;
 		rt2x00dev->led_qual.led_dev.blink_set =
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 2864b16..0a9b5b4 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -69,14 +69,9 @@
 
 /***************************** INCLUDES *****************************/
 
-/* This header is used in user-space, therefore need to be sanitised
- * for that purpose. Those includes are usually not compatible with glibc.
- * To know which includes to use in user-space, check iwlib.h. */
-#ifdef __KERNEL__
-#include <linux/types.h>		/* for "caddr_t" et al		*/
+#include <linux/types.h>		/* for __u* and __s* typedefs */
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/if.h>			/* for IFNAMSIZ and co... */
-#endif	/* __KERNEL__ */
 
 /***************************** VERSION *****************************/
 /*
-- 
John W. Linville
linville@tuxdriver.com
