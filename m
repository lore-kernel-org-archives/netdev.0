From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 4/24] RT2x00: Add ethtool support
Date: Wed, 26 Jul 2006 20:23:15 +0200
Message-ID: <200607262023.15645.IvDoorn@gmail.com>
References: <200607261904.45076.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:48887 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751745AbWGZSX2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 14:23:28 -0400
Received: by nf-out-0910.google.com with SMTP id o25so838661nfa
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2006 11:23:26 -0700 (PDT)
To: netdev@vger.kernel.org
In-Reply-To: <200607261904.45076.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From Ivo van Doorn <IvDoorn@gmail.com>

Add ethtool support.
At the moment we support the following features:
* read driver info
* read registers
* read eeprom
* enable and disable debug output

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 15:53:06.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-07-23 16:30:58.000000000 +0200
@@ -33,7 +33,9 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -362,6 +364,79 @@
 #endif /* CONFIG_RT2400PCI_BUTTON */
 
 /*
+ * Ethtool handlers.
+ */
+static void rt2400pci_get_drvinfo(struct net_device *net_dev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
+	drvinfo->eedump_len = EEPROM_SIZE;
+	drvinfo->regdump_len = CSR_REG_SIZE;
+}
+
+static int rt2400pci_get_regs_len(struct net_device *net_dev)
+{
+	return CSR_REG_SIZE;
+}
+
+static void rt2400pci_get_regs(struct net_device *net_dev,
+	struct ethtool_regs *regs, void *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
+	regs->version = *((u32*)data);
+	regs->len = CSR_REG_SIZE;
+}
+
+#ifdef CONFIG_RT2400PCI_DEBUG
+static u32 rt2400pci_get_msglevel(struct net_device *net_dev)
+{
+	return rt2x00_debug_level;
+}
+
+static void rt2400pci_set_msglevel(struct net_device *net_dev, u32 msg)
+{
+	rt2x00_debug_level = !!msg;
+}
+#endif /* CONFIG_RT2400PCI_DEBUG */
+
+static int rt2400pci_get_eeprom_len(struct net_device *net_dev)
+{
+	return EEPROM_SIZE;
+}
+
+static int rt2400pci_get_eeprom(struct net_device *net_dev,
+	struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	eeprom->magic = 0xbad;
+
+	rt2x00_eeprom_multiread(rt2x00dev,
+		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+
+	return 0;
+}
+
+static struct ethtool_ops rt2400pci_ethtool_ops = {
+	.get_drvinfo	= rt2400pci_get_drvinfo,
+	.get_regs_len	= rt2400pci_get_regs_len,
+	.get_regs	= rt2400pci_get_regs,
+#ifdef CONFIG_RT2400PCI_DEBUG
+	.get_msglevel	= rt2400pci_get_msglevel,
+	.set_msglevel	= rt2400pci_set_msglevel,
+#endif /* CONFIG_RT2400PCI_DEBUG */
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= rt2400pci_get_eeprom_len,
+	.get_eeprom	= rt2400pci_get_eeprom,
+};
+
+/*
  * Configuration handlers.
  */
 static void rt2400pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2582,6 +2657,8 @@
 		goto exit_release_regions;
 	}
 
