From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 24/26] rt2x00: Misc. fixes
Date: Sun, 3 Dec 2006 19:18:56 +0100
Message-ID: <200612031918.56659.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758790AbWLCSTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:14 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:13 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Misc fixes.

* Correctly set the RFCSR value using the setfield function.
* Remove the DISABLE_RX register setting during initialization.
* Changing the durationid should not add but overwrite. (sparse fix)
* Prevent false warnings about ignoring ring initialization,
  by only mentioning which rings have been initialized.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:21:22.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:48:37.000000000 +0100
@@ -188,7 +188,8 @@
 	return;
 
 rf_write:
-	reg = value;
+	reg = 0;
+	rt2x00_set_field32(&reg, RFCSR_VALUE, value);
 	rt2x00_set_field32(&reg, RFCSR_NUMBER_OF_BITS, 20);
 	rt2x00_set_field32(&reg, RFCSR_IF_SELECT, 0);
 	rt2x00_set_field32(&reg, RFCSR_BUSY, 1);
@@ -882,7 +883,6 @@
 		rt2x00_desc_read(rxd, 0, &word);
 		rt2x00_set_field32(&word, RXD_W0_OWNER_NIC, 1);
 		rt2x00_desc_write(rxd, 0, word);
-
 	}
 
 	rt2x00_ring_index_clear(ring);
@@ -1011,10 +1011,6 @@
 
 	rt2x00_register_write(rt2x00dev, CNT3, 0x3f080000);
 
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
 	rt2x00_register_write(rt2x00dev, MACCSR0, 0x00217223);
 	rt2x00_register_write(rt2x00dev, MACCSR1, 0x00235518);
 
@@ -1372,7 +1368,7 @@
 	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
-	ieee80211hdr->duration_id += cpu_to_le16(duration);
+	ieee80211hdr->duration_id = cpu_to_le16(duration);
 
 	ieee80211hdr->seq_ctrl = 0;
 
@@ -1984,7 +1980,7 @@
 	rt2400pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2400pci_config_antenna(rt2x00dev, conf->antenna_sel);
 	rt2400pci_config_duration(rt2x00dev,
-				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
+		(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME));
 	rt2400pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2127,7 +2123,7 @@
 	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
-	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
+	rt2x00dev->scan = kzalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00dev->scan)
 		return -ENOMEM;
 
@@ -2206,10 +2202,8 @@
 	 * per queue. So by default we only configure the TX queue,
 	 * and ignore all other configurations.
 	 */
-	if (queue != IEEE80211_TX_QUEUE_DATA0) {
-		NOTICE("Ignoring configuration for queue %d.\n", queue);
+	if (queue != IEEE80211_TX_QUEUE_DATA0)
 		return -EINVAL;
-	}
 
 	memcpy(&ring->tx_params, params, sizeof(*params));
 
@@ -2232,6 +2226,9 @@
 	 */
 	rt2400pci_config_cw(rt2x00dev, &ring->tx_params);
 
+	INFO("Configured TX ring %d - CWmin: %d, CWmax: %d.\n",
+		queue, ring->tx_params.cw_min, ring->tx_params.cw_max);
+
 	return 0;
 }
 
@@ -2267,10 +2264,9 @@
 static void rt2400pci_reset_tsf(struct ieee80211_hw *hw)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	u32 reg = 0;
 
-	rt2x00_register_write(rt2x00dev, CSR16, reg);
-	rt2x00_register_write(rt2x00dev, CSR17, reg);
+	rt2x00_register_write(rt2x00dev, CSR16, 0);
+	rt2x00_register_write(rt2x00dev, CSR17, 0);
 }
 
 static int rt2400pci_beacon_update(struct ieee80211_hw *hw,
@@ -2293,6 +2289,9 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
+	/*
+	 * Update the beacon entry.
+	 */
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, rt2x00_desc_addr(entry),
 		skb, control);
@@ -2470,7 +2469,7 @@
 	/*
 	 * Check if the BBP tuning should be enabled.
 	 */
-	if (!rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RX_AGCVGC))
+	if (!rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RX_AGCVGC_TUNING))
 		SET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING);
 
 	return 0;
@@ -2713,6 +2712,9 @@
 	rt2x00dev->dev = pci_dev;
 	rt2x00dev->hw = hw;
 
