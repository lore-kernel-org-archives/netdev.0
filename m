From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-06-25
Date: Wed, 25 Jun 2008 11:36:24 -0400
Message-ID: <20080625153624.GB9111@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4954 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755318AbYFYPrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 11:47:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest round of wireless fixes for 2.6.26.

The EU regulatory domain patch is straight-forward and should not
affect anyone who doesn't choose to use it.  It is already queued in
net-next-2.6, but upon reflection I think it makes sense to include
it as a fix.  I don't think git will choke on it at all.

The iwlwifi patch is physically bigger than I would like to see at this
point of the release, but it is isolated to the iwlwifi drivers and
it should avoid problems with some cards trying to scan on channels
they don't actually support.

The rt2x00 patch seems a bit bigger than it really is, as it moves
and consolidates some existing code.

The b43 and b43legacy are all basically straight-forward bugfixes.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6

---

The following changes since commit 88a6f4ad76be425f47df7f892baf913bcd466fb3:
  Patrick McHardy (1):
        netfilter: ip6table_mangle: don't reroute in LOCAL_IN

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Ivo van Doorn (1):
      rt2x00: Fix unbalanced mutex locking

Michael Buesch (4):
      b43: Do not return TX_BUSY from op_tx
      b43legacy: Do not return TX_BUSY from op_tx
      b43: Fix possible MMIO access while device is down
      b43legacy: Fix possible NULL pointer dereference in DMA code

Ron Rindjunsky (1):
      iwlwifi: improve scanning band selection management

Tony Vroon (1):
      mac80211: implement EU regulatory domain

 drivers/net/wireless/b43/leds.c             |    3 ++
 drivers/net/wireless/b43/main.c             |   12 +++++---
 drivers/net/wireless/b43legacy/dma.c        |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    6 +++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   33 ++++++++++++----------
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   39 ++++++++++++++------------
 drivers/net/wireless/rt2x00/rt2500usb.c     |   36 ++++++++++++++----------
 drivers/net/wireless/rt2x00/rt73usb.c       |   36 ++++++++++++++----------
 net/wireless/reg.c                          |   18 ++++++++++++
 9 files changed, 115 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/b43/leds.c b/drivers/net/wireless/b43/leds.c