+	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
+
 	pci_set_drvdata(pci_dev, net_dev);
 
 	status = rt2400pci_initialize(pci_dev, net_dev);
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-07-22 23:05:16.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-07-23 16:34:46.000000000 +0200
@@ -39,6 +39,14 @@
 #define RF2421				0x0001
 
 /*
+ * Register layout information.
+ */
+#define CSR_REG_BASE			0x0000
+#define CSR_REG_SIZE			0x014c
+#define EEPROM_BASE			0x0000
+#define EEPROM_SIZE			0x00ff
+
+/*
  * Control/Status Registers(CSR).
  * Some values are set in TU, whereas 1 TU == 1024 us.
  */
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 15:53:09.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-07-23 16:31:10.000000000 +0200
@@ -33,7 +33,9 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -362,6 +364,79 @@
 #endif /* CONFIG_RT2500PCI_BUTTON */
 
 /*
+ * Ethtool handlers.
+ */
+static void rt2500pci_get_drvinfo(struct net_device *net_dev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
+	drvinfo->eedump_len = EEPROM_SIZE;
+	drvinfo->regdump_len = CSR_REG_SIZE;
+}
+
+static int rt2500pci_get_regs_len(struct net_device *net_dev)
+{
+	return CSR_REG_SIZE;
+}
+
+static void rt2500pci_get_regs(struct net_device *net_dev,
+	struct ethtool_regs *regs, void *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
+	regs->version = *((u32*)data);
+	regs->len = CSR_REG_SIZE;
+}
+
+#ifdef CONFIG_RT2500PCI_DEBUG
+static u32 rt2500pci_get_msglevel(struct net_device *net_dev)
+{
+	return rt2x00_debug_level;
+}
+
+static void rt2500pci_set_msglevel(struct net_device *net_dev, u32 msg)
+{
+	rt2x00_debug_level = !!msg;
+}
+#endif /* CONFIG_RT2500PCI_DEBUG */
+
+static int rt2500pci_get_eeprom_len(struct net_device *net_dev)
+{
+	return EEPROM_SIZE;
+}
+
+static int rt2500pci_get_eeprom(struct net_device *net_dev,
+	struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	eeprom->magic = 0xbad;
+
+	rt2x00_eeprom_multiread(rt2x00dev,
+		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+
+	return 0;
+}
+
+static struct ethtool_ops rt2500pci_ethtool_ops = {
+	.get_drvinfo	= rt2500pci_get_drvinfo,
+	.get_regs_len	= rt2500pci_get_regs_len,
+	.get_regs	= rt2500pci_get_regs,
+#ifdef CONFIG_RT2500PCI_DEBUG
+	.get_msglevel	= rt2500pci_get_msglevel,
+	.set_msglevel	= rt2500pci_set_msglevel,
+#endif /* CONFIG_RT2500PCI_DEBUG */
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= rt2500pci_get_eeprom_len,
+	.get_eeprom	= rt2500pci_get_eeprom,
+};
+
+/*
  * Configuration handlers.
  */
 static void rt2500pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2885,6 +2960,8 @@
 		goto exit_release_regions;
 	}
 
+	SET_ETHTOOL_OPS(net_dev, &rt2500pci_ethtool_ops);
+
 	pci_set_drvdata(pci_dev, net_dev);
 
 	status = rt2500pci_initialize(pci_dev, net_dev);
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-07-22 23:14:25.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-07-23 16:35:07.000000000 +0200
@@ -50,6 +50,14 @@
 #define RT2560_VERSION_D		4
 
 /*
+ * Register layout information.
+ */
+#define CSR_REG_BASE			0x0000
+#define CSR_REG_SIZE			0x0174
+#define EEPROM_BASE			0x0000
+#define EEPROM_SIZE			0x01ff
+
+/*
  * Control/Status Registers(CSR).
  * Some values are set in TU, whereas 1 TU == 1024 us.
  */
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 15:46:52.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-07-23 16:31:02.000000000 +0200
@@ -32,7 +32,9 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -212,6 +214,79 @@
 }
 
 /*
+ * Ethtool handlers.
+ */
+static void rt2500usb_get_drvinfo(struct net_device *net_dev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
+	drvinfo->eedump_len = EEPROM_SIZE;
+	drvinfo->regdump_len = CSR_REG_SIZE;
+}
+
+static int rt2500usb_get_regs_len(struct net_device *net_dev)
+{
+	return CSR_REG_SIZE;
+}
+
+static void rt2500usb_get_regs(struct net_device *net_dev,
+	struct ethtool_regs *regs, void *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
+	regs->version = *((u16*)data);
+	regs->len = CSR_REG_SIZE;
+}
+
+#ifdef CONFIG_RT2500USB_DEBUG
+static u32 rt2500usb_get_msglevel(struct net_device *net_dev)
+{
+	return rt2x00_debug_level;
+}
+
+static void rt2500usb_set_msglevel(struct net_device *net_dev, u32 msg)
+{
+	rt2x00_debug_level = !!msg;
+}
+#endif /* CONFIG_RT2500USB_DEBUG */
+
+static int rt2500usb_get_eeprom_len(struct net_device *net_dev)
+{
+	return EEPROM_SIZE;
+}
+
+static int rt2500usb_get_eeprom(struct net_device *net_dev,
+	struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	eeprom->magic = 0xbad;
+
+	rt2x00_eeprom_multiread(rt2x00dev,
+		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+
+	return 0;
+}
+
+static struct ethtool_ops rt2500usb_ethtool_ops = {
+	.get_drvinfo	= rt2500usb_get_drvinfo,
+	.get_regs_len	= rt2500usb_get_regs_len,
+	.get_regs	= rt2500usb_get_regs,
+#ifdef CONFIG_RT2500USB_DEBUG
+	.get_msglevel	= rt2500usb_get_msglevel,
+	.set_msglevel	= rt2500usb_set_msglevel,
+#endif /* CONFIG_RT2500USB_DEBUG */
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= rt2500usb_get_eeprom_len,
+	.get_eeprom	= rt2500usb_get_eeprom,
+};
+
+/*
  * Configuration handlers.
  */
 static void rt2500usb_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2469,6 +2544,8 @@
 		goto exit_put_device;
 	}
 
