From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] zd1211: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 20:47:40 +0100
Message-ID: <200612152047.41270.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	dsd@gentoo.org, kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51120
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbWLOTsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:48:03 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes compilation for the d80211 hwmode API change.

Signed-off-by: Michael Buesch <mb@bu3sch.de>


Index: jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/zd1211rw/zd_mac.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_mac.c	2006-12-15 20:27:38.000000000 +0100
@@ -521,9 +521,6 @@ struct ieee80211_hw *zd_mac_alloc(struct
 		     IEEE80211_HW_WEP_INCLUDE_IV;
 	dev->maxssi = 100;
 
-	dev->num_modes = 2;
-	dev->modes = mac->modes;
-
 	dev->queues = 1;
 	dev->extra_tx_headroom = sizeof(struct zd_ctrlset);
 
Index: jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/zd1211rw/zd_mac.h	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_mac.h	2006-12-15 20:26:58.000000000 +0100
@@ -137,7 +137,7 @@ struct zd_mac {
 	u8 *hwaddr;
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
-	struct ieee80211_hw_modes modes[2];
+	struct ieee80211_hw_mode modes[2];
 };
 
 static inline struct zd_mac *zd_dev_mac(struct ieee80211_hw *dev)
Index: jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
===================================================================
--- jbenc-dscape.orig/drivers/net/wireless/d80211/zd1211rw/zd_usb.c	2006-12-15 15:58:04.000000000 +0100
+++ jbenc-dscape/drivers/net/wireless/d80211/zd1211rw/zd_usb.c	2006-12-15 20:34:49.000000000 +0100
@@ -1006,7 +1006,7 @@ static int eject_installer(struct usb_in
 
 static int probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
-	int r;
+	int i, r;
 	struct usb_device *udev = interface_to_usbdev(intf);
 	struct ieee80211_hw *dev = NULL;
 
@@ -1064,10 +1064,20 @@ static int probe(struct usb_interface *i
 			 "couldn't register device. Error number %d\n", r);
 		goto error;
 	}
+	for (i = 0; i < 2; i++) {
+		struct zd_mac *mac = zd_dev_mac(dev);
+		r = ieee80211_register_hwmode(dev,
+					      &mac->modes[i]);
+		if (r)
+			goto error_unreg_hw;
+	}
 
 	dev_dbg_f(&intf->dev, "successful\n");
 	dev_info(&intf->dev,"wiphy%d\n", dev->index);
 	return 0;
+
+error_unreg_hw:
+	ieee80211_unregister_hw(dev);
 error:
 	usb_reset_device(interface_to_usbdev(intf));
 	if (dev) {

-- 
Greetings Michael.
