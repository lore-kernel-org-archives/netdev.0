From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 11/26] rt2x00: Put link tuning on workqueue
Date: Sun, 3 Dec 2006 19:19:02 +0100
Message-ID: <200612031919.02690.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:57689 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1759739AbWLCSTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:32 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144364nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:30 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put the link tuning in a workqueue, this prevents
the interrupthandlers from being busy for a too long
period and blocking new inetrrupt handling.
To do this correctly we add a link structure containing
all information regarding the link status.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 12:46:41.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 13:25:32.000000000 +0100
@@ -624,12 +624,20 @@
 /*
  * Link tuning
  */
-static void rt2400pci_link_tuner(struct rt2x00_dev *rt2x00dev)
+static void rt2400pci_link_tuner(void *data)
 {
+	struct rt2x00_dev *rt2x00dev = data;
 	u8 reg;
 	char false_cca_delta;
 
 	/*
+	 * Don't perform any tuning when it is disabled
+	 * in the EEPROM.
+	 */
+	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING))
+		return;
+
+	/*
 	 * Read false CCA counter.
 	 */
 	rt2x00_bbp_read(rt2x00dev, 39, &reg);
@@ -653,6 +661,9 @@
 		if (reg < 0x20)
 			rt2x00_bbp_write(rt2x00dev, 13, reg);
 	}
+
+	queue_delayed_work(rt2x00dev->workqueue, &rt2x00dev->link.work,
+		LINK_TUNE_INTERVAL);
 }
 
 /*
@@ -1568,16 +1579,6 @@
 		rt2x00_desc_write(rxd, 0, word0);
 		rt2x00_ring_index_inc(ring);
 	}
-
-	/*
-	 * Tune link for optimal performance.
-	 */
-	rt2400pci_link_tuner(rt2x00dev);
-
-	/*
-	 * Update LED.
-	 */
-	rt2400pci_activity_led(rt2x00dev, 0);
 }
 
 static void rt2400pci_txdone(void *data)
@@ -1885,8 +1886,11 @@
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
-	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		queue_delayed_work(rt2x00dev->workqueue,
+			&rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 		return rt2400pci_enable_radio(rt2x00dev);
+	}
 
 	return 0;
 }
@@ -1908,6 +1912,9 @@
 	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
+	cancel_rearming_delayed_workqueue(rt2x00dev->workqueue,
+			&rt2x00dev->link.work);
+
 	/*
 	 * When this is a non-monitor mode,
 	 * clear the INTERFACE_INITIALIZED FLAG to allow
@@ -2694,6 +2701,11 @@
 		goto exit;
 
 	/*
+	 * Initialize configuration work.
+	 */
+	INIT_WORK(&rt2x00dev->link.work, rt2400pci_link_tuner, rt2x00dev);
+
+	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 12:47:36.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 13:25:36.000000000 +0100
@@ -698,18 +698,27 @@
 /*
  * Link tuning
  */
-static void rt2500pci_link_tuner(struct rt2x00_dev *rt2x00dev, char rssi)
+static void rt2500pci_link_tuner(void *data)
 {
+	struct rt2x00_dev *rt2x00dev = data;
 	u32 reg;
+	u32 rssi;
 	u8 reg_r17;
 
 	/*
 	 * Don't perform any tuning when it is disabled
 	 * in the EEPROM.
 	 */
-	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING))
+	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING))
 		return;
 
+	/*
+	 * Retreive link quality.
+	 */
+	rssi = rt2x00_get_link_rssi(&rt2x00dev->link);
+	if (!rssi)
+		goto exit;
+
 	rt2x00_register_read(rt2x00dev, CSR0, &reg);
 	rt2x00_bbp_read(rt2x00dev, 17, &reg_r17);
 
@@ -719,14 +728,14 @@
 	if (rssi < 40) {
 		if (reg_r17 >= 0x41)
 			rt2x00_bbp_write(rt2x00dev, 17, reg_r17);
-		return;
+		goto exit;
 	} else if (rssi >= 62) {
 		if (reg_r17 != 0x50)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x50);
-		return;
+		goto exit;
 	} else if (reg_r17 >= 0x41) {
 		rt2x00_bbp_write(rt2x00dev, 17, reg_r17);
-		return;
+		goto exit;
 	}
 
 dynamic_cca_tune:
@@ -738,6 +747,16 @@
 		rt2x00_bbp_write(rt2x00dev, 17, ++reg_r17);
 	else if (reg < 100 && reg_r17 > 0x32)
 		rt2x00_bbp_write(rt2x00dev, 17, --reg_r17);
