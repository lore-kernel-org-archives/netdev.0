From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 24/24] RT2x00: Misc. fixes
Date: Wed, 26 Jul 2006 19:05:56 +0200
Message-ID: <200607261905.57136.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030340AbWGZRHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:53 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:52 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Misc. fixes
* Compile fixes
* Code style fixes previously overlooked
* Better check of return values of functions

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 15:39:52.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-26 15:56:37.000000000 +0200
@@ -360,7 +360,7 @@
 		rt2x00dev, rt2x00_get_field32(reg, GPIOCSR_BIT0));
 }
 #else /* CONFIG_RT2400PCI_BUTTON */
-static void rt2400pci_button_poll(struct rt2x00_dev *rt2x00dev){}
+static void rt2400pci_button_poll(unsigned long data){}
 #endif /* CONFIG_RT2400PCI_BUTTON */
 
 /*
@@ -1520,7 +1520,7 @@
 {
 	struct ieee80211_hdr *ieee80211hdr;
 	struct sk_buff *skb;
-	u16 temp;
+	u16 frame_control;
 
 	skb = dev_alloc_skb(IEEE80211_HEADER);
 	if (!skb)
@@ -1532,8 +1532,8 @@
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
-	ieee80211hdr->frame_control = cpu_to_le16(temp);
+	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
 
@@ -1559,7 +1559,7 @@
 	u16 frame_control;
 	u8 bitrate;
 	int tx_rate;
- 
+
 	/*
 	 * Check which rate should be used for this frame.
 	 */
@@ -1593,16 +1593,16 @@
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (frame_control & WLAN_FC_MOREFRAG)
+	if (ieee80211_get_morefrag(ieee80211hdr))
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
- 
+
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		rt2x00_set_field32(&txd->word0, TXD_W0_RTS, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_RTS, 0);
- 
+
 	rt2x00_set_field32(&txd->word2, TXD_W2_DATABYTE_COUNT, skb->len);
 
 	/*
@@ -1613,10 +1613,9 @@
 	/*
 	 * Convert length to microseconds.
 	 */
-	residual = get_duration_res(length,
-		DEVICE_GET_RATE_FIELD(tx_rate, RATE));
-	length = get_duration(length,
-		DEVICE_GET_RATE_FIELD(tx_rate, RATE));
+	bitrate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
+	residual = get_duration_res(length, bitrate);
+	length = get_duration(length, bitrate);
 
 	if (residual)
 		length++;
@@ -2627,16 +2626,16 @@
 	for (i = 0; i < 13; i++) {
 		channels[i].chan = i + 1;
 		channels[i].freq = 2407 + ((i + 1) * 5);
-		channels[i].flag = IEEE80211_CHAN_W_IBSS
-			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+		channels[i].flag = IEEE80211_CHAN_W_IBSS |
+			IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[i].val = cpu_to_le32(vals[i]);
 		channels[i].antenna_max = 0xff;
 	}
 
 	channels[13].chan = 14;
 	channels[13].freq = 2484;
-	channels[13].flag = IEEE80211_CHAN_W_IBSS
-		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+	channels[13].flag = IEEE80211_CHAN_W_IBSS |
+		IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].val = cpu_to_le32(vals[13]);
 	channels[13].antenna_max = 0xff;
 
@@ -2852,9 +2851,10 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (pci_enable_device(pci_dev)) {
+	status = pci_enable_device(pci_dev);
+	if (status) {
 		ERROR("Enable device failed.\n");
-		return -EIO;
+		return status;
 	}
 
 	pci_set_master(pci_dev);
@@ -2869,9 +2869,9 @@
 		goto exit_disable_device;
 	}
 
-	if (pci_request_regions(pci_dev, pci_name(pci_dev))) {
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
 		ERROR("PCI request regions failed.\n");
-		status = -EBUSY;
 		goto exit_disable_device;
 	}
 
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 15:39:52.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-26 15:56:37.000000000 +0200
@@ -360,7 +360,7 @@
 		rt2x00dev, rt2x00_get_field32(reg, GPIOCSR_BIT0));
 }
 #else /* CONFIG_RT2500PCI_BUTTON */