+	/*
+	 * Allocate the CSR memory.
+	 */
 	rt2x00dev->csr_addr = ioremap(
 		pci_resource_start(rt2x00dev_pci(rt2x00dev), 0),
 		pci_resource_len(rt2x00dev_pci(rt2x00dev), 0));
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 15:08:03.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-12-03 15:33:27.000000000 +0100
@@ -738,7 +738,7 @@
 #define EEPROM_ANTENNA_RX_DEFAULT	FIELD16(0x0030)
 #define EEPROM_ANTENNA_RF_TYPE		FIELD16(0x0040)
 #define EEPROM_ANTENNA_LED_MODE		FIELD16(0x0180)
-#define EEPROM_ANTENNA_RX_AGCVGC	FIELD16(0x0200)
+#define EEPROM_ANTENNA_RX_AGCVGC_TUNING	FIELD16(0x0200)
 #define EEPROM_ANTENNA_HARDWARE_RADIO	FIELD16(0x0400)
 
 /*
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:21:27.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:48:55.000000000 +0100
@@ -188,7 +188,8 @@
 	return;
 
 rf_write:
-	reg = value;
+	reg = 0;
+	rt2x00_set_field32(&reg, RFCSR_VALUE, value);
 	rt2x00_set_field32(&reg, RFCSR_NUMBER_OF_BITS, 20);
 	rt2x00_set_field32(&reg, RFCSR_IF_SELECT, 0);
 	rt2x00_set_field32(&reg, RFCSR_BUSY, 1);
@@ -1094,10 +1095,6 @@
 
 	rt2x00_register_write(rt2x00dev, CNT3, 0);
 
-	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-
 	rt2x00_register_write(rt2x00dev, GPIOCSR, 0x0000ff00);
 	rt2x00_register_write(rt2x00dev, TESTCSR, 0x000000f0);
 
@@ -1497,7 +1494,7 @@
 	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
-	ieee80211hdr->duration_id += cpu_to_le16(duration);
+	ieee80211hdr->duration_id = cpu_to_le16(duration);
 
 	ieee80211hdr->seq_ctrl = 0;
 
@@ -2147,7 +2144,7 @@
 	rt2500pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2500pci_config_antenna(rt2x00dev, conf->antenna_sel);
 	rt2500pci_config_duration(rt2x00dev,
-				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
+		(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME));
 	rt2500pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2286,7 +2283,7 @@
 	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
-	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
+	rt2x00dev->scan = kzalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00dev->scan)
 		return -ENOMEM;
 
@@ -2361,10 +2358,8 @@
 	struct data_ring *ring;
 
 	ring = rt2x00_get_ring(rt2x00dev, queue);
-	if (unlikely(!ring)) {
-		NOTICE("Ignoring configuration for queue %d.\n", queue);
+	if (unlikely(!ring))
 		return -EINVAL;
-	}
 
 	memcpy(&ring->tx_params, params, sizeof(*params));
 
@@ -2385,6 +2380,10 @@
 	if (!params->aifs)
 		ring->tx_params.aifs = 2;
 
+	INFO("Configured TX ring %d - CWmin: %d, CWmax: %d, Aifs: %d.\n",
+		queue, ring->tx_params.cw_min, ring->tx_params.cw_max,
+		ring->tx_params.aifs);
+
 	return 0;
 }
 
@@ -2420,10 +2419,9 @@
 static void rt2500pci_reset_tsf(struct ieee80211_hw *hw)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	u32 reg = 0;
 
-	rt2x00_register_write(rt2x00dev, CSR16, reg);
-	rt2x00_register_write(rt2x00dev, CSR17, reg);
+	rt2x00_register_write(rt2x00dev, CSR16, 0);
+	rt2x00_register_write(rt2x00dev, CSR17, 0);
 }
 
 static int rt2500pci_beacon_update(struct ieee80211_hw *hw,
@@ -2446,6 +2444,9 @@
 	 */
 	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
 
+	/*
+	 * Update the beacon entry.
+	 */
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, rt2x00_desc_addr(entry),
 		skb, control);
@@ -3014,6 +3015,9 @@
 	rt2x00dev->dev = pci_dev;
 	rt2x00dev->hw = hw;
 