+
+exit:
+	/*
+	 * Update noise statistics.
+	 */
+	if (reg_r17)
+		rt2x00_update_link_noise(&rt2x00dev->link, reg_r17);
+
+	queue_delayed_work(rt2x00dev->workqueue, &rt2x00dev->link.work,
+		LINK_TUNE_INTERVAL);
 }
 
 /*
@@ -1669,14 +1688,6 @@
 	u32 word0;
 	u32 word2;
 	u16 size;
-	u8 rssi_count;
-	char total_rssi;
-
-	/*
-	 * Initialize variable for average RSSI calculation.
-	 */
-	rssi_count = 0;
-	total_rssi = 0;
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
@@ -1721,24 +1732,16 @@
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
 
-			rssi_count++;
-			total_rssi += rt2x00dev->rx_params.ssi;
+			/*
+			 * Update link statistics
+			 */
+			rt2x00_update_link_rssi(&rt2x00dev->link,
+				rt2x00dev->rx_params.ssi);
 		}
 		rt2x00_set_field32(&word0, RXD_W0_OWNER_NIC, 1);
 		rt2x00_desc_write(rxd, 0, word0);
 		rt2x00_ring_index_inc(ring);
 	}
-
-	/*
-	 * Tune link for optimal performance.
-	 */
-	if (total_rssi && rssi_count)
-		rt2500pci_link_tuner(rt2x00dev, total_rssi / rssi_count);
-
-	/*
-	 * Update LED.
-	 */
-	rt2500pci_activity_led(rt2x00dev, 0);
 }
 
 static void rt2500pci_txdone(void *data)
@@ -2045,8 +2048,11 @@
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
-	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		queue_delayed_work(rt2x00dev->workqueue,
+			&rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 		return rt2500pci_enable_radio(rt2x00dev);
+	}
 
 	return 0;
 }
@@ -2068,6 +2074,9 @@
 	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
+	cancel_rearming_delayed_workqueue(rt2x00dev->workqueue,
+			&rt2x00dev->link.work);
+
 	/*
 	 * When this is a non-monitor mode,
 	 * clear the INTERFACE_INITIALIZED FLAG to allow
@@ -2993,6 +3002,11 @@
 		goto exit;
 
 	/*
+	 * Initialize configuration work.
+	 */
+	INIT_WORK(&rt2x00dev->link.work, rt2500pci_link_tuner, rt2x00dev);
+
+	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 12:48:18.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 13:25:40.000000000 +0100
@@ -710,9 +710,11 @@
 /*
  * Link tuning
  */
-static void rt2500usb_link_tuner(struct rt2x00_dev *rt2x00dev, char rssi)
+static void rt2500usb_link_tuner(void *data)
 {
+	struct rt2x00_dev *rt2x00dev = data;
 	u16 reg;
+	u32 rssi;
 	u8 reg_r17;
 	u8 up_bound;
 	u8 low_bound;
@@ -721,9 +723,16 @@
 	 * Don't perform any tuning when it is disabled
 	 * in the EEPROM.
 	 */
-	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_BBP_TUNING))
+	if (GET_FLAG(rt2x00dev, CONFIG_DISABLE_LINK_TUNING))
 		return;
 
+	/*
+	 * Retreive link quality.
+	 */
+	rssi = rt2x00_get_link_rssi(&rt2x00dev->link);
+	if (!rssi)
+		goto exit;
+
 	low_bound = 0x32;
 	if (rssi >= 43)
 		up_bound = 0x40;
@@ -747,18 +756,18 @@
 	if (rssi > 80) {
 		if (reg_r17 != 0x60)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x60);
-		return;
+		goto exit;
 	} else if (rssi >= 62) {
 		if (reg_r17 != 0x48)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x48);
-		return;
+		goto exit;
 	} else if (rssi >= 46) {
 		if (reg_r17 != 0x41)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x41);
-		return;
+		goto exit;
 	} else if (reg_r17 > up_bound) {
 		rt2x00_bbp_write(rt2x00dev, 17, up_bound);
-		return;
+		goto exit;
 	}
 
 	rt2x00_register_read(rt2x00dev, STA_CSR3, &reg);
@@ -767,6 +776,16 @@
 		rt2x00_bbp_write(rt2x00dev, 17, ++reg_r17);
 	else if (reg < 100 && reg_r17 > low_bound)
 		rt2x00_bbp_write(rt2x00dev, 17, --reg_r17);
