From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 5/6] rt2x00 - scan handlers
Date: Tue, 8 Aug 2006 15:46:57 +0200
Message-ID: <200608081546.57183.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:28394 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964878AbWHHNr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:28 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175926nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:27 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move scan structure initialization and handling into
some generic handlers in rt2x00.h.
This also fixed some obscure coding when waiting for the
empty txrings before starting a scan.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:55:51.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 15:09:24.000000000 +0200
@@ -1381,10 +1381,8 @@
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1802,10 +1800,8 @@
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2153,14 +2149,7 @@
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2232,13 +2221,7 @@
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:56:52.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 15:10:31.000000000 +0200
@@ -1501,10 +1501,8 @@
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1949,10 +1947,8 @@
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2301,14 +2297,7 @@
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2376,13 +2365,7 @@
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 14:57:42.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 15:12:02.000000000 +0200
@@ -1264,10 +1264,8 @@
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -1713,10 +1711,8 @@
 	if (rt2x00dev->scan &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_TX]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_ATIM]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2026,14 +2022,7 @@
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2101,13 +2090,7 @@
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 14:45:29.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 15:12:43.000000000 +0200
@@ -734,7 +734,8 @@
 	 * Flag to see if this scan has been cancelled.
 	 */
 	short status;
-#define SCANNING_READY		0x0001
+#define SCANNING_READY		0x0000
+#define SCANNING_WAITING	0x0001
 #define SCANNING_CANCELLED	0x0002
 
 	/*
@@ -743,6 +744,48 @@
 	struct work_struct work;
 };
 
+static inline void rt2x00_start_scan(struct scanning *scan,
+	struct ieee80211_scan_conf *conf, int state)
+{
+	init_completion(&scan->completion);
+
+	memcpy(&scan->conf, conf, sizeof(*conf));
+
+	scan->state = state;
+
+	/*
+	 * Set initial status to SCANNING_WAITING to prevent scanning
+	 * to begin while there are still TX packets queued.
+	 */
+	scan->status = SCANNING_WAITING;
+}
+
+static inline void rt2x00_signal_scan(struct scanning *scan, short status)
+{
+	scan->status = status;
+
+	complete_all(&scan->completion);
+}
+
+static inline int rt2x00_wait_scan(struct scanning *scan)
+{
+	/*
+	 * Only wait for completion when the status
+	 * indicates we should. The SCANNING_READY
+	 * and SCANNING_CANCELLED are both states
+	 * which indicate complete_all has already
+	 * been called.
+	 */
+	if (scan->status == SCANNING_WAITING)
+		wait_for_completion(&scan->completion);
+
+	/*
+	 * Status field will have been updated by the handler
+	 * that has called complete_all() on our complete structure.
+	 */
+	return scan->status;
+}
+
 /*
  * rt2x00 device structure.
  */
diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:59:09.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 15:14:45.000000000 +0200
@@ -1927,10 +1927,8 @@
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -2449,10 +2447,8 @@
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 }
 
 static irqreturn_t rt61pci_interrupt(int irq, void *dev_instance,
@@ -2779,14 +2775,7 @@
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2854,13 +2843,7 @@
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
diff -rU3 wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-txpower/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 15:00:03.000000000 +0200
+++ wireless-dev-rt2x00-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 15:15:57.000000000 +0200
@@ -1525,10 +1525,8 @@
 	/*
 	 * Cancel scanning.
 	 */
-	if (rt2x00dev->scan) {
-		rt2x00dev->scan->status = SCANNING_CANCELLED;
-		complete_all(&rt2x00dev->scan->completion);
-	}
+	if (rt2x00dev->scan)
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_CANCELLED);
 
 	/*
 	 * Flush out all pending work.
@@ -2000,10 +1998,8 @@
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_BE]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VI]) &&
 	    rt2x00_ring_empty(&rt2x00dev->ring[RING_AC_VO]) &&
-	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO])) {
-		rt2x00dev->scan->status = SCANNING_READY;
-		complete(&rt2x00dev->scan->completion);
-	}
+	    rt2x00_ring_empty(&rt2x00dev->ring[RING_PRIO]))
+		rt2x00_signal_scan(rt2x00dev->scan, SCANNING_READY);
 
 	/*
 	 * If the data ring was full before the txdone handler
@@ -2309,14 +2305,7 @@
 	 * we need to wait untill all TX rings are empty to
 	 * guarentee that all frames are send on the correct channel.
 	 */
-	if (rt2x00dev->scan->status != SCANNING_READY)
-		wait_for_completion(&rt2x00dev->scan->completion);
-
-	/*
-	 * Check if this scan has been cancelled while
-	 * work was still scheduled.
-	 */
-	if (rt2x00dev->scan->status == SCANNING_CANCELLED)
+	if (rt2x00_wait_scan(rt2x00dev->scan))
 		goto exit;
 
 	/*
@@ -2384,13 +2373,7 @@
 	/*
 	 * Initialize Scanning structure.
 	 */
-	init_completion(&rt2x00dev->scan->completion);
-
-	memcpy(&rt2x00dev->scan->conf, conf, sizeof(*conf));
-
-	rt2x00dev->scan->state = state;
-
-	rt2x00dev->scan->status = 0;
+	rt2x00_start_scan(rt2x00dev->scan, conf, state);
 
 	/*
 	 * Queue work.
