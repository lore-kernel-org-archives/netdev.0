From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 2/6] rt2x00 - ieee80211_hw->config no longer requires scheduling
Date: Tue, 8 Aug 2006 15:46:55 +0200
Message-ID: <200608081546.55368.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:39914 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964850AbWHHNrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:25 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175918nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:24 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

d80211 no longer calls ieee80211_hw->config() fom interrupt context.
Make gratefully use of this and remove the workqueue scheduling
for the config changes.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:35:53.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:42:33.000000000 +0200
@@ -2050,11 +2050,10 @@
 		rt2400pci_disable_radio(rt2x00dev);
 }
 
-static void rt2400pci_config_update(void *data)
+static int rt2400pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2085,21 +2084,10 @@
 		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
 		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2400pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
+	} else if (conf->radio_enabled)
+		return rt2400pci_enable_radio(rt2x00dev);
 
-static int rt2400pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt2400pci_config_interface(struct net_device *net_dev, int if_id,
@@ -2798,11 +2786,6 @@
 		goto exit;
 
 	/*
-	 * Initialize cofniguration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2400pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:35:38.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:43:39.000000000 +0200
@@ -2197,11 +2197,10 @@
 		rt2500pci_disable_radio(rt2x00dev);
 }
 
-static void rt2500pci_config_update(void *data)
+static int rt2500pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2233,21 +2232,10 @@
 		rt2x00_register_read(rt2x00dev, RXCSR0, &reg);
 		rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, RXCSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2500pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
+	} else if (conf->radio_enabled)
+		return rt2500pci_enable_radio(rt2x00dev);
 
-static int rt2500pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt2500pci_config_interface(struct net_device *net_dev, int if_id,
@@ -3081,11 +3069,6 @@
 		goto exit;
 
 	/*
-	 * Initialize cofniguration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2500pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 14:18:32.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 14:45:02.000000000 +0200
@@ -1912,12 +1912,10 @@
 		rt2500usb_disable_radio(rt2x00dev);
 }
 
-static void rt2500usb_config_update(void *data)
+static int rt2500usb_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev =
-		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u16 reg;
 
 	/*
@@ -1949,21 +1947,10 @@
 		rt2x00_register_read(rt2x00dev, TXRX_CSR2, &reg);
 		rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR2, reg);
-	} else if (conf->radio_enabled) {
-		if (rt2500usb_enable_radio(rt2x00dev))
-			return;
-	}
-}
+	} else if (conf->radio_enabled)
+		return rt2500usb_enable_radio(rt2x00dev);
 
-static int rt2500usb_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static void rt2500usb_interface_update(void *data)
@@ -2738,9 +2725,8 @@
 		return -ENODEV;
 
 	/*
-	 * Initialize cofniguration work.
+	 * Initialize configuration work.
 	 */
-	INIT_WORK(&rt2x00dev->config_work, rt2500usb_config_update, rt2x00dev);
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt2500usb_interface_update, rt2x00dev);
 
diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-01 19:30:38.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-08 14:45:29.000000000 +0200
@@ -873,11 +873,6 @@
 	struct ieee80211_rx_status rx_params;
 
 	/*
-	 * work structure for configuration changes.
-	 */
-	struct work_struct config_work;
-
-	/*
 	 * Scanning structure.
 	 */
 	struct scanning *scan;
diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:35:44.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:46:43.000000000 +0200
@@ -2675,11 +2675,10 @@
 		rt61pci_disable_radio(rt2x00dev);
 }
 
-static void rt61pci_config_update(void *data)
+static int rt61pci_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2711,21 +2710,10 @@
 		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt61pci_enable_radio(rt2x00dev))
-			return;
-	}
-}
+	} else if (conf->radio_enabled)
+		return rt61pci_enable_radio(rt2x00dev);
 
-static int rt61pci_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static int rt61pci_config_interface(struct net_device *net_dev, int if_id,
@@ -3607,11 +3595,6 @@
 		goto exit;
 
 	/*
-	 * Initialize configuration work.
-	 */
-	INIT_WORK(&rt2x00dev->config_work, rt61pci_config_update, rt2x00dev);
-
-	/*
 	 * Reset current working type.
 	 */
 	rt2x00dev->interface.type = -EINVAL;
diff -rU3 wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-pci/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 14:18:32.000000000 +0200
+++ wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 14:47:36.000000000 +0200
@@ -2195,12 +2195,10 @@
 		rt73usb_disable_radio(rt2x00dev);
 }
 
-static void rt73usb_config_update(void *data)
+static int rt73usb_config(struct net_device *net_dev,
+	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = data;
-	struct net_device *net_dev =
-		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(net_dev);
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 	u32 reg;
 
 	/*
@@ -2232,21 +2230,10 @@
 		rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 		rt2x00_set_field32(&reg, TXRX_CSR0_DISABLE_RX, 0);
 		rt2x00_register_write(rt2x00dev, TXRX_CSR0, reg);
-	} else if (conf->radio_enabled) {
-		if (rt73usb_enable_radio(rt2x00dev))
-			return;
-	}
-}
+	} else if (conf->radio_enabled)
+		return rt73usb_enable_radio(rt2x00dev);
 
-static int rt73usb_config(struct net_device *net_dev,
-	struct ieee80211_conf *conf)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	/*
-	 * Queue work.
-	 */
-	return !queue_work(rt2x00dev->workqueue, &rt2x00dev->config_work);
+	return 0;
 }
 
 static void rt73usb_interface_update(void *data)
@@ -3095,9 +3082,8 @@
 		return -ENODEV;
 
 	/*
-	 * Initialize cofniguration work.
+	 * Initialize configuration work.
 	 */
-	INIT_WORK(&rt2x00dev->config_work, rt73usb_config_update, rt2x00dev);
 	INIT_WORK(&rt2x00dev->interface.work,
 		rt73usb_interface_update, rt2x00dev);
 