+	/*
+	 * Allocate the CSR memory.
+	 */
 	rt2x00dev->csr_addr = ioremap(
 		pci_resource_start(rt2x00dev_pci(rt2x00dev), 0),
 		pci_resource_len(rt2x00dev_pci(rt2x00dev), 0));
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:28:17.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:48:36.000000000 +0100
@@ -217,14 +217,17 @@
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("RFCSR register busy. Write failed.\n");
+	ERROR("PHY_CSR10 register busy. Write failed.\n");
 	return;
 
 rf_write:
-	reg = value & 0x0000ffff;
+	reg = 0;
+	rt2x00_set_field16(&reg, PHY_CSR9_RF_VALUE, value & 0x0000ffff);
 	rt2x00_register_write(rt2x00dev, PHY_CSR9, reg);
 
-	reg = (value >> 16) & 0x0000ffff;
+	reg = 0;
+	rt2x00_set_field16(&reg, PHY_CSR10_RF_VALUE,
+		(value >> 16) & 0x0000ffff);
 	rt2x00_set_field16(&reg, PHY_CSR10_RF_NUMBER_OF_BITS, 20);
 	rt2x00_set_field16(&reg, PHY_CSR10_RF_IF_SELECT, 0);
 	rt2x00_set_field16(&reg, PHY_CSR10_RF_BUSY, 1);
@@ -1456,7 +1459,7 @@
 	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
-	ieee80211hdr->duration_id += cpu_to_le16(duration);
+	ieee80211hdr->duration_id = cpu_to_le16(duration);
 
 	ieee80211hdr->seq_ctrl = 0;
 
@@ -2077,7 +2080,7 @@
 	rt2500usb_config_txpower(rt2x00dev, conf->power_level);
 	rt2500usb_config_antenna(rt2x00dev, conf->antenna_sel);
 	rt2500usb_config_duration(rt2x00dev,
-				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
+		(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME));
 	rt2500usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2218,7 +2221,7 @@
 	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
-	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
+	rt2x00dev->scan = kzalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00dev->scan)
 		return -ENOMEM;
 
@@ -2279,10 +2282,8 @@
 	struct data_ring *ring;
 
 	ring = rt2x00_get_ring(rt2x00dev, queue);
-	if (unlikely(!ring)) {
-		NOTICE("Ignoring configuration for queue %d.\n", queue);
+	if (unlikely(!ring))
 		return -EINVAL;
-	}
 
 	memcpy(&ring->tx_params, params, sizeof(*params));
 
@@ -2303,6 +2304,10 @@
 	if (!params->aifs)
 		ring->tx_params.aifs = 2;
 
+	INFO("Configured TX ring %d - CWmin: %d, CWmax: %d, Aifs: %d.\n",
+		queue, ring->tx_params.cw_min, ring->tx_params.cw_max,
+		ring->tx_params.aifs);
+
 	return 0;
 }
 
@@ -2338,6 +2343,9 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
+	/*
+	 * Update the beacon entry.
+	 */
 	memcpy(rt2x00_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev,
 		rt2x00_txdesc_addr(entry), skb, control);
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 14:13:46.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 15:44:04.000000000 +0100
@@ -419,7 +419,7 @@
 struct rt2x00_chip {
 	u16 rt;
 	u16 rf;
-	u16 rev;
+	u32 rev;
 	u8 fw_h;
 	u8 fw_l;
 };
@@ -428,9 +428,9 @@
  * Set chipset data.
  */
 static inline void rt2x00_set_chip(struct rt2x00_chip *chipset,
-	const u16 rt, const u16 rf, const u16 rev)
+	const u16 rt, const u16 rf, const u32 rev)
 {
-	INFO("Chipset detected - rt: %04x, rf: %04x, rev: %04x.\n",
+	INFO("Chipset detected - rt: %04x, rf: %04x, rev: %08x.\n",
 		rt, rf, rev);
 
 	chipset->rt = rt;
@@ -1065,6 +1065,7 @@
 			stats->dot11RTSFailureCount++;
 	}
 }
+
 /*
  * Device specific rate value.
  * We will have to create the device specific rate value
@@ -1207,7 +1208,7 @@
 	 * Set the sequence number for this frame,
 	 * but do not change the fragment number.
 	 */
