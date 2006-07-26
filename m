From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/24] RT2x00: Add interface structure
Date: Wed, 26 Jul 2006 19:04:35 +0200
Message-ID: <200607261904.35952.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:46239 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030224AbWGZRHX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 13:07:23 -0400
Received: by nf-out-0910.google.com with SMTP id o25so812592nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 10:07:22 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Move all settings depending on the current association into
a seperate interface structure.
Altough we only support 1 association type at a time,
we do support multiple monitor devices, keep track of the
number using the monitor_count field.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2400pci.c 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-22 23:17:54.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	
2006-07-23 14:54:53.000000000 +0200
@@ -411,7 +411,7 @@
 		rt2x00_set_field32(&reg, RXCSR0_DROP_TODS, 0);
 
 	rt2x00_set_field32(&reg, RXCSR0_DROP_CRC, 1);
-	if (type == IEEE80211_IF_TYPE_MNTR) {
+	if (rt2x00pci->interface.monitor_count) {
 		rt2x00_set_field32(&reg, RXCSR0_DROP_PHYSICAL, 0);
 		rt2x00_set_field32(&reg, RXCSR0_DROP_CONTROL, 0);
 		rt2x00_set_field32(&reg, RXCSR0_DROP_VERSION_ERROR, 0);
@@ -426,7 +426,7 @@
 	/*
 	 * Enable promisc mode when in monitor mode.
 	 */
-	if (type == IEEE80211_IF_TYPE_MNTR)
+	if (rt2x00pci->interface.monitor_count)
 		rt2400pci_config_promisc(rt2x00pci, 1);
 
 	/*
@@ -445,7 +445,7 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00pci->type = type;
+	rt2x00pci->interface.type = type;
 }
 
 static void rt2400pci_config_channel(struct rt2x00_pci *rt2x00pci,
@@ -897,7 +897,7 @@
 	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00pci->interface_id, &beacon);
+		rt2x00pci->interface.id, &beacon);
 	if (!skb)
 		return;
 
@@ -1725,16 +1725,36 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	rt2x00pci->interface_id = conf->if_id;
+	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	rt2x00_add_interface(&rt2x00pci->interface, conf);
 
+	/*
+	 * Enable configuration.
+	 */
+	rt2400pci_config_type(rt2x00pci, conf->type);
 	rt2400pci_config_mac_address(rt2x00pci, conf->mac_addr);
 
-	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+	/*
+	 * In case of master mode, set the BSSID to our MAC.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(&rt2x00pci->interface.bssid, conf->mac_addr, ETH_ALEN);
+		rt2400pci_config_bssid(rt2x00pci, conf->mac_addr);
+	}
+
+	/*
+	 * Enable radio when this is the first
+	 * interface that is brought up.
+	 */
+	if (!GET_FLAG(rt2x00pci, DEVICE_ENABLED_RADIO))
+		return rt2400pci_enable_radio(rt2x00pci);
 
 	return 0;
 }
@@ -1745,14 +1765,22 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (!GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    !GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return;
 
-	rt2x00pci->interface_id = 0;
+	rt2x00_remove_interface(&rt2x00pci->interface, conf);
 
 	CLEAR_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	/*
+	 * Disable radio if this was the last interface
+	 * that was working with this device.
+	 */
+	if (!rt2x00pci->interface.monitor_count)
+		rt2400pci_disable_radio(rt2x00pci);
 }
 
 static void rt2400pci_config_update(void *data)
@@ -1818,15 +1846,20 @@
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
-	rt2400pci_config_type(rt2x00pci, conf->type);
-
 	/*
 	 * When configuring monitor mode, we are done now.
+	 * but if we are configuring another mode it must be
+	 * equal to the interface that has been added.
 	 */
-	if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
+	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
+	else if (conf->type != rt2x00pci->interface.type)
+		return -EINVAL;
 
-	rt2400pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid) {
+		memcpy(&rt2x00pci->interface.bssid, conf->bssid, ETH_ALEN);
+		rt2400pci_config_bssid(rt2x00pci, conf->bssid);
+	}
 
 	return 0;
 }