-static void rt2500pci_button_poll(struct rt2x00_dev *rt2x00dev){}
+static void rt2500pci_button_poll(unsigned long data){}
 #endif /* CONFIG_RT2500PCI_BUTTON */
 
 /*
@@ -520,14 +520,12 @@
 	/*
 	 * Enable beacon config
 	 */
-	if (ring) {
-		rt2x00_register_read(rt2x00dev, BCNCSR1, &reg);
-		rt2x00_set_field32(&reg, BCNCSR1_PRELOAD,
-			PREAMBLE + get_duration(IEEE80211_HEADER, 2));
-		rt2x00_set_field32(&reg, BCNCSR1_BEACON_CWMIN,
-			rt2x00dev->ring[RING_BEACON].tx_params.cw_min);
-		rt2x00_register_write(rt2x00dev, BCNCSR1, reg);
-	}
+	rt2x00_register_read(rt2x00dev, BCNCSR1, &reg);
+	rt2x00_set_field32(&reg, BCNCSR1_PRELOAD,
+		PREAMBLE + get_duration(IEEE80211_HEADER, 2));
+	rt2x00_set_field32(&reg, BCNCSR1_BEACON_CWMIN,
+		rt2x00dev->ring[RING_BEACON].tx_params.cw_min);
+	rt2x00_register_write(rt2x00dev, BCNCSR1, reg);
 
 	/*
 	 * Enable synchronisation.
@@ -1642,7 +1640,7 @@
 {
 	struct ieee80211_hdr *ieee80211hdr;
 	struct sk_buff *skb;
-	u16 temp;
+	u16 frame_control;
 
 	skb = dev_alloc_skb(IEEE80211_HEADER);
 	if (!skb)
@@ -1654,8 +1652,8 @@
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
-	ieee80211hdr->frame_control = cpu_to_le16(temp);
+	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
 
@@ -1679,7 +1677,6 @@
 	u16 length_low;
 	u16 signal;
 	u16 service;
-	u8 rate;
 	u16 frame_control;
 	u8 bitrate;
 	int tx_rate;
@@ -1721,7 +1718,7 @@
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (frame_control & WLAN_FC_MOREFRAG)
+	if (ieee80211_get_morefrag(ieee80211hdr))
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -1758,12 +1755,12 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
+		bitrate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
-		residual = get_duration_res(length, rate);
-		length = get_duration(length, rate);
+		residual = get_duration_res(length, bitrate);
+		length = get_duration(length, bitrate);
 
 		if (residual != 0)
 			length++;
@@ -2032,6 +2029,7 @@
 
 	return IRQ_HANDLED;
 }
+
 /*
  * IEEE80211 stack callback functions.
  */
@@ -2786,15 +2784,15 @@
 	for (i = 0; i < 13; i++) {
 		channels[i].chan = i + 1;
 		channels[i].freq = 2407 + ((i + 1) * 5);
-		channels[i].flag = IEEE80211_CHAN_W_IBSS
-			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+		channels[i].flag = IEEE80211_CHAN_W_IBSS |
+			IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[i].antenna_max = 0xff;
 	}
 
 	channels[13].chan = 14;
 	channels[13].freq = 2484;
-	channels[13].flag = IEEE80211_CHAN_W_IBSS
-		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+	channels[13].flag = IEEE80211_CHAN_W_IBSS |
+		IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max = 0xff;
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5222)) {
@@ -2807,9 +2805,9 @@
 				channels[i].chan = 149;
 			channels[i].chan += ((i - 14) * 4);
 			channels[i].freq = ((i - 13) + 1000) * 5;
-			channels[i].flag = IEEE80211_CHAN_W_IBSS
-				| IEEE80211_CHAN_W_ACTIVE_SCAN
-				| IEEE80211_CHAN_W_SCAN;
+			channels[i].flag = IEEE80211_CHAN_W_IBSS |
+				IEEE80211_CHAN_W_ACTIVE_SCAN |
+				IEEE80211_CHAN_W_SCAN;
 			channels[i].power_level = DEFAULT_TXPOWER;
 			channels[i].antenna_max = 0xff;
 		}
