From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/6] rt2x00 - optimize MAC reading & initialize perm_addr
Date: Tue, 8 Aug 2006 15:46:55 +0200
Message-ID: <200608081546.56016.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:28394 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964864AbWHHNr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 09:47:26 -0400
Received: by nf-out-0910.google.com with SMTP id q29so175926nfc
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2006 06:47:25 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When reading the MAC addr from MAC register or EEPROM
it is always read as little endian. Since we want to store it in a u8 array
we don't require byte ordering as long as we correctly read it into
an u8 array directly.
Also copy the address to perm_addr and enable ethtool to read it.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:42:33.000000000 +0200
+++ wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-08 14:55:51.000000000 +0200
@@ -434,6 +434,7 @@
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2400pci_get_eeprom_len,
 	.get_eeprom	= rt2400pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -2509,25 +2510,29 @@
 static int rt2400pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u32 reg[2] = { 0, 0 };
+	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
-	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
+	/*
+	 * Read MAC address from MAC register.
+	 */
+	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field32(reg[0], CSR3_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field32(reg[0], CSR3_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field32(reg[0], CSR3_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field32(reg[1], CSR4_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field32(reg[1], CSR4_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&reg[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
+	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:43:39.000000000 +0200
+++ wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-08 14:56:52.000000000 +0200
@@ -434,6 +434,7 @@
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2500pci_get_eeprom_len,
 	.get_eeprom	= rt2500pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -2661,25 +2662,29 @@
 static int rt2500pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u32 reg[2] = { 0, 0 };
+	u8 reg[8];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
-	rt2x00_register_multiread(rt2x00dev, CSR3, &reg[0], sizeof(reg));
+	/*
+	 * Read MAC address from MAC register.
+	 */
+	rt2x00_register_multiread(rt2x00dev, CSR3, (u32*)&reg[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field32(reg[0], CSR3_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field32(reg[0], CSR3_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field32(reg[0], CSR3_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field32(reg[0], CSR3_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field32(reg[1], CSR4_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field32(reg[1], CSR4_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&reg[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &reg[0], 6);
+	memcpy(&net_dev->perm_addr[0], &reg[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 14:45:02.000000000 +0200
+++ wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-08 14:57:42.000000000 +0200
@@ -284,6 +284,7 @@
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt2500usb_get_eeprom_len,
 	.get_eeprom	= rt2500usb_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -2332,7 +2333,7 @@
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -2340,26 +2341,22 @@
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:46:43.000000000 +0200
+++ wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-08 14:59:09.000000000 +0200
@@ -465,6 +465,7 @@
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt61pci_get_eeprom_len,
 	.get_eeprom	= rt61pci_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -3186,7 +3187,7 @@
 static int rt61pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -3194,26 +3195,22 @@
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
diff -rU3 wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00-config/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 14:47:36.000000000 +0200
+++ wireless-dev-rt2x00-perm-addr/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-08 15:00:03.000000000 +0200
@@ -286,6 +286,7 @@
 	.get_link	= ethtool_op_get_link,
 	.get_eeprom_len	= rt73usb_get_eeprom_len,
 	.get_eeprom	= rt73usb_get_eeprom,
+	.get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /*
@@ -2697,7 +2698,7 @@
 {
 	struct net_device *net_dev =
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev));
-	u16 eeprom[3] = { 0, 0, 0 };
+	u8 eeprom[6];
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
@@ -2705,26 +2706,22 @@
 	/*
 	 * Read MAC address from EEPROM.
 	 */
-	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR, &eeprom[0], 6);
+	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR,
+		(u16*)&eeprom[0], 6);
 
-	net_dev->dev_addr[0] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE0);
-	net_dev->dev_addr[1] = rt2x00_get_field16(eeprom[0],
-					EEPROM_MAC_ADDR_BYTE1);
-	net_dev->dev_addr[2] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE2);
-	net_dev->dev_addr[3] = rt2x00_get_field16(eeprom[1],
-					EEPROM_MAC_ADDR_BYTE3);
-	net_dev->dev_addr[4] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE4);
-	net_dev->dev_addr[5] = rt2x00_get_field16(eeprom[2],
-					EEPROM_MAC_ADDR_BYTE5);
+	/*
+	 * Check if a valid MAC address has been read.
+	 */
+	if (!is_valid_ether_addr(&eeprom[0]))
+		return -EINVAL;
 
+	/*
+	 * Copy to netdevice structure.
+	 */
+	memcpy(&net_dev->dev_addr[0], &eeprom[0], 6);
+	memcpy(&net_dev->perm_addr[0], &eeprom[0], 6);
 	net_dev->addr_len = 6;
 
-	if (!is_valid_ether_addr(&net_dev->dev_addr[0]))
-		return -EINVAL;
-
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
 }
