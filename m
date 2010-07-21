From: Manuel Lauss <manuel.lauss@googlemail.com>
Subject: [PATCH] au1000_eth: get ethernet address from platform_data
Date: Wed, 21 Jul 2010 14:30:50 +0200
Message-ID: <1279715450-28762-1-git-send-email-manuel.lauss@googlemail.com>
Cc: netdev@vger.kernel.org, Manuel Lauss <manuel.lauss@googlemail.com>
To: Linux-MIPS <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49578 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447Ab0GUMa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 08:30:59 -0400
Received: by bwz1 with SMTP id 1so123805bwz.19
        for <netdev@vger.kernel.org>; Wed, 21 Jul 2010 05:30:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

au1000_eth uses firmware calls to get a valid MAC address, and changes
it depending on platform device id.  This patch moves this logic out
of the driver into the platform device registration part, where boards
with supported chips can use whatever firmware interface they need;
the default implementation maintains compatibility with existing,
YAMON-based firmware.

Tested-by: Wolfgang Grandegger <wg@denx.de>
Acked-by: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
---
This patch depends on another patch to the MIPS tree to
apply cleanly, so I'd prefer if it went in through it as well.

 arch/mips/alchemy/common/platform.c            |   15 ++++++++++-
 arch/mips/include/asm/mach-au1x00/au1xxx_eth.h |    1 +
 drivers/net/au1000_eth.c                       |   31 +++++------------------
 3 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/arch/mips/alchemy/common/platform.c b/arch/mips/alchemy/common/platform.c
index f9e5622..e9c354f 100644
--- a/arch/mips/alchemy/common/platform.c
+++ b/arch/mips/alchemy/common/platform.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
 #include <linux/platform_device.h>
 #include <linux/serial_8250.h>
 #include <linux/init.h>
@@ -21,6 +22,8 @@
 #include <asm/mach-au1x00/au1100_mmc.h>
 #include <asm/mach-au1x00/au1xxx_eth.h>
 
+#include <prom.h>
+
 #define PORT(_base, _irq)					\
 	{							\
 		.mapbase	= _base,			\
@@ -436,17 +439,27 @@ static int __init au1xxx_platform_init(void)
 {
 	unsigned int uartclk = get_au1x00_uart_baud_base() * 16;
 	int err, i;
+	unsigned char ethaddr[6];
 
 	/* Fill up uartclk. */
 	for (i = 0; au1x00_uart_data[i].flags; i++)
 		au1x00_uart_data[i].uartclk = uartclk;
 
+	/* use firmware-provided mac addr if available and necessary */
+	i = prom_get_ethernet_addr(ethaddr);
+	if (!i && !is_valid_ether_addr(au1xxx_eth0_platform_data.mac))
+		memcpy(au1xxx_eth0_platform_data.mac, ethaddr, 6);
+
 	err = platform_add_devices(au1xxx_platform_devices,
 				   ARRAY_SIZE(au1xxx_platform_devices));
 #ifndef CONFIG_SOC_AU1100
+	ethaddr[5] += 1;	/* next addr for 2nd MAC */
+	if (!i && !is_valid_ether_addr(au1xxx_eth1_platform_data.mac))
+		memcpy(au1xxx_eth1_platform_data.mac, ethaddr, 6);
+
 	/* Register second MAC if enabled in pinfunc */
 	if (!err && !(au_readl(SYS_PINFUNC) & (u32)SYS_PF_NI2))
-		platform_device_register(&au1xxx_eth1_device);
+		err = platform_device_register(&au1xxx_eth1_device);
 #endif
 
 	return err;
diff --git a/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
index bae9b75..49dc8d9 100644
--- a/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
+++ b/arch/mips/include/asm/mach-au1x00/au1xxx_eth.h
@@ -9,6 +9,7 @@ struct au1000_eth_platform_data {
 	int phy_addr;
 	int phy_busid;
 	int phy_irq;
+	char mac[6];
 };
 
 void __init au1xxx_override_eth_cfg(unsigned port,
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index ece6128..17e7e27 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -104,14 +104,6 @@ MODULE_VERSION(DRV_VERSION);
  * complete immediately.
  */
 
-/* These addresses are only used if yamon doesn't tell us what
- * the mac address is, and the mac address is not passed on the
- * command line.
- */
-static unsigned char au1000_mac_addr[6] __devinitdata = {
-	0x00, 0x50, 0xc2, 0x0c, 0x30, 0x00
-};
-
 struct au1000_private *au_macs[NUM_ETH_INTERFACES];
 
 /*
@@ -1002,7 +994,6 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	db_dest_t *pDB, *pDBfree;
 	int irq, i, err = 0;
 	struct resource *base, *macen;
-	char ethaddr[6];
 
 	base = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!base) {
@@ -1079,24 +1070,13 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	}
 	aup->mac_id = pdev->id;
 
-	if (pdev->id == 0) {
-		if (prom_get_ethernet_addr(ethaddr) == 0)
-			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
-		else {
-			netdev_info(dev, "No MAC address found\n");
-				/* Use the hard coded MAC addresses */
-		}
-
+	if (pdev->id == 0)
 		au1000_setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
-	} else if (pdev->id == 1)
+	else if (pdev->id == 1)
 		au1000_setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
 
-	/*
-	 * Assign to the Ethernet ports two consecutive MAC addresses
-	 * to match those that are printed on their stickers
-	 */
-	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
-	dev->dev_addr[5] += pdev->id;
+	/* set a random MAC now in case platform_data doesn't provide one */
+	random_ether_addr(dev->dev_addr);
 
 	*aup->enable = 0;
 	aup->mac_enabled = 0;
@@ -1106,6 +1086,9 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		dev_info(&pdev->dev, "no platform_data passed, PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
+		if (is_valid_ether_addr(pd->mac))
+			memcpy(dev->dev_addr, pd->mac, 6);
+
 		aup->phy_static_config = pd->phy_static_config;
 		aup->phy_search_highest_addr = pd->phy_search_highest_addr;
 		aup->phy1_search_mac0 = pd->phy1_search_mac0;
-- 
1.7.1.1

