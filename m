From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH V4 2/4] CS89x0 : add CS89x0 platform device to the iMX21ADS board
Date: Thu, 19 Jan 2012 19:13:50 +0100
Message-ID: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: s.hauer@pengutronix.de, kernel@pengutronix.de,
	u.kleine-koenig@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49233 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195Ab2ASSN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 13:13:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so89760eek.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 10:13:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CS89x0 networking support to the iMX21ADS board by using the
platform driver support in the CS89x0 driver.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 arch/arm/configs/imx_v4_v5_defconfig |    2 ++
 arch/arm/mach-imx/mach-mx21ads.c     |   31 ++++++++++++++++++++++++++++---
 2 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/configs/imx_v4_v5_defconfig
index 11a4192..fc0106f 100644
--- a/arch/arm/configs/imx_v4_v5_defconfig
+++ b/arch/arm/configs/imx_v4_v5_defconfig
@@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=y
 CONFIG_SMC91X=y
 CONFIG_DM9000=y
 CONFIG_SMC911X=y
+CONFIG_CS89x0=y
+CONFIG_CS89x0_PLATFORM=y
 # CONFIG_NETDEV_1000 is not set
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_INPUT_MOUSEDEV is not set
diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/mach-mx21ads.c
index 25f8402..4fd37fc 100644
--- a/arch/arm/mach-imx/mach-mx21ads.c
+++ b/arch/arm/mach-imx/mach-mx21ads.c
@@ -37,8 +37,8 @@
 #define MX21ADS_REG_ADDR(offset)    (void __force __iomem *) \
 		(MX21ADS_MMIO_BASE_ADDR + (offset))
 
+#define MX21ADS_CS8900A_MMIO_SIZE   0x200000
 #define MX21ADS_CS8900A_IRQ         IRQ_GPIOE(11)
-#define MX21ADS_CS8900A_IOBASE_REG  MX21ADS_REG_ADDR(0x000000)
 #define MX21ADS_ST16C255_IOBASE_REG MX21ADS_REG_ADDR(0x200000)
 #define MX21ADS_VERSION_REG         MX21ADS_REG_ADDR(0x400000)
 #define MX21ADS_IO_REG              MX21ADS_REG_ADDR(0x800000)
@@ -159,6 +159,26 @@ static struct platform_device mx21ads_nor_mtd_device = {
 	.resource = &mx21ads_flash_resource,
 };
 
+static const struct resource mx21ads_cs8900_resources[] __initconst = {
+	{
+		.start = MX21_CS1_BASE_ADDR,
+		.end = MX21_CS1_BASE_ADDR +  MX21ADS_CS8900A_MMIO_SIZE - 1,
+		.flags = IORESOURCE_MEM,
+	},
+	{
+		.start = MX21ADS_CS8900A_IRQ,
+		.end = MX21ADS_CS8900A_IRQ,
+		.flags = IORESOURCE_IRQ,
+	}
+};
+
+static const struct platform_device_info mx21ads_cs8900_devinfo __initconst = {
+	.name = "cs89x0",
+	.id = 0,
+	.res = mx21ads_cs8900_resources,
+	.num_res = ARRAY_SIZE(mx21ads_cs8900_resources),
+};
+
 static const struct imxuart_platform_data uart_pdata_rts __initconst = {
 	.flags = IMXUART_HAVE_RTSCTS,
 };
@@ -254,14 +274,17 @@ mx21ads_nand_board_info __initconst = {
 static struct map_desc mx21ads_io_desc[] __initdata = {
 	/*
 	 * Memory-mapped I/O on MX21ADS Base board:
-	 *   - CS8900A Ethernet controller
 	 *   - ST16C2552CJ UART
 	 *   - CPU and Base board version
 	 *   - Base board I/O register
+	 *
+	 * Note that the CS8900 uses the first MX21ADS_CS8900A_MMIO_SIZE
+	 * bytes of the CS1 memory range.
 	 */
 	{
 		.virtual = MX21ADS_MMIO_BASE_ADDR,
-		.pfn = __phys_to_pfn(MX21_CS1_BASE_ADDR),
+		.pfn = __phys_to_pfn(MX21_CS1_BASE_ADDR +
+					MX21ADS_CS8900A_MMIO_SIZE),
 		.length = MX21ADS_MMIO_SIZE,
 		.type = MT_DEVICE,
 	},
@@ -292,6 +315,8 @@ static void __init mx21ads_board_init(void)
 	imx21_add_mxc_nand(&mx21ads_nand_board_info);
 
 	platform_add_devices(platform_devices, ARRAY_SIZE(platform_devices));
+	platform_device_register_full(
+			(struct platform_device_info *)&mx21ads_cs8900_devinfo);
 }
 
 static void __init mx21ads_timer_init(void)
-- 
1.7.1
