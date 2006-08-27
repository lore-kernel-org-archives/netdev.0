From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 4/10] rt2x00: add/remove interface fix
Date: Sun, 27 Aug 2006 17:39:13 +0200
Message-ID: <200608271739.13694.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42540 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932106AbWH0PjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:22 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091663nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow correct configuration of the register depending on working mode.
This can only be done by configuring the register before calling
rt2x00_add_interface.

Second fix is to disable the radio when all monitor interfaces
_and_ the non-monitor interface has been removed.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:08:49.000000000 +0200
+++ wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:11:40.000000000 +0200
@@ -2001,10 +2001,6 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2020,6 +2016,19 @@
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2041,15 +2050,25 @@
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2400pci_disable_radio(rt2x00dev);
 }
 
diff -rU3 wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:06:12.000000000 +0200
+++ wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:12:03.000000000 +0200
@@ -2146,10 +2146,6 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2165,6 +2161,19 @@
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2186,15 +2195,25 @@
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2500pci_disable_radio(rt2x00dev);
 }
 
diff -rU3 wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:06:31.000000000 +0200
+++ wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:12:24.000000000 +0200
@@ -1862,10 +1862,6 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -1881,6 +1877,19 @@
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -1902,15 +1911,25 @@
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt2500usb_disable_radio(rt2x00dev);
 }
 
diff -rU3 wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:06:48.000000000 +0200
+++ wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:12:45.000000000 +0200
@@ -2624,10 +2624,6 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2643,6 +2639,19 @@
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2664,15 +2673,25 @@
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt61pci_disable_radio(rt2x00dev);
 }
 
diff -rU3 wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:07:02.000000000 +0200
+++ wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:13:06.000000000 +0200
@@ -2145,10 +2145,6 @@
 	    GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
-
-	rt2x00_add_interface(&rt2x00dev->interface, conf);
-
 	/*
 	 * Enable configuration.
 	 */
@@ -2164,6 +2160,19 @@
 	}
 
 	/*
+	 * Add the new interface.
+	 */
+	rt2x00_add_interface(&rt2x00dev->interface, conf);
+
+	/*
+	 * When this is a non-monitor mode,
+	 * set the INTERFACE_INITIALIZED FLAG to prevent
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		SET_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+
+	/*
 	 * Enable radio when this is the first
 	 * interface that is brought up.
 	 */
@@ -2185,15 +2194,25 @@
 	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		return;
 
+	/*
+	 * Remove the interface.
+	 */
 	rt2x00_remove_interface(&rt2x00dev->interface, conf);
 
-	CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
+	/*
+	 * When this is a non-monitor mode,
+	 * clear the INTERFACE_INITIALIZED FLAG to allow
+	 * new non-monitor interfaces to be added.
+	 */
+	if (conf->type != IEEE80211_IF_TYPE_MNTR)
+		CLEAR_FLAG(rt2x00dev, INTERFACE_INITIALIZED);
 
 	/*
 	 * Disable radio if this was the last interface
 	 * that was working with this device.
 	 */
-	if (!rt2x00dev->interface.monitor_count)
+	if (!rt2x00dev->interface.monitor_count &&
+	    !GET_FLAG(rt2x00dev, INTERFACE_INITIALIZED))
 		rt73usb_disable_radio(rt2x00dev);
 }
 
