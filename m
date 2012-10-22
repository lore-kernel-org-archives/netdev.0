From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH v3 4/4] net/at91_ether: add pdata flag for reverse Eth addr
Date: Mon, 22 Oct 2012 20:45:34 +0200
Message-ID: <1350931534-8416-5-git-send-email-manabian@gmail.com>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:40554 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046Ab2JVSrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 14:47:21 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1824433lag.19
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2012 11:47:20 -0700 (PDT)
In-Reply-To: <1350931534-8416-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow us to remove the last mach include from at91_ether
and also make it easier to share address setup with macb.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 arch/arm/mach-at91/board-csb337.c         | 2 ++
 drivers/net/ethernet/cadence/Kconfig      | 1 -
 drivers/net/ethernet/cadence/at91_ether.c | 5 ++---
 include/linux/platform_data/macb.h        | 1 +
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mach-at91/board-csb337.c b/arch/arm/mach-at91/board-csb337.c
index 3e37437..aa9b320 100644
--- a/arch/arm/mach-at91/board-csb337.c
+++ b/arch/arm/mach-at91/board-csb337.c
@@ -53,6 +53,8 @@ static void __init csb337_init_early(void)
 static struct macb_platform_data __initdata csb337_eth_data = {
 	.phy_irq_pin	= AT91_PIN_PC2,
 	.is_rmii	= 0,
+	/* The CSB337 bootloader stores the MAC the wrong-way around */
+	.rev_eth_addr	= 1,
 };
 
 static struct at91_usbh_data __initdata csb337_usbh_data = {
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
index 375d272..b92815a 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -32,8 +32,6 @@
 #include <linux/phy.h>
 #include <linux/io.h>
 
-#include <asm/mach-types.h>
-
 #include "macb.h"
 
 #define DRV_NAME	"at91_ether"
@@ -61,9 +59,10 @@
 
 static short __init unpack_mac_address(struct net_device *dev, unsigned int hi, unsigned int lo)
 {
+	struct macb *lp = netdev_priv(dev);
 	char addr[6];
 
-	if (machine_is_csb337()) {
+	if (lp->board_data.rev_eth_addr) {
 		addr[5] = (lo & 0xff);			/* The CSB337 bootloader stores the MAC the wrong-way around */
 		addr[4] = (lo & 0xff00) >> 8;
 		addr[3] = (lo & 0xff0000) >> 16;
diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
index b081c72..044a124 100644
--- a/include/linux/platform_data/macb.h
+++ b/include/linux/platform_data/macb.h
@@ -12,6 +12,7 @@ struct macb_platform_data {
 	u32		phy_mask;
 	int		phy_irq_pin;	/* PHY IRQ */
 	u8		is_rmii;	/* using RMII interface? */
+	u8		rev_eth_addr;	/* reverse Ethernet address byte order */
 };
 
 #endif /* __MACB_PDATA_H__ */
-- 
1.7.12.4