@@ -1835,21 +1868,27 @@
 	unsigned short flags, int mc_count)
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
+	int update = 0;
+
+	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
+		if (!(flags & IFF_PROMISC)) {
+			rt2x00pci->interface.promisc = 0;
+			update = 1;
+		}
+	} else {
+		if (flags & IFF_PROMISC) {
+			rt2x00pci->interface.promisc = 1;
+			update = 1;
+		}
+	}
 
 	/*
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
-		return;
-
-	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
-		if (!(flags & IFF_PROMISC))
-			rt2400pci_config_promisc(rt2x00pci, 0);
-	} else {
-		if (flags & IFF_PROMISC)
-			rt2400pci_config_promisc(rt2x00pci, 1);
-	}
+	if (update && !rt2x00pci->interface.monitor_count)
+		rt2400pci_config_promisc(rt2x00pci,
+			rt2x00pci->interface.promisc);
 }
 
 static void rt2400pci_scan(void *data)
@@ -2419,6 +2458,11 @@
 	INIT_WORK(&rt2x00pci->config_work, rt2400pci_config_update, rt2x00pci);
 
 	/*
+	 * Reset current working type.
+	 */
+	rt2x00pci->interface.type = -EINVAL;
+
+	/*
 	 * Intialize scanning attributes.
 	 */
 	INIT_WORK(&rt2x00pci->scan_work, rt2400pci_scan, rt2x00pci);
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2500pci.c 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-22 23:18:04.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	
2006-07-23 14:55:00.000000000 +0200
@@ -411,7 +411,7 @@
 		rt2x00_set_field32(&reg, RXCSR0_DROP_TODS, 0);
 
 	rt2x00_set_field32(&reg, RXCSR0_DROP_CRC, 1);
-	if (type == IEEE80211_IF_TYPE_MNTR) {
+	if (rt2x00pci->interface.monitor_count) {
 		rt2x00_set_field32(&reg, RXCSR0_DROP_PHYSICAL, 0);
 		rt2x00_set_field32(&reg, RXCSR0_DROP_CONTROL, 0);
 		rt2x00_set_field32(&reg, RXCSR0_DROP_VERSION_ERROR, 0);
@@ -429,7 +429,7 @@
 	/*
 	 * Enable promisc mode when in monitor mode.
 	 */
-	if (type == IEEE80211_IF_TYPE_MNTR)
+	if (rt2x00pci->interface.monitor_count)
 		rt2500pci_config_promisc(rt2x00pci, 1);
 
 	/*
@@ -448,7 +448,7 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00pci->type = type;
+	rt2x00pci->interface.type = type;
 }
 
 static void rt2500pci_config_channel(struct rt2x00_pci *rt2x00pci,
@@ -976,7 +976,7 @@
 	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00pci->interface_id, &beacon);
+		rt2x00pci->interface.id, &beacon);
 	if (!skb)
 		return;
 
@@ -1850,16 +1850,36 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	rt2x00pci->interface_id = conf->if_id;
+	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	rt2x00_add_interface(&rt2x00pci->interface, conf);
 
+	/*
+	 * Enable configuration.
+	 */
+	rt2500pci_config_type(rt2x00pci, conf->type);
 	rt2500pci_config_mac_address(rt2x00pci, conf->mac_addr);
 
-	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+	/*
+	 * In case of master mode, set the BSSID to our MAC.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(&rt2x00pci->interface.bssid, conf->mac_addr, ETH_ALEN);
+		rt2500pci_config_bssid(rt2x00pci, conf->mac_addr);
+	}
+
+	/*
+	 * Enable radio when this is the first
+	 * interface that is brought up.
+	 */
+	if (!GET_FLAG(rt2x00pci, DEVICE_ENABLED_RADIO))
+		return rt2500pci_enable_radio(rt2x00pci);
 
 	return 0;
 }
@@ -1870,14 +1890,22 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (!GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    !GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return;
 
-	rt2x00pci->interface_id = 0;
+	rt2x00_remove_interface(&rt2x00pci->interface, conf);
 
 	CLEAR_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	/*
+	 * Disable radio if this was the last interface
+	 * that was working with this device.
+	 */
+	if (!rt2x00pci->interface.monitor_count)
+		rt2500pci_disable_radio(rt2x00pci);
 }
 
 static void rt2500pci_config_update(void *data)
@@ -1943,15 +1971,20 @@
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
-	rt2500pci_config_type(rt2x00pci, conf->type);
-
 	/*
 	 * When configuring monitor mode, we are done now.
+	 * but if we are configuring another mode it must be
+	 * equal to the interface that has been added.
 	 */
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
+	else if (conf->type != rt2x00pci->interface.type)
+		return -EINVAL;
 
-	rt2500pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid) {
+		memcpy(&rt2x00pci->interface.bssid, conf->bssid, ETH_ALEN);
+		rt2500pci_config_bssid(rt2x00pci, conf->bssid);
+	}
 
 	return 0;
 }