@@ -3136,9 +3134,10 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (pci_enable_device(pci_dev)) {
+	status = pci_enable_device(pci_dev);
+	if (status) {
 		ERROR("Enable device failed.\n");
-		return -EIO;
+		return status;
 	}
 
 	pci_set_master(pci_dev);
@@ -3153,9 +3152,9 @@
 		goto exit_disable_device;
 	}
 
-	if (pci_request_regions(pci_dev, pci_name(pci_dev))) {
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
 		ERROR("PCI request regions failed.\n");
-		status = -EBUSY;
 		goto exit_disable_device;
 	}
 
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 15:39:52.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-26 15:56:37.000000000 +0200
@@ -1402,7 +1402,7 @@
 {
 	struct ieee80211_hdr *ieee80211hdr;
 	struct sk_buff *skb;
-	u16 temp;
+	u16 frame_control;
 
 	skb = dev_alloc_skb(IEEE80211_HEADER);
 	if (!skb)
@@ -1414,8 +1414,8 @@
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
-	ieee80211hdr->frame_control = cpu_to_le16(temp);
+	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
 
@@ -1435,11 +1435,11 @@
 	struct data_ring *ring;
 	u32 length;
 	u32 residual;
+	u16 frame_control;
 	u8 length_high;
 	u8 length_low;
 	u8 signal;
 	u8 service;
-	u16 frame_control;
 	u8 bitrate;
 	int tx_rate;
 
@@ -1477,7 +1477,7 @@
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_LIMIT,
 		control->retry_limit);
 
-	if (frame_control & WLAN_FC_MOREFRAG)
+	if (ieee80211_get_morefrag(ieee80211hdr))
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -1514,12 +1514,12 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
+		bitrate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
-		residual = get_duration_res(length, rate);
-		length = get_duration(length, rate);
+		residual = get_duration_res(length, bitrate);
+		length = get_duration(length, bitrate);
 
 		if (residual != 0)
 			length++;
@@ -2462,15 +2462,15 @@
 	for (i = 0; i < 13; i++) {
 		channels[i].chan = i + 1;
 		channels[i].freq = 2407 + ((i + 1) * 5);
-		channels[i].flag = IEEE80211_CHAN_W_IBSS
-			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+		channels[i].flag = IEEE80211_CHAN_W_IBSS |
+			IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[i].antenna_max = 0xff;
 	}
 
 	channels[13].chan = 14;
 	channels[13].freq = 2484;
-	channels[13].flag = IEEE80211_CHAN_W_IBSS
-		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+	channels[13].flag = IEEE80211_CHAN_W_IBSS |
+		IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max = 0xff;
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5222)) {
@@ -2483,9 +2483,9 @@
 				channels[i].chan = 149;
 			channels[i].chan += ((i - 14) * 4);
 			channels[i].freq = ((i - 13) + 1000) * 5;
-			channels[i].flag = IEEE80211_CHAN_W_IBSS
-				| IEEE80211_CHAN_W_ACTIVE_SCAN
-				| IEEE80211_CHAN_W_SCAN;
+			channels[i].flag = IEEE80211_CHAN_W_IBSS |
+				IEEE80211_CHAN_W_ACTIVE_SCAN |
+				IEEE80211_CHAN_W_SCAN;
 			channels[i].power_level = DEFAULT_TXPOWER;
 			channels[i].antenna_max = 0xff;
 		}
@@ -2953,7 +2953,7 @@
 	{ USB_DEVICE(0x0eb0, 0x9020) },
 	/* Zinwell */
 	{ USB_DEVICE(0x5a57, 0x0260) },
