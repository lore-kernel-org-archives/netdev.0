From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 22/24] RT2x00: Optimize config handlers
Date: Wed, 26 Jul 2006 20:31:25 +0200
Message-ID: <200607262031.25284.IvDoorn@gmail.com>
References: <200607261905.52685.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161024AbWGZSbh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:31:37 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:31:36 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.52685.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Optimize the configuration handlers to only run
when the current configuration has been changed.
This means we need to store the current setting
of most configuration options in rt2x00_dev.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-26 10:55:31.000000000 +0200
+++ wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-26 12:49:38.000000000 +0200
@@ -475,6 +475,14 @@
 	u32 reg;
 
 	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (type == rt2x00dev->interface.type ||
+	    (rt2x00dev->interface.monitor_count ^
+	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
+		return;
+
+	/*
 	 * Apply hardware packet filter.
 	 */
 	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
@@ -520,7 +528,13 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00dev->interface.type = type;
+	if (type != IEEE80211_IF_TYPE_MNTR)
+		rt2x00dev->interface.type = type;
+
+	if (rt2x00dev->interface.monitor_count)
+		SET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
+	else
+		CLEAR_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
 }
 
 static void rt2400pci_config_channel(struct rt2x00_dev *rt2x00dev,
@@ -529,6 +543,12 @@
 	u32 rf1 = rt2x00dev->rf1;
 	u32 rf3 = rt2x00dev->rf3;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (channel == rt2x00dev->rx_params.channel)
+		return;
+
 	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x.\n",
 		rf1, rf2, rf3);
 
@@ -575,15 +595,31 @@
 	rt2x00dev->rx_params.channel = channel;
 
 	/*
+	 * Update rf fields
+	 */
+	rt2x00dev->rf1 = rf1;
+	rt2x00dev->rf2 = rf2;
+	rt2x00dev->rf3 = rf3;
+
+	/*
 	 * Clear false CRC during channel switch.
 	 */
 	rt2x00_register_read(rt2x00dev, CNT0, &rf1);
 }
 
-static void rt2400pci_config_txpower(struct rt2x00_dev *rt2x00dev, u8 txpower)
+static void rt2400pci_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
 {
 	txpower = TXPOWER_TO_DEV(txpower);
+
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (txpower == rt2x00dev->tx_power)
+		return;
+
 	rt2x00_bbp_write(rt2x00dev, 3, txpower);
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt2400pci_config_antenna(struct rt2x00_dev *rt2x00dev, int antenna)
@@ -591,6 +627,12 @@
 	u8 reg_rx;
 	u8 reg_tx;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.antenna == antenna)
+		return;
+
 	rt2x00_bbp_read(rt2x00dev, 4, &reg_rx);
 	rt2x00_bbp_read(rt2x00dev, 1, &reg_tx);
 
@@ -713,6 +755,12 @@
 {
 	struct ieee80211_rate *rate;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.phymode == phymode)
+		return;
+
 	rate = &rt2x00dev->hw.modes[0].rates[
 		rt2x00dev->hw.modes[0].num_rates - 1];
 
@@ -1760,6 +1808,9 @@
 	if (!reg)
 		return IRQ_NONE;
 
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return IRQ_HANDLED;
+
 	/*
 	 * Handle interrupts, walk through all bits
 	 * and run the tasks, the bits are checked in order of
@@ -1982,12 +2033,17 @@
 	u32 reg;
 
 	/*
-	 * Some configuration changes require the RX to be disabled.
+	 * Check if we need to disable the radio,
+	 * if this is not the case, at least the RX must be disabled.
 	 */
 	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
-		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+		if (!conf->radio_enabled)
+			rt2400pci_disable_radio(rt2x00dev);
+		else {
+			rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
+			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
+			rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+		}
 	}
 
 	rt2400pci_config_channel(rt2x00dev,
@@ -2000,24 +2056,13 @@
 	/*
 	 * Reenable RX only if the radio should be on.
 	 */
-	if (conf->radio_enabled) {
-		if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2400pci_open(net_dev)) {
-				ERROR("Failed to enabled radio.\n");
-				return;
-			}
-		} else {
-			rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-			rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-		}
-	} else {
-		if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2400pci_stop(net_dev)) {
-				ERROR("Failed to disable radio.\n");
-				return;
-			}
-		}
+	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
+		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
+		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+	} else if (conf->radio_enabled) {
+		if (rt2400pci_enable_radio(rt2x00dev))
+			return;
 	}
 }
 