@@ -1960,21 +1993,27 @@
 	unsigned short flags, int mc_count)
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
+	int update = 0;
+
+	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
+		if (!(flags & IFF_PROMISC)) {
+			rt2x00pci->interface.promisc = 0;
+			update = 1;
+		}
+	} else {
+		if (flags & IFF_PROMISC) {
+			rt2x00pci->interface.promisc = 1;
+			update = 1;
+		}
+	}
 
 	/*
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
-		return;
-
-	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
-		if (!(flags & IFF_PROMISC))
-			rt2500pci_config_promisc(rt2x00pci, 0);
-	} else {
-		if (flags & IFF_PROMISC)
-			rt2500pci_config_promisc(rt2x00pci, 1);
-	}
+	if (update && !rt2x00pci->interface.monitor_count)
+		rt2500pci_config_promisc(rt2x00pci,
+			rt2x00pci->interface.promisc);
 }
 
 static void rt2500pci_scan(void *data)
@@ -2722,6 +2761,11 @@
 	INIT_WORK(&rt2x00pci->config_work, rt2500pci_config_update, rt2x00pci);
 
 	/*
+	 * Reset current working type.
+	 */
+	rt2x00pci->interface.type = -EINVAL;
+
+	/*
 	 * Intialize scanning attributes.
 	 */
 	INIT_WORK(&rt2x00pci->scan_work, rt2500pci_scan, rt2x00pci);
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2500usb.c 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-22 22:53:28.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	
2006-07-23 14:54:29.000000000 +0200
@@ -261,7 +261,7 @@
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DROP_TODS, 0);
 
 	rt2x00_set_field16_nb(&reg, TXRX_CSR2_DROP_CRC, 1);
-	if (type == IEEE80211_IF_TYPE_MNTR) {
+	if (rt2x00usb->interface.monitor_count) {
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DROP_PHYSICAL, 0);
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DROP_CONTROL, 0);
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DROP_VERSION_ERROR, 0);
@@ -276,7 +276,7 @@
 	/*
 	 * Enable promisc mode when in monitor mode.
 	 */
-	if (type == IEEE80211_IF_TYPE_MNTR)
+	if (rt2x00usb->interface.monitor_count)
 		rt2500usb_config_promisc(rt2x00usb, 1);
 
 	/*
@@ -295,7 +295,7 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00usb->type = type;
+	rt2x00usb->interface.type = type;
 }
 
 static void rt2500usb_config_channel(struct rt2x00_usb *rt2x00usb,
@@ -796,7 +796,7 @@
 	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00usb->interface_id, &beacon);
+		rt2x00usb->interface.id, &beacon);
 	if (!skb)
 		return;
 
@@ -1510,16 +1510,36 @@
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	rt2x00usb->interface_id = conf->if_id;
+	SET_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+
+	rt2x00_add_interface(&rt2x00usb->interface, conf);
 
+	/*
+	 * Enable configuration.
+	 */
+	rt2500usb_config_type(rt2x00usb, conf->type);
 	rt2500usb_config_mac_address(rt2x00usb, conf->mac_addr);
 