-	{0,}
+	{ 0, }
 };
 
 MODULE_AUTHOR(DRV_PROJECT);
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-26 15:39:43.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-26 
15:56:37.000000000 +0200
@@ -107,6 +107,19 @@
 #define CLEAR_FLAGS(__dev)		( (__dev)->flags = 0 )
 
 /*
+ * Standard timning and size defines.
+ */
+#define ACK_SIZE		14
+#define IEEE80211_HEADER	24
+#define PLCP			48
+#define BEACON			100
+#define SIFS			10
+#define PREAMBLE		144
+#define SHORT_PREAMBLE		72
+#define SLOT_TIME		20
+#define SHORT_SLOT_TIME		7
+
+/*
  * TX result flags.
  */
 enum TX_STATUS {
@@ -451,7 +464,7 @@
  * and the data buffer. For TX rings the reference to the
  * sk_buff of the packet being transmitted is also stored here.
  */
-struct data_entry{
+struct data_entry {
 	/*
 	 * Status flags
 	 */
@@ -1022,14 +1035,4 @@
 	return ((size * 8 * 10) % rate);
 }
 
-#define ACK_SIZE		14
-#define IEEE80211_HEADER	24
-#define PLCP			48
-#define BEACON			100
-#define SIFS			10
-#define PREAMBLE		144
-#define SHORT_PREAMBLE		72
-#define SLOT_TIME		20
-#define SHORT_SLOT_TIME		7
-
 #endif /* RT2X00_H */
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-26 15:39:37.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-26 15:56:37.000000000 +0200
@@ -151,7 +151,7 @@
 }
 #else /* CONFIG_RT2X00_BUTTON */
 static inline void rt2x00pci_button_start(struct rt2x00_dev *rt2x00dev,
-	int (*handler)(struct rt2x00_dev *rt2x00dev)){}
+	void (*handler)(unsigned long data)){}
 static inline void rt2x00pci_button_stop(struct rt2x00_dev *rt2x00dev){}
 #endif /* CONFIG_RT2X00_BUTTON */
 
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-26 15:39:37.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-26 15:56:37.000000000 +0200
@@ -84,9 +84,9 @@
 	struct usb_device *usb_dev = interface_to_usbdev(
 		rt2x00dev_usb(rt2x00dev));
 	int status;
-	u8 counter;
+	unsigned int i;
 
-	for (counter = 0; counter < REGISTER_BUSY_COUNT; counter++) {
+	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
 		status = usb_control_msg(
 			usb_dev,
 			(type == USB_VENDOR_REQUEST_IN) ?
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-26 15:39:52.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 
15:57:18.000000000 +0200
@@ -391,7 +391,7 @@
 		rt2x00dev, rt2x00_get_field32(reg, MAC_CSR13_BIT5));
 }
 #else /* CONFIG_RT61PCI_BUTTON */
-static void rt61pci_button_poll(struct rt2x00_dev *rt2x00dev){}
+static void rt61pci_button_poll(unsigned long data){}
 #endif /* CONFIG_RT61PCI_BUTTON */
 
 /*
@@ -1591,7 +1591,7 @@
 		rt2x00_set_field32(&txd->word1, TXD_W1_BUFFER_COUNT, 1);
 		rt2x00_set_field32(&txd->word6, TXD_W6_BUFFER_PHYSICAL_ADDRESS,
 			ring->entry[i].data_dma);
-		rt2x00_set_field32(&txd->word5, TXD_W5_PID_TYPE, type);
+		rt2x00_set_field32(&txd->word5, TXD_W5_PID_TYPE, ring_type);
 		rt2x00_set_field32(&txd->word5, TXD_W5_PID_SUBTYPE, i);
 	}
 
@@ -2073,7 +2073,7 @@
 {
 	struct ieee80211_hdr *ieee80211hdr;
 	struct sk_buff *skb;
-	u16 temp;
+	u16 frame_control;
 
 	skb = dev_alloc_skb(IEEE80211_HEADER);
 	if (!skb)
@@ -2085,8 +2085,8 @@
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
-	ieee80211hdr->frame_control = cpu_to_le16(temp);
+	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
 
@@ -2110,7 +2110,6 @@
 	u16 length_low;
 	u16 signal;
 	u16 service;
-	u8 rate;
 	u16 frame_control;
 	u8 bitrate;
 	int tx_rate;
@@ -2152,7 +2151,7 @@
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (frame_control & WLAN_FC_MOREFRAG)
+	if (ieee80211_get_morefrag(ieee80211hdr))
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -2203,12 +2202,12 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
+		bitrate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
-		residual = get_duration_res(length, rate);
-		length = get_duration(length, rate);
+		residual = get_duration_res(length, bitrate);
+		length = get_duration(length, bitrate);
 
 		if (residual != 0)
 			length++;
@@ -2313,13 +2312,11 @@
 		rt2x00_ring_index_inc(ring);
 	}
 
-	if (total_rssi && rssi_count)
-		total_rssi /= rssi_count;
-
 	/*
 	 * Tune link for optimal performance.
 	 */