@@ -2141,10 +2186,20 @@
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
+	/*
+	 * Check if we are not busy with the previous
+	 * passive scan request.
+	 */
 	if (rt2x00dev->scan)
 		return -EBUSY;
 
 	/*
+	 * Check if the radio is enabled.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return -EIO;
+
+	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
 	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
@@ -2443,6 +2498,9 @@
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg[2] = { 0, 0 };
 
+	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
+		return 0;
+
 	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
 
 	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
@@ -2454,6 +2512,10 @@
 
 	net_dev->addr_len = 6;
 
+	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+		return -EINVAL;
+
+	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
 
diff -rU3 wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-26 10:56:10.000000000 +0200
+++ wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-26 12:50:25.000000000 +0200
@@ -475,6 +475,14 @@
 	u32 reg;
 
 	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (type == rt2x00dev->interface.type ||
+	    (rt2x00dev->interface.monitor_count ^
+	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
+		return;
+
+	/*
 	 * Apply hardware packet filter.
 	 */
 	rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
@@ -523,7 +531,13 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00dev->interface.type = type;
+	if (type != IEEE80211_IF_TYPE_MNTR)
+		rt2x00dev->interface.type = type;
+
+	if (rt2x00dev->interface.monitor_count)
+		SET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
+	else
+		CLEAR_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
 }
 
 static void rt2500pci_config_channel(struct rt2x00_dev *rt2x00dev,
@@ -533,6 +547,12 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = rt2x00dev->rf4;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (channel == rt2x00dev->rx_params.channel)
+		return;
+
 	if (txpower == 0xff)
 		txpower = rt2x00dev->tx_power;
 	txpower = TXPOWER_TO_DEV(txpower);
@@ -559,14 +579,14 @@
 		}
 	}
 
-	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
-		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
-
 	/*
 	 * Set TXpower.
 	 */
 	rt2x00_set_field32(&rf3, RF3_TXPOWER, txpower);
 
+	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
+		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
+
 	/*
 	 * For RT2525 we should first set the channel to half band higher.
 	 */
@@ -611,6 +631,16 @@
 	rt2x00dev->rx_params.channel = channel;
 
 	/*
+	 * Update rf fields
+	 */
+	rt2x00dev->rf1 = rf1;
+	rt2x00dev->rf2 = rf2;
+	rt2x00dev->rf3 = rf3;
+	rt2x00dev->rf4 = rf4;
+
+	rt2x00dev->tx_power = txpower;
+
+	/*
 	 * Clear false CRC during channel switch.
 	 */
 	rt2x00_register_read(rt2x00dev, CNT0, &rf1);
@@ -620,8 +650,16 @@
 {
 	txpower = TXPOWER_TO_DEV(txpower);
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (txpower == rt2x00dev->tx_power)
+		return;
+
 	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3);
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt2500pci_config_antenna(struct rt2x00_dev *rt2x00dev, int antenna)
@@ -630,6 +668,12 @@
 	u8 reg_rx;
 	u8 reg_tx;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.antenna == antenna)
+		return;
+
 	rt2x00_register_read(rt2x00dev, BBPCSR1, &reg);
 	rt2x00_bbp_read(rt2x00dev, 14, &reg_rx);
 	rt2x00_bbp_read(rt2x00dev, 2, &reg_tx);
@@ -768,6 +812,12 @@
 {
 	struct ieee80211_rate *rate;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.phymode == phymode)