+	SET_ETHTOOL_OPS(net_dev, &rt2500usb_ethtool_ops);
+
 	usb_set_intfdata(usb_intf, net_dev);
 
 	status = rt2500usb_initialize(usb_intf, net_dev);
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-07-22 23:05:34.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-07-23 16:35:21.000000000 +0200
@@ -43,6 +43,14 @@
 #define RF5222				0x0010
 
 /*
+ * Register layout information.
+ */
+#define CSR_REG_BASE			0x0400
+#define CSR_REG_SIZE			0x00ff
+#define EEPROM_BASE			0x0000
+#define EEPROM_SIZE			0x006a
+
+/*
  * Control/Status Registers(CSR).
  * Some values are set in TU, whereas 1 TU == 1024 us.
  */
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 15:53:12.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-07-23 16:30:48.000000000 +0200
@@ -33,8 +33,10 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
+#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -393,6 +395,79 @@
 #endif /* CONFIG_RT61PCI_BUTTON */
 
 /*
+ * Ethtool handlers.
+ */
+static void rt61pci_get_drvinfo(struct net_device *net_dev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
+	drvinfo->eedump_len = EEPROM_SIZE;
+	drvinfo->regdump_len = CSR_REG_SIZE;
+}
+
+static int rt61pci_get_regs_len(struct net_device *net_dev)
+{
+	return CSR_REG_SIZE;
+}
+
+static void rt61pci_get_regs(struct net_device *net_dev,
+	struct ethtool_regs *regs, void *data)
+{
+	struct rt2x00_dev	*rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
+	regs->version = *((u32*)data);
+	regs->len = CSR_REG_SIZE;
+}
+
+#ifdef CONFIG_RT61PCI_DEBUG
+static u32 rt61pci_get_msglevel(struct net_device *net_dev)
+{
+	return rt2x00_debug_level;
+}
+
+static void rt61pci_set_msglevel(struct net_device *net_dev, u32 msg)
+{
+	rt2x00_debug_level = !!msg;
+}
+#endif /* CONFIG_RT61PCI_DEBUG */
+
+static int rt61pci_get_eeprom_len(struct net_device *net_dev)
+{
+	return EEPROM_SIZE;
+}
+
+static int rt61pci_get_eeprom(struct net_device *net_dev,
+	struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	eeprom->magic = 0xbad;
+
+	rt2x00_eeprom_multiread(rt2x00dev,
+		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+
+	return 0;
+}
+
+static struct ethtool_ops rt61pci_ethtool_ops = {
+	.get_drvinfo	= rt61pci_get_drvinfo,
+	.get_regs_len	= rt61pci_get_regs_len,
+	.get_regs	= rt61pci_get_regs,
+#ifdef CONFIG_RT61PCI_DEBUG
+	.get_msglevel	= rt61pci_get_msglevel,
+	.set_msglevel	= rt61pci_set_msglevel,
+#endif /* CONFIG_RT61PCI_DEBUG */
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= rt61pci_get_eeprom_len,
+	.get_eeprom	= rt61pci_get_eeprom,
+};
+
+/*
  * Configuration handlers.
  */
 static void rt61pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -3434,6 +3509,8 @@
 		goto exit_release_regions;
 	}
 