-	SET_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+	/*
+	 * In case of master mode, set the BSSID to our MAC.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(&rt2x00usb->interface.bssid, conf->mac_addr, ETH_ALEN);
+		rt2500usb_config_bssid(rt2x00usb, conf->mac_addr);
+	}
+
+	/*
+	 * Enable radio when this is the first
+	 * interface that is brought up.
+	 */
+	if (!GET_FLAG(rt2x00usb, DEVICE_ENABLED_RADIO))
+		return rt2500usb_enable_radio(rt2x00usb);
 
 	return 0;
 }
@@ -1530,14 +1550,22 @@
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (!GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    !GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
 		return;
 
-	rt2x00usb->interface_id = 0;
+	rt2x00_remove_interface(&rt2x00usb->interface, conf);
 
 	CLEAR_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+
+	/*
+	 * Disable radio if this was the last interface
+	 * that was working with this device.
+	 */
+	if (!rt2x00usb->interface.monitor_count)
+		rt2500usb_disable_radio(rt2x00usb);
 }
 
 static void rt2500usb_config_update(void *data)
@@ -1598,20 +1626,35 @@
 	return !queue_work(rt2x00usb->workqueue, &rt2x00usb->config_work);
 }
 
+static void rt2500usb_interface_update(void *data)
+{
+	struct rt2x00_usb *rt2x00usb = data;
+
+	rt2500usb_config_bssid(rt2x00usb, &rt2x00usb->interface.bssid[0]);
+	rt2500usb_config_promisc(rt2x00usb, (rt2x00usb->interface.promisc ||
+		rt2x00usb->interface.monitor_count));
+}
+
 static int rt2500usb_config_interface(struct net_device *net_dev, int if_id,
 	struct ieee80211_if_conf *conf)
 {
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
-	rt2500usb_config_type(rt2x00usb, conf->type);
-
 	/*
 	 * When configuring monitor mode, we are done now.
+	 * but if we are configuring another mode it must be
+	 * equal to the interface that has been added.
 	 */
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
+	else if (conf->type != rt2x00usb->interface.type)
+		return -EINVAL;
 
-	rt2500usb_config_bssid(rt2x00usb, conf->bssid);
+	if (conf->bssid) {
+		memcpy(&rt2x00usb->interface.bssid, conf->bssid, ETH_ALEN);
+		return !queue_work(rt2x00usb->workqueue,
+				&rt2x00usb->interface.work);
+	}
 
 	return 0;
 }
