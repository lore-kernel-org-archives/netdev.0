From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [PATCH 4/5] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue,  9 Aug 2011 09:43:50 -0500
Message-ID: <1312901031-29887-5-git-send-email-holt@sgi.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: , netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312901031-29887-1-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

I added a simple clock source for the p1010rdb so the flexcan driver
could determine a clock frequency.  The p1010 can device only has an
oscillator of system bus frequency divided by 2.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
---
 arch/powerpc/platforms/85xx/Kconfig    |    2 +
 arch/powerpc/platforms/85xx/Makefile   |    2 +
 arch/powerpc/platforms/85xx/clock.c    |   53 ++++++++++++++++++++++++++++++++
 arch/powerpc/platforms/85xx/p1010rdb.c |    8 +++++
 4 files changed, 65 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/platforms/85xx/clock.c

diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
index 498534c..c4304ae 100644
--- a/arch/powerpc/platforms/85xx/Kconfig
+++ b/arch/powerpc/platforms/85xx/Kconfig
@@ -70,6 +70,8 @@ config MPC85xx_RDB
 config P1010_RDB
 	bool "Freescale P1010RDB"
 	select DEFAULT_UIMAGE
+	select HAVE_CAN_FLEXCAN if NET && CAN
+	select PPC_CLOCK if CAN_FLEXCAN
 	help
 	  This option enables support for the MPC85xx RDB (P1010 RDB) board
 
diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platforms/85xx/Makefile
index a971b32..cc7f381 100644
--- a/arch/powerpc/platforms/85xx/Makefile
+++ b/arch/powerpc/platforms/85xx/Makefile
@@ -3,6 +3,8 @@
 #
 obj-$(CONFIG_SMP) += smp.o
 
+obj-$(CONFIG_PPC_CLOCK)   += clock.o
+
 obj-$(CONFIG_MPC8540_ADS) += mpc85xx_ads.o
 obj-$(CONFIG_MPC8560_ADS) += mpc85xx_ads.o
 obj-$(CONFIG_MPC85xx_CDS) += mpc85xx_cds.o
diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platforms/85xx/clock.c
new file mode 100644
index 0000000..16fae04
--- /dev/null
+++ b/arch/powerpc/platforms/85xx/clock.c
@@ -0,0 +1,53 @@
+/*
+ * Copyright 2011 SGI, inc.
+ *
+ * This code is licensed for use under the GPL V2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/of.h>
+
+#include <asm/clk_interface.h>
+
+#include <sysdev/fsl_soc.h>
+
+/*
+ * p1010 needs to provide a clock source for the flexcan driver. The
+ * oscillator for the p1010 processor is only ever the system clock / 2.
+ */
+
+static struct clk *mpc85xx_clk_get(struct device *dev, const char *id)
+{
+	if (!dev)
+		return ERR_PTR(-ENOENT);
+
+        if (!dev->of_node ||
+            !of_device_is_compatible(dev->of_node, "fsl,flexcan"))
+                return ERR_PTR(-ENOENT);
+
+	return NULL;
+}
+
+static void mpc85xx_clk_put(struct clk *clk)
+{
+	return;
+}
+
+static unsigned long mpc85xx_clk_get_rate(struct clk *clk)
+{
+	return fsl_get_sys_freq() / 2;
+}
+
+static struct clk_interface mpc85xx_clk_functions = {
+	.clk_get = mpc85xx_clk_get,
+	.clk_get_rate = mpc85xx_clk_get_rate,
+	.clk_put = mpc85xx_clk_put,
+};
+
+void __init mpc85xx_clk_init(void)
+{
+	clk_functions = mpc85xx_clk_functions;
+}
+
diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/platforms/85xx/p1010rdb.c
index d7387fa..5e52122 100644
--- a/arch/powerpc/platforms/85xx/p1010rdb.c
+++ b/arch/powerpc/platforms/85xx/p1010rdb.c
@@ -81,6 +81,13 @@ static void __init p1010_rdb_setup_arch(void)
 	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
 }
 
+extern void mpc85xx_clk_init(void);
+
+static void __init p1010_rdb_init(void)
+{
+	mpc85xx_clk_init();
+}
+
 static struct of_device_id __initdata p1010rdb_ids[] = {
 	{ .type = "soc", },
 	{ .compatible = "soc", },
@@ -111,6 +118,7 @@ define_machine(p1010_rdb) {
 	.name			= "P1010 RDB",
 	.probe			= p1010_rdb_probe,
 	.setup_arch		= p1010_rdb_setup_arch,
+	.init			= p1010_rdb_init,
 	.init_IRQ		= p1010_rdb_pic_init,
 #ifdef CONFIG_PCI
 	.pcibios_fixup_bus	= fsl_pcibios_fixup_bus,
-- 
1.7.2.1