+	SET_ETHTOOL_OPS(net_dev, &rt61pci_ethtool_ops);
+
 	pci_set_drvdata(pci_dev, net_dev);
 
 	status = rt61pci_initialize(pci_dev, net_dev);
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-22 23:16:12.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-07-23 16:35:36.000000000 +0200
@@ -44,6 +44,14 @@
 #define RF2529				0x0004
 
 /*
+ * Register layout information.
+ */
+#define CSR_REG_BASE			0x3000
+#define CSR_REG_SIZE			0x04b0
+#define EEPROM_BASE			0x0000
+#define EEPROM_SIZE			0x00ff
+
+/*
  * PCI registers.
  */
 
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 15:51:03.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-07-23 16:30:55.000000000 +0200
@@ -32,8 +32,10 @@
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
+#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -214,6 +216,79 @@
 }
 
 /*
+ * Ethtool handlers.
+ */
+static void rt73usb_get_drvinfo(struct net_device *net_dev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
+	drvinfo->eedump_len = EEPROM_SIZE;
+	drvinfo->regdump_len = CSR_REG_SIZE;
+}
+
+static int rt73usb_get_regs_len(struct net_device *net_dev)
+{
+	return CSR_REG_SIZE;
+}
+
+static void rt73usb_get_regs(struct net_device *net_dev,
+	struct ethtool_regs *regs, void *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
+	regs->version = *((u32*)data);
+	regs->len = CSR_REG_SIZE;
+}
+
+#ifdef CONFIG_RT73USB_DEBUG
+static u32 rt73usb_get_msglevel(struct net_device *net_dev)
+{
+	return rt2x00_debug_level;
+}
+
+static void rt73usb_set_msglevel(struct net_device *net_dev, u32 msg)
+{
+	rt2x00_debug_level = !!msg;
+}
+#endif /* CONFIG_RT73USB_DEBUG */
+
+static int rt73usb_get_eeprom_len(struct net_device *net_dev)
+{
+	return EEPROM_SIZE;
+}
+
+static int rt73usb_get_eeprom(struct net_device *net_dev,
+	struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+
+	eeprom->magic = 0xbad;
+
+	rt2x00_eeprom_multiread(rt2x00dev,
+		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
+
+	return 0;
+}
+
+static struct ethtool_ops rt73usb_ethtool_ops = {
+	.get_drvinfo	= rt73usb_get_drvinfo,
+	.get_regs_len	= rt73usb_get_regs_len,
+	.get_regs	= rt73usb_get_regs,
+#ifdef CONFIG_RT73USB_DEBUG
+	.get_msglevel	= rt73usb_get_msglevel,
+	.set_msglevel	= rt73usb_set_msglevel,
+#endif /* CONFIG_RT2500USB_DEBUG */
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= rt73usb_get_eeprom_len,
+	.get_eeprom	= rt73usb_get_eeprom,
+};
+
+/*
  * Configuration handlers.
  */
 static void rt73usb_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -2885,6 +2960,8 @@
 		goto exit_put_device;
 	}
 
+	SET_ETHTOOL_OPS(net_dev, &rt73usb_ethtool_ops);
+
 	usb_set_intfdata(usb_intf, net_dev);
 
 	status = rt73usb_initialize(usb_intf, net_dev);
diff -rU3 wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-pciusb_dev/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-22 23:05:59.000000000 +0200
+++ wireless-dev-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-07-23 16:35:48.000000000 +0200
@@ -41,6 +41,14 @@
 #define RF2527				0x0004
 
 /*
+ * Register layout information.
+ */
+#define CSR_REG_BASE			0x3000
+#define CSR_REG_SIZE			0x04b0
+#define EEPROM_BASE			0x0000
+#define EEPROM_SIZE			0x00ff
+
+/*
  * USB registers.
  */
 
