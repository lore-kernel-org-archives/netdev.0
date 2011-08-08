From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 8 Aug 2011 15:27:41 -0500
Message-ID: <20110808202741.GI4926@sgi.com>
References: <4E3FF4B8.2010603@grandegger.com>
 <20110808144424.GY4926@sgi.com>
 <4E3FF9EA.6030601@grandegger.com>
 <4E3FFD5B.7080000@pengutronix.de>
 <4E4001E1.3030508@grandegger.com>
 <20110808155540.GD4926@sgi.com>
 <4E4008BA.6030303@grandegger.com>
 <20110808160810.GF4926@sgi.com>
 <4E402CF1.1040300@grandegger.com>
 <20110808191403.GG4926@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Holt <holt@sgi.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, U Bhaskar-B22300 <B22300@freescale.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:60977 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751023Ab1HHU1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 16:27:45 -0400
Content-Disposition: inline
In-Reply-To: <20110808191403.GG4926@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2011 at 02:14:03PM -0500, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 08:37:37PM +0200, Wolfgang Grandegger wrote:
> > On 08/08/2011 06:08 PM, Robin Holt wrote:
> > > On Mon, Aug 08, 2011 at 06:03:06PM +0200, Wolfgang Grandegger wrote:
> > ...
> > > So we would stay with the clk_* functions.  I assume clk_get() would
> > > return NULL, clk_get_rate() would just return fsl_get_sys_freq() and
> > > the other functions would do nothing.  Doesn't this really polute what
> > > clk_* functions are supposed to do?  Aren't we making flexcan dictate
> > > a different behavior for powerpc than for the arm (and possibly other)
> > > architectures?
> > 
> > Well, I see it as one way to provide compatibility with the ARM port. If
> > the PowerPC people don't like it, we can switch to something else,
> > whatever they suggest.
> 
> I have spent the last few hours and I think I found the communication
> problem and I think it is me.
> 
> I assumed long ago we would be better off implementing a Kconfig language
> which does "select PPC_CLOCK".  This assumption was in part because I
> did not understand what I was doing when I started this (still don't
> honestly), but I did know the freescale patch series did a select
> PPC_CLOCK.
> 
> Here is my patch for introducing the p1010 clock source.  Am I finally
> starting to understand your guidance?
> 
> Thanks,
> Robin
> 

Here is _ALL_ of the patch.  Sorry about the earlier noise.

Robin

------------------------------------------------------------------------


diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
index 498534c..ed4cf92 100644
--- a/arch/powerpc/platforms/85xx/Kconfig
+++ b/arch/powerpc/platforms/85xx/Kconfig
@@ -26,6 +26,10 @@ config MPC8560_ADS
 	help
 	  This option enables support for the MPC 8560 ADS board
 
+config 85xx_HAVE_CAN_FLEXCAN
+	bool
+	select HAVE_CAN_FLEXCAN if NET && CAN
+
 config MPC85xx_CDS
 	bool "Freescale MPC85xx CDS"
 	select DEFAULT_UIMAGE
@@ -70,6 +74,8 @@ config MPC85xx_RDB
 config P1010_RDB
 	bool "Freescale P1010RDB"
 	select DEFAULT_UIMAGE
+	select 85xx_HAVE_CAN_FLEXCAN
+	select PPC_CLOCK if CAN_FLEXCAN
 	help
 	  This option enables support for the MPC85xx RDB (P1010 RDB) board
 
diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platforms/85xx/Makefile
index a971b32..64ad7a4 100644
--- a/arch/powerpc/platforms/85xx/Makefile
+++ b/arch/powerpc/platforms/85xx/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_MPC85xx_DS)  += mpc85xx_ds.o
 obj-$(CONFIG_MPC85xx_MDS) += mpc85xx_mds.o
 obj-$(CONFIG_MPC85xx_RDB) += mpc85xx_rdb.o
 obj-$(CONFIG_P1010_RDB)   += p1010rdb.o
+obj-$(CONFIG_PPC_CLOCK)   += clock.o
 obj-$(CONFIG_P1022_DS)    += p1022_ds.o
 obj-$(CONFIG_P1023_RDS)   += p1023_rds.o
 obj-$(CONFIG_P2040_RDB)   += p2040_rdb.o corenet_ds.o
diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platforms/85xx/clock.c
new file mode 100644
index 0000000..a25cbf3
--- /dev/null
+++ b/arch/powerpc/platforms/85xx/clock.c
@@ -0,0 +1,59 @@
+
+#include <linux/device.h>
+#include <linux/err.h>
+
+#include <asm/clk_interface.h>
+
+#include <sysdev/fsl_soc.h>
+
+/*
+ * p1010rdb needs to provide a clock source for the flexcan driver.
+ */
+struct clk {
+	unsigned long rate;
+} p1010_rdb_system_clock;
+
+static struct clk *p1010_rdb_clk_get(struct device *dev, const char *id)
+{
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
+	return &p1010_rdb_system_clock;
+}
+
+static void p1010_rdb_clk_put(struct clk *clk)
+{
+	return;
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
+void __init p1010_rdb_clk_init(void)
+{
+	p1010_rdb_system_clock.rate = fsl_get_sys_freq();
+	clk_functions = p1010_rdb_clk_functions;
+}
+
diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/platforms/85xx/p1010rdb.c
index d7387fa..29e04d6 100644
--- a/arch/powerpc/platforms/85xx/p1010rdb.c
+++ b/arch/powerpc/platforms/85xx/p1010rdb.c
@@ -81,6 +81,13 @@ static void __init p1010_rdb_setup_arch(void)
 	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
 }
 
+static void __init p1010_rdb_init(void)
+{
+#ifdef PPC_CLOCK
+	p1010_rdb_clk_init();
+#endif
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