+		return;
+
 	if (phymode == MODE_IEEE80211A &&
 	    rt2x00_rf(&rt2x00dev->chip, RF5222))
 		rate = &rt2x00dev->hw.modes[2].rates[
@@ -1896,6 +1946,9 @@
 	if (!reg)
 		return IRQ_NONE;
 
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return IRQ_HANDLED;
+
 	/*
 	 * Handle interrupts, walk through all bits
 	 * and run the tasks, the bits are checked in order of
@@ -2117,12 +2170,17 @@
 	u32 reg;
 
 	/*
-	 * Some configuration changes require the RX to be disabled.
+	 * Check if we need to disable the radio,
+	 * if this is not the case, at least the RX must be disabled.
 	 */
 	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
-		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+		if (!conf->radio_enabled)
+			rt2500pci_disable_radio(rt2x00dev);
+		else {
+			rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
+			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 1);
+			rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+		}
 	}
 
 	rt2500pci_config_channel(rt2x00dev,
@@ -2136,24 +2194,13 @@
 	/*
 	 * Reenable RX only if the radio should be on.
 	 */
-	if (conf->radio_enabled) {
-		if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2500pci_open(net_dev)) {
-				ERROR("Failed to enabled radio.\n");
-				return;
-			}
-		} else {
-			rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
-			rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
-			rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-		}
-	} else {
-		if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2500pci_stop(net_dev)) {
-				ERROR("Failed to disable radio.\n");
-				return;
-			}
-		}
+	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
+		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
+		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
+	} else if (conf->radio_enabled) {
+		if (rt2500pci_enable_radio(rt2x00dev))
+			return;
 	}
 }
 
@@ -2273,10 +2320,20 @@
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
+	/*
+	 * Check if we are not busy with the previous
+	 * passive scan request.
+	 */
 	if (rt2x00dev->scan)
 		return -EBUSY;
 
 	/*
+	 * Check if the radio is enabled.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return -EIO;
+
+	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
 	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
@@ -2583,6 +2640,9 @@
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg[2] = { 0, 0 };
 
+	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
+		return 0;
+
 	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
 
 	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
@@ -2594,6 +2654,10 @@
 
 	net_dev->addr_len = 6;
 
+	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+		return -EINVAL;
+
+	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
 
diff -rU3 wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-26 10:56:11.000000000 +0200
+++ wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-26 12:50:28.000000000 +0200
@@ -325,6 +325,14 @@
 	u16 reg;
 
 	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (type == rt2x00dev->interface.type ||
+	    (rt2x00dev->interface.monitor_count ^
+	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
+		return;
+
+	/*
 	 * Apply hardware packet filter.
 	 */
 	rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
@@ -370,7 +378,13 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00dev->interface.type = type;
+	if (type != IEEE80211_IF_TYPE_MNTR)
+		rt2x00dev->interface.type = type;
+
+	if (rt2x00dev->interface.monitor_count)
+		SET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
+	else
+		CLEAR_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
 }
 
 static void rt2500usb_config_channel(struct rt2x00_dev *rt2x00dev,
@@ -380,6 +394,12 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = rt2x00dev->rf4;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (channel == rt2x00dev->rx_params.channel)
+		return;
+
 	if (txpower == 0xff)
 		txpower = rt2x00dev->tx_power;
 	txpower = TXPOWER_TO_DEV(txpower);
@@ -418,11 +438,14 @@
 		}
 	}
 
+	/*
+	 * Set TXpower.
+	 */
+	rt2x00_set_field32_nb(&rf3, RF3_TXPOWER, txpower);
+
 	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
 		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
 
-	rt2x00_set_field32_nb(&rf3, RF3_TXPOWER, txpower);
-
 	/*
 	 * For RT2525E we should first set the channel to half band higher.
 	 */
@@ -443,14 +466,34 @@
 	 */
 	rt2x00dev->rx_params.freq = freq;
 	rt2x00dev->rx_params.channel = channel;
+
+	rt2x00dev->tx_power = txpower;
+
+	/*
+	 * Update rf fields
+	 */
+	rt2x00dev->rf1 = rf1;
+	rt2x00dev->rf2 = rf2;
+	rt2x00dev->rf3 = rf3;
+	rt2x00dev->rf4 = rf4;
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt2500usb_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
 {
 	txpower = TXPOWER_TO_DEV(txpower);
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (txpower == rt2x00dev->tx_power)
+		return;
+
 	rt2x00_set_field32_nb(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3);
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt2500usb_config_antenna(struct rt2x00_dev *rt2x00dev, int antenna)
@@ -460,6 +503,12 @@
 	u16 csr5_reg;
 	u16 csr6_reg;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.antenna == antenna)
+		return;
+
 	rt2x00_bbp_read(rt2x00dev, 2, &reg_tx);
 	rt2x00_bbp_read(rt2x00dev, 14, &reg_rx);
 	rt2x00_register_read(rt2x00dev, PHY_CSR5, &csr5_reg);