@@ -1620,21 +1663,27 @@
 	unsigned short flags, int mc_count)
 {
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
+	int update = 0;
+
+	if (GET_FLAG(rt2x00usb, INTERFACE_PROMISC)) {
+		if (!(flags & IFF_PROMISC)) {
+			rt2x00usb->interface.promisc = 0;
+			update = 1;
+		}
+	} else {
+		if (flags & IFF_PROMISC) {
+			rt2x00usb->interface.promisc = 1;
+			update = 1;
+		}
+	}
 
 	/*
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (rt2x00usb->type == IEEE80211_IF_TYPE_MNTR)
-		return;
-
-	if (GET_FLAG(rt2x00usb, INTERFACE_PROMISC)) {
-		if (!(flags & IFF_PROMISC))
-			rt2500usb_config_promisc(rt2x00usb, 0);
-	} else {
-		if (flags & IFF_PROMISC)
-			rt2500usb_config_promisc(rt2x00usb, 1);
-	}
+	if (update && !rt2x00usb->interface.monitor_count)
+		queue_work(rt2x00usb->workqueue,
+			&rt2x00usb->interface.work);
 }
 
 static void rt2500usb_scan(void *data)
@@ -2326,6 +2375,13 @@
 	 * Initialize cofniguration work.
 	 */
 	INIT_WORK(&rt2x00usb->config_work, rt2500usb_config_update, rt2x00usb);
+	INIT_WORK(&rt2x00usb->interface.work,
+		rt2500usb_interface_update, rt2x00usb);
+
+	/*
+	 * Reset current working type.
+	 */
+	rt2x00usb->interface.type = -EINVAL;
 
 	/*
 	 * Intialize scanning attributes.
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00.h 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-07-23 
14:17:22.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00.h	
2006-07-23 14:24:04.000000000 +0200
@@ -570,6 +570,90 @@
 }
 
 /*
+ * Interface structure
+ * Configuration details about the current interface.
+ */
+struct interface {
+	/*
+	 * Interface identification. The value is assigned
+	 * to us by the 80211 stack, and is used to request
+	 * new beacons.
+	 */
+	int id;
+
+	/*
+	 * Current working type (IEEE80211_IF_TYPE_*).
+	 * This excludes the type IEEE80211_IF_TYPE_MNTR
+	 * since that is counted seperately in the monitor_count
+	 * field.
+	 */
+	int type;
+
+	/*
+	 * BBSID of the AP to associate with.
+	 */
+	u8 bssid[ETH_ALEN];
+
+	/*
+	 * Store the promisc mode for the current interface.
+	 * monitor mode always forces promisc mode to be enabled,
+	 * so we need to store the promisc mode seperately.
+	 */
+	short promisc;
+
+	/*
+	 * Monitor mode count, the number of interfaces
+	 * in monitor mode that that have been added.
+	 */
+	short monitor_count;
+
+	/*
+	 * Sequence number for software controled sequence counters.
+	 */
+	u16 sequence;
+
+	/*
+	 * Work structure in case interface configuration
+	 * requires scheduling.
+	 */
+	struct work_struct work;
+};
+
+static inline void rt2x00_add_interface(struct interface *intf,
+	struct ieee80211_if_init_conf *conf)
+{
+	/*
+	 * We support muliple monitor mode interfaces.
+	 * All we need to do is increase the monitor_count.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
+		intf->monitor_count++;
+	} else {
+		intf->id = conf->if_id;
+		intf->promisc = 0;
+		intf->sequence = 0;
+	}
+}
+
+static inline void rt2x00_remove_interface(struct interface *intf,
+	struct ieee80211_if_init_conf *conf)
+{
+	/*
+	 * We support muliple monitor mode interfaces.
+	 * All we need to do is decrease the monitor_count.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_MNTR) {
+		intf->monitor_count--;
+	} else if (intf->type == conf->type) {
+		intf->id = 0;
+		intf->type = -EINVAL;
+		memset(&intf->bssid, 0x00, ETH_ALEN);
+		intf->promisc = 0;
+		intf->sequence = 0;
+	}
+}
+
+/*
  * Scanning structure.
  * Swithing channel during scanning will be put
  * in a workqueue so we will be able to sleep
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-22 23:04:01.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	
2006-07-23 14:24:46.000000000 +0200
@@ -155,15 +155,9 @@
 	struct workqueue_struct *workqueue;
 
 	/*
-	 * Interface identication required for requesting beacons
-	 * from dscape stack.
+	 * Interface we are connected with.
 	 */
-	int interface_id;
-
-	/*
-	 * Current working mode.
-	 */
-	int type;
+	struct interface interface;
 
 	/*
 	 * EEPROM bus width.
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-22 23:04:13.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt2x00usb.h	
2006-07-23 14:25:07.000000000 +0200
@@ -150,15 +150,9 @@
 	struct workqueue_struct *workqueue;
 
 	/*
-	 * Interface identication required for requesting beacons
-	 * from dscape stack.
+	 * Interface we are connected with.
 	 */
-	int interface_id;
-
-	/*
-	 * Current working mode.
-	 */
-	int type;
+	struct interface interface;
 
 	/*
 	 * Frequency offset (for rt73usb).
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt61pci.c 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-22 
23:19:03.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt61pci.c	
2006-07-23 14:55:07.000000000 +0200
@@ -442,7 +442,7 @@
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_TO_DS, 0);
 
 	rt2x00_set_field32(&reg, TXRX_CSR0_DROP_CRC, 1);
-	if (type == IEEE80211_IF_TYPE_MNTR) {
+	if (rt2x00pci->interface.monitor_count) {
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_PHYSICAL, 0);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_CONTROL, 0);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_VERSION_ERROR, 0);
@@ -460,7 +460,7 @@
 	/*
 	 * Enable promisc mode when in monitor mode.
 	 */
-	if (type == IEEE80211_IF_TYPE_MNTR)
+	if (rt2x00pci->interface.monitor_count)
 		rt61pci_config_promisc(rt2x00pci, 1);
 
 	/*
@@ -479,7 +479,7 @@
 	/*
 	 * Update working mode.
 	 */
-	rt2x00pci->type = type;
+	rt2x00pci->interface.type = type;
 }
 
 static void rt61pci_config_channel(struct rt2x00_pci *rt2x00pci,
@@ -1231,7 +1231,7 @@
 	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00pci->interface_id, &beacon);
+		rt2x00pci->interface.id, &beacon);
 	if (!skb)
 		return;
 