index 36a9c42..76f4c7b 100644
--- a/drivers/net/wireless/b43/leds.c
+++ b/drivers/net/wireless/b43/leds.c
@@ -72,6 +72,9 @@ static void b43_led_brightness_set(struct led_classdev *led_dev,
 	struct b43_wldev *dev = led->dev;
 	bool radio_enabled;
 
+	if (unlikely(b43_status(dev) < B43_STAT_INITIALIZED))
+		return;
+
 	/* Checking the radio-enabled status here is slightly racy,
 	 * but we want to avoid the locking overhead and we don't care
 	 * whether the LED has the wrong state for a second. */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index fa4b0d8..a708277 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2883,12 +2883,11 @@ static int b43_op_tx(struct ieee80211_hw *hw,
 
 	if (unlikely(skb->len < 2 + 2 + 6)) {
 		/* Too short, this can't be a valid frame. */
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		goto drop_packet;
 	}
 	B43_WARN_ON(skb_shinfo(skb)->nr_frags);
 	if (unlikely(!dev))
-		return NETDEV_TX_BUSY;
+		goto drop_packet;
 
 	/* Transmissions on seperate queues can run concurrently. */
 	read_lock_irqsave(&wl->tx_lock, flags);
@@ -2904,7 +2903,12 @@ static int b43_op_tx(struct ieee80211_hw *hw,
 	read_unlock_irqrestore(&wl->tx_lock, flags);
 
 	if (unlikely(err))
-		return NETDEV_TX_BUSY;
+		goto drop_packet;
+	return NETDEV_TX_OK;
+
+drop_packet:
+	/* We can not transmit this packet. Drop it. */
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index c990f87..93ddc1c 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -876,6 +876,7 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 	if (!ring)
 		goto out;
 	ring->type = type;
+	ring->dev = dev;
 
 	nr_slots = B43legacy_RXRING_SLOTS;
 	if (for_tx)
@@ -922,7 +923,6 @@ struct b43legacy_dmaring *b43legacy_setup_dmaring(struct b43legacy_wldev *dev,
 				 DMA_TO_DEVICE);
 	}
 
-	ring->dev = dev;
 	ring->nr_slots = nr_slots;
 	ring->mmio_base = b43legacy_dmacontroller_base(type, controller_index);
 	ring->index = controller_index;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 204077c..3e612d0 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2378,8 +2378,10 @@ static int b43legacy_op_tx(struct ieee80211_hw *hw,
 	} else
 		err = b43legacy_dma_tx(dev, skb, ctl);
 out:
-	if (unlikely(err))
-		return NETDEV_TX_BUSY;
+	if (unlikely(err)) {
+		/* Drop the packet. */
+		dev_kfree_skb_any(skb);
+	}
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 13925b6..b1b3c52 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2227,7 +2227,10 @@ static int iwl3945_scan_initiate(struct iwl3945_priv *priv)
 	}
 
 	IWL_DEBUG_INFO("Starting scan...\n");
-	priv->scan_bands = 2;
+	if (priv->cfg->sku & IWL_SKU_G)
+		priv->scan_bands |= BIT(IEEE80211_BAND_2GHZ);
+	if (priv->cfg->sku & IWL_SKU_A)
+		priv->scan_bands |= BIT(IEEE80211_BAND_5GHZ);
 	set_bit(STATUS_SCANNING, &priv->status);
 	priv->scan_start = jiffies;
 	priv->scan_pass_start = priv->scan_start;
@@ -3352,13 +3355,18 @@ static void iwl3945_rx_scan_complete_notif(struct iwl3945_priv *priv,
 	cancel_delayed_work(&priv->scan_check);
 
 	IWL_DEBUG_INFO("Scan pass on %sGHz took %dms\n",
-		       (priv->scan_bands == 2) ? "2.4" : "5.2",
+		       (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ)) ?
+							"2.4" : "5.2",
 		       jiffies_to_msecs(elapsed_jiffies
 					(priv->scan_pass_start, jiffies)));
 
-	/* Remove this scanned band from the list
-	 * of pending bands to scan */
-	priv->scan_bands--;
+	/* Remove this scanned band from the list of pending
+	 * bands to scan, band G precedes A in order of scanning
+	 * as seen in iwl3945_bg_request_scan */
+	if (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ))
+		priv->scan_bands &= ~BIT(IEEE80211_BAND_2GHZ);
+	else if (priv->scan_bands &  BIT(IEEE80211_BAND_5GHZ))
+		priv->scan_bands &= ~BIT(IEEE80211_BAND_5GHZ);
 
 	/* If a request to abort was given, or the scan did not succeed
 	 * then we reset the scan state machine and terminate,
@@ -4972,7 +4980,7 @@ static int iwl3945_get_channels_for_scan(struct iwl3945_priv *priv,
 
 		ch_info = iwl3945_get_channel_info(priv, band, scan_ch->channel);
 		if (!is_channel_valid(ch_info)) {
-			IWL_DEBUG_SCAN("Channel %d is INVALID for this SKU.\n",
+			IWL_DEBUG_SCAN("Channel %d is INVALID for this band.\n",
 				       scan_ch->channel);
 			continue;
 		}
@@ -6315,21 +6323,16 @@ static void iwl3945_bg_request_scan(struct work_struct *data)
 
 	/* flags + rate selection */
 
-	switch (priv->scan_bands) {
-	case 2:
+	if (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ)) {
 		scan->flags = RXON_FLG_BAND_24G_MSK | RXON_FLG_AUTO_DETECT_MSK;
 		scan->tx_cmd.rate = IWL_RATE_1M_PLCP;
 		scan->good_CRC_th = 0;
 		band = IEEE80211_BAND_2GHZ;
-		break;
-
-	case 1:
+	} else if (priv->scan_bands & BIT(IEEE80211_BAND_5GHZ)) {
 		scan->tx_cmd.rate = IWL_RATE_6M_PLCP;
 		scan->good_CRC_th = IWL_GOOD_CRC_TH;
 		band = IEEE80211_BAND_5GHZ;
-		break;
-
-	default:
+	} else {
 		IWL_WARNING("Invalid scan band count\n");
 		goto done;
 	}
