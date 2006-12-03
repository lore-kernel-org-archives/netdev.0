From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 22/26] rt2x00: Fix various initialization problems
Date: Sun, 3 Dec 2006 19:18:57 +0100
Message-ID: <200612031918.57702.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758816AbWLCSTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:19 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:18 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Always use kzalloc instead of kmalloc.
Remove duplicate init functions.
And destroy the workqueue before freeing
resources, otherwise a thread on the queue might
still want to access that resource.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:14:07.000000000 +0100
+++ wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-12-03 15:21:22.000000000 +0100
@@ -771,7 +771,7 @@
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
+	ring->entry = kzalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -791,6 +791,7 @@
 	 * addresses.
 	 */
 	for (i = 0; i < ring->stats.limit; i++) {
+		ring->entry[i].flags = 0;
 		ring->entry[i].ring = ring;
 		ring->entry[i].skb = NULL;
 		ring->entry[i].priv = ring->data_addr
@@ -1174,16 +1175,6 @@
 	}
 
 	/*
-	 * Initialize all registers.
-	 */
-	if (rt2400pci_init_rings(rt2x00dev) ||
-	    rt2400pci_init_registers(rt2x00dev) ||
-	    rt2400pci_init_bbp(rt2x00dev)) {
-		ERROR("Register initialization failed.\n");
-		goto exit_fail;
-	}
-
-	/*
 	 * Reset the channel_change_time value
 	 * to make sure it will be correctly initialized
 	 * after the radio has been enabled.
@@ -2677,6 +2668,14 @@
 static void rt2400pci_free_dev(struct rt2x00_dev *rt2x00dev)
 {
 	/*
+	 * Free workqueue.
+	 */
+	if (likely(rt2x00dev->workqueue)) {
+		destroy_workqueue(rt2x00dev->workqueue);
+		rt2x00dev->workqueue = NULL;
+	}
+
+	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -2696,14 +2695,6 @@
 	}
 
 	/*
-	 * Free workqueue.
-	 */
-	if (likely(rt2x00dev->workqueue)) {
-		destroy_workqueue(rt2x00dev->workqueue);
-		rt2x00dev->workqueue = NULL;
-	}
-
-	/*
 	 * Free ieee80211_hw memory.
 	 */
 	if (likely(rt2x00dev->hw->modes)) {
diff -rU3 wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:14:05.000000000 +0100
+++ wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-12-03 15:21:27.000000000 +0100
@@ -864,7 +864,7 @@
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
+	ring->entry = kzalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -884,6 +884,7 @@
 	 * addresses.
 	 */
 	for (i = 0; i < ring->stats.limit; i++) {
+		ring->entry[i].flags = 0;
 		ring->entry[i].ring = ring;
 		ring->entry[i].skb = NULL;
 		ring->entry[i].priv = ring->data_addr
@@ -1299,16 +1300,6 @@
 	}
 
 	/*
-	 * Initialize all registers.
-	 */
-	if (rt2500pci_init_rings(rt2x00dev) ||
-	    rt2500pci_init_registers(rt2x00dev) ||
-	    rt2500pci_init_bbp(rt2x00dev)) {
-		ERROR("Register initialization failed.\n");
-		goto exit_fail;
-	}
-
-	/*
 	 * Reset the channel_change_time value
 	 * to make sure it will be correctly initialized
 	 * after the radio has been enabled.
@@ -2978,6 +2969,14 @@
 static void rt2500pci_free_dev(struct rt2x00_dev *rt2x00dev)
 {
 	/*
+	 * Free workqueue.
+	 */
+	if (likely(rt2x00dev->workqueue)) {
+		destroy_workqueue(rt2x00dev->workqueue);
+		rt2x00dev->workqueue = NULL;
+	}
+
+	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -2997,14 +2996,6 @@
 	}
 
 	/*
-	 * Free workqueue.
-	 */
-	if (likely(rt2x00dev->workqueue)) {
-		destroy_workqueue(rt2x00dev->workqueue);
-		rt2x00dev->workqueue = NULL;
-	}
-
-	/*
 	 * Free ieee80211_hw memory.
 	 */
 	if (likely(rt2x00dev->hw->modes)) {
diff -rU3 wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:14:10.000000000 +0100
+++ wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-12-03 15:21:33.000000000 +0100
@@ -917,7 +917,7 @@
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
+	ring->entry = kzalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -939,6 +939,7 @@
 	 */
 	status = 0;
 	for (i = 0; i < ring->stats.limit; i++) {
+		ring->entry[i].flags = 0;
 		ring->entry[i].ring = ring;
 		ring->entry[i].priv =
 			(!status) ? usb_alloc_urb(0, GFP_KERNEL) : NULL;
@@ -1265,16 +1266,6 @@
 	}
 
 	/*
-	 * Initialize all registers.
-	 */
-	if (rt2500usb_init_rings(rt2x00dev) ||
-	    rt2500usb_init_registers(rt2x00dev) ||
-	    rt2500usb_init_bbp(rt2x00dev)) {
-		ERROR("Register initialization failed.\n");
-		goto exit_fail;
-	}
-
-	/*
 	 * Reset the channel_change_time value
 	 * to make sure it will be correctly initialized
 	 * after the radio has been enabled.
@@ -2803,6 +2794,14 @@
 static void rt2500usb_free_dev(struct rt2x00_dev *rt2x00dev)
 {
 	/*
+	 * Free workqueue.
+	 */
+	if (likely(rt2x00dev->workqueue)) {
+		destroy_workqueue(rt2x00dev->workqueue);
+		rt2x00dev->workqueue = NULL;
+	}
+
+	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -2814,14 +2813,6 @@
 	kfree(rt2x00dev->eeprom);
 
 	/*
-	 * Free workqueue.
-	 */
-	if (likely(rt2x00dev->workqueue)) {
-		destroy_workqueue(rt2x00dev->workqueue);
-		rt2x00dev->workqueue = NULL;
-	}
-
-	/*
 	 * Free ieee80211_hw memory.
 	 */
 	if (likely(rt2x00dev->hw->modes)) {
diff -rU3 wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:14:18.000000000 +0100
+++ wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 15:21:35.000000000 +0100
@@ -1291,7 +1291,7 @@
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
+	ring->entry = kzalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1311,6 +1311,7 @@
 	 * addresses.
 	 */
 	for (i = 0; i < ring->stats.limit; i++) {
+		ring->entry[i].flags = 0;
 		ring->entry[i].ring = ring;
 		ring->entry[i].skb = NULL;
 		ring->entry[i].priv = ring->data_addr
@@ -1738,16 +1739,6 @@
 	}
 
 	/*
-	 * Initialize all registers.
-	 */
-	if (rt61pci_init_rings(rt2x00dev) ||
-	    rt61pci_init_registers(rt2x00dev) ||
-	    rt61pci_init_bbp(rt2x00dev)) {
-		ERROR("Register initialization failed.\n");
-		goto exit_fail;
-	}
-
-	/*
 	 * Reset the channel_change_time value
 	 * to make sure it will be correctly initialized
 	 * after the radio has been enabled.
@@ -3506,6 +3497,14 @@
 static void rt61pci_free_dev(struct rt2x00_dev *rt2x00dev)
 {
 	/*
+	 * Free workqueue.
+	 */
+	if (likely(rt2x00dev->workqueue)) {
+		destroy_workqueue(rt2x00dev->workqueue);
+		rt2x00dev->workqueue = NULL;
+	}
+
+	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -3525,14 +3524,6 @@
 	}
 
 	/*
-	 * Free workqueue.
-	 */
-	if (likely(rt2x00dev->workqueue)) {
-		destroy_workqueue(rt2x00dev->workqueue);
-		rt2x00dev->workqueue = NULL;
-	}
-
-	/*
 	 * Free ieee80211_hw memory.
 	 */
 	if (likely(rt2x00dev->hw->modes)) {
diff -rU3 wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-ringfull/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:14:33.000000000 +0100
+++ wireless-dev-init/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 15:21:44.000000000 +0100
@@ -1149,7 +1149,7 @@
 	/*
 	 * Allocate all ring entries.
 	 */
-	ring->entry = kmalloc(ring->stats.limit * sizeof(struct data_entry),
+	ring->entry = kzalloc(ring->stats.limit * sizeof(struct data_entry),
 		GFP_KERNEL);
 	if (!ring->entry)
 		return -ENOMEM;
@@ -1171,6 +1171,7 @@
 	 */
 	status = 0;
 	for (i = 0; i < ring->stats.limit; i++) {
+		ring->entry[i].flags = 0;
 		ring->entry[i].ring = ring;
 		ring->entry[i].priv =
 			(!status) ? usb_alloc_urb(0, GFP_KERNEL) :  NULL;
@@ -1521,16 +1522,6 @@
 	}
 
 	/*
-	 * Initialize all registers.
-	 */
-	if (rt73usb_init_rings(rt2x00dev) ||
-	    rt73usb_init_registers(rt2x00dev) ||
-	    rt73usb_init_bbp(rt2x00dev)) {
-		ERROR("Register initialization failed.\n");
-		goto exit_fail;
-	}
-
-	/*
 	 * Reset the channel_change_time value
 	 * to make sure it will be correctly initialized
 	 * after the radio has been enabled.
@@ -3147,6 +3138,14 @@
 static void rt73usb_free_dev(struct rt2x00_dev *rt2x00dev)
 {
 	/*
+	 * Free workqueue.
+	 */
+	if (likely(rt2x00dev->workqueue)) {
+		destroy_workqueue(rt2x00dev->workqueue);
+		rt2x00dev->workqueue = NULL;
+	}
+
+	/*
 	 * Free ring structures.
 	 */
 	kfree(rt2x00dev->ring);
@@ -3158,14 +3157,6 @@
 	kfree(rt2x00dev->eeprom);
 
 	/*
-	 * Free workqueue.
-	 */
-	if (likely(rt2x00dev->workqueue)) {
-		destroy_workqueue(rt2x00dev->workqueue);
-		rt2x00dev->workqueue = NULL;
-	}
-
-	/*
 	 * Free ieee80211_hw memory.
 	 */
 	if (likely(rt2x00dev->hw->modes)) {
