From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/5] ar7: add fixed PHY support for the two on-board cpmac
Date: Tue, 4 Aug 2009 22:52:47 +0200
Message-ID: <200908042252.47549.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:50430 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbZHDUwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:52:49 -0400
Received: by mail-ew0-f214.google.com with SMTP id 10so654827ewy.37
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 13:52:50 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds fixed PHY support for the two on-chip
cpmac Ethernet adapters.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
index 5422449..c4737ce 100644
--- a/arch/mips/ar7/platform.c
+++ b/arch/mips/ar7/platform.c
@@ -33,6 +33,8 @@
 #include <linux/leds.h>
 #include <linux/string.h>
 #include <linux/etherdevice.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include <asm/addrspace.h>
 #include <asm/mach-ar7/ar7.h>
@@ -209,6 +211,12 @@ static struct physmap_flash_data physmap_flash_data = {
 	.width = 2,
 };
 
+static struct fixed_phy_status fixed_phy_status __initdata = {
+	.link = 1,
+	.speed = 100,
+	.duplex = 1,
+};
+
 static struct plat_cpmac_data cpmac_low_data = {
 	.reset_bit = 17,
 	.power_bit = 20,
@@ -530,6 +538,9 @@ static int __init ar7_register_devices(void)
 	}
 
 	if (ar7_has_high_cpmac()) {
+		res = fixed_phy_add(PHY_POLL, cpmac_high.id, &fixed_phy_status);
+		if (res && res != -ENODEV)
+			return res;
 		cpmac_get_mac(1, cpmac_high_data.dev_addr);
 		res = platform_device_register(&cpmac_high);
 		if (res)
@@ -538,6 +549,10 @@ static int __init ar7_register_devices(void)
 		cpmac_low_data.phy_mask = 0xffffffff;
 	}
 
+	res = fixed_phy_add(PHY_POLL, cpmac_low.id, &fixed_phy_status);
+	if (res && res != -ENODEV)
+		return res;
+
 	cpmac_get_mac(0, cpmac_low_data.dev_addr);
 	res = platform_device_register(&cpmac_low);
 	if (res)
