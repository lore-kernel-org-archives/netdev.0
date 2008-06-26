From: Imre Kaloz <kaloz@openwrt.org>
Subject: [PATCH] Add support for the ethernet ports on IXP43x
Date: Thu, 26 Jun 2008 02:02:07 +0200
Message-ID: <12144385273321-git-send-email-kaloz@openwrt.org>
Cc: netdev@vger.kernel.org, khc@pm.waw.pl
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:26304 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750770AbYFZACx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 20:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 arch/arm/mach-ixp4xx/ixp4xx_npe.c         |    6 +++---
 drivers/net/arm/ixp4xx_eth.c              |   13 +++++++++----
 include/asm-arm/arch-ixp4xx/cpu.h         |    2 ++
 include/asm-arm/arch-ixp4xx/ixp4xx-regs.h |    7 ++++---
 4 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/arch/arm/mach-ixp4xx/ixp4xx_npe.c b/arch/arm/mach-ixp4xx/ixp4xx_npe.c
index 63a23fa..cb92702 100644
--- a/arch/arm/mach-ixp4xx/ixp4xx_npe.c
+++ b/arch/arm/mach-ixp4xx/ixp4xx_npe.c
@@ -575,8 +575,8 @@ int npe_load_firmware(struct npe *npe, const char *name, struct device *dev)
 		for (i = 0; i < image->size; i++)
 			image->data[i] = swab32(image->data[i]);
 
-	if (!cpu_is_ixp46x() && ((image->id >> 28) & 0xF /* device ID */)) {
-		print_npe(KERN_INFO, npe, "IXP46x firmware ignored on "
+	if (cpu_is_ixp42x() && ((image->id >> 28) & 0xF /* device ID */)) {
+		print_npe(KERN_INFO, npe, "IXP46x/IXP43x firmware ignored on "
 			  "IXP42x\n");
 		goto err;
 	}
@@ -596,7 +596,7 @@ int npe_load_firmware(struct npe *npe, const char *name, struct device *dev)
 		  "revision 0x%X:%X\n", (image->id >> 16) & 0xFF,
 		  (image->id >> 8) & 0xFF, image->id & 0xFF);
 
-	if (!cpu_is_ixp46x()) {
+	if (cpu_is_ixp42x()) {
 		if (!npe->id)
 			instr_size = NPE_A_42X_INSTR_SIZE;
 		else
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index c617b64..aaf7fa6 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -32,6 +32,7 @@
 #include <linux/kernel.h>
 #include <linux/mii.h>
 #include <linux/platform_device.h>
+#include <asm/arch/cpu.h>
 #include <asm/arch/npe.h>
 #include <asm/arch/qmgr.h>
 
@@ -1241,12 +1242,16 @@ static struct platform_driver drv = {
 
 static int __init eth_init_module(void)
 {
-	if (!(ixp4xx_read_feature_bits() & IXP4XX_FEATURE_NPEB_ETH0))
-		return -ENOSYS;
 
-	/* All MII PHY accesses use NPE-B Ethernet registers */
 	spin_lock_init(&mdio_lock);
-	mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
+	if (!cpu_is_ixp43x())
+	/* All MII PHY accesses use NPE-B Ethernet registers */
+		mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthB_BASE_VIRT;
+
+	else
+	/* IXP43x lacks NPE-B and uses NPE-C for MII PHY access */
+		mdio_regs = (struct eth_regs __iomem *)IXP4XX_EthC_BASE_VIRT;
+
 	__raw_writel(DEFAULT_CORE_CNTRL, &mdio_regs->core_control);
 
 	return platform_driver_register(&drv);
diff --git a/include/asm-arm/arch-ixp4xx/cpu.h b/include/asm-arm/arch-ixp4xx/cpu.h
index 2fa3d6b..0821cf2 100644
--- a/include/asm-arm/arch-ixp4xx/cpu.h
+++ b/include/asm-arm/arch-ixp4xx/cpu.h
@@ -34,6 +34,8 @@ static inline u32 ixp4xx_read_feature_bits(void)
 	val &= ~IXP4XX_FEATURE_RESERVED;
 	if (!cpu_is_ixp46x())
 		val &= ~IXP4XX_FEATURE_IXP46X_ONLY;
+	if (cpu_is_ixp42x())
+		val &= ~IXP4XX_FEATURE_IXP43X_46X;
 
 	return val;
 }
diff --git a/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h b/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
index 68aca85..1d0a218 100644
--- a/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
+++ b/include/asm-arm/arch-ixp4xx/ixp4xx-regs.h
@@ -628,11 +628,12 @@
 #define IXP4XX_FEATURE_XSCALE_MAX_FREQ	(3 << 22)
 #define IXP4XX_FEATURE_RESERVED		(0xFF << 24)
 
-#define IXP4XX_FEATURE_IXP46X_ONLY (IXP4XX_FEATURE_ECC_TIMESYNC |	\
+#define IXP4XX_FEATURE_IXP43X_46X (IXP4XX_FEATURE_ECC_TIMESYNC |	\
 				    IXP4XX_FEATURE_USB_HOST |		\
 				    IXP4XX_FEATURE_NPEA_ETH |		\
-				    IXP4XX_FEATURE_NPEB_ETH_1_TO_3 |	\
-				    IXP4XX_FEATURE_RSA |		\
 				    IXP4XX_FEATURE_XSCALE_MAX_FREQ)
 
+#define IXP4XX_FEATURE_IXP46X_ONLY (IXP4XX_FEATURE_NPEB_ETH_1_TO_3 |	\
+				    IXP4XX_FEATURE_RSA)
+
 #endif
-- 
1.5.2.5

