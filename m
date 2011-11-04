From: Zhao Chenhui <chenhui.zhao@freescale.com>
Subject: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event source
Date: Fri, 4 Nov 2011 20:39:09 +0800
Message-ID: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <leoli@freescale.com>, <netdev@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:59986 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab1KDMjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 08:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add APIs for setting wakeup source and lossless Ethernet in low power modes.
These APIs can be used by wake-on-packet feature.

Signed-off-by: Dave Liu <daveliu@freescale.com>
Signed-off-by: Li Yang <leoli@freescale.com>
Signed-off-by: Jin Qing <b24347@freescale.com>
Signed-off-by: Zhao Chenhui <chenhui.zhao@freescale.com>
---
 arch/powerpc/sysdev/fsl_pmc.c |   67 +++++++++++++++++++++++++++++++++++++++++
 arch/powerpc/sysdev/fsl_soc.h |   11 +++++++
 2 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_pmc.c b/arch/powerpc/sysdev/fsl_pmc.c
index 58d35d8..dab8161 100644
--- a/arch/powerpc/sysdev/fsl_pmc.c
+++ b/arch/powerpc/sysdev/fsl_pmc.c
@@ -38,6 +38,7 @@ static struct device *pmc_dev;
 static struct pmc_regs __iomem *pmc_regs;
 
 #define PMCSR_SLP	0x00020000
+#define PMCSR_LOSSLESS	0x00400000
 static int has_deep_sleep;
 static int has_lossless;
 
@@ -45,6 +46,72 @@ static int has_lossless;
  * code can be compatible with both 32-bit & 36-bit */
 extern void mpc85xx_enter_deep_sleep(u64 ccsrbar, u32 powmgtreq);
 
+#ifdef CONFIG_FSL_PMC
+/**
+ * pmc_enable_wake - enable OF device as wakeup event source
+ * @pdev: platform device affected
+ * @state: PM state from which device will issue wakeup events
+ * @enable: True to enable event generation; false to disable
+ *
+ * This enables the device as a wakeup event source, or disables it.
+ *
+ * RETURN VALUE:
+ * 0 is returned on success
+ * -EINVAL is returned if device is not supposed to wake up the system
+ * Error code depending on the platform is returned if both the platform and
+ * the native mechanism fail to enable the generation of wake-up events
+ */
+int pmc_enable_wake(struct platform_device *pdev,
+				suspend_state_t state, bool enable)
+{
+	int ret = 0;
+	struct device_node *clk_np;
+	u32 *pmcdr_mask;
+
+	if (!pmc_regs) {
+		printk(KERN_WARNING "PMC is unavailable\n");
+		return -ENOMEM;
+	}
+
+	if (enable && !device_may_wakeup(&pdev->dev))
+		return -EINVAL;
+
+	clk_np = of_parse_phandle(pdev->dev.of_node, "clk-handle", 0);
+	if (!clk_np)
+		return -EINVAL;
+
+	pmcdr_mask = (u32 *)of_get_property(clk_np, "fsl,pmcdr-mask", NULL);
+	if (!pmcdr_mask) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* clear to enable clock in low power mode */
+	if (enable)
+		clrbits32(&pmc_regs->pmcdr, *pmcdr_mask);
+	else
+		setbits32(&pmc_regs->pmcdr, *pmcdr_mask);
+
+out:
+	of_node_put(clk_np);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pmc_enable_wake);
+
+/**
+ * pmc_enable_lossless - enable lossless ethernet in low power mode
+ * @enable: True to enable event generation; false to disable
+ */
+void pmc_enable_lossless(int enable)
+{
+	if (enable && has_lossless)
+		setbits32(&pmc_regs->pmcsr, PMCSR_LOSSLESS);
+	else
+		clrbits32(&pmc_regs->pmcsr, PMCSR_LOSSLESS);
+}
+EXPORT_SYMBOL_GPL(pmc_enable_lossless);
+#endif
+
 static int pmc_suspend_enter(suspend_state_t state)
 {
 	int ret;
diff --git a/arch/powerpc/sysdev/fsl_soc.h b/arch/powerpc/sysdev/fsl_soc.h
index c6d0073..f4f322a 100644
--- a/arch/powerpc/sysdev/fsl_soc.h
+++ b/arch/powerpc/sysdev/fsl_soc.h
@@ -3,6 +3,8 @@
 #ifdef __KERNEL__
 
 #include <asm/mmu.h>
+#include <linux/platform_device.h>
+#include <linux/suspend.h>
 
 struct spi_device;
 
@@ -21,6 +23,15 @@ struct device_node;
 
 extern void fsl_rstcr_restart(char *cmd);
 
+#ifdef CONFIG_FSL_PMC
+int pmc_enable_wake(struct platform_device *pdev, suspend_state_t state,
+		bool enable);
+void pmc_enable_lossless(int enable);
+#else
+#define pmc_enable_wake(pdev, state, enable)
+#define pmc_enable_lossless(enable)
+#endif
+
 #if defined(CONFIG_FB_FSL_DIU) || defined(CONFIG_FB_FSL_DIU_MODULE)
 
 /* The different ports that the DIU can be connected to */
-- 
1.6.4.1
