From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 13/26] rt2x00: RX rate conversion
Date: Sun, 3 Dec 2006 19:19:01 +0100
Message-ID: <200612031919.01833.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:57177 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758881AbWLCSTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:30 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144387nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:28 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Each received packet has a signal field, this field
can be translated into the rate with which the frame
has been received.
Create a seperate function for this since the
conversion is equal for all drivers.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 13:45:34.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 13:49:47.000000000 +0100
@@ -1571,6 +1571,11 @@
 			memcpy(skb_put(skb, size), rt2x00_data_addr(entry),
 				size);
 
+			rt2x00dev->rx_params.rate = device_signal_to_rate(
+				&rt2x00dev->hw->modes[0],
+				rt2x00_get_field32(word2, RXD_W2_SIGNAL),
+				0);
+
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word2, RXD_W2_RSSI);
 
diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 13:46:02.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 13:52:24.000000000 +0100
@@ -1728,6 +1728,11 @@
 			memcpy(skb_put(skb, size), rt2x00_data_addr(entry),
 				size);
 
+			rt2x00dev->rx_params.rate = device_signal_to_rate(
+				&rt2x00dev->hw->modes[0],
+				rt2x00_get_field32(word2, RXD_W2_SIGNAL),
+				rt2x00_get_field32(word0, RXD_W0_OFDM));
+
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word2, RXD_W2_RSSI);
 
diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 13:46:16.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 13:52:23.000000000 +0100
@@ -1683,6 +1683,11 @@
 			memcpy(skb_put(skb, size),
 				rt2x00_rxdata_addr(entry), size);
 
+			rt2x00dev->rx_params.rate = device_signal_to_rate(
+				&rt2x00dev->hw->modes[0],
+				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
+				rt2x00_get_field32(word0, RXD_W0_OFDM));
+
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:42:23.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-12-03 13:48:57.000000000 +0100
@@ -1118,6 +1118,39 @@
 	entry->min_rssi_ack_delta = 0;
 }
 
+static inline int device_signal_to_rate(struct ieee80211_hw_modes *mode,
+	u8 signal, u8 ofdm)
+{
+	unsigned int i;
+	u8 plcp;
+	u8 rate;
+
+	for (i = 0; i < mode->num_rates; i++) {
+		/*
+		 * When frame was received with an OFDM bitrate,
+		 * the signal is the PLCP value. If it was received with
+		 * a CCK bitrate the signal is the rate in 0.5kbit/s.
+		 */
+		if (!ofdm) {
+			rate = DEVICE_GET_RATE_FIELD(mode->rates[i].val, RATE);
+			if (rate == signal)
+				return mode->rates[i].val;
+		} else {
+			plcp = DEVICE_GET_RATE_FIELD(mode->rates[i].val, PLCP);
+			if (plcp == signal) {
+				/*
+				 * Check for preamble bit.
+				 */
+				if (signal & 0x08)
+					return mode->rates[i].val2;
+				return mode->rates[i].val;
+			}
+		}
+	}
+
+	return 0;
+}
+
 /*
  * Sequence number handlers.
  */
diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:46:30.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 13:52:24.000000000 +0100
@@ -2185,6 +2185,11 @@
 			memcpy(skb_put(skb, size), rt2x00_data_addr(entry),
 				size);
 
+			rt2x00dev->rx_params.rate = device_signal_to_rate(
+				&rt2x00dev->hw->modes[0],
+				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
+				rt2x00_get_field32(word0, RXD_W0_OFDM));
+
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
diff -rU3 wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:46:42.000000000 +0100
+++ wireless-dev-signal/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 13:52:23.000000000 +0100
@@ -1964,6 +1964,11 @@
 			memcpy(skb_put(skb, size),
 				rt2x00_data_addr(entry), size);
 
+			rt2x00dev->rx_params.rate = device_signal_to_rate(
+				&rt2x00dev->hw->modes[0],
+				rt2x00_get_field32(word1, RXD_W1_SIGNAL),
+				rt2x00_get_field32(word0, RXD_W0_OFDM));
+
 			rt2x00dev->rx_params.ssi =
 				rt2x00_get_field32(word1, RXD_W1_RSSI);
 