+
+exit:
+	/*
+	 * Update noise statistics.
+	 */
+	if (reg_r17)
+		rt2x00_update_link_noise(&rt2x00dev->link, reg_r17);
+
+	queue_delayed_work(rt2x00dev->workqueue, &rt2x00dev->link.work,
+		LINK_TUNE_INTERVAL);
 }
 
 /*
@@ -1604,14 +1623,6 @@
 	u32 word0;
 	u32 word1;
 	u16 size;
-	u8 rssi_count;
-	char total_rssi;
-
-	/*
-	 * Initialize variable for average RSSI calculation.
-	 */
-	rssi_count = 0;
-	total_rssi = 0;
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
@@ -1671,8 +1682,11 @@
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
 
-			rssi_count++;
-			total_rssi += rt2x00dev->rx_params.ssi;
+			/*
+			 * Update link statistics
+			 */
+			rt2x00_update_link_rssi(&rt2x00dev->link,
+				rt2x00dev->rx_params.ssi);
 		}
 
 		SET_FLAG(entry, ENTRY_OWNER_NIC);
@@ -1680,17 +1694,6 @@
 
 		rt2x00_ring_index_inc(ring);
 	}
-
-	/*
-	 * Tune link for optimal performance.
-	 */
-	if (total_rssi && rssi_count)
-		rt2500usb_link_tuner(rt2x00dev, total_rssi / rssi_count);
-
-	/*
-	 * Update LED.
-	 */
-	rt2500usb_activity_led(rt2x00dev, 0);
 }
 
 static void rt2500usb_txdone(void *data)
@@ -1939,8 +1942,11 @@
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
-	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		queue_delayed_work(rt2x00dev->workqueue,
+			&rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 		return rt2500usb_enable_radio(rt2x00dev);
+	}
 
 	return 0;
 }
@@ -1962,6 +1968,9 @@
 	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
+	cancel_rearming_delayed_workqueue(rt2x00dev->workqueue,
+			&rt2x00dev->link.work);
+
 	/*
 	 * When this is a non-monitor mode,
 	 * clear the INTERFACE_INITIALIZED FLAG to allow
@@ -2789,6 +2798,7 @@
 	 */
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt2500usb_interface_update, rt2x00dev);
+	INIT_WORK(&rt2x00dev->link.work, rt2500usb_link_tuner, rt2x00dev);
 
 	/*
 	 * Reset current working type.
diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 12:56:07.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:13:46.000000000 +0100
@@ -642,6 +642,65 @@
 }
 
 /*
+ * To optimize the quality of the link we need to store
+ * the quality of received frames and periodically
+ * optimize the link.
+ */
+struct link {
+	/*
+	 * RSSI statistics.
+	 */
+	u32 count_rssi;
+	u32 total_rssi;
+
+	/*
+	 * Noise statistics.
+	 */
+	u32 curr_noise;
+
+	/*
+	 * Work structure for scheduling periodic link tuning.
+	 */
+	struct work_struct work;
+};
+
+static inline void rt2x00_start_link_tune(struct link *link)
+{
+	link->count_rssi = 0;
+	link->total_rssi = 0;
+	link->curr_noise = 0;
+}
+
+static inline void rt2x00_update_link_rssi(struct link *link, u32 rssi)
+{
+	link->count_rssi++;
+	link->total_rssi += rssi;
+}
+
+static inline void rt2x00_update_link_noise(struct link *link, u32 noise)
+{
+	link->curr_noise = noise;
+}
+
+static inline u32 rt2x00_get_link_rssi(struct link *link)
+{
+	u32 average = 0;
+
+	if (link->count_rssi && link->total_rssi)
+		average = link->total_rssi / link->count_rssi;
+
+	link->count_rssi = 0;
+	link->total_rssi = 0;
+
+	return average;
+}
+
+static inline u32 rt2x00_get_link_noise(struct link *link)
+{
+	return link->curr_noise;
+}
+
+/*
  * Interface structure
  * Configuration details about the current interface.
  */
@@ -872,6 +931,11 @@
 	struct interface interface;
 
 	/*
+	 * Link quality
+	 */
+	struct link link;
+
+	/*
 	 * EEPROM data.
 	 */
 	__le16 *eeprom;
diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:08:21.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:25:43.000000000 +0100
@@ -922,13 +922,31 @@
 /*
  * Link tuning
  */