@@ -2305,16 +2305,36 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	rt2x00pci->interface_id = conf->if_id;
+	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	rt2x00_add_interface(&rt2x00pci->interface, conf);
 
+	/*
+	 * Enable configuration.
+	 */
+	rt61pci_config_type(rt2x00pci, conf->type);
 	rt61pci_config_mac_address(rt2x00pci, conf->mac_addr);
 
-	SET_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+	/*
+	 * In case of master mode, set the BSSID to our MAC.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(&rt2x00pci->interface.bssid, conf->mac_addr, ETH_ALEN);
+		rt61pci_config_bssid(rt2x00pci, conf->mac_addr);
+	}
+
+	/*
+	 * Enable radio when this is the first
+	 * interface that is brought up.
+	 */
+	if (!GET_FLAG(rt2x00pci, DEVICE_ENABLED_RADIO))
+		return rt61pci_enable_radio(rt2x00pci);
 
 	return 0;
 }
@@ -2325,14 +2345,22 @@
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (!GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    !GET_FLAG(rt2x00pci, INTERFACE_INITIALIZED))
 		return;
 
-	rt2x00pci->interface_id = 0;
+	rt2x00_remove_interface(&rt2x00pci->interface, conf);
 
 	CLEAR_FLAG(rt2x00pci, INTERFACE_INITIALIZED);
+
+	/*
+	 * Disable radio if this was the last interface
+	 * that was working with this device.
+	 */
+	if (!rt2x00pci->interface.monitor_count)
+		rt61pci_disable_radio(rt2x00pci);
 }
 
 static void rt61pci_config_update(void *data)
@@ -2398,15 +2426,20 @@
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
 
-	rt61pci_config_type(rt2x00pci, conf->type);
-
 	/*
 	 * When configuring monitor mode, we are done now.
+	 * but if we are configuring another mode it must be
+	 * equal to the interface that has been added.
 	 */
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
+	else if (conf->type != rt2x00pci->interface.type)
+		return -EINVAL;
 
-	rt61pci_config_bssid(rt2x00pci, conf->bssid);
+	if (conf->bssid) {
+		memcpy(&rt2x00pci->interface.bssid, conf->bssid, ETH_ALEN);
+		rt61pci_config_bssid(rt2x00pci, conf->bssid);
+	}
 
 	return 0;
 }
