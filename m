From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Wed, 25 Apr 2007 01:55:49 +0900 (JST)
Message-ID: <20070425.015549.108742168.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This patch lets RBTX49XX boards use generic platform_driver interface
for the ne driver.

* Use platform_device to pass ioaddr and irq to the ne driver.
* Remove unnecessary ifdefs for RBTX49XX from the ne driver.
* Make the ne driver selectable on these boards regardless of CONFIG_ISA
* Add an ifdef for netcard_portlist[] to avoid unnecessary auto-probe.
  (I'm not sure M32R needs auto-probe but it is current behavior)

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 .../toshiba_rbtx4927/toshiba_rbtx4927_setup.c      |   19 +++++++++++++++++++
 arch/mips/tx4938/toshiba_rbtx4938/setup.c          |   20 ++++++++++++++++++++
 drivers/net/Kconfig                                |    2 +-
 drivers/net/ne.c                                   |   13 ++++---------
 4 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
index 0f7576d..7d2c9d0 100644
--- a/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
+++ b/arch/mips/tx4927/toshiba_rbtx4927/toshiba_rbtx4927_setup.c
@@ -1049,3 +1049,22 @@ static int __init toshiba_rbtx4927_rtc_init(void)
 	return IS_ERR(dev) ? PTR_ERR(dev) : 0;
 }
 device_initcall(toshiba_rbtx4927_rtc_init);
+
+static int __init rbtx4927_ne_init(void)
+{
+	struct resource res[] = {
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
index aba0d39..a80e8ce 100644
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
index b8a181f..4e99e7a 100644
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
@@ -81,7 +77,10 @@ static const char version2[] =
 /* A zero-terminated list of I/O addresses to be probed at boot. */
 #ifndef MODULE
 static unsigned int netcard_portlist[] __initdata = {
-	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
+#if defined(CONFIG_ISA) || defined(CONFIG_M32R)
+	0x300, 0x280, 0x320, 0x340, 0x360, 0x380,
+#endif
+	0
 };
 #endif
 
@@ -227,10 +226,6 @@ struct net_device * __init ne_probe(int unit)
 	sprintf(dev->name, "eth%d", unit);
 	netdev_boot_setup_check(dev);
 
-#ifdef CONFIG_TOSHIBA_RBTX4938
-	dev->base_addr = RBTX4938_RTL_8019_BASE;
-	dev->irq = RBTX4938_RTL_8019_IRQ;
-#endif
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