@@ -6770,7 +6773,7 @@ static int iwl3945_mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *co
 	ch_info = iwl3945_get_channel_info(priv, conf->channel->band,
 					   conf->channel->hw_value);
 	if (!is_channel_valid(ch_info)) {
-		IWL_DEBUG_SCAN("Channel %d [%d] is INVALID for this SKU.\n",
+		IWL_DEBUG_SCAN("Channel %d [%d] is INVALID for this band.\n",
 			       conf->channel->hw_value, conf->channel->band);
 		IWL_DEBUG_MAC80211("leave - invalid channel\n");
 		spin_unlock_irqrestore(&priv->lock, flags);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 883b42f..5ed16ce 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -1774,7 +1774,10 @@ static int iwl4965_scan_initiate(struct iwl_priv *priv)
 	}
 
 	IWL_DEBUG_INFO("Starting scan...\n");
-	priv->scan_bands = 2;
+	if (priv->cfg->sku & IWL_SKU_G)
+		priv->scan_bands |= BIT(IEEE80211_BAND_2GHZ);
+	if (priv->cfg->sku & IWL_SKU_A)
+		priv->scan_bands |= BIT(IEEE80211_BAND_5GHZ);
 	set_bit(STATUS_SCANNING, &priv->status);
 	priv->scan_start = jiffies;
 	priv->scan_pass_start = priv->scan_start;
@@ -3023,8 +3026,9 @@ static void iwl4965_rx_reply_tx(struct iwl_priv *priv,
 
 	IWL_DEBUG_TX_REPLY("Tx queue reclaim %d\n", index);
 	if (index != -1) {
-		int freed = iwl4965_tx_queue_reclaim(priv, txq_id, index);
 #ifdef CONFIG_IWL4965_HT
+		int freed = iwl4965_tx_queue_reclaim(priv, txq_id, index);
+
 		if (tid != MAX_TID_COUNT)
 			priv->stations[sta_id].tid[tid].tfds_in_queue -= freed;
 		if (iwl4965_queue_space(&txq->q) > txq->q.low_mark &&
@@ -3276,13 +3280,18 @@ static void iwl4965_rx_scan_complete_notif(struct iwl_priv *priv,
 	cancel_delayed_work(&priv->scan_check);
 
 	IWL_DEBUG_INFO("Scan pass on %sGHz took %dms\n",
-		       (priv->scan_bands == 2) ? "2.4" : "5.2",
+		       (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ)) ?
+						"2.4" : "5.2",
 		       jiffies_to_msecs(elapsed_jiffies
 					(priv->scan_pass_start, jiffies)));
 
-	/* Remove this scanned band from the list
-	 * of pending bands to scan */
-	priv->scan_bands--;
+	/* Remove this scanned band from the list of pending
+	 * bands to scan, band G precedes A in order of scanning
+	 * as seen in iwl_bg_request_scan */
+	if (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ))
+		priv->scan_bands &= ~BIT(IEEE80211_BAND_2GHZ);
+	else if (priv->scan_bands &  BIT(IEEE80211_BAND_5GHZ))
+		priv->scan_bands &= ~BIT(IEEE80211_BAND_5GHZ);
 
 	/* If a request to abort was given, or the scan did not succeed
 	 * then we reset the scan state machine and terminate,
@@ -3292,7 +3301,7 @@ static void iwl4965_rx_scan_complete_notif(struct iwl_priv *priv,
 		clear_bit(STATUS_SCAN_ABORTING, &priv->status);
 	} else {
 		/* If there are more bands on this scan pass reschedule */
-		if (priv->scan_bands > 0)
+		if (priv->scan_bands)
 			goto reschedule;
 	}
 
@@ -4635,10 +4644,9 @@ static int iwl4965_get_channels_for_scan(struct iwl_priv *priv,
 
 		scan_ch->channel = ieee80211_frequency_to_channel(channels[i].center_freq);
 
-		ch_info = iwl_get_channel_info(priv, band,
-					 scan_ch->channel);
+		ch_info = iwl_get_channel_info(priv, band, scan_ch->channel);
 		if (!is_channel_valid(ch_info)) {
-			IWL_DEBUG_SCAN("Channel %d is INVALID for this SKU.\n",
+			IWL_DEBUG_SCAN("Channel %d is INVALID for this band.\n",
 				       scan_ch->channel);
 			continue;
 		}
@@ -5830,8 +5838,7 @@ static void iwl4965_bg_request_scan(struct work_struct *data)
 	scan->tx_cmd.stop_time.life_time = TX_CMD_LIFE_TIME_INFINITE;
 
 
-	switch (priv->scan_bands) {
-	case 2:
+	if (priv->scan_bands & BIT(IEEE80211_BAND_2GHZ)) {
 		scan->flags = RXON_FLG_BAND_24G_MSK | RXON_FLG_AUTO_DETECT_MSK;
 		scan->tx_cmd.rate_n_flags =
 				iwl4965_hw_set_rate_n_flags(IWL_RATE_1M_PLCP,
@@ -5839,17 +5846,13 @@ static void iwl4965_bg_request_scan(struct work_struct *data)
 
 		scan->good_CRC_th = 0;
 		band = IEEE80211_BAND_2GHZ;
-		break;
-
-	case 1:
+	} else if (priv->scan_bands & BIT(IEEE80211_BAND_5GHZ)) {
 		scan->tx_cmd.rate_n_flags =
 				iwl4965_hw_set_rate_n_flags(IWL_RATE_6M_PLCP,
 				RATE_MCS_ANT_B_MSK);
 		scan->good_CRC_th = IWL_GOOD_CRC_TH;
 		band = IEEE80211_BAND_5GHZ;
-		break;
-
-	default:
+	} else {
 		IWL_WARNING("Invalid scan band count\n");
 		goto done;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index fdbd0ef..61e59c1 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -138,11 +138,8 @@ static void rt2500usb_bbp_write(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt2500usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR8 register busy. Write failed.\n");
-		mutex_unlock(&rt2x00dev->usb_cache_mutex);
-		return;
-	}
+	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY))
+		goto exit_fail;
 
 	/*
 	 * Write the data into the BBP.
@@ -155,6 +152,13 @@ static void rt2500usb_bbp_write(struct rt2x00_dev *rt2x00dev,
 	rt2500usb_register_write_lock(rt2x00dev, PHY_CSR7, reg);
 
 	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	return;
+
+exit_fail:
+	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	ERROR(rt2x00dev, "PHY_CSR8 register busy. Write failed.\n");
 }
 
 static void rt2500usb_bbp_read(struct rt2x00_dev *rt2x00dev,
@@ -168,10 +172,8 @@ static void rt2500usb_bbp_read(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt2500usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR8 register busy. Read failed.\n");
-		return;
-	}
+	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY))
+		goto exit_fail;
 
 	/*
 	 * Write the request into the BBP.
@@ -186,17 +188,21 @@ static void rt2500usb_bbp_read(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt2500usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR8 register busy. Read failed.\n");
-		*value = 0xff;
-		mutex_unlock(&rt2x00dev->usb_cache_mutex);
-		return;
-	}
+	if (rt2x00_get_field16(reg, PHY_CSR8_BUSY))
+		goto exit_fail;
 
 	rt2500usb_register_read_lock(rt2x00dev, PHY_CSR7, &reg);
 	*value = rt2x00_get_field16(reg, PHY_CSR7_DATA);
 
 	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	return;
+
+exit_fail:
+	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	ERROR(rt2x00dev, "PHY_CSR8 register busy. Read failed.\n");
+	*value = 0xff;
 }
 
 static void rt2500usb_rf_write(struct rt2x00_dev *rt2x00dev,
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index fff8386..83cc014 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -134,11 +134,8 @@ static void rt73usb_bbp_write(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt73usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR3 register busy. Write failed.\n");
-		mutex_unlock(&rt2x00dev->usb_cache_mutex);
-		return;
-	}
+	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY))
+		goto exit_fail;
 
 	/*
 	 * Write the data into the BBP.
@@ -151,6 +148,13 @@ static void rt73usb_bbp_write(struct rt2x00_dev *rt2x00dev,
 
 	rt73usb_register_write_lock(rt2x00dev, PHY_CSR3, reg);
 	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	return;
+
+exit_fail:
+	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	ERROR(rt2x00dev, "PHY_CSR3 register busy. Write failed.\n");
 }
 
 static void rt73usb_bbp_read(struct rt2x00_dev *rt2x00dev,
@@ -164,11 +168,8 @@ static void rt73usb_bbp_read(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt73usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR3 register busy. Read failed.\n");
-		mutex_unlock(&rt2x00dev->usb_cache_mutex);
-		return;
-	}
+	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY))
+		goto exit_fail;
 
 	/*
 	 * Write the request into the BBP.
@@ -184,14 +185,19 @@ static void rt73usb_bbp_read(struct rt2x00_dev *rt2x00dev,
 	 * Wait until the BBP becomes ready.
 	 */
 	reg = rt73usb_bbp_check(rt2x00dev);
-	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY)) {
-		ERROR(rt2x00dev, "PHY_CSR3 register busy. Read failed.\n");
-		*value = 0xff;
-		return;
-	}
+	if (rt2x00_get_field32(reg, PHY_CSR3_BUSY))
+		goto exit_fail;
 
 	*value = rt2x00_get_field32(reg, PHY_CSR3_VALUE);
 	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	return;
+
+exit_fail:
+	mutex_unlock(&rt2x00dev->usb_cache_mutex);
+
+	ERROR(rt2x00dev, "PHY_CSR3 register busy. Read failed.\n");
+	*value = 0xff;
 }
 
 static void rt73usb_rf_write(struct rt2x00_dev *rt2x00dev,
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 185488d..855bff4 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -80,6 +80,23 @@ static const struct ieee80211_channel_range ieee80211_JP_channels[] = {
 				     IEEE80211_CHAN_RADAR),
 };
 
+static const struct ieee80211_channel_range ieee80211_EU_channels[] = {
+	/* IEEE 802.11b/g, channels 1..13 */
+	RANGE_PWR(2412, 2472, 20, 6, 0),
+	/* IEEE 802.11a, channel 36*/
+	RANGE_PWR(5180, 5180, 23, 6, IEEE80211_CHAN_PASSIVE_SCAN),
+	/* IEEE 802.11a, channel 40*/
+	RANGE_PWR(5200, 5200, 23, 6, IEEE80211_CHAN_PASSIVE_SCAN),
+	/* IEEE 802.11a, channel 44*/
+	RANGE_PWR(5220, 5220, 23, 6, IEEE80211_CHAN_PASSIVE_SCAN),
+	/* IEEE 802.11a, channels 48..64 */
+	RANGE_PWR(5240, 5320, 23, 6, IEEE80211_CHAN_NO_IBSS |
+				     IEEE80211_CHAN_RADAR),
+	/* IEEE 802.11a, channels 100..140 */
+	RANGE_PWR(5500, 5700, 30, 6, IEEE80211_CHAN_NO_IBSS |
+				     IEEE80211_CHAN_RADAR),
+};
+
 #define REGDOM(_code)							\
 	{								\
 		.code = __stringify(_code),				\
@@ -90,6 +107,7 @@ static const struct ieee80211_channel_range ieee80211_JP_channels[] = {
 static const struct ieee80211_regdomain ieee80211_regdoms[] = {
 	REGDOM(US),
 	REGDOM(JP),
+	REGDOM(EU),
 };
 
 
-- 
John W. Linville
linville@tuxdriver.com
