From: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Subject: [RFC 4/4] [powerpc] Implement a p1010rdb clock source.
Date: Fri,  5 Aug 2011 23:05:04 -0500
Message-ID: <1312603504-30282-5-git-send-email-holt@sgi.com>
References: <1312603504-30282-1-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312603504-30282-1-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
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

flexcan driver needs the clk_get, clk_get_rate, etc functions
to work.  This patch provides the minimum functionality.

Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/powerpc/platforms/85xx/p1010rdb.c |   78 ++++++++++++++++++++++++++++++++
 1 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/platforms/85xx/p1010rdb.c
index 3540a88..8f78ddd 100644
--- a/arch/powerpc/platforms/85xx/p1010rdb.c
+++ b/arch/powerpc/platforms/85xx/p1010rdb.c
@@ -28,6 +28,7 @@
 #include <asm/udbg.h>
 #include <asm/mpic.h>
 #include <asm/swiotlb.h>
+#include <asm/clk_interface.h>
 
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
@@ -164,6 +165,82 @@ static void __init p1010_rdb_setup_arch(void)
 	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
 }
 
+/*
+ * p1010rdb needs to provide a clock source for the flexcan driver.
+ */
+struct clk {
+	unsigned long rate;
+} p1010rdb_system_clk;
+
+static struct clk *p1010_rdb_clk_get(struct device *dev, const char *id)
+{
+	struct clk *clk;
+	u32 *of_property;
+	unsigned long clock_freq, clock_divider;
+	const char *dev_init_name;
+
+	if (!dev)
+		return ERR_PTR(-ENOENT);
+
+	/*
+	 * The can devices are named ffe1c000.can0 and ffe1d000.can1 on
+	 * the p1010rdb.  Check for the "can" portion of that name before
+	 * returning a clock source.
+	 */
+	dev_init_name = dev_name(dev);
+	if (strlen(dev_init_name) != 13)
+		return ERR_PTR(-ENOENT);
+	dev_init_name += 9;
+	if (strncmp(dev_init_name, "can", 3))
+		return ERR_PTR(-ENOENT);
+
+	of_property = (u32 *)of_get_property(dev->of_node, "clock_freq", NULL);
+	if (!of_property)
+		return ERR_PTR(-ENOENT);
+	clock_freq = *of_property;
+
+	of_property = (u32 *)of_get_property(dev->of_node,
+					     "fsl,flexcan-clock-divider", NULL);
+	if (!of_property)
+		return ERR_PTR(-ENOENT);
+	clock_divider = *of_property;
+
+	clk = kmalloc(sizeof(struct clk), GFP_KERNEL);
+	if (!clk)
+		return ERR_PTR(-ENOMEM);
+
+	clk->rate = DIV_ROUND_CLOSEST(clock_freq / clock_divider, 1000);
+	clk->rate *= 1000;
+
+	return clk;
+}
+
+static void p1010_rdb_clk_put(struct clk *clk)
+{
+	kfree(clk);
+}
+
+static unsigned long p1010_rdb_clk_get_rate(struct clk *clk)
+{
+	return clk->rate;
+}
+
+static struct clk_interface p1010_rdb_clk_functions = {
+	.clk_get		= p1010_rdb_clk_get,
+	.clk_get_rate		= p1010_rdb_clk_get_rate,
+	.clk_put		= p1010_rdb_clk_put,
+};
+
+static void __init p1010_rdb_clk_init(void)
+{
+	clk_functions = p1010_rdb_clk_functions;
+}
+
+static void __init p1010_rdb_init(void)
+{
+	p1010_rdb_clk_init();
+}
+
 static struct of_device_id __initdata p1010rdb_ids[] = {
 	{ .type = "soc", },
 	{ .compatible = "soc", },
@@ -195,6 +272,7 @@ define_machine(p1010_rdb) {
 	.name			= "P1010 RDB",
 	.probe			= p1010_rdb_probe,
 	.setup_arch		= p1010_rdb_setup_arch,
+	.init			= p1010_rdb_init,
 	.init_IRQ		= p1010_rdb_pic_init,
 #ifdef CONFIG_PCI
 	.pcibios_fixup_bus	= fsl_pcibios_fixup_bus,
-- 
1.7.2.1
