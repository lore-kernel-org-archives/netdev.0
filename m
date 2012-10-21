From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 3/5] net/at91_ether: move eth addr quirk into csb337 board setup
Date: Sun, 21 Oct 2012 16:23:10 +0200
Message-ID: <1350829392-3812-4-git-send-email-manabian@gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65406 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab2JUOXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:23:37 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1170561lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 07:23:36 -0700 (PDT)
In-Reply-To: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move Ethernet address byte order fix for csb337 into it's board
setup.

This will allow us to remove the last mach include from at91_ether
and also to share the address setup with the macb driver.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 arch/arm/mach-at91/board-csb337.c         | 35 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/cadence/Kconfig      |  1 -
 drivers/net/ethernet/cadence/at91_ether.c | 26 ++++++-----------------
 3 files changed, 41 insertions(+), 21 deletions(-)

diff --git a/arch/arm/mach-at91/board-csb337.c b/arch/arm/mach-at91/board-csb337.c
index 3e37437..5522132 100644
--- a/arch/arm/mach-at91/board-csb337.c
+++ b/arch/arm/mach-at91/board-csb337.c
@@ -217,6 +217,40 @@ static struct gpio_led csb_leds[] = {
 	}
 };
 
+/*
+ * MicroMonitor (uMon) on the CSB337 store the ethernet address in the
+ * wrong byte order (and continues to do so, for bug-compatibility).
+ */
+#define MACB_SA1B	0x0098
+#define MACB_SA1T	0x009c
+static void __init csb337_fix_eth_addr(void)
+{
+	void __iomem *emac;
+	u32 lo, hi, tmp;
+	int i;
+
+	emac = ioremap(AT91RM9200_BASE_EMAC, SZ_16K);
+	if (!emac) {
+		printk(KERN_ERR "csb337: unable to fixup Ethernet address\n");
+		return;
+	}
+
+	/* Fix byte order on all 4 address registers */
+	for (i = 0; i < 4; i++) {
+		lo = readl(emac + MACB_SA1B + i * 8);
+		hi = readl(emac + MACB_SA1T + i * 8);
+
+		tmp = (lo & 0xff) << 8 | (lo & 0xff00) >> 8;
+		writel(tmp, emac + MACB_SA1T + i * 8);
+
+		tmp = (hi & 0xff) << 8 | (hi & 0xff00) >> 8
+			| (lo & 0xff0000) << 8
+			| (lo & 0xff000000) >> 8;
+		writel(tmp, emac + MACB_SA1B + i * 8);
+	}
+
+	iounmap(emac);
+}
 
 static void __init csb337_board_init(void)
 {
@@ -225,6 +259,7 @@ static void __init csb337_board_init(void)
 	at91_register_uart(0, 0, 0);
 	at91_add_device_serial();
 	/* Ethernet */
+	csb337_fix_eth_addr();
 	at91_add_device_eth(&csb337_eth_data);
 	/* USB Host */
 	at91_add_device_usbh(&csb337_usbh_data);
diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index f6d0956..40172d1 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -21,7 +21,6 @@ if NET_CADENCE
 
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
-	depends on ARM && ARCH_AT91RM9200
 	select NET_CORE
 	select MACB
 	---help---
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 375d272..5ed1a63 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -32,8 +32,6 @@
 #include <linux/phy.h>
 #include <linux/io.h>
 
-#include <asm/mach-types.h>
-
 #include "macb.h"
 
 #define DRV_NAME	"at91_ether"
@@ -55,30 +53,18 @@
  *   U-Boot on the AT91RM9200-DK do not do this.
  *
  * - Likewise it must store the addresses in the correct byte order.
- *   MicroMonitor (uMon) on the CSB337 does this incorrectly (and
- *   continues to do so, for bug-compatibility).
  */
 
 static short __init unpack_mac_address(struct net_device *dev, unsigned int hi, unsigned int lo)
 {
 	char addr[6];
 
-	if (machine_is_csb337()) {
-		addr[5] = (lo & 0xff);			/* The CSB337 bootloader stores the MAC the wrong-way around */
-		addr[4] = (lo & 0xff00) >> 8;
-		addr[3] = (lo & 0xff0000) >> 16;
-		addr[2] = (lo & 0xff000000) >> 24;
-		addr[1] = (hi & 0xff);
-		addr[0] = (hi & 0xff00) >> 8;
-	}
-	else {
-		addr[0] = (lo & 0xff);
-		addr[1] = (lo & 0xff00) >> 8;
-		addr[2] = (lo & 0xff0000) >> 16;
-		addr[3] = (lo & 0xff000000) >> 24;
-		addr[4] = (hi & 0xff);
-		addr[5] = (hi & 0xff00) >> 8;
-	}
+	addr[0] = (lo & 0xff);
+	addr[1] = (lo & 0xff00) >> 8;
+	addr[2] = (lo & 0xff0000) >> 16;
+	addr[3] = (lo & 0xff000000) >> 24;
+	addr[4] = (hi & 0xff);
+	addr[5] = (hi & 0xff00) >> 8;
 
 	if (is_valid_ether_addr(addr)) {
 		memcpy(dev->dev_addr, &addr, 6);
-- 
1.7.12.4
