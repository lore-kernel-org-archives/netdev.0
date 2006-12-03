From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 23/26] rt2x00: Fix USB packet length and block promisc mode
Date: Sun, 3 Dec 2006 19:18:56 +0100
Message-ID: <200612031918.57180.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18521 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758793AbWLCSTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:15 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144331nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:15 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The length of a packet that needs to be send over a USB device,
needs to have an even length. odd lengths will cause problems.
At the moment there is no solution for the enabling of promisc
mode on usb devices. The function is called from interrupt
context which means the driver cannot access a register.
Scheduling the request is required, but a clean solution
needs to be found.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:21:33.000000000 +0100
+++ wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:28:17.000000000 +0100
@@ -1846,6 +1846,7 @@
 	struct sk_buff *skb_rts;
 	u16 frame_control;
 	int res;
+	int length;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -1903,13 +1904,21 @@
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
+	/*
+	 * Length passed to usb_fill_urb cannot be an odd number,
+	 * so add 1 byte to make it even.
+	 */
+	length = skb->len + ring->desc_size;
+	if (length % 2)
+		length++;
+
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
 		rt2x00_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
-		skb->len + ring->desc_size,
+		length,
 		rt2500usb_interrupt,
 		entry);
 	usb_submit_urb(rt2x00_urb(entry), GFP_ATOMIC);
@@ -2138,9 +2147,11 @@
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (update && !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED_MONITOR))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->interface.work);
+	if (update && !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED_MONITOR)) {
+		NOTICE("For the moment promisc mode is ignored");
+	/*	queue_work(rt2x00dev->workqueue,
+			&rt2x00dev->interface.work);*/
+	}
 }
 
 static void rt2500usb_scan(void *data)
diff -rU3 wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:21:44.000000000 +0100
+++ wireless-dev-usb/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:27:24.000000000 +0100
@@ -2118,6 +2118,7 @@
 	struct sk_buff *skb_rts;
 	u16 frame_control;
 	int res;
+	int length;
 
 	/*
 	 * Determine which ring to put packet on.
@@ -2175,13 +2176,21 @@
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
+	/*
+	 * Length passed to usb_fill_urb cannot be an odd number,
+	 * so add 1 byte to make it even.
+	 */
+	length = skb->len + ring->desc_size;
+	if (length % 2)
+		length++;
+
 	SET_FLAG(entry, ENTRY_OWNER_NIC);
 	usb_fill_bulk_urb(
 		rt2x00_urb(entry),
 		usb_dev,
 		usb_sndbulkpipe(usb_dev, 1),
 		entry->data_addr,
-		skb->len + ring->desc_size,
+		length,
 		rt73usb_interrupt,
 		entry);
 	usb_submit_urb(rt2x00_urb(entry), GFP_ATOMIC);
@@ -2410,9 +2419,11 @@
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (update && !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED_MONITOR))
-		queue_work(rt2x00dev->workqueue,
-			&rt2x00dev->interface.work);
+	if (update && !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED_MONITOR)) {
+		NOTICE("For the moment promisc mode is ignored");
+	/*	queue_work(rt2x00dev->workqueue,
+			&rt2x00dev->interface.work);*/
+	}
 }
 
 static void rt73usb_scan(void *data)
