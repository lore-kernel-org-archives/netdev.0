From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 26/26] rt2x00: Move CRC into seperate module
Date: Sun, 3 Dec 2006 19:18:55 +0100
Message-ID: <200612031918.55494.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:19032 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1758789AbWLCSTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:19:12 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4144307nfa
        for <netdev@vger.kernel.org>; Sun, 03 Dec 2006 10:19:11 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the crc handling of rt61pci and rt73usb into a seperate module.
This will create the crc-itu-t module inside the rt2x00 folder.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/Kconfig wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/Kconfig
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-12-03 16:13:58.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-12-03 16:17:48.000000000 +0100
@@ -40,6 +40,7 @@
 config RT61PCI
 	tristate "Ralink rt61 pci/pcmcia support"
 	depends on RT2X00 && FW_LOADER && PCI
+	select CRC_ITU_T
 	select EEPROM_93CX6
 	---help---
 	This is an experimental driver for the Ralink rt61 wireless chip.
@@ -69,6 +70,7 @@
 config RT73USB
 	tristate "Ralink rt73 usb support"
 	depends on RT2X00 && FW_LOADER && USB
+	select CRC_ITU_T
 	---help---
 	This is an experimental driver for the Ralink rt73 wireless chip.
 
@@ -88,3 +90,11 @@
 	These chipsets are found inside the Ralink wireless cards.
 
 	When compiled as a module, this driver will be called "eeprom_93c6.ko".
+
+config CRC_ITU_T
+	tristate "CRC ITU-T V.41 functions"
+	help
+	  This option is provided for the case where no in-kernel-tree
+	  modules require CRC ITU-T V.41 functions, but a module built outside
+	  the kernel tree does. Such modules that use library CRC ITU-T V.41
+	  functions require M here.
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/Makefile wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/Makefile
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/Makefile	2006-12-03 16:13:58.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/Makefile	2006-12-03 16:17:19.000000000 +0100
@@ -3,4 +3,5 @@
 obj-$(CONFIG_RT61PCI)		+= rt61pci.o
 obj-$(CONFIG_RT2500USB)		+= rt2500usb.o
 obj-$(CONFIG_RT73USB)		+= rt73usb.o
+obj-$(CONFIG_CRC_ITU_T)		+= crc-itu-t.o
 obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/crc-itu-t.c wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/crc-itu-t.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/crc-itu-t.c	1970-01-01 01:00:00.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/crc-itu-t.c	2006-12-03 16:15:35.000000000 +0100
