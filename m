From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/10] rt2x00: Add register revision and firmware version to ethtool
Date: Sun, 27 Aug 2006 17:39:12 +0200
Message-ID: <200608271739.12131.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:42540 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751106AbWH0PjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 11:39:19 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1091663nfa
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 08:39:18 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When chipset is detected it is also a good idea to read the
revision number from the register. This can than also
be used with "ethtool -d".
For rt61pci and rt73usb the firmware version should be stored
so it can be accessed for "ethtool -i"
For the other device just set firmware version to "N/A"

Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>

---

diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 15:48:21.000000000 +0200
@@ -373,6 +373,7 @@
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -389,7 +390,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -2450,7 +2451,8 @@
 	 * 3 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT2460, value);
+	rt2x00_register_read(rt2x00dev, CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2460, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2420) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2421))
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 15:48:35.000000000 +0200
@@ -373,6 +373,7 @@
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -389,7 +390,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -2589,7 +2590,8 @@
 	 * 3 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT2560, value);
+	rt2x00_register_read(rt2x00dev, CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2560, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2522) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2523) &&
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	2006-08-27 15:49:07.000000000 +0200
@@ -224,6 +224,7 @@
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, "N/A");
 	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -240,7 +241,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u16*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -2255,6 +2256,8 @@
 {
 	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev)));
+	u16 reg;
+	u16 value;
 	u16 eeprom;
 
 	/*
@@ -2265,8 +2268,9 @@
 	/*
 	 * 2 - Identify RF chipset.
 	 */
-	rt2x00_set_chip(&rt2x00dev->chip, RT2570,
-		rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE));
+	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT2570, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF2522) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2523) &&
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-08-27 15:45:39.000000000 +0200
@@ -433,18 +433,32 @@
 struct rt2x00_chip {
 	u16 rt;
 	u16 rf;
+	u16 rev;
+	u8 fw_h;
+	u8 fw_l;
 };
 
 /*
  * Set chipset data.
  */
 static inline void rt2x00_set_chip(struct rt2x00_chip *chipset,
-	const u16 rt, const u16 rf)
+	const u16 rt, const u16 rf, const u16 rev)
 {
-	INFO("Chipset detected - rt: %04x, rf: %04x.\n", rt, rf);
+	INFO("Chipset detected - rt: %04x, rf: %04x, rev: %04x.\n",
+		rt, rf, rev);
 
 	chipset->rt = rt;
 	chipset->rf = rf;
+	chipset->rev = rev;
+}
+
+static inline void rt2x00_set_chip_fw(struct rt2x00_chip *chipset,
+	const u8 fw_h, const u8 fw_l)
+{
+	INFO("Firmware detected - version: %d.%d.\n", fw_h, fw_l);
+
+	chipset->fw_h = fw_h;
+	chipset->fw_l = fw_l;
 }
 
 static inline char rt2x00_rt(const struct rt2x00_chip *chipset, const u16 chip)
@@ -457,6 +471,16 @@
 	return (chipset->rf == chip);
 }
 
+static inline u16 rt2x00_rev(const struct rt2x00_chip *chipset)
+{
+	return chipset->rev;
+}
+
+static inline char* rt2x00_fw(const struct rt2x00_chip *chipset)
+{
+	return chipset->fw_h + "." + chipset->fw_l;
+}
+
 /*
  * data_entry
  * The data ring is a list of data entries.
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-08-27 15:49:42.000000000 +0200
@@ -404,6 +404,7 @@
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
 	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -420,7 +421,7 @@
 	struct rt2x00_dev	*rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -1359,7 +1360,7 @@
 		goto exit;
 	}
 
-	DEBUG("Loading Firmware version: %d.%d.\n",
+	rt2x00_set_chip_fw(&rt2x00dev->chip,
 		fw->data[fw->size - 4], fw->data[fw->size - 3]);
 
 	/*
@@ -3057,11 +3058,11 @@
 	 * To determine the RT chip we have to read the
 	 * PCI header of the device.
 	 */
-	pci_read_config_word(
-		rt2x00dev_pci(rt2x00dev), PCI_CONFIG_HEADER_DEVICE, &device);
-
+	pci_read_config_word(rt2x00dev_pci(rt2x00dev),
+		PCI_CONFIG_HEADER_DEVICE, &device);
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, device, value);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, device, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF5225) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF5325) &&
diff -rU3 wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-19 17:38:02.000000000 +0200
+++ wireless-dev-rt2x00-ethtool/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-08-27 15:50:11.000000000 +0200
@@ -225,6 +225,7 @@
 
 	strcpy(drvinfo->driver, DRV_NAME);
 	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, rt2x00_fw(&rt2x00dev->chip));
 	strcpy(drvinfo->bus_info, rt2x00dev_usb(rt2x00dev)->dev.bus_id);
 	drvinfo->eedump_len = EEPROM_SIZE;
 	drvinfo->regdump_len = CSR_REG_SIZE;
@@ -241,7 +242,7 @@
 	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
 
 	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = *((u32*)data);
+	regs->version = rt2x00_rev(&rt2x00dev->chip);
 	regs->len = CSR_REG_SIZE;
 }
 
@@ -1070,7 +1071,7 @@
 		goto exit;
 	}
 
-	DEBUG("Loading Firmware version: %d.%d.\n",
+	rt2x00_set_chip_fw(&rt2x00dev->chip,
 		fw->data[fw->size - 4], fw->data[fw->size - 3]);
 
 	/*
@@ -2577,6 +2578,7 @@
 {
 	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
 		usb_get_intfdata(rt2x00dev_usb(rt2x00dev)));
+	u32 reg;
 	u16 value;
 	u16 eeprom;
 
@@ -2589,7 +2591,8 @@
 	 * 2 - Identify RF chipset.
 	 */
 	value = rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE);
-	rt2x00_set_chip(&rt2x00dev->chip, RT73, value);
+	rt2x00_register_read(rt2x00dev, MAC_CSR0, &reg);
+	rt2x00_set_chip(&rt2x00dev->chip, RT73, value, reg);
 
 	if (!rt2x00_rf(&rt2x00dev->chip, RF5226) &&
 	    !rt2x00_rf(&rt2x00dev->chip, RF2528) &&