@@ -578,6 +627,12 @@
 {
 	struct ieee80211_rate *rate;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.phymode == phymode)
+		return;
+
 	if (phymode == MODE_IEEE80211A &&
 	    rt2x00_rf(&rt2x00dev->chip, RF5222))
 		rate = &rt2x00dev->hw.modes[2].rates[
@@ -1819,12 +1874,17 @@
 	u16 reg;
 
 	/*
-	 * Some configuration changes require the RX to be disabled.
+	 * Check if we need to disable the radio,
+	 * if this is not the case, at least the RX must be disabled.
 	 */
 	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
-		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 1);
-		rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
+		if (!conf->radio_enabled)
+			rt2500usb_disable_radio(rt2x00dev);
+		else {
+			rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
+			rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 1);
+			rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
+		}
 	}
 
 	rt2500usb_config_channel(rt2x00dev,
@@ -1838,24 +1898,13 @@
 	/*
 	 * Reenable RX only if the radio should be on.
 	 */
-	if (conf->radio_enabled) {
-		if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2500usb_open(net_dev)) {
-				ERROR("Failed to enabled radio.\n");
-				return;
-			}
-		} else {
-			rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
-			rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
-			rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
-		}
-	} else {
-		if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt2500usb_stop(net_dev)) {
-				ERROR("Failed to disable radio.\n");
-				return;
-			}
-		}
+	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
+		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
+		rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
+	} else if (conf->radio_enabled) {
+		if (rt2500usb_enable_radio(rt2x00dev))
+			return;
 	}
 }
 
@@ -1985,10 +2034,20 @@
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
+	/*
+	 * Check if we are not busy with the previous
+	 * passive scan request.
+	 */
 	if (rt2x00dev->scan)
 		return -EBUSY;
 
 	/*
+	 * Check if the radio is enabled.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return -EIO;
+
+	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
 	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
@@ -2241,6 +2300,9 @@
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	u16 eeprom[3] = { 0, 0, 0 };
 
+	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
+		return 0;
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
@@ -2261,6 +2323,10 @@
 
 	net_dev->addr_len = 6;
 
+	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+		return -EINVAL;
+
+	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
 
diff -rU3 wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 10:56:17.000000000 +0200
+++ wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 12:50:33.000000000 +0200
@@ -506,6 +506,14 @@
 	u32 reg;
 
 	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (type == rt2x00dev->interface.type ||
+	    (rt2x00dev->interface.monitor_count ^
+	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
+		return;
+
+	/*
 	 * Apply hardware packet filter.
 	 */
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -554,7 +562,13 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00dev->interface.type = type;
+	if (type != IEEE80211_IF_TYPE_MNTR)
+		rt2x00dev->interface.type = type;
+
+	if (rt2x00dev->interface.monitor_count)
+		SET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
+	else
+		CLEAR_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
 }
 
 static void rt61pci_config_channel(struct rt2x00_dev *rt2x00dev,
@@ -565,6 +579,12 @@
 	u32 rf3 = 0;
 	u32 rf4 = 0;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (channel == rt2x00dev->rx_params.channel)
+		return;
+
 	if (txpower == 0xff)
 		txpower = rt2x00dev->tx_power;
 	txpower = TXPOWER_TO_DEV(txpower);
@@ -735,14 +755,14 @@
 		}
 	}
 
-	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
-		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
-
 	/*
 	 * Set TXpower.
 	 */
 	rt2x00_set_field32(&rf3, RF3_TXPOWER, txpower);
 
+	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
+		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
+
 	/*
 	 * Set Frequency offset.
 	 */
@@ -782,12 +802,28 @@
 	 */
 	rt2x00dev->rx_params.freq = freq;
 	rt2x00dev->rx_params.channel = channel;
