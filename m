From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/10] rt2x00: Mac address reading optimization
Date: Sun, 27 Aug 2006 17:39:13 +0200
Message-ID: <200608271739.13230.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:49708 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932112AbWH0PjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:22 -0400
Received: by nf-out-0910.google.com with SMTP id x37so1242849nfc
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:20 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't need a seperate array when reading the mac address from eeprom.
Read it directly into the perm_addr array which has been correctly memsetted.
Also to prevent confusing add eeprom addresses for each eeprom word for the
mac address.

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:00:34.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:08:49.000000000 +0200
@@ -2500,29 +2500,36 @@
 static int rt2400pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
-	 * Read MAC address from MAC register.
+	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&reg[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
-	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2400pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.h wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	2006-08-27 16:50:22.000000000 +0200
@@ -705,6 +705,19 @@
  */
 
 /*
+ * HW MAC address.
+ */
+#define EEPROM_MAC_ADDR_0		0x0002
+#define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0003
+#define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0004
+#define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
+
+/*
  * EEPROM antenna.
  * ANTENNA_NUM: Number of antenna's.
  * TX_DEFAULT: Default antenna 0: diversity, 1: A, 2: B.
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:00:40.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:06:12.000000000 +0200
@@ -2650,29 +2650,36 @@
 static int rt2500pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
-	 * Read MAC address from MAC register.
+	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&reg[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
-	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2500pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.h wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.h
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	2006-08-27 16:50:34.000000000 +0200
@@ -935,6 +935,19 @@
  */
 
 /*
+ * HW MAC address.
+ */
+#define EEPROM_MAC_ADDR_0		0x0002
+#define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0003
+#define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0004
+#define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
+#define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
+
+/*
  * EEPROM antenna.
  * ANTENNA_NUM: Number of antenna's.
  * TX_DEFAULT: Default antenna 0: diversity, 1: A, 2: B.
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:00:52.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 16:06:31.000000000 +0200
@@ -2324,30 +2324,36 @@
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt2500usb_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.h wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.h
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	2006-08-27 16:51:20.000000000 +0200
@@ -492,11 +492,13 @@
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0004
+#define EEPROM_MAC_ADDR_0		0x0004
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0006
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0008
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:01:03.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 16:06:48.000000000 +0200
@@ -3174,30 +3174,36 @@
 static int rt61pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt61pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.h wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.h
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt61pci.h	2006-08-27 16:52:02.000000000 +0200
@@ -991,11 +991,13 @@
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0002
+#define EEPROM_MAC_ADDR_0		0x0002
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0004
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0006
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:01:09.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 16:07:02.000000000 +0200
@@ -2688,30 +2688,36 @@
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
+	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
-		(u16*)&eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
+		(u16*)&net_dev->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&eeprom[0]))
+	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to netdevice structure.
+	 * Copy to perm_addr to dev_addr structure.
 	 */
-	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
-	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
+		sizeof(net_dev->perm_addr));
 	net_dev->addr_len = 6;
 
+	/*
+	 * Write MAC address to register.
+	 */
+	rt73usb_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.h wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.h
--- wireless-dev-rt2x00-rate/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-mac/drivers/net/wireless/d80211/rt2x00/rt73usb.h	2006-08-27 16:52:29.000000000 +0200
@@ -643,11 +643,13 @@
 /*
  * HW MAC address.
  */
-#define EEPROM_MAC_ADDR			0x0004
+#define EEPROM_MAC_ADDR_0		0x0004
 #define EEPROM_MAC_ADDR_BYTE0		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE1		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR1		0x0006
 #define EEPROM_MAC_ADDR_BYTE2		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE3		FIELD16(0xff00)
+#define EEPROM_MAC_ADDR_2		0x0008
 #define EEPROM_MAC_ADDR_BYTE4		FIELD16(0x00ff)
 #define EEPROM_MAC_ADDR_BYTE5		FIELD16(0xff00)
 
