From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: IXP42x rev. A0 support for network devices
Date: Sun, 26 Apr 2009 23:58:27 +0200
Message-ID: <m3y6tnaxh8.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Benoit LIETAER <blietaer@free.fr>, John Woods <johnrw@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754292AbZDZV6o@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

well, I finally found that old prototype board with IXP425 rev A0 and
I was even able to implant some modern RedBoot to it, so I gave it
a try.

It seems that a list of rev. A0 bugs (or "bugs") isn't that long after
all (those affecting Ethernet at least). Basically the QMgr IRQ status
is unreliable, and the undocumented "feature" register is write-only.

This patch is a bit of handcraft but it applies to 2.6.29 and
probably to older kernels.
Benoit, John, please let me know if it works or not. Thanks.
-- 
Krzysztof Halasa

--- a/arch/arm/mach-ixp4xx/include/mach/cpu.h
+++ b/arch/arm/mach-ixp4xx/include/mach/cpu.h
@@ -26,6 +26,8 @@
 #define IXP46X_PROCESSOR_ID_VALUE	0x69054200
 #define IXP46X_PROCESSOR_ID_MASK	0xfffffff0
 
+#define cpu_is_ixp42x_rev_a0() ((read_cpuid_id() & (IXP4XX_PROCESSOR_ID_MASK | 0xF)) == \
+				IXP42X_PROCESSOR_ID_VALUE)
 #define cpu_is_ixp42x()	((read_cpuid_id() & IXP4XX_PROCESSOR_ID_MASK) == \
 			 IXP42X_PROCESSOR_ID_VALUE)
 #define cpu_is_ixp43x()	((read_cpuid_id() & IXP43X_PROCESSOR_ID_MASK) == \
@@ -35,6 +35,9 @@
 {
	unsigned int val = ~*IXP4XX_EXP_CFG2;
 	val &= ~IXP4XX_FEATURE_RESERVED;
+	if (cpu_is_ixp42x_rev_a0())
+		return ~IXP4XX_FEATURE_IXP46X_ONLY & ~(IXP4XX_FEATURE_RCOMP |
+						       IXP4XX_FEATURE_AES);
 	if (!cpu_is_ixp46x())
 		val &= ~IXP4XX_FEATURE_IXP46X_ONLY;
 
--- a/arch/arm/mach-ixp4xx/ixp4xx_npe.c
+++ b/arch/arm/mach-ixp4xx/ixp4xx_npe.c
@@ -386,15 +386,6 @@ static int npe_reset(struct npe *npe)
 	/* reset the NPE */
 	ixp4xx_write_feature_bits(val &
 				  ~(IXP4XX_FEATURE_RESET_NPEA << npe->id));
-	for (i = 0; i < MAX_RETRIES; i++) {
-		if (!(ixp4xx_read_feature_bits() &
-		      (IXP4XX_FEATURE_RESET_NPEA << npe->id)))
-			break;	/* reset completed */
-		udelay(1);
-	}
-	if (i == MAX_RETRIES)
-		return -ETIMEDOUT;
-
 	/* deassert reset */
 	ixp4xx_write_feature_bits(val |
 				  (IXP4XX_FEATURE_RESET_NPEA << npe->id));
--- a/arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
+++ b/arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
@@ -41,6 +41,31 @@ void qmgr_set_irq(unsigned int queue, int src,
 }
 
 
+static irqreturn_t qmgr_irq1_a0(int irq, void *pdev)
+{
+	int i, ret = 0;
+
+	/* ACK - it may also clear newly requested irqs so don't rely on it */
+	__raw_writel(__raw_readl(&qmgr_regs->irqstat[0]),
+		     &qmgr_regs->irqstat[0]);
+
+	for (i = 0; i < HALF_QUEUES; i++) {
+		u32 src, stat;
+		if (!(qmgr_regs->irqen[0] & BIT(i)))
+			continue;
+		src = qmgr_regs->irqsrc[i >> 3];
+		stat = qmgr_regs->stat1[i >> 3];
+		if (src & 4) /* the IRQ condition is inverted */
+			stat = ~stat;
+		if (stat & BIT(src & 3)) {
+			irq_handlers[i](irq_pdevs[i]);
+			ret = IRQ_HANDLED;
+		}
+	}
+	return ret;
+}
+
+
 static irqreturn_t qmgr_irq1(int irq, void *pdev)
 {
 	int i;
@@ -250,8 +275,8 @@ static int qmgr_init(void)
 	for (i = 0; i < QUEUES; i++)
 		__raw_writel(0, &qmgr_regs->sram[i]);
 
-	err = request_irq(IRQ_IXP4XX_QM1, qmgr_irq1, 0,
-			  "IXP4xx Queue Manager", NULL);
+	err = request_irq(IRQ_IXP4XX_QM1, cpu_is_ixp42x_rev_a0() ? qmgr_irq1_a0
+			  : qmgr_irq1, 0, "IXP4xx Queue Manager", NULL);
 	if (err) {
 		printk(KERN_ERR "qmgr: failed to request IRQ%i\n",
 		       IRQ_IXP4XX_QM1);