+
+	rt2x00dev->tx_power = txpower;
+
+	/*
+	 * Update rf fields
+	 */
+	rt2x00dev->rf1 = rf1;
+	rt2x00dev->rf2 = rf2;
+	rt2x00dev->rf3 = rf3;
+	rt2x00dev->rf4 = rf4;
 }
 
 static void rt61pci_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
 {
 	txpower = TXPOWER_TO_DEV(txpower);
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (txpower == rt2x00dev->tx_power)
+		return;
+
 	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
 
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
@@ -808,6 +844,8 @@
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt61pci_config_antenna(struct rt2x00_dev *rt2x00dev,
@@ -819,6 +857,12 @@
 	u8 reg_r77;
 	u8 frame_type;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.antenna == antenna)
+		return;
+
 	rt2x00_register_read(rt2x00dev, PHY_CSR0, &reg);
 
 	if (phymode == MODE_IEEE80211A) {
@@ -997,6 +1041,12 @@
 {
 	struct ieee80211_rate *rate;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.phymode == phymode)
+		return;
+
 	if (phymode == MODE_IEEE80211A &&
 	    (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5325)))
@@ -2400,6 +2450,9 @@
 	if (!reg)
 		return IRQ_NONE;
 
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return IRQ_HANDLED;
+
 	/*
 	 * Handle interrupts, walk through all bits
 	 * and run the tasks, the bits are checked in order of
@@ -2632,12 +2685,17 @@
 	u32 reg;
 
 	/*
-	 * Some configuration changes require the RX to be disabled.
+	 * Check if we need to disable the radio,
+	 * if this is not the case, at least the RX must be disabled.
 	 */
 	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 1);
-		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+		if (!conf->radio_enabled)
+			rt61pci_disable_radio(rt2x00dev);
+		else {
+			rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+			rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 1);
+			rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+		}
 	}
 
 	rt61pci_config_channel(rt2x00dev,
@@ -2651,24 +2709,13 @@
 	/*
 	 * Reenable RX only if the radio should be on.
 	 */
-	if (conf->radio_enabled) {
-		if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt61pci_open(net_dev)) {
-				ERROR("Failed to enabled radio.\n");
-				return;
-			}
-		} else {
-			rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-			rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
-			rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-		}
-	} else {
-		if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt61pci_stop(net_dev)) {
-				ERROR("Failed to disable radio.\n");
-				return;
-			}
-		}
+	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
+		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+	} else if (conf->radio_enabled) {
+		if (rt61pci_enable_radio(rt2x00dev))
+			return;
 	}
 }
 
@@ -2788,10 +2835,20 @@
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
+	/*
+	 * Check if we are not busy with the previous
+	 * passive scan request.
+	 */
 	if (rt2x00dev->scan)
 		return -EBUSY;
 
 	/*
+	 * Check if the radio is enabled.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return -EIO;
+
+	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
 	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
@@ -3143,7 +3200,10 @@
 static int rt61pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u16 eeprom[3];
+	u16 eeprom[3] = { 0, 0, 0 };
+
+	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
+		return 0;
 
 	/*
 	 * Read MAC address from EEPROM.
@@ -3165,6 +3225,10 @@
 
 	net_dev->addr_len = 6;
 
+	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+		return -EINVAL;
+
+	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
 
diff -rU3 wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 10:56:20.000000000 +0200
+++ wireless-dev-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 12:50:39.000000000 +0200
@@ -327,6 +327,14 @@
 	u32 reg;
 
 	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (type == rt2x00dev->interface.type ||
+	    (rt2x00dev->interface.monitor_count ^
+	    GET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR)))
+		return;
+
+	/*
 	 * Apply hardware packet filter.
 	 */
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
@@ -375,7 +383,13 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00dev->interface.type = type;
+	if (type != IEEE80211_IF_TYPE_MNTR)
+		rt2x00dev->interface.type = type;
+
+	if (rt2x00dev->interface.monitor_count)
+		SET_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
+	else
+		CLEAR_FLAG(rt2x00dev, INTERFACE_ENABLED_MONITOR);
 }
 
 static void rt73usb_config_channel(struct rt2x00_dev *rt2x00dev,
@@ -386,6 +400,12 @@
 	u32 rf3 = rt2x00dev->rf3;
 	u32 rf4 = 0;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (channel == rt2x00dev->rx_params.channel)
+		return;
+
 	if (txpower == 0xff)
 		txpower = rt2x00dev->tx_power;
 	txpower = TXPOWER_TO_DEV(txpower);
@@ -463,14 +483,14 @@
 	    rt2x00_rf(&rt2x00dev->chip, RF5225))
 		rf4 |= 0x00010000;
 
-	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
-		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
-
 	/*
 	 * Set TXpower.
 	 */
 	rt2x00_set_field32(&rf3, RF3_TXPOWER, txpower);
 
