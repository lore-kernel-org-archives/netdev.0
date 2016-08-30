From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 1/4] ARM: sa1100: convert to common clock framework
Date: Tue, 30 Aug 2016 11:52:35 +0100
Message-ID: <E1begeh-0006uo-BH@rmk-PC.armlinux.org.uk>
References: <20160830105117.GM1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:36579 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755400AbcH3Kwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 06:52:40 -0400
In-Reply-To: <20160830105117.GM1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert sa1100 to use the common clock framework.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/arm/Kconfig             |   1 +
 arch/arm/mach-sa1100/clock.c | 191 +++++++++++++++++++------------------------
 2 files changed, 87 insertions(+), 105 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index a91c47f30986..e6706601dbe9 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -588,6 +588,7 @@ config ARCH_SA1100
 	select CLKSRC_MMIO
 	select CLKSRC_PXA
 	select CLKSRC_OF if OF
+	select COMMON_CLK
 	select CPU_FREQ
 	select CPU_SA1100
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/arm/mach-sa1100/clock.c b/arch/arm/mach-sa1100/clock.c
index f6f75c9325bf..ebb39eba3717 100644
--- a/arch/arm/mach-sa1100/clock.c
+++ b/arch/arm/mach-sa1100/clock.c
@@ -1,151 +1,132 @@
 /*
  *  linux/arch/arm/mach-sa1100/clock.c
  */
-#include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/device.h>
-#include <linux/list.h>
 #include <linux/errno.h>
 #include <linux/err.h>
-#include <linux/string.h>
 #include <linux/clk.h>
-#include <linux/spinlock.h>
-#include <linux/mutex.h>
-#include <linux/io.h>
 #include <linux/clkdev.h>
+#include <linux/clk-provider.h>
+#include <linux/io.h>
+#include <linux/spinlock.h>
 
 #include <mach/hardware.h>
 #include <mach/generic.h>
 
-struct clkops {
-	void			(*enable)(struct clk *);
-	void			(*disable)(struct clk *);
-	unsigned long		(*get_rate)(struct clk *);
-};
-
-struct clk {
-	const struct clkops	*ops;
-	unsigned int		enabled;
+static const char *clk_tucr_parents[] = {
+	"clk32768", "clk3686400",
 };
 
-#define DEFINE_CLK(_name, _ops)				\
-struct clk clk_##_name = {				\
-		.ops	= _ops,				\
-	}
-
-static DEFINE_SPINLOCK(clocks_lock);
+static DEFINE_SPINLOCK(tucr_lock);
 
-static void clk_gpio27_enable(struct clk *clk)
+static int clk_gpio27_enable(struct clk_hw *hw)
 {
+	unsigned long flags;
+
 	/*
 	 * First, set up the 3.6864MHz clock on GPIO 27 for the SA-1111:
 	 * (SA-1110 Developer's Manual, section 9.1.2.1)
 	 */
+	local_irq_save(flags);
 	GAFR |= GPIO_32_768kHz;
 	GPDR |= GPIO_32_768kHz;
-	TUCR = TUCR_3_6864MHz;
-}
-
-static void clk_gpio27_disable(struct clk *clk)
-{
-	TUCR = 0;
-	GPDR &= ~GPIO_32_768kHz;
-	GAFR &= ~GPIO_32_768kHz;
-}
-
-static void clk_cpu_enable(struct clk *clk)
-{
-}
-
-static void clk_cpu_disable(struct clk *clk)
-{
-}
-
-static unsigned long clk_cpu_get_rate(struct clk *clk)
-{
-	return sa11x0_getspeed(0) * 1000;
-}
-
-int clk_enable(struct clk *clk)
-{
-	unsigned long flags;
-
-	if (clk) {
-		spin_lock_irqsave(&clocks_lock, flags);
-		if (clk->enabled++ == 0)
-			clk->ops->enable(clk);
-		spin_unlock_irqrestore(&clocks_lock, flags);
-	}
+	local_irq_restore(flags);
 
 	return 0;
 }
-EXPORT_SYMBOL(clk_enable);
 
-void clk_disable(struct clk *clk)
+static void clk_gpio27_disable(struct clk_hw *hw)
 {
 	unsigned long flags;
 
-	if (clk) {
-		WARN_ON(clk->enabled == 0);
-		spin_lock_irqsave(&clocks_lock, flags);
-		if (--clk->enabled == 0)
-			clk->ops->disable(clk);
-		spin_unlock_irqrestore(&clocks_lock, flags);
-	}
-}
-EXPORT_SYMBOL(clk_disable);
-
-unsigned long clk_get_rate(struct clk *clk)
-{
-	if (clk && clk->ops && clk->ops->get_rate)
-		return clk->ops->get_rate(clk);
-
-	return 0;
+	local_irq_save(flags);
+	GPDR &= ~GPIO_32_768kHz;
+	GAFR &= ~GPIO_32_768kHz;
+	local_irq_restore(flags);
 }
-EXPORT_SYMBOL(clk_get_rate);
 
