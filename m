From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 11/24] RT2x00: Move scan_work to scanning structure
Date: Wed, 26 Jul 2006 20:27:30 +0200
Message-ID: <200607262027.30929.IvDoorn@gmail.com>
References: <200607261905.12030.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2063 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161013AbWGZS1m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:27:42 -0400
Received: by nf-out-0910.google.com with SMTP id o25so839729nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:27:41 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261905.12030.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Remove scan_work from rt2x00_dev and place it in the scanning structure.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 19:52:17.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 22:41:51.000000000 +0200
@@ -2139,7 +2139,8 @@
 	/*
 	 * Queue work.
 	 */
-	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan_work))
+	INIT_WORK(&rt2x00dev->scan->work, rt2400pci_scan, rt2x00dev);
+	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan->work))
 		goto exit;
 
 	return 0;
@@ -2599,7 +2600,6 @@
 	/*
 	 * Intialize scanning attributes.
 	 */
-	INIT_WORK(&rt2x00dev->scan_work, rt2400pci_scan, rt2x00dev);
 	rt2x00dev->scan = NULL;
 
 	if (rt2400pci_init_eeprom(rt2x00dev) ||
diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 19:52:28.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 22:41:58.000000000 +0200
@@ -2271,7 +2271,8 @@
 	/*
 	 * Queue work.
 	 */
-	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan_work))
+	INIT_WORK(&rt2x00dev->scan->work, rt2500pci_scan, rt2x00dev);
+	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan->work))
 		goto exit;
 
 	return 0;
@@ -2865,7 +2866,6 @@
 	/*
 	 * Intialize scanning attributes.
 	 */
-	INIT_WORK(&rt2x00dev->scan_work, rt2500pci_scan, rt2x00dev);
 	rt2x00dev->scan = NULL;
 
 	if (rt2500pci_init_eeprom(rt2x00dev) ||
diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 19:54:54.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 22:42:03.000000000 +0200
@@ -1942,7 +1942,8 @@
 	/*
 	 * Queue work.
 	 */
-	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan_work))
+	INIT_WORK(&rt2x00dev->scan->work, rt2500usb_scan, rt2x00dev);
+	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan->work))
 		goto exit;
 
 	return 0;
@@ -2481,7 +2482,6 @@
 	/*
 	 * Intialize scanning attributes.
 	 */
-	INIT_WORK(&rt2x00dev->scan_work, rt2500usb_scan, rt2x00dev);
 	rt2x00dev->scan = NULL;
 
 	if (rt2500usb_init_eeprom(rt2x00dev) ||
diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 19:49:00.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 22:32:51.000000000 +0200
@@ -676,6 +676,11 @@
 	short status;
 #define SCANNING_READY		0x0001
 #define SCANNING_CANCELLED	0x0002
+
+	/*
+	 * Work structure for scheduling the scanning work.
+	 */
+	struct work_struct work;
 };
 
 /*
diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 19:53:45.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 22:42:09.000000000 +0200
@@ -2764,7 +2764,8 @@
 	/*
 	 * Queue work.
 	 */
-	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan_work))
+	INIT_WORK(&rt2x00dev->scan->work, rt61pci_scan, rt2x00dev);
+	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan->work))
 		goto exit;
 
 	return 0;
@@ -3438,7 +3439,6 @@
 	/*
 	 * Initialize scanning attributes.
 	 */
-	INIT_WORK(&rt2x00dev->scan_work, rt61pci_scan, rt2x00dev);
 	rt2x00dev->scan = NULL;
 
 	if (rt61pci_init_eeprom(rt2x00dev) ||
diff -rU3 wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-sequence/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 19:54:16.000000000 +0200
+++ wireless-dev-scan/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 22:35:17.000000000 +0200
@@ -2266,7 +2266,8 @@
 	/*
 	 * Queue work.
 	 */
-	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan_work))
+	INIT_WORK(&rt2x00dev->scan->work, rt73usb_scan, rt2x00dev);
+	if (!queue_work(rt2x00dev->workqueue, &rt2x00dev->scan->work))
 		goto exit;
 
 	return 0;
@@ -2910,7 +2911,6 @@
 	/*
 	 * Intialize scanning attributes.
 	 */
-	INIT_WORK(&rt2x00dev->scan_work, rt73usb_scan, rt2x00dev);
 	rt2x00dev->scan = NULL;
 
 	if (rt73usb_init_eeprom(rt2x00dev) ||