-static void rt61pci_link_tuner(struct rt2x00_dev *rt2x00dev, char rssi)
+static void rt61pci_link_tuner(void *data)
 {
+	struct rt2x00_dev *rt2x00dev = data;
 	u32 reg;
+	u32 rssi;
 	u8 reg_r17;
 	u8 up_bound;
 	u8 low_bound;
 
+	/*
+	 * Retreive link quality.
+	 */
+	rssi = rt2x00_get_link_rssi(&rt2x00dev->link);
+	if (!rssi)
+		goto exit;
+
+
+	/*
+	 * Update LED.
+	 */
+	rt61pci_activity_led(rt2x00dev, rssi);
+
+	/*
+	 * Determine upper and lower limit for BBP17 register.
+	 */
 	if (rt2x00dev->rx_params.phymode == MODE_IEEE80211A) {
 		up_bound = 0x48;
 		low_bound = 0x28;
@@ -942,24 +960,24 @@
 	if (rssi >= 85) {
 		if (reg_r17 != 0x60)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x60);
-		return;
+		goto exit;
 	} else if (rssi >= 62) {
 		if (reg_r17 != up_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, up_bound);
-		return;
+		goto exit;
 	} else if (rssi >= 54) {
 		low_bound += 0x10;
 		if (reg_r17 != low_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, low_bound);
-		return;
+		goto exit;
 	} else if (rssi >= 46) {
 		low_bound += 0x08;
 		if (reg_r17 != low_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, low_bound);
-		return;
+		goto exit;
 	} else if (reg_r17 >= up_bound) {
 		rt2x00_bbp_write(rt2x00dev, 17, up_bound);
-		return;
+		goto exit;
 	}
 
 	rt2x00_register_read(rt2x00dev, STA_CSR1, &reg);
@@ -969,6 +987,13 @@
 		rt2x00_bbp_write(rt2x00dev, 17, ++reg_r17);
 	else if (reg < 100 && reg_r17 > low_bound)
 		rt2x00_bbp_write(rt2x00dev, 17, --reg_r17);
+
+exit:
+	if (reg_r17)
+		rt2x00_update_link_noise(&rt2x00dev->link, reg_r17);
+
+	queue_delayed_work(rt2x00dev->workqueue, &rt2x00dev->link.work,
+		LINK_TUNE_INTERVAL);
 }
 
 /*
@@ -2121,14 +2146,6 @@
 	u32 word0;
 	u32 word1;
 	u16 size;
-	u8 rssi_count;
-	char total_rssi;
-
-	/*
-	 * Initialize variable for average RSSI calculation.
-	 */
-	rssi_count = 0;
-	total_rssi = 0;
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
@@ -2172,24 +2189,16 @@
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
 
-			rssi_count++;
-			total_rssi += rt2x00dev->rx_params.ssi;
+			/*
+			 * Update link statistics
+			 */
+			rt2x00_update_link_rssi(&rt2x00dev->link,
+				rt2x00dev->rx_params.ssi);
 		}
 		rt2x00_set_field32(&word0, RXD_W0_OWNER_NIC, 1);
 		rt2x00_desc_write(rxd, 0, word0);
 		rt2x00_ring_index_inc(ring);
 	}
-
-	/*
-	 * Tune link for optimal performance.
-	 */
-	if (total_rssi && rssi_count)
-		rt61pci_link_tuner(rt2x00dev, total_rssi / rssi_count);
-
-	/*
-	 * Update LED.
-	 */
-	rt61pci_activity_led(rt2x00dev, total_rssi);
 }
 
 static void rt61pci_txdone_entry(struct data_entry *entry, u32 sta_csr4)
@@ -2526,8 +2535,11 @@
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
-	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		queue_delayed_work(rt2x00dev->workqueue,
+			&rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 		return rt61pci_enable_radio(rt2x00dev);
+	}
 
 	return 0;
 }
@@ -2549,6 +2561,9 @@
 	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
+	cancel_rearming_delayed_workqueue(rt2x00dev->workqueue,
+			&rt2x00dev->link.work);
+
 	/*
 	 * When this is a non-monitor mode,
 	 * clear the INTERFACE_INITIALIZED FLAG to allow
@@ -3503,6 +3518,11 @@
 		goto exit;
 
 	/*
+	 * Initialize configuration work.
+	 */
+	INIT_WORK(&rt2x00dev->link.work, rt61pci_link_tuner, rt2x00dev);
+
+	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-ringindex/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:10:11.000000000 +0100
+++ wireless-dev-linktuning/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:25:46.000000000 +0100
@@ -812,13 +812,30 @@
 /*
  * Link tuning
  */