+	INFO("Switching channel. RF1: 0x%08x, RF2: 0x%08x, RF3: 0x%08x, "
+		"RF4: 0x%08x.\n", rf1, rf2, rf3, rf4);
+
 	/*
 	 * Set Frequency offset.
 	 */
@@ -506,12 +526,30 @@
 	 */
 	rt2x00dev->rx_params.freq = freq;
 	rt2x00dev->rx_params.channel = channel;
+
+	rt2x00dev->tx_power = txpower;
+
+	/*
+	 * Update rf fields
+	 */
+	rt2x00dev->rf1 = rf1;
+	rt2x00dev->rf2 = rf2;
+	rt2x00dev->rf3 = rf3;
+	rt2x00dev->rf4 = rf4;
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt73usb_config_txpower(struct rt2x00_dev *rt2x00dev, int txpower)
 {
 	txpower = TXPOWER_TO_DEV(txpower);
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (txpower == rt2x00dev->tx_power)
+		return;
+
 	rt2x00_set_field32(&rt2x00dev->rf3, RF3_TXPOWER, txpower);
 
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf1);
@@ -528,6 +566,8 @@
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf2);
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf3 & ~cpu_to_le32(0x00000004));
 	rt2x00_rf_write(rt2x00dev, rt2x00dev->rf4);
+
+	rt2x00dev->tx_power = txpower;
 }
 
 static void rt73usb_config_antenna(struct rt2x00_dev *rt2x00dev,
@@ -539,6 +579,12 @@
 	u8 reg_r77;
 	u8 frame_type;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.antenna == antenna)
+		return;
+
 	rt2x00_register_read(rt2x00dev, PHY_CSR0, &reg);
 
 	if (phymode == MODE_IEEE80211A) {
@@ -711,6 +757,12 @@
 {
 	struct ieee80211_rate *rate;
 
+	/*
+	 * Only continue when there is something to be done.
+	 */
+	if (rt2x00dev->rx_params.phymode == phymode)
+		return;
+
 	if (phymode == MODE_IEEE80211A &&
 	    (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
 	    rt2x00_rf(&rt2x00dev->chip, RF5226)))
@@ -2133,12 +2185,17 @@
 	u32 reg;
 
 	/*
-	 * Some configuration changes require the RX to be disabled.
+	 * Check if we need to disable the radio,
+	 * if this is not the case, at least the RX must be disabled.
 	 */
 	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 1);
-		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+		if (!conf->radio_enabled)
+			rt73usb_disable_radio(rt2x00dev);
+		else {
+			rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+			rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 1);
+			rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+		}
 	}
 
 	rt73usb_config_channel(rt2x00dev,
@@ -2150,29 +2207,15 @@
 	rt73usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
-	 * Reenable RX.
-	 */
-	/*
 	 * Reenable RX only if the radio should be on.
 	 */
-	if (conf->radio_enabled) {
-		if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt73usb_open(net_dev)) {
-				ERROR("Failed to enabled radio.\n");
-				return;
-			}
-		} else {
-			rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
-			rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
-			rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-		}
-	} else {
-		if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
-			if (rt73usb_stop(net_dev)) {
-				ERROR("Failed to disable radio.\n");
-				return;
-			}
-		}
+	if (GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
+		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+	} else if (conf->radio_enabled) {
+		if (rt73usb_enable_radio(rt2x00dev))
+			return;
 	}
 }
 
@@ -2302,10 +2345,20 @@
 {
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
+	/*
+	 * Check if we are not busy with the previous
+	 * passive scan request.
+	 */
 	if (rt2x00dev->scan)
 		return -EBUSY;
 
 	/*
+	 * Check if the radio is enabled.
+	 */
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+		return -EIO;
+
+	/*
 	 * Allocate scanning structure to store scanning info.
 	 */
 	rt2x00dev->scan = kmalloc(sizeof(struct scanning), GFP_ATOMIC);
@@ -2640,6 +2693,9 @@
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
 	u16 eeprom[3] = { 0, 0, 0 };
 
+	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
+		return 0;
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
@@ -2660,6 +2716,10 @@
 
 	net_dev->addr_len = 6;
 
+	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
+		return -EINVAL;
+
+	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
 