-const struct clkops clk_gpio27_ops = {
-	.enable		= clk_gpio27_enable,
-	.disable	= clk_gpio27_disable,
+static const struct clk_ops clk_gpio27_ops = {
+	.enable = clk_gpio27_enable,
+	.disable = clk_gpio27_disable,
 };
 
-const struct clkops clk_cpu_ops = {
-	.enable		= clk_cpu_enable,
-	.disable	= clk_cpu_disable,
-	.get_rate	= clk_cpu_get_rate,
+static const char *clk_gpio27_parents[] = {
+	"tucr-mux",
 };
 
-static DEFINE_CLK(gpio27, &clk_gpio27_ops);
-
-static DEFINE_CLK(cpu, &clk_cpu_ops);
-
-static unsigned long clk_36864_get_rate(struct clk *clk)
+static unsigned long clk_mpll_recalc_rate(struct clk_hw *hw, unsigned long prate)
 {
-	return 3686400;
+	return sa11x0_getspeed(0) * 1000;
 }
 
-static struct clkops clk_36864_ops = {
-	.enable		= clk_cpu_enable,
-	.disable	= clk_cpu_disable,
-	.get_rate	= clk_36864_get_rate,
+static const struct clk_ops cpu_clock_ops = {
+	.recalc_rate = clk_mpll_recalc_rate,
 };
 
-static DEFINE_CLK(36864, &clk_36864_ops);
-
-static struct clk_lookup sa11xx_clkregs[] = {
-	CLKDEV_INIT("sa1111.0", NULL, &clk_gpio27),
-	CLKDEV_INIT("sa1100-rtc", NULL, NULL),
-	CLKDEV_INIT("sa11x0-fb", NULL, &clk_cpu),
-	CLKDEV_INIT("sa11x0-pcmcia", NULL, &clk_cpu),
-	CLKDEV_INIT("sa11x0-pcmcia.0", NULL, &clk_cpu),
-	CLKDEV_INIT("sa11x0-pcmcia.1", NULL, &clk_cpu),
-	/* sa1111 names devices using internal offsets, PCMCIA is at 0x1800 */
-	CLKDEV_INIT("1800", NULL, &clk_cpu),
-	CLKDEV_INIT(NULL, "OSTIMER0", &clk_36864),
+static const char *clk_mpll_parents[] = {
+	"clk3686400",
 };
 
 int __init sa11xx_clk_init(void)
 {
-	clkdev_add_table(sa11xx_clkregs, ARRAY_SIZE(sa11xx_clkregs));
+	struct clk_init_data init;
+	struct clk_hw *hw;
+	int ret;
+
+	hw = clk_hw_register_fixed_rate(NULL, "clk32768", NULL, 0, 32768);
+	if (IS_ERR(hw))
+		return PTR_ERR(hw);
+
+	clk_hw_register_clkdev(hw, NULL, "sa1100-rtc");
+
+	hw = clk_hw_register_fixed_rate(NULL, "clk3686400", NULL, 0, 3686400);
+	if (IS_ERR(hw))
+		return PTR_ERR(hw);
+
+	clk_hw_register_clkdev(hw, "OSTIMER0", NULL);
+
+	init.name = "mpll";
+	init.ops = &cpu_clock_ops;
+	init.flags = CLK_IS_BASIC;
+	init.parent_names = clk_mpll_parents;
+	init.num_parents = ARRAY_SIZE(clk_mpll_parents);
+	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
+	if (!hw)
+		return -ENOMEM;
+	hw->init = &init;
+	ret = clk_hw_register(NULL, hw);
+	if (ret) {
+		kfree(hw);
+		return ret;
+	}
+
+	clk_hw_register_clkdev(hw, NULL, "sa11x0-fb");
+	clk_hw_register_clkdev(hw, NULL, "sa11x0-pcmcia");
+	clk_hw_register_clkdev(hw, NULL, "sa11x0-pcmcia.0");
+	clk_hw_register_clkdev(hw, NULL, "sa11x0-pcmcia.1");
+	clk_hw_register_clkdev(hw, NULL, "1800");
+
+	hw = clk_hw_register_mux(NULL, "tucr-mux", clk_tucr_parents,
+				 ARRAY_SIZE(clk_tucr_parents), 0,
+				 (void __iomem *)&TUCR, FShft(TUCR_TSEL),
+				 FAlnMsk(TUCR_TSEL), 0, &tucr_lock);
+	clk_set_rate(hw->clk, 3686400);
+
+	init.name = "gpio27";
+	init.ops = &clk_gpio27_ops;
+	init.parent_names = clk_gpio27_parents;
+	init.num_parents = ARRAY_SIZE(clk_gpio27_parents);
+	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
+	if (!hw)
+		return -ENOMEM;
+	hw->init = &init;
+	ret = clk_hw_register(NULL, hw);
+	if (ret) {
+		kfree(hw);
+		return ret;
+	}
+
+	clk_hw_register_clkdev(hw, NULL, "sa1111.0");
+
 	return 0;
 }
-- 
2.1.0
