From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v3 02/11] irqchip: axi-intc: Clean up irqdomain argument and read/write
Date: Wed, 31 Aug 2016 17:35:43 +0100
Message-ID: <1472661352-11983-3-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <soren.brinkmann@xilinx.com>, <Zubair.Kakakhel@imgtec.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <michal.simek@xilinx.com>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The drivers read/write function handling is a bit quirky.
And the irqmask is passed directly to the handler.

Add a new irqchip struct to pass to the handler and
cleanup read/write handling.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V2 -> V3
New patch. Cleans up driver structure
---
 drivers/irqchip/irq-axi-intc.c | 85 +++++++++++++++++++++++++++---------------
 1 file changed, 54 insertions(+), 31 deletions(-)

diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
index 90bec7d..cb69241 100644
--- a/drivers/irqchip/irq-axi-intc.c
+++ b/drivers/irqchip/irq-axi-intc.c
@@ -16,8 +16,6 @@
 #include <linux/io.h>
 #include <linux/bug.h>
 
-static void __iomem *intc_baseaddr;
-
 /* No one else should require these constants, so define them locally here. */
 #define ISR 0x00			/* Interrupt Status Register */
 #define IPR 0x04			/* Interrupt Pending Register */
@@ -31,8 +29,16 @@ static void __iomem *intc_baseaddr;
 #define MER_ME (1<<0)
 #define MER_HIE (1<<1)
 
-static unsigned int (*read_fn)(void __iomem *);
-static void (*write_fn)(u32, void __iomem *);
+struct xintc_irq_chip {
+	void __iomem *base;
+	struct	irq_domain *domain;
+	struct	irq_chip chip;
+	u32	intr_mask;
+	unsigned int (*read)(void __iomem *iomem);
+	void (*write)(u32 data, void __iomem *iomem);
+};
+
+static struct xintc_irq_chip *xintc_irqc;
 
 static void intc_write32(u32 val, void __iomem *addr)
 {
@@ -54,6 +60,18 @@ static unsigned int intc_read32_be(void __iomem *addr)
 	return ioread32be(addr);
 }
 
+static inline unsigned int xintc_read(struct xintc_irq_chip *xintc_irqc,
+					     int reg)
+{
+	return xintc_irqc->read(xintc_irqc->base + reg);
+}
+
+static inline void xintc_write(struct xintc_irq_chip *xintc_irqc,
+				     int reg, u32 data)
+{
+	xintc_irqc->write(data, xintc_irqc->base + reg);
+}
+
 static void intc_enable_or_unmask(struct irq_data *d)
 {
 	unsigned long mask = 1 << d->hwirq;
@@ -65,21 +83,21 @@ static void intc_enable_or_unmask(struct irq_data *d)
 	 * acks the irq before calling the interrupt handler
 	 */
 	if (irqd_is_level_type(d))
-		write_fn(mask, intc_baseaddr + IAR);
+		xintc_write(xintc_irqc, IAR, mask);
 
-	write_fn(mask, intc_baseaddr + SIE);
+	xintc_write(xintc_irqc, SIE, mask);
 }
 
 static void intc_disable_or_mask(struct irq_data *d)
 {
 	pr_debug("disable: %ld\n", d->hwirq);
-	write_fn(1 << d->hwirq, intc_baseaddr + CIE);
+	xintc_write(xintc_irqc, CIE, 1 << d->hwirq);
 }
 
 static void intc_ack(struct irq_data *d)
 {
 	pr_debug("ack: %ld\n", d->hwirq);
-	write_fn(1 << d->hwirq, intc_baseaddr + IAR);
+	xintc_write(xintc_irqc, IAR, 1 << d->hwirq);
 }
 
 static void intc_mask_ack(struct irq_data *d)
@@ -87,8 +105,8 @@ static void intc_mask_ack(struct irq_data *d)
 	unsigned long mask = 1 << d->hwirq;
 
 	pr_debug("disable_and_ack: %ld\n", d->hwirq);