-static void rt73usb_link_tuner(struct rt2x00_dev *rt2x00dev, char rssi)
+static void rt73usb_link_tuner(void *data)
 {
+	struct rt2x00_dev *rt2x00dev = data;
 	u32 reg;
+	u32 rssi;
 	u8 reg_r17;
 	u8 up_bound;
 	u8 low_bound;
 
+	/*
+	 * Retreive link quality.
+	 */
+	rssi = rt2x00_get_link_rssi(&rt2x00dev->link);
+	if (!rssi)
+		goto exit;
+
+	/*
+	 * Update LED.
+	 */
+	rt73usb_activity_led(rt2x00dev, rssi);
+
+	/*
+	 * Determine upper and lower limit for BBP17 register.
+	 */
 	if (rt2x00dev->rx_params.phymode == MODE_IEEE80211A) {
 		up_bound = 0x48;
 		low_bound = 0x28;
@@ -845,21 +862,21 @@
 	if (rssi >= 85) {
 		if (reg_r17 != 0x60)
 			rt2x00_bbp_write(rt2x00dev, 17, 0x60);
-		return;
+		goto exit;
 	} else if (rssi >= 62) {
 		if (reg_r17 != up_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, up_bound);
-		return;
+		goto exit;
 	} else if (rssi >= 54) {
 		low_bound += 0x10;
 		if (reg_r17 != low_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, low_bound);
-		return;
+		goto exit;
 	} else if (rssi >= 46) {
 		low_bound += 0x08;
 		if (reg_r17 != low_bound)
 			rt2x00_bbp_write(rt2x00dev, 17, low_bound);
-		return;
+		goto exit;
 	} else {
 		up_bound -= 2 * (46 - rssi);
 		if (up_bound < low_bound)
@@ -867,7 +884,7 @@
 
 		if (reg_r17 > up_bound) {
 			rt2x00_bbp_write(rt2x00dev, 17, up_bound);
-			return;
+			goto exit;
 		}
 	}
 
@@ -878,6 +895,13 @@
 		rt2x00_bbp_write(rt2x00dev, 17, ++reg_r17);
 	else if (reg < 100 && reg_r17 > low_bound)
 		rt2x00_bbp_write(rt2x00dev, 17, --reg_r17);
+
+exit:
+	if (reg_r17)
+		rt2x00_update_link_noise(&rt2x00dev->link, reg_r17);
+
+	queue_delayed_work(rt2x00dev->workqueue, &rt2x00dev->link.work,
+		LINK_TUNE_INTERVAL);
 }
 
 /*
@@ -1883,14 +1907,6 @@
 	u32 word0;
 	u32 word1;
 	u16 size;
-	u8 rssi_count;
-	char total_rssi;
-
-	/*
-	 * Initialize variable for average RSSI calculation.
-	 */
-	rssi_count = 0;
-	total_rssi = 0;
 
 	while (1) {
 		entry = rt2x00_get_data_entry(ring);
@@ -1946,8 +1962,11 @@
 			__ieee80211_rx(rt2x00dev->hw,
 				skb, &rt2x00dev->rx_params);
 
-			rssi_count++;
-			total_rssi += rt2x00dev->rx_params.ssi;
+			/*
+			 * Update link statistics
+			 */
+			rt2x00_update_link_rssi(&rt2x00dev->link,
+				rt2x00dev->rx_params.ssi);
 		}
 
 		SET_FLAG(entry, ENTRY_OWNER_NIC);
@@ -1955,17 +1974,6 @@
 
 		rt2x00_ring_index_inc(ring);
 	}
-
-	/*
-	 * Tune link for optimal performance.
-	 */
-	if (total_rssi && rssi_count)
-		rt73usb_link_tuner(rt2x00dev, total_rssi / rssi_count);
-
-	/*
-	 * Update LED.
-	 */
-	rt73usb_activity_led(rt2x00dev, total_rssi);
 }
 
 static void rt73usb_txdone(void *data)
@@ -2213,8 +2221,11 @@
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
-	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
+	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO)) {
+		queue_delayed_work(rt2x00dev->workqueue,
+			&rt2x00dev->link.work, LINK_TUNE_INTERVAL);
 		return rt73usb_enable_radio(rt2x00dev);
+	}
 
 	return 0;
 }
@@ -2236,6 +2247,9 @@
 	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
+	cancel_rearming_delayed_workqueue(rt2x00dev->workqueue,
+			&rt2x00dev->link.work);
+
 	/*
 	 * When this is a non-monitor mode,
 	 * clear the INTERFACE_INITIALIZED FLAG to allow
@@ -3130,6 +3144,7 @@
 	 */
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt73usb_interface_update, rt2x00dev);
+	INIT_WORK(&rt2x00dev->link.work, rt73usb_link_tuner, rt2x00dev);
 
 	/*
 	 * Reset current working type.
