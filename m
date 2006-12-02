From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 07/10] chelsio: use standard CRC routines
Date: Fri, 01 Dec 2006 16:36:19 -0800
Message-ID: <20061202003707.675818000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:65251 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162420AbWLBAmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:42:52 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=pm3393-crc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace driver crc calculation with existing library.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/Kconfig          |    1 +
 drivers/net/chelsio/pm3393.c |   31 +++----------------------------
 2 files changed, 4 insertions(+), 28 deletions(-)

--- chelsio.orig/drivers/net/Kconfig
+++ chelsio/drivers/net/Kconfig
@@ -2360,6 +2360,7 @@ menu "Ethernet (10000 Mbit)"
 config CHELSIO_T1
         tristate "Chelsio 10Gb Ethernet support"
         depends on PCI
+	select CRC32
         help
           This driver supports Chelsio gigabit and 10-gigabit
           Ethernet cards. More information about adapter features and
--- chelsio.orig/drivers/net/chelsio/pm3393.c
+++ chelsio/drivers/net/chelsio/pm3393.c
@@ -43,6 +43,8 @@
 #include "elmer0.h"
 #include "suni1x10gexp_regs.h"
 
+#include <linux/crc32.h>
+
 #define OFFSET(REG_ADDR)    (REG_ADDR << 2)
 
 /* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
@@ -345,33 +347,6 @@ static int pm3393_set_mtu(struct cmac *c
 	return 0;
 }
 
-static u32 calc_crc(u8 *b, int len)
-{
-	int i;
-	u32 crc = (u32)~0;
-
-	/* calculate crc one bit at a time */
-	while (len--) {
-		crc ^= *b++;
-		for (i = 0; i < 8; i++) {
-			if (crc & 0x1)
-				crc = (crc >> 1) ^ 0xedb88320;
-			else
-				crc = (crc >> 1);
-		}
-	}
-
-	/* reverse bits */
-	crc = ((crc >> 4) & 0x0f0f0f0f) | ((crc << 4) & 0xf0f0f0f0);
-	crc = ((crc >> 2) & 0x33333333) | ((crc << 2) & 0xcccccccc);
-	crc = ((crc >> 1) & 0x55555555) | ((crc << 1) & 0xaaaaaaaa);
-	/* swap bytes */
-	crc = (crc >> 16) | (crc << 16);
-	crc = (crc >> 8 & 0x00ff00ff) | (crc << 8 & 0xff00ff00);
-
-	return crc;
-}
-
 static int pm3393_set_rx_mode(struct cmac *cmac, struct t1_rx_mode *rm)
 {
 	int enabled = cmac->instance->enabled & MAC_DIRECTION_RX;
@@ -405,7 +380,7 @@ static int pm3393_set_rx_mode(struct cma
 		u16 mc_filter[4] = { 0, };
 
 		while ((addr = t1_get_next_mcaddr(rm))) {
-			bit = (calc_crc(addr, ETH_ALEN) >> 23) & 0x3f;	/* bit[23:28] */
+			bit = (ether_crc(ETH_ALEN, addr) >> 23) & 0x3f;	/* bit[23:28] */
 			mc_filter[bit >> 4] |= 1 << (bit & 0xf);
 		}
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_LOW, mc_filter[0]);

-- 

