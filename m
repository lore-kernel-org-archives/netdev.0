From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 21/24] RT2x00: Correctly initialize tx_status->control field before packet transmission
Date: Wed, 26 Jul 2006 20:31:01 +0200
Message-ID: <200607262031.01898.IvDoorn@gmail.com>
References: <200607261905.50524.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161020AbWGZSbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:31:13 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:31:13 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.50524.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

The control field inside the tx_status field of each entry
should be correctly initialized when a packet is queued.
We can use the same field to pass it to dscape when updating the beacon.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-26 10:46:52.000000000 +0200
+++ wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-26 10:55:31.000000000 +0200
@@ -1587,17 +1587,16 @@
 {
 	struct data_ring *ring = data;
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct data_entry *entry = rt2x00_get_data_entry(
+		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
-	struct ieee80211_tx_control beacon;
-
-	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00dev->interface.id, &beacon);
+		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt2400pci_beacon_update(ring->net_dev, skb, &beacon);
+	rt2400pci_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -1881,6 +1880,7 @@
 
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	memcpy(&entry->tx_status.control, control, sizeof(*control));
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
diff -rU3 wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-26 10:46:48.000000000 +0200
+++ wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-26 10:56:10.000000000 +0200
@@ -1712,17 +1712,16 @@
 {
 	struct data_ring *ring = data;
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct data_entry *entry = rt2x00_get_data_entry(
+		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
-	struct ieee80211_tx_control beacon;
-
-	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00dev->interface.id, &beacon);
+		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt2500pci_beacon_update(ring->net_dev, skb, &beacon);
+	rt2500pci_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -2016,6 +2015,7 @@
 
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	memcpy(&entry->tx_status.control, control, sizeof(*control));
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
diff -rU3 wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-26 10:46:32.000000000 +0200
+++ wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-26 10:56:11.000000000 +0200
@@ -1447,17 +1447,16 @@
 {
 	struct data_ring *ring = data;
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct data_entry *entry = rt2x00_get_data_entry(
+		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
-	struct ieee80211_tx_control beacon;
-
-	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00dev->interface.id, &beacon);
+		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt2500usb_beacon_update(ring->net_dev, skb, &beacon);
+	rt2500usb_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -1715,6 +1714,7 @@
 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
+	memcpy(&entry->tx_status.control, control, sizeof(*control));
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
diff -rU3 wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 10:46:44.000000000 +0200
+++ wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-26 10:56:17.000000000 +0200
@@ -2169,17 +2169,16 @@
 {
 	struct data_ring *ring = data;
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct data_entry *entry = rt2x00_get_data_entry(
+		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
-	struct ieee80211_tx_control beacon;
-
-	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00dev->interface.id, &beacon);
+		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt61pci_beacon_update(ring->net_dev, skb, &beacon);
+	rt61pci_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -2527,6 +2526,7 @@
 
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
+	memcpy(&entry->tx_status.control, control, sizeof(*control));
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
diff -rU3 wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-setnetdev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 10:46:22.000000000 +0200
+++ wireless-dev-control/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-26 10:56:20.000000000 +0200
@@ -1761,17 +1761,16 @@
 {
 	struct data_ring *ring = data;
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct data_entry *entry = rt2x00_get_data_entry(
+		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
-	struct ieee80211_tx_control beacon;
-
-	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00dev->interface.id, &beacon);
+		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt73usb_beacon_update(ring->net_dev, skb, &beacon);
+	rt73usb_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -2030,6 +2029,7 @@
 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
+	memcpy(&entry->tx_status.control, control, sizeof(*control));
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
