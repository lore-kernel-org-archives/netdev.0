From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 10/24] RT2x00: Add software and hardware sequence counting
Date: Wed, 26 Jul 2006 19:05:08 +0200
Message-ID: <200607261905.08494.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030310AbWGZRHe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:34 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:33 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Add software sequence number counting to rt2400pci and rt2500pci,
enable hardware sequence number counting for rt2500usb, rt61pci and rt73usb.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 
19:36:40.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-23 19:52:17.000000000 +0200
@@ -1682,6 +1682,11 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * Set the software sequence number.
+	 */
+	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
+
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
@@ -2275,6 +2280,11 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
+	/*
+	 * Set the software sequence number.
+	 */
+	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
+
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, entry->desc_addr, skb, control);
 
diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 
19:33:46.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-23 19:52:28.000000000 +0200
@@ -1817,6 +1817,11 @@
 		return NETDEV_TX_BUSY;
 	}
 
+	/*
+	 * Set the software sequence number.
+	 */
+	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
+
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
@@ -2401,6 +2406,11 @@
 	 */
 	control->queue = IEEE80211_TX_QUEUE_BEACON;
 
+	/*
+	 * Set the software sequence number.
+	 */
+	rt2x00_set_sequence(skb, &rt2x00dev->interface.sequence);
+
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, entry->desc_addr, skb, control);
 
diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 
19:36:18.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-23 19:54:54.000000000 +0200
@@ -1385,7 +1385,7 @@
 	rt2x00_register_write(rt2x00dev, MAC_CSR18, reg);
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
-	rt2x00_set_field16_nb(&reg, TXRX_CSR1_AUTO_SEQUENCE, 0x00);
+	rt2x00_set_field16_nb(&reg, TXRX_CSR1_AUTO_SEQUENCE, 1);
 	rt2x00_register_write(rt2x00dev, TXRX_CSR1, reg);
 
 	rt2x00_register_read(rt2x00dev, PHY_CSR4, &reg);
diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 
18:09:00.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-23 19:49:00.000000000 +0200
@@ -911,6 +911,50 @@
 }
 
 /*
+ * Sequence number handlers.
+ */
+static inline int rt2x00_require_sequence(struct ieee80211_hdr *ieee80211hdr)
+{
+	/*
+	 * Check if the packet has a header
+	 * that contains a seq_ctrl field.
+	 */
+	if (ieee80211_get_hdrlen(
+		le16_to_cpu(ieee80211hdr->frame_control)) >= IEEE80211_HEADER)
+		return 1;
+	return 0;
+}
+
+static inline void rt2x00_set_sequence(struct sk_buff *skb, u16 *seq)
+{
+	struct ieee80211_hdr *ieee80211hdr =
+		(struct ieee80211_hdr*)skb->data;
+
+	/*
+	 * Only attach the sequence number, when
+	 * the buffer requires it.
+	 */
+	if (!rt2x00_require_sequence(ieee80211hdr))
+		return;
+
+	/*
+	 * Set the sequence number for this frame,
+	 * but do not change the fragment number.
+	 */
+	ieee80211hdr->seq_ctrl |= cpu_to_le16((*seq << 4) & 0xfff0);
+
+	/*
+	 * Since the dscape stack sends all packets and
+	 * fragments individually, we need to check if there
+	 * will be new fragments following.
+	 * If this is the last or only fragment, the sequence
+	 * counter should be increased.
+	 */
+	if (!ieee80211_get_morefrag(ieee80211hdr))
+		*seq = (*seq + 1) & 0x0fff;
+}
+
+/*
  * Duration calculations
  * The rate variable passed is: 100kbs.
  * To convert from bytes to bits we multiply size with 8,
diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 
19:34:27.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-23 19:53:45.000000000 +0200
@@ -1321,7 +1321,10 @@
 		rt2x00_set_field32(&txd->word1,
 			TXD_W1_HOST_Q_ID, control->queue);
 
-	rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 0);
+	if (rt2x00_require_sequence(ieee80211hdr))
+		rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 1);
+	else
+		rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 0);
 
 	rt2x00_set_field32(&txd->word1, TXD_W1_AIFSN, ring->tx_params.aifs);
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMIN, ring->tx_params.cw_min);
@@ -2113,6 +2116,10 @@
 	rt2x00_set_field32(&reg, MAC_CSR9_CW_SELECT, 0);
 	rt2x00_register_write(rt2x00dev, MAC_CSR9, reg);
 
+	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+	rt2x00_set_field32(&reg, TXRX_CSR0_AUTO_TX_SEQ, 1);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+
 	rt2x00_register_write(rt2x00dev, PHY_CSR1, cpu_to_le32(0x000023b0));
 	rt2x00_register_write(rt2x00dev, PHY_CSR5, cpu_to_le32(0x060a100c));
 	rt2x00_register_write(rt2x00dev, PHY_CSR6, cpu_to_le32(0x00080606));
diff -rU3 wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 
19:33:08.000000000 +0200
+++ wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-23 19:54:16.000000000 +0200
@@ -1038,7 +1038,10 @@
 		rt2x00_set_field32(&txd->word1,
 			TXD_W1_HOST_Q_ID, control->queue);
 
-	rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 0);
+	if (rt2x00_require_sequence(ieee80211hdr))
+		rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 1);
+	else
+		rt2x00_set_field32(&txd->word1, TXD_W1_HW_SEQUENCE, 0);
 
 	rt2x00_set_field32(&txd->word1, TXD_W1_AIFSN, ring->tx_params.aifs);
 	rt2x00_set_field32(&txd->word1, TXD_W1_CWMIN, ring->tx_params.cw_min);
@@ -1682,6 +1685,10 @@
 	rt2x00_set_field32(&reg, MAC_CSR9_CW_SELECT, 0);
 	rt2x00_register_write(rt2x00dev, MAC_CSR9, reg);
 
+	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
+	rt2x00_set_field32(&reg, TXRX_CSR0_AUTO_TX_SEQ, 1);
+	rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
+
 	/*
 	 * We must clear the error counters.
 	 * These registers are cleared on read,