-	ieee80211hdr->seq_ctrl |= cpu_to_le16((*seq << 4) & 0xfff0);
+	ieee80211hdr->seq_ctrl |= cpu_to_le16(*seq & IEEE80211_SCTL_SEQ);
 
 	/*
 	 * Since the dscape stack sends all packets and
@@ -1217,7 +1218,7 @@
 	 * counter should be increased.
 	 */
 	if (!ieee80211_get_morefrag(ieee80211hdr))
-		*seq = (*seq + 1) & 0x0fff;
+		*seq = (*seq + 0x10) & IEEE80211_SCTL_SEQ;
 }
 
 /*
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:21:35.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:48:35.000000000 +0100
@@ -191,11 +191,12 @@
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("RFCSR register busy. Write failed.\n");
+	ERROR("PHY_CSR4 register busy. Write failed.\n");
 	return;
 
 rf_write:
-	reg = value;
+	reg = 0;
+	rt2x00_set_field32(&reg, PHY_CSR4_VALUE, value);
 	rt2x00_set_field32(&reg, PHY_CSR4_NUMBER_OF_BITS, 21);
 	rt2x00_set_field32(&reg, PHY_CSR4_IF_SELECT, 0);
 	rt2x00_set_field32(&reg, PHY_CSR4_BUSY, 1);
@@ -288,6 +289,7 @@
 	 * We only need to set the BSS ID MASK at the correct offset.
 	 */
 	memcpy(&reg, bssid, ETH_ALEN);
+	rt2x00_set_field32(&reg[1], MAC_CSR5_BSS_ID_MASK, 3);
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR4, &reg[0], sizeof(reg));
 }
 
@@ -1088,7 +1090,6 @@
 		rt2x00_register_write(rt2x00dev, SOFT_RESET_CSR, 0x00000005);
 		rt2x00_register_write(rt2x00dev, IO_CNTL_CSR, 0x0000001c);
 		rt2x00_register_write(rt2x00dev, PCI_USEC_CSR, 0x00000060);
-
 		rt2x00_mcu_request(rt2x00dev, MCU_SLEEP, 0xff, 0x00, 0x00);
 	} else {
 		rt2x00_register_write(rt2x00dev, SOFT_RESET_CSR, 0x00000007);
@@ -1941,7 +1942,7 @@
 	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
-	ieee80211hdr->duration_id += cpu_to_le16(duration);
+	ieee80211hdr->duration_id = cpu_to_le16(duration);
 
 	ieee80211hdr->seq_ctrl = 0;
 
@@ -2235,8 +2236,6 @@
 	    !rt2x00_get_field32(word, TXD_W0_VALID))
 		return;
 
-	ack = rt2x00_get_field32(word, TXD_W0_ACK);
-
 	entry->tx_status.flags = 0;
 	entry->tx_status.queue_length = entry->ring->stats.limit;
 	entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -2641,7 +2640,7 @@
 	rt61pci_config_txpower(rt2x00dev, conf->power_level);
 	rt61pci_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
 	rt61pci_config_duration(rt2x00dev,
-				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
+		(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME));
 	rt61pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2780,7 +2779,7 @@
 	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
-	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
+	rt2x00dev->scan = kzalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00dev->scan)
 		return -ENOMEM;
 
@@ -2855,10 +2854,8 @@
 	struct data_ring *ring;
 
 	ring = rt2x00_get_ring(rt2x00dev, queue);
-	if (unlikely(!ring)) {
-		NOTICE("Ignoring configuration for queue %d.\n", queue);
+	if (unlikely(!ring))
 		return -EINVAL;
-	}
 
 	memcpy(&ring->tx_params, params, sizeof(*params));
 
@@ -2879,6 +2876,10 @@
 	if (!params->aifs)
 		ring->tx_params.aifs = 2;
 
+	INFO("Configured TX ring %d - CWmin: %d, CWmax: %d, Aifs: %d.\n",
+		queue, ring->tx_params.cw_min, ring->tx_params.cw_max,
+		ring->tx_params.aifs);
+
 	return 0;
 }
 
@@ -2923,10 +2924,9 @@
 static void rt61pci_reset_tsf(struct ieee80211_hw *hw)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	u32 reg = 0;
 
