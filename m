From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 4/5] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Tue, 01 May 2007 00:27:58 +0900 (JST)
Message-ID: <20070501.002758.15250764.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:55640 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423371AbXD3P14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:27:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch lets RBTX49XX boards use generic platform_driver interface
for the ne driver.

* Use platform_device to pass ioaddr and irq to the ne driver.
* Remove unnecessary ifdefs for RBTX49XX from the ne driver.
* Make the ne driver selectable on these boards regardless of CONFIG_ISA

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 .../toshiba_rbtx4927/toshiba_rbtx4927_setup.c      |   19 +++++++++++++++++++
 arch/mips/tx4938/toshiba_rbtx4938/setup.c          |   20 ++++++++++++++++++++
 drivers/net/Kconfig                                |    2 +-
 drivers/net/ne.c                                   |    8 --------
 4 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
index 0f7576d..a0c11ef 100644
--- a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
+++ b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
@@ -1049,3 +1049,22 @@ static int __init toshiba_rbtx4927_rtc_init(void)
 	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
 }
 device_initcall(toshiba_rbtx4927_rtc_init);
+
+static int __init rbtx4927_ne_init(void)
+{
+	static struct resource __initdata res[] = {
+		{
+			.start	= RBTX4927_RTL_8019_BASE,
+			.end	= RBTX4927_RTL_8019_BASE + 0x20 - 1,
+			.flags	= IORESOURCE_IO,
+		}, {
+			.start	= RBTX4927_RTL_8019_IRQ,
+			.flags	= IORESOURCE_IRQ,
+		}
+	};
+	struct platform_device *dev =
+		platform_device_register_simple("ne", -1,
+						res, ARRAY_SIZE(res));
+	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
+}
+device_initcall(rbtx4927_ne_init);
diff --git a/arch/mips/tx4938/toshiba_rbtx4938/setup.c b/arch/mips/tx4938/toshiba_rbtx4938/setup.c
index 66163ba..f5d1ce7 100644
--- a/arch/mips/tx4938/toshiba_rbtx4938/setup.c
+++ b/arch/mips/tx4938/toshiba_rbtx4938/setup.c
@@ -20,6 +20,7 @@
 #include <linux/console.h>
 #include <linux/pci.h>
 #include <linux/pm.h>
+#include <linux/platform_device.h>
 
 #include <asm/wbflush.h>
 #include <asm/reboot.h>
@@ -1037,3 +1038,22 @@ static int __init tx4938_spi_proc_setup(void)
 
 __initcall(tx4938_spi_proc_setup);
 #endif
+
+static int __init rbtx4938_ne_init(void)
+{
+	struct resource res[] = {
+		{
+			.start	= RBTX4938_RTL_8019_BASE,
+			.end	= RBTX4938_RTL_8019_BASE + 0x20 - 1,
+			.flags	= IORESOURCE_IO,
+		}, {
+			.start	= RBTX4938_RTL_8019_IRQ,
+			.flags	= IORESOURCE_IRQ,
+		}
+	};
+	struct platform_device *dev =
+		platform_device_register_simple("ne", -1,
+						res, ARRAY_SIZE(res));
+	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
+}
+device_initcall(rbtx4938_ne_init);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 88d924d..3796366 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1088,7 +1088,7 @@ config ETH16I
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R
+	depends on NET_ISA || (Q40 && m) || M32R || TOSHIBA_RBTX4927 || TOSHIBA_RBTX4938
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 22d6fe4..c9f74bf 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -56,10 +56,6 @@ static const char version2[] =
 #include <asm/system.h>
 #include <asm/io.h>
 
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
-#include <asm/tx4938/rbtx4938.h>
-#endif
-
 #include "8390.h"
 
 #define DRV_NAME "ne"
@@ -232,10 +228,6 @@ struct net_device * __init ne_probe(int unit)
 	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
-#ifdef CONFIG_TOSHIBA_RBTX4938
-	dev->base_addr = RBTX4938_RTL_8019_BASE;
-	dev->irq = RBTX4938_RTL_8019_IRQ;
-#endif
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
