From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 21/26] rt2x00: Fix txdone race condition
Date: Sun, 3 Dec 2006 19:18:57 +0100
Message-ID: <200612031918.58175.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758820AbWLCSTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:23 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:22 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Always call ieee80211_wake_queue if the ring
is not full after the txrun. The ieee80211_wake_queue
is responsible for chacking if the queue was stopped
or not.
The current implementation of checking the ring_full
before the txdone run was flawed and race conditions
could occur that blocked all tx handling.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:09:41.000000000 +0100
+++ wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:14:07.000000000 +0100
@@ -1613,14 +1613,8 @@
 	u32 word;
 	int tx_status;
 	int ack;
-	int ring_full;
 	int rts;
 
-	/*
-	 * Store the current status of the ring.
-	 */
-	ring_full = rt2x00_ring_full(ring);
-
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
 		txd = rt2x00_desc_addr(entry);
@@ -1687,7 +1681,7 @@
 	 * is reenabled when the txdone handler has finished.
 	 */
 	entry = ring->entry;
-	if (ring_full && !rt2x00_ring_full(ring))
+	if (!rt2x00_ring_full(ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
diff -rU3 wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:09:55.000000000 +0100
+++ wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:14:05.000000000 +0100
@@ -1776,14 +1776,8 @@
 	u32 word;
 	int tx_status;
 	int ack;
-	int ring_full;
 	int rts;
 
-	/*
-	 * Store the current status of the ring.
-	 */
-	ring_full = rt2x00_ring_full(ring);
-
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
 		txd = rt2x00_desc_addr(entry);
@@ -1850,7 +1844,7 @@
 	 * is reenabled when the txdone handler has finished.
 	 */
 	entry = ring->entry;
-	if (ring_full && !rt2x00_ring_full(ring))
+	if (!rt2x00_ring_full(ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
diff -rU3 wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:10:04.000000000 +0100
+++ wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:14:10.000000000 +0100
@@ -1753,14 +1753,8 @@
 	struct urb *urb;
 	u32 word;
 	int ack;
-	int ring_full;
 	int rts;
 
-	/*
-	 * Store the current status of the ring.
-	 */
-	ring_full = rt2x00_ring_full(ring);
-
 	 while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
 		txd = rt2x00_txdesc_addr(entry);
@@ -1821,7 +1815,7 @@
 	 * is reenabled when the txdone handler has finished.
 	 */
 	entry = ring->entry;
-	if (ring_full && !rt2x00_ring_full(ring))
+	if (!rt2x00_ring_full(ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
diff -rU3 wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:10:28.000000000 +0100
+++ wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:14:18.000000000 +0100
@@ -2235,7 +2235,6 @@
 	u32 word;
 	int tx_status;
 	int ack;
-	int ring_full;
 	int rts;
 
 	txd = rt2x00_desc_addr(entry);
@@ -2285,11 +2284,6 @@
 	CLEAR_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = NULL;
 
-	/*
-	 * Store the current status of the ring.
-	 */
-	ring_full = rt2x00_ring_full(entry->ring);
-
 	rt2x00_ring_index_done_inc(entry->ring);
 
 	/*
@@ -2297,7 +2291,8 @@
 	 * we must make sure the packet queue in the d80211 stack
 	 * is reenabled when the txdone handler has finished.
 	 */
-	if (ring_full && !rt2x00_ring_full(entry->ring))
+	entry = ring->entry;
+	if (!rt2x00_ring_full(ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
diff -rU3 wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-led/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 14:52:44.000000000 +0100
+++ wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:14:33.000000000 +0100
@@ -2026,14 +2026,8 @@
 	struct urb *urb;
 	u32 word;
 	int ack;
-	int ring_full;
 	int rts;
 
-	/*
-	 * Store the current status of the ring.
-	 */
-	ring_full = rt2x00_ring_full(ring);
-
 	while (!rt2x00_ring_empty(ring)) {
 		entry = rt2x00_get_data_entry_done(ring);
 		txd = rt2x00_desc_addr(entry);
@@ -2096,7 +2090,7 @@
 	 * is reenabled when the txdone handler has finished.
 	 */
 	entry = ring->entry;
-	if (ring_full && !rt2x00_ring_full(ring))
+	if (!rt2x00_ring_full(ring))
 		ieee80211_wake_queue(rt2x00dev->hw,
 			entry->tx_status.control.queue);
 }
