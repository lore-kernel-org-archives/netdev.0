From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH 1/4] MCS7830 USB-Ether: add Rx error support
Date: Sun, 31 Jan 2010 13:58:19 +0100
Message-ID: <20100131125819.GA13435@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
	David Hollis <dhollis@davehollis.com>,
	Phil Chang <pchang23@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:60145 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab0AaM6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2010 07:58:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChangeLog:
- evaluate Rx error statistics from trailing Rx status byte
- add driver TODO list
- add myself to authors


Quilt series run-tested, based on 2.6.33-rc4 (net-2.6.git mcs7830 has idle history,
should be good to go).

Signed-off-by: Andreas Mohr <andi@lisas.de>


Index: linux-2.6.33-rc4/drivers/net/usb/mcs7830.c
===================================================================
--- linux-2.6.33-rc4.orig/drivers/net/usb/mcs7830.c	2010-01-31 07:29:11.000000000 +0100
+++ linux-2.6.33-rc4/drivers/net/usb/mcs7830.c	2010-01-31 12:59:56.000000000 +0100
@@ -3,11 +3,27 @@
  *
  * based on usbnet.c, asix.c and the vendor provided mcs7830 driver
  *
+ * Copyright (C) 2010 Andreas Mohr <andi@lisas.de>
  * Copyright (C) 2006 Arnd Bergmann <arnd@arndb.de>
  * Copyright (C) 2003-2005 David Hollis <dhollis@davehollis.com>
  * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
  * Copyright (c) 2002-2003 TiVo Inc.
  *
+ * Definitions gathered from MOSCHIP, Data Sheet_7830DA.pdf (thanks!).
+ *
+ * TODO:
+ * - add .reset_resume support (iface is _gone_ after resume w/ power loss)
+ * - verify that mcs7830_get_regs() does have same output pre-/post-suspend
+ * - support HIF_REG_CONFIG_SLEEPMODE/HIF_REG_CONFIG_TXENABLE (via autopm?)
+ * - implement ethtool_ops get_pauseparam/set_pauseparam
+ *   via HIF_REG_PAUSE_THRESHOLD (>= revision C only!)
+ * - implement get_eeprom/[set_eeprom]
+ * - switch PHY on/off on ifup/ifdown (perhaps in usbnet.c, via MII)
+ * - mcs7830_get_regs() handling is weird: for rev 2 we return 32 regs,
+ *   can access only ~ 24, remaining user buffer is uninitialized garbage
+ * - anything else?
+ *
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 2 of the License, or
@@ -83,6 +99,17 @@
 	   HIF_REG_PAUSE_THRESHOLD_DEFAULT	= 0,
 };
 
+/* Trailing status byte in Ethernet Rx frame */
+enum {
+	MCS7830_RX_SHORT_FRAME		= 0x01, /* < 64 bytes */
+	MCS7830_RX_LENGTH_ERROR		= 0x02, /* framelen != Ethernet length field */
+	MCS7830_RX_ALIGNMENT_ERROR	= 0x04, /* non-even number of nibbles */
+	MCS7830_RX_CRC_ERROR		= 0x08,
+	MCS7830_RX_LARGE_FRAME		= 0x10, /* > 1518 bytes */
+	MCS7830_RX_FRAME_CORRECT	= 0x20, /* frame is correct */
+	/* [7:6] reserved */
+};
+
 struct mcs7830_data {
 	u8 multi_filter[8];
 	u8 config;
@@ -539,9 +566,23 @@
 	skb_trim(skb, skb->len - 1);
 	status = skb->data[skb->len];
 
-	if (status != 0x20)
+	if (status != MCS7830_RX_FRAME_CORRECT) {
 		dev_dbg(&dev->udev->dev, "rx fixup status %x\n", status);
 
+		/* hmm, perhaps usbnet.c already sees a globally visible
+		   frame error and increments rx_errors on its own already? */
+		dev->net->stats.rx_errors++;
+
+		if (status &	(MCS7830_RX_SHORT_FRAME
+				|MCS7830_RX_LENGTH_ERROR
+				|MCS7830_RX_LARGE_FRAME))
+			dev->net->stats.rx_length_errors++;
+		if (status & MCS7830_RX_ALIGNMENT_ERROR)
+			dev->net->stats.rx_frame_errors++;
+		if (status & MCS7830_RX_CRC_ERROR)
+			dev->net->stats.rx_crc_errors++;
+	}
+
 	return skb->len > 0;
 }
 