@@ -0,0 +1,66 @@
+/*
+ *	crc-itu-t.c
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2. See the file COPYING for more details.
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+
+#include "crc-itu-t.h"
+
+MODULE_AUTHOR("http://rt2x00.serialmonkey.com");
+MODULE_DESCRIPTION("CRC ITU-T V.41 calculations");
+MODULE_LICENSE("GPL");
+
+/** CRC table for the CRC ITU-T V.41 0x0x1021 (x^16 + x^12 + x^15 + 1) */
+const u16 crc_itu_t_table[256] = {
+	0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
+	0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
+	0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
+	0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
+	0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
+	0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
+	0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
+	0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
+	0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
+	0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
+	0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
+	0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
+	0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
+	0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
+	0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
+	0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
+	0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
+	0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
+	0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
+	0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
+	0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
+	0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
+	0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
+	0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
+	0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
+	0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
+	0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
+	0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
+	0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
+	0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
+	0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
+	0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
+};
+EXPORT_SYMBOL(crc_itu_t_table);
+
+/**
+ * crc_itu_t - Compute the CRC-ITU-T for the data buffer
+ * @crc: previous CRC value
+ * @buffer: data pointer
+ * @len: number of bytes in the buffer
+ */
+u16 crc_itu_t(u16 crc, const u8 *buffer, size_t len)
+{
+	while (len--)
+		crc = crc_itu_t_byte(crc, *buffer++);
+	return crc;
+}
+EXPORT_SYMBOL(crc_itu_t);
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/crc-itu-t.h wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/crc-itu-t.h
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/crc-itu-t.h	1970-01-01 01:00:00.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/crc-itu-t.h	2006-08-01 13:18:16.000000000 +0200
@@ -0,0 +1,27 @@
+/*
+ *	crc-itu-t.h - CRC ITU-T V.41 routine
+ *
+ * Implements the standard CRC ITU-T V.41:
+ *   Width 16
+ *   Poly  0x1021 (x^16 + x^12 + x^15 + 1)
+ *   Init  0
+ *
+ * This source code is licensed under the GNU General Public License,
+ * Version 2. See the file COPYING for more details.
+ */
+
+#ifndef CRC_ITU_T_H
+#define CRC_ITU_T_H
+
+#include <linux/types.h>
+
+extern u16 const crc_itu_t_table[256];
+
+extern u16 crc_itu_t(u16 crc, const u8 *buffer, size_t len);
+
+static inline u16 crc_itu_t_byte(u16 crc, const u8 data)
+{
+	return (crc << 8) ^ crc_itu_t_table[((crc >> 8) ^ data) & 0xff];
+}
+
+#endif /* CRC_ITU_T_H */
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2x00crc.h wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt2x00crc.h
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt2x00crc.h	2006-12-02 14:24:40.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt2x00crc.h	1970-01-01 01:00:00.000000000 +0100
@@ -1,82 +0,0 @@
-/*
-	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
-	<http://rt2x00.serialmonkey.com>
-
-	This program is free software; you can redistribute it and/or modify
-	it under the terms of the GNU General Public License as published by
-	the Free Software Foundation; either version 2 of the License, or
-	(at your option) any later version.
-
-	This program is distributed in the hope that it will be useful,
-	but WITHOUT ANY WARRANTY; without even the implied warranty of
-	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-	GNU General Public License for more details.
-
-	You should have received a copy of the GNU General Public License
-	along with this program; if not, write to the
-	Free Software Foundation, Inc.,
-	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
- */
-
-/*
-	Module: rt2x00
-	Abstract: rt2x00 CRC implementation for firmware validation.
-	Supported chipsets: rt2561, rt2561s, rt2661 & rt2573
- */
-
-#ifndef RT2X00CRC_H
-#define RT2X00CRC_H
-
-static const u16 rt2x00crc_table[256] = {
-	0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
-	0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
-	0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
-	0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
-	0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
-	0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
-	0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
-	0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
-	0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
-	0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
-	0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
-	0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
-	0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
-	0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
-	0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
-	0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
-	0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
-	0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
-	0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
-	0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
-	0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
-	0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
-	0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
-	0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
-	0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
-	0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
-	0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
-	0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
-	0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
-	0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
-	0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
-	0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
-};
-
-static inline u16
-rt2x00crc_byte(u16 crc, const u8 data)
-{
-	return (crc << 8) ^ rt2x00crc_table[((crc >> 8) ^ data) & 0xff];
-}
-
-/*
- * Compute the rt2x00 CRC for the data buffer
- */
-static inline u16
-rt2x00crc(u16 crc, const u8 *buffer, size_t len)
-{
-	while (len--)
-		crc = rt2x00crc_byte(crc, *buffer++);
-	return crc;
-}
-
-#endif /* RT2X00CRC_H */
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt61pci.c wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt61pci.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 16:14:21.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-12-03 16:20:20.000000000 +0100
@@ -55,6 +55,7 @@
 #include "rt2x00pci.h"
 #include "rt2x00crc.h"
 #include "rt61pci.h"
+#include "crc-itu-t.h"
 #include "eeprom_93cx6.h"
 
 /*
@@ -1182,8 +1183,8 @@
 	 * and set those 2 bytes to 0 when calculating CRC.
 	 */
 	reg = 0;
-	crc = rt2x00crc(0, fw->data, fw->size - 2);
-	crc = rt2x00crc(crc, (u8*)&reg, 2);
+	crc = crc_itu_t(0, fw->data, fw->size - 2);
+	crc = crc_itu_t(crc, (u8*)&reg, 2);
 
 	if (crc != (fw->data[fw->size - 2] << 8 | fw->data[fw->size - 1])) {
 		ERROR("Firmware CRC error.\n");
diff -rNU3 wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt73usb.c
--- wireless-dev-base/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 16:14:21.000000000 +0100
+++ wireless-dev-crc/drivers/net/wireless/d80211/rt2x00/rt73usb.c	2006-12-03 16:20:22.000000000 +0100
@@ -52,6 +52,7 @@
 #include "rt2x00usb.h"
 #include "rt2x00crc.h"
 #include "rt73usb.h"
+#include "crc-itu-t.h"
 
 /*
  * Register access.
@@ -1081,8 +1082,8 @@
 	 * and set those 2 bytes to 0 when calculating CRC.
 	 */
 	reg = 0;
-	crc = rt2x00crc(0, fw->data, fw->size - 2);
-	crc = rt2x00crc(crc, (u8*)&reg, 2);
+	crc = crc_itu_t(0, fw->data, fw->size - 2);
+	crc = crc_itu_t(crc, (u8*)&reg, 2);
 
 	if (crc != (fw->data[fw->size - 2] << 8 | fw->data[fw->size - 1])) {
 		ERROR("Firmware CRC error.\n");