-	rt61pci_link_tuner(rt2x00dev, total_rssi);
+	if (total_rssi && rssi_count)
+		rt61pci_link_tuner(rt2x00dev, total_rssi / rssi_count);
 
 	/*
 	 * Update LED.
@@ -2500,40 +2497,15 @@
 			&rt2x00dev->ring[RING_RX].irq_work);
 
 	/*
-	 * 3 - AC_BK ring transmit done interrupt.
+	 * 3 - Tx ring done interrupt.
+	 * Don't care about which ring we use to schedule
+	 * work to. The handler will run for all TX
+	 * related rings except Beacon.
 	 */
-	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_AC0_DMA_DONE))
+	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_TXDONE))
 		queue_work(rt2x00dev->workqueue,
 			&rt2x00dev->ring[RING_AC_BK].irq_work);
 
-	/*
-	 * 4 - AC_BE ring transmit done interrupt.
-	 */
-	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_AC1_DMA_DONE))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->ring[RING_AC_BE].irq_work);
-
-	/*
-	 * 5 - AC_VI ring transmit done interrupt.
-	 */
-	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_AC2_DMA_DONE))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->ring[RING_AC_VI].irq_work);
-
-	/*
-	 * 6 - AC_VO ring transmit done interrupt.
-	 */
-	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_AC3_DMA_DONE))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->ring[RING_AC_VO].irq_work);
-
-	/*
-	 * 7 - PRIO ring transmit done interrupt.
-	 */
-	if (rt2x00_get_field32(reg, INT_SOURCE_CSR_MGMT_DMA_DONE))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->ring[RING_PRIO].irq_work);
-
 	return IRQ_HANDLED;
 }
 
@@ -3329,15 +3301,15 @@
 	for (i = 0; i < 13; i++) {
 		channels[i].chan = i + 1;
 		channels[i].freq = 2407 + ((i + 1) * 5);
-		channels[i].flag = IEEE80211_CHAN_W_IBSS
-			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+		channels[i].flag = IEEE80211_CHAN_W_IBSS |
+			IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[i].antenna_max = 0xff;
 	}
 
 	channels[13].chan = 14;
 	channels[13].freq = 2484;
-	channels[13].flag = IEEE80211_CHAN_W_IBSS
-		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+	channels[13].flag = IEEE80211_CHAN_W_IBSS |
+		IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max = 0xff;
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
@@ -3351,9 +3323,9 @@
 				channels[i].chan = 149;
 			channels[i].chan += ((i - 14) * 4);
 			channels[i].freq = ((i - 13) + 1000) * 5;
-			channels[i].flag = IEEE80211_CHAN_W_IBSS
-				| IEEE80211_CHAN_W_ACTIVE_SCAN
-				| IEEE80211_CHAN_W_SCAN;
+			channels[i].flag = IEEE80211_CHAN_W_IBSS |
+				IEEE80211_CHAN_W_ACTIVE_SCAN |
+				IEEE80211_CHAN_W_SCAN;
 			channels[i].antenna_max = 0xff;
 		}
 	}
@@ -3693,9 +3665,10 @@
 	struct net_device *net_dev;
 	int status;
 
-	if (pci_enable_device(pci_dev)) {
+	status = pci_enable_device(pci_dev);
+	if (status) {
 		ERROR("Enable device failed.\n");
-		return -EIO;
+		return status;
 	}
 
 	pci_set_master(pci_dev);
@@ -3710,9 +3683,9 @@
 		goto exit_disable_device;
 	}
 