-	write_fn(mask, intc_baseaddr + CIE);
-	write_fn(mask, intc_baseaddr + IAR);
+	xintc_write(xintc_irqc, CIE, mask);
+	xintc_write(xintc_irqc, IAR, mask);
 }
 
 static struct irq_chip intc_dev = {
@@ -105,7 +123,7 @@ unsigned int get_irq(void)
 {
 	unsigned int hwirq, irq = -1;
 
-	hwirq = read_fn(intc_baseaddr + IVR);
+	hwirq = xintc_read(xintc_irqc, IVR);
 	if (hwirq != -1U)
 		irq = irq_find_mapping(root_domain, hwirq);
 
@@ -116,7 +134,8 @@ unsigned int get_irq(void)
 
 static int xintc_map(struct irq_domain *d, unsigned int irq, irq_hw_number_t hw)
 {
-	u32 intr_mask = (u32)d->host_data;
+	struct xintc_irq_chip *irqc = d->host_data;
+	u32 intr_mask = irqc->intr_mask;
 
 	if (intr_mask & (1 << hw)) {
 		irq_set_chip_and_handler_name(irq, &intc_dev,
@@ -138,11 +157,18 @@ static const struct irq_domain_ops xintc_irq_domain_ops = {
 static int __init xilinx_intc_of_init(struct device_node *intc,
 					     struct device_node *parent)
 {
-	u32 nr_irq, intr_mask;
+	u32 nr_irq;
 	int ret;
+	struct xintc_irq_chip *irqc;
+
+	irqc = kzalloc(sizeof(*irqc), GFP_KERNEL);
+	if (!irqc)
+		return -ENOMEM;
+
+	xintc_irqc = irqc;
 
-	intc_baseaddr = of_iomap(intc, 0);
-	BUG_ON(!intc_baseaddr);
+	irqc->base = of_iomap(intc, 0);
+	BUG_ON(!irqc->base);
 
 	ret = of_property_read_u32(intc, "xlnx,num-intr-inputs", &nr_irq);
 	if (ret < 0) {
@@ -150,43 +176,40 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
 		return ret;
 	}
 
-	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &intr_mask);
+	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &irqc->intr_mask);
 	if (ret < 0) {
 		pr_err("%s: unable to read xlnx,kind-of-intr\n", __func__);
 		return ret;
 	}
 
-	if (intr_mask >> nr_irq)
+	if (irqc->intr_mask >> nr_irq)
 		pr_warn("%s: mismatch in kind-of-intr param\n", __func__);
 
 	pr_info("%s: num_irq=%d, edge=0x%x\n",
-		intc->full_name, nr_irq, intr_mask);
+		intc->full_name, nr_irq, irqc->intr_mask);
 
-	write_fn = intc_write32;
-	read_fn = intc_read32;
+	irqc->read = intc_read32;
+	irqc->write = intc_write32;
 
 	/*
 	 * Disable all external interrupts until they are
 	 * explicity requested.
 	 */
-	write_fn(0, intc_baseaddr + IER);
+	xintc_write(irqc, IER, 0);
 
 	/* Acknowledge any pending interrupts just in case. */
-	write_fn(0xffffffff, intc_baseaddr + IAR);
+	xintc_write(irqc, IAR, 0xffffffff);
 
 	/* Turn on the Master Enable. */
-	write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
-	if (!(read_fn(intc_baseaddr + MER) & (MER_HIE | MER_ME))) {
-		write_fn = intc_write32_be;
-		read_fn = intc_read32_be;
-		write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
+	xintc_write(irqc, MER, MER_HIE | MER_ME);
+	if (!(xintc_read(irqc, MER) & (MER_HIE | MER_ME))) {
+		irqc->read = intc_read32_be;
+		irqc->write = intc_write32_be;
+		xintc_write(irqc, MER, MER_HIE | MER_ME);
 	}
 
-	/* Yeah, okay, casting the intr_mask to a void* is butt-ugly, but I'm
-	 * lazy and Michal can clean it up to something nicer when he tests
-	 * and commits this patch.  ~~gcl */
 	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
-							(void *)intr_mask);
+					    irqc);
 
 	irq_set_default_host(root_domain);
 
-- 
1.9.1
