From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH] r8169: Add ff_dup wich disable advertise on full duplex
Date: Sat,  1 Aug 2015 20:20:21 +0300
Message-ID: <1438449621-3061-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33305 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbbHARUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 13:20:35 -0400
Received: by wicmv11 with SMTP id mv11so90500929wic.0
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2015 10:20:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Add parameter ff_dup wich disable advertise 10/100Mbs
 duplex full   for card wich start on low speed on full duplex.Verry strange with this patch
 First insert module with ff_dup=1 link is good , unload module, load module wo parameter ff_dup
 and is full duplex and full speed on RTL_GIGA_MAC_VER_09.  


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 3df51fa..c635d11 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -346,6 +346,7 @@ MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
 
 static int rx_buf_sz = 16383;
 static int use_dac;
+static int ff_dup;
 static struct {
 	u32 msg_enable;
 } debug = { -1 };
@@ -850,6 +851,8 @@ module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
 MODULE_PARM_DESC(debug, "Debug verbosity level (0=none, ..., 16=all)");
+module_param(ff_dup, int, 0);
+MODULE_PARM_DESC(ff_dup, "Disable full duplex operations. ");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 MODULE_FIRMWARE(FIRMWARE_8168D_1);
@@ -1901,6 +1904,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 				  u8 autoneg, u16 speed, u8 duplex, u32 adv)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	int adv_10baseT_full, adv_100baseT_full;
 	int giga_ctrl, bmcr;
 	int rc = -EINVAL;
 
@@ -1913,13 +1917,27 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
 				ADVERTISE_100HALF | ADVERTISE_100FULL);
 
+		if (!ff_dup) {
+		  adv_10baseT_full = ADVERTISED_10baseT_Full;
+		  adv_100baseT_full = ADVERTISED_100baseT_Full;
+		} else {
+		  adv_10baseT_full = 0;
+		  adv_100baseT_full = 0;
+                 }
+
+		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
+		rtl_writephy(tp, MII_BMCR, bmcr);
+
+
 		if (adv & ADVERTISED_10baseT_Half)
 			auto_nego |= ADVERTISE_10HALF;
-		if (adv & ADVERTISED_10baseT_Full)
-			auto_nego |= ADVERTISE_10FULL;
 		if (adv & ADVERTISED_100baseT_Half)
 			auto_nego |= ADVERTISE_100HALF;
-		if (adv & ADVERTISED_100baseT_Full)
+
+		if (adv & adv_10baseT_full)
+			auto_nego |= ADVERTISE_10FULL;
+
+		if (adv & adv_100baseT_full)
 			auto_nego |= ADVERTISE_100FULL;
 
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
@@ -1940,7 +1958,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 			goto out;
 		}
 
-		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
+		//bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 
 		rtl_writephy(tp, MII_ADVERTISE, auto_nego);
 		rtl_writephy(tp, MII_CTRL1000, giga_ctrl);
-- 
2.1.4