-	rt2x00_register_write(rt2x00dev, TXRX_CSR12, reg);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR13, reg);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR12, 0);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR13, 0);
 }
 
 static int rt61pci_beacon_update(struct ieee80211_hw *hw,
@@ -2944,6 +2944,9 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
+	/*
+	 * Update the beacon entry.
+	 */
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, rt2x00_desc_addr(entry),
 		skb, control);
@@ -3542,6 +3545,9 @@
 	rt2x00dev->dev = pci_dev;
 	rt2x00dev->hw = hw;
 
+	/*
+	 * Allocate the CSR memory.
+	 */
 	rt2x00dev->csr_addr = ioremap(
 		pci_resource_start(rt2x00dev_pci(rt2x00dev), 0),
 		pci_resource_len(rt2x00dev_pci(rt2x00dev), 0));
diff -rU3 wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:27:24.000000000 +0100
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:48:35.000000000 +0100
@@ -218,11 +218,12 @@
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR("RFCSR register busy. Write failed.\n");
+	ERROR("PHY_CSR4 register busy. Write failed.\n");
 	return;
 
 rf_write:
-	reg = value;
+	reg = 0;
+	rt2x00_set_field32(&reg, PHY_CSR4_VALUE, value);
 	rt2x00_set_field32(&reg, PHY_CSR4_NUMBER_OF_BITS, 20);
 	rt2x00_set_field32(&reg, PHY_CSR4_IF_SELECT, 0);
 	rt2x00_set_field32(&reg, PHY_CSR4_BUSY, 1);
@@ -295,6 +296,7 @@
 	 * We only need to set the BSS ID MASK at the correct offset.
 	 */
 	memcpy(&reg, bssid, ETH_ALEN);
+	rt2x00_set_field32(&reg[1], MAC_CSR5_BSS_ID_MASK, 3);
 	rt2x00_register_multiwrite(rt2x00dev, MAC_CSR4, &reg[0], sizeof(reg));
 }
 
@@ -1719,7 +1721,7 @@
 	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
-	ieee80211hdr->duration_id += cpu_to_le16(duration);
+	ieee80211hdr->duration_id = cpu_to_le16(duration);
 
 	ieee80211hdr->seq_ctrl = 0;
 
@@ -2349,7 +2351,7 @@
 	rt73usb_config_txpower(rt2x00dev, conf->power_level);
 	rt73usb_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
 	rt73usb_config_duration(rt2x00dev,
-				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
+		(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME));
 	rt73usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2490,7 +2492,7 @@
 	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
-	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
+	rt2x00dev->scan = kzalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00dev->scan)
 		return -ENOMEM;
 
@@ -2565,10 +2567,8 @@
 	struct data_ring *ring;
 
 	ring = rt2x00_get_ring(rt2x00dev, queue);
-	if (unlikely(!ring)) {
-		NOTICE("Ignoring configuration for queue %d.\n", queue);
+	if (unlikely(!ring))
 		return -EINVAL;
-	}
 
 	memcpy(&ring->tx_params, params, sizeof(*params));
 
@@ -2589,6 +2589,10 @@
 	if (!params->aifs)
 		ring->tx_params.aifs = 2;
 
+	INFO("Configured TX ring %d - CWmin: %d, CWmax: %d, Aifs: %d.\n",
+		queue, ring->tx_params.cw_min, ring->tx_params.cw_max,
+		ring->tx_params.aifs);
+
 	return 0;
 }
 
@@ -2633,10 +2637,9 @@
 static void rt73usb_reset_tsf(struct ieee80211_hw *hw)
 {
 	struct rt2x00_dev *rt2x00dev = hw->priv;
-	u32 reg = 0;
 
-	rt2x00_register_write(rt2x00dev, TXRX_CSR12, reg);
-	rt2x00_register_write(rt2x00dev, TXRX_CSR13, reg);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR12, 0);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR13, 0);
 }
 
 static int rt73usb_beacon_update(struct ieee80211_hw *hw,
@@ -2656,6 +2659,9 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
+	/*
+	 * Update the beacon entry.
+	 */
 	memcpy(rt2x00_data_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev,
 		rt2x00_desc_addr(entry), skb, control);