@@ -2415,21 +2448,27 @@
 	unsigned short flags, int mc_count)
 {
 	struct rt2x00_pci *rt2x00pci = ieee80211_dev_hw_data(net_dev);
+	int update = 0;
+
+	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
+		if (!(flags & IFF_PROMISC)) {
+			rt2x00pci->interface.promisc = 0;
+			update = 1;
+		}
+	} else {
+		if (flags & IFF_PROMISC) {
+			rt2x00pci->interface.promisc = 1;
+			update = 1;
+		}
+	}
 
 	/*
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (rt2x00pci->type == IEEE80211_IF_TYPE_MNTR)
-		return;
-
-	if (GET_FLAG(rt2x00pci, INTERFACE_PROMISC)) {
-		if (!(flags & IFF_PROMISC))
-			rt61pci_config_promisc(rt2x00pci, 0);
-	} else {
-		if (flags & IFF_PROMISC)
-			rt61pci_config_promisc(rt2x00pci, 1);
-	}
+	if (update && !rt2x00pci->interface.monitor_count)
+		rt61pci_config_promisc(rt2x00pci,
+			rt2x00pci->interface.promisc);
 }
 
 static void rt61pci_scan(void *data)
@@ -3263,6 +3302,11 @@
 	INIT_WORK(&rt2x00pci->config_work, rt61pci_config_update, rt2x00pci);
 
 	/*
+	 * Reset current working type.
+	 */
+	rt2x00pci->interface.type = -EINVAL;
+
+	/*
 	 * Initialize scanning attributes.
 	 */
 	INIT_WORK(&rt2x00pci->scan_work, rt61pci_scan, rt2x00pci);
diff -rU3 wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt73usb.c 
wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-style/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-22 
23:18:51.000000000 +0200
+++ wireless-dev-interface/drivers/net/wireless/d80211/rt2x00/rt73usb.c	
2006-07-23 14:55:15.000000000 +0200
@@ -263,7 +263,7 @@
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_TO_DS, 0);
 
 	rt2x00_set_field32(&reg, TXRX_CSR0_DROP_CRC, 1);
-	if (type == IEEE80211_IF_TYPE_MNTR) {
+	if (rt2x00usb->interface.monitor_count) {
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_PHYSICAL, 0);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_CONTROL, 0);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DROP_VERSION_ERROR, 0);
@@ -281,7 +281,7 @@
 	/*
 	 * Enable promisc mode when in monitor mode.
 	 */
-	if (type == IEEE80211_IF_TYPE_MNTR)
+	if (rt2x00usb->interface.monitor_count)
 		rt73usb_config_promisc(rt2x00usb, 1);
 
 	/*
@@ -296,6 +296,11 @@
 	else
 		rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC_MODE, 0);
 	rt2x00_register_write(rt2x00usb, TXRX_CSR9, reg);
+
+	/*
+	 * Update working mode.
+	 */
+	rt2x00usb->interface.type = type;
 }
 
 static void rt73usb_config_channel(struct rt2x00_usb *rt2x00usb,
@@ -959,7 +964,7 @@
 	memset(&beacon, 0x00, sizeof(beacon));
 
 	skb = ieee80211_beacon_get(ring->net_dev,
-		rt2x00usb->interface_id, &beacon);
+		rt2x00usb->interface.id, &beacon);
 	if (!skb)
 		return;
 
@@ -1804,16 +1809,36 @@
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
 		return -ENOBUFS;
 
-	rt2x00usb->interface_id = conf->if_id;
+	SET_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+
+	rt2x00_add_interface(&rt2x00usb->interface, conf);
 
+	/*
+	 * Enable configuration.
+	 */
+	rt73usb_config_type(rt2x00usb, conf->type);
 	rt73usb_config_mac_address(rt2x00usb, conf->mac_addr);
 
-	SET_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+	/*
+	 * In case of master mode, set the BSSID to our MAC.
+	 */
+	if (conf->type == IEEE80211_IF_TYPE_AP) {
+		memcpy(&rt2x00usb->interface.bssid, conf->mac_addr, ETH_ALEN);
+		rt73usb_config_bssid(rt2x00usb, conf->mac_addr);
+	}
+
+	/*
+	 * Enable radio when this is the first
+	 * interface that is brought up.
+	 */
+	if (!GET_FLAG(rt2x00usb, DEVICE_ENABLED_RADIO))
+		return rt73usb_enable_radio(rt2x00usb);
 
 	return 0;
 }
@@ -1824,14 +1849,22 @@
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
 	/*
-	 * We only support 1 single working mode.
+	 * We only support 1 non-monitor interface.
 	 */