-	if (pci_request_regions(pci_dev, pci_name(pci_dev))) {
+	status = pci_request_regions(pci_dev, pci_name(pci_dev));
+	if (status) {
 		ERROR("PCI request regions failed.\n");
-		status = -EBUSY;
 		goto exit_disable_device;
 	}
 
diff -rU3 wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-reginit/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-26 15:39:52.000000000 +0200
+++ wireless-dev-misc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 
15:59:09.000000000 +0200
@@ -1669,7 +1669,7 @@
 {
 	struct ieee80211_hdr *ieee80211hdr;
 	struct sk_buff *skb;
-	u16 temp;
+	u16 frame_control;
 
 	skb = dev_alloc_skb(IEEE80211_HEADER);
 	if (!skb)
@@ -1681,8 +1681,8 @@
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	temp = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
-	ieee80211hdr->frame_control = cpu_to_le16(temp);
+	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
 
@@ -1706,7 +1706,6 @@
 	u16 length_low;
 	u16 signal;
 	u16 service;
-	u8 rate;
 	u16 frame_control;
 	u8 bitrate;
 	int tx_rate;
@@ -1748,7 +1747,7 @@
 	 */
 	rt2x00_set_field32(&txd->word0, TXD_W0_RETRY_MODE, 0);
 
-	if (frame_control & WLAN_FC_MOREFRAG)
+	if (ieee80211_get_morefrag(ieee80211hdr))
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
@@ -1798,12 +1797,12 @@
 		length_low = (length & 0x3f);
 
 	} else {
-		rate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
+		bitrate = DEVICE_GET_RATE_FIELD(tx_rate, RATE);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_OFDM, 0);
 
-		residual = get_duration_res(length, rate);
-		length = get_duration(length, rate);
+		residual = get_duration_res(length, bitrate);
+		length = get_duration(length, bitrate);
 
 		if (residual != 0)
 			length++;
@@ -1889,11 +1888,7 @@
 			continue;
 		}
 
-		/*
-		 * Received USB packets have 4 bytes of extra data.
-		 */
 		size = rt2x00_get_field32(rxd->word0, RXD_W0_DATABYTE_COUNT);
-		size -= 4;
 
 		/*
 		 * TODO: Don't we need to keep statistics
@@ -1926,13 +1921,11 @@
 		rt2x00_ring_index_inc(ring);
 	}
 
-	if (total_rssi && rssi_count)
-		total_rssi /= rssi_count;
-
 	/*
 	 * Tune link for optimal performance.
 	 */
-	rt73usb_link_tuner(rt2x00dev, total_rssi);
+	if (total_rssi && rssi_count)
+		rt73usb_link_tuner(rt2x00dev, total_rssi / rssi_count);
 
 	/*
 	 * Update LED.
@@ -2837,15 +2830,15 @@
 	for (i = 0; i < 13; i++) {
 		channels[i].chan = i + 1;
 		channels[i].freq = 2407 + ((i + 1) * 5);
-		channels[i].flag = IEEE80211_CHAN_W_IBSS
-			| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+		channels[i].flag = IEEE80211_CHAN_W_IBSS |
+			IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 		channels[i].antenna_max = 0xff;
 	}
 
 	channels[13].chan = 14;
 	channels[13].freq = 2484;
-	channels[13].flag = IEEE80211_CHAN_W_IBSS
-		| IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
+	channels[13].flag = IEEE80211_CHAN_W_IBSS |
+		IEEE80211_CHAN_W_ACTIVE_SCAN | IEEE80211_CHAN_W_SCAN;
 	channels[13].antenna_max = 0xff;
 
 	if (rt2x00_rf(&rt2x00dev->chip, RF5225) ||
@@ -2859,9 +2852,9 @@
 				channels[i].chan = 149;
 			channels[i].chan += ((i - 14) * 4);
 			channels[i].freq = ((i - 13) + 1000) * 5;
-			channels[i].flag = IEEE80211_CHAN_W_IBSS
-				| IEEE80211_CHAN_W_ACTIVE_SCAN
-				| IEEE80211_CHAN_W_SCAN;
+			channels[i].flag = IEEE80211_CHAN_W_IBSS |
+				IEEE80211_CHAN_W_ACTIVE_SCAN |
+				IEEE80211_CHAN_W_SCAN;
 			channels[i].antenna_max = 0xff;
 		}
 	}
@@ -3133,6 +3126,7 @@
 	    rt73usb_init_hw_modes(rt2x00dev)) {
 		ERROR("Failed to initialize device.\n");
 		goto exit;
+	}
 
 	if (rt73usb_init_firmware(rt2x00dev)) {
 		ERROR("Failed to load Firmware.\n");