-	if (!GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
+	if (conf->type != IEEE80211_IF_TYPE_MNTR &&
+	    !GET_FLAG(rt2x00usb, INTERFACE_INITIALIZED))
 		return;
 
-	rt2x00usb->interface_id = 0;
+	rt2x00_remove_interface(&rt2x00usb->interface, conf);
 
 	CLEAR_FLAG(rt2x00usb, INTERFACE_INITIALIZED);
+
+	/*
+	 * Disable radio if this was the last interface
+	 * that was working with this device.
+	 */
+	if (!rt2x00usb->interface.monitor_count)
+		rt73usb_disable_radio(rt2x00usb);
 }
 
 static void rt73usb_config_update(void *data)
@@ -1895,20 +1928,35 @@
 	return !queue_work(rt2x00usb->workqueue, &rt2x00usb->config_work);
 }
 
+static void rt73usb_interface_update(void *data)
+{
+	struct rt2x00_usb *rt2x00usb = data;
+
+	rt73usb_config_bssid(rt2x00usb, &rt2x00usb->interface.bssid[0]);
+	rt73usb_config_promisc(rt2x00usb, (rt2x00usb->interface.promisc ||
+		rt2x00usb->interface.monitor_count));
+}
+
 static int rt73usb_config_interface(struct net_device *net_dev, int if_id,
 	struct ieee80211_if_conf *conf)
 {
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
 
-	rt73usb_config_type(rt2x00usb, conf->type);
-
 	/*
 	 * When configuring monitor mode, we are done now.
+	 * but if we are configuring another mode it must be
+	 * equal to the interface that has been added.
 	 */
 	if (conf->type == IEEE80211_IF_TYPE_MNTR)
 		return 0;
+	else if (conf->type != rt2x00usb->interface.type)
+		return -EINVAL;
 
-	rt73usb_config_bssid(rt2x00usb, conf->bssid);
+	if (conf->bssid) {
+		memcpy(&rt2x00usb->interface.bssid, conf->bssid, ETH_ALEN);
+		return !queue_work(rt2x00usb->workqueue,
+				&rt2x00usb->interface.work);
+	}
 
 	return 0;
 }
@@ -1917,21 +1965,27 @@
 	unsigned short flags, int mc_count)
 {
 	struct rt2x00_usb *rt2x00usb = ieee80211_dev_hw_data(net_dev);
+	int update = 0;
+
+	if (GET_FLAG(rt2x00usb, INTERFACE_PROMISC)) {
+		if (!(flags & IFF_PROMISC)) {
+			rt2x00usb->interface.promisc = 0;
+			update = 1;
+		}
+	} else {
+		if (flags & IFF_PROMISC) {
+			rt2x00usb->interface.promisc = 1;
+			update = 1;
+		}
+	}
 
 	/*
 	 * Monitor mode works with PROMISC mode forced on,
 	 * so there is nothing to be done here.
 	 */
-	if (rt2x00usb->type == IEEE80211_IF_TYPE_MNTR)
-		return;
-
-	if (GET_FLAG(rt2x00usb, INTERFACE_PROMISC)) {
-		if (!(flags & IFF_PROMISC))
-			rt73usb_config_promisc(rt2x00usb, 0);
-	} else {
-		if (flags & IFF_PROMISC)
-			rt73usb_config_promisc(rt2x00usb, 1);
-	}
+	if (update && !rt2x00usb->interface.monitor_count)
+		queue_work(rt2x00usb->workqueue,
+			&rt2x00usb->interface.work);
 }
 
 static void rt73usb_scan(void *data)
@@ -2730,6 +2784,13 @@
 	 * Initialize cofniguration work.
 	 */
 	INIT_WORK(&rt2x00usb->config_work, rt73usb_config_update, rt2x00usb);
+	INIT_WORK(&rt2x00usb->interface.work,
+		rt73usb_interface_update, rt2x00usb);
+
+	/*
+	 * Reset current working type.
+	 */
+	rt2x00usb->interface.type = -EINVAL;
 
 	/*
 	 * Intialize scanning attributes.
